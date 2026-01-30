"""
SentAlert model for ArogyaKrishi (async SQLAlchemy ORM).
"""
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, func
from sqlalchemy.orm import relationship

from . import Base


class SentAlert(Base):
    __tablename__ = "sent_alerts"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    disease = Column(String, nullable=False)
    sent_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    # Relationship back to user
    user = relationship("User", back_populates="sent_alerts")
