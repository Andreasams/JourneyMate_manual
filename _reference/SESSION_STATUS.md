# SESSION_STATUS.md
## Project: JourneyMate-Organized — Flutter migration
## Always update this before ending a session.

---

## Current Status

**Phase:** Phase 2 — Bundle.md Audit (starting)
**Last completed task:** Task 1A — MASTER_STATE_MAP.md (Phase 1 complete)
**Next task:** Task 2A — Create BUNDLE_STANDARD.md, then Task 2B — Audit all 13 BUNDLE.md files
**Blocked on:** Nothing — ready to start

---

## Phases complete

| Phase | Status | Output |
|-------|--------|--------|
| Phase 0A | ✅ Complete | `CLAUDE.md` created |
| Phase 0B | ✅ Complete | `journey_mate/` Flutter project scaffolded, `flutter analyze` 0 issues |
| Phase 1 | ✅ Complete | `_reference/MASTER_STATE_MAP.md` — all 43 FFAppState variables mapped |
| Phase 2 | 🔄 Starting | `_reference/BUNDLE_STANDARD.md` + audit of 13 BUNDLE.md files |
| Phase 3 | ⏳ Not started | BuildShip gap analysis |
| Phase 3.5 | ⏳ Not started | Master task list (requires user approval) |
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
| `_reference/BUILDSHIP_API_REFERENCE.md` | All 9 BuildShip endpoints — exact inputs/outputs |
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

---

## Confirmed product decisions (see CLAUDE.md for full details)

1. **CityID = 17 (Copenhagen) always** — no city switching, use `const kDefaultCityId = 17`
2. **No favorites feature** — `restaurantIsFavorited` is future, skip entirely
3. **Filters are a bottom sheet in v2** — not inline 3-column overlay. Local tab state.
4. **foodDrinkTypes IS used** — populated by GET_FILTERS_FOR_SEARCH, stored in filterProvider
5. **No direct Supabase** — all API through BuildShip
6. **GitHub repo:** `Andreasams/JourneyMate_manual`

---

## Phase 2: What the next session must do

**Task 2A:** Create `_reference/BUNDLE_STANDARD.md` (the standard template all BUNDLE.md files must follow)

**Task 2B:** Audit each of these 13 files against the standard, cross-reference with MASTER_STATE_MAP.md and BUILDSHIP_API_REFERENCE.md:

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

None currently. Phase 2 can start immediately.

---

## How to resume in a new chat

Paste this into the new chat window:

> Working directory: `C:\Users\Rikke\Documents\JourneyMate-Organized`
> Read `CLAUDE.md` completely, then read `_reference/SESSION_STATUS.md`, then tell me what we're picking up and start the next task.
