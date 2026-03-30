from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from uuid import UUID
import json

from core.database import get_db
from models.documents import Document, EntityTypeEnum, VerificationStatusEnum
from schemas.documents import DocumentResponse, DocumentUpdateStatus
from core.utils import upload_document_to_cloudinary, delete_document_from_cloudinary

router = APIRouter(prefix="/api/documents", tags=["Documents"])

@router.post("/upload", response_model=DocumentResponse)
async def upload_document(
    entity_type: EntityTypeEnum = Form(...),
    entity_id: str = Form(..., description="The ID of the student, teacher, or admin"),
    document_type: str = Form(...),
    metadata_json: str = Form(default="{}"),
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    try:
        metadata_dict = json.loads(metadata_json)
    except json.JSONDecodeError:
        raise HTTPException(status_code=400, detail="Invalid JSON format for metadata")

    # Upload to Cloudinary
    upload_result = upload_document_to_cloudinary(file, folder=f"documents/{entity_type.value}/{entity_id}")
    
    # Save metadata to Database
    new_doc = Document(
        entity_type=entity_type,
        document_type=document_type,
        metadata_=metadata_dict,
        file_url=upload_result["file_url"],
        cloudinary_public_id=upload_result["cloudinary_public_id"],
        student_id=entity_id if entity_type == EntityTypeEnum.student else None,
        teacher_id=entity_id if entity_type == EntityTypeEnum.teacher else None,
        admin_id=entity_id if entity_type == EntityTypeEnum.admin else None
    )
    db.add(new_doc)
    
    try:
        db.commit()
    except Exception as e:
        db.rollback()
        # Clean up Cloudinary file if DB fails
        delete_document_from_cloudinary(upload_result["cloudinary_public_id"])
        raise HTTPException(status_code=400, detail=f"Database error. This usually means the {entity_type.value} with ID '{entity_id}' does not exist in the base table. ({str(e)})")
        
    db.refresh(new_doc)
    return new_doc

@router.get("/{entity_type}/{entity_id}", response_model=list[DocumentResponse])
def get_documents_by_entity(entity_type: EntityTypeEnum, entity_id: str, db: Session = Depends(get_db)):
    query = db.query(Document).filter(Document.entity_type == entity_type)
    if entity_type == EntityTypeEnum.student:
        query = query.filter(Document.student_id == entity_id)
    elif entity_type == EntityTypeEnum.teacher:
        query = query.filter(Document.teacher_id == entity_id)
    elif entity_type == EntityTypeEnum.admin:
        query = query.filter(Document.admin_id == entity_id)
    
    docs = query.all()
    return docs

@router.delete("/{document_id}")
def delete_document(document_id: UUID, db: Session = Depends(get_db)):
    doc = db.query(Document).filter(Document.id == document_id).first()
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")
    
    # Delete from Cloudinary
    delete_document_from_cloudinary(doc.cloudinary_public_id)
    
    # Delete from Database
    db.delete(doc)
    db.commit()
    return {"message": "Document deleted successfully"}

@router.patch("/{document_id}/status", response_model=DocumentResponse)
def update_document_status(document_id: UUID, status_update: DocumentUpdateStatus, db: Session = Depends(get_db)):
    doc = db.query(Document).filter(Document.id == document_id).first()
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")
    
    doc.status = status_update.status
    if status_update.verified_by:
        doc.verified_by = status_update.verified_by
    if status_update.rejection_reason:
        doc.rejection_reason = status_update.rejection_reason
    
    from datetime import datetime, timezone
    if doc.status == VerificationStatusEnum.verified:
        doc.verified_at = datetime.now(timezone.utc)
    
    db.commit()
    db.refresh(doc)
    return doc
