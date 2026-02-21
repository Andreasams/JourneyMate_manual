# buildFilterAppliedEventData Function

**Type:** Custom Function (Pure)
**File:** `custom_functions.dart` (lines 2241-2350)
**Category:** Analytics & Filter Tracking
**Status:** ✅ Production Ready

---

## Purpose

Builds comprehensive analytics event data for filter application tracking. Analyzes the difference between current and previous filter/search states to categorize the type of change (added, removed, modified, cleared) and extracts relevant metadata from search results.

**Key Feature:** Provides detailed change detection to understand user refinement behavior and search result impact.

---

## Function Signature

```dart
dynamic buildFilterAppliedEventData(
  String filterSessionId,
  List<int> currentFilters,
  String? currentSearchText,
  dynamic searchResults,
  bool filterOverlayWasOpen,
  List<int> previousFilters,
  String? previousSearchText,
  int refinementSequence,
  DateTime? lastRefinementTime,
)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `filterSessionId` | `String` | **Yes** | Unique identifier for current filter session (UUID) |
| `currentFilters` | `List<int>` | **Yes** | List of currently active filter IDs |
| `currentSearchText` | `String?` | No | Current search query (null/empty if none) |
| `searchResults` | `dynamic` | No | Full API response containing {documents, resultCount, activeids} |
| `filterOverlayWasOpen` | `bool` | **Yes** | Whether filter overlay was visible when applied |
| `previousFilters` | `List<int>` | **Yes** | List of previously active filter IDs |
| `previousSearchText` | `String?` | No | Previous search query (null/empty if none) |
| `refinementSequence` | `int` | **Yes** | Sequential number of refinements in session (1, 2, 3...) |
| `lastRefinementTime` | `DateTime?` | No | Timestamp of previous refinement (null if first) |

### Returns

| Type | Description |
|------|-------------|
| `Map<String, dynamic>` | Event data map for analytics tracking with 15+ fields |

---

## Return Value Structure

```dart
{
  // Session tracking
  'filterSessionId': 'uuid-here',
  'refinementSequence': 2,

  // Current state
  'filters': [1, 2, 3],
  'searchText': 'pizza',
  'resultsCount': 12,
  'returnedBusinessIds': [101, 102, 103],
  'isZeroResults': false,

  // Previous state
  'previousFilters': [1, 2],
  'previousSearchText': 'pizza',

  // Change detection
  'changeType': 'added',  // 'added' | 'removed' | 'modified' | 'cleared' | 'unchanged'
  'addedFilters': [3],
  'removedFilters': [],
  'searchTextChanged': false,

  // Context
  'filterOverlayWasOpen': true,
  'timeSincePreviousRefinement': 45,  // seconds, or null if first
}
```

---

## Change Type Logic

### changeType: 'cleared'
**Condition:** Current filters empty AND previous filters not empty
```dart
currentFilters = []
previousFilters = [1, 2, 3]
// User cleared all filters
```

### changeType: 'unchanged'
**Condition:** Both current and previous filters empty
```dart
currentFilters = []
previousFilters = []
// No filters active before or after
```

### changeType: 'added'
**Condition:** Filters added, none removed
```dart
currentFilters = [1, 2, 3]
previousFilters = [1, 2]
addedFilters = [3]
removedFilters = []
// User added filter 3
```

### changeType: 'removed'
**Condition:** Filters removed, none added
```dart
currentFilters = [1]
previousFilters = [1, 2, 3]
addedFilters = []
removedFilters = [2, 3]
// User removed filters 2 and 3
```

### changeType: 'modified'
**Condition:** Filters both added AND removed
```dart
currentFilters = [1, 4, 5]
previousFilters = [1, 2, 3]
addedFilters = [4, 5]
removedFilters = [2, 3]
// User swapped out filters 2,3 for 4,5
```

---

## Dependencies

### pub.dev Packages
- None (pure Dart function)

### Internal Dependencies
- None

---

## Usage Example

### Complete Filter Application Flow

```dart
// Page model state:
String _filterSessionId = const Uuid().v4();
List<int> _previousFilters = [];
String? _previousSearchText;
int _refinementSequence = 0;
DateTime? _lastRefinementTime;

// When user applies filters:
void _onFiltersApplied() async {
  // Increment sequence
  _refinementSequence++;

  // Build event data
  final eventData = functions.buildFilterAppliedEventData(
    _filterSessionId,
    FFAppState().selectedFilters,  // Current filters
    _searchBarController.text,     // Current search
    FFAppState().searchResults,    // API response
    _model.filterOverlayOpen,      // Was overlay open?
    _previousFilters,              // Previous state
    _previousSearchText,           // Previous search
    _refinementSequence,           // 1, 2, 3...
    _lastRefinementTime,           // Last refinement timestamp
  );

  // Track analytics
  await actions.trackAnalyticsEvent('filter_applied', eventData);

  // Update previous state for next comparison
  _previousFilters = List.from(FFAppState().selectedFilters);
  _previousSearchText = _searchBarController.text;
  _lastRefinementTime = DateTime.now();
}
```

---

## Used By Pages

| Page | When Called | Purpose |
|------|-------------|---------|
| **Search Results** | Filter submit, search submit | Track search refinements |

---

## Used By Custom Actions

| Action | Purpose |
|--------|---------|
| `performSearchAndUpdateState` | Builds event data for filter tracking |
| `updatePreviousFilterState` | Updates state after filter changes |

---

## Null Safety & Edge Cases

### Edge Case 1: Null Search Results
**Input:**
```dart
searchResults = null
```

**Behavior:**
- `businessIds = []` (empty list)
- `resultsCount = 0`
- No crash - safely handles null

### Edge Case 2: Empty Search Results
**Input:**
```dart
searchResults = {
  'documents': [],
  'resultCount': 0
}
```

**Behavior:**
- `businessIds = []`
- `resultsCount = 0`
- `isZeroResults = true`

### Edge Case 3: Malformed Search Results
**Input:**
```dart
searchResults = {
  'documents': [
    {'business_id': 123},
    {'business_id': null},  // Missing ID
    {'no_id_field': 456}    // Wrong structure
  ]
}
```

**Behavior:**
- Skips null and malformed entries
- `businessIds = [123]` (only valid IDs)
- No crash

### Edge Case 4: Empty Search Text
**Input:**
```dart
currentSearchText = ""
previousSearchText = null
```

**Behavior:**
- Both normalized to `null`
- `searchTextChanged = false`
- Treats empty string same as null

### Edge Case 5: First Refinement
**Input:**
```dart
lastRefinementTime = null
```

**Behavior:**
- `timeSincePreviousRefinement = null`
- Indicates this is first refinement in session

---

## Analytics Insights

This function enables tracking:

### 1. Refinement Patterns
```
refinementSequence = 1 → Initial search
refinementSequence = 2 → First refinement
refinementSequence = 5 → User explored 5 variations
```

**Insight:** Higher sequence numbers = more engaged/indecisive users

### 2. Filter Change Behavior
```
changeType = 'added' → User narrowing results
changeType = 'removed' → User broadening results
changeType = 'modified' → User exploring alternatives
changeType = 'cleared' → User starting over
```

**Insight:** Understand how users refine searches

### 3. Zero Results Impact
```
isZeroResults = true
previousResultsCount = 8
```

**Insight:** Track when filters over-narrow results

### 4. Refinement Speed
```
timeSincePreviousRefinement = 5  → Quick adjustment
timeSincePreviousRefinement = 120 → Slow, considered change
```

**Insight:** Measure decision-making speed

### 5. Overlay Usage
```
filterOverlayWasOpen = true → Used filter UI
filterOverlayWasOpen = false → Used chip removal
```

**Insight:** Understand filter interaction patterns

---

## Performance Considerations

### Time Complexity
- **O(n + m)** where:
  - n = number of current filters
  - m = number of previous filters
- Filter comparison uses `contains()` checks

### Memory Usage
- **O(n + m + b)** where:
  - b = number of business IDs in search results
- Creates temporary lists for added/removed filters

### Optimization Opportunities

**Current:** Iterates search results to extract business IDs
```dart
for (var doc in searchResults['documents']) {
  if (doc['business_id'] != null) {
    businessIds.add(doc['business_id'] as int);
  }
}
```

**Optimization:** If API already provides `activeids` field:
```dart
final businessIds = (searchResults?['activeids'] as List?)
    ?.cast<int>() ?? [];
// Avoids iteration if API returns IDs directly
```

---

## Testing Checklist

When implementing in Flutter:

- [ ] Test adding first filter - changeType = 'added'
- [ ] Test adding additional filters - changeType = 'added'
- [ ] Test removing one filter - changeType = 'removed'
- [ ] Test removing all filters - changeType = 'cleared'
- [ ] Test swapping filters - changeType = 'modified'
- [ ] Test with null search results - no crash
- [ ] Test with empty search results - isZeroResults = true
- [ ] Test with malformed business IDs - skip invalid entries
- [ ] Test empty vs null search text - both treated as null
- [ ] Test first refinement - timeSincePreviousRefinement = null
- [ ] Test second refinement - timeSincePreviousRefinement calculated
- [ ] Test refinementSequence increments - 1, 2, 3, 4...
- [ ] Test with 100+ filters - performance acceptable
- [ ] Test with 1000+ search results - extraction efficient

---

## Migration Notes

### Phase 3 Changes

**No changes needed** - pure Dart function with no FlutterFlow dependencies.

**Update calling code** to use new state management:
```dart
// Before (FFAppState):
functions.buildFilterAppliedEventData(
  _filterSessionId,
  FFAppState().selectedFilters,
  _searchBarController.text,
  FFAppState().searchResults,
  _model.filterOverlayOpen,
  _previousFilters,
  _previousSearchText,
  _refinementSequence,
  _lastRefinementTime,
)

// After (Riverpod example):
functions.buildFilterAppliedEventData(
  ref.read(filterSessionProvider).sessionId,
  ref.watch(filtersProvider),
  ref.watch(searchTextProvider),
  ref.watch(searchResultsProvider),
  ref.watch(filterOverlayProvider).isOpen,
  ref.read(filtersProvider.notifier).previous,
  ref.read(searchTextProvider.notifier).previous,
  ref.read(filterSessionProvider).refinementCount,
  ref.read(filterSessionProvider).lastRefinementTime,
)
```

---

## Related Functions

| Function | Relationship |
|----------|-------------|
| `getSessionDurationSeconds` | Used internally for `timeSincePreviousRefinement` |
| `generateFilterSummary` | Alternative function for human-readable filter summaries |

---

## Related Actions

| Action | Relationship |
|--------|-------------|
| `trackAnalyticsEvent` | Receives this function's output as event data |
| `performSearchAndUpdateState` | Calls this function during search execution |
| `updatePreviousFilterState` | Updates state tracked by this function |

---

## Known Issues

1. **No deduplication** - If same filter added/removed multiple times, counted each time
2. **No validation** - Accepts any filter IDs without checking validity
3. **Search results type safety** - Dynamic type, no compile-time structure validation
4. **No maximum refinement limit** - Sequence can grow infinitely

**None of these are critical** - current implementation sufficient for analytics.

---

**Last Updated:** 2026-02-19
**Migration Status:** ✅ Phase 3 - No changes needed (pure Dart)
**Priority:** ⭐⭐⭐⭐ High (critical for filter analytics)
