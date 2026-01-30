"""Remedies and disease knowledge base service."""

import json
import logging
from typing import List, Dict, Optional

logger = logging.getLogger(__name__)


DISEASE_REMEDIES = {
    "Early_Blight": {
        "symptoms": ["Brown spots on lower leaves", "Concentric rings on spots", "Yellow halo around spots"],
        "remedies": [
            "Remove infected leaves",
            "Apply copper fungicide spray",
            "Improve air circulation",
            "Water at soil level to keep leaves dry",
            "Avoid overhead watering"
        ],
        "prevention": [
            "Space plants properly",
            "Use disease-resistant varieties",
            "Practice crop rotation",
            "Mulch soil to prevent spores from splashing",
            "Remove plant debris"
        ]
    },
    "Late_Blight": {
        "symptoms": ["Water-soaked spots on leaves and stems", "White mold on leaf undersides", "Soft rot on fruits"],
        "remedies": [
            "Remove infected plant parts immediately",
            "Apply mancozeb or chlorothalonil fungicide",
            "Improve air circulation",
            "Reduce moisture on plants",
            "Avoid overhead irrigation"
        ],
        "prevention": [
            "Plant resistant varieties",
            "Use disease-free seed potatoes",
            "Practice crop rotation",
            "Monitor weather for high humidity",
            "Remove volunteer potato plants"
        ]
    },
    "Powdery_Mildew": {
        "symptoms": ["White powdery coating on leaves", "Yellowing of affected leaves", "Leaf curling"],
        "remedies": [
            "Apply sulfur dust or spray",
            "Use potassium bicarbonate fungicide",
            "Increase air circulation",
            "Remove heavily infected leaves",
            "Avoid high nitrogen fertilizer"
        ],
        "prevention": [
            "Plant in well-ventilated areas",
            "Choose resistant varieties",
            "Maintain proper spacing",
            "Avoid overhead watering",
            "Clean up plant debris"
        ]
    },
    "Leaf_Rust": {
        "symptoms": ["Orange-brown pustules on leaf undersides", "Yellow spots on upper leaf surface", "Severe leaf drop"],
        "remedies": [
            "Apply fungicide containing sulfur or copper",
            "Remove infected leaves",
            "Improve plant spacing for air flow",
            "Avoid overhead irrigation",
            "Apply mancozeb fungicide"
        ],
        "prevention": [
            "Use resistant varieties",
            "Practice crop rotation",
            "Remove alternate hosts",
            "Maintain sanitation",
            "Monitor plants regularly"
        ]
    },
    "Septoria_Leaf_Spot": {
        "symptoms": ["Small circular spots with dark borders", "Gray center with black dots", "Spot coalescence"],
        "remedies": [
            "Remove infected leaves",
            "Apply chlorothalonil fungicide",
            "Space plants properly",
            "Avoid splashing soil onto leaves",
            "Water at soil level"
        ],
        "prevention": [
            "Use disease-resistant varieties",
            "Practice crop rotation",
            "Remove plant debris",
            "Avoid overhead watering",
            "Improve air circulation"
        ]
    },
    "Healthy": {
        "symptoms": ["No disease signs present"],
        "remedies": [
            "Continue regular maintenance",
            "Monitor plant health",
            "Practice preventive care"
        ],
        "prevention": [
            "Maintain proper watering",
            "Ensure adequate spacing",
            "Provide proper nutrition",
            "Monitor for early disease signs"
        ]
    }
}

LANGUAGE_TRANSLATIONS = {
    "en": {
        "Early_Blight": "Early Blight",
        "Late_Blight": "Late Blight",
        "Powdery_Mildew": "Powdery Mildew",
        "Leaf_Rust": "Leaf Rust",
        "Septoria_Leaf_Spot": "Septoria Leaf Spot",
        "Healthy": "Healthy",
    },
    "te": {  # Telugu
        "Early_Blight": "తొలి ఫాతు",
        "Late_Blight": "చివరి ఫాతు",
        "Powdery_Mildew": "పౌడర్ మిల్డ్యూ",
        "Leaf_Rust": "ఆకు తుప్పు",
        "Septoria_Leaf_Spot": "సెప్టోరియా ఆకు చుక్క",
        "Healthy": "ఆరోగ్యం",
    },
    "hi": {  # Hindi
        "Early_Blight": "प्रारंभिक झुलसा",
        "Late_Blight": "देर से झुलसा",
        "Powdery_Mildew": "पाउडर फफूंदी",
        "Leaf_Rust": "पत्ती की जंग",
        "Septoria_Leaf_Spot": "सेप्टोरिया पत्ती धब्बा",
        "Healthy": "स्वस्थ",
    }
}


class RemedyService:
    """Service for managing disease remedies and guidance."""
    
    @staticmethod
    def get_remedies(disease: str) -> Optional[Dict]:
        """Get remedies for a disease."""
        return DISEASE_REMEDIES.get(disease, DISEASE_REMEDIES.get("Healthy"))
    
    @staticmethod
    def get_remedies_list(disease: str) -> List[str]:
        """Get list of remedies for a disease."""
        remedies_data = DISEASE_REMEDIES.get(disease, DISEASE_REMEDIES.get("Healthy"))
        if remedies_data:
            return remedies_data.get("remedies", [])
        return []
    
    @staticmethod
    def get_translated_disease(disease: str, language: str = "en") -> str:
        """Get disease name in requested language."""
        translations = LANGUAGE_TRANSLATIONS.get(language, LANGUAGE_TRANSLATIONS["en"])
        return translations.get(disease, disease)
    
    @staticmethod
    def validate_language(language: str) -> str:
        """Validate and return language code (default to 'en')."""
        if language in LANGUAGE_TRANSLATIONS:
            return language
        return "en"


def load_remedies():
    """Initialize remedies service at startup."""
    logger.info(f"Loaded remedies for {len(DISEASE_REMEDIES)} disease types")
