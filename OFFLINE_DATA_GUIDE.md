# Offline Mode - Quick Data Addition Guide

This guide shows you exactly how to add new crops, symptoms, and diseases to the offline mode.

## File Location

All data is in: **`lib/services/mock_data_service.dart`**

## Current Data

### Crops (8 total)

- Rice, Wheat, Cotton, Tomato, Potato, Groundnut, Sugarcane, Maize

### Symptoms (8 total)

- Yellow Leaves, Brown Spots, Wilting, Powdery Coating, Root Rot, Leaf Curl, Stem Rot, Aphids/Insects

### Diseases (8 total)

- Blast, Leaf Spot, Powdery Mildew, Root Rot, Early Blight, Late Blight, Yellowing Virus, Cotton Bollworm

## Quick Add Template

### 1️⃣ Adding a Crop

**File**: `mock_data_service.dart` → `crops` map

```dart
static const Map<String, String> crops = {
  'rice': 'Rice',
  // ... existing crops ...
  'lemon': 'Lemon',  // ← ADD THIS LINE
};
```

**Then add to `cropDiseases` map:**

```dart
static const Map<String, List<String>> cropDiseases = {
  'rice': ['blast', 'leaf_spot'],
  // ... existing mappings ...
  'lemon': ['citrus_canker', 'powdery_mildew'],  // ← ADD THIS LINE
};
```

---

### 2️⃣ Adding a Symptom

**File**: `mock_data_service.dart` → `symptoms` map

```dart
static const Map<String, Map<String, String>> symptoms = {
  'yellow_leaves': {
    'name': 'Yellow Leaves',
    'description': 'Leaves are turning yellow',
  },
  // ... existing symptoms ...
  'citrus_spots': {  // ← ADD THIS BLOCK
    'name': 'Citrus-like Spots',
    'description': 'Brown circular spots with yellow halos on leaves',
  },
};
```

**Then add to `diseaseSymptoms` map:**

```dart
static const Map<String, List<String>> diseaseSymptoms = {
  'blast': ['brown_spots', 'wilting'],
  // ... existing mappings ...
  'citrus_canker': ['citrus_spots', 'yellow_leaves'],  // ← ADD THIS LINE
};
```

---

### 3️⃣ Adding a Disease

**File**: `mock_data_service.dart` → `diseases` map

```dart
static const Map<String, Map<String, dynamic>> diseases = {
  'blast': {
    'name': 'Blast',
    'description': 'Fungal disease affecting rice',
    'remedies': [
      'Spray with Mancozeb (0.2%)',
      'Remove infected leaves',
    ],
  },
  // ... existing diseases ...
  'citrus_canker': {  // ← ADD THIS BLOCK
    'name': 'Citrus Canker',
    'description': 'Bacterial disease causing lesions on leaves, stems, and fruit',
    'remedies': [
      'Remove infected branches and burn them',
      'Spray with Copper Hydroxide (0.3%)',
      'Maintain strict sanitation and quarantine',
      'Avoid overhead irrigation to prevent spread',
      'Use disease-free planting material',
    ],
  },
};
```

**Then add to both maps:**

```dart
// In cropDiseases:
'lemon': ['citrus_canker', 'powdery_mildew'],

// In diseaseSymptoms:
'citrus_canker': ['citrus_spots', 'yellow_leaves'],
```

---

## Complete Example: Adding Lemon Crop

### Step 1: Add Crop to `crops`

```dart
static const Map<String, String> crops = {
  'rice': 'Rice',
  'wheat': 'Wheat',
  'cotton': 'Cotton',
  'tomato': 'Tomato',
  'potato': 'Potato',
  'groundnut': 'Groundnut',
  'sugarcane': 'Sugarcane',
  'maize': 'Maize',
  'lemon': 'Lemon',  // ← NEW
};
```

### Step 2: Add New Symptom to `symptoms`

```dart
static const Map<String, Map<String, String>> symptoms = {
  'yellow_leaves': {...},
  // ... existing symptoms ...
  'pustules': {  // ← NEW
    'name': 'Pustules on Leaves',
    'description': 'Brown pustules or raised spots on leaf surface',
  },
};
```

### Step 3: Add New Disease to `diseases`

```dart
static const Map<String, Map<String, dynamic>> diseases = {
  'blast': {...},
  // ... existing diseases ...
  'citrus_canker': {  // ← NEW
    'name': 'Citrus Canker',
    'description': 'Bacterial disease causing lesions on leaves',
    'remedies': [
      'Remove infected branches and burn them',
      'Spray with Copper Hydroxide (0.3%)',
      'Maintain strict sanitation',
      'Avoid overhead irrigation',
    ],
  },
};
```

### Step 4: Link Crop to Diseases in `cropDiseases`

```dart
static const Map<String, List<String>> cropDiseases = {
  'rice': ['blast', 'leaf_spot', 'yellowing_virus'],
  // ... existing mappings ...
  'lemon': ['citrus_canker', 'powdery_mildew'],  // ← NEW
};
```

### Step 5: Link Diseases to Symptoms in `diseaseSymptoms`

```dart
static const Map<String, List<String>> diseaseSymptoms = {
  'blast': ['brown_spots', 'wilting'],
  // ... existing mappings ...
  'citrus_canker': ['pustules', 'yellow_leaves'],  // ← NEW
};
```

### Step 6: Save and Run

```bash
cd mobile-app
flutter pub get
flutter run
```

---

## Verification Checklist

After adding data, verify:

- ✅ New crop appears in crop selection screen
- ✅ New symptoms appear when selecting that crop
- ✅ Selecting those symptoms shows the new disease
- ✅ Disease page shows all remedies
- ✅ No syntax errors (run `flutter analyze`)

---

## Common Mistakes to Avoid

❌ **WRONG**: Forgetting the comma after each entry

```dart
'lemon': 'Lemon'  // ← Missing comma!
'cotton': 'Cotton',
```

✅ **RIGHT**: Include the comma

```dart
'lemon': 'Lemon',
'cotton': 'Cotton',
```

---

❌ **WRONG**: Not linking in all required maps

```dart
// Only added to crops, forgot cropDiseases!
'lemon': 'Lemon',
```

✅ **RIGHT**: Link in both maps

```dart
// In crops
'lemon': 'Lemon',

// In cropDiseases
'lemon': ['citrus_canker', 'powdery_mildew'],
```

---

❌ **WRONG**: Using spaces or special characters in IDs

```dart
'lemon tree': 'Lemon Tree',  // ← Spaces not allowed!
```

✅ **RIGHT**: Use underscores or camelCase

```dart
'lemon_tree': 'Lemon Tree',
'lemonTree': 'Lemon Tree',
```

---

## Testing Your Data

### In Terminal:

```bash
# Check for syntax errors
flutter analyze

# Run the app
flutter run

# Check build
flutter build apk --debug
```

### In App:

1. Open offline mode
2. Your new crop should appear in the crop grid
3. Select it and check if symptoms appear
4. Select symptoms and verify diagnosis works
5. Check if all remedies are displayed

---

## Need More Help?

Refer to the main README at: **`mobile-app/README.md`**

For detailed data structure: **`lib/services/mock_data_service.dart`**
