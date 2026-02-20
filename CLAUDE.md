# JourneyMate-Organized — Claude Code Instructions

Read this file before touching anything. It defines how every session must work.

---

## What this project is

JourneyMate is a restaurant discovery app being migrated from a FlutterFlow export into clean,
production-ready Flutter code using Riverpod 2.x for state management.

**We are in Phase 3: Flutter migration.** The JSX design phase is complete. The FlutterFlow
export is the ground truth for all functionality. BUNDLE.md files per page are the
implementation specs. The new Flutter project (`journey_mate/`) is built by copying behavior
from FlutterFlow and applying the v2 design from `shared/app_theme.dart`.

---

## Working directory

`C:\Users\Rikke\Documents\JourneyMate-Organized\`

This is the single canonical folder. All work happens here.

---

## File structure — always maintain this

```
JourneyMate-Organized/
  CLAUDE.md                          ← this file
  DESIGN_SYSTEM_flutter.md           ← all color, spacing, typography tokens (read before every session)
  MASTER_TRANSLATION_KEYS.md         ← all known translation keys
  _flutterflow_export/               ← FlutterFlow export (READ-ONLY — ground truth for ALL functionality)
    lib/
      app_state.dart                 ← FFAppState — source of truth for all state variables
      backend/api_requests/api_calls.dart  ← all BuildShip API calls
      custom_code/                   ← actual code for all custom actions/widgets/functions
  pages/
    01_search/
      BUNDLE.md                      ← implementation spec
      GAP_ANALYSIS.md                ← what Claude builds vs. what needs BuildShip
    02_business_profile/
    03_menu_full_page/
    04_gallery_full_page/
    05_contact_details/
    06_welcome_onboarding/
    07_settings/
  shared/
    app_theme.dart                   ← design token source (ThemeData, colors, spacing, typography)
    actions/                         ← MASTER_README for every custom action
    widgets/                         ← MASTER_README for every custom widget
    functions/                       ← MASTER_README for every custom function
  _reference/                        ← Generated reference documents
    MASTER_STATE_MAP.md              ← FFAppState → Riverpod mapping (Phase 1 output)
    BUNDLE_STANDARD.md               ← Standard sections required in every BUNDLE.md
    BUNDLE_AUDIT_REPORT.md           ← Phase 2 audit output
    BUILDSHIP_REQUIREMENTS.md        ← Phase 3 API gap analysis
    MASTER_TASK_LIST.md              ← Phase 3.5 approved work plan
    PROVIDERS_REFERENCE.md           ← Phase 5 output: all Riverpod providers documented
    NEW_TRANSLATION_KEYS.sql         ← Running SQL file for new keys (appended per page)
  journey_mate/                      ← NEW Flutter project (production app being built)
    lib/
      main.dart
      app.dart
      router/app_router.dart
      providers/
      services/
      models/
      pages/
      widgets/shared/
      theme/
```

**Rules:**
- `_flutterflow_export/` is READ-ONLY. Never edit it.
- `_reference/` contains generated documents. Edit only to fill gaps, never to invent.
- `journey_mate/` is the production app. All new code goes here.
- Every feature must be traceable to the FlutterFlow source before implementation begins.

---

## Three sources for every feature (REQUIRED before writing any code)

For any widget, page, or feature:

1. **BUNDLE.md** — functional spec for what to build (pages/XX_name/BUNDLE.md)
2. **FlutterFlow source** — ground truth code (`_flutterflow_export/lib/`)
3. **Design system** — visual correctness (`DESIGN_SYSTEM_flutter.md` + `shared/app_theme.dart`)

**Never guess or invent functionality.** Always read the FlutterFlow source first.

For every custom widget/action/function a page uses, also read its `shared/` MASTER_README
AND its source in `_flutterflow_export/lib/custom_code/`.

---

## Tech stack

- **Flutter 3.x** (currently 3.41.x)
- **Riverpod 2.x** (`flutter_riverpod`) — state management for ALL state. No FFAppState, no Provider.
- **go_router 12.x** — routing
- **BuildShip REST API** — all backend including auth. No direct Supabase SDK calls.
- **FlutterSecureStorage** — session token, sensitive preferences
- **SharedPreferences** — user language, currency, city preferences
- **google_fonts** — typography
- **flutter_animate** — animations
- **geolocator** — location
- **map_launcher** — open in maps actions
- **http** — raw HTTP client for BuildShip API calls

---

## State management: Riverpod (not FFAppState, not Provider)

Every FFAppState variable has been mapped to a Riverpod provider in `_reference/MASTER_STATE_MAP.md`.
Refer to `_reference/PROVIDERS_REFERENCE.md` for the canonical list of providers.

**Key rules:**
- Global persisted state → `StateNotifierProvider` backed by SharedPreferences/SecureStorage
- Session-shared state → `StateNotifierProvider` at app scope
- Page-local state → local `ConsumerStatefulWidget` state (NOT a provider)
- No `FFAppState` references anywhere in `journey_mate/`

---

## Auth decision

No direct Supabase SDK. Authentication flows through BuildShip → Supabase.
The Flutter app treats "logged in" as a local state (token stored in SecureStorage).

On launch: always route to `/welcome`. The welcome page handles new vs. returning user
distinction by checking stored language preference via `getUserPreference('user_language_code')`.

---

## Page implementation workflow (repeat for EVERY page)

Before implementing any page:
1. Re-read `DESIGN_SYSTEM_flutter.md`
2. Re-read `_reference/PROVIDERS_REFERENCE.md`
3. Read `pages/XX_name/BUNDLE.md`
4. Read `pages/XX_name/GAP_ANALYSIS.md` — classify "Claude builds" vs "BuildShip-blocked"
5. For every custom widget/action/function: read its `shared/` MASTER_README + FlutterFlow source
6. Verify the page's BuildShip dependencies are not blocked in `_reference/BUILDSHIP_REQUIREMENTS.md`
7. Implement following BUNDLE.md checklist exactly
8. After page is complete: run translation key pass → append to `_reference/NEW_TRANSLATION_KEYS.sql`
9. Run code review against DESIGN_SYSTEM_flutter.md + BUNDLE.md + PROVIDERS_REFERENCE.md
10. Run `flutter analyze` — must return 0 warnings, 0 errors
11. Commit

---

## Page order (dependency-driven)

| # | Page | BUNDLE.md |
|---|------|-----------|
| 7.1 | Welcome / Onboarding | pages/06_welcome_onboarding/BUNDLE_welcome_page.md |
| 7.2 | Search | pages/01_search/BUNDLE.md |
| 7.3 | Business Profile | pages/02_business_profile/BUNDLE.md |
| 7.4 | Menu Full Page | pages/03_menu_full_page/BUNDLE.md |
| 7.5 | Gallery Full Page | pages/04_gallery_full_page/BUNDLE.md |
| 7.6 | Contact Details | pages/05_contact_details/BUNDLE_information_page.md |
| 7.7 | Settings Main | pages/07_settings/settings_main/BUNDLE.md |
| 7.8 | Localization | pages/07_settings/localization/ |
| 7.9 | Location Sharing | pages/07_settings/location_sharing/ |
| 7.10 | Contact Us | pages/07_settings/contact_us/ |
| 7.11 | Share Feedback | pages/07_settings/share_feedback/ |
| 7.12 | Missing Place | pages/07_settings/missing_place/ |

---

## Code review checklist (run after every page)

**Design token adherence:**
- [ ] All colors from `AppColors` (no raw hex strings)
- [ ] All spacing from `AppSpacing` (no magic pixel numbers)
- [ ] All text styles from `AppTypography` (no inline TextStyle)
- [ ] Orange (`#e8751a`) only for CTAs/interactive elements (never match status)
- [ ] Green (`#1a9456`) only for match confirmation (never CTAs)
- [ ] Filter column widths are exactly 36%/33%/31%

**BUNDLE.md adherence:**
- [ ] Every widget listed is implemented
- [ ] Every action triggers the correct state change
- [ ] Every analytics event is tracked
- [ ] Every API call is made at the correct trigger point
- [ ] Every navigation action is wired
- [ ] All edge cases handled (empty, loading, error)

**State correctness:**
- [ ] No FFAppState references
- [ ] All reads from correct Riverpod provider per PROVIDERS_REFERENCE.md
- [ ] Page-local state in local widget state (not a provider)
- [ ] No hardcoded strings (all text uses `td()` or `ts()`)

**Code quality:**
- [ ] `flutter analyze` returns 0 warnings, 0 errors
- [ ] No unaddressed TODOs

---

## Flutter code conventions

- Use `ConsumerStatefulWidget` for pages with local state, `ConsumerWidget` for pure display
- Bottom sheets: `showModalBottomSheet` with `DraggableScrollableSheet`
- Page transitions: `PageRouteBuilder` with `SlideTransition`
- All API calls go through `journey_mate/lib/services/api_service.dart`
- Translation: `td(key)` for dynamic BuildShip keys, `ts(context, key)` for static keys
- Analytics: always fire-and-forget (don't await analytics calls)

## Font weight mapping

| Design value | Flutter FontWeight |
|--------------|-------------------|
| 420–460 | `FontWeight.w400` |
| 480–540 | `FontWeight.w500` |
| 560–600 | `FontWeight.w600` |
| 620–680 | `FontWeight.w700` |
| 700–750 | `FontWeight.w800` |

---

## Git workflow

Git is initialized in `JourneyMate-Organized/`. Commit after every completed task.

**Commit message format:** `feat/fix/chore/docs: short description`

Commit after:
- Completing a task or phase
- Before trying something risky
- At end of each session

---

## What not to do

- Do not edit `_flutterflow_export/` (read-only ground truth)
- Do not add direct Supabase SDK calls — all backend is through BuildShip
- Do not invent functionality — always reference FlutterFlow source first
- Do not use FFAppState or Provider in `journey_mate/`
- Do not add raw hex colors — use `AppColors` constants
- Do not add magic numbers — use `AppSpacing` constants
- Do not refactor working code unless explicitly asked
- Do not add features beyond what BUNDLE.md specifies
