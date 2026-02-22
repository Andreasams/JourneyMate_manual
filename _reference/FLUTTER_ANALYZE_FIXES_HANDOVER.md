# Flutter Analyze Issues - Session Handover Document

**Created:** 2026-02-22
**For:** Next session to fix all 20 flutter analyze issues
**Working Directory:** `C:\Users\Rikke\Documents\JourneyMate-Organized`

---

## ⚠️ CRITICAL: DO NOT START FIXING UNTIL YOU COMPLETE THE INVESTIGATION PHASE

This document requires you to **investigate and understand each error in context** before making any fixes. Rushing to fix without understanding could break functionality.

---

## Session Workflow (MANDATORY)

### Phase 0: Setup (Before Any Work)
1. Read this entire handover document
2. Read `CLAUDE.md` completely
3. Read `_reference/SESSION_STATUS.md`
4. Read `_reference/PHASE7_LESSONS_LEARNED.md`
5. Confirm current flutter analyze output:
   ```bash
   cd journey_mate
   flutter analyze > analyze_before.txt
   ```

### Phase 1: Investigation (REQUIRED - Do NOT skip)
For each error/warning/info issue:
1. ✅ Read the file and understand the surrounding code (±20 lines)
2. ✅ Understand what functionality this code provides
3. ✅ Identify what other code depends on this
4. ✅ Check if fixing this could break anything else
5. ✅ Read related documentation (MASTER_README, BUNDLE.md, etc.)
6. ✅ Document your findings in investigation notes

### Phase 2: Planning (REQUIRED - Do NOT skip)
1. ✅ For each issue, write a fix strategy with:
   - Exact changes to make
   - Why this fix is safe
   - What could go wrong
   - How to verify it works
2. ✅ Group related fixes together
3. ✅ Identify any high-risk fixes that need extra testing

### Phase 3: Implementation (Only after Phases 1-2 complete)
1. Fix issues in priority order (errors → warnings → info)
2. Run `flutter analyze` after EACH fix
3. If analyze shows new issues, STOP and investigate
4. Document any deviations from the plan

### Phase 4: Verification (REQUIRED)
1. Run `flutter analyze` - must return "No issues found!"
2. Verify app still builds: `flutter build apk --debug`
3. Check that no new issues were introduced
4. Update handover document with "COMPLETED" status

### Phase 5: Handover (REQUIRED)
1. Update `_reference/SESSION_STATUS.md`
2. Commit all changes with descriptive message
3. Document any issues that couldn't be fixed and why

---

## Issue Inventory (20 Total)

### Summary by Severity

| Severity | Count | Files Affected | Priority |
|----------|-------|----------------|----------|
| ERROR | 7 | filter_overlay_widget.dart | 🔴 CRITICAL |
| WARNING | 5 | filter_overlay_widget.dart | 🟡 HIGH |
| INFO | 8 | 4 files | 🔵 MEDIUM |

### Summary by File

| File | Issues | Complexity | Risk Level |
|------|--------|------------|------------|
| `filter_overlay_widget.dart` | 14 | ⭐⭐⭐⭐⭐ Extreme (1,715 lines) | 🔴 HIGH |
| `search_page.dart` | 1 | ⭐⭐⭐⭐ High | 🟡 MEDIUM |
| `item_bottom_sheet.dart` | 2 | ⭐⭐⭐⭐⭐ Extreme (1,780 lines) | 🟢 LOW (acceptable) |
| `sort_bottom_sheet.dart` | 1 | ⭐⭐ Low | 🟢 LOW |

---

## CRITICAL ERRORS (7) - Priority 1

### 🔴 ERROR 1-4: Missing Required Arguments - filter_overlay_widget.dart:800

**Error Messages:**
```
error - The named parameter 'deviceId' is required, but there's no corresponding argument - lib\widgets\shared\filter_overlay_widget.dart:800:39
error - The named parameter 'sessionId' is required, but there's no corresponding argument - lib\widgets\shared\filter_overlay_widget.dart:800:39
error - The named parameter 'timestamp' is required, but there's no corresponding argument - lib\widgets\shared\filter_overlay_widget.dart:800:39
error - The named parameter 'userId' is required, but there's no corresponding argument - lib\widgets\shared\filter_overlay_widget.dart:800:39
```

#### Investigation Required (DO THIS FIRST)

**1. Understand the Context:**
- [ ] Read `filter_overlay_widget.dart` lines 780-820 (±20 lines around error)
- [ ] What is this code doing? (Likely: analytics tracking when filters change)
- [ ] When is this code called? (Likely: on filter selection/deselection)
- [ ] What functionality would break if this fails?

**2. Check the API Signature:**
- [ ] Read `journey_mate/lib/services/api_service.dart`
- [ ] Find the `postAnalytics()` method signature
- [ ] Document ALL required parameters and their types
- [ ] Check if parameters changed recently (git log api_service.dart)

**3. Check Other Usages:**
```bash
# Find all postAnalytics calls in the codebase
cd journey_mate
grep -r "postAnalytics" lib/ --include="*.dart"
```
- [ ] How do other widgets call postAnalytics?
- [ ] Are they all using the same pattern?
- [ ] What values do they pass for deviceId/sessionId/userId/timestamp?

**4. Understand the Impact:**
- [ ] Is this analytics tracking or critical functionality?
- [ ] What happens if analytics fails? (Fire-and-forget? Blocking?)
- [ ] Are there any .catchError handlers?

#### Fix Strategy (Complete Investigation First)

**Expected Pattern (verify before implementing):**
```dart
// Current (BROKEN):
ApiService.instance.postAnalytics(
  eventType: 'filter_change',
  eventData: { ... },
);

// Expected Fix (VERIFY THIS IS CORRECT):
ApiService.instance.postAnalytics(
  eventType: 'filter_change',
  deviceId: '', // ApiService auto-fills from analyticsProvider
  sessionId: '', // ApiService auto-fills from analyticsProvider
  userId: '', // ApiService auto-fills from analyticsProvider
  timestamp: DateTime.now().toIso8601String(),
  eventData: { ... },
);
```

**Verification Steps:**
1. After fix, run `flutter analyze` - error should be gone
2. Check if similar pattern is used in other widgets (search for "postAnalytics")
3. Verify analytics still fires (check logs or add debug print)

**Risk Assessment:**
- **Risk Level:** 🟡 MEDIUM
- **Why:** Analytics is fire-and-forget, unlikely to break core functionality
- **What could go wrong:** Analytics might not track filter changes
- **How to detect:** Check analytics logs after fix

---

### 🔴 ERROR 5: Missing cityId - filter_overlay_widget.dart:818

**Error Message:**
```
error - The named parameter 'cityId' is required, but there's no corresponding argument - lib\widgets\shared\filter_overlay_widget.dart:818:48
```

#### Investigation Required (DO THIS FIRST)

**1. Understand the Context:**
- [ ] Read `filter_overlay_widget.dart` lines 800-840 (±20 lines around error)
- [ ] What API call is this? (Search? Filter fetch?)
- [ ] Why is cityId required?
- [ ] What happens if wrong cityId is used?

**2. Check the API:**
- [ ] Read `journey_mate/lib/services/api_service.dart`
- [ ] Find the API method being called at line 818
- [ ] Confirm cityId is required
- [ ] Check what cityId should be used (always 17 for Copenhagen per CLAUDE.md)

**3. Check Constants:**
- [ ] Verify `AppConstants.kDefaultCityId` exists
- [ ] Read `journey_mate/lib/theme/app_constants.dart`
- [ ] Confirm value is 17

**4. Check Other Usages:**
```bash
# Find all API calls that use cityId
cd journey_mate
grep -r "cityId:" lib/ --include="*.dart"
```
- [ ] How do other widgets pass cityId?
- [ ] Is it always AppConstants.kDefaultCityId?

#### Fix Strategy (Complete Investigation First)

**Expected Fix:**
```dart
// Add cityId parameter
cityId: AppConstants.kDefaultCityId, // 17 (Copenhagen)
```

**Verification Steps:**
1. After fix, run `flutter analyze` - error should be gone
2. Verify AppConstants is imported
3. Check that API call works with cityId

**Risk Assessment:**
- **Risk Level:** 🟢 LOW
- **Why:** Simple parameter addition, well-defined constant
- **What could go wrong:** Import missing, wrong city returned
- **How to detect:** API should return Copenhagen data

---

### 🔴 ERROR 6-7: Undefined Named Parameters - filter_overlay_widget.dart:823-824

**Error Messages:**
```
error - The named parameter 'hasTrainStation' isn't defined - lib\widgets\shared\filter_overlay_widget.dart:823:9
error - The named parameter 'trainStationId' isn't defined - lib\widgets\shared\filter_overlay_widget.dart:824:9
```

#### Investigation Required (DO THIS FIRST) ⚠️ HIGH RISK

**1. Understand the Context:**
- [ ] Read `filter_overlay_widget.dart` lines 805-845 (±20 lines around errors)
- [ ] What API call is this?
- [ ] Why were hasTrainStation/trainStationId being passed?
- [ ] What functionality depends on train station filtering?

**2. Check API Signature Changes:**
- [ ] Read `journey_mate/lib/services/api_service.dart`
- [ ] Find the API method being called at lines 823-824
- [ ] Document the CURRENT parameter list
- [ ] Check git history: `git log -p -- journey_mate/lib/services/api_service.dart`
- [ ] When did the API signature change?
- [ ] Why did it change?

**3. Check BUILDSHIP_API_REFERENCE.md:**
- [ ] Read `_reference/BUILDSHIP_API_REFERENCE.md`
- [ ] Find the relevant endpoint (likely SEARCH or GET_FILTERS)
- [ ] What are the current accepted parameters?
- [ ] How should train station filtering work now?

**4. Check FlutterFlow Source:**
- [ ] Read `_flutterflow_export/lib/custom_code/widgets/filter_overlay_widget.dart`
- [ ] How does FlutterFlow handle train station filtering?
- [ ] Are these parameters still used there?

**5. Understand User Impact:**
- [ ] What happens when user selects a train station filter?
- [ ] Will train station filtering break if we remove these parameters?
- [ ] Is there an alternative way to pass this data?

#### Fix Strategy Options (Choose After Investigation)

**Option A: Remove Parameters (if API no longer accepts them)**
```dart
// Remove hasTrainStation and trainStationId entirely
// Verify train station filtering still works through other mechanism
```

**Option B: Rename Parameters (if API renamed them)**
```dart
// Example: hasTrainStation → includeTrainStation
// Verify new parameter names from API docs
```

**Option C: Move to eventData (if API changed structure)**
```dart
// Move to eventData map instead of top-level parameters
eventData: {
  'hasTrainStation': hasTrainStation,
  'trainStationId': trainStationId,
  // ...
}
```

**Verification Steps:**
1. After fix, run `flutter analyze` - errors should be gone
2. **CRITICAL:** Test train station filtering manually
3. Check API request logs to verify correct data sent
4. Verify search results change when train station selected

**Risk Assessment:**
- **Risk Level:** 🔴 HIGH
- **Why:** Train station filtering is core functionality (per BUILDSHIP_API_REFERENCE.md)
- **What could go wrong:** Train station filtering breaks completely
- **How to detect:** Test manually - select train station, verify results filtered

---

## WARNINGS (5) - Priority 2

### 🟡 WARNING 1-3: Unused Imports - filter_overlay_widget.dart:7,8,10

**Warning Messages:**
```
warning - Unused import: '../../theme/app_spacing.dart' - line 7
warning - Unused import: '../../theme/app_radius.dart' - line 8
warning - Unused import: '../../providers/filter_providers.dart' - line 10
```

#### Investigation Required (DO THIS FIRST)

**1. Verify Actually Unused:**
- [ ] Read `filter_overlay_widget.dart` lines 1-50 (imports section)
- [ ] Search file for "AppSpacing" usage
- [ ] Search file for "AppRadius" usage
- [ ] Search file for "filterProvider" usage
- [ ] Could these be used in commented-out code?

**2. Understand Why They're There:**
- [ ] Check git history: when were these imports added?
- [ ] Were they used in previous versions?
- [ ] Could they be needed for future planned work?

**3. Check Dependencies:**
- [ ] If we remove these, could it break anything?
- [ ] Are they re-exported elsewhere?

#### Fix Strategy (Complete Investigation First)

**Simple Fix (if truly unused):**
```dart
// Remove the import lines entirely
// - import '../../theme/app_spacing.dart';
// - import '../../theme/app_radius.dart';
// - import '../../providers/filter_providers.dart';
```

**Verification Steps:**
1. After removal, run `flutter analyze` - warnings should be gone
2. Run `flutter build` - should still compile
3. No functionality should change

**Risk Assessment:**
- **Risk Level:** 🟢 LOW
- **Why:** Dart analyzer is accurate about unused imports
- **What could go wrong:** Almost nothing (compile would fail if actually needed)

---

### 🟡 WARNING 4-5: Unused Fields - filter_overlay_widget.dart:106,158

**Warning Messages:**
```
warning - The value of the field '_hasReceivedNewCount' isn't used - line 106
warning - The value of the field '_orangeAccentBarSpacing' isn't used - line 158
```

#### Investigation Required (DO THIS FIRST) ⚠️ MEDIUM RISK

**1. Understand the Fields:**
- [ ] Read `filter_overlay_widget.dart` lines 90-120 (around _hasReceivedNewCount)
- [ ] Read `filter_overlay_widget.dart` lines 140-180 (around _orangeAccentBarSpacing)
- [ ] What were these fields intended for?
- [ ] Are they ever assigned values?
- [ ] Are they read anywhere?

**2. Check FlutterFlow Source:**
- [ ] Read `_flutterflow_export/lib/custom_code/widgets/filter_overlay_widget.dart`
- [ ] Are these fields used in FlutterFlow version?
- [ ] What functionality do they support?
- [ ] Were they intentionally removed or accidentally left behind?

**3. Search for Usage:**
```bash
cd journey_mate
grep -n "_hasReceivedNewCount" lib/widgets/shared/filter_overlay_widget.dart
grep -n "_orangeAccentBarSpacing" lib/widgets/shared/filter_overlay_widget.dart
```
- [ ] Are they only declared but never used?
- [ ] Are they set but never read?
- [ ] Could they be debugging leftovers?

**4. Understand Intent:**
- [ ] Could `_hasReceivedNewCount` be for preventing duplicate updates?
- [ ] Could `_orangeAccentBarSpacing` be for layout calculations?
- [ ] Are these TODO items for future functionality?

#### Fix Strategy Options (Choose After Investigation)

**Option A: Remove Fields (if confirmed unused)**
```dart
// Remove field declarations entirely
// Remove any assignments to these fields
```

**Option B: Add Ignore Comment (if intentionally unused)**
```dart
// ignore: unused_field
bool _hasReceivedNewCount = false; // Reserved for future duplicate prevention
```

**Option C: Actually Use Them (if they should be used)**
```dart
// Implement the intended functionality
// Example: use _hasReceivedNewCount to prevent duplicate API calls
```

**Verification Steps:**
1. After fix, run `flutter analyze` - warnings should be gone
2. **CRITICAL:** Test filter widget thoroughly
3. Verify no functionality degradation
4. Check for any console errors

**Risk Assessment:**
- **Risk Level:** 🟡 MEDIUM
- **Why:** Unclear if removal breaks intended (but unfinished) functionality
- **What could go wrong:** Removing might break edge case handling
- **How to detect:** Thorough testing of filter interactions

---

## INFO ISSUES (8) - Priority 3

### 🔵 INFO 1: Async BuildContext Gap - search_page.dart:154

**Info Message:**
```
info - Don't use 'BuildContext's across async gaps - lib\pages\search_page.dart:154:49
```

#### Investigation Required (DO THIS FIRST)

**1. Understand the Context:**
- [ ] Read `search_page.dart` lines 135-175 (±20 lines)
- [ ] What async operation is happening?
- [ ] What is being done with context after the await?
- [ ] Is there already a mounted check?

**2. Check Current Pattern:**
- [ ] Is `context.mounted` already used?
- [ ] Or is old `mounted` check used?
- [ ] Or is there no check at all?

#### Fix Strategy (Complete Investigation First)

**Expected Pattern:**
```dart
// Add context.mounted check after async operation
await someAsyncOperation();
if (context.mounted) {
  Navigator.push(context, ...);
  // or ScaffoldMessenger.of(context)...
  // or any other context usage
}
```

**Risk Assessment:**
- **Risk Level:** 🟢 LOW
- **Why:** This is a Flutter 3.x best practice, safe to add

---

### 🔵 INFO 2: Prefer Final Fields - filter_overlay_widget.dart:93

**Info Message:**
```
info - The private field _filterMap could be 'final' - line 93
```

#### Investigation Required

**1. Check if Field is Reassigned:**
- [ ] Read entire `filter_overlay_widget.dart` file
- [ ] Search for `_filterMap =` (assignment operator)
- [ ] Is the map itself reassigned, or just modified?

**2. Understand Usage:**
```dart
// If this pattern (modification, not reassignment):
_filterMap[key] = value; // OK to make final

// If this pattern (reassignment):
_filterMap = {}; // Cannot make final
```

#### Fix Strategy

**If only modified (likely):**
```dart
final Map<int, dynamic> _filterMap = {}; // Add 'final' keyword
```

**Risk Assessment:**
- **Risk Level:** 🟢 LOW
- **Why:** Dart analyzer is accurate, won't suggest if unsafe

---

### 🔵 INFO 3-4: Curly Braces in Control Flow - filter_overlay_widget.dart:522,524

**Info Messages:**
```
info - Statements in an if should be enclosed in a block - line 522
info - Statements in an if should be enclosed in a block - line 524
```

#### Investigation Required

**1. Read the Code:**
- [ ] Read lines 510-535
- [ ] What are these if statements doing?
- [ ] Are they single-line or multi-line?

#### Fix Strategy

**Add Curly Braces:**
```dart
// Before:
if (condition) statement;

// After:
if (condition) {
  statement;
}
```

**Risk Assessment:**
- **Risk Level:** 🟢 LOW
- **Why:** Pure formatting change, no logic change

---

### 🔵 INFO 5: Deprecated 'index' - filter_overlay_widget.dart:1622

**Info Message:**
```
info - 'index' is deprecated and shouldn't be used. Use value, which is more precise - line 1622
```

#### Investigation Required

**1. Find the Enum:**
- [ ] Read line 1622 and surrounding code
- [ ] What enum is being used?
- [ ] What is `.index` being used for?

**2. Understand the Change:**
- [ ] In Flutter 3.x, enum.index → enum.value for better type safety
- [ ] Check if `.value` exists for this enum

#### Fix Strategy

**Replace .index with .value:**
```dart
// Before:
SomeEnum.someValue.index

// After:
SomeEnum.someValue.value
```

**Risk Assessment:**
- **Risk Level:** 🟢 LOW
- **Why:** Simple API update, same functionality

---

### 🔵 INFO 6-7: Async BuildContext Gaps - item_bottom_sheet.dart:582,643

**Info Messages:**
```
info - Don't use 'BuildContext's across async gaps, guarded by an unrelated 'mounted' check - lines 582, 643
```

#### ✅ SPECIAL STATUS: ACCEPTABLE (No Fix Required)

**From PHASE7_LESSONS_LEARNED.md lines 1077-1080:**
> 4. **ItemBottomSheet - Lint Warnings** (✅ Acceptable)
>    - 2 info-level `use_build_context_synchronously` warnings
>    - Code correct (context.mounted used properly), linter overly cautious
>    - No action required

#### Investigation Required (Understand, Don't Fix)

**1. Understand Why Acceptable:**
- [ ] Read `item_bottom_sheet.dart` lines 565-600 (around 582)
- [ ] Read `item_bottom_sheet.dart` lines 625-660 (around 643)
- [ ] Verify `context.mounted` check IS present
- [ ] Understand why linter still warns (false positive)

#### Fix Strategy

**Add Ignore Comments:**
```dart
// ignore: use_build_context_synchronously
// Linter is overly cautious - context.mounted check is present and correct
Navigator.push(context, ...);
```

**Risk Assessment:**
- **Risk Level:** 🟢 LOW
- **Why:** Code is already correct, just adding ignore comment

---

### 🔵 INFO 8: Deprecated 'activeColor' - sort_bottom_sheet.dart:108

**Info Message:**
```
info - 'activeColor' is deprecated and shouldn't be used. Use activeThumbColor instead - line 108
```

#### Investigation Required

**1. Find the Widget:**
- [ ] Read `sort_bottom_sheet.dart` lines 95-120
- [ ] What widget uses activeColor? (Likely Switch or Slider)
- [ ] What is the current value?

#### Fix Strategy

**Replace Deprecated Parameter:**
```dart
// Before:
activeColor: AppColors.accent,

// After:
activeThumbColor: AppColors.accent,
```

**Risk Assessment:**
- **Risk Level:** 🟢 LOW
- **Why:** Simple parameter rename, same functionality

---

## Investigation Checklist (Complete Before ANY Fixes)

### Phase 1A: Read All Error Contexts
- [ ] Read filter_overlay_widget.dart lines 780-840 (all errors)
- [ ] Read filter_overlay_widget.dart lines 1-180 (all warnings/info)
- [ ] Read filter_overlay_widget.dart lines 500-540 (curly braces)
- [ ] Read filter_overlay_widget.dart lines 1600-1640 (deprecated index)
- [ ] Read search_page.dart lines 135-175 (async context)
- [ ] Read item_bottom_sheet.dart lines 565-660 (async contexts)
- [ ] Read sort_bottom_sheet.dart lines 95-120 (deprecated activeColor)

### Phase 1B: Read All Relevant Documentation
- [ ] Read `_reference/BUILDSHIP_API_REFERENCE.md` (API signatures)
- [ ] Read `journey_mate/lib/services/api_service.dart` (all API methods)
- [ ] Read `_flutterflow_export/lib/custom_code/widgets/filter_overlay_widget.dart` (FlutterFlow source)
- [ ] Read `shared/widgets/MASTER_README_filter_overlay_widget.md` (if exists)

### Phase 1C: Search for Patterns
- [ ] Run: `grep -r "postAnalytics" journey_mate/lib/ --include="*.dart"` (find all usage)
- [ ] Run: `grep -r "cityId:" journey_mate/lib/ --include="*.dart"` (find all usage)
- [ ] Run: `grep -r "hasTrainStation\|trainStationId" journey_mate/lib/ --include="*.dart"` (check if used elsewhere)

### Phase 1D: Understand Impact
- [ ] List all functionality that could break if fixes are wrong
- [ ] Identify high-risk fixes (train station parameters)
- [ ] Identify low-risk fixes (unused imports, formatting)
- [ ] Plan testing strategy for each fix

---

## Fix Execution Checklist (Only After Investigation Complete)

### Priority 1: Critical Errors (BLOCKING)
- [ ] Fix ERROR 1-4: Missing postAnalytics parameters (line 800)
  - [ ] Verify API signature from api_service.dart
  - [ ] Check other postAnalytics calls for pattern
  - [ ] Apply fix
  - [ ] Run `flutter analyze` - verify error gone
  - [ ] Check analytics logs for successful tracking

- [ ] Fix ERROR 5: Missing cityId (line 818)
  - [ ] Verify AppConstants.kDefaultCityId exists
  - [ ] Add import if needed
  - [ ] Apply fix
  - [ ] Run `flutter analyze` - verify error gone

- [ ] Fix ERROR 6-7: Undefined train station parameters (lines 823-824) ⚠️ HIGH RISK
  - [ ] Choose fix strategy based on investigation
  - [ ] Apply fix
  - [ ] Run `flutter analyze` - verify errors gone
  - [ ] **CRITICAL:** Test train station filtering manually
  - [ ] Verify API request contains correct data

### Priority 2: Warnings
- [ ] Fix WARNING 1-3: Remove unused imports (lines 7, 8, 10)
  - [ ] Verify truly unused
  - [ ] Remove import lines
  - [ ] Run `flutter analyze` - verify warnings gone

- [ ] Fix WARNING 4-5: Unused fields (lines 106, 158)
  - [ ] Choose fix strategy based on investigation
  - [ ] Apply fix
  - [ ] Run `flutter analyze` - verify warnings gone
  - [ ] Test filter widget thoroughly

### Priority 3: Info Issues
- [ ] Fix INFO 1: Async context gap in search_page.dart
- [ ] Fix INFO 2: Add final to _filterMap
- [ ] Fix INFO 3-4: Add curly braces (lines 522, 524)
- [ ] Fix INFO 5: Replace .index with .value (line 1622)
- [ ] Fix INFO 6-7: Add ignore comments to item_bottom_sheet.dart
- [ ] Fix INFO 8: Replace activeColor with activeThumbColor

---

## Final Verification Checklist

### Before Committing
- [ ] Run `flutter analyze` - MUST return "No issues found!"
- [ ] Run `flutter build apk --debug` - MUST complete successfully
- [ ] Compare with `analyze_before.txt` - all 20 issues resolved
- [ ] No NEW issues introduced

### Functionality Testing (HIGH RISK AREAS)
- [ ] Test filter overlay widget:
  - [ ] Open filter bottom sheet
  - [ ] Select/deselect filters
  - [ ] Check analytics tracking (if accessible)
  - [ ] Select train station filter
  - [ ] Verify results update correctly
- [ ] Test search page:
  - [ ] Perform search
  - [ ] Navigate to results
  - [ ] Verify no crashes
- [ ] Test item bottom sheet:
  - [ ] Open item detail
  - [ ] Change language
  - [ ] Verify navigation works
- [ ] Test sort bottom sheet:
  - [ ] Open sort options
  - [ ] Verify switch/slider works

---

## Commit Message Template

```bash
git add .
git commit -m "$(cat <<'EOF'
fix: resolve all 20 flutter analyze issues

CRITICAL ERRORS FIXED (7):
- filter_overlay_widget.dart:800 - Added missing postAnalytics parameters (deviceId, sessionId, userId, timestamp)
- filter_overlay_widget.dart:818 - Added missing cityId parameter (AppConstants.kDefaultCityId)
- filter_overlay_widget.dart:823-824 - [DESCRIBE YOUR FIX FOR TRAIN STATION PARAMETERS]

WARNINGS FIXED (5):
- filter_overlay_widget.dart:7,8,10 - Removed unused imports (app_spacing, app_radius, filter_providers)
- filter_overlay_widget.dart:106,158 - [DESCRIBE HOW YOU HANDLED UNUSED FIELDS]

INFO ISSUES FIXED (8):
- search_page.dart:154 - Added context.mounted check after async operation
- filter_overlay_widget.dart:93 - Made _filterMap final
- filter_overlay_widget.dart:522,524 - Added curly braces to if statements
- filter_overlay_widget.dart:1622 - Replaced deprecated .index with .value
- item_bottom_sheet.dart:582,643 - Added ignore comments (code correct, linter overly cautious)
- sort_bottom_sheet.dart:108 - Replaced deprecated activeColor with activeThumbColor

VERIFICATION:
- flutter analyze: 0 issues ✅
- flutter build apk --debug: SUCCESS ✅
- Manual testing: [DESCRIBE WHAT YOU TESTED]

HIGH RISK AREAS TESTED:
- Train station filtering: [DESCRIBE RESULTS]
- Filter analytics tracking: [DESCRIBE RESULTS]
- Search navigation: [DESCRIBE RESULTS]

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

---

## Session Handover Completion

When you finish this session, update this section:

**Status:** [ ] NOT STARTED | [ ] IN PROGRESS | [ ] COMPLETED

**Issues Resolved:** __ / 20

**Issues Remaining:** __ / 20 (list which ones and why)

**High Risk Fixes Applied:**
- [ ] Train station parameters (ERROR 6-7) - Strategy used: ________________

**Functionality Testing Results:**
- [ ] Filter overlay widget: ________________
- [ ] Search page: ________________
- [ ] Item bottom sheet: ________________
- [ ] Sort bottom sheet: ________________

**Known Issues:**
- [List any issues that couldn't be fixed and why]

**Recommendations for Next Session:**
- [Any follow-up work needed]

---

## References

**Read Before Starting:**
- `CLAUDE.md` - All project rules and conventions
- `_reference/SESSION_STATUS.md` - Current project state
- `_reference/PHASE7_LESSONS_LEARNED.md` - Phase 7 patterns and lessons
- `_reference/BUILDSHIP_API_REFERENCE.md` - All API signatures
- `journey_mate/lib/services/api_service.dart` - API service implementation

**Related Plans:**
- `C:\Users\Rikke\.claude\plans\fix-flutter-analyze-issues.md` - Original fix plan (reference only)

---

**End of Handover Document**

**REMEMBER:** Do NOT start fixing until you complete Phase 1 (Investigation) for ALL issues!
