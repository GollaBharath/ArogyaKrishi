## Global Rules (MANDATORY)

- Complete **one checkbox at a time**
- Do **not** combine steps
- Do **not** invent features not listed
- After completing a checkbox:
  - Summarize what was done
  - Ask for explicit confirmation to proceed

- If blocked, return a **mock or stub** instead of skipping

# ✅ CHECKLIST — ANDROID APP (Flutter)

## Global Rules (MANDATORY)

- Complete **one checkbox at a time**
- Do **not** invent backend logic
- Do **not** bypass API contracts
- Confirm after every checkbox

---

## Phase F0: Context & Setup

- [x] Read backend API contracts
- [x] Confirm Flutter version (3.38.8 stable, Dart 3.10.7)
- [x] Confirm Android-only scope (for MVP)

---

## Phase F1: Flutter Project Setup

- [x] Initialize Flutter project (com.arogyakrishi.arogya_krishi)
- [x] Set app name & package id (ArogyaKrishi)
- [x] Configure Android permissions:
  - camera
  - storage
  - internet
  - location (optional)

---

## Phase F2: App Architecture

- [x] Define folder structure:
  - screens/
  - services/
  - models/
  - utils/

- [x] Choose state management (simple only) - using setState
- [x] Define API service layer (ApiService with detectImage & getNearbyAlerts)

---

## Phase F3: Image Capture & Upload

- [x] Integrate camera/gallery picker (image_picker)
- [x] Compress image before upload (flutter_image_compress)
- [x] Handle permission denial (permission_handler)
- [x] Preview selected image (HomeScreen with image preview)

---

## Phase F4: Backend Integration

- [ ] Implement API client
- [ ] Call `/detect-image`
- [ ] Handle loading state
- [ ] Handle error responses
- [ ] Parse JSON response

---

## Phase F5: Detection Result UI

- [ ] Display crop name
- [ ] Display disease name
- [ ] Display confidence score
- [ ] Display remedies list
- [ ] Display advisory disclaimer

---

## Phase F6: Local Language Support (UI)

- [ ] Select supported languages
- [ ] Toggle language setting
- [ ] Display translated content from backend

---

## Phase F7: Offline Mode (Client-Side)

- [ ] Detect offline state
- [ ] Show offline diagnosis flow
- [ ] Crop → symptom → disease UI
- [ ] Display offline remedies

---

## Phase F8: Nearby Alerts UI

- [ ] Fetch `/nearby-alerts`
- [ ] Display soft warning banner
- [ ] Avoid panic language

---

## Phase F9: Google Maps Integration

- [ ] Generate Maps search URL
- [ ] Open nearest agri store link
- [ ] Handle location unavailable case

---

## Phase F10: Reminders (Local)

- [ ] Implement local notifications
- [ ] Schedule reminder
- [ ] Allow user to cancel reminder

---

## Phase F11: Safety & UX

- [ ] Display disclaimers clearly
- [ ] Handle low-confidence detections
- [ ] Provide retry options

---

## Phase F12: Demo Readiness

- [ ] Test happy path
- [ ] Test offline path
- [ ] Test poor network
- [ ] Prepare demo script
