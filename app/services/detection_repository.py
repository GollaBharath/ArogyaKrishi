"""Repository for detection events."""

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.sql import func
from ..db.models import DetectionEvent
from typing import List
import math


class DetectionRepository:
    """Repository for detection events."""
    
    @staticmethod
    async def save_event(
        session: AsyncSession,
        crop: str,
        disease: str,
        confidence: float,
        latitude: float = None,
        longitude: float = None
    ) -> DetectionEvent:
        """Save a detection event to database."""
        event = DetectionEvent(
            crop=crop,
            disease=disease,
            confidence=confidence,
            latitude=latitude,
            longitude=longitude
        )
        session.add(event)
        await session.commit()
        await session.refresh(event)
        return event
    
    @staticmethod
    async def get_events_within_radius(
        session: AsyncSession,
        latitude: float,
        longitude: float,
        radius_km: float = 10.0
    ) -> List[DetectionEvent]:
        """Get detection events within a geographic radius."""
        if latitude is None or longitude is None:
            # If no location provided, return recent events
            query = select(DetectionEvent).order_by(DetectionEvent.created_at.desc()).limit(50)
        else:
            # Haversine formula approximation for distance
            # For simplicity, using basic lat/lng distance
            lat_delta = radius_km / 111.0  # 1 degree latitude ≈ 111 km
            lng_delta = radius_km / (111.0 * math.cos(math.radians(latitude)))
            
            query = select(DetectionEvent).where(
                (DetectionEvent.latitude >= latitude - lat_delta) &
                (DetectionEvent.latitude <= latitude + lat_delta) &
                (DetectionEvent.longitude >= longitude - lng_delta) &
                (DetectionEvent.longitude <= longitude + lng_delta)
            ).order_by(DetectionEvent.created_at.desc()).limit(100)
        
        result = await session.execute(query)
        return result.scalars().all()
    
    @staticmethod
    async def get_recent_events(
        session: AsyncSession,
        limit: int = 50
    ) -> List[DetectionEvent]:
        """Get recent detection events."""
        query = select(DetectionEvent).order_by(DetectionEvent.created_at.desc()).limit(limit)
        result = await session.execute(query)
        return result.scalars().all()
