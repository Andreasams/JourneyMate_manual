# documentation-maintenance Skill: TDD Testing

This document contains the comprehensive Test-Driven Development (TDD) test suite for the documentation-maintenance skill.

## TDD Methodology

This skill was developed using **Test-Driven Development (TDD)** with the RED-GREEN-REFACTOR cycle:

### TDD Cycle

1. **RED:** Write test scenario describing desired behavior (skill fails test)
2. **GREEN:** Implement skill workflow to pass test (skill produces expected output)
3. **REFACTOR:** Improve skill clarity and efficiency without changing behavior

---

## Test Scenarios

### Baseline Scenarios (Core Functionality)

#### Scenario 1: Concept Already Documented

**Invoke:**
```bash
/documentation-maintenance "Test: analyze if 'ActivityScope handles engagement' is documented"
```

**Expected Output:**
```markdown
## Documentation Analysis: ActivityScope Engagement Handling

### Verification Results
- Found 6 mentions across 3 files:
  - CLAUDE.md (lines 79, 104)
  - ARCHITECTURE.md (lines 729-803, 951-980)
  - journey_mate/lib/widgets/activity_scope.dart (implementation)

### Recommendation
- **Action:** Already Covered
- **Primary Location:** ARCHITECTURE.md → Analytics Architecture (lines 729-803)
- **Category:** Architectural Pattern

### Proposed Changes
None required. Concept is fully documented with code examples and navigation guide references.

### Navigation Guide Impact
- **Affected Scenarios:** None
- **Updates Needed:** None

### Commit Message
No commit needed.
```

**Pass Criteria:** Skill reports "Already Covered" with no changes.

---

#### Scenario 2: New Pitfall Discovery

**Invoke:**
```bash
/documentation-maintenance "Fix from commit xyz789: prevent double context.go() calls in navigation handlers"
```

**Expected Output:**
```markdown
## Documentation Analysis: Double Navigation Prevention

### Verification Results
- Found 0 mentions of "double context.go()" pattern
- Found 3 mentions of navigation patterns (but none about duplicate calls)

### Recommendation
- **Action:** Document New
- **Primary Location:** ARCHITECTURE.md → Common Pitfalls (new #12)
- **Category:** Common Pitfall

### Proposed Changes

**Common Pitfall #12: Double Navigation (context.go() Called Twice)**

❌ **Bad: Multiple navigation calls**
```dart
void _handleButtonPress() {
  context.go('/pageA');
  // ... more logic
  context.go('/pageB'); // ERROR: Second navigation cancels first
}
```

✅ **Good: Single navigation call**
```dart
void _handleButtonPress() {
  // ... all logic first
  context.go('/pageB'); // Only one navigation at end
}
```

**Why:** Multiple `context.go()` calls in sequence cause race conditions. Only the last call takes effect.

**Fix:** Ensure navigation happens once, at the end of handler logic.

**Reference:** Commit xyz789

### Navigation Guide Impact
- **Affected Scenarios:** 1 (Adding/Modifying Pages)
- **Updates Needed:** Add to "Critical warnings" list

### Commit Message
docs: add Common Pitfall #12 for double navigation prevention

- ARCHITECTURE.md: New pitfall with ❌/✅ examples (commit xyz789)
- CLAUDE.md Navigation Guide: Updated Scenario 1 warnings
- Code Review Checklist: Add navigation check
```

**Pass Criteria:** Skill recommends new Common Pitfall #12 with ❌/✅ examples and commit message.

---

#### Scenario 3: Expand Existing Pattern

**Invoke:**
```bash
/documentation-maintenance "Pattern variation: pre-loading with error handling using try-catch in _preLoad() functions"
```

**Expected Output:**
```markdown
## Documentation Analysis: Pre-Loading with Error Handling

### Verification Results
- Found 12 mentions of "pre-loading" pattern:
  - ARCHITECTURE.md → Pre-Loading Architecture (lines 520-597)
  - welcome_page.dart, settings_page.dart (implementations)

### Recommendation
- **Action:** Expand Existing
- **Primary Location:** ARCHITECTURE.md → Pre-Loading Architecture (lines 520-597)
- **Category:** Pattern Variation

### Proposed Changes

Add "Variation: Error Handling" subsection at line 598:

**Variation: Error Handling in Pre-Loading**

If API calls can fail during pre-load, wrap in try-catch to prevent silent failures:

```dart
Future<void> _preLoad() async {
  try {
    await _loadTranslations();
    await _loadSearchResults();
  } catch (e) {
    // Log error, show user-friendly message, or use cached data
    debugPrint('Pre-load failed: $e');
  }
}
```

**When to use:** API calls without guaranteed success (external APIs, network-dependent operations).

**When to skip:** Internal state initialization that cannot fail.

### Navigation Guide Impact
- **Affected Scenarios:** 8 (Fixing State Persistence), 9 (Search/Filter Features)
- **Updates Needed:** Add line reference to error handling variation

### Commit Message
docs: expand pre-loading pattern with error handling variation

- ARCHITECTURE.md: Add "Variation: Error Handling" subsection (line 598)
- Navigation Guide: Updated scenarios 8 and 9 with new line ref
```

**Pass Criteria:** Skill recommends "Variation:" subsection added to existing pattern section.

---

### Pressure Scenarios (Edge Cases)

#### Pressure 1: Ambiguous Concept

**Invoke:**
```bash
/documentation-maintenance "API response caching improves performance"
```

**Expected Output:**
```markdown
## Documentation Analysis: API Response Caching

### Verification Results
- Found 2 mentions of "caching":
  - Translation caching in ARCHITECTURE.md (line 599)
  - Exchange rate caching in localizationProvider (PROVIDERS_REFERENCE.md)

### Recommendation
- **Action:** Clarify Before Documenting
- **Ambiguity:** Concept could apply to:
  1. API Service Pattern (how to implement caching in ApiService)
  2. Performance Best Practices (architectural decision to use caching)
  3. BuildShip API behavior (does BuildShip cache responses?)

**Question for User:** Which aspect do you want to document?
- [ ] How to implement response caching in Flutter app
- [ ] Why caching is used (architectural decision)
- [ ] BuildShip API caching behavior

Please clarify, then re-invoke with more specific description.

### Proposed Changes
None (awaiting clarification)

### Navigation Guide Impact
None (awaiting clarification)

### Commit Message
None (awaiting clarification)
```

**Pass Criteria:** Skill asks for clarification with specific options, does not guess.

---

#### Pressure 2: Multi-File Impact

**Invoke:**
```bash
/documentation-maintenance "New requirement from commit def456: all API calls must include user_id header for analytics tracking"
```

**Expected Output:**
```markdown
## Documentation Analysis: User ID Header Requirement

### Verification Results
- Found 0 mentions of "user_id header" requirement
- Found 13 API call examples across docs (none include user_id header)

### Recommendation
- **Action:** Document New (Multi-File Cascade)
- **Primary Location:** BUILDSHIP_API_REFERENCE.md → All 12 endpoints
- **Secondary Locations:** ARCHITECTURE.md → API Service Pattern

### Proposed Changes

**File 1: BUILDSHIP_API_REFERENCE.md**
Add to each endpoint's "Request Headers" section:
```
user_id: String (required) - Anonymous user identifier for analytics tracking
```

**File 2: ARCHITECTURE.md → API Service Pattern (line 461)**
Add after line 480:
```dart
// All requests include user_id header for analytics
headers['user_id'] = await _getUserId();
```

**File 3: CLAUDE.md → Critical Product Decisions**
Add decision #13:
```
13. **User ID header required for all API calls** — All BuildShip API calls include anonymous user_id for analytics tracking. Required since commit def456.
```

**File 4: CLAUDE.md → Code Review Checklist**
Add to "API Call Checklist":
- [ ] API call includes user_id header

**File 5: journey_mate/lib/services/api_service.dart**
(Implementation - not documentation, but note for developer)

### Navigation Guide Impact
- **Affected Scenarios:** 3 (Integrating with BuildShip API)
- **Updates Needed:** Add "user_id header" to critical warnings

### Commit Message
docs: add user_id header requirement for all API calls (commit def456)

- BUILDSHIP_API_REFERENCE.md: Added user_id to all 12 endpoint headers
- ARCHITECTURE.md: Updated API Service Pattern example (line 480)
- CLAUDE.md: Added Critical Product Decision #13
- CLAUDE.md: Updated Code Review Checklist
- Navigation Guide: Updated Scenario 3 warnings
```

**Pass Criteria:** Skill identifies all 5 affected files and proposes coordinated updates.

---

#### Pressure 3: Duplicate Detection

**Invoke:**
```bash
/documentation-maintenance "Quarterly review: check if 'self-contained widget pattern' is duplicated across docs"
```

**Expected Output:**
```markdown
## Documentation Analysis: Self-Contained Widget Pattern Duplication

### Verification Results
- Found 8 mentions of "self-contained widget" pattern:
  1. ARCHITECTURE.md → Widget Patterns (lines 265-310) — **PRIMARY** (full explanation)
  2. ARCHITECTURE.md → Common Pitfall #8 (lines 937-949) — Example of violation
  3. CLAUDE.md → Task-Based Navigation (Scenario 2, lines 45-68) — Reference in reading list
  4. CLAUDE.md → Code Patterns (line 67) — Brief mention
  5. CLAUDE.md → Code Review Checklist (line 97) — Checklist item
  6. CONTRIBUTING.md → Widget Guidelines (line 123) — Brief summary
  7. README.md → Quick Start (line 34) — Brief mention
  8. welcome_page.dart comment (line 12) — Code comment

### Recommendation
- **Action:** Consolidate (Excessive Duplication)
- **Primary Location:** ARCHITECTURE.md → Widget Patterns (lines 265-310) — **Keep full explanation**
- **Secondary Locations to Keep:**
  - ARCHITECTURE.md → Common Pitfall #8 (keep example, add link to primary)
  - CLAUDE.md → Navigation Guide Scenario 2 (keep in reading list, it's critical)
- **Locations to Reduce:**
  - CLAUDE.md → Code Patterns: Replace with "See ARCHITECTURE.md → Widget Patterns"
  - CLAUDE.md → Code Review Checklist: Keep brief item, add line ref to primary
  - CONTRIBUTING.md: Replace with link to ARCHITECTURE.md
  - README.md: Replace with link to ARCHITECTURE.md

### Proposed Changes

**CLAUDE.md (line 67):**
```diff
- **Self-contained widgets:** Read providers/context internally (NO infrastructure props)
+ **Self-contained widgets:** See ARCHITECTURE.md → Widget Patterns (lines 265-310)
```

**CLAUDE.md (line 97):**
```diff
- [ ] Widgets are self-contained (no infrastructure props)
+ [ ] Widgets are self-contained (ARCHITECTURE.md:265-310) (no infrastructure props)
```

**CONTRIBUTING.md (line 123):**
```diff
- Widgets should be self-contained: read language/translations from context, don't accept as props.
+ Widgets should be self-contained. See ARCHITECTURE.md → Widget Patterns (lines 265-310).
```

**README.md (line 34):**
```diff
- Follow self-contained widget pattern.
+ Follow self-contained widget pattern (see ARCHITECTURE.md:265-310).
```

### Navigation Guide Impact
- **Affected Scenarios:** None (Scenario 2 retains full reference)
- **Updates Needed:** None

### Commit Message
docs: consolidate self-contained widget pattern references

- CLAUDE.md: Replaced 2 full explanations with links to ARCHITECTURE.md
- CONTRIBUTING.md: Replaced explanation with link to ARCHITECTURE.md
- README.md: Replaced mention with link to ARCHITECTURE.md
- Result: 8 mentions → 3 (1 primary + 2 critical links)
```

**Pass Criteria:** Skill detects 8 mentions, recommends reducing to 3, provides specific diff changes.

---

#### Pressure 4: Line Reference Shift

**Invoke:**
```bash
/documentation-maintenance "Added new 50-line section at ARCHITECTURE.md line 300. Calculate line reference shifts for navigation guide."
```

**Expected Output:**
```markdown
## Documentation Analysis: Line Reference Shift (ARCHITECTURE.md +50 lines at line 300)

### Verification Results
- ARCHITECTURE.md now 50 lines longer (new section at line 300)
- Navigation Guide has 18 line references to ARCHITECTURE.md
- 12 references are AFTER line 300 (require +50 offset)
- 6 references are BEFORE line 300 (no change)

### Recommendation
- **Action:** Update Line References
- **Primary Location:** CLAUDE.md → Task-Based Navigation Guide
- **Category:** Maintenance

### Proposed Changes

**Affected Line References (12 total):**

**Scenario 1: Adding or Modifying a Page**
- Old: `lines 311-376`
- New: `lines 361-426` (+50)

**Scenario 2: Creating a New Shared Widget**
- Old: `lines 377-410`
- New: `lines 427-460` (+50)

**Scenario 3: Integrating with BuildShip API**
- Old: `lines 461-517`
- New: `lines 511-567` (+50)

**Scenario 5: Modifying State Management**
- Old: `lines 520-597`
- New: `lines 570-647` (+50)

**Scenario 6: Implementing a Form**
- Old: `lines 937-949`
- New: `lines 987-999` (+50)

**Scenario 8: Fixing State Persistence**
- Old: `lines 982-1012`
- New: `lines 1032-1062` (+50)

**Scenario 9: Implementing Search/Filter**
- Old: `lines 998-1080`
- New: `lines 1048-1130` (+50)

**Scenario 11: Analytics & Engagement**
- Old: `lines 729-803`
- New: `lines 779-853` (+50)
- Old: `lines 951-980`
- New: `lines 1001-1030` (+50)

**Bulk Find/Replace Commands:**
```bash
# Scenario 1
sed -i 's/lines 311-376/lines 361-426/g' CLAUDE.md

# Scenario 2
sed -i 's/lines 377-410/lines 427-460/g' CLAUDE.md

# ... (10 more commands)
```

### Navigation Guide Impact
- **Affected Scenarios:** 8 of 12 scenarios (scenarios 1, 2, 3, 5, 6, 8, 9, 11)
- **Updates Needed:** 18 line reference updates

### Commit Message
docs: update navigation guide line references after ARCHITECTURE.md expansion

- CLAUDE.md: Updated 18 line references (+50 offset for lines after 300)
- Affected scenarios: 1, 2, 3, 5, 6, 8, 9, 11
- Trigger: New 50-line section added at ARCHITECTURE.md line 300
```

**Pass Criteria:** Skill calculates correct offsets, lists all affected scenarios, provides bulk find/replace commands.

---

## Running Tests

To verify the skill works correctly, run each test scenario and compare actual output to expected output.

### Baseline Tests (Must Pass)

1. **Scenario 1:** Already documented concept
   - **Status:** ☐ Pass / ☐ Fail
   - **Notes:**

2. **Scenario 2:** New pitfall discovery
   - **Status:** ☐ Pass / ☐ Fail
   - **Notes:**

3. **Scenario 3:** Expand existing pattern
   - **Status:** ☐ Pass / ☐ Fail
   - **Notes:**

### Pressure Tests (Edge Cases)

4. **Pressure 1:** Ambiguous concept (asks for clarification)
   - **Status:** ☐ Pass / ☐ Fail
   - **Notes:**

5. **Pressure 2:** Multi-file impact (identifies all files)
   - **Status:** ☐ Pass / ☐ Fail
   - **Notes:**

6. **Pressure 3:** Duplicate detection (finds 3+ mentions)
   - **Status:** ☐ Pass / ☐ Fail
   - **Notes:**

7. **Pressure 4:** Line reference shift (calculates offsets)
   - **Status:** ☐ Pass / ☐ Fail
   - **Notes:**

### Test Results Summary

**Date:** _______________
**Tester:** _______________
**Skill Version:** _______________

**Pass Rate:** ___ / 7 tests (___%)

**Issues Found:**
-

**Recommended Actions:**
-

---

## Test Maintenance

**Update tests when:**
- Documentation structure changes (new files, renamed sections)
- Common Pitfall numbering changes (currently at #11)
- Navigation Guide expands (currently 12 scenarios)
- Decision matrix changes (new document categories)

**Last Test Run:** 2026-02-24
**Test Results:** Baseline test passed (Scenario 1: ActivityScope already documented)
