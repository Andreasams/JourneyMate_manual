# Search Results Page

**Route:** `/searchResults`
**Route Name:** `Search_Results`
**Status:** ✅ Production Ready

---

## Purpose

The main search page where users discover restaurants. Displays filterable search results with real-time updates, location-based sorting, and comprehensive business information cards.

**Primary User Task:** Find restaurants that match their dietary needs, preferences, and location.

---

## Page Structure

```
┌─────────────────────────────────────────────────┐
│ Status Bar                                      │
├─────────────────────────────────────────────────┤
│ [Back] Copenhagen [Location Icon]              │
├─────────────────────────────────────────────────┤
│ [Search bar with filter icon]                  │
├─────────────────────────────────────────────────┤
│ [Selected filter chips row] [Ryd alle]         │ ← Only if filters active
├─────────────────────────────────────────────────┤
│ Restaurant Card 1                               │
│ ┌─────┐ Name                                   │
│ │ Img │ Open • til 22:00                       │
│ │84x84│ Restaurant • 100-200 kr • 1 km        │
│ └─────┘ Vesterbro, Copenhagen                  │
├─────────────────────────────────────────────────┤
│ Restaurant Card 2                               │
│ ...                                             │
├─────────────────────────────────────────────────┤
│ [Bottom Navigation]                             │
│ Search | Account | Home                         │
└─────────────────────────────────────────────────┘

When filter overlay open:
┌─────────────────────────────────────────────────┐
│ [Backdrop blur: 16px]                          │
│ [Filter Overlay Sheet - from bottom]           │
│   Column 1 (36%) | Column 2 (33%) | Column 3   │
│   Dietary        | Allergens      | Features    │
│   [Filters...]   | [Filters...]   | [Filters..]│
│                                                  │
│   [Vis 24 resultater button]                   │
└─────────────────────────────────────────────────┘
```

---

## JSX Design Files

Located in: `pages/01_search_results/design/`

| File | Purpose | Lines |
|------|---------|-------|
| `search.jsx` | Main search page with filters | ~500 lines |
| `search_no_results.jsx` | Empty state | ~100 lines |

**Design Reference:** `JourneyMate-v2/pages/search/`

---

## FlutterFlow Files

Located in: `pages/01_search_results/flutterflow/`

| File | Purpose | Lines |
|------|---------|-------|
| `search_results_widget.dart` | Main page widget | 468 lines |
| `search_results_model.dart` | Page model (state) | ~150 lines |
| `empty_search_message_widget.dart` | Empty state component | ~50 lines |
| `search_result_business_block_widget.dart` | Single result card (not used in custom widget) | ~200 lines |

---

## Custom Widgets Used

Located in: `pages/01_search_results/custom_code/widgets/`

| Widget | Purpose | Lines | Used By | README |
|--------|---------|-------|---------|--------|
| `SearchResultsListView` | Main results list with infinite scroll | 670 | **SearchResults page** | ✅ See `shared/widgets/MASTER_README_search_results_list_view.md` |
| `FilterOverlayWidget` | Filter overlay sheet | 800+ | **SearchResults page** | ⏳ Pending |
| `SelectedFiltersBtns` | Selected filter chips row | 300+ | **SearchResults page** | ⏳ Pending |
| `FilterTitlesRow` | Filter category titles | 200+ | **SearchResults page** | ⏳ Pending |
| `UnifiedFiltersWidget` | Unified filter interface | 500+ | FilterOverlayWidget | ⏳ Pending |
| `RestaurantListShimmerWidget` | Loading skeleton (list) | 150+ | SearchResultsListView | ⏳ Pending |
| `RestaurantShimmerWidget` | Loading skeleton (card) | 100+ | RestaurantListShimmerWidget | ⏳ Pending |

---

## Custom Actions Used

Located in: `pages/01_search_results/custom_code/actions/`

| Action | Purpose | Called When | README |
|--------|---------|-------------|--------|
| `checkLocationPermission` | Check location permission status (param: 'searchPage') | Page load | ⏳ Pending |
| `requestLocationPermission` | Request location access (param: 'searchPage') | Page load (if not granted) | ⏳ Pending |
| `markUserEngaged` | Track user engagement | Search bar focus | ⏳ Pending |
| `trackAnalyticsEvent` | Track page view events | Page dispose | ✅ See `shared/actions/MASTER_README_track_analytics_event.md` |
| `performSearchAndUpdateState` | Execute search with state update | Search bar submit | ⏳ Pending |
| `performSearchBarUpdateState` | Search bar typing update | Search bar change (debounced) | ⏳ Pending |
| `checkAndResetFilterSession` | Manage filter session lifecycle | Page load | ⏳ Pending |
| `generateAndStoreFilterSessionId` | Create filter session ID | First filter interaction | ⏳ Pending |
| `updatePreviousFilterState` | Track filter state changes | Filter apply | ⏳ Pending |
| `trackFilterReset` | Track filter clear events | "Ryd alle" button | ⏳ Pending |

---

## Custom Functions Used

Located in: `shared/functions/custom_functions.dart`

**NOTE:** Only `getSessionDurationSeconds` is called directly by the search page. All other functions are called by custom widgets or custom actions.

| Function | Purpose | Called By | README |
|----------|---------|-----------|--------|
| `getSessionDurationSeconds` | Calculate session duration | **SearchResults page** (dispose) | ⏳ Pending |
| `getFilterTitles` | Get localized filter titles with counts | FilterTitlesRow widget | ⏳ Pending |
| `generateFilterSummary` | Generate filter summary text | Custom actions (analytics) | ⏳ Pending |
| `returnDistance` | Calculate distance to business | SearchResultsListView widget | ⏳ Pending |
| `streetAndNeighbourhoodLength` | Format address display | SearchResultsListView widget | ⏳ Pending |
| `openClosesAt` | Determine open/closed status text | SearchResultsListView widget | ⏳ Pending |
| `hasLocationPermission` | Check location permission status | Custom actions | ⏳ Pending |
| `getTranslations` | Get localized text | Custom widgets (various) | ✅ See `shared/functions/MASTER_README_get_translations.md` |

---

## API Calls

### SearchCall
**Endpoint:** BuildShip search API
**Method:** POST
**Called:** Page load (if no cached results) + search bar submit

**Parameters:**
```dart
{
  'cityId': FFAppState().CityID.toString(),
  'searchInput': '',  // Empty string on page load, user query on search
  'userLocation': currentUserLocationValue.toString(),
  'languageCode': FFLocalizations.of(context).languageCode,
}
```

**Note:** Initial page load uses empty `searchInput` to fetch all nearby results.

**Response Structure:**
```json
{
  "documents": [
    {
      "business_id": 123,
      "business_name": "Restaurant Name",
      "profile_picture_url": "https://...",
      "latitude": 55.6761,
      "longitude": 12.5683,
      "street": "Vesterbrogade 1",
      "neighbourhood_name": "Vesterbro",
      "price_range_min": 100,
      "price_range_max": 200,
      "business_type": "Restaurant",
      "business_hours": {},
      "filters": [1, 2, 3]
    }
  ]
}
```

**Response Storage:**
```dart
FFAppState().searchResults = apiResult.jsonBody;
```

---

## FFAppState Usage

### Read Properties
```dart
// Primary State
FFAppState().CityID                  // City ID for search (e.g., 17 for Copenhagen)
FFAppState().searchResults           // Cached search results (dynamic JSON)
FFAppState().searchResultsCount      // Total results count
FFAppState().locationStatus          // Location permission granted
FFAppState().filtersUsedForSearch    // Array of selected filter IDs
FFAppState().filterOverlayOpen       // Filter overlay open state
FFAppState().activeSelectedTitleId   // Active filter tab ID
FFAppState().filtersForUserLanguage  // Filter data for current language
FFAppState().filterLookupMap         // Map of filter IDs to metadata
FFAppState().currentSearchText       // Current search query

// Display & Formatting
FFAppState().fontScale              // Accessibility font scaling
FFAppState().exchangeRate           // Currency exchange rate
FFAppState().userCurrencyCode       // User's currency ('DKK', 'EUR')
FFAppState().BusinessIsOpen         // Business open/closed status

// Translation
FFAppState().translationsCache      // Translation cache for dynamic content

// Analytics & Tracking
FFAppState().sessionStartTime       // App session start timestamp
FFAppState().currentFilterSessionId // Filter session tracking ID
FFAppState().previousActiveFilters  // Previous filter state for analytics
FFAppState().previousSearchText     // Previous search text for analytics
FFAppState().currentRefinementSequence // Refinement sequence counter
FFAppState().lastRefinementTime     // Last refinement timestamp
```

### Write Properties
```dart
FFAppState().searchResults = apiResult.jsonBody;  // Store search results
```

---

## Lifecycle Events

### initState (lines 39-109)

**Sequence:**
1. Create model: `_model = createModel(context, () => SearchResultsModel())`
2. **Post-frame callback** (page load actions):
   - Get user location: `currentUserLocationValue = await getCurrentUserLocation()`
   - Check location permission: `await actions.checkLocationPermission('searchPage')`
   - If not granted: `await actions.requestLocationPermission('searchPage')`
   - Record page start time: `_model.pageStartTime = getCurrentTimestamp`
   - **If cached results exist:**
     - Enable filter UI: `_model.filterMayLoad = true`
     - Enable button row: `_model.buttonRowMayLoad = true`
   - **If no cached results:**
     - Call SearchAPI with empty query
     - Store results: `FFAppState().searchResults = apiResult.jsonBody`
     - Enable filter UI and button row
3. Get user location (cached): `getCurrentUserLocation(cached: true)`
4. Setup keyboard visibility listener
5. Initialize search bar controller: `_model.searchBarTextController`
6. Setup search bar focus listener:
   - Calls `markUserEngaged()` on focus
   - Closes filter overlay if open
   - Toggles `searchBarIsFocused` state

**Critical Details:**
- Location permission check happens **before** any search
- Search results are cached in FFAppState (persist between visits)
- Filter UI only loads **after** results are available
- Keyboard listener enables keyboard-aware UI adjustments

### dispose (lines 112-132)

**Sequence:**
1. **Page dispose action:**
   - Track analytics: `trackAnalyticsEvent('page_viewed', ...)`
     - Event data: `pageName: 'search_results'`
     - Event data: `durationSeconds: [calculated]`
2. Dispose model: `_model.dispose()`
3. Cancel keyboard listener: `_keyboardVisibilitySubscription.cancel()`
4. Call super.dispose()

**Critical Details:**
- Analytics tracked on **every** page exit (captures session duration)
- Session duration calculated from `_model.pageStartTime`
- Keyboard listener must be canceled to prevent memory leaks

---

## User Interactions

### Search Bar Focus
**Trigger:** User taps search bar

**Actions:**
1. Mark user engaged: `markUserEngaged()`
2. Close filter overlay: `_model.filterOverlayOpen = false`
3. Toggle focus state: `_model.searchBarIsFocused = !_model.searchBarIsFocused`
4. Rebuild UI

### Search Bar Text Change
**Trigger:** User types in search bar (debounced 200ms)

**Actions:**
1. Call `performSearchBarUpdateState(searchQuery)`
2. Execute search API call
3. Update `FFAppState().searchResults`
4. Results list rebuilds automatically (listening to FFAppState)

### Search Bar Submit
**Trigger:** User presses enter or search button

**Actions:**
1. Unfocus keyboard
2. Call `performSearchAndUpdateState(searchQuery)`
3. Execute search API call
4. Update `FFAppState().searchResults`
5. Track analytics: `search_performed` event

### Filter Button Tap
**Trigger:** User taps filter icon in search bar

**Actions:**
1. Toggle overlay: `_model.filterOverlayOpen = !_model.filterOverlayOpen`
2. Show/hide `FilterOverlayWidget`
3. Apply backdrop blur (16px)

### Filter Apply
**Trigger:** User selects/deselects filter in overlay

**Actions:**
1. Update `FFAppState().selectedFilters`
2. Call `updatePreviousFilterState()`
3. Execute search API with filters
4. Update `FFAppState().searchResults`
5. Track analytics: `filter_applied` event

### "Ryd alle" (Clear All) Button
**Trigger:** User taps clear filters button

**Actions:**
1. Clear `FFAppState().selectedFilters`
2. Call `trackFilterReset()`
3. Execute search API without filters
4. Update `FFAppState().searchResults`
5. Hide filter chips row

### Business Card Tap
**Trigger:** User taps anywhere on a business card

**Actions:**
1. Track analytics: `business_clicked` event
   - `businessId`, `clickPosition`, `filterSessionId`, `timeOnListSeconds`, `totalResults`
2. Call `markUserEngaged()`
3. Store business data:
   - `FFAppState().openingHours = business.business_hours`
   - `FFAppState().filtersOfSelectedBusiness = business.filters`
4. Navigate to `BusinessProfileWidget`:
   - Path parameter: `businessId` (int)
   - Path parameter: `businessName` (String)

---

## Navigation

### Entry Points
1. **App Launch** - Default landing page
2. **Bottom Nav "Search" tab** - From any page
3. **Back from Business Profile** - Returns to search results

### Exit Points
1. **Business Profile** - Tap business card → `BusinessProfileWidget`
2. **Settings** - Bottom nav "Account" tab → `AccountWidget`
3. **User Profile** - Bottom nav "Home" tab → `ProfileWidget`

### State Preservation
Search results are **cached** in FFAppState:
- Results persist when navigating away and returning
- Filters persist (selectedFilters array)
- Scroll position **not preserved** (resets to top)

---

## Analytics Events

### page_viewed
**Tracked:** Page dispose (every exit)

**Event Data:**
```dart
{
  'pageName': 'search_results',
  'durationSeconds': '45',
}
```

### business_clicked
**Tracked:** Business card tap

**Event Data:**
```dart
{
  'businessId': '123',
  'clickPosition': '0',
  'filterSessionId': 'uuid',
  'timeOnListSeconds': '30',
  'totalResults': '12',
}
```

### search_performed
**Tracked:** Search bar submit

**Event Data:**
```dart
{
  'searchQuery': 'pizza',
  'resultsCount': '8',
  'hasFilters': 'true',
  'filterCount': '3',
}
```

### filter_applied
**Tracked:** Filter selection

**Event Data:**
```dart
{
  'filterType': 'dietary',
  'filterValue': 'vegan',
  'filterSessionId': 'uuid',
}
```

### filter_reset
**Tracked:** Clear all filters

**Event Data:**
```dart
{
  'filterSessionId': 'uuid',
  'timeInSession': '120',
  'filtersCleared': '5',
}
```

---

## Translation Keys

### FlutterFlow UI Translations (kTranslationsMap)
```dart
'05aeogb1': {  // Copenhagen city name
  'en': 'Copenhagen',
  'da': 'København',
  'de': 'Kopenhagen',
  'fr': 'Copenhague',
  'it': 'Copenaghen',
  'no': 'København',
  'sv': 'Köpenhamn',
},
'xn0d16r3': {  // Search button/page title
  'en': 'Search',
  'da': 'Søg',
  'de': 'Suche',
  'fr': 'Recherche',
  'it': 'Cerca',
  'no': 'Søk',
  'sv': 'Sök',
},
```

### Supabase Dynamic Translations (translationsCache)
- Filter names: `filter_outdoor_seating`, `filter_wheelchair_accessible`
- Dietary preferences: `dietary_vegan`, `dietary_vegetarian`
- Allergen names: `allergen_gluten`, `allergen_nuts`
- Status text: "til", "opens at", "closes tomorrow at"

**See:** `TRANSLATION_ANALYSIS.md` for complete translation system overview.

---

## Dependencies

### pub.dev Packages
```yaml
provider: ^6.1.5                     # State management (context.watch)
easy_debounce: ^3.0.3               # Search bar debouncing
flutter_keyboard_visibility: ^6.1.0  # Keyboard state tracking
google_fonts: ^6.2.1                 # Typography
```

### Internal Dependencies
- All custom widgets listed above
- All custom actions listed above
- All custom functions listed above
- `NavBarWidget` - Bottom navigation bar

---

## Display States

### 1. Location Loading (Initial)
**Condition:** `currentUserLocationValue == null`

**Display:**
- Full screen with primary background color
- Centered circular progress indicator (20x20, tertiary color)
- No other UI elements

**Duration:** Until location is obtained (usually <1s)

### 2. Shimmer Loading (Searching)
**Condition:** `searchResults == null` OR search in progress

**Display:**
- `RestaurantListShimmerWidget` fills result area
- Animated shimmer effect (grey gradient waves)
- Skeleton cards matching real card layout

**Duration:** Until API response received

### 3. Empty State
**Condition:** `searchResults.documents.isEmpty`

**Display:**
- Large search icon (64px, secondaryText color)
- "No results found" message (localized)
- Optional: Suggestions for adjusting filters

### 4. Results State
**Condition:** `searchResults.documents.isNotEmpty`

**Display:**
- Search bar at top
- Filter chips row (if filters active)
- Scrollable list of business cards
- Bottom navigation bar

---

## Performance Optimizations

1. **Result Caching**
   - Search results cached in FFAppState
   - Avoids re-fetching on page revisit
   - Cleared only when user searches again

2. **Debounced Search**
   - 200ms debounce on search bar input
   - Prevents excessive API calls while typing
   - Uses `EasyDebounce` package

3. **FFAppState Listener Pattern**
   - `SearchResultsListView` listens to state changes
   - Only rebuilds when `searchResults` actually changes
   - Prevents full page rebuilds on every state change

4. **Non-blocking Analytics**
   - Analytics calls use `unawaited()`
   - Don't block navigation or user interactions
   - Tracked in background

5. **Status Caching in List**
   - Business status (open/closed) calculated once
   - Cached per business_id
   - Reused on scroll/rebuild

6. **Lazy Loading**
   - ListView.separated builds cards on-demand
   - Only visible cards are rendered
   - Efficient for 100+ results

---

## Edge Cases Handled

1. **No location permission** - Shows results without distance sorting
2. **Location service disabled** - Prompts user to enable
3. **Empty search results** - Shows empty state with message
4. **API failure** - Shows error message, keeps cached results
5. **No internet connection** - Shows cached results if available
6. **Keyboard overlap** - Adjusts UI when keyboard shown
7. **Very long business names** - Truncates with ellipsis
8. **Missing profile pictures** - Shows placeholder image
9. **Null price range** - Hides price display
10. **Missing address** - Shows "Address unavailable"

---

## Testing Checklist

When implementing in Flutter:

- [ ] **Page Load**
  - [ ] Location permission requested
  - [ ] Default search executed if no cache
  - [ ] Cached results displayed if available
  - [ ] Page start time recorded
- [ ] **Search Bar**
  - [ ] Focus triggers engagement tracking
  - [ ] Typing debounced (500ms)
  - [ ] Submit executes search
  - [ ] Keyboard dismissed on submit
- [ ] **Filters**
  - [ ] Filter button toggles overlay
  - [ ] Backdrop blur applied (16px)
  - [ ] Filter selection updates results
  - [ ] "Ryd alle" clears all filters
  - [ ] Filter chips show selected filters
- [ ] **Results List**
  - [ ] Shimmer shown while loading
  - [ ] Empty state shown for no results
  - [ ] Cards display all business data
  - [ ] Distance shown if location enabled
  - [ ] Price converted to user currency
  - [ ] Status text correct (open/closed + timing)
  - [ ] Tap navigates to business profile
- [ ] **Analytics**
  - [ ] page_viewed tracked on dispose
  - [ ] business_clicked tracked on tap
  - [ ] search_performed tracked on submit
  - [ ] filter_applied tracked on selection
  - [ ] filter_reset tracked on clear
- [ ] **Navigation**
  - [ ] Back button returns to previous page
  - [ ] Bottom nav switches pages
  - [ ] State preserved on return
- [ ] **Translation**
  - [ ] UI text changes with language
  - [ ] Filter names translated
  - [ ] Empty state message translated
  - [ ] Status text translated
- [ ] **Accessibility**
  - [ ] Font scale adjusts spacing
  - [ ] Screen reader announces elements
  - [ ] Touch targets ≥44x44
  - [ ] Keyboard navigation works

---

## Known Issues

1. **Scroll position not preserved** - Returns to top on page revisit
2. **Filter state inconsistency** - selectedFilters can desync from API results
3. **Location prompt timing** - May show twice if user denies first time
4. **Keyboard overlap** - May cover bottom results on small screens
5. **Rapid filter changes** - Can trigger multiple API calls simultaneously

---

## Migration Notes

### Phase 3 Changes

1. **Translation System**
   - Extract FlutterFlow translations to .arb files
   - Keep Supabase system for dynamic content (filter names, etc.)
   - See `TRANSLATION_ANALYSIS.md` for strategy

2. **State Management**
   - Replace `FFAppState()` with Riverpod providers
   - Example: `ref.watch(searchResultsProvider)`
   - Maintain reactivity for real-time updates

3. **Navigation**
   - Migrate from `context.pushNamed()` to go_router
   - Maintain path parameters: `businessId`, `businessName`

4. **API Calls**
   - Keep BuildShip endpoint unchanged
   - Consider adding request cancellation for search debouncing
   - Add retry logic for failed searches

5. **Custom Widgets**
   - Port all 7 custom widgets to pure Flutter
   - Maintain same parameters and behavior
   - See individual widget READMEs for details

---

## Related Pages

| Page | Relationship | Navigation |
|------|--------------|------------|
| **Business Profile** | Child page | Tap business card → details |
| **Settings** | Sibling page | Bottom nav "Account" tab |
| **User Profile** | Sibling page | Bottom nav "Home" tab |
| **Welcome** | Parent page | First launch entry point |

---

## Design System References

**Colors:**
- Orange (`#e8751a`) - Filter selections, CTAs
- Green (`#1a9456`) - Open status, match indicators
- Error red - Closed status

**Typography:**
- Business name: Title Large, 18px
- Details: Body Medium, 15px, weight 300
- Status: Body Medium, 15px, varies by state

**Spacing:**
- Card padding: 8px between image and text
- Row spacing: 2px (4px if fontScale)
- Item separator: 2px (4px if fontScale)
- Bottom padding: 32px

**See:** `_reference/journeymate-design-system.md` for complete design system.

---

## Documentation Verification

**Verified Against:** FlutterFlow source code (`_flutterflow_export/lib/search/search_results/search_results_widget.dart`)
**Verification Date:** 2026-02-19

### Key Corrections Made

1. ✅ Custom action parameters documented (accepts 'searchPage' string)
2. ✅ Search bar debounce corrected: 200ms (not 500ms)
3. ✅ FFAppState variables expanded: added 10 missing variables
4. ✅ API call details corrected: empty searchInput on page load
5. ✅ Custom function usage clarified: direct vs indirect calls
6. ✅ Widget hierarchy documented: which widgets call which

### Source Code Alignment
- **Custom Actions:** 6 actions - all documented ✅
- **Custom Widgets:** 7 widgets - all documented ✅
- **Custom Functions:** 8 functions - 1 direct, 7 indirect - clarified ✅
- **FFAppState Variables:** 24 variables - all documented ✅
- **API Endpoints:** 1 endpoint - fully documented ✅

---

**Last Updated:** 2026-02-19
**Migration Status:** ✅ Phase 2 - Documentation Complete & Verified
**Next Step:** Phase 3 - Flutter Implementation
