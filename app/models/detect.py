from pydantic import BaseModel
from typing import Optional, List

class DetectImageRequest(BaseModel):
    lat: Optional[float] = None
    lng: Optional[float] = None

class DetectImageResponse(BaseModel):
    crop: str = "unknown"
    disease: str
    confidence: float
    remedies: List[str]
    language: str = "en"
    disease_name: str  # Added for AI pipeline
    advisory_text: str  # Added for AI pipeline