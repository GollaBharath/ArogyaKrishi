"""Detection API routes (multipart-free)."""

import logging
from fastapi import APIRouter, Query, Depends, HTTPException, status, Body
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Optional

from ..models.schemas import DetectImageResponse, NearbyAlertsResponse
from ..services.detection_service import DetectionService
from ..db.session import get_db

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api", tags=["detection"])


@router.post("/detect-image", response_model=DetectImageResponse)
async def detect_image(
    image_bytes: str = Body(..., description="Stub image content"),
    lat: Optional[float] = Query(None, description="Latitude"),
    lng: Optional[float] = Query(None, description="Longitude"),
    language: str = Query("en", description="Language: en, te, hi"),
    db_session: AsyncSession = Depends(get_db),
) -> DetectImageResponse:
    """
    Detect plant disease (HACKATHON MODE).

    NOTE:
    - No file uploads
    - No multipart/form-data
    - No python-multipart dependency
    - Image content is stubbed
    """
    try:
        logger.info("Received detect-image request (stub mode)")

        result = await DetectionService.detect_disease(
            image_bytes=image_bytes.encode(),
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
