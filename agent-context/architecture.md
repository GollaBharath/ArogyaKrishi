# System Architecture

Clients:

- Flutter mobile app (current)
- React web app (future)

Backend:

- Python FastAPI
- REST APIs only
- Stateless

Core Services:

1. Image Detection Service
   - Receives image
   - Runs pretrained ML model
   - Outputs disease + confidence

2. Remedy Service
   - Maps disease → remedies
   - Language support via static mappings

3. Advisory Service (Optional)
   - Uses LLM for cross-checking crop-disease-medicine relevance
   - Advisory only, not authoritative

Offline Mode:

- Implemented on client
- Backend unaware of offline logic

Data Store:

- MVP: simple DB (SQLite)
- Stores detection events for nearby alerts

Deployment:

- Single backend service
- No microservices
