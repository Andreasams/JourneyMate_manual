# JourneyMate-Organized — Claude Code Instructions

Read this file before touching anything. It defines how every session must work.

**FIRST ACTION IN EVERY SESSION:**
1. Read this file completely
2. Read `_reference/SESSION_STATUS.md` — it tells you exactly where the project is and what to do next
3. Read `_reference/BUILDSHIP_API_REFERENCE.md` — the exact API contract for all BuildShip endpoints
4. Then read any phase-specific files listed in SESSION_STATUS.md

---

## What this project is

JourneyMate is a restaurant discovery app being migrated from a FlutterFlow export into clean,
production-ready Flutter code using Riverpod 3.x for state management.

**Check `_reference/SESSION_STATUS.md` for the current phase.** The FlutterFlow export is the
ground truth for all functionality. BUNDLE.md files per page are the implementation specs.
The new Flutter project (`journey_mate/`) is built by copying behavior from FlutterFlow and
applying the v2 design from `DESIGN_SYSTEM_flutter.md` and `shared/app_theme.dart`.

---

## Working directory

`C:\Users\Rikke\Documents\JourneyMate-Organized\`

This is the single canonical folder. All work happens here.

**GitHub repo:** `https://github.com/Andreasams/JourneyMate_manual`
(Not `JourneyMate` — that is the old JSX/FlutterFlow project. This is the clean Flutter rebuild.)

**Implementation plan:** `_reference/IMPLEMENTATION_PLAN.txt` — the master migration plan for this project.

---

## Session handover — how to end a session cleanly

**Before ending any session** (whether the user says "let's continue in a new chat", or you reach a natural phase boundary, or the context is getting large), do the following:

### Step 1: Update SESSION_STATUS.md

`_reference/SESSION_STATUS.md` is the handover document. Every new session reads it first. Update it to reflect the current state:

```markdown
## Current Status
- Phase: X
- Last completed task: [task name + what was done]
- Next task: [exact task name from IMPLEMENTATION_PLAN]
- Blocked on: [anything waiting for user action, or "nothing"]

## Files changed this session
- [list of files created or modified]

## Decisions made this session
- [any new decisions not yet in CLAUDE.md or design docs]

## What the next session must do first
- [exact first steps, e.g. "Read pages/01_search/BUNDLE.md then start Task 2B audit for search page"]

## Open questions for user
- [anything needing user input before next task can proceed]
```

### Step 2: Update CLAUDE.md if new decisions were made

Any decision made during the session that is not yet in CLAUDE.md must be added to the **Known product decisions** section before closing.

### Step 3: Commit

```
git add _reference/SESSION_STATUS.md CLAUDE.md
git commit -m "docs: end-of-session handover update"
```

### How to start a new session from a handover

The user pastes this into the new chat:

> "Working directory: C:\Users\Rikke\Documents\JourneyMate-Organized. Read CLAUDE.md and then SESSION_STATUS.md and tell me what we're picking up."

That is sufficient. The new session reads CLAUDE.md → SESSION_STATUS.md → picks up exactly where we left off.

---

## When the user gives feedback — update documents immediately

**This is a standing procedure.** Whenever the user provides corrections, clarifications, or new context during a session:

1. **Identify which documents are affected** (CLAUDE.md, MASTER_STATE_MAP.md, BUNDLE.md, GAP_ANALYSIS.md, BUILDSHIP_API_REFERENCE.md, etc.)
2. **Update those documents immediately** — before continuing any other work
3. **Commit the updates** with message `docs: update [file] based on user feedback`
4. **Then continue** with the task at hand

Do not leave feedback in code comments or conversation only. It must land in the reference documents where future sessions will find it.

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
    05_business_information/
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

**For any API call:** Always read `_reference/BUILDSHIP_API_REFERENCE.md` first — it documents the exact inputs and outputs for all 12 BuildShip endpoints. The raw BuildShip node scripts are in `_reference/_buildship/` if you need to go deeper. Never guess API shapes.

---

## Tech stack

- **Flutter 3.x** (currently 3.41.x)
- **Riverpod 3.x** (`flutter_riverpod: ^3.2.1`) — state management for ALL state. No FFAppState, no Provider.
- **go_router 17.x** (`go_router: ^17.1.0`) — routing
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
- Global persisted state → `NotifierProvider` or `AsyncNotifierProvider` backed by SharedPreferences/SecureStorage
- Session-shared state → `NotifierProvider` at app scope
- Page-local state → local `ConsumerStatefulWidget` state (NOT a provider)
- No `FFAppState` references anywhere in `journey_mate/`
- **Use Riverpod 3.x API** — `Notifier`/`AsyncNotifier` classes, not the deprecated `StateNotifier` pattern
- **Do NOT use `@riverpod` code generation** — write providers manually. `riverpod_annotation` and `riverpod_generator` are in pubspec but are not used. The confirmed approach is hand-written `NotifierProvider`/`AsyncNotifierProvider`.
- **⚠️ shared/ MASTER_README files use Riverpod 2.x patterns** (`StateNotifierProvider`, `StateNotifier`) — these were written before the version was confirmed. When implementing providers in Phase 5 or widgets in Phase 7, translate their code examples to Riverpod 3.x: `StateNotifierProvider<X, S>` → `NotifierProvider<X, S>`, `extends StateNotifier<S>` → `extends Notifier<S>` with `S build()` instead of a constructor.

---

## Auth decision

No direct Supabase SDK. Authentication flows through BuildShip → Supabase.
The Flutter app treats "logged in" as a local state (token stored in SecureStorage).

On launch: always route to `/welcome`. The welcome page handles new vs. returning user
distinction by checking stored language preference via `getUserPreference('user_language_code')`.

---

## Phase 7 — Page Implementation Protocol

**⚠️ CRITICAL: Before starting ANY Phase 7 work, you MUST:**

1. **Read the Phase 7 Session Protocol:**
   - Location: `_reference/PHASE7_LESSONS_LEARNED.md`
   - **SESSION SCOPE RULE (MANDATORY):** Each Claude Code session MUST work on ONLY ONE aspect at a time:
     - **For widgets:** 3 widgets per session (batch implementation)
     - **Exception:** `menu_dishes_list_view` and `filter_overlay_widget` are massive files — MUST be solo sessions
     - **For pages:** 1 page per session (NEVER multiple pages)
   - This document contains:
     - Session workflow (start → implementation → verification → end)
     - Lessons learned from all completed widgets/pages
     - Translation patterns discovered
     - Common pitfalls & solutions
     - Design token quick reference
     - Widget complexity guide
     - Implementation order recommendations
   - **Append to this file at end of EVERY session** with lessons learned

2. **Read the Phase 7 Implementation Plan:**
   - Location: `C:\Users\Rikke\.claude\plans\drifting-meandering-koala.md`
   - This 500+ line document contains:
     - Complete Phase 7 workflow (Preliminary Task: 29 widgets → 12 pages in strict order)
     - Per-page implementation guidelines with complexity ratings
     - Code review checklist (run after each page)
     - Translation key management protocol (Phase 6B)
     - Session handover protocol
   - **Do NOT skip this.** Every page implementation depends on this plan.

3. **Understand the strict dependency order:**
   - Preliminary Task: Build all 29 shared widgets FIRST (in batches of 3)
   - Then pages in this exact order: Welcome → Search → Business Profile → Menu/Gallery/Info → Settings pages
   - Do NOT skip ahead. Each page depends on previous pages' routing, state patterns, and reusable components.

4. **Follow the session workflow:**
   - Pre-implementation: Read PHASE7_LESSONS_LEARNED.md + Phase 7 plan + foundation docs + BUNDLE.md
   - Implementation: Build per BUNDLE.md checklist with design tokens
   - Post-implementation: flutter analyze, code review, Phase 6B translation keys, commit, SESSION_STATUS update
   - **Session end:** Append lessons learned to PHASE7_LESSONS_LEARNED.md

**The Phase 7 protocol documents are the single source of truth for all implementations.** Each separate Claude Code instance must reference them.

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
| 7.6 | Business Information | pages/05_business_information/BUNDLE_information_page.md |
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

## Known product decisions (confirmed by user)

These decisions have been explicitly confirmed and must not be re-debated:

- **CityID is always 17 (Copenhagen).** City selection is not implemented in v1. CityID does not need a provider or persistence — use a plain `const int kDefaultCityId = 17` constant and pass it directly to API calls. Do not build city-switching UI.

- **`restaurantIsFavorited` is a future feature.** Do not implement. No favorite button, no favorite state, no related UI.

- **Filter panel is now a bottom sheet, not a modal overlay.** The `filterOverlayOpen` / `activeSelectedTitleId` approach from FlutterFlow is replaced. In the new design, tapping "Filter" opens a `showModalBottomSheet`. Which tab is selected inside that sheet is local state in the bottom sheet widget itself. Do not build the 3-column inline overlay from FlutterFlow.

- **`foodDrinkTypes`** is populated from the `GET_FILTERS_FOR_SEARCH` BuildShip endpoint (returned as `foodDrinkTypes: FoodDrinkItem[]`). Store it in `filterProvider` alongside `filtersForUserLanguage`. It is NOT unused — it was just not referenced directly in page widgets (used indirectly through filter logic).

- **BuildShip API reference:** All 12 endpoints are documented in `_reference/BUILDSHIP_API_REFERENCE.md` with exact inputs and outputs. Always read this before touching API service code. (Endpoints 1–9 use custom BuildShip logic; endpoints 10–12 use `supabaseInsertObject` — direct Supabase REST POST with no server-side transformation.)

- **ContactUs Subject field is free-text.** Do not implement a dropdown. Match FlutterFlow: single `TextFormField`, free-text, non-empty validation. The JSX design shows a dropdown but FlutterFlow is the ground truth.

- **FeedbackForm topic is sent as the localized label string** (e.g. `"Bug"` or `"Fejl"`), not a stable key. This goes straight into a `text` column in Supabase via `supabaseInsertObject`. Foreign-language values are fine. Do not attempt to map to an English key before sending.

- **Welcome page analytics `pageName` is `'welcomePage'`** (corrected from `'homepage'` / `'welcomepage'`). This requires a matching update in the BuildShip handler and Supabase analytics table (user to manage separately). Flutter code must send `'welcomePage'`.

- **`pages/05_contact_details/` has been renamed to `pages/05_business_information/`** via `git mv`. Update any cross-references that still use the old path. BUNDLE.md filename inside the folder is still `BUNDLE_information_page.md`.

- **Translation migration path: 100% Supabase end goal** — Phase 6A creates temporary hardcoded `kStaticTranslations` map (191 FlutterFlow keys) as scaffolding for Phase 7 page implementation. Phase 6B appends new keys to both hardcoded map AND SQL file. Phase 8 (end of project) runs SQL to insert ALL keys into Supabase `ui_translations`, then app switches to `td()` for everything and deletes hardcoded map. **Ultimate goal: 0% hardcoded translations, 100% dynamic from Supabase BuildShip API.** Single source of truth for all languages. The hardcoded map in `translation_service.dart` is TEMPORARY and will be retired after Phase 7 SQL migration completes.

- **Portrait-only for iPhone, all orientations for iPad** — iPhone locked to portrait mode for optimal restaurant discovery UX (vertical scrolling, map views, menu browsing). iPad supports all orientations for table/counter browsing. Landscape rarely adds value for restaurant search and can break layouts.

- **Deep linking deferred to Phase 7** — No deep link handling code exists yet (go_router has no deepLink routes configured). iOS CFBundleURLTypes + FlutterDeepLinkingEnabled and Android intent-filter will be added when Phase 7 implements deep link routes for specific pages/businesses.

- **Codemagic uses journey_mate/ working config** — codemagic.yaml copied from `/c/Users/Rikke/Documents/JourneyMate/codemagic.yaml` (proven working). Single iOS workflow: builds IPA → submits to TestFlight. Build number offset +250 continues from last AppStore build (249). flutter analyze + flutter test as build gates.

- **iOS location permission strings match dietary use case** — NSLocationWhenInUseUsageDescription: "JourneyMate uses your location to find nearby restaurants that match your dietary needs". NSLocationAlwaysAndWhenInUseUsageDescription: "JourneyMate uses your location to find nearby restaurants that match your dietary preferences". Clearly states purpose for App Store review compliance.

- **LSApplicationQueriesSchemes includes 12 map apps** — Exact list from FlutterFlow: comgooglemaps, baidumap, iosamap, waze, yandexmaps, yandexnavi, citymapper, mapswithme, osmandmaps, dgis, qqmap, here-location. Required for map_launcher feature in contact_details_widget.dart "Open in Maps" button.

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
