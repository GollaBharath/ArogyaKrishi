"""Database initialization utility for PostgreSQL."""

import asyncio
import logging
from app.db.session import engine, Base
from app.db.models import DetectionEvent, User, SentAlert

logger = logging.getLogger(__name__)


async def init_db():
    """
    Initialize the PostgreSQL database with all tables.
    
    This creates the schema for:
    - detection_events: Disease detection records with location data
    - users: Device/user profiles for notifications (optional)
    - sent_alerts: Alert delivery tracking (optional)
    """
    async with engine.begin() as conn:
        logger.info("Creating database tables...")
        await conn.run_sync(Base.metadata.create_all)
        logger.info("✓ Database tables created successfully")


async def drop_all():
    """
    Drop all tables (for development/testing only).
    WARNING: This will delete all data.
    """
    async with engine.begin() as conn:
        logger.warning("Dropping all database tables...")
        await conn.run_sync(Base.metadata.drop_all)
        logger.warning("✓ All tables dropped")


async def main():
    """Run database initialization."""
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == "drop":
        await drop_all()
    else:
        await init_db()
    
    await engine.dispose()


if __name__ == "__main__":
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    )
    asyncio.run(main())
