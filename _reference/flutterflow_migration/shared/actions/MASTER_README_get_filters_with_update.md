# getFiltersWithUpdate Action

**Type:** Custom Action (Async)
**File:** `get_filters_with_update.dart` (300 lines)
**Category:** Filters & Data Fetching
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐⭐⭐ (Critical - Filter system foundation)

---

## Purpose

Retrieves filter data with intelligent caching and background updates. This action is the backbone of JourneyMate's filter system, providing instant UI response through caching while keeping data fresh with background updates.

**Key Features:**
- Returns cached data immediately for instant UI response
- Automatically refreshes stale cache in the background
- 4-hour staleness threshold for optimal freshness
- Handles network failures gracefully with cached fallback
- Builds filter lookup map for O(1) metadata access
- Updates both filtersForUserLanguage and filterLookupMap
- Uses SharedPreferences for persistent caching

**Critical:** This action implements a sophisticated caching strategy that balances performance with freshness. Never call this on every page load - let the cache system work.

---

## Function Signature

```dart
Future<bool> getFiltersWithUpdate(String languageCode, {String? cityId})
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `languageCode` | `String` | **Yes** | ISO 639-1 code ('en', 'da', 'de', etc.) |
| `cityId` | `String` | No | City ID (defaults to `"17"` / Copenhagen). Will be set by city selector in future. |

### Returns

| Type | Description |
|------|-------------|
| `Future<bool>` | `true` if filters loaded successfully, `false` on error |

---

## Dependencies

### pub.dev Packages
```yaml
http: ^1.2.1              # API calls
shared_preferences: ^2.0.0 # Persistent caching
```

### FFAppState Usage

#### Writes
| State Variable | Type | Purpose |
|---------------|------|---------|
| `filtersForUserLanguage` | `Map<String, dynamic>` | Full API response (filters + foodDrinkTypes) |
| `filterLookupMap` | `Map<int, dynamic>` | Flat map for O(1) filter metadata access |

---

## BuildShip Endpoint

```
GET https://wvb8ww.buildship.run/filters
```

### Query Parameters
```dart
{
  'language_code': 'da',
  'city_id': '17'
}
```

### Response Format
```json
{
  "filters": [
    {
      "id": 1,
      "name": "Dietary Restrictions",
      "type": "category",
      "children": [
        {
          "id": 101,
          "name": "Vegetarian",
          "type": "item",
          "parent_id": 1
        }
      ]
    }
  ],
  "foodDrinkTypes": [
    {
      "id": 1,
      "name": "Coffee",
      "category": "drinks"
    }
  ]
}
```

---

## Caching Strategy

### Overview

The action implements a three-tier caching strategy:

1. **Immediate Return:** If cache exists, return it instantly
2. **Background Update:** If cache is stale (>4 hours), refresh in background
3. **Fallback:** If network fails, use cached data

### Cache Keys

Each language gets two cache entries in SharedPreferences:

| Key | Value | Purpose |
|-----|-------|---------|
| `cached_filters_${languageCode}` | JSON string | Serialized filter data |
| `last_filter_update_${languageCode}` | int (milliseconds) | Last update timestamp |

### Staleness Threshold

```dart
const staleCacheThresholdMs = 14400000; // 4 hours in milliseconds
```

**Rationale:**
- Filters change infrequently (new restaurants added weekly)
- 4 hours balances freshness with performance
- Background updates prevent user-facing delays

### Cache Flow Diagram

```
┌─────────────────────────────────────────────────────┐
│ getFiltersWithUpdate(languageCode)                  │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
         ┌─────────────────┐
         │ Cache exists?   │
         └────┬────────┬───┘
              │        │
            NO│        │YES
              │        │
              ▼        ▼
    ┌──────────────┐  ┌────────────────────┐
    │ Fetch from   │  │ Return cache       │
    │ network      │  │ immediately        │
    │              │  └────────┬───────────┘
    │ Cache result │           │
    └──────────────┘           ▼
                     ┌──────────────────┐
                     │ Cache stale?     │
                     │ (>4 hours)       │
                     └────┬────────┬────┘
                          │        │
                        NO│        │YES
                          │        │
                          ▼        ▼
                    ┌─────────┐  ┌──────────────────┐
                    │ Done    │  │ Background update│
                    └─────────┘  │ (fire & forget)  │
                                 └──────────────────┘
```

---

## Helper Functions

### _getCacheKeys

Generates cache keys for a language code.

```dart
({String data, String timestamp}) _getCacheKeys(String languageCode)
```

**Returns:** Named record with `data` and `timestamp` keys

**Example:**
```dart
final keys = _getCacheKeys('da');
// keys.data = 'cached_filters_da'
// keys.timestamp = 'last_filter_update_da'
```

---

### _getCachedFilters

Retrieves and parses cached filter data.

```dart
dynamic _getCachedFilters(SharedPreferences prefs, String cacheKey)
```

**Returns:** Full response object or `null` if cache doesn't exist

**Side Effects:**
- Updates `FFAppState().filtersForUserLanguage`
- Updates `FFAppState().filterLookupMap`

**Error Handling:**
- Returns `null` if cache doesn't exist
- Returns `null` if JSON parsing fails
- Logs error with debug output

**Example:**
```dart
final prefs = await SharedPreferences.getInstance();
final cached = _getCachedFilters(prefs, 'cached_filters_da');

if (cached != null) {
  // Cache hit - FFAppState already updated
  print('Loaded ${cached['filters'].length} filters');
}
```

---

### _isCacheStale

Checks if cached data exceeds staleness threshold.

```dart
bool _isCacheStale(
  SharedPreferences prefs,
  String timestampKey,
  int currentTimeMs,
  int thresholdMs,
)
```

**Logic:**
```dart
final lastUpdate = prefs.getInt(timestampKey) ?? 0;
return (currentTimeMs - lastUpdate) > thresholdMs;
```

**Example:**
```dart
final now = DateTime.now().toUtc().millisecondsSinceEpoch;
final isStale = _isCacheStale(prefs, 'last_filter_update_da', now, 14400000);

if (isStale) {
  print('Cache is stale - triggering background update');
}
```

---

### _fetchAndCacheFilters

Fetches filters from API and caches the result.

```dart
Future<bool> _fetchAndCacheFilters(
  SharedPreferences prefs,
  int timestamp,
  String languageCode,
  String baseUrl,
)
```

**Returns:** `true` on success, `false` on error

**Side Effects:**
- Writes to SharedPreferences (data + timestamp)
- Updates `FFAppState().filtersForUserLanguage`
- Updates `FFAppState().filterLookupMap`

**Error Handling:**
- Sets empty state on any error
- Logs error details
- Returns `false` to signal failure

---

### _updateFiltersInBackground

Updates filters in the background without blocking UI.

```dart
Future<void> _updateFiltersInBackground(
  SharedPreferences prefs,
  int timestamp,
  String languageCode,
  String baseUrl,
)
```

**Key Characteristics:**
- Fire-and-forget (returns `void`)
- Errors are logged but don't affect user experience
- Updates SharedPreferences on success
- Updates FFAppState on success

**Example:**
```dart
// Called internally when cache is stale
_updateFiltersInBackground(prefs, now, 'da', apiBaseUrl);
// User never sees this - happens in background
```

---

### _buildFilterLookupMap

Builds a flat lookup map from nested filter structure.

```dart
Map<int, dynamic> _buildFilterLookupMap(dynamic filterData)
```

**Purpose:** Enables O(1) filter metadata access without tree traversal

**Performance:**
- Time: O(n) where n = total number of filters
- Space: O(n) - one entry per filter
- Lookup: O(1) after building

**Map Structure:**
```dart
{
  101: {
    'id': 101,
    'name': 'Vegetarian',
    'parent_id': 1,
    'type': 'item',
    // ... all other filter properties
  },
  102: {
    'id': 102,
    'name': 'Vegan',
    'parent_id': 1,
    'type': 'item',
  }
}
```

**Algorithm:**
1. Initialize empty map
2. Define recursive `traverse()` function
3. For each node:
   - Validate it's a Map with integer id
   - Add to map indexed by id
   - Recursively process children
4. Handle both List and single object inputs

**Use Cases:**
- Train station detection (check filter properties)
- Filter validation (verify filter exists)
- Parent filter lookup (find category of leaf filter)
- Analytics (track filter metadata)

---

## Usage Examples

### Example 1: App Initialization

```dart
@override
void initState() {
  super.initState();
  _loadFilters();
}

Future<void> _loadFilters() async {
  final savedLanguage = await actions.getUserPreference('user_language_code');
  final language = savedLanguage.isEmpty ? 'en' : savedLanguage;

  final success = await actions.getFiltersWithUpdate(language);

  if (!success) {
    _showError('Failed to load filters');
  }
}
```

---

### Example 2: Language Change

```dart
Future<void> _onLanguageChanged(String newLanguage) async {
  setState(() => _isLoading = true);

  try {
    // Fetch filters for new language
    final filtersLoaded = await actions.getFiltersWithUpdate(newLanguage);

    if (filtersLoaded) {
      // Update translations
      await actions.getTranslationsWithUpdate(newLanguage);

      // Update currency
      await actions.updateCurrencyForLanguage(newLanguage);

      // Save preference
      await actions.saveUserPreference('user_language_code', newLanguage);

      setState(() => _currentLanguage = newLanguage);
    } else {
      _showError('Failed to load filters for $newLanguage');
    }
  } finally {
    setState(() => _isLoading = false);
  }
}
```

---

### Example 3: Force Refresh

```dart
Future<void> _forceRefreshFilters() async {
  final prefs = await SharedPreferences.getInstance();
  final language = FFAppState().currentLanguage;

  // Clear cache to force fresh fetch
  await prefs.remove('cached_filters_$language');
  await prefs.remove('last_filter_update_$language');

  final success = await actions.getFiltersWithUpdate(language);

  if (success) {
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Filters refreshed')),
    );
  }
}
```

---

### Example 4: Train Station Detection

```dart
bool isTrainStationFilter(int filterId) {
  final filterMeta = FFAppState().filterLookupMap[filterId];

  if (filterMeta == null) return false;

  // Check if filter has specific property
  return filterMeta['isTrainStation'] == true;
}

// Usage in filter sheet
final selectedFilters = FFAppState().selectedFilters;
final hasTrainStation = selectedFilters.any(isTrainStationFilter);

if (hasTrainStation) {
  // Show train station specific UI
}
```

---

## Cache Behavior Examples

### Scenario 1: Fresh Cache (< 4 hours old)

```
User opens app
  └─> getFiltersWithUpdate('da')
      ├─> Check cache: EXISTS (2 hours old)
      ├─> Return cached data: INSTANT
      ├─> Check staleness: FRESH
      └─> Result: Cached data, no network call
```

**User Experience:** Instant filter display

---

### Scenario 2: Stale Cache (> 4 hours old)

```
User opens app after 5 hours
  └─> getFiltersWithUpdate('da')
      ├─> Check cache: EXISTS (5 hours old)
      ├─> Return cached data: INSTANT
      ├─> Check staleness: STALE
      ├─> Trigger background update
      │   └─> Fetch from network (in background)
      │       └─> Update cache + FFAppState
      └─> Result: Instant display, fresh data next time
```

**User Experience:** Instant filter display + silent update

---

### Scenario 3: No Cache (First Launch)

```
User first opens app
  └─> getFiltersWithUpdate('da')
      ├─> Check cache: NONE
      ├─> Fetch from network: BLOCKING
      ├─> Cache result
      ├─> Update FFAppState
      └─> Result: Small delay first time only
```

**User Experience:** Brief loading, then instant every time after

---

### Scenario 4: Network Failure with Cache

```
User opens app offline (cache exists)
  └─> getFiltersWithUpdate('da')
      ├─> Check cache: EXISTS
      ├─> Return cached data: INSTANT
      ├─> Check staleness: STALE
      ├─> Trigger background update
      │   └─> Network call: FAILS
      │       └─> Log error, keep cached data
      └─> Result: App works offline with cached data
```

**User Experience:** App works offline (data may be stale)

---

### Scenario 5: Network Failure without Cache

```
User first opens app offline
  └─> getFiltersWithUpdate('da')
      ├─> Check cache: NONE
      ├─> Fetch from network: FAILS
      ├─> Set empty state
      └─> Result: Returns false, empty filters
```

**User Experience:** Error state - user can't use filters

---

## FFAppState Updates

### filtersForUserLanguage

Stores the complete API response:

```dart
FFAppState().filtersForUserLanguage = {
  'filters': [
    {
      'id': 1,
      'name': 'Dietary Restrictions',
      'type': 'category',
      'children': [...]
    }
  ],
  'foodDrinkTypes': [
    {
      'id': 1,
      'name': 'Coffee',
      'category': 'drinks'
    }
  ]
};
```

**Usage:**
```dart
// Get all filters
final filters = FFAppState().filtersForUserLanguage['filters'] as List?;

// Get food/drink types
final foodTypes = FFAppState().filtersForUserLanguage['foodDrinkTypes'] as List?;
```

---

### filterLookupMap

Stores flattened filter structure for O(1) access:

```dart
FFAppState().filterLookupMap = {
  1: {'id': 1, 'name': 'Dietary Restrictions', 'type': 'category'},
  101: {'id': 101, 'name': 'Vegetarian', 'parent_id': 1, 'type': 'item'},
  102: {'id': 102, 'name': 'Vegan', 'parent_id': 1, 'type': 'item'},
  // ... hundreds more
};
```

**Usage:**
```dart
// O(1) lookup
final filter = FFAppState().filterLookupMap[101];
print(filter['name']); // 'Vegetarian'

// Check if filter exists
if (FFAppState().filterLookupMap.containsKey(filterId)) {
  // Filter is valid
}

// Get parent category
final parentId = filter['parent_id'];
final parent = FFAppState().filterLookupMap[parentId];
print(parent['name']); // 'Dietary Restrictions'
```

---

## Error Handling

### Error 1: Empty Language Code

```
⚠️ getFiltersWithUpdate: Empty language code provided
```

**Return:** `false`
**FFAppState:**
```dart
filtersForUserLanguage = {}
filterLookupMap = {}
```

**Recovery:** None - caller must provide valid language code

---

### Error 2: API Failure (No Cache)

```
❌ Failed to fetch filters. Status: 500
```

**Return:** `false`
**FFAppState:**
```dart
filtersForUserLanguage = {}
filterLookupMap = {}
```

**Recovery:** Show error to user, retry later

---

### Error 3: API Failure (With Cache)

```
🔄 Background update failed. Status: 503
```

**Return:** `true` (cached data still valid)
**FFAppState:** Unchanged (keeps cached data)

**Recovery:** Automatic - next call will retry

---

### Error 4: JSON Parse Error

```
❌ Error parsing cached filters: FormatException...
```

**Return:** `false`
**FFAppState:**
```dart
filtersForUserLanguage = {}
filterLookupMap = {}
```

**Recovery:** Cache cleared, will fetch fresh data

---

## Debug Output

### Success - Cache Hit (Fresh)

```
✅ Returning cached filters for da
📊 Loaded cached filters with 247 entries in lookup map
📊 Response contains 23 food/drink types
```

---

### Success - Cache Hit (Stale)

```
✅ Returning cached filters for da
🔄 Cache is stale. Initiating background update for da
📊 Loaded cached filters with 247 entries in lookup map
📊 Response contains 23 food/drink types
```

Later (background):
```
✅ Background update successful for da
📊 Updated lookup map with 251 entries
📊 Response contains 24 food/drink types
```

---

### Success - Cache Miss

```
🔍 No cache found. Fetching filters from network for da
✅ Successfully fetched and cached filters for da
📊 Built lookup map with 247 entries
📊 Response contains 23 food/drink types
```

---

### Failure

```
❌ Error in getFiltersWithUpdate: SocketException: Failed host lookup
```

---

## Performance Considerations

### Cache Size

Typical cache size per language:
- **Filters:** ~50KB (247 filters, nested structure)
- **foodDrinkTypes:** ~5KB (23 items)
- **Total:** ~55KB per language

**SharedPreferences Limit:** 1MB (plenty of room for multiple languages)

---

### Memory Impact

FFAppState holds two copies of filter data:

1. **filtersForUserLanguage:** Nested structure (~50KB)
2. **filterLookupMap:** Flat map (~40KB)

**Total:** ~90KB in memory per language

**Trade-off:** Small memory cost for O(1) lookup performance

---

### Network Usage

- **First load:** 55KB download
- **Background update:** 55KB download (every 4+ hours)
- **Language switch:** 55KB download (if not cached)

**Optimization:** Multi-language users accumulate caches over time

---

### Recommended Patterns

#### ✅ GOOD - Once per language change

```dart
await actions.getFiltersWithUpdate(newLanguage);
```

#### ✅ GOOD - Once on app start

```dart
@override
void initState() {
  super.initState();
  actions.getFiltersWithUpdate(savedLanguage);
}
```

#### ❌ BAD - Every page navigation

```dart
// DON'T DO THIS
@override
void initState() {
  super.initState();
  // Unnecessary - cache already loaded!
  actions.getFiltersWithUpdate(FFAppState().currentLanguage);
}
```

#### ❌ BAD - Manual background updates

```dart
// DON'T DO THIS - action handles this automatically
Timer.periodic(Duration(hours: 1), (_) {
  actions.getFiltersWithUpdate(currentLanguage);
});
```

---

## Testing Checklist

- [ ] Fetch English filters → cache populated, FFAppState updated
- [ ] Fetch Danish filters → cache populated, FFAppState updated
- [ ] Empty language code → returns false, state empty
- [ ] API returns 404 → returns false, state empty
- [ ] API returns malformed JSON → returns false, state empty
- [ ] Fresh cache (<4h) → returns immediately, no network call
- [ ] Stale cache (>4h) → returns immediately, triggers background update
- [ ] Background update success → cache refreshed silently
- [ ] Background update failure → cache unchanged, no user impact
- [ ] No cache + offline → returns false, state empty
- [ ] Stale cache + offline → returns true, uses cached data
- [ ] filterLookupMap built correctly → O(1) filter access works
- [ ] foodDrinkTypes included → available in filtersForUserLanguage
- [ ] Switch languages back and forth → correct cache used each time
- [ ] Force refresh (clear cache) → fresh fetch works

---

## Migration Notes

### Phase 3 Changes

1. **Replace FFAppState with Riverpod:**
   ```dart
   // Before:
   FFAppState().update(() {
     FFAppState().filtersForUserLanguage = responseJson;
     FFAppState().filterLookupMap = lookupMap;
   });

   // After:
   ref.read(filtersProvider.notifier).setFilters(responseJson);
   ref.read(filterLookupProvider.notifier).setLookup(lookupMap);
   ```

2. **Consider RxDart for background updates:**
   ```dart
   // Stream-based background updates
   final _updateStream = BehaviorSubject<FilterUpdate>();

   // Listen for updates in UI
   _updateStream.listen((update) {
     if (update.success) {
       // Silently refresh UI
       setState(() {});
     }
   });
   ```

3. **Keep caching strategy** - It works well, don't change it

4. **Add cache invalidation:**
   ```dart
   // Clear all language caches
   Future<void> clearAllFilterCaches() async {
     final prefs = await SharedPreferences.getInstance();
     final keys = prefs.getKeys().where((k) => k.startsWith('cached_filters_'));
     for (final key in keys) {
       await prefs.remove(key);
     }
   }
   ```

---

## Related Actions

| Action | Purpose | Relationship |
|--------|---------|--------------|
| `getTranslationsWithUpdate` | Fetch translations | Called together on language change |
| `updateCurrencyForLanguage` | Update currency | Called after filter/translation load |
| `saveUserPreference` | Save language | Called after successful load |

---

## Used By Pages

1. **Welcome/Onboarding** - Initial filter load
2. **Settings** - Language selector
3. **Search** - Filter system (reads cached data)
4. **Business Profile** - Filter display (reads cached data)
5. **Filter Sheet** - Filter selection (reads cached data)

---

## Known Issues

1. **No cleanup for old language caches** - Accumulates over time
2. **No retry logic for failed background updates** - Waits for next call
3. **No progress indication** - First load appears instant even if slow

---

## Advanced Topics

### Why Fire-and-Forget Background Updates?

The `_updateFiltersInBackground` function returns `void` instead of being awaited. This is intentional:

**Benefits:**
- User sees instant response from cache
- No UI blocking during network calls
- Failures don't affect user experience
- Updates happen silently

**Trade-offs:**
- No immediate feedback on update success
- Can't show "Updated" notification
- Error handling is limited to logging

**Alternative:** If you need feedback, refactor to use streams:
```dart
final _updateController = StreamController<bool>.broadcast();

// In background update
_updateController.add(true); // success

// In UI
_updateController.stream.listen((success) {
  if (success) showSnackBar('Filters updated');
});
```

---

### Why 4-Hour Threshold?

The staleness threshold balances freshness with performance:

**Too Short (1 hour):**
- Excessive network calls
- Battery drain
- Higher data usage

**Too Long (24 hours):**
- Stale data shown too long
- New restaurants not discovered
- Filter changes delayed

**4 Hours (chosen):**
- Filters rarely change during a session
- Background updates happen naturally
- Reasonable freshness guarantee
- Low network overhead

**Adjust for your needs:**
```dart
// More aggressive (testing)
const staleCacheThresholdMs = 300000; // 5 minutes

// More conservative (production)
const staleCacheThresholdMs = 86400000; // 24 hours
```

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Riverpod migration, cache cleanup
