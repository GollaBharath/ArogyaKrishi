"""
User model for ArogyaKrishi (async SQLAlchemy ORM).
"""
from sqlalchemy import Column, Integer, Float, String, Boolean
from sqlalchemy.orm import relationship

from . import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    device_token = Column(String, nullable=True)
    notifications_enabled = Column(Boolean, nullable=False, default=True)

    # Relationship to sent alerts
    sent_alerts = relationship("SentAlert", back_populates="user", cascade="all, delete-orphan")
