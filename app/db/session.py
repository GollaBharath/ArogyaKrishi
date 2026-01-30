"""Database session management."""

import os
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.orm import declarative_base

# PostgreSQL connection URL
# Default: postgresql+psycopg://user:password@localhost:5432/arogya_krishi
DATABASE_URL = os.getenv(
    "DATABASE_URL", 
    "postgresql+psycopg://arogya_user:arogya_password@localhost:5432/arogya_krishi"
)

engine = create_async_engine(
    DATABASE_URL,
    echo=False,
    future=True,
)

AsyncSessionLocal = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
)

Base = declarative_base()


async def get_db() -> AsyncSession:
    """Get async database session."""
    async with AsyncSessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()

