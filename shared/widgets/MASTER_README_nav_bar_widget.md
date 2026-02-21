# MASTER_README_nav_bar_widget.md

**Widget Name:** `NavBarWidget`
**Type:** Shared Widget (Bottom Navigation Bar)
**Phase:** Phase 7 Batch 6
**Created:** 2026-02-21

---

## Purpose

Bottom navigation bar with 2 tabs (Search, Account) that provides primary app navigation and triggers search API calls.

---

## Overview

### What it does
- Displays a fixed bottom navigation bar with 2 tabs
- Search tab: Triggers API search call, updates searchStateProvider, navigates to /search
- Account tab: Clears filters, navigates to /settings
- Active tab styling with accent color
- Location integration for search (with fallback to LatLng(0, 0))

### When it's used
- Present on ALL pages that need bottom navigation
- Search page: pageIsSearchResults = true (Search tab active)
- Settings pages: pageIsSearchResults = false (Account tab active)

### Dependencies
- **Riverpod Providers:** searchStateProvider (read/write), filterProvider (write)
- **API Service:** ApiService.instance.search() for search tab functionality
- **Navigation:** go_router for page transitions
- **Location:** geolocator package for user location
- **Translation:** ts() helper for static UI text

---

## Implementation Details

### Widget Type
`ConsumerStatefulWidget` (needs ref for provider access, has local state for async operations)

### File Location
`journey_mate/lib/widgets/shared/nav_bar_widget.dart` (~230 lines)

### Parameters

```dart
class NavBarWidget extends ConsumerStatefulWidget {
  /// Whether the current page is the search results page
  /// - true = Search page (search tab is active)
  /// - false = Account page (account tab is active)
  final bool pageIsSearchResults;

  const NavBarWidget({
    super.key,
    required this.pageIsSearchResults,
  });
}
```

**Parameter Details:**
- `pageIsSearchResults` (bool, required): Determines which tab is visually active and controls tap behavior

---

## Key Features

### 1. Search Tab Behavior
When search tab is tapped (and NOT already on search page):
1. Get user location (falls back to LatLng(0, 0) if permission denied)
2. Format location as "LatLng(lat: X, lng: Y)" string
3. Call SearchCall API with:
   - cityId: AppConstants.kDefaultCityId (17)
   - userLocation: formatted location string
   - searchInput: '' (empty for initial load)
   - languageCode: from Localizations.localeOf(context)
   - filters: [] (empty initially)
   - sortBy: 'match', sortOrder: 'desc'
   - page: 1, pageSize: 20
4. Parse response and update searchStateProvider with results and count
5. Generate new filter session ID
6. Navigate to /search (with context.mounted check)

### 2. Account Tab Behavior
When account tab is tapped (and NOT already on account page):
1. Clear all active filters via searchStateProvider
2. Clear filter session ID
3. Navigate to /settings

### 3. Location Fallback Pattern
```dart
Future<Position?> _getUserLocation() async {
  try {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 5),
      ),
    );
  } catch (e) {
    return null; // Fallback on any error
  }
}

String _formatLatLng(Position? position) {
  if (position == null) {
    return 'LatLng(lat: 0.0, lng: 0.0)'; // Fallback
  }
  return 'LatLng(lat: ${position.latitude}, lng: ${position.longitude})';
}
```

### 4. Tab Styling
- **Active tab:** AppColors.accent (orange #e8751a)
- **Inactive tab:** AppColors.textPrimary (dark gray #0F0F0F)
- Icon size: 24.0
- Font: GoogleFonts.roboto, 16px, FontWeight.w400

---

## Design Token Mappings

### Colors
| Element | Token | Hex Value | Usage |
|---------|-------|-----------|-------|
| Active tab icon/text | AppColors.accent | #e8751a | Search tab when on /search, Account tab when on /settings |
| Inactive tab icon/text | AppColors.textPrimary | #0F0F0F | Inactive tab |
| Background | AppColors.bgPage | #FFFFFF | NavBar container |

### Spacing
| Element | Token | Value | Usage |
|---------|-------|-------|-------|
| Icon to text gap | const | 4px | SizedBox between icon and label |
| Container height | const | 70.0 | Total NavBar height |
| Tab width | const | 100.0 | Each tab button width |

### Typography
| Element | Style | Size/Weight | Usage |
|---------|-------|-------------|-------|
| Tab labels | GoogleFonts.roboto | 16px, w400 | "Search" and "Account" text |

---

## Translation Keys

| Key | English | Usage |
|-----|---------|-------|
| `m4kntw8r` | "Search" | Search tab label (FlutterFlow legacy key) |
| `ykne5sdr` | "Account" | Account tab label (FlutterFlow legacy key) |

**Note:** These keys already exist in kStaticTranslations from Phase 6A. No new keys added for NavBarWidget.

---

## Provider Integration

### searchStateProvider (read/write)
```dart
// Update search results after API call
ref.read(searchStateProvider.notifier).updateSearchResults(
  jsonBody,  // dynamic results
  resultCount, // int
);

// Generate new filter session ID
ref.read(searchStateProvider.notifier).generateNewFilterSessionId();

// Clear filters (Account tab)
ref.read(searchStateProvider.notifier).clearFilters();

// Clear filter session ID
ref.read(searchStateProvider.notifier).setFilterSessionId('');
```

---

## API Integration

### SearchCall API (BuildShip Endpoint #1)
**Endpoint:** `/search`
**Method:** POST
**Called by:** ApiService.instance.search()

**Request Parameters:**
```dart
{
  'cityId': '17',
  'userLocation': 'LatLng(lat: 55.6761, lng: 12.5683)',
  'searchInput': '',
  'languageCode': 'en',
  'filters': [],
  'filtersUsedForSearch': [],
  'sortBy': 'match',
  'sortOrder': 'desc',
  'selectedStation': null,
  'onlyOpen': false,
  'category': 'all',
  'page': 1,
  'pageSize': 20,
}
```

**Response Format:**
```dart
{
  'resultCount': 42,
  'results': [ /* array of business objects */ ],
  // ... other fields
}
```

---

## Navigation Routes

### go_router Routes Used
- `/search` — Search results page
- `/settings` — Settings main page

### Navigation Pattern
```dart
// After API success
if (!context.mounted) return;
// ignore: use_build_context_synchronously
context.go('/search');
```

**Note:** The `use_build_context_synchronously` lint is intentionally suppressed here. The code correctly checks `context.mounted` before using context after async operations.

---

## Usage Example

```dart
class SearchPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: /* page content */,
      bottomNavigationBar: NavBarWidget(
        pageIsSearchResults: true, // Search tab is active
      ),
    );
  }
}

class SettingsMainPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: /* page content */,
      bottomNavigationBar: NavBarWidget(
        pageIsSearchResults: false, // Account tab is active
      ),
    );
  }
}
```

---

## Error Handling

### Location Permission Denied
- Falls back to LatLng(0, 0) without crashing
- User won't see any error message
- Search still proceeds with fallback coordinates

### API Call Failure
- Caught in try-catch block
- Silently fails (prints debug message only)
- User will see no results or error on search page itself
- No toast/snackbar shown from NavBar

### Widget Unmounted After Async
- All context usage after async operations checks `context.mounted` first
- Returns early if widget is no longer mounted
- Prevents "use context after dispose" errors

---

## Testing Checklist

### Functional Tests
- [ ] Search tab tap from /settings → API call → /search navigation
- [ ] Account tab tap from /search → filters cleared → /settings navigation
- [ ] Search tab tap when already on /search → no action
- [ ] Account tab tap when already on /settings → no action
- [ ] Location permission granted → real coordinates sent
- [ ] Location permission denied → LatLng(0, 0) fallback
- [ ] API call fails → silent failure, no crash

### Visual Tests
- [ ] Active tab has accent color (orange)
- [ ] Inactive tab has textPrimary color (dark gray)
- [ ] Icon and label properly aligned (4px gap)
- [ ] NavBar height is 70.0
- [ ] Safe area respected (no overlap with system UI)

### Translation Tests
- [ ] Change language → tab labels update
- [ ] All 7 languages render correctly

---

## Known Gotchas

1. **Language code must be captured BEFORE async operations**
   ```dart
   // ✅ CORRECT: Get languageCode before await
   final languageCode = Localizations.localeOf(context).languageCode;
   final position = await _getUserLocation();

   // ❌ WRONG: Get languageCode after await (BuildContext across async gap)
   final position = await _getUserLocation();
   final languageCode = Localizations.localeOf(context).languageCode;
   ```

2. **updateSearchResults uses positional arguments, not named**
   ```dart
   // ✅ CORRECT
   ref.read(searchStateProvider.notifier).updateSearchResults(
     jsonBody,
     resultCount,
   );

   // ❌ WRONG
   ref.read(searchStateProvider.notifier).updateSearchResults(
     results: jsonBody,
     count: resultCount,
   );
   ```

3. **Always use const for kDefaultCityId**
   ```dart
   // ✅ CORRECT
   cityId: AppConstants.kDefaultCityId.toString()

   // ❌ WRONG (hardcoded)
   cityId: '17'
   ```

4. **Navigation requires context.mounted check**
   ```dart
   // ✅ CORRECT
   if (!context.mounted) return;
   // ignore: use_build_context_synchronously
   context.go('/search');

   // ❌ WRONG (no mounted check)
   context.go('/search');
   ```

5. **Geolocator uses new LocationSettings API**
   ```dart
   // ✅ CORRECT (Flutter 3.x)
   await Geolocator.getCurrentPosition(
     locationSettings: LocationSettings(
       accuracy: LocationAccuracy.medium,
       timeLimit: Duration(seconds: 5),
     ),
   );

   // ❌ DEPRECATED (old API)
   await Geolocator.getCurrentPosition(
     desiredAccuracy: LocationAccuracy.medium,
     timeLimit: Duration(seconds: 5),
   );
   ```

---

## FlutterFlow Source Reference

### Original Files
- `_flutterflow_export/lib/widgets/nav_bar/nav_bar_widget.dart` (249 lines)
- `_flutterflow_export/lib/widgets/nav_bar/nav_bar_model.dart` (model file)

### Migration Changes
1. **FFAppState → Riverpod**
   - `FFAppState().searchResults` → `searchStateProvider.updateSearchResults()`
   - `FFAppState().filtersUsedForSearch` → `searchStateProvider.clearFilters()`

2. **Navigation**
   - `context.goNamed(SearchResultsWidget.routeName)` → `context.go('/search')`
   - `context.goNamed(SettingsWidget.routeName)` → `context.go('/settings')`

3. **Location**
   - Updated from deprecated geolocator API to new LocationSettings API

4. **Analytics**
   - Removed markUserEngaged() calls (method doesn't exist in current analyticsProvider)

---

## Phase 7 Integration

### Progress After This Widget
- **Total widgets:** 29
- **Completed:** 15 (including this widget)
- **Remaining:** 14

### Dependencies for Page Implementation
This widget is used by:
- Task 7.2: Search Results page (Search tab active)
- Task 7.7-7.12: All Settings pages (Account tab active)

---

## Maintenance Notes

### If Search API Changes
1. Update API call in `_onSearchTabTap()` method
2. Update response parsing logic
3. Test location fallback still works

### If New Navigation Tabs Added
1. Add new tab parameters to constructor
2. Add new tab buttons to Row in build()
3. Add new handler methods (like `_onNewTabTap()`)
4. Update active tab logic

### If Provider Structure Changes
1. Check searchStateProvider method signatures
2. Update provider calls in both tap handlers
3. Test navigation still works with new state structure

---

**End of MASTER_README**
