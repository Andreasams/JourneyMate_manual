# SESSION_STATUS.md
## Project: JourneyMate-Organized — Flutter migration
## Always update this before ending a session.

---

## Current Status

**Phase:** Phase 4 — Flutter foundation
**Last completed task:** Phase 3.5 complete — all BuildShip/Supabase changes executed and verified (2026-02-20)
**Next task:** Phase 4 — Flutter foundation (theme, router, API service, translation infrastructure, analytics service)
**Blocked on:** Nothing — Phase 4 can start immediately.

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
| Phase 4 | ⏳ Not started | Flutter foundation (theme, router, API service, translation, analytics) |
| Phase 4.5 | ⏳ Not started | Codemagic CI/CD |
| Phase 5 | ⏳ Not started | Riverpod providers |
| Phase 6 | ⏳ Not started | Translation infrastructure |
| Phase 7 | ⏳ Not started | Page implementation (12 pages) |
| Phase 8 | ⏳ Not started | Integration polish |

---

## Key reference files (read these at session start)

| File | Purpose |
|------|---------|
| `CLAUDE.md` | All session rules, decisions, procedures |
| `_reference/SESSION_STATUS.md` | This file — current project state |
| `_reference/BUILDSHIP_API_REFERENCE.md` | All 12 BuildShip endpoints — exact inputs/outputs |
| `_reference/MASTER_STATE_MAP.md` | All FFAppState vars → Riverpod mapping |
| `_reference/IMPLEMENTATION_PLAN.txt` | Full migration plan |
| `DESIGN_SYSTEM_flutter.md` | All design tokens |

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

## Open questions for user

None. All Phase 3 and Phase 3.5 items resolved. Phase 4 can begin immediately.

---

## How to resume in a new chat

Paste this into the new chat window:

> Working directory: `C:\Users\Rikke\Documents\JourneyMate-Organized`
> Read `CLAUDE.md` completely, then read `_reference/SESSION_STATUS.md`, then tell me what we're picking up and start the next task.
