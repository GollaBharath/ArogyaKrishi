# Offline Mode - Visual Architecture & Data Flow

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        ArogyaKrishi App                         │
│                      (Mobile - Flutter)                         │
└─────────────────────────────────────────────────────────────────┘
                              │
                    ┌─────────┴──────────┐
                    │                    │
              ┌─────▼────────┐    ┌─────▼─────────┐
              │  Online Mode │    │ Offline Mode  │
              │  (Backend)   │    │  (Local Data) │
              └──────────────┘    └─────┬─────────┘
                                        │
                         ┌──────────────┴──────────────┐
                         │                             │
                  ┌──────▼──────┐            ┌────────▼──────┐
                  │ Connectivity│            │  Mock Data    │
                  │  Detector   │            │   Service     │
                  └─────────────┘            └───────┬───────┘
                                                     │
                          ┌──────────────────────────┼──────────────────┐
                          │                          │                  │
                   ┌──────▼─────────┐        ┌──────▼──────┐   ┌──────▼──────┐
                   │ Offline Screen │        │   Crops     │   │  Symptoms   │
                   │  (UI Layer)    │        │   Diseases  │   │  Remedies   │
                   └────────────────┘        └─────────────┘   └─────────────┘
```

## User Flow - Offline Diagnosis

```
                              START
                               │
                    ┌──────────▼────────────┐
                    │ Is Device Online?     │
                    └──────────┬────────────┘
                               │
                ┌──────────────┴──────────────┐
                │                             │
           YES │                             │ NO
                ▼                             ▼
        ┌───────────────┐         ┌──────────────────────┐
        │ Show "Online" │         │ Show "Offline" Badge │
        │   Badge       │         │ & Notification       │
        └───────────────┘         └──────────┬───────────┘
                                             │
                    ┌────────────────────────┴────────────────────────┐
                    │                                                 │
                    ▼                                                 ▼
        ┌────────────────────┐                         ┌─────────────────────┐
        │ Click "Select      │                         │ Click "Offline      │
        │  Image"            │                         │ Diagnosis"          │
        └────────────────────┘                         └─────────────────────┘
                    │                                                 │
                    ├─────────────────────────────────┬───────────────┤
                    │                                 │               │
                    ▼                                 ▼               │
        ┌────────────────────────┐         ┌──────────────────────┐  │
        │ Upload Image to        │         │ OFFLINE DIAGNOSIS    │  │
        │ Backend                │         │ STEP 1: Select Crop  │  │
        └────────────────────────┘         └──────────┬───────────┘  │
                                                      │              │
                                           ┌──────────▼──────────┐  │
                                           │ Show Crop Grid      │  │
                                           │ (Rice, Wheat, etc)  │  │
                                           └──────────┬──────────┘  │
                                                      │              │
                                           ┌──────────▼──────────┐  │
                                           │ STEP 2: Select      │  │
                                           │ Symptoms            │  │
                                           └──────────┬──────────┘  │
                                                      │              │
                                           ┌──────────▼──────────┐  │
                                           │ Show Symptom        │  │
                                           │ Checklist           │  │
                                           │ (Filtered by Crop)  │  │
                                           └──────────┬──────────┘  │
                                                      │              │
                                           ┌──────────▼──────────┐  │
                                           │ STEP 3: Analyze &   │  │
                                           │ Show Disease        │  │
                                           └──────────┬──────────┘  │
                                                      │              │
                                           ┌──────────▼──────────┐  │
                                           │ Display:            │  │
                                           │ • Disease Name      │  │
                                           │ • Description       │  │
                                           │ • Remedies (List)   │  │
                                           │ • Expert Disclaimer │  │
                                           └──────────┬──────────┘  │
                                                      │              │
                                           ┌──────────▼──────────┐  │
                                           │ Options:            │  │
                                           │ • Share Result      │  │
                                           │ • Start Over        │  │
                                           └─────────────────────┘  │
```

## Data Linking Structure

```
┌──────────────────────────────────────────────────────────────┐
│                  MOCK DATA SERVICE                           │
└──────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
   ┌────────────┐    ┌────────────┐    ┌─────────────┐
   │   CROPS    │    │  SYMPTOMS  │    │  DISEASES   │
   ├────────────┤    ├────────────┤    ├─────────────┤
   │ rice       │    │ yellow_... │    │ blast       │
   │ wheat      │    │ brown_...  │    │ leaf_spot   │
   │ cotton     │    │ wilting    │    │ powdery_... │
   │ tomato     │    │ powdery... │    │ root_rot    │
   │ potato     │    │ root_rot   │    │ early_...   │
   │ groundnut  │    │ leaf_curl  │    │ late_...    │
   │ sugarcane  │    │ stem_rot   │    │ yellowing.. │
   │ maize      │    │ aphids     │    │ cotton_...  │
   └────────────┘    └────────────┘    └─────────────┘
        │                   │                   │
        │                   │                   │
        └───────────┬───────┴───────────────┬───┘
                    │                       │
        ┌───────────▼─────────┐  ┌─────────▼──────────┐
        │  CROP→DISEASES      │  │ DISEASE→SYMPTOMS   │
        │  cropDiseases Map   │  │ diseaseSymptoms    │
        ├─────────────────────┤  ├────────────────────┤
        │ rice →              │  │ blast →            │
        │   [blast, ...]      │  │   [brown_spots,    │
        │                     │  │    wilting]        │
        │ wheat →             │  │                    │
        │   [leaf_spot, ...]  │  │ leaf_spot →        │
        │                     │  │   [brown_spots,    │
        │ tomato →            │  │    yellow_leaves]  │
        │   [early_blight,    │  │                    │
        │    late_blight]     │  │ powdery_mildew →   │
        │                     │  │   [powdery_coat,   │
        │ potato →            │  │    leaf_curl]      │
        │   [early_blight,    │  │                    │
        │    late_blight,     │  │ ... more mappings  │
        │    root_rot]        │  │                    │
        │                     │  │                    │
        │ ... more            │  │                    │
        └─────────────────────┘  └────────────────────┘
```

## Diagnosis Algorithm

```
User selects Crop
       │
       ▼
Get all DISEASES for this crop
from cropDiseases[crop_id]
       │
       ▼
Get all SYMPTOMS for each disease
from diseaseSymptoms[disease_id]
       │
       ▼
User selects SYMPTOMS
       │
       ▼
┌──────────────────────────────────┐
│ Score each disease:              │
│ - For each user-selected symptom │
│ - Check if disease has symptom   │
│ - Add +1 to disease score        │
└──────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────┐
│ Find disease with highest score  │
│ If score > 0, show disease       │
│ Else, show "No match found"      │
└──────────────────────────────────┘
       │
       ▼
Display:
- Disease Name
- Description
- List of Remedies (1-5 steps each)
- Expert Disclaimer
```

## File Structure

```
mobile-app/
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── home_screen.dart ............................ Updated with offline UI
│   │   └── offline_detection_screen.dart ............... NEW! Main offline UI
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── image_service.dart
│   │   ├── mock_data_service.dart ..................... NEW! Offline data
│   │   │   ├── crops map (8 entries)
│   │   │   ├── symptoms map (8 entries)
│   │   │   ├── diseases map (8 entries)
│   │   │   ├── cropDiseases map
│   │   │   └── diseaseSymptoms map
│   │   └── offline_detector.dart ....................... NEW! Connectivity
│   ├── models/
│   │   ├── detection_result.dart
│   │   └── nearby_alert.dart
│   └── utils/
├── pubspec.yaml ........................................ Updated (added connectivity_plus)
└── README.md ............................................ Updated with offline docs
```

## State Management Flow

```
Home Screen
    │
    ├─► OfflineDetector.isOnline()
    │       │
    │       ├─► Online = true → Show image upload
    │       └─► Online = false → Show offline banner
    │
    ├─► User clicks "Offline Diagnosis"
    │       │
    │       └─► Navigate to OfflineDetectionScreen
    │               │
    │               ├─► MockDataService.getCrops()
    │               │
    │               ├─► User selects crop
    │               │       │
    │               │       ├─► Get diseases for crop
    │               │       └─► Get symptoms for those diseases
    │               │
    │               ├─► User selects symptoms
    │               │       │
    │               │       └─► Analyze (score diseases)
    │               │
    │               └─► Display matched disease + remedies
```

## Data Validation Rules

```
✅ Valid ID: 'rice', 'leaf_spot', 'yellow_leaves'
❌ Invalid ID: 'Rice', 'leaf spot', 'yellow-leaves'
   (avoid capitals and spaces)

✅ Valid Remedy: 'Spray with fungicide weekly'
❌ Invalid Remedy: Empty string

✅ All IDs must be present in relevant maps
✅ No orphaned IDs (IDs not linked in mapping)
```

## Performance Characteristics

- **Crop selection screen**: Renders 8 crop cards instantly (grid)
- **Symptom selection**: Renders 2-5 symptoms per crop (filtered)
- **Disease diagnosis**: O(n\*m) where n=diseases, m=symptoms (instant for MVP data)
- **Memory**: ~15KB for mock data (negligible)
- **Startup time**: <100ms to load all data (on device)

All operations are synchronous for instant UI response!

---

## Next Steps After Backend Integration

```
Current (Offline Only):
┌─────────────────────────┐
│  MockDataService        │
│  (8 crops, 8 diseases)  │
└─────────────────────────┘

Future (When Backend Ready):
┌──────────────────────┐         ┌──────────────────────┐
│  MockDataService     │         │  Backend API         │
│  (Fallback)          │         │  (Live Data)         │
└──────────────────────┘         └──────────────────────┘
         │                                │
         └───────────────┬────────────────┘
                         │
              ┌──────────▼──────────┐
              │  Offline Detection  │
              │  Screen (works for  │
              │  both online/       │
              │  offline)           │
              └─────────────────────┘
```
