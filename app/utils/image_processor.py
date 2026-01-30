"""Image preprocessing utilities."""

from PIL import Image
import numpy as np
from io import BytesIO


def preprocess_image(image_bytes: bytes, input_size: tuple = (224, 224)) -> np.ndarray:
    """
    Preprocess image bytes to model-ready tensor.
    
    Args:
        image_bytes: Raw image bytes
        input_size: Target size (height, width)
    
    Returns:
        Preprocessed image as numpy array
    """
    # Load image
    image = Image.open(BytesIO(image_bytes))
    
    # Convert to RGB if necessary
    if image.mode != "RGB":
        image = image.convert("RGB")
    
    # Resize
    image = image.resize(input_size, Image.Resampling.LANCZOS)
    
    # Convert to numpy array and normalize to [0, 1]
    image_array = np.array(image, dtype=np.float32) / 255.0
    
    # Normalize with ImageNet mean/std
    mean = np.array([0.485, 0.456, 0.406], dtype=np.float32)
    std = np.array([0.229, 0.224, 0.225], dtype=np.float32)
    image_array = (image_array - mean) / std
    
    # Convert to CHW format for PyTorch
    image_array = np.transpose(image_array, (2, 0, 1))
    
    return image_array
