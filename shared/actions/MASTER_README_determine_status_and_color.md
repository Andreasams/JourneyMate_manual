# determineStatusAndColor Action

**Type:** Custom Action (Async)
**File:** `determine_status_and_color.dart` (451 lines)
**Category:** Business Hours & Status
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐⭐⭐ (CRITICAL - Core business card display)

---

## Purpose

Analyzes complex business hours data to determine real-time open/closed status and sets appropriate status indicator colors. Handles sophisticated scheduling scenarios including multiple daily time slots, overnight hours, appointment-only periods, and "soon" thresholds.

**Key Features:**
- Determines if business is open, closed, opening soon, or closing soon
- Handles up to 5 time slots per day (e.g., lunch and dinner service)
- Supports overnight hours spanning midnight (22:00 to 02:00)
- Recognizes "closed" and "by_appointment_only" as closed status
- 30-minute "soon" thresholds for opening/closing
- Seven-day weekly schedule analysis
- Dynamic color callback (green for open, red for closed)
- Translation integration for status text

**Core Logic:**
This action is the single source of truth for business status across the app. It powers every business card status indicator and color dot.

---

## Function Signature

```dart
Future<String> determineStatusAndColor(
  Future Function(Color color) statuscolor,
  dynamic businessHoursInput,
  DateTime currentDateTime,
  String? languageCode,
  dynamic translationsCache,
)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `statuscolor` | `Future Function(Color)` | **Yes** | Callback to set status indicator color |
| `businessHoursInput` | `dynamic` | **Yes** | Business hours map (see structure below) |
| `currentDateTime` | `DateTime` | **Yes** | Current date/time for status calculation |
| `languageCode` | `String?` | No | ISO 639-1 language code (defaults to 'en') |
| `translationsCache` | `dynamic` | No | Translation cache from FFAppState |

### Returns

| Type | Description |
|------|-------------|
| `Future<String>` | Translated status text: "Open", "Closed", "Opening soon", "Closing soon" |

**Status Text Keys:**
- `'status_open'` - Currently open
- `'status_closed'` - Currently closed
- `'status_opening_soon'` - Opens within 30 minutes
- `'status_closing_soon'` - Closes within 30 minutes

**Color Values:**
- **Green** (`Color(0xFF518751)`) - Open or closing soon
- **Red** (`Color(0xFFFF5963)`) - Closed or opening soon

---

## Business Hours Structure

### Input Format

```dart
{
  "0": {  // Monday (0=Monday, 6=Sunday)
    "closed": false,                  // Day explicitly closed
    "by_appointment_only": false,     // By appointment (treated as closed)

    // Time slot 1
    "opening_time_1": "09:00",
    "closing_time_1": "14:00",
    "cutoff_type_1_1": "kitchen_close",
    "cutoff_time_1_1": "13:30",

    // Time slot 2 (e.g., dinner service)
    "opening_time_2": "17:00",
    "closing_time_2": "22:00",
    "cutoff_type_2_1": "kitchen_close",
    "cutoff_time_2_1": "21:30",

    // ... up to 5 slots per day
  },
  "1": { ... },  // Tuesday
  // ... through "6" (Sunday)
}
```

### Key Concepts

**Day Numbering:**
- `0` = Monday
- `1` = Tuesday
- `2` = Wednesday
- `3` = Thursday
- `4` = Friday
- `5` = Saturday
- `6` = Sunday

**Closed vs By Appointment:**
Both `"closed": true` and `"by_appointment_only": true` are treated identically as **closed** for status determination.

**Time Slot Numbering:**
- Slots numbered 1-5 per day
- `opening_time_1`, `closing_time_1` = first slot
- `opening_time_2`, `closing_time_2` = second slot
- etc.

**Overnight Hours:**
Hours that span midnight are detected automatically:
- `"22:00"` to `"02:00"` = overnight slot
- Closing time < opening time = overnight
- `"24:00"` = midnight (converted to 1440 minutes)

---

## Dependencies

### Internal Dependencies
```dart
import '/custom_code/actions/index.dart';
// Uses: getTranslations
```

**Translation Keys Used:**
- `'status_open'`
- `'status_closed'`
- `'status_opening_soon'`
- `'status_closing_soon'`

---

## Usage Examples

### Example 1: Basic Card Status
```dart
// In business card widget
Color statusColor = Colors.grey;

final statusText = await actions.determineStatusAndColor(
  (color) async {
    setState(() => statusColor = color);
  },
  businessItem['business_hours'],
  DateTime.now(),
  FFAppState().selectedLanguage,
  FFAppState().translationsCache,
);

// Display status
Text(
  statusText,
  style: TextStyle(
    color: statusColor,
    fontWeight: FontWeight.w600,
  ),
);
```

### Example 2: With State Management
```dart
// In StatefulWidget
String _statusText = '';
Color _statusColor = Colors.grey;

Future<void> _updateStatus() async {
  final text = await actions.determineStatusAndColor(
    (color) async {
      if (mounted) {
        setState(() => _statusColor = color);
      }
    },
    widget.businessHours,
    DateTime.now(),
    'da',
    FFAppState().translationsCache,
  );

  if (mounted) {
    setState(() => _statusText = text);
  }
}

@override
void initState() {
  super.initState();
  _updateStatus();
}
```

### Example 3: Periodic Updates
```dart
// Update status every minute
Timer.periodic(Duration(minutes: 1), (timer) async {
  final statusText = await actions.determineStatusAndColor(
    (color) async {
      setState(() => _model.statusColor = color);
    },
    _model.businessHours,
    DateTime.now(),
    FFAppState().selectedLanguage,
    FFAppState().translationsCache,
  );

  setState(() => _model.statusText = statusText);
});
```

---

## Core Algorithm

### High-Level Flow

```
1. Validate inputs (businessHoursInput, currentDateTime)
2. Normalize business hours to Map<String, dynamic>
3. Determine current day (0-6) and time in minutes
4. Check if currently open:
   a. Check today's time slots
   b. Check yesterday's overnight slots
5. If open:
   - Determine closing time
   - Check if closing within 30 minutes → "Closing soon"
   - Otherwise → "Open"
6. If closed:
   - Find next opening time
   - Check if opening within 30 minutes → "Opening soon"
   - Otherwise → "Closed"
7. Set color (green if open, red if closed)
8. Return translated status text
```

### Key Constants

```dart
const int soonThresholdMinutes = 30;      // "Soon" window
const int _maxTimeSlotsPerDay = 5;         // Max slots per day
const Color openColor = Color(0xFF518751); // Green
const Color closedColor = Color(0xFFFF5963); // Red
```

---

## Helper Functions

### Validation & Normalization

#### `_isValidBusinessHoursInput(dynamic input)`
Validates that business hours input is a non-null Map.

**Returns:** `bool` - True if valid

#### `_normalizeBusinessHours(dynamic input)`
Converts dynamic input to `Map<String, dynamic>` structure.

**Handles:**
- Type casting
- Key/value string conversion
- Nested map normalization

**Returns:** Normalized map (empty map on error)

### Day Status

#### `_parseBool(dynamic value)`
Safely parses boolean from dynamic input.

**Handles:**
- `bool` values (returns as-is)
- `String` values ("true"/"false")
- Other types (returns false)

**Returns:** `bool`

#### `_isDayClosed(Map<String, dynamic> dayHours)`
Determines if a day is effectively closed.

**Closed if:**
- `closed == true`
- `by_appointment_only == true`

**Returns:** `bool`

### Time Conversion

#### `_convertTimeToMinutes(String? timeString)`
Converts "HH:MM" time string to minutes since midnight.

**Examples:**
- `"09:00"` → `540`
- `"14:30"` → `870`
- `"24:00"` → `1440`
- Invalid → `-1`

**Validation:**
- Hours: 0-24
- Minutes: 0-59
- Special case: "24:00" = 1440 minutes

**Returns:** `int` - Minutes since midnight (-1 on error)

#### `_isOvernightTimeSlot(int openMinutes, int closeMinutes)`
Detects if time slot spans midnight.

**Overnight if:**
- `closeMinutes < openMinutes`
- `closeMinutes == 1440` (closes at midnight)
- `closeMinutes == 0 && openMinutes > 0`

**Returns:** `bool`

### Open Status Checking

#### `_checkOpenStatus(businessHours, day, currentMinutes)`
Checks if business is currently open based on today's hours.

**Process:**
1. Get day's hours
2. Return false if day is closed
3. Iterate through time slots (1-5)
4. Check if current time falls within any slot
5. Return slot info if open

**Returns:**
```dart
{
  'isOpen': bool,
  'nextTime': String?,           // Closing time "HH:MM"
  'isOvernightClose': bool,
  'slotIndex': int,             // Which slot (1-5)
}
```

#### `_checkPreviousDayOvernightStatus(businessHours, previousDay, currentMinutes)`
Checks if business is open from yesterday's overnight hours.

**Example:**
- Friday 22:00 - 02:00
- Current time: Saturday 01:30
- Result: Open (from Friday's overnight slot)

**Returns:** Same structure as `_checkOpenStatus`

#### `_getDayHours(businessHours, day)`
Retrieves hours for a specific day.

**Returns:** `Map<String, dynamic>?` - Day's hours (null if not found)

#### `_getTimeSlot(dayHours, slot)`
Extracts and validates a specific time slot.

**Returns:**
```dart
{
  'open': int,                  // Opening time in minutes
  'close': int,                 // Closing time in minutes
  'closeStr': String,           // "HH:MM" format
  'isOvernight': bool,
}
```

#### `_isCurrentlyInTimeSlot(currentMinutes, openMinutes, closeMinutes, isOvernight)`
Determines if current time falls within a time slot.

**Logic:**
- **Normal:** `currentMinutes >= openMinutes && currentMinutes < closeMinutes`
- **Overnight:** `currentMinutes >= openMinutes || currentMinutes < closeMinutes`

**Returns:** `bool`

### Closing Time Logic

#### `_getClosingTimeInfo(todayStatus, yesterdayStatus)`
Determines which closing time to use (today's or yesterday's overnight).

**Priority:**
1. Today's status if open
2. Yesterday's overnight if that's what's open

**Returns:**
```dart
{
  'closingTime': String?,       // "HH:MM"
  'isOvernight': bool,
}
```

#### `_isClosingSoon(closingInfo, currentMinutes, thresholdMinutes)`
Checks if closing within threshold (30 minutes).

**Returns:** `bool`

#### `_calculateMinutesUntilClosing(currentMinutes, closeMinutes, isOvernight)`
Calculates minutes until closing time.

**Logic:**
- **Normal:** `closeMinutes - currentMinutes`
- **Overnight (before midnight):** `(closeMinutes + 1440) - currentMinutes`
- **Overnight (after midnight):** `closeMinutes - currentMinutes`

**Returns:** `int` - Minutes until closing

### Opening Time Logic

#### `_isOpeningSoon(businessHours, currentDay, currentMinutes, thresholdMinutes)`
Checks if opening within threshold (30 minutes).

**Process:**
1. Find next opening time
2. Return false if not today (offsetDays != 0)
3. Calculate minutes until opening
4. Return true if within threshold

**Returns:** `bool`

#### `_findNextOpeningTime(businessHours, startDay, currentMinutes)`
Finds the next opening time across the weekly schedule.

**Search Strategy:**
1. Start from current day
2. Check each day for up to 7 days
3. Skip closed/appointment-only days
4. For each day, check time slots 1-5
5. Return first slot after current time

**Returns:**
```dart
{
  'time': String,               // "HH:MM" or "N/A"
  'offsetDays': int,            // Days from now (-1 if none found)
}
```

---

## Status Determination Logic

### Primary Decision Tree

```
Is currently open?
├─ YES → Check closing time
│  ├─ Closing within 30 min → "Closing soon" (GREEN)
│  └─ Not closing soon → "Open" (GREEN)
└─ NO → Check next opening
   ├─ Opening within 30 min → "Opening soon" (RED)
   └─ Not opening soon → "Closed" (RED)
```

### "Currently Open" Determination

**Open if ANY of:**
1. Current time within today's time slot
2. Current time within yesterday's overnight slot

**Example Scenarios:**

**Scenario 1: Normal Hours**
```
Monday: 09:00 - 17:00
Current: Monday 14:30
Result: OPEN (in slot 1)
```

**Scenario 2: Overnight Hours**
```
Friday: 22:00 - 02:00
Current: Saturday 01:30
Result: OPEN (yesterday's overnight)
```

**Scenario 3: Multiple Slots**
```
Tuesday: 11:00-14:00, 17:00-22:00
Current: Tuesday 18:00
Result: OPEN (in slot 2)
```

**Scenario 4: Between Slots**
```
Wednesday: 11:00-14:00, 17:00-22:00
Current: Wednesday 15:30
Result: CLOSED (between slots)
```

### "Soon" Threshold Logic

**Opening Soon:**
- Currently closed
- Next opening is TODAY
- Next opening within 30 minutes

**Closing Soon:**
- Currently open
- Closing time within 30 minutes

**Examples:**

```
Scenario: Opens at 11:00
Current: 10:35
Result: "Opening soon" (RED)

Scenario: Opens at 11:00
Current: 10:25
Result: "Opening soon" (RED)

Scenario: Opens at 11:00
Current: 10:29
Result: "Opening soon" (RED)

Scenario: Opens at 11:00
Current: 10:31 (31 min away)
Result: "Closed" (RED)
```

```
Scenario: Closes at 22:00
Current: 21:45
Result: "Closing soon" (GREEN)

Scenario: Closes at 22:00
Current: 21:29
Result: "Closing soon" (GREEN)

Scenario: Closes at 22:00
Current: 21:28
Result: "Open" (GREEN)
```

---

## Edge Cases

### Edge Case 1: Closed All Day
```dart
{
  "0": {
    "closed": true,
    "by_appointment_only": false,
    "opening_time_1": "09:00",  // Ignored
    "closing_time_1": "17:00",  // Ignored
  }
}
```
**Result:** CLOSED (red), checks tomorrow for next opening

### Edge Case 2: By Appointment Only
```dart
{
  "0": {
    "closed": false,
    "by_appointment_only": true,
    "opening_time_1": "09:00",  // Ignored
    "closing_time_1": "17:00",  // Ignored
  }
}
```
**Result:** CLOSED (red), treated identically to `closed: true`

### Edge Case 3: Midnight Closing (24:00)
```dart
{
  "0": {
    "opening_time_1": "00:00",
    "closing_time_1": "24:00",  // Converted to 1440 minutes
  }
}
```
**Result:** Open all day (00:00 to 23:59)

### Edge Case 4: Overnight Spanning Weekend
```dart
{
  "6": {  // Sunday
    "opening_time_1": "22:00",
    "closing_time_1": "02:00",
  }
}
```
**Current:** Monday 01:00
**Result:** OPEN (from Sunday's overnight)

### Edge Case 5: Invalid Time Format
```dart
{
  "0": {
    "opening_time_1": "9:00",     // Invalid (should be "09:00")
    "closing_time_1": "25:00",    // Invalid (hours > 24)
  }
}
```
**Result:** Slot ignored, returns CLOSED

### Edge Case 6: No Business Hours
```dart
businessHoursInput = null
```
**Result:** CLOSED (red), returns translated "Closed" text

### Edge Case 7: Empty Time Slots
```dart
{
  "0": {
    "closed": false,
    "by_appointment_only": false,
    // No time slots defined
  }
}
```
**Result:** CLOSED (no valid slots)

---

## Error Handling

### Error 1: Invalid Business Hours Input
```
Guard: !_isValidBusinessHoursInput(businessHoursInput)
Action: Return CLOSED with red color
Log: None (silent fallback)
```

### Error 2: Null currentDateTime
```
Guard: currentDateTime == null
Action: Return CLOSED with red color
Log: None (silent fallback)
```

### Error 3: Time Parsing Failure
```dart
debugPrint('DSAC Error parsing time "$timeString": $e');
```
**Fallback:** Returns `-1`, slot treated as invalid

### Error 4: Normalization Failure
```dart
debugPrint('DSAC Error normalizing business hours: $e');
```
**Fallback:** Returns empty map, business treated as closed

---

## Translation Keys

### Required Translations

```dart
// Status texts
'status_open'          → "Open" / "Åben"
'status_closed'        → "Closed" / "Lukket"
'status_opening_soon'  → "Opening soon" / "Åbner snart"
'status_closing_soon'  → "Closing soon" / "Lukker snart"
```

### Language Support
- English (`'en'`)
- Danish (`'da'`)
- Extensible to additional languages via translation cache

---

## Performance Considerations

### Computational Complexity
- **Best Case:** O(1) - First time slot matches
- **Average Case:** O(5) - Check all slots for current day
- **Worst Case:** O(35) - Check 7 days × 5 slots for next opening

### Optimization Opportunities
1. **Cache results** - Status changes at most once per minute
2. **Early exit** - Stop searching after finding next opening
3. **Lazy evaluation** - Only search for next opening if currently closed

### Blocking Time
- **Duration:** <1ms (pure computation, no I/O)
- **Blocks UI:** No (fast enough for synchronous execution)
- **Network:** None required

### Memory Usage
- **Input:** ~2KB for full weekly schedule
- **Working memory:** ~1KB for intermediate calculations
- **Total:** Negligible (<5KB)

---

## Used By

### Pages
1. **Search Results Page** - Status indicator on every business card
2. **Business Profile Page** - Header status display
3. **Map View** - Map marker status colors

### Widgets
1. **BusinessCard** - Primary usage for card status
2. **BusinessCardCompact** - Condensed card status
3. **MapMarker** - Color-coded map pins

---

## Testing Checklist

### Basic Functionality
- [ ] Returns "Open" when currently in time slot
- [ ] Returns "Closed" when outside all time slots
- [ ] Color callback sets green for open
- [ ] Color callback sets red for closed
- [ ] Translates status text correctly

### Time Slot Scenarios
- [ ] Single time slot per day works
- [ ] Multiple time slots per day work
- [ ] Overnight hours detected correctly
- [ ] Hours spanning midnight work
- [ ] 24:00 closing time handled

### "Soon" Thresholds
- [ ] "Opening soon" at 29 minutes before
- [ ] "Opening soon" at 30 minutes before
- [ ] "Closed" at 31 minutes before
- [ ] "Closing soon" at 29 minutes before
- [ ] "Closing soon" at 30 minutes before
- [ ] "Open" at 31 minutes before closing

### Special Cases
- [ ] Closed day returns "Closed"
- [ ] By appointment returns "Closed"
- [ ] Empty time slots handled
- [ ] Invalid time format handled
- [ ] Null business hours handled
- [ ] Null currentDateTime handled

### Day Transitions
- [ ] Overnight from Friday to Saturday works
- [ ] Overnight from Sunday to Monday works
- [ ] Status updates correctly at midnight
- [ ] Next opening found across week boundary

### Edge Cases
- [ ] Business open 24 hours
- [ ] Business closed all week
- [ ] Only weekend hours defined
- [ ] Gap between lunch and dinner service
- [ ] Time exactly at opening time
- [ ] Time exactly at closing time

---

## Debug Output

### Normal Operation
```
(No debug output - silent operation for performance)
```

### Error Conditions
```
DSAC Error parsing time "25:00": FormatException: Invalid time format
DSAC Error normalizing business hours: type 'String' is not a subtype of type 'Map'
```

---

## Migration Notes

### Phase 3 Changes

#### 1. Replace Color Callback with Return Value
```dart
// Before (FlutterFlow pattern):
Color statusColor;
final statusText = await determineStatusAndColor(
  (color) async { statusColor = color; },
  businessHours,
  DateTime.now(),
  'da',
  cache,
);

// After (Clean pattern):
final result = await determineStatusAndColor(
  businessHours,
  DateTime.now(),
  'da',
  cache,
);
// result = {statusText: "Open", color: Color(0xFF518751)}
```

#### 2. Add Result Caching
```dart
class StatusCache {
  String? _lastStatusText;
  Color? _lastColor;
  DateTime? _lastCheck;

  Future<StatusResult> getStatus(businessHours) async {
    final now = DateTime.now();

    // Cache valid for 60 seconds
    if (_lastCheck != null &&
        now.difference(_lastCheck!) < Duration(seconds: 60)) {
      return StatusResult(_lastStatusText!, _lastColor!);
    }

    final result = await determineStatusAndColor(...);
    _lastCheck = now;
    return result;
  }
}
```

#### 3. Make Synchronous
Since there's no async I/O, consider making this synchronous:

```dart
// Current (unnecessarily async):
Future<String> determineStatusAndColor(...) async {
  await statuscolor(color);  // Only async operation
  return text;
}

// Improved:
StatusResult determineStatusAndColor(...) {
  // Direct return, no await needed
  return StatusResult(text: text, color: color);
}
```

#### 4. Add Time Zone Support
```dart
// Add timezone parameter
String determineStatusAndColor(
  businessHours,
  DateTime currentDateTime,
  String timeZone,  // NEW: e.g., "Europe/Copenhagen"
  languageCode,
  cache,
) {
  final localTime = TZDateTime.from(currentDateTime, getLocation(timeZone));
  // Rest of logic...
}
```

---

## Related Actions

| Action | Purpose | Relationship |
|--------|---------|--------------|
| `getTranslations` | Translate status text | Called internally for each status |
| `openClosesAt` | Format detailed hours text | Complementary (shows hours, not just status) |

---

## Known Issues

### Issue 1: No Timezone Support
**Problem:** Assumes all times are in app's local timezone
**Impact:** Incorrect status for businesses in different timezones
**Workaround:** Only use for businesses in user's timezone
**Fix:** Add timezone parameter and conversion logic

### Issue 2: Cutoff Times Ignored
**Problem:** `cutoff_type_1_1` and `cutoff_time_1_1` fields are ignored
**Impact:** Kitchen closing times don't affect open/closed status
**Expected:** Business might show "Open" but kitchen is closed
**Fix:** Add cutoff time logic to status determination

### Issue 3: No Half-Status
**Problem:** Only two states: open (green) or closed (red)
**Impact:** Can't show "Kitchen closed but bar open"
**Potential:** Add third status: "Limited service" (yellow/orange)

### Issue 4: Soon Threshold Hardcoded
**Problem:** 30-minute threshold not configurable
**Impact:** Can't adjust "soon" window per business type
**Example:** Fast food might want 15 min, fine dining 60 min

### Issue 5: Callback Pattern Anti-Pattern
**Problem:** Async callback for color is unnecessary complexity
**Impact:** Forces caller to manage mutable state
**Fix:** Return struct with both text and color

---

## Real-World Examples

### Example 1: Restaurant with Split Service
```dart
// Italian restaurant: lunch and dinner
{
  "0": {
    "opening_time_1": "11:00",
    "closing_time_1": "14:30",
    "opening_time_2": "17:00",
    "closing_time_2": "22:00",
  }
}

// Test cases:
10:30 → "Opening soon" (RED)
11:15 → "Open" (GREEN)
14:15 → "Closing soon" (GREEN)
15:30 → "Closed" (RED)
16:35 → "Opening soon" (RED)
18:00 → "Open" (GREEN)
21:45 → "Closing soon" (GREEN)
22:15 → "Closed" (RED)
```

### Example 2: Late Night Bar
```dart
// Bar open until 2 AM
{
  "4": {  // Friday
    "opening_time_1": "18:00",
    "closing_time_1": "02:00",  // Saturday morning
  }
}

// Test cases:
Friday 17:30 → "Opening soon" (RED)
Friday 19:00 → "Open" (GREEN)
Friday 23:00 → "Open" (GREEN)
Saturday 00:30 → "Open" (GREEN) [from Friday's overnight]
Saturday 01:45 → "Closing soon" (GREEN)
Saturday 02:15 → "Closed" (RED)
```

### Example 3: 24-Hour Diner
```dart
{
  "0": {  // Monday
    "opening_time_1": "00:00",
    "closing_time_1": "24:00",
  },
  // ... same for all days
}

// Result: Always "Open" (GREEN)
```

### Example 4: Weekend Brunch Place
```dart
{
  "0": {"closed": true},        // Monday
  "1": {"closed": true},        // Tuesday
  "2": {"closed": true},        // Wednesday
  "3": {"closed": true},        // Thursday
  "4": {"closed": true},        // Friday
  "5": {                        // Saturday
    "opening_time_1": "09:00",
    "closing_time_1": "15:00",
  },
  "6": {                        // Sunday
    "opening_time_1": "09:00",
    "closing_time_1": "15:00",
  }
}

// Monday-Friday: "Closed" (RED)
// Saturday/Sunday 08:30 → "Opening soon" (RED)
// Saturday/Sunday 11:00 → "Open" (GREEN)
```

---

## Security Notes

✅ **Safe:**
- No external I/O
- No user input processing
- No database access
- Pure computation on trusted data

⚠️ **Considerations:**
- Business hours data trusted as valid
- No sanitization of time strings (minor parsing risk)
- Debug prints may expose business hours structure

**Recommendation:** No security changes needed. This is low-risk pure logic.

---

## Future Enhancements

### Enhancement 1: Cutoff Time Support
Add kitchen/bar closing logic:
```dart
// Show "Kitchen closing soon" instead of just "Closing soon"
// Use cutoff_time_1_1 for more accurate status
```

### Enhancement 2: Multi-Status Support
```dart
enum BusinessStatus {
  open,
  closingSoon,
  kitchenClosed,    // NEW
  barOnly,          // NEW
  openingSoon,
  closed,
}
```

### Enhancement 3: Holiday Hours
```dart
// Add special hours for holidays
{
  "holidays": {
    "2026-12-25": {"closed": true},
    "2026-12-31": {
      "opening_time_1": "18:00",
      "closing_time_1": "02:00",
    }
  }
}
```

### Enhancement 4: Configurable Soon Threshold
```dart
// Per-business customization
"soon_threshold_minutes": 45  // Instead of hardcoded 30
```

### Enhancement 5: Smart Refresh
```dart
// Return next status change time
return {
  'text': "Open",
  'color': greenColor,
  'nextChange': DateTime(2026, 2, 19, 22, 0),  // When it closes
  'nextStatus': "Closed",
};
```

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Flutter Implementation
**Complexity:** ⭐⭐⭐⭐⭐ (Very High - 451 lines, 19 helper functions)
