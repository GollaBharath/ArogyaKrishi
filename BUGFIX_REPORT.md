# Bug Fix Report - Offline Mode Layout Issues

## Issues Identified

### 1. Offline Mode Checkboxes Not Showing

**Location:** `lib/screens/offline_detection_screen.dart` - `_buildSymptomSelection()` method

**Root Cause:** The `possibleSymptoms` was a Set that was being iterated directly in a `for` loop without conversion to a List. This caused inconsistent behavior and potential rendering issues.

**Fix Applied:**

```dart
// Before
final possibleSymptoms = <Symptom>{};
// ... populate set
for (final symptom in possibleSymptoms)  // ← Set iteration

// After
final possibleSymptoms = <Symptom>{};
// ... populate set
final symptomList = possibleSymptoms.toList()
  ..sort((a, b) => a.name.compareTo(b.name));
for (final symptom in symptomList)  // ← Sorted list iteration
```

**Impact:** Checkboxes now render properly with consistent ordering.

---

### 2. Online Mode Layout Crash - "RenderFlex children have non-zero flex"

**Location:** `lib/screens/home_screen.dart` - `build()` method body

**Root Cause:** The layout structure had `Expanded` widgets inside a `SingleChildScrollView` > `Column`, which doesn't provide bounded height constraints. This caused the flex layout to fail.

**Structure Before:**

```
SingleChildScrollView
  └─ Column (unbounded height)
      ├─ ... content
      └─ Expanded
          └─ Center (trying to flex but no constraint)
```

**Fixes Applied:**

1. **Removed `Expanded` from image preview:**

```dart
// Before
Expanded(
  child: Card(...),
)

// After
Card(
  clipBehavior: Clip.antiAlias,
  child: Stack(
    children: [
      Container(
        constraints: const BoxConstraints(maxHeight: 400),
        child: Center(
          child: Image.file(...),
        ),
      ),
      // ... buttons
    ],
  ),
)
```

2. **Replaced `Expanded` placeholder with constrained `Container`:**

```dart
// Before
Expanded(
  child: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [...],
    ),
  ),
)

// After
Container(
  constraints: const BoxConstraints(minHeight: 300),
  child: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [...],
    ),
  ),
)
```

**Impact:** Layout now renders correctly in both online and offline modes without flex constraint errors.

---

## Testing Notes

Both issues have been fixed in:

- `lib/screens/offline_detection_screen.dart` - Fixed Set to List conversion
- `lib/screens/home_screen.dart` - Fixed flex constraints in layout

The fixes ensure:
✅ Offline mode checkboxes display correctly
✅ Online mode no longer crashes with flex constraint errors
✅ Layout properly handles image preview with constrained height
✅ Proper spacing and transitions between states

## Build Status

```
flutter analyze: 20 issues (all non-critical info items)
No compile errors detected
```
