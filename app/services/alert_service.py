"""
Alert processing service for detection events.

Exports:
- async def process_detection_event(event, session): process a DetectionEvent and
  send notifications to nearby users according to business rules.
"""
from __future__ import annotations

from datetime import datetime, timedelta, timezone
from typing import Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.user import User
from app.models.sent_alert import SentAlert
from app.models.detection_event import DetectionEvent
from app.services.notification_service import send_push_notification
from app.utils.geo import haversine_km


# Notification message constants
_NOTIFICATION_TITLE = "Crop Health Alert"
_NOTIFICATION_BODY = (
    "A crop disease was reported near your area. Please monitor your crops."
)


async def process_detection_event(event: DetectionEvent, session: AsyncSession) -> None:
    """Process a detection event and notify eligible nearby users.

    Rules implemented:
    - Only proceed if event.confidence >= 0.75
    - Find users within 2 km of the event location
    - Skip users who have notifications_enabled = False
    - Skip users already alerted for the same disease within 24 hours

    Args:
        event: DetectionEvent ORM instance.
        session: AsyncSession used for DB queries and mutations.
    """

    # Proceed only for high-confidence detections
    if event.confidence is None or event.confidence < 0.75:
        return

    # Timestamp cutoff for duplicate alerts (24 hours ago, UTC)
    now = datetime.now(timezone.utc)
    cutoff = now - timedelta(hours=24)

    # Load all users who have notifications enabled
    stmt = select(User).where(User.notifications_enabled.is_(True))
    result = await session.execute(stmt)
    users = result.scalars().all()

    # Loop through candidates and process each one
    for user in users:
        # Must have a device token to receive push
        if not user.device_token:
            continue

        # Compute distance (in km) using the Haversine formula
        distance_km = haversine_km(
            event.latitude, event.longitude, user.latitude, user.longitude
        )

        # Skip users outside the 2 km radius
        if distance_km > 2.0:
            continue

        # Check if we've already sent an alert for this disease to this user in the last 24 hours
        dup_stmt = (
            select(SentAlert)
            .where(
                SentAlert.user_id == user.id,
                SentAlert.disease == event.disease,
                SentAlert.sent_at >= cutoff,
            )
            .limit(1)
        )
        dup_res = await session.execute(dup_stmt)
        recent = dup_res.scalar_one_or_none()
        if recent is not None:
            # Recent alert exists, skip
            continue

        # Send the notification (stub)
        sent = await send_push_notification(user.device_token, _NOTIFICATION_TITLE, _NOTIFICATION_BODY)

        # Record the sent alert only if send succeeded
        if sent:
            new_alert = SentAlert(user_id=user.id, disease=event.disease)
            session.add(new_alert)
            # Commit per alert to ensure it's persisted and to avoid duplicate sends on retries
            await session.commit()
