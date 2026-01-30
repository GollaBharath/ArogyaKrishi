"""Detection API routes (multipart-free)."""

import logging
from fastapi import APIRouter, File, UploadFile, Query, Depends, HTTPException, status, Body, Form
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Optional

from ..models.schemas import DetectImageResponse, NearbyAlertsResponse, ScanTreatmentResponse
from ..services.detection_service import DetectionService
from ..services.remedy_service import RemedyService
from ..db.session import get_db
from ..config import settings

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api", tags=["detection"])


@router.post("/detect-image", response_model=DetectImageResponse)
async def detect_image(
    image: UploadFile = File(..., description="Image file (jpg/png)"),
    lat: Optional[float] = Query(None, description="Latitude"),
    lng: Optional[float] = Query(None, description="Longitude"),
    language: str = Query("en", description="Language: en, te, hi, kn, ml"),
    db_session: AsyncSession = Depends(get_db),
) -> DetectImageResponse:
    """
    Detect plant disease from an uploaded image.
    
    - **image**: Image file (jpg/png)
    - **lat**: Optional latitude
    - **lng**: Optional longitude
    - **language**: Response language (en, te, hi, kn, ml)
    """
    try:
        logger.info(f"Received detect-image request - filename: {image.filename}, content_type: {image.content_type}")
        
        # Read image bytes
        image_bytes = await image.read()
        
        # Validate image type
        if image.content_type and image.content_type not in ["image/jpeg", "image/png"]:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid image type: {image.content_type}. Allowed: image/jpeg, image/png"
            )

        result = await DetectionService.detect_disease(
            image_bytes=image_bytes,
            latitude=lat,
            longitude=lng,
            language=language,
            db_session=db_session,
        )

        return DetectImageResponse(**result)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error detecting disease: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error processing image",
        )


@router.get("/nearby-alerts", response_model=NearbyAlertsResponse)
async def get_nearby_alerts(
    lat: Optional[float] = Query(None, description="Latitude"),
    lng: Optional[float] = Query(None, description="Longitude"),
    radius: float = Query(10.0, description="Search radius in km"),
    db_session: AsyncSession = Depends(get_db),
) -> NearbyAlertsResponse:
    """
    Get disease alerts detected nearby.
    """
    try:
        result = await DetectionService.get_nearby_alerts(
            latitude=lat,
            longitude=lng,
            radius_km=radius,
            db_session=db_session,
        )
        return NearbyAlertsResponse(**result)

    except Exception as e:
        logger.error(f"Error retrieving alerts: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error retrieving nearby alerts",
        )


@router.post("/scan-treatment", response_model=ScanTreatmentResponse)
async def scan_treatment(
    image: UploadFile = File(...),
    disease: str = Form(..., description="Disease name (localized or English key)"),
    item_label: Optional[str] = Form(None, description="Scanned item/product name"),
    language: str = Form("en", description="Language: en, te, hi, kn, ml")
) -> ScanTreatmentResponse:
    """
    Scan a fertilizer/medicine item and provide feedback if it can treat the disease.

    - **image**: Image file (jpg/png)
    - **disease**: Disease name (localized or English key)
    - **item_label**: Scanned item/product name
    - **language**: Response language (en, te, hi, kn, ml)
    """
    try:
        logger.info(f"Received scan-treatment request - filename: {image.filename}, content_type: {image.content_type}")
        logger.info(f"Disease: {disease}, Item Label: '{item_label}', Language: {language}")

        if not image.content_type or image.content_type not in ["image/jpeg", "image/png"]:
            logger.warning(f"Invalid content type: {image.content_type}")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid image format. Please upload JPG or PNG."
            )

        max_size = settings.max_image_size_mb * 1024 * 1024
        contents = await image.read()
        if len(contents) > max_size:
            raise HTTPException(
                status_code=status.HTTP_413_PAYLOAD_TOO_LARGE,
                detail=f"Image too large. Maximum size: {settings.max_image_size_mb}MB"
            )

        result = RemedyService.evaluate_treatment(
            disease=disease,
            item_label=item_label,
            language=language
        )

        return ScanTreatmentResponse(**result)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error evaluating treatment: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error evaluating treatment"
        )
