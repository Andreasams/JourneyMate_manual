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

## Code Development Process

**Follow systematic workflow when writing code:**

See **CODE_DEVELOPMENT_WORKFLOW.md** for complete development process including:
- **Pre-development:** Use NAVIGATION_GUIDE.md to find which docs to read for your task
- **Development:** Follow patterns from ARCHITECTURE.md while writing code
- **Pre-commit validation:** Systematic review against checklist and pitfalls

**Quick reference:**
1. Before coding → NAVIGATION_GUIDE.md (find your scenario)
2. During coding → Follow ARCHITECTURE.md patterns
3. Before commit → ARCHITECTURE.md → Code Review Checklist (lines 1816-1910)
4. Validate against → ARCHITECTURE.md → Common Pitfalls (lines 1913-3178)

---

## Architectural Patterns

**For all code patterns, see ARCHITECTURE.md:**
- **Design tokens, state management, translations, analytics:** See ARCHITECTURE.md → Philosophy (lines 39-81)
- **Widget patterns:** See ARCHITECTURE.md → Widget Patterns (lines 354-870)
- **Pre-commit checklist:** See ARCHITECTURE.md → Code Review Checklist (lines 1816-1910)

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

15. **Business Profile v2 is the active route** — Router serves `BusinessProfilePageV2` (not v1). The v2 page reads from a flat `businessInfo` API response, merges top-level `filters` into the business map, and computes `status_open`/`closing_time`/`price_range` client-side from `openWindows` data. Analytics events use v2 naming: `business_profile_viewed`, `share_button_clicked`, `menu_session_started`, `menu_session_ended`. See `_reference/PROFILE_V2_GAP_ANALYSIS.md` for full API structure.

16. **Google Maps API key via xcconfig build-time injection** — API key is read from `Info.plist` at runtime, populated from `Secrets.xcconfig` at build time. Codemagic generates `Secrets.xcconfig` from encrypted environment variables (never committed to git). `AppDelegate.swift` reads key with `Bundle.main.infoDictionary` and calls `GMSServices.provideAPIKey()`. Fresh clones: xcconfig `#include` produces a warning (not error) if file missing — safe for local dev without key. Two pages use Google Maps: business information page (`/business/:id/information`) and search map view (list/map toggle on search page). Commits `172a66e`, `e35de89`, `c545543`.

---

## What NOT to Do

- ❌ No direct Supabase SDK | No FFAppState/Provider | No raw hex colors/magic numbers
- ❌ No await on analytics | No manual `markUserEngaged()` calls
- ❌ No infrastructure props to self-contained widgets | No features beyond requirements

---

## Documentation Workflow

**CRITICAL:** This is the MAIN worktree. Documentation is handled by the DOCS worktree.

### What Main Worktree Does:
- ✅ Write inline code documentation (comments, docstrings)
- ✅ Include "Discovered:" and "Decision:" sections in commit messages
- ✅ Flag docs needing updates in "See also:" section of commits

### What Main Worktree NEVER Does:
- ❌ NEVER modify .md files (CLAUDE.md, ARCHITECTURE.md, etc.)
- ❌ NEVER update reference documentation directly
- ❌ NEVER create new documentation files

**Rationale:** Single source of truth for documentation. Docs worktree maintains ALL .md files to prevent merge conflicts and ensure consistency.

**When you discover something worth documenting:**
1. Add inline code comment explaining the pattern/pitfall
2. Include "Discovered:" section in commit message
3. Flag in "See also:" section which docs need review
4. Docs worktree will handle the formal documentation update

**Example commit message:**
```
feat: implement filter greying for unavailable options

Implementation details here...

Discovered:
- Parent neighbourhood state must be checked BEFORE hasSubitems
- Widget updates must restore routed IDs to prevent orphaned state

See also:
- Needs update: ARCHITECTURE.md (add pitfall about filter state management)
- Needs update: NAVIGATION_GUIDE.md (update scenario 9 with new warning)
```

The docs worktree will then review your commit and update the formal documentation.

---

## When User Gives Feedback

**Update documents immediately:** Identify affected files (CLAUDE.md, ARCHITECTURE.md, etc.), update before continuing, commit with `docs: update [file] based on user feedback`. Feedback must land in reference documents, not just code comments.

---

## Help & Feedback

**Claude Code:** `/help` | **Issues:** https://github.com/anthropics/claude-code/issues | **Repo:** https://github.com/Andreasams/JourneyMate_manual

---

**Last Updated:** February 2026
**For deep dives:** See ARCHITECTURE.md (how app is built), DESIGN_SYSTEM_flutter.md (design tokens), PROVIDERS_REFERENCE.md (state catalog), BUILDSHIP_API_REFERENCE.md (API contracts), DIRECTORY_STRUCTURE.md (file organization)
