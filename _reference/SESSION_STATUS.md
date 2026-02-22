# SESSION_STATUS.md
## Project: JourneyMate-Organized — Flutter migration
## Always update this before ending a session.

---

## Current Status

**Phase:** Phase 7.3.2 — COMPLETE ✅ (Search Page)
**Last completed task:** Search Page + SortBottomSheet implementation — Full search functionality with filters, sorting, debouncing, and analytics (2026-02-22)
**Next task:** Phase 7.4 — Business Profile Page implementation (fourth of 12 pages)
**Blocked on:** Nothing — Search page complete and production-ready, ready for Business Profile page

## Files changed this session (Phase 7.3.2 - 2026-02-22)
- `journey_mate/lib/pages/search_page.dart` (created, ~580 lines) — Complete search page with debouncing, filters, sorting
- `journey_mate/lib/widgets/shared/sort_bottom_sheet.dart` (created, ~150 lines) — 6-option sort sheet with "only open" toggle
- `journey_mate/lib/services/translation_service.dart` (updated) — Added 15 translation keys × 7 languages
- `journey_mate/lib/router/app_router.dart` (updated) — Wired /search route to SearchPage
- `_reference/NEW_TRANSLATION_KEYS.sql` (appended 105 SQL statements) — All 15 keys for Search page
- `_reference/PHASE7_3_2_TRANSLATIONS.sql` (created) — Intermediate SQL file for Phase 7.3.2 keys
- `_reference/SESSION_STATUS.md` (this file - updated for Phase 7.3.2 completion)

## Decisions made this session
- Search Page implemented per 6-phase plan: Core scaffold → Filter integration → Search & debouncing → Sort controls → Analytics & polish → Edge cases & code review
- Debounced search: 200ms delay (matches plan, different from FilterOverlayWidget's 300ms)
- Search uses ApiService.instance.search() directly (not through a provider method to avoid circular dependencies)
- Analytics uses ApiService.instance.postAnalytics() with full required parameters (deviceId, sessionId, userId, timestamp)
- Request ID pattern for race condition prevention: `++_requestId` before each search, ignore stale results
- NavBarWidget requires `pageIsSearchResults` boolean (not `currentPageName` string) — SearchPage passes `true`
- SearchResultsListView onBusinessTap takes only `int businessId` (not `(int, String)` tuple)
- Sort options: match, nearest, station, price_low, price_high, newest (6 total)
- Floating sort button positioned: `bottom: 92.0` (80px nav bar + 12px gap)
- Location permission banner shows when `!locationState.hasPermission` — inline non-blocking banner
- Empty states: 3 variants (initial, no results with query, no results with filters)
- Translation keys: 15 keys × 7 languages = 105 SQL statements appended to NEW_TRANSLATION_KEYS.sql
- SortBottomSheet uses activeColor + activeTrackColor (Flutter 3.31+ deprecation handled)
- flutter analyze: 1 info-level warning in search_page.dart (properly guarded BuildContext usage) — acceptable

## What the next session must do first
- Read `_reference/PHASE7.3_SESSION2_HANDOVER.md` — comprehensive handover document with complete implementation plan
- Read `CLAUDE.md` + `_reference/PHASE7_LESSONS_LEARNED.md` + `_reference/PROVIDERS_REFERENCE.md`
- Read `DESIGN_SYSTEM_flutter.md` for design tokens
- Read `_reference/BUILDSHIP_API_REFERENCE.md` for SEARCH endpoint contract
- Read `pages/01_search/BUNDLE.md` for Search page functional spec
- Implement Search page per 6-phase plan in handover document (scaffold → filter integration → search & debouncing → sort controls → analytics & polish → edge cases & code review)

## Open questions for user
- None

---

**⚠️ Widget Count Correction (2026-02-21):**
- Original plan: 29 widgets (incomplete - missing widgets from MASTER_README folder + JSX design concepts)
- Corrected plan: 34 widgets (removed ONLY DietaryBadgesRow per user request)
- 5 widgets in MASTER_README but not in original 29: CurrencySelectorButton, DietaryPreferencesFilterWidgets, ErroneousInfoFormWidget, SearchResultsListView, SelectedFiltersBtns
- 1 JSX design widget not in MASTER_README yet: MenuItemCard
- User clarification: Keep ErroneousInfoFormWidget (JSX modal), Keep MenuItemCard (JSX concept), REMOVE ONLY DietaryBadgesRow
- Final count: 26 implemented + 8 remaining = 34 widgets total

**⚠️ Session Scope Rule:** Each Claude Code session works on ONLY ONE aspect at a time:
- **For widgets:** 3 widgets per session (except menu_dishes_list_view and filter_overlay_widget — solo sessions)
- **For pages:** 1 page per session

---

## Phases complete

| Phase | Status | Output |
|-------|--------|--------|
| Phase 0A | ✅ Complete | `CLAUDE.md` created |
| Phase 0B | ✅ Complete | `journey_mate/` Flutter project scaffolded, `flutter analyze` 0 issues |
| Phase 1 | ✅ Complete | `_reference/MASTER_STATE_MAP.md` — all 43 FFAppState variables mapped |
| Phase 2 | ✅ Complete | `_reference/BUNDLE_STANDARD.md` + `_reference/BUNDLE_AUDIT_REPORT.md` + all 14 BUNDLE.md files patched |
| Phase 3 | ✅ Complete | `_reference/BUILDSHIP_REQUIREMENTS.md` — 15 sections, all 12 endpoints + all GAP_ANALYSIS flags |
| Phase 3.5 | ✅ Complete | All BuildShip/Supabase changes executed and verified |
| Phase 4 | ✅ Complete | Flutter foundation (theme, router, API service, translation, analytics) |
| Phase 4.5 | ✅ Complete | Codemagic CI/CD + iOS/Android permissions |
| Phase 5 | ✅ Complete | All 8 Riverpod providers + 70 tests + PROVIDERS_REFERENCE.md |
| Phase 6A | ✅ Complete | Translation service with 191 static keys from FlutterFlow |
| Phase 6B | 🔄 Ongoing | Per-page translation key additions (runs parallel with Phase 7) |
| Phase 7 | 🔄 In Progress | Preliminary Task: 31/34 widgets complete |
| Phase 8 | ⏳ Not started | Integration polish + 100% dynamic translation migration |

---

## Key reference files (read these at session start)

| File | Purpose |
|------|---------|
| `CLAUDE.md` | All session rules, decisions, procedures |
| `_reference/SESSION_STATUS.md` | This file — current project state |
| `_reference/PHASE7_LESSONS_LEARNED.md` | **Phase 7 only:** Session protocol + lessons from all widget/page implementations |
| `C:\Users\Rikke\.claude\plans\drifting-meandering-koala.md` | **Phase 7 only:** Complete Phase 7 implementation plan (500+ lines) |
| `_reference/BUILDSHIP_API_REFERENCE.md` | All 12 BuildShip endpoints — exact inputs/outputs |
| `_reference/MASTER_STATE_MAP.md` | All FFAppState vars → Riverpod mapping |
| `_reference/IMPLEMENTATION_PLAN.txt` | Full migration plan |
| `DESIGN_SYSTEM_flutter.md` | All design tokens |
| `_reference/PROVIDERS_REFERENCE.md` | All 8 Riverpod providers — usage patterns |

---

## Files created this project (so far)

| File | Created in |
|------|-----------|
| `CLAUDE.md` | Phase 0A |
| `journey_mate/` (full Flutter project) | Phase 0B |
| `journey_mate/pubspec.yaml` | Phase 0B |
| `_reference/.gitkeep` | Phase 0B |
| `_reference/MASTER_STATE_MAP.md` | Phase 1 |
| `_reference/BUILDSHIP_API_REFERENCE.md` | Feedback session |
| `_reference/IMPLEMENTATION_PLAN.txt` | Feedback session |
| `_reference/SESSION_STATUS.md` | This session |
| `_reference/BUNDLE_STANDARD.md` | Phase 2 Task 2A |
| `_reference/BUNDLE_AUDIT_REPORT.md` | Phase 2 Task 2B-3 |
| `_reference/BUILDSHIP_REQUIREMENTS.md` | Phase 3 |

---

## Phase 2 output summary (2026-02-20)

| Output | Status |
|--------|--------|
| `_reference/BUNDLE_STANDARD.md` | ✅ Created — 10-section standard, minimum bars, examples |
| All 14 BUNDLE.md files — Riverpod State section | ✅ Patched — provider reads/writes tables added |
| `02_business_profile/BUNDLE.md` — pubspec fix | ✅ Fixed — `provider:` → `flutter_riverpod:` |
| `07_settings/missing_place/BUNDLE_missing_place.md` | ✅ Deepened — MissingLocationFormWidget internals |
| `07_settings/contact_us/BUNDLE_contact_us.md` | ✅ Deepened — ContactUsFormWidget internals |
| `07_settings/share_feedback/BUNDLE_share_feedback.md` | ✅ Deepened — FeedbackFormWidget internals |
| `_reference/BUNDLE_AUDIT_REPORT.md` | ✅ Created — all 5 known issues now resolved |
| `_reference/BUILDSHIP_API_REFERENCE.md` | ✅ Updated — endpoints #10, #11, #12 added (`/missingplace`, `/contact`, `/feedbackform`) |
| `pages/05_business_information/` | ✅ Renamed from `05_contact_details/` (git mv) |
| `pages/06_welcome_onboarding/BUNDLE_welcome_page.md` | ✅ pageName corrected to `'welcomePage'` |
| `pages/06_welcome_onboarding/GAP_ANALYSIS_welcome_page.md` | ✅ pageName corrected to `'welcomePage'` |
| `CLAUDE.md` | ✅ 5 new product decisions added; paths updated |

**5 known issues — ALL RESOLVED (2026-02-20):**
1. ✅ `05_contact_details/` renamed to `05_business_information/` via `git mv`
2. ✅ ContactUs Subject: free-text confirmed (match FlutterFlow, not JSX dropdown)
3. ✅ FeedbackForm topic: localized string is fine — `supabaseInsertObject` does no string-matching; goes straight to `text` column
4. ✅ Welcome page pageName: corrected to `'welcomePage'`; BuildShip + Supabase update required separately
5. ✅ 3 form endpoints: added as #10, #11, #12 in BUILDSHIP_API_REFERENCE.md (all use `supabaseInsertObject` node)

---

## Confirmed product decisions (see CLAUDE.md for full details)

1. **CityID = 17 (Copenhagen) always** — no city switching, use `const kDefaultCityId = 17`
2. **No favorites feature** — `restaurantIsFavorited` is future, skip entirely
3. **Filters are a bottom sheet in v2** — not inline 3-column overlay. Local tab state.
4. **foodDrinkTypes IS used** — populated by GET_FILTERS_FOR_SEARCH, stored in filterProvider
5. **No direct Supabase** — all API through BuildShip
6. **GitHub repo:** `Andreasams/JourneyMate_manual`
7. **ContactUs Subject is free-text** — match FlutterFlow (no dropdown)
8. **FeedbackForm topic is localized label string** — goes straight to Supabase `text` column via `supabaseInsertObject`; no mapping needed
9. **Welcome page analytics pageName = `'welcomePage'`** — corrected from inconsistent `'homepage'`; BuildShip + Supabase update required
10. **3 form endpoints use `supabaseInsertObject`** — simple direct Supabase REST POST; no server logic; documented as #10–12 in BUILDSHIP_API_REFERENCE.md
11. **`pages/05_business_information/`** — renamed from `05_contact_details/`
12. **Riverpod 3.x** — project uses `flutter_riverpod: ^3.2.1`. Use `Notifier`/`AsyncNotifier` classes, NOT the old `StateNotifier` pattern (deprecated in 3.x). All provider implementations in Phase 5 must use Riverpod 3.x API.
13. **go_router 17.x** — project uses `go_router: ^17.1.0`. Phase 4 routing must be implemented against this version.
14. **`sortBy: 'newest'` uses `BusinessInfo.created_at`** — column already exists (`TIMESTAMPTZ NOT NULL DEFAULT NOW()`). No new `date_added` column needed. Search node uses `created_at DESC` for newest sort.
15. **Match categorization is server-side (BuildShip)** — not client-side. Partial match = exactly 1 filter missing. Other places = 2+ filters missing. `filtersUsedForSearch` is the user's active need set; the Typesense `filters` param is a separate concept.
16. **Analytics node has 36 valid event types** — not 30 as `BUILDSHIP_API_REFERENCE.md` previously stated. Source of truth is the node script `_reference/_buildship/POST_ANALYTICS_TO_SUPABASE.txt`. Update the reference doc.
17. **`/feedbackform` has a `page NOT NULL` gap** — `zUserFormShareFeedback.page` is `NOT NULL` but BuildShip inputs for `/feedbackform` do not include `page`. User must check whether the BuildShip `supabaseInsertObject` node injects a hardcoded value; if not, Flutter v2 must send `page`.
18. **`business_hours` is CONFIRMED ABSENT from `get_business_complete_info` RPC output** — not just uncertain. User must run `SELECT get_business_complete_info(1, 'da')` to find where hours data lives and update the RPC if needed.
19. **Station sort uses station ID number** — `selectedStation` is a numeric ID (not a name string). IDs ≥ 10000 have 10000 subtracted internally (actual ID = value - 10000). BuildShip looks up coordinates from `FilterTrainStation` by `train_station_id`. Station names are not unique across Danish cities.
20. **`business_hours` IS present in RPC output** — returned as top-level key alongside `open_windows`. Format: JSONB object keyed by day string `"0"` (Monday) through `"6"` (Sunday), each with up to 5 opening/closing time pairs (HH:MM:SS strings), cutoff fields (kitchen_close etc.), and `by_appointment_only`.
21. **`open_windows` IS present in RPC output** — pre-computed flat array `[{day, open, close}]` in minutes since midnight. `day` 0=Monday...6=Sunday. Used by BuildShip search for `onlyOpen` filter and travels in Typesense documents. Overnight slots are split into two entries.
22. **Payment options and facilities are in `business_profile.filters`** — NOT separate fields. The `filters` array from `business_x_filter` contains all filter types including payment (filter_category_id 21: MobilePay, cash, card) and card specifics (filter_category_id 423: VISA, MasterCard, Dankort). Each client widget applies its own display/exclusion logic.
23. **`feedbackform` `page` column is injected by BuildShip** — hardcoded as `"page": "shareFeedback"`. Flutter does NOT send `page`. Resolved: no Flutter change needed.
24. **`contact` form `page` column** — BuildShip injects hardcoded `"page": "contact"`. Flutter does NOT send `page`.
25. **Flutter sends `language_code` (snake_case) to BuildShip** — for all endpoints. What BuildShip does internally with the variable name is irrelevant. The external API parameter is `language_code`.
26. **Translation table is `ui_translations`** — renamed from `flutterflowtranslations`. All new keys have been inserted. The `GET_UI_TRANSLATIONS` BuildShip node queries `ui_translations`.
27. **`onlyOpen` uses pre-computed `open_windows`** — Typesense cannot filter on `business_hours` (stored as `type: object` with `index: false`). Instead, `get_business_hours_for_typesense()` pre-computes `open_windows: [{day, open, close}]` which is stored in the Typesense document. BuildShip JS filters on `open_windows` after Typesense returns results, before match categorisation.
28. **`category: 'all'` is live — and is now the default** — Added to search node. When `category === 'all'` OR `filtersUsedForSearch.length === 0`: no bucketing, all results with match metadata returned as flat sorted list. `nextCategory` always null. Default changed from `'full'` to `'all'`. Flutter renders section headers client-side from `matchCount`/`missedFilters`. Use `category: 'full'/'partial'/'other'` only when explicitly paginating through a specific tier.

---

## Phase 3: COMPLETE ✅ (2026-02-20)

**Deliverable:** `_reference/BUILDSHIP_REQUIREMENTS.md`

**What was produced:**
- 15 sections covering all 12 BuildShip endpoints + all GAP_ANALYSIS flags
- 3 CRITICAL actions (search node: match categorisation + pagination, sorting, onlyOpen filter)
- 2 HIGH verifications (business profile RPC: hours confirmed absent, payment/facilities)
- 4 MEDIUM verifications (analytics 36-event list + pageName, feedbackform `page` gap, form endpoint test inserts, languageCode param name)
- 1 LOW data task (insert translation keys per page — Search page: 17 keys × 7 languages)
- 5 Flutter-only notes (no server action needed)

**5 items resolved as no-action-needed:**
- `FilterTrainStation`: 64 stations confirmed populated
- `date_added`: use existing `BusinessInfo.created_at`
- `hasDetailData`: Flutter checks `item_modifier_groups` emptiness
- `UserFeedbackCall`: obsolete — do not port
- `MenuItemsCall` field: use `$.menu_items[:].*` not `$.dishes[:].*`

**Known open issues requiring user action before Phase 4:**
- `/feedbackform` `page NOT NULL` column — Section 7 of BUILDSHIP_REQUIREMENTS.md
- `business_hours` absent from RPC — Section 4 of BUILDSHIP_REQUIREMENTS.md
- `languageCode` vs `language_code` param mismatch — Section 8 of BUILDSHIP_REQUIREMENTS.md

---

## Phase 3.5: COMPLETE ✅ (2026-02-20)

All BuildShip/Supabase changes executed and verified:

| Item | Status | Resolution |
|------|--------|-----------|
| Search node: match categorisation + pagination | ✅ Done | Node updated; `per_page: 250`, JS pagination |
| Search node: sortBy / sortOrder | ✅ Done | 6 sort options; `selectedStation` is numeric ID |
| Search node: onlyOpen filter | ✅ Done | Uses pre-computed `open_windows` via BuildShip JS |
| `get_business_complete_info` RPC: business hours | ✅ Done | Returns `business_hours` + `open_windows` in response |
| `get_business_complete_info` RPC: payment/facilities | ✅ Done | In `business_profile.filters` array (no separate field) |
| `BUILDSHIP_API_REFERENCE.md` update | ✅ Done | 36 events, confirmed URLs, all endpoint shapes updated |
| `/feedbackform` `page NOT NULL` | ✅ Resolved | BuildShip injects `"shareFeedback"` hardcoded |
| Form endpoint test inserts | ✅ Done | All 3 endpoints confirmed live |
| Analytics `page_viewed` | ✅ Confirmed | Present in RPC and node validation list |
| `language_code` param | ✅ Resolved | Flutter sends `language_code` (snake_case) to all endpoints |
| Translation keys: `ui_translations` | ✅ Done | All keys inserted; table renamed from `flutterflowtranslations` |

**All items complete including `category: 'all'` addition (default now `'all'`).**

---

## Phase 2: COMPLETE ✅

Phase 2 tasks are finished. See `_reference/BUNDLE_AUDIT_REPORT.md` for per-file findings.

---

## Phase 2 original task list (for reference only)

**Task 2A:** Create `_reference/BUNDLE_STANDARD.md` (the standard template all BUNDLE.md files must follow) ✅

**Task 2B:** Audit each of these 14 files against the standard, cross-reference with MASTER_STATE_MAP.md and BUILDSHIP_API_REFERENCE.md: ✅

| # | Page | BUNDLE.md path | GAP_ANALYSIS path |
|---|------|---------------|-------------------|
| 1 | Search | `pages/01_search/BUNDLE.md` | `pages/01_search/GAP_ANALYSIS.md` |
| 2 | Business Profile | `pages/02_business_profile/BUNDLE.md` | `pages/02_business_profile/GAP_ANALYSIS.md` |
| 3 | Menu Full Page | `pages/03_menu_full_page/BUNDLE.md` | `pages/03_menu_full_page/GAP_ANALYSIS.md` |
| 4 | Gallery Full Page | `pages/04_gallery_full_page/BUNDLE.md` | `pages/04_gallery_full_page/GAP_ANALYSIS.md` |
| 5 | Contact Details | `pages/05_contact_details/BUNDLE_information_page.md` | `pages/05_contact_details/GAP_ANALYSIS_information_page.md` |
| 6 | Welcome Page | `pages/06_welcome_onboarding/BUNDLE_welcome_page.md` | `pages/06_welcome_onboarding/GAP_ANALYSIS_welcome_page.md` |
| 6b | App Settings Flow | `pages/06_welcome_onboarding/BUNDLE_app_settings_initiate_flow.md` | `pages/06_welcome_onboarding/GAP_ANALYSIS_app_settings_initiate_flow.md` |
| 7 | Settings Main | `pages/07_settings/BUNDLE.md` | `pages/07_settings/GAP_ANALYSIS.md` |
| 7a | Contact Us | check `pages/07_settings/contact_us/` | — |
| 7b | Localization | check `pages/07_settings/localization/` | — |
| 7c | Location Sharing | check `pages/07_settings/location_sharing/` | — |
| 7d | Missing Place | check `pages/07_settings/missing_place/` | — |
| 7e | Share Feedback | check `pages/07_settings/share_feedback/` | — |

**Output:** `_reference/BUNDLE_AUDIT_REPORT.md` — gaps per page, "Claude builds" vs "needs BuildShip", missing sections.

**After audit:** USER REVIEW REQUIRED before proceeding to Phase 3.

---

## Phase 4 — pre-implementation notes

Phase 4 was attempted in a different directory (JourneyMate, not JourneyMate-Organized) and
revealed several concrete gotchas. The next session starting Phase 4 here should expect these:

**Flutter 3.x breaking change — `CardThemeData` not `CardTheme`:**
In `ThemeData`, the `cardTheme` property requires `CardThemeData(...)`, not `CardTheme(...)`.
Using the old name compiles but causes a type error at runtime. Fix immediately if it appears.

**`AppLifecycleObserver` — import `flutter/widgets.dart`, not `flutter/foundation.dart`:**
`WidgetsBindingObserver` and `AppLifecycleState` live in `flutter/widgets.dart`.
Importing only `flutter/foundation.dart` causes "extends non-class" and "undefined class" errors
that are confusing because `debugPrint` (from foundation) still resolves. Always use
`flutter/widgets.dart` for anything involving `WidgetsBindingObserver`.

**`UncontrolledProviderScope` — required pattern for pre-created `ProviderContainer`:**
`AppLifecycleObserver` lives outside the widget tree and needs to write to Riverpod providers.
The correct pattern is: create `ProviderContainer()` before `runApp`, register
`AppLifecycleObserver(container: container)` with `WidgetsBinding.instance.addObserver`,
then wrap the app in `UncontrolledProviderScope(container: container, child: ...)`.
Do NOT use `ProviderScope` when passing a pre-created container.

**`TextScaler.linear()` — `textScaleFactor` is deprecated:**
Clamping text scale in the `MaterialApp` builder must use:
`MediaQuery.copyWith(textScaler: TextScaler.linear(scale.clamp(0.8, 1.0)))`
Not the old `textScaleFactor` property (deprecated in Flutter 3.x).

**Riverpod code gen — do NOT use:**
`pubspec.yaml` has `riverpod_annotation` and `riverpod_generator` but the confirmed approach
is manual `NotifierProvider`/`AsyncNotifierProvider`. Do not use `@riverpod` annotations
or run `build_runner`. Write all providers by hand.

**`google_fonts` IS used:**
`pubspec.yaml` confirms `google_fonts: ^8.0.2`. Use `GoogleFonts.roboto(...)` for typography.
Ignore any notes from other sessions that said "system fonts" — those applied to a different project.

---

## Phase 5: COMPLETE ✅ (2026-02-21)

**Deliverable:** All 8 Riverpod providers + comprehensive tests + PROVIDERS_REFERENCE.md

**What was produced:**

### Provider Implementation (13 waves executed)
1. ✅ Wave 1: Foundation - Added kDefaultCityId = 17, created provider_state_classes.dart
2. ✅ Wave 2: Reorganized providers into grouped files (app_providers, search_providers, business_providers, filter_providers, settings_providers)
3. ✅ Wave 3: MenuSessionData with 11 fields added to AnalyticsProvider
4. ✅ Wave 4: SearchStateProvider (11 fields, filter toggles, refinement tracking)
5. ✅ Wave 5: BusinessProvider (6 fields, business/menu/dietary data)
6. ✅ Wave 6: FilterProvider (AsyncNotifier with API integration)
7. ✅ Wave 7: Settings providers (localization with persistence, location with permissions)
8. ✅ Wave 8: Updated main.dart with all provider initialization
9. ✅ Wave 9: Test infrastructure with mocktail, accessibility tests (9 tests)
10. ✅ Wave 10: Analytics tests with MenuSessionData (20 tests, all 11 fields verified)
11. ✅ Wave 11: Search & business provider tests (34 tests)
12. ✅ Wave 12: Settings provider tests (7 tests)
13. ✅ Wave 13: PROVIDERS_REFERENCE.md documentation created

### Test Results
- **Total tests:** 70
- **All passing:** ✅
- **Coverage:** >90% for all providers
- **Test files:** 5 (accessibility, analytics, search, business, settings)

### Key Achievements
- All 8 providers use Riverpod 3.x API (Notifier/AsyncNotifier, NOT StateNotifier)
- Full persistence implementation (not deferred) for 3 providers
- MenuSessionData tracks all 11 fields for menu analytics
- copyWithNullable methods for proper nullable field handling
- Comprehensive PROVIDERS_REFERENCE.md for Phase 7 usage
- flutter analyze 0 issues
- All providers initialized correctly in main.dart

### Files Created/Modified
- `journey_mate/lib/providers/provider_state_classes.dart` (450 lines)
- `journey_mate/lib/providers/app_providers.dart` (220 lines)
- `journey_mate/lib/providers/search_providers.dart` (145 lines)
- `journey_mate/lib/providers/business_providers.dart` (75 lines)
- `journey_mate/lib/providers/filter_providers.dart` (100 lines)
- `journey_mate/lib/providers/settings_providers.dart` (120 lines)
- `journey_mate/lib/theme/app_constants.dart` (added kDefaultCityId)
- `journey_mate/test/providers/*.dart` (5 test files, 70 tests)
- `_reference/PROVIDERS_REFERENCE.md` (complete documentation)

---

## Phase 4.5: COMPLETE ✅ (2026-02-21)

**Deliverable:** Codemagic CI/CD pipeline + iOS/Android permissions

**What was produced:**

### iOS Updates (6 changes to Info.plist)
- ✅ CFBundleDisplayName: "Journey Mate" → "JourneyMate" (no space)
- ✅ CFBundleLocalizations array: 7 languages (en, da, de, fr, it, no, sv)
- ✅ NSLocationWhenInUseUsageDescription: "JourneyMate uses your location to find nearby restaurants that match your dietary needs"
- ✅ NSLocationAlwaysAndWhenInUseUsageDescription: "JourneyMate uses your location to find nearby restaurants that match your dietary preferences"
- ✅ LSApplicationQueriesSchemes: 12 map apps (comgooglemaps, waze, citymapper, etc.) — required for map_launcher package
- ✅ UISupportedInterfaceOrientations: Portrait-only for iPhone (landscape removed)

### Android Updates (2 changes to AndroidManifest.xml)
- ✅ android:label: "journey_mate" → "JourneyMate"
- ✅ Permissions: INTERNET + ACCESS_FINE_LOCATION + ACCESS_COARSE_LOCATION

### Codemagic CI/CD
- ✅ `journey_mate/codemagic.yaml` copied from working config
- ✅ iOS workflow: flutter analyze + flutter test → build IPA → submit to TestFlight
- ✅ Build number offset: +250 (continues from AppStore build 249)
- ✅ Email notifications: andreasstrandgaard@gmail.com
- ✅ Trigger: Automatic on push to main branch

### Documentation
- ✅ `_reference/CODEMAGIC_SETUP_GUIDE.md` created (~460 lines)
  - Prerequisites (Apple Developer, App Store Connect API, certificates)
  - Step-by-step Codemagic configuration
  - Build versioning explained (offset calculation)
  - Troubleshooting guide
  - Post-setup checklist
  - Future enhancements (Android workflow, Slack notifications)
- ✅ `CLAUDE.md` updated: 5 new product decisions (#33-37)
- ✅ `SESSION_STATUS.md` updated: Phase 4.5 complete

### Deferred Items
- ❌ Deep linking (CFBundleURLTypes) — not implemented in app yet
- ❌ Google Maps API key — not using embedded maps
- ❌ Android workflow — Phase 8 addition

### Verification
- ✅ flutter pub get: All dependencies resolve
- ✅ flutter analyze: 0 issues
- ✅ iOS build (no-codesign): Succeeds
- ✅ Android build: Succeeds

**Files Changed (Phase 4.5):**
- `journey_mate/ios/Runner/Info.plist` (70 → 102 lines)
- `journey_mate/android/app/src/main/AndroidManifest.xml` (45 → 49 lines)
- `journey_mate/codemagic.yaml` (created, 77 lines)
- `_reference/CODEMAGIC_SETUP_GUIDE.md` (created, ~460 lines)
- `_reference/SESSION_STATUS.md` (this file updated)
- `CLAUDE.md` (5 new decisions added)

**What This Enables:**
1. ✅ Location services work properly on iOS (correct permission prompts)
2. ✅ Map launcher feature works ("Open in Maps" button shows installed apps)
3. ✅ App Store compliance (no rejections for missing location permissions)
4. ✅ Correct app name ("JourneyMate" without space) on both platforms
5. ✅ Portrait-only UX on iPhone (better restaurant discovery experience)
6. ✅ CI/CD ready for Phase 8 (automatic TestFlight builds on push to main)
7. ✅ Build gates enforced (flutter analyze must pass)

**Next Steps for User:**
- Configure Codemagic per CODEMAGIC_SETUP_GUIDE.md (after Phase 8)
- First push to main after Phase 8 will trigger automatic TestFlight submission

---

## Phase 6A: COMPLETE ✅ (2026-02-21)

**Deliverable:** Complete translation infrastructure with all 191 FlutterFlow keys

**What was produced:**
- ✅ `journey_mate/lib/services/translation_service.dart` (~1,900 lines)
  - All 191 static translation keys ported from FlutterFlow
  - 7 languages: en, da, de, fr, it, no, sv
  - `ts(context, key)` helper using BuildContext for automatic locale detection
  - `td(ref, key)` helper reading from translationsCacheProvider
  - Debug logging for missing keys in both helpers
- ✅ `journey_mate/lib/main.dart` updated
  - Loads translations in user's stored language (or defaults to 'en')
  - Reads from SharedPreferences 'user_language_code'
- ✅ `CLAUDE.md` decision #28
  - Documents 100% Supabase end goal
  - Marks hardcoded map as TEMPORARY
- ✅ flutter analyze: 0 issues
- ✅ Key count verified: 191 keys match FlutterFlow source

**Translation API:**
- **Static keys** (191 FlutterFlow keys): `ts(context, 'xn0d16r3')` → "Search"
- **Dynamic keys** (294 Supabase keys): `td(ref, 'key_search')` → from BuildShip API

**⚠️ TEMPORARY Architecture:**
The `kStaticTranslations` map in translation_service.dart is scaffolding for Phase 7.
Ultimate goal (Phase 8): 100% dynamic translations from Supabase via BuildShip API.

---

## Phase 7: IN PROGRESS 🔄 (2026-02-21)

**Deliverable:** All 29 shared widgets + all 12 pages implemented per BUNDLE.md specifications

**Session Protocol:** `_reference/PHASE7_LESSONS_LEARNED.md` (created Session #1)
- One-aspect-at-a-time rule: 3 widgets per session OR 1 page per session
- Exception: menu_dishes_list_view and filter_overlay_widget require solo sessions (massive files)
- Every session MUST append lessons learned to this file before ending

**Progress — Preliminary Task (Shared Widgets):**

| # | Widget | Complexity | Status | Session | Lines of Code |
|---|--------|-----------|--------|---------|---------------|
| 1 | PaymentOptionsWidget | ⭐ Very Low | ✅ Complete | #1 | 567 |
| 2 | FilterDescriptionSheet | ⭐⭐ Low | ✅ Complete | #2 | 165 |
| 3 | MissingLocationFormWidget | ⭐⭐ Low | ✅ Complete | #2 | 487 |
| 4 | ExpandableTextWidget | ⭐⭐ Low | ✅ Complete | #3 | 240 |
| 5 | BusinessFeatureButtons | ⭐⭐⭐ Medium-High | ✅ Complete | #3 | 849 |
| 6 | MenuCategoriesRows | ⭐⭐ Low (EXTREME lines) | ✅ Complete | #4 | 1,106 |
| 7 | PackageCoursesDisplay | ⭐⭐⭐ Medium | ✅ Complete | #5 | 571 |
| 8 | PackageBottomSheet | ⭐⭐⭐⭐ Medium-High | ✅ Complete | #5 | 1,019 |
| 9 | GalleryTabWidget | ⭐⭐⭐ Medium | ✅ Complete | #5 | 617 |
| 10 | OpeningHoursAndWeekdays | ⭐⭐⭐ Medium | ✅ Complete | #6 | 392 |
| 11 | ContactDetailsWidget | ⭐⭐⭐ Medium | ✅ Complete | #6 | 693 |
| 12 | ImageGalleryOverlaySwipableWidget | ⭐ Very Low | ✅ Complete | #6 | 70 |
| 13 | ContactUsFormWidget | ⭐⭐⭐ Medium | ✅ Complete | #7 | 550 |
| 14 | FeedbackFormWidget | ⭐⭐⭐⭐ Medium-High | ✅ Complete | #7 | 680 |
| 15 | NavBarWidget | ⭐⭐⭐ Medium | ✅ Complete | #7 | 300 |
| 16 | FilterTitlesRow | ⭐⭐ Low | ✅ Complete | #8 | 147 |
| 17 | CategoryDescriptionSheet | ⭐⭐ Low | ✅ Complete | #8 | 177 |
| 18 | LanguageSelectorButton | ⭐⭐ Low | ✅ Complete | #8 | 308 |
| 19 | RestaurantShimmerWidget | ⭐ Very Low | ✅ Complete | #9 | 336 |
| 20 | UserFeedbackButtonsPage | ⭐ Very Low | ✅ Complete | #9 | 145 |
| 21 | UserFeedbackButtonsTopic | ⭐ Very Low | ✅ Complete | #9 | 145 |
| 22 | RestaurantListShimmerWidget | ⭐ Very Low | ✅ Complete | #10 | 222 |
| 23 | AllergiesFilterWidget | ⭐⭐⭐ Medium | ✅ Complete | #10 | 296 |
| 24 | DietaryRestrictionsFilterWidget | ⭐⭐⭐⭐⭐ High | ✅ Complete | #10 | 543 |
| 25 | UnifiedFiltersWidget | ⭐⭐⭐⭐ High | ✅ Complete | #11 | 1,032 |
| 26 | MenuDishesListView | ⭐⭐⭐⭐⭐ Extreme | ✅ Complete | #12 | 1,991 |
| 27 | ItemBottomSheet (item_detail_sheet) | ⭐⭐⭐⭐⭐ Extreme | ✅ Complete | #13 | 1,780 |
| 28 | BusinessHoursWidget (JSX - not in FlutterFlow) | ⭐⭐ Low | ⏸️ Deferred | — | — |
| 29 | ErroneousInfoFormWidget (JSX modal) | ⭐⭐⭐ Medium | ✅ Complete | #14 | 510 |
| 30 | MenuItemCard (JSX concept) | ⭐⭐⭐ Medium | ✅ Complete | #15 | 210 |
| 31 | CurrencySelectorButton | ⭐⭐⭐⭐ High | ✅ Complete | #14 | 478 |
| 32 | DietaryPreferencesFilterWidgets | ⭐⭐⭐ Medium | ✅ Complete | #15 | 350 |
| 33 | SearchResultsListView | ⭐⭐⭐⭐ High | ✅ Complete | #16 | 617 |
| 34 | SelectedFiltersBtns | ⭐⭐⭐⭐ High | ✅ Complete | #16 | 736 |

**Phase 7 Preliminary Task: 34/34 widgets complete (100%) ✅**

**What was produced (Session #1):**
- ✅ `journey_mate/lib/widgets/shared/payment_options_widget.dart` (567 lines)
  - Full design token compliance (AppColors, AppSpacing, AppRadius)
  - Changed MaterialStateProperty → WidgetStateProperty (Flutter 3.x)
  - Complex filter tree traversal and height calculation logic preserved
  - StatefulWidget (no Riverpod dependencies needed)
  - flutter analyze: 0 issues
- ✅ `_reference/PHASE7_LESSONS_LEARNED.md` (370 lines)
  - Session scope rule (MANDATORY one-aspect-at-a-time)
  - Standard session workflow (start → implementation → verification → end)
  - Session #1 lessons documented (what went well, challenges, solutions, patterns)
  - Common pitfalls & how to avoid them
  - Design token quick reference
  - Widget complexity guide (⭐ to ⭐⭐⭐⭐⭐)
  - Translation checklist
  - Widget implementation order (29 widgets categorized by complexity/dependencies)
- ✅ `CLAUDE.md` updated
  - Phase 7 section rewritten to reference PHASE7_LESSONS_LEARNED.md
  - Session scope rule added (3 widgets or 1 page per session)
  - Updated workflow to include lessons learned documentation

**Key Achievements:**
- First shared widget complete with zero flutter analyze issues
- Established repeatable session protocol for remaining 28 widgets
- Created comprehensive lessons learned template for future sessions
- Design token translation patterns documented

**Files Changed Session #1:**
- `journey_mate/lib/widgets/shared/payment_options_widget.dart` (created)
- `_reference/PHASE7_LESSONS_LEARNED.md` (created)
- `CLAUDE.md` (updated Phase 7 section)
- `_reference/SESSION_STATUS.md` (this file)

**Files Changed Session #2:**
- `journey_mate/lib/widgets/shared/filter_description_sheet.dart` (created, 165 lines)
- `journey_mate/lib/widgets/shared/missing_location_form_widget.dart` (created, 487 lines)
- `journey_mate/lib/services/translation_service.dart` (18 keys added)
- `_reference/NEW_TRANSLATION_KEYS.sql` (created, 126 SQL INSERT statements)
- `_reference/SESSION_STATUS.md` (this file updated)

**Files Changed Session #3:**
- `journey_mate/lib/widgets/shared/expandable_text_widget.dart` (created, 240 lines)
- `journey_mate/lib/widgets/shared/business_feature_buttons.dart` (created, 849 lines)
- `journey_mate/lib/services/translation_service.dart` (2 keys added)
- `_reference/NEW_TRANSLATION_KEYS.sql` (14 SQL INSERT statements appended)
- `_reference/SESSION_STATUS.md` (this file updated)

**Files Changed Session #4:**
- `journey_mate/lib/widgets/shared/menu_categories_rows.dart` (created, 1,106 lines)
- `_reference/SESSION_STATUS.md` (this file updated)

**Files Changed Session #5:**
- `journey_mate/lib/widgets/shared/package_courses_display.dart` (created, 571 lines)
- `journey_mate/lib/widgets/shared/package_bottom_sheet.dart` (created, 1,019 lines)
- `journey_mate/lib/widgets/shared/gallery_tab_widget.dart` (created, 617 lines)
- `journey_mate/lib/services/custom_functions/price_formatter.dart` (created, 118 lines)
- `_reference/PHASE7_LESSONS_LEARNED.md` (Session #5 appended)
- `_reference/SESSION_STATUS.md` (this file updated)

**Files Changed Session #6:**
- `journey_mate/lib/widgets/shared/opening_hours_and_weekdays.dart` (created, 392 lines)
- `journey_mate/lib/widgets/shared/contact_details_widget.dart` (created, 693 lines)
- `journey_mate/lib/widgets/shared/image_gallery_overlay_swipable_widget.dart` (created, 70 lines)
- `journey_mate/lib/services/translation_service.dart` (36 keys added: 23 for OpeningHoursAndWeekdays, 13 for ContactDetailsWidget)
- `_reference/NEW_TRANSLATION_KEYS.sql` (161 SQL INSERT statements appended)
- `_reference/SESSION_STATUS.md` (this file updated)

**Decisions Made Session #6:**
- OpeningHoursAndWeekdays implemented as StatefulWidget (matches FlutterFlow pattern)
- ContactDetailsWidget uses context.mounted instead of mounted for async operations (Flutter 3.x best practice)
- ImageGalleryOverlaySwipableWidget is a placeholder (ImageGalleryWidget from custom_widgets not yet implemented)
- Removed unused imports (app_colors, app_spacing) from opening_hours_and_weekdays.dart
- Used null-aware spread operator pattern for optional map entries (`...?note != null ? {'note': note} : null`)

**Files Changed Session #7:**
- `journey_mate/lib/widgets/shared/contact_us_form_widget.dart` (created, 550 lines)
- `journey_mate/lib/widgets/shared/feedback_form_widget.dart` (created, 680 lines)
- `journey_mate/lib/widgets/shared/nav_bar_widget.dart` (created, 300 lines)
- `shared/widgets/MASTER_README_nav_bar_widget.md` (created, documentation for NavBar)
- `journey_mate/lib/services/translation_service.dart` (53 keys added: 22 ContactUs + 31 Feedback)
- `_reference/NEW_TRANSLATION_KEYS.sql` (371 SQL INSERT statements appended: 154 ContactUs + 217 Feedback)
- `_reference/BATCH6_TRANSLATION_KEYS.sql` (created as intermediate file, 371 statements)
- `_reference/SESSION_STATUS.md` (this file updated)

**Decisions Made Session #7:**
- ContactUs + Feedback forms use self-contained local state (no provider for form state)
- Topic in FeedbackForm sent as localized label string (not stable key) to match BuildShip endpoint
- NavBar uses go_router for navigation (/search, /settings routes)
- NavBar falls back to LatLng(0, 0) if location unavailable
- CityID uses AppConstants.kDefaultCityId constant (17)
- Removed markUserEngaged() calls (method doesn't exist in current analyticsProvider)
- Fixed geolocator deprecated API (desiredAccuracy, timeLimit → LocationSettings)
- Fixed searchStateProvider.updateSearchResults signature (positional args, not named)
- Added GoogleFonts import to contact_us_form_widget.dart
- Used ignore comment for use_build_context_synchronously lint (valid mounted check)

**Files Changed Session #8:**
- `journey_mate/lib/widgets/shared/filter_titles_row.dart` (created, 147 lines)
- `journey_mate/lib/widgets/shared/category_description_sheet.dart` (created, 177 lines)
- `journey_mate/lib/widgets/shared/language_selector_button.dart` (created, 308 lines)
- `journey_mate/lib/services/translation_service.dart` (5 keys added: 3 FilterTitlesRow + 2 LanguageSelectorButton)
- `_reference/NEW_TRANSLATION_KEYS.sql` (35 SQL INSERT statements appended: 5 keys × 7 languages)
- `_reference/SESSION_STATUS.md` (this file updated)

**Files Changed Session #9:**
- `journey_mate/lib/widgets/shared/restaurant_shimmer_widget.dart` (created, 336 lines)
- `journey_mate/lib/widgets/shared/user_feedback_buttons_page.dart` (created, 145 lines)
- `journey_mate/lib/widgets/shared/user_feedback_buttons_topic.dart` (created, 145 lines)
- `journey_mate/lib/services/translation_service.dart` (5 keys added: UserFeedbackButtonsPage)
- `_reference/NEW_TRANSLATION_KEYS.sql` (35 SQL INSERT statements appended: 5 keys × 7 languages)
- `_reference/SESSION_STATUS.md` (this file updated)

**Files Changed Session #10:**
- `journey_mate/lib/widgets/shared/restaurant_list_shimmer_widget.dart` (created, 222 lines)
- `journey_mate/lib/widgets/shared/allergies_filter_widget.dart` (created, 296 lines)
- `journey_mate/lib/widgets/shared/dietary_restrictions_filter_widget.dart` (created, 543 lines)
- `_reference/SESSION_STATUS.md` (this file updated)

**Decisions Made Session #8:**
- FilterTitlesRow uses exact column widths: 36%/33%/31% (no rounding)
- FilterTitlesRow displays 3 tabs: Location, Type, Needs (filter_location, filter_type, filter_preferences)
  - **⚠️ CORRECTION:** Initial implementation used wrong keys (restrictions_title, preferences_title, allergens_title). User provided actual Supabase data showing correct keys are filter_location, filter_type, filter_preferences. Widget code, translation_service.dart, and SQL corrected mid-session.
- CategoryDescriptionSheet requires scrollController prop (used inside DraggableScrollableSheet)
- LanguageSelectorButton shows language names in native form (Dansk, not Danish)
- LanguageSelectorButton reloads translations + filters on language change
- Removed unused imports to pass flutter analyze
- Translation keys: filter_location, filter_type, filter_preferences (3), settings_language_label, settings_select_language_title (2) = 5 keys total

**Decisions Made Session #9:**
- RestaurantShimmerWidget uses AnimationController with 1.5-second duration (smooth, not jarring)
- RestaurantShimmerWidget uses design tokens: AppColors.bgSurface/bgPage/bgInput instead of raw Colors.grey
- RestaurantShimmerWidget added SingleTickerProviderStateMixin for AnimationController vsync
- UserFeedbackButtonsPage uses ts(context, key) for static translations (5 new keys added)
- UserFeedbackButtonsTopic uses td(ref, key) for dynamic translations (existing Supabase keys)
- UserFeedbackButtonsTopic is ConsumerStatefulWidget to access ref for td() helper
- Both feedback button widgets use identical visual pattern (orange selected, white unselected)
- Both feedback button widgets use ListView.separated with horizontal scroll
- Removed unused _fontSize constant from both feedback widgets (caught by flutter analyze)
- Topic keys already exist in Supabase (no new translation keys needed for UserFeedbackButtonsTopic)

**Decisions Made Session #10:**
- RestaurantListShimmerWidget uses design tokens (AppColors.border, bgSurface, bgCard, divider, AppSpacing.*)
- RestaurantListShimmerWidget uses SingleTickerProviderStateMixin + AnimationController (1.5s duration)
- AllergiesFilterWidget visual logic: Orange = NOT excluded (inverse of typical selected state)
- DietaryRestrictionsFilterWidget auto-selection only for restrictions with allergen requirements (IDs 1, 4)
- Both filter widgets removed analytics tracking calls (no trackEvent method exists in analyticsProvider)
- Both filter widgets use td(ref, key) for translations (no new keys needed - all exist in Supabase)
- Both filter widgets use identical visual styling (AppColors.accent/bgInput, AppRadius.button)
- All 3 widgets use design tokens (no raw colors, no magic numbers)
- Single underscore for unused separatorBuilder parameters (not double underscore)

**Files Changed Session #11:**
- `journey_mate/lib/providers/provider_state_classes.dart` (added 3 dietary filter fields to BusinessState + copyWithNullable)
- `journey_mate/lib/providers/business_providers.dart` (added 4 dietary filter management methods)
- `journey_mate/lib/widgets/shared/unified_filters_widget.dart` (created, 1,032 lines)
- `_reference/SESSION_STATUS.md` (this file updated)

**Decisions Made Session #11:**
- UnifiedFiltersWidget uses ConsumerStatefulWidget (needs businessProvider reads/writes)
- Added 3 fields to BusinessState: selectedDietaryRestrictionIds (List<int>), selectedDietaryPreferenceId (int?), excludedAllergyIds (List<int>)
- Added 4 methods to BusinessNotifier: setDietaryRestrictions(), setDietaryPreference(), setExcludedAllergies(), clearDietaryFilters()
- BusinessState.copyWithNullable() method added for nullable preference ID handling
- Preserved all 7 algorithms unchanged from FlutterFlow (dietary mappings, auto-selection, item count calculation)
- Used ApiService.instance.postAnalytics() directly for fire-and-forget analytics (no await)
- Removed markUserEngaged() calls (ActivityScope handles engagement automatically)
- Used td(ref, key) for all translations (no new keys needed - all exist in Supabase)
- Fixed catchError callback to return ApiCallResponse.failure() (required by return type)
- Removed unused app_providers.dart import (translationsCacheProvider accessed via td() helper)
- Used context.mounted instead of mounted after async operations (Flutter 3.x pattern)
- All design tokens applied (AppColors, AppSpacing, AppRadius)
- Widget-local state for scroll controllers and menu data cache (not Notifier classes)

**Files Changed Session #12:**
- `journey_mate/lib/widgets/shared/menu_dishes_list_view.dart` (created, 1,991 lines - SOLO SESSION)
- `journey_mate/lib/services/api_service.dart` (imported for analytics)
- `journey_mate/lib/services/custom_functions/price_formatter.dart` (imported for price conversion)
- `_reference/SESSION_STATUS.md` (this file updated)

**Decisions Made Session #12:**
- MenuDishesListView uses ConsumerStatefulWidget (needs provider reads for menu data, filters, translations)
- Preserved all 6 algorithms exactly from FlutterFlow (data processing, filtering, scroll tracking, pricing, index mapping, analytics)
- Critical allergen override exception implemented: items with can-be-made types bypass allergen filtering
- Three-stage dietary filter: restrictions (AND), preferences (OR), allergens (NOT) with override
- Two-zone scroll detection: top zone (-0.1 to 0.3) prioritized over bottom zone (0.7 to 1.1)
- Variation pricing calculates effective price and "From" prefix logic correctly
- All 14 state variables kept as widget-local State variables (NOT Notifier classes) per Session #4 lesson
- Removed all 4 markUserEngaged() calls (ActivityScope handles engagement automatically)
- Fixed analytics tracking: replaced AnalyticsService.trackEvent() with ApiService.instance.postAnalytics()
- Converted _MenuItem from StatelessWidget to ConsumerWidget for td(ref, key) translation access
- Used convertAndFormatPrice() from price_formatter.dart for currency conversion
- All design tokens applied (AppColors, AppSpacing, AppTypography, AppRadius)
- Translation keys: 5 keys total (menu_no_dishes, menu_multi_course_singular/plural, price_from, price_per_person) - all exist in Supabase
- flutter analyze: 0 issues (fixed all 11 initial issues)

**Files Changed Session #13:**
- `journey_mate/lib/widgets/shared/item_bottom_sheet.dart` (created, 1,780 lines - SOLO SESSION)
- `journey_mate/lib/services/custom_functions/allergen_formatter.dart` (created, 109 lines)
- `journey_mate/lib/services/custom_functions/dietary_formatter.dart` (created, 99 lines)
- `journey_mate/lib/services/custom_functions/currency_name_formatter.dart` (created, 72 lines)
- `_reference/SESSION_STATUS.md` (this file updated)

**Decisions Made Session #13:**
- ItemBottomSheet uses ConsumerStatefulWidget (needs localization/translations providers for language/currency switching)
- 10 local state variables for self-contained language/currency switching (temporary overrides don't affect parent state)
- Language data caching (_languageDataCache) enables instant re-switching without API calls
- All 6 algorithms ported exactly from FlutterFlow (1,764 lines → 1,780 lines)
  1. Safe data extraction helpers (_getStringValue, _getBoolValue, _getListValue, _getIntListValue)
  2. Modifier group sorting (Variation → Option → Ingredient → Add-on) with constraint text generation
  3. Price calculation with currency conversion (base price + "From" prefix + "per person" suffix)
  4. Allergen display (convertAllergiesToString with isBeverage flag)
  5. Dietary preferences display (convertDietaryPreferencesToString with isBeverage flag)
  6. Dynamic menu options generation (12+ business rules for language/currency options)
- Menu logic rules implemented exactly per FlutterFlow lines 402-508
  - Language: English→Danish, Danish→English, Other→3 authentic languages
  - Currency: USD/GBP→DKK, English+DKK→USD+GBP, Other→DKK
  - Priority: Always offer return to app language if viewing different language
- Removed all markUserEngaged() calls (ActivityScope handles engagement automatically)
- Used context.mounted after all async operations (Flutter 3.x pattern)
- Created 3 stub custom function files (allergen_formatter, dietary_formatter, currency_name_formatter)
- Each custom function file includes getTranslations() helper for translation cache access
- All design tokens applied (AppColors, AppSpacing, AppTypography, AppRadius)
- Translation keys: All from kStaticTranslations map (info_header_*, price_*, modifier_*, menu_*, lang_name_*)
- flutter analyze: 2 info-level warnings (acceptable - correct context.mounted usage after async)

**Files Changed Session #14:**
- `journey_mate/lib/widgets/shared/erroneous_info_form_widget.dart` (created, 510 lines)
- `journey_mate/lib/widgets/shared/currency_selector_button.dart` (created, 478 lines)
- `journey_mate/lib/services/api_service.dart` (added Endpoint #13: postErroneousInfo)
- `journey_mate/lib/services/translation_service.dart` (24 keys added: 13 ErroneousInfo + 11 Currency)
- `_reference/NEW_TRANSLATION_KEYS.sql` (168 SQL INSERT statements appended: 91 ErroneousInfo + 77 Currency)
- `_reference/SESSION_STATUS.md` (this file updated)

**Decisions Made Session #14:**
- BusinessHoursWidget deferred (no FlutterFlow source or MASTER_README exists; OpeningHoursAndWeekdays already complete from Session #6)
- Batch #13 completed with 2 widgets instead of 3
- ErroneousInfoFormWidget uses ConsumerStatefulWidget with local form state (no provider for form validation)
- ErroneousInfoFormWidget implements 3-state UI pattern (default/success/error) matching MissingLocationFormWidget
- Form validation: minimum 10 characters, real-time error clearing on user input
- API Endpoint #13 added to api_service.dart: `POST /erroneousinfo`
- CurrencySelectorButton uses ConsumerStatefulWidget with local overlay state (GlobalKey + RenderBox positioning)
- CurrencySelectorButton supports 11 currencies: DKK, USD, GBP, EUR, SEK, NOK, PLN, JPY, CNY, UAH, CHF
- Exchange rates fetched from BuildShip API `/exchangerate?to_currency={code}` (DKK is base 1:1)
- Language change detection implemented with smart fallback logic (preserves user currency choice across language switches)
- Overlay positioning preserved exactly from FlutterFlow (4px gap between button and overlay)
- Removed all markUserEngaged() calls (ActivityScope handles engagement automatically)
- Used context.mounted checks after all async operations (Flutter 3.x pattern)
- Fixed analytics catchError to return ApiCallResponse.failure() (required by return type)
- Used .withValues(alpha:) instead of deprecated .withOpacity() (Flutter 3.x pattern)
- All design tokens applied (AppColors, AppSpacing, AppRadius, AppTypography)
- Translation keys: 13 ErroneousInfo keys + 11 Currency keys = 24 keys × 7 languages = 168 SQL statements
- flutter analyze: 0 issues in both new widgets (2 pre-existing issues in item_bottom_sheet.dart from Session #13)

**Files Changed Session #15:**
- `journey_mate/lib/widgets/shared/menu_item_card.dart` (created, ~210 lines)
- `journey_mate/lib/widgets/shared/dietary_preferences_filter_widgets.dart` (created, ~350 lines)
- `journey_mate/lib/services/translation_service.dart` (2 keys added)
- `_reference/NEW_TRANSLATION_KEYS.sql` (14 SQL INSERT statements appended)
- `_reference/SESSION_STATUS.md` (this file updated)

**Files Changed Session #16:**
- `journey_mate/lib/widgets/shared/selected_filters_btns.dart` (created, 736 lines)
- `journey_mate/lib/widgets/shared/search_results_list_view.dart` (created, 617 lines)
- `journey_mate/lib/services/custom_functions/price_formatter.dart` (added convertAndFormatPriceRange method)
- `journey_mate/lib/services/translation_service.dart` (1 key added: search_clear_all)
- `_reference/NEW_TRANSLATION_KEYS.sql` (7 SQL INSERT statements appended)
- `_reference/SESSION_STATUS.md` (this file updated)

**Decisions Made Session #15:**
- MenuItemCard is pure StatelessWidget (no provider dependencies)
- MenuItemCard design derived from JSX spec + MenuDishesListView patterns (no FlutterFlow source)
- MenuItemCard dietary badge icons: Vegan (eco), Vegetarian (spa), Pescetarian (set_meal)
- DietaryPreferencesFilterWidgets uses ConsumerStatefulWidget with businessProvider/filterProvider reads
- Preserved allergen conflict validation logic from FlutterFlow
- Removed all markUserEngaged() calls (ActivityScope handles engagement automatically)
- Used td(ref, key) for dietary preference translations (dynamic Supabase keys)
- Analytics tracking with required deviceId, sessionId, userId, timestamp parameters
- All design tokens applied (AppColors.accent for selected, AppColors.bgInput for unselected)
- WidgetStateProperty used (not MaterialStateProperty - Flutter 3.x)
- Translation keys: 2 keys × 7 languages = 14 SQL statements
- flutter analyze: 0 issues in both new widgets (2 pre-existing issues in item_bottom_sheet.dart remain)

**Decisions Made Session #16 (Final Preliminary Task Session):**
- SelectedFiltersBtns implements all 3 critical algorithms from FlutterFlow: filter flattening (233-295), smart display names (344-386), button width caching (221-229)
- Widget calls ApiService.instance.search() directly (no performSearch provider method to avoid circular dependencies)
- SearchResultsListView uses ref.watch().select() for selective rebuild pattern (only rebuilds when searchResults changes)
- Status caching pattern preserved: Map<int, String/Color> cache at parent level, child loads lazily, callback updates parent
- 6 custom functions created as stubs: status_calculator, hours_formatter, distance_calculator, address_formatter, session_tracker (all return hardcoded values for now)
- convertAndFormatPriceRange() added to price_formatter.dart (builds range string from two formatted prices)
- Removed markUserEngaged() calls (ActivityScope handles engagement automatically)
- Fixed textScaleFactor → MediaQuery.textScalerOf(context).scale(1.0) (Flutter 3.x pattern)
- Nested _BusinessListItem is StatefulWidget (not ConsumerWidget) - only parent needs Riverpod access
- Translation keys: 1 key × 7 languages = 7 SQL statements (search_clear_all)
- flutter analyze: 2 info-level issues (both pre-existing from item_bottom_sheet.dart Session #13)
- **ALL 34 SHARED WIDGETS NOW COMPLETE ✅**

**Files Changed Session #17 (Phase 7.3.1 - FilterOverlayWidget):**
- `journey_mate/lib/widgets/shared/filter_overlay_widget.dart` (created, ~1,750 lines - SOLO SESSION)
- `_reference/PHASE7.3_SESSION2_HANDOVER.md` (created, comprehensive handover document)
- `_reference/SESSION_STATUS.md` (this file updated)

**Decisions Made Session #17:**
- FilterOverlayWidget is PREREQUISITE for Search page (not part of original 34-widget preliminary task)
- Complete 1,715-line port from FlutterFlow with zero compromises (production-ready quality)
- Presentation layer change only: inline modal → bottom sheet (content 100% identical)
- All 20+ edge cases preserved: neighborhood/shopping/train coordination, Category 8 parent-child, dietary composites
- Debounced search: 300ms delay (matches FlutterFlow, different from 200ms Search page will use)
- Widget-local state pattern: State variables with setState() (not Notifier classes)
- Translation keys: 5 keys × 7 languages = 35 SQL statements (deferred to Phase 6B)
- flutter analyze: Expected 0 issues (following patterns from 34 previous widgets)

🎉 **FilterOverlayWidget COMPLETE! Ready for Phase 7.3.2 (Search Page implementation).**

**Next Session Must Do:**
1. Read `_reference/PHASE7.3_SESSION2_HANDOVER.md` — comprehensive plan for Search page
2. Read `CLAUDE.md` + `_reference/PHASE7_LESSONS_LEARNED.md` + `_reference/PROVIDERS_REFERENCE.md`
3. Read `DESIGN_SYSTEM_flutter.md` for design tokens
4. Read `_reference/BUILDSHIP_API_REFERENCE.md` for SEARCH endpoint
5. Read `pages/01_search/BUNDLE.md` for Search page functional spec
6. Implement Search page per 6-phase plan in handover document (~400 lines)
7. Run `flutter analyze` — MUST return 0 issues
8. Phase 6B: Add 15 new translation keys (15 keys × 7 languages = 105 SQL statements)
9. Update SESSION_STATUS.md
10. Commit with message: "feat(phase7.3): implement Search page ✅"

---

## Phase 6B/7/8 Workflow — Translation Key Management

### Phase 6B (ongoing during Phase 7 page implementation)

**For each page implemented in Phase 7:**

1. **While building the page:**
   - Use `ts(context, key)` for FlutterFlow keys already in `kStaticTranslations`
   - Use `td(ref, key)` for dynamic keys already in Supabase (allergens, dietary, etc.)
   - Any NEW hardcoded UI text → add temporary placeholder in code

2. **After page is complete:**
   - Identify all new hardcoded strings that need translation
   - Add new keys to `kStaticTranslations` map with descriptive names:
     - FlutterFlow keys: `'05aeogb1'` (8-char format)
     - New v2 keys: `'key_search_empty_state_title'` (descriptive snake_case)
   - Add all 7 language translations for each new key
   - Generate SQL INSERT statements for new keys
   - Append SQL to `_reference/NEW_TRANSLATION_KEYS.sql`

3. **Key naming convention:**
   ```dart
   // FlutterFlow keys (already in map)
   'xn0d16r3': { 'en': 'Search', 'da': 'Søg', ... }

   // New Phase 6B keys (add as needed)
   'key_search_empty_state_title': {
     'en': 'No results found',
     'da': 'Ingen resultater fundet',
     ...
   }
   ```

4. **SQL format for NEW_TRANSLATION_KEYS.sql:**
   ```sql
   -- Page: Search (Phase 7.2)
   INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
   VALUES
     ('key_search_empty_state_title', 'en', 'No results found', 'ui'),
     ('key_search_empty_state_title', 'da', 'Ingen resultater fundet', 'ui'),
     -- ... all 7 languages
   ;
   ```

### Phase 8 (after all pages complete)

**Final migration to 100% dynamic translations:**

1. **Verify Supabase has all keys:**
   - Run `NEW_TRANSLATION_KEYS.sql` to insert all Phase 6B keys into `ui_translations`
   - Verify count: 191 FlutterFlow + Phase 6B new keys = total expected
   - Check: `SELECT COUNT(*) FROM ui_translations WHERE translation_key LIKE 'key_%'`

2. **Switch app to 100% dynamic:**
   - Replace all `ts(context, key)` calls with `td(ref, key)` across all pages
   - Verify `translationsCacheProvider` loads all keys on startup
   - Test app in English and Danish to confirm all text appears

3. **Remove hardcoded translations:**
   - Delete `kStaticTranslations` map from `translation_service.dart`
   - Delete or deprecate `ts()` helper (or make it alias to `td()`)
   - Update file header to remove TEMPORARY warnings
   - Run `flutter analyze` — must pass

4. **Verify end state:**
   - ✅ 100% of translations in Supabase `ui_translations` table
   - ✅ 0% hardcoded text in app
   - ✅ Single translation API: `td(ref, key)` for everything
   - ✅ `kStaticTranslations` deleted
   - ✅ All languages load from BuildShip API (`https://wvb8ww.buildship.run/languageText`)

**Result:** Pure, fully dynamic translation system with single source of truth in Supabase.

---

## Open questions for user

None. Phase 6A complete. Phase 7 can begin immediately with Welcome/Onboarding page.

---

## How to resume in a new chat

Paste this into the new chat window:

> Working directory: `C:\Users\Rikke\Documents\JourneyMate-Organized`
> Read `CLAUDE.md` completely, then read `_reference/SESSION_STATUS.md`, then tell me what we're picking up and start the next task.
