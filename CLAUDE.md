# JourneyMate — Claude Code Instructions

**Read this file before touching anything. It defines how every session must work.**

---

## Project Status

- **App:** JourneyMate restaurant discovery app
- **Phase:** 8 (Maintenance & Debugging)
- **Deployment:** ✅ Live on TestFlight (since 2026-02-22)
- **Tech Stack:** Flutter 3.41.x, Riverpod 3.x, BuildShip REST API
- **Migration:** Complete (FlutterFlow → production Flutter)

---

## Required Reading (Every Session)

Read these documents IN ORDER at the start of every session:

1. **CLAUDE.md** (this file) — Session rules, critical decisions, quick reference
2. **ARCHITECTURE.md** — How the app is built (state management, patterns, pitfalls)
3. **DESIGN_SYSTEM_flutter.md** — Design tokens (colors, spacing, typography)
4. **_reference/BUILDSHIP_API_REFERENCE.md** — API contracts for all 12 endpoints
5. **_reference/PROVIDERS_REFERENCE.md** — Riverpod provider catalog

**Time:** 60 minutes to productive (10 + 45 + 15 + 5 + 5)

---

## Task-Based Navigation Guide

**Working on a specific task?** Use this guide to jump directly to relevant sections instead of reading all 3,275 lines of documentation.

Each scenario below provides:
- ✅ **Targeted reading list** (4-6 critical sections, 10-30 minutes)
- ⚠️ **Critical warnings** (common pitfalls to avoid)
- 📁 **Reference files** (actual codebase examples to follow)

**Expected impact:** Reduce time-to-first-productive-code from 60 minutes to 10-30 minutes for common tasks.

---

### 1. Adding or Modifying a Page
**Estimated reading time:** 20 minutes

**Read these sections:**
1. **ARCHITECTURE.md** → Widget Patterns → Self-Contained ConsumerWidget (lines 265-310)
2. **ARCHITECTURE.md** → Widget Patterns → Page Wrapper Pattern (lines 311-376)
3. **ARCHITECTURE.md** → State Management → When to Use What (lines 123-131)
4. **ARCHITECTURE.md** → State Management → Page-Local State (lines 216-259)
5. **DESIGN_SYSTEM_flutter.md** → Quick Start (lines 16-36)
6. **ARCHITECTURE.md** → Common Pitfalls #8, #11 (lines 937-949, 982-1012)

**Critical warnings:**
- ⚠️ Page-local UI state (loading flags, TextControllers, ScrollControllers) → local State variables, NOT providers
- ⚠️ Never pass language/translations/dimensions as props to widgets (self-contained pattern)
- ⚠️ Use `context.mounted` after async operations to prevent ref access after unmount
- ⚠️ Save notifier with `ref.read()` BEFORE any `await` in pre-loading patterns

**Reference files:**
- `journey_mate/lib/pages/search_page.dart` — Full page pattern with local state + provider reads
- `journey_mate/lib/pages/contact_us_page.dart` — Page wrapper pattern (analytics + navigation)
- `_reference/PROVIDERS_REFERENCE.md` — Which providers to read from pages

---

### 2. Creating a New Shared Widget
**Estimated reading time:** 15 minutes

**Read these sections:**
1. **ARCHITECTURE.md** → Widget Patterns → Self-Contained ConsumerWidget (lines 265-310)
2. **ARCHITECTURE.md** → Widget Patterns → ConsumerWidget vs ConsumerStatefulWidget (lines 377-410)
3. **DESIGN_SYSTEM_flutter.md** → Colors (lines 39-90)
4. **DESIGN_SYSTEM_flutter.md** → Spacing (lines 92-120)
5. **DESIGN_SYSTEM_flutter.md** → Typography (lines 122-180)
6. **ARCHITECTURE.md** → Common Pitfall #8 (lines 937-949)

**Critical warnings:**
- ⚠️ Widgets read providers/context internally — NO infrastructure props (language, translations, dimensions)
- ⚠️ All colors from `AppColors` (no raw hex: `Color(0xFF...)`)
- ⚠️ All spacing from `AppSpacing` (no magic numbers: `16.0`)
- ⚠️ All typography from `AppTypography` (no inline `TextStyle(...)`)

**Reference files:**
- `journey_mate/lib/widgets/shared/contact_us_form_widget.dart` — Self-contained form widget
- `journey_mate/lib/widgets/shared/filter_overlay_widget.dart` — Complex widget with local state

---

### 3. Integrating with BuildShip API
**Estimated reading time:** 15 minutes

**Read these sections:**
1. **ARCHITECTURE.md** → API Service Pattern (lines 461-517)
2. **_reference/BUILDSHIP_API_REFERENCE.md** → Endpoint you need (e.g., lines 9-80 for SEARCH)
3. **ARCHITECTURE.md** → State Management → AsyncNotifierProvider (lines 176-214)
4. **ARCHITECTURE.md** → Pre-Loading Architecture (lines 520-597)
5. **ARCHITECTURE.md** → Common Pitfall #11 (lines 982-1012)

**Critical warnings:**
- ⚠️ All backend calls through `ApiService.instance` singleton — NO direct Supabase SDK
- ⚠️ Check `response.succeeded` and `response.jsonBody != null` before accessing data
- ⚠️ Save notifier with `ref.read()` BEFORE any `await` to prevent ref-after-unmount bugs
- ⚠️ Use `ApiCallResponse` wrapper for all responses

**Reference files:**
- `journey_mate/lib/services/api_service.dart` — All 13 BuildShip endpoints
- `journey_mate/lib/providers/search_providers.dart` — API integration example
- `_reference/BUILDSHIP_API_REFERENCE.md` — Complete API contracts

---

### 4. Adding or Updating Translations
**Estimated reading time:** 10 minutes

**Read these sections:**
1. **ARCHITECTURE.md** → Translation System (lines 599-659)
2. **CLAUDE.md** → Code Patterns → Translations (lines 67-70)
3. **_reference/BUILDSHIP_API_REFERENCE.md** → GET /languageText (search for "languageText")
4. **ARCHITECTURE.md** → Philosophy → Single Source of Truth for Translations (lines 42-48)

**Critical warnings:**
- ⚠️ All text via `td(ref, 'key')` function — NO hardcoded strings
- ⚠️ 100% dynamic from Supabase `ui_translations` table
- ⚠️ If key missing, `td()` returns key name and logs warning
- ⚠️ Language changes trigger full app rebuild via `localeProvider`

**Reference files:**
- `journey_mate/lib/services/translation_service.dart` — `td()` function implementation
- `journey_mate/lib/providers/app_providers.dart` — `translationsCacheProvider`

---

### 5. Modifying State Management (Providers)
**Estimated reading time:** 25 minutes

**Read these sections:**
1. **ARCHITECTURE.md** → State Management → When to Use What (lines 123-131)
2. **ARCHITECTURE.md** → State Management → Provider Catalog (lines 133-146)
3. **ARCHITECTURE.md** → State Management → Riverpod 3.x Patterns (lines 148-259)
4. **_reference/PROVIDERS_REFERENCE.md** → Full provider details (entire file, 726 lines)
5. **ARCHITECTURE.md** → Provider Initialization Order (lines 1038-1062)
6. **ARCHITECTURE.md** → Common Pitfall #11 (lines 982-1012)

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

### 6. Implementing a Form
**Estimated reading time:** 20 minutes

**Read these sections:**
1. **ARCHITECTURE.md** → Widget Patterns → Self-Contained ConsumerWidget (lines 265-310)
2. **ARCHITECTURE.md** → State Management → Page-Local State (lines 216-259)
3. **DESIGN_SYSTEM_flutter.md** → Input Decorations (search for "AppInputDecorations")
4. **DESIGN_SYSTEM_flutter.md** → Button Styles (search for "AppButtonStyles")
5. **ARCHITECTURE.md** → API Service Pattern (lines 461-517)
6. **ARCHITECTURE.md** → Common Pitfall #8 (lines 937-949)
7. **ARCHITECTURE.md** → Common Pitfall #11 Variation B (lines 998-1080)

**Critical warnings:**
- ⚠️ Form state (TextEditingController, validation) → local State variables, NOT providers
- ⚠️ Widget reads language/translations internally — NO props
- ⚠️ Use `AppInputDecorations.standard()` for consistent input styling
- ⚠️ Dispose controllers in `dispose()` method
- ⚠️ Use `context.mounted` after async submit operations
- ⚠️ If syncing state in `dispose()`, save notifier in `initState()` (Pitfall #11 Variation B)

**Reference files:**
- `journey_mate/lib/widgets/shared/contact_us_form_widget.dart` — Complete form pattern
- `journey_mate/lib/widgets/shared/feedback_form_widget.dart` — Form with dropdown

---

### 7. Changing Design Tokens
**Estimated reading time:** 15 minutes

**Read these sections:**
1. **DESIGN_SYSTEM_flutter.md** → Colors (lines 39-90)
2. **DESIGN_SYSTEM_flutter.md** → Spacing (lines 92-120)
3. **DESIGN_SYSTEM_flutter.md** → Typography (lines 122-180)
4. **DESIGN_SYSTEM_flutter.md** → Border Radius (search for "AppRadius")
5. **ARCHITECTURE.md** → Code Quality Standards → Design Token Adherence (lines 819-826)
6. **CLAUDE.md** → Code Review Checklist (lines 84-104)

**Critical warnings:**
- ⚠️ Orange (`#e8751a`) ONLY for CTAs/interactive elements (never match status)
- ⚠️ Green (`#1a9456`) ONLY for match confirmation (never CTAs)
- ⚠️ ALL colors must come from `AppColors` — no raw hex strings
- ⚠️ ALL spacing must come from `AppSpacing` — no magic numbers
- ⚠️ Changes propagate automatically across entire app (30 color constants, 8 spacing constants)

**Reference files:**
- `journey_mate/lib/theme/app_colors.dart` — All 30 color constants
- `journey_mate/lib/theme/app_spacing.dart` — All 8 spacing constants
- `journey_mate/lib/theme/app_typography.dart` — All 14 text styles
- `DESIGN_SYSTEM_flutter.md` — Complete design system documentation (683 lines)

---

### 8. Fixing State Persistence & Widget Lifecycle
**Estimated reading time:** 20 minutes

**Read these sections:**
1. **ARCHITECTURE.md** → Common Pitfall #11 (lines 982-1012)
2. **ARCHITECTURE.md** → Pre-Loading Architecture (lines 520-597)
3. **ARCHITECTURE.md** → State Management → When to Use What (lines 123-131)
4. **ARCHITECTURE.md** → Common Pitfall #5 (lines 890-904)
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

### 9. Implementing Search/Filter Features
**Estimated reading time:** 30 minutes

**Read these sections:**
1. **_reference/BUILDSHIP_API_REFERENCE.md** → SEARCH endpoint (lines 9-80)
2. **ARCHITECTURE.md** → API Service Pattern (lines 461-517)
3. **_reference/PROVIDERS_REFERENCE.md** → searchStateProvider (search for "searchStateProvider")
4. **_reference/PROVIDERS_REFERENCE.md** → filterProvider (search for "filterProvider")
5. **ARCHITECTURE.md** → Widget Patterns → Bottom Sheet Pattern (lines 412-458)
6. **ARCHITECTURE.md** → Pre-Loading Architecture (lines 520-597)
7. **ARCHITECTURE.md** → Common Pitfall #11 (lines 998-1080)

**Critical warnings:**
- ⚠️ CityID is always 17 (Copenhagen) — use `AppConstants.kDefaultCityId`
- ⚠️ Filter hierarchy loaded via AsyncNotifierProvider from BuildShip
- ⚠️ Search results pre-loaded on Welcome/Settings pages for instant Search page
- ⚠️ Filter panel is bottom sheet (NOT inline overlay) — tab selection is local state
- ⚠️ Match categorization (full/partial/other) handled by BuildShip, not Flutter
- ⚠️ Filter overlays that sync state on close: save notifier in `initState()`, use in `dispose()` (Pitfall #11 Variation B)

**Reference files:**
- `journey_mate/lib/pages/search_page.dart` — Complete search implementation
- `journey_mate/lib/widgets/shared/filter_overlay_widget.dart` — Filter bottom sheet
- `journey_mate/lib/providers/search_providers.dart` — Search state management
- `journey_mate/lib/providers/filter_providers.dart` — Filter hierarchy state

---

### 10. Working with Business Profile & Menu Data
**Estimated reading time:** 25 minutes

**Read these sections:**
1. **_reference/BUILDSHIP_API_REFERENCE.md** → GET /businessProfile (search for "businessProfile")
2. **_reference/BUILDSHIP_API_REFERENCE.md** → GET /businessMenu (search for "businessMenu")
3. **_reference/PROVIDERS_REFERENCE.md** → businessProvider (search for "businessProvider")
4. **ARCHITECTURE.md** → API Service Pattern (lines 461-517)
5. **ARCHITECTURE.md** → State Management → NotifierProvider (lines 149-174)

**Critical warnings:**
- ⚠️ Business data fetched per page load (not persistent across navigation)
- ⚠️ Menu items have dietary filters (vegan, vegetarian, gluten-free, lactose-free)
- ⚠️ Price range is MinMax object with currency symbol
- ⚠️ Opening hours are pre-computed `open_windows` arrays from BuildShip
- ⚠️ Image URLs come from BuildShip (Supabase Storage paths)

**Reference files:**
- `journey_mate/lib/pages/business_profile_page.dart` — Business data display
- `journey_mate/lib/pages/menu_full_page.dart` — Menu with dietary filtering
- `journey_mate/lib/providers/business_providers.dart` — Business state management

---

### 11. Analytics & Engagement Tracking
**Estimated reading time:** 15 minutes

**Read these sections:**
1. **ARCHITECTURE.md** → Analytics Architecture (lines 729-803)
2. **ARCHITECTURE.md** → Philosophy → Fire-and-Forget Analytics (lines 50-56)
3. **ARCHITECTURE.md** → Common Pitfall #9, #10 (lines 951-980)
4. **_reference/BUILDSHIP_API_REFERENCE.md** → POST /analytics (search for "analytics")

**Critical warnings:**
- ⚠️ NEVER await analytics calls — fire-and-forget with `.catchError()`
- ⚠️ ActivityScope handles engagement automatically — NEVER call `markUserEngaged()` manually
- ⚠️ Analytics service initializes in `main.dart` before provider container
- ⚠️ User experience is NEVER blocked by analytics (data loss acceptable, UX responsiveness is not)
- ⚠️ 36 event types tracked to Supabase via BuildShip

**Reference files:**
- `journey_mate/lib/services/analytics_service.dart` — AnalyticsService + EngagementTracker (469 lines)
- `journey_mate/lib/widgets/activity_scope.dart` — Automatic engagement detection
- `journey_mate/lib/pages/search_page.dart` — Page view tracking example (lines ~240-260)

---

### 12. Localization & Multi-Language Support
**Estimated reading time:** 15 minutes

**Read these sections:**
1. **ARCHITECTURE.md** → Translation System (lines 599-659)
2. **_reference/PROVIDERS_REFERENCE.md** → localeProvider (search for "localeProvider")
3. **_reference/PROVIDERS_REFERENCE.md** → localizationProvider (search for "localizationProvider")
4. **_reference/BUILDSHIP_API_REFERENCE.md** → GET /languageText (search for "languageText")
5. **ARCHITECTURE.md** → Key Architectural Decisions → Translation: 100% Supabase (lines 1082-1086)

**Critical warnings:**
- ⚠️ All text via `td(ref, 'key')` function — NO hardcoded strings
- ⚠️ 7 languages supported: en, da, de, fr, it, no, sv (355 app keys + 142 legacy keys)
- ⚠️ Language change triggers full app rebuild via `localeProvider` + MaterialApp
- ⚠️ Currency preference stored separately in `localizationProvider`
- ⚠️ Exchange rates fetched from external API, cached in provider state

**Reference files:**
- `journey_mate/lib/services/translation_service.dart` — `td()` function (40 lines)
- `journey_mate/lib/providers/settings_providers.dart` — locale + localization providers
- `journey_mate/lib/pages/localization_settings_page.dart` — Language/currency selector

---

### Navigation Guide Changelog

**2026-02-24:** Initial 12-scenario guide created with targeted reading lists
**2026-02-24:** Updated Scenarios 6 & 9 to reference expanded Common Pitfall #11 (dispose pattern)

---

## Working Directory

`C:\Users\Rikke\Documents\JourneyMate-Organized\`

All work happens here. Production code is in `journey_mate/` subdirectory.

**GitHub repo:** `https://github.com/Andreasams/JourneyMate_manual`

---

## Tech Stack

- **Flutter 3.x** (currently 3.41.x)
- **Riverpod 3.x** (`flutter_riverpod: ^3.2.1`) — state management, hand-written Notifiers (NO codegen)
- **go_router 17.x** (`go_router: ^17.1.0`) — routing (11 routes)
- **BuildShip REST API** — all backend including auth (no direct Supabase SDK)
- **SharedPreferences** — user language, currency, accessibility preferences
- **geolocator** — location permission and coordinates
- **http** — raw HTTP client for BuildShip API calls

---

## Code Patterns (Non-Negotiable)

### Design Tokens
- **All colors** from `AppColors` (NO raw hex: `Color(0xFF...)`)
- **All spacing** from `AppSpacing` (NO magic numbers: `16.0`)
- **All typography** from `AppTypography` (NO inline `TextStyle(...)`)
- **All radii** from `AppRadius` (NO `BorderRadius.circular(16)`)

### State Management
- **Global/session state:** `NotifierProvider` or `AsyncNotifierProvider`
- **Page-local UI state:** Local `State` variables in `ConsumerStatefulWidget`
- **NO FFAppState, NO Provider, NO StateNotifier** (deprecated Riverpod 2.x pattern)
- **See ARCHITECTURE.md** for "when to use what" decision matrix

### Translations
- **All text** via `td(ref, 'key')` function (NO hardcoded strings)
- **100% dynamic** from Supabase `ui_translations` table via BuildShip
- **355 app keys** + 142 legacy keys = 497 total

### Analytics
- **Fire-and-forget** (NEVER await analytics calls)
- **ActivityScope** handles engagement tracking automatically
- **NEVER call** `markUserEngaged()` manually (pattern removed from FlutterFlow)

### Widget Patterns
- **Self-contained widgets:** Read providers/context internally (NO infrastructure props)
- **ConsumerWidget:** Pure display (no local state)
- **ConsumerStatefulWidget:** Page/widget with local state + provider reads

---

## Code Review Checklist

Before every commit, verify:

**Design Token Adherence:**
- [ ] All colors from `AppColors` (no raw hex strings)
- [ ] All spacing from `AppSpacing` (no magic pixel numbers)
- [ ] All text styles from `AppTypography` (no inline TextStyle)
- [ ] Orange (`#e8751a`) only for CTAs/interactive elements (never match status)
- [ ] Green (`#1a9456`) only for match confirmation (never CTAs)

**State Correctness:**
- [ ] No FFAppState references
- [ ] All reads from correct Riverpod provider per PROVIDERS_REFERENCE.md
- [ ] Page-local state in local widget state (not a provider)
- [ ] No hardcoded strings (all text uses `td(ref, key)`)

**Code Quality:**
- [ ] `flutter analyze` returns `No issues found!` (0 warnings, 0 errors)
- [ ] No unaddressed TODOs

---

## Git Workflow

Git is initialized in `JourneyMate-Organized/`. Commit after every completed task.

**Commit message format:** `feat/fix/chore/docs: short description`

Examples:
- `feat: add dietary filter to menu page`
- `fix: resolve grey screen navigation issue`
- `chore: update dependencies`
- `docs: update ARCHITECTURE.md with new pattern`

**Commit after:**
- Completing a task or milestone
- Before trying something risky
- At end of each session

---

## Flutter Code Conventions

- **Pages:** `ConsumerStatefulWidget` with local state
- **Pure widgets:** `ConsumerWidget` for display-only
- **Bottom sheets:** `showModalBottomSheet` with `DraggableScrollableSheet`
- **API calls:** All through `ApiService.instance` singleton
- **Translation:** `td(ref, key)` for all user-facing text
- **Analytics:** Fire-and-forget with `.catchError()`, never await
- **Engagement:** Automatic via ActivityScope (never call `markUserEngaged()`)

**Flutter 3.x APIs (not deprecated 2.x):**
- `WidgetStateProperty` (not MaterialStateProperty)
- `.withValues(alpha:)` (not .withOpacity())
- `context.mounted` (not mounted after async)

---

## Critical Product Decisions

These decisions have been confirmed and must not be re-debated:

1. **CityID is always 17 (Copenhagen)** — Use `AppConstants.kDefaultCityId` constant. No city-switching UI in v1. Pass directly to API calls.

2. **No favorites feature** — `restaurantIsFavorited` is future work. Don't build favorite button, state, or UI.

3. **Filter panel is bottom sheet** — Use `showModalBottomSheet`, not FlutterFlow's 3-column inline overlay. Tab selection is local state in sheet widget.

4. **Translation: 100% Supabase** — Ultimate goal is zero hardcoded translations. All text from `ui_translations` table. Single source of truth for all 7 languages.

5. **Portrait-only iPhone, all orientations iPad** — iPhone locked to portrait for optimal restaurant discovery UX. iPad supports all orientations for table/counter browsing.

6. **ActivityScope handles engagement automatically** — FlutterFlow uses manual `markUserEngaged()` calls in 44+ files. New app uses ActivityScope widget wrapping entire app. Migration rule: REMOVE all `markUserEngaged()` calls, DO NOT REPLACE.

7. **Self-contained widgets** — Widgets read language/translations/dimensions from providers/context internally. Props only for business logic data. Discovered in Phase 7, now standard pattern.

8. **FlutterFlow code is historical reference** — FlutterFlow export was removed from Git repo (2026-02-22). Local copy exists for reference only. Production code is 100% in `journey_mate/`.

9. **Welcome page analytics pageName is `'welcomePage'`** (camelCase) — Not `'homepage'` or `'welcomepage'`. Requires matching BuildShip handler update.

10. **ContactUs Subject field is free-text** — Single `TextFormField`, non-empty validation. No dropdown. FlutterFlow is ground truth, not JSX design.

11. **FeedbackForm topic sent as localized label string** — Sends `"Bug"` or `"Fejl"` directly to Supabase `text` column. Foreign-language values are fine. Don't map to English key.

12. **Filter column widths exact: 36%/33%/31%** — Required for visual design. Never approximate.

---

## What NOT to Do

- ❌ Do not add direct Supabase SDK calls (all via BuildShip API)
- ❌ Do not use FFAppState or Provider (only Riverpod 3.x)
- ❌ Do not add raw hex colors or magic numbers (use design tokens)
- ❌ Do not refactor complex algorithms from FlutterFlow unless explicitly asked
- ❌ Do not add features beyond requirements
- ❌ Do not await analytics calls (fire-and-forget only)
- ❌ Do not call `markUserEngaged()` manually (ActivityScope handles it)
- ❌ Do not pass infrastructure props to self-contained widgets (language, translations, dimensions)

---

## When User Gives Feedback — Update Documents Immediately

**Standing procedure:** When user provides corrections, clarifications, or new context:

1. **Identify affected documents** (CLAUDE.md, ARCHITECTURE.md, BUILDSHIP_API_REFERENCE.md, PROVIDERS_REFERENCE.md, etc.)
2. **Update immediately** — before continuing other work
3. **Commit updates** with message `docs: update [file] based on user feedback`
4. **Then continue** with task at hand

Do not leave feedback in code comments or conversation only. It must land in reference documents.

---

## Help & Feedback

- **Help with Claude Code:** Use `/help` command
- **Report issues:** https://github.com/anthropics/claude-code/issues
- **JourneyMate repo:** https://github.com/Andreasams/JourneyMate_manual

---

**Last Updated:** February 2026
**For deep dives:** See ARCHITECTURE.md (how app is built), DESIGN_SYSTEM_flutter.md (design tokens), PROVIDERS_REFERENCE.md (state catalog), BUILDSHIP_API_REFERENCE.md (API contracts)
