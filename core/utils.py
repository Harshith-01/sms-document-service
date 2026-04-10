import os

import cloudinary.uploader
import cloudinary.api
from fastapi import UploadFile, HTTPException

# Load Cloudinary credentials from environment before any upload/delete call.
from core import cloudinary_config  # noqa: F401

def upload_document_to_cloudinary(file: UploadFile, folder: str = "documents"):
    """
    Uploads a file to Cloudinary and returns the URL and public ID.
    """
    try:
        if not (os.getenv("CLOUDINARY_CLOUD_NAME") and os.getenv("CLOUDINARY_API_KEY") and os.getenv("CLOUDINARY_API_SECRET")):
            raise HTTPException(status_code=503, detail="Document storage service is not configured")

        # Read the file content
        file_content = file.file.read()
        
        # Upload to Cloudinary
        result = cloudinary.uploader.upload(
            file_content,
            folder=folder,
            resource_type="auto"  # Automatically detect resource type (image, raw, video, etc.)
        )
        
        return {
            "file_url": result.get("secure_url"),
            "cloudinary_public_id": result.get("public_id")
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=503, detail="Document storage service is temporarily unavailable")
    finally:
        # Important: Reset file pointer or close after reading
        file.file.close()

def delete_document_from_cloudinary(public_id: str):
    """
    Deletes a file from Cloudinary using its public ID.
    """
    try:
        if not (os.getenv("CLOUDINARY_CLOUD_NAME") and os.getenv("CLOUDINARY_API_KEY") and os.getenv("CLOUDINARY_API_SECRET")):
            raise HTTPException(status_code=503, detail="Document storage service is not configured")

        result = cloudinary.uploader.destroy(public_id)
        return result
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=503, detail="Document storage service is temporarily unavailable")
