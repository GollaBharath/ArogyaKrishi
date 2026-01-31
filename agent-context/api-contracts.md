# API Contracts

POST /detect-image
Request:

- multipart/form-data
  - image
  - lat (optional)
  - lng (optional)

Response:

```json
{
    "crop": "string",
    "disease": "string",
    "confidence": float,
    "remedies": [string],
    "language": "en|te|hi"
}
```

GET /nearby-alerts
Response:

```json
{
"alerts": [
        {
            "disease": "string",
            "distance_km": float,
            "timestamp": "iso"
        }
    ]
}
```

POST /scan-treatment
Request:

- multipart/form-data
  - image
  - disease (localized or English key)
  - item_label (optional)
  - language (en|te|hi|kn|ml)

Response:

```json
{
	"disease": "string",
	"language": "en|te|hi|kn|ml",
	"item_label": "string | null",
	"will_cure": true,
	"feedback": "string"
}
```

GET /suggested-treatments
Request:

- query params
  - disease (required)
  - language (optional)
  - lat (required for real-time stores)
  - lng (required for real-time stores)

Response:

```json
{
  "disease": "string",
  "language": "en|te|hi|kn|ml",
  "remedies": ["string"],
  "stores": [
    {
      "name": "string",
      "address": "string | null",
      "phone": "string | null",
      "latitude": float,
      "longitude": float,
      "distance_km": float | null
    }
  ]
}
```

Notes:

- Real-time store lookup uses OpenStreetMap Overpass API (no API key required).

POST /register-device
Request:

- JSON body
  - device_token (required)
  - latitude (required)
  - longitude (required)
  - notifications_enabled (optional, default true)

Response:

```json
{
	"ok": true
}
```

---

## Chatbot APIs

POST /api/chat/text
Request:

- JSON body
  - message (required): User's text message
  - language (required): Language code (en|hi|te)
  - session_id (optional): Session identifier for conversation continuity

Response:

```json
{
	"reply": "string",
	"audio_url": "string | null",
	"session_id": "string",
	"language": "string",
	"message_id": "string"
}
```

POST /api/chat/voice
Request:

- multipart/form-data
  - audio (required): Audio file (WAV format)
  - language (required): Language code (en|hi|te)
  - session_id (optional): Session identifier for conversation continuity

Response:

```json
{
	"reply": "string",
	"audio_url": "string | null",
	"session_id": "string",
	"language": "string",
	"message_id": "string"
}
```

Notes:

- Session-based conversation tracking
- Backend handles LLM integration
- Audio URL is optional (TTS-generated response)
- Flutter uses speech_to_text for voice input
- Flutter uses flutter_tts for local TTS
- Audio playback via audioplayers package
