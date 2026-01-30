## Global Rules (MANDATORY)

- Complete **one checkbox at a time**
- Do **not** combine steps
- Do **not** invent features not listed
- After completing a checkbox:
  - Summarize what was done
  - Ask for explicit confirmation to proceed

- If blocked, return a **mock or stub** instead of skipping

---

## Phase 0: Project Initialization & Constraints

- [ ] Read and acknowledge `brain.md`
- [ ] Read and acknowledge `architecture.md`
- [ ] Identify explicit non-goals from `brain.md`
- [ ] Confirm technology choices (FastAPI, Python, backend ML)

---

## Phase 1: Backend Skeleton (FastAPI)

### 1.1 Repository & Environment

- [ ] Initialize Python project
- [ ] Create virtual environment instructions
- [ ] Define `requirements.txt`
- [ ] Pin versions for FastAPI, Uvicorn, Pillow, ML libs

### 1.2 Base Folder Structure

- [ ] Create `app/` package
- [ ] Create `main.py`
- [ ] Create `api/` module
- [ ] Create `services/` module
- [ ] Create `models/` module (ML + data)
- [ ] Create `utils/` module
- [ ] Create `data/` directory (static mappings)

### 1.3 App Bootstrapping

- [ ] Initialize FastAPI app
- [ ] Add CORS middleware
- [ ] Add startup event handler
- [ ] Add shutdown handler

### 1.4 Health & Sanity

- [ ] Add `/health` endpoint
- [ ] Add `/version` endpoint
- [ ] Verify app runs via Uvicorn

---

## Phase 2: Image Upload & Preprocessing

### 2.1 Image Input Handling

- [ ] Accept multipart image upload
- [ ] Validate file type (jpg/png)
- [ ] Enforce file size limit
- [ ] Handle invalid image gracefully

### 2.2 Image Preprocessing

- [ ] Convert image to RGB
- [ ] Resize to model input size
- [ ] Normalize pixel values
- [ ] Isolate preprocessing logic into utility function

---

## Phase 3: Plant Disease Detection (ML)

### 3.1 Model Strategy

- [ ] Select pretrained plant disease model
- [ ] Document model source and limitations
- [ ] Define expected input/output format

### 3.2 Model Loading

- [ ] Implement model loader
- [ ] Load model at app startup
- [ ] Ensure model loads only once
- [ ] Handle model load failure

### 3.3 Inference Logic

- [ ] Implement inference function
- [ ] Map model output → disease label
- [ ] Compute confidence score
- [ ] Apply confidence threshold

### 3.4 Mock Fallback

- [ ] Implement mock prediction logic
- [ ] Toggle mock via environment variable
- [ ] Ensure app works without real model

---

## Phase 4: Detection API Endpoint

- [ ] Implement `POST /detect-image`
- [ ] Connect image preprocessing
- [ ] Connect inference logic
- [ ] Return crop, disease, confidence
- [ ] Return consistent JSON schema
- [ ] Handle low-confidence cases

---

## Phase 5: Remedies & Guidance

### 5.1 Disease Knowledge Base

- [ ] Create disease → remedy mapping (JSON)
- [ ] Limit to selected crops/diseases
- [ ] Include:
  - Symptoms
  - Basic remedies
  - Preventive advice

### 5.2 Remedy Service

- [ ] Load remedy data at startup
- [ ] Lookup remedies by disease
- [ ] Handle unknown disease safely

### 5.3 API Integration

- [ ] Attach remedies to detection response
- [ ] Add advisory disclaimer text

---

## Phase 6: Local Language Support (Limited)

- [ ] Select supported languages
- [ ] Create translation mapping for:
  - Disease name
  - Remedy steps

- [ ] Add language parameter to API
- [ ] Fallback to English if missing

---

## Phase 7: Nearby Disease Alerts (Soft Alerts)

### 7.1 Detection Event Storage

- [ ] Define detection event schema
- [ ] Store:
  - disease
  - latitude
  - longitude
  - timestamp
  - confidence

### 7.2 Geo Logic

- [ ] Implement distance calculation
- [ ] Filter events within 2 km radius
- [ ] Apply confidence threshold

### 7.3 Alerts API

- [ ] Implement `GET /nearby-alerts`
- [ ] Return soft alert messages
- [ ] Avoid panic-inducing language

---

## Phase 8: GPT Advisory Cross-Check (Optional, Advisory Only)

### 8.1 Scope Definition

- [ ] Explicitly mark as non-authoritative
- [ ] Define safe prompt boundaries

### 8.2 Prompt Engineering

- [ ] Create fixed GPT prompt template
- [ ] Restrict outputs to general advice
- [ ] Prevent regulatory or chemical claims

### 8.3 Integration

- [ ] Call GPT with crop + disease + medicine
- [ ] Attach response as “AI advisory”
- [ ] Fail gracefully if GPT unavailable

---

## Phase 9: Offline Mode Support (Backend Awareness)

- [ ] Document offline logic assumptions
- [ ] Ensure backend APIs do not depend on offline state
- [ ] Provide offline-compatible disease metadata endpoint

---

## Phase 10: Notifications & Reminders (Backend Prep)

- [ ] Define reminder data structure
- [ ] Expose reminder-related endpoints (stub)
- [ ] Leave scheduling to client (Flutter)

---

## Phase 11: Safety, Ethics & Guardrails

- [ ] Add disclaimer fields in responses
- [ ] Avoid definitive medical language
- [ ] Handle misclassification messaging
- [ ] Log errors without exposing internals

---

## Phase 12: Documentation & Demo Readiness

- [ ] Verify OpenAPI docs
- [ ] Add sample request/response
- [ ] Prepare demo dataset
- [ ] Confirm Flutter/React compatibility

---

## Final Rule (VERY IMPORTANT)

> The agent **must stop after each checkbox**, summarize changes, and explicitly ask:
>
> **“May I proceed to the next task?”**
