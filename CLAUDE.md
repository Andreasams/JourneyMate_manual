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
