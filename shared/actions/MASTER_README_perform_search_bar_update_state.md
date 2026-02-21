# performSearchBarUpdateState Action

**Type:** Custom Action (Async)
**File:** `perform_search_bar_update_state.dart` (280 lines)
**Category:** Search & Filters
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐⭐⭐ (Critical - Search bar interactions)

---

## Purpose

Performs search from search bar interactions (text change and submit) and updates app state with results. This is the **search bar-specific variant** that derives filter context from FFAppState rather than accepting filter parameters.

**Key Features:**
- Uses existing filters from FFAppState.filtersUsedForSearch
- Auto-detects train station filters for distance-based sorting
- Tracks analytics with searchTrigger to distinguish onChange vs onSubmit
- Updates FFAppState identically to filter-based searches
- Returns metadata for page state updates
- Handles filter session lifecycle and refinement tracking

**Difference from `performSearchAndUpdateState`:** This action is for search bar events, while the other is for filter overlay changes.

---

## Function Signature

```dart
Future<dynamic> performSearchBarUpdateState(
  String searchText,
  String searchTrigger,
  String languageCode,
)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `searchText` | `String` | **Yes** | Search query text from search bar |
| `searchTrigger` | `String` | **Yes** | Source of search event ('text_change' or 'submit') |
| `languageCode` | `String` | **Yes** | Language for translations (e.g., 'en', 'da') |

### Returns

| Type | Description |
|------|-------------|
| `Future<dynamic>` | JSON object with search metadata |

**Return Structure:**
```dart
{
  'activeFilterIds': List<int>,     // Filter IDs that matched results
  'resultCount': int,                // Total search results
  'timestamp': String,               // ISO 8601 timestamp
  'hasTrainStation': bool,           // Train station filter detected
  'trainStationId': int?,            // Train station ID (if applicable)
  'searchTrigger': String,           // Passed-through trigger value
  'error': String?,                  // Error message (only on failure)
}
```

---

## Dependencies

### pub.dev Packages
```yaml
http: ^1.2.1              # Search API calls
```

### Internal Dependencies
```dart
import '/custom_code/actions/index.dart';           // trackAnalyticsEvent, checkAndResetFilterSession, generateAndStoreFilterSessionId, updatePreviousFilterState
import '/flutter_flow/custom_functions.dart';       // buildFilterAppliedEventData
```

### FFAppState Usage

#### Reads
| State Variable | Type | Purpose |
|---------------|------|---------|
| `filtersUsedForSearch` | `List<int>` | Active filter IDs |
| `filterLookupMap` | `Map` | Filter metadata for train station detection |
| `CityID` | `int` | Current city context |
| `currentFilterSessionId` | `String` | Current session UUID |
| `previousActiveFilters` | `List<int>` | Previous filters for comparison |
| `previousSearchText` | `String` | Previous search text for comparison |
| `currentRefinementSequence` | `int` | Refinement counter |
| `lastRefinementTime` | `DateTime?` | Last refinement timestamp |

#### Writes
| State Variable | Type | Purpose |
|---------------|------|---------|
| `searchResults` | `Map` | Complete API response |
| `searchResultsCount` | `int` | Total result count |
| `currentSearchText` | `String` | Current search query |
| `filtersUsedForSearch` | `List<int>` | Active filters snapshot |
| `lastRefinementTime` | `DateTime` | Updated after search |

---

## BuildShip Endpoint

```
GET https://wvb8ww.buildship.run/search
```

### Query Parameters
```dart
{
  'city_id': '1',
  'search_input': 'pizza',
  'filters': '[1,2,3]',                    // JSON-encoded filter IDs
  'userLocation': 'LatLng(55.6761, 12.5683)',
  'hasTrainStationFilter': 'true',
  'trainStationFilterId': '42',            // Empty if no train station
  'language': 'da',
}
```

---

## Usage Examples

### Example 1: Search Bar Text Change (onChange)
```dart
// In search bar widget
TextField(
  onChanged: (text) async {
    // Debounce recommended (not shown here)
    final metadata = await actions.performSearchBarUpdateState(
      text,
      'text_change',
      FFAppState().languageCode,
    );

    setState(() {
      _resultCount = metadata['resultCount'];
    });
  },
)
```

### Example 2: Search Bar Submit (onSubmit)
```dart
// In search bar widget
TextField(
  onSubmitted: (text) async {
    final metadata = await actions.performSearchBarUpdateState(
      text,
      'submit',
      FFAppState().languageCode,
    );

    if (metadata['resultCount'] > 0) {
      // Navigate to results
      context.pushNamed('SearchResults');
    }
  },
)
```

### Example 3: With Error Handling
```dart
Future<void> _performSearch(String text, String trigger) async {
  try {
    final metadata = await actions.performSearchBarUpdateState(
      text,
      trigger,
      FFAppState().languageCode,
    );

    if (metadata.containsKey('error')) {
      _showError('Search failed: ${metadata['error']}');
      return;
    }

    setState(() {
      _resultCount = metadata['resultCount'];
      _hasResults = metadata['resultCount'] > 0;
    });
  } catch (e) {
    _showError('Unexpected error: $e');
  }
}
```

---

## Workflow Steps

```
1. Get user location (getCurrentUserLocation)
2. Get active filters from FFAppState.filtersUsedForSearch
3. Detect train station filter (if present)
4. Build query parameters
5. Send GET request to BuildShip
6. Extract resultCount and activeFilterIds from response
7. Update FFAppState with results
8. Check/reset filter session (checkAndResetFilterSession)
9. Build analytics event data (buildFilterAppliedEventData)
10. Add searchTrigger to event data
11. Track 'filter_applied' analytics
12. Update previous state (updatePreviousFilterState)
13. Update lastRefinementTime
14. Return metadata
```

---

## Train Station Detection

### Purpose
When user selects a train station filter, search results are sorted by distance from that station.

### Logic
```dart
_detectTrainStationFilter(List<int> filterIds) {
  const trainStationCategoryId = 7; // Parent ID for train stations

  for (int filterId in filterIds) {
    final filter = FFAppState().filterLookupMap[filterId];

    if (filter['parent_id'] == trainStationCategoryId) {
      return (true, filterId); // Tuple: (hasTrainStation, trainStationId)
    }
  }

  return (false, null);
}
```

**Example:**
- User selects "Nørreport Station" (filterId: 42, parent_id: 7)
- `hasTrainStationFilter = true`, `trainStationFilterId = 42`
- API returns results sorted by distance from Nørreport

---

## Analytics Event

### Event Type: `filter_applied`

**Event Data:**
```dart
{
  'filterSessionId': String,              // Current session UUID
  'filtersChanged': Map,                  // Added/removed filter analysis
  'searchTextChanged': bool,              // Did search text change?
  'resultCount': int,                     // Search result count
  'timeSincePreviousRefinement': int?,    // Seconds since last refinement
  'refinementSequence': int,              // Refinement number in session
  'searchTrigger': String,                // 'text_change' or 'submit'
  // ... more fields from buildFilterAppliedEventData
}
```

**searchTrigger Values:**
- `'text_change'` - User typed in search bar (onChange)
- `'submit'` - User pressed Enter or search button (onSubmit)

---

## Error Handling

### Error 1: API Failure
```
❌ Search API failed: 500
   Response: {"error": "Internal server error"}
```
**Return:** Error object with empty results
**FFAppState:** Not updated (preserves previous results)

### Error 2: Invalid Response
```
❌ Error in performSearchBarUpdateState:
   Error: FormatException: Unexpected JSON
```
**Return:** Error object
**Impact:** Page shows previous results

### Error 3: Analytics Failure
```
⚠️ Analytics tracking failed: [error]
```
**Return:** Success (search still worked)
**Impact:** Analytics event lost, but search functional

---

## Debug Output

### Successful Search
```
🔍 Starting search bar action
   Query: "pizza"
   Trigger: text_change
📍 User location: LatLng(55.6761, 12.5683)
🔖 Active filters: 3
🚉 Train station detected: ID 42
📤 Sending GET request to: [URL]
✅ Search API successful
📊 Search results:
   Total items: 15
   Active filters: 3
✅ FFAppState updated with search results
📈 Tracking search bar analytics...
✅ Analytics tracked with trigger: text_change
✅ Search bar action completed successfully
```

---

## Testing Checklist

- [ ] Search with empty text → returns empty results
- [ ] Search with text only (no filters) → works
- [ ] Search with filters only (no text) → works
- [ ] Search with text + filters → combines correctly
- [ ] Search with train station filter → hasTrainStation=true
- [ ] Verify searchTrigger passed to analytics ('text_change' vs 'submit')
- [ ] Check resultCount matches actual results
- [ ] Verify FFAppState updates correctly
- [ ] Test with API failure → returns error object
- [ ] Check filter session reset logic
- [ ] Verify refinement sequence increments

---

## Migration Notes

### Phase 3 Changes

1. **Replace FFAppState with Riverpod:**
   ```dart
   // Before:
   final filterIds = FFAppState().filtersUsedForSearch;

   // After:
   final filterIds = ref.read(filterProvider).activeFilters;
   ```

2. **Add debouncing for text_change:**
   ```dart
   Timer? _debounce;

   void _onSearchChanged(String text) {
     _debounce?.cancel();
     _debounce = Timer(Duration(milliseconds: 300), () {
       actions.performSearchBarUpdateState(text, 'text_change', languageCode);
     });
   }
   ```

3. **Keep analytics tracking** - Well-designed with searchTrigger distinction

---

## Related Actions

| Action | Purpose | Relationship |
|--------|---------|--------------|
| `performSearchAndUpdateState` | Filter overlay search | Sibling action |
| `checkAndResetFilterSession` | Session lifecycle | Called internally |
| `updatePreviousFilterState` | State tracking | Called internally |
| `trackAnalyticsEvent` | Analytics | Called internally |

---

## Used By Pages

1. **Search Results** - Primary search bar

---

## Known Issues

1. **No debouncing built-in** - Page must implement debounce logic
2. **No cancellation for in-flight requests** - Multiple rapid searches may cause race conditions
3. **Train station detection hardcodes parent_id = 7** - Not configurable

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Flutter Implementation with debouncing
