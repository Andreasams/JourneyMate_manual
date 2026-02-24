# dishBottomSheetMaxHeight Custom Function

**Status:** ✅ **PRODUCTION-READY** — Documented from FlutterFlow source
**Source:** `_flutterflow_export\lib\flutter_flow\custom_functions.dart` (Lines 1867-1923)
**Related:** `dishBottomSheetMinHeight` (companion function for collapsed state)
**Used in:** `ItemDetailSheet` widget (dish detail bottom sheet)

---

## Purpose

Calculates the **maximum expanded height** for the dish detail bottom sheet based on content size. This function determines how tall the sheet should be when fully dragged up, ensuring all content (header, description, image, dietary info, and disclaimer) fits within a reasonable screen percentage while preventing awkwardly small or excessively large sheets.

Works in tandem with `dishBottomSheetMinHeight` to create a smooth, content-aware bottom sheet experience where the sheet can expand from its collapsed state to show all available information.

---

## Function Signature

```dart
double dishBottomSheetMaxHeight(
  String? dishDescription,
  double screenHeight,
  bool hasImage,
  List<int>? dietaryDescription,
)
```

---

## Parameters

### Input Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `dishDescription` | `String?` | ✅ Yes | Dish description text. Used to calculate height needed for text content. Can be null if no description exists. |
| `screenHeight` | `double` | ✅ Yes | Total screen height in pixels (from `MediaQuery.of(context).size.height`). Used as basis for percentage calculations. |
| `hasImage` | `bool` | ✅ Yes | Whether the dish has an image to display. If `true`, adds 200px for image space. If `false`, image space is omitted. |
| `dietaryDescription` | `List<int>?` | ✅ Yes | List of dietary preference IDs (1-7). Used to determine dietary section height. Can be null/empty. |

### Parameter Notes

**dishDescription:**
- Null-safe: Uses `?? 0` to handle null values
- Length is multiplied by `textHeightPerChar` (0.35) to estimate text height
- Includes line breaks and formatting in character count

**screenHeight:**
- Must be positive and non-zero
- Typically ranges from ~600px (small phone) to ~900px (large phone/tablet)
- Used for both absolute calculations (base height) and percentage caps

**hasImage:**
- Simple boolean flag
- When `true`, adds fixed `imageHeight` constant (200px)
- When `false`, adds 0px

**dietaryDescription:**
- List of dietary IDs: 1=Gluten-free, 2=Pescetarian, 3=Halal, 4=Lactose-free, 5=Kosher, 6=Vegan, 7=Vegetarian
- Null/empty = no dietary items → uses larger empty state height (50px)
- Contains items → uses compact filled state height (25px)

---

## Return Value

**Type:** `double`

**Value:** Maximum height in pixels for fully expanded bottom sheet, capped at 90% of screen height

**Range:**
- **Minimum:** Base height (60% of screen) + expandable section (90px) ≈ ~450px on small screens
- **Maximum:** 90% of screen height ≈ ~810px on large screens

**Calculation:**
```
maxHeight = min(
  baseHeight + descriptionHeight + imageSpace + dietaryHeight + expandableHeight,
  screenHeight * 0.90
)
```

Where:
- `baseHeight` = `screenHeight * 0.60` (header, title, rating, price)
- `descriptionHeight` = `(dishDescription?.length ?? 0) * 0.35`
- `imageSpace` = `hasImage ? 200.0 : 0.0`
- `dietaryHeight` = `hasDietaryItems ? 25.0 : 50.0`
- `expandableHeight` = `90.0` (fixed height for disclaimer section)

---

## Dependencies

### Standard Library

```dart
import 'dart:math' as math;
```

**Usage:** `math.min()` to cap total height at maximum percentage

### Internal Dependencies

**None.** This is a pure calculation function with no dependencies on other custom functions.

---

## FFAppState Usage

**None.** This function does not access or modify `FFAppState`. All inputs are passed as parameters.

---

## Usage Examples

### Example 1: Dish with All Content (Image, Description, Dietary Info)

```dart
final maxHeight = dishBottomSheetMaxHeight(
  'A classic Italian pasta dish with creamy carbonara sauce, pancetta, and Parmesan cheese. Served with fresh black pepper.',
  844.0,  // iPhone 14 Pro Max height
  true,   // Has image
  [6],    // Vegetarian (ID: 6)
);

// Calculation:
// baseHeight = 844 * 0.60 = 506.4
// descriptionHeight = 126 chars * 0.35 = 44.1
// imageSpace = 200.0
// dietaryHeight = 25.0 (has items)
// expandableHeight = 90.0
// total = 506.4 + 44.1 + 200.0 + 25.0 + 90.0 = 865.5
// capped = min(865.5, 844 * 0.90) = min(865.5, 759.6) = 759.6

// Returns: 759.6 pixels
```

### Example 2: Minimal Dish (No Image, Short Description)

```dart
final maxHeight = dishBottomSheetMaxHeight(
  'Caesar salad',
  667.0,  // iPhone SE height
  false,  // No image
  null,   // No dietary info
);

// Calculation:
// baseHeight = 667 * 0.60 = 400.2
// descriptionHeight = 13 chars * 0.35 = 4.55
// imageSpace = 0.0
// dietaryHeight = 50.0 (empty state)
// expandableHeight = 90.0
// total = 400.2 + 4.55 + 0.0 + 50.0 + 90.0 = 544.75
// capped = min(544.75, 667 * 0.90) = min(544.75, 600.3) = 544.75

// Returns: 544.75 pixels
```

### Example 3: Very Long Description Hitting Cap

```dart
final longDescription = '''
This exquisite dish represents the pinnacle of modern French cuisine,
combining classical techniques with contemporary innovation. Our chef has
meticulously crafted each element to create a harmonious balance of flavors
and textures. The dish features locally-sourced seasonal vegetables,
sustainably-caught seafood, and artisanal ingredients from small producers.
Each component is prepared using traditional methods passed down through
generations of culinary masters.
''';

final maxHeight = dishBottomSheetMaxHeight(
  longDescription,  // 470 characters
  844.0,
  true,
  [1, 4],  // Gluten-free & Lactose-free
);

// Calculation:
// baseHeight = 844 * 0.60 = 506.4
// descriptionHeight = 470 chars * 0.35 = 164.5
// imageSpace = 200.0
// dietaryHeight = 25.0
// expandableHeight = 90.0
// total = 506.4 + 164.5 + 200.0 + 25.0 + 90.0 = 985.9
// capped = min(985.9, 844 * 0.90) = min(985.9, 759.6) = 759.6

// Returns: 759.6 pixels (capped)
```

### Example 4: Usage in ItemDetailSheet Widget

```dart
// In ItemDetailSheet build method:
return DraggableScrollableSheet(
  initialChildSize: dishBottomSheetMinHeight(
    widget.screenHeight,
    widget.dietaryDescription,
    widget.dishDescription,
    widget.hasImage,
  ) / widget.screenHeight,

  minChildSize: dishBottomSheetMinHeight(
    widget.screenHeight,
    widget.dietaryDescription,
    widget.dishDescription,
    widget.hasImage,
  ) / widget.screenHeight,

  maxChildSize: dishBottomSheetMaxHeight(
    widget.dishDescription,
    widget.screenHeight,
    widget.hasImage,
    widget.dietaryDescription,
  ) / widget.screenHeight,

  builder: (context, scrollController) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: ListView(
        controller: scrollController,
        children: [
          // Header with drag handle
          // Dish title and rating
          // Price and add-to-order button
          if (widget.hasImage) DishImage(...),
          if (widget.dishDescription != null) DescriptionSection(...),
          DietarySection(...),
          DisclaimerSection(...),  // The expandable section
        ],
      ),
    );
  },
);
```

---

## Constants Breakdown

### Height Calculation Constants

```dart
const baseHeightFactor = 0.60;  // Base height (60% of screen)
```
- **Purpose:** Covers header, title, rating, price, and add button
- **Why 60%:** Ensures essential info visible even on small screens
- **Screen-relative:** Scales proportionally with device size

```dart
const maxHeightFactor = 0.90;  // Maximum height cap (90% of screen)
```
- **Purpose:** Prevents sheet from covering entire screen
- **Why 90%:** Leaves 10% visible for context (status bar, visual anchor)
- **Accessibility:** Ensures users can see they're in a modal context

```dart
const imageHeight = 200.0;  // Fixed height for image
```
- **Purpose:** Reserved space for dish image
- **Fixed vs. Variable:** Image has defined aspect ratio and size
- **Same as minHeight:** Both functions use identical image height for consistency

```dart
const textHeightPerChar = 0.35;  // Estimated height per character
```
- **Purpose:** Estimate multi-line text height from character count
- **Calibration:** Based on typical line height + padding in ItemDetailSheet
- **Why higher than minHeight (0.3):** maxHeight includes expandable sections below text
- **Considerations:**
  - Assumes average character width
  - Includes word wrapping
  - Includes line spacing

```dart
const dietaryWithItemsHeight = 25.0;  // Height when dietary items present
```
- **Purpose:** Compact height when dietary info is displayed
- **Layout:** Single-line display of dietary preference badges

```dart
const dietaryEmptyHeight = 50.0;  // Height when no dietary items
```
- **Purpose:** Larger space for empty state messaging
- **Layout:** Shows "No dietary restrictions" message with padding

```dart
const expandableHeight = 90.0;  // Fixed height for disclaimer section
```
- **Purpose:** Space for "Information source" expandable section
- **Includes:**
  - Section header (30px)
  - Disclaimer text when expanded (60px)
  - Padding and borders
- **Critical:** This is the key difference from `minHeight` (which omits this)

---

## Algorithm Flow

### Step 1: Calculate Base Height

```dart
final baseHeight = screenHeight * baseHeightFactor;
```

**Covers:**
- Drag handle (24px)
- Dish title (40-60px depending on length)
- Rating display (32px)
- Price and add button (56px)
- Internal padding (~100px total)

**Total:** ~250-300px + 60% screen buffer = stable base

### Step 2: Calculate Description Height

```dart
final descriptionHeight = (dishDescription?.length ?? 0) * textHeightPerChar;
```

**Example calculations:**
- Short (50 chars): 50 * 0.35 = 17.5px
- Medium (150 chars): 150 * 0.35 = 52.5px
- Long (400 chars): 400 * 0.35 = 140px

### Step 3: Determine Image Space

```dart
final imageSpace = hasImage ? imageHeight : 0.0;
```

**Binary decision:**
- Has image → Add 200px
- No image → Add 0px

### Step 4: Calculate Dietary Section Height

```dart
final hasDietaryItems = dietaryDescription != null && dietaryDescription.isNotEmpty;
final dietaryHeight = hasDietaryItems ? dietaryWithItemsHeight : dietaryEmptyHeight;
```

**Logic:**
- `dietaryDescription` is null → `hasDietaryItems = false` → 50px
- `dietaryDescription` is empty list → `hasDietaryItems = false` → 50px
- `dietaryDescription` has items → `hasDietaryItems = true` → 25px

**Why empty is taller:** Empty state needs space for explanatory message

### Step 5: Add Expandable Section

```dart
// Implicit: expandableHeight constant is added in total calculation
```

**This is the key difference from minHeight:**
- minHeight: Excludes this section (collapsed state)
- maxHeight: Includes this section (expanded state)

### Step 6: Calculate Total and Apply Cap

```dart
final totalHeight = baseHeight + descriptionHeight + imageSpace + dietaryHeight + expandableHeight;

return math.min(totalHeight, screenHeight * maxHeightFactor);
```

**Cap logic:**
- If `totalHeight ≤ 90% screen` → Return `totalHeight`
- If `totalHeight > 90% screen` → Return `90% screen`

**Why cap at 90%:**
- Prevents covering entire screen
- Maintains modal context
- Ensures drag-to-dismiss gesture area remains visible

---

## Edge Cases

### Case 1: Null Description

**Input:**
```dart
dishBottomSheetMaxHeight(null, 844.0, true, [6])
```

**Behavior:**
- `dishDescription?.length ?? 0` → `0`
- `descriptionHeight = 0 * 0.35 = 0.0`
- Description section is omitted, height comes from other components

**Result:** Valid calculation, no error

---

### Case 2: Empty Dietary List vs. Null

**Input A:**
```dart
dishBottomSheetMaxHeight('Pasta', 844.0, true, [])
```

**Input B:**
```dart
dishBottomSheetMaxHeight('Pasta', 844.0, true, null)
```

**Behavior (Both):**
- `hasDietaryItems = false` (both empty and null)
- Uses `dietaryEmptyHeight = 50.0`

**Result:** Identical height for both cases

---

### Case 3: Very Small Screen

**Input:**
```dart
dishBottomSheetMaxHeight('Short', 568.0, false, null)  // iPhone SE 1st gen
```

**Calculation:**
- `baseHeight = 568 * 0.60 = 340.8`
- `descriptionHeight = 5 * 0.35 = 1.75`
- `imageSpace = 0.0`
- `dietaryHeight = 50.0`
- `expandableHeight = 90.0`
- `total = 340.8 + 1.75 + 0.0 + 50.0 + 90.0 = 482.55`
- `cap = 568 * 0.90 = 511.2`
- `result = min(482.55, 511.2) = 482.55`

**Result:** Under cap, uses calculated height

---

### Case 4: Very Large Screen (Tablet)

**Input:**
```dart
dishBottomSheetMaxHeight(longText, 1366.0, true, [1,2,3,4])  // iPad Pro 12.9"
```

**Calculation:**
- `baseHeight = 1366 * 0.60 = 819.6`
- `descriptionHeight = 400 * 0.35 = 140.0`
- `imageSpace = 200.0`
- `dietaryHeight = 25.0`
- `expandableHeight = 90.0`
- `total = 819.6 + 140.0 + 200.0 + 25.0 + 90.0 = 1274.6`
- `cap = 1366 * 0.90 = 1229.4`
- `result = min(1274.6, 1229.4) = 1229.4`

**Result:** Capped at 90%, prevents excessive height

---

### Case 5: Extremely Long Description (Edge Stress Test)

**Input:**
```dart
final massiveText = 'A' * 5000;  // 5000 characters
dishBottomSheetMaxHeight(massiveText, 844.0, true, [6])
```

**Calculation:**
- `baseHeight = 844 * 0.60 = 506.4`
- `descriptionHeight = 5000 * 0.35 = 1750.0`
- `imageSpace = 200.0`
- `dietaryHeight = 25.0`
- `expandableHeight = 90.0`
- `total = 506.4 + 1750.0 + 200.0 + 25.0 + 90.0 = 2571.4`
- `cap = 844 * 0.90 = 759.6`
- `result = min(2571.4, 759.6) = 759.6`

**Result:** Capped at 90%, scroll handles overflow

---

### Case 6: Zero/Invalid Screen Height (Error Condition)

**Input:**
```dart
dishBottomSheetMaxHeight('Pasta', 0.0, true, null)
```

**Behavior:**
- `baseHeight = 0 * 0.60 = 0.0`
- `total` will be very small (just fixed heights: 200 + 50 + 90 = 340px)
- `cap = 0 * 0.90 = 0.0`
- `result = min(340, 0) = 0.0`

**Result:** Returns 0.0, which will break layout

**Mitigation in Widget:**
Widget should validate screen height before calling:
```dart
final screenHeight = MediaQuery.of(context).size.height;
assert(screenHeight > 0, 'Screen height must be positive');
```

---

## Relationship with dishBottomSheetMinHeight

### Functional Relationship

These functions form a **min/max pair** for `DraggableScrollableSheet`:

```dart
DraggableScrollableSheet(
  minChildSize: dishBottomSheetMinHeight(...) / screenHeight,  // Collapsed state
  maxChildSize: dishBottomSheetMaxHeight(...) / screenHeight,  // Expanded state
  initialChildSize: dishBottomSheetMinHeight(...) / screenHeight,  // Start collapsed
  // ...
)
```

### Key Differences

| Aspect | minHeight | maxHeight |
|--------|-----------|-----------|
| **Purpose** | Collapsed preview state | Fully expanded state |
| **Base Factor** | 0.60 (60%) | 0.60 (60%) — Same |
| **Max Cap** | 0.65 (65%) | 0.90 (90%) |
| **Text Height/Char** | 0.3 | 0.35 |
| **Includes Expandable Section** | ❌ No (90px omitted) | ✅ Yes (90px added) |
| **Use Case** | Show key info without scrolling | Show all content when dragged up |

### Why Different Text Height Constants?

**minHeight uses 0.3:**
- Conservative estimate for collapsed state
- Prioritizes compact initial view
- Under-estimates slightly to keep sheet small

**maxHeight uses 0.35:**
- Slightly larger estimate for expanded state
- Accounts for additional padding around disclaimer section
- Over-estimates slightly to ensure content fits without cut-off

### Expandable Section (Critical Difference)

**The 90px expandable section is the defining difference:**

**Collapsed (minHeight):**
```
┌─────────────────────┐
│ Header + Drag       │
│ Title               │
│ Rating + Price      │
│ Image (if present)  │
│ Description         │
│ Dietary Info        │
└─────────────────────┘
```

**Expanded (maxHeight):**
```
┌─────────────────────┐
│ Header + Drag       │
│ Title               │
│ Rating + Price      │
│ Image (if present)  │
│ Description         │
│ Dietary Info        │
│ ┌─────────────────┐ │
│ │ Information     │ │  ← Expandable section (90px)
│ │ Source          │ │
│ │ Disclaimer...   │ │
│ └─────────────────┘ │
└─────────────────────┘
```

### Parameter Order Difference (Important!)

**minHeight signature:**
```dart
double dishBottomSheetMinHeight(
  double screenHeight,        // 1st
  List<int>? dietaryDescription,  // 2nd
  String? dishDescription,    // 3rd
  bool hasImage,             // 4th
)
```

**maxHeight signature:**
```dart
double dishBottomSheetMaxHeight(
  String? dishDescription,    // 1st ⚠️ Different order!
  double screenHeight,        // 2nd
  bool hasImage,             // 3rd
  List<int>? dietaryDescription,  // 4th
)
```

**⚠️ CRITICAL:** Parameter order differs between the two functions! This is a FlutterFlow quirk and must be handled carefully to avoid swapped arguments.

**Safe calling pattern:**
```dart
// Use named arguments to avoid confusion:
final minSize = dishBottomSheetMinHeight(
  screenHeight: height,
  dietaryDescription: dietary,
  dishDescription: description,
  hasImage: hasImg,
);

final maxSize = dishBottomSheetMaxHeight(
  dishDescription: description,
  screenHeight: height,
  hasImage: hasImg,
  dietaryDescription: dietary,
);
```

---

## Testing Checklist

### Unit Tests

- [ ] **Test 1: Null description returns valid height**
  - Input: `null` description, valid other params
  - Expected: Height > 0, no errors

- [ ] **Test 2: Empty dietary list same as null**
  - Input A: `dietaryDescription: []`
  - Input B: `dietaryDescription: null`
  - Expected: Identical heights returned

- [ ] **Test 3: Image flag affects height correctly**
  - Input A: `hasImage: true`
  - Input B: `hasImage: false` (same other params)
  - Expected: Difference = 200px

- [ ] **Test 4: Dietary items vs. empty affects height**
  - Input A: `dietaryDescription: [6]`
  - Input B: `dietaryDescription: null`
  - Expected: Difference = 25px (empty taller by 25px)

- [ ] **Test 5: Very long description hits 90% cap**
  - Input: 5000-char description, 844px screen
  - Expected: Returns `844 * 0.90 = 759.6`, not higher

- [ ] **Test 6: Short content stays under cap**
  - Input: 50-char description, no image, 844px screen
  - Expected: Returns calculated height < 759.6

- [ ] **Test 7: Minimum viable screen size**
  - Input: 568px screen (iPhone SE), minimal content
  - Expected: Returns reasonable height (400-500px range)

- [ ] **Test 8: Tablet screen respects cap**
  - Input: 1366px screen (iPad Pro), maximal content
  - Expected: Returns `1366 * 0.90 = 1229.4` (capped)

### Integration Tests

- [ ] **Test 9: minHeight always ≤ maxHeight**
  - For 20 random combinations of parameters
  - Expected: `minHeight(params) ≤ maxHeight(params)` in all cases

- [ ] **Test 10: Difference equals expandable section**
  - For same parameters to both functions
  - Expected: `maxHeight - minHeight ≈ 90px + (text constant diff * desc length)`

- [ ] **Test 11: DraggableScrollableSheet accepts sizes**
  - Input: Heights converted to size fractions
  - Expected: `minChildSize ≤ maxChildSize ≤ 1.0`

- [ ] **Test 12: Bottom sheet renders without overflow**
  - Create ItemDetailSheet with maxHeight
  - Expected: No overflow errors, all content visible when scrolled

### Edge Case Tests

- [ ] **Test 13: Zero screen height (error condition)**
  - Input: `screenHeight: 0.0`
  - Expected: Returns 0.0 (degrades gracefully, widget should validate)

- [ ] **Test 14: Negative screen height (invalid)**
  - Input: `screenHeight: -844.0`
  - Expected: Returns negative (invalid, widget should validate)

- [ ] **Test 15: Parameter order swap detection**
  - Input: Accidentally swap description and screenHeight
  - Expected: Type error at compile time (different types) OR runtime assertion

---

## Migration Notes

### FlutterFlow → Pure Flutter Changes

**1. Function Location**

**FlutterFlow:**
```
lib/flutter_flow/custom_functions.dart
```

**Pure Flutter:**
```
lib/shared/functions/dish_bottom_sheet_sizing.dart
```

Consolidate both min/max functions into single file to keep them together.

---

**2. Null Safety Enhancement**

**FlutterFlow (current):**
```dart
final descriptionHeight = (dishDescription?.length ?? 0) * textHeightPerChar;
```

**Pure Flutter (enhanced):**
```dart
final descriptionLength = dishDescription?.trim().length ?? 0;
final descriptionHeight = descriptionLength * textHeightPerChar;
```

Add `.trim()` to ignore whitespace-only descriptions.

---

**3. Add Validation**

**Add to pure Flutter version:**
```dart
double dishBottomSheetMaxHeight(
  String? dishDescription,
  double screenHeight,
  bool hasImage,
  List<int>? dietaryDescription,
) {
  // Validate screen height
  assert(
    screenHeight > 0,
    'Screen height must be positive, got: $screenHeight',
  );

  if (screenHeight <= 0) {
    debugPrint('⚠️ Invalid screen height: $screenHeight, returning default 500px');
    return 500.0;
  }

  // Rest of function...
}
```

---

**4. Consolidate Constants**

**Create shared constants file:**
```dart
// lib/shared/constants/bottom_sheet_constants.dart

class BottomSheetSizing {
  // Height factors
  static const double baseHeightFactor = 0.60;
  static const double minHeightMaxFactor = 0.65;
  static const double maxHeightMaxFactor = 0.90;

  // Component heights
  static const double imageHeight = 200.0;
  static const double dietaryWithItemsHeight = 25.0;
  static const double dietaryEmptyHeight = 50.0;
  static const double expandableHeight = 90.0;

  // Text estimation
  static const double textHeightPerCharMin = 0.30;
  static const double textHeightPerCharMax = 0.35;
}
```

Use shared constants in both functions to ensure consistency.

---

**5. Standardize Parameter Order**

**Create wrapper with consistent order:**
```dart
// lib/shared/functions/dish_bottom_sheet_sizing.dart

class DishBottomSheetSizing {
  static double getMinHeight({
    required double screenHeight,
    required bool hasImage,
    String? dishDescription,
    List<int>? dietaryDescription,
  }) {
    return dishBottomSheetMinHeight(
      screenHeight,
      dietaryDescription,
      dishDescription,
      hasImage,
    );
  }

  static double getMaxHeight({
    required double screenHeight,
    required bool hasImage,
    String? dishDescription,
    List<int>? dietaryDescription,
  }) {
    return dishBottomSheetMaxHeight(
      dishDescription,
      screenHeight,
      hasImage,
      dietaryDescription,
    );
  }
}
```

Use named parameters to prevent order confusion.

---

**6. Add Debug Visualization**

**Pure Flutter enhancement:**
```dart
import 'package:flutter/foundation.dart';

double dishBottomSheetMaxHeight(
  String? dishDescription,
  double screenHeight,
  bool hasImage,
  List<int>? dietaryDescription,
) {
  // ... existing calculation ...

  if (kDebugMode) {
    debugPrint('''
    Bottom Sheet Max Height Calculation:
      Screen: ${screenHeight.toStringAsFixed(1)}px
      Base: ${baseHeight.toStringAsFixed(1)}px (${(baseHeightFactor * 100).toStringAsFixed(0)}%)
      Description: ${descriptionHeight.toStringAsFixed(1)}px (${dishDescription?.length ?? 0} chars)
      Image: ${imageSpace.toStringAsFixed(1)}px
      Dietary: ${dietaryHeight.toStringAsFixed(1)}px
      Expandable: ${expandableHeight.toStringAsFixed(1)}px
      ---
      Total: ${totalHeight.toStringAsFixed(1)}px
      Cap: ${(screenHeight * maxHeightFactor).toStringAsFixed(1)}px
      Result: ${math.min(totalHeight, screenHeight * maxHeightFactor).toStringAsFixed(1)}px
    ''');
  }

  return math.min(totalHeight, screenHeight * maxHeightFactor);
}
```

---

**7. Add Responsive Breakpoints**

**For tablet optimization:**
```dart
double dishBottomSheetMaxHeight(
  String? dishDescription,
  double screenHeight,
  bool hasImage,
  List<int>? dietaryDescription,
) {
  // Use different factors for tablets
  final isTablet = screenHeight > 1000;
  final maxHeightFactor = isTablet ? 0.85 : 0.90;  // Lower cap on tablets

  // ... rest of calculation ...

  return math.min(totalHeight, screenHeight * maxHeightFactor);
}
```

---

### Widget Integration Notes

**DraggableScrollableSheet setup:**
```dart
class ItemDetailSheet extends StatelessWidget {
  final String? dishDescription;
  final bool hasImage;
  final List<int>? dietaryDescription;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate sizes
    final minHeight = DishBottomSheetSizing.getMinHeight(
      screenHeight: screenHeight,
      hasImage: hasImage,
      dishDescription: dishDescription,
      dietaryDescription: dietaryDescription,
    );

    final maxHeight = DishBottomSheetSizing.getMaxHeight(
      screenHeight: screenHeight,
      hasImage: hasImage,
      dishDescription: dishDescription,
      dietaryDescription: dietaryDescription,
    );

    // Convert to size fractions (required by DraggableScrollableSheet)
    final minSize = minHeight / screenHeight;
    final maxSize = maxHeight / screenHeight;

    return DraggableScrollableSheet(
      initialChildSize: minSize,
      minChildSize: minSize,
      maxChildSize: maxSize,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              // ... content ...
            ],
          ),
        );
      },
    );
  }
}
```

---

## Summary

**dishBottomSheetMaxHeight** calculates the fully expanded height for dish detail bottom sheets based on content. It works with `dishBottomSheetMinHeight` to create a content-aware, draggable sheet experience.

**Key characteristics:**
- 90% screen cap (vs. 65% for minHeight)
- Includes 90px expandable disclaimer section
- Uses 0.35 text height/char (vs. 0.3 for minHeight)
- Parameter order differs from minHeight ⚠️

**Migration priorities:**
1. Consolidate constants
2. Standardize parameter order with named arguments
3. Add validation and debug logging
4. Add responsive tablet handling

**Related documentation:**
- `MASTER_README_dish_bottom_sheet_min_height.md` (companion function)
- ItemDetailSheet widget implementation
- DraggableScrollableSheet Flutter documentation
