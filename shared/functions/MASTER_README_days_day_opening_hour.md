# daysDayOpeningHour — Custom Function Documentation

**Function:** `daysDayOpeningHour`
**File:** `custom_functions.dart` (lines 674-914)
**Category:** Business hours display and status reporting
**Used in:** Business Profile page (Contact Details section), business detail views

---

## Purpose

Returns localized opening hours status and schedule information for a specific day. Unlike `openClosesAt` which returns dynamic status messages based on current time ("closes at 18:00", "opens tomorrow"), this function returns a formatted day schedule or next opening information suitable for display in contact details sections.

**Output formats:**
- **If currently open:** "[DayName] - [OpenTime] - [CloseTime]" (e.g., "Monday - 12:00 - 22:00")
- **If closed but opens later today:** "Closed - opens later at [Time]"
- **If closed until tomorrow:** "Closed - opens again tomorrow at [Time]"
- **If closed until future day:** "Closed - opens again on [DayName] at [Time]"
- **If no valid hours found:** "Closed"

This function is designed for **static display** of business hours in contact information, providing users with clear scheduling information rather than real-time status updates.

---

## Function Signature

```dart
String daysDayOpeningHour(
  DateTime currentTime,
  dynamic openingHours,
  String languageCode,
  dynamic translationsCache,
)
```

---

## Parameters

### `currentTime` (DateTime)
- **Purpose:** Reference timestamp for determining current day and time
- **Type:** `DateTime` object with date, hour, minute information
- **Usage:** Extracted to `weekday` (1-7, Monday-Sunday) and minutes since midnight
- **Example:** `DateTime.now()` for real-time evaluation

### `openingHours` (dynamic)
- **Purpose:** Complete opening hours data structure for all days of the week
- **Expected Type:** `Map<String, dynamic>` with day indices as keys
- **Structure:**
  ```dart
  {
    "0": {  // Monday (weekday - 1)
      "closed": false,
      "by_appointment_only": false,
      "opening_time_1": "12:00:00",
      "closing_time_1": "22:00:00",
      "opening_time_2": null,  // Additional slots if needed
      "closing_time_2": null,
      // ... up to opening_time_5/closing_time_5
    },
    "1": { /* Tuesday */ },
    // ... through "6" (Sunday)
  }
  ```
- **Validation:** Returns "Closed" if null or not a Map

### `languageCode` (String)
- **Purpose:** ISO 639-1 language code for localized output
- **Supported:** 'da', 'en', 'de', 'sv', 'no', 'it', 'fr', and other languages in translation system
- **Usage:** Passed to `getTranslations()` for localized day names and status text
- **Example:** `'da'`, `'en'`, `'de'`

### `translationsCache` (dynamic)
- **Purpose:** Pre-loaded translation cache from FFAppState
- **Type:** `Map<String, dynamic>` or JSON string containing translation key-value pairs
- **Usage:** Passed to `getTranslations()` helper for efficient localized text retrieval
- **Required Keys:**
  - `day_monday_cap`, `day_monday_lower` (and similar for all weekdays)
  - `hours_closed`
  - `hours_opens_later`
  - `hours_opens_again`
  - `hours_tomorrow`
  - `hours_on`
  - `hours_at`

---

## Return Value

**Type:** `String`

**Format depends on current business status:**

### Currently Open
```dart
"Monday - 12:00 - 22:00"
// [Capitalized Day Name] - [Opening Time] - [Closing Time]
```

### Closed, Opens Later Today
```dart
"Closed - opens later at 18:00"
// Uses 'hours_closed' + 'hours_opens_later' + time
```

### Closed, Opens Tomorrow
```dart
"Closed - opens again tomorrow at 11:00"
// Uses 'hours_closed' + 'hours_opens_again' + 'hours_tomorrow' + 'hours_at' + time
```

### Closed, Opens on Future Day
```dart
"Closed - opens again on tuesday at 11:00"
// Uses 'hours_closed' + 'hours_opens_again' + 'hours_on' + [lowercase day] + 'hours_at' + time
```

### No Valid Hours Data
```dart
"Closed"
// Default fallback when no hours available
```

---

## Dependencies

### Internal Helper Functions

#### `_getUIText(String key)`
- **Purpose:** Retrieves localized text from translation cache
- **Implementation:** Wrapper for `getTranslations(languageCode, key, translationsCache)`
- **Used for:** All UI strings (day names, status messages)

#### `_getDayKey(int dayIndex)`
- **Purpose:** Converts day index (0-6) to translation key suffix
- **Mapping:**
  ```dart
  0 → 'monday'
  1 → 'tuesday'
  2 → 'wednesday'
  3 → 'thursday'
  4 → 'friday'
  5 → 'saturday'
  6 → 'sunday'
  ```

#### `_getDayNameCapitalized(int dayIndex)`
- **Purpose:** Gets capitalized day name for current day display
- **Translation Key Pattern:** `day_[daykey]_cap` (e.g., `day_monday_cap`)
- **Example Output:** "Monday", "Mandag" (da), "Montag" (de)

#### `_getDayNameLowercase(int dayIndex)`
- **Purpose:** Gets lowercase day name for future day references
- **Translation Key Pattern:** `day_[daykey]_lower` (e.g., `day_monday_lower`)
- **Example Output:** "monday", "mandag" (da), "montag" (de)

#### `_convertTimeToMinutes(String? timeStr)`
- **Purpose:** Converts time string to minutes since midnight for comparison
- **Input Format:** "HH:MM:SS" or "HH:MM"
- **Returns:** Integer minutes (0-1440), or -1 if invalid
- **Special Cases:**
  - `"24:00:00"` → `1440`
  - `null` or empty → `-1`
  - Invalid format → `-1`

#### `_formatTimeForDisplay(String? timeStr)`
- **Purpose:** Extracts HH:MM from time string for display
- **Input:** "HH:MM:SS" or "HH:MM"
- **Output:** "HH:MM" (first 5 characters)
- **Returns empty string if null or too short**

#### `_parseBool(dynamic value)`
- **Purpose:** Safely converts dynamic input to boolean
- **Handles:**
  - `bool` type → direct return
  - `String` "true"/"false" → parsed (case-insensitive)
  - Other types → `false`

#### `_isDayClosed(dynamic dayHoursRaw)`
- **Purpose:** Determines if a day is effectively closed
- **Returns true if:**
  - `closed == true`
  - `by_appointment_only == true` (treated as closed for walk-ins)
- **Returns false if:** Day hours data is null or not a Map

#### `_checkIfOpenNow(Map<String, String?> dayHours, int currentMinutes)`
- **Purpose:** Checks if business is open at current time within day's time slots
- **Logic:**
  - Iterates through slots 1-5
  - Handles overnight hours (closing < opening)
  - Handles 00:00 closing times (treated as 24:00 / 1440 minutes)
- **Returns:** `Map<String, String>?` with `openTime` and `closeTime` keys if open, null otherwise

#### `_findLaterOpeningToday(Map<String, String?> dayHours, int currentMinutes)`
- **Purpose:** Finds next opening time slot later in the same day
- **Returns:** Opening time string if found, null otherwise
- **Used for:** "Closed - opens later at [Time]" message

#### `_findFutureOpening(Map<String, String?> dayHours)`
- **Purpose:** Finds first valid opening time in a future day
- **Returns:** Opening time string for first valid slot, null if none

### External Dependencies

#### `getTranslations(languageCode, key, translationsCache)`
- **Purpose:** Central translation retrieval function
- **Returns:** Localized string for given key and language
- **Fallback:** Returns empty string or key itself if translation missing

---

## FFAppState Usage

### Read Access

**translationsCache:**
- **Source:** `FFAppState().translationsCache`
- **Type:** `Map<String, dynamic>` or JSON string
- **Purpose:** Pre-loaded translation key-value pairs
- **Loaded at:** App initialization, language change
- **Required Keys:**
  ```dart
  'day_monday_cap', 'day_monday_lower'
  'day_tuesday_cap', 'day_tuesday_lower'
  'day_wednesday_cap', 'day_wednesday_lower'
  'day_thursday_cap', 'day_thursday_lower'
  'day_friday_cap', 'day_friday_lower'
  'day_saturday_cap', 'day_saturday_lower'
  'day_sunday_cap', 'day_sunday_lower'
  'hours_closed'
  'hours_opens_later'
  'hours_opens_again'
  'hours_tomorrow'
  'hours_on'
  'hours_at'
  ```

### No State Modifications
This function is **read-only** and does not modify any FFAppState variables.

---

## Usage Examples

### Example 1: Currently Open (Single Slot)
```dart
final openingHours = {
  "0": {  // Monday
    "closed": false,
    "by_appointment_only": false,
    "opening_time_1": "11:00:00",
    "closing_time_1": "22:00:00",
  }
};

final currentTime = DateTime(2025, 2, 19, 14, 30);  // Monday 14:30
final result = daysDayOpeningHour(
  currentTime,
  openingHours,
  'en',
  translationsCache,
);
// Returns: "Monday - 11:00 - 22:00"
```

### Example 2: Closed, Opens Later Today
```dart
final openingHours = {
  "0": {  // Monday
    "closed": false,
    "by_appointment_only": false,
    "opening_time_1": "17:00:00",
    "closing_time_1": "23:00:00",
  }
};

final currentTime = DateTime(2025, 2, 19, 14, 30);  // Monday 14:30
final result = daysDayOpeningHour(
  currentTime,
  openingHours,
  'en',
  translationsCache,
);
// Returns: "Closed - opens later at 17:00"
```

### Example 3: Closed, Opens Tomorrow
```dart
final openingHours = {
  "0": {  // Monday - CLOSED
    "closed": true,
  },
  "1": {  // Tuesday - OPEN
    "closed": false,
    "opening_time_1": "11:00:00",
    "closing_time_1": "22:00:00",
  }
};

final currentTime = DateTime(2025, 2, 19, 20, 0);  // Monday 20:00
final result = daysDayOpeningHour(
  currentTime,
  openingHours,
  'en',
  translationsCache,
);
// Returns: "Closed - opens again tomorrow at 11:00"
```

### Example 4: Closed, Opens on Specific Day
```dart
final openingHours = {
  "0": { "closed": true },  // Monday - CLOSED
  "1": { "closed": true },  // Tuesday - CLOSED
  "2": { "closed": true },  // Wednesday - CLOSED
  "3": {  // Thursday - OPEN
    "closed": false,
    "opening_time_1": "12:00:00",
    "closing_time_1": "21:00:00",
  }
};

final currentTime = DateTime(2025, 2, 19, 10, 0);  // Monday 10:00
final result = daysDayOpeningHour(
  currentTime,
  openingHours,
  'en',
  translationsCache,
);
// Returns: "Closed - opens again on thursday at 12:00"
```

### Example 5: Multiple Time Slots per Day
```dart
final openingHours = {
  "0": {  // Monday
    "closed": false,
    "by_appointment_only": false,
    "opening_time_1": "11:00:00",
    "closing_time_1": "14:00:00",  // Lunch service
    "opening_time_2": "17:00:00",
    "closing_time_2": "23:00:00",  // Dinner service
  }
};

final currentTime = DateTime(2025, 2, 19, 12, 30);  // Monday 12:30 (lunch)
final result = daysDayOpeningHour(
  currentTime,
  openingHours,
  'en',
  translationsCache,
);
// Returns: "Monday - 11:00 - 14:00"
// (Shows current active slot)

final currentTime2 = DateTime(2025, 2, 19, 15, 30);  // Monday 15:30 (closed)
final result2 = daysDayOpeningHour(
  currentTime2,
  openingHours,
  'en',
  translationsCache,
);
// Returns: "Closed - opens later at 17:00"
```

### Example 6: Overnight Hours
```dart
final openingHours = {
  "5": {  // Saturday
    "closed": false,
    "opening_time_1": "22:00:00",
    "closing_time_1": "02:00:00",  // Closes Sunday 02:00
  }
};

final currentTime = DateTime(2025, 2, 22, 23, 30);  // Saturday 23:30
final result = daysDayOpeningHour(
  currentTime,
  openingHours,
  'en',
  translationsCache,
);
// Returns: "Saturday - 22:00 - 02:00"
```

### Example 7: By Appointment Only (Treated as Closed)
```dart
final openingHours = {
  "6": {  // Sunday
    "closed": false,
    "by_appointment_only": true,
    "opening_time_1": "10:00:00",
    "closing_time_1": "16:00:00",
  }
};

final currentTime = DateTime(2025, 2, 23, 12, 0);  // Sunday 12:00
final result = daysDayOpeningHour(
  currentTime,
  openingHours,
  'en',
  translationsCache,
);
// Returns: "Closed - ..." (finds next regular opening day)
// by_appointment_only is treated as effectively closed
```

---

## Edge Cases

### 1. Null or Invalid Opening Hours
```dart
daysDayOpeningHour(DateTime.now(), null, 'en', cache);
// Returns: "Closed"

daysDayOpeningHour(DateTime.now(), "invalid", 'en', cache);
// Returns: "Closed"
```

### 2. Empty Day Data
```dart
final openingHours = {
  "0": {},  // No hours defined
};
// Returns: "Closed" (no valid time slots found)
```

### 3. All Days Closed
```dart
final openingHours = {
  "0": {"closed": true},
  "1": {"closed": true},
  "2": {"closed": true},
  "3": {"closed": true},
  "4": {"closed": true},
  "5": {"closed": true},
  "6": {"closed": true},
};
// Returns: "Closed" (no future opening found within 7 days)
```

### 4. Invalid Time Format
```dart
final openingHours = {
  "0": {
    "closed": false,
    "opening_time_1": "25:00:00",  // Invalid hour
    "closing_time_1": "22:00:00",
  }
};
// _convertTimeToMinutes returns -1 for invalid times
// Slot is skipped, function continues to next available slot or returns "Closed"
```

### 5. Midnight Closing (00:00)
```dart
final openingHours = {
  "0": {
    "closed": false,
    "opening_time_1": "20:00:00",
    "closing_time_1": "00:00:00",  // Midnight
  }
};
// "00:00:00" is converted to 1440 minutes (24:00 equivalent)
// Treated as closing at end of same day, not start of next day
```

### 6. Time Exactly at Opening
```dart
final currentTime = DateTime(2025, 2, 19, 11, 0);  // Monday 11:00 exactly
final openingHours = {
  "0": {
    "opening_time_1": "11:00:00",
    "closing_time_1": "22:00:00",
  }
};
// Returns: "Monday - 11:00 - 22:00"
// Opening time is inclusive (currentMinutes >= openingMinutes)
```

### 7. Time Exactly at Closing
```dart
final currentTime = DateTime(2025, 2, 19, 22, 0);  // Monday 22:00 exactly
final openingHours = {
  "0": {
    "opening_time_1": "11:00:00",
    "closing_time_1": "22:00:00",
  }
};
// Returns: "Closed - ..." (finds next opening)
// Closing time is exclusive (currentMinutes < closingMinutes)
```

### 8. Sunday Wrapping to Monday
```dart
final currentTime = DateTime(2025, 2, 23, 20, 0);  // Sunday 20:00
final openingHours = {
  "6": {"closed": true},  // Sunday closed
  "0": {  // Monday open
    "opening_time_1": "11:00:00",
    "closing_time_1": "22:00:00",
  }
};
// Returns: "Closed - opens again tomorrow at 11:00"
// Correctly wraps from Sunday (index 6) to Monday (index 0)
```

### 9. Multiple Slots with Gaps
```dart
final openingHours = {
  "0": {
    "opening_time_1": "08:00:00",
    "closing_time_1": "11:00:00",  // Breakfast
    "opening_time_2": "12:00:00",
    "closing_time_2": "14:00:00",  // Lunch
    "opening_time_3": "18:00:00",
    "closing_time_3": "23:00:00",  // Dinner
  }
};

// At 10:30 - returns: "Monday - 08:00 - 11:00" (current slot)
// At 11:30 - returns: "Closed - opens later at 12:00" (between slots)
// At 13:00 - returns: "Monday - 12:00 - 14:00" (second slot)
// At 16:00 - returns: "Closed - opens later at 18:00" (between slots)
```

### 10. Missing Translation Keys
```dart
// If translation key missing, getTranslations returns empty string
// Function may return incomplete strings like: "Closed -  at 17:00"
// Best practice: Ensure all required translation keys are present
```

---

## Relationship to `openClosesAt` Function

Both functions work with the same opening hours data structure but serve **different purposes**:

### `openClosesAt` (lines 82-392)
- **Purpose:** Real-time status messages for **current moment**
- **Output Style:** Dynamic, user-facing status
- **Examples:**
  - "closes at 18:00"
  - "opens tomorrow at 11:00"
  - "closes tomorrow at 02:00" (overnight)
- **Use Case:** Live status indicators in search results, business cards
- **Context:** Helps users answer "Can I go there NOW?"

### `daysDayOpeningHour` (lines 674-914)
- **Purpose:** Day schedule display for **contact information**
- **Output Style:** Structured day + time range or next opening
- **Examples:**
  - "Monday - 12:00 - 22:00"
  - "Closed - opens later at 17:00"
  - "Closed - opens again on thursday at 12:00"
- **Use Case:** Business profile contact details section
- **Context:** Helps users answer "What are the regular hours?"

### Key Differences

| Aspect | openClosesAt | daysDayOpeningHour |
|--------|--------------|-------------------|
| **Overnight handling** | Sophisticated ("closes tomorrow at 02:00") | Basic (shows single slot time) |
| **Previous day check** | Yes (checks if open from yesterday's overnight) | No |
| **Day name format** | Not included in output | Included (capitalized for current day) |
| **Time format** | "HH:MM" with context | "HH:MM - HH:MM" range |
| **Slot preference** | Current/next relevant | First valid slot for display |
| **Localization keys** | hours_closes_at, hours_opens_tomorrow, etc. | hours_closed, hours_opens_again, day names |

### When to Use Each

**Use `openClosesAt` when:**
- Displaying live status in search results
- Showing "open now" / "closes soon" indicators
- User needs to know immediate availability

**Use `daysDayOpeningHour` when:**
- Displaying contact information section
- Showing "today's hours" in business profile
- User needs to know regular schedule

### Complementary Usage Example
```dart
// Search Result Card
final status = openClosesAt(hours, DateTime.now(), lang, cache);
// → "closes at 22:00"

// Business Profile Contact Section
final schedule = daysDayOpeningHour(DateTime.now(), hours, lang, cache);
// → "Monday - 11:00 - 22:00"
```

---

## Testing Checklist

### Basic Functionality
- [ ] Returns correct format when currently open (single slot)
- [ ] Returns correct format when currently open (multiple slots - shows active one)
- [ ] Returns "Closed - opens later at [Time]" when closed but opens later same day
- [ ] Returns "Closed - opens again tomorrow at [Time]" when closed until next day
- [ ] Returns "Closed - opens again on [day] at [Time]" when closed for multiple days
- [ ] Returns "Closed" when no valid hours found in 7-day window

### Edge Cases - Time Handling
- [ ] Handles midnight closing (00:00) correctly (treats as 1440 minutes)
- [ ] Handles overnight hours (closing < opening) correctly
- [ ] Handles time exactly at opening (inclusive)
- [ ] Handles time exactly at closing (exclusive)
- [ ] Handles invalid time formats gracefully (skips invalid slots)

### Edge Cases - Day Handling
- [ ] Handles Sunday → Monday wrapping correctly
- [ ] Handles all days closed scenario
- [ ] Handles by_appointment_only as closed
- [ ] Handles explicit closed flag
- [ ] Handles missing day data in hours map

### Edge Cases - Multiple Slots
- [ ] Shows correct slot when business has multiple slots per day
- [ ] Finds next slot later in day when between slots
- [ ] Iterates through slots 1-5 correctly
- [ ] Skips null/empty time slots

### Localization
- [ ] Returns capitalized day name for current day display
- [ ] Returns lowercase day name for future day references
- [ ] Uses correct translation keys for all status messages
- [ ] Handles missing translation keys gracefully (via getTranslations fallback)
- [ ] Works correctly for all supported languages (da, en, de, sv, no, it, fr)

### Data Validation
- [ ] Returns "Closed" when openingHours is null
- [ ] Returns "Closed" when openingHours is not a Map
- [ ] Handles empty day data objects
- [ ] Handles missing time slot fields (null opening/closing times)

### Time Calculation
- [ ] Correctly converts DateTime.weekday (1-7) to day index (0-6)
- [ ] Correctly calculates minutes since midnight
- [ ] Correctly compares current time against slot times
- [ ] Correctly checks all 5 possible time slots per day

### Integration Testing
- [ ] Works with real FlutterFlow opening hours data from Supabase
- [ ] Integrates correctly with getTranslations function
- [ ] Integrates correctly with translationsCache from FFAppState
- [ ] Output format matches UI expectations in Business Profile page

### Performance
- [ ] Handles large opening hours maps efficiently (7 days × 5 slots)
- [ ] Helper function calls are reasonably optimized
- [ ] Translation lookups don't cause performance issues

### Comparison with openClosesAt
- [ ] Both functions handle same data structure correctly
- [ ] Both functions use same time conversion logic
- [ ] Output formats are appropriately different for their use cases
- [ ] Both handle overnight hours (though with different messaging)

---

## Migration Notes

### From FlutterFlow to Pure Flutter

**Location in FlutterFlow:**
- File: `lib/flutter_flow/custom_functions.dart`
- Lines: 674-914

**Migration Steps:**

1. **Copy function signature and body** directly - function is pure Dart with no FlutterFlow-specific dependencies

2. **Ensure dependencies are available:**
   ```dart
   // Must be imported:
   import 'package:flutter/material.dart';  // For debugPrint
   ```

3. **Verify translation system integration:**
   - Ensure `getTranslations()` function is available
   - Ensure `translationsCache` is accessible from state management
   - Verify all required translation keys are present

4. **Replace FFAppState access:**
   ```dart
   // FlutterFlow:
   final cache = FFAppState().translationsCache;

   // Pure Flutter (Provider example):
   final cache = context.read<AppState>().translationsCache;

   // Pure Flutter (Riverpod example):
   final cache = ref.read(translationsCacheProvider);
   ```

5. **Test with real data:**
   - Use actual business opening hours from Supabase
   - Test all edge cases listed above
   - Verify output matches expected UI format

### Potential Issues

**Translation Key Dependencies:**
- Function requires 20+ translation keys (day names × 2, status messages)
- Missing keys will result in incomplete/malformed output
- **Recommendation:** Validate all keys exist before using function

**Time Zone Considerations:**
- Function uses `DateTime.weekday` and `DateTime.hour/minute` directly
- No time zone conversion performed
- **Recommendation:** Ensure `currentTime` parameter is in business's local time zone

**State Management:**
- FlutterFlow uses `FFAppState().translationsCache`
- Pure Flutter may use Provider, Riverpod, Bloc, etc.
- **Recommendation:** Adapt state access pattern to your chosen solution

### Integration with Business Profile Page

**Typical usage in Business Profile:**
```dart
// In Contact Details section
final currentHoursDisplay = daysDayOpeningHour(
  DateTime.now(),
  businessData['opening_hours'],
  appState.currentLanguage,
  appState.translationsCache,
);

// Display in UI:
Text(
  currentHoursDisplay,
  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
);
```

**Complementary status indicator:**
```dart
// Show both schedule AND real-time status
final schedule = daysDayOpeningHour(...);  // "Monday - 11:00 - 22:00"
final status = openClosesAt(...);          // "closes at 22:00"

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(schedule),  // Regular hours
    Text(status, style: TextStyle(color: Colors.green)),  // Live status
  ],
);
```

### Testing in Pure Flutter

**Unit test example:**
```dart
test('daysDayOpeningHour returns correct format when open', () {
  final openingHours = {
    "0": {
      "closed": false,
      "opening_time_1": "11:00:00",
      "closing_time_1": "22:00:00",
    }
  };

  final mockCache = {
    'day_monday_cap': 'Monday',
    'hours_closed': 'Closed',
    // ... other required keys
  };

  final result = daysDayOpeningHour(
    DateTime(2025, 2, 19, 14, 30),  // Monday 14:30
    openingHours,
    'en',
    mockCache,
  );

  expect(result, equals('Monday - 11:00 - 22:00'));
});
```

---

## Related Documentation

- **MASTER_README_open_closes_at.md** — Real-time status messages
- **MASTER_README_get_translations.md** — Translation system
- **opening_hours_data_structure.md** — Opening hours schema documentation
- **business_profile_page_audit.md** — Usage context in UI

---

**Last Updated:** 2026-02-19
**Documented By:** Claude Code (Sonnet 4.5)
**Status:** ✅ Complete - Ready for migration
