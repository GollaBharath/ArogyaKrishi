import os
from typing import Optional

class Settings:
    def __init__(self):
        self.env = os.getenv("ENV", "development")
        self.debug = os.getenv("DEBUG", "True").lower() == "true"
        self.openai_api_key = os.getenv("OPENAI_API_KEY")
        self.anthropic_api_key = os.getenv("ANTHROPIC_API_KEY")
        self.use_mock_model = os.getenv("USE_MOCK_MODEL", "False").lower() == "true"
        self.confidence_threshold = float(os.getenv("CONFIDENCE_THRESHOLD", "0.7"))

settings = Settings()