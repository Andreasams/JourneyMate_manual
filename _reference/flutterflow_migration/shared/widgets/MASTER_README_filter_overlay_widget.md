# FilterOverlayWidget

**Type:** Custom Widget
**File:** `filter_overlay_widget.dart` (1715 lines)
**Category:** Filters & Search
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐⭐⭐ (Critical - Core filter functionality)

---

## Purpose

A comprehensive 3-column filter overlay sheet that enables users to browse and select filters across multiple categories. Displays selected filters in a scrollable header row with "Clear All" functionality. Handles complex filter relationships including neighborhood/shopping area/train station coordination, parent-child filter structures, and multi-restriction dietary composites.

**Key Features:**
- Three-column hierarchical filter interface (categories → items → sub-items)
- Real-time result count updates during filter selection
- Selected filters displayed as removable chips
- Auto-coordination of location filters (neighborhood, shopping area, train station)
- Debounced search execution (300ms delay)
- Grey left column with white selection background
- Orange accent bar on selected category
- Selected items use bold font (+100 weight)

---

## Parameters

```dart
FilterOverlayWidget({
  super.key,
  this.width,
  this.height,
  required this.filterData,
  required this.selectedTitleID,
  required this.activeFilterIds,
  required this.selectedFilterIds,
  required this.onSearchCompleted,
  this.onCloseOverlay,
  required this.searchTerm,
  required this.mayLoad,
  required this.resultCount,
  required this.languageCode,
  required this.translationsCache,
})
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `width` | `double?` | No | Container width |
| `height` | `double?` | No | Container height |
| `filterData` | `dynamic` | **Yes** | Hierarchical filter data (titles → categories → items → sub-items) |
| `selectedTitleID` | `int` | **Yes** | Currently active title (1=Location, 2=Type, 3=Preferences) |
| `activeFilterIds` | `List<int>` | **Yes** | Filter IDs that have results (used for disabling) |
| `selectedFilterIds` | `List<int>?` | No | Currently selected filter IDs |
| `onSearchCompleted` | `Future Function(List<int>, int)` | **Yes** | Callback with active filters and result count |
| `onCloseOverlay` | `Future Function(List<int>?)?` | No | Callback when overlay closes |
| `searchTerm` | `String?` | No | Current search text (affects display logic) |
| `mayLoad` | `bool` | **Yes** | Whether widget should render (performance optimization) |
| `resultCount` | `int?` | No | Current result count for display |
| `languageCode` | `String` | **Yes** | Current UI language |
| `translationsCache` | `dynamic` | **Yes** | Translation cache for dynamic text |

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
import '/custom_code/actions/index.dart';
import '/custom_code/widgets/index.dart';
import '/flutter_flow/custom_functions.dart';
```

### Custom Actions Used

| Action | Purpose | Line Reference |
|--------|---------|----------------|
| `markUserEngaged()` | Tracks user engagement | 584 |
| `generateAndStoreFilterSessionId()` | Creates new filter session | 793 |
| `trackAnalyticsEvent()` | Tracks filter events | 794-797 |
| `performSearchAndUpdateState()` | Executes search with filters | 804-812 |

### Custom Functions Used

| Function | Purpose |
|----------|---------|
| `getTranslations()` | Retrieves localized text |

---

## FFAppState Usage

### Read Properties

| Property | Purpose | Read Location |
|----------|---------|---------------|
| `fontScale` | Adjusts spacing for accessibility | 173 |
| `isBoldTextEnabled` | Adjusts spacing for bold text | 174 |
| `currentSearchText` | Gets search query for execution | 805 |
| `currentFilterSessionId` | Tracks filter session | 792 |

### Write Properties

| Property | Purpose | Write Location |
|----------|---------|---------------|
| `filtersUsedForSearch` | Stores selected filter IDs | 224-226, 602, 877, 928, 945 |
| `filterOverlayOpen` | Controls overlay visibility | 946, 1640 |

### State Listening

Widget does NOT explicitly listen to FFAppState changes. Updates occur through `didUpdateWidget` lifecycle method.

---

## Lifecycle Events

### initState (lines 184-194)
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addObserver(this);
  _handleFirstLaunchCleanup();
  _setupFilterData();

  if (widget.resultCount != null) {
    _optimisticResultCount = widget.resultCount;
    _hasReceivedNewCount = true;
  }
}
```

**Actions:**
- Adds lifecycle observer to detect app termination
- Clears selected filters on first launch (static flag)
- Builds filter lookup map from hierarchical data
- Initializes state from props (search term, selected filters)
- Selects first active category
- Captures initial state for reset functionality
- Sets initial result count if provided

### didUpdateWidget (lines 197-211)
**Triggers Handled:**
- Translation cache change → Rebuild UI
- Language code change → Rebuild UI
- Filter data change → Rebuild filter map
- Search term change → Update search state
- Result count change → Update optimistic count
- Active filter IDs change → Update disabled states
- Selected title ID change → Select first category
- Selected filter IDs change → Update internal selection

### didChangeAppLifecycleState (lines 214-218)
**Actions:**
- Resets `isFirstLaunch` static flag when app terminates
- Ensures clean state on next app launch

### dispose (lines 221-232)
```dart
@override
void dispose() {
  if (!listEquals(_selectedFilterIds.toList(), FFAppState().filtersUsedForSearch)) {
    FFAppState().update(() {
      FFAppState().filtersUsedForSearch = List<int>.from(_selectedFilterIds);
    });
  }

  WidgetsBinding.instance.removeObserver(this);
  _debounceTimer?.cancel();
  super.dispose();
}
```

**Actions:**
- Syncs selected filters to FFAppState if changed
- Removes lifecycle observer
- Cancels pending debounce timer

---

## User Interactions

### onTap Category (Column 1)
**Trigger:** User taps a category name
**Line:** 612 (via `_handleFilterSelection`)

**Actions:**
1. Marks user as engaged
2. Updates `selectedCategoryId` state
3. Finds expanded item in category (if sub-items selected)
4. Updates FFAppState.filtersUsedForSearch
5. No search triggered (category selection only)

### onTap Item (Column 2)
**Trigger:** User taps an item name
**Line:** 614 (via `_handleFilterSelection`)

**Actions:**
1. Marks user as engaged
2. **If item has sub-items:**
   - Toggles expansion (shows column 3)
3. **If item is leaf-level:**
   - Toggles selection
   - Triggers debounced search (300ms)
4. **If item is category 8 parent (searchable):**
   - Selecting: Adds parent, optionally shows column 3
   - Deselecting: Removes parent + all sub-items, hides column 3
5. Updates FFAppState.filtersUsedForSearch

### onTap Sub-Item (Column 3)
**Trigger:** User taps a sub-item name
**Line:** 618 (via `_handleFilterSelection`)

**Actions:**
1. Marks user as engaged
2. Toggles sub-item selection
3. **Auto-adds category 8 parent if not selected**
4. Triggers debounced search (300ms)
5. Updates FFAppState.filtersUsedForSearch

### onTap Filter Chip (Header)
**Trigger:** User taps X on a selected filter chip
**Line:** 858 (`_handleFilterRemoval`)

**Actions:**
1. Marks user as engaged
2. Removes filter from selection
3. **If category 8 parent:** Removes all sub-items
4. Updates selection type if neighborhood/shopping/train station
5. Triggers immediate search (no debounce)
6. Updates FFAppState.filtersUsedForSearch

### onTap Combined Category 8 Chip
**Trigger:** User taps X on a combined "Café with bakery" chip
**Line:** 1395 (`_handleCombinedCat8Removal`)

**Actions:**
1. Marks user as engaged
2. Removes all sub-items in that combined button
3. Triggers immediate search
4. Updates FFAppState.filtersUsedForSearch

### onTap "View Results" Button
**Trigger:** User taps footer button showing result count
**Line:** 1638

**Actions:**
1. Sets `FFAppState().filterOverlayOpen = false`
2. Calls `onCloseOverlay` callback with selected filters
3. No search triggered (already up to date)

### onTap "Reset" Button (Ryd alle)
**Trigger:** User taps reset button in footer
**Line:** 912 (`_handleReset`)

**Actions:**
1. Clears all selected filters
2. Resets initial state variables
3. Resets selection type (neighborhood/shopping/train station)
4. Hides column 3 if category 8 parent was selected
5. Triggers immediate search
6. Updates FFAppState.filtersUsedForSearch = []

### onTap Close Button (X)
**Trigger:** User taps X button in header
**Line:** 934 (`_handleCloseButton`)

**Actions:**
1. Restores initial filter selection (undo changes)
2. Restores initial category/item selection
3. Sets `FFAppState().filterOverlayOpen = false`
4. Calls `onCloseOverlay` callback
5. Triggers search with restored filters
6. Updates FFAppState.filtersUsedForSearch

---

## Display States

### 1. Hidden State
**Condition:** `widget.mayLoad == false`

**Display:** `SizedBox.shrink()` (nothing rendered)

### 2. Loading State
**Condition:** `!_hasReceivedNewCount && widget.searchTerm?.isNotEmpty == true`

**Display:** Filter columns shown, but inactive filters grayed out until server responds

### 3. Initial State (No Search)
**Condition:** `_isInitialState == true` (no search term, no selected filters)

**Display:**
- All categories/items enabled (no graying)
- "Browse nearby" button text in footer
- No result count shown

### 4. Active Filtering State
**Condition:** Filters selected or search term present

**Display:**
- Inactive items grayed out (based on `activeFilterIds`)
- Result count in footer button
- Selected filters in header row
- Category badges show selection count (e.g., "Neighborhood (3)")

### 5. No Results State
**Condition:** `resultCount == 0` after search

**Display:**
- "No results" text in footer button
- Button not highlighted (white background)
- Filters still selectable

---

## Filter Column Layout

### Column Widths
Fixed ratios prevent layout shift when switching tabs:
- **Left (Categories):** Grey background (`#f2f3f5`)
- **Middle (Items):** White background
- **Right (Sub-items):** White background
- **Dividers:** 1px black between columns

### Selected Category Visual (Left Column)
- White background box
- Orange accent bar (2px) on left edge (3px margin, 3px spacing)
- Orange text color (`#ee8b60`)
- Bold font (+100 weight from base)

### Selected Item/Sub-item Visual (Middle/Right Columns)
- Bold font (+100 weight from base)
- Orange text color
- No background change

### Inactive Filter Visual (All Columns)
- Light grey text color (`#dcdee0`)
- Not tappable

---

## Special Filter Coordination Logic

### Neighborhood → Shopping Area/Train Station
When a neighborhood is selected:
1. **Shopping areas:** Filtered to those with `activeFilterIds` matches
2. **Train stations:** Filtered to those with `neighbourhood_id_1` or `neighbourhood_id_2` matching selected neighborhood
3. Selection type = `FilterSelectionType.neighborhood`

### Shopping Area Selection
**Mutually exclusive with train stations**
1. Removes all train station filters
2. Removes conflicting shopping area filters
3. Selection type = `FilterSelectionType.shoppingArea`
4. Grays out "Train Stations" category

### Train Station Selection
**Mutually exclusive with shopping areas**
1. Removes all shopping area filters
2. Removes conflicting train station filters
3. Selection type = `FilterSelectionType.trainStation`
4. Grays out "Shopping Areas" category

### Category 8 (Business Type) Parent-Child Logic
**Special behavior for items with sub-items:**
- **Selecting parent:** Adds parent to selection, shows column 3 if has sub-items
- **Deselecting parent:** Removes parent + all sub-items, hides column 3
- **Selecting sub-item:** Auto-adds parent if not selected
- **Deselecting last sub-item:** Does NOT remove parent (parent can stand alone)

---

## Filter Chip Display Logic

### Standard Filters
Display filter name directly (e.g., "Vesterbro")

### Category 8 Parent + Behavior 1 Sub-items
**IDs:** 585, 586, 158, 159, 588

**Display:** Combined chip showing parent + sub-items
- **Bakery** (ID 26): "Bakery with seating and with kitchen"
- **Café** (ID 31): "Café with in-house bakery" (one sub-item)
- **Café** (ID 31): "Café with in-house bakery and in bookstore" (two sub-items)
- **Food truck** (ID 55): "Food truck - other" (dash separator)

### Category 8 Parent + Behavior 2 Sub-items
**All other sub-items**

**Display:** Individual chips for each sub-item (e.g., "Baguette", "Croissants")

### Dietary Composite Filters (6-digit IDs starting with 593-597)
**Display:** Parent name + lowercased child name
- Example: "Lactose-free baguette" (parent: "Lactose-free", child: "Baguette")
- Exception: ID 592 ("All") displays normally

---

## Translation Keys

### UI Text (Supabase System)

| Key | Purpose | Default (en) |
|-----|---------|--------------|
| `search_results_singular` | Single result text | "1 result" (with {{count}} placeholder) |
| `search_results_plural` | Multiple results text | "{{count}} results" |
| `search_browse_nearby` | Initial state button | "Browse nearby" |
| `search_no_results` | Zero results text | "No results" |
| `search_reset` | Reset button text | "Clear all" (Ryd alle in Danish) |

### Filter Names (Supabase System)
- Filter names come from `filterData` (already localized)
- Dietary composite names constructed from parent + child

---

## Data Structure

### Expected filterData Format
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
              "is_neighborhood": true,
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
- `children` (array) - Nested filters
- `display_order` (int) - Sort order within level
- `is_neighborhood` (bool) - Special flag for neighborhood items

---

## Cache Management

### Filter Lookup Map
```dart
Map<int, dynamic> _filterMap = {};
```
**Purpose:** Fast O(1) lookup of any filter by ID
**Lifecycle:** Rebuilt on filterData change
**Cleared:** When widget disposes

### Display Name Cache
**None** - Names calculated dynamically for dietary composites

---

## Performance Optimizations

1. **Filter Lookup Map**
   - Flattens hierarchical data into map for O(1) access
   - Avoids repeated tree traversal

2. **Debounced Search**
   - 300ms delay prevents search spam
   - Cancels pending timer on new selection

3. **Optimistic Result Count**
   - Shows immediate feedback with `_optimisticResultCount`
   - Updates when server responds

4. **Active Filter Graying**
   - Only checks `activeFilterIds` for leaf-level items
   - Categories check if ANY child is active

5. **Accessibility Adjustments**
   - Font size reduced by 1px when `fontScale` or `isBoldTextEnabled`
   - Prevents layout overflow

6. **Static First Launch Flag**
   - Shared across all instances
   - Prevents redundant clear operations

7. **mayLoad Parameter**
   - Widget returns `SizedBox.shrink()` when hidden
   - Avoids unnecessary rebuilds

---

## Usage Example

### In FlutterFlow Page Widget

```dart
import '/custom_code/widgets/index.dart' as custom_widgets;

// In build method:
custom_widgets.FilterOverlayWidget(
  width: double.infinity,
  height: MediaQuery.sizeOf(context).height * 0.85,
  filterData: FFAppState().filtersData,
  selectedTitleID: FFAppState().activeSelectedTitleId,
  activeFilterIds: FFAppState().activeFilters,
  selectedFilterIds: FFAppState().filtersUsedForSearch,
  onSearchCompleted: (activeIds, count) async {
    FFAppState().update(() {
      FFAppState().searchResultsCount = count;
    });
  },
  onCloseOverlay: (selectedIds) async {
    // Optional: Handle overlay close
  },
  searchTerm: FFAppState().currentSearchText,
  mayLoad: FFAppState().filterOverlayOpen,
  resultCount: FFAppState().searchResultsCount,
  languageCode: FFLocalizations.of(context).languageCode,
  translationsCache: FFAppState().translationsCache,
)
```

### Required Setup
1. FFAppState must have `filtersData` populated (hierarchical structure)
2. Active filters must be tracked in `activeFilterIds`
3. Translation cache must be initialized

---

## Edge Cases Handled

1. **Null filterData** - Widget shows nothing, no crash
2. **Missing filter ID in map** - Logs warning, skips filter
3. **Conflicting location filters** - Auto-removes conflicts (shopping vs train station)
4. **Empty categories** - Category still shown but disabled
5. **Neighborhood without train stations** - Train station category shows "no matching stations"
6. **Category 8 parent deselection** - Removes all sub-items
7. **Sub-item selection without parent** - Auto-adds parent
8. **Zero results** - "No results" text, button not highlighted
9. **Search term + no filters** - Shows search results count
10. **No search term + no filters** - "Browse nearby" button
11. **Rapid filter toggling** - Debounce prevents search spam
12. **Close without changes** - Restores initial state
13. **Translation cache change** - Rebuilds all text
14. **Long filter names** - Chips wrap in horizontal scroll
15. **Dietary composite display** - Combines parent + child names
16. **First launch** - Clears stale selected filters
17. **App termination** - Resets first launch flag
18. **Column 3 parent deselection** - Hides column 3
19. **Neighborhood change** - Re-filters shopping/train station items
20. **Display order missing** - Falls back to 999

---

## Migration Notes

### Phase 3 Strategy

**FlutterFlow → Pure Flutter**

#### 1. Bottom Sheet Implementation
```dart
// Before (FlutterFlow):
// Widget embedded in page with `mayLoad` parameter

// After (Pure Flutter):
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => DraggableScrollableSheet(
    initialChildSize: 0.85,
    minChildSize: 0.5,
    maxChildSize: 0.95,
    builder: (context, scrollController) => FilterOverlayWidget(...),
  ),
);
```

#### 2. State Management
```dart
// Before:
FFAppState().filtersUsedForSearch

// After (Riverpod):
final selectedFiltersProvider = StateNotifierProvider<FiltersNotifier, List<int>>(...);
```

#### 3. Search Execution
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

#### 4. Translation System
```dart
// Before:
getTranslations(languageCode, key, translationsCache)

// After:
AppLocalizations.of(context)!.searchResultsSingular
```

---

## Related Elements

### Used By Pages
- **SearchResults** (`search_results_widget.dart`) - Main implementation

### Related Widgets
- `FilterTitlesRow` - Title tab navigation (calls this widget)
- `SelectedFiltersBtns` - Selected filter chips (displays filters from this widget)

### Related Actions
- `markUserEngaged` - User interaction tracking
- `generateAndStoreFilterSessionId` - Session tracking
- `trackAnalyticsEvent` - Event logging
- `performSearchAndUpdateState` - Search execution

### Related Functions
- `getTranslations` - Localization

---

## Testing Checklist

When implementing in Flutter:

- [ ] Load with empty filter data - verify no crash
- [ ] Select category - verify column 2 updates
- [ ] Select item with sub-items - verify column 3 shows
- [ ] Select leaf-level item - verify search triggers
- [ ] Select neighborhood - verify shopping/train filters update
- [ ] Select shopping area - verify train stations gray out
- [ ] Select train station - verify shopping areas gray out
- [ ] Deselect neighborhood - verify shopping/train reset
- [ ] Select category 8 parent - verify adds to chips
- [ ] Deselect category 8 parent - verify removes sub-items
- [ ] Select category 8 sub-item - verify auto-adds parent
- [ ] Remove filter chip - verify search executes
- [ ] Remove combined chip - verify removes all sub-items
- [ ] Tap "Clear All" - verify all filters cleared
- [ ] Tap close button - verify restores initial state
- [ ] Rapid filter toggling - verify debounce works
- [ ] Change language - verify translations update
- [ ] Enable fontScale - verify font size adjusts
- [ ] Search with no results - verify "No results" shows
- [ ] Initial state - verify "Browse nearby" shows
- [ ] Result count updates - verify footer button updates
- [ ] Long filter names - verify chips scroll horizontally

---

## Known Issues

None currently documented.

---

## Analytics Events

### filter_session_started
**Tracked on:** First filter selection in a session
**Event Data:**
```dart
{
  'filterSessionId': 'uuid-here',
  'entryPoint': 'filter_overlay',
}
```

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Flutter Implementation with Bottom Sheet
