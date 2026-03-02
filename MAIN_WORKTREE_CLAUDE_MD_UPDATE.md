# Main Worktree CLAUDE.md Update

**Purpose:** This file contains sections to add to the main worktree's CLAUDE.md (`C:\Users\Rikke\Documents\JourneyMate\Main\CLAUDE.md`)

**How to apply:**
1. Copy this file to the main worktree
2. Add the sections below to CLAUDE.md at the indicated locations
3. Delete this file after applying

---

## Section 1: Add After "Git Workflow" Section

**Location:** After the "Git Workflow" section (around line 107 in current main CLAUDE.md)

**Insert this:**

```markdown
---

## Commit Messages: Documentation Context Protocol

Your commits are reviewed by the docs worktree to maintain project documentation. Include these sections to provide documentation context.

### Required Format

See **[COMMIT_MESSAGE_TEMPLATE.md](COMMIT_MESSAGE_TEMPLATE.md)** for complete examples and guidance.

**Required sections:**
```
<type>: <short description>

Problem: [What issue/bug/need triggered this change]
Solution: [How you solved it - high-level approach]
Tested: [What testing confirmed it works]
```

**Optional sections (include when applicable):**
```
Discovered: [Patterns, pitfalls, or insights - THIS FEEDS DOCUMENTATION]
Decision: [Architectural choices made and why]
Errors: [Error messages encountered before fixing]
See also: [Related files or docs that might need updates]
```

### Key Sections for Documentation

#### Discovered: Patterns & Pitfalls
**Include when:**
- You hit a common pitfall or gotcha
- You learned something non-obvious about Flutter/Riverpod/BuildShip
- You found a best practice through trial and error
- You discovered a pattern that applies beyond this specific change

**Example:**
```
Discovered: Riverpod pitfall - ref.read() in callbacks gives stale data
if state updates after callback creation. Rule: ALWAYS use ref.watch()
in build methods for reactive state. This applies to all bottom sheets,
dialogs, and overlays with provider-derived state.

Recommended for ARCHITECTURE.md Common Pitfalls section.
```

#### Decision: Architectural Choices
**Include when:**
- You chose between multiple valid approaches
- You made a trade-off (simplicity vs flexibility, performance vs maintainability)
- You deviated from a standard pattern for good reason
- Future developers might ask "why not do it this other way?"

**Example:**
```
Decision: Used local state in FilterOverlay instead of creating a provider.
Rationale: Tab selection is ephemeral UI state that doesn't need to persist
or be accessed elsewhere. Local state is simpler and follows the "page-local
UI state" pattern from ARCHITECTURE.md.

Alternative considered: NotifierProvider, rejected because it adds complexity
with no benefit. Revisit if tab selection needs to persist across closes.
```

#### See Also: Documentation Updates
**Include when:**
- You updated reference docs (API contracts, provider lists, design tokens)
- You suspect high-level docs need updates based on your changes
- Your change affects multiple areas requiring doc updates

**Example:**
```
See also:
- Updated: _reference/BUILDSHIP_API_REFERENCE.md (searchRestaurants response)
- Review needed: ARCHITECTURE.md "State Management" section (add note about
  ref.read() staleness pitfall?)
- Related: lib/widgets/filter_overlay.dart:142-167
```

### Workflow Integration

**Your commit message is the documentation handoff:**
```
Main Worktree (You) → GitHub Commit → Docs Worktree
     (codes)           (explains)      (documents)
```

The docs worktree reads your commit messages to:
- Extract patterns for ARCHITECTURE.md
- Identify pitfalls for Common Pitfalls section
- Update strategic documentation (CLAUDE.md, NAVIGATION_GUIDE.md)
- Validate your reference doc updates

**Good commit messages = Good documentation.** Invest time here.

---

## Documentation Update Rules

### ✅ You CAN Update (Reference Docs)

Update these directly when code changes:

- **`_reference/BUILDSHIP_API_REFERENCE.md`** — When API contracts change
  - Example: New fields in response, changed parameter types, new endpoints

- **`_reference/PROVIDERS_REFERENCE.md`** — When adding/removing/renaming providers
  - Example: Created new NotifierProvider, removed deprecated provider

- **`DESIGN_SYSTEM_flutter.md`** — When adding new design tokens
  - Example: Added new color to AppColors, new spacing constant to AppSpacing

- **Inline code comments** — Always for complex logic
  - Example: Explaining why a specific Riverpod pattern is used

**When updating reference docs:**
- Keep it factual (what the API/provider does)
- Don't add architectural guidance (that's docs worktree's job)
- Mention the update in commit "See also:" section

### ❌ You CANNOT Update (Strategic Docs)

These are maintained exclusively by the docs worktree:

- **`CLAUDE.md`** — Session rules, critical decisions, high-level guidance
- **`ARCHITECTURE.md`** — Pattern documentation, Common Pitfalls, architectural guidance
- **`NAVIGATION_GUIDE.md`** — Task scenarios, reading lists
- Any section titled "Common Pitfalls" or "Patterns"

**If you think these need updates:**
- Add "See also: [doc] might need update because [reason]" to commit message
- The docs worktree will review and update if appropriate

### 🤝 Hybrid (Design System)

- **`DESIGN_SYSTEM_flutter.md`**
  - You: Add new tokens (colors, spacing, radii) when created
  - Docs worktree: Documents patterns, usage rules, semantic meanings

---

## Example: Good Commit with Documentation Context

```
fix: restore state reads in _openFilterOverlay and improve docs

Problem: FilterOverlay showed stale restaurant counts after search results
updated. Root cause: ref.read() in _openFilterOverlay callback captured state
at callback creation time, not invocation time. Users would search "pasta"
(12 results), then "pizza" (8 results), open filter overlay, see counts from
"pasta" (stale data).

Solution: Moved provider reads from callback parameters to inside FilterOverlay
widget's build method. Changed pattern from:
  onPressed: () => _openFilterOverlay(context, ref.read(matchCountsProvider))
to:
  onPressed: () => _openFilterOverlay(context)

FilterOverlay now uses ref.watch() in build to reactively track state changes.

Tested:
- Search "pasta" → open filter → counts show 12 (correct)
- Apply filter → close → reopen → counts update immediately
- Rapid searches → no stale data at any point
- iOS simulator (iPhone 15 Pro, iOS 17.2)

Discovered: Major Riverpod pitfall - ref.read() in callbacks gives stale data
if state updates after callback creation. This is because callbacks capture
the value at creation time (closure), not invocation time.

Rule: ALWAYS use ref.watch() in build methods for reactive state reads. Use
ref.read() ONLY for one-time actions in event handlers (like triggering
navigation, analytics) where you want the value at that exact moment, not
reactive tracking.

This applies to ALL bottom sheets, dialogs, overlays, and any callback that
displays provider-derived state. Common locations: onPressed, onTap,
showModalBottomSheet callbacks.

Strongly recommend documenting as Common Pitfall in ARCHITECTURE.md - this is
a framework-level misunderstanding that will recur.

Decision: Updated BUILDSHIP_API_REFERENCE.md to clarify searchRestaurants
returns match_counts object with filter counts. This was undocumented API
behavior. Updated reference doc in main worktree since it's 1:1 with API
contract (not a pattern/architecture insight).

Errors: Initially got "Bad state: Cannot read providers inside callbacks"
which was misleading - problem wasn't reading in callback, but stale data
from closure capture.

See also:
- Updated: _reference/BUILDSHIP_API_REFERENCE.md (searchRestaurants response format)
- Review needed: ARCHITECTURE.md "State Management > Common Pitfalls"
  (add ref.read() staleness pitfall)
- Files: lib/pages/search_results_page.dart:287-312
- Pattern used in: lib/widgets/filter_overlay.dart:142-167

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

**What makes this good:**
- ✅ Clear problem statement (what was broken, how to reproduce)
- ✅ Solution approach (high-level, code shows details)
- ✅ Thorough testing details
- ✅ **"Discovered:" section documents the pitfall pattern**
- ✅ **"Decision:" section explains doc update choice**
- ✅ **"See also:" flags docs needing review**
- ✅ Enough context that docs worktree can write quality documentation

---

## Code Review Checklist Update

**Replace the existing "Code Review Checklist" section with:**

```markdown
## Code Review Checklist

Before every commit:
- [ ] Design tokens: All colors/spacing/typography from `App*` classes (no raw hex/numbers)
- [ ] Color semantics: Orange for CTAs only, green for match confirmation only
- [ ] State: No FFAppState, page-local state in widgets not providers, all text via `td(ref, key)`
- [ ] Shared sources: Check theme (app_theme.dart) and shared widgets (lib/widgets/shared/) before modifying individual pages
- [ ] Quality: `flutter analyze` clean, no unaddressed TODOs
- [ ] **Commit message:** Includes Problem/Solution/Tested, plus Discovered/Decision/See also when applicable (see [COMMIT_MESSAGE_TEMPLATE.md](COMMIT_MESSAGE_TEMPLATE.md))
- [ ] **Reference docs updated:** If API/provider/design token changes, updated corresponding reference doc
```

---

## Summary for Main Worktree

**Your responsibilities:**
1. ✅ Write code with quality and patterns from ARCHITECTURE.md
2. ✅ Update reference docs (API contracts, provider lists, design tokens) when code changes
3. ✅ Write rich commit messages with "Discovered:" and "Decision:" sections
4. ✅ Add inline code comments for complex logic
5. ❌ Never update strategic docs (CLAUDE.md, ARCHITECTURE.md, NAVIGATION_GUIDE.md)

**Docs worktree responsibilities:**
1. ✅ Reviews your commits for patterns and pitfalls
2. ✅ Extracts insights from "Discovered:" sections
3. ✅ Documents architectural decisions from "Decision:" sections
4. ✅ Maintains strategic documentation
5. ✅ Validates your reference doc updates

**The handoff:** Your commit message is documentation. Write it well.
```

---

## Implementation Steps

1. **Copy COMMIT_MESSAGE_TEMPLATE.md to main worktree:**
   ```bash
   cp "C:\Users\Rikke\Documents\JourneyMate\Docs\COMMIT_MESSAGE_TEMPLATE.md" \
      "C:\Users\Rikke\Documents\JourneyMate\Main\COMMIT_MESSAGE_TEMPLATE.md"
   ```

2. **Open main worktree CLAUDE.md:**
   - Location: `C:\Users\Rikke\Documents\JourneyMate\Main\CLAUDE.md`

3. **Add "Commit Messages: Documentation Context Protocol" section:**
   - Insert after "Git Workflow" section (around line 107)
   - Copy from "Section 1" above

4. **Update "Code Review Checklist":**
   - Replace existing checklist with updated version above (includes commit message item)

5. **Commit in main worktree:**
   ```bash
   cd "C:\Users\Rikke\Documents\JourneyMate\Main"
   git add CLAUDE.md COMMIT_MESSAGE_TEMPLATE.md
   git commit -m "docs: add commit message protocol for docs worktree coordination

   - Added COMMIT_MESSAGE_TEMPLATE.md with required/optional sections
   - Added 'Commit Messages: Documentation Context Protocol' to CLAUDE.md
   - Added 'Documentation Update Rules' (what can/can't update)
   - Updated Code Review Checklist to include commit message requirements

   This enables the docs worktree to extract patterns and pitfalls from
   commit messages to maintain high-level documentation (ARCHITECTURE.md,
   CLAUDE.md) while main worktree updates reference docs directly.

   Key: 'Discovered:' sections in commits become Common Pitfalls in docs.

   Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
   "
   ```

---

**After applying:** Delete this file (MAIN_WORKTREE_CLAUDE_MD_UPDATE.md) from docs worktree.
