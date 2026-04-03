"""
Document Service – Production Entry Point
Features:
- Global rate limiting (SlowAPI)
- Secure headers
- Request size limiting (important for file uploads)
- Strict CORS (env-controlled)
- Trusted host protection (env-controlled)
"""

from dotenv import load_dotenv
load_dotenv(override=False)

import os
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from starlette.responses import JSONResponse
from slowapi import Limiter
from slowapi.util import get_remote_address
from slowapi.middleware import SlowAPIMiddleware
from slowapi.errors import RateLimitExceeded

from api.routes import router
from core.security_middleware import (
    RequestSizeLimitMiddleware,
    SecurityHeadersMiddleware
)

app = FastAPI(
    title="Document Service",
    docs_url="/docs",
    redoc_url=None
)

# ============================================================
# GLOBAL RATE LIMITER
# ============================================================
limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter

app.add_middleware(SlowAPIMiddleware)

app.add_exception_handler(
    RateLimitExceeded,
    lambda request, exc: JSONResponse(
        status_code=429,
        content={"detail": "Too many requests. Please try again later."},
    ),
)

# ============================================================
# SECURITY MIDDLEWARE
# ============================================================
# Allow max 15MB for document uploads
app.add_middleware(RequestSizeLimitMiddleware, max_upload_size=15_000_000)
app.add_middleware(SecurityHeadersMiddleware)

# ============================================================
# CORS
# ============================================================
ALLOWED_ORIGINS = os.getenv("ALLOWED_ORIGINS", "")
origins = [origin.strip() for origin in ALLOWED_ORIGINS.split(",") if origin]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type", "X-Internal-Service"],
)

# ============================================================
# TRUSTED HOST PROTECTION
# ============================================================
ALLOWED_HOSTS = os.getenv("ALLOWED_HOSTS", "localhost").split(",")

app.add_middleware(
    TrustedHostMiddleware,
    allowed_hosts=[host.strip() for host in ALLOWED_HOSTS]
)

# ============================================================
# ROUTES
# ============================================================
app.include_router(router)

# ============================================================
# HEALTH CHECK
# ============================================================
@app.get("/health")
@limiter.limit("20/minute")
def health_check(request: Request):
    return {
        "status": "ok",
        "service": "document_service"
    }
