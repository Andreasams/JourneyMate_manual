# SESSION_STATUS.md
## Project: JourneyMate-Organized — Flutter migration
## Always update this before ending a session.

---

## Current Status

**Phase:** Phase 7 Preliminary Task — Shared widget implementation (5/29 complete)
**Last completed task:** Batch 2 — BusinessFeatureButtons + ExpandableTextWidget complete (2026-02-21 Session #3)
**Next task:** Batch 3 (Solo) — MenuCategoriesRows (⭐⭐⭐⭐⭐ EXTREME complexity, 1,250 lines, BLoC→Riverpod migration)
**Blocked on:** Nothing — continue widget implementation per PHASE7_LESSONS_LEARNED.md protocol

**⚠️ Session Scope Rule:** Each Claude Code session works on ONLY ONE aspect at a time:
- **For widgets:** 3 widgets per session (except menu_dishes_list_view and filter_overlay_widget — solo sessions)
- **For pages:** 1 page per session

**Execution order change:** Phase 4.5 (Codemagic CI/CD) is POSTPONED until after Phase 5 (not skipped). Execution order is now: Phase 4 → Phase 5 → Phase 4.5 → Phase 6 → Phase 7 → Phase 8.

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
| Phase 4.5 | 🔄 Postponed | Codemagic CI/CD (postponed until after Phase 5) |
| Phase 5 | ✅ Complete | All 8 Riverpod providers + 70 tests + PROVIDERS_REFERENCE.md |
| Phase 6A | ✅ Complete | Translation service with 191 static keys from FlutterFlow |
| Phase 6B | 🔄 Ongoing | Per-page translation key additions (runs parallel with Phase 7) |
| Phase 7 | 🔄 In Progress | Preliminary Task: 1/29 widgets complete (PaymentOptionsWidget) |
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
| 6-29 | [Remaining 24 widgets] | Various | ⏳ Pending | #4-11 | — |

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

**Next Session Must Do:**
1. Read `CLAUDE.md` + `_reference/PHASE7_LESSONS_LEARNED.md` + `_reference/PROVIDERS_REFERENCE.md`
2. Read `DESIGN_SYSTEM_flutter.md` for design tokens
3. Dedicate FULL session to MenuCategoriesRows (⭐⭐⭐⭐⭐ EXTREME: 1,250 lines, BLoC→Riverpod migration)
4. DO NOT batch MenuCategoriesRows with other widgets (solo session required)
5. Run `flutter analyze` — MUST return 0 issues
6. Append lessons learned to PHASE7_LESSONS_LEARNED.md (if relevant)
7. Update SESSION_STATUS.md
8. Commit

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
