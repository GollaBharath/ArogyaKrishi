from PIL import Image
import numpy as np

def preprocess_image(image: Image.Image, target_size=(224, 224)) -> np.ndarray:
    """
    Preprocess image for model input.
    - Convert to RGB
    - Resize to target size
    - Normalize to [0,1]
    - Convert to numpy array with shape (C, H, W)
    """
    # Convert to RGB if not already
    if image.mode != 'RGB':
        image = image.convert('RGB')
    
    # Resize
    image = image.resize(target_size, Image.Resampling.LANCZOS)
    
    # Convert to numpy array and normalize
    img_array = np.array(image) / 255.0
    
    # Transpose to (C, H, W) for PyTorch
    img_array = img_array.transpose(2, 0, 1)
    
    return img_array.astype(np.float32)