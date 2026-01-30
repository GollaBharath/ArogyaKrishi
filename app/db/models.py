"""ORM models for ArogyaKrishi."""

from sqlalchemy import Column, String, Float, DateTime, Integer
from sqlalchemy.sql import func
from datetime import datetime
from .session import Base


class DetectionEvent(Base):
    """Detection event model."""
    
    __tablename__ = "detection_events"
    
    id = Column(Integer, primary_key=True, index=True)
    crop = Column(String, nullable=False)
    disease = Column(String, nullable=False)
    confidence = Column(Float, nullable=False)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
