# Commit Message Template

This template ensures commits contain enough context for documentation maintenance in the docs worktree.

---

## Standard Format

```
<type>: <short description>

Problem: [What issue/bug/need triggered this change]
Solution: [How you solved it - high-level, code shows details]
Tested: [What testing confirmed it works]

[Optional sections below - include if applicable]

Discovered: [Patterns, pitfalls, or insights learned during implementation]
Decision: [Architectural choices made and why]
Errors: [Error messages encountered before fixing]
See also: [Related files or docs that might need updates]

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

---

## Commit Types

- **feat:** New feature or significant enhancement
- **fix:** Bug fix
- **refactor:** Code restructuring without behavior change
- **docs:** Documentation-only changes (no code)
- **chore:** Maintenance (dependencies, config, tooling)
- **test:** Adding or updating tests
- **perf:** Performance improvement

---

## Section Guidance

### Required Sections

#### Problem
**What to include:**
- What user-facing issue or developer need triggered this
- What wasn't working or what gap existed
- Context: When does this occur, who's affected

**Examples:**
```
Problem: Filter overlay showed stale restaurant counts after search
results updated. Users would search "pasta", get 12 results, open
filters, but see counts from previous "pizza" search (8 results).
```

```
Problem: Need to add German translation support. Currently only
6 languages supported, but app is launching in Germany next month.
```

#### Solution
**What to include:**
- High-level approach (code shows implementation details)
- Key architectural decisions in the solution
- What pattern or technique you used

**Examples:**
```
Solution: Moved provider reads from callback to build method. FilterOverlay
now uses ref.watch() instead of capturing ref.read() values at callback
creation time. This ensures reactive updates when search results change.
```

```
Solution: Added German (de) to supported languages list, created
ui_translations entries for all 355 app keys, tested with German locale.
```

#### Tested
**What to include:**
- Manual testing steps performed
- Automated tests added/updated
- Edge cases verified
- Platforms tested (iOS/Android if relevant)

**Examples:**
```
Tested:
- Search "pasta" → open filter → counts match result count (12)
- Apply filter → close → counts update immediately
- Rapid search changes → no stale data
- Tested on iOS simulator (iPhone 15 Pro)
```

```
Tested:
- Changed device language to German → all UI text in German
- Verified all 355 keys have translations (none showing English fallback)
- Checked for text overflow in German (longer words than English)
```

---

### Optional Sections (Include When Applicable)

#### Discovered: Patterns & Pitfalls
**When to include:**
- You discovered a pattern that should be documented
- You hit a common pitfall that others might encounter
- You learned something non-obvious about the framework/libraries
- You found a best practice through trial and error

**What to include:**
- The insight or pattern discovered
- Why this matters (what breaks if you don't follow this)
- Where else this applies (generalize beyond this specific fix)

**Examples:**
```
Discovered: Riverpod pitfall - ref.read() in callbacks gives stale data
if state updates after callback creation but before invocation.

Rule: ALWAYS use ref.watch() in build methods for reactive state. Use
ref.read() ONLY for one-time reads in event handlers where you want the
exact value at that moment, not reactive updates.

This pattern applies to all bottom sheets, dialogs, and overlays that
display provider-derived state. Affects any callback passed as onPressed,
onTap, etc. that references providers.

Recommended for ARCHITECTURE.md Common Pitfalls section.
```

```
Discovered: Flutter localization delegates are REQUIRED for
Localizations.localeOf(context) to work correctly. Without delegates,
locale detection falls back to English even when device is in German.

This was causing currency filter to always show USD/GBP instead of EUR
when running on German devices. The delegates initialize the localization
system that context.locale depends on.

Applies to any feature using Localizations.localeOf() or currency/locale
detection. Should be documented as setup requirement.
```

#### Decision: Architectural Choices
**When to include:**
- You chose between multiple valid approaches
- You made a trade-off (chose simplicity over flexibility, etc.)
- You deviated from a standard pattern for good reason
- Future developers might wonder "why not do it this other way?"

**What to include:**
- What alternatives you considered
- Why you chose this approach
- Trade-offs accepted
- When this decision might need revisiting

**Examples:**
```
Decision: Used local state in FilterOverlay widget instead of creating
a FilterOverlayProvider.

Rationale: Tab selection (Cuisine/Dietary/Currency) is ephemeral UI state
that doesn't need to persist or be accessed elsewhere. Local state is
simpler and follows the "page-local UI state" pattern from ARCHITECTURE.md.

Alternative considered: NotifierProvider for tab state, rejected because
it adds complexity with no benefit (no other widgets need this state,
doesn't persist across sessions).

Revisit if: Tab selection needs to be remembered across overlay closes,
or if other features need to know current tab.
```

```
Decision: Updated BUILDSHIP_API_REFERENCE.md to document match_counts
field in searchRestaurants response. This was always returned by API
but undocumented, causing confusion about where filter counts come from.

This is a reference doc (1:1 with code/API) so updated in main worktree
rather than deferring to docs worktree. High-level patterns about how
to use match counts will be handled by docs worktree.
```

#### Errors: What Went Wrong
**When to include:**
- You hit confusing error messages during implementation
- You spent significant time debugging
- The error message wasn't helpful/misleading
- Others might hit the same error

**What to include:**
- Actual error message (copy-paste)
- What you tried that didn't work
- What finally fixed it
- How to recognize and avoid this error

**Examples:**
```
Errors: Initially got "Bad state: Cannot read providers inside callbacks"
when calling ref.read() in _openFilterOverlay callback.

Tried: Moving ref.read() to different locations in callback, wrapping in
Future.microtask (didn't help).

Fixed by: Reading the provider inside the overlay widget's build method
instead of passing the value through the callback. The error message was
misleading - problem wasn't reading in callback, but reading a stale value.

Recognize: If you see stale data after state updates, check if you're
capturing provider values in callback closures. Move reads inside build.
```

#### See Also: Cross-References
**When to include:**
- You updated reference documentation (API contracts, provider lists)
- You suspect high-level docs (ARCHITECTURE.md, CLAUDE.md) need updates
- Your change relates to existing documentation sections
- Your change affects multiple areas of the codebase

**What to include:**
- Files you modified (with line numbers if helpful)
- Documentation that might need updates (flag for docs worktree)
- Related patterns or features affected

**Examples:**
```
See also:
- Updated: _reference/BUILDSHIP_API_REFERENCE.md (searchRestaurants response)
- Review needed: ARCHITECTURE.md "State Management" section (add note about
  ref.read() staleness pitfall?)
- Related: lib/widgets/filter_overlay.dart:142-167 (the callback pattern)
- Similar pattern: lib/pages/restaurant_detail_page.dart uses same approach
```

---

## Examples: Real Commits

### Example 1: Bug Fix with Pattern Discovery

```
fix: restore state reads in _openFilterOverlay and improve docs

Problem: FilterOverlay showed stale restaurant counts after search
results updated. Root cause: ref.read() in _openFilterOverlay callback
captured state at callback creation time, not invocation time. User
would search "pasta" (12 results), then "pizza" (8 results), open
filter overlay, see counts from "pasta" (stale data).

Solution: Moved provider reads from callback parameters to inside
FilterOverlay widget's build method. Changed pattern from:
  onPressed: () => _openFilterOverlay(context, ref.read(matchCountsProvider))
to:
  onPressed: () => _openFilterOverlay(context)

FilterOverlay now uses ref.watch() in build to reactively track state.

Tested:
- Search "pasta" → open filter → counts show 12 (correct)
- Apply filter → close → reopen → counts update immediately
- Rapid searches → no stale data at any point
- iOS simulator (iPhone 15 Pro, iOS 17.2)

Discovered: Major Riverpod pitfall - ref.read() in callbacks gives
stale data if state updates after callback creation. This is because
callbacks capture the value at creation time (closure), not invocation.

Rule: ALWAYS use ref.watch() in build methods for reactive state reads.
Use ref.read() ONLY for one-time actions in event handlers (like
triggering navigation, analytics) where you want the value at that exact
moment, not reactive tracking.

This applies to ALL bottom sheets, dialogs, overlays, and any callback
that displays provider-derived state. Common locations: onPressed, onTap,
showModalBottomSheet callbacks.

Strongly recommend documenting as Common Pitfall in ARCHITECTURE.md -
this is a framework-level misunderstanding that will recur.

Decision: Updated BUILDSHIP_API_REFERENCE.md to clarify searchRestaurants
returns match_counts object with filter counts. This was undocumented
API behavior. Updated reference doc in main worktree since it's 1:1 with
API contract (not a pattern/architecture insight).

See also:
- Updated: _reference/BUILDSHIP_API_REFERENCE.md (searchRestaurants response format)
- Review needed: ARCHITECTURE.md "State Management > Common Pitfalls" (add ref.read() staleness)
- Files: lib/pages/search_results_page.dart:287-312
- Pattern used in: lib/widgets/filter_overlay.dart:142-167

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

### Example 2: Feature with Architecture Decision

```
feat: implement filter greying for unavailable options

Problem: Users were confused when selecting filters that returned zero
results. No visual indication that a filter option was unavailable for
current search. Example: Searching "sushi" and selecting "Italian"
cuisine returned empty list with no explanation.

Solution: Added computed getter `disabledCuisineIds` that checks
match_counts from search response. Filter buttons now show greyed
appearance (50% opacity) when count is zero. Users can still tap to
select (allowing multi-filter exploration), but visual feedback shows
the option won't narrow results.

Implemented as computed getter in search results provider rather than
separate provider to avoid state synchronization issues.

Tested:
- Search "pasta" → Italian shows count, Japanese greyed (0 matches)
- Multi-select: Italian + Japanese still allows selection, shows 0 results
- Search "sushi" → Japanese shows count, Italian greyed
- Filter counts update immediately on search change
- No flash of wrong state on initial load
- iOS simulator + Android emulator

Decision: Used computed getter pattern instead of separate
disabledOptionsProvider. This ensures disabled state is always in sync
with search results (single source of truth).

Alternative considered: Separate NotifierProvider for disabled state,
rejected because it requires manual synchronization and can get out of
sync with match_counts. Computed getter is simpler and eliminates
synchronization bugs.

Trade-off: Computed getter recalculates on every build, but performance
impact is negligible (filtering ~10 cuisine IDs). Benefit of guaranteed
correctness outweighs micro-optimization.

Revisit if: Filter options grow to 100+ items, then consider memoization.

Discovered: Pattern for derived state - when state is computed from
existing provider data, use computed getters in the same provider rather
than creating separate providers. This follows single-source-of-truth
principle and eliminates sync bugs.

Applies to any "derived state" scenario: disabled buttons, visibility
toggles, filtered lists. If the logic is "if X then Y", make Y a getter
that reads X, not a separate provider.

See also:
- Review needed: ARCHITECTURE.md "State Management > When to Use What"
  (add guidance on computed getters for derived state)
- Pattern: lib/providers/search_results_provider.dart:156-162
- Similar pattern could apply to: Restaurant list filtering, map markers

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

### Example 3: Documentation Update (Docs Worktree)

```
docs: add Common Pitfall #13 from commit bd3f4f8

- ARCHITECTURE.md: added ref.read() staleness pitfall with examples
- NAVIGATION_GUIDE.md: updated scenario 6 (Search/Filter) with new warning
- Cross-references validated

Problem from original commit: FilterOverlay showed stale data because
ref.read() in callbacks captured state at creation time, causing confusion
about Riverpod behavior.

Documentation added:
- Common Pitfall #13: "ref.read() in Callbacks Gives Stale Data"
- When it happens: Callbacks passed to onPressed, showModalBottomSheet
- How to fix: Move provider reads inside build method, use ref.watch()
- Where it applies: All bottom sheets, dialogs, overlays with provider state
- Code example: Before/after pattern from SearchResultsPage

Updated NAVIGATION_GUIDE.md scenario 6 to include this pitfall in reading
list (now mentions: "read Common Pitfall #13 about ref.read() staleness").

Commit reviewed: bd3f4f8 (fix: restore state reads in _openFilterOverlay and improve docs)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

---

## Tips for Good Commit Messages

### Do:
✅ Write for someone who hasn't seen the code or issue
✅ Explain why, not just what (code shows what)
✅ Include error messages you encountered (copy-paste)
✅ Mention patterns that could apply elsewhere
✅ Flag docs that might need updates
✅ Be specific about testing ("tested X, Y, Z")

### Don't:
❌ Write terse messages ("fix bug", "update component")
❌ Assume reader knows the context
❌ Skip the "Discovered:" section when you learned something
❌ Forget to mention doc updates you made
❌ Leave out error messages (they help future debugging)

---

## Workflow: Main Worktree vs Docs Worktree

### Main Worktree (Code Development)

**When committing code:**
1. Use this template
2. Focus on "Discovered:" and "Decision:" sections (feeds docs worktree)
3. Update reference docs directly (API contracts, provider lists)
4. Flag high-level docs for review ("See also: ARCHITECTURE.md needs update?")

**Can update:**
- `_reference/BUILDSHIP_API_REFERENCE.md` (API contracts)
- `_reference/PROVIDERS_REFERENCE.md` (provider catalog)
- `DESIGN_SYSTEM_flutter.md` (design tokens)
- Inline code comments

**Cannot update:**
- `CLAUDE.md` (strategic instructions - docs worktree only)
- `ARCHITECTURE.md` (pattern documentation - docs worktree only)
- `NAVIGATION_GUIDE.md` (task scenarios - docs worktree only)

### Docs Worktree (Documentation Maintenance)

**When committing documentation:**
1. Reference the commit hash being documented
2. Use simplified format (no "Problem/Solution/Tested" - that's in original commit)
3. Focus on what docs were updated and why
4. Cross-reference original commit message

**Format for docs commits:**
```
docs: <what was documented> from commit <hash>

- [File1]: [what changed]
- [File2]: [what changed]
- Cross-references validated

Commit reviewed: <hash> ([original commit message summary])

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

---

## Questions?

- **"How much detail?"** → Enough that someone unfamiliar with the code can understand the change
- **"When to include Discovered?"** → Whenever you learned something non-obvious or hit a common pitfall
- **"When to include Decision?"** → When you chose between valid alternatives or deviated from patterns
- **"What if commit is trivial?"** → Still include Problem/Solution/Tested, but can be brief

**The commit message is documentation.** Future developers (and AI agents) read commits to understand why code looks the way it does.

---

**Last Updated:** March 2026
