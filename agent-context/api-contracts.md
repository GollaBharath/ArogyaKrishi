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
