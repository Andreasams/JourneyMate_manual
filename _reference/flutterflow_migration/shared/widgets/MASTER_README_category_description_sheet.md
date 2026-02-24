# CategoryDescriptionSheet

**Type:** Custom Widget
**File:** `category_description_sheet.dart` (290 lines)
**Category:** Menu & Restaurant Details
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐ (Medium - Menu category information)

---

## Purpose

A bottom sheet-style widget that displays detailed information about a menu category (e.g., "Appetizers", "Main Courses", "Desserts"). Provides a clean modal-like presentation with the category name and full description, designed to look like a modal bottom sheet but implemented as a regular widget for FlutterFlow integration.

**Key Features:**
- Swipe bar visual affordance (non-functional)
- Close button with callback wiring
- Scrollable content for long descriptions
- Graceful handling of missing descriptions
- User engagement tracking
- Category name (bold, prominent)
- Full category description (body text)

---

## Parameters

```dart
CategoryDescriptionSheet({
  Key? key,
  required this.width,
  required this.height,
  required this.categoryData,
  required this.onClose,
})
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `width` | `double` | **Yes** | Container width (typically full screen) |
| `height` | `double` | **Yes** | Container height (typically full screen or sheet size) |
| `categoryData` | `dynamic` | **Yes** | Category data JSON (categoryName, categoryDescription) |
| `onClose` | `Future Function()` | **Yes** | Callback fired when close button tapped |

---

## Dependencies

### Internal Dependencies
```dart
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';
```

### Custom Actions Used

| Action | Purpose | Line Reference |
|--------|---------|----------------|
| `markUserEngaged()` | Tracks user interaction | 121 |

---

## FFAppState Usage

### Read Properties
None. Widget does not read from FFAppState.

### Write Properties
None. Widget does not modify FFAppState.

### State Isolation
This widget is completely stateless from the app's perspective. It only displays data passed via props and triggers a callback on close.

---

## API Endpoints

None. Widget displays pre-fetched data only.

---

## State Management

### Local State Variables
None. This is a `StatefulWidget` for lifecycle management, but does not maintain local state beyond Flutter's internal widget state.

---

## Lifecycle Events

### initState (lines 106-108)
```dart
@override
void initState() {
  super.initState();
}
```

**Actions:**
- Placeholder for potential future initialization

### dispose (lines 111-113)
```dart
@override
void dispose() {
  super.dispose();
}
```

**Actions:**
- Placeholder for potential cleanup

---

## User Interactions

### onTap Close Button
**Trigger:** User taps X button in top-left corner
**Line:** 214 (via `_handleClose`)

**Actions:**
1. Calls `markUserEngaged()` to track interaction
2. Executes `onClose` callback (async)
3. Parent widget is responsible for dismissing the sheet

---

## Translation Keys

None. Widget displays raw text from `categoryData`. Parent widget is responsible for passing translated content.

---

## categoryData Structure

### Expected JSON Format
```json
{
  "categoryName": "Appetizers",
  "categoryDescription": "Start your meal with our selection of delicious appetizers, ranging from fresh salads to hot finger foods."
}
```

### Field Extraction

| Field | Type | Required | Default | Purpose |
|-------|------|----------|---------|---------|
| `categoryName` | `String` | **Yes** | `'Category'` | Category display name |
| `categoryDescription` | `String` | No | `''` | Full category description |

### Missing Data Handling

**Missing categoryName:**
- Displays `'Category'` as fallback

**Missing categoryDescription:**
- Displays `'No description available.'` in grey italic text

---

## Layout & Styling

### Dimensions

| Element | Size |
|---------|------|
| Sheet border radius | 20px (top corners only) |
| Header height (no image) | 64px |
| Swipe bar width | 80px |
| Swipe bar height | 4px |
| Swipe bar top padding | 8px |
| Swipe bar bottom padding | 12px |
| Swipe bar border radius | 20px |
| Close button size | 40px × 40px |
| Close button position | 12px from top-left |
| Close button border radius | 20px |
| Close icon size | 30px |
| Content horizontal padding | 28px |
| Content top spacing | 12px |
| Name to description spacing | 8px |
| Bottom padding | 20px |

### Typography

| Element | Size | Weight | Color |
|---------|------|--------|-------|
| Category name | 22px | 600 | Black |
| Description | 16px | 300 | #2D3236 (dark grey) |
| No description fallback | 16px | 300 | Grey (italic) |

### Colors

| Element | Color |
|---------|-------|
| Sheet background | White |
| Swipe bar | #14181B (dark grey) |
| Close button background | #F2F3F5 (light grey) |
| Close icon | #14181B (dark grey) |
| Category name | Black |
| Description | #2D3236 (dark grey) |
| No description fallback | `Colors.grey` |

### Spacing

| Gap | Size |
|-----|------|
| Category name to description | 8px |
| Content bottom padding | 20px |

---

## Data Extraction Helpers

### Safe Data Access (lines 95-99)

| Method | Return Type | Purpose |
|--------|-------------|---------|
| `_getStringValue(key, [default])` | `String` | Safely extracts string from categoryData, returns default if missing or invalid |

**Implementation:**
```dart
String _getStringValue(String key, [String defaultValue = '']) {
  if (widget.categoryData is! Map) return defaultValue;
  final value = widget.categoryData[key];
  return (value is String && value.isNotEmpty) ? value : defaultValue;
}
```

**Safety Checks:**
1. Validates `categoryData` is a Map
2. Extracts value by key
3. Checks value is non-empty String
4. Returns default if any check fails

---

## UI Structure

### Build Hierarchy (lines 130-142)

```
Container (full width/height)
└── Column
    ├── _buildHeaderSection()
    │   └── SizedBox (64px height)
    │       └── Stack
    │           ├── _buildSwipeBar()
    │           └── _buildCloseButton()
    └── _buildScrollableContent()
        └── Expanded
            └── SingleChildScrollView
                └── Padding (28px horizontal)
                    └── Column
                        ├── SizedBox (12px spacing)
                        ├── _buildCategoryName()
                        ├── SizedBox (8px spacing)
                        ├── _buildCategoryDescription()
                        └── SizedBox (20px spacing)
```

---

## Sub-Components

### _buildHeaderSection (lines 158-168)

**Purpose:** Renders swipe bar and close button in fixed header

**Structure:**
- Fixed 64px height container
- Stack layout for overlapping elements
- Swipe bar centered at top
- Close button positioned at top-left

---

### _buildSwipeBar (lines 171-193)

**Purpose:** Visual affordance indicating swipe-to-dismiss capability

**Structure:**
- Positioned at top center
- 80px × 4px rounded bar
- 8px top padding, 12px bottom padding
- Dark grey color (#14181B)

**Note:** Visual only. Does not handle drag gestures.

---

### _buildCloseButton (lines 196-218)

**Purpose:** Tappable button to dismiss the sheet

**Structure:**
- 40px × 40px circular button
- Light grey background (#F2F3F5)
- Black close icon (30px)
- Positioned 12px from top-left corner

**Interaction:**
- Calls `_handleClose()` on tap
- Marks user as engaged
- Executes `onClose` callback

---

### _buildScrollableContent (lines 225-245)

**Purpose:** Scrollable content area with category details

**Structure:**
- Expanded to fill remaining height
- SingleChildScrollView with ClampingScrollPhysics
- 28px horizontal padding
- Top spacing: 12px
- Bottom padding: 20px

**Content:**
1. Category name (bold, 22px)
2. 8px spacer
3. Category description (or fallback)
4. 20px bottom padding

---

### _buildCategoryName (lines 248-260)

**Purpose:** Displays category name with fallback

**Data Extraction:**
```dart
final categoryName = _getStringValue('categoryName', 'Category').trim();
```

**Styling:**
- Font: Roboto
- Size: 22px
- Weight: 600 (semi-bold)
- Color: Black

**Fallback:** `'Category'` if missing

---

### _buildCategoryDescription (lines 263-288)

**Purpose:** Displays category description or fallback message

**Data Extraction:**
```dart
final description = _getStringValue('categoryDescription').trim();
```

**Empty State:**
- Shows `'No description available.'`
- Grey, italic, 16px
- Clearly indicates missing data

**Normal State:**
- Shows full description text
- Font: Roboto
- Size: 16px
- Weight: 300 (light)
- Color: #2D3236 (dark grey)

---

## Close Handler

### _handleClose (lines 120-123)

```dart
Future<void> _handleClose() async {
  markUserEngaged();
  await widget.onClose();
}
```

**Process:**
1. Marks user engagement for analytics
2. Awaits onClose callback
3. Parent widget handles actual dismissal (e.g., `Navigator.pop()`)

**Note:** Widget does not dismiss itself. It defers to the parent for navigation control.

---

## Performance Considerations

### Rendering Optimization
- No images to load
- No API calls
- No state updates
- No animations
- Instant rendering

### Memory Usage
- Minimal state
- No caching
- No large data structures
- Text rendering only

---

## Usage Example

```dart
// In FlutterFlow action:
await showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => CategoryDescriptionSheet(
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height * 0.9,
    categoryData: {
      'categoryName': 'Appetizers',
      'categoryDescription': 'Start your meal with our selection...'
    },
    onClose: () async {
      Navigator.pop(context);
    },
  ),
);
```

---

## Error Handling

### Invalid categoryData Type
- If `categoryData` is not a Map, all fields return defaults
- No crashes or exceptions
- Graceful degradation

### Missing categoryName
- Displays `'Category'` fallback
- Widget still renders correctly

### Missing categoryDescription
- Displays `'No description available.'` message
- Clearly indicates to user that data is missing

---

## Analytics Tracking

### Events Tracked
None directly. Widget calls `markUserEngaged()` on close button tap, but does not fire specific analytics events.

**Parent Responsibility:**
- Track sheet open event
- Track which category was viewed
- Track sheet close event

---

## Known Limitations

1. **No Translation Support:** Widget displays raw text from props (parent must translate)
2. **No Language Switching:** Unlike ItemDetailSheet, no inline language toggle
3. **No Image Support:** Only text content (no category images)
4. **No Swipe-to-Dismiss:** Swipe bar is visual only, no gesture handling
5. **Fixed Layout:** No dynamic sizing based on content length
6. **No Backdrop Dismiss:** Close button is only way to dismiss
7. **No Keyboard Handling:** No search or filter capabilities

---

## Related Widgets

| Widget | Relationship |
|--------|--------------|
| `ItemDetailSheet` | Sibling - similar bottom sheet pattern for menu items |
| `FilterDescriptionSheet` | Sibling - similar description pattern for filters |
| `FullGalleryViewerWidget` | Sibling - similar modal presentation |
| `MenuCategoriesListView` | Parent - triggers CategoryDescriptionSheet on info button tap |

---

## Migration Notes

### From FlutterFlow
This widget is production-ready and directly exported from FlutterFlow. No migration needed.

### To v2 Design
When migrating to v2 design system:
1. Update color constants to match design tokens (e.g., ACCENT, GREEN)
2. Review spacing constants against design system
3. Update font weights to match v2 hierarchy
4. Consider extracting bottom sheet pattern to shared component
5. Add translation system integration (languageCode, translationsCache params)
6. Consider adding backdrop tap to dismiss
7. Consider adding swipe gesture handling

---

## Design Decisions

### Why No Image?
Unlike ItemDetailSheet, categories typically don't have images. The simpler layout focuses attention on the description text.

### Why No Language Toggle?
Category descriptions are typically shorter and less critical than menu item details. The added complexity of inline language switching was deemed unnecessary.

### Why Visual-Only Swipe Bar?
FlutterFlow custom widgets don't easily support gesture handling. The swipe bar provides visual affordance, but actual dismissal requires the close button or parent-implemented gestures.

### Why Scrollable for Short Content?
Ensures consistent behavior regardless of content length. Long descriptions are rare but possible, so scrollability prevents overflow.

---

## Testing Checklist

- [ ] Sheet displays with correct width/height
- [ ] Swipe bar renders at top center
- [ ] Close button appears at top-left
- [ ] Close button triggers onClose callback
- [ ] markUserEngaged() called on close
- [ ] Category name displays correctly
- [ ] Category description displays correctly
- [ ] Fallback shows for missing categoryName
- [ ] Fallback shows for missing categoryDescription
- [ ] Content is scrollable for long descriptions
- [ ] Sheet has rounded top corners
- [ ] Close icon is visible and centered in button
- [ ] Typography matches design specs
- [ ] Colors match design specs
- [ ] Spacing matches design specs
- [ ] No crashes with null/invalid categoryData
- [ ] No crashes with empty categoryData
- [ ] No crashes with missing fields
- [ ] Sheet dismisses when parent handles onClose

---

**Last Updated:** 2026-02-19
**FlutterFlow Export Version:** Current production version
