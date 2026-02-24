# openClosesAt Function

**Type:** Custom Function (Pure)
**File:** `custom_functions.dart` (lines 82-392)
**Category:** Business Hours & Status Display
**Status:** ✅ Production Ready
**Complexity:** ⚠️ Very High (~300 lines)

---

## Purpose

Determines if a business is currently open/closed and returns a localized status message indicating when it closes (if open) or when it opens next (if closed). Handles complex business hour scenarios including multiple time slots per day, overnight hours, and special closure conditions.

**Critical Function:** This is the **most complex function** in the entire codebase, handling 15+ edge cases for business hours calculation.

**Key Features:**
- Up to 5 time slots per day support
- Overnight hours handling (e.g., 22:00-02:00)
- Special cases (00:00, 24:00 closing times)
- "Closed" and "by_appointment_only" handling
- Multi-language support (15 languages)
- Previous day overnight spillover detection

---

## Function Signature

```dart
String openClosesAt(
  dynamic businessHours,
  DateTime currentDateTime,
  String? languageCode,
  dynamic translationsCache,
)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `businessHours` | `dynamic` | **Yes** | Map with day indices (0-6) as keys containing time slots and closure flags |
| `currentDateTime` | `DateTime` | **Yes** | The reference time for checking status |
| `languageCode` | `String?` | No | ISO language code (defaults to 'en' if null or unsupported) |
| `translationsCache` | `dynamic` | **Yes** | Translation cache from FFAppState |

### Returns

| Type | Description |
|------|-------------|
| `String` | Localized message indicating current status and next time change |

---

## Business Hours Data Structure

```dart
{
  "0": {  // Monday (0=Mon, 1=Tue, ..., 6=Sun)
    "closed": false,
    "by_appointment_only": false,

    // Time slot 1
    "opening_time_1": "10:00",
    "closing_time_1": "14:00",

    // Time slot 2 (optional)
    "opening_time_2": "17:00",
    "closing_time_2": "22:00",

    // Time slots 3-5 (optional)
    "opening_time_3": null,
    "closing_time_3": null,
    // ... up to slot 5

    // Cutoff times (optional - for kitchen/last orders)
    "cutoff_type_1_1": "kitchen",
    "cutoff_time_1_1": "13:30",
    "cutoff_note_1_1": "Kitchen closes early",
    // ... up to 2 cutoffs per slot
  },
  "1": { // Tuesday
    // ... same structure
  },
  // ... days 2-6
}
```

---

## Implementation Overview

### Constants

```dart
const int maxTimeSlotsPerDay = 5;
```

### Helper Functions

| Function | Purpose | Lines |
|----------|---------|-------|
| `_getLocalizedMessage` | Get translation from cache | 119-122 |
| `_convertTimeToMinutes` | Parse "HH:MM" to minutes since midnight | 124-144 |
| `_parseBool` | Parse dynamic bool (handles string "true"/"false") | 147-151 |
| `_isDayClosed` | Check if day is closed or by_appointment_only | 154-157 |
| `_checkDayOpenStatus` | Check if business is open at current time | 159-224 |
| `_checkPreviousDayOvernight` | Check overnight hours from previous day | 226-270 |
| `_findNextOpening` | Find next opening time in coming days | 272-305 |

### Main Logic Flow

```
1. Validate businessHours input
2. Convert to typed Map<String, dynamic>
3. Calculate current day index (0-6) and minutes since midnight
4. Check today's status (all time slots)
5. Check previous day's overnight status
6. Determine if currently open
7. If open: Return "closes at [TIME]" message
8. If closed: Find next opening and return "opens at [TIME]"
```

---

## Dependencies

### pub.dev Packages
- None (pure Dart function)

### Internal Dependencies
```dart
import 'custom_functions.dart';  // Calls getTranslations() internally
```

### Translation Keys Used

| Key | English | Danish | Usage |
|-----|---------|--------|-------|
| `hours_closes_at` | "til" | "til" | Normal closing time |
| `hours_closes_tomorrow` | "closes tomorrow at" | "lukker i morgen kl." | Overnight closing |
| `hours_closes_tonight` | "closes tonight at" | "lukker i nat kl." | Midnight closing |
| `hours_opens_at` | "opens at" | "åbner kl." | Opens later today |
| `hours_opens_tomorrow` | "opens tomorrow at" | "åbner i morgen kl." | Opens tomorrow |
| `hours_no_data` | "No hours available" | "Ingen åbningstider" | Missing/invalid data |

---

## Usage Examples

### Example 1: Restaurant Open Now (Single Time Slot)
**Input:**
```dart
final hours = {
  "0": {  // Monday
    "closed": false,
    "by_appointment_only": false,
    "opening_time_1": "10:00",
    "closing_time_1": "22:00",
  }
};

final result = functions.openClosesAt(
  hours,
  DateTime(2025, 2, 17, 15, 30),  // Monday 3:30 PM
  'en',
  translationsCache,
);
```

**Output:** `"til 22:00"`

---

### Example 2: Restaurant Open (Split Hours)
**Input:**
```dart
final hours = {
  "0": {
    "closed": false,
    "by_appointment_only": false,
    "opening_time_1": "11:00",
    "closing_time_1": "14:00",
    "opening_time_2": "17:00",
    "closing_time_2": "23:00",
  }
};

final result = functions.openClosesAt(
  hours,
  DateTime(2025, 2, 17, 12, 30),  // Monday 12:30 PM (in first slot)
  'da',
  translationsCache,
);
```

**Output:** `"til 14:00"` (closes after lunch)

---

### Example 3: Restaurant Closed (Opens Later Today)
**Input:**
```dart
final hours = {
  "0": {
    "closed": false,
    "by_appointment_only": false,
    "opening_time_1": "17:00",
    "closing_time_1": "23:00",
  }
};

final result = functions.openClosesAt(
  hours,
  DateTime(2025, 2, 17, 14, 00),  // Monday 2:00 PM
  'en',
  translationsCache,
);
```

**Output:** `"opens at 17:00"`

---

### Example 4: Overnight Hours (Open Past Midnight)
**Input:**
```dart
final hours = {
  "4": {  // Friday
    "closed": false,
    "by_appointment_only": false,
    "opening_time_1": "17:00",
    "closing_time_1": "02:00",  // Closes 2 AM Saturday
  }
};

final result = functions.openClosesAt(
  hours,
  DateTime(2025, 2, 21, 23, 30),  // Friday 11:30 PM
  'en',
  translationsCache,
);
```

**Output:** `"closes tomorrow at 02:00"`

---

### Example 5: Currently in Overnight Hours
**Input:**
```dart
final hours = {
  "4": {  // Friday
    "closed": false,
    "by_appointment_only": false,
    "opening_time_1": "17:00",
    "closing_time_1": "02:00",
  },
  "5": {  // Saturday
    "closed": false,
    "by_appointment_only": false,
    "opening_time_1": "12:00",
    "closing_time_1": "23:00",
  }
};

final result = functions.openClosesAt(
  hours,
  DateTime(2025, 2, 22, 01, 00),  // Saturday 1:00 AM (in Friday's overnight)
  'da',
  translationsCache,
);
```

**Output:** `"til 02:00"` (still in Friday's hours)

---

### Example 6: Closed (Day Marked Closed)
**Input:**
```dart
final hours = {
  "0": {  // Monday
    "closed": true,  // Explicitly closed
    "by_appointment_only": false,
    "opening_time_1": null,
    "closing_time_1": null,
  },
  "1": {  // Tuesday
    "closed": false,
    "by_appointment_only": false,
    "opening_time_1": "10:00",
    "closing_time_1": "22:00",
  }
};

final result = functions.openClosesAt(
  hours,
  DateTime(2025, 2, 17, 15, 00),  // Monday 3:00 PM
  'en',
  translationsCache,
);
```

**Output:** `"opens tomorrow at 10:00"`

---

### Example 7: By Appointment Only (Treated as Closed)
**Input:**
```dart
final hours = {
  "6": {  // Sunday
    "closed": false,
    "by_appointment_only": true,  // By appointment = closed for walk-ins
    "opening_time_1": "10:00",
    "closing_time_1": "18:00",
  }
};

final result = functions.openClosesAt(
  hours,
  DateTime(2025, 2, 23, 12, 00),  // Sunday 12:00 PM
  'da',
  translationsCache,
);
```

**Output:** `"åbner mandag kl. 10:00"` (shows next available walk-in time)

---

### Example 8: Special Case - 24:00 Closing
**Input:**
```dart
final hours = {
  "0": {
    "closed": false,
    "by_appointment_only": false,
    "opening_time_1": "00:00",
    "closing_time_1": "24:00",  // Open 24 hours
  }
};

final result = functions.openClosesAt(
  hours,
  DateTime(2025, 2, 17, 15, 00),
  'en',
  translationsCache,
);
```

**Output:** `"til 24:00"`

---

## Used By Pages

| Page | Usage | Purpose |
|------|-------|---------|
| **Search Results** | Display status on restaurant cards | Quick status visibility |
| **Business Profile** | Display status in header | Prominent status display |

---

## Used By Custom Widgets

| Widget | Usage | Purpose |
|--------|-------|---------|
| `RestaurantCardWidget` | Status text in card footer | "til 22:00" or "opens at 17:00" |
| `BusinessHeaderWidget` | Status in business header | Prominent display |
| `HoursDisplayWidget` | Calculate current status | Real-time status |

---

## Edge Cases Handled

### Edge Case 1: Null Business Hours
**Input:** `businessHours = null`

**Returns:** `"No hours available"` (localized)

---

### Edge Case 2: Empty Business Hours
**Input:** `businessHours = {}`

**Returns:** `"No hours available"` (localized)

---

### Edge Case 3: Overnight Hours (Closing < Opening)
**Example:** `opening_time_1 = "22:00"`, `closing_time_1 = "02:00"`

**Logic:**
```dart
if (closingMinutes < openingMinutes) {
  isOvernightType = true;
  isOpen = currentMinutes >= openingMinutes || currentMinutes < closingMinutes;
}
```

**Behavior:** Correctly handles cross-midnight hours

---

### Edge Case 4: 24:00 Closing (Midnight as 24:00)
**Example:** `closing_time_1 = "24:00"`

**Conversion:**
```dart
if (hours == 24 && minutes == 0) return 1440;
```

**Behavior:** Treated as overnight closing (end of day)

---

### Edge Case 5: 00:00 Closing (Midnight as 00:00)
**Example:** `closing_time_1 = "00:00"`

**Logic:**
```dart
if (closingMinutes == 0 && openingMinutes > 0 && openingMinutes < 1440) {
  isOvernightType = true;
  isOpen = currentMinutes >= openingMinutes;
}
```

**Behavior:** Treated as overnight closing (start of next day)

---

### Edge Case 6: Multiple Time Slots (Up to 5)
**Example:**
```dart
"opening_time_1": "06:00", "closing_time_1": "10:00",  // Breakfast
"opening_time_2": "11:00", "closing_time_2": "14:00",  // Lunch
"opening_time_3": "17:00", "closing_time_3": "23:00",  // Dinner
```

**Behavior:** Checks all slots sequentially, returns first matching slot

---

### Edge Case 7: Previous Day Overnight Spillover
**Scenario:** It's Saturday 1:00 AM, but Friday was open until 2:00 AM

**Logic:**
```dart
final yesterdayStatus = _checkPreviousDayOvernight(
  typedBusinessHours,
  previousDayIndex,
  currentMinutes,
);
```

**Behavior:** Correctly shows "til 02:00" (still in Friday's hours)

---

### Edge Case 8: Day Marked "closed" but Has Time Slots
**Example:**
```dart
"closed": true,
"opening_time_1": "10:00",
"closing_time_1": "22:00",
```

**Behavior:** `closed` flag takes precedence - treated as closed

---

### Edge Case 9: Day Marked "by_appointment_only"
**Example:**
```dart
"by_appointment_only": true,
"opening_time_1": "10:00",
"closing_time_1": "18:00",
```

**Behavior:** Treated same as `closed` for walk-in customers

---

### Edge Case 10: Invalid Time Format
**Example:** `opening_time_1 = "25:99"` (invalid)

**Returns:** `-1` from `_convertTimeToMinutes()`, slot skipped

**Behavior:** Ignores invalid slots, moves to next slot

---

### Edge Case 11: Null Language Code
**Input:** `languageCode = null`

**Behavior:** Defaults to 'en' internally

---

### Edge Case 12: All Days Closed for 7 Days
**Behavior:** Loops through all 7 days, returns `"No hours available"` if no opening found

---

## Time Conversion Logic

### _convertTimeToMinutes Function

```dart
int _convertTimeToMinutes(String? time) {
  if (time == null || time.isEmpty) return -1;

  try {
    final parts = time.split(':');
    if (parts.length < 2) return -1;

    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);

    // Special case: 24:00 = 1440 minutes
    if (hours == 24 && minutes == 0) return 1440;

    // Validate range
    if (hours >= 0 && hours < 24 && minutes >= 0 && minutes < 60) {
      return hours * 60 + minutes;
    }

    return -1;
  } catch (e) {
    return -1;
  }
}
```

**Examples:**
- `"10:00"` → `600` (10 * 60 + 0)
- `"14:30"` → `870` (14 * 60 + 30)
- `"00:00"` → `0` (midnight start)
- `"24:00"` → `1440` (midnight end)
- `"25:00"` → `-1` (invalid)

---

## Performance Considerations

### Time Complexity
- **Worst case: O(35)** - 5 time slots × 7 days
- **Average case: O(5)** - Usually finds status in current/next day

### Memory Usage
- **O(1)** - No dynamic allocations, only stack variables

### Execution Time
- **< 100 microseconds** - Very fast despite complexity

### Why No Caching?
- Status changes every minute
- Cache would require invalidation logic
- Re-calculation is faster than cache management
- Called once per restaurant card render (acceptable)

---

## Testing Checklist

When implementing in Flutter:

**Basic Scenarios:**
- [ ] Test restaurant open now (single slot) - returns "til HH:MM"
- [ ] Test restaurant closed now - returns "opens at HH:MM"
- [ ] Test restaurant with split hours (lunch/dinner) - returns correct slot

**Overnight Scenarios:**
- [ ] Test overnight hours (22:00-02:00) before midnight - "closes tomorrow at"
- [ ] Test overnight hours after midnight - still shows closing time
- [ ] Test 24:00 closing time - handled correctly
- [ ] Test 00:00 closing time - handled correctly

**Multi-Slot Scenarios:**
- [ ] Test 2 time slots (lunch + dinner) - correct slot selected
- [ ] Test 3 time slots (breakfast + lunch + dinner) - correct slot
- [ ] Test 5 time slots (maximum) - correct slot selected
- [ ] Test between slots (closed gap) - shows next opening

**Closure Scenarios:**
- [ ] Test day marked "closed" - shows next opening day
- [ ] Test "by_appointment_only" - treated as closed
- [ ] Test closed with time slots present - "closed" flag wins
- [ ] Test all days closed - returns "No hours available"

**Edge Cases:**
- [ ] Test null businessHours - returns error message
- [ ] Test empty businessHours map - returns error message
- [ ] Test invalid time format "25:99" - slot skipped
- [ ] Test null language code - defaults to English
- [ ] Test previous day overnight spillover - correct status

**Localization:**
- [ ] Test English output - correct translations
- [ ] Test Danish output - correct translations
- [ ] Test all 15 supported languages - correct output

**Performance:**
- [ ] Test 1000 calls - completes in < 100ms
- [ ] Test complex hours (5 slots × 7 days) - fast response

---

## Migration Notes

### Phase 3 Changes

**Keep function as-is** - pure Dart with no FlutterFlow-specific dependencies.

**Update calling code:**
```dart
// Before (FlutterFlow):
final status = functions.openClosesAt(
  businessItem.openingHours,
  getCurrentTimestamp,
  FFLocalizations.of(context).languageCode,
  FFAppState().translationsCache,
);

// After (Riverpod example):
final status = functions.openClosesAt(
  business.openingHours,
  DateTime.now(),
  Localizations.localeOf(context).languageCode,
  ref.watch(translationsCacheProvider),
);
```

**No changes to function logic** - it's already production-ready.

---

## Related Functions

| Function | Relationship |
|----------|-------------|
| `getTranslations` | Called internally for localized messages |
| `daysDayOpeningHour` | Alternative function for detailed hours display |

---

## Related Custom Actions

| Action | Relationship |
|--------|-------------|
| `getBusinessDetails` | Fetches businessHours data used by this function |
| `updateBusinessHours` | Updates hours that this function displays |

---

## Known Issues

1. **No timezone handling** - Assumes business hours in device timezone
2. **No daylight saving adjustment** - Could show incorrect status during DST transition
3. **No holiday handling** - Cannot show special holiday hours
4. **No temporary closures** - Cannot indicate temporary closure (e.g., "Closed for renovation")
5. **No real-time updates** - Status calculated once per render, not live-updated

**Severity:** Low - acceptable for restaurant discovery app

---

## Future Enhancements

1. **Add timezone support** - Handle businesses in different timezones
2. **Add holiday hours** - Special hours for holidays
3. **Add temporary closures** - "Closed until [date]" messages
4. **Add cutoff times display** - Show "Kitchen closes at 21:30" warnings
5. **Add caching with invalidation** - Cache status for 60 seconds
6. **Add real-time updates** - Live countdown "Closes in 15 minutes"

---

## Why This Function Is So Complex

### Handled Scenarios (15+)

1. Single time slot per day
2. Multiple time slots per day (up to 5)
3. Overnight hours (cross-midnight)
4. Previous day overnight spillover
5. 24:00 closing time (midnight as 24:00)
6. 00:00 closing time (midnight as 00:00)
7. Closed days (explicit "closed" flag)
8. By-appointment-only days
9. Invalid time formats
10. Missing time slots
11. Null business hours
12. Empty business hours
13. All days closed
14. Gap between time slots
15. Multi-language support (15 languages)

### Alternative Approach (Not Used)

**Simple approach:** Just show "Open" or "Closed"

**Problem:** Users want to know:
- "How long until it closes?"
- "When does it open?"
- "Is it worth going there now?"

**Solution:** This complex function provides actionable information, not just binary status.

---

**Last Updated:** 2026-02-19
**Migration Status:** ✅ Phase 3 - Keep as-is (production-ready)
**Priority:** ⭐⭐⭐⭐⭐ Critical (used on every restaurant card + profile)
**Complexity:** ⚠️ Very High (~300 lines, 15+ edge cases)
