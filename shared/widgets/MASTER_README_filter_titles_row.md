# FilterTitlesRow Widget

**Type:** Custom Widget
**File:** `filter_titles_row.dart` (376 lines)
**Category:** Filter Navigation
**Status:** ✅ Production Ready

---

## Purpose

A tab-like navigation row that displays three filter category titles (Location, Type, Preferences) with dynamic selection counts. Provides visual feedback for the active category and manages filter overlay state. Acts as the header for the filter system, allowing users to switch between filter categories.

**Key Features:**
- Tab-like button navigation with three fixed columns
- Dynamic count badges showing active filters per category
- Toggle behavior (click active tab to close overlay)
- Automatic count synchronization via periodic rebuilds
- Fixed column widths (36% / 33% / 31%) per design system

---

## Parameters

```dart
FilterTitlesRow({
  super.key,
  this.width,                     // Optional container width
  this.height,                    // Optional container height
  required this.filterData,       // Hierarchical filter structure
  required this.languageCode,     // User's language (e.g., 'da', 'en')
  required this.translationsCache, // Translation cache for text
  required this.onTitleClick,     // Callback when title is clicked
})
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `width` | `double?` | No | Container width (defaults to parent width) |
| `height` | `double?` | No | Container height (defaults to content height) |
| `filterData` | `dynamic` | **Yes** | Hierarchical filter data structure (JSON) |
| `languageCode` | `String` | **Yes** | User's language code for translations |
| `translationsCache` | `dynamic` | **Yes** | Cached translation data |
| `onTitleClick` | `Future Function(int titleId)` | **Yes** | Callback invoked when a title is clicked |

---

## Dependencies

### Internal Dependencies
```dart
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';
```

### Custom Actions Used
- `markUserEngaged()` - Tracks user interaction when title clicked

### Custom Functions Used
- `getTranslations(languageCode, key, translationsCache)` - Gets localized UI text

---

## FFAppState Usage

### Read Properties
```dart
FFAppState().filtersUsedForSearch      // Selected filter IDs for count calculation
FFAppState().filterOverlayOpen         // Whether filter overlay is visible
FFAppState().activeSelectedTitleId     // Currently selected title ID (0 = none)
```

### Write Properties
```dart
FFAppState().filterOverlayOpen = true/false;           // Toggle overlay visibility
FFAppState().activeSelectedTitleId = titleId;          // Set active title
```

**State Update Pattern:**
```dart
FFAppState().update(() {
  if (titleId == FFAppState().activeSelectedTitleId) {
    FFAppState().filterOverlayOpen = !FFAppState().filterOverlayOpen;  // Toggle
  } else {
    FFAppState().activeSelectedTitleId = titleId;
    FFAppState().filterOverlayOpen = true;                             // Switch & open
  }
});
```

---

## Title IDs

The widget uses fixed constants for title identification:

```dart
static const int _locationTitleId = 1;      // Location filter category
static const int _typeTitleId = 2;          // Type filter category
static const int _preferencesTitleId = 3;   // Preferences/Needs filter category
```

**Translation Keys:**
- Title ID 1 → `'filter_location'`
- Title ID 2 → `'filter_type'`
- Title ID 3 → `'filter_preferences'`

---

## Lifecycle Events

### initState (lines 90-95)
```dart
@override
void initState() {
  super.initState();
  _buildFilterMap();
  _schedulePeriodicRebuild();
}
```

**Actions:**
1. Builds flat filter map from hierarchical `filterData`
2. Schedules periodic rebuilds (500ms intervals) to sync counts with FFAppState

### didUpdateWidget (lines 98-109)
```dart
@override
void didUpdateWidget(FilterTitlesRow oldWidget) {
  super.didUpdateWidget(oldWidget);

  if (widget.filterData != oldWidget.filterData) {
    _buildFilterMap();
  }

  if (widget.translationsCache != oldWidget.translationsCache ||
      widget.languageCode != oldWidget.languageCode) {
    setState(() {});
  }
}
```

**Actions:**
1. Rebuilds filter map if `filterData` changes
2. Triggers rebuild if translations or language change

### dispose (lines 112-115)
```dart
@override
void dispose() {
  _rebuildTimer?.cancel();
  super.dispose();
}
```

**Actions:**
- Cancels periodic rebuild timer to prevent memory leaks

---

## User Interactions

### onTap Title Button (lines 224-242)
**Trigger:** User taps any of the three title buttons

**Actions:**
1. Calls `markUserEngaged()` (non-blocking) to track interaction
2. Updates FFAppState:
   - **If clicking same title:** Toggle `filterOverlayOpen` (open ↔ close)
   - **If clicking different title:** Set new `activeSelectedTitleId` + open overlay
3. Invokes `onTitleClick(titleId)` callback for parent side effects

**Toggle Logic:**
```dart
if (titleId == FFAppState().activeSelectedTitleId) {
  FFAppState().filterOverlayOpen = !FFAppState().filterOverlayOpen;
} else {
  FFAppState().activeSelectedTitleId = titleId;
  FFAppState().filterOverlayOpen = true;
}
```

---

## Visual States

### Active State
**Condition:** `FFAppState().filterOverlayOpen == true` AND `FFAppState().activeSelectedTitleId == titleId`

**Styling:**
- Text color: `#e9874b` (orange)
- Font weight: `w500` (medium)
- Border color: `#000000` (black)

### Inactive State
**Condition:** Title is not the active selected title

**Styling:**
- Text color: `#14181b` (primary text)
- Font weight: `w400` (regular)
- Border color: `#000000` (black)

---

## Layout Structure

The widget uses a `Row` with three `Expanded` containers for equal distribution:

```
┌─────────────┬─────────────┬─────────────┐
│  Location   │    Type     │ Preferences │
│     (2)     │     (1)     │     (3)     │
└─────────────┴─────────────┴─────────────┘
```

### Border Structure
Each button has specific borders to create a unified appearance:

| Title | Borders | Purpose |
|-------|---------|---------|
| Location | Top, Bottom, Right | Right border acts as divider |
| Type | Top, Bottom, Right | Right border acts as divider |
| Preferences | Top, Bottom only | No right border (last column) |

**Border Specs:**
- Color: `#000000` (black)
- Width: 1px
- Top and bottom borders span entire row
- Vertical dividers between columns (right borders on Location/Type)

---

## Count Calculation

### Dynamic Count Display
Each title shows a count badge if active filters exist in that category:
- Format: `"Title (n)"` where n = count
- Example: `"Location (2)"`, `"Type (1)"`, `"Preferences (3)"`
- If count = 0: Shows only title without parentheses

### Count Logic (lines 175-203)
```dart
int _calculateCount(int titleId) {
  final selectedFilters = FFAppState().filtersUsedForSearch;
  int count = 0;

  for (final filterId in selectedFilters) {
    final filter = _filterMap[filterId];
    if (filter != null) {
      final filterTitleId = _findTitleIdForFilter(filter);
      if (filterTitleId == titleId) {
        count++;
      }
    }
  }

  return count;
}
```

**Process:**
1. Gets selected filter IDs from `FFAppState().filtersUsedForSearch`
2. For each selected filter, looks up filter object in `_filterMap`
3. Traverses up parent hierarchy to find which title it belongs to
4. Increments count if filter belongs to current title

---

## Filter Map Building

### Hierarchical to Flat Map (lines 122-154)
The widget converts the hierarchical `filterData` structure into a flat lookup map:

```dart
Map<int, dynamic> _filterMap = {};  // filterId → filter object
```

**Purpose:** Fast O(1) lookup of any filter by ID without traversing hierarchy

**Process:**
1. Recursively walks `filterData` tree structure
2. Extracts filters with numeric IDs
3. Stores in flat map: `_filterMap[filterId] = filterObject`
4. Continues recursion through `children` arrays

**Example Input:**
```json
{
  "filters": [
    {
      "id": 1,
      "type": "title",
      "name": "Location",
      "children": [
        {"id": 10, "type": "filter", "name": "Downtown"},
        {"id": 11, "type": "filter", "name": "Suburbs"}
      ]
    }
  ]
}
```

**Example Output:**
```dart
{
  1: {id: 1, type: "title", name: "Location", ...},
  10: {id: 10, type: "filter", name: "Downtown", parent_id: 1},
  11: {id: 11, type: "filter", name: "Suburbs", parent_id: 1}
}
```

---

## Periodic Rebuild System

### Auto-Sync with FFAppState (lines 160-168)
```dart
void _schedulePeriodicRebuild() {
  _rebuildTimer?.cancel();
  _rebuildTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
    if (mounted) {
      setState(() {});
    }
  });
}
```

**Purpose:** Keep displayed counts synchronized with `FFAppState().filtersUsedForSearch`

**Frequency:** Every 500ms (2 times per second)

**Why Needed:**
- Filter selections can change from filter overlay interactions
- FFAppState updates don't automatically trigger widget rebuilds
- Periodic rebuild ensures counts always reflect current selection state

**Performance Impact:** Minimal - only recalculates counts (lightweight integer math)

---

## Typography & Styling

### Font Specifications
```dart
static const double _fontSize = 17.0;
```

**Font Family:** `Roboto`
**Font Sizes:** 17px (all titles)
**Font Weights:**
- Active: `FontWeight.w500` (500)
- Inactive: `FontWeight.w400` (400)

### Text Overflow
```dart
maxLines: 1,
overflow: TextOverflow.clip,
softWrap: false,
textAlign: TextAlign.center,
```

**Behavior:** Text clips at container edge without ellipsis

### Optical Padding Adjustments (lines 359-374)
Each button has custom padding to compensate for visual weight of letters:

| Title | Left | Right | Reason |
|-------|------|-------|--------|
| Location | 6px | 10px | 'L' has visual weight on left |
| Type | 8px | 8px | Balanced letters |
| Preferences | 10px | 6px | 's' curves away on right |

**Vertical Padding:** 8px (all titles)

---

## Translation System

### Translation Keys Used
```dart
static const String _locationKey = 'filter_location';
static const String _typeKey = 'filter_type';
static const String _preferencesKey = 'filter_preferences';
```

### Translation Helper (lines 249-251)
```dart
String _getUIText(String key) {
  return getTranslations(widget.languageCode, key, widget.translationsCache);
}
```

### Title Text Generation (lines 254-265)
```dart
String _getTitleText(int titleId) {
  final key = switch (titleId) {
    _locationTitleId => _locationKey,
    _typeTitleId => _typeKey,
    _ => _preferencesKey,
  };

  final baseText = _getUIText(key);
  final count = _calculateCount(titleId);

  return count > 0 ? '$baseText ($count)' : baseText;
}
```

**Example Outputs:**
- No filters: `"Location"`, `"Type"`, `"Preferences"`
- With filters: `"Location (2)"`, `"Type (1)"`, `"Preferences (3)"`

---

## Color Constants

```dart
static const Color _primaryOrange = Color(0xFFe9874b);  // Active title
static const Color _primaryText = Color(0xFF14181b);    // Inactive title
static const Color _borderColor = Colors.black;          // All borders
```

**Design System Alignment:**
- Orange matches design token for interactive elements
- Black borders create clear visual separation
- Primary text provides readable contrast

---

## Usage Example

### In FlutterFlow Page Widget

```dart
import '/custom_code/widgets/index.dart' as custom_widgets;

// In build method:
custom_widgets.FilterTitlesRow(
  width: double.infinity,
  height: 48.0,
  filterData: FFAppState().filterData,
  languageCode: FFAppState().languageCode,
  translationsCache: FFAppState().translationsCache,
  onTitleClick: (titleId) async {
    // Optional: Add page-specific side effects
    // Example: Scroll filter overlay to top
    await Future.delayed(Duration.zero);
  },
)
```

### Required Setup
1. FFAppState must have `filterData` populated (hierarchical structure)
2. FFAppState must have `translationsCache` loaded
3. FFAppState must have `languageCode` set
4. Parent page must handle `onTitleClick` callback (can be no-op)

---

## Edge Cases Handled

1. **Null filterData** - Returns empty filter map, counts show as 0
2. **Missing translation keys** - Falls back to key string
3. **Invalid filter IDs in filtersUsedForSearch** - Skips missing filters
4. **Filter without parent_id** - Returns null for title ID (safe)
5. **Widget unmounted during periodic rebuild** - Checks `mounted` before setState
6. **Same title clicked twice** - Toggles overlay open/closed
7. **Different title clicked** - Switches to new category and opens overlay
8. **Count overflow** - No limit, displays actual count (e.g., "(15)")

---

## Integration with Filter System

### Filter Overlay Coordination
The FilterTitlesRow works in tandem with the FilterOverlay:

1. **User clicks title** → FilterTitlesRow updates `activeSelectedTitleId`
2. **FilterOverlay reads** `activeSelectedTitleId` → Shows matching category
3. **User selects filter** → Updates `filtersUsedForSearch`
4. **Periodic rebuild** → FilterTitlesRow recalculates counts
5. **User clicks same title** → FilterTitlesRow toggles `filterOverlayOpen`

### State Flow Diagram
```
User Tap Title
     ↓
markUserEngaged()
     ↓
Update FFAppState (activeSelectedTitleId, filterOverlayOpen)
     ↓
onTitleClick callback (parent side effects)
     ↓
FilterOverlay reads new activeSelectedTitleId
     ↓
Shows corresponding filter category
```

---

## Performance Considerations

1. **Periodic Rebuilds**
   - Lightweight: Only recalculates integer counts
   - Frequency: 2x per second (500ms)
   - Cancels on dispose to prevent leaks

2. **Filter Map Caching**
   - Hierarchical data flattened once in `initState`
   - O(1) filter lookups during count calculation
   - Only rebuilt when `filterData` prop changes

3. **Count Calculation**
   - Linear time: O(n) where n = selected filter count
   - Typically n < 10, so very fast
   - Happens on every periodic rebuild (acceptable overhead)

4. **State Updates**
   - Uses `FFAppState().update()` for atomic multi-property updates
   - Prevents intermediate states from triggering unnecessary rebuilds

---

## Migration Notes

### Translation System
⚠️ **CRITICAL:** Uses Supabase translation system via `getTranslations()`. During Phase 3 migration:

1. **Keep Supabase pattern** OR **migrate to .arb files:**
   ```json
   // app_en.arb
   {
     "filterLocation": "Location",
     "filterType": "Type",
     "filterPreferences": "Preferences"
   }
   ```

2. **Update translation calls:**
   ```dart
   // Before:
   getTranslations(languageCode, 'filter_location', translationsCache)

   // After:
   AppLocalizations.of(context)!.filterLocation
   ```

### State Management
Currently uses `FFAppState()` singleton. Consider:
- **Riverpod StateNotifierProvider** for reactive filter state
- **Watch pattern** for automatic rebuilds (eliminates periodic timer)
- **Separate FilterState class** for better encapsulation

### Periodic Rebuild Elimination
With proper reactive state management:
```dart
// Replace Timer.periodic with:
ref.watch(filterStateProvider).filtersUsedForSearch
```
Rebuilds automatically when `filtersUsedForSearch` changes.

---

## Related Elements

### Used By Pages
- **SearchResults** (`search_results_widget.dart`) - Main filter UI

### Related Widgets
- `FilterOverlayWidget` - Shows filter categories controlled by title selection
- `FilterDescriptionSheet` - Shows help for selected filter

### Related Actions
- `markUserEngaged` - Tracks user interaction timing

### Related Functions
- `getTranslations` - Localized UI text

---

## Testing Checklist

When implementing in Flutter:

- [ ] Display all three titles correctly
- [ ] Show counts when filters selected (e.g., "Location (2)")
- [ ] Hide counts when no filters selected
- [ ] Click inactive title - verify activates and opens overlay
- [ ] Click active title - verify toggles overlay open/closed
- [ ] Switch between titles - verify overlay stays open
- [ ] Verify borders display correctly (vertical dividers)
- [ ] Verify active state styling (orange text, bold)
- [ ] Verify inactive state styling (black text, regular)
- [ ] Add filter in overlay - verify count updates within 500ms
- [ ] Remove filter in overlay - verify count updates within 500ms
- [ ] Change language - verify translations update
- [ ] Test with missing filterData - verify graceful fallback
- [ ] Test with invalid filter IDs - verify skips gracefully
- [ ] Verify widget disposes timer properly (no memory leaks)

---

## Known Issues

None currently documented.

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Flutter Implementation
