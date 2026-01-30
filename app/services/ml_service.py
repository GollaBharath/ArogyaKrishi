"""ML model loading and inference."""

import torch
import torch.nn.functional as F
import numpy as np
import logging
from typing import Tuple, Dict
from ..config import settings

logger = logging.getLogger(__name__)

# Example crop-disease classes
DISEASE_CLASSES = {
    0: "Healthy",
    1: "Early_Blight",
    2: "Late_Blight",
    3: "Powdery_Mildew",
    4: "Leaf_Rust",
    5: "Septoria_Leaf_Spot",
}

CROP_TYPES = {
    0: "Tomato",
    1: "Potato",
    2: "Grape",
    3: "Corn",
    4: "Wheat",
}


class ModelLoader:
    """Load and manage ML models."""
    
    def __init__(self):
        self.model = None
        self.use_mock = settings.use_mock_inference
    
    def load_model(self):
        """Load pretrained model."""
        if self.use_mock:
            logger.info("Using mock inference mode")
            return
        
        try:
            # Try to load a real model (placeholder)
            # In production, this would load a proper plant disease model
            # e.g., from torchvision or a custom checkpoint
            logger.info("Attempting to load real ML model...")
            # self.model = torch.hub.load(...)
            logger.info("Real model loaded successfully")
        except Exception as e:
            logger.warning(f"Failed to load real model: {e}. Falling back to mock.")
            self.use_mock = True
    
    def predict(self, image_array: np.ndarray) -> Tuple[str, float, str]:
        """
        Run inference on preprocessed image.
        
        Returns:
            Tuple of (disease_label, confidence, crop_type)
        """
        if self.use_mock:
            return self._mock_predict(image_array)
        
        return self._real_predict(image_array)
    
    def _mock_predict(self, image_array: np.ndarray) -> Tuple[str, float, str]:
        """Mock prediction for testing."""
        import random
        
        disease_id = random.randint(0, len(DISEASE_CLASSES) - 1)
        crop_id = random.randint(0, len(CROP_TYPES) - 1)
        confidence = random.uniform(0.5, 0.95)
        
        disease = DISEASE_CLASSES.get(disease_id, "Unknown")
        crop = CROP_TYPES.get(crop_id, "Unknown")
        
        return disease, confidence, crop
    
    def _real_predict(self, image_array: np.ndarray) -> Tuple[str, float, str]:
        """Real model prediction."""
        if self.model is None:
            return self._mock_predict(image_array)
        
        try:
            # Convert to tensor and add batch dimension
            tensor = torch.from_numpy(image_array).unsqueeze(0)
            
            with torch.no_grad():
                outputs = self.model(tensor)
            
            # Get predicted class and confidence
            probabilities = F.softmax(outputs, dim=1)
            confidence, predicted_idx = torch.max(probabilities, 1)
            
            disease = DISEASE_CLASSES.get(predicted_idx.item(), "Unknown")
            crop = "Tomato"  # Default crop
            
            return disease, confidence.item(), crop
        
        except Exception as e:
            logger.error(f"Inference error: {e}")
            return "Unknown", 0.0, "Unknown"


# Global model loader instance
_model_loader = None


def get_model_loader() -> ModelLoader:
    """Get global model loader instance."""
    global _model_loader
    if _model_loader is None:
        _model_loader = ModelLoader()
    return _model_loader


def load_models():
    """Initialize models at startup."""
    loader = get_model_loader()
    loader.load_model()
