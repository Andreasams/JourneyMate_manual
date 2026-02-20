# BuildShip Requirements
## What must change in BuildShip and Supabase before Flutter implementation begins

**Generated:** 2026-02-20
**Source analysis:** Phase 3 — 14 BUNDLE.md + 9 GAP_ANALYSIS + 9 BuildShip node scripts + api_calls.dart + Supabase schema files

---

## How to read this document

**Priority levels:**
- **CRITICAL** — Core user flow is broken without this. Do before any Flutter work begins.
- **HIGH** — Important feature blocked. Must resolve before implementing the specific page.
- **MEDIUM** — Requires verification or documentation update. Can run in parallel with Flutter work.
- **LOW** — Data setup or informational. Can be done incrementally.

**USER ACTION REQUIRED** — Means a human must make a change in BuildShip or Supabase.
**Flutter note** — No server change needed. Documents a Flutter-only implementation decision.
**RESOLVED** — Issue investigated and confirmed not to require any action.

---

## CRITICAL — Core user flow blocked without these changes

These three changes all target the same BuildShip node (`SEARCH_SCRIPT_GENERATOR`). Execute them in a single BuildShip session.

---

### Section 1 — BuildShip `/search`: Match categorization + pagination

**USER ACTION REQUIRED**

**Why this is CRITICAL:**
The entire match-quality UX ("Matcher alle behov / Matcher delvist / Andre steder") depends on this. Without it, the app is just a flat restaurant list — the primary differentiator is missing. Pagination is also required here because category-aware scrolling (full matches → partial → others) cannot work without server-side bucketing.

**Current behaviour (from `SEARCH_SCRIPT_GENERATOR.txt`):**
- Node receives: `cityId`, `searchInput`, `userLocation`, `hasTrainStationFilter`, `trainStationFilterId`, `languageCode`, `filters` (Typesense filter string, not the same as `filtersUsedForSearch`)
- `per_page: 10` is hardcoded at line 313 of the node
- Returns flat list of documents sorted by GPS proximity or station proximity
- No match count, no bucketing, no pagination

**Business rule for match categorization (from GAP_ANALYSIS.md):**
- **Full match:** `matchCount === selectedFilters.length` — all user's active needs are present
- **Partial match:** `matchCount > 0 AND missingCount === 1` — exactly 1 filter missing
- **Other places:** `missingCount >= 2` — 2 or more filters missing

**Note:** `filtersUsedForSearch` is the user's active need set. It is a separate concept from the Typesense `filters` param (which pre-filters the Typesense result set). The match categorization runs *after* Typesense returns results, comparing each document's `filters` array against `filtersUsedForSearch`.

**New inputs to add to `/search`:**

| New field | Type | Description |
|-----------|------|-------------|
| `filtersUsedForSearch` | `number[]` | User's selected filter IDs (active needs) |
| `category` | `'full' \| 'partial' \| 'other'` | Which tier to return in this call |
| `page` | `number` | 1-indexed page within the requested category |
| `pageSize` | `number` | Recommend 20 |

**New per-document fields to add to each result:**

| New field | Type | Description |
|-----------|------|-------------|
| `matchCount` | `number` | How many of the user's filters this business has |
| `matchedFilters` | `number[]` | Which filter IDs match |
| `missedFilters` | `number[]` | Which filter IDs are absent |

**Required response shape:**

```json
{
  "category": "full",
  "documents": [
    {
      "...all existing fields...",
      "matchCount": 3,
      "matchedFilters": [1, 5, 12],
      "missedFilters": []
    }
  ],
  "activeids": ["..."],
  "resultCount": 42,
  "pagination": {
    "currentPage": 1,
    "totalPages": 3,
    "totalResults": 42,
    "hasMore": true,
    "nextCategory": null
  }
}
```

`nextCategory` is non-null only when the current category is fully exhausted. Values: `'partial'` (when full matches run out), `'other'` (when partial matches run out), `null` otherwise.

**Backend pseudocode:**

```javascript
const selectedFilters = params.filtersUsedForSearch || [];

// Categorize all Typesense results
const full = allDocs.filter(b => {
  const matchCount = selectedFilters.filter(f => b.filters.includes(f)).length;
  return matchCount === selectedFilters.length;
});
const partial = allDocs.filter(b => {
  const matchCount = selectedFilters.filter(f => b.filters.includes(f)).length;
  const missing = selectedFilters.length - matchCount;
  return matchCount > 0 && missing === 1;
});
const others = allDocs.filter(b => {
  const matchCount = selectedFilters.filter(f => b.filters.includes(f)).length;
  return (selectedFilters.length - matchCount) >= 2;
});

// Select requested category
const pool = { full, partial, other: others }[params.category];

// Paginate
const start = (params.page - 1) * params.pageSize;
const paginated = pool.slice(start, start + params.pageSize);
const hasMore = (start + params.pageSize) < pool.length;

// Determine nextCategory (only when current category is exhausted)
const nextCategory = !hasMore
  ? (params.category === 'full' ? 'partial'
     : params.category === 'partial' ? 'other'
     : null)
  : null;

return {
  category: params.category,
  documents: paginated.map(b => ({
    ...b,
    matchCount: selectedFilters.filter(f => b.filters.includes(f)).length,
    matchedFilters: selectedFilters.filter(f => b.filters.includes(f)),
    missedFilters: selectedFilters.filter(f => !b.filters.includes(f))
  })),
  activeids: paginated.map(b => b.id),
  resultCount: pool.length,
  pagination: { currentPage: params.page, totalPages: Math.ceil(pool.length / params.pageSize), totalResults: pool.length, hasMore, nextCategory }
};
```

**When `filtersUsedForSearch` is empty** (user ran a keyword search with no filters active): skip categorization — all documents are "full match" by definition. Return them as a single flat list.

**Pages blocked:** Search page (01) — primary page of the app.
**Effort estimate:** 3–5 days.

---

### Section 2 — BuildShip `/search`: Sorting (`sortBy` / `sortOrder`)

**USER ACTION REQUIRED**

**Why this is CRITICAL:**
Without sorting, users cannot find restaurants by their priorities. "Bedst match" is the core value proposition. All 6 sort options are surfaced prominently in the sort sheet.

**New inputs to add to `/search`:**

| New field | Type | Description |
|-----------|------|-------------|
| `sortBy` | `'match' \| 'nearest' \| 'station' \| 'price_low' \| 'price_high' \| 'newest'` | Sort field |
| `sortOrder` | `'asc' \| 'desc'` | Direction (most options have a natural direction; include for completeness) |
| `selectedStation` | `string` | Station name string (e.g. `"Nørreport"`), required when `sortBy === 'station'` |

**Sort logic per option:**

| `sortBy` | Logic |
|----------|-------|
| `'match'` | Sort by `matchCount` DESC, then distance ASC (tiebreaker). Requires `filtersUsedForSearch` from Section 1. |
| `'nearest'` | Sort by Haversine distance from `userLocation` ASC. |
| `'station'` | Look up `selectedStation` coordinates from `FilterTrainStation` table (confirmed: 64 stations, `train_station_id` + lat/lng). Sort by distance from station ASC. |
| `'price_low'` | Sort by `price_range_min` ASC. |
| `'price_high'` | Sort by `price_range_max` DESC. |
| `'newest'` | Sort by `created_at` DESC. Use `created_at` from `BusinessInfo` table — column already exists (`TIMESTAMPTZ NOT NULL DEFAULT NOW()`). No new column needed. |

**Absorbing existing logic:**
The current node has `hasTrainStationFilter` / `trainStationFilterId` parameters and GPS-proximity sort. These are replaced by:
- `sortBy: 'station'` + `selectedStation` (station name string) replaces `hasTrainStationFilter`/`trainStationFilterId`
- `sortBy: 'nearest'` replaces the default GPS-proximity sort

Remove the old station filter parameters from the node after migrating.

**Note on station lookup:** `FilterTrainStation` table uses `train_station_id` (values 9–73) and station `name`. Look up station coordinates by matching `selectedStation` against the `name` column.

**Pages blocked:** All 6 sort options on the sort sheet.
**Effort estimate:** 2–3 days. Do in the same BuildShip session as Section 1.

---

### Section 3 — BuildShip `/search`: `onlyOpen` filter

**USER ACTION REQUIRED**

**Why this is CRITICAL:**
The "Kun åbne steder" toggle on the sort sheet is a visible, named feature. Users who enable it expect closed restaurants to disappear from results.

**New input to add to `/search`:**

| New field | Type | Description |
|-----------|------|-------------|
| `onlyOpen` | `boolean` | When `true`, filter out businesses that are currently closed |

**Recommended:** Server-side filtering. The server knows the current time in Copenhagen timezone (`'Europe/Copenhagen'`). Apply this filter before match categorization and pagination so the category counts reflect open-only results.

**Why server-side (not client-side):**
The client doesn't have full `business_hours` data until the profile is loaded. The search response contains the hours data needed for this check. Server filters before returning, reducing payload size and preventing category count discrepancies.

**Pages blocked:** "Kun åbne steder" toggle on sort sheet.
**Effort estimate:** 4–6 hours. Do in the same BuildShip session as Sections 1 and 2.

---

## HIGH — Important feature blocked

---

### Section 4 — Supabase: `get_business_complete_info` RPC — business hours

**USER ACTION REQUIRED**

**Status:** CONFIRMED ABSENT from RPC output.

The `GET_BUSINESS_PROFILE` BuildShip node calls `get_business_complete_info(p_business_id, p_language_code)`. The confirmed RPC output schema contains:
- `business_profile` object: `business_id`, `business_name`, `business_type`, `price ranges`, `is_active`, `tags` (JSONB), `typesense_id`, `last_reviewed_at`, `description`, `address`, `profile_picture`, `contact`, `brand`, `company`
- `gallery` array
- `menu_structure` array
- `exchange_rate` object

**`business_hours` is NOT present anywhere in the confirmed output.** It may be stored inside `tags` JSONB alongside filter tags, or it may be entirely absent from the RPC return.

**The v2 design requires business hours** to display on the Business Profile page and for the `onlyOpen` server-side filter (Section 3).

**User action:**
1. In Supabase SQL editor, run: `SELECT get_business_complete_info(1, 'da');`
2. Inspect the full JSON output. Find where business hours data lives (if at all).
3. Confirm the structure of each day's entry. The v2 design needs an array of time slots per day to support split-shift restaurants: `[{ time: "07:00–10:00" }, { time: "12:00–22:00" }]`. A single string per day (e.g. `"07:00–22:00"`) cannot represent split shifts.
4. If hours are absent or in an incompatible format, the Supabase RPC function needs updating to return them in the array-of-slots format.
5. **No BuildShip node change is needed** — the Business Profile node passes the RPC output through directly.

**Pages blocked:** Hours display on Business Profile (02). Split-shift restaurants will display incorrectly if hours are a flat string.
**Effort estimate:** 2–4 hours.

---

### Section 5 — Supabase: `get_business_complete_info` RPC — payment options and facilities

**USER ACTION REQUIRED (combine with Section 4)**

The Business Profile design expects `payment_options` (e.g. "Kontant", "Dankort", "MobilePay") and `facilities` (accessibility and amenity information) to be available in the profile response. Neither appears in the confirmed RPC output schema.

These may be encoded in the `tags` JSONB field alongside other filter-tag data, or absent entirely.

**User action:** While running the full output inspection from Section 4, also note:
- Whether `payment_options` appears (as an array of IDs, strings, or objects)
- Whether facilities or amenity data appears (separate from match filter data)
- If either is absent, update the RPC to return them

**Pages blocked:** Payment options and facilities sections on Business Profile (02).
**Effort estimate:** Covered by the Section 4 inspection — no separate time needed.

---

## MEDIUM — Verification required

---

### Section 6 — Analytics endpoint: URL confirmed, event types, pageName fix

**USER ACTION REQUIRED (partial)**

**URL confirmed:** `https://wvb8ww.buildship.run/analytics`

**Mechanism:** Fire-and-forget via Supabase RPC `track_analytics_event(p_user_id, p_session_id, p_event_type, p_event_data, p_timestamp, p_business_id, p_click_position)`.

**Event type count discrepancy:** `BUILDSHIP_API_REFERENCE.md` documents 30 event types. The live BuildShip node (`POST_ANALYTICS_TO_SUPABASE.txt`) defines **36 valid event types**:

```
session_start, session_end, session_heartbeat,
filter_applied, filter_session_ended, filter_session_started,
business_clicked, business_profile_viewed,
menu_filter_applied, menu_filters_reset,
menu_session_started, menu_session_ended,
menu_item_clicked, menu_package_clicked,
menu_filter_impact, menu_scroll_depth,
category_description_viewed, page_viewed,
location_permission_changed, location_settings_opened, location_settings_error,
allergen_filter_toggled, dietary_restriction_toggled, dietary_preference_toggled,
image_gallery_opened, image_gallery_navigation, image_gallery_closed,
filter_info_clicked, currency_changed, language_changed,
gallery_tab_opened, gallery_tab_changed,
expandable_text_toggled, social_link_clicked,
share_button_clicked, business_contact_toggled
```

**`pageName` fix:** For `event_type: 'page_viewed'` events, the correct `event_data.pageName` value for the welcome page is `'welcomePage'`. The FlutterFlow export used inconsistent values (`'homepage'`, `'welcomepage'`). Flutter v2 must use `'welcomePage'`.

**User action:**
1. Update `_reference/BUILDSHIP_API_REFERENCE.md`: replace the 30-event list with the 36-event list above. Add confirmed URL.
2. In Supabase, inspect the `track_analytics_event` RPC function. Confirm `'page_viewed'` is accepted (the node validates event types server-side).
3. No new event types are needed for Phase 4.

**Pages blocked:** Welcome page analytics records wrong `pageName` — data quality issue, not a blocking crash.
**Effort estimate:** 30–60 minutes.

---

### Section 7 — Form endpoints: URLs confirmed, update reference doc, resolve `/feedbackform` `page` column

**USER ACTION REQUIRED**

All three form endpoints are now fully confirmed:

| Endpoint | URL (confirmed) | Supabase table (confirmed) |
|----------|-----------------|---------------------------|
| `/missingplace` | `https://wvb8ww.buildship.run/missingplace` | `zUserFormMissingLocation` |
| `/contact` | `https://wvb8ww.buildship.run/contact` | `zUserFormContactUs` |
| `/feedbackform` | `https://wvb8ww.buildship.run/feedbackform` | `zUserFormShareFeedback` |

All three use BuildShip's `supabaseInsertObject` node (no custom script). All tables have `language_code` columns.

**Confirmed inputs per endpoint:**

`/missingplace`: `message`, `businessName`, `businessAddress`, `languageCode`
`/contact`: `message`, `name`, `contact`, `languageCode`, `subject`
`/feedbackform`: `message`, `contact`, `languageCode`, `topic`, `allowContact`, `name`

**⚠️ NEW ISSUE — `zUserFormShareFeedback.page` is `NOT NULL`:**

The `zUserFormShareFeedback` table schema:
```sql
page text NOT NULL  -- ← problem
```

The BuildShip inputs for `/feedbackform` do **not** include a `page` field. Two possibilities:
1. The `supabaseInsertObject` node is configured in BuildShip to inject a hardcoded `page` value (e.g. `'feedbackform'`). If so, no Flutter change is needed.
2. Flutter v2 must send a `page` parameter. The current spec is incomplete.

`zUserFormContactUs.page` is `NULL`-able — not a problem there.
`zUserFormMissingLocation` has no `page` column — not a problem there.

**User action:**
1. Update `_reference/BUILDSHIP_API_REFERENCE.md`: add confirmed URLs and table names for all three endpoints.
2. Open the `/feedbackform` workflow in BuildShip. Check the `supabaseInsertObject` node configuration — does it inject a hardcoded `page` value? If yes, document it. If no, add `page` to the `/feedbackform` Flutter input spec.
3. POST a test payload to each endpoint to confirm they are live and accepting inserts.

**Note:** The old `UserFeedbackCall` in `api_calls.dart` hits `/userfeedback`. This endpoint does not exist. Do not port it to Flutter v2. See Section 12.

**Pages blocked:** Missing Place form (07d), Contact Us form (07a), Share Feedback form (07e).
**Effort estimate:** 30–60 minutes (primarily the `page` column investigation).

---

### Section 8 — BuildShip: Verify `languageCode` vs `language_code` parameter name

**USER ACTION REQUIRED**

The FlutterFlow export (`api_calls.dart`) sends `'language_code'` (snake_case) to both `/getBusinessProfile` and `/DishesAndDrinks`. The BuildShip node interface for Business Profile declares `languageCode` (camelCase) as its input field name.

If the BuildShip node only accepts `languageCode` and Flutter sends `language_code`, the RPC will receive `null` for the language parameter — returning data in the wrong language or failing silently.

**User action:** In BuildShip dashboard, open the Business Profile and Menu Item workflows. Check the exact parameter name each node expects:
- If nodes accept `languageCode` only → Flutter v2 must send `languageCode` (camelCase)
- If nodes accept both → document which is canonical and use that in Flutter v2
- If nodes accept `language_code` only → update `BUILDSHIP_API_REFERENCE.md` to reflect snake_case

**Pages blocked:** Business Profile (02) and Menu Full (03) may return wrong-language data silently.
**Effort estimate:** 30 minutes.

---

## LOW — Data setup and Flutter notes

---

### Section 9 — Supabase: Insert new translation keys

**USER ACTION REQUIRED**

All new UI strings for the v2 design must be inserted into the `flutterflowtranslations` table before page implementation. The complete set of new keys is in `MASTER_TRANSLATION_KEYS.md`. Below are the keys confirmed as new by the GAP_ANALYSIS for the Search page (the primary page). Other pages will add further keys during Phase 4.

**Search page translation keys (minimum required before Search page work begins):**

From `GAP_ANALYSIS.md` Gap C.1 — Match headers and info:

| Key | da | en |
|-----|----|----|
| `match_full_header` | MATCHER ALLE BEHOV | MATCHES ALL NEEDS |
| `match_partial_header` | MATCHER DELVIST | PARTIAL MATCH |
| `match_other_header` | ANDRE STEDER | OTHER PLACES |
| `match_info_matches` | Matcher {count}/{total} | Matches {count}/{total} |
| `match_info_missing` | Mangler: {filters} | Missing: {filters} |

From Gap C.2 — Sort options:

| Key | da | en |
|-----|----|----|
| `sort_match` | Bedst match | Best match |
| `sort_nearest` | Nærmest | Nearest |
| `sort_station` | Nærmest togstation | Nearest train station |
| `sort_price_low` | Pris: Lav til høj | Price: Low to high |
| `sort_price_high` | Pris: Høj til lav | Price: High to low |
| `sort_newest` | Nyeste | Newest |
| `sort_sheet_title` | Sortér efter | Sort by |
| `sort_select_station` | Vælg togstation | Select train station |
| `filter_only_open` | Kun åbne steder | Only open places |

From Gap C.3 — Empty state:

| Key | da | en |
|-----|----|----|
| `search_no_results_title` | Ingen søgeresultater | No search results |
| `search_no_results_body` | Vi kunne ikke finde steder der matcher "{query}". | We couldn't find any places matching "{query}". |
| `search_clear_button` | Ryd søgning | Clear search |

**Total for Search page: 17 keys**

Full translations for de, fr, it, no, sv are in `GAP_ANALYSIS.md` Gap C sections and `MASTER_TRANSLATION_KEYS.md`. All values are specified there — use them directly.

**Insert target table:** `flutterflowtranslations` (the table name the `GET_UI_TRANSLATIONS` node queries).

**Note:** `GAP_ANALYSIS.md` and `MASTER_TRANSLATION_KEYS.md` refer to the translations table by two different names (`flutterflowtranslations` and `translations`). The BuildShip node `GET_UI_TRANSLATIONS` queries `flutterflowtranslations` — use that name.

**Pages blocked:** Any page using new strings will show blank text until the keys are inserted.
**Effort estimate:** 1–2 days total across all pages (translation work dominates).

---

### Section 10 — Flutter note: `MenuItemsCall` reads wrong field

**No user action required.**

`api_calls.dart` reads `$.dishes[:].*` from the `/DishesAndDrinks` response.

The BuildShip node `GET_RESTAURANT_MENU` returns `menu_items` (not `dishes`). This is correct in BuildShip. The FlutterFlow accessor is wrong.

**Flutter v2 must use `$.menu_items[:].*`.** Do not copy the field accessor from `api_calls.dart`.

---

### Section 11 — Flutter note: `UserFeedbackCall` is obsolete

**No user action required.**

`api_calls.dart` contains `UserFeedbackCall` targeting `/userfeedback`. This endpoint does not exist in the current BuildShip setup and has not existed at any point in the confirmed endpoint list.

Do not port this call to Flutter v2. The three replacement endpoints are `/missingplace`, `/contact`, and `/feedbackform` (Section 7).

---

### Section 12 — Flutter note: Menu item detail — use `item_modifier_groups`

**No user action required.**

The `get_menu_complete` RPC output does not include a `hasDetailData` boolean. Flutter v2 should determine whether to show the menu item detail overlay by checking whether the item's `item_modifier_groups` array is non-empty. If `item_modifier_groups` is empty **and** `allergy_ids` and dietary arrays are also empty, treat the item as no-detail.

This is a Flutter implementation decision — no API change needed.

---

### Section 13 — Flutter note: "Nyeste" sort uses `created_at`

**No user action required.**

`BusinessInfo` table already has `created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()`. No new `date_added` column is needed.

The search node (Section 2) should sort by `created_at DESC` when `sortBy: 'newest'`. This is part of the CRITICAL Section 2 work — no separate Supabase change required.

---

### Section 14 — Informational: `FilterTrainStation` table confirmed complete

**No user action required.**

Table contains 64 Copenhagen metro/S-train stations (indices 0–63, `train_station_id` values 9–73) with accurate lat/lng coordinates. The search node already references this table. Station lookup for `sortBy: 'station'` (Section 2) should match by station `name` column.

---

### Section 15 — Informational: Partial match definition

**No user action required. Documents the implemented business rule.**

"Partial match" means **exactly 1 filter missing** from the user's active needs. Businesses with 2 or more filters missing are "Other places." This distinction matters for the BuildShip node implementation in Section 1.

The GAP_ANALYSIS.md confirms this threshold explicitly. If it needs to be adjusted later (e.g., "2 missing = partial"), it changes only the BuildShip node — no app update required.

---

## USER ACTION REQUIRED — Summary Table

| # | Where | Action | Priority | Effort |
|---|-------|--------|----------|--------|
| 1 | BuildShip: `/search` node | Add `filtersUsedForSearch` + match categorization + per-document match fields + pagination | CRITICAL | 3–5 days |
| 2 | BuildShip: `/search` node | Add `sortBy` / `sortOrder` / `selectedStation` (6 sort options); absorb existing station/GPS params; use `created_at` for newest | CRITICAL | 2–3 days (same session as #1) |
| 3 | BuildShip: `/search` node | Add `onlyOpen: boolean` filter | CRITICAL | 4–6 hours (same session as #1, #2) |
| 4 | Supabase: `get_business_complete_info` RPC | Run `SELECT get_business_complete_info(1, 'da')`. Locate `business_hours`. Confirm hours structure (must support array of slots per day for split-shift). Update RPC if absent or wrong format. | HIGH | 2–4 hours |
| 5 | Supabase: `get_business_complete_info` RPC | During #4 inspection: confirm `payment_options` and `facilities` are present in output. Add to RPC if absent. | HIGH | Covered by #4 |
| 6 | `_reference/BUILDSHIP_API_REFERENCE.md` | Replace 30-event list with the 36-event list (Section 6). Add confirmed URLs for analytics and all three form endpoints. | MEDIUM | 30 min |
| 7 | BuildShip: `/feedbackform` workflow | Check `supabaseInsertObject` node — does it inject a hardcoded `page` value? If no, add `page` to the endpoint input spec. | MEDIUM | 30 min |
| 8 | All three form endpoints | POST a test payload to `/missingplace`, `/contact`, `/feedbackform` to confirm they are live | MEDIUM | 30 min |
| 9 | Supabase: `track_analytics_event` RPC | Confirm `'page_viewed'` is accepted. Document `'welcomePage'` as the correct pageName for the welcome page. | MEDIUM | 30 min |
| 10 | BuildShip: Business Profile + Menu nodes | Confirm whether nodes accept `language_code` or `languageCode`. Update Flutter v2 input spec accordingly. | MEDIUM | 30 min |
| 11 | Supabase: `flutterflowtranslations` table | INSERT 17 new keys × 7 languages for the Search page (Section 9). Insert further keys per page during Phase 4. | LOW | 1–2 days total |

---

## Items resolved — no user action needed

| Item | Resolution |
|------|-----------|
| `FilterTrainStation` table | ✅ 64 stations confirmed populated with accurate coordinates (Section 14) |
| `date_added` column | ✅ Use existing `BusinessInfo.created_at` — no new column needed (Section 13) |
| `hasDetailData` field | ✅ Flutter checks `item_modifier_groups` non-empty — no API change needed (Section 12) |
| `MenuItemsCall` field mismatch | ✅ Flutter v2 fix only — use `$.menu_items[:].*` instead of `$.dishes[:].*` (Section 10) |
| `UserFeedbackCall` | ✅ Obsolete — do not port. Replaced by `/missingplace`, `/contact`, `/feedbackform` (Section 11) |

---

## Verification Checklist

Before Phase 4 can begin:

### All 12 endpoints covered?
- [x] #1 `/search` → Sections 1, 2, 3 (CRITICAL changes)
- [x] #2 `/getBusinessProfile` → Sections 4, 5 (hours + payment/facilities), Section 8 (param name)
- [x] #3 `/DishesAndDrinks` → Section 10 (Flutter note only; no server change)
- [x] #4 `/filters` → No action needed ✓
- [x] #5 `/getExchangeRates` → No action needed ✓
- [x] #6 `/filterDescriptions` → No action needed ✓
- [x] #7 `/menuItem` → No action needed ✓
- [x] #8 `/getTranslations` → Section 9 (Supabase INSERT new keys)
- [x] #9 `/analytics` → Section 6 (URL confirmed; 36 event types; pageName fix)
- [x] #10 `/missingplace` → Section 7 (URL + table confirmed; update reference doc)
- [x] #11 `/contact` → Section 7 (URL + table confirmed; update reference doc)
- [x] #12 `/feedbackform` → Section 7 (URL + table confirmed; resolve `page NOT NULL`)

### All GAP_ANALYSIS flags addressed?
- [x] Search Gap A.1 (match indicators + categorization) → Section 1
- [x] Search Gap A.2 (only open) → Section 3
- [x] Search Gap B.1 (sorting — 6 options incl. newest via `created_at`) → Section 2 + Section 13
- [x] Search Gap B.2 (pagination) → Section 1 (same implementation)
- [x] Search Gap B.3 (train station data) → Section 14 (RESOLVED — 64 stations confirmed)
- [x] Search Gap B.4 (`date_added`) → Section 13 (RESOLVED — use existing `created_at`)
- [x] Search Gap C.1–C.3 (translation keys) → Section 9
- [x] Business Profile Gap (hours location + format) → Section 4
- [x] Business Profile Gap (payment/facilities) → Section 5
- [x] Business Profile Gap (`hasDetailData`) → Section 12 (RESOLVED — Flutter check)
- [x] Welcome `pageName` fix → Section 6
- [x] Form endpoint URLs + tables → Section 7
- [x] `languageCode` param mismatch → Section 8

---

## Recommended execution order

**Phase 3.5 — Before any Flutter work begins:**

1. **CRITICAL (one BuildShip session):**
   - Update `/search` node: match categorization + pagination (Section 1)
   - Update `/search` node: sortBy / sortOrder / selectedStation (Section 2)
   - Update `/search` node: onlyOpen filter (Section 3)

2. **HIGH (one Supabase session):**
   - Run `SELECT get_business_complete_info(1, 'da')` and inspect full output (Sections 4 + 5)

3. **MEDIUM (can run in parallel with Flutter work):**
   - Update `BUILDSHIP_API_REFERENCE.md` with confirmed URLs + 36 event list (Section 6)
   - Investigate `/feedbackform` `page` NOT NULL in BuildShip (Section 7)
   - POST test inserts to all three form endpoints (Section 7)
   - Confirm `track_analytics_event` RPC accepts `'page_viewed'` (Section 9)
   - Confirm `languageCode` vs `language_code` param name (Section 8)

4. **LOW (start before or during page implementation):**
   - INSERT Search page translation keys (Section 9) — must be done before Search page Flutter work

**Phase 4 can begin** once the CRITICAL search node changes are deployed. HIGH and MEDIUM items can be resolved incrementally as the relevant pages are implemented.
