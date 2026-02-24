# Search Results Page — Gap Analysis

**Date:** 2026-02-19
**FlutterFlow Version:** Current Production
**JSX Design Version:** v2.0

---

## Executive Summary

This document identifies **functional gaps** between the current FlutterFlow implementation and the JSX v2 design for the Search Results page. Design/layout differences are excluded—this focuses solely on features, data requirements, and architectural decisions.

### Gap Count
- **Category A (Buildable with Existing Data):** 2 gaps
- **Category B (Requires BuildShip API Changes):** 4 gaps
- **Category C (Translation Infrastructure):** 3 gap areas (8+ keys)
- **Category D (Known Missing Features):** 2 gaps

---

## Gap Categories Explained

**Category A: Buildable with Existing Data**
- **A1 (Frontend):** Logic in Flutter after API returns data
- **A2 (Backend):** Logic in BuildShip before returning data

**Category B:** Requires BuildShip API endpoint modifications

**Category C:** New UI strings need translation keys added to Supabase

**Category D:** Features not in either system yet (user-identified needs)

---

## CATEGORY A: Buildable with Existing Data

### Gap A.1: Match Indicators (Full/Partial/Other Places)

**Status:** 🟨 MAJOR FEATURE GAP

#### JSX v2 Design (What's Planned)
```
✓ MATCHER ALLE BEHOV              [Green section header]
  [Card with green border]
  [Card with green border]

MATCHER DELVIST                    [Orange section header]
  [Card with orange border]
  ⓘ Matcher 2/3 · Mangler: Børnestol

ANDRE STEDER                       [Grey section header]
  [Card with grey border]
```

**Features:**
- Results grouped into 3 tiers based on match quality
- Full match: Green border, section header "MATCHER ALLE BEHOV"
- Partial match: Orange border, info box showing "Matcher 2/3 · Mangler: [missing filters]"
- Other places: Grey border, section header "ANDRE STEDER"
- Match count calculation: `[...allNeeds].filter(n => r.has.includes(n)).length`
- Visual hierarchy: Green = best, Orange = partial, Grey = no match

**Source:** DESIGN_README_search.md lines 86-111, 354-369

#### FlutterFlow Current (What Exists)
- No match indicators
- No match sections
- All results displayed in flat list regardless of filter matches
- Cards have no colored borders
- No info boxes showing missing filters

#### Data Availability Check ✅
**Already available in FlutterFlow:**
- `FFAppState().filtersUsedForSearch` — Array of selected filter IDs (List<int>)
- `business.filters` — Array of filter IDs each restaurant has (from API response)
- All restaurant data in `FFAppState().searchResults`

**Calculation logic:**
```dart
// Example:
allNeeds = FFAppState().filtersUsedForSearch;  // [1, 5, 12]
restaurantFilters = business.filters;          // [1, 5, 19]

matchCount = allNeeds.where((id) => restaurantFilters.contains(id)).length;  // 2
missedNeeds = allNeeds.where((id) => !restaurantFilters.contains(id)).toList();  // [12]

if (matchCount == allNeeds.length) {
  // Full match: green border
} else if (matchCount > 0) {
  // Partial match: orange border + "Matcher 2/3 · Mangler: [filter name]"
} else {
  // No match: grey border
}
```

#### Architecture Decision: A2 (Backend/BuildShip) ✅ RECOMMENDED

**Why Backend (Not Frontend):**

1. **Business Logic Separation** ✅
   - Match calculation is core business logic
   - Should be centralized, not duplicated in app code

2. **Performance** ✅
   - Heavy computation: Comparing arrays for 100-300 restaurants
   - Server-side processing prevents UI lag
   - Mobile devices (especially lower-end) would struggle with complex array operations

3. **Pagination Support** ✅
   - **Critical UX requirement:** "Show full matches first, scroll to bottom to load partial matches, scroll to bottom again to load other places"
   - Backend can paginate each category separately
   - Frontend just loads "next page" when user scrolls to bottom

4. **Single Source of Truth** ✅
   - Match algorithm defined once in BuildShip
   - Consistent across all clients (iOS, Android, web)
   - No risk of frontend/backend logic diverging

5. **Future Flexibility** ✅
   - Add "2 filters missing" tier without app update
   - Adjust match scoring algorithm without releasing new app version
   - A/B test different match definitions

6. **Translation Lookup** ✅
   - Backend knows filter names (can include in "Mangler: [name]" text)
   - Frontend doesn't need to resolve filter IDs to names

#### BuildShip API Changes Needed

**Current SearchCall:**
```dart
POST https://wvb8ww.buildship.run/search

Input:
{
  "cityId": "17",
  "searchInput": "pizza",
  "userLocation": "55.6761,12.5683",
  "languageCode": "da"
}

Output:
{
  "documents": [
    {
      "business_id": 123,
      "business_name": "Restaurant Name",
      "filters": [1, 5, 12],
      ...
    }
  ]
}
```

**Proposed Enhancement:**
```dart
POST https://wvb8ww.buildship.run/search

Input:
{
  "cityId": "17",
  "searchInput": "pizza",
  "userLocation": "55.6761,12.5683",
  "languageCode": "da",
  "filtersUsedForSearch": [1, 5, 12],    // NEW: Selected filters
  "category": "full",                      // NEW: 'full' | 'partial' | 'other'
  "page": 1,                               // NEW: Pagination
  "pageSize": 20                           // NEW: Results per page
}

Output:
{
  "category": "full",                      // Which category this page belongs to
  "documents": [
    {
      "business_id": 123,
      "business_name": "Restaurant Name",
      "filters": [1, 5, 12],
      "matchCount": 3,                     // NEW: How many filters match
      "matchedFilters": [1, 5, 12],       // NEW: Which filters match
      "missedFilters": []                  // NEW: Which filters missing
    }
  ],
  "pagination": {
    "currentPage": 1,
    "totalPages": 3,
    "totalResults": 42,
    "hasMore": true,
    "nextCategory": null                   // 'partial' when full matches exhausted
  }
}
```

**Backend Logic:**
```javascript
// BuildShip pseudocode
function searchWithMatching(params) {
  const allBusinesses = await querySupabase(params.cityId, params.searchInput);
  const selectedFilters = params.filtersUsedForSearch || [];

  // Categorize
  const fullMatch = allBusinesses.filter(b => {
    const matchCount = selectedFilters.filter(f => b.filters.includes(f)).length;
    return matchCount === selectedFilters.length;
  });

  const partialMatch = allBusinesses.filter(b => {
    const matchCount = selectedFilters.filter(f => b.filters.includes(f)).length;
    return matchCount > 0 && matchCount < selectedFilters.length &&
           (selectedFilters.length - matchCount === 1);  // Only 1 filter missing
  });

  const others = allBusinesses.filter(b => {
    const matchCount = selectedFilters.filter(f => b.filters.includes(f)).length;
    const missingCount = selectedFilters.length - matchCount;
    return missingCount >= 2;  // 2+ filters missing
  });

  // Select category based on request
  let results;
  let nextCategory = null;

  if (params.category === 'full') {
    results = fullMatch;
    nextCategory = fullMatch.length === 0 ? 'partial' : null;
  } else if (params.category === 'partial') {
    results = partialMatch;
    nextCategory = partialMatch.length === 0 ? 'other' : null;
  } else {
    results = others;
  }

  // Paginate
  const start = (params.page - 1) * params.pageSize;
  const end = start + params.pageSize;
  const paginatedResults = results.slice(start, end);

  // Add match metadata to each result
  return {
    category: params.category,
    documents: paginatedResults.map(b => ({
      ...b,
      matchCount: selectedFilters.filter(f => b.filters.includes(f)).length,
      matchedFilters: selectedFilters.filter(f => b.filters.includes(f)),
      missedFilters: selectedFilters.filter(f => !b.filters.includes(f))
    })),
    pagination: {
      currentPage: params.page,
      totalPages: Math.ceil(results.length / params.pageSize),
      totalResults: results.length,
      hasMore: end < results.length,
      nextCategory: end >= results.length ? nextCategory : null
    }
  };
}
```

#### FlutterFlow Changes Needed

1. **ListView with Category Headers:**
   ```dart
   ListView.builder(
     itemCount: _getCurrentCategoryResults().length + 1,  // +1 for header
     itemBuilder: (context, index) {
       if (index == 0) {
         return CategoryHeader(
           category: _currentCategory,  // 'full', 'partial', 'other'
           color: _currentCategory == 'full' ? GREEN :
                  _currentCategory == 'partial' ? ORANGE : GREY,
         );
       }

       final business = _results[index - 1];
       return BusinessCard(
         business: business,
         borderColor: _getBorderColor(business.matchCount),
         showMatchInfo: business.matchCount > 0 && business.matchCount < _totalNeeds,
         missedFilters: business.missedFilters,
       );
     },
   );
   ```

2. **Pagination Logic:**
   ```dart
   Future<void> _loadMoreResults() async {
     if (_pagination.hasMore) {
       // Load next page of current category
       await _fetchResults(category: _currentCategory, page: _currentPage + 1);
     } else if (_pagination.nextCategory != null) {
       // Transition to next category
       _currentCategory = _pagination.nextCategory;
       await _fetchResults(category: _currentCategory, page: 1);
     }
   }
   ```

3. **Scroll Detection:**
   ```dart
   ScrollController _scrollController = ScrollController();

   @override
   void initState() {
     super.initState();
     _scrollController.addListener(() {
       if (_scrollController.position.pixels >=
           _scrollController.position.maxScrollExtent - 200) {
         _loadMoreResults();
       }
     });
   }
   ```

#### Translation Keys Needed (Category C)

**Section Headers:**
- `match_full_header`: "MATCHER ALLE BEHOV" (da), "MATCHES ALL NEEDS" (en)
- `match_partial_header`: "MATCHER DELVIST" (da), "PARTIAL MATCH" (en)
- `match_other_header`: "ANDRE STEDER" (da), "OTHER PLACES" (en)

**Match Info Text:**
- `match_info_matches`: "Matcher {count}/{total}" (da), "Matches {count}/{total}" (en)
- `match_info_missing`: "Mangler: {filters}" (da), "Missing: {filters}" (en)

#### Implementation Priority: 🔥 **HIGH**

**Reason:**
- Core value proposition: "Find what you need"
- Match indicators are the primary differentiator vs Google Maps
- Users with dietary restrictions need this to feel safe
- Without this, JourneyMate is just another restaurant list

#### Estimated Effort:
- **BuildShip work:** 2-3 days (matching logic, pagination, testing)
- **Flutter work:** 2-3 days (ListView rebuild, category headers, infinite scroll)
- **Translation work:** 1 day (add 5+ keys, test all languages)
- **Total:** 1 week

---

### Gap A.2: "Kun åbne steder" (Only Open Places) Filter

**Status:** 🟩 MINOR FEATURE GAP

#### JSX v2 Design
- Toggle in sort sheet: "Kun åbne steder" (Show only open places)
- When enabled: Closed restaurants removed from results
- Visual: Green checkmark when active

**Source:** DESIGN_README_search.md lines 331-332, 546-551

#### FlutterFlow Current
- No "only open" filter
- All restaurants shown regardless of open/closed status
- Closed restaurants rendered at opacity 0.5 (de-emphasized)

**Note from JSX design (line 892):** "Closed restaurants render at opacity: 0.5 to de-emphasize them while keeping them scannable. Users might want to see closed restaurants for future planning."

#### Data Availability Check ✅
- `business_hours` field in API response
- `openClosesAt()` function exists — calculates open/closed status

#### Architecture Decision: A1 (Frontend) or A2 (Backend)?

**A1 (Frontend) - If result set is small (<100 restaurants):**
```dart
final filteredResults = showOnlyOpen
    ? searchResults.where((b) => _isOpen(b.business_hours)).toList()
    : searchResults;
```

**A2 (Backend) - If result set is large (100-1000 restaurants):** ✅ RECOMMENDED
- Add `onlyOpen: bool` parameter to SearchCall
- BuildShip filters before returning results
- Reduces payload size
- Faster response time

**Recommendation:** **A2 (Backend)**
- Reduces data transfer (especially on slow connections)
- Consistent with match filtering approach
- Future-proof: if database grows to 10,000 restaurants, frontend filtering becomes inefficient

#### BuildShip API Changes Needed
```dart
Input:
{
  ...existing params,
  "onlyOpen": true  // NEW: Filter to open restaurants only
}
```

Backend applies time-based filter before returning results.

#### FlutterFlow Changes Needed
1. Add toggle to sort sheet (or filter overlay)
2. Pass `onlyOpen` parameter to SearchCall
3. Update UI when toggled

#### Translation Keys Needed (Category C)
- `filter_only_open`: "Kun åbne steder" (da), "Only open places" (en)

#### Implementation Priority: 🟨 **MEDIUM**

**Reason:**
- Useful feature but not critical
- Can be added post-launch
- Desktop users (planning ahead) might prefer seeing closed restaurants

#### Estimated Effort:
- **BuildShip work:** 4 hours (time-based filtering logic)
- **Flutter work:** 2 hours (toggle UI, API param)
- **Translation work:** 30 mins (1 key)
- **Total:** 1 day

---

## CATEGORY B: Requires BuildShip API Changes

### Gap B.1: Sorting Functionality

**Status:** 🟥 CRITICAL FEATURE GAP

#### JSX v2 Design (lines 1054-1060)

**Sort Options:**
1. **Bedst match** (Best match) — Sort by match count descending, then distance ascending
2. **Nærmest** (Nearest) — Sort by distance ascending
3. **Nærmest togstation** (Nearest train station) — Sort by distance to selected station
4. **Pris: Lav til høj** (Price: Low to high) — Sort by price_range_min ascending
5. **Pris: Høj til lav** (Price: High to low) — Sort by price_range_max descending
6. **Nyeste** (Newest) — Sort by date_added descending

**UI:**
- Floating orange button (bottom-right): Shows current sort ("Bedst match")
- Tap → opens sort sheet (bottom sheet, 62% height)
- Sort options listed with current selection marked (orange checkmark)

**Source:** DESIGN_README_search.md lines 539-570

#### FlutterFlow Current
- **NO sorting functionality**
- Results displayed in API response order (likely default: nearest)
- No UI for sort selection
- No sort state tracking

#### Data Availability Check

**Already available:**
- Distance: Can be calculated from `userLocation` + `business.latitude/longitude`
- Price: `price_range_min` and `price_range_max` in API response
- Match count: Will be available after Gap A.1 implemented

**NOT available:**
- **Train station proximity:** No station location data, no distance-to-station calculation
- **Date added:** `date_added` field not in API response

#### Architecture Decision: B (Backend/BuildShip) ✅ REQUIRED

**Why BuildShip must handle sorting:**

1. **Database-level sorting is efficient**
   - Supabase/PostgreSQL can sort 1000s of rows in milliseconds
   - Frontend sorting of 300 restaurants is slow

2. **Pagination depends on sort**
   - If paginating results, sorting must happen before pagination
   - Can't paginate unsorted data then sort on frontend (would get wrong pages)

3. **Match sort requires backend knowledge**
   - "Bedst match" sort needs `matchCount` calculation
   - This ties to Gap A.1 (match indicators)

4. **Train station sort requires geographic calculation**
   - BuildShip must calculate distance from restaurant to station
   - Requires station coordinates (stored in database or hardcoded)

#### BuildShip API Changes Needed

```dart
POST https://wvb8ww.buildship.run/search

Input:
{
  ...existing params,
  "sortBy": "nearest",              // NEW: Sort field
  "sortOrder": "asc",               // NEW: 'asc' | 'desc'
  "selectedStation": "København H"   // NEW: For station sort
}

// Sort options:
// - "match" (requires filtersUsedForSearch to calculate match count)
// - "nearest" (default, sort by distance from userLocation)
// - "station" (sort by distance to selectedStation)
// - "price_low" (sort by price_range_min ascending)
// - "price_high" (sort by price_range_max descending)
// - "newest" (sort by date_added descending)
```

**Backend Logic:**
```javascript
switch (params.sortBy) {
  case 'match':
    // Calculate match count for each business
    // Sort by matchCount DESC, then distance ASC (tiebreaker)
    results.sort((a, b) => {
      if (b.matchCount !== a.matchCount) return b.matchCount - a.matchCount;
      return calculateDistance(userLocation, a.coordinates) -
             calculateDistance(userLocation, b.coordinates);
    });
    break;

  case 'nearest':
    // Sort by distance from userLocation
    results.sort((a, b) =>
      calculateDistance(userLocation, a.coordinates) -
      calculateDistance(userLocation, b.coordinates)
    );
    break;

  case 'station':
    // Get station coordinates
    const stationCoords = getStationCoordinates(params.selectedStation);
    // Sort by distance from station
    results.sort((a, b) =>
      calculateDistance(stationCoords, a.coordinates) -
      calculateDistance(stationCoords, b.coordinates)
    );
    break;

  case 'price_low':
    results.sort((a, b) => a.price_range_min - b.price_range_min);
    break;

  case 'price_high':
    results.sort((a, b) => b.price_range_max - a.price_range_max);
    break;

  case 'newest':
    results.sort((a, b) => new Date(b.date_added) - new Date(a.date_added));
    break;
}
```

#### Supabase Schema Changes Needed

**Add `date_added` field to `business` table:**
```sql
ALTER TABLE business ADD COLUMN date_added TIMESTAMP DEFAULT NOW();
```

**Add station coordinates (option 1: hardcode in BuildShip):**
```javascript
const COPENHAGEN_STATIONS = {
  "København H": { lat: 55.6723, lng: 12.5644 },
  "Nørreport": { lat: 55.6832, lng: 12.5717 },
  "Østerport": { lat: 55.6925, lng: 12.5886 },
  "Vesterport": { lat: 55.6734, lng: 12.5645 },
  "Flintholm": { lat: 55.6894, lng: 12.4979 },
};
```

**Or option 2: Create `train_stations` table:**
```sql
CREATE TABLE train_stations (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL
);

INSERT INTO train_stations (name, latitude, longitude) VALUES
  ('København H', 55.6723, 12.5644),
  ('Nørreport', 55.6832, 12.5717),
  ('Østerport', 55.6925, 12.5886),
  ('Vesterport', 55.6734, 12.5645),
  ('Flintholm', 55.6894, 12.4979);
```

#### FlutterFlow Changes Needed

1. **Add Sort Sheet UI:**
   ```dart
   showModalBottomSheet(
     context: context,
     builder: (context) => SortSheet(
       currentSort: _currentSort,
       onSortSelected: (sortOption) {
         setState(() => _currentSort = sortOption);
         _executeSearch();
       },
     ),
   );
   ```

2. **Add Floating Sort Button:**
   ```dart
   Positioned(
     bottom: 92,  // 12px above tab bar (80px)
     right: 16,
     child: FloatingActionButton.extended(
       onPressed: () => _openSortSheet(),
       backgroundColor: ACCENT,
       label: Text(_getSortLabel()),
       icon: Icon(Icons.sort),
     ),
   );
   ```

3. **Track Sort State:**
   ```dart
   String _currentSort = 'match';  // Default
   String? _selectedStation;
   ```

4. **Pass Sort to API:**
   ```dart
   await SearchCall.call(
     ...existing params,
     sortBy: _currentSort,
     selectedStation: _selectedStation,
   );
   ```

#### Translation Keys Needed (Category C)

**Sort Options:**
- `sort_match`: "Bedst match" (da), "Best match" (en)
- `sort_nearest`: "Nærmest" (da), "Nearest" (en)
- `sort_station`: "Nærmest togstation" (da), "Nearest train station" (en)
- `sort_price_low`: "Pris: Lav til høj" (da), "Price: Low to high" (en)
- `sort_price_high`: "Pris: Høj til lav" (da), "Price: High to low" (en)
- `sort_newest`: "Nyeste" (da), "Newest" (en)

**Sort Sheet:**
- `sort_sheet_title`: "Sortér efter" (da), "Sort by" (en)
- `sort_select_station`: "Vælg togstation" (da), "Select train station" (en)

**Stations:**
- Station names are proper nouns (no translation): "København H", "Nørreport", etc.

#### Implementation Priority: 🔥 **CRITICAL**

**Reason:**
- Without sorting, users can't find restaurants by their priorities
- "Best match" sort is essential for needs-first UX
- Price sorting helps budget-conscious users
- Station sorting helps commuters

#### Estimated Effort:
- **BuildShip work:** 3-4 days (sort logic, station data, testing all 6 sorts)
- **Supabase work:** 1 day (add date_added field, station table if needed)
- **Flutter work:** 2-3 days (sort sheet UI, floating button, API integration)
- **Translation work:** 1 day (8+ keys)
- **Total:** 1.5 weeks

---

### Gap B.2: Pagination (Known Missing Feature)

**Status:** 🟥 CRITICAL INFRASTRUCTURE GAP

**User-Identified Need:** "I imagine the best UX and approach is that they all live inside a single scrollable list, but that we keep scrolling full matches indefinitely until we reach the last one before going for partial matches."

#### JSX v2 Design
- Single scrollable list with infinite scroll
- Load full matches first (page 1, 2, 3...)
- When all full matches loaded → automatically load partial matches
- When all partial matches loaded → automatically load "other places"
- User never sees "load more" button — seamless scrolling

**Source:** User's most recent message

#### FlutterFlow Current
- **NO pagination**
- SearchCall returns all results in single response
- If 300 restaurants match → 300 returned at once
- Slow network = long wait time
- Large JSON payload

#### Why Pagination is Essential

1. **Performance:**
   - Large payloads (300+ businesses) slow down app
   - Mobile networks (3G, LTE) struggle with 500KB+ JSON
   - Parsing large JSON blocks UI thread

2. **UX:**
   - Faster initial load (show first 20 results immediately)
   - Progressive disclosure (load more as user scrolls)
   - Reduces perceived wait time

3. **Match Categories Require It:**
   - Gap A.1 (match indicators) depends on paginated categories
   - Can't show "full matches first" without pagination

#### Architecture Decision: B (Backend/BuildShip) ✅ REQUIRED

**Why BuildShip Must Handle Pagination:**
- Database pagination is efficient (LIMIT/OFFSET in SQL)
- Frontend can't paginate results it hasn't received yet
- Ties to match categorization (Gap A.1)

#### BuildShip API Changes Needed

**Already covered in Gap A.1 — same API enhancement**

```dart
Input:
{
  ...existing params,
  "page": 1,        // Page number (1-indexed)
  "pageSize": 20    // Results per page
}

Output:
{
  "documents": [...],
  "pagination": {
    "currentPage": 1,
    "totalPages": 5,
    "totalResults": 87,
    "hasMore": true,
    "nextCategory": null  // 'partial' when full matches exhausted
  }
}
```

#### FlutterFlow Changes Needed

**Already covered in Gap A.1 — scroll detection + load more logic**

#### Implementation Priority: 🔥 **CRITICAL**

**Reason:**
- Required for Gap A.1 (match indicators)
- Required for scalability (handling 1000+ restaurants)
- Standard mobile app pattern

#### Estimated Effort:
- Included in Gap A.1 work (no separate effort)

---

### Gap B.3: Train Station Proximity Data

**Status:** 🟨 DATA REQUIREMENT

**Related to:** Gap B.1 (Sorting — "Nærmest togstation")

#### Requirement
- Store train station coordinates
- Calculate distance from each restaurant to selected station
- Sort results by that distance

#### Data Source Options

**Option 1: Hardcode in BuildShip (Quick)**
```javascript
const COPENHAGEN_STATIONS = {
  "København H": { lat: 55.6723, lng: 12.5644 },
  "Nørreport": { lat: 55.6832, lng: 12.5717 },
  "Østerport": { lat: 55.6925, lng: 12.5886 },
  "Vesterport": { lat: 55.6734, lng: 12.5645 },
  "Flintholm": { lat: 55.6894, lng: 12.4979 },
};
```

**Pros:** Fast to implement, no database changes
**Cons:** Not scalable, not editable without code deployment

**Option 2: Supabase Table (Scalable)**
```sql
CREATE TABLE train_stations (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  city_id INT REFERENCES cities(id)
);
```

**Pros:** Scalable to other cities, editable via admin panel
**Cons:** Requires database migration, admin UI for managing stations

**Recommendation:** **Option 1 for MVP**, migrate to Option 2 post-launch

#### Implementation Priority: 🟨 **MEDIUM**

**Reason:**
- Required for station sort (Gap B.1)
- But station sort is lower priority than other sorts
- Can launch without station sort, add later

#### Estimated Effort:
- **Option 1:** 2 hours (hardcode coordinates in BuildShip)
- **Option 2:** 1 day (database migration, admin UI)

---

### Gap B.4: "Nyeste" (Newest) Sort — Missing `date_added` Field

**Status:** 🟩 MINOR DATA GAP

**Related to:** Gap B.1 (Sorting)

#### Requirement
- Sort restaurants by date added (newest first)
- Requires `date_added` timestamp field on `business` table

#### Supabase Changes Needed
```sql
ALTER TABLE business ADD COLUMN date_added TIMESTAMP DEFAULT NOW();

-- Backfill existing businesses with reasonable dates
-- (or set all to NOW() if exact date unknown)
UPDATE business SET date_added = NOW() WHERE date_added IS NULL;
```

#### BuildShip Changes Needed
```javascript
case 'newest':
  results.sort((a, b) => new Date(b.date_added) - new Date(a.date_added));
  break;
```

#### FlutterFlow Changes Needed
- None (sort handled by backend)

#### Implementation Priority: 🟩 **LOW**

**Reason:**
- "Nyeste" sort is nice-to-have, not essential
- Most users will use "Bedst match" or "Nærmest"
- Can launch without it

#### Estimated Effort:
- **Supabase work:** 1 hour (add column, backfill)
- **BuildShip work:** 30 mins (add sort case)
- **Total:** 2 hours

---

## CATEGORY C: Translation Infrastructure Gaps

### Gap C.1: Match Section Headers & Info Text

**Status:** 🟨 REQUIRED FOR GAP A.1

**Related to:** Gap A.1 (Match Indicators)

#### Translation Keys Needed

**Section Headers:**
```json
{
  "match_full_header": {
    "da": "MATCHER ALLE BEHOV",
    "en": "MATCHES ALL NEEDS",
    "de": "PASST ALLE BEDÜRFNISSE",
    "fr": "CORRESPOND À TOUS LES BESOINS",
    "it": "SODDISFA TUTTE LE ESIGENZE",
    "no": "OPPFYLLER ALLE BEHOV",
    "sv": "UPPFYLLER ALLA BEHOV"
  },
  "match_partial_header": {
    "da": "MATCHER DELVIST",
    "en": "PARTIAL MATCH",
    "de": "TEILWEISE ÜBEREINSTIMMUNG",
    "fr": "CORRESPONDANCE PARTIELLE",
    "it": "CORRISPONDENZA PARZIALE",
    "no": "DELVIS TREFF",
    "sv": "DELVIS MATCHNING"
  },
  "match_other_header": {
    "da": "ANDRE STEDER",
    "en": "OTHER PLACES",
    "de": "ANDERE ORTE",
    "fr": "AUTRES LIEUX",
    "it": "ALTRI LUOGHI",
    "no": "ANDRE STEDER",
    "sv": "ANDRA PLATSER"
  }
}
```

**Match Info Text (Dynamic):**
```json
{
  "match_info_matches": {
    "da": "Matcher {count}/{total}",
    "en": "Matches {count}/{total}",
    "de": "Entspricht {count}/{total}",
    "fr": "Correspond {count}/{total}",
    "it": "Corrisponde {count}/{total}",
    "no": "Matcher {count}/{total}",
    "sv": "Matchar {count}/{total}"
  },
  "match_info_missing": {
    "da": "Mangler: {filters}",
    "en": "Missing: {filters}",
    "de": "Fehlt: {filters}",
    "fr": "Manquant: {filters}",
    "it": "Mancante: {filters}",
    "no": "Mangler: {filters}",
    "sv": "Saknas: {filters}"
  }
}
```

#### Supabase Changes Needed
- Add these keys to `translations` table
- Ensure `getTranslationsWithUpdate` fetches them

#### Usage in FlutterFlow
```dart
final matchHeader = getTranslations(
  languageCode,
  'match_full_header',
  FFAppState().translationsCache,
);

final matchInfo = getTranslations(
  languageCode,
  'match_info_matches',
  FFAppState().translationsCache,
).replaceAll('{count}', '2').replaceAll('{total}', '3');

final missingText = getTranslations(
  languageCode,
  'match_info_missing',
  FFAppState().translationsCache,
).replaceAll('{filters}', 'Børnestol');
```

#### Implementation Priority: 🔥 **CRITICAL**

**Reason:**
- Blocks Gap A.1 (match indicators)
- No point building match UI without translations

#### Estimated Effort:
- **Translation work:** 1 day (5 keys × 7 languages = 35 translations)
- **Supabase work:** 2 hours (add keys, test fetch)
- **Total:** 1.5 days

---

### Gap C.2: Sort Option Labels

**Status:** 🟨 REQUIRED FOR GAP B.1

**Related to:** Gap B.1 (Sorting Functionality)

#### Translation Keys Needed

**Sort Options:**
```json
{
  "sort_match": {
    "da": "Bedst match",
    "en": "Best match",
    "de": "Beste Übereinstimmung",
    "fr": "Meilleure correspondance",
    "it": "Migliore corrispondenza",
    "no": "Beste treff",
    "sv": "Bästa matchning"
  },
  "sort_nearest": {
    "da": "Nærmest",
    "en": "Nearest",
    "de": "Am nächsten",
    "fr": "Le plus proche",
    "it": "Più vicino",
    "no": "Nærmest",
    "sv": "Närmast"
  },
  "sort_station": {
    "da": "Nærmest togstation",
    "en": "Nearest train station",
    "de": "Nächster Bahnhof",
    "fr": "Gare la plus proche",
    "it": "Stazione ferroviaria più vicina",
    "no": "Nærmeste togstasjon",
    "sv": "Närmaste tågstation"
  },
  "sort_price_low": {
    "da": "Pris: Lav til høj",
    "en": "Price: Low to high",
    "de": "Preis: Niedrig bis hoch",
    "fr": "Prix: Du plus bas au plus élevé",
    "it": "Prezzo: Dal più basso al più alto",
    "no": "Pris: Lav til høy",
    "sv": "Pris: Låg till hög"
  },
  "sort_price_high": {
    "da": "Pris: Høj til lav",
    "en": "Price: High to low",
    "de": "Preis: Hoch bis niedrig",
    "fr": "Prix: Du plus élevé au plus bas",
    "it": "Prezzo: Dal più alto al più basso",
    "no": "Pris: Høy til lav",
    "sv": "Pris: Hög till låg"
  },
  "sort_newest": {
    "da": "Nyeste",
    "en": "Newest",
    "de": "Neueste",
    "fr": "Le plus récent",
    "it": "Più recente",
    "no": "Nyeste",
    "sv": "Nyaste"
  }
}
```

**Sort Sheet UI:**
```json
{
  "sort_sheet_title": {
    "da": "Sortér efter",
    "en": "Sort by",
    "de": "Sortieren nach",
    "fr": "Trier par",
    "it": "Ordina per",
    "no": "Sorter etter",
    "sv": "Sortera efter"
  },
  "sort_select_station": {
    "da": "Vælg togstation",
    "en": "Select train station",
    "de": "Bahnhof wählen",
    "fr": "Sélectionner la gare",
    "it": "Seleziona stazione",
    "no": "Velg togstasjon",
    "sv": "Välj tågstation"
  }
}
```

**"Only Open" Filter:**
```json
{
  "filter_only_open": {
    "da": "Kun åbne steder",
    "en": "Only open places",
    "de": "Nur geöffnete Orte",
    "fr": "Seulement les lieux ouverts",
    "it": "Solo luoghi aperti",
    "no": "Kun åpne steder",
    "sv": "Endast öppna platser"
  }
}
```

#### Implementation Priority: 🔥 **HIGH**

**Reason:**
- Blocks Gap B.1 (sorting UI)
- No point building sort sheet without translations

#### Estimated Effort:
- **Translation work:** 1 day (9 keys × 7 languages = 63 translations)
- **Total:** 1 day

---

### Gap C.3: Empty State Text

**Status:** 🟩 MINOR GAP

**Note:** FlutterFlow has basic empty state, but JSX v2 has enhanced empty state with dynamic search term echo.

#### Translation Keys Needed

**Empty State:**
```json
{
  "search_no_results_title": {
    "da": "Ingen søgeresultater",
    "en": "No search results",
    "de": "Keine Suchergebnisse",
    "fr": "Aucun résultat de recherche",
    "it": "Nessun risultato di ricerca",
    "no": "Ingen søkeresultater",
    "sv": "Inga sökresultat"
  },
  "search_no_results_body": {
    "da": "Vi kunne ikke finde steder der matcher \"{query}\". Prøv at justere din søgning eller filtre.",
    "en": "We couldn't find any places matching \"{query}\". Try adjusting your search or filters.",
    "de": "Wir konnten keine Orte finden, die \"{query}\" entsprechen. Versuchen Sie, Ihre Suche oder Filter anzupassen.",
    "fr": "Nous n'avons trouvé aucun lieu correspondant à \"{query}\". Essayez d'ajuster votre recherche ou vos filtres.",
    "it": "Non abbiamo trovato luoghi corrispondenti a \"{query}\". Prova ad aggiustare la tua ricerca o i filtri.",
    "no": "Vi kunne ikke finne steder som matcher \"{query}\". Prøv å justere søket eller filtrene.",
    "sv": "Vi kunde inte hitta några platser som matchar \"{query}\". Försök justera din sökning eller filter."
  },
  "search_clear_button": {
    "da": "Ryd søgning",
    "en": "Clear search",
    "de": "Suche löschen",
    "fr": "Effacer la recherche",
    "it": "Cancella ricerca",
    "no": "Slett søk",
    "sv": "Rensa sökning"
  }
}
```

#### Implementation Priority: 🟩 **LOW**

**Reason:**
- Empty state already exists (just needs better copy)
- Not blocking any other features

#### Estimated Effort:
- **Translation work:** 2 hours (3 keys × 7 languages = 21 translations)

---

## CATEGORY D: Known Missing Features

### Gap D.1: Map View

**Status:** 🟦 FUTURE ENHANCEMENT (Out of Scope for MVP)

#### JSX v2 Design (lines 589-600, 951-961)
- "Liste/Kort" toggle (List/Map view switcher)
- Map shows restaurant pins
- Pins color-coded by match quality (green/orange/grey)
- Tap pin → show compact card overlay
- Tap card → navigate to profile
- Cluster pins when zoomed out

**Source:** DESIGN_README_search.md lines 589-600

#### FlutterFlow Current
- No map view
- Only list view

#### Why Out of Scope for MVP
1. **Complex implementation:**
   - Google Maps API integration
   - Pin clustering algorithm
   - Custom pin colors
   - Interactive overlays

2. **Not critical for core UX:**
   - List view is primary mode
   - Map view is nice-to-have for geographic browsing

3. **Significant development time:**
   - 2-3 weeks for full implementation
   - QA testing across devices

#### Future Requirements (Phase 2)
- Google Maps SDK integration
- Custom pin markers with match color coding
- Pin clustering (when zoomed out)
- Tap pin → show card overlay
- Map follows user location

#### Implementation Priority: 🟦 **FUTURE** (Post-MVP)

---

### Gap D.2: Search Input Enhancement

**Status:** 🟩 MINOR GAP (Already Working)

**Note:** FlutterFlow has search bar with debouncing (200ms). JSX design doesn't specify debounce timing.

#### JSX v2 Design Notes (lines 941-950)
- "Search Input Functionality: Current: Visual placeholder only"
- "Phase 3 needs: Text input triggers API search (Typesense), Debounced input (300ms)"

#### FlutterFlow Current
- Search bar text change: debounced 200ms ✅
- Search bar submit: immediate ✅
- Uses `performSearchBarUpdateState` action

#### Gap Assessment
**NO GAP** — FlutterFlow already has this functionality implemented correctly. JSX design notes say "current: visual placeholder" but that was referring to the JSX prototype, not FlutterFlow production.

---

## Summary & Implementation Roadmap

### Priority 1: Critical Path (Must Have for Launch)
1. **Gap A.1 + B.2:** Match Indicators + Pagination — **1.5 weeks** (includes A.1 + B.2 combined)
2. **Gap B.1:** Sorting Functionality — **1.5 weeks**
3. **Gap C.1 + C.2:** Translation Keys (match + sort) — **2 days**

**Total Critical Path:** ~3.5 weeks

### Priority 2: High Value (Launch Window)
4. **Gap A.2:** Only Open Filter — **1 day**
5. **Gap B.3:** Station Data (for station sort) — **2 hours**
6. **Gap C.3:** Empty State Translations — **2 hours**

**Total High Value:** 1.5 days

### Priority 3: Nice to Have (Post-Launch)
7. **Gap B.4:** Newest Sort (`date_added` field) — **2 hours**
8. **Gap D.1:** Map View — **2-3 weeks** (Phase 2)

---

## Architectural Decisions Summary

### Backend vs Frontend Logic

**✅ Backend (BuildShip) Should Handle:**
1. **Match Categorization** (Gap A.1) — Heavy computation, pagination dependency
2. **Sorting** (Gap B.1) — Database-level efficiency, pagination dependency
3. **"Only Open" Filter** (Gap A.2) — Reduces payload size
4. **Pagination** (Gap B.2) — Required for scalability

**❌ Frontend (Flutter) Should Handle:**
- UI state (sort sheet open/closed, current sort selection)
- Scroll detection (load more when near bottom)
- Category transitions (full → partial → other)
- Card rendering with match borders

**Rationale:**
- Keep business logic centralized in backend
- Reduce mobile app complexity (easier to maintain)
- Performance: server-side processing faster than mobile
- Single source of truth for matching/sorting algorithms

---

## Translation Strategy

**Current System:** Dual translation system
1. **FFLocalizations** — Static UI text (button labels, page titles)
2. **Supabase translationsCache** — Dynamic content (filter names, match text)

**Gap C Additions:**
- Add 15+ new keys to Supabase `translations` table
- Fetch via `getTranslationsWithUpdate` action
- Use `getTranslations()` function in UI

**No changes to dual system architecture** — this works well.

---

## End of Gap Analysis

**Total Functional Gaps:** 12 gaps
**Critical Gaps:** 4 (A.1, B.1, B.2, C.1+C.2)
**Total Implementation Effort:** ~4 weeks (critical path) + 2 days (high value)

**Next Step:** User review and prioritization → Implement in order: A.1+B.2 → B.1 → C.1+C.2 → A.2
