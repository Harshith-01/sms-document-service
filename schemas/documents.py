from pydantic import BaseModel, ConfigDict
from typing import Optional, Dict, Any
from datetime import datetime
from uuid import UUID
from models.documents import EntityTypeEnum, VerificationStatusEnum

class DocumentBase(BaseModel):
    entity_type: EntityTypeEnum
    student_id: Optional[str] = None
    teacher_id: Optional[str] = None
    admin_id: Optional[str] = None
    document_type: str
    metadata_: Optional[Dict[str, Any]] = None

class DocumentResponse(DocumentBase):
    id: UUID
    file_url: str
    cloudinary_public_id: str
    status: VerificationStatusEnum
    uploaded_at: datetime
    verified_at: Optional[datetime] = None
    verified_by: Optional[str] = None
    rejection_reason: Optional[str] = None

    model_config = ConfigDict(from_attributes=True, populate_by_name=True)

class DocumentUpdateStatus(BaseModel):
    status: VerificationStatusEnum
    verified_by: Optional[str] = None
    rejection_reason: Optional[str] = None
