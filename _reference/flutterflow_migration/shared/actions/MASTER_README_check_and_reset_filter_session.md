# checkAndResetFilterSession Action

**Type:** Custom Action (Async)
**File:** `check_and_reset_filter_session.dart` (97 lines)
**Category:** Search & Filters
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐⭐ (High - Session management)

---

## Purpose

Manages filter session lifecycle with refinement tracking. Detects when user clears all filters and search text, ending the current session and starting a new one. Tracks refinement sequence for analytics.

**Key Features:**
- Detects complete reset (both search text and filters empty)
- Ends current session and starts new session with new UUID
- Increments refinement sequence for each search modification
- Tracks `filter_session_ended` and `filter_session_started` analytics
- Links sessions with previousSessionId for funnel analysis

---

## Function Signature

```dart
Future<void> checkAndResetFilterSession(
  String searchText,
  List<int> activeFilters,
)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `searchText` | `String` | **Yes** | Current search text |
| `activeFilters` | `List<int>` | **Yes** | Current active filter IDs |

### Returns

| Type | Description |
|------|-------------|
| `Future<void>` | No return value |

---

## Dependencies

### Internal Dependencies
```dart
import '/custom_code/actions/index.dart';           // trackAnalyticsEvent, generateAndStoreFilterSessionId
```

### FFAppState Usage

#### Reads
| State Variable | Type | Purpose |
|---------------|------|---------|
| `hasActiveSearch` | `bool` | Whether session is active |
| `currentFilterSessionId` | `String` | Current session UUID |
| `currentRefinementSequence` | `int` | Refinement counter |

#### Writes
| State Variable | Type | Purpose |
|---------------|------|---------|
| `hasActiveSearch` | `bool` | Set to true/false based on content |
| `currentFilterSessionId` | `String` | New UUID on reset |
| `currentRefinementSequence` | `int` | Incremented or reset |
| `lastRefinementTime` | `DateTime?` | Timestamp of last refinement |
| `previousActiveFilters` | `List<int>` | Cleared on reset |
| `previousSearchText` | `String` | Cleared on reset |
| `previousFilterSessionId` | `String` | Set to old session ID on reset |

---

## Behavior Logic

### Case 1: Complete Reset (Both Empty After Having Content)
```
Conditions:
- FFAppState().hasActiveSearch == true (was active)
- searchText.isEmpty (now empty)
- activeFilters.isEmpty (now empty)

Actions:
1. Track 'filter_session_ended' analytics
2. Store old session ID
3. Generate new session ID
4. Track 'filter_session_started' analytics
5. Reset refinement sequence to 0
6. Clear previous state
7. Set hasActiveSearch = false
```

### Case 2: First Refinement (Content Added to Empty Session)
```
Conditions:
- FFAppState().hasActiveSearch == false (was inactive)
- searchText.isNotEmpty OR activeFilters.isNotEmpty

Actions:
1. Set hasActiveSearch = true
2. Set currentRefinementSequence = 1
3. Set lastRefinementTime = now
```

### Case 3: Subsequent Refinement (Content Changed)
```
Conditions:
- FFAppState().hasActiveSearch == true (already active)
- searchText.isNotEmpty OR activeFilters.isNotEmpty

Actions:
1. Increment currentRefinementSequence
2. Update lastRefinementTime = now
```

### Case 4: No-Op (Both Empty, Was Inactive)
```
Conditions:
- searchText.isEmpty
- activeFilters.isEmpty
- FFAppState().hasActiveSearch == false

Actions:
- No state changes
- No analytics
```

---

## Usage Examples

### Example 1: Called from Search Action
```dart
// In performSearchAndUpdateState or performSearchBarUpdateState
Future<void> _performSearch(String searchText, List<int> filterIds) async {
  // ... API call ...

  // Check if session needs reset
  await actions.checkAndResetFilterSession(searchText, filterIds);

  // ... continue with analytics ...
}
```

### Example 2: Manual Reset Tracking
```dart
// When user clicks "Clear All" button
Future<void> _onClearAllPressed() async {
  // Clear UI
  setState(() {
    _searchController.clear();
    _selectedFilters.clear();
  });

  // Trigger session reset
  await actions.checkAndResetFilterSession('', []);

  // Optionally trigger new search
  await _performSearch();
}
```

---

## Analytics Events

### Event 1: Session Ended
**Event Type:** `filter_session_ended`

**Event Data:**
```dart
{
  'filterSessionId': String,              // Ending session UUID
  'reason': 'user_cleared',               // Always this value
  'totalRefinements': int,                // Number of refinements in session
  'resultedInClicks': false,              // Updated by business_clicked if applicable
}
```

### Event 2: Session Started
**Event Type:** `filter_session_started`

**Event Data:**
```dart
{
  'filterSessionId': String,              // New session UUID
  'previousSessionId': String,            // Old session UUID (for funnel tracking)
}
```

---

## State Flow Diagram

```
┌─────────────────────────────────────────┐
│ User State                               │
├─────────────────────────────────────────┤
│ 1. Empty (No search, no filters)        │
│    hasActiveSearch = false              │
│    currentRefinementSequence = 0        │
└─────────────┬───────────────────────────┘
              │ Add content
              ▼
┌─────────────────────────────────────────┐
│ 2. First Refinement                      │
│    hasActiveSearch = true               │
│    currentRefinementSequence = 1        │
└─────────────┬───────────────────────────┘
              │ Change filters/text
              ▼
┌─────────────────────────────────────────┐
│ 3. Subsequent Refinements                │
│    currentRefinementSequence = 2, 3, 4...│
└─────────────┬───────────────────────────┘
              │ Clear all
              ▼
┌─────────────────────────────────────────┐
│ 4. Reset                                 │
│    Track session_ended                  │
│    Generate new session ID              │
│    Track session_started                │
│    Reset to state #1                    │
└─────────────────────────────────────────┘
```

---

## Debug Output

### Complete Reset
```
🔄 Reset detected - ending current session
[analytics: filter_session_ended]
[analytics: filter_session_started]
✅ Reset complete - new session: abc123de...
```

### First Refinement
```
🆕 First refinement in session
```

### Subsequent Refinement
```
🔄 Refinement #3
```

### No-Op
```
⚪ No active search state
```

---

## Testing Checklist

- [ ] Start with empty state → first refinement sets sequence = 1
- [ ] Add filter → refinement increments
- [ ] Change search text → refinement increments
- [ ] Clear all (text + filters) → session ends, new session starts
- [ ] Verify session IDs link (previousSessionId matches old ID)
- [ ] Check refinement sequence resets to 0 after clear
- [ ] Verify hasActiveSearch toggles correctly
- [ ] Test multiple clear cycles → new session each time

---

## Migration Notes

### Phase 3 Changes

1. **Replace FFAppState with Riverpod:**
   ```dart
   // Before:
   final wasActive = FFAppState().hasActiveSearch;

   // After:
   final wasActive = ref.read(filterSessionProvider).hasActiveSearch;
   ```

2. **Keep session linking** - previousSessionId enables funnel analysis
3. **Keep refinement tracking** - Critical for understanding user search behavior

---

## Related Actions

| Action | Purpose | Relationship |
|--------|---------|--------------|
| `generateAndStoreFilterSessionId` | Creates new session UUID | Called on reset |
| `updatePreviousFilterState` | Stores previous state | Called after analytics |
| `trackAnalyticsEvent` | Analytics tracking | Called for session events |

---

## Used By Actions

1. **performSearchAndUpdateState** - Filter overlay searches
2. **performSearchBarUpdateState** - Search bar searches

---

## Known Issues

1. **resultedInClicks always false** - Updated later by business_clicked event
2. **No session timeout** - Sessions never expire automatically
3. **No maximum refinement limit** - Could track infinite refinements

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Riverpod migration
