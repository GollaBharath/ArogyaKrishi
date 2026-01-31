"""Chat models for chatbot API."""

from pydantic import BaseModel
from typing import Optional


class ChatTextRequest(BaseModel):
    """Request model for text chat."""
    message: str
    language: str
    session_id: Optional[str] = None


class ChatVoiceRequest(BaseModel):
    """Request model for voice chat (multipart form fields)."""
    language: str
    session_id: Optional[str] = None


class ChatResponse(BaseModel):
    """Response model for chat API."""
    reply: str
    audio_url: Optional[str] = None
    session_id: str
    language: str
    message_id: str
