# JourneyMate — Claude Code Instructions

**Read this file before touching anything. It defines how every session must work.**

---

## ⚠️ Worktree Identity: Documentation Maintenance

**THIS IS A DOCS WORKTREE** — You are in a dedicated documentation maintenance environment.

**Purpose:**
- Review commits from main branch
- Analyze code changes for documentation impact
- Update project documentation (CLAUDE.md, ARCHITECTURE.md, DESIGN_SYSTEM_flutter.md, etc.)
- Create documentation PRs separate from code changes

**What NOT to do here:**
- ❌ Code development (no implementing features)
- ❌ Running the app (no `flutter run`, no TestFlight testing)
- ❌ Installing dependencies (no `flutter pub get` unless verifying doc accuracy)
- ❌ Making code commits (all commits here are `docs:` prefix only)

**Location:**
- **Docs worktree:** `C:\Users\Rikke\Documents\JourneyMate\Docs` (branch: `docs`)
- **Main worktree:** `C:\Users\Rikke\Documents\JourneyMate\Main` (branch: `main`)

**Primary Skill:** `/documentation-maintenance` (adapted for commit review workflow)

---

## Project Status

**JourneyMate** restaurant discovery app | **Phase 8** (Maintenance & Debugging) | **✅ Live on TestFlight** (2026-02-22)
**Tech:** Flutter 3.41.x, Riverpod 3.x, BuildShip REST API | **Migration:** Complete (FlutterFlow → production)

---

## Required Reading (Every Session)

**For documentation maintenance tasks:**

1. **CLAUDE.md** (this file) — Worktree identity, documentation workflow, project reference
2. **ARCHITECTURE.md** — Current architectural patterns (use when analyzing commits)
3. **.claude/skills/documentation-maintenance/SKILL.md** — How to use the documentation skill
4. **NAVIGATION_GUIDE.md** — Which task scenarios are affected by documentation changes

**Optional (task-specific):**
- **DESIGN_SYSTEM_flutter.md** — When documenting design token changes
- **_reference/BUILDSHIP_API_REFERENCE.md** — When documenting API changes
- **_reference/PROVIDERS_REFERENCE.md** — When documenting state management changes

**Time:** 20-30 minutes for documentation tasks (vs 60 minutes for code development)

---

## Task-Based Navigation

**For documentation maintenance tasks:**
- **Documenting a new pitfall:** See `.claude/skills/documentation-maintenance/SKILL.md`
- **Expanding existing pattern:** Follow "Documentation Maintenance Workflow" section below
- **Quarterly documentation review:** Use skill with "Quarterly review: [date range]" prompt
- **Analyzing commit impact:** Use workflow steps 1-3 below

**For understanding codebase patterns** (when analyzing commits):
See **[NAVIGATION_GUIDE.md](NAVIGATION_GUIDE.md)** for 12 scenarios with targeted reading lists.

---

## Cost & Context Optimization

**Built-in:** Claude Code uses automatic prompt caching (~90% savings on repeated content, no configuration needed).

**Commands:** `/cost` (token usage) | `/context` (what's in context) | `/clear` (fresh start)
**Best practices:** Commit before heavy work, use `/clear` when switching between unrelated features

---

## Working Directory

`C:\Users\Rikke\Documents\JourneyMate-Organized\` — Production code in `journey_mate/`
**GitHub repo:** `https://github.com/Andreasams/JourneyMate_manual`

---

## Documentation Maintenance Workflow

This worktree exists to maintain documentation separately from code development.

### Communication Protocol: Main Worktree → Docs Worktree

**The commit message is your documentation handoff.** Main worktree commits include:
- **Discovered:** Patterns and pitfalls found during implementation
- **Decision:** Architectural choices made
- **See also:** Flags for docs that might need updates

**See [COMMIT_MESSAGE_TEMPLATE.md](COMMIT_MESSAGE_TEMPLATE.md) for complete format.**

### Division of Responsibility

| Document Type | Main Worktree | Docs Worktree |
|---------------|---------------|---------------|
| **Reference docs** (API contracts, provider lists) | ✅ Updates directly | ✅ Reviews for accuracy |
| **Strategic docs** (CLAUDE.md, ARCHITECTURE.md) | ❌ Never touches | ✅ Maintains exclusively |
| **Design tokens** (DESIGN_SYSTEM_flutter.md) | ✅ Adds new tokens | ✅ Documents patterns/usage |
| **Commit messages** | ✅ Writes with "Discovered:" sections | ✅ Reads to extract insights |

**Main worktree's job:** Code + commit context + update reference docs
**Docs worktree's job:** Extract patterns → Update strategic docs → Maintain consistency

### 1. Sync with Main Branch

Before starting documentation work:
```bash
cd "C:\Users\Rikke\Documents\JourneyMate\Docs"
git fetch origin main
git log docs..origin/main --oneline  # See new commits since last sync
```

**Purpose:** Identify commits from main that need documentation review.

### 2. Review Commits for Documentation Impact

For each commit identified:
```bash
# View commit details
git show <commit-hash> --stat

# See full diff
git show <commit-hash>

# Analyze changed files
git diff <commit-hash>~1 <commit-hash> -- path/to/file.dart
```

**Look for:**
- New patterns or architectural changes
- Bug fixes that reveal common pitfalls
- Breaking changes to API contracts
- Design system updates (color semantics, spacing rules)
- Product decisions (feature removals, behavior changes)

### 3. Use documentation-maintenance Skill

Invoke the skill with commit references:
```bash
/documentation-maintenance "Review commit <hash>: [commit message]"
```

**Example:**
```bash
/documentation-maintenance "Review commit 5b0ce37: feat: implement filter greying for unavailable options"
```

**The skill will:**
1. Search existing docs for related content
2. Recommend where to document the change
3. Draft documentation updates
4. Identify affected navigation guide scenarios
5. Prepare commit message

**Key: Read the Commit Message**
Main worktree commits follow [COMMIT_MESSAGE_TEMPLATE.md](COMMIT_MESSAGE_TEMPLATE.md) format:
- **Discovered:** section → Becomes Common Pitfalls in ARCHITECTURE.md
- **Decision:** section → Becomes architectural guidance
- **See also:** section → Tells you what docs to review

**Adapted for this worktree:**
- You're documenting others' commits, not your own work
- Include commit hash from main branch in all documentation
- Reference main worktree file paths when needed
- Look for "Discovered:" and "Decision:" sections in commit messages

### 4. Update Documentation Files

Based on skill recommendations:
1. Review proposed changes
2. Edit affected .md files (CLAUDE.md, ARCHITECTURE.md, etc.)
3. Verify cross-references are correct
4. Update NAVIGATION_GUIDE.md if section line numbers shifted

### 5. Create Documentation PR

```bash
# Commit documentation updates
git add CLAUDE.md ARCHITECTURE.md  # (or other affected files)
git commit -m "docs: document [change] from commit <hash>

- ARCHITECTURE.md: added Common Pitfall #[N]
- NAVIGATION_GUIDE.md: updated scenario [X] reading list
- Cross-references validated

Commit reviewed: <hash> ([original commit message])
"

# Push to docs branch
git push origin docs

# Create PR via GitHub
gh pr create --base main --head docs --title "docs: [summary]" --body "[details with commit links]"
```

### 6. Merge and Sync

After PR is merged to main:
```bash
git checkout docs
git pull origin main
git push origin docs
```

---

## Tech Stack

- **Flutter 3.x** (3.41.x) | **Riverpod 3.x** (hand-written Notifiers, NO codegen) | **go_router 17.x** (11 routes)
- **BuildShip REST API** — all backend including auth (NO direct Supabase SDK)
- **SharedPreferences** — user prefs | **geolocator** — location | **http** — API client

---

## Code Patterns (Reference Only)

**Note:** This worktree is for documentation, not code development. These patterns are provided as **reference material** when documenting code changes from the main branch.

Use these patterns to:
- Identify when a commit introduces a new pattern worth documenting
- Recognize violations of established patterns (potential pitfalls)
- Ensure documentation examples follow project conventions

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

---

## Documentation Review Checklist

Before committing documentation updates:
- [ ] **Commit hash referenced:** Include git commit hash(es) being documented
- [ ] **Primary location identified:** Use documentation-maintenance skill's decision matrix
- [ ] **Cross-references validated:** All line references and links are correct
- [ ] **Navigation guide updated:** If section line numbers shifted, update affected scenarios
- [ ] **No duplication:** Concept documented once (primary location) with cross-refs elsewhere
- [ ] **Commit message format:** `docs: [what changed] from commit <hash>`

---

## Git Workflow

### Commit Message Format
```
docs: [short description] from commit <hash>

- [File1]: [what changed]
- [File2]: [what changed]
- Cross-references validated

Commit reviewed: <hash> ([original commit message])
```

**Examples:**
```bash
# Documenting a new pitfall
git commit -m "docs: add Common Pitfall #13 from commit 0bca826

- ARCHITECTURE.md: added pitfall about client-side vs backend-driven logic
- NAVIGATION_GUIDE.md: updated scenario 6 (Search/Filter) with new warning
- Cross-references validated

Commit reviewed: 0bca826 (refactor: replace client-side match grouping with backend-driven sections)
"

# Documenting a pattern change
git commit -m "docs: update state detection pattern from commit 5b0ce37

- ARCHITECTURE.md: added computed getter example for derived state
- CLAUDE.md: added state detection guidance to State Management section
- Cross-references validated

Commit reviewed: 5b0ce37 (feat: implement filter greying for unavailable options)
"
```

### Branch Strategy
- **docs branch:** All documentation updates
- **main branch:** Source of commits to review
- **PRs:** Always `docs` → `main`

### Sync Frequency
- **Before starting work:** `git fetch origin main` to see new commits
- **After PR merge:** `git pull origin main` (into docs branch)
- **Weekly:** Check for unreviewed commits with `git log docs..main --oneline`

---

## documentation-maintenance Skill: Commit Review Adaptation

The `/documentation-maintenance` skill was originally designed for documenting your own fixes during development. In this worktree, we use it to review **others' commits from main branch**.

### Key Difference

| Original Workflow | Docs Worktree Workflow |
|-------------------|------------------------|
| Document fix you just implemented | Document commit from main branch |
| Reference your own code changes | Reference commits from main (`git show <hash>`) |
| Test fix before documenting | Analyze commit diff instead |

### Invocation Pattern

**Format:**
```bash
/documentation-maintenance "Review commit <hash>: [commit message]"
```

**Real examples:**
```bash
# Example 1: New pattern discovered
/documentation-maintenance "Review commit 5b0ce37: feat: implement filter greying for unavailable options"

# Example 2: Bug fix reveals pitfall
/documentation-maintenance "Review commit bd3f4f8: fix: restore state reads in _openFilterOverlay and improve docs"

# Example 3: Refactoring changes architecture
/documentation-maintenance "Review commit 0bca826: refactor: replace client-side match grouping with backend-driven sections"
```

### What the Skill Does (Unchanged)

1. **Verification:** Searches all .md files for existing mentions of the pattern
2. **Placement Decision:** Recommends where to document (CLAUDE.md, ARCHITECTURE.md, etc.)
3. **Navigation Guide Impact:** Identifies affected task scenarios
4. **Draft Documentation:** Creates proposed text with examples
5. **Cross-Reference Validation:** Checks for duplication across files
6. **Commit Preparation:** Prepares commit message with proper format

**Output:** Structured recommendation with draft documentation and commit message.

### When NOT to Document

Not every commit needs documentation:
- ✅ **DO document:** New patterns, common pitfalls, architecture changes, product decisions
- ❌ **SKIP:** Trivial changes (typos, formatting), already-documented patterns, low-level implementation details

**Signal: Look for "Discovered:" or "Decision:" sections in commit message.** If the main worktree included these sections (per [COMMIT_MESSAGE_TEMPLATE.md](COMMIT_MESSAGE_TEMPLATE.md)), the commit needs documentation. If these sections are absent and the change is straightforward, it's likely already documented or not significant enough.

**Use the skill's assessment to determine if documentation is needed.**

### Quarterly Review Workflow

Every 3 months, review commits from last quarter for undocumented patterns:
```bash
# Find commits from last quarter
git log --since="3 months ago" --until="now" main --oneline

# Review for patterns
/documentation-maintenance "Quarterly review: check for undocumented patterns from [start-date] to [end-date]"
```

---

## Critical Product Decisions (Reference)

**Note:** These decisions are documented here for reference when analyzing commits from main branch. They help identify when a commit:
- Violates an established decision (needs documentation as a pitfall)
- Introduces a new decision (needs adding to this list)
- Implements a decision correctly (may not need additional documentation)

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
