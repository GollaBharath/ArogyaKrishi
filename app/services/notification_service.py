"""
Notification service (stub) for sending push notifications.

Provides a simple async stub `send_push_notification` that would be
replaced by a real push provider in production.
"""
from __future__ import annotations

import asyncio
from typing import Any


async def send_push_notification(device_token: str, title: str, body: str) -> bool:
    """Stub: send a push notification.

    Args:
        device_token: Recipient device token (provider-specific).
        title: Notification title.
        body: Notification body.

    Returns:
        True when the notification would have been sent successfully, False otherwise.

    Note: This is a synchronous stub made async to keep the real interface.
    """

    # No token -> cannot send
    if not device_token:
        return False

    # Simulate network delay for a push provider call
    await asyncio.sleep(0.01)

    # Here we would integrate with FCM/APNs or another provider.
    # For the MVP we just log (print) and return success.
    print(f"[notification] to={device_token} title={title!r} body={body!r}")

    return True
