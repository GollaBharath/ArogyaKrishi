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
