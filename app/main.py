from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import logging

from config import settings
from api.detect import router as detect_router

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    logger.info("Starting ArogyaKrishi backend...")
    # Load models here if needed
    from services.disease_detection import load_disease_model
    try:
        load_disease_model()
    except Exception as e:
        logger.warning(f"Model loading failed at startup: {e}")
    yield
    # Shutdown
    logger.info("Shutting down...")

app = FastAPI(
    title="ArogyaKrishi Backend",
    description="Plant Disease Detection API",
    version="1.0.0",
    lifespan=lifespan
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify allowed origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(detect_router)

@app.get("/health")
async def health():
    return {"status": "healthy"}

@app.get("/version")
async def version():
    return {"version": "1.0.0"}