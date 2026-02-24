# Search Results Page Bundle

## Purpose

The main search page where users discover restaurants. Displays filterable search results with real-time updates, location-based sorting, and comprehensive business information cards. Primary user task: Find restaurants that match their dietary needs, preferences, and location.

---

## Dependencies

### Actions

- **checkLocationPermission** - Check location permission status on page load (accepts page identifier string param) → `../../shared/actions/MASTER_README_check_location_permission.md`
- **requestLocationPermission** - Request location access if not granted (accepts page identifier string param) → `../../shared/actions/MASTER_README_request_location_permission.md`
- **markUserEngaged** - Track user engagement events (search bar focus, button taps) → `../../shared/actions/MASTER_README_mark_user_engaged.md`
- **trackAnalyticsEvent** - Track page view and session analytics on page dispose → `../../shared/actions/MASTER_README_track_analytics_event.md`
- **performSearchAndUpdateState** - Execute search with state update on search bar submit → `../../shared/actions/MASTER_README_perform_search_and_update_state.md`
- **performSearchBarUpdateState** - Update search results on search bar text change (debounced) → `../../shared/actions/MASTER_README_perform_search_bar_update_state.md`
- **checkAndResetFilterSession** - Manage filter session lifecycle on page load → `../../shared/actions/MASTER_README_check_and_reset_filter_session.md`
- **generateAndStoreFilterSessionId** - Create filter session ID on first filter interaction → `../../shared/actions/MASTER_README_generate_and_store_filter_session_id.md`
- **updatePreviousFilterState** - Track filter state changes on filter apply → `../../shared/actions/MASTER_README_update_previous_filter_state.md`
- **trackFilterReset** - Track filter clear events when "Ryd alle" button tapped → `../../shared/actions/MASTER_README_track_filter_reset.md`

### Widgets

- **SearchResultsListView** - Main results list with infinite scroll and business cards → `../../shared/widgets/MASTER_README_search_results_list_view.md`
- **FilterOverlayWidget** - Three-tab filter overlay sheet (Location, Type, Behov) → `../../shared/widgets/MASTER_README_filter_overlay_widget.md`
- **FilterTitlesRow** - Filter category title buttons with badges → `../../shared/widgets/MASTER_README_filter_titles_row.md`
- **SelectedFiltersBtns** - Selected filter chips row with "Ryd alle" button → `../../shared/widgets/MASTER_README_selected_filters_btns.md`
- **NavBarWidget** - Bottom navigation bar (3 tabs: Search, Account, Home) → `../../shared/widgets/MASTER_README_nav_bar.md`
- **UnifiedFiltersWidget** - Unified filter interface (used within FilterOverlayWidget) → `../../shared/widgets/MASTER_README_unified_filters_widget.md`
- **RestaurantListShimmerWidget** - Loading skeleton for list view → `../../shared/widgets/MASTER_README_restaurant_list_shimmer_widget.md`
- **RestaurantShimmerWidget** - Loading skeleton for single card → `../../shared/widgets/MASTER_README_restaurant_shimmer_widget.md`

### Functions

**NOTE:** Only one function is called directly by the search page. All others are called by custom widgets/actions.

- **getSessionDurationSeconds** - Calculate session duration for analytics (pageStartTime → dispose) → `../../shared/functions/MASTER_README_get_session_duration_seconds.md`

**Functions Called by Custom Widgets (not directly by page):**
- **getFilterTitles** - Get localized filter titles (FilterTitlesRow widget) → `../../shared/functions/MASTER_README_get_filter_titles.md`
- **generateFilterSummary** - Generate filter summary (custom actions) → `../../shared/functions/MASTER_README_generate_filter_summary.md`
- **returnDistance** - Calculate distance (SearchResultsListView widget) → `../../shared/functions/MASTER_README_return_distance.md`
- **streetAndNeighbourhoodLength** - Format address (SearchResultsListView widget) → `../../shared/functions/MASTER_README_street_and_neighbourhood_length.md`
- **openClosesAt** - Status text (SearchResultsListView widget) → `../../shared/functions/MASTER_README_open_closes_at.md`
- **hasLocationPermission** - Check permissions (custom actions) → `../../shared/functions/MASTER_README_has_location_permission.md`
- **getTranslations** - Get localized text (custom widgets) → `../../shared/functions/MASTER_README_get_translations.md`

### FFAppState Variables

**Primary Variables:**
- **CityID** - City ID for search (e.g., 17 for Copenhagen) - persistent
- **searchResults** - Cached search results (dynamic JSON) - session
- **searchResultsCount** - Total results count - session
- **locationStatus** - Location permission granted (bool) - session
- **filtersUsedForSearch** - Array of selected filter IDs - session
- **filterOverlayOpen** - Filter overlay sheet open state - session
- **activeSelectedTitleId** - Active filter tab ID (Location/Type/Behov) - session
- **filtersForUserLanguage** - Filter data structure for current language - session
- **filterLookupMap** - Map of filter IDs to filter metadata (for train station detection) - session
- **translationsCache** - Translation cache for dynamic content - persistent
- **sessionStartTime** - App session start timestamp - session
- **currentFilterSessionId** - Filter session tracking ID - session
- **currentSearchText** - Current search query text - session

**Analytics & Tracking:**
- **previousActiveFilters** - Previous filter state for analytics comparison - session
- **previousSearchText** - Previous search text for analytics comparison - session
- **currentRefinementSequence** - Refinement sequence counter for analytics - session
- **lastRefinementTime** - Last refinement timestamp for analytics - session

**Display & Formatting:**
- **fontScale** - Accessibility font scaling - persistent
- **exchangeRate** - Currency exchange rate - persistent
- **userCurrencyCode** - User's currency ('DKK', 'EUR') - persistent
- **BusinessIsOpen** - Business open/closed status (used by list item widget) - session

**Navigation State:**
- **openingHours** - Business hours stored when navigating to profile - session
- **filtersOfSelectedBusiness** - Stored when navigating to business profile - session

### BuildShip Endpoints

- **SearchCall** - Main search API
  - **Method:** POST (page load) / GET (search bar)
  - **Called:**
    - Page load: if `FFAppState().searchResults == null`
    - Search bar text change: debounced 200ms (via `performSearchBarUpdateState`)
    - Search bar submit: immediate (via `performSearchBarUpdateState`)
  - **Parameters:**
    - `cityId`: `FFAppState().CityID.toString()`
    - `searchInput`: empty string on page load, user query on search
    - `userLocation`: `currentUserLocationValue.toString()`
    - `languageCode`: `FFLocalizations.of(context).languageCode`
  - **Response:** `{ documents: [ { business_id, business_name, profile_picture_url, latitude, longitude, street, neighbourhood_name, price_range_min, price_range_max, business_type, business_hours, filters } ] }`
  - **Storage:** `FFAppState().searchResults = apiResult.jsonBody`
  - **Note:** Initial page load uses empty `searchInput` to fetch all results

---

## Navigation

### From
- **App Launch** - Default landing page (if onboarding complete)
- **Bottom Nav "Search" tab** - From any page with bottom nav
- **Back from Business Profile** - Returns to search results (cached state preserved)
- **Welcome/Onboarding** - After completing first-time setup

### To
- **Business Profile** (`BusinessProfileWidget`) - Tap business card "Se mere →" button
  - Path parameters: `businessId` (int), `businessName` (String)
  - State stored: `openingHours`, `filtersOfSelectedBusiness`
- **Settings** (`AccountWidget`) - Bottom nav "Account" tab
- **User Profile** (`ProfileWidget`) - Bottom nav "Home" tab

---

## Design Reference

- **FlutterFlow:** `_flutterflow_export/lib/search/search_results/search_results_widget.dart`
- **FlutterFlow Model:** `_flutterflow_export/lib/search/search_results/search_results_model.dart`
- **JSX Design:** `pages/01_search_results/DESIGN_README_search.md`
- **Audit:** `pages/01_search_results/PAGE_README.md`
- **Screenshots:** `FF-pages-images/search_page/`

---

## Additional Notes

### Translation Keys (kTranslationsMap)
- `'05aeogb1'` - "Copenhagen" / "København"
- `'xn0d16r3'` - "Search" / "Søg"
- Dynamic translations via `translationsCache` for filter names, dietary preferences, allergen names

### Lifecycle Events
- **initState:** Location permission check → fetch search results (if no cache) → setup keyboard listener → setup search bar focus listener
- **dispose:** Track page_viewed analytics event with session duration

### State Preservation
- Search results cached in FFAppState (persist across navigation)
- Filter selections persist in `filtersUsedForSearch`
- Scroll position NOT preserved (resets to top on return)

### Performance Optimizations
1. Result caching - avoids re-fetching on page revisit
2. Debounced search (200ms) - prevents excessive API calls
3. FFAppState listener pattern - only rebuilds when searchResults changes
4. Non-blocking analytics - uses `unawaited()` to avoid blocking UI
5. Lazy loading - ListView.separated builds cards on-demand

### Analytics Events Tracked
- `page_viewed` - Page dispose (every exit) with duration
- `business_clicked` - Business card tap with position, filterSessionId, timeOnList
- `search_performed` - Search bar submit with query, resultsCount, filters
- `filter_applied` - Filter selection with type, value, sessionId
- `filter_reset` - Clear all filters with sessionId, duration, count

---

## Documentation Verification

**Verified Against:** FlutterFlow source code (`_flutterflow_export/lib/search/search_results/search_results_widget.dart`)
**Verification Date:** 2026-02-19

### Corrections Made

1. **Custom Actions:** Added parameter documentation (page identifier string)
2. **Custom Functions:** Clarified which are called directly by page vs by widgets
3. **FFAppState Variables:** Added 10 missing variables (filterLookupMap, BusinessIsOpen, analytics tracking vars)
4. **API Call:** Documented empty searchInput on page load, corrected debounce timing (200ms not 500ms)
5. **Custom Widgets:** Clarified widget usage hierarchy (which widgets call which)

### Verification Results
✅ All custom actions referenced in source are documented
✅ All custom widgets used in source are documented
✅ All FFAppState variables accessed in source are documented
✅ API call parameters match source code
✅ Debounce timing corrected (200ms)
✅ Widget/function call hierarchy clarified

---

**Last Updated:** 2026-02-19
**Status:** ✅ Production Ready - Verified Against Source
**Phase:** Phase 2 - Documentation Complete & Verified

---

## Riverpod State

> Cross-reference: `_reference/MASTER_STATE_MAP.md`

### Reads
| Provider | Field | Used for |
|----------|-------|----------|
| `ref.watch(searchStateProvider)` | `searchResults` | Restaurant list rendered by SearchResultsListView |
| `ref.watch(searchStateProvider)` | `searchResultsCount` | Result count display + NavBarWidget badge |
| `ref.watch(searchStateProvider)` | `hasActiveSearch` | Controls "clear search" button visibility |
| `ref.watch(searchStateProvider)` | `currentSearchText` | Search bar text value |
| `ref.watch(searchStateProvider)` | `filtersUsedForSearch` | Active filter chip display + search params |
| `ref.watch(searchStateProvider)` | `currentFilterSessionId` | Analytics filter session tracking |
| `ref.watch(searchStateProvider)` | `previousActiveFilters` | Filter reset detection (checkAndResetFilterSession) |
| `ref.watch(searchStateProvider)` | `previousSearchText` | Filter reset detection |
| `ref.watch(searchStateProvider)` | `previousFilterSessionId` | Filter session analytics |
| `ref.watch(searchStateProvider)` | `currentRefinementSequence` | Filter refinement analytics |
| `ref.watch(searchStateProvider)` | `lastRefinementTime` | Filter refinement analytics |
| `ref.watch(translationsCacheProvider)` | `translationsCache` | All translated text on this page |
| `ref.watch(locationProvider)` | `hasPermission` | Distance sorting enabled/disabled; location banner |
| `ref.watch(filterProvider)` | `filtersForLanguage` | Filter tree passed to FilterOverlayWidget |
| `ref.watch(filterProvider)` | `filterLookupMap` | Fast filter lookup in performSearchBarUpdateState |
| `ref.watch(filterProvider)` | `foodDrinkTypes` | Food/drink dietary type filters |
| `ref.watch(analyticsProvider)` | `sessionStartTime` | Session duration calculation on dispose |
| `ref.watch(accessibilityProvider)` | `fontScaleLarge` | Filter panel height: 385px (true) or 350px (false) |
| `ref.watch(accessibilityProvider)` | `isBoldTextEnabled` | All text rendered one weight heavier |

### Writes
| Provider | Notifier method | Trigger |
|----------|----------------|---------|
| `ref.read(searchStateProvider.notifier).updateResults(...)` | `updateResults` | SEARCH API response received |
| `ref.read(searchStateProvider.notifier).setFilters(...)` | `setFilters` | User toggles filter chip in FilterOverlayWidget |
| `ref.read(searchStateProvider.notifier).setSearchText(...)` | `setSearchText` | User types in search bar |
| `ref.read(searchStateProvider.notifier).resetFilterSession(...)` | `resetFilterSession` | checkAndResetFilterSession detects session change |
| `ref.read(locationProvider.notifier).setPermission(...)` | `setPermission` | checkLocationPermission result on page load |
| `ref.read(analyticsProvider.notifier).setSessionStartTime(...)` | `setSessionStartTime` | SearchResultsListView initState |
| `ref.read(filterProvider.notifier).setFilters(...)` | `setFilters` | getFiltersWithUpdate on language change |
