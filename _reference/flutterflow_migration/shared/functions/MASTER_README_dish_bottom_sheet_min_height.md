# dishBottomSheetMinHeight

**Status:** ✅ Documented
**Last Updated:** 2026-02-19
**Source:** `_flutterflow_export/lib/flutter_flow/custom_functions.dart` (lines 1813-1865)

---

## Purpose

Calculates the minimum (collapsed) height for the dish detail bottom sheet based on content requirements. This function determines the initial height when the sheet first appears, ensuring key information (title, rating, dietary info, description preview, and image if present) is visible without requiring the user to scroll or expand the sheet.

The minimum height is dynamically calculated based on what content is available, but is capped at **65% of screen height** to prevent the collapsed state from taking up too much vertical space.

**Key behavior:**
- Starts with a base height (60% of screen height) for essential UI elements
- Adds height for optional content: image, description text, dietary section
- Caps total height at 65% of screen height maximum
- Used in conjunction with `dishBottomSheetMaxHeight` to define the draggable sheet range

---

## Function Signature

```dart
double dishBottomSheetMinHeight(
  double screenHeight,
  List<int>? dietaryDescription,
  String? dishDescription,
  bool hasImage,
)
```

---

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `screenHeight` | `double` | ✅ Yes | Total screen height in pixels (obtained from `MediaQuery.of(context).size.height`) |
| `dietaryDescription` | `List<int>?` | ❌ No | Optional list of dietary preference IDs (1-7). Used to determine dietary section height. Can be null or empty. |
| `dishDescription` | `String?` | ❌ No | Optional dish description text. Length determines estimated text height. Can be null or empty. |
| `hasImage` | `bool` | ✅ Yes | Whether the dish has an image to display. Controls whether 200px image space is included. |

---

## Return Value

**Type:** `double`

**Returns:** Minimum height in pixels for the bottom sheet's collapsed state.

**Range:** Between `baseHeight` (60% of screen) and `maxHeightFactor` (65% of screen)

**Calculation formula:**
```dart
totalHeight = baseHeight + imageSpace + descriptionHeight + dietaryHeight
return min(totalHeight, screenHeight * 0.65)
```

---

## Dependencies

### Imports
```dart
import 'dart:math' as math;
```

### Related Functions
- **`dishBottomSheetMaxHeight`** - Companion function that calculates maximum (expanded) height
- Used together to define `minChildSize` and `maxChildSize` for `DraggableScrollableSheet`

### Constants Used
```dart
const baseHeightFactor = 0.60;      // 60% of screen height for base UI
const maxHeightFactor = 0.65;       // 65% of screen height cap
const imageHeight = 200.0;          // Fixed image display height
const textHeightPerChar = 0.3;      // Estimated height per character
const dietaryWithItemsHeight = 25.0; // Height when dietary items present
const dietaryEmptyHeight = 50.0;    // Height when no dietary items
```

---

## FFAppState Usage

**State Variables:** None

This function is **stateless** and performs pure calculation based on input parameters only. It does not read from or write to FFAppState.

---

## Usage Examples

### Example 1: Dish with all content (image + description + dietary)
```dart
final screenHeight = MediaQuery.of(context).size.height; // 844px (iPhone 14)
final dietaryIds = [1, 6]; // Gluten-free, Vegan
final description = "This is a delicious organic bowl with fresh vegetables and quinoa.";
final hasImage = true;

final minHeight = dishBottomSheetMinHeight(
  screenHeight,      // 844px
  dietaryIds,        // 2 dietary items
  description,       // 67 characters
  hasImage,          // true
);

// Calculation:
// baseHeight = 844 * 0.60 = 506.4px
// imageSpace = 200px
// descriptionHeight = 67 * 0.3 = 20.1px
// dietaryHeight = 25px (has items)
// totalHeight = 506.4 + 200 + 20.1 + 25 = 751.5px
// cap = 844 * 0.65 = 548.6px
// return min(751.5, 548.6) = 548.6px ✅
```

### Example 2: Minimal content (no image, no description, no dietary)
```dart
final minHeight = dishBottomSheetMinHeight(
  844.0,    // screenHeight
  null,     // no dietary
  null,     // no description
  false,    // no image
);

// Calculation:
// baseHeight = 844 * 0.60 = 506.4px
// imageSpace = 0px
// descriptionHeight = 0px
// dietaryHeight = 50px (empty section)
// totalHeight = 506.4 + 0 + 0 + 50 = 556.4px
// cap = 548.6px
// return min(556.4, 548.6) = 548.6px ✅
```

### Example 3: Small screen (iPhone SE - 667px height)
```dart
final minHeight = dishBottomSheetMinHeight(
  667.0,    // screenHeight
  [2, 7],   // dietary items
  "Short description",
  true,     // has image
);

// Calculation:
// baseHeight = 667 * 0.60 = 400.2px
// imageSpace = 200px
// descriptionHeight = 17 * 0.3 = 5.1px
// dietaryHeight = 25px
// totalHeight = 400.2 + 200 + 5.1 + 25 = 630.3px
// cap = 667 * 0.65 = 433.55px
// return min(630.3, 433.55) = 433.55px ✅
```

### Example 4: Usage in ItemDetailSheet widget
```dart
// From ItemDetailSheet (business_profile_widget.dart)
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => DraggableScrollableSheet(
    initialChildSize: dishBottomSheetMinHeight(
      MediaQuery.of(context).size.height,
      widget.item.dietaryDescription,
      widget.item.dishDescription,
      widget.item.hasImage,
    ) / MediaQuery.of(context).size.height, // Convert to ratio
    minChildSize: 0.5,  // Fallback minimum (50%)
    maxChildSize: dishBottomSheetMaxHeight(
      widget.item.dishDescription,
      MediaQuery.of(context).size.height,
      widget.item.hasImage,
      widget.item.dietaryDescription,
    ) / MediaQuery.of(context).size.height, // Convert to ratio
    builder: (context, scrollController) => SingleChildScrollView(
      controller: scrollController,
      child: ItemDetailContent(...),
    ),
  ),
);
```

---

## Edge Cases

### 1. Null/Empty Optional Parameters
**Scenario:** All optional parameters are null or empty
```dart
dishBottomSheetMinHeight(844.0, null, null, false);
```
**Behavior:** Uses `dietaryEmptyHeight` (50px) for dietary section, 0px for description/image
**Result:** Returns base height + empty dietary section, capped at 65%

---

### 2. Very Long Description
**Scenario:** Description text is extremely long (e.g., 500 characters)
```dart
dishBottomSheetMinHeight(844.0, null, veryLongDescription, false);
```
**Behavior:** Description height = 500 * 0.3 = 150px, but total is capped
**Result:** Returns maximum 65% of screen height (548.6px on 844px screen)

---

### 3. Small Screen (iPhone SE)
**Scenario:** Screen height is only 667px
```dart
dishBottomSheetMinHeight(667.0, [1, 2], description, true);
```
**Behavior:** Base height scales down (60% of 667 = 400px)
**Result:** Cap = 433.55px (65% of 667px)

---

### 4. Large Screen (iPad Pro)
**Scenario:** Screen height is 1366px (iPad Pro 12.9")
```dart
dishBottomSheetMinHeight(1366.0, [1], "Short", true);
```
**Behavior:** Base height = 819.6px, cap = 887.9px
**Result:** Likely hits cap at 887.9px unless content requires less

---

### 5. Empty Dietary List vs Null
**Scenario:** `dietaryDescription = []` vs `dietaryDescription = null`
```dart
dishBottomSheetMinHeight(844.0, [], null, false);
dishBottomSheetMinHeight(844.0, null, null, false);
```
**Behavior:** Both are treated identically (`isEmpty` check handles both)
**Result:** Both use `dietaryEmptyHeight` (50px)

---

### 6. Image Flag Mismatch
**Scenario:** `hasImage = true` but item has no actual image URL
```dart
dishBottomSheetMinHeight(844.0, null, null, true);
```
**Behavior:** Function assumes 200px space is needed
**Result:** May create unnecessary whitespace if image fails to load
**Mitigation:** Widget should validate image exists before setting `hasImage = true`

---

### 7. Description Character Estimation Accuracy
**Scenario:** Text wrapping causes actual height to differ from estimate
```dart
dishDescription = "A\nB\nC\nD\nE"; // 9 chars but 5 lines
```
**Behavior:** Formula uses `length * 0.3` regardless of line breaks
**Result:** May underestimate height for text with many newlines
**Impact:** Bottom sheet may initially show truncated text, user must scroll

---

## Testing Checklist

### Unit Tests
- [ ] Returns correct height for all content present (image + description + dietary items)
- [ ] Returns correct height for minimal content (no image, no description, empty dietary)
- [ ] Caps height at 65% of screen when content would exceed maximum
- [ ] Handles null dietary description (uses empty height)
- [ ] Handles empty dietary list (uses empty height)
- [ ] Handles null/empty dish description (0px height)
- [ ] Handles missing image (hasImage = false, 0px height)
- [ ] Scales correctly for small screens (iPhone SE - 667px)
- [ ] Scales correctly for large screens (iPad Pro - 1366px)
- [ ] Uses correct constant values (verify against FlutterFlow source)

### Integration Tests
- [ ] Bottom sheet opens at calculated minimum height
- [ ] Sheet can be dragged to expand beyond minimum height
- [ ] Content is visible without scrolling at minimum height (for typical content)
- [ ] Long descriptions don't break layout (cap prevents overflow)
- [ ] Dietary section displays correctly at calculated height
- [ ] Image space is allocated correctly when hasImage = true
- [ ] Works correctly with DraggableScrollableSheet initialChildSize
- [ ] Minimum height ratio (minHeight / screenHeight) is valid (0.0-1.0)

### Edge Case Tests
- [ ] Screen rotation (portrait → landscape): Recalculates correctly
- [ ] Accessibility font scaling: Text height estimation remains reasonable
- [ ] Very short screen (e.g., split-screen mode on tablet)
- [ ] Description with special characters (emojis, Unicode) counts correctly
- [ ] Dietary list with maximum items (all 7 types)
- [ ] Zero-height screen (defensive programming): Returns sensible fallback

### Visual Regression Tests
- [ ] Screenshot comparison: Dish with all content
- [ ] Screenshot comparison: Dish with no optional content
- [ ] Screenshot comparison: Small screen (iPhone SE)
- [ ] Screenshot comparison: Large screen (iPad)
- [ ] Screenshot comparison: Long description hitting cap

---

## Migration Notes

### From FlutterFlow to Pure Dart/Flutter

**1. Context for MediaQuery**
```dart
// FlutterFlow (component parameter):
double screenHeight

// Pure Flutter (access in build method):
final screenHeight = MediaQuery.of(context).size.height;
```

**2. DraggableScrollableSheet Integration**
```dart
// Convert pixel height to ratio for DraggableScrollableSheet
DraggableScrollableSheet(
  initialChildSize: dishBottomSheetMinHeight(
    MediaQuery.of(context).size.height,
    item.dietaryDescription,
    item.dishDescription,
    item.hasImage,
  ) / MediaQuery.of(context).size.height, // Must be ratio 0.0-1.0

  minChildSize: 0.5,  // Absolute minimum (50%) as safety fallback

  maxChildSize: dishBottomSheetMaxHeight(...) / screenHeight,

  builder: (context, scrollController) => SingleChildScrollView(
    controller: scrollController,
    child: ItemDetailContent(...),
  ),
);
```

**3. Optional Parameters from Item Model**
```dart
// FlutterFlow item structure:
itemData.dietaryDescription  // List<int>?
itemData.dishDescription     // String?
itemData.hasImage            // bool

// Pure Flutter item model:
class MenuItem {
  final String id;
  final String name;
  final List<int>? dietaryDescription;
  final String? dishDescription;
  final String? imageUrl;

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
}
```

**4. Constant Values (Verify Against Design)**
```dart
// These constants were tuned in FlutterFlow - preserve exactly:
const baseHeightFactor = 0.60;      // DO NOT CHANGE
const maxHeightFactor = 0.65;       // DO NOT CHANGE
const imageHeight = 200.0;          // Matches image widget height
const textHeightPerChar = 0.3;      // Empirically determined
const dietaryWithItemsHeight = 25.0; // Matches dietary chip row
const dietaryEmptyHeight = 50.0;    // Matches empty state message
```

**5. Relationship to dishBottomSheetMaxHeight**
```dart
// Always use both functions together:
final screenHeight = MediaQuery.of(context).size.height;

final minHeight = dishBottomSheetMinHeight(
  screenHeight,
  item.dietaryDescription,
  item.dishDescription,
  item.hasImage,
);

final maxHeight = dishBottomSheetMaxHeight(
  item.dishDescription,
  screenHeight,
  item.hasImage,
  item.dietaryDescription,
);

// Validate relationship (minHeight should be ≤ maxHeight):
assert(minHeight <= maxHeight,
  'MinHeight ($minHeight) exceeds MaxHeight ($maxHeight)');
```

**6. Testing Strategy**
```dart
// Unit test with mock data:
test('dishBottomSheetMinHeight calculation', () {
  const screenHeight = 844.0;
  final dietaryIds = [1, 6];
  const description = "Test description";
  const hasImage = true;

  final result = dishBottomSheetMinHeight(
    screenHeight,
    dietaryIds,
    description,
    hasImage,
  );

  expect(result, lessThanOrEqualTo(screenHeight * 0.65));
  expect(result, greaterThan(screenHeight * 0.5));
});
```

**7. Performance Considerations**
- Function is **pure** (no side effects) → safe to call in build method
- Calculations are **synchronous** → no async/await needed
- Consider **memoization** if called frequently in same build:
  ```dart
  late final double _minHeight;

  @override
  void initState() {
    super.initState();
    _minHeight = dishBottomSheetMinHeight(...);
  }
  ```

**8. Common Migration Pitfalls**

| Issue | Symptom | Solution |
|-------|---------|----------|
| Forgot to divide by screenHeight | Bottom sheet appears at wrong size | Convert pixel value to ratio (0.0-1.0) |
| Using wrong parameter order | Incorrect height calculation | Match exact parameter order from FlutterFlow |
| Changed constant values | Sheet feels too tall/short | Use exact constants from FlutterFlow source |
| Not capping at 65% | Sheet takes entire screen | Verify `math.min()` is applied |
| Using old dietaryDescription format | Wrong dietary height | Ensure List&lt;int&gt;? type matches |

---

## Analytics Tracking

This function does not directly trigger analytics events, but the bottom sheet it configures does:

**Related Events:**
- `menu_item_viewed` (tracked when bottom sheet opens)
- `menu_item_dismissed` (tracked when bottom sheet closes)

---

## Known Issues

**Issue #1: Text Height Estimation**
- **Problem:** `textHeightPerChar = 0.3` is an approximation and may not be accurate for all fonts/sizes
- **Impact:** Bottom sheet may initially show truncated description if estimate is too low
- **Workaround:** User can drag sheet to expand; does not break functionality
- **Future Fix:** Consider using TextPainter to calculate actual text height

**Issue #2: Dietary Section Height Assumptions**
- **Problem:** `dietaryWithItemsHeight = 25px` assumes single row of chips
- **Impact:** If many dietary items wrap to multiple rows, section may be truncated
- **Workaround:** User can expand sheet to see all items
- **Future Fix:** Calculate actual chip row height based on item count and screen width

**Issue #3: Image Loading State**
- **Problem:** Function assumes image space even if image fails to load
- **Impact:** May create 200px whitespace if image URL is invalid
- **Workaround:** Widget should validate image exists before setting hasImage=true
- **Future Fix:** Consider dynamic height adjustment after image load/error

---

## Design System Compliance

✅ **Compliant** with JourneyMate design system:

- Uses **60% base height** → consistent with design spec for bottom sheets
- Caps at **65% minimum height** → prevents over-collapse, ensures usability
- Works with **90% maximum height** (from dishBottomSheetMaxHeight) → consistent expansion range
- Accounts for **200px image height** → matches image widget specifications
- Includes **dietary section spacing** → follows design token spacing values

---

## Related Documentation

- **`MASTER_README_dish_bottom_sheet_max_height.md`** - Companion function for maximum height
- **`MASTER_README_item_detail_sheet.md`** - Widget that uses this function
- **`business_profile_page_audit.md`** - Page audit documenting bottom sheet behavior
- **`journeymate-design-system.md`** - Design system specifications for bottom sheets

---

## Change Log

| Date | Change | Author |
|------|--------|--------|
| 2026-02-19 | Initial documentation created from FlutterFlow source | Claude |

---

## Footer

**Function Location:** `lib/flutter_flow/custom_functions.dart:1813-1865`
**Used By:** ItemDetailSheet widget (business_profile_page)
**Companion Function:** dishBottomSheetMaxHeight
**Migration Priority:** 🔴 HIGH (Critical for bottom sheet functionality)
