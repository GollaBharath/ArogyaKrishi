import logging
from transformers import pipeline
import torch
from PIL import Image
import numpy as np
import subprocess
import json
from typing import Tuple, Optional

from utils.image_processing import preprocess_image

logger = logging.getLogger(__name__)

# Global model
disease_model = None

def load_disease_model():
    global disease_model
    if disease_model is None:
        logger.info("Loading disease detection model...")
        try:
            disease_model = pipeline(
                "image-classification",
                model="linkanjarad/mobilenet_v2_1.0_224-plant-disease-identification",
                device=0 if torch.cuda.is_available() else -1
            )
            logger.info("Model loaded successfully")
        except Exception as e:
            logger.error(f"Failed to load model: {e}")
            raise
    return disease_model

def detect_disease(image: Image.Image) -> Tuple[str, float]:
    """
    Detect disease from image.
    Returns: (disease_label, confidence)
    """
    model = load_disease_model()
    
    # Preprocess
    img_array = preprocess_image(image)
    
    # Convert back to PIL for pipeline
    # Pipeline expects PIL Image
    # Actually, pipeline can take PIL or numpy, but let's use PIL
    # Wait, preprocess returns numpy, but pipeline can take tensor or PIL.
    # To be safe, pass the PIL image directly, as pipeline handles preprocessing.
    
    # Actually, the model is trained on certain preprocessing, but let's assume pipeline handles it.
    # But to be precise, perhaps pass the numpy array, but pipeline expects PIL or path.
    # Let's check: pipeline("image-classification") can take PIL.Image
    
    results = model(image)
    
    # Get top prediction
    top = results[0]
    label = top['label']
    confidence = top['score']
    
    # Clean label: replace ___ and _ with spaces
    disease_name = label.replace('___', ' ').replace('_', ' ')
    
    return disease_name, confidence

def get_advisory_from_ollama(disease_name: str) -> str:
    """
    Get advisory from Ollama using llama3.1:8b
    """
    prompt = f"Disease: {disease_name}\n\nReturn ONLY this format with exactly two lines per section:\n\n1 Cause\n2 Symptoms\n3 Treatment Steps\n4 Prevention\n5 Best Pesticide Types\n7 Spray Schedule\n\nUse simple farmer-friendly language.\nNo extra paragraphs.\nNo markdown formatting.\nNo explanations outside sections."
    
    try:
        # Run Ollama subprocess
        result = subprocess.run(
            ['ollama', 'run', 'llama3.1:8b'],
            input=prompt,
            text=True,
            capture_output=True,
            timeout=30  # 30 seconds timeout
        )
        
        if result.returncode == 0:
            return result.stdout.strip()
        else:
            logger.error(f"Ollama error: {result.stderr}")
            return get_fallback_advisory(disease_name)
    except subprocess.TimeoutExpired:
        logger.error("Ollama timeout")
        return get_fallback_advisory(disease_name)
    except FileNotFoundError:
        logger.error("Ollama not installed")
        return get_fallback_advisory(disease_name)
    except Exception as e:
        logger.error(f"Ollama failed: {e}")
        return get_fallback_advisory(disease_name)

def get_fallback_advisory(disease_name: str) -> str:
    """
    Fallback advisory if Ollama fails
    """
    return f"1 Cause\nUnknown cause for {disease_name}.\n\n2 Symptoms\nPlease consult local agricultural expert.\n\n3 Treatment Steps\nSeek professional advice.\n\n4 Prevention\nMonitor crops regularly.\n\n5 Best Pesticide Types\nConsult local extension service.\n\n7 Spray Schedule\nAs recommended by experts."