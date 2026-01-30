"""Pydantic models for API requests/responses."""

from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime


class DetectImageResponse(BaseModel):
    """Response model for /detect-image endpoint."""
    crop: str
    disease: str
    confidence: float
    remedies: List[str]
    language: str


class AlertData(BaseModel):
    """Alert item model."""
    disease: str
    distance_km: Optional[float] = None
    timestamp: Optional[str] = None


class NearbyAlertsResponse(BaseModel):
    """Response model for /nearby-alerts endpoint."""
    alerts: List[AlertData]


class ScanTreatmentResponse(BaseModel):
    """Response model for /scan-treatment endpoint."""
    disease: str
    language: str
    item_label: Optional[str] = None
    will_cure: bool
    feedback: str
