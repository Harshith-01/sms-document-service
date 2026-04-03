import json
import logging
from datetime import datetime, timezone
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from sqlalchemy import text

from core.database import get_db
from models.documents import Document, EntityTypeEnum, VerificationStatusEnum
from schemas.documents import DocumentResponse, DocumentUpdateStatus
from core.utils import upload_document_to_cloudinary, delete_document_from_cloudinary
from core.security import get_current_user

router = APIRouter(prefix="/api/documents", tags=["Documents"])
logger = logging.getLogger(__name__)

SUPPORTED_ENTITY_TYPES = {EntityTypeEnum.student, EntityTypeEnum.teacher}


def _normalize_role(role: str | None) -> str:
    value = (role or "").strip().upper()
    if value == "SUPER_ADMIN":
        return "SUPERADMIN"
    return value


def _is_admin_role(role: str) -> bool:
    normalized = _normalize_role(role)
    return normalized in {"ADMIN", "SUPERADMIN"}


def _resolve_entity_id_for_user(db: Session, role: str, user_id: str) -> tuple[EntityTypeEnum, str] | None:
    normalized_role = _normalize_role(role)

    if normalized_role == "STUDENT":
        row = db.execute(
            text("SELECT id FROM public.students WHERE user_id = :user_id LIMIT 1"),
            {"user_id": user_id},
        ).first()
        return (EntityTypeEnum.student, row[0]) if row else None

    if normalized_role == "TEACHER":
        row = db.execute(
            text("SELECT id FROM public.teachers WHERE user_id = :user_id LIMIT 1"),
            {"user_id": user_id},
        ).first()
        return (EntityTypeEnum.teacher, row[0]) if row else None

    return None


def _owner_filter(query, entity_type: EntityTypeEnum, entity_id: str):
    if entity_type == EntityTypeEnum.student:
        return query.filter(Document.student_id == entity_id)
    if entity_type == EntityTypeEnum.teacher:
        return query.filter(Document.teacher_id == entity_id)
    if entity_type == EntityTypeEnum.staff:
        return query.filter(Document.staff_id == entity_id)
    return query.filter(Document.parent_id == entity_id)


def _enforce_supported_entity(entity_type: EntityTypeEnum) -> None:
    if entity_type not in SUPPORTED_ENTITY_TYPES:
        raise HTTPException(
            status_code=400,
            detail="For MVP, documents are supported only for student and teacher entities.",
        )


def _ensure_owner_access(db: Session, user: dict, entity_type: EntityTypeEnum, entity_id: str) -> None:
    role = user.get("role", "")
    if _is_admin_role(role):
        return

    resolved = _resolve_entity_id_for_user(db, role, user.get("user_id", ""))
    if not resolved:
        raise HTTPException(status_code=403, detail="You are not allowed to access this entity")

    resolved_type, resolved_entity_id = resolved
    if resolved_type != entity_type or resolved_entity_id != entity_id:
        raise HTTPException(status_code=403, detail="You can only access your own documents")

@router.post("/upload", response_model=DocumentResponse)
async def upload_document(
    entity_type: EntityTypeEnum = Form(...),
    entity_id: str | None = Form(default=None, description="The ID of the target student or teacher"),
    document_type: str = Form(...),
    is_profile_photo: bool = Form(default=False),
    metadata_json: str = Form(default="{}"),
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    user: dict = Depends(get_current_user),
):
    _enforce_supported_entity(entity_type)

    role = user.get("role", "")
    actor_user_id = user.get("user_id", "")

    if _is_admin_role(role):
        if not entity_id:
            raise HTTPException(status_code=400, detail="entity_id is required for admin uploads")
    else:
        resolved = _resolve_entity_id_for_user(db, role, actor_user_id)
        if not resolved:
            raise HTTPException(status_code=403, detail="Only ADMIN, STUDENT, or TEACHER can upload documents")

        resolved_type, resolved_entity_id = resolved
        if resolved_type != entity_type:
            raise HTTPException(status_code=403, detail="You can upload only for your own role entity type")

        if entity_id and entity_id != resolved_entity_id:
            raise HTTPException(status_code=403, detail="You can upload only for your own entity")

        entity_id = resolved_entity_id

    if not entity_id:
        raise HTTPException(status_code=400, detail="entity_id is required")

    try:
        metadata_dict = json.loads(metadata_json)
    except json.JSONDecodeError:
        raise HTTPException(status_code=400, detail="Invalid JSON format for metadata")

    # Upload to Cloudinary first; DB rollback cleanup is handled below.
    upload_result = upload_document_to_cloudinary(file, folder=f"documents/{entity_type.value}/{entity_id}")

    # Ensure only one active profile photo per entity by soft-deleting previous one.
    if is_profile_photo:
        existing_photo = _owner_filter(
            db.query(Document).filter(
                Document.entity_type == entity_type,
                Document.is_profile_photo.is_(True),
                Document.deleted_at.is_(None),
            ),
            entity_type,
            entity_id,
        ).first()

        if existing_photo:
            existing_photo.deleted_at = datetime.now(timezone.utc)
            try:
                delete_document_from_cloudinary(existing_photo.cloudinary_public_id)
            except HTTPException:
                logger.warning("failed_to_delete_previous_profile_photo", exc_info=True)

    status = VerificationStatusEnum.verified if is_profile_photo else VerificationStatusEnum.pending_verification
    verified_at = datetime.now(timezone.utc) if is_profile_photo else None
    verified_by = actor_user_id if is_profile_photo else None

    student_id = entity_id if entity_type == EntityTypeEnum.student else None
    teacher_id = entity_id if entity_type == EntityTypeEnum.teacher else None

    new_doc = Document(
        entity_type=entity_type,
        document_type=document_type,
        is_profile_photo=is_profile_photo,
        metadata_=metadata_dict,
        file_url=upload_result["file_url"],
        cloudinary_public_id=upload_result["cloudinary_public_id"],
        student_id=student_id,
        teacher_id=teacher_id,
        status=status,
        verified_at=verified_at,
        verified_by=verified_by,
    )
    db.add(new_doc)

    try:
        db.commit()
    except Exception as exc:
        db.rollback()
        delete_document_from_cloudinary(upload_result["cloudinary_public_id"])
        raise HTTPException(
            status_code=400,
            detail=(
                f"Database error. This usually means the {entity_type.value} with ID '{entity_id}' "
                f"does not exist in the base table. ({str(exc)})"
            ),
        )

    db.refresh(new_doc)
    return new_doc

@router.get("/{entity_type}/{entity_id}", response_model=list[DocumentResponse])
def get_documents_by_entity(
    entity_type: EntityTypeEnum,
    entity_id: str,
    db: Session = Depends(get_db),
    user: dict = Depends(get_current_user),
):
    _enforce_supported_entity(entity_type)
    _ensure_owner_access(db, user, entity_type, entity_id)

    query = db.query(Document).filter(
        Document.entity_type == entity_type,
        Document.deleted_at.is_(None),
    )
    query = _owner_filter(query, entity_type, entity_id)
    return query.order_by(Document.uploaded_at.desc()).all()

@router.delete("/{document_id}")
def delete_document(
    document_id: UUID,
    db: Session = Depends(get_db),
    user: dict = Depends(get_current_user),
):
    doc = db.query(Document).filter(Document.id == document_id, Document.deleted_at.is_(None)).first()
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")

    role = user.get("role", "")
    if not _is_admin_role(role):
        resolved = _resolve_entity_id_for_user(db, role, user.get("user_id", ""))
        if not resolved:
            raise HTTPException(status_code=403, detail="You are not allowed to delete this document")
        resolved_type, resolved_entity_id = resolved

        owned = (
            (resolved_type == EntityTypeEnum.student and doc.entity_type == EntityTypeEnum.student and doc.student_id == resolved_entity_id)
            or
            (resolved_type == EntityTypeEnum.teacher and doc.entity_type == EntityTypeEnum.teacher and doc.teacher_id == resolved_entity_id)
        )
        if not owned:
            raise HTTPException(status_code=403, detail="You can delete only your own documents")

    try:
        delete_document_from_cloudinary(doc.cloudinary_public_id)
    except HTTPException:
        logger.warning("failed_to_delete_cloudinary_asset", exc_info=True)

    doc.deleted_at = datetime.now(timezone.utc)
    db.commit()
    return {"message": "Document deleted successfully"}

@router.patch("/{document_id}/status", response_model=DocumentResponse)
def update_document_status(
    document_id: UUID,
    status_update: DocumentUpdateStatus,
    db: Session = Depends(get_db),
    user: dict = Depends(get_current_user),
):
    if not _is_admin_role(user.get("role", "")):
        raise HTTPException(status_code=403, detail="Only ADMIN or SUPERADMIN can verify/reject documents")

    doc = db.query(Document).filter(Document.id == document_id, Document.deleted_at.is_(None)).first()
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")

    if doc.is_profile_photo:
        raise HTTPException(status_code=400, detail="Profile photos are auto-verified and cannot be manually verified/rejected")

    doc.status = status_update.status
    doc.rejection_reason = status_update.rejection_reason

    if doc.status == VerificationStatusEnum.verified:
        doc.verified_at = datetime.now(timezone.utc)
        doc.verified_by = status_update.verified_by or user.get("user_id")
    else:
        doc.verified_at = None
        doc.verified_by = None

    db.commit()
    db.refresh(doc)
    return doc
