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
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to upload document to Cloudinary: {str(e)}")
    finally:
        # Important: Reset file pointer or close after reading
        file.file.close()

def delete_document_from_cloudinary(public_id: str):
    """
    Deletes a file from Cloudinary using its public ID.
    """
    try:
        result = cloudinary.uploader.destroy(public_id)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to delete document from Cloudinary: {str(e)}")
