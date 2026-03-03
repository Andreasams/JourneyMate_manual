# business_profile_page_v2 — Gap Analysis & Implementation Decisions

**Session date:** 2026-03-03
**Status:** Research complete — ready for implementation
**Branch:** `claude/research-profile-v2-gaps-zdxNe`

---

## Actual API Response Structure (Source of Truth)

Endpoint: `GET /getBusinessProfile` — params: `language_code`, `businessId`

Top-level keys returned:

```
businessInfo      — flat business object (no nested "address" or "filters")
filters           — TOP-LEVEL array of filter objects (not inside businessInfo)
gallery           — { interior: [], food: [], outdoor: [], menu: [] }
menuCategories    — array of menu category objects
exchangeRate      — { rate, to_currency, from_currency, ... }
businessHours     — object keyed "0"–"6" per day of week
openWindows       — array of { day, open, close } in minutes from midnight
```

### businessInfo flat fields (relevant to widgets)

| Field | Type | Notes |
|-------|------|-------|
| `business_id` | int | |
| `business_name` | string | |
| `business_type` | string | e.g. `"Bakery"` |
| `description` | string | |
| `price_range_min` | int | e.g. `140` |
| `price_range_max` | int | e.g. `230` |
| `price_range_currency_code` | string | e.g. `"DKK"` |
| `street` | string | e.g. `"Østerbrogade 139"` — **flat, not nested** |
| `neighbourhood_name` | string | e.g. `"Østerbro"` |
| `postal_city` | string | e.g. `"København Ø"` |
| `latitude` | double | |
| `longitude` | double | |
| `google_maps_url` | string | |
| `profile_picture_url` | string | image URL — **flat, not nested** |
| `website_url` | string or null | |
| `instagram_url` | string or null | |
| `reservation_url` | string or null | |
| `general_phone` | string or null | e.g. `"51 85 69 96"` |

**NOT present:** `cuisine_type`, `price_range` (string), `status_open`, `closing_time`, `address.address_line` — HeroSectionWidget reads all of these and will receive empty/false for every field.

### filters array (top-level, not inside businessInfo)

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

### businessHours structure (top-level, not inside businessInfo)

Object with string keys "0"–"6" (0 = Monday). Each day:
```json
{
  "closed": false,
  "opening_time_1": "07:00:00",
  "closing_time_1": "18:00:00",
  "cutoff_*": null
}
```

---

## Investigation Area 1: API Response — Findings

### V1 vs V2 parsing code

| | V1 | V2 |
|---|---|---|
| Business object key | `jsonBody['businessInfo']` ✅ | `jsonBody['business_data']` ❌ |
| Hours key | `jsonBody['businessHours']` ✅ | `jsonBody['business_data']?['business_hours']` ❌ |
| Filters | `businessInfo['filters']` ❌ (null — filters are top-level, not nested) | `jsonBody['filter_ids']` ❌ (key doesn't exist) |

**V2 is broken for API parsing.** `businessData['business_data']` returns `null`, so `setCurrentBusiness(business: null, ...)` is called, and every widget returns `SizedBox.shrink()`. The page loads but displays nothing.

**V1 has a secondary bug:** it reads `businessInfo['filters']`, but the actual `filters` array is top-level (`jsonBody['filters']`). This means filter IDs are empty in both v1 and v2. Filter matching is currently broken in production — MatchCardWidget hides gracefully.

### What the fix looks like in _loadBusinessData()

```dart
final profileResponse = ...;
final raw = profileResponse.jsonBody as Map<String, dynamic>;

final businessInfo = raw['businessInfo'] as Map<String, dynamic>?;
final topLevelFilters = raw['filters'] as List? ?? [];    // top-level, not nested
final businessHours = raw['businessHours'] as Map<String, dynamic>? ?? {};
final openWindows = raw['openWindows'] as List? ?? [];

// Merge filters into business object so MatchCardWidget can read them
final business = {
  ...businessInfo!,
  'filters': topLevelFilters,
};

final filterIds = topLevelFilters
    .whereType<Map<String, dynamic>>()
    .map((f) => f['filter_id'] as int?)
    .whereType<int>()
    .toList();

ref.read(businessProvider.notifier).setCurrentBusiness(
  business: business,
  filterIds: filterIds,
  hours: businessHours,
);
```

This fix also restores working filter matching — a bonus v1 never had.

---

## Investigation Area 2: Filter Match Computation — Findings

`MatchCardWidget` computes filter matches **client-side on every build** from `currentBusiness['filters']` + `searchStateProvider.filtersUsedForSearch`. It does NOT consume the pre-computed `filterDescriptions` stored by v1's `setFilterDescriptions()`.

**Conclusion:**
- `_computeFilterMatchData()` is redundant — the widget recomputes the same data itself. Do not port it to v2.
- If the API parsing fix above is applied (filters merged into business object), `MatchCardWidget` will work correctly in v2 with no additional changes.
- `setFilterDescriptions()` stores data nothing reads. It is dead code and can be omitted.

---

## Investigation Area 3: Menu Session Analytics — Findings

### What startMenuSession/endMenuSession do in the provider

Both are **local state only** — no HTTP call:
```dart
void startMenuSession(int businessId) {
  state = state.copyWith(menuSessionData: MenuSessionData.initial(Uuid().v4()));
}
void endMenuSession(int businessId) {
  state = state.copyWithNullable(clearMenuSession: true);
}
```

The 11-field `MenuSessionData` accumulates interaction counts locally. Even in v1, this data was **never sent to any analytics endpoint**.

### But we WANT menu session tracking (requirement change)

The BuildShip analytics handler accepts `menu_session_started` and `menu_session_ended` as valid event types. The user has confirmed: **"for analytics WE WANT IT — even if V1 did not have it."**

V2 must:
1. Fire `menu_session_started` event after `_loadBusinessData()` succeeds (replacing/in addition to the local provider call)
2. Fire `menu_session_ended` event in `dispose()` with session duration + interaction data

See Area 5 for the complete corrected event name mapping.

---

## Investigation Area 4: Widget Swap Assessment — Findings

### 4a. HeroSectionWidget — REGRESSION (all display fields missing from API)

The widget reads these keys from `currentBusiness`, none of which exist in `businessInfo`:

| Widget reads | Actual API field | Result |
|---|---|---|
| `business['cuisine_type']` | `business_type` | shows empty string |
| `business['price_range']` (String) | `price_range_min` + `price_range_max` + currency | shows nothing |
| `business['status_open']` (bool) | not in API — must compute from `businessHours` | always shows "Lukket" |
| `business['closing_time']` (String) | not in API — must compute from `businessHours` | shows nothing |
| `business['address']['address_line']` | `street` (flat in `businessInfo`) | shows empty string |

**Fix required:** Compute the missing fields in `_loadBusinessData()` before calling `setCurrentBusiness()`, and merge them into the business map:

```dart
// status_open and closing_time: compute from openWindows
final now = DateTime.now();
final todayMinutes = now.hour * 60 + now.minute;
final todayIndex = (now.weekday - 1) % 7;  // 0=Monday
final todayWindow = (openWindows as List).firstWhereOrNull(
  (w) => w['day'] == todayIndex
);
final statusOpen = todayWindow != null &&
    todayMinutes >= (todayWindow['open'] as int) &&
    todayMinutes < (todayWindow['close'] as int);
final closingMinutes = todayWindow?['close'] as int?;
final closingTime = closingMinutes != null
    ? '${closingMinutes ~/ 60}:${(closingMinutes % 60).toString().padLeft(2, '0')}'
    : '';

// price_range: format from min/max
final priceMin = businessInfo['price_range_min'] as int?;
final priceMax = businessInfo['price_range_max'] as int?;
final currency = businessInfo['price_range_currency_code'] as String? ?? '';
final priceRange = (priceMin != null && priceMax != null)
    ? '$priceMin–$priceMax $currency'
    : '';

final business = {
  ...businessInfo,
  'filters': topLevelFilters,
  'cuisine_type': businessInfo['business_type'] ?? '',     // alias for HeroSectionWidget
  'price_range': priceRange,                               // computed string
  'status_open': statusOpen,                               // computed bool
  'closing_time': closingTime,                             // computed string
  'address': {'address_line': businessInfo['street'] ?? ''},  // expected shape
};
```

**Alternative:** Update `HeroSectionWidget` to read `business_type` directly instead of `cuisine_type`, read `price_range_min`/`price_range_max` directly, and read `street` directly. Either approach works — the computed-fields approach requires no widget change.

### 4b. QuickActionsPillsWidget — Clean upgrade ✅

Null URL handling: pills are rendered only when the URL is non-null and non-empty. If null, the pill is not shown — no error, no disabled state. Map pill is always shown.

Relevant fields (`website_url`, `reservation_url`, `general_phone`, `instagram_url`) all exist flat in `businessInfo`. The widget reads them from `businessProvider` internally — no field name mismatch.

### 4c. OpeningHoursContactWidget — Major upgrade ✅

Combines opening hours + contact info (phone, website, Instagram, booking) into one collapsible panel. Reads from `businessProvider` internally. No field mismatches — it reads `businessHours` data stored via `setCurrentBusiness(hours: ...)`.

---

## Investigation Area 5: Analytics Event Names — Findings

### BuildShip analytics schema (actual valid event types)

The BuildShip `trackAnalyticsEvent` handler accepts these event types relevant to the business profile page:

| Scenario | Correct event type |
|---|---|
| Page view | `business_profile_viewed` |
| Share button tapped | `share_button_clicked` |
| Menu session start | `menu_session_started` |
| Menu session end | `menu_session_ended` |
| About text expand/collapse | `expandable_text_toggled` |
| Contact panel open/close | `business_contact_toggled` |
| Social link tapped | `social_link_clicked` |
| Opening hours contact widget | `business_contact_toggled` |

### What v1 uses (wrong event types)

| v1 event | Correct event | Status |
|---|---|---|
| `page_viewed` + `pageName: 'businessProfile'` | `business_profile_viewed` | Wrong type name |
| `business_shared` + `businessId`/`businessName` | `share_button_clicked` + `business_id`/`business_name` | Wrong type name + camelCase keys |
| `about_expanded` / `about_collapsed` | `expandable_text_toggled` + `action: 'expanded'/'collapsed'` | Wrong event pattern |
| `report_link_tapped` | Acceptable — use as-is | Not in schema but fire-and-forget |
| `startMenuSession` (local only) | `menu_session_started` (POST to analytics) | Local state only in v1 |
| `endMenuSession` (local only) | `menu_session_ended` (POST to analytics) | Local state only in v1 |

### What v2 uses (partially wrong)

| v2 event | Correct event | Status |
|---|---|---|
| `page_viewed` + `page_name: 'businessProfile'` | `business_profile_viewed` | Wrong type name |
| `business_profile_shared` + `business_id`/`business_name` | `share_button_clicked` | Wrong type name |
| `business_profile_session_end` + `session_duration_seconds` | Superseded by `menu_session_ended` | Replace with schema event |
| `about_expanded` / `about_collapsed` | `expandable_text_toggled` | Wrong event pattern |
| `business_info_button_tapped` | Not in schema — fire-and-forget acceptable | Low risk |

### Correct event payloads for v2

```dart
// Page view — call after _loadBusinessData() succeeds
ApiService.instance.postAnalytics(
  eventType: 'business_profile_viewed',
  eventData: {
    'business_id': businessId,
    'business_name': businessName,
  },
);

// Share
ApiService.instance.postAnalytics(
  eventType: 'share_button_clicked',
  eventData: {
    'business_id': businessId,
    'business_name': businessName,
  },
);

// Menu session start — call after data loads
ApiService.instance.postAnalytics(
  eventType: 'menu_session_started',
  eventData: {
    'business_id': businessId,
  },
);

// Menu session end — call in dispose()
ApiService.instance.postAnalytics(
  eventType: 'menu_session_ended',
  eventData: {
    'business_id': businessId,
    'session_duration_seconds': duration.inSeconds,
  },
);

// About text expand/collapse
ApiService.instance.postAnalytics(
  eventType: 'expandable_text_toggled',
  eventData: {
    'action': _aboutExpanded ? 'expanded' : 'collapsed',
    'text_id': 'about',
    'business_id': businessId,
  },
);

// Contact panel open/close (OpeningHoursContactWidget internal)
ApiService.instance.postAnalytics(
  eventType: 'business_contact_toggled',
  eventData: {
    'business_id': businessId,
  },
);
```

---

## Decision Matrix (Final Answers)

| Question | Answer |
|---|---|
| Does the API return `businessInfo` or `business_data`? | **`businessInfo`** — v2 reads wrong key |
| Does the API return filter objects (with names) or just IDs? | **Filter objects** — at top level (`jsonBody['filters']`), not inside `businessInfo` |
| Is MatchCardWidget broken in v2? | **Effectively hidden** (not broken) — `currentBusiness` is null due to wrong key. Fix the API key and filter merge; MatchCardWidget works without `_computeFilterMatchData()` |
| Does `startMenuSession` post to BuildShip? | **No** — local state only. In v1, menu session data was never sent. |
| Is menu session tracking required or droppable? | **Required** — user has confirmed `menu_session_started`/`menu_session_ended` events must be sent via analytics API |
| Do `cuisine_type`, `price_range`, `status_open`, `closing_time`, `address_line` exist in API response? | **No** — all must be computed/mapped from actual API fields before storing |
| Does `QuickActionsPillsWidget` handle null URLs gracefully? | **Yes** — pills simply don't render. No errors. |
| Are analytics event names consumed by downstream systems? | **Yes** — BuildShip `trackAnalyticsEvent` validates against an allowlist. `page_viewed`/`business_shared`/`business_profile_shared` are **not in the allowlist** and will be rejected with `Invalid event type` error |

---

## What the Next Session Must Fix (Priority Order)

### Bug 1 — Wrong API keys (BLOCKING — page shows nothing)

In `business_profile_page_v2.dart`, `_loadBusinessData()`:
- Change `businessData['business_data']` → `businessData['businessInfo']`
- Change `businessData['filter_ids']` → top-level `businessData['filters']` (parse to IDs)
- Change `businessData['business_data']?['business_hours']` → `businessData['businessHours']`

### Bug 2 — HeroSectionWidget field mismatches (VISUAL — hero shows empty)

Before calling `setCurrentBusiness()`, compute and inject the expected fields into the business map:
- `cuisine_type` ← `business_type`
- `price_range` ← format from `price_range_min`, `price_range_max`, `price_range_currency_code`
- `status_open` ← compute from `openWindows` and current time
- `closing_time` ← compute from `openWindows` today's close time
- `address.address_line` ← `street`

### Bug 3 — Wrong analytics event names (SILENT FAILURE — events rejected by BuildShip)

| Replace | With |
|---|---|
| `page_viewed` + pageName | `business_profile_viewed` |
| `business_profile_shared` | `share_button_clicked` |
| `business_profile_session_end` | `menu_session_ended` |
| `about_expanded`/`about_collapsed` | `expandable_text_toggled` + `action` field |

### Addition 1 — Menu session tracking (NEW — never worked in v1)

Add `menu_session_started` fire-and-forget call after data loads.
Add `menu_session_ended` call in `dispose()` with `session_duration_seconds`.

### Cleanup — Dead code not worth porting

- `_computeFilterMatchData()` — do not port; MatchCardWidget computes the same data internally
- `setFilterDescriptions()` — nothing reads this; omit from v2
- `startMenuSession()`/`endMenuSession()` provider calls — replace with analytics API calls above

---

## Router Swap (One Line)

`journey_mate/lib/router/app_router.dart` line 7 + line 47:

```dart
// Before
import '../pages/business_profile/business_profile_page.dart';
...
return BusinessProfilePage(businessId: businessId);

// After
import '../pages/business_profile/business_profile_page_v2.dart';
...
return BusinessProfilePageV2(businessId: businessId);
```

No other files need changing to perform the swap.
