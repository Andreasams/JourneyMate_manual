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
- **CODE_DEVELOPMENT_WORKFLOW.md** — When documenting workflow or process changes
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

**CRITICAL RULE: ALL documentation is exclusive to docs worktree. Main worktree NEVER touches .md files.**

| Document Type | Main Worktree | Docs Worktree |
|---------------|---------------|---------------|
| **ALL .md files** (reference docs, strategic docs, design system, etc.) | ❌ **NEVER touches** | ✅ Maintains exclusively |
| **Commit messages** | ✅ Writes with "Discovered:" + "See also:" sections | ✅ Reads to extract insights and identify docs needing updates |
| **Code (.dart files)** | ✅ Writes code | ❌ Never touches (read-only reference) |

**Why this matters:** If both worktrees can modify documentation, merge conflicts are inevitable. Single source of truth = clean workflow.

### CLAUDE.md: Worktree-Specific Versions

**Problem:** Each worktree needs its own CLAUDE.md with different instructions, but merging overwrites one with the other.

**Solution:** Docs worktree maintains TWO files:
- `CLAUDE.md` - Instructions for documentation maintenance (this file, docs-specific)
- `CLAUDE_MAIN.md` - Copy of main worktree's CLAUDE.md (for code development)

**When to edit which:**
- Updating **docs workflow** → Edit `CLAUDE.md`
- Adding **Critical Product Decision** → Edit `CLAUDE_MAIN.md`
- Adding **Code Pattern** → Edit `CLAUDE_MAIN.md`

**In PRs:** Include `CLAUDE_MAIN.md` which merges to main as `CLAUDE.md`. NEVER include docs' `CLAUDE.md` in PRs to main.

**Main worktree's job:**
- Write code
- Write detailed commit messages with "Discovered:", "Decision:", and "See also:" sections
- NEVER modify .md files (not even reference docs!)

**Docs worktree's job:**
- Read commit messages from main branch
- Update ALL documentation (reference docs, strategic docs, design system, etc.)
- Maintain cross-references and consistency
- Create separate documentation PRs

**When main worktree discovers documentation needs updating:**
Use "See also:" section in commit message to flag which docs need review. Example:
```
See also:
- Needs update: _reference/BUILDSHIP_API_REFERENCE.md (new field: match_score)
- Needs update: ARCHITECTURE.md (add pitfall about ref.read() staleness)
```

### 🛡️ Automated CLAUDE.md Protection

**Problem:** When pulling main into docs worktree (`git pull origin main`), git tries to merge main's CLAUDE.md (code instructions) with docs' CLAUDE.md (documentation instructions), causing overwrites.

**Solution (Automatic):**
Two layers of protection ensure docs' CLAUDE.md is never lost:

1. **`.gitattributes` merge strategy:**
   ```
   CLAUDE.md merge=ours
   ```
   Tells git to always keep docs branch version during merges. Configuration: `git config merge.ours.driver true`

2. **Post-merge hook (safety net):**
   Located at `.git/worktrees/Docs/hooks/post-merge`, automatically runs after `git pull`:
   - Detects if CLAUDE.md was changed in merge
   - Checks if it still has "Worktree Identity: Documentation Maintenance" marker
   - If overwritten, auto-restores from previous commit and commits fix
   - Logs result: ✅ correct or ❌ restored

**Verification:**
```bash
# Check .gitattributes exists
cat .gitattributes  # Should show: CLAUDE.md merge=ours

# Check hook exists
ls -la C:/Users/Rikke/Documents/JourneyMate/Main/.git/worktrees/Docs/hooks/post-merge

# Test: Pull from main and check CLAUDE.md starts with "⚠️ Worktree Identity"
git pull origin main && head -10 CLAUDE.md
```

**Manual Recovery (if needed):**
If both protections fail:
```bash
# Restore from last known good commit on docs branch
git show HEAD~1:CLAUDE.md > CLAUDE.md
git add CLAUDE.md
git commit -m "docs: restore docs worktree's CLAUDE.md"
```

**Why this is critical:** Without protection, opening Claude Code in docs worktree after pulling main would load main's instructions, causing Claude to try modifying code instead of documentation.

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
2. Edit affected .md files:
   - **Main worktree's CLAUDE.md** → Edit `CLAUDE_MAIN.md` (NOT `CLAUDE.md`)
   - **Other docs** → Edit directly (ARCHITECTURE.md, DESIGN_SYSTEM_flutter.md, etc.)
3. Verify cross-references are correct
4. Update NAVIGATION_GUIDE.md if section line numbers shifted

### 5. Create Documentation PR

```bash
# Commit documentation updates
git add ARCHITECTURE.md NAVIGATION_GUIDE.md CLAUDE_MAIN.md  # (or other affected files)
# NOTE: NEVER add CLAUDE.md (docs-specific) to commits going to main
git commit -m "docs: document [change] from commit <hash>

- CLAUDE_MAIN.md: added Critical Product Decision #[N]
- ARCHITECTURE.md: added Common Pitfall #[N]
- NAVIGATION_GUIDE.md: updated scenario [X] reading list
- Cross-references validated

Commit reviewed: <hash> ([original commit message])
"

# Push to docs branch
git push origin docs

# Create PR via GitHub
gh pr create --base main --head docs --title "docs: [summary]" --body "[details]"
```

**⚠️ AFTER PR IS MERGED: Immediately proceed to Step 6 (Merge and Sync) to sync both worktrees locally.**

### 6. Merge and Sync (REQUIRED after every PR)

**CRITICAL: This step must be done immediately after PR merge to keep local worktrees in sync with GitHub.**

After PR is merged to main on GitHub, run these commands:

```bash
# ============================================
# STEP 1: Sync Main Worktree (code development)
# ============================================
cd "C:\Users\Rikke\Documents\JourneyMate\Main"

# Pull merged changes from GitHub
git pull origin main

# Replace CLAUDE.md with correct version from CLAUDE_MAIN.md
cp CLAUDE_MAIN.md CLAUDE.md

# Remove CLAUDE_MAIN.md (staging file only needed in docs worktree)
rm CLAUDE_MAIN.md

# Commit and push the cleanup
git add CLAUDE.md
git rm CLAUDE_MAIN.md
git commit -m "docs: sync CLAUDE.md from CLAUDE_MAIN.md and remove staging file"
git push origin main

# Verify correct file exists
ls -lh *.md | grep -E "(CLAUDE|CODE_DEVELOPMENT)"
# Should show: CLAUDE.md (correct), CODE_DEVELOPMENT_WORKFLOW.md (new), no CLAUDE_MAIN.md

# ============================================
# STEP 2: Sync Docs Worktree (documentation maintenance)
# ============================================
cd "C:\Users\Rikke\Documents\JourneyMate\Docs"

# Pull main worktree's cleanup commit
git pull origin main

# Verify CLAUDE.md protected (should still be docs version)
head -10 CLAUDE.md | grep "Worktree Identity: Documentation Maintenance"
# Should output: ## ⚠️ Worktree Identity: Documentation Maintenance

# Update CLAUDE_MAIN.md to match main's CLAUDE.md (for future edits)
cp "C:\Users\Rikke\Documents\JourneyMate\Main\CLAUDE.md" CLAUDE_MAIN.md

# Commit and push CLAUDE_MAIN.md update
git add CLAUDE_MAIN.md
git commit -m "docs: sync CLAUDE_MAIN.md with main worktree"
git push origin docs
```

**Verification checklist:**
- [ ] Main worktree: `CLAUDE.md` exists, `CLAUDE_MAIN.md` removed, `CODE_DEVELOPMENT_WORKFLOW.md` exists
- [ ] Docs worktree: `CLAUDE.md` (docs version) protected, `CLAUDE_MAIN.md` updated
- [ ] GitHub main branch: Has cleanup commit removing `CLAUDE_MAIN.md`
- [ ] Both worktrees pushed to GitHub (no uncommitted changes)

### Documentation Placement Decision Matrix

**Use this matrix to determine where new documentation belongs:**

| Content Type | Primary Location | Why |
|--------------|------------------|-----|
| **Code patterns** (design tokens, state, widgets) | ARCHITECTURE.md | Implementation details |
| **Common pitfalls** (bugs learned from) | ARCHITECTURE.md → Common Pitfalls | Pattern violations |
| **API contracts** (endpoints, responses) | _reference/BUILDSHIP_API_REFERENCE.md | API reference |
| **Provider catalog** (state, methods) | _reference/PROVIDERS_REFERENCE.md | State reference |
| **Design tokens** (colors, spacing, typography) | DESIGN_SYSTEM_flutter.md | Design reference |
| **Critical product decisions** (features, business logic) | CLAUDE_MAIN.md → Critical Decisions | Business rules |
| **Pre-commit checklist** | ARCHITECTURE.md → Code Review Checklist | Developer workflow |
| **Workflow instructions** (git, commits, navigation) | CLAUDE_MAIN.md | High-level guidance |

**Key principle:**
- **CLAUDE_MAIN.md** = Workflow + Product Decisions + Navigation (high-level)
- **ARCHITECTURE.md** = Code Patterns + Pitfalls + Checklist (implementation)
- **Reference docs** = API/Provider catalogs (lookup tables)
- **Design docs** = Visual tokens + UI patterns (design reference)

**How main worktree communicates documentation needs:**
Main worktree NEVER modifies .md files. Instead, commits include:
- **Inline code comments:** Explain complex logic directly in code
- **Commit message "Discovered:" section:** Patterns/pitfalls found
- **Commit message "See also:" section:** Flags which docs need updates

Docs worktree reviews commits and places formal documentation in correct location.

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
- **344 app keys** (0 legacy keys remaining)

### Analytics
- **Fire-and-forget** (NEVER await analytics calls)
- **ActivityScope** handles engagement tracking automatically
- **NEVER call** `markUserEngaged()` manually (pattern removed from FlutterFlow)

### Location Permissions
- **User-facing buttons:** `enableLocation()` (shows dialog or opens Settings)
- **App startup:** `requestPermissionIfNeeded()` (safe to call on every launch)
- **See ARCHITECTURE.md** → Location Permission Pattern (lines 624-703) for full guidance

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
- [ ] **CLAUDE.md separation:** Edited `CLAUDE_MAIN.md` for main worktree changes, NOT `CLAUDE.md` (docs-specific)
- [ ] **Commit hash referenced:** Include git commit hash(es) being documented
- [ ] **Primary location identified:** Use documentation-maintenance skill's decision matrix
- [ ] **Cross-references validated:** All line references and links are correct
- [ ] **Navigation guide updated:** If section line numbers shifted, update affected scenarios
- [ ] **No duplication:** Concept documented once (primary location) with cross-refs elsewhere
- [ ] **Code examples validated:** Type-safe code in examples (Map<String, Object> not dynamic in callbacks)
- [ ] **Commit message format:** `docs: [what changed] from commit <hash>`
- [ ] **PR excludes docs' CLAUDE.md:** Never include docs' CLAUDE.md in PRs to main

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
