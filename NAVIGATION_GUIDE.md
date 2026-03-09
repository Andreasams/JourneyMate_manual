# JourneyMate — Task-Based Navigation Guide

**Quick links:** [← Back to CLAUDE.md](CLAUDE.md) | [ARCHITECTURE.md](ARCHITECTURE.md) | [DESIGN_SYSTEM_flutter.md](DESIGN_SYSTEM_flutter.md)

---

**Working on a specific task?** Use this guide to jump directly to relevant sections instead of reading all 4,850 lines of documentation.

Each scenario below provides:
- ✅ **Targeted reading list** (4-6 critical sections, 10-30 minutes)
- ⚠️ **Critical warnings** (common pitfalls to avoid)
- 📁 **Reference files** (actual codebase examples to follow)

**Expected impact:** Reduce time-to-first-productive-code from 60 minutes to 10-30 minutes for common tasks.

---

## 1. Adding or Modifying a Page
**Estimated reading time:** 20 minutes

**Read these sections:**
1. **ARCHITECTURE.md** → Widget Patterns → Self-Contained ConsumerWidget (lines 356-401)
2. **ARCHITECTURE.md** → Widget Patterns → Page Wrapper Pattern (lines 402-467)
3. **ARCHITECTURE.md** → Widget Patterns → Cross-Page Widget Reuse Pattern (lines 503-524) — if sharing widgets across pages
4. **ARCHITECTURE.md** → State Management → When to Use What (lines 156-163)
5. **ARCHITECTURE.md** → State Management → Page-Local State (lines 249-292)
6. **DESIGN_SYSTEM_flutter.md** → Quick Start (lines 16-36)
7. **ARCHITECTURE.md** → Common Pitfalls #8, #11, #13, #14, #20, #22 (lines 2149-2162, 2194-2278, 2394-2449, 2450-2489, 2734-2778, 2833-2892)
8. **ARCHITECTURE.md** → Location Permission Pattern (lines 1524-1602) — if page needs location UI
9. **ARCHITECTURE.md** → Swipe Gesture Patterns (lines 959-1304) — if page has dismissible UI elements

**Critical warnings:**
- ⚠️ Page-local UI state (loading flags, TextControllers, ScrollControllers) → local State variables, NOT providers
- ⚠️ Never pass language/translations/dimensions as props to widgets (self-contained pattern)
- ⚠️ Use `context.mounted` after async operations to prevent ref access after unmount
- ⚠️ Save notifier with `ref.read()` BEFORE any `await` in pre-loading patterns
- ⚠️ Use `enableLocation()` for user-facing "Enable Location" buttons (NOT `requestPermission()`)
- ⚠️ For swipe gestures with tappable children: use `HitTestBehavior.translucent` (Pitfall #15)
- ⚠️ **Navigation to full pages: use `context.push()` (NOT `context.go()`)** — go() clears navigation stack and breaks back button (Pitfall #22)
- ⚠️ **Cross-page widget reuse:** If two pages show same business data, extract to shared widget — don't duplicate status computation (commit `9e75f0f`)

**Reference files:**
- `journey_mate/lib/pages/search/search_page.dart` — Full page pattern with local state + provider reads
- `journey_mate/lib/pages/settings/contact_us_page.dart` — Page wrapper pattern (analytics + navigation)
- `_reference/PROVIDERS_REFERENCE.md` — Which providers to read from pages

---

## 2. Creating a New Shared Widget
**Estimated reading time:** 20 minutes

**Read these sections:**
1. **ARCHITECTURE.md** → Widget Patterns → Self-Contained ConsumerWidget (lines 356-401)
2. **ARCHITECTURE.md** → Widget Patterns → ConsumerWidget vs ConsumerStatefulWidget (lines 468-502)
3. **DESIGN_SYSTEM_flutter.md** → Colors (lines 39-90)
4. **DESIGN_SYSTEM_flutter.md** → Spacing (lines 93-130)
5. **DESIGN_SYSTEM_flutter.md** → Typography (lines 177-265)
6. **ARCHITECTURE.md** → Common Pitfall #8, #13, #15, #16, #20, #23 (lines 2149-2162, 2394-2449, 2490-2532, 2533-2583, 2734-2778, 2893-2959)
7. **ARCHITECTURE.md** → Swipe Gesture Patterns (lines 959-1304) — if widget has dismissible/swipeable UI

**Critical warnings:**
- ⚠️ Widgets read providers/context internally — NO infrastructure props (language, translations, dimensions)
- ⚠️ All colors from `AppColors` (no raw hex: `Color(0xFF...)`)
- ⚠️ All spacing from `AppSpacing` (no magic numbers: `16.0`)
- ⚠️ All typography from `AppTypography` (no inline `TextStyle(...)`)
- ⚠️ For swipe gestures: use adaptive thresholds (percentage, not fixed pixels) — see Pitfall #16
- ⚠️ **For expand/collapse animations: use `AnimatedOpacity` (NOT `AnimatedSize`)** — AnimatedSize causes jankiness with complex children (Pitfall #23)

**Reference files:**
- `journey_mate/lib/pages/settings/widgets/contact_us_form_widget.dart` — Self-contained form widget
- `journey_mate/lib/widgets/shared/filter_overlay_widget.dart` — Complex widget with local state

---

## 3. Integrating with BuildShip API
**Estimated reading time:** 15 minutes

**Read these sections:**
1. **ARCHITECTURE.md** → API Service Pattern (lines 1307-1441)
2. **_reference/BUILDSHIP_API_REFERENCE.md** → Endpoint you need (e.g., lines 11-131 for SEARCH v9.2)
3. **ARCHITECTURE.md** → State Management → AsyncNotifierProvider (lines 209-248)
4. **ARCHITECTURE.md** → Pre-Loading Architecture (lines 1444-1521)
5. **ARCHITECTURE.md** → Common Pitfall #11 (lines 2194-2278)
6. **ARCHITECTURE.md** → Common Pitfall #25 (lines 3048-3111)
7. **ARCHITECTURE.md** → Common Pitfall #27 (unsafe JSON numeric casting, lines 3141-3165)

**Critical warnings:**
- ⚠️ All backend calls through `ApiService.instance` singleton — NO direct Supabase SDK
- ⚠️ Check `response.succeeded` and `response.jsonBody != null` before accessing data
- ⚠️ Save notifier with `ref.read()` BEFORE any `await` to prevent ref-after-unmount bugs
- ⚠️ Use `ApiCallResponse` wrapper for all responses
- ⚠️ Pass full API response Maps to providers if downstream consumers need multiple keys (Pitfall #25)
- ⚠️ **JSON numeric casting:** Use `(as num?)?.toDouble()` not `as double?` — Dart JSON decoder returns `int` for whole numbers, causing TypeError (Pitfall #27)

**Reference files:**
- `journey_mate/lib/services/api_service.dart` — All 13 BuildShip endpoints
- `journey_mate/lib/providers/search_providers.dart` — API integration example
- `_reference/BUILDSHIP_API_REFERENCE.md` — Complete API contracts

---

## 4. Adding or Updating Translations
**Estimated reading time:** 10 minutes

**Read these sections:**
1. **ARCHITECTURE.md** → Translation System (lines 1605-1748)
2. **ARCHITECTURE.md** → Philosophy → Single Source of Truth for Translations (lines 61-67)
3. **_reference/BUILDSHIP_API_REFERENCE.md** → GET /languageText (search for "languageText")

**Critical warnings:**
- ⚠️ All text via `td(ref, 'key')` function — NO hardcoded strings
- ⚠️ 100% dynamic from Supabase `ui_translations` table
- ⚠️ If key missing, `td()` returns key name and logs warning
- ⚠️ Language changes trigger full app rebuild via `localeProvider`

**Reference files:**
- `journey_mate/lib/services/translation_service.dart` — `td()` function implementation
- `journey_mate/lib/providers/app_providers.dart` — `translationsCacheProvider`

---

## 5. Modifying State Management (Providers)
**Estimated reading time:** 25 minutes

**Read these sections:**
1. **ARCHITECTURE.md** → State Management → When to Use What (lines 156-163)
2. **ARCHITECTURE.md** → State Management → Provider Catalog (lines 165-179)
3. **ARCHITECTURE.md** → State Management → Riverpod 3.x Patterns (lines 181-351)
4. **_reference/PROVIDERS_REFERENCE.md** → Full provider details (entire file)
5. **ARCHITECTURE.md** → Provider Initialization Order (lines 3345-3369)
6. **ARCHITECTURE.md** → Common Pitfall #11 (lines 2194-2278)
7. **ARCHITECTURE.md** → Location Permission Pattern (lines 1524-1602) — if working with locationProvider
8. **ARCHITECTURE.md** → Atomic State Updates (lines 294-322) — when updating dependent state fields
9. **ARCHITECTURE.md** → ref.listen for Async Data Reactivity (lines 323-351) — when reacting to async data arrival

**Critical warnings:**
- ⚠️ Global/session state → `NotifierProvider` or `AsyncNotifierProvider`
- ⚠️ Page-local UI state → local State variables in `ConsumerStatefulWidget`
- ⚠️ NO FFAppState, NO Provider, NO StateNotifier (deprecated Riverpod 2.x)
- ⚠️ Save notifier BEFORE any `await` to prevent ref-after-unmount bugs
- ⚠️ Provider initialization order MUST match `main.dart` sequence

**Reference files:**
- `journey_mate/lib/providers/search_providers.dart` — NotifierProvider pattern
- `journey_mate/lib/providers/filter_providers.dart` — AsyncNotifierProvider pattern
- `_reference/PROVIDERS_REFERENCE.md` — Complete catalog of all 8 providers

---

## 6. Implementing a Form
**Estimated reading time:** 20 minutes

**Read these sections:**
1. **ARCHITECTURE.md** → Widget Patterns → Self-Contained ConsumerWidget (lines 356-401)
2. **ARCHITECTURE.md** → State Management → Page-Local State (lines 249-292)
3. **DESIGN_SYSTEM_flutter.md** → Input Decorations (search for "AppInputDecorations")
4. **DESIGN_SYSTEM_flutter.md** → Button Styles (search for "AppButtonStyles")
5. **ARCHITECTURE.md** → API Service Pattern (lines 1307-1441)
6. **ARCHITECTURE.md** → Common Pitfall #8 (lines 2149-2162)
7. **ARCHITECTURE.md** → Common Pitfall #11 Variation B (lines 2194-2278)

**Critical warnings:**
- ⚠️ Form state (TextEditingController, validation) → local State variables, NOT providers
- ⚠️ Widget reads language/translations internally — NO props
- ⚠️ Use `AppInputDecorations.standard()` for consistent input styling
- ⚠️ Dispose controllers in `dispose()` method
- ⚠️ Use `context.mounted` after async submit operations
- ⚠️ If syncing state in `dispose()`, save notifier in `initState()` (Pitfall #11 Variation B)
- ⚠️ Form page pattern: Section titles use w600 override, subtitles 14px/w300, placeholders 14px (see DESIGN_SYSTEM_flutter.md)

**Reference files:**
- `journey_mate/lib/pages/settings/widgets/contact_us_form_widget.dart` — Complete form pattern
- `journey_mate/lib/pages/settings/widgets/feedback_form_widget.dart` — Form with dropdown

---

## 7. Changing Design Tokens
**Estimated reading time:** 15 minutes

**Read these sections:**
1. **DESIGN_SYSTEM_flutter.md** → Colors (lines 39-92)
2. **DESIGN_SYSTEM_flutter.md** → Spacing (lines 93-130)
3. **DESIGN_SYSTEM_flutter.md** → Typography (lines 177-265)
4. **DESIGN_SYSTEM_flutter.md** → Border Radius (search for "AppRadius")
5. **ARCHITECTURE.md** → Code Quality Standards → Design Token Adherence (lines 1854-1862)
6. **CLAUDE.md** → Code Review Checklist (lines 84-104)

**Critical warnings:**
- ⚠️ Orange (`#e8751a`) ONLY for CTAs/interactive elements (never match status)
- ⚠️ Green (`#1a9456`) ONLY for match confirmation (never CTAs)
- ⚠️ ALL colors must come from `AppColors` — no raw hex strings
- ⚠️ ALL spacing must come from `AppSpacing` — no magic numbers
- ⚠️ Changes propagate automatically across entire app (30 color constants, 8 spacing constants)
- ⚠️ For UI styling issues (AppBar, buttons, inputs), check `app_theme.dart` FIRST before modifying individual widgets

**Reference files:**
- `journey_mate/lib/theme/app_colors.dart` — All 30 color constants
- `journey_mate/lib/theme/app_spacing.dart` — All 8 spacing constants
- `journey_mate/lib/theme/app_typography.dart` — All 14 text styles
- `journey_mate/lib/theme/app_theme.dart` — Centralized ThemeData (AppBar, buttons, inputs, cards)
- `DESIGN_SYSTEM_flutter.md` — Complete design system documentation (683 lines)

---

## 8. Fixing State Persistence & Widget Lifecycle
**Estimated reading time:** 20 minutes

**Read these sections:**
1. **ARCHITECTURE.md** → Common Pitfall #11 (lines 2194-2278)
2. **ARCHITECTURE.md** → Pre-Loading Architecture (lines 1444-1521)
3. **ARCHITECTURE.md** → State Management → When to Use What (lines 156-163)
4. **ARCHITECTURE.md** → Common Pitfall #5 (lines 2102-2117)
5. **CLAUDE.md** → Flutter Code Conventions (lines 126-140)

**Critical warnings:**
- ⚠️ NEVER call `ref.read()` or `ref.watch()` after async operations — widget may have unmounted
- ⚠️ Save notifier with `ref.read()` BEFORE any `await`
- ⚠️ Use saved notifier variable for all post-async operations
- ⚠️ Use `context.mounted` (not `mounted`) after async in Flutter 3.x
- ⚠️ Pre-loading pages must handle widget unmount during background API calls

**Reference files:**
- `journey_mate/lib/pages/welcome_page.dart` — Pre-loading pattern (3 functions)
- `journey_mate/lib/pages/settings_and_account_page.dart` — Safe async pattern
- Git commit `72eff57` — "fix: prevent ref access after widget unmount"

---

## 9. Implementing Search/Filter Features
**Estimated reading time:** 45 minutes

**Read these sections:**
1. **_reference/BUILDSHIP_API_REFERENCE.md** → SEARCH endpoint v9.2 (lines 11-131)
2. **ARCHITECTURE.md** → API Service Pattern (lines 1307-1441)
3. **_reference/PROVIDERS_REFERENCE.md** → searchStateProvider (search for "searchStateProvider")
4. **_reference/PROVIDERS_REFERENCE.md** → filterProvider (search for "filterProvider")
5. **ARCHITECTURE.md** → Widget Patterns → Map View with Viewport-Based Geo-Filtering Pattern (lines 554-573)
6. **ARCHITECTURE.md** → Widget Patterns → Bottom Sheet Pattern (lines 575-620)
7. **ARCHITECTURE.md** → Widget Patterns → BottomSheetHeader — Shared Bottom Sheet Widget (lines 622-679)
8. **ARCHITECTURE.md** → Widget Patterns → Filter Coordination Pattern (lines 681-763)
9. **ARCHITECTURE.md** → Widget Patterns → Parent-Child Filter Pattern (lines 767-884)
10. **ARCHITECTURE.md** → Widget Patterns → Filter Exclusivity Pattern (lines 888-955)
11. **ARCHITECTURE.md** → Swipe Gesture Patterns (lines 959-1304) — for dismissible location banner
12. **ARCHITECTURE.md** → Pre-Loading Architecture (lines 1444-1521)
13. **ARCHITECTURE.md** → Location Permission Pattern (lines 1524-1602) — for search banner location UI
14. **ARCHITECTURE.md** → Common Pitfall #11, #13, #14, #18, #24 (lines 2194-2278, 2394-2449, 2450-2489, 2629-2684, 2960-3047)

**Critical warnings:**
- ⚠️ **SEARCH API v9.2 LIVE:** NO `filtersUsedForSearch` parameter (use `filters` only), NO `category` parameter (always returns all with `section` field), access new `fullMatchCount` output field
- ⚠️ **Map view uses 200-result page size** (vs 20 for list view). Map sends `geoBoundsJson` for viewport-based geo-filtering. `geoBounds` is ANDed with filters but does NOT affect sort order
- ⚠️ CityID is always 17 (Copenhagen) — use `AppConstants.kDefaultCityId`
- ⚠️ Filter hierarchy loaded via AsyncNotifierProvider from BuildShip
- ⚠️ Search results pre-loaded on Welcome/Settings pages for instant Search page
- ⚠️ Filter panel is bottom sheet (NOT inline overlay) — tab selection is local state
- ⚠️ **Cross-filter dependencies:** When filters have interdependencies (neighbourhood → station, shopping area → neighbourhood), use parent callbacks to auto-clear invalidated state (Filter Coordination Pattern prevents sort button showing unavailable station)
- ⚠️ **Parent-child filters:** When parent+child both selected, deduplicate BEFORE titleId lookup to prevent double-counting (Pitfall #18). Hide parent chips AFTER routed ID inclusion to preserve neighbourhood/shopping area display. Bakery children use lowercase format ("Bakery with seating"), others use colon ("Café: In bookstore").
- ⚠️ **Filter exclusivity:** Neighbourhoods, train stations, and shopping areas are mutually exclusive — call `_removeConflictingFilters()` BEFORE adding new selection (Filter Exclusivity Pattern). Without this, multiple location anchors can be active simultaneously, breaking search results.
- ⚠️ **Filter state management:** Parent neighbourhoods need special routing logic (check `kNeighborhoodHierarchy` FIRST before `hasSubitems`). Widget updates must restore routed IDs (neighbourhoods, shopping areas) to prevent orphaned state (Pitfall #24).
- ⚠️ Match categorization handled by BuildShip via `section` field (`"fullMatch"`, `"partialMatch"`, `"others"`) — Flutter renders section headers when value changes
- ⚠️ Filter overlays that sync state on close: save notifier in `initState()`, use in `dispose()` (Pitfall #11 Variation B)
- ⚠️ Collection callbacks: Use `Map<String, Object>{}` not `Map<String, dynamic>{}` in `orElse:` (Common Pitfall #13)
- ⚠️ Use `enableLocation()` for search page location banner (NOT `requestPermission()`)
- ⚠️ Location banner uses swipe-to-dismiss gesture: `HitTestBehavior.translucent` + adaptive 30% threshold (commit 58a7549)
- ⚠️ **v9.2 Geographic filters:** Use `neighbourhood_id` (number | number[]) and `shopping_area_id` (number) parameters for filtering. Flutter sends `neighbourhoodId` as `List<int>?` (JSON-encoded array via `json.encode()`). Station validation uses `.any()` OR logic across selected neighbourhoods (commits `bd1c12f`/`61a7cea`). Map view adds `geoBounds` parameter for viewport filtering (commit `c545543`)
- ⚠️ **v9.2 Pagination:** When `onlyOpen=true`, `totalPages` = `-1` (use `hasMore` field instead for infinite scroll)

**Reference files:**
- `journey_mate/lib/pages/search/search_page.dart` — Complete search implementation (list + map toggle)
- `journey_mate/lib/widgets/shared/search_results_map_view.dart` — Map view with markers
- `journey_mate/lib/widgets/shared/filter_overlay_widget.dart` — Filter bottom sheet
- `journey_mate/lib/providers/search_providers.dart` — Search state management
- `journey_mate/lib/providers/filter_providers.dart` — Filter hierarchy state
- `_reference/_buildship/SEARCH_NODE_v9.2.ts` — Full search endpoint reference (920 lines)

---

## 10. Working with Business Profile & Menu Data
**Estimated reading time:** 25 minutes

**Read these sections:**
1. **_reference/BUILDSHIP_API_REFERENCE.md** → GET /businessProfile (search for "GET_BUSINESS_PROFILE")
2. **_reference/BUILDSHIP_API_REFERENCE.md** → GET /businessMenu (search for "businessMenu")
3. **_reference/PROVIDERS_REFERENCE.md** → businessProvider (search for "businessProvider")
4. **ARCHITECTURE.md** → API Service Pattern (lines 1307-1441)
5. **ARCHITECTURE.md** → Graceful Degradation on Secondary API Failure (lines 1372-1410)
6. **ARCHITECTURE.md** → State Management → NotifierProvider (lines 183-208)
7. **ARCHITECTURE.md** → ref.listen for Async Data Reactivity (lines 323-351)
8. **ARCHITECTURE.md** → Common Pitfall #22, #23, #25, #26, #27, #30, #31, #32 (lines 2833-2892, 2893-2959, 3048-3111, 3112-3140, 3141-3165, 3231-3255, 3256-3293, 3294-3325)
9. **_reference/BUILDSHIP_API_REFERENCE.md** → GET /businessProfile API response structure (source of truth)

**Critical warnings:**
- ⚠️ **v2 is live** — Router serves `BusinessProfilePageV2` (Decision #15 in CLAUDE.md)
- ⚠️ API returns flat `businessInfo` (no nested address/contact objects) + separate top-level `filters` array
- ⚠️ Client-side field enrichment: `status_open`, `closing_time`, `price_range` computed from `openWindows` data before storing to provider
- ⚠️ **menuCategories (profile API) vs menuItems (menu API):** `MenuCategoriesRows` expects `menuCategories` from `GET_BUSINESS_PROFILE`, NOT `menu_items` from `GET_RESTAURANT_MENU` — different data structures (Pitfall #30)
- ⚠️ **ref.listen for async data:** Use `ref.listen(businessProvider)` in `build()` when widget mounts before menu data arrives (Pitfall #31 for ref.read vs ref.watch)
- ⚠️ **Session analytics timing:** Fire `_trackMenuSessionStart()` in `initState()` (page open), NOT after API response. Guard `dispose()` with `_menuSessionStarted` flag (Pitfall #32)
- ⚠️ **Graceful degradation:** When menu API fails, show error widget in menu section only — business profile stays visible. Track with page-local `_menuLoadFailed` bool
- ⚠️ Menu items have dietary filters (vegan, vegetarian, gluten-free, lactose-free)
- ⚠️ Opening hours are pre-computed `openWindows` arrays from BuildShip
- ⚠️ **businessHours day keys:** `"0"`=Monday through `"6"`=Sunday. Convert with `weekday - 1`, NOT `weekday % 7` (Pitfall #26)
- ⚠️ **JSON numeric casting:** Use `(as num?)?.toDouble()` for lat/lng and other numeric API fields — `as double?` throws on whole numbers (Pitfall #27)
- ⚠️ Image gallery is categorized: `{ interior: [], food: [], outdoor: [], menu: [] }`. Note: API ref says objects with `image_url`, but code may treat as strings — verify at runtime
- ⚠️ **Navigation to full pages (gallery/menu/info): use `context.push()` (NOT `context.go()`)** — go() breaks back button (Pitfall #22)
- ⚠️ **Expandable sections: use `AnimatedOpacity` (NOT `AnimatedSize`)** — AnimatedSize causes jankiness (Pitfall #23)
- ⚠️ **Pass full API response Maps to providers** (NOT partial arrays) if downstream consumers need multiple keys — see Pitfall #25

**Reference files:**
- `journey_mate/lib/pages/business_profile/business_profile_page_v2.dart` — Business data display (v2, active)
- `journey_mate/lib/pages/menu_full_page/menu_full_page.dart` — Menu with dietary filtering
- `journey_mate/lib/providers/business_providers.dart` — Business state management

---

## 11. Analytics & Engagement Tracking
**Estimated reading time:** 15 minutes

**Read these sections:**
1. **ARCHITECTURE.md** → Analytics Architecture (lines 1764-1838)
2. **ARCHITECTURE.md** → Philosophy → Fire-and-Forget Analytics (lines 69-75)
3. **ARCHITECTURE.md** → Common Pitfall #9, #10, #32 (lines 2163-2193, 3294-3325)
4. **_reference/BUILDSHIP_API_REFERENCE.md** → POST /analytics (search for "analytics")

**Critical warnings:**
- ⚠️ NEVER await analytics calls — fire-and-forget with `.catchError()`
- ⚠️ ActivityScope handles engagement automatically — NEVER call `markUserEngaged()` manually
- ⚠️ Analytics service initializes in `main.dart` before provider container
- ⚠️ User experience is NEVER blocked by analytics (data loss acceptable, UX responsiveness is not)
- ⚠️ 47 event types tracked to Supabase via BuildShip (updated from 36 — commit `6804d38` added 11 widget-level events)
- ⚠️ **Verify event names against allowlist** before adding new analytics — BuildShip silently rejects unknown event types with "Invalid event type" error (no crash, no log)
- ⚠️ **Session timing: fire session start in `initState()`, not after API response** — ensures accurate duration even when API is slow/fails. Guard `dispose()` with `_menuSessionStarted` flag (Pitfall #32)

**Reference files:**
- `journey_mate/lib/services/analytics_service.dart` — AnalyticsService + EngagementTracker (469 lines)
- `journey_mate/lib/widgets/activity_scope.dart` — Automatic engagement detection
- `journey_mate/lib/pages/search/search_page.dart` — Page view tracking example (lines ~240-260)

---

## 12. Localization & Multi-Language Support
**Estimated reading time:** 15 minutes

**Read these sections:**
1. **ARCHITECTURE.md** → Translation System (lines 1605-1748)
2. **_reference/PROVIDERS_REFERENCE.md** → localeProvider (search for "localeProvider")
3. **_reference/PROVIDERS_REFERENCE.md** → localizationProvider (search for "localizationProvider")
4. **_reference/BUILDSHIP_API_REFERENCE.md** → GET /languageText (search for "languageText")
5. **ARCHITECTURE.md** → Key Architectural Decisions → Translation: 100% Supabase (lines 3389-3394)

**Critical warnings:**
- ⚠️ All text via `td(ref, 'key')` function — NO hardcoded strings
- ⚠️ 15 languages in Supabase, 7 fallback languages in app (344 app keys, 0 legacy)
- ⚠️ Language change triggers full app rebuild via `localeProvider` + MaterialApp
- ⚠️ Currency preference stored separately in `localizationProvider`
- ⚠️ Exchange rates fetched from external API, cached in provider state
- ⚠️ **Distance unit preference is English-only** — Non-English users ALWAYS see metric (km/meters), ignoring stored preference. `DistanceUnitSelectorButton` visible only when `currentLanguage == 'en'`. See CLAUDE.md Decision #14.

**Reference files:**
- `journey_mate/lib/services/translation_service.dart` — `td()` function (40 lines)
- `journey_mate/lib/providers/settings_providers.dart` — locale + localization providers
- `journey_mate/lib/pages/localization_settings_page.dart` — Language/currency selector

---

## Navigation Guide Changelog

**2026-03-09 (batch):** 3 documentation PRs merged: (1) Translation system — td() 4-step fallback chain, 344 keys, 0 legacy, 15 Supabase languages; (2) Widget patterns — BottomSheetHeader, contact_utils.dart, _buildSheetHandle fix; (3) Design tokens — dotSeparator color, BusinessCache LRU cache. All 12 scenario line refs recalculated (~150 lines added to ARCHITECTURE.md). Commits covered: 03a5073, 9f7a6bb, 9762445, 80ae4b6, 932e351, c777591, 9ffcefb, 645d8c4, 403a51a, ae9ad82
**2026-03-07 (batch):** Added Pitfalls #28-32 (nested scroll physics, cache provider mismatch, menuCategories vs menuItems, ref.read in getters, analytics session timing). Added 4 patterns (cross-page widget reuse, map view geo-filtering, ref.listen reactivity, graceful degradation). SEARCH API v9.1→v9.2 with geoBounds parameter. Decision #16 updated (xcconfig + two pages). Scenarios 1 (cross-page reuse), 9 (map view, v9.2, geoBounds), 10 (pitfalls #30-32, ref.listen, graceful degradation), 11 (pitfall #32 session timing) expanded. All 12 scenario line refs recalculated (~200 lines added to ARCHITECTURE.md). Commits covered: 9e75f0f, b419988, e35de89, c9e9eff, c545543, 5eae0ca, 2cb5e50
**2026-03-07:** Added custom_functions/ subdirectory to ARCHITECTURE.md project structure tree from commit 1ae1371 (formatDistanceText shared utility extraction). BUILDSHIP_API_REFERENCE.md clarified business_type is pre-localized in profile API. Line shift: +6 lines from directory tree expansion, all 12 scenario line refs updated
**2026-03-06:** Added Pitfalls #26 (businessHours day key indexing) and #27 (unsafe JSON numeric casting) from commits 6804d38/172a66e. Updated Scenario 3 (API: added Pitfall #27), Scenario 10 (business profile: added Pitfalls #26, #27, gallery format note), Scenario 11 (analytics: 36→47 events + allowlist warning). BUILDSHIP_API_REFERENCE.md updated with 11 new event types. PROVIDERS_REFERENCE.md flagged dead fields. CLAUDE_MAIN.md added Decision #16 (Google Maps AppDelegate setup)
**2026-03-05:** Added Common Pitfall #25 (provider data structure expectations) from commit 5f4aeab. Updated Scenario 3 (API integration) and Scenario 10 (business profile/menu) with new pitfall reference. PROVIDERS_REFERENCE.md businessProvider usage example corrected. Line shift: Pitfall #25 added at line 2785 (~65 lines), all subsequent line refs shifted
**2026-03-03:** Updated neighbourhood filter docs to multi-select (`List<int>?`) pattern from commits bd1c12f/61a7cea. ARCHITECTURE.md Filter Coordination Pattern code example updated, PROVIDERS_REFERENCE.md SearchState fields and setFiltersWithRouting() method added. No line-number shifts in ARCHITECTURE.md
**2026-03-03:** Updated all line references after 6-branch merge documentation (Pitfall #20, atomic state updates, submit button pattern, v2 business profile). Updated Scenario 5 with atomic state pattern, Scenario 10 with v2 profile info
**2026-03-03:** Added Parent-Child Filter Pattern (lines 571-691) and Pitfall #18 to Scenario 9. Updated all line references across 12 scenarios due to 121-line insertion in ARCHITECTURE.md from commit a917eee
**2026-03-03:** Added Filter Coordination Pattern (lines 485-569) to Scenario 9. Updated all line references across 12 scenarios due to 86-line insertion in ARCHITECTURE.md from commit 8606b21
**2026-03-02:** Updated Scenario 12 with distance unit preference warning (English-only) from commit c767773
**2026-03-02:** Updated Scenarios 1, 2, 9 with Swipe Gesture Patterns section (lines 486-831) and new Pitfalls #14-16 from commit 58a7549
**2026-02-24:** Initial 12-scenario guide created with targeted reading lists
**2026-02-24:** Updated Scenarios 6 & 9 to reference expanded Common Pitfall #11 (dispose pattern)
**2026-02-24:** Extracted to separate file for CLAUDE.md optimization
