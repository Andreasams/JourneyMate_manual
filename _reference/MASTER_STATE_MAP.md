# MASTER_STATE_MAP.md
## FFAppState → Riverpod Migration Map

Source: `_flutterflow_export/lib/app_state.dart`
Generated: Phase 1 of JourneyMate migration

---

## Category Definitions

- **Global** — Persists across sessions. Stored in SecureStorage or SharedPreferences. Provider scope: app-level.
- **Session-shared** — Lives for the duration of one app session. Used by 2+ pages. Provider scope: app-level StateNotifierProvider.
- **Page-local** — Was only ever set and read on one page (FFAppState used for FlutterFlow limitations). Migrate to local ConsumerStatefulWidget state.
- **Unused/Legacy** — Not meaningfully used in any widget or action. Do not migrate; simply drop.

---

## Persisted Variables (2)

### `CityID`
- **Type:** `int`
- **Default:** `17`
- **Persistent:** Yes — `FlutterSecureStorage` (`ff_CityID`)
- **Pages that READ it:** `search_results_list_view` (custom widget), search action files
- **Pages that WRITE it:** `welcome_page_widget` (when city selected), `get_user_preference` (custom action)
- **Category:** Global
- **Riverpod target:** `cityIdProvider` (persisted StateNotifierProvider, backed by SharedPreferences)
- **Migration notes:** Default city 17 must be preserved. On first launch use 17 until user selects a different city.

---

### `translationsCache`
- **Type:** `dynamic` (JSON map — `Map<String, dynamic>`)
- **Default:** `null`
- **Persistent:** Yes — `FlutterSecureStorage` (`ff_translationsCache`)
- **Pages that READ it:** `business_profile_widget`, `contact_us_widget`, `share_feedback_widget`, `missing_place_widget`, `language_selector_button`, `currency_selector_button`, `unified_filters_widget`, `dish_expanded_info_sheet_widget`, `view_all_gallery_widget`, `modal_submit_erroneous_info_widget`, `contact_detail_widget`, `business_information_widget`
- **Pages that WRITE it:** `get_translations_with_update` (custom action)
- **Category:** Global
- **Riverpod target:** `translationsCacheProvider` (persisted StateNotifierProvider, backed by SecureStorage)
- **Migration notes:** Critical — used everywhere for dynamic translations. Must be loaded before any page renders translated text.

---

## Session-Shared Variables (26)

### `searchResults`
- **Type:** `dynamic` (JSON — array of restaurant documents)
- **Default:** `null`
- **Persistent:** No
- **Pages that READ it:** `search_results_list_view` (custom widget), `search_results_widget` (search page)
- **Pages that WRITE it:** `perform_search_and_update_state`, `perform_search_bar_update_state` (custom actions)
- **Category:** Session-shared
- **Riverpod target:** `searchStateProvider` — field `searchResults`

---

### `searchResultsCount`
- **Type:** `int`
- **Default:** `0`
- **Persistent:** No
- **Pages that READ it:** `search_results_widget` (search page), `nav_bar_widget`
- **Pages that WRITE it:** `perform_search_and_update_state`, `perform_search_bar_update_state`
- **Category:** Session-shared
- **Riverpod target:** `searchStateProvider` — field `searchResultsCount`

---

### `hasActiveSearch`
- **Type:** `bool`
- **Default:** `false`
- **Persistent:** No
- **Pages that READ it:** `search_results_widget`, `nav_bar_widget`, `check_and_reset_filter_session`
- **Pages that WRITE it:** `check_and_reset_filter_session`, `perform_search_and_update_state`, `perform_search_bar_update_state`
- **Category:** Session-shared
- **Riverpod target:** `searchStateProvider` — field `hasActiveSearch`

---

### `currentSearchText`
- **Type:** `String`
- **Default:** `''`
- **Persistent:** No
- **Pages that READ it:** `filter_overlay_widget`, `selected_filters_btns` (custom widgets)
- **Pages that WRITE it:** `perform_search_bar_update_state`, `perform_search_and_update_state`, `selected_filters_btns`
- **Category:** Session-shared
- **Riverpod target:** `searchStateProvider` — field `currentSearchText`

---

### `filtersUsedForSearch`
- **Type:** `List<int>`
- **Default:** `[]`
- **Persistent:** No
- **Pages that READ it:** `search_results_widget`, `nav_bar_widget`, `filter_overlay_widget`, `filter_titles_row`, `business_information_widget`, search action files
- **Pages that WRITE it:** `filter_overlay_widget`, `perform_search_bar_update_state`, `perform_search_and_update_state`, `selected_filters_btns`
- **Category:** Session-shared
- **Riverpod target:** `searchStateProvider` — field `filtersUsedForSearch`
- **Migration notes:** This is the active filter selection list. Drives both search and filter display.

---

### `currentFilterSessionId`
- **Type:** `String`
- **Default:** `''`
- **Persistent:** No
- **Pages that READ it:** `perform_search_bar_update_state`, `perform_search_and_update_state`, `filter_overlay_widget`, `search_results_list_view`
- **Pages that WRITE it:** `generate_and_store_filter_session_id`, `check_and_reset_filter_session`
- **Category:** Session-shared
- **Riverpod target:** `searchStateProvider` — field `currentFilterSessionId`

---

### `previousActiveFilters`
- **Type:** `List<int>`
- **Default:** `[]`
- **Persistent:** No
- **Pages that READ it:** `check_and_reset_filter_session`
- **Pages that WRITE it:** `update_previous_filter_state`, `check_and_reset_filter_session`, `perform_search_and_update_state`
- **Category:** Session-shared
- **Riverpod target:** `searchStateProvider` — field `previousActiveFilters`

---

### `previousSearchText`
- **Type:** `String`
- **Default:** `''`
- **Persistent:** No
- **Pages that READ it:** `check_and_reset_filter_session`
- **Pages that WRITE it:** `update_previous_filter_state`, `check_and_reset_filter_session`, `perform_search_and_update_state`
- **Category:** Session-shared
- **Riverpod target:** `searchStateProvider` — field `previousSearchText`

---

### `previousFilterSessionId`
- **Type:** `String`
- **Default:** `''`
- **Persistent:** No
- **Pages that READ it:** `check_and_reset_filter_session`
- **Pages that WRITE it:** `check_and_reset_filter_session`
- **Category:** Session-shared
- **Riverpod target:** `searchStateProvider` — field `previousFilterSessionId`

---

### `currentRefinementSequence`
- **Type:** `int`
- **Default:** `0`
- **Persistent:** No
- **Pages that READ it:** `check_and_reset_filter_session`
- **Pages that WRITE it:** `check_and_reset_filter_session` (increment + reset)
- **Category:** Session-shared
- **Riverpod target:** `searchStateProvider` — field `currentRefinementSequence`

---

### `lastRefinementTime`
- **Type:** `DateTime?`
- **Default:** `null`
- **Persistent:** No
- **Pages that READ it:** `check_and_reset_filter_session`
- **Pages that WRITE it:** `check_and_reset_filter_session`, `update_previous_filter_state`
- **Category:** Session-shared
- **Riverpod target:** `searchStateProvider` — field `lastRefinementTime`

---

### `mostRecentlyViewedBusiness`
- **Type:** `dynamic` (JSON — single business document)
- **Default:** `null`
- **Persistent:** No
- **Pages that READ it:** `business_profile_widget` (profile)
- **Pages that WRITE it:** `search_results_list_view` (custom widget — on card tap)
- **Category:** Session-shared
- **Riverpod target:** `businessProvider` — field `currentBusiness`

---

### `mostRecentlyViewedBusinesMenuItems`
- **Type:** `dynamic` (JSON — menu items)
- **Default:** `null`
- **Persistent:** No (note: typo "Busines" is intentional — from FlutterFlow)
- **Pages that READ it:** `menu_dishes_list_view` (custom widget)
- **Pages that WRITE it:** `menu_dishes_list_view` (custom widget — from API)
- **Category:** Session-shared
- **Riverpod target:** `businessProvider` — field `menuItems`

---

### `filtersOfSelectedBusiness`
- **Type:** `List<int>`
- **Default:** `[]`
- **Persistent:** No
- **Pages that READ it:** `business_profile_widget`
- **Pages that WRITE it:** `search_results_list_view` (when a business is selected)
- **Category:** Session-shared
- **Riverpod target:** `businessProvider` — field `businessFilterIds`

---

### `openingHours`
- **Type:** `dynamic` (JSON — opening hours data)
- **Default:** `null`
- **Persistent:** No
- **Pages that READ it:** `contact_details_widget`, `business_profile_widget`, `business_information_widget`
- **Pages that WRITE it:** `search_results_list_view`
- **Category:** Session-shared
- **Riverpod target:** `businessProvider` — field `openingHours`

---

### `mostRecentlyViewedBusinessAvailableDietaryPreferences`
- **Type:** `List<int>`
- **Default:** `[]`
- **Persistent:** No
- **Pages that READ it:** `unified_filters_widget`
- **Pages that WRITE it:** `unified_filters_widget` (from business data)
- **Category:** Session-shared
- **Riverpod target:** `businessProvider` — field `availableDietaryPreferences`

---

### `mostRecentlyViewedBusinessAvailableDietaryRestrictions`
- **Type:** `List<int>`
- **Default:** `[]`
- **Persistent:** No
- **Pages that READ it:** `unified_filters_widget`
- **Pages that WRITE it:** `unified_filters_widget` (from business data)
- **Category:** Session-shared
- **Riverpod target:** `businessProvider` — field `availableDietaryRestrictions`

---

### `filtersForUserLanguage`
- **Type:** `dynamic` (JSON — filter structure)
- **Default:** `null`
- **Persistent:** No
- **Pages that READ it:** `business_profile_widget`
- **Pages that WRITE it:** `get_filters_with_update` (custom action)
- **Category:** Session-shared
- **Riverpod target:** `filterProvider` — field `filtersForLanguage`

---

### `filterLookupMap`
- **Type:** `dynamic` (JSON map — filterId → filter data)
- **Default:** `null`
- **Persistent:** No
- **Pages that READ it:** `perform_search_bar_update_state`
- **Pages that WRITE it:** `perform_search_bar_update_state`, `get_filters_with_update`
- **Category:** Session-shared
- **Riverpod target:** `filterProvider` — field `filterLookupMap`

---

### `foodDrinkTypes`
- **Type:** `List<dynamic>`
- **Default:** `[]`
- **Persistent:** No
- **Pages that READ it:** None found
- **Pages that WRITE it:** None found
- **Category:** Unused/Legacy → drop in migration
- **Migration notes:** Not used anywhere. Was likely a precursor to `filtersForUserLanguage`. Do not migrate.

---

### `sessionStartTime`
- **Type:** `DateTime?`
- **Default:** `null`
- **Persistent:** No
- **Pages that READ it:** `search_results_list_view`, `main.dart`
- **Pages that WRITE it:** `search_results_list_view` (on init), `main.dart`
- **Category:** Session-shared
- **Riverpod target:** `analyticsProvider` — field `sessionStartTime`

---

### `menuSessionData`
- **Type:** `dynamic` (JSON — menu analytics session object)
- **Default:** `null`
- **Persistent:** No
- **Pages that READ it:** `menu_dishes_list_view`, `end_menu_session`
- **Pages that WRITE it:** `start_menu_session`, `update_menu_session_filter_metrics`, `end_menu_session`, `track_filter_reset`
- **Category:** Session-shared
- **Riverpod target:** `analyticsProvider` — field `menuSessionData`
- **Migration notes:** Complex analytics object. Port `start_menu_session` / `end_menu_session` / `update_menu_session_filter_metrics` custom actions to Riverpod notifier methods.

---

### `userCurrencyCode`
- **Type:** `String`
- **Default:** `''`
- **Persistent:** Yes (via `saveUserPreference` to SharedPreferences) — NOT via FFAppState, but via custom action
- **Pages that READ it:** `search_results_list_view`, `item_bottom_sheet_widget`, `package_bottom_sheet_widget`, `menu_package_expanded_info_sheet_widget`, `menu_dishes_list_view`, `currency_selector_button`
- **Pages that WRITE it:** `get_user_preference`, `save_user_preference`, `update_currency_for_language`, `language_and_currency_widget`
- **Category:** Session-shared (loaded from pref on launch)
- **Riverpod target:** `localizationProvider` — field `currencyCode`
- **Migration notes:** Persisted via `SharedPreferences('user_currency_code')`, not SecureStorage. Load on app init.

---

### `exchangeRate`
- **Type:** `double`
- **Default:** `0.0`
- **Persistent:** No (recalculated each session)
- **Pages that READ it:** `search_results_list_view`, `item_bottom_sheet_widget`, `package_bottom_sheet_widget`, `menu_package_expanded_info_sheet_widget`, `menu_dishes_list_view`
- **Pages that WRITE it:** `update_currency_with_exchange_rate`, `language_and_currency_widget`
- **Category:** Session-shared
- **Riverpod target:** `localizationProvider` — field `exchangeRate`

---

### `locationStatus`
- **Type:** `bool`
- **Default:** `false`
- **Persistent:** No (re-checked each session)
- **Pages that READ it:** `search_results_list_view`, `search_result_business_block_widget`, `check_location_permission`
- **Pages that WRITE it:** `request_location_permission`, `check_location_permission_and_track`, `request_location_permission_and_track`, `debug_location_status`, `location_sharing_widget`
- **Category:** Session-shared
- **Riverpod target:** `locationProvider` — field `hasPermission`

---

## Accessibility Variables (2)

### `fontScale`
- **Type:** `bool` (true = font scale > 1.1)
- **Default:** `false`
- **Persistent:** No (re-detected each session from device settings)
- **Pages that READ it:** `filter_overlay_widget`, `search_results_list_view`, `business_profile_widget`, `contact_details_widget`, `opening_hours_and_weekdays`
- **Pages that WRITE it:** `detect_accessibility_settings` (custom action), `main.dart`
- **Category:** Session-shared
- **Riverpod target:** `accessibilityProvider` — field `fontScaleLarge`

---

### `isBoldTextEnabled`
- **Type:** `bool`
- **Default:** `false`
- **Persistent:** No (re-detected each session from device settings)
- **Pages that READ it:** `main.dart`, `business_profile_widget`, `contact_detail_widget`, `opening_hours_and_weekdays`, `filter_overlay_widget`, `view_full_menu_widget`
- **Pages that WRITE it:** `detect_accessibility_settings`, `main.dart`
- **Category:** Session-shared
- **Riverpod target:** `accessibilityProvider` — field `isBoldTextEnabled`

---

## Page-Local Variables (9)

These were forced into FFAppState by FlutterFlow's architecture. In Riverpod they become
local widget state (`ConsumerStatefulWidget`).

### `CityPickerIsOpen`
- **Type:** `bool`
- **Default:** `false`
- **Category:** Page-local (search page — city picker overlay)
- **Migration:** Local `bool _cityPickerOpen` in `SearchPage` state

---

### `filterOverlayOpen`
- **Type:** `bool`
- **Default:** `false`
- **Category:** Page-local (search page — filter overlay visibility)
- **Pages that READ/WRITE it:** `filter_overlay_widget`, `search_results_widget`, `filter_titles_row`
- **Migration:** Local `bool _filterOverlayOpen` in `SearchPage` state
- **Migration notes:** Shared across the search page and its embedded custom widgets. Pass down via callback/prop, not a provider.

---

### `mostRecentlyViewedBusinessSelectedCategoryID`
- **Type:** `int`
- **Default:** `0`
- **Category:** Page-local (menu full page — which category tab is active)
- **Pages that READ/WRITE it:** `menu_dishes_list_view` only
- **Migration:** Local `int _selectedCategoryId` in `MenuFullPage` state

---

### `mostRecentlyViewedBusinessSelectedMenuID`
- **Type:** `int`
- **Default:** `0`
- **Category:** Page-local (menu full page — which menu tab is active)
- **Pages that READ/WRITE it:** `menu_dishes_list_view` only
- **Migration:** Local `int _selectedMenuId` in `MenuFullPage` state

---

### `selectedDietaryPreferenceId`
- **Type:** `int`
- **Default:** `0`
- **Category:** Page-local (business profile / menu — active dietary preference filter)
- **Pages that READ/WRITE it:** `business_profile_widget`, `unified_filters_widget`, `view_full_menu_widget`, `end_menu_session`
- **Migration:** Local `int _selectedDietaryPreferenceId` passed between business profile and menu full page
- **Migration notes:** Must be reset when navigating away from business profile.

---

### `excludedAllergyIds`
- **Type:** `List<int>`
- **Default:** `[]`
- **Category:** Page-local (business profile / menu — active allergy exclusions)
- **Pages that READ/WRITE it:** `business_profile_widget`, `menu_dishes_list_view`
- **Migration:** Local `List<int> _excludedAllergyIds` in `BusinessProfilePage` state, passed to menu

---

### `selectedDietaryRestrictionId`
- **Type:** `List<int>` (NOTE: despite singular name, this is a list)
- **Default:** `[]`
- **Category:** Page-local (business profile / menu — active restriction filters)
- **Pages that READ/WRITE it:** `business_profile_widget`, `unified_filters_widget`, `view_full_menu_widget`, `end_menu_session`
- **Migration:** Local `List<int> _selectedRestrictionIds` in `BusinessProfilePage` state, passed to menu

---

### `restaurantIsFavorited`
- **Type:** `bool`
- **Default:** `false`
- **Category:** Page-local (business profile — favorite button state)
- **Pages that READ/WRITE it:** `business_profile_widget` only
- **Migration:** Local `bool _isFavorited` in `BusinessProfilePage` state
- **Migration notes:** Favoriting is not yet backed by a real API. This is UI-only state.

---

### `visibleItemCount`
- **Type:** `int`
- **Default:** `0`
- **Category:** Page-local (business profile — count of visible menu items for "show more")
- **Pages that READ/WRITE it:** `business_profile_widget` only
- **Migration:** Local `int _visibleItemCount` in `BusinessProfilePage` state

---

## Unused / Legacy Variables (6)

These variables exist in FFAppState but are not meaningfully used in any page widget or custom action.
**Do not migrate them.** Simply do not reference them in the new app.

| Variable | Type | Note |
|----------|------|------|
| `BusinessIsOpen` | `bool` | Not referenced anywhere. Legacy. |
| `isClosed` | `bool` | Not referenced anywhere. Legacy. |
| `BusinessFeatureButtonsCount` | `int` | Not referenced anywhere. Legacy. |
| `emptyLocation` | `LatLng?` | Placeholder LatLng(0,0). Not used. |
| `foodDrinkTypes` | `List<dynamic>` | Not read or written by any page. |
| `activeSelectedTitleId` | `int` | Used only inside `filter_titles_row` widget — local widget state in FlutterFlow context. Migrate as local state in filter widget. |

> **Note on `activeSelectedTitleId`:** It IS used in `filter_titles_row.dart` to track which filter column header is active. Migrate as local state in `FilterTitlesRow` widget, not as a provider.

---

## Riverpod Provider Summary

| Provider | Owns | Persisted |
|----------|------|-----------|
| `cityIdProvider` | `CityID` | Yes — SharedPreferences |
| `translationsCacheProvider` | `translationsCache` | Yes — SecureStorage |
| `searchStateProvider` | `searchResults`, `searchResultsCount`, `hasActiveSearch`, `currentSearchText`, `filtersUsedForSearch`, `currentFilterSessionId`, `previousActiveFilters`, `previousSearchText`, `previousFilterSessionId`, `currentRefinementSequence`, `lastRefinementTime` | No |
| `businessProvider` | `mostRecentlyViewedBusiness`, `mostRecentlyViewedBusinesMenuItems`, `filtersOfSelectedBusiness`, `openingHours`, `availableDietaryPreferences`, `availableDietaryRestrictions` | No |
| `filterProvider` | `filtersForUserLanguage`, `filterLookupMap` | No |
| `localizationProvider` | `userCurrencyCode`, `exchangeRate` | currencyCode via SharedPreferences |
| `locationProvider` | `locationStatus` | No |
| `analyticsProvider` | `sessionStartTime`, `menuSessionData` | No |
| `accessibilityProvider` | `fontScale`, `isBoldTextEnabled` | No |

**Page-local state (NOT in providers):** `CityPickerIsOpen`, `filterOverlayOpen`, `mostRecentlyViewedBusinessSelectedCategoryID`, `mostRecentlyViewedBusinessSelectedMenuID`, `selectedDietaryPreferenceId`, `excludedAllergyIds`, `selectedDietaryRestrictionId`, `restaurantIsFavorited`, `visibleItemCount`, `activeSelectedTitleId`

**Not migrated (unused):** `BusinessIsOpen`, `isClosed`, `BusinessFeatureButtonsCount`, `emptyLocation`, `foodDrinkTypes`
