# SearchResultsListView Widget

**Type:** Custom Widget
**File:** `search_results_list_view.dart` (670 lines)
**Category:** Search & Display
**Status:** ✅ Production Ready

---

## Purpose

A performant ListView widget that displays search results for businesses. Encapsulates all list rendering, item display, tap handling, analytics, and navigation logic. Shows shimmer loading state when data is unavailable.

**Key Feature:** Explicitly listens to FFAppState changes and rebuilds when `searchResults` updates, ensuring real-time updates from search bar input.

---

## Parameters

```dart
SearchResultsListView({
  super.key,
  this.width,              // Optional container width (default: double.infinity)
  this.height,             // Optional container height
  required this.userLocation,  // User's LatLng for distance calculations
})
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `width` | `double?` | No | Container width (defaults to full width) |
| `height` | `double?` | No | Container height (defaults to content height) |
| `userLocation` | `LatLng` | **Yes** | User's location for distance calculations |

---

## Dependencies

### pub.dev Packages
- `provider: ^6.1.5` - FFAppState listening and context.watch
- None (uses only FlutterFlow built-in dependencies)

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
- `markUserEngaged()` - Tracks user engagement on business tap
- `trackAnalyticsEvent()` - Tracks business click with position, filters, timing
- `determineStatusAndColor()` - Calculates business open/closed status

### Custom Functions Used
- `getSessionDurationSeconds(sessionStartTime)` - Calculates time on search results
- `openClosesAt(openingHours, currentDateTime, languageCode, translationsCache)` - Gets timing text
- `returnDistance(userLocation, businessLat, businessLng, languageCode)` - Calculates distance
- `streetAndNeighbourhoodLength(neighbourhood, street)` - Formats address display
- `convertAndFormatPriceRange(min, max, baseCurrency, exchangeRate, targetCurrency)` - Formats price

### Custom Widgets Used
- `RestaurantListShimmerWidget` - Loading skeleton displayed before data loads

---

## FFAppState Usage

### Read Properties
```dart
FFAppState().searchResults          // Main data source (dynamic JSON)
FFAppState().searchResultsCount     // Total results count for analytics
FFAppState().fontScale              // Adjusts spacing for accessibility
FFAppState().locationStatus         // Whether location is enabled
FFAppState().exchangeRate           // For price conversion
FFAppState().userCurrencyCode       // User's selected currency
FFAppState().translationsCache      // Translation cache for dynamic content
FFAppState().sessionStartTime       // For session duration tracking
FFAppState().currentFilterSessionId // Filter session tracking
FFAppState().BusinessIsOpen         // Current business open/closed status
```

### Write Properties
```dart
FFAppState().openingHours = openingHours;              // Store for next page
FFAppState().filtersOfSelectedBusiness = filters;      // Store business filters
```

### State Listening
The widget **explicitly listens** to FFAppState changes:
```dart
void _setupAppStateListener() {
  _appStateListener = () {
    if (FFAppState().searchResults != _lastSearchResults) {
      setState(() {}); // Rebuild when search results change
    }
  };
  FFAppState().addListener(_appStateListener!);
}
```

---

## Lifecycle Events

### initState (lines 75-79)
```dart
@override
void initState() {
  super.initState();
  _lastSearchResults = FFAppState().searchResults;
  _setupAppStateListener();
}
```

**Actions:**
- Captures initial search results
- Sets up FFAppState listener for real-time updates

### dispose (lines 82-85)
```dart
@override
void dispose() {
  _removeAppStateListener();
  super.dispose();
}
```

**Actions:**
- Removes FFAppState listener to prevent memory leaks

---

## User Interactions

### onTap Business Card (lines 225-265)
**Trigger:** User taps anywhere on a business list item

**Actions:**
1. Validates business_id exists
2. Unfocuses text fields (keyboard dismiss)
3. Tracks `business_clicked` analytics event (non-blocking):
   - businessId
   - clickPosition (index in list)
   - filterSessionId
   - timeOnListSeconds
   - totalResults
4. Calls `markUserEngaged()` (non-blocking)
5. Stores `openingHours` and `filtersOfSelectedBusiness` in FFAppState
6. Navigates to `BusinessProfileWidget` with:
   - Path parameter: `businessId` (int)
   - Path parameter: `businessName` (String)

**Navigation:**
```dart
context.pushNamed(
  BusinessProfileWidget.routeName,
  pathParameters: {
    'businessId': serializeParam(businessId, ParamType.int),
    'businessName': serializeParam(businessName ?? 'Business', ParamType.String),
  },
);
```

---

## Display States

### 1. Loading State (Shimmer)
**Condition:** `FFAppState().searchResults == null`

**Display:** `RestaurantListShimmerWidget` (full width/height)

### 2. Empty State
**Condition:** `searchResults != null` but `documents.isEmpty`

**Display:**
- Search icon (64px, secondaryText color)
- Localized "No results found" message

### 3. Results State
**Condition:** `searchResults != null` and `documents.isNotEmpty`

**Display:** ListView with:
- Each business card
- Divider between cards (1px, secondaryText)
- Bottom padding (32px)
- Separator height: 2px (4px if fontScale enabled)

---

## Business Card Layout

Each card displays:

```
┌─────────────────────────────────────────┐
│ [Image]  Business Name                  │
│  84x84   Open • til 22:00               │
│          Restaurant • 100-200 kr • 1 km │
│          Vesterbro, Copenhagen          │
└─────────────────────────────────────────┘
```

### Card Components

1. **Profile Image** (84x84px, rounded 5px)
   - Source: `profile_picture_url` or placeholder
   - Placeholder: `https://tlqfuazpshfaozdvmcbh.supabase.co/.../placeholder.webp`

2. **Business Name** (Title Large, 18px)
   - Max lines: 1
   - Overflow: clip

3. **Status Row**
   - **Status:** "Open" (success color) / "Closed" (error color, bold)
   - **Bullet separator:** •
   - **Timing:** Dynamic from `openClosesAt()` function
     - Examples: "til 22:00", "opens at 10:00", "closes tomorrow at 02:00"

4. **Details Row** (flexible, clips overflow)
   - **Business Type:** Localized (e.g., "Restaurant")
   - **Bullet separator:** •
   - **Price Range:** Converted to user currency (e.g., "100-200 kr")
   - **Bullet separator:** •
   - **Distance:** Only if location enabled (e.g., "1 km" or "0.6 mi.")

5. **Address Row**
   - Format: `streetAndNeighbourhoodLength(neighbourhood, street)`
   - Fallback: "Address unavailable" (localized)

---

## Analytics Events

### business_clicked
**Tracked on:** Business card tap

**Event Data:**
```dart
{
  'businessId': '123',
  'clickPosition': '0',              // Index in list
  'filterSessionId': 'uuid-here',
  'timeOnListSeconds': '45',
  'totalResults': '12',
}
```

---

## Translation Keys

The widget uses **FlutterFlow UI translations** (not Supabase):

```dart
FFLocalizations.of(context).getVariableText(
  enText: 'No results found',
  daText: 'Ingen resultater fundet',
  deText: 'Keine Ergebnisse gefunden',
  itText: 'Nessun risultato trovato',
  svText: 'Inga resultat hittades',
  noText: 'Ingen resultater funnet',
  frText: 'Aucun résultat trouvé',
)
```

**Keys Used:**
- Empty state message (inline translations)
- Address unavailable fallback (inline: 'Address unavailable' / 'Adresse ikke tilgængelig')
- Status text: Uses `determineStatusAndColor()` action

---

## Data Structure

### Expected searchResults JSON Format
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
      "business_type_da": "Restaurant",
      "business_hours": { /* opening hours object */ },
      "filters": [1, 2, 3]  // Array of filter IDs
    }
  ]
}
```

---

## Cache Management

The widget maintains internal caches for performance:

### Status Text Cache
```dart
final Map<int, String?> _statusTextCache = {};
```
**Purpose:** Avoid recalculating status text on every rebuild
**Key:** `business_id`
**Value:** Cached status string (e.g., "Open", "Closed")

### Status Color Cache
```dart
final Map<int, Color?> _statusColorCache = {};
```
**Purpose:** Avoid recalculating status color on every rebuild
**Key:** `business_id`
**Value:** Cached color (success/error)

**Lifecycle:** Caches persist for widget lifetime, cleared on dispose

---

## Performance Optimizations

1. **FFAppState Listener Pattern**
   - Only rebuilds when `searchResults` actually changes
   - Prevents unnecessary rebuilds from other state changes

2. **Status Caching**
   - Status text/color calculated once per business
   - Cached values passed to list items via ValueKey

3. **Non-blocking Analytics**
   - Analytics calls use `unawaited()` - don't block navigation
   - User sees instant navigation, tracking happens in background

4. **Lazy Status Loading**
   - Status calculated in `initState` of each list item
   - Uses `WidgetsBinding.instance.addPostFrameCallback`

5. **ValueKey for List Items**
   - Each card has `ValueKey('business_$businessId')`
   - Prevents unnecessary rebuilds of unchanged items

---

## Usage Example

### In FlutterFlow Page Widget

```dart
import '/custom_code/widgets/index.dart' as custom_widgets;

// In build method:
custom_widgets.SearchResultsListView(
  width: double.infinity,
  height: MediaQuery.sizeOf(context).height * 0.7,
  userLocation: currentUserLocationValue!,
)
```

### Required Setup
1. FFAppState must have `searchResults` populated
2. User location must be available (`currentUserLocationValue`)
3. All translation caches must be initialized

---

## Edge Cases Handled

1. **Null business_id** - Skips navigation, logs error
2. **Missing profile picture** - Shows placeholder image
3. **No opening hours** - Shows only "Open"/"Closed" without timing
4. **Location disabled** - Skips distance calculation, shows other details
5. **Empty address fields** - Shows "Address unavailable" (localized)
6. **Null price range** - Skips price display
7. **JSON parsing errors** - Returns empty array, shows empty state

---

## Migration Notes

### Translation System
⚠️ **CRITICAL:** This widget uses FlutterFlow's inline `getVariableText()` pattern for UI translations. During Phase 3 migration:

1. **Extract to .arb files:**
   ```json
   // app_en.arb
   {
     "searchNoResults": "No results found",
     "addressUnavailable": "Address unavailable"
   }
   ```

2. **Update widget code:**
   ```dart
   // Before:
   FFLocalizations.of(context).getVariableText(enText: 'No results found', ...)

   // After:
   AppLocalizations.of(context)!.searchNoResults
   ```

### State Management
Currently uses `FFAppState()` singleton. Consider migrating to:
- **Riverpod providers** for reactive state
- **Notifier pattern** for search results updates

### Navigation
Currently uses FlutterFlow's `context.pushNamed()`. Migrate to:
- **go_router** with path parameters
- Maintain same parameter passing: `businessId`, `businessName`

---

## Related Elements

### Used By Pages
- **SearchResults** (`search_results_widget.dart`) - Main implementation

### Related Widgets
- `RestaurantListShimmerWidget` - Loading skeleton
- `FilterOverlayWidget` - Filter sheet (triggers search updates)
- `SearchResultBusinessBlock` - Alternative card layout (not used in custom widget)

### Related Actions
- `markUserEngaged` - User interaction tracking
- `trackAnalyticsEvent` - Event logging
- `determineStatusAndColor` - Status calculation

### Related Functions
- `getSessionDurationSeconds` - Session timing
- `openClosesAt` - Opening hours text
- `returnDistance` - Distance calculation
- `streetAndNeighbourhoodLength` - Address formatting
- `convertAndFormatPriceRange` - Price display

---

## Testing Checklist

When implementing in Flutter:

- [ ] Load empty search results - verify empty state shows
- [ ] Load populated results - verify list displays correctly
- [ ] Tap business card - verify navigation with correct parameters
- [ ] Toggle location on/off - verify distance shows/hides
- [ ] Change language - verify translations update
- [ ] Change currency - verify price range updates
- [ ] Enable fontScale - verify spacing increases
- [ ] Scroll list - verify performance is smooth
- [ ] Update search results - verify list rebuilds automatically
- [ ] Check analytics - verify business_clicked events logged
- [ ] Test with missing data fields - verify graceful fallbacks
- [ ] Test with very long business names - verify truncation

---

## Known Issues

None currently documented.

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Flutter Implementation
