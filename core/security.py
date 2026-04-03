import os
from secrets import compare_digest

from fastapi import Depends, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt

SECRET_KEY = os.getenv("SECRET_KEY", "")
ALGORITHM = "HS256"
INTERNAL_SERVICE_TOKEN = os.getenv("INTERNAL_SERVICE_TOKEN", "")
INTERNAL_ALLOWED_SERVICES = {
    service.strip()
    for service in os.getenv("INTERNAL_ALLOWED_SERVICES", "").split(",")
    if service.strip()
}

bearer_scheme = HTTPBearer(auto_error=True)

ROLE_ALIASES = {
    "SUPER_ADMIN": "SUPERADMIN",
}


def _normalize_role(role: str | None) -> str:
    if not role:
        return ""
    return ROLE_ALIASES.get(role, role)


def _has_required_role(actual_role: str, allowed_roles: list[str]) -> bool:
    actual = _normalize_role(actual_role)
    allowed = {_normalize_role(item) for item in allowed_roles}

    if actual == "SUPERADMIN":
        return True

    if "ADMIN" in allowed and actual in {"ADMIN", "SUPERADMIN"}:
        return True

    return actual in allowed


def get_current_user(
    request: Request,
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
):
    token = credentials.credentials

    if INTERNAL_SERVICE_TOKEN and compare_digest(token, INTERNAL_SERVICE_TOKEN):
        service_name = (request.headers.get("x-internal-service", "unknown").strip() or "unknown")
        if INTERNAL_ALLOWED_SERVICES and service_name not in INTERNAL_ALLOWED_SERVICES:
            raise HTTPException(status_code=403, detail="Service identity is not allowed")

        return {
            "user_id": f"svc:{service_name}",
            "role": "SERVICE",
            "principal_type": "service",
            "service_name": service_name,
        }

    if not SECRET_KEY:
        raise HTTPException(status_code=503, detail="SECRET_KEY is not configured")

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("sub")
        role = payload.get("role")

        if not user_id or not role:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token payload")

        return {"user_id": user_id, "role": role, "claims": payload}
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid or expired token")


def require_role(allowed_roles: list[str]):
    def checker(user=Depends(get_current_user)):
        if not _has_required_role(user.get("role", ""), allowed_roles):
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Insufficient permissions")
        return user

    return checker
