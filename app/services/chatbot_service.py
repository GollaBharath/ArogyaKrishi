"""Chatbot service for agricultural assistance."""

import logging
import uuid
from typing import Dict, Optional, Tuple
import random

logger = logging.getLogger(__name__)

# In-memory session storage (replace with Redis in production)
_sessions: Dict[str, list] = {}


class ChatbotService:
    """Service for chatbot interactions."""
    
    # Sample responses for agricultural questions (multilingual)
    RESPONSES = {
        "en": [
            "Based on your question, I recommend consulting with a local agricultural expert for specific advice.",
            "That's a great question about farming! For the best results, consider factors like soil quality, weather patterns, and crop rotation.",
            "In my experience, proper irrigation and pest management are key to healthy crops. What specific crop are you growing?",
            "I suggest monitoring your plants regularly for signs of disease or pest damage. Early detection is crucial.",
            "For optimal growth, ensure your plants receive adequate sunlight, water, and nutrients. What issue are you facing?",
        ],
        "hi": [
            "आपके प्रश्न के आधार पर, मैं विशिष्ट सलाह के लिए स्थानीय कृषि विशेषज्ञ से परामर्श करने की सलाह देता हूं।",
            "खेती के बारे में यह एक बढ़िया सवाल है! सर्वोत्तम परिणामों के लिए, मिट्टी की गुणवत्ता, मौसम के पैटर्न और फसल चक्र जैसे कारकों पर विचार करें।",
            "मेरे अनुभव में, स्वस्थ फसलों के लिए उचित सिंचाई और कीट प्रबंधन महत्वपूर्ण हैं। आप कौन सी फसल उगा रहे हैं?",
            "मैं आपके पौधों की नियमित रूप से बीमारी या कीट क्षति के संकेतों के लिए निगरानी करने का सुझाव देता हूं। शीघ्र पता लगाना महत्वपूर्ण है।",
            "इष्टतम वृद्धि के लिए, सुनिश्चित करें कि आपके पौधों को पर्याप्त धूप, पानी और पोषक तत्व मिलें। आप किस समस्या का सामना कर रहे हैं?",
        ],
        "te": [
            "మీ ప్రశ్న ఆధారంగా, నేను నిర్దిష్ట సలహా కోసం స్థానిక వ్యవసాయ నిపుణుడిని సంప్రదించాలని సిఫార్సు చేస్తున్నాను.",
            "వ్యవసాయం గురించి ఇది గొప్ప ప్రశ్న! ఉత్తమ ఫలితాల కోసం, నేల నాణ్యత, వాతావరణ నమూనాలు మరియు పంట మార్పిడి వంటి అంశాలను పరిగణించండి.",
            "నా అనుభవంలో, ఆరోగ్యకరమైన పంటలకు సరైన నీటిపారుదల మరియు పెస్ట్ నిర్వహణ కీలకం. మీరు ఏ నిర్దిష్ట పంటను పెంచుతున్నారు?",
            "వ్యాధి లేదా పెస్ట్ నష్టం యొక్క సంకేతాల కోసం మీ మొక్కలను క్రమం తప్పకుండా పర్యవేక్షించాలని నేను సూచిస్తున్నాను. ముందస్తు గుర్తింపు కీలకం.",
            "సరైన వృద్ధి కోసం, మీ మొక్కలకు తగినంత సూర్యరశ్మి, నీరు మరియు పోషకాలు అందుతున్నాయని నిర్ధారించుకోండి. మీరు ఏ సమస్యను ఎదుర్కొంటున్నారు?",
        ],
    }
    
    @classmethod
    def get_session_id(cls, session_id: Optional[str] = None) -> str:
        """Get or create session ID."""
        if session_id and session_id in _sessions:
            return session_id
        new_id = str(uuid.uuid4())
        _sessions[new_id] = []
        return new_id
    
    @classmethod
    def add_to_history(cls, session_id: str, role: str, content: str) -> None:
        """Add message to session history."""
        if session_id not in _sessions:
            _sessions[session_id] = []
        _sessions[session_id].append({"role": role, "content": content})
        
        # Keep only last 20 messages
        if len(_sessions[session_id]) > 20:
            _sessions[session_id] = _sessions[session_id][-20:]
    
    @classmethod
    async def process_text_message(
        cls,
        message: str,
        language: str,
        session_id: Optional[str] = None
    ) -> Tuple[str, str, str]:
        """
        Process text message and return response.
        
        Args:
            message: User's text message
            language: Language code (en, hi, te)
            session_id: Optional session ID
            
        Returns:
            Tuple of (reply, session_id, message_id)
        """
        logger.info(f"Processing text message: {message[:50]}... (lang={language})")
        
        # Get or create session
        session_id = cls.get_session_id(session_id)
        
        # Add user message to history
        cls.add_to_history(session_id, "user", message)
        
        # Generate response (stub - replace with actual LLM call)
        responses = cls.RESPONSES.get(language, cls.RESPONSES["en"])
        reply = random.choice(responses)
        
        # Add assistant message to history
        cls.add_to_history(session_id, "assistant", reply)
        
        # Generate message ID
        message_id = str(uuid.uuid4())
        
        logger.info(f"Generated response for session {session_id}")
        
        return reply, session_id, message_id
    
    @classmethod
    async def process_voice_message(
        cls,
        audio_bytes: bytes,
        language: str,
        session_id: Optional[str] = None
    ) -> Tuple[str, str, str, Optional[str]]:
        """
        Process voice message and return response.
        
        Args:
            audio_bytes: Audio file bytes
            language: Language code (en, hi, te)
            session_id: Optional session ID
            
        Returns:
            Tuple of (reply, session_id, message_id, audio_url)
        """
        logger.info(f"Processing voice message (lang={language}, size={len(audio_bytes)} bytes)")
        
        # Get or create session
        session_id = cls.get_session_id(session_id)
        
        # TODO: Implement speech-to-text transcription
        # For now, use a placeholder message
        transcribed_text = "[Voice message received]"
        
        # Add user message to history
        cls.add_to_history(session_id, "user", transcribed_text)
        
        # Generate response (stub - replace with actual LLM call)
        responses = cls.RESPONSES.get(language, cls.RESPONSES["en"])
        reply = random.choice(responses)
        
        # Add assistant message to history
        cls.add_to_history(session_id, "assistant", reply)
        
        # Generate message ID
        message_id = str(uuid.uuid4())
        
        # TODO: Implement text-to-speech for audio URL
        # For now, return None (client will use flutter_tts)
        audio_url = None
        
        logger.info(f"Generated voice response for session {session_id}")
        
        return reply, session_id, message_id, audio_url
