# updateMenuSessionFilterMetrics Action

**Type:** Custom Action (Async)
**File:** `update_menu_session_filter_metrics.dart` (74 lines)
**Category:** Search & Filters (Menu-Specific)
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐⭐ (High - Critical UX analytics)

---

## Purpose

Updates menu session metrics **after every filter change** that affects visible menu items. Tracks filter engagement, result counts, and quality metrics to understand user interaction patterns and identify problematic filtering states (zero or low results).

**Key Features:**
- Increments filterInteractions counter on every filter change
- Tracks result count history over time
- Detects zero-result states (critical UX problem)
- Detects low-result states (1-2 items, suboptimal UX)
- Marks everHadFiltersActive flag for session analysis
- Records filterResultHistory for pattern analysis

**Context:** This is a **post-filter update action** called after any filter toggle. It powers analytics that identify filter friction, over-filtering, and poor result quality.

---

## Function Signature

```dart
Future<void> updateMenuSessionFilterMetrics(int currentResultCount)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `currentResultCount` | `int` | **Yes** | Number of menu items visible after filter change |

### Returns

| Type | Description |
|------|-------------|
| `Future<void>` | No return value |

---

## Dependencies

### Internal Dependencies
```dart
import '/custom_code/actions/index.dart';           // No direct imports needed
import '/flutter_flow/custom_functions.dart';       // No direct imports needed
```

### FFAppState Usage

#### Reads
| State Variable | Type | Purpose |
|---------------|------|---------|
| `menuSessionData` | `Map<String, dynamic>` | Menu session context |
| `menuSessionData['filterInteractions']` | `int` | Current interaction count |
| `menuSessionData['filterResultHistory']` | `List<int>` | Result count history |
| `menuSessionData['zeroResultCount']` | `int` | Zero-result occurrence count |
| `menuSessionData['lowResultCount']` | `int` | Low-result occurrence count |

#### Writes
| State Variable | Type | Purpose |
|---------------|------|---------|
| `menuSessionData['everHadFiltersActive']` | `bool` | Set to true when filters used |
| `menuSessionData['filterInteractions']` | `int` | Incremented interaction count |
| `menuSessionData['filterResultHistory']` | `List<int>` | Updated result history |
| `menuSessionData['zeroResultCount']` | `int` | Incremented zero-result count |
| `menuSessionData['lowResultCount']` | `int` | Incremented low-result count |

---

## Usage Examples

### Example 1: After Filter Toggle
```dart
// In menu page filter widget
Future<void> _onFilterToggled(String allergen, bool selected) async {
  setState(() {
    if (selected) {
      _selectedAllergens.add(allergen);
    } else {
      _selectedAllergens.remove(allergen);
    }
  });

  // Filter menu items
  final filteredItems = _applyFilters(_allMenuItems);

  // Update metrics with new result count
  await actions.updateMenuSessionFilterMetrics(filteredItems.length);

  setState(() {
    _visibleItems = filteredItems;
  });
}
```

### Example 2: After Multiple Filter Changes
```dart
// When user toggles multiple filters in quick succession
Future<void> _onFiltersChanged(Set<String> allergens, Set<String> dietary) async {
  setState(() {
    _selectedAllergens = allergens;
    _selectedDietary = dietary;
  });

  final filteredItems = _applyFilters(_allMenuItems);

  // Track each filter change separately
  await actions.updateMenuSessionFilterMetrics(filteredItems.length);

  // Show zero-result warning if needed
  if (filteredItems.isEmpty) {
    _showZeroResultsWarning();
  }

  setState(() {
    _visibleItems = filteredItems;
  });
}
```

### Example 3: With Result Quality Feedback
```dart
Future<void> _updateFiltersAndTrack(Set<String> filters) async {
  final filteredItems = _filterMenuItems(_allMenuItems, filters);
  final resultCount = filteredItems.length;

  // Update metrics
  await actions.updateMenuSessionFilterMetrics(resultCount);

  // Provide user feedback based on result quality
  if (resultCount == 0) {
    _showSnackBar('Ingen retter matchede dine filtre');
  } else if (resultCount <= 2) {
    _showSnackBar('Kun $resultCount retter fundet');
  }

  setState(() {
    _visibleItems = filteredItems;
  });
}
```

### Example 4: After Filter Reset
```dart
Future<void> _onClearFilters() async {
  setState(() {
    _selectedAllergens.clear();
    _selectedDietary.clear();
  });

  // All items visible after reset
  await actions.updateMenuSessionFilterMetrics(_allMenuItems.length);

  // Track reset separately
  await actions.trackFilterReset(widget.businessId);
}
```

---

## Session Data Updates

### Data Structure
```dart
FFAppState().menuSessionData = {
  // Set to true when filters are used at least once
  'everHadFiltersActive': true,

  // Total number of filter interactions (toggles)
  'filterInteractions': 7,

  // History of result counts after each filter change
  'filterResultHistory': [12, 8, 3, 0, 5, 8, 2],

  // Number of times filters resulted in zero items
  'zeroResultCount': 1,

  // Number of times filters resulted in 1-2 items
  'lowResultCount': 2,

  // ... other menu session metrics
};
```

### Metric Interpretation

| Metric | Good Range | Warning | Critical |
|--------|-----------|---------|----------|
| `filterInteractions` | 1-5 | 6-10 | 11+ |
| `zeroResultCount` | 0 | 1 | 2+ |
| `lowResultCount` | 0-1 | 2-3 | 4+ |
| `filterResultHistory` length | Matches interactions | - | - |

**High filterInteractions** = User exploring filters or frustrated
**High zeroResultCount** = Filters too restrictive or poor menu data
**High lowResultCount** = Suboptimal filtering experience

---

## Result Quality States

### Zero Results (Critical UX Problem)
```
currentResultCount == 0
```
**User Experience:** "Ingen retter matchede dine filtre"
**Analytics Impact:** Increments zeroResultCount
**Action Required:** Show "Ingen resultater" message, suggest removing filters

### Low Results (Suboptimal UX)
```
currentResultCount > 0 && currentResultCount <= 2
```
**User Experience:** Very limited options (1-2 items)
**Analytics Impact:** Increments lowResultCount
**Action Required:** Consider showing "Kun X retter fundet" notice

### Healthy Results
```
currentResultCount > 2
```
**User Experience:** Good selection of filtered items
**Analytics Impact:** Recorded in filterResultHistory
**Action Required:** None

---

## Error Handling

### Error 1: Invalid Result Count
```
⚠️ Failed to update filter metrics: [error]
   Stack trace: [stack trace]
```
**Cause:** Exception during metric update (data structure issue)
**Impact:** Metrics not updated (silent failure)
**Fix:** Check menuSessionData structure, ensure initialized

### Error 2: Missing Session Data
```
⚠️ Failed to update filter metrics: type 'Null' is not a subtype of type 'Map<String, dynamic>'
```
**Cause:** menuSessionData is null or not initialized
**Impact:** Metrics not updated
**Fix:** Ensure `startMenuSession()` called before first filter interaction

---

## Workflow

```
1. Receive currentResultCount parameter
2. Read menuSessionData from FFAppState
3. Set everHadFiltersActive = true (marks session as having used filters)
4. Read current filterInteractions count
5. Increment filterInteractions by 1
6. Add currentResultCount to filterResultHistory
7. If currentResultCount == 0:
   - Increment zeroResultCount
8. If currentResultCount > 0 AND <= 2:
   - Increment lowResultCount
9. Update menuSessionData in FFAppState
10. Log debug output
```

---

## Debug Output

### Normal Filter Interaction
```
📊 Filter metrics updated:
   Interaction #7
   Current results: 8
```

### Zero Results Detected
```
📊 Filter metrics updated:
   Interaction #4
   Current results: 0
   ⚠️ Zero results detected
```

### Low Results Detected
```
📊 Filter metrics updated:
   Interaction #9
   Current results: 2
   ⚠️ Low results detected
```

### Error
```
⚠️ Failed to update filter metrics: Exception: Cannot read property of null
   Stack trace: ...
```

---

## Testing Checklist

- [ ] Start menu session with `startMenuSession()`
- [ ] Toggle filter → filterInteractions = 1
- [ ] Toggle another filter → filterInteractions = 2
- [ ] Check filterResultHistory has 2 entries
- [ ] Filter to zero results → zeroResultCount = 1
- [ ] Filter to 1 item → lowResultCount = 1
- [ ] Filter to 2 items → lowResultCount = 2
- [ ] Filter to 3+ items → no quality warnings
- [ ] Check everHadFiltersActive set to true
- [ ] Clear filters → metrics still tracked
- [ ] Test without active session → handled gracefully

---

## Analytics Use Cases

**This data helps answer:**

1. **Filter Engagement:**
   - How many times do users interact with filters per session?
   - Do users explore filters or set them once?

2. **Result Quality:**
   - How often do filters produce zero results?
   - How often do filters produce too few results (1-2)?
   - What's the typical result count after filtering?

3. **Filter Patterns:**
   - What's the result count progression over a session?
   - Do users start broad and narrow down, or vice versa?
   - Do zero-result experiences lead to session abandonment?

4. **Menu Data Quality:**
   - Which menus have high zero-result rates? (poor filter data)
   - Which allergen combinations produce no results?

**Example Analysis:**

```sql
-- Sessions with high filter frustration (zero results)
SELECT menu_session_id, zero_result_count, filter_interactions
FROM menu_sessions
WHERE zero_result_count > 0
ORDER BY zero_result_count DESC;

-- Average result count distribution
SELECT
  business_id,
  AVG(filter_interactions) as avg_interactions,
  AVG(zero_result_count) as avg_zero_results,
  AVG(low_result_count) as avg_low_results
FROM menu_sessions
WHERE ever_had_filters_active = true
GROUP BY business_id;

-- Result count patterns over sessions
SELECT
  unnest(filter_result_history) as result_count,
  COUNT(*) as occurrences
FROM menu_sessions
GROUP BY result_count
ORDER BY result_count;
```

---

## Migration Notes

### Phase 3 Changes

1. **Replace FFAppState with Riverpod:**
   ```dart
   // Before:
   final sessionData = FFAppState().menuSessionData as Map<String, dynamic>;
   FFAppState().update(() {
     FFAppState().menuSessionData = sessionData;
   });

   // After:
   final sessionData = ref.read(menuSessionProvider).sessionData;
   ref.read(menuSessionProvider.notifier).updateFilterMetrics(
     currentResultCount: currentResultCount,
   );
   ```

2. **Consider batching rapid filter changes:**
   ```dart
   // Add debouncing for rapid filter toggles
   Timer? _metricUpdateTimer;

   void _scheduleMetricUpdate(int resultCount) {
     _metricUpdateTimer?.cancel();
     _metricUpdateTimer = Timer(Duration(milliseconds: 300), () {
       actions.updateMenuSessionFilterMetrics(resultCount);
     });
   }
   ```

3. **Add result quality thresholds:**
   ```dart
   // Make thresholds configurable
   const ZERO_RESULT_THRESHOLD = 0;
   const LOW_RESULT_THRESHOLD = 2;
   const HEALTHY_RESULT_THRESHOLD = 3;
   ```

---

## Related Actions

| Action | Purpose | Relationship |
|--------|---------|--------------|
| `startMenuSession` | Start menu session | Must be called first to initialize menuSessionData |
| `endMenuSession` | End menu session | Receives final filter metrics for session summary |
| `trackFilterReset` | Track filter reset | Updates filterInteractions, called before this action |
| `updatePreviousFilterState` | Track filter state | Works with this action to track filter changes |
| `trackAnalyticsEvent` | Analytics tracking | Used by parent actions to send filter events |

---

## Used By Pages

1. **Menu Full Page** - Called after every allergen/dietary filter toggle

---

## Known Issues

1. **No debouncing for rapid changes** - Multiple quick toggles create many metric updates
2. **No maximum history length** - filterResultHistory grows unbounded
3. **No validation of result count** - Could receive negative or unrealistic values
4. **Silent failure on error** - No user feedback when metrics fail to update
5. **No distinction between filter types** - Doesn't track which filters caused zero results

---

## Filter Interaction Flow

```
User toggles allergen filter
        ↓
_applyFilters() runs
        ↓
Calculate new result count
        ↓
updateMenuSessionFilterMetrics(resultCount)
        ↓
┌─────────────────────────────────────┐
│ 1. everHadFiltersActive = true      │
│ 2. filterInteractions++             │
│ 3. filterResultHistory.add(count)   │
│ 4. If count == 0: zeroResultCount++ │
│ 5. If count <= 2: lowResultCount++  │
└─────────────────────────────────────┘
        ↓
Update FFAppState.menuSessionData
        ↓
Debug log output
```

---

## Advanced Usage

### Pattern 1: Track Filter Quality Score
```dart
Future<double> _calculateFilterQualityScore() async {
  final sessionData = FFAppState().menuSessionData;
  final interactions = sessionData['filterInteractions'] as int? ?? 0;
  final zeroResults = sessionData['zeroResultCount'] as int? ?? 0;
  final lowResults = sessionData['lowResultCount'] as int? ?? 0;

  if (interactions == 0) return 1.0; // No filters used = perfect

  // Quality score: penalize zero/low results
  final problematicInteractions = zeroResults + (lowResults * 0.5);
  final qualityScore = 1.0 - (problematicInteractions / interactions);

  return qualityScore.clamp(0.0, 1.0);
}
```

### Pattern 2: Detect Over-Filtering
```dart
Future<bool> _isUserOverFiltering() async {
  final sessionData = FFAppState().menuSessionData;
  final history = sessionData['filterResultHistory'] as List? ?? [];

  if (history.length < 3) return false;

  // Check if last 3 interactions produced declining results
  final last3 = history.sublist(history.length - 3);
  return last3[0] > last3[1] && last3[1] > last3[2];
}
```

### Pattern 3: Suggest Filter Removal
```dart
Future<void> _checkAndSuggestFilterRemoval() async {
  final sessionData = FFAppState().menuSessionData;
  final currentResults = _visibleItems.length;

  if (currentResults == 0 || currentResults <= 2) {
    final zeroCount = sessionData['zeroResultCount'] as int? ?? 0;

    if (zeroCount >= 2) {
      // Show suggestion to remove filters
      _showSuggestion('Prøv at fjerne nogle filtre for flere resultater');
    }
  }
}
```

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Riverpod migration + debouncing optimization
