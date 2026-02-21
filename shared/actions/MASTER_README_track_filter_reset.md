# trackFilterReset Action

**Type:** Custom Action (Async)
**File:** `track_filter_reset.dart` (70 lines)
**Category:** Search & Filters (Menu-Specific)
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐ (Medium - Menu analytics)

---

## Purpose

Tracks when user resets/clears all **menu filters** (allergens, dietary restrictions). Updates session-level reset counter and sends individual reset event for understanding filter abandonment patterns and user friction.

**Key Features:**
- Specific to menu filter resets (not search page filters)
- Updates menuSessionData.filterResets counter
- Tracks individual reset event with context
- Marks user as engaged (extends engagement window)
- Safely handles missing session data

**Context:** Menu filters are different from search filters - they control which menu items are visible based on allergens and dietary preferences.

---

## Function Signature

```dart
Future<void> trackFilterReset(int businessId)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `businessId` | `int` | **Yes** | ID of business whose menu is being viewed |

### Returns

| Type | Description |
|------|-------------|
| `Future<void>` | No return value |

---

## Dependencies

### Internal Dependencies
```dart
import '/custom_code/actions/index.dart';           // trackAnalyticsEvent, markUserEngaged
```

### FFAppState Usage

#### Reads
| State Variable | Type | Purpose |
|---------------|------|---------|
| `menuSessionData` | `Map<String, dynamic>` | Menu session context |
| `menuSessionData['menuSessionId']` | `String` | Menu session UUID |
| `menuSessionData['filterResets']` | `int` | Current reset count |
| `menuSessionData['filterInteractions']` | `int` | Total filter interactions |

#### Writes
| State Variable | Type | Purpose |
|---------------|------|---------|
| `menuSessionData['filterResets']` | `int` | Incremented reset count |

---

## Usage Examples

### Example 1: Clear All Filters Button
```dart
// In menu page with filter controls
Widget _buildClearFiltersButton() {
  return TextButton(
    onPressed: () async {
      // Clear filter state
      setState(() {
        _selectedAllergens.clear();
        _selectedDietary.clear();
      });

      // Track reset
      await actions.trackFilterReset(widget.businessId);

      // Reload menu items
      _refreshMenuItems();
    },
    child: Text('Ryd alle'),
  );
}
```

### Example 2: With Confirmation
```dart
Future<void> _onClearFiltersPressed() async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Ryd alle filtre?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Annuller'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Ryd'),
        ),
      ],
    ),
  );

  if (confirm == true) {
    _clearFilters();
    await actions.trackFilterReset(widget.businessId);
  }
}
```

### Example 3: Auto-Reset on Menu Exit
```dart
@override
void dispose() {
  // If user had filters active and exits without clearing
  if (_hadActiveFilters && !_userClearedFilters) {
    // Don't track as reset - user just left
  }
  super.dispose();
}
```

---

## Analytics Event

### Event Type: `menu_filters_reset`

**Event Data:**
```dart
{
  'menu_session_id': String,                    // Menu session UUID
  'business_id': int,                           // Business ID
  'reset_number': int,                          // Reset count in this session
  'total_interactions_before_reset': int,       // Filter interactions before reset
}
```

**Example:**
```json
{
  "menu_session_id": "550e8400-e29b-41d4-a716-446655440000",
  "business_id": 42,
  "reset_number": 2,
  "total_interactions_before_reset": 7
}
```

**Interpretation:**
- User has reset filters twice in this menu session
- Before this reset, they had 7 filter interactions
- High reset count = filter friction or exploration

---

## Session Data Structure

```dart
FFAppState().menuSessionData = {
  'menuSessionId': '550e8400-...',      // UUID for this menu session
  'filterResets': 2,                    // Number of resets
  'filterInteractions': 7,              // Total filter clicks/changes
  // ... other menu session metrics
};
```

---

## Error Handling

### Error 1: No Active Menu Session
```
⚠️ Cannot track filter reset - no active menu session
```
**Cause:** User on menu page but session not started
**Impact:** Reset not tracked (silent failure)
**Fix:** Ensure `startMenuSession()` called on menu page `initState`

### Error 2: Exception During Tracking
```
⚠️ Failed to track filter reset: [error]
   Stack trace: [stack trace]
```
**Cause:** Analytics API error or data structure issue
**Impact:** Reset counter updated but analytics event lost
**Fix:** Check analytics endpoint and session data structure

---

## Workflow

```
1. Check if menuSessionData exists and has menuSessionId
2. If no session → log warning and return
3. Read current filterResets count
4. Increment reset count
5. Update menuSessionData.filterResets
6. Track 'menu_filters_reset' analytics event
7. Call markUserEngaged() to extend engagement window
```

---

## Debug Output

### Success
```
🔄 Menu filters reset (#2)
```

### No Active Session
```
⚠️ Cannot track filter reset - no active menu session
```

### Error
```
⚠️ Failed to track filter reset: Exception: Analytics failed
   Stack trace: ...
```

---

## Testing Checklist

- [ ] Start menu session with `startMenuSession()`
- [ ] Reset filters → filterResets increments
- [ ] Reset again → filterResets = 2
- [ ] Check analytics event sent with correct data
- [ ] Verify markUserEngaged() extends engagement window
- [ ] Test without active session → warning logged
- [ ] Check filterInteractions count included in event
- [ ] Reset multiple times in one session → all tracked

---

## Migration Notes

### Phase 3 Changes

1. **Replace FFAppState with Riverpod:**
   ```dart
   // Before:
   final sessionData = FFAppState().menuSessionData;

   // After:
   final sessionData = ref.read(menuSessionProvider).sessionData;
   ```

2. **Keep reset tracking** - Important for UX analytics
3. **Consider adding reset reasons:**
   ```dart
   await trackFilterReset(businessId, reason: 'found_nothing');
   await trackFilterReset(businessId, reason: 'too_many_filters');
   ```

---

## Related Actions

| Action | Purpose | Relationship |
|--------|---------|--------------|
| `startMenuSession` | Start menu session | Must be called first |
| `endMenuSession` | End menu session | Receives final filterResets count |
| `updateMenuSessionFilterMetrics` | Update filter interaction count | Increments filterInteractions |
| `markUserEngaged` | Extend engagement window | Called after reset |
| `trackAnalyticsEvent` | Analytics tracking | Called internally |

---

## Used By Pages

1. **Menu Full Page** - Clear all filters button

---

## Known Issues

1. **No validation of reset validity** - Could be called without active filters
2. **No maximum reset limit** - Could track infinite resets
3. **Silent failure when no session** - May hide integration bugs

---

## Analytics Use Cases

**This data helps answer:**
- How often do users reset filters?
- Do users reset because they filtered too much?
- Does high reset count correlate with menu exit?
- Are filters confusing or too restrictive?

**Example Analysis:**
```sql
-- High reset rate = filter friction
SELECT business_id, AVG(reset_number) as avg_resets
FROM menu_filters_reset
GROUP BY business_id
HAVING avg_resets > 2;
```

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Riverpod migration
