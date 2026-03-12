# Code Development Workflow

**Version:** 1.0
**Last Updated:** March 2026
**Applies to:** Main worktree code development

---

## Purpose

This document defines the **systematic process for developing code** in JourneyMate. It ensures:
- All documented patterns are followed
- Common pitfalls are avoided
- Code is validated before committing
- Documentation is used effectively

**This is a PROCESS document, not a structure document.**
- For app structure/patterns → See **ARCHITECTURE.md**
- For task-based navigation → See **NAVIGATION_GUIDE.md**
- For API details → See **_reference/** docs

---

## Documentation Flow

```
CLAUDE.md (entry point)
  ↓
CODE_DEVELOPMENT_WORKFLOW.md (this doc - process guidance)
  ↓
NAVIGATION_GUIDE.md (task-based routing)
  ↓
ARCHITECTURE.md (patterns, pitfalls, checklist)
  ↓
Reference docs (API, providers, design system)
```

---

## Workflow Overview

### Three Phases

1. **Pre-Development** — Understand context before writing code
2. **Development** — Follow patterns while writing code
3. **Pre-Commit Validation** — Verify code before committing

Each phase has specific steps and document references.

---

## Phase 1: Pre-Development

**Goal:** Understand relevant patterns, pitfalls, and references BEFORE writing code.

### Step 1.1: Identify Your Task Type

Use **NAVIGATION_GUIDE.md** to find your scenario (1-12):

| Scenario | When to Use |
|----------|-------------|
| 1. New Page/Route | Creating a new screen |
| 2. State Management | Adding/modifying providers |
| 3. API Integration | Calling BuildShip endpoints |
| 4. Translations | Adding/updating UI text |
| 5. Design Changes | Modifying colors/spacing/typography |
| 6. Search/Filter | Restaurant filtering logic |
| 7. Location/Maps | Geolocation features |
| 8. Analytics | Tracking events |
| 9. Navigation | go_router configuration |
| 10. Swipe Gestures | Dismissible UI |
| 11. Debugging | Fixing bugs |
| 12. Testing | Writing/fixing tests |

**Action:** Find your scenario in NAVIGATION_GUIDE.md → Get targeted reading list (10-30 minutes).

### Step 1.2: Read Relevant Architecture Sections

Based on NAVIGATION_GUIDE.md recommendations, read:
- **Required sections** — Core patterns for your task
- **Common Pitfalls** — Specific pitfalls for your code area (see mapping below)
- **Code Review Checklist** — Items relevant to your changes

**Example:** If adding state management (Scenario 2):
1. Read ARCHITECTURE.md → State Management (lines 154-351)
2. Read Common Pitfalls #6-10 (state-related, lines 2187-2262)
3. Note checklist items: "Global state uses NotifierProvider"

### Step 1.3: Check Reference Documentation

If your task involves:
- **API calls** → Read _reference/BUILDSHIP_API_REFERENCE.md for endpoint contracts
- **State changes** → Read _reference/PROVIDERS_REFERENCE.md for existing providers
- **Design tokens** → Read DESIGN_SYSTEM_flutter.md for color/spacing rules
- **File locations** → Read DIRECTORY_STRUCTURE.md for where files belong

**Do NOT skip this step.** Reference docs prevent common mistakes like:
- Using wrong API field names
- Duplicating existing providers
- Violating color semantics

### Step 1.4: Review Existing Code

Before modifying existing code:
1. **Read the file first** — Understand current patterns
2. **Check shared sources** — See if logic exists in app_theme.dart or lib/widgets/shared/
3. **Understand dependencies** — What providers does this widget use?

**Never propose changes to code you haven't read.**

---

## Phase 2: Development

**Goal:** Write code that follows documented patterns.

### Step 2.1: Follow Design Token Rules (Non-Negotiable)

**Every UI element must use design tokens:**
- Colors → `AppColors.*` (NO raw hex)
- Spacing → `AppSpacing.*` (NO magic numbers)
- Typography → `AppTypography.*` (NO inline TextStyle)
- Radii → `AppRadius.*` (NO BorderRadius.circular)

**Check while writing:**
- ✅ `color: AppColors.accent`
- ❌ `color: Color(0xFFe8751a)`

**Reference:** ARCHITECTURE.md → Design Token System (lines 1820-1830)

### Step 2.2: Follow State Management Patterns

**Decision matrix:**
- **Global/session state** → `NotifierProvider` or `AsyncNotifierProvider`
- **Page-local UI state** → Local `State` variables in widget
- **NO** `FFAppState`, `Provider`, or `StateNotifier` (deprecated)

**Before creating new provider:**
1. Check _reference/PROVIDERS_REFERENCE.md — Does provider already exist?
2. Check ARCHITECTURE.md → State Management (lines 154-351) — Which type?
3. Follow established patterns from existing providers

**Reference:** ARCHITECTURE.md → State Management (lines 154-351)

### Step 2.3: Follow Widget Patterns

**Self-contained widgets:**
- Widgets read providers/context internally
- NO infrastructure props (language, translations, dimensions)
- Props only for business logic data

**Widget type selection:**
- Use `ConsumerWidget` when reading providers
- Use `StatelessWidget` for pure widgets (no provider reads)
- Use `ConsumerStatefulWidget` for widgets with local state + provider reads

**Reference:** ARCHITECTURE.md → Widget Patterns (lines 354-1025)

### Step 2.4: Translations (100% Required)

**Every user-facing text must use td() function:**
```dart
// ✅ Correct
Text(td(ref, 'welcomeMessage'))

// ❌ Wrong
Text('Welcome to JourneyMate')
```

**Before adding new translation key:**
1. Check if key exists in _reference/BUILDSHIP_API_REFERENCE.md → GET /languageText
2. If new key needed, add to all 15 languages via Supabase

**Reference:** ARCHITECTURE.md → Translation System (lines 1738-1893)

### Step 2.5: Analytics (Fire-and-Forget)

**Rules:**
- NEVER `await` analytics calls
- NEVER call `markUserEngaged()` manually (ActivityScope handles it)
- Fire-and-forget pattern: `AnalyticsService().logEvent(...);`

**Reference:** ARCHITECTURE.md → Analytics Architecture (lines 1833-1907)

### Step 2.6: API Calls

**Before making API call:**
1. Read _reference/BUILDSHIP_API_REFERENCE.md → Find endpoint
2. Verify required parameters and response format
3. Use ApiService singleton pattern (see ARCHITECTURE.md lines 1376-1510)

**Common mistake:** Assuming API response structure. Always check reference first.

### Step 2.7: Use Skills When Appropriate

**Available skills for systematic development:**
- `/tdd` — Use when implementing features (write tests first)
- `/systematic-debugging` — Use when encountering bugs (root cause analysis)
- `/verification-before-completion` — Use before claiming work is done

**When to use:**
- Implementing new feature → Consider TDD approach
- Bug not obvious → Use systematic debugging
- About to commit → Use verification

**Don't overuse:** Not every small change needs a skill. Use judgment.

---

## Phase 3: Pre-Commit Validation

**Goal:** Ensure code meets all requirements before committing.

### Step 3.1: Run Code Quality Checks

**Required:**
```bash
flutter analyze
```

**Must pass with 0 errors, 0 warnings.**

**If warnings appear:**
- Fix them (don't ignore)
- Common warnings: unnecessary_underscores, prefer_const_constructors
- See ARCHITECTURE.md → Common Pitfalls #19-21 (lines 2754-2901) for linting rules

### Step 3.2: Review Against Code Review Checklist

**Required reading:** ARCHITECTURE.md → Code Review Checklist (lines 2032-2126)

**Go through EVERY item relevant to your changes:**

**Design Tokens:**
- [ ] All colors from AppColors
- [ ] All spacing from AppSpacing
- [ ] All typography from AppTypography
- [ ] All radii from AppRadius

**State Management:**
- [ ] Global state uses NotifierProvider/AsyncNotifierProvider
- [ ] Page-local state uses local State variables
- [ ] No FFAppState/Provider/StateNotifier

**Translations:**
- [ ] All text via td(ref, 'key')

**Widget Architecture:**
- [ ] Self-contained widgets (no infrastructure props)
- [ ] ConsumerWidget only when using ref

**Analytics:**
- [ ] Fire-and-forget (never await)
- [ ] No manual markUserEngaged()

**Flutter 3.x APIs:**
- [ ] WidgetStateProperty (not MaterialStateProperty)
- [ ] .withValues(alpha:) (not .withOpacity())
- [ ] context.mounted checks after async

**Code Quality:**
- [ ] flutter analyze clean
- [ ] No unaddressed TODOs

**Shared Sources:**
- [ ] Checked app_theme.dart before modifying pages
- [ ] Checked lib/widgets/shared/ before creating new widgets

### Step 3.3: Verify Against Common Pitfalls

**Check pitfalls relevant to your code area:**

| Code Area | Check These Pitfalls |
|-----------|---------------------|
| **Colors/Spacing** | Pitfalls #1-2 (lines 2131-2160) |
| **Flutter 3.x APIs** | Pitfalls #3-5 (lines 2151-2206) |
| **State Management** | Pitfalls #6-10 (lines 2187-2262) |
| **Widget Lifecycle** | Pitfalls #11, #33 (lines 2263-2347, 3398-3447) |
| **Translations** | Pitfall #12 (lines 2348-2462) |
| **Widget Props** | Pitfall #8 (lines 2218-2231) |
| **Search/Filter** | Pitfalls #13-18 (lines 2463-2753) |
| **Linting** | Pitfalls #19-21 (lines 2754-2901) |
| **Code Quality** | Pitfalls #22-24, #34 (lines 2902-3116, 3448-3487) |

**Action:** Scan relevant pitfalls, verify your code doesn't violate them.

**Reference:** ARCHITECTURE.md → Common Pitfalls (lines 2129-3487)

### Step 3.4: Test Your Changes

**Minimum testing requirements:**
- [ ] Code compiles without errors
- [ ] Changed functionality works as expected
- [ ] No regressions in related features
- [ ] Analytics events fire (if applicable)
- [ ] Translations display correctly (if applicable)

**For complex changes:**
- [ ] Test on both iOS and Android (if UI changes)
- [ ] Test with different language selections (if translations)
- [ ] Test edge cases (empty states, errors, loading)

### Step 3.5: Document Discoveries

**If you discovered patterns or pitfalls during development:**

Add to commit message:
```
feat: implement feature X

Implementation details...

Discovered:
- [Pattern/pitfall discovered during development]
- [Why it matters]

Decision:
- [Architectural choice made]
- [Rationale]

See also:
- Needs update: [which doc needs review]
```

**Docs worktree will review and update formal documentation.**

**Reference:** COMMIT_MESSAGE_TEMPLATE.md for full format

---

## Navigation Between Documents

### Document Purposes

| Document | When to Read | What It Contains |
|----------|--------------|------------------|
| **CLAUDE.md** | Session start | Where to start, what exists |
| **CODE_DEVELOPMENT_WORKFLOW.md** | Before coding | This doc - systematic process |
| **NAVIGATION_GUIDE.md** | Task unclear | 12 scenarios with reading lists |
| **ARCHITECTURE.md** | During dev | Patterns, pitfalls, checklist |
| **DESIGN_SYSTEM_flutter.md** | UI changes | Color semantics, spacing scale |
| **PROVIDERS_REFERENCE.md** | State work | All providers and methods |
| **BUILDSHIP_API_REFERENCE.md** | API calls | Endpoint contracts |
| **DIRECTORY_STRUCTURE.md** | File location unclear | Where files belong |
| **COMMIT_MESSAGE_TEMPLATE.md** | Before commit | How to write commit message |

### Efficient Reading Strategy

**Don't read everything!** Use targeted reading:

1. **Start here** (CODE_DEVELOPMENT_WORKFLOW.md) → Understand process
2. **NAVIGATION_GUIDE.md** → Get targeted reading list for your task
3. **ARCHITECTURE.md** → Read ONLY sections from navigation guide
4. **Reference docs** → Check ONLY when you need specific details

**Example: Adding API call to new page:**
1. CODE_DEVELOPMENT_WORKFLOW.md (this doc) → Understand workflow
2. NAVIGATION_GUIDE.md → Scenario 3 (API Integration) → 15-minute reading list
3. ARCHITECTURE.md → API Service Pattern (lines 1376-1510)
4. BUILDSHIP_API_REFERENCE.md → Specific endpoint you're calling
5. ARCHITECTURE.md → Code Review Checklist before commit

**Total reading: 20-30 minutes vs. reading everything (2+ hours).**

### When Documents Are Outdated

If you notice documentation doesn't match reality:
1. Add inline code comment explaining actual pattern
2. Flag in commit message "See also:" section
3. Docs worktree will update formal documentation

**Never let outdated docs block you.** Code works, then docs get updated.

---

## Error Prevention Strategy

**Goal:** Use documented pitfalls to prevent errors BEFORE they happen.

### Pitfall Categories

**34 documented pitfalls organized by category:**

1. **Design Tokens (Pitfalls #1-2)** — Raw hex, magic numbers
2. **Flutter 3.x APIs (Pitfalls #3-5)** — Deprecated APIs
3. **State Management (Pitfalls #6-10)** — Non-atomic updates, staleness, prop drilling
4. **Widget Lifecycle (Pitfalls #11, #33)** — ref after unmount, ref.read in dispose
5. **Translations (Pitfall #12)** — Hardcoded strings
6. **Search/Filter (Pitfalls #13-18)** — Client-side logic, state management
7. **Linting (Pitfalls #19-21)** — Double underscores, conditional entries
8. **Code Quality (Pitfalls #22-24)** — Refactoring tested code, defensive validation
9. **Data & API (Pitfalls #25-32)** — Provider data, day keys, JSON casting, caching, sessions
10. **UI Patterns (Pitfall #34)** — Tab-jumping guard for PageController

### How to Use Pitfalls

**Before coding:**
- Scan pitfalls relevant to your task (see Step 1.2)
- Mental note: "Don't do X"

**During coding:**
- If you're about to do something that feels hacky, check if it's a documented pitfall
- When stuck, check if related pitfall has solution

**Before committing:**
- Go through Step 3.3 (Verify Against Common Pitfalls)
- Systematically verify your code doesn't violate relevant pitfalls

**When reviewing code:**
- Use pitfalls as review criteria
- Each pitfall has ✅ Good and ❌ Bad examples

---

## Special Cases

### Working in FlutterFlow Legacy Code

**If modifying files with FlutterFlow patterns:**
- Read file first to understand existing patterns
- Maintain consistency within that file
- Don't mix FlutterFlow patterns with new patterns
- Consider refactoring entire file to new patterns (if feasible)

**Reference:** ARCHITECTURE.md → Code Quality Standards (lines 1910-2029)

### Emergency Fixes

**If production issue needs immediate fix:**
- Still run `flutter analyze` (must pass)
- Still check relevant pitfalls (quick scan)
- Document shortcuts taken in commit message
- Flag for follow-up refactoring if needed

**Don't skip validation completely, even in emergencies.**

### Refactoring Existing Code

**Before refactoring:**
- Read ARCHITECTURE.md → Pitfall #22 (lines 2902-2961)
- Understand why code exists as-is
- Test thoroughly before/after

**Refactoring FlutterFlow algorithms:**
- High risk of bugs
- Only refactor if you fully understand edge cases
- Prefer leaving working code alone

---

## Quick Reference Card

**Before coding:**
1. Find task in NAVIGATION_GUIDE.md (12 scenarios)
2. Read recommended ARCHITECTURE.md sections (10-30 min)
3. Check reference docs for API/state details

**During coding:**
4. Follow design token rules (AppColors, AppSpacing, etc.)
5. Follow state management patterns (NotifierProvider, local state)
6. All text via td(ref, 'key')
7. Fire-and-forget analytics

**Before committing:**
8. `flutter analyze` (must be clean)
9. ARCHITECTURE.md → Code Review Checklist (lines 2032-2126)
10. Verify against relevant Common Pitfalls (lines 2129-3487)
11. Test changes work
12. Document discoveries in commit message

---

## Integration with CLAUDE.md

**CLAUDE.md tells you to come here (CODE_DEVELOPMENT_WORKFLOW.md) when starting code work.**

This document then guides you through:
- What to read (via NAVIGATION_GUIDE.md)
- How to write code (following ARCHITECTURE.md patterns)
- How to validate (using Code Review Checklist and Common Pitfalls)

**Flow:**
```
CLAUDE.md → "Go to CODE_DEVELOPMENT_WORKFLOW.md"
  ↓
CODE_DEVELOPMENT_WORKFLOW.md → "Use NAVIGATION_GUIDE.md for your task"
  ↓
NAVIGATION_GUIDE.md → "Read these ARCHITECTURE.md sections"
  ↓
ARCHITECTURE.md → Patterns, pitfalls, checklist
  ↓
Reference docs → Specific API/state/design details
```

---

## When to Update This Document

**This document should be updated when:**
- New workflow steps are identified (e.g., new validation requirement)
- Navigation flow changes (e.g., new reference doc added)
- Skills become available/deprecated
- Common workflow mistakes are discovered

**This document should NOT contain:**
- Specific code patterns (those go in ARCHITECTURE.md)
- API contracts (those go in _reference/)
- Design tokens (those go in DESIGN_SYSTEM_flutter.md)

**Single Responsibility: This document defines PROCESS, not STRUCTURE.**

---

**Last Updated:** March 2026
**For questions:** See CLAUDE.md → Help & Feedback
