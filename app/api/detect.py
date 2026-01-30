from fastapi import APIRouter, UploadFile, File, HTTPException, Form
from PIL import Image
import io
from typing import Optional

from models.detect import DetectImageRequest, DetectImageResponse
from services.disease_detection import detect_disease, get_advisory_from_ollama

router = APIRouter()

@router.post("/detect-image", response_model=DetectImageResponse)
async def detect_image(
    image: UploadFile = File(...),
    lat: Optional[float] = Form(None),
    lng: Optional[float] = Form(None)
):
    # Validate file type
    if not image.content_type in ["image/jpeg", "image/png", "image/jpg"]:
        raise HTTPException(status_code=400, detail="Invalid file type. Only JPEG and PNG allowed.")
    
    # Read image
    try:
        contents = await image.read()
        img = Image.open(io.BytesIO(contents))
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid image file.")
    
    # Detect disease
    try:
        disease_name, confidence = detect_disease(img)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Disease detection failed: {str(e)}")
    
    # Get advisory
    advisory_text = get_advisory_from_ollama(disease_name)
    
    # For now, mock other fields as per original API
    # But extend with disease_name and advisory_text
    response = DetectImageResponse(
        crop="unknown",  # Could be detected, but for now unknown
        disease=disease_name,  # Use cleaned name
        confidence=confidence,
        remedies=[],  # Could parse from advisory, but for now empty
        language="en",
        disease_name=disease_name,
        advisory_text=advisory_text
    )
    
    return response