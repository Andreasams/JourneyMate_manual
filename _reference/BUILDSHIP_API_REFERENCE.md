# BuildShip API Reference

Source: `_reference/_buildship/` — actual BuildShip node scripts
All endpoints call BuildShip, which mediates all Supabase/Typesense access.
**No direct Supabase SDK calls from Flutter.**

---

## 1. SEARCH (`SEARCH_SCRIPT_GENERATOR`)

**Purpose:** Full-text + filter search of restaurants via Typesense.

**Inputs (from Flutter):**
| Field | Type | Notes |
|-------|------|-------|
| `filters` | `number[]` | Active filter IDs. Regular + composite (6-digit 592xxx–602xxx) separated internally. |
| `city_id` | `string` | Always `"17"` (Copenhagen) for now. |
| `search_input` | `string` | Free text. Empty/null → `'*'` (match all). |
| `userLocation` | `string` | Flutter LatLng string: `"LatLng(lat: 55.6761, lng: 12.5683)"`. `null` if no permission. |
| `language_code` | `string` | BCP-47, e.g. `"en"`, `"da"`. |
| `hasTrainStationFilter` | `boolean` | `true` if a train station filter ID is selected. |
| `trainStationFilterId` | `number?` | Filter ID ≥ 10000 for train station (offset applied internally). |

> BuildShip injects `host`, `apiKey`, `supabaseUrl`, `supabaseKey` from environment — Flutter never sends these.

**Output:**
```dart
{
  "documents": [...],    // List of restaurant documents (max 10)
  "activeids": [1,2,3],  // Union of all filter IDs present in result set
  "resultCount": 10      // Total results returned
}
```

**Each document includes:**
- `business_id`, `business_name`, `street`, `neighbourhood_name`
- `business_type` (normalized from `business_type_{lang}`)
- `tags` (normalized from `tags_{lang}`)
- `tags_en`, `tags_da` (always retained)
- `filters: number[]` — filter IDs on this business
- `dietary_menu_filters: string[]` — composite dietary filter IDs
- `city_id`, `is_active`, `latitude`, `longitude`, `location`

**Sorting priority:** train station coords > user GPS > alphabetical by `business_name`

**Filter logic:**
- Regular filters: `filters:{id} && filters:{id}`
- Composite (6-digit): `dietary_menu_filters:{id}`

---

## 2. GET BUSINESS PROFILE (`GET_BUSINESS_PROFILE`)

**Purpose:** Fetch complete business info including gallery and menu structure.

**Inputs:**
| Field | Type | Notes |
|-------|------|-------|
| `businessId` | `number` | Integer business ID |
| `languageCode` | `string` | BCP-47, e.g. `"en"` |

**Output:**
```dart
{
  "businessInfo": {
    // Core
    "business_id", "business_name", "is_active", "business_type", "tags",
    "description", "last_reviewed_at",
    // Price range (numerical)
    "price_range_min": number,
    "price_range_max": number,
    "price_range_currency_code": string,
    // Address
    "street", "postal_code", "city_id", "city_name", "postal_city",
    "neighbourhood_name", "latitude", "longitude", "location",
    "google_maps_url",
    // Profile picture
    "profile_picture_url", "profile_picture_alt_text",
    // Contact
    "website_url", "facebook_url", "instagram_url", "reservation_url",
    "general_phone", "reservation_phone", "general_email", "reservation_email",
    // Brand/Company
    "brand_id", "brand_name", "company_id", "company_name"
  },
  "gallery": {
    "interior": ["url1", ...],  // Interior photos
    "food": ["url1", ...],      // Food photos
    "outdoor": ["url1", ...],   // Outdoor photos
    "menu": ["url1", ...]       // Menu photos
  },
  "menuCategories": [...],      // Menu structure (categories)
  "exchangeRate": {             // Exchange rate data (nullable)
    "from_currency", "to_currency", "rate", "language_code"
  }
}
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

**Purpose:** Fetch hierarchical filter tree + food/drink dietary types for a language.

**Inputs:**
| Field | Type |
|-------|------|
| `languageCode` | `string` |

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

## 5. GET EXCHANGE RATE (`GET_EXCHANGE_RATE`)

**Purpose:** Fetch exchange rate from DKK to user's currency.

**Inputs:**
| Field | Notes |
|-------|-------|
| `to_currency` | User's currency code, e.g. `"EUR"`, `"USD"` |

> `from_currency` is hardcoded to `"DKK"` in BuildShip.

**Output:** Array of rows from `ExchangeRate` table:
```dart
[{
  "from_currency": "DKK",
  "to_currency": "EUR",
  "rate": 0.134  // multiply DKK price by this to get EUR
}]
```

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

Source table: `flutterflowtranslations` (columns: `translation_key`, `translation_value`, filtered by `language_code`).

---

## 9. POST ANALYTICS (`POST_ANALYTICS_TO_SUPABASE`)

**Purpose:** Track user behaviour events. Fire-and-forget — never await.

**Inputs:**
| Field | Type | Notes |
|-------|------|-------|
| `eventType` | `string` | Must be one of the 30 valid event types below |
| `deviceId` | `string` | Persistent device identifier |
| `sessionId` | `string` | Session UUID (from `AnalyticsService`) |
| `userId` | `string` | User identifier |
| `eventData` | `Map<String, dynamic>` | Event-specific data |
| `timestamp` | `string` | ISO 8601 timestamp |

**Valid event types (30):**
```
session_start, session_end, session_heartbeat,
filter_applied, filter_session_ended, filter_session_started,
business_clicked, business_profile_viewed,
menu_filter_applied, menu_filters_reset, menu_session_started, menu_session_ended,
menu_item_clicked, menu_package_clicked, menu_filter_impact, menu_scroll_depth,
category_description_viewed, page_viewed,
location_permission_changed, location_settings_opened, location_settings_error,
allergen_filter_toggled, dietary_restriction_toggled, dietary_preference_toggled,
image_gallery_opened, image_gallery_navigation, image_gallery_closed,
filter_info_clicked, currency_changed, language_changed,
gallery_tab_opened, gallery_tab_changed,
expandable_text_toggled, social_link_clicked, share_button_clicked, business_contact_toggled
```

**Output:**
```dart
{ "success": bool, "error": string?, "eventType": string?, "timestamp": string? }
```

> Always fire analytics as `unawaited(analyticsService.track(...))`. Never block UI on analytics.

---

## 10. SUBMIT MISSING PLACE (`/missingplace`)

**Purpose:** User reports a restaurant that is missing from the app.

**BuildShip mechanism:** `supabaseInsertObject` node — direct Supabase table insert.
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

**BuildShip mechanism:** `supabaseInsertObject` node — direct Supabase table insert.

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

**BuildShip mechanism:** `supabaseInsertObject` node — direct Supabase table insert.

**Inputs (from Flutter):**
| Field | Type | Notes |
|-------|------|-------|
| `topic` | `string` | Required — the **localized label string** of the selected topic chip (e.g. "Bug" or "Fejl"). Stored directly as a `text` field in Supabase. Foreign-language strings are fine. |
| `message` | `string` | Required — validated non-empty AND ≥ 10 chars |
| `allowContact` | `boolean` | Whether the user consented to be contacted |
| `name` | `string?` | Optional — only sent if `allowContact = true` and field filled |
| `contact` | `string?` | Optional — only sent if `allowContact = true` and field filled (email or phone) |
| `languageCode` | `string` | BCP-47 code of user's active language |

**Note on `pageName`:** `FeedbackFormWidget` receives a `pageName` prop (`'shareFeedback'`) but does
NOT currently include it in the request body. It is available for future routing if needed.

**Response:** Same pattern as `/missingplace` — array of inserted rows.

---

## Summary table

| # | Endpoint | Flutter inputs | Key output fields |
|---|----------|---------------|-------------------|
| 1 | SEARCH | filters, city_id, search_input, userLocation, language_code | documents, activeids, resultCount |
| 2 | GET_BUSINESS_PROFILE | businessId, languageCode | businessInfo, gallery, menuCategories, exchangeRate |
| 3 | GET_RESTAURANT_MENU | businessId, languageCode | menu_items, categories, availableRestrictions/Preferences |
| 4 | GET_FILTERS | languageCode | filters (tree), foodDrinkTypes |
| 5 | GET_EXCHANGE_RATE | to_currency | rate (double) |
| 6 | GET_FILTER_DESCRIPTIONS | businessId, languageCode | filterDescriptions [{filter_id, description}] |
| 7 | GET_SINGLE_MENU_ITEM | menuItemId, languageCode | full menu item object |
| 8 | GET_UI_TRANSLATIONS | languageCode | Map<String, String> key-value pairs |
| 9 | POST_ANALYTICS | eventType, deviceId, sessionId, userId, eventData, timestamp | success bool |
| 10 | SUBMIT_MISSING_PLACE (`/missingplace`) | businessName, businessAddress, message, languageCode | inserted row array |
| 11 | SUBMIT_CONTACT (`/contact`) | name, contact, subject, message, languageCode | inserted row array |
| 12 | SUBMIT_FEEDBACK (`/feedbackform`) | topic, message, allowContact, name?, contact?, languageCode | inserted row array |
| 9 | POST_ANALYTICS | eventType, deviceId, sessionId, userId, eventData, timestamp | success bool |
