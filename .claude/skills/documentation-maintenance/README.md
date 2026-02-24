# documentation-maintenance Skill

**Purpose:** Systematically verify, update, and maintain JourneyMate documentation after discovering fixes, patterns, or architectural changes.

## When to Use

Invoke this skill when:
- You've implemented a major fix that reveals a new pattern
- You discover a common pitfall that should be documented
- Architectural changes affect multiple documentation sections
- User says "document this" or "update docs"
- Quarterly documentation review (every 3 months)

## How to Invoke

```
/documentation-maintenance "Describe the fix/pattern/change you want to document"
```

**Example:**
```
/documentation-maintenance "Analyze the fix from commit c998826: prevent ref access in dispose() in filter overlay widget"
```

## What the Skill Does

The skill follows a 6-phase workflow:

### Phase 1: Verification
- Searches all `.md` files for mentions of the concept
- Reports how many mentions found and where
- Determines if concept is already documented

### Phase 2: Placement Decision
Uses decision matrix to recommend where to document:
- Common pitfall → ARCHITECTURE.md → Common Pitfalls
- Architectural pattern → ARCHITECTURE.md (detailed section)
- Critical product decision → CLAUDE.md → Critical Product Decisions
- API endpoint → BUILDSHIP_API_REFERENCE.md
- Provider details → PROVIDERS_REFERENCE.md
- Design token → DESIGN_SYSTEM_flutter.md

### Phase 3: Navigation Guide Impact
- Identifies which of the 12 task scenarios relate to this concept
- Determines if scenarios need updated reading lists
- Checks if line references need updating

### Phase 4: Draft Documentation Update
- Drafts proposed text following target document's format
- Uses ❌ Bad / ✅ Good pattern for Common Pitfalls
- Ensures no contradictions with existing docs

### Phase 5: Cross-Reference Validation
- Checks for duplication (concept mentioned 3+ times)
- Verifies all cross-references are valid
- Suggests consolidation if needed

### Phase 6: Commit Preparation
- Prepares commit message with format:
  ```
  docs: [what changed] based on [trigger]

  - [Primary doc]: [what was added/changed]
  - [Navigation guide impact]: [scenarios updated]
  ```

## Output Format

The skill provides a structured report:

```markdown
## Documentation Analysis: [Concept Name]

### Verification Results
[Grep results showing existing mentions]

### Recommendation
- **Action:** [Document New | Expand Existing | Already Covered]
- **Primary Location:** [File and section]
- **Category:** [Pitfall | Pattern | Decision | etc.]

### Proposed Changes
[Draft text to add/modify]

### Navigation Guide Impact
- **Affected Scenarios:** [List scenario numbers]
- **Updates Needed:** [What to change in each]

### Commit Message
[Draft commit message]
```

## Example Usage

**Scenario:** You fixed a "ref when unmounted" bug in `dispose()` method

**Invoke:**
```
/documentation-maintenance "Fix from commit abc123: save notifier in initState(), use in dispose() to prevent ref-when-unmounted error"
```

**Skill Output:**
1. Searches for existing "ref unmount" documentation
2. Finds Common Pitfall #11 covers async operations, but not dispose()
3. Recommends: Expand Pitfall #11 with "Variation B: dispose() Method"
4. Drafts the code examples (Bad vs Good)
5. Identifies affected navigation scenarios (6 and 9)
6. Proposes commit message

**You then:**
- Review the recommendation
- Approve or adjust
- Skill implements the changes
- Commits with prepared message

## Special Cases

### Case A: Fix for Existing Pitfall
If fix relates to existing pitfall, skill will propose expansion with new example.

### Case B: New Pitfall Discovery
If fix reveals NEW pitfall, skill drafts as Common Pitfall #[next number].

### Case C: Pattern Variation
If fix is variation of existing pattern, skill expands section with "Variation:" subsection.

## Testing the Skill

To test the skill works correctly:

1. **Read the skill file:**
   ```bash
   cat .claude/skills/documentation-maintenance/skill.clde
   ```

2. **Invoke with test scenario:**
   ```
   /documentation-maintenance "Test: analyze if 'ActivityScope handles engagement' is documented"
   ```

3. **Expected output:**
   - Grep results showing mentions in CLAUDE.md and ARCHITECTURE.md
   - Recommendation: "Already Covered"
   - No changes needed

## Maintenance

**Update skill when:**
- New documentation files are added to the project
- Decision matrix changes (new doc categories)
- Navigation guide expands beyond 12 scenarios
- Commit message format changes

**Skill version:** 1.0
**Created:** 2026-02-24
**Last tested:** 2026-02-24 (successfully analyzed dispose() pattern fix)
