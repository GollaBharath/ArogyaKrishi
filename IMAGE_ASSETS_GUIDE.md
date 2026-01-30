# Image Assets Guide for ArogyaKrishi Offline Mode

## Folder Structure

All images are stored in the `assets/images/` directory with the following structure:

```
mobile-app/
└── assets/
    └── images/
        ├── crops/           # Crop images
        │   ├── rice.png
        │   ├── wheat.png
        │   ├── cotton.png
        │   ├── tomato.png
        │   ├── potato.png
        │   ├── groundnut.png
        │   ├── sugarcane.png
        │   └── maize.png
        │
        └── symptoms/        # Symptom images
            ├── yellow_leaves.png
            ├── brown_spots.png
            ├── wilting.png
            ├── stunted_growth.png
            ├── white_powder.png
            ├── root_rot.png
            ├── early_blight.png
            └── leaf_curl.png
```

## Image Naming Scheme

### Crops

**Format:** `{crop_id}.png`

Examples:

- `rice.png` → for crop ID "rice"
- `wheat.png` → for crop ID "wheat"
- `cotton.png` → for crop ID "cotton"
- `tomato.png` → for crop ID "tomato"
- `potato.png` → for crop ID "potato"
- `groundnut.png` → for crop ID "groundnut"
- `sugarcane.png` → for crop ID "sugarcane"
- `maize.png` → for crop ID "maize"

### Symptoms

**Format:** `{symptom_id}.png`

Examples:

- `yellow_leaves.png` → for symptom ID "yellow_leaves"
- `brown_spots.png` → for symptom ID "brown_spots"
- `wilting.png` → for symptom ID "wilting"
- `stunted_growth.png` → for symptom ID "stunted_growth"
- `white_powder.png` → for symptom ID "white_powder"
- `root_rot.png` → for symptom ID "root_rot"
- `early_blight.png` → for symptom ID "early_blight"
- `leaf_curl.png` → for symptom ID "leaf_curl"

## Image Specifications

### Recommended Format

- **File Format:** PNG (with transparent background recommended)
- **Aspect Ratio:** Square (1:1)
- **Resolution:** At least 200x200 pixels for crops, 150x150 for symptoms

### Crop Images (assets/images/crops/)

- **Size:** 200x200 dp minimum
- **Content:** Clear view of the crop plant/leaves
- **Background:** Transparent or solid white
- **Style:** Realistic photos or quality illustrations

### Symptom Images (assets/images/symptoms/)

- **Size:** 150x150 dp minimum
- **Content:** Close-up of the symptom on the leaf/plant
- **Background:** Transparent or solid white
- **Style:** Clear disease/pest evidence

## Fallback Behavior

If an image file is missing or fails to load:

1. **Crop Fallback:** Shows a green container with:
   - Eco icon (🌿)
   - First letter of crop name
   - Example: For "Rice" → shows "R" with eco icon

2. **Symptom Fallback:** Shows an amber container with:
   - Health & safety icon (⚕️)
   - First letter of symptom name
   - Example: For "Yellow Leaves" → shows "Y" with health icon

## Adding New Crops/Symptoms

To add a new crop or symptom:

1. **Update the IDs in `lib/services/mock_data_service.dart`:**

   ```dart
   static const Map<String, String> crops = {
     'rice': 'Rice',
     'new_crop': 'New Crop Name',  // ← Add here
   };
   ```

2. **Add corresponding image file:**
   - Place `new_crop.png` in `assets/images/crops/`
   - Or let it use the fallback icon if image is not available yet

3. **No code changes needed** - the `ImageAssetService` automatically looks for images based on the crop/symptom ID.

## Code Integration

Images are loaded using `ImageAssetService` class from `lib/services/image_asset_service.dart`:

### For Crops

```dart
ImageAssetService.buildCropImage(
  cropId: crop.id,
  cropName: crop.name,
  size: 80,  // width and height in dp
)
```

### For Symptoms

```dart
ImageAssetService.buildSymptomImage(
  symptomId: symptom.id,
  symptomName: symptom.name,
  size: 60,  // width and height in dp
)
```

Both methods automatically handle missing images and show the fallback icon.

## Testing Images Locally

1. Add PNG files to the appropriate folders
2. Run `flutter pub get` to update assets
3. Build and run: `flutter run`
4. Images should load if file names match crop/symptom IDs

## If Images Don't Load

1. **Check file names match crop/symptom IDs exactly** (case-sensitive)
2. **Verify pubspec.yaml has assets configured:**
   ```yaml
   flutter:
     assets:
       - assets/images/crops/
       - assets/images/symptoms/
   ```
3. **Run `flutter clean && flutter pub get`** to force asset rebuild
4. **Check console for error messages** - will show which images failed to load

## Future Enhancements

- Add image upload functionality for custom symptoms
- Support for multiple language-specific labels
- Image resize/optimize pipeline
- Local caching of downloaded images when backend integrates
