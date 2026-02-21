# updatePreviousFilterState Action

**Type:** Custom Action (Async)
**File:** `update_previous_filter_state.dart` (43 lines)
**Category:** Search & Filters
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐⭐ (High - State tracking)

---

## Purpose

Updates previous state tracking for next refinement comparison. Stores current filter state and search text as "previous" so the next refinement can detect what changed. **Critical** for analytics calculations like `timeSincePreviousRefinement`.

**Key Features:**
- Stores current filters as previous for next comparison
- Stores current search text as previous
- Updates `lastRefinementTime` for timing calculations
- Called AFTER `trackAnalyticsEvent('filter_applied', ...)` completes

---

## Function Signature

```dart
Future<void> updatePreviousFilterState(
  List<int> currentFilters,
  String? currentSearchText,
)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `currentFilters` | `List<int>` | **Yes** | Current active filter IDs |
| `currentSearchText` | `String?` | No | Current search text (nullable) |

### Returns

| Type | Description |
|------|-------------|
| `Future<void>` | No return value |

---

## Dependencies

### No External Dependencies
Uses only `FFAppState`.

### FFAppState Usage

#### Writes
| State Variable | Type | Purpose |
|---------------|------|---------|
| `previousActiveFilters` | `List<int>` | Stored copy of currentFilters |
| `previousSearchText` | `String` | Stored copy of currentSearchText |
| `lastRefinementTime` | `DateTime` | Timestamp of this refinement |

---

## Usage Examples

### Example 1: Standard Usage (After Analytics)
```dart
// In performSearchAndUpdateState
async function performSearch() {
  // 1. Perform search
  final results = await _callSearchAPI();

  // 2. Track analytics
  await actions.trackAnalyticsEvent('filter_applied', eventData);

  // 3. Update previous state (AFTER analytics)
  await actions.updatePreviousFilterState(
    currentFilters,
    currentSearchText,
  );
}
```

### Example 2: Null Search Text
```dart
// When search text is empty
await actions.updatePreviousFilterState(
  [1, 2, 3],  // Current filters
  null,       // No search text
);

// Result:
// FFAppState().previousSearchText = ''  (empty string, not null)
```

### Example 3: Called from performSearchBarUpdateState
```dart
// Inside performSearchBarUpdateState action
try {
  // Build and track analytics
  await trackAnalyticsEvent('filter_applied', analyticsEventData);

  // Update previous state for next comparison
  await updatePreviousFilterState(filterIds, searchText);

  // Update timestamp for next refinement timing
  FFAppState().update(() {
    FFAppState().lastRefinementTime = DateTime.now();
  });
} catch (analyticsError) {
  debugPrint('Analytics failed: $analyticsError');
}
```

---

## Why This Matters

### Enables Analytics Comparisons

**Next refinement can calculate:**
```dart
// In buildFilterAppliedEventData (next refinement):

// 1. What changed?
final added = current.where((id) => !previous.contains(id));
final removed = previous.where((id) => !current.contains(id));

// 2. How long since last change?
final timeSincePrevious = DateTime.now().difference(lastRefinementTime).inSeconds;

// 3. Did search text change?
final searchTextChanged = currentSearchText != previousSearchText;
```

**Without this action:** Analytics can't detect what changed between refinements.

---

## State Flow

```
Refinement #1:
  Current: [1, 2], "pizza"
  Previous: [], ""
  ↓ updatePreviousFilterState
  Previous becomes: [1, 2], "pizza"

Refinement #2:
  Current: [1, 2, 3], "pizza"
  Previous: [1, 2], "pizza"  ← From previous call
  Can detect: Filter 3 added, search unchanged
  ↓ updatePreviousFilterState
  Previous becomes: [1, 2, 3], "pizza"

Refinement #3:
  Current: [1, 3], "italian"
  Previous: [1, 2, 3], "pizza"  ← From previous call
  Can detect: Filter 2 removed, search changed
```

---

## Debug Output

```
📝 Updated previous state: 3 filters
⏰ Updated lastRefinementTime: 2026-02-19 14:32:18.000
```

---

## Testing Checklist

- [ ] Call with empty filters → previousActiveFilters = []
- [ ] Call with null search text → previousSearchText = '' (empty string)
- [ ] Call with filters → previousActiveFilters matches input
- [ ] Verify lastRefinementTime updated to current time
- [ ] Call twice → second call overwrites first
- [ ] Check List.from creates copy (not reference)
- [ ] Verify timestamp accuracy within 1 second

---

## Migration Notes

### Phase 3 Changes

1. **Replace FFAppState with Riverpod:**
   ```dart
   // Before:
   FFAppState().update(() {
     FFAppState().previousActiveFilters = List<int>.from(currentFilters);
     FFAppState().previousSearchText = currentSearchText ?? '';
     FFAppState().lastRefinementTime = DateTime.now();
   });

   // After:
   ref.read(filterSessionProvider.notifier).updatePreviousState(
     filters: currentFilters,
     searchText: currentSearchText ?? '',
   );
   ```

2. **Keep timestamp update** - Critical for timing analytics
3. **Keep List.from copy** - Prevents reference issues

---

## Related Actions

| Action | Purpose | Relationship |
|--------|---------|--------------|
| `performSearchAndUpdateState` | Filter overlay search | Calls this after analytics |
| `performSearchBarUpdateState` | Search bar search | Calls this after analytics |
| `trackAnalyticsEvent` | Analytics tracking | Called before this |

---

## Used By Actions

1. **performSearchAndUpdateState**
2. **performSearchBarUpdateState**

---

## Known Issues

**None** - Simple state update action with no known issues.

---

## Important Timing

**CRITICAL:** Must be called **AFTER** `trackAnalyticsEvent`, not before:

```dart
// ✅ CORRECT ORDER:
await trackAnalyticsEvent('filter_applied', eventData);
await updatePreviousFilterState(filters, searchText);

// ❌ WRONG ORDER:
await updatePreviousFilterState(filters, searchText);  // Too early!
await trackAnalyticsEvent('filter_applied', eventData);  // Can't compare changes
```

**Reason:** `trackAnalyticsEvent` needs to compare current vs previous state. If you update previous state first, comparison will show no changes.

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Riverpod migration
