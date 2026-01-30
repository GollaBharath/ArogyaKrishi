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

# Crop name translations
CROP_TRANSLATIONS = {
    "en": {
        "Tomato": "Tomato",
        "Potato": "Potato",
        "Grape": "Grape",
        "Corn": "Corn",
        "Wheat": "Wheat",
    },
    "te": {
        "Tomato": "టమాటా",
        "Potato": "బంగాళాదుంప",
        "Grape": "ద్రాక్ష",
        "Corn": "మొక్కజొన్న",
        "Wheat": "గోధుమ",
    },
    "hi": {
        "Tomato": "टमाटर",
        "Potato": "आलू",
        "Grape": "अंगूर",
        "Corn": "मक्का",
        "Wheat": "गेहूं",
    },
    "kn": {
        "Tomato": "ಟೊಮೇಟೊ",
        "Potato": "ಆಲೂಗಡ್ಡೆ",
        "Grape": "ದ್ರಾಕ್ಷಿ",
        "Corn": "ಜೋಳ",
        "Wheat": "ಗೋಧಿ",
    },
    "ml": {
        "Tomato": "തക്കാളി",
        "Potato": "ഉരുളക്കിഴങ്ങ്",
        "Grape": "മുന്തിരി",
        "Corn": "ചോളം",
        "Wheat": "ഗോതമ്പ്",
    }
}

# Disease name translations
DISEASE_TRANSLATIONS = {
    "en": {
        "Early_Blight": "Early Blight",
        "Late_Blight": "Late Blight",
        "Powdery_Mildew": "Powdery Mildew",
        "Leaf_Rust": "Leaf Rust",
        "Septoria_Leaf_Spot": "Septoria Leaf Spot",
        "Healthy": "Healthy",
    },
    "te": {
        "Early_Blight": "తొలి ఫాతు",
        "Late_Blight": "చివరి ఫాతు",
        "Powdery_Mildew": "పౌడర్ మిల్డ్యూ",
        "Leaf_Rust": "ఆకు తుప్పు",
        "Septoria_Leaf_Spot": "సెప్టోరియా ఆకు చుక్క",
        "Healthy": "ఆరోగ్యం",
    },
    "hi": {
        "Early_Blight": "प्रारंभिक झुलसा",
        "Late_Blight": "देर से झुलसा",
        "Powdery_Mildew": "पाउडर फफूंदी",
        "Leaf_Rust": "पत्ती की जंग",
        "Septoria_Leaf_Spot": "सेप्टोरिया पत्ती धब्बा",
        "Healthy": "स्वस्थ",
    },
    "kn": {
        "Early_Blight": "ಆರಂಭಿಕ ಬ್ಲೈಟ್",
        "Late_Blight": "ತಡವಾದ ಬ್ಲೈಟ್",
        "Powdery_Mildew": "ಪುಡಿ ಶಿಲೀಂಧ್ರ",
        "Leaf_Rust": "ಎಲೆ ತುಕ್ಕು",
        "Septoria_Leaf_Spot": "ಸೆಪ್ಟೋರಿಯಾ ಎಲೆ ಕಲೆ",
        "Healthy": "ಆರೋಗ್ಯಕರ",
    },
    "ml": {
        "Early_Blight": "ആദ്യകാല ബ്ലൈറ്റ്",
        "Late_Blight": "വൈകിയുള്ള ബ്ലൈറ്റ്",
        "Powdery_Mildew": "പൊടി ഫംഗസ്",
        "Leaf_Rust": "ഇല തുരുമ്പ്",
        "Septoria_Leaf_Spot": "സെപ്റ്റോറിയ ഇല പാട്",
        "Healthy": "ആരോഗ്യമുള്ള",
    }
}

# Remedy translations
REMEDY_TRANSLATIONS = {
    "en": {
        "Early_Blight": [
            "Remove infected leaves",
            "Apply copper fungicide spray",
            "Improve air circulation",
            "Water at soil level to keep leaves dry",
            "Avoid overhead watering"
        ],
        "Late_Blight": [
            "Remove infected plant parts immediately",
            "Apply mancozeb or chlorothalonil fungicide",
            "Improve air circulation",
            "Reduce moisture on plants",
            "Avoid overhead irrigation"
        ],
        "Powdery_Mildew": [
            "Apply sulfur dust or spray",
            "Use potassium bicarbonate fungicide",
            "Increase air circulation",
            "Remove heavily infected leaves",
            "Avoid high nitrogen fertilizer"
        ],
        "Leaf_Rust": [
            "Apply fungicide containing sulfur or copper",
            "Remove infected leaves",
            "Improve plant spacing for air flow",
            "Avoid overhead irrigation",
            "Apply mancozeb fungicide"
        ],
        "Septoria_Leaf_Spot": [
            "Remove infected leaves",
            "Apply chlorothalonil fungicide",
            "Space plants properly",
            "Avoid splashing soil onto leaves",
            "Water at soil level"
        ],
        "Healthy": [
            "Continue regular maintenance",
            "Monitor plant health",
            "Practice preventive care"
        ]
    },
    "te": {
        "Early_Blight": [
            "బాధిత ఆకులను తొలగించండి",
            "కాపర్ ఫంగిసైడ్ స్ప్రే వేయండి",
            "గాలి ప్రసరణను మెరుగుపరచండి",
            "ఆకులు పొడిగా ఉండేలా నేల స్థాయిలో నీరు పోయండి",
            "పై నుంచి నీరు పోయడం నివారించండి"
        ],
        "Late_Blight": [
            "బాధిత మొక్క భాగాలను వెంటనే తొలగించండి",
            "మాంకోజెబ్ లేదా క్లోరోథలోనిల్ ఫంగిసైడ్ వేయండి",
            "గాలి ప్రసరణను మెరుగుపరచండి",
            "మొక్కలపై తేమను తగ్గించండి",
            "పైనుంచి నీటిపారుదల నివారించండి"
        ],
        "Powdery_Mildew": [
            "సల్ఫర్ పొడి లేదా స్ప్రే వేయండి",
            "పొటాషియం బైకార్బోనేట్ ఫంగిసైడ్ ఉపయోగించండి",
            "గాలి ప్రసరణను పెంచండి",
            "అధికంగా బాధిత ఆకులను తొలగించండి",
            "అధిక నత్రజని ఎరువు నివారించండి"
        ],
        "Leaf_Rust": [
            "సల్ఫర్ లేదా కాపర్ కలిగిన ఫంగిసైడ్ వేయండి",
            "బాధిత ఆకులను తొలగించండి",
            "గాలి ప్రవాహం కోసం మొక్కల అంతరం మెరుగుపరచండి",
            "పై నుంచి నీటిపారుదల నివారించండి",
            "మాంకోజెబ్ ఫంగిసైడ్ వేయండి"
        ],
        "Septoria_Leaf_Spot": [
            "బాధిత ఆకులను తొలగించండి",
            "క్లోరోథలోనిల్ ఫంగిసైడ్ వేయండి",
            "మొక్కలను సరిగ్గా అంతరం ఉంచండి",
            "ఆకులపై నేల చిమ్మడం నివారించండి",
            "నేల స్థాయిలో నీరు పోయండి"
        ],
        "Healthy": [
            "క్రమంగా నిర్వహణ కొనసాగించండి",
            "మొక్క ఆరోగ్యాన్ని పర్యవేక్షించండి",
            "నివారణ సంరక్షణ పాటించండి"
        ]
    },
    "hi": {
        "Early_Blight": [
            "संक्रमित पत्तियाँ हटाएँ",
            "कॉपर फंगीसाइड स्प्रे करें",
            "हवा का संचार सुधारें",
            "पत्तियों को सूखा रखने के लिए मिट्टी स्तर पर पानी दें",
            "ऊपर से पानी देने से बचें"
        ],
        "Late_Blight": [
            "संक्रमित पौधे के हिस्से तुरंत हटाएँ",
            "मैनकोजेब या क्लोरोथैलोनिल फंगीसाइड लगाएँ",
            "हवा का संचार सुधारें",
            "पौधों पर नमी कम करें",
            "ऊपर से सिंचाई से बचें"
        ],
        "Powdery_Mildew": [
            "सल्फर धूल या स्प्रे लगाएँ",
            "पोटैशियम बाइकार्बोनेट फंगीसाइड उपयोग करें",
            "हवा का संचार बढ़ाएँ",
            "अत्यधिक संक्रमित पत्तियाँ हटाएँ",
            "उच्च नाइट्रोजन उर्वरक से बचें"
        ],
        "Leaf_Rust": [
            "सल्फर या कॉपर युक्त फंगीसाइड लगाएँ",
            "संक्रमित पत्तियाँ हटाएँ",
            "हवा प्रवाह के लिए पौधों की दूरी सुधारें",
            "ऊपर से सिंचाई से बचें",
            "मैनकोजेब फंगीसाइड लगाएँ"
        ],
        "Septoria_Leaf_Spot": [
            "संक्रमित पत्तियाँ हटाएँ",
            "क्लोरोथैलोनिल फंगीसाइड लगाएँ",
            "पौधों को सही दूरी पर रखें",
            "पत्तियों पर मिट्टी छींटने से बचें",
            "मिट्टी स्तर पर पानी दें"
        ],
        "Healthy": [
            "नियमित रखरखाव जारी रखें",
            "पौधों के स्वास्थ्य की निगरानी करें",
            "निवारक देखभाल का अभ्यास करें"
        ]
    },
    "kn": {
        "Early_Blight": [
            "ಸೋಂಕಿತ ಎಲೆಗಳನ್ನು ತೆಗೆದುಹಾಕಿ",
            "ಕಾಪರ್ ಶಿಲೀಂಧ್ರನಾಶಕ ಸ್ಪ್ರೇ ಅನ್ವಯಿಸಿ",
            "ಗಾಳಿ ಪರಿಚಲನೆಯನ್ನು ಸುಧಾರಿಸಿ",
            "ಎಲೆಗಳನ್ನು ಒಣಗಿಸಲು ಮಣ್ಣಿನ ಮಟ್ಟದಲ್ಲಿ ನೀರು ಹಾಕಿ",
            "ಮೇಲಿನಿಂದ ನೀರು ಹಾಕುವುದನ್ನು ತಪ್ಪಿಸಿ"
        ],
        "Late_Blight": [
            "ಸೋಂಕಿತ ಸಸ್ಯ ಭಾಗಗಳನ್ನು ತಕ್ಷಣ ತೆಗೆದುಹಾಕಿ",
            "ಮ್ಯಾಂಕೋಜೆಬ್ ಅಥವಾ ಕ್ಲೋರೋಥಲೋನಿಲ್ ಶಿಲೀಂಧ್ರನಾಶಕ ಅನ್ವಯಿಸಿ",
            "ಗಾಳಿ ಪರಿಚಲನೆಯನ್ನು ಸುಧಾರಿಸಿ",
            "ಸಸ್ಯಗಳ ಮೇಲೆ ತೇವಾಂಶವನ್ನು ಕಡಿಮೆ ಮಾಡಿ",
            "ಮೇಲಿನಿಂದ ನೀರಾವರಿಯನ್ನು ತಪ್ಪಿಸಿ"
        ],
        "Powdery_Mildew": [
            "ಗಂಧಕ ಪುಡಿ ಅಥವಾ ಸ್ಪ್ರೇ ಅನ್ವಯಿಸಿ",
            "ಪೊಟ್ಯಾಸಿಯಮ್ ಬೈಕಾರ್ಬೋನೇಟ್ ಶಿಲೀಂಧ್ರನಾಶಕ ಬಳಸಿ",
            "ಗಾಳಿ ಪರಿಚಲನೆಯನ್ನು ಹೆಚ್ಚಿಸಿ",
            "ಅತೀವವಾಗಿ ಸೋಂಕಿತ ಎಲೆಗಳನ್ನು ತೆಗೆದುಹಾಕಿ",
            "ಹೆಚ್ಚಿನ ಸಾರಜನಕ ರಸಗೊಬ್ಬರವನ್ನು ತಪ್ಪಿಸಿ"
        ],
        "Leaf_Rust": [
            "ಗಂಧಕ ಅಥವಾ ತಾಮ್ರ ಹೊಂದಿರುವ ಶಿಲೀಂಧ್ರನಾಶಕ ಅನ್ವಯಿಸಿ",
            "ಸೋಂಕಿತ ಎಲೆಗಳನ್ನು ತೆಗೆದುಹಾಕಿ",
            "ಗಾಳಿ ಹರಿವಿಗಾಗಿ ಸಸ್ಯ ಅಂತರವನ್ನು ಸುಧಾರಿಸಿ",
            "ಮೇಲಿನಿಂದ ನೀರಾವರಿಯನ್ನು ತಪ್ಪಿಸಿ",
            "ಮ್ಯಾಂಕೋಜೆಬ್ ಶಿಲೀಂಧ್ರನಾಶಕ ಅನ್ವಯಿಸಿ"
        ],
        "Septoria_Leaf_Spot": [
            "ಸೋಂಕಿತ ಎಲೆಗಳನ್ನು ತೆಗೆದುಹಾಕಿ",
            "ಕ್ಲೋರೋಥಲೋನಿಲ್ ಶಿಲೀಂಧ್ರನಾಶಕ ಅನ್ವಯಿಸಿ",
            "ಸಸ್ಯಗಳನ್ನು ಸರಿಯಾಗಿ ಅಂತರಿಸಿ",
            "ಎಲೆಗಳ ಮೇಲೆ ಮಣ್ಣು ಚಿಮ್ಮುವುದನ್ನು ತಪ್ಪಿಸಿ",
            "ಮಣ್ಣಿನ ಮಟ್ಟದಲ್ಲಿ ನೀರು ಹಾಕಿ"
        ],
        "Healthy": [
            "ನಿಯಮಿತ ನಿರ್ವಹಣೆಯನ್ನು ಮುಂದುವರಿಸಿ",
            "ಸಸ್ಯ ಆರೋಗ್ಯವನ್ನು ಮೇಲ್ವಿಚಾರಣೆ ಮಾಡಿ",
            "ತಡೆಗಟ್ಟುವ ಆರೈಕೆಯನ್ನು ಅಭ್ಯಾಸ ಮಾಡಿ"
        ]
    },
    "ml": {
        "Early_Blight": [
            "രോഗബാധിത ഇലകൾ നീക്കം ചെയ്യുക",
            "കോപ്പർ ഫംഗിസൈഡ് സ്പ്രേ പ്രയോഗിക്കുക",
            "വായു സഞ്ചാരം മെച്ചപ്പെടുത്തുക",
            "ഇലകൾ ഉണങ്ങി നിലനിർത്താൻ മണ്ണ് നിലയിൽ വെള്ളം ഒഴിക്കുക",
            "മുകളിൽ നിന്ന് വെള്ളം ഒഴിക്കുന്നത് ഒഴിവാക്കുക"
        ],
        "Late_Blight": [
            "രോഗബാധിത ചെടി ഭാഗങ്ങൾ ഉടൻ നീക്കം ചെയ്യുക",
            "മാൻകോസെബ് അല്ലെങ്കിൽ ക്ലോറോതലോനിൽ ഫംഗിസൈഡ് പ്രയോഗിക്കുക",
            "വായു സഞ്ചാരം മെച്ചപ്പെടുത്തുക",
            "ചെടികളിലെ ഈർപ്പം കുറയ്ക്കുക",
            "മുകളിൽ നിന്നുള്ള ജലസേചനം ഒഴിവാക്കുക"
        ],
        "Powdery_Mildew": [
            "സൾഫർ പൊടി അല്ലെങ്കിൽ സ്പ്രേ പ്രയോഗിക്കുക",
            "പൊട്ടാസ്യം ബൈകാർബണേറ്റ് ഫംഗിസൈഡ് ഉപയോഗിക്കുക",
            "വായു സഞ്ചാരം വർദ്ധിപ്പിക്കുക",
            "കൂടുതൽ രോഗബാധിത ഇലകൾ നീക്കം ചെയ്യുക",
            "ഉയർന്ന നൈട്രജൻ വളം ഒഴിവാക്കുക"
        ],
        "Leaf_Rust": [
            "സൾഫർ അല്ലെങ്കിൽ കോപ്പർ അടങ്ങിയ ഫംഗിസൈഡ് പ്രയോഗിക്കുക",
            "രോഗബാധിത ഇലകൾ നീക്കം ചെയ്യുക",
            "വായു പ്രവാഹത്തിനായി ചെടി അകലം മെച്ചപ്പെടുത്തുക",
            "മുകളിൽ നിന്നുള്ള ജലസേചനം ഒഴിവാക്കുക",
            "മാൻകോസെബ് ഫംഗിസൈഡ് പ്രയോഗിക്കുക"
        ],
        "Septoria_Leaf_Spot": [
            "രോഗബാധിത ഇലകൾ നീക്കം ചെയ്യുക",
            "ക്ലോറോതലോനിൽ ഫംഗിസൈഡ് പ്രയോഗിക്കുക",
            "ചെടികൾ ശരിയായി അകറ്റി വയ്ക്കുക",
            "ഇലകളിൽ മണ്ണ് തെറിക്കുന്നത് ഒഴിവാക്കുക",
            "മണ്ണ് നിലയിൽ വെള്ളം ഒഴിക്കുക"
        ],
        "Healthy": [
            "പതിവ് പരിപാലനം തുടരുക",
            "ചെടിയുടെ ആരോഗ്യം നിരീക്ഷിക്കുക",
            "പ്രതിരോധ പരിചരണം പരിശീലിക്കുക"
        ]
    }
}

TREATMENT_FEEDBACK_TRANSLATIONS = {
    "en": {
        "match": "✓ This product matches recommended treatment for {disease}.",
        "no_match": "✗ This product does not match recommended treatments.\n\nRecommended: {suggestions}",
        "no_disease": "No disease detected. Treatment is not required.",
        "need_label": "Please provide a clear product name for accurate feedback.",
        "unknown_disease": "Disease not recognized. Unable to verify treatment."
    },
    "te": {
        "match": "✓ ఈ ఉత్పత్తి {disease}కి సూచించిన చికిత్సతో సరిపోతుంది.",
        "no_match": "✗ ఈ ఉత్పత్తి సూచించిన చికిత్సతో సరిపోవడం లేదు.\n\nసూచించబడినది: {suggestions}",
        "no_disease": "వ్యాధి గుర్తించబడలేదు. చికిత్స అవసరం లేదు.",
        "need_label": "ఖచ్చితమైన అభిప్రాయానికి స్పష్టమైన ఉత్పత్తి పేరును ఇవ్వండి.",
        "unknown_disease": "వ్యాధిని గుర్తించలేకపోయాము. చికిత్సను నిర్ధారించలేము."
    },
    "hi": {
        "match": "✓ यह उत्पाद {disease} के लिए सुझाए गए उपचार से मेल खाता है।",
        "no_match": "✗ यह उत्पाद सुझाए गए उपचार से मेल नहीं खाता है।\n\nसुझाया गया: {suggestions}",
        "no_disease": "कोई रोग नहीं मिला। उपचार आवश्यक नहीं है।",
        "need_label": "सटीक प्रतिक्रिया के लिए कृपया स्पष्ट उत्पाद नाम दें।",
        "unknown_disease": "रोग पहचाना नहीं गया। उपचार की पुष्टि नहीं की जा सकती।"
    },
    "kn": {
        "match": "✓ ಈ ಉತ್ಪನ್ನ {disease}ಕ್ಕೆ ಶಿಫಾರಸು ಮಾಡಿದ ಚಿಕಿತ್ಸೆಗೆ ಹೊಂದಿಕೆಯಾಗುತ್ತದೆ.",
        "no_match": "✗ ಈ ಉತ್ಪನ್ನ ಶಿಫಾರಸು ಮಾಡಿದ ಚಿಕಿತ್ಸೆಗೆ ಹೊಂದಿಕೆಯಾಗುವುದಿಲ್ಲ.\n\nಶಿಫಾರಸು: {suggestions}",
        "no_disease": "ಯಾವುದೇ ರೋಗ ಕಂಡುಬಂದಿಲ್ಲ. ಚಿಕಿತ್ಸೆ ಅಗತ್ಯವಿಲ್ಲ.",
        "need_label": "ಖಚಿತ ಪ್ರತಿಕ್ರಿಯೆಗೆ ಸ್ಪಷ್ಟ ಉತ್ಪನ್ನ ಹೆಸರನ್ನು ನೀಡಿ.",
        "unknown_disease": "ರೋಗವನ್ನು ಗುರುತಿಸಲಾಗಲಿಲ್ಲ. ಚಿಕಿತ್ಸೆಯನ್ನು ಪರಿಶೀಲಿಸಲಾಗುವುದಿಲ್ಲ."
    },
    "ml": {
        "match": "✓ ഈ ഉൽപ്പന്നം {disease}ന് ശുപാർശ ചെയ്ത ചികിത്സയുമായി പൊരുത്തപ്പെടുന്നു.",
        "no_match": "✗ ഈ ഉൽപ്പന്നം ശുപാർശ ചെയ്ത ചികിത്സയുമായി പൊരുത്തപ്പെടുന്നില്ല.\n\nശുപാർശ: {suggestions}",
        "no_disease": "രോഗം കണ്ടെത്തിയില്ല. ചികിത്സ ആവശ്യമില്ല.",
        "need_label": "കൃത്യമായ പ്രതികരണത്തിനായി വ്യക്തമായ ഉൽപ്പന്ന പേര് നൽകുക.",
        "unknown_disease": "രോഗം തിരിച്ചറിയാനായില്ല. ചികിത്സ സ്ഥിരീകരിക്കാൻ കഴിയില്ല."
    }
}

# Common treatment keywords to match against
TREATMENT_KEYWORDS = {
    # Fungicides
    "mancozeb": ["mancozeb", "dithane"],
    "chlorothalonil": ["chlorothalonil", "bravo", "daconil"],
    "sulfur": ["sulfur", "sulphur", "sul"],
    "copper": ["copper", "kocide", "cuprofix"],
    "carbendazim": ["carbendazim", "bavistin"],
    
    # Other fungicides
    "potassium bicarbonate": ["potassium bicarbonate", "bicarbonate", "kaligreen"],
    "neem": ["neem", "azadirachtin"],
    
    # Generic terms
    "fungicide": ["fungicide", "antifungal", "fungus control", "fungus"],
    "bactericide": ["bactericide", "antibacterial", "bacteria control"],
}


class RemedyService:
    """Service for managing disease remedies and guidance."""
    
    @staticmethod
    def get_remedies(disease: str) -> Optional[Dict]:
        """Get remedies for a disease."""
        return DISEASE_REMEDIES.get(disease, DISEASE_REMEDIES.get("Healthy"))
    
    @staticmethod
    def get_remedies_list(disease: str, language: str = "en") -> List[str]:
        """Get list of remedies for a disease in the specified language."""
        # Get translated remedies if available
        remedy_translations = REMEDY_TRANSLATIONS.get(language, REMEDY_TRANSLATIONS["en"])
        translated_remedies = remedy_translations.get(disease)
        
        if translated_remedies:
            return translated_remedies
        
        # Fallback to English remedies from DISEASE_REMEDIES
        remedies_data = DISEASE_REMEDIES.get(disease, DISEASE_REMEDIES.get("Healthy"))
        if remedies_data:
            return remedies_data.get("remedies", [])
        return []
    
    @staticmethod
    def get_translated_disease(disease: str, language: str = "en") -> str:
        """Get disease name in requested language."""
        translations = DISEASE_TRANSLATIONS.get(language, DISEASE_TRANSLATIONS["en"])
        return translations.get(disease, disease)
    
    @staticmethod
    def get_translated_crop(crop: str, language: str = "en") -> str:
        """Get crop name in requested language."""
        translations = CROP_TRANSLATIONS.get(language, CROP_TRANSLATIONS["en"])
        return translations.get(crop, crop)
    
    @staticmethod
    def validate_language(language: str) -> str:
        """Validate and return language code (default to 'en')."""
        if language in DISEASE_TRANSLATIONS:
            return language
        return "en"

    @staticmethod
    def normalize_disease_name(disease: str) -> str:
        """Normalize disease name to internal key if possible."""
        if disease in DISEASE_REMEDIES:
            return disease
        if not disease:
            return disease
        disease_lower = disease.strip().lower()
        for _, translations in DISEASE_TRANSLATIONS.items():
            for key, value in translations.items():
                if value.strip().lower() == disease_lower:
                    return key
        return disease

    @staticmethod
    def extract_treatment_keywords(remedies: List[str]) -> List[str]:
        """Extract treatment keywords from remedy text."""
        keywords = set()
        for remedy in remedies:
            remedy_lower = remedy.lower()
            # Check against all known treatment keywords
            for treatment_name, treatment_variants in TREATMENT_KEYWORDS.items():
                for variant in treatment_variants:
                    if variant in remedy_lower:
                        keywords.add(treatment_name)
        return sorted(list(keywords))

    @staticmethod
    def evaluate_treatment(disease: str, item_label: Optional[str], language: str = "en") -> Dict:
        """Evaluate if an item label matches recommended treatment for a disease."""
        language = RemedyService.validate_language(language)
        feedback_translations = TREATMENT_FEEDBACK_TRANSLATIONS.get(language, TREATMENT_FEEDBACK_TRANSLATIONS["en"])

        normalized_disease = RemedyService.normalize_disease_name(disease)
        translated_disease = RemedyService.get_translated_disease(normalized_disease, language)

        if normalized_disease == "Healthy":
            return {
                "disease": translated_disease,
                "language": language,
                "item_label": item_label,
                "will_cure": False,
                "feedback": feedback_translations["no_disease"]
            }

        if normalized_disease not in DISEASE_REMEDIES:
            return {
                "disease": translated_disease,
                "language": language,
                "item_label": item_label,
                "will_cure": False,
                "feedback": feedback_translations["unknown_disease"]
            }

        label = (item_label or "").strip().lower()
        if not label:
            return {
                "disease": translated_disease,
                "language": language,
                "item_label": item_label,
                "will_cure": False,
                "feedback": feedback_translations["need_label"]
            }

        # Get remedies for this disease
        remedies = RemedyService.get_remedies_list(normalized_disease, "en")
        recommended_keywords = RemedyService.extract_treatment_keywords(remedies)
        
        # Check if the item label matches any recommended treatment
        will_cure = False
        for treatment_name, treatment_variants in TREATMENT_KEYWORDS.items():
            if treatment_name in recommended_keywords:
                for variant in treatment_variants:
                    if variant in label:
                        will_cure = True
                        break
            if will_cure:
                break
        
        # Build feedback message
        if will_cure:
            feedback = feedback_translations["match"].format(disease=translated_disease)
        else:
            # Provide suggestions based on recommended keywords
            if recommended_keywords:
                suggestions = ", ".join(recommended_keywords[:3])  # Top 3 suggestions
            else:
                suggestions = "Check remedy details"
            feedback = feedback_translations["no_match"].format(suggestions=suggestions)

        return {
            "disease": translated_disease,
            "language": language,
            "item_label": item_label,
            "will_cure": will_cure,
            "feedback": feedback
        }


def load_remedies():
    """Initialize remedies service at startup."""
    logger.info(f"Loaded remedies for {len(DISEASE_REMEDIES)} disease types")
