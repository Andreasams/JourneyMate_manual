# BuildShip API Reference

**Working on a specific task?** See **CLAUDE.md → Task-Based Navigation Guide** (Scenario 3: Integrating with BuildShip API) for targeted reading. Otherwise, browse the complete API contracts below.

Source: `_reference/_buildship/` — actual BuildShip node scripts
All endpoints call BuildShip, which mediates all Supabase/Typesense access.
**No direct Supabase SDK calls from Flutter.**

---

## 1. SEARCH (`SEARCH_SCRIPT_GENERATOR`) — v9

**Purpose:** Full-text + filter search of restaurants via Typesense. Returns scored, paginated results where full dietary matches rank above partial matches. Backend-driven section tagging eliminates client-side sorting.

**Inputs (from Flutter):**
| Field | Type | Notes |
|-------|------|-------|
| `filters` | `number[]` \| `string` | Dietary/feature filter IDs to score. Backend strips train station IDs (10000–19999) and shopping area IDs (20000+) from scoring. Composite dietary menu filters (592000–602999) use `dietary_menu_filters` field for matching. |
| `city_id` | `string` \| `null` | Always `"17"` (Copenhagen) for now. |
| `search_input` | `string` \| `null` | Free text. Empty/null → `'*'` (match all). |
| `userLocation` | `string` \| `null` | Flutter LatLng string: `"LatLng(lat: 55.6761, lng: 12.5683)"`. `null` if no permission. |
| `language_code` | `string` | BCP-47, e.g. `"en"`, `"da"`. Default: `"da"`. 15 languages supported. |
| `sortBy` | `string` | One of: `'nearest'`, `'station'`, `'price_low'`, `'price_high'`. **Flutter default: `'nearest'`**. When location unavailable, backend degrades to alphabetical (`business_name:asc`). |
| `sortOrder` | `string` | `'asc'` or `'desc'`. Default: `'desc'`. (Not used in v9; kept for API compatibility.) |
| `selectedStation` | `number` \| `null` | Station filter ID (numeric). Required when `sortBy='station'`. IDs ≥ 10000 have 10000 offset applied internally. Looked up in `FilterTrainStation` by `train_station_id`. |
| `onlyOpen` | `boolean` \| `string` | When `true`, filter out closed businesses using pre-computed `open_windows`. **Over-fetches** (3× pageSize, up to 5 rounds) and filters locally in Copenhagen timezone. `totalPages` becomes `-1`; Flutter uses `hasMore` instead. Default: `false`. |
| `page` | `number` | 1-indexed page. Default: `1`. |
| `pageSize` | `number` | Results per page. Recommended: `20`. Default: `20`. |
| `neighbourhood_id` | `number` \| `number[]` \| `null` | Filter by neighbourhood(s). Handles: number, array, string ("47"), JSON array ("[47]"), 0 (ignored). Zero values filtered out. |
| `shopping_area_id` | `number` \| `null` | Filter by shopping area. Zero values ignored. |

> BuildShip injects `host`, `apiKey`, `supabaseUrl`, `supabaseKey` from environment — Flutter never sends these.

**Sort options:**
| `sortBy` | Logic |
|----------|-------|
| `'nearest'` | Distance from `userLocation` ASC. **Flutter default.** When `userLocation` is `null` (location unavailable), backend falls back to alphabetical (`business_name:asc`). Typesense `_eval()` scoring ranks full matches above partials regardless of sort. |
| `'station'` | Distance from `selectedStation` coords ASC (looks up lat/lng from `FilterTrainStation` by `train_station_id`). Falls back to `userLocation` if station lookup fails. |
| `'price_low'` | `price_range_min` ASC |
| `'price_high'` | `price_range_max` DESC |

**Note:** Unrecognized `sortBy` values fall through to alphabetical (`business_name:asc`).

**Scoring System (Typesense `_eval()`):**

v9 uses a priority-based scoring system to rank restaurants:
- **10,000 pts bonus** if ALL scoring filters match (full match)
- **Per-filter points** by safety-critical priority group:
  - P1 (5000 pts): parentId 94 — ids [466, 173, 174] (most critical dietary needs)
  - P2 (4000 pts): parentId 93 — ids [177]
  - P3 (3000 pts): parentId 91 — ids [553–577] (15 items)
  - P4 (2000 pts): parentId 95 — ids [175, 176]
  - P5 (1500 pts): parentId 96 — ids [178]
  - P6 (1000 pts): parentIds 90, 92, 97 — ids [179, 180, 181, 182, 183]
- **Non-dietary filters:** 200 pts each

**Result:** Full matches (all filters present) always rank above partial matches, regardless of which filters are missing. Within partial matches, results with higher-priority filters rank higher.

**Section Tagging (backend-driven):**

Each document includes a `section` field for client-side rendering:
- **`fullMatch`**: All scoring filters present
- **`partialMatch`**: Exactly 1 scoring filter missing AND at least 1 matched
- **`others`**: 2+ filters missing, or 0 matched

Documents arrive **pre-sorted** by Typesense `_eval()` score (full → partial → others). Flutter renders cards top-to-bottom and inserts section headers when `section` value changes. **No client-side sorting or grouping** needed.

**ID Ranges:**
- **1–9999**: Standard filters (dietary, features)
- **10000–19999**: Train stations (offset by 10000) — stripped from scoring
- **20000+**: Shopping areas — stripped from scoring
- **592000–602999**: Composite dietary menu filters → use `dietary_menu_filters` field for matching

**Output:**
```json
{
  "documents": [...],
  "scoringFilterIds": [466, 83],
  "activeids": [1, 2, 3],
  "resultCount": 42,
  "fullMatchCount": 12,
  "pagination": {
    "currentPage": 1,
    "totalPages": 3,
    "totalResults": 42,
    "hasMore": true
  }
}
```

**Output fields:**
- **`documents`**: Array of restaurant objects (see below)
- **`scoringFilterIds`**: Echo of cleaned filter IDs used for scoring (train station/shopping area IDs stripped)
- **`activeids`**: All filter IDs present in result set (from Typesense facets, for filter chips)
- **`resultCount`**: Total Typesense matches (pre open-now filtering)
- **`fullMatchCount`**: Global count of restaurants matching ALL scoring filters (separate `per_page=0` query with hard constraints)
- **`pagination`**:
  - `currentPage`: 1-indexed
  - `totalPages`: Number of pages (or `-1` when `onlyOpen=true`)
  - `totalResults`: Total results (same as `resultCount`)
  - `hasMore`: Boolean indicating more results available

**Each document includes:**
- `business_id`, `business_name`, `street`, `neighbourhood_name`, `postal_code`, `postal_city`
- `business_type` (normalised from `business_type_{lang}`)
- `tags` (normalised from `tags_{lang}`), `tags_en`, `tags_da` (always retained)
- `filters: number[]` — regular filter IDs on this business
- `dietary_menu_filters: number[]` — composite dietary filter IDs (592000–602999)
- `city_id`, `is_active`, `latitude`, `longitude`, `location`
- `profile_picture_url`
- `price_range_min`, `price_range_max`, `price_range`
- `created_at`, `last_reviewed_at`
- `brand_id`, `company_id`, `typesense_id`, `business_type_id`, `gallery_images`
- `neighbourhood_id`, `shopping_area_id`
- `open_windows: [{day, open, close}]` — pre-computed hours windows (included only when `onlyOpen=true`)
- **`matchCount: number`** — how many of `scoringFilterIds` this business has
- **`matchedFilters: number[]`** — which filter IDs matched
- **`missedFilters: number[]`** — which filter IDs are absent
- **`section: string`** — `"fullMatch"`, `"partialMatch"`, or `"others"` (for client-side rendering)

---

## 2. GET BUSINESS PROFILE (`GET_BUSINESS_PROFILE`)

**Purpose:** Fetch complete business info including hours, gallery, and menu structure via RPC `get_business_complete_info`.

**Inputs:**
| Field | Type | Notes |
|-------|------|-------|
| `businessId` | `number` | Integer business ID |
| `language_code` | `string` | BCP-47, e.g. `"en"`, `"da"` |

**Output (top-level keys):**
```json
{
  "businessInfo": { ... },
  "filters": [...],
  "gallery": { "interior": [], "food": [], "outdoor": [], "menu": [] },
  "menuCategories": [...],
  "exchangeRate": { "rate", "to_currency", "from_currency" },
  "businessHours": { ... },
  "openWindows": [...]
}
```

**`businessInfo` object (flat — no nested address/contact/profile_picture sub-objects):**

| Field | Type | Notes |
|-------|------|-------|
| `business_id` | int | e.g. `4130` |
| `business_name` | string | e.g. `"Ø.12"` |
| `business_type` | string | e.g. `"Restaurant"`, `"Bakery"` |
| `description` | string | Business description |
| `is_active` | bool | |
| `price_range_min` | int | e.g. `140` |
| `price_range_max` | int | e.g. `530` |
| `price_range_currency_code` | string | e.g. `"DKK"` |
| `street` | string | Flat field, e.g. `"Østerbrogade 139"` |
| `neighbourhood_name` | string | e.g. `"Østerbro"` |
| `postal_city` | string | e.g. `"København Ø"` |
| `latitude` | double | |
| `longitude` | double | |
| `google_maps_url` | string | |
| `profile_picture_url` | string | Flat field (not a nested object) |
| `website_url` | string? | |
| `instagram_url` | string? | |
| `reservation_url` | string? | |
| `general_phone` | string? | e.g. `"51 85 69 96"` |
| `tags` | string[] | e.g. `["Aperol", "Brunch"]` |

**Not present in API response** (must be computed client-side if needed): `cuisine_type`, `price_range` (string), `status_open`, `closing_time`, `address.address_line`.

**`filters` array (top-level, NOT inside businessInfo):**

Each filter object:
```json
{
  "filter_id": 475,
  "parent_id": 12,
  "filter_name": "Breakfast",
  "filter_type": "item",
  "display_order": 1,
  "has_no_subitems": false,
  "filter_category_id": 12,
  "filter_description": null,
  "is_primary_category": false,
  "filter_name_translated": "Breakfast"
}
```

Raw rows from `business_x_filter`. No server-side exclusions. Each client widget applies its own display/exclusion logic independently. **Payment options and facilities are encoded here** — payment types are filter_category_id 21 (Accepts MobilePay, cash, payment card) and 423 (VISA, MasterCard, Dankort).

**Client-side field enrichment:** `business_profile_page_v2.dart` merges top-level `filters` into the `businessInfo` map and computes `status_open`, `closing_time`, and `price_range` from `openWindows` data before storing to provider. See `_reference/PROFILE_V2_GAP_ANALYSIS.md` for details.

**`business_hours` object:** Keyed by day-of-week string `"0"` (Monday) through `"6"` (Sunday). Each day:
```json
{
  "closed": false,
  "opening_time_1": "07:30:00",
  "closing_time_1": "17:00:00",
  "opening_time_2": null,
  "closing_time_2": null,
  "opening_time_3": null, "closing_time_3": null,
  "opening_time_4": null, "closing_time_4": null,
  "opening_time_5": null, "closing_time_5": null,
  "cutoff_time_1_1": "15:00:00",
  "cutoff_type_1_1": "kitchen_close",
  "cutoff_note_1_1": null,
  "cutoff_time_1_2": null, "cutoff_type_1_2": null, "cutoff_note_1_2": null,
  "cutoff_time_2_1": null, "cutoff_type_2_1": null, "cutoff_note_2_1": null,
  "by_appointment_only": false
}
```
Up to 5 opening/closing time pairs per day. `cutoff_type` values include `"kitchen_close"`, `"last_booking"`, etc. Times are `"HH:MM:SS"` strings or `null`.

**`open_windows` array:** Pre-computed for `onlyOpen` filtering. Overnight slots are split into two entries.
```json
[
  { "day": 0, "open": 450, "close": 1020 },
  { "day": 1, "open": 450, "close": 1020 }
]
```
`day`: 0=Monday…6=Sunday. `open`/`close`: minutes since midnight (e.g. 450 = 7:30, 1020 = 17:00).

**`gallery` object:** Categorized by type: `{ interior: [], food: [], outdoor: [], menu: [] }`. Each image has `image_id`, `image_url`, `image_name`, `alt_text`, `description`, `created_at`, `updated_at`, `category_id`, `category_name`.

**`menuCategories` array:** Array of menu category objects.

**`menu_structure` array:** Each item:
```json
{
  "menu_id", "menu_title", "menu_description", "menu_display_order",
  "business_id", "menu_category_id", "category_name", "category_description",
  "category_display_order", "category_type", "is_beverage"
}
```
Ordered by `menu.display_order`, then `menu_category.display_order`. `category_type` values: `'menu_category'`, `'menu_package'`.

**`exchange_rate` object:**
```json
{ "from_currency": "DKK", "to_currency": "DKK", "rate": 1, "last_updated": "...", "language_code": "da" }
```

---

## 3. GET RESTAURANT MENU (`GET_RESTAURANT_MENU`)

**Purpose:** Fetch full menu with items, categories, and dietary availability.

**Inputs:**
| Field | Type |
|-------|------|
| `businessId` | `number` |
| `languageCode` | `string` |

**Output:**
```dart
{
  "menu_version": string,
  "menu_items": [
    {
      "menu_item_id": number,
      "item_name": string,
      "item_description": string,
      "base_price": number,
      "is_price_per_person": bool,
      "item_image_url": string?,
      "is_beverage": bool,
      "display_order": number,
      "authentic_languages": [string],  // e.g. ["da", "en"] — languages menu was written in
      "dietary_type_ids": [number],           // inherently compliant dietary types
      "dietary_type_can_be_made_ids": [number], // can be adapted to these dietary types
      "allergy_ids": [number],
      "item_modifier_groups": [...]
    }
  ],
  "categories": [...],
  "availableRestrictions": [number],          // dietary types 1,3,4,5 available (IS or CAN BE)
  "availablePreferences": [number],           // dietary types 2,6,7 available (IS or CAN BE)
  "availableAllergies": [number],
  "availableCanBeMadeRestrictions": [number], // types 1,3,4,5 available as CAN BE MADE only
  "availableCanBeMadePreferences": [number],  // types 2,6,7 available as CAN BE MADE only
}
```

**Dietary type IDs:**
- Restrictions: `1`=gluten-free, `3`=halal, `4`=lactose-free, `5`=kosher
- Preferences: `2`=pescetarian, `6`=vegan, `7`=vegetarian

---

## 4. GET FILTERS (`GET_FILTERS_FOR_SEARCH`)

**Purpose:** Fetch hierarchical filter tree + food/drink dietary types for a language and city.

**Inputs:**
| Field | Type | Notes |
|-------|------|-------|
| `language_code` | `string` | BCP-47, e.g. `"en"`, `"da"` |
| `city_id` | `string` | Always `"17"` (Copenhagen) for now. Will be set by city selector in future. |

**Output:**
```dart
{
  "filters": [FilterItem],     // Hierarchical filter tree (top-level items)
  "foodDrinkTypes": [FoodDrinkItem],
  "success": bool,
  "filterCount": number,
  "foodDrinkCount": number
}
```

**FilterItem shape:**
```dart
{
  "id": number,
  "name": string,
  "type": string,
  "parent_id": number?,
  "is_neighborhood": bool,
  "city_id": number?,
  "has_subitems": bool,
  "children": [FilterItem],    // Nested children
  "display_order": number?,
  "neighbourhood_id_1": number?,
  "neighbourhood_id_2": number?
}
```

**FoodDrinkItem shape:**
```dart
{
  "id": number,
  "name": string,
  "type": "food" | "drink",
  "has_gluten_free": bool,
  "has_halal": bool,
  "has_lactose_free": bool,
  "has_vegan": bool,
  "has_vegetarian": bool,
  "display_order": number?
}
```

---

## 5. GET EXCHANGE RATES (`GET_EXCHANGE_RATE`)

**Endpoint:** `/getExchangeRates` (plural)

**Purpose:** Fetch exchange rate from DKK to target currency.

**Inputs:**
| Field | Required | Notes |
|-------|----------|-------|
| `from_currency` | Yes | Base currency code. Always `"DKK"` for JourneyMate. |
| `to_currency` | Yes | Target currency code (e.g., `"USD"`, `"EUR"`) |

**Output:** Array with exchange rate object and metadata:
```dart
[{
  "from_currency": "DKK",
  "to_currency": "USD",
  "rate": 0.158414,
  "associated_language_code": ["en"],
  "last_updated": "2026-02-23T05:01:13.718973+00:00"
}]
```

**Usage:**
- API call: `GET /getExchangeRates?from_currency=DKK&to_currency=USD`
- Flutter: `ApiService.instance.getExchangeRate(toCurrency: 'USD')`

---

## 6. GET FILTER DESCRIPTIONS (`GET_FILTER_DESCRIPTIONS`)

**Purpose:** Fetch business-specific descriptions for each filter it has.

**Inputs:**
| Field | Type |
|-------|------|
| `businessId` | `number` |
| `languageCode` | `string` |

**Output:**
```dart
{
  "filterDescriptions": [
    { "filter_id": number, "description": string }
  ]
}
```

---

## 7. GET SINGLE MENU ITEM (`GET_SINGLE_MENU_ITEM`)

**Purpose:** Fetch one menu item in a specific language. Used for "view in original language" feature.

**Inputs:**
| Field | Type |
|-------|------|
| `menuItemId` | `number` |
| `languageCode` | `string` |

**Output:** Single `MenuItemOutput` (same shape as one item from GET_RESTAURANT_MENU):
```dart
{
  "menu_item_id", "item_name", "item_description", "base_price",
  "is_price_per_person", "item_image_url", "is_beverage", "display_order",
  "language_code", "business_id", "authentic_languages": [string],
  "dietary_type_ids": [number], "dietary_type_can_be_made_ids": [number],
  "allergy_ids": [number], "item_modifier_groups": [...]
}
```

---

## 8. GET UI TRANSLATIONS (`GET_UI_TRANSLATIONS`)

**Endpoint:** `GET /languageText`

**Purpose:** Fetch all UI translation strings for a language as a flat key-value map.

**Inputs:**
| Field | Type |
|-------|------|
| `languageCode` | `string` |

**Output:** Flat `Map<String, String>`:
```dart
{
  "allergen_1": "celery",
  "key_home": "Home",
  "search_placeholder": "Search restaurants...",
  // ... all keys for this language
}
```

Source table: `ui_translations` (columns: `translation_key`, `translation_value`, filtered by `language_code`).

---

## 9. POST ANALYTICS (`POST_ANALYTICS_TO_SUPABASE`)

**Purpose:** Track user behaviour events. Fire-and-forget — never await.

URL API Endpoint: https://wvb8ww.buildship.run/analytics

**Inputs:**
| Field | Type | Notes |
|-------|------|-------|
| `eventType` | `string` | Must be one of the 36 valid event types below |
| `deviceId` | `string` | Persistent device identifier |
| `sessionId` | `string` | Session UUID (from `AnalyticsService`) |
| `userId` | `string` | User identifier |
| `eventData` | `Map<String, dynamic>` | Event-specific data |
| `timestamp` | `string` | ISO 8601 timestamp |

**Valid event types (36):**
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

**`page_viewed` event:** Use `event_data.pageName = 'welcomePage'` for the welcome page (not `'homepage'` or `'welcomepage'`).

**Output:**
```dart
{ "success": bool, "error": string?, "eventType": string?, "timestamp": string? }
```

> Always fire analytics as `unawaited(analyticsService.track(...))`. Never block UI on analytics.

---

## 10. SUBMIT MISSING PLACE (`/missingplace`)

**Purpose:** User reports a restaurant that is missing from the app.

**URL:** `https://wvb8ww.buildship.run/missingplace`

**BuildShip mechanism:** `supabaseInsertObject` node — direct Supabase table insert into `zUserFormMissingLocation`.
No server-side transformation or validation. The input object becomes the inserted row.

**Inputs (from Flutter):**
| Field | Type | Notes |
|-------|------|-------|
| `businessName` | `string` | Required — validated non-empty in widget before send |
| `businessAddress` | `string` | Required — validated non-empty in widget before send |
| `message` | `string` | Required — validated non-empty AND ≥ 10 chars in widget |
| `languageCode` | `string` | BCP-47 code of user's active language |

**Response:** Array of inserted rows (`Prefer: return=representation`):
```json
[{ ...inserted row }]
```
Widget treats any `response.statusCode == 200` as success regardless of body.
Non-200 → error state shown with retry.

---

## 11. SUBMIT CONTACT US (`/contact`)

**Purpose:** User sends a support or general enquiry message.

**URL:** `https://wvb8ww.buildship.run/contact`

**BuildShip mechanism:** `supabaseInsertObject` node — direct Supabase table insert into `zUserFormContactUs`. BuildShip injects `"page": "contact"` hardcoded.

**Inputs (from Flutter):**
| Field | Type | Notes |
|-------|------|-------|
| `name` | `string` | Required — validated non-empty |
| `contact` | `string` | Required — validated non-empty (free-text: email or phone) |
| `subject` | `string` | Required — validated non-empty (free-text, not a dropdown) |
| `message` | `string` | Required — validated non-empty AND ≥ 10 chars |
| `languageCode` | `string` | BCP-47 code of user's active language |

**Response:** Same pattern as `/missingplace` — array of inserted rows.

---

## 12. SUBMIT FEEDBACK (`/feedbackform`)

**Purpose:** User submits app feedback with an optional topic tag and contact consent.

**URL:** `https://wvb8ww.buildship.run/feedbackform`

**BuildShip mechanism:** `supabaseInsertObject` node — direct Supabase table insert into `zUserFormShareFeedback`. BuildShip injects `"page": "shareFeedback"` hardcoded. Flutter does NOT need to send `page`.

**Inputs (from Flutter):**
| Field | Type | Notes |
|-------|------|-------|
| `topic` | `string` | Required — the **localized label string** of the selected topic chip (e.g. "Bug" or "Fejl"). Stored directly as a `text` field in Supabase. Foreign-language strings are fine. |
| `message` | `string` | Required — validated non-empty AND ≥ 10 chars |
| `allowContact` | `boolean` | Whether the user consented to be contacted |
| `name` | `string?` | Optional — only sent if `allowContact = true` and field filled |
| `contact` | `string?` | Optional — only sent if `allowContact = true` and field filled (email or phone) |
| `languageCode` | `string` | BCP-47 code of user's active language |

**Response:** Same pattern as `/missingplace` — array of inserted rows.

---

## Summary table

| # | Endpoint | Flutter inputs | Key output fields |
|---|----------|---------------|-------------------|
| 1 | SEARCH (v9) | filters, city_id, search_input, userLocation, language_code, sortBy, selectedStation, onlyOpen, page, pageSize, neighbourhood_id, shopping_area_id | documents (with matchCount/matchedFilters/missedFilters/section), activeids, scoringFilterIds, resultCount, fullMatchCount, pagination |
| 2 | GET_BUSINESS_PROFILE | businessId, language_code | businessInfo (flat), filters (top-level array), gallery (categorized), menuCategories, exchangeRate, businessHours, openWindows |
| 3 | GET_RESTAURANT_MENU | businessId, languageCode | menu_items, categories, availableRestrictions/Preferences |
| 4 | GET_FILTERS | language_code, city_id | filters (tree), foodDrinkTypes |
| 5 | GET_EXCHANGE_RATE | to_currency | rate (double) |
| 6 | GET_FILTER_DESCRIPTIONS | businessId, languageCode | filterDescriptions [{filter_id, description}] |
| 7 | GET_SINGLE_MENU_ITEM | menuItemId, languageCode | full menu item object |
| 8 | GET_UI_TRANSLATIONS | languageCode | Map<String, String> key-value pairs (table: `ui_translations`) |
| 9 | POST_ANALYTICS | eventType, deviceId, sessionId, userId, eventData, timestamp | success bool |
| 10 | SUBMIT_MISSING_PLACE (`/missingplace`) | businessName, businessAddress, message, languageCode | inserted row array |
| 11 | SUBMIT_CONTACT (`/contact`) | name, contact, subject, message, languageCode | inserted row array |
| 12 | SUBMIT_FEEDBACK (`/feedbackform`) | topic, message, allowContact, name?, contact?, languageCode | inserted row array |
