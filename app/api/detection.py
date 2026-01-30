"""Detection API routes."""

import logging
from fastapi import APIRouter, File, UploadFile, Query, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Optional

from ..models.schemas import DetectImageResponse, NearbyAlertsResponse
from ..services.detection_service import DetectionService
from ..db.session import get_db
from ..config import settings

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api", tags=["detection"])


@router.post("/detect-image", response_model=DetectImageResponse)
async def detect_image(
    image: UploadFile = File(...),
    lat: Optional[float] = Query(None, description="Latitude"),
    lng: Optional[float] = Query(None, description="Longitude"),
    language: str = Query("en", description="Language: en, te, hi"),
    db_session: AsyncSession = Depends(get_db)
) -> DetectImageResponse:
    """
    Detect plant disease from an uploaded image.
    
    - **image**: Image file (jpg/png)
    - **lat**: Optional latitude
    - **lng**: Optional longitude
    - **language**: Response language (en, te, hi)
    """
    try:
        # Log request details
        logger.info(f"Received detect-image request - filename: {image.filename}, content_type: {image.content_type}")
        
        # Validate file type
        if not image.content_type or image.content_type not in ["image/jpeg", "image/png"]:
            logger.warning(f"Invalid content type: {image.content_type}")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid image format. Please upload JPG or PNG."
            )
        
        # Validate file size
        max_size = settings.max_image_size_mb * 1024 * 1024
        contents = await image.read()
        if len(contents) > max_size:
            raise HTTPException(
                status_code=status.HTTP_413_PAYLOAD_TOO_LARGE,
                detail=f"Image too large. Maximum size: {settings.max_image_size_mb}MB"
            )
        
        # Run detection
        result = await DetectionService.detect_disease(
            image_bytes=contents,
            latitude=lat,
            longitude=lng,
            language=language,
            db_session=db_session
        )
        
        return DetectImageResponse(**result)
    
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error detecting disease: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error processing image"
        )


@router.get("/nearby-alerts", response_model=NearbyAlertsResponse)
async def get_nearby_alerts(
    lat: Optional[float] = Query(None, description="Latitude"),
    lng: Optional[float] = Query(None, description="Longitude"),
    radius: float = Query(10.0, description="Search radius in km"),
    db_session: AsyncSession = Depends(get_db)
) -> NearbyAlertsResponse:
    """
    Get disease alerts detected nearby.
    
    - **lat**: Optional latitude
    - **lng**: Optional longitude
    - **radius**: Search radius in kilometers (default: 10)
    """
    try:
        result = await DetectionService.get_nearby_alerts(
            latitude=lat,
            longitude=lng,
            radius_km=radius,
            db_session=db_session
        )
        
        return NearbyAlertsResponse(**result)
    
    except Exception as e:
        logger.error(f"Error retrieving alerts: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error retrieving nearby alerts"
        )
