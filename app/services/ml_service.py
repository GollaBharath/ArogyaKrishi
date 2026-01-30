"""
Pure-Python ML stub for hackathon MVP.

- NO numpy
- NO torch
- ZERO external ML dependencies
- Safe on low disk environments
"""

import logging
import random
from typing import Tuple
from ..config import settings

logger = logging.getLogger(__name__)

# -----------------------------------
# Static labels
# -----------------------------------
DISEASE_CLASSES = [
    "Healthy",
    "Early_Blight",
    "Late_Blight",
    "Powdery_Mildew",
    "Leaf_Rust",
    "Septoria_Leaf_Spot",
]

CROP_TYPES = [
    "Tomato",
    "Potato",
    "Grape",
    "Corn",
    "Wheat",
]


class ModelLoader:
    """
    Stub ML loader.
    """

    def __init__(self):
        self.use_mock = True

    def load_model(self) -> None:
        logger.info("ML service running in PURE MOCK mode (no ML deps).")

    def predict(self, image_bytes: bytes) -> Tuple[str, float, str]:
        """
        Fake prediction that mimics real output.
        """
        disease = random.choice(DISEASE_CLASSES)
        crop = random.choice(CROP_TYPES)
        confidence = round(random.uniform(0.80, 0.95), 2)

        return disease, confidence, crop


# -----------------------------------
# Singleton
# -----------------------------------
_model_loader: ModelLoader | None = None


def get_model_loader() -> ModelLoader:
    global _model_loader
    if _model_loader is None:
        _model_loader = ModelLoader()
    return _model_loader


def load_models() -> None:
    loader = get_model_loader()
    loader.load_model()
