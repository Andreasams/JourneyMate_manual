# BuildShip API Reference

**Working on a specific task?** See **CLAUDE.md → Task-Based Navigation Guide** (Scenario 3: Integrating with BuildShip API) for targeted reading. Otherwise, browse the complete API contracts below.

Source: `_reference/_buildship/` — actual BuildShip node scripts
All endpoints call BuildShip, which mediates all Supabase/Typesense access.
**No direct Supabase SDK calls from Flutter.**

---

## 1. SEARCH (`SEARCH_SCRIPT_GENERATOR`)

**Purpose:** Full-text + filter search of restaurants via Typesense. Fetches up to 250 results from Typesense, then applies open-only filtering, match categorisation, and pagination in BuildShip JS.

**Inputs (from Flutter):**
| Field | Type | Notes |
|-------|------|-------|
| `filters` | `number[]` | Active filter IDs sent to Typesense for pre-filtering. Regular + composite (6-digit 592xxx–602xxx) separated internally. |
| `filtersUsedForSearch` | `number[]` | User's active need IDs for match scoring. Compared against each document's `filters` array. When empty, all results treated as full match. |
| `city_id` | `string` | Always `"17"` (Copenhagen) for now. |
| `search_input` | `string` | Free text. Empty/null → `'*'` (match all). |
| `userLocation` | `string` | Flutter LatLng string: `"LatLng(lat: 55.6761, lng: 12.5683)"`. `null` if no permission. |
| `language_code` | `string` | BCP-47, e.g. `"en"`, `"da"`. |
| `sortBy` | `string` | One of: `'match'`, `'nearest'`, `'station'`, `'price_low'`, `'price_high'`, `'newest'`. Default: `'match'`. |
| `sortOrder` | `string` | `'asc'` or `'desc'`. Default: `'desc'`. |
| `selectedStation` | `number` | Station filter ID (numeric). Required when `sortBy='station'`. IDs ≥ 10000 have 10000 offset applied internally. Looked up in `FilterTrainStation` by `train_station_id`. |
| `onlyOpen` | `boolean` | When `true`, filter out closed businesses using pre-computed `open_windows`. Applied before categorisation. Default: `false`. |
| `category` | `string` | Which match tier to return: `'full'`, `'partial'`, `'other'`, `'all'`. `'all'` returns all results as a flat sorted list without bucketing (match metadata still added per document). Default: `'all'`. |
| `page` | `number` | 1-indexed page within the requested category. Default: `1`. |
| `pageSize` | `number` | Results per page. Recommended: `20`. Default: `20`. |

> BuildShip injects `host`, `apiKey`, `supabaseUrl`, `supabaseKey` from environment — Flutter never sends these.

**Sort options:**
| `sortBy` | Logic |
|----------|-------|
| `'match'` | `_eval()` scores full=3, partial=1, other=0 in Typesense; distance ASC tiebreaker if `userLocation` present |
| `'nearest'` | Distance from `userLocation` ASC |
| `'station'` | Distance from `selectedStation` coords ASC (looks up lat/lng from `FilterTrainStation` by `train_station_id`) |
| `'price_low'` | `price_range_min` ASC |
| `'price_high'` | `price_range_max` DESC |
| `'newest'` | `created_at` DESC (uses `BusinessInfo.created_at`) |

**Match categorisation:**
- `'full'`: `matchCount === filtersUsedForSearch.length` (all needs met)
- `'partial'`: exactly 1 need missing
- `'other'`: 2+ needs missing
- When `filtersUsedForSearch` is empty OR `category === 'all'`: skip bucketing — all results returned as flat list with match metadata; Flutter renders section headers client-side

**Output:**
```json
{
  "documents": [...],
  "activeids": [1, 2, 3],
  "scoringFilterIds": [466, 83],
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
`nextCategory` is non-null only when a specific category is exhausted: `'full'→'partial'`, `'partial'→'other'`, `'other'→null`. Always `null` when `category === 'all'`.

**Each document includes:**
- `business_id`, `business_name`, `street`, `neighbourhood_name`, `postal_code`, `postal_city`
- `business_type` (normalised from `business_type_{lang}`)
- `tags` (normalised from `tags_{lang}`), `tags_en`, `tags_da` (always retained)
- `filters: number[]` — filter IDs on this business
- `dietary_menu_filters: string[]` — composite dietary filter IDs
- `city_id`, `is_active`, `latitude`, `longitude`, `location`
- `profile_picture_url`
- `price_range_min`, `price_range_max`, `price_range`
- `created_at`, `last_reviewed_at`
- `brand_id`, `company_id`, `typesense_id`, `business_type_id`
- `open_windows: [{day, open, close}]` — pre-computed hours windows (travels with document, not indexed by Typesense)
- `matchCount: number` — how many of `filtersUsedForSearch` this business has
- `matchedFilters: number[]` — which filter IDs matched
- `missedFilters: number[]` — which filter IDs are absent

---

## 2. GET BUSINESS PROFILE (`GET_BUSINESS_PROFILE`)

**Purpose:** Fetch complete business info including hours, gallery, and menu structure via RPC `get_business_complete_info`.

**Inputs:**
| Field | Type | Notes |
|-------|------|-------|
| `businessId` | `number` | Integer business ID |
| `language_code` | `string` | BCP-47, e.g. `"en"`, `"da"` |

**Output (top-level):**
```json
{
  "success": true,
  "business_profile": { ... },
  "gallery": [...],
  "menu_structure": [...],
  "exchange_rate": { ... },
  "business_hours": { ... },
  "open_windows": [...],
  "language_code": "da",
  "retrieved_at": "2026-02-20T18:32:07.584Z"
}
```

**`business_profile` object:**
```json
{
  "business_id": 4130,
  "business_name": "Ø.12",
  "business_type": "Restaurant",
  "description": "...",
  "is_active": true,
  "typesense_id": 33,
  "last_reviewed_at": "2025-11-05T14:05:57Z",
  "price_range_min": 290,
  "price_range_max": 530,
  "price_range_currency_code": "DKK",
  "tags": ["Aperol", "Brunch", ...],
  "address": {
    "address_id", "street", "postal_code", "city_id", "city_name",
    "postal_city", "neighbourhood_name", "latitude", "longitude",
    "location": [lat, lng], "google_maps_url"
  },
  "profile_picture": {
    "business_profile_picture_id", "url", "name", "alt_text", "created_at", "updated_at"
  },
  "contact": {
    "website_url", "facebook_url", "instagram_url", "reservation_url",
    "general_phone", "reservation_phone", "general_email", "reservation_email"
  },
  "brand": { "brand_id", "brand_name" },
  "company": { "company_id", "company_name" },
  "filters": [
    { "filter_id": 141, "filter_name": "Accepts MobilePay", "filter_category_id": 21 },
    { "filter_id": 425, "filter_name": "VISA", "filter_category_id": 423 },
    ...
  ]
}
```

**`filters` in `business_profile`:** Raw rows from `business_x_filter`. No server-side exclusions. Each client widget applies its own display/exclusion logic independently. **Payment options and facilities are encoded here** — payment types are filter_category_id 21 (Accepts MobilePay, cash, payment card) and 423 (VISA, MasterCard, Dankort).

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

**`gallery` array:** Flat list of image objects, each with `image_id`, `image_url`, `image_name`, `alt_text`, `description`, `created_at`, `updated_at`, `category_id`, `category_name`. Category IDs: 1=Interior, 2=Outdoor, 3=Food, 4=Menu.

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
| 1 | SEARCH | filters, filtersUsedForSearch, city_id, search_input, userLocation, language_code, sortBy, sortOrder, selectedStation, onlyOpen, category, page, pageSize | documents (with matchCount/matchedFilters/missedFilters), activeids, scoringFilterIds, resultCount, pagination |
| 2 | GET_BUSINESS_PROFILE | businessId, language_code | business_profile (incl. filters), gallery, menu_structure, exchange_rate, business_hours, open_windows |
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
