# endMenuSession Action

**Type:** Custom Action (Async)
**File:** `end_menu_session.dart` (283 lines)
**Category:** Menu Session & Analytics
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐⭐ (CRITICAL - Menu session tracking)
**Complexity:** 🔴 VERY COMPLEX (Multiple calculations, helper functions)

---

## Purpose

Ends a menu browsing session and tracks comprehensive session metrics including browsing behavior, filter usage patterns, and filter effectiveness. This is the terminal action in the menu session lifecycle, capturing all accumulated data before cleanup.

**Key Features:**
- Reads filter state directly from FFAppState (unified filter structure)
- Extracts browsing metrics (clicks, scrolls, categories viewed)
- Extracts filter engagement metrics (interactions, resets)
- Calculates filter result quality metrics (zero results, low results)
- Calculates filter engagement score (0-100)
- Tracks comprehensive analytics event with 20+ data points
- Resets session data for next session
- Handles missing session gracefully

**Updated for Unified Filters:**
Now reads filter state from the unified filter widget structure that includes dietary restrictions, preferences, and allergens in a single interface.

---

## Function Signature

```dart
Future<void> endMenuSession(
  int businessId,
)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `businessId` | `int` | **Yes** | The ID of the business whose menu was viewed |

### Returns

| Type | Description |
|------|-------------|
| `Future<void>` | No return value (fire-and-forget analytics) |

---

## Dependencies

### Internal Dependencies
```dart
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';
// Uses: trackAnalyticsEvent
```

### No pub.dev Packages Required
All calculations and tracking use built-in Dart features and existing custom actions.

---

## FFAppState Usage

### Read Properties - Session Data
```dart
FFAppState().menuSessionData['menuSessionId']        // Session UUID
FFAppState().menuSessionData['itemClicks']           // Item detail clicks
FFAppState().menuSessionData['packageClicks']        // Package detail clicks
FFAppState().menuSessionData['categoriesViewed']     // Array of category IDs viewed
FFAppState().menuSessionData['deepestScrollPercent'] // Max scroll depth (0-100)
FFAppState().menuSessionData['filterInteractions']   // Filter toggle count
FFAppState().menuSessionData['filterResets']         // Filter clear count
FFAppState().menuSessionData['everHadFiltersActive'] // Whether filters were ever used
FFAppState().menuSessionData['zeroResultCount']      // Times filters resulted in 0 items
FFAppState().menuSessionData['lowResultCount']       // Times filters resulted in 1-2 items
FFAppState().menuSessionData['filterResultHistory']  // Array of result counts
```

### Read Properties - Filter State
```dart
FFAppState().selectedDietaryRestrictionId            // Current dietary restriction (empty = inactive)
FFAppState().selectedDietaryPreferenceId             // Current dietary preference (0 = inactive)
FFAppState().excludedAllergyIds                      // Current excluded allergens (empty = inactive)
```

### Write Properties
```dart
FFAppState().menuSessionData                         // Reset to empty state
```

---

## Filter State Detection

### Unified Filter Structure

The action determines filter state by checking three separate filter types:

```dart
// Dietary Restriction (e.g., "Vegetarian", "Vegan")
final hasRestrictionActive =
    FFAppState().selectedDietaryRestrictionId?.isNotEmpty ?? false;

// Dietary Preference (e.g., "Organic", "Locally Sourced")
final hasPreferenceActive =
    (FFAppState().selectedDietaryPreferenceId ?? 0) > 0;

// Allergen Exclusions (e.g., "Gluten", "Nuts", "Dairy")
final hasAllergiesExcluded =
    FFAppState().excludedAllergyIds?.isNotEmpty ?? false;

// Combined state
final currentlyHasFiltersActive =
    hasRestrictionActive || hasPreferenceActive || hasAllergiesExcluded;
```

### Filter State Examples

| Restriction ID | Preference ID | Excluded Allergens | Has Filters Active? |
|----------------|---------------|--------------------|---------------------|
| "" (empty) | 0 | [] (empty) | ❌ No |
| "vegetarian" | 0 | [] | ✅ Yes |
| "" | 5 | [] | ✅ Yes |
| "" | 0 | [1, 3, 7] | ✅ Yes |
| "vegan" | 2 | [4] | ✅ Yes |

---

## Browsing Metrics

### Captured Metrics

| Metric | Source | Description |
|--------|--------|-------------|
| `itemsClicked` | `itemClicks` | Number of individual menu items viewed |
| `packagesClicked` | `packageClicks` | Number of package/combo items viewed |
| `categoriesViewed` | `categoriesViewed.length` | Unique categories scrolled to |
| `deepestScrollPercent` | `deepestScrollPercent` | Maximum scroll depth (0-100) |
| `totalInteractions` | Calculated | `itemsClicked + packagesClicked` |

### Example Data Flow

```dart
// User browses menu:
// - Clicks 5 individual items
// - Clicks 2 package deals
// - Scrolls through "Appetizers", "Mains", "Desserts"
// - Reaches 85% of menu length

// Metrics captured:
{
  'items_clicked': 5,
  'packages_clicked': 2,
  'categories_viewed': 3,
  'deepest_scroll_percent': 85,
  'total_interactions': 7
}
```

---

## Filter Engagement Metrics

### Tracked Metrics

| Metric | Source | Description |
|--------|--------|-------------|
| `everHadFiltersActive` | Session flag | Whether filters were toggled during session |
| `filtersActiveAtEnd` | Current state | Whether filters are still active when leaving |
| `filterInteractions` | Accumulated | Total filter toggle count |
| `filterResets` | Accumulated | Total filter clear/reset count |

### Engagement Patterns

**Pattern 1: Active Filter User**
```dart
{
  'ever_had_filters_active': true,
  'filters_active_at_end': true,
  'filter_interactions': 8,
  'filter_resets': 1,
  'filter_engagement_score': 65
}
// User actively filters, finds results, keeps filters
```

**Pattern 2: Frustrated User**
```dart
{
  'ever_had_filters_active': true,
  'filters_active_at_end': false,
  'filter_interactions': 12,
  'filter_resets': 4,
  'filter_engagement_score': 0
}
// User tries many filters, gets frustrated, clears all
```

**Pattern 3: Non-Filter User**
```dart
{
  'ever_had_filters_active': false,
  'filters_active_at_end': false,
  'filter_interactions': 0,
  'filter_resets': 0,
  'filter_engagement_score': 0
}
// User browses without using filters
```

---

## Filter Result Quality Metrics

### Zero Result Events

**Tracked When:** User applies filter combination that results in 0 matching items

```dart
// Example: User selects "Vegan" + "Gluten-Free" + Excludes "Soy"
// If no items match, zeroResultCount increments
{
  'zero_result_count': 3  // Happened 3 times during session
}
```

### Low Result Events

**Tracked When:** User applies filter combination that results in 1-2 matching items

```dart
// Example: User selects "Organic" + "Locally Sourced"
// If only 2 items match, lowResultCount increments
{
  'low_result_count': 2  // Happened 2 times during session
}
```

### Result History

**Purpose:** Track all filter result counts to calculate aggregate statistics

```dart
// User changes filters 5 times during session
'filterResultHistory': [12, 8, 0, 15, 2]

// Calculated statistics:
{
  'avg_result_count': 7,    // (12+8+0+15+2) / 5
  'min_result_count': 0,    // Minimum value
  'max_result_count': 15,   // Maximum value
  'total_filter_changes': 5 // Length of history
}
```

---

## Filter Engagement Score Calculation

### Scoring Algorithm

**Formula:**
```dart
rawScore = (interactions × 10) - (resets × 15) - (zeroResults × 5)
finalScore = rawScore.clamp(0, 100)
```

### Scoring Components

| Component | Weight | Impact | Reasoning |
|-----------|--------|--------|-----------|
| **Interactions** | +10 points | Positive | Shows active exploration |
| **Resets** | -15 points | Negative | Indicates frustration |
| **Zero Results** | -5 points | Negative | Poor UX, overly restrictive |

### Score Examples

**Example 1: Successful Filter Usage**
```dart
interactions: 8
resets: 0
zeroResults: 1

Score = (8 × 10) - (0 × 15) - (1 × 5)
      = 80 - 0 - 5
      = 75/100  ✅ High engagement
```

**Example 2: Frustrated User**
```dart
interactions: 6
resets: 3
zeroResults: 4

Score = (6 × 10) - (3 × 15) - (4 × 5)
      = 60 - 45 - 20
      = -5 → clamped to 0/100  ❌ Poor experience
```

**Example 3: No Filter Usage**
```dart
interactions: 0
resets: 0
zeroResults: 0

Score = 0  (returns 0 immediately)
```

**Example 4: Power User**
```dart
interactions: 15
resets: 1
zeroResults: 0

Score = (15 × 10) - (1 × 15) - (0 × 5)
      = 150 - 15 - 0
      = 135 → clamped to 100/100  ⭐ Maximum engagement
```

---

## Helper Functions

### 1. _calculateAverageResultCount()

**Purpose:** Calculate mean result count across all filter changes

```dart
int? _calculateAverageResultCount(List resultHistory)
```

**Logic:**
- Returns `null` if history is empty (no data)
- Sums all result counts
- Divides by number of entries
- Rounds to nearest integer

**Example:**
```dart
resultHistory: [10, 15, 5, 20]
sum: 50
average: 50 / 4 = 12.5 → 13 (rounded)
```

---

### 2. _calculateMinResultCount()

**Purpose:** Find minimum result count in filter history

```dart
int? _calculateMinResultCount(List resultHistory)
```

**Logic:**
- Returns `null` if history is empty
- Uses `fold()` to find minimum value
- Returns as integer

**Example:**
```dart
resultHistory: [10, 15, 0, 20, 3]
minimum: 0
```

---

### 3. _calculateMaxResultCount()

**Purpose:** Find maximum result count in filter history

```dart
int? _calculateMaxResultCount(List resultHistory)
```

**Logic:**
- Returns `null` if history is empty
- Uses `fold()` to find maximum value
- Returns as integer

**Example:**
```dart
resultHistory: [10, 15, 0, 20, 3]
maximum: 20
```

---

### 4. _calculateFilterEngagementScore()

**Purpose:** Calculate 0-100 engagement quality score

```dart
int _calculateFilterEngagementScore({
  required int interactions,
  required int resets,
  required int zeroResults,
})
```

**Logic:**
- Returns 0 if no interactions
- Applies weighted formula (see "Filter Engagement Score Calculation")
- Clamps result to 0-100 range

**Example:**
```dart
_calculateFilterEngagementScore(
  interactions: 8,
  resets: 1,
  zeroResults: 2,
) // Returns: (8×10)-(1×15)-(2×5) = 55
```

---

### 5. _logSessionMetrics()

**Purpose:** Debug logging for development

```dart
void _logSessionMetrics({
  required String menuSessionId,
  required int itemsClicked,
  required int packagesClicked,
  required int categoriesViewed,
  required int filterInteractions,
  required int filterResets,
  required int zeroResultCount,
  required int lowResultCount,
  required int filterEngagementScore,
  required bool currentlyHasFiltersActive,
})
```

**Output Example:**
```
📋 Menu session ended: 550e8400-e29b-41d4-a716-446655440000
   Items clicked: 5
   Packages clicked: 2
   Categories viewed: 3
   Filter interactions: 8
   Filter resets: 1
   Zero results: 2 times
   Low results (1-2): 3 times
   Filter engagement score: 55/100
   Filters active at end: true
```

---

### 6. _resetSessionData()

**Purpose:** Clear session data for next menu session

```dart
void _resetSessionData()
```

**Reset Structure:**
```dart
FFAppState().menuSessionData = {
  'menuSessionId': '',                // Clear session ID
  'itemClicks': 0,
  'packageClicks': 0,
  'categoriesViewed': [],
  'deepestScrollPercent': 0,
  'filterInteractions': 0,
  'filterResets': 0,
  'everHadFiltersActive': false,
  'zeroResultCount': 0,
  'lowResultCount': 0,
  'filterResultHistory': [],
};
```

---

## Analytics Event Structure

### Event Name
```dart
'menu_session_ended'
```

### Complete Payload

```json
{
  "eventType": "menu_session_ended",
  "deviceId": "uuid-device-id",
  "sessionId": "uuid-session-id",
  "timestamp": "2026-02-19T14:32:18.000Z",
  "eventData": {
    // Session identifiers
    "menu_session_id": "550e8400-e29b-41d4-a716-446655440000",
    "business_id": 123,

    // Browsing metrics
    "items_clicked": 5,
    "packages_clicked": 2,
    "categories_viewed": 3,
    "deepest_scroll_percent": 85,
    "total_interactions": 7,

    // Filter usage metrics
    "ever_had_filters_active": true,
    "filters_active_at_end": true,
    "filter_interactions": 8,
    "filter_resets": 1,
    "filter_engagement_score": 55,

    // Filter result quality metrics
    "zero_result_count": 2,
    "low_result_count": 3,
    "avg_result_count": 12,
    "min_result_count": 0,
    "max_result_count": 20,
    "total_filter_changes": 5
  }
}
```

---

## Usage Examples

### Example 1: Basic Usage (Page Dispose)

```dart
class FullMenuPageWidget extends StatefulWidget {
  final int businessId;

  const FullMenuPageWidget({
    required this.businessId,
  });
}

class _FullMenuPageWidgetState extends State<FullMenuPageWidget> {
  @override
  void dispose() {
    // End menu session when leaving page
    actions.endMenuSession(widget.businessId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... page content
  }
}
```

---

### Example 2: With Error Handling

```dart
@override
void dispose() async {
  try {
    await actions.endMenuSession(widget.businessId);
    debugPrint('✅ Menu session ended successfully');
  } catch (e) {
    debugPrint('⚠️ Failed to end menu session: $e');
  }
  super.dispose();
}
```

**Note:** The action includes internal error handling, so explicit try-catch is optional.

---

### Example 3: Conditional Session End

```dart
@override
void dispose() {
  // Only end session if one is active
  final sessionId = FFAppState().menuSessionData['menuSessionId'] as String?;

  if (sessionId != null && sessionId.isNotEmpty) {
    actions.endMenuSession(widget.businessId);
  } else {
    debugPrint('No active menu session to end');
  }

  super.dispose();
}
```

---

## Error Handling

### Error 1: No Active Session
```
⚠️ Cannot end menu session - no active session ID found
```
**Behavior:** Returns early without tracking
**Fix:** Ensure `startMenuSession` was called when page opened

---

### Error 2: Invalid Session Data
```
⚠️ Failed to end menu session: type 'int' is not a subtype of type 'String?'
```
**Behavior:** Logs error and stack trace
**Fix:** Verify `menuSessionData` structure matches expected format

---

### Error 3: Analytics Failure
```
⚠️ Failed to end menu session: SocketException: Failed host lookup
   Stack trace: ...
```
**Behavior:** Logs error but still resets session data
**Impact:** Session metrics lost, but state cleanup proceeds

---

## Workflow Integration

### Complete Menu Session Lifecycle

```dart
// 1. User opens Full Menu page
startMenuSession(businessId)
// Creates session ID, initializes metrics

// 2. User browses menu
trackMenuItemClick()
trackPackageClick()
trackCategoryView()
trackScrollDepth()
// Accumulates browsing metrics

// 3. User interacts with filters
trackFilterInteraction()
trackFilterResultCount()
// Accumulates filter metrics

// 4. User resets filters
trackFilterReset()
// Increments reset counter

// 5. User leaves page
endMenuSession(businessId)
// Captures all metrics, tracks analytics, resets state
```

---

## Session Data Flow

### Data Accumulation

```dart
// Session starts
menuSessionData = {
  'menuSessionId': '550e8400-...',
  'itemClicks': 0,
  'categoriesViewed': [],
  // ... all zeros/empty
}

// After user activity
menuSessionData = {
  'menuSessionId': '550e8400-...',
  'itemClicks': 5,
  'packageClicks': 2,
  'categoriesViewed': [1, 3, 7],
  'deepestScrollPercent': 85,
  'filterInteractions': 8,
  'filterResets': 1,
  'everHadFiltersActive': true,
  'zeroResultCount': 2,
  'lowResultCount': 3,
  'filterResultHistory': [12, 8, 0, 15, 2],
}

// endMenuSession reads this data
// Calculates aggregate metrics
// Tracks analytics
// Resets to empty state
```

---

## Performance Considerations

### Non-Blocking Disposal

**Don't block navigation:**
```dart
@override
void dispose() {
  actions.endMenuSession(widget.businessId);  // Fire and forget
  super.dispose();
}
```

**Why:** Analytics should not delay page transitions

---

### Memory Cleanup

**Session data reset ensures:**
- No memory leaks from accumulated arrays
- Clean slate for next session
- No carryover of previous metrics

```dart
// Before reset: ~500 bytes (with history arrays)
// After reset: ~100 bytes (empty structure)
```

---

## Debug Output

### Successful Session End
```
📋 Menu session ended: 550e8400-e29b-41d4-a716-446655440000
   Items clicked: 5
   Packages clicked: 2
   Categories viewed: 3
   Filter interactions: 8
   Filter resets: 1
   Zero results: 2 times
   Low results (1-2): 3 times
   Filter engagement score: 55/100
   Filters active at end: true
✅ Event tracked: menu_session_ended
```

---

### No Active Session
```
⚠️ Cannot end menu session - no active session ID found
```

---

### Exception During Tracking
```
⚠️ Failed to end menu session: Exception: Connection timeout
   Stack trace:
   #0      endMenuSession (package:journey_mate/custom_code/actions/end_menu_session.dart:156:5)
   ...
```

---

## Related Actions

| Action | Purpose | Relationship |
|--------|---------|--------------|
| `startMenuSession` | Begins menu session | Must be called before `endMenuSession` |
| `trackMenuItemClick` | Increments item click count | Updates `itemClicks` metric |
| `trackPackageClick` | Increments package click count | Updates `packageClicks` metric |
| `trackCategoryView` | Adds category to viewed list | Updates `categoriesViewed` array |
| `trackScrollDepth` | Updates scroll percentage | Updates `deepestScrollPercent` |
| `trackFilterInteraction` | Increments filter toggle count | Updates `filterInteractions` |
| `trackFilterReset` | Increments reset count | Updates `filterResets` |
| `trackFilterResultCount` | Logs result count | Updates `filterResultHistory` |
| `trackAnalyticsEvent` | Sends event to BuildShip | Called by `endMenuSession` |

---

## Used By Pages

### Full Menu Page
**When:** Page dispose lifecycle
**Purpose:** Track complete menu browsing session
**Metrics:** All browsing + filter metrics

---

## Data Analysis Use Cases

### Business Intelligence

**Question:** Do filters help or hurt menu engagement?

**Analysis:**
```sql
SELECT
  AVG(filter_engagement_score) as avg_score,
  AVG(total_interactions) as avg_interactions,
  AVG(filter_interactions) as avg_filter_usage
FROM menu_sessions
WHERE ever_had_filters_active = true
GROUP BY business_id
```

---

### UX Optimization

**Question:** Which filter combinations cause zero results?

**Analysis:**
```sql
SELECT
  business_id,
  AVG(zero_result_count) as avg_zero_results,
  AVG(filter_resets) as avg_resets
FROM menu_sessions
WHERE zero_result_count > 0
GROUP BY business_id
ORDER BY avg_zero_results DESC
```

---

### Engagement Patterns

**Question:** Do users keep filters active or turn them off?

**Analysis:**
```sql
SELECT
  filters_active_at_end,
  COUNT(*) as session_count,
  AVG(total_interactions) as avg_interactions
FROM menu_sessions
WHERE ever_had_filters_active = true
GROUP BY filters_active_at_end
```

---

## Testing Checklist

When implementing in Flutter:

**Session Lifecycle:**
- [ ] Call `startMenuSession` before tracking any menu activity
- [ ] Call `endMenuSession` in page dispose
- [ ] Verify session ID is present in menuSessionData
- [ ] Verify session ID is cleared after endMenuSession

**Browsing Metrics:**
- [ ] Item clicks accumulate correctly
- [ ] Package clicks accumulate correctly
- [ ] Categories viewed adds unique categories only
- [ ] Scroll depth tracks maximum value

**Filter Metrics:**
- [ ] Filter interactions increment on each toggle
- [ ] Filter resets increment on clear action
- [ ] everHadFiltersActive becomes true when filters used
- [ ] Zero result count tracks correctly
- [ ] Low result count tracks correctly
- [ ] Result history accumulates all counts

**Calculations:**
- [ ] Average result count calculated correctly
- [ ] Min/max result counts found correctly
- [ ] Engagement score matches formula
- [ ] Engagement score clamped to 0-100
- [ ] Returns 0 score when no interactions

**Filter State Detection:**
- [ ] Detects dietary restriction correctly
- [ ] Detects dietary preference correctly
- [ ] Detects allergen exclusions correctly
- [ ] Combined state calculation correct

**Analytics:**
- [ ] Event tracked with all 20+ data points
- [ ] Event sent to BuildShip successfully
- [ ] Verify event appears in BuildShip logs

**Error Handling:**
- [ ] Handles missing session ID gracefully
- [ ] Handles empty result history (returns null)
- [ ] Logs errors without crashing
- [ ] Resets data even if analytics fails

**State Cleanup:**
- [ ] Session data reset to empty structure
- [ ] All counters reset to 0
- [ ] All arrays reset to empty
- [ ] Session ID cleared

---

## Migration Notes

### Phase 3 Changes

1. **Keep FFAppState.menuSessionData structure** - critical for metric accumulation
2. **Keep filter state reading logic** - unified filter structure is current design
3. **Consider Riverpod for filter state:**
   ```dart
   // Current:
   final hasRestrictionActive =
       FFAppState().selectedDietaryRestrictionId?.isNotEmpty ?? false;

   // After (Riverpod):
   final hasRestrictionActive =
       ref.read(filterProvider).dietaryRestrictionId?.isNotEmpty ?? false;
   ```

4. **Maintain analytics event structure** - keep same event name and data keys

---

### Enhancement Opportunities

**1. Session Duration Tracking:**
```dart
// Add to metrics:
'session_duration_seconds': sessionEndTime - sessionStartTime
```

**2. Category Engagement Time:**
```dart
// Track time spent per category:
'category_time_distribution': {
  'appetizers': 45,
  'mains': 120,
  'desserts': 30
}
```

**3. Filter Combination Analysis:**
```dart
// Track specific filter combinations:
'filter_combinations': [
  ['vegan', 'gluten-free'],
  ['organic', 'locally-sourced']
]
```

---

## Known Issues

1. **No session duration** - Start/end times not captured
2. **No category engagement time** - Only tracks which categories, not time spent
3. **No filter combination tracking** - Can't analyze which combinations cause issues
4. **No retry on analytics failure** - Failed events are lost
5. **Result history unbounded** - Could grow large with excessive filter changes

---

## Security & Privacy Notes

⚠️ **Important:**
- Session data contains **detailed behavioral metrics**
- Business ID identifies **which restaurant was viewed**
- Filter interactions reveal **user dietary restrictions/allergies**
- Result counts could expose **menu content indirectly**

**Recommendations:**
- Anonymize session IDs in analytics storage
- Aggregate metrics before sharing with restaurants
- Allow users to opt-out of detailed tracking
- Clear session data on app uninstall

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Flutter Implementation
**Complexity:** 🔴 VERY COMPLEX - 6 helper functions, multiple calculations
