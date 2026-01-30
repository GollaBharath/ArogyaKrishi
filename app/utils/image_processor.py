"""
Image preprocessing stub for hackathon MVP.

- No PIL
- No NumPy
- No image decoding
- Compatible with mock ML service
"""

def preprocess_image(image_bytes: bytes):
    """
    Stub image preprocessing.

    Since ML is mocked, we don't need to actually process the image.
    We simply pass through the raw bytes.
    """
    return image_bytes
