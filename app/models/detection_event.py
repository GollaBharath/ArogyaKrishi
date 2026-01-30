"""
DetectionEvent model for ArogyaKrishi (async SQLAlchemy ORM).
"""
from sqlalchemy import Column, Integer, Float, String, DateTime, func

from . import Base


class DetectionEvent(Base):
    __tablename__ = "detection_events"

    id = Column(Integer, primary_key=True, index=True)
    disease = Column(String, nullable=False)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    confidence = Column(Float, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
