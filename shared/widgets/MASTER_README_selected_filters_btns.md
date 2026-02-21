# SelectedFiltersBtns

**Type:** Custom Widget
**File:** `selected_filters_btns.dart` (722 lines)
**Category:** Filters & Search
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐⭐⭐ (Critical - Core filter display functionality)

---

## Purpose

A horizontal scrollable row of selected filter chips with individual removal buttons and a sticky "Clear All" button. Displays filters organized by category (Location, Type, Preferences) with intelligent display name formatting. Executes search after filter removal and notifies parent components of updated state.

**Key Features:**
- Sticky "Clear All" button with gradient fade overlay
- Horizontal scrolling filter chips
- Individual chip removal with X icon
- Smart display names (parent + child for ambiguous filters)
- Integrated search execution on filter removal
- Filter count updates by category
- Dynamic button width caching for performance
- Translation support for UI text
- Accessibility support with text scaling

---

## Parameters

```dart
SelectedFiltersBtns({
  super.key,
  this.width,
  this.height,
  required this.filters,
  this.selectedFilterIds,
  this.removeFilter,
  required this.onLocationFiltersCount,
  required this.onTypeFiltersCount,
  required this.onPreferencesFiltersCount,
  this.onClearAll,
  required this.languageCode,
  required this.translationsCache,
  required this.buttonRowMayLoad,
  this.onSearchCompleted,
})
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `width` | `double?` | No | Container width (optional) |
| `height` | `double?` | No | Container height (optional) |
| `filters` | `dynamic` | **Yes** | Hierarchical filter data structure |
| `selectedFilterIds` | `List<int>?` | No | Currently selected filter IDs |
| `removeFilter` | `Future Function(int)?` | No | Callback to remove single filter |
| `onLocationFiltersCount` | `Future Function(int)` | **Yes** | Callback with location filter count change (-1) |
| `onTypeFiltersCount` | `Future Function(int)` | **Yes** | Callback with type filter count change (-1) |
| `onPreferencesFiltersCount` | `Future Function(int)` | **Yes** | Callback with preferences filter count change (-1) |
| `onClearAll` | `Future Function()?` | No | Callback when "Clear All" tapped |
| `languageCode` | `String` | **Yes** | Current UI language code |
| `translationsCache` | `dynamic` | **Yes** | Translation cache for dynamic text |
| `buttonRowMayLoad` | `bool` | **Yes** | Whether widget should render (performance optimization) |
| `onSearchCompleted` | `Future Function(List<int>, int)?` | No | Callback with updated filters and result count |

---

## Dependencies

### pub.dev Packages
- None (uses Flutter SDK only)

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
| `markUserEngaged()` | Tracks user engagement | 396, 500 |
| `performSearchAndUpdateState()` | Executes search with current filters | 432-440, 512-520 |

### Custom Functions Used

| Function | Purpose |
|----------|---------|
| `getTranslations()` | Retrieves localized UI text |

---

## FFAppState Usage

### Read Properties

| Property | Purpose | Read Location |
|----------|---------|---------------|
| `filtersUsedForSearch` | Gets current selected filters after removal | 408, 509 |
| `currentSearchText` | Gets search query for execution | 433, 513 |

### Write Properties

None - This widget reads state but does not write to FFAppState directly.

### State Listening

Widget updates through `didUpdateWidget` lifecycle method when parent passes new filter data or translations.

---

## Lifecycle Events

### initState (lines 122-129)
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addObserver(this);

  if (_shouldInitialize()) {
    _initializeFlattenedFilters();
  }
}
```

**Actions:**
- Adds lifecycle observer for accessibility changes
- Initializes flattened filter list if conditions met
- Sets `_initialized` flag

### didChangeDependencies (lines 132-135)
**Actions:**
- Monitors text scale factor changes
- Clears button width cache when scaling changes
- Schedules re-measurement of button width

### didUpdateWidget (lines 138-156)
**Triggers Handled:**
- Translation cache change → Clear button width cache, rebuild UI
- Language code change → Clear button width cache, rebuild UI
- Filter data change → Reinitialize flattened filters
- Selected filter IDs change → Reinitialize flattened filters

### dispose (lines 159-162)
```dart
@override
void dispose() {
  WidgetsBinding.instance.removeObserver(this);
  super.dispose();
}
```

**Actions:**
- Removes lifecycle observer
- Cleans up resources

---

## User Interactions

### onTap Filter Chip (Remove)
**Trigger:** User taps X icon on a filter chip
**Line:** 392 (`_handleFilterRemoval`)

**Actions:**
1. Marks user as engaged (analytics)
2. Updates category count callback (-1)
3. Calls parent's `removeFilter` callback
4. Reads updated filters from FFAppState (single source of truth)
5. Determines if train station filter exists
6. Executes search with updated filters
7. Calls `onSearchCompleted` callback with new state
8. Silent failure if errors occur (search handles errors)

**Special Cases:**
- Train station detection checks parent_id == 7
- Passes train station ID to search if present

### onTap "Clear All" Button (Ryd alle)
**Trigger:** User taps sticky "Clear All" button
**Line:** 496 (`_handleClearAll`)

**Actions:**
1. Marks user as engaged (analytics)
2. Calls parent's `onClearAll` callback
3. Reads updated filters from FFAppState (should be empty)
4. Executes search with empty filters
5. Calls `onSearchCompleted` callback with cleared state
6. Silent failure if errors occur

**Note:** No train station handling needed (all filters cleared)

---

## Display States

### 1. Hidden State
**Condition:** `buttonRowMayLoad == false` OR `!_initialized` OR no selected filters

**Display:** `SizedBox.shrink()` (nothing rendered)

### 2. Visible State
**Condition:** `buttonRowMayLoad == true` AND `_initialized` AND has selected filters

**Display:**
- Horizontal scrollable row of filter chips
- Sticky "Clear All" button with gradient overlay
- Chips organized by category (Location → Type → Preferences)

### 3. Measurement State
**Condition:** First render with new language or text scale change

**Display:**
- Measures "Clear All" button width
- Caches width for scroll padding calculation
- Single measurement per language + text scale combination

---

## Filter Display Logic

### Standard Filters
**Display:** Filter name directly
- Example: "Vesterbro", "Bakery", "Gluten-free"

### Special Parent IDs (100, 101)
**Display:** Parent name + colon + child name
- Example: "Central Copenhagen: Inner City"
- **IDs:** 100, 101

### Needs Parent Context IDs
**Display:** Parent name + colon + child name
- Example: "Café: With in-house bakery"
- **IDs:** 158, 159, 588
- Prevents ambiguity for sub-items

### Dietary Composite Filters (6-digit IDs starting with 593-597)
**Display:** Parent name + lowercased child name
- Example: "Lactose-free baguette"
- **Parent IDs:** 593-597 (first 3 digits)
- **Exception:** ID 592 ("All") displays normally
- **Logic:** Combines parent dietary restriction with food item

### Category Organization
**Sort Order:**
1. **Location filters** (title_id = 1)
2. **Type filters** (title_id = 2)
3. **Preferences filters** (title_id = 3)
4. Within category: alphabetical by name (case-insensitive)

---

## Translation Keys

### UI Text (Supabase System)

| Key | Purpose | Default (en) | Default (da) |
|-----|---------|--------------|--------------|
| `search_clear_all` | Clear all button text | "Clear all" | "Ryd alle" |

**Note:** Filter names come from `filters` data structure (already localized)

---

## Data Structure

### Expected filters Format
```json
{
  "filters": [
    {
      "id": 1,
      "type": "title",
      "name": "Location",
      "children": [
        {
          "id": 5,
          "type": "category",
          "name": "Neighborhood",
          "parent_id": 1,
          "children": [
            {
              "id": 100,
              "type": "item",
              "name": "Vesterbro",
              "parent_id": 5,
              "children": []
            }
          ]
        }
      ]
    }
  ]
}
```

**Required Fields:**
- `id` (int) - Unique filter ID
- `type` (string) - "title", "category", "item", or "sub_item"
- `name` (string) - Display name (localized)
- `parent_id` (int) - ID of parent filter
- `parent_name` (string) - Name of parent filter (for display)
- `title_id` (int) - ID of title category (1, 2, or 3)
- `children` (array) - Nested filters

### Flattened Filter Structure
```dart
List<Map<String, dynamic>> _flattenedFilters = [
  {
    'id': 100,
    'name': 'Vesterbro',
    'parent_id': 5,
    'parent_name': 'Neighborhood',
    'type': 'item',
    'title_id': 1,
  },
  // ...
];
```

---

## Cache Management

### Button Width Cache
```dart
static Map<String, double> cachedButtonWidths = {};
```
**Purpose:** Caches "Clear All" button width by language code
**Key:** Language code (e.g., "en", "da")
**Value:** Button width + spacing (in pixels)
**Lifecycle:**
- Cleared on text scale change
- Cleared on language change
- Persists across widget rebuilds (static)

**Why Static?**
- Shared across all instances
- Prevents redundant measurements
- Improves performance with multiple instances

---

## Performance Optimizations

1. **Static Button Width Cache**
   - One measurement per language + text scale
   - Shared across all widget instances
   - Prevents layout jank on rebuild

2. **Lazy Initialization**
   - Only flattens filters if `buttonRowMayLoad == true`
   - Skips processing when hidden

3. **Efficient Filter Lookup**
   - Flattened list for O(n) category filtering
   - Organized by category before display

4. **Accessibility-Aware Spacing**
   - Detects text scale changes
   - Clears cache and remeasures
   - Prevents overflow issues

5. **Silent Failures**
   - Search errors handled by `performSearchAndUpdateState`
   - Engagement tracking failures don't block removal
   - Callback serialization errors caught and ignored

6. **Single Source of Truth**
   - Always reads from FFAppState after removal
   - Never maintains separate filter state
   - Prevents sync issues

---

## Style Constants

### Colors
```dart
static const Color _selectedColor = Color(0xFFdcdee0);      // Pressed state
static const Color _unselectedColor = Color(0xFFf2f3f5);    // Normal state
static const Color _selectedTextColor = Color(0xFF242629);  // Text color
static const Color _unselectedTextColor = Color(0xFF242629);// Text color
static final Color _borderColor = Colors.grey[500]!;        // Chip border
```

### Clear All Button Colors
```dart
backgroundColor: Color(0xFFFEEBED)    // Light red background
foregroundColor: Color(0xFFFF5963)    // Red text
borderColor: Colors.red               // Red border
```

### Dimensions
```dart
static const double _buttonHeight = 32.0;          // Chip height
static const double _buttonSpacing = 6.0;          // Space between chips
static const double _clearButtonSpacing = 8.0;     // Space after clear button
static const double _iconSize = 12.0;              // Close icon size
static const double _fontSize = 12.0;              // Text size
```

### Gradient Configuration
```dart
colors: [bgColor, bgColor, bgColor.withOpacity(0.9), bgColor.withOpacity(0.0)]
stops: [0.0, 0.7, 0.85, 1.0]
```

---

## Sticky "Clear All" Button Logic

### Positioning
```dart
Positioned(
  left: 0,
  top: 0,
  bottom: 0,
  // ...
)
```
**Strategy:** Positioned overlay on the left edge

### Gradient Fade
**Purpose:** Creates seamless transition from button to scrollable chips
**Implementation:**
- Reads scaffold background color from theme
- Creates 4-stop gradient (solid → transparent)
- Adds subtle shadow for depth

### Padding Calculation
```dart
padding: EdgeInsets.only(
  left: cachedButtonWidths[languageCode] ?? 75,
)
```
**Strategy:**
- Scrollable row padded by button width
- Falls back to 75px if not measured
- Prevents chips from hiding under button

### Measurement Process
1. Widget builds with `GlobalKey` on button
2. Post-frame callback measures button width
3. Width + spacing cached by language code
4. Widget rebuilds with correct padding

---

## Category Count Updates

### Location Filters (title_id = 1)
**Callback:** `onLocationFiltersCount(-1)`
**Trigger:** Any filter with `title_id == 1` removed

### Type Filters (title_id = 2)
**Callback:** `onTypeFiltersCount(-1)`
**Trigger:** Any filter with `title_id == 2` removed

### Preferences Filters (title_id = 3)
**Callback:** `onPreferencesFiltersCount(-1)`
**Trigger:** Any filter with `title_id == 3` removed

**Note:** Always passes `-1` (decrement by 1)

---

## Search Integration

### After Individual Filter Removal
```dart
final result = await performSearchAndUpdateState(
  FFAppState().currentSearchText ?? '',
  currentFilters,                     // From FFAppState
  hasTrainStation,                    // Detected from filters
  trainStationId,                     // Detected from filters
  true,                               // shouldTrackAnalytics
  false,                              // filterOverlayWasOpen
  widget.languageCode,
);
```

### After Clear All
```dart
final result = await performSearchAndUpdateState(
  FFAppState().currentSearchText ?? '',
  currentFilters,                     // Should be empty
  false,                              // hasTrainStation
  null,                               // trainStationId
  true,                               // shouldTrackAnalytics
  false,                              // filterOverlayWasOpen
  widget.languageCode,
);
```

### Result Callback
```dart
await widget.onSearchCompleted?.call(
  activeFilterIds,                    // List<int>
  resultCount,                        // int
);
```

**Purpose:** Notifies parent to update page state (result count, filter state)

---

## Usage Example

### In FlutterFlow Page Widget

```dart
import '/custom_code/widgets/index.dart' as custom_widgets;

// In build method:
custom_widgets.SelectedFiltersBtns(
  width: double.infinity,
  height: 40,
  filters: FFAppState().filtersData,
  selectedFilterIds: FFAppState().filtersUsedForSearch,
  removeFilter: (filterId) async {
    setState(() {
      FFAppState().filtersUsedForSearch =
        FFAppState().filtersUsedForSearch
          .where((id) => id != filterId)
          .toList();
    });
  },
  onLocationFiltersCount: (count) async {
    setState(() {
      _locationCount += count;
    });
  },
  onTypeFiltersCount: (count) async {
    setState(() {
      _typeCount += count;
    });
  },
  onPreferencesFiltersCount: (count) async {
    setState(() {
      _preferencesCount += count;
    });
  },
  onClearAll: () async {
    setState(() {
      FFAppState().filtersUsedForSearch = [];
      _locationCount = 0;
      _typeCount = 0;
      _preferencesCount = 0;
    });
  },
  languageCode: FFLocalizations.of(context).languageCode,
  translationsCache: FFAppState().translationsCache,
  buttonRowMayLoad: FFAppState().filtersUsedForSearch.isNotEmpty,
  onSearchCompleted: (activeIds, count) async {
    setState(() {
      FFAppState().searchResultsCount = count;
    });
  },
)
```

### Required Setup
1. FFAppState must have `filtersData` populated
2. FFAppState must have `filtersUsedForSearch` list
3. FFAppState must have `currentSearchText` string
4. Translation cache must be initialized

---

## Edge Cases Handled

1. **Null filters** - Widget shows nothing, no crash
2. **Empty selectedFilterIds** - Widget hidden
3. **Missing filter in flattened list** - Skips display
4. **Null parent_name** - Uses name only
5. **Missing title_id** - No category count update
6. **Search execution failure** - Silent failure (handled by search action)
7. **Engagement tracking failure** - Silent failure (doesn't block removal)
8. **Callback serialization error** - Caught and ignored
9. **Train station detection edge cases** - Checks both direct ID and parent_id
10. **Button width measurement failure** - Falls back to 75px
11. **Text scale changes** - Clears cache and remeasures
12. **Language changes** - Clears cache and remeasures
13. **Translation cache updates** - Rebuilds UI
14. **Dietary composite display** - Handles 6-digit IDs with parent context
15. **Special parent IDs** - Shows parent + child names
16. **Long filter names** - Horizontal scroll handles overflow
17. **Rapid removal clicks** - Each removal executes full search
18. **Filter data structure changes** - Reinitializes flattened list
19. **Widget disposal during async operation** - Mounted check before setState
20. **Clear all with no filters** - Executes search with empty list

---

## Migration Notes

### Phase 3 Strategy

**FlutterFlow → Pure Flutter**

#### 1. State Management Migration
```dart
// Before:
FFAppState().filtersUsedForSearch

// After (Riverpod):
final selectedFiltersProvider = StateNotifierProvider<FiltersNotifier, List<int>>(...);

// Widget update:
ref.listen(selectedFiltersProvider, (previous, next) {
  // Rebuild widget when filters change
});
```

#### 2. Search Execution
```dart
// Before:
performSearchAndUpdateState(...)

// After:
ref.read(searchProvider.notifier).executeSearch(
  searchTerm: searchTerm,
  filterIds: filterIds,
  hasTrainStation: hasTrainStation,
  trainStationId: trainStationId,
);
```

#### 3. Translation System
```dart
// Before:
getTranslations(languageCode, key, translationsCache)

// After:
AppLocalizations.of(context)!.searchClearAll
```

#### 4. Analytics Integration
```dart
// Before:
markUserEngaged()

// After:
ref.read(analyticsProvider).trackEvent('user_engaged');
```

---

## Related Elements

### Used By Pages
- **SearchResults** (`search_results_widget.dart`) - Main implementation

### Related Widgets
- `FilterOverlayWidget` - Filter selection UI (creates filters for this widget)
- `FilterTitlesRow` - Title tab navigation (works with this widget)

### Related Actions
- `markUserEngaged` - User interaction tracking
- `performSearchAndUpdateState` - Search execution with filters

### Related Functions
- `getTranslations` - Localization

---

## Testing Checklist

When implementing in Flutter:

- [ ] Load with empty filters - verify hidden state
- [ ] Load with selected filters - verify chips display
- [ ] Tap filter X icon - verify removal and search
- [ ] Tap "Clear All" - verify all filters removed
- [ ] Remove location filter - verify count callback (-1)
- [ ] Remove type filter - verify count callback (-1)
- [ ] Remove preferences filter - verify count callback (-1)
- [ ] Remove filter with train station - verify train station passed to search
- [ ] Remove last filter - verify widget hides
- [ ] Change language - verify button width recalculated
- [ ] Enable text scaling - verify button width recalculated
- [ ] Display standard filter - verify name only
- [ ] Display special parent filter - verify parent + child name
- [ ] Display dietary composite - verify parent + lowercased child
- [ ] Scroll horizontally - verify "Clear All" stays fixed
- [ ] Multiple filters - verify category sort order
- [ ] Long filter names - verify horizontal scroll works
- [ ] Search execution failure - verify silent handling
- [ ] Engagement tracking failure - verify removal still works
- [ ] Callback serialization error - verify caught and ignored
- [ ] Rapid removals - verify each executes search

---

## Known Issues

None currently documented.

---

## Analytics Events

### Indirect Tracking
This widget calls `markUserEngaged()` but does not directly track events. The following actions handle analytics:

**From performSearchAndUpdateState:**
- `search_performed` - Tracked after filter removal/clear
- `filter_applied` - Tracked with updated filter state

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Flutter Implementation with Riverpod State Management
