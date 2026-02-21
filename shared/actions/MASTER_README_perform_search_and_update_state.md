# performSearchAndUpdateState Action

**Type:** Custom Action (Async)
**File:** `perform_search_and_update_state.dart` (223 lines)
**Category:** Search & Filters
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐⭐⭐ (CRITICAL - Primary search workflow)

---

## Purpose

Coordinates the complete search workflow from user location retrieval through API call to state updates and analytics tracking. This is the PRIMARY search action triggered by filter changes.

**Key Features:**
- Retrieves user's current location automatically
- Calls BuildShip search API with all parameters
- Updates FFAppState with complete search results
- Tracks detailed analytics with refinement sequences
- Manages filter session lifecycle
- Returns metadata for page state updates

---

## Function Signature

```dart
Future<dynamic> performSearchAndUpdateState(
  String searchText,
  List<int> filterIds,
  bool hasTrainStation,
  int? trainStationId,
  bool shouldTrackAnalytics,
  bool filterOverlayWasOpen,
  String languageCode,
)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `searchText` | `String` | **Yes** | Search query text (can be empty) |
| `filterIds` | `List<int>` | **Yes** | Selected filter IDs (can be empty list) |
| `hasTrainStation` | `bool` | **Yes** | Whether train station filter is active |
| `trainStationId` | `int?` | No | ID of selected train station (null if none) |
| `shouldTrackAnalytics` | `bool` | **Yes** | Whether to log this search in analytics |
| `filterOverlayWasOpen` | `bool` | **Yes** | Whether filter overlay was open (for analytics) |
| `languageCode` | `String` | **Yes** | ISO 639-1 language code for results |

### Returns

| Type | Description |
|------|-------------|
| `Future<dynamic>` | JSON object with search metadata (see below) |

**Return Structure:**
```dart
{
  'activeFilterIds': [1, 2, 3],      // Filters that matched results
  'resultCount': 42,                  // Total results found
  'timestamp': '2026-02-19T14:30:00.000Z',
  'hasTrainStation': true,
  'trainStationId': 5,
  'error': 'error message'            // Only present on error
}
```

---

## Dependencies

### pub.dev Packages
```yaml
http: ^1.2.1              # BuildShip API calls
```

### Internal Dependencies
```dart
import '/custom_code/actions/index.dart';
// Uses: checkAndResetFilterSession, updatePreviousFilterState, trackAnalyticsEvent
import '/flutter_flow/custom_functions.dart';
// Uses: getCurrentUserLocation, buildFilterAppliedEventData
```

---

## BuildShip Endpoint

```
GET https://wvb8ww.buildship.run/search
```

### Query Parameters
```dart
{
  'city_id': '1',                            // From FFAppState().CityID
  'search_input': 'pasta',                   // Search text
  'filters': '[1,2,3]',                      // JSON-encoded filter IDs
  'userLocation': 'LatLng(55.6761, 12.5683)', // User coordinates
  'hasTrainStationFilter': 'true',           // Train station flag
  'trainStationFilterId': '5',               // Station ID (empty if none)
  'language': 'da',                          // Language code
}
```

### Response Structure
```json
{
  "documents": [...],                // Array of business results
  "resultCount": 42,                 // Total matches
  "activeids": [1, 2, 3],           // Filters that matched
  // ... additional metadata
}
```

---

## FFAppState Usage

### Read Properties
```dart
FFAppState().CityID                          // City to search in
FFAppState().currentFilterSessionId          // Active filter session
FFAppState().previousActiveFilters           // For refinement detection
FFAppState().previousSearchText              // For change tracking
FFAppState().currentRefinementSequence       // Refinement counter
FFAppState().lastRefinementTime              // Last refinement timestamp
```

### Write Properties
```dart
FFAppState().searchResults                   // Complete API response
FFAppState().searchResultsCount              // Result count (convenience)
FFAppState().currentSearchText               // Current query
FFAppState().filtersUsedForSearch            // Filters for this search
FFAppState().lastRefinementTime              // Updated after analytics
```

---

## Usage Examples

### Example 1: Filter Applied from Sheet
```dart
// In filter sheet apply button
final result = await actions.performSearchAndUpdateState(
  _model.searchTextController.text,
  _model.selectedFilterIds,
  _model.hasTrainStationFilter,
  _model.trainStationId,
  true,  // Track analytics
  true,  // Filter overlay was open
  FFAppState().selectedLanguage,
);

// Check result
if (result['resultCount'] > 0) {
  Navigator.pop(context);
} else {
  // Show "no results" message
}
```

### Example 2: Silent Search (No Analytics)
```dart
// In background refresh
final result = await actions.performSearchAndUpdateState(
  FFAppState().currentSearchText,
  FFAppState().filtersUsedForSearch,
  false,
  null,
  false,  // Don't track analytics
  false,
  FFAppState().selectedLanguage,
);
```

### Example 3: With Error Handling
```dart
try {
  final result = await actions.performSearchAndUpdateState(
    searchText,
    filterIds,
    hasTrainStation,
    trainStationId,
    true,
    false,
    'da',
  );

  if (result.containsKey('error')) {
    // Handle error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Search failed: ${result['error']}')),
    );
  } else {
    // Success - state already updated
    debugPrint('Found ${result['resultCount']} results');
  }
} catch (e) {
  // Handle exception
}
```

---

## Workflow Steps

### 1. Get User Location
```dart
final userLocation = await getCurrentUserLocation(
  defaultLocation: LatLng(0.0, 0.0),
);
```

### 2. Build Query & Call API
```dart
final queryParams = {
  'city_id': FFAppState().CityID.toString(),
  'search_input': searchText,
  // ... other params
};

final response = await http.get(uri);
```

### 3. Parse Response
```dart
final responseBody = json.decode(response.body);
int resultCount = responseBody['resultCount'] ?? 0;
List<int> activeFilterIds = ...;
```

### 4. Update FFAppState
```dart
FFAppState().update(() {
  FFAppState().searchResults = responseBody;
  FFAppState().searchResultsCount = resultCount;
  FFAppState().currentSearchText = searchText;
  FFAppState().filtersUsedForSearch = filterIds;
});
```

### 5. Track Analytics (if enabled)
```dart
if (shouldTrackAnalytics) {
  await checkAndResetFilterSession(searchText, filterIds);
  final analyticsData = buildFilterAppliedEventData(...);
  await trackAnalyticsEvent('filter_applied', analyticsData);
  await updatePreviousFilterState(filterIds, searchText);
  FFAppState().lastRefinementTime = DateTime.now();
}
```

### 6. Return Metadata
```dart
return {
  'activeFilterIds': activeFilterIds,
  'resultCount': resultCount,
  'timestamp': DateTime.now().toIso8601String(),
  'hasTrainStation': hasTrainStation,
  'trainStationId': trainStationId,
};
```

---

## Error Handling

### Error 1: Location Retrieval Failure
**Fallback:** Uses `LatLng(0.0, 0.0)` as default
**Impact:** Search continues with default location

### Error 2: API Response Non-200
```
❌ Search API failed: 500
   Response: {"error": "Internal server error"}
```
**Return:** Error metadata with `resultCount: 0`

### Error 3: Analytics Tracking Failure
```
⚠️ Analytics tracking failed: [error]
```
**Impact:** Search succeeds, analytics not recorded

### Error 4: Exception in Workflow
```
❌ Error in performSearchAndUpdateState:
   Error: [error]
   Stack trace: [stackTrace]
```
**Return:** Empty result with error field

---

## Analytics Integration

### Filter Session Management

**Checks for session reset:**
```dart
await checkAndResetFilterSession(searchText, filterIds);
// Resets session if both searchText and filterIds are now empty
// Increments refinement sequence if active
```

### Event Data Building
```dart
final analyticsData = buildFilterAppliedEventData(
  currentFilterSessionId,
  filterIds,
  searchText,
  searchResults,
  filterOverlayWasOpen,
  previousActiveFilters,
  previousSearchText,
  currentRefinementSequence,
  lastRefinementTime,
);
```

**Tracked Event:** `'filter_applied'`

**Contains:**
- Filter session ID
- Refinement sequence number
- Time since previous refinement
- Result count
- Active filters
- Search query
- Filter overlay state

---

## Common Use Cases

| Use Case | shouldTrackAnalytics | filterOverlayWasOpen | Notes |
|----------|---------------------|----------------------|-------|
| User applies filters | `true` | `true` | Primary use case |
| User types in search bar | `false` | `false` | Use `performSearchBarUpdateState` instead |
| Background refresh | `false` | `false` | Don't track routine refreshes |
| Initial page load | `true` | `false` | Track first search |
| Filters reset | `true` | `true` | Track reset action |

---

## Used By Pages

1. **Search Results Page** - Filter sheet apply button
2. **Filter Sheet** - Apply/confirm actions
3. **Needs Picker** - After needs selection
4. **City Selection** - After city change

---

## Performance Considerations

### Blocking Operation
- **Duration:** 200-500ms (network dependent)
- **Blocks UI:** Yes, if awaited before navigation
- **Recommendation:** Show loading indicator

```dart
// Show loading
setState(() => _isLoading = true);

try {
  final result = await actions.performSearchAndUpdateState(...);
} finally {
  setState(() => _isLoading = false);
}
```

### Network Dependency
- **Requires:** Active internet connection
- **Timeout:** None configured (uses http default)
- **Retry:** No automatic retry

---

## Debug Output

### Full Workflow
```
🔍 Starting search action
   Query: "pasta"
   Filters: 3 active
   Track analytics: true
📍 User location: LatLng(55.6761, 12.5683)
📤 Sending GET request to: https://wvb8ww.buildship.run/search?...
✅ Search API successful
📊 Search results:
   Total items: 42
   Active filters: 3
✅ FFAppState updated with search results
📈 Tracking search analytics...
✅ Analytics tracked successfully with timestamp
✅ Search action completed successfully
```

---

## Testing Checklist

- [ ] Search with empty text and no filters
- [ ] Search with text only
- [ ] Search with filters only
- [ ] Search with both text and filters
- [ ] Train station filter properly detected
- [ ] FFAppState.searchResults updated
- [ ] FFAppState.searchResultsCount matches API
- [ ] Analytics tracked when enabled
- [ ] Analytics skipped when disabled
- [ ] Location permission not required (uses default)
- [ ] API failure returns error metadata
- [ ] Result metadata structure correct
- [ ] Filter session management works
- [ ] Refinement sequence increments
- [ ] Previous state tracking works

---

## Migration Notes

### Phase 3 Changes

1. **Replace FFAppState with Riverpod:**
   ```dart
   // Before:
   FFAppState().update(() {
     FFAppState().searchResults = responseBody;
   });

   // After:
   ref.read(searchProvider.notifier).updateResults(responseBody);
   ```

2. **Add timeout to HTTP:**
   ```dart
   final response = await http.get(uri).timeout(
     Duration(seconds: 10),
     onTimeout: () => throw TimeoutException('Search timed out'),
   );
   ```

3. **Add retry logic:**
   ```dart
   for (int attempt = 0; attempt < 3; attempt++) {
     try {
       final response = await http.get(uri);
       if (response.statusCode == 200) break;
     } catch (e) {
       if (attempt == 2) rethrow;
       await Future.delayed(Duration(seconds: 1));
     }
   }
   ```

---

## Related Actions

| Action | Purpose | Relationship |
|--------|---------|--------------|
| `performSearchBarUpdateState` | Search from text input | Alternative entry point |
| `checkAndResetFilterSession` | Manage filter sessions | Called internally |
| `updatePreviousFilterState` | Track state changes | Called internally |
| `trackAnalyticsEvent` | Log analytics | Called internally |

---

## Known Issues

1. **No request timeout** - Can hang indefinitely on slow networks
2. **No retry logic** - Single failure loses search attempt
3. **Location always fetched** - Even if not needed for search
4. **No request deduplication** - Rapid calls can queue multiple searches

---

## Security Notes

⚠️ **Important:**
- Search query may contain PII (user's search terms)
- User location transmitted to BuildShip (privacy concern)
- No authentication on BuildShip endpoint
- Filter IDs may reveal user dietary restrictions/allergies

**Recommendations:**
- Add authentication to BuildShip endpoint
- Consider hashing/anonymizing search queries in analytics
- Inform users about location usage in privacy policy

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Flutter Implementation
