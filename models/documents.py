from sqlalchemy import Column, String, DateTime, func, JSON, Enum, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID
import uuid
import enum
from core.database import Base

class EntityTypeEnum(str, enum.Enum):
    student = "student"
    teacher = "teacher"
    admin = "admin"

class VerificationStatusEnum(str, enum.Enum):
    pending_verification = "pending_verification"
    verified = "verified"
    rejected = "rejected"

class Document(Base):
    __tablename__ = "documents"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    entity_type = Column(Enum(EntityTypeEnum), nullable=False)
    
    student_id = Column(String(20), nullable=True, index=True)
    teacher_id = Column(String(20), nullable=True, index=True)
    admin_id = Column(String(20), nullable=True, index=True)
    
    document_type = Column(String(100), nullable=False, index=True)
    metadata_ = Column("metadata", JSON, default={})
    file_url = Column(String, nullable=False)
    cloudinary_public_id = Column(String(255), nullable=False)
    status = Column(Enum(VerificationStatusEnum), default=VerificationStatusEnum.pending_verification)
    
    uploaded_at = Column(DateTime(timezone=True), server_default=func.now())
    verified_at = Column(DateTime(timezone=True), nullable=True)
    verified_by = Column(String(50), nullable=True)
    rejection_reason = Column(String, nullable=True)

    __table_args__ = (
        CheckConstraint(
            "(entity_type = 'student' AND student_id IS NOT NULL AND teacher_id IS NULL AND admin_id IS NULL) OR "
            "(entity_type = 'teacher' AND teacher_id IS NOT NULL AND student_id IS NULL AND admin_id IS NULL) OR "
            "(entity_type = 'admin' AND admin_id IS NOT NULL AND student_id IS NULL AND teacher_id IS NULL)",
            name="chk_document_entity"
        ),
    )
