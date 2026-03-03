# JourneyMate — Claude Code Instructions

**Read this file before touching anything. It defines how every session must work.**

---

## Project Status

**JourneyMate** restaurant discovery app | **Phase 8** (Maintenance & Debugging) | **✅ Live on TestFlight** (2026-02-22)
**Tech:** Flutter 3.41.x, Riverpod 3.x, BuildShip REST API | **Migration:** Complete (FlutterFlow → production)

---

## Required Reading (Every Session)

Read these documents IN ORDER at the start of every session:

1. **CLAUDE.md** (this file) — Session rules, critical decisions, quick reference
2. **ARCHITECTURE.md** — How the app is built (state management, patterns, pitfalls)
3. **DESIGN_SYSTEM_flutter.md** — Design tokens (colors, spacing, typography)
4. **_reference/BUILDSHIP_API_REFERENCE.md** — API contracts for all 12 endpoints
5. **_reference/PROVIDERS_REFERENCE.md** — Riverpod provider catalog

**Time:** 60 minutes to productive (10 + 45 + 15 + 5 + 5) | **Task-specific:** See [NAVIGATION_GUIDE.md](NAVIGATION_GUIDE.md) for 10-30 minute targeted reading

---

## Task-Based Navigation

**Working on a specific task?** See **[NAVIGATION_GUIDE.md](NAVIGATION_GUIDE.md)** for 12 scenarios with targeted reading lists (10-30 minutes each).

---

## Cost & Context Optimization

**Built-in:** Claude Code uses automatic prompt caching (~90% savings on repeated content, no configuration needed).

**Commands:** `/cost` (token usage) | `/context` (what's in context) | `/clear` (fresh start)
**Best practices:** Commit before heavy work, use `/clear` when switching between unrelated features

---

## Working Directory

`C:\Users\Rikke\Documents\JourneyMate\Main\` — Production code in `journey_mate/`
**GitHub repo:** `https://github.com/Andreasams/JourneyMate_manual`

---

## Tech Stack

- **Flutter 3.x** (3.41.x) | **Riverpod 3.x** (hand-written Notifiers, NO codegen) | **go_router 17.x** (11 routes)
- **BuildShip REST API** — all backend including auth (NO direct Supabase SDK)
- **SharedPreferences** — user prefs | **geolocator** — location | **http** — API client

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
- **Bottom sheets:** `showModalBottomSheet` with `DraggableScrollableSheet`

### Flutter 3.x APIs
- `WidgetStateProperty` (not MaterialStateProperty) | `.withValues(alpha:)` (not .withOpacity()) | `context.mounted` (not mounted after async)

### Linting Rules
- **Parameter names:** Never use double underscores `__` (triggers `unnecessary_underscores` lint)
- **Ignored parameters:** Use single underscore `_` or simple names like `e`, `s`, `error`, `stack`
- **Example:** `error: (e, s) => true` NOT `error: (_, __) => true`

---

## Code Review Checklist

Before every commit:
- [ ] Design tokens: All colors/spacing/typography from `App*` classes (no raw hex/numbers)
- [ ] Color semantics: Orange for CTAs only, green for match confirmation only
- [ ] State: No FFAppState, page-local state in widgets not providers, all text via `td(ref, key)`
- [ ] Shared sources: Check theme (app_theme.dart) and shared widgets (lib/widgets/shared/) before modifying individual pages
- [ ] Quality: `flutter analyze` clean, no unaddressed TODOs

---

## Git Workflow

**Format:** `feat/fix/chore/docs: short description`
**Commit after:** Completing tasks, before risky changes, end of session

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

13. **Flutter localization delegates required** — MaterialApp must include `supportedLocales` and `localizationsDelegates` for `Localizations.localeOf(context)` to work. Without these, currency filtering breaks (always shows English currencies). Fixed 2026-02-24.

14. **Distance units: Imperial ONLY for English** — Distance unit preference (Imperial/Metric) is **only available when language is English**. Non-English users **always** see metric (km/meters), ignoring any stored preference. English users default to Imperial (miles/feet) for backward compatibility. Rationale: European languages expect metric exclusively; preference would confuse non-English users. Implementation: `DistanceUnitSelectorButton` visible only when `currentLanguage == 'en'`.

---

## What NOT to Do

- ❌ No direct Supabase SDK | No FFAppState/Provider | No raw hex colors/magic numbers
- ❌ No await on analytics | No manual `markUserEngaged()` calls
- ❌ No infrastructure props to self-contained widgets | No features beyond requirements

---

## When User Gives Feedback

**Update documents immediately:** Identify affected files (CLAUDE.md, ARCHITECTURE.md, etc.), update before continuing, commit with `docs: update [file] based on user feedback`. Feedback must land in reference documents, not just code comments.

---

## Help & Feedback

**Claude Code:** `/help` | **Issues:** https://github.com/anthropics/claude-code/issues | **Repo:** https://github.com/Andreasams/JourneyMate_manual

---

**Last Updated:** February 2026
**For deep dives:** See ARCHITECTURE.md (how app is built), DESIGN_SYSTEM_flutter.md (design tokens), PROVIDERS_REFERENCE.md (state catalog), BUILDSHIP_API_REFERENCE.md (API contracts), DIRECTORY_STRUCTURE.md (file organization)
