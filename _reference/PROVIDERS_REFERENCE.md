# PROVIDERS_REFERENCE.md
## Complete reference for all Riverpod providers (Phase 5 output)

**Working on a specific task?** See **CLAUDE.md → Task-Based Navigation Guide** (Scenario 5: Modifying State Management) for targeted reading. Otherwise, browse the full provider catalog below.

**Created:** 2026-02-21
**For:** Phase 7 page implementation

---

## Provider File Locations

All providers use **Riverpod 3.x** API (`Notifier`/`AsyncNotifier`, NOT `StateNotifier`).

| Provider File | Providers Included | Lines of Code |
|--------------|-------------------|---------------|
| `providers/provider_state_classes.dart` | All state classes (centralized) | ~450 |
| `providers/app_providers.dart` | accessibility, analytics, translationsCache | ~220 |
| `providers/search_providers.dart` | searchState | ~145 |
| `providers/business_providers.dart` | business | ~75 |
| `providers/filter_providers.dart` | filter (AsyncNotifier) | ~100 |
| `providers/settings_providers.dart` | localization, location | ~120 |
| `theme/app_constants.dart` | kDefaultCityId constant | N/A |

---

## All Provider Exports (Import Statements for Phase 7)

```dart
// App-level providers
import 'package:journey_mate/providers/app_providers.dart';
// Contains: accessibilityProvider, analyticsProvider, translationsCacheProvider

// Search state
import 'package:journey_mate/providers/search_providers.dart';
// Contains: searchStateProvider

// Business/menu state
import 'package:journey_mate/providers/business_providers.dart';
// Contains: businessProvider

// Filter state (async)
import 'package:journey_mate/providers/filter_providers.dart';
// Contains: filterProvider (AsyncNotifierProvider)

// Settings
import 'package:journey_mate/providers/settings_providers.dart';
// Contains: localizationProvider, locationProvider

// Constants
import 'package:journey_mate/theme/app_constants.dart';
// Contains: AppConstants.kDefaultCityId (17)
```

---

## Provider 1: accessibilityProvider

### State Class: AccessibilityState

```dart
class AccessibilityState {
  final bool isBoldTextEnabled;  // Default: false
  final double fontScale;        // Default: 1.0
}
```

### Persistence

- **Persisted fields:** `isBoldTextEnabled`, `fontScale`
- **Storage:** SharedPreferences
- **Keys:** `'is_bold_text_enabled'`, `'font_scale'`
- **Initialization:** `await container.read(accessibilityProvider.notifier).loadFromPreferences()`

### Methods

```dart
// Read
final state = ref.watch(accessibilityProvider);

// Write
await ref.read(accessibilityProvider.notifier).loadFromPreferences();
await ref.read(accessibilityProvider.notifier).setBoldText(bool enabled);
await ref.read(accessibilityProvider.notifier).setFontScale(double scale);
```

### Usage Example

```dart
class MyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibility = ref.watch(accessibilityProvider);

    return Text(
      'Hello',
      style: TextStyle(
        fontWeight: accessibility.isBoldTextEnabled ? FontWeight.bold : FontWeight.normal,
        fontSize: 16 * accessibility.fontScale,
      ),
    );
  }
}
```

---

## Provider 2: analyticsProvider

### State Classes

```dart
class AnalyticsState {
  final String deviceId;             // Persisted UUID
  final String? sessionId;            // Current session UUID
  final DateTime? sessionStartTime;
  final MenuSessionData? menuSessionData;  // 11 fields
}

class MenuSessionData {
  final String menuSessionId;          // UUID v4
  final int itemClicks;                // Menu item detail opens
  final int packageClicks;             // Package detail opens
  final List<int> categoriesViewed;    // Category IDs (de-duped)
  final int deepestScrollPercent;      // Max scroll depth (0-100)
  final int filterInteractions;        // Total filter toggle count
  final int filterResets;              // "Clear All" presses
  final bool everHadFiltersActive;     // Any filter activated flag
  final int zeroResultCount;           // Times filters → 0 items
  final int lowResultCount;            // Times filters → 1-2 items
  final List<int> filterResultHistory; // Result count after each change
}
```

### Persistence

- **Persisted fields:** `deviceId` only
- **Storage:** SharedPreferences
- **Key:** `'device_id'`
- **Initialization:** `await container.read(analyticsProvider.notifier).initialize()`

### Methods

```dart
// Session management
ref.read(analyticsProvider.notifier).startSession();
ref.read(analyticsProvider.notifier).endSession();

// Menu session tracking
ref.read(analyticsProvider.notifier).startMenuSession(int businessId);
ref.read(analyticsProvider.notifier).endMenuSession(int businessId);

// Menu session increments
ref.read(analyticsProvider.notifier).incrementItemClick();
ref.read(analyticsProvider.notifier).incrementPackageClick();
ref.read(analyticsProvider.notifier).recordCategoryViewed(int categoryId);
ref.read(analyticsProvider.notifier).updateDeepestScroll(int percent);
ref.read(analyticsProvider.notifier).incrementFilterReset();
ref.read(analyticsProvider.notifier).updateMenuSessionFilterMetrics(int resultCount, bool hasActiveFilters);
```

### Usage Example

```dart
// On menu page load
ref.read(analyticsProvider.notifier).startMenuSession(businessId);

// On menu item click
ref.read(analyticsProvider.notifier).incrementItemClick();

// On filter change (menu page)
final searchState = ref.read(searchStateProvider);
final hasActiveFilters = searchState.filtersUsedForSearch.isNotEmpty;
ref.read(analyticsProvider.notifier).updateMenuSessionFilterMetrics(
  filteredItems.length,
  hasActiveFilters,
);

// On menu page exit
ref.read(analyticsProvider.notifier).endMenuSession(businessId);
```

---

## Provider 3: translationsCacheProvider

### State Type: `Map<String, String>`

Cache of dynamic translations from BuildShip `GET_UI_TRANSLATIONS` endpoint.

### Persistence

- **No persistence** (loaded from API on startup)

### Methods

```dart
// Load from API
await ref.read(translationsCacheProvider.notifier).loadTranslations('en');

// Clear cache
ref.read(translationsCacheProvider.notifier).clear();

// Read translation (via helper function)
import 'package:journey_mate/services/translation_service.dart';

String translated = td(ref, 'key_search'); // Dynamic keys
```

### Initialization

Called in `main.dart`:
```dart
await container.read(translationsCacheProvider.notifier).loadTranslations('en');
```

---

## Provider 4: searchStateProvider

### State Class: SearchState

```dart
class SearchState {
  final dynamic searchResults;              // JSON from API
  final int searchResultsCount;
  final bool hasActiveSearch;
  final String currentSearchText;
  final List<int> filtersUsedForSearch;     // Active filter IDs
  final String currentFilterSessionId;
  final List<int> previousActiveFilters;    // Snapshot before change
  final String previousSearchText;
  final String previousFilterSessionId;
  final int currentRefinementSequence;      // Refinement count
  final List<int>? selectedNeighbourhoodId;  // Neighbourhood filter IDs (multi-select, routed from overlay)
  final int? selectedShoppingAreaId;          // Shopping area filter ID (routed from overlay)
  final DateTime? lastRefinementTime;
  final DateTime? lastFetchTime;             // Timestamp of most recent search API call
  final int visibleResultCount;             // Count for Open Now badge & page title
}
```

### Persistence

- **No persistence** (session-only state)

### Methods

```dart
// Search results (atomic — updates results, counts, and visibleResultCount together)
ref.read(searchStateProvider.notifier).updateSearchResults(results, count);
ref.read(searchStateProvider.notifier).setSearchText(String text);
ref.read(searchStateProvider.notifier).markSearchInactive();
ref.read(searchStateProvider.notifier).clearSearch();

// Filters
ref.read(searchStateProvider.notifier).toggleFilter(int filterId);
ref.read(searchStateProvider.notifier).addFilters(List<int> filterIds);
ref.read(searchStateProvider.notifier).removeFilters(List<int> filterIds);
ref.read(searchStateProvider.notifier).clearFilters();
ref.read(searchStateProvider.notifier).setFilters(List<int> filterIds);

// Geographic filter routing (separates neighbourhood/shopping area/station from regular filters)
// Neighbourhoods → selectedNeighbourhoodId (List<int>), shopping areas → selectedShoppingAreaId,
// train stations → dropped (handled via selectedStation param), rest → filtersUsedForSearch
ref.read(searchStateProvider.notifier).setFiltersWithRouting(
    List<int> allIds, Map<int, dynamic> filterLookup);

// Filter session tracking
ref.read(searchStateProvider.notifier).setFilterSessionId(String sessionId);
ref.read(searchStateProvider.notifier).generateNewFilterSessionId();

// Refinement tracking
ref.read(searchStateProvider.notifier).updatePreviousState();
ref.read(searchStateProvider.notifier).incrementRefinementSequence();
ref.read(searchStateProvider.notifier).resetRefinementSequence();

// Utility methods
bool isActive = ref.read(searchStateProvider.notifier).isFilterActive(10);
int count = ref.read(searchStateProvider.notifier).getActiveFilterCount();
```

### Page-Local State (search_page.dart — Not in Provider)

The search page manages additional state locally that does NOT belong in `searchStateProvider`:

| Local Variable | Type | Purpose |
|---------------|------|---------|
| `_ViewMode` enum | `list` / `map` | Current view mode (list or map toggle) |
| `_mapViewportBounds` | `LatLngBounds?` | Map viewport bounds, sent as `geoBoundsJson` to API |
| `_mapPageSize` | `int` (200) | Page size for map view (vs `_listPageSize` = 20 for list view) |

**Why page-local:** These are UI concerns specific to the search page's presentation mode. The search provider manages what results to fetch; the page manages how to display them.

### Usage Example

```dart
class SearchPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchStateProvider);

    return Column(
      children: [
        TextField(
          onChanged: (text) {
            ref.read(searchStateProvider.notifier).setSearchText(text);
          },
        ),
        if (searchState.hasActiveSearch)
          Text('Found ${searchState.searchResultsCount} results'),
      ],
    );
  }
}
```

---

## Provider 5: businessProvider

### State Class: BusinessState

```dart
class BusinessState {
  final dynamic currentBusiness;            // JSON from API
  final dynamic menuItems;                  // JSON from API
  final List<int> businessFilterIds;        // Filter IDs
  final dynamic openingHours;               // JSON hours data
  final List<int> availableDietaryPreferences;
  final List<int> availableDietaryRestrictions;
}
```

**Field notes (v2 audit — commit `6804d38`):**
- `filterDescriptions` — exists in notifier via `setFilterDescriptions()` method, not yet consumed by v2 widgets. Reserved for upcoming services chip feature (filter description bottom sheet). Keep.
- `matchedCount` / `totalCount` — dead code. Set alongside `filterDescriptions` but never read; `MatchCardWidget` computes matches internally from raw filters. Do not use in new code.

### Page-Local State (business_profile_page_v2.dart — Not in Provider)

Some business-related state lives locally in the profile page, not in `businessProvider`:

| Local Variable | Type | Purpose |
|---------------|------|---------|
| `_menuLoadFailed` | `bool` | Tracks whether the menu API call failed (shows error widget in menu section only) |
| `_menuSessionStarted` | `bool` | Guards `dispose()` session tracking — prevents ending a session that never started |

**Why page-local:** These track per-page-visit error state and analytics guards. They reset on each page visit and don't need to be shared across pages.

### Persistence

- **No persistence** (session-only state)

### Methods

```dart
// Set business data
ref.read(businessProvider.notifier).setCurrentBusiness(
  business: businessJson,
  filterIds: [10, 20, 30],
  hours: hoursJson,
);

// Set menu
ref.read(businessProvider.notifier).setMenuItems(menuJson);

// Set dietary options
ref.read(businessProvider.notifier).setDietaryOptions(
  preferences: [100, 101],
  restrictions: [200, 201],
);

// Partial updates
ref.read(businessProvider.notifier).updateOpeningHours(hoursJson);
ref.read(businessProvider.notifier).updateFilterIds([10, 20]);

// Clear
ref.read(businessProvider.notifier).clearBusiness();

// Utility methods
bool hasData = ref.read(businessProvider.notifier).hasCurrentBusiness();
bool hasMenu = ref.read(businessProvider.notifier).hasMenuItems();
int? id = ref.read(businessProvider.notifier).getCurrentBusinessId();
```

### Usage Example

```dart
// On business profile load
final response = await ApiService.instance.getBusinessProfile(businessId);
ref.read(businessProvider.notifier).setCurrentBusiness(
  business: response.jsonBody['business_profile'],
  filterIds: response.jsonBody['filter_ids'],
  hours: response.jsonBody['business_hours'],
);

// On menu load
final menuResponse = await ApiService.instance.getRestaurantMenu(businessId);
// Pass FULL response Map (contains menu_items, categories, availablePreferences, availableRestrictions)
ref.read(businessProvider.notifier).setMenuItems(menuResponse.jsonBody);
```

---

## Provider 6: filterProvider (AsyncNotifier)

### State Class: FilterState

```dart
class FilterState {
  final dynamic filtersForLanguage;         // JSON hierarchy from API
  final Map<int, dynamic> filterLookupMap;  // Flattened for quick lookups
  final List<dynamic> foodDrinkTypes;       // Food/drink type list
}
```

### Persistence

- **No persistence** (loaded from API on startup or language change)

### Methods

```dart
// Load filters (async)
await ref.read(filterProvider.notifier).loadFiltersForLanguage('en');

// Access state (with AsyncValue handling)
final filterState = ref.watch(filterProvider);
filterState.when(
  data: (state) {
    // Use state.filtersForLanguage, state.filterLookupMap
  },
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Text('Error: $e'),
);

// Utility methods
final filter = ref.read(filterProvider.notifier).getFilterById(10);
bool loaded = ref.read(filterProvider.notifier).isLoaded();

// Clear
ref.read(filterProvider.notifier).clear();
```

### Usage Example

```dart
class FilterBottomSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(filterProvider);

    return filterState.when(
      data: (state) {
        final filters = state.filtersForLanguage;
        return ListView(/* build filter UI */);
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Failed to load filters'),
    );
  }
}
```

### Initialization

Called in `main.dart` (optional, can lazy-load on first access):
```dart
// Not initialized in main.dart by default
// Loads when first accessed or when language changes
```

---

## Provider 7: localizationProvider

### State Class: LocalizationState

```dart
class LocalizationState {
  final String currencyCode;   // Persisted (default: 'DKK')
  final double exchangeRate;   // NOT persisted (default: 1.0)
  final String distanceUnit;   // Persisted (default: 'imperial' for English, 'metric' for others)
}
```

### Persistence

- **Persisted fields:** `currencyCode`, `distanceUnit`
- **Storage:** SharedPreferences
- **Keys:** `'user_currency_code'`, `'user_distance_unit'`
- **Initialization:** `container.read(localizationProvider.notifier).initializeFromPrefs()`

### Methods

```dart
// Load from preferences
await ref.read(localizationProvider.notifier).loadFromPreferences();

// Set currency (persists code, updates rate)
await ref.read(localizationProvider.notifier).setCurrency('EUR', 7.5);

// Set exchange rate only (NOT persisted)
ref.read(localizationProvider.notifier).setExchangeRate(8.0);

// Reset to default
await ref.read(localizationProvider.notifier).resetToDefault();

// Set distance unit (persists to SharedPreferences)
await ref.read(localizationProvider.notifier).setDistanceUnit('metric');
```

### Usage Example

```dart
class PriceDisplay extends ConsumerWidget {
  final double priceInDKK;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localization = ref.watch(localizationProvider);
    final convertedPrice = priceInDKK * localization.exchangeRate;

    return Text('${convertedPrice.toStringAsFixed(2)} ${localization.currencyCode}');
  }
}

class DistanceDisplay extends ConsumerWidget {
  final double distanceInKm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localization = ref.watch(localizationProvider);
    final languageCode = Localizations.localeOf(context).languageCode;

    // Non-English: ALWAYS metric (ignore stored preference)
    // English: Use stored preference (imperial or metric)
    final effectiveUnit = languageCode == 'en'
        ? localization.distanceUnit
        : 'metric';

    final displayDistance = effectiveUnit == 'imperial'
        ? distanceInKm * 0.621371 // Convert to miles
        : distanceInKm;

    final unitLabel = effectiveUnit == 'imperial' ? 'mi' : 'km';

    return Text('${displayDistance.toStringAsFixed(1)} $unitLabel');
  }
}
```

---

## Provider 8: locationProvider

### State Class: LocationState

```dart
class LocationState {
  final bool hasPermission;   // Default: false
}
```

### Persistence

- **No persistence** (checked at runtime)

### Methods

```dart
// Check permission status (async)
await ref.read(locationProvider.notifier).checkPermission();

// Smart enable - RECOMMENDED for user-facing "Enable" buttons (async)
// - Shows permission dialog if first time
// - Opens Settings if previously denied
// - Opens Settings if already granted (for management)
await ref.read(locationProvider.notifier).enableLocation();

// Request permission - only use for programmatic requests (async)
// - Shows permission dialog
// - Returns false if previously denied (no fallback to Settings)
bool granted = await ref.read(locationProvider.notifier).requestPermission();

// Request permission only if never asked before (async)
// Safe to call on app launch - becomes no-op after first denial
await ref.read(locationProvider.notifier).requestPermissionIfNeeded();

// Banner management
await ref.read(locationProvider.notifier).dismissBanner();
await ref.read(locationProvider.notifier).resetBannerDismissal();

// Manual state control (rarely needed)
ref.read(locationProvider.notifier).setPermission(true);

// Open app settings directly (async)
await ref.read(locationProvider.notifier).openSettings();
```

### Method Selection Guide

**When to use each method:**

- **`enableLocation()`** — User-facing "Enable Location" / "Activate" buttons
  - ✅ Handles all cases: first request, denied, already granted
  - ✅ Always provides a path forward (dialog or Settings)
  - Example: LocationStatusCard, search page banner

- **`requestPermission()`** — Programmatic permission requests
  - ⚠️ Only shows dialog, fails silently if previously denied
  - Use when you need immediate yes/no without Settings fallback
  - Rare use case - prefer `enableLocation()` for UI elements

- **`requestPermissionIfNeeded()`** — App startup permission check
  - ✅ Safe to call on every launch
  - Only requests if never asked before (status == denied)
  - Becomes no-op after first denial

- **`checkPermission()`** — Refresh current status
  - Use when returning from Settings to update state
  - Called automatically in initState of pages needing location

### Usage Example

```dart
class LocationButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationProvider);

    return ElevatedButton(
      onPressed: () async {
        if (!locationState.hasPermission) {
          // Use enableLocation for user-facing buttons
          await ref.read(locationProvider.notifier).enableLocation();
        }
        // Use location after permission granted
      },
      child: Text(locationState.hasPermission ? 'Use Location' : 'Enable Location'),
    );
  }
}
```

### Initialization

Called in `main.dart`:
```dart
await container.read(locationProvider.notifier).checkPermission();
```

---

## Initialization Order (main.dart)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AnalyticsService.instance.initialize();

  final container = ProviderContainer();

  // Initialization order: Analytics → Accessibility → Localization → Translations → Location
  await container.read(analyticsProvider.notifier).initialize();
  await container.read(accessibilityProvider.notifier).loadFromPreferences();
  await container.read(localizationProvider.notifier).loadFromPreferences();
  await container.read(translationsCacheProvider.notifier).loadTranslations('en');
  await container.read(locationProvider.notifier).checkPermission();

  // Register lifecycle observer
  final appObserver = AppLifecycleObserver(container: container);
  WidgetsBinding.instance.addObserver(appObserver);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ActivityScope(
        child: JourneyMateApp(),
      ),
    ),
  );
}
```

---

## Common Patterns for Phase 7

### Pattern 1: Read State in ConsumerWidget

```dart
class MyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchStateProvider);
    final business = ref.watch(businessProvider);

    return Column(/* use state */);
  }
}
```

### Pattern 2: Write State (Fire-and-Forget)

```dart
onPressed: () {
  ref.read(searchStateProvider.notifier).setSearchText('pizza');
}
```

### Pattern 3: Write State (Await)

```dart
onPressed: () async {
  await ref.read(localizationProvider.notifier).setCurrency('EUR', 7.5);
}
```

### Pattern 4: Conditional Rendering Based on State

```dart
final accessibility = ref.watch(accessibilityProvider);

return Text(
  'Hello',
  style: accessibility.isBoldTextEnabled
    ? AppTypography.headingBold
    : AppTypography.heading,
);
```

### Pattern 5: AsyncValue Handling (filterProvider)

```dart
final filterState = ref.watch(filterProvider);

return filterState.when(
  data: (state) => ListView(/* build UI */),
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Text('Error: $e'),
);
```

### Pattern 6: Local State + Provider State

```dart
class MyPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyPage> createState() => _MyPageState();
}

class _MyPageState extends ConsumerState<MyPage> {
  String _localSearchText = '';  // Local UI state

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchStateProvider);  // Global state

    return TextField(
      onChanged: (text) {
        setState(() => _localSearchText = text);  // Local update
        ref.read(searchStateProvider.notifier).setSearchText(text);  // Global update
      },
    );
  }
}
```

---

## Constants

### kDefaultCityId

```dart
import 'package:journey_mate/theme/app_constants.dart';

const cityId = AppConstants.kDefaultCityId;  // 17 (Copenhagen)
```

Use this constant in all API calls requiring `cityId`. Do not hardcode `17`.

---

## Persistence Summary

| Provider | Persisted Fields | Storage | Load Method |
|----------|-----------------|---------|-------------|
| accessibility | isBoldTextEnabled, fontScale | SharedPreferences | `loadFromPreferences()` |
| analytics | deviceId | SharedPreferences | `initialize()` |
| translationsCache | — | — (API cache) | `loadTranslations(lang)` |
| searchState | — | — (session only) | N/A |
| business | — | — (session only) | N/A |
| filter | — | — (API cache) | `loadFiltersForLanguage(lang)` |
| localization | currencyCode | SharedPreferences | `loadFromPreferences()` |
| location | — | — (runtime check) | `checkPermission()` |

---

## Testing Notes

All providers have comprehensive unit tests:
- **accessibilityProvider:** 9 tests, 100% coverage
- **analyticsProvider:** 20 tests, all 11 menuSessionData fields verified
- **searchStateProvider:** 21 tests, all state transitions covered
- **businessProvider:** 13 tests, all methods covered
- **localizationProvider:** 5 tests, persistence verified
- **locationProvider:** 2 tests (runtime permission checks excluded)

**Total:** 70 tests, all passing

Run tests: `flutter test test/providers/`

---

## Phase 7 Readiness Checklist

- [x] All 8 providers implemented
- [x] All providers use Riverpod 3.x API
- [x] Persistence fully implemented (not deferred)
- [x] MenuSessionData with 11 fields complete
- [x] kDefaultCityId constant added
- [x] All providers initialized in main.dart
- [x] Unit tests with >90% coverage
- [x] flutter analyze 0 issues
- [x] Documentation complete

**Status:** ✅ Phase 5 COMPLETE — Phase 7 can begin

---

**End of PROVIDERS_REFERENCE.md**
