# OpeningHoursAndWeekdays Custom Widget

**Source File:** `_flutterflow_export/lib/custom_code/widgets/opening_hours_and_weekdays.dart`
**Widget Type:** StatefulWidget (Custom UI Component)
**Lines of Code:** 393
**Last Updated:** 2026-02-19

---

## Purpose

Displays a restaurant's weekly opening hours with full internationalization support across 15 languages. The widget renders a seven-day schedule with localized weekday names, showing up to 5 time slots per day and handling complex scenarios including:

- Multiple time periods per day (e.g., lunch and dinner service)
- Typed cutoff times with labels (e.g., "Kitchen: 22:00", "Last order: 23:30")
- Closed days and by-appointment-only days
- Dynamic layout that wraps cutoff times on a new line when text scaling is ≥1.1× or bold text is enabled
- Language-adaptive column widths (e.g., German weekday names need 110px, Chinese needs 75px)
- Automatic rebuilds when translations cache or language changes

**Key Design Principle:** This widget is purely presentational. It does NOT determine business status (open/closed) — that logic lives in the `determineStatusAndColor` custom action.

---

## Function Signature

```dart
class OpeningHoursAndWeekdays extends StatefulWidget {
  const OpeningHoursAndWeekdays({
    super.key,
    this.width,
    this.height,
    required this.languageCode,
    required this.translationsCache,
    this.openingHours,
  });

  final double? width;
  final double? height;
  final String languageCode;
  final dynamic translationsCache;
  final dynamic openingHours;
}
```

---

## Parameters

### Required Parameters

#### `languageCode` (String)
- **Purpose:** ISO 639-1 language code for localization
- **Source:** `FFLocalizations.of(context).languageCode` or `FFAppState().languageCode`
- **Supported Languages:** `da`, `de`, `en`, `es`, `fi`, `fr`, `it`, `ja`, `ko`, `nl`, `no`, `pl`, `sv`, `uk`, `zh`
- **Impact:** Controls weekday names, status labels, and day name column width
- **Example:** `'da'` → "Mandag", `'en'` → "Monday", `'zh'` → "星期一"

#### `translationsCache` (dynamic)
- **Purpose:** Pre-loaded translations map from FFAppState
- **Source:** `FFAppState().translationsCache`
- **Type:** `Map<String, Map<String, String>>` (but passed as dynamic)
- **Structure:**
  ```dart
  {
    'en': {
      'day_monday_cap': 'Monday',
      'hours_closed': 'Closed',
      'hours_kitchen': 'Kitchen',
      ...
    },
    'da': {...},
    ...
  }
  ```
- **Why Required:** Widget calls `getTranslations()` function to fetch localized strings

### Optional Parameters

#### `openingHours` (dynamic)
- **Purpose:** Weekly schedule data structure
- **Type:** `Map<String, dynamic>` (but passed as dynamic for FlutterFlow compatibility)
- **Default:** `{}` (empty map) if null
- **Structure:** See "Opening Hours Data Structure" section below

#### `width` (double?)
- **Purpose:** Fixed width constraint
- **Default:** `double.infinity` (full available width)
- **Usage:** Rarely set explicitly; typically omitted to fill parent container

#### `height` (double?)
- **Purpose:** Fixed height constraint
- **Default:** Automatically sizes to content
- **Usage:** Can be set if parent requires explicit height, but usually omitted

---

## Opening Hours Data Structure

The `openingHours` parameter expects this schema:

```dart
{
  "0": {  // Monday (0=Monday, 6=Sunday)
    "closed": false,                  // Day is closed (no service)
    "by_appointment_only": false,     // Day requires appointment (treated as closed in display)

    // Time slot 1 (e.g., lunch service)
    "opening_time_1": "11:00",
    "closing_time_1": "14:00",
    "cutoff_type_1_1": "last_order",  // Optional: cutoff type enum
    "cutoff_time_1_1": "13:30",       // Optional: cutoff time
    "cutoff_note_1_1": "Note text",   // Optional: cutoff note (not displayed in current implementation)
    "cutoff_type_1_2": "kitchen_close", // Optional: second cutoff for same slot
    "cutoff_time_1_2": "13:45",

    // Time slot 2 (e.g., dinner service)
    "opening_time_2": "17:00",
    "closing_time_2": "22:00",
    "cutoff_type_2_1": "kitchen_close",
    "cutoff_time_2_1": "21:30",

    // Slots 3, 4, 5 follow same pattern (rarely used)
    "opening_time_3": null,
    ...
  },
  "1": { // Tuesday
    "closed": false,
    "opening_time_1": "11:00",
    "closing_time_1": "22:00",
  },
  "2": { // Wednesday
    "closed": true,  // This day shows "Closed"
  },
  "3": { // Thursday
    "by_appointment_only": true,  // This day shows "By appointment"
  },
  ...
  "6": { // Sunday
    ...
  }
}
```

### Data Structure Rules

1. **Day Keys:** String numbers `"0"` through `"6"` (Monday=0, Sunday=6)
2. **Time Slots:** Up to 5 slots per day (`opening_time_1` through `opening_time_5`)
3. **Cutoff Types:** Up to 2 cutoffs per slot (`cutoff_type_1_1`, `cutoff_type_1_2`, etc.)
4. **Time Format:** `"HH:MM"` (24-hour format, e.g., `"09:00"`, `"22:30"`)
5. **Closed States:**
   - `"closed": true` → Shows "Closed" (translated)
   - `"by_appointment_only": true` → Shows "By appointment" (translated)
   - No opening times defined → Treated as closed
6. **Boolean Parsing:** Accepts both `bool` and `String` (`"true"`, `"false"`)

### Cutoff Type Enum Values

Supported `cutoff_type` values and their translation keys:

| Enum Value | Translation Key | English Label | Purpose |
|------------|----------------|---------------|---------|
| `kitchen_close` | `hours_kitchen` | "Kitchen" | Kitchen closes before restaurant |
| `last_order` | `hours_last_order` | "Last order" | Last time to place food orders |
| `last_arrival` | `hours_last_arrival` | "Last arrival" | Latest time to arrive |
| `last_booking` | `hours_last_booking` | "Last booking" | Latest reservation time |
| `first_seating` | `hours_first_seating` | "First seating" | Multi-seating restaurants |
| `second_seating` | `hours_second_seating` | "Second seating" | Multi-seating restaurants |
| `third_seating` | `hours_third_seating` | "Third seating" | Multi-seating restaurants |
| `call_for_hours` | `hours_call_for_hours` | "Call for hours" | Variable schedule |

---

## Dependencies

### FlutterFlow Framework
```dart
import '/flutter_flow/flutter_flow_theme.dart';  // ThemeData and color scheme
import '/flutter_flow/flutter_flow_util.dart';   // getTranslations() function
```

### Flutter SDK
```dart
import 'package:flutter/material.dart';  // Core UI framework
```

### Backend Schema (Indirect)
```dart
import '/backend/schema/structs/index.dart';  // Struct definitions (not directly used)
import '/backend/schema/enums/enums.dart';    // Enum definitions (cutoff types)
```

### Custom Code (Indirect)
```dart
import '/custom_code/widgets/index.dart';   // Widget registry
import '/custom_code/actions/index.dart';   // Custom actions (not directly used)
import '/flutter_flow/custom_functions.dart'; // Custom functions (not directly used)
```

### Key Functions Used

#### `getTranslations(String languageCode, String key, dynamic cache)`
- **Location:** `/flutter_flow/flutter_flow_util.dart`
- **Purpose:** Fetches translated string from cache
- **Parameters:**
  - `languageCode`: ISO 639-1 code (`'en'`, `'da'`, etc.)
  - `key`: Translation key (`'day_monday_cap'`, `'hours_closed'`, etc.)
  - `cache`: FFAppState().translationsCache
- **Returns:** Translated string, or key if translation missing
- **Example:**
  ```dart
  getTranslations('da', 'day_monday_cap', cache)
  // Returns: "Mandag"
  ```

---

## FFAppState Usage

### Read-Only State Access

#### `FFAppState().translationsCache`
- **Type:** `Map<String, Map<String, String>>`
- **Usage:** Passed as `translationsCache` parameter
- **Purpose:** Provides all UI strings in all supported languages
- **Read Frequency:** On every `_getUIText()` call (internally cached by Flutter)

#### `FFAppState().isBoldTextEnabled`
- **Type:** `bool`
- **Usage:** Accessed in `_buildTimeSlotWidget()` to determine layout wrapping
- **Purpose:** Detects if user enabled system-wide bold text (accessibility)
- **Impact:** Forces cutoff times to wrap to new line when `true`
- **Default:** `false`

### No State Mutations

This widget is **read-only** — it never modifies FFAppState.

---

## Translation Keys Reference

### Weekday Names (Capitalized)

| Key | English | Danish | German | Chinese |
|-----|---------|--------|--------|---------|
| `day_monday_cap` | Monday | Mandag | Montag | 星期一 |
| `day_tuesday_cap` | Tuesday | Tirsdag | Dienstag | 星期二 |
| `day_wednesday_cap` | Wednesday | Onsdag | Mittwoch | 星期三 |
| `day_thursday_cap` | Thursday | Torsdag | Donnerstag | 星期四 |
| `day_friday_cap` | Friday | Fredag | Freitag | 星期五 |
| `day_saturday_cap` | Saturday | Lørdag | Samstag | 星期六 |
| `day_sunday_cap` | Sunday | Søndag | Sonntag | 星期日 |

### Status Labels

| Key | English | Danish | German | Chinese |
|-----|---------|--------|--------|---------|
| `hours_closed` | Closed | Lukket | Geschlossen | 关闭 |
| `hours_by_appointment` | By appointment | Efter aftale | Nach Vereinbarung | 预约 |

### Cutoff Type Labels

| Key | English | Danish | German | Chinese |
|-----|---------|--------|--------|---------|
| `hours_kitchen` | Kitchen | Køkken | Küche | 厨房 |
| `hours_last_order` | Last order | Sidste ordre | Letzte Bestellung | 最后订单 |
| `hours_last_arrival` | Last arrival | Sidste ankomst | Letzte Ankunft | 最晚到达 |
| `hours_last_booking` | Last booking | Sidste booking | Letzte Buchung | 最后预订 |
| `hours_first_seating` | First seating | Første servering | Erste Sitzung | 第一批 |
| `hours_second_seating` | Second seating | Anden servering | Zweite Sitzung | 第二批 |
| `hours_third_seating` | Third seating | Tredje servering | Dritte Sitzung | 第三批 |
| `hours_call_for_hours` | Call for hours | Ring for tider | Anrufen für Öffnungszeiten | 致电询问 |

**Note:** If a translation key is missing from the cache, the widget displays the raw key (e.g., `"hours_kitchen"`) as fallback.

---

## Layout System

### Language-Adaptive Column Widths

The widget adjusts the weekday name column width based on language character length:

| Language | Code | Width (px) | Rationale |
|----------|------|-----------|-----------|
| Chinese | `zh` | 75.0 | Compact CJK characters |
| Korean | `ko` | 75.0 | Compact CJK characters |
| Japanese | `ja` | 75.0 | Compact CJK characters |
| Danish | `da` | 85.0 | Short weekday names |
| Spanish | `es` | 85.0 | Medium weekday names |
| French | `fr` | 85.0 | Medium weekday names |
| Italian | `it` | 85.0 | Medium weekday names |
| Dutch | `nl` | 85.0 | Medium weekday names |
| Norwegian | `no` | 85.0 | Medium weekday names |
| Swedish | `sv` | 85.0 | Medium weekday names |
| Ukrainian | `uk` | 85.0 | Medium weekday names |
| German | `de` | 110.0 | Long compound names |
| English | `en` | 110.0 | Long full names |
| Polish | `pl` | 125.0 | Very long weekday names |
| Finnish | `fi` | 125.0 | Very long weekday names |
| **Fallback** | (any) | 85.0 | Default for unsupported languages |

**Implementation:**
```dart
static const Map<String, double> _languageWidths = {
  'zh': 75.0,
  'ko': 75.0,
  'ja': 75.0,
  'da': 85.0,
  // ... (full map in source)
};

double get _containerWidth {
  return _languageWidths[widget.languageCode] ?? 85.0;
}
```

### Spacing Constants

| Constant | Value | Purpose |
|----------|-------|---------|
| `_dayNameToHoursSpacing` | 20.0px | Horizontal gap between day name and hours |
| `_rowSpacing` | 2.0px | Vertical gap between weekday rows |
| `_timeSlotSpacing` | 1.0px | Vertical gap between time slots on same day |
| `_multiSlotBottomPadding` | 4.0px | Extra bottom padding when day has multiple slots |

### Responsive Wrapping

Cutoff times wrap to a new line when:
1. **Text scale ≥1.1×:** User increased system font size
2. **Bold text enabled:** User enabled system-wide bold text (accessibility)

**Inline Layout (Default):**
```
11:00 - 14:00 (Kitchen: 13:30, Last order: 13:45)
```

**Wrapped Layout (Large Text or Bold):**
```
11:00 - 14:00
(Kitchen: 13:30, Last order: 13:45)
```

**Implementation:**
```dart
final textScaleFactor = MediaQuery.of(context).textScaler.scale(1.0);
final isBoldTextEnabled = FFAppState().isBoldTextEnabled;
final shouldWrap = textScaleFactor >= 1.1 || isBoldTextEnabled;
```

### Typography

| Property | Value | Source |
|----------|-------|--------|
| Font Size | 15.0px | Hard-coded constant |
| Font Weight | 300 (Light) | Hard-coded constant |
| Letter Spacing | 0.0 | FlutterFlowTheme override |
| Color | `#14181B` | Hard-coded (dark gray, not from theme) |
| Font Family | `theme.bodyMediumFamily` | From FlutterFlowTheme |

**Note:** The widget uses a custom override of `theme.bodyMedium` rather than pure theme values, ensuring consistent rendering across different theme configurations.

---

## Widget Hierarchy

```
OpeningHoursAndWeekdays (StatefulWidget)
└─ SizedBox(height: widget.height)
   └─ ListView.separated(shrinkWrap: true, physics: NeverScrollableScrollPhysics)
      ├─ _buildWeekdayRow(0)  // Monday
      │  └─ Row(crossAxisAlignment: start)
      │     ├─ SizedBox(width: _containerWidth)
      │     │  └─ Text(_getDayName(0))  // "Monday"
      │     ├─ SizedBox(width: 20)
      │     └─ _buildOpeningHoursColumn(dayHours)
      │        ├─ Text("Closed") // if closed
      │        └─ Expanded > Container > Column  // if open
      │           ├─ _buildTimeSlotWidget(slot1)
      │           │  ├─ Text("11:00 - 14:00 (Kitchen: 13:30)")  // inline
      │           │  └─ Column                                   // wrapped
      │           │     ├─ Text("11:00 - 14:00")
      │           │     └─ Text("(Kitchen: 13:30)")
      │           ├─ SizedBox(height: 1)
      │           └─ _buildTimeSlotWidget(slot2)
      ├─ SizedBox(height: 2)  // separator
      ├─ _buildWeekdayRow(1)  // Tuesday
      ├─ SizedBox(height: 2)
      ├─ ...
      └─ _buildWeekdayRow(6)  // Sunday
```

---

## Usage Examples

### Example 1: Basic Usage (Single Time Slot Per Day)

```dart
custom_widgets.OpeningHoursAndWeekdays(
  width: double.infinity,
  languageCode: FFLocalizations.of(context).languageCode,
  translationsCache: FFAppState().translationsCache,
  openingHours: {
    "0": {"opening_time_1": "09:00", "closing_time_1": "17:00"}, // Monday
    "1": {"opening_time_1": "09:00", "closing_time_1": "17:00"}, // Tuesday
    "2": {"opening_time_1": "09:00", "closing_time_1": "17:00"}, // Wednesday
    "3": {"opening_time_1": "09:00", "closing_time_1": "17:00"}, // Thursday
    "4": {"opening_time_1": "09:00", "closing_time_1": "17:00"}, // Friday
    "5": {"closed": true},  // Saturday - Closed
    "6": {"closed": true},  // Sunday - Closed
  },
)
```

**Rendered Output (English):**
```
Monday      09:00 - 17:00
Tuesday     09:00 - 17:00
Wednesday   09:00 - 17:00
Thursday    09:00 - 17:00
Friday      09:00 - 17:00
Saturday    Closed
Sunday      Closed
```

### Example 2: Real-World Usage in ContactDetailWidget

**Source:** `_flutterflow_export/lib/profile/contact_details/contact_detail/contact_detail_widget.dart`

```dart
custom_widgets.OpeningHoursAndWeekdays(
  width: double.infinity,
  languageCode: FFLocalizations.of(context).languageCode,
  openingHours: widget.openingHours,  // Passed from parent (from API)
  translationsCache: FFAppState().translationsCache,
),
```

**Context:** This widget is used in the Contact Details component of a business profile page, where `widget.openingHours` comes from a Supabase API query result.

### Example 3: Multiple Time Slots with Cutoffs

```dart
custom_widgets.OpeningHoursAndWeekdays(
  width: double.infinity,
  languageCode: 'da',  // Danish
  translationsCache: FFAppState().translationsCache,
  openingHours: {
    "0": {  // Monday
      "opening_time_1": "11:00",
      "closing_time_1": "14:00",
      "cutoff_type_1_1": "last_order",
      "cutoff_time_1_1": "13:30",
      "opening_time_2": "17:00",
      "closing_time_2": "22:00",
      "cutoff_type_2_1": "kitchen_close",
      "cutoff_time_2_1": "21:30",
    },
    "1": {  // Tuesday
      "opening_time_1": "17:00",
      "closing_time_1": "22:00",
      "cutoff_type_1_1": "kitchen_close",
      "cutoff_time_1_1": "21:30",
      "cutoff_type_1_2": "last_order",
      "cutoff_time_1_2": "21:45",
    },
    "2": {"closed": true},  // Wednesday
    "3": {"by_appointment_only": true},  // Thursday
  },
)
```

**Rendered Output (Danish):**
```
Mandag      11:00 - 14:00 (Sidste ordre: 13:30)
            17:00 - 22:00 (Køkken: 21:30)
Tirsdag     17:00 - 22:00 (Køkken: 21:30, Sidste ordre: 21:45)
Onsdag      Lukket
Torsdag     Efter aftale
```

### Example 4: Overnight Hours

```dart
custom_widgets.OpeningHoursAndWeekdays(
  width: double.infinity,
  languageCode: 'en',
  translationsCache: FFAppState().translationsCache,
  openingHours: {
    "4": {  // Friday
      "opening_time_1": "18:00",
      "closing_time_1": "02:00",  // Closes at 2 AM Saturday
    },
    "5": {  // Saturday
      "opening_time_1": "18:00",
      "closing_time_1": "03:00",  // Closes at 3 AM Sunday
    },
  },
)
```

**Rendered Output:**
```
Friday      18:00 - 02:00
Saturday    18:00 - 03:00
```

**Note:** The widget **displays** overnight hours correctly (showing `02:00` on Friday's row), but it does NOT compute status. The `determineStatusAndColor` action handles the logic of "is the restaurant still open from yesterday's overnight slot?"

### Example 5: Fixed Height Container

```dart
SizedBox(
  height: 250,  // Fixed height for scrollable region
  child: SingleChildScrollView(
    child: custom_widgets.OpeningHoursAndWeekdays(
      height: null,  // Let widget size naturally
      width: double.infinity,
      languageCode: FFLocalizations.of(context).languageCode,
      openingHours: widget.openingHours,
      translationsCache: FFAppState().translationsCache,
    ),
  ),
)
```

**Use Case:** When the opening hours might exceed available screen space, wrap in a scrollable container with fixed height.

---

## Lifecycle and State Management

### Widget Lifecycle

```dart
initState()
  ↓
build()  // Initial render
  ↓
didUpdateWidget()  // When parent rebuilds with new props
  ↓
  └─ Checks if translationsCache or languageCode changed
      ↓
      setState(() {})  // Triggers rebuild if changed
  ↓
build()  // Re-render with new translations
  ↓
dispose()
```

### State Change Triggers

#### Internal State Changes
- **None.** This widget has no user-interactive state (no taps, no text input).
- The only stateful aspect is reacting to external prop changes.

#### External Prop Changes
```dart
@override
void didUpdateWidget(OpeningHoursAndWeekdays oldWidget) {
  super.didUpdateWidget(oldWidget);

  if (widget.translationsCache != oldWidget.translationsCache ||
      widget.languageCode != oldWidget.languageCode) {
    setState(() {});  // Force rebuild
  }
}
```

**When This Triggers:**
1. User changes app language → `languageCode` changes
2. Translations loaded from API → `translationsCache` changes
3. Parent widget rebuilds with different `openingHours` data → Full rebuild (Flutter detects prop change)

**Performance Note:** The `!=` comparison for `translationsCache` (a Map) triggers a deep equality check. In practice, this is acceptable because:
- The translations cache rarely changes after initial load
- The widget is typically used once per business profile, not in scrollable lists

### No Internal State Variables

This widget declares **zero** mutable state variables. All rendering is derived from props:
- Day names → `_getDayName(index)` → `getTranslations()`
- Hours text → `_formatTime()` → Direct prop access
- Layout width → `_containerWidth` → Computed from `widget.languageCode`

**Why StatefulWidget if no state?**
- To override `didUpdateWidget()` for cache invalidation
- Could theoretically be `StatelessWidget`, but FlutterFlow's custom widget system requires `StatefulWidget`

---

## Error Handling

### Null Safety Strategy

| Scenario | Handling | Fallback Behavior |
|----------|----------|-------------------|
| `openingHours` is null | `Map<String, dynamic>.from(widget.openingHours ?? {})` | Empty map → all days show nothing (blank rows) |
| Day key missing (e.g., no `"0"`) | `_openingHoursData[dayIndex.toString()] ?? {}` | Empty day data → blank row |
| `opening_time_X` is null | Check `if (dayHours['opening_time_$slot'] != null)` | Skip that time slot |
| `closing_time_X` is null | Still renders opening time | Shows "HH:MM - " (no closing time) |
| Invalid time format | `_formatTime()` returns substring of first 5 chars | Displays raw string (e.g., "invalid" → "inval") |
| Translation key missing | `getTranslations()` returns key itself | Shows raw key (e.g., "hours_closed") |
| `cutoff_type` invalid | `_cutoffTypeTranslationKeys[cutoffType]` returns null | Falls back to raw enum value (e.g., "kitchen_close") |
| Boolean as string | `_parseBool()` handles both `bool` and `"true"`/`"false"` | Default `false` if unparseable |

### Invalid Data Examples

#### Missing Day Data
```dart
openingHours: {
  "0": {"opening_time_1": "09:00", "closing_time_1": "17:00"},
  // "1" missing entirely
  "2": {"opening_time_1": "09:00", "closing_time_1": "17:00"},
}
```
**Result:** Tuesday row displays blank (no "Closed", no hours). The row still renders with the day name.

#### Malformed Time String
```dart
openingHours: {
  "0": {"opening_time_1": "25:00", "closing_time_1": "abc"},
}
```
**Result:** Displays "25:00 - abc" (no validation, shows raw substrings).

#### Boolean as String (Common from API)
```dart
openingHours: {
  "0": {"closed": "true"},  // String, not bool
}
```
**Result:** Correctly interprets as closed due to `_parseBool()` logic.

### No Error Boundaries

The widget does **not** use try-catch blocks around rendering logic. If a fatal error occurs (e.g., null reference), the error propagates to Flutter's error boundary (red screen in debug, gray screen in release).

**Rationale:** The widget is purely presentational. If data is so malformed that rendering crashes, the issue is upstream (API layer), and the crash surfaces the problem immediately during development.

---

## Testing Checklist

### Unit Tests (Isolated Widget Tests)

#### Language Support Tests
- [ ] Test all 15 supported languages render correct day names
- [ ] Verify column width adapts correctly for each language
- [ ] Test fallback width (85.0) for unsupported language codes
- [ ] Verify translation keys fetch correct strings from cache
- [ ] Test missing translation keys show raw key as fallback

#### Data Structure Tests
- [ ] Test single time slot per day
- [ ] Test multiple time slots (2, 3, 4, 5) per day
- [ ] Test closed day (`"closed": true`)
- [ ] Test by-appointment-only day (`"by_appointment_only": true`)
- [ ] Test day with no opening times (implicitly closed)
- [ ] Test boolean as string (`"true"`, `"false"`)
- [ ] Test null openingHours parameter (renders empty)
- [ ] Test missing day keys (e.g., no `"0"`)

#### Cutoff Time Tests
- [ ] Test single cutoff per slot
- [ ] Test two cutoffs per slot (e.g., kitchen + last order)
- [ ] Test all cutoff type enums render correct labels
- [ ] Test unknown cutoff type shows raw enum value
- [ ] Test missing cutoff_time (cutoff not displayed)

#### Layout Tests
- [ ] Test cutoff inline when text scale < 1.1
- [ ] Test cutoff wrapped when text scale ≥ 1.1
- [ ] Test cutoff wrapped when bold text enabled
- [ ] Test spacing between rows (2px separator)
- [ ] Test spacing between time slots (1px)
- [ ] Test multi-slot bottom padding (4px)

#### Time Format Tests
- [ ] Test standard times (e.g., `"09:00"`)
- [ ] Test midnight (`"00:00"`)
- [ ] Test near-midnight (`"23:59"`)
- [ ] Test malformed times (too short, invalid characters)
- [ ] Test overnight times display correctly (e.g., `"02:00"`)

### Integration Tests (In Context)

#### Prop Change Tests
- [ ] Test language change updates day names
- [ ] Test translationsCache change triggers rebuild
- [ ] Test openingHours change updates display
- [ ] Test rapid prop changes don't cause flicker

#### Theme Integration Tests
- [ ] Test widget respects FlutterFlowTheme.bodyMediumFamily
- [ ] Test widget overrides fontSize to 15.0
- [ ] Test widget overrides fontWeight to 300
- [ ] Test widget color stays #14181B regardless of theme

#### Accessibility Tests
- [ ] Test with system font scale 1.5× (wraps cutoffs)
- [ ] Test with bold text enabled (wraps cutoffs)
- [ ] Test screen reader reads day names and hours correctly
- [ ] Test text contrast meets WCAG AA standards

#### Real Data Tests (From Supabase API)
- [ ] Test with actual restaurant data from production
- [ ] Test with restaurant having irregular hours
- [ ] Test with restaurant having seasonal hours (partially closed)
- [ ] Test with restaurant having only weekend hours

### Performance Tests

#### Rendering Performance
- [ ] Test rendering 7 days with 5 slots each (35 time slots)
- [ ] Test rapid language switches (no memory leaks)
- [ ] Test in scrollable list of 50+ restaurants (no jank)

#### Memory Tests
- [ ] Test translationsCache rebuild doesn't leak widgets
- [ ] Test widget dispose cleans up state correctly

---

## Known Limitations

### 1. No Current Day Highlighting
**What's Missing:** The widget does NOT visually distinguish the current day (e.g., bold text, background color).

**Rationale:** The FlutterFlow original implementation doesn't include this. The `determineStatusAndColor` action handles current status separately.

**Future Enhancement:** Could add:
```dart
final isToday = dayIndex == (DateTime.now().weekday - 1);
return Text(
  _getDayName(dayIndex),
  style: _getTextStyle().copyWith(
    fontWeight: isToday ? FontWeight.w600 : FontWeight.w300,
  ),
);
```

### 2. Cutoff Notes Not Displayed
**What's Missing:** The `cutoff_note_X_Y` fields are parsed but never rendered.

**Data Schema Includes:**
```dart
"cutoff_note_1_1": "Booking required for kitchen close time"
```

**Current Behavior:** Note is silently ignored.

**Future Enhancement:** Could display as tooltip or fine print:
```dart
Text('$cutoffText', style: ...)
if (note != null)
  Text('($note)', style: _getTextStyle().copyWith(fontSize: 13)),
```

### 3. No Validation of Time Strings
**What's Missing:** The widget accepts any string for `opening_time_X` and `closing_time_X`.

**Examples:**
- `"25:99"` → Displays "25:99" (invalid time)
- `"abc"` → Displays "abc" (not a time)
- `""` → Displays empty string

**Rationale:** Validation should happen at the API/data layer, not in presentation.

**Risk:** Invalid data from buggy API could display confusingly.

### 4. No Status Indicator
**What's Missing:** The widget does NOT show open/closed status (e.g., green/red dot).

**Why:** Status is determined by the `determineStatusAndColor` custom action, which runs separately and updates a different UI element (e.g., status badge on business card).

**Architecture Decision:** Keeps concerns separated:
- `OpeningHoursAndWeekdays` = static schedule display
- `determineStatusAndColor` = dynamic real-time status

### 5. Hard-Coded Text Color
**What's Missing:** Text color `#14181B` is hard-coded, not from theme.

**Impact:** Dark mode users see dark gray text on dark background (potential readability issue).

**Why:** FlutterFlow export uses hard-coded values. JourneyMate v2 design system should address this.

**Future Enhancement:**
```dart
color: FlutterFlowTheme.of(context).primaryText,  // Theme-aware
```

### 6. No Empty State Message
**What's Missing:** If `openingHours` is empty or null, the widget renders 7 blank rows (just day names, no hours).

**Better UX:** Could display "Hours not available" message:
```dart
if (_openingHoursData.isEmpty) {
  return Center(
    child: Text(
      _getUIText('hours_not_available'),
      style: _getTextStyle().copyWith(fontStyle: FontStyle.italic),
    ),
  );
}
```

### 7. No Support for "24 Hours" or "Always Open"
**What's Missing:** Cannot represent a business that never closes.

**Workaround:** Would need to set:
```dart
"opening_time_1": "00:00",
"closing_time_1": "24:00",  // Or "00:00" next day
```

**Better Solution:** Add explicit flag:
```dart
"always_open": true,
```
Then display "Open 24 hours" (translated).

### 8. Time Format is HH:MM Only
**What's Missing:** No support for 12-hour format (e.g., "9:00 AM").

**Current:** Always displays 24-hour format (`"09:00"`, `"17:00"`, `"22:00"`).

**Future Enhancement:** Respect locale's time format preference:
```dart
final formattedTime = DateFormat.Hm(widget.languageCode).format(
  DateTime(2000, 1, 1, hours, minutes),
);
```

---

## Migration Notes (Phase 3: Flutter Rebuild)

### Step 1: Review Source Materials

**Before writing ANY code:**

1. **Read FlutterFlow Source:**
   - Location: `_flutterflow_export/lib/custom_code/widgets/opening_hours_and_weekdays.dart`
   - This is the definitive implementation
   - Note ALL translation keys used
   - Note ALL FFAppState dependencies
   - Note accessibility features (text scaling, bold text)

2. **Review Page Audit:**
   - Location: `_reference/page-audit.md`
   - Find where this widget is used (Business Profile page)
   - Note parameters passed in real usage
   - Verify no functionality was missed

3. **View Screenshots:**
   - Location: `FF-pages-images/`
   - Compare rendered output with design
   - Note any visual differences

### Step 2: Verify Translation System Integration

**Critical:** This widget is fully integrated with the translation system.

**Required Translation Keys (Total: 23):**

Weekdays (7):
- `day_monday_cap`
- `day_tuesday_cap`
- `day_wednesday_cap`
- `day_thursday_cap`
- `day_friday_cap`
- `day_saturday_cap`
- `day_sunday_cap`

Status (2):
- `hours_closed`
- `hours_by_appointment`

Cutoffs (8):
- `hours_kitchen`
- `hours_last_order`
- `hours_last_arrival`
- `hours_last_booking`
- `hours_first_seating`
- `hours_second_seating`
- `hours_third_seating`
- `hours_call_for_hours`

**Verify in `FFAppState().translationsCache` for all 15 languages:**
`da`, `de`, `en`, `es`, `fi`, `fr`, `it`, `ja`, `ko`, `nl`, `no`, `pl`, `sv`, `uk`, `zh`

### Step 3: Map to JourneyMate v2 Design System

**File:** `_reference/journeymate-design-system.md`

**Design Tokens to Apply:**

| FlutterFlow Value | v2 Design System Token | Notes |
|-------------------|------------------------|-------|
| `#14181B` (text color) | `PRIMARY_TEXT` or `TEXT_DARK` | Use theme-aware color |
| `FontWeight.w300` | `FONT_WEIGHT_LIGHT` | Maintain light weight |
| `15.0` (font size) | `BODY_MEDIUM` or `14.0` | Check design system spec |
| `20.0` (spacing) | `SPACING_MD` | Horizontal gap |
| `2.0` (spacing) | `SPACING_XXS` | Row separator |
| Hard-coded widths | Keep as-is | Language-specific layout |

**JSX Reference:** `pages/business-profile.jsx` (when created) should show how this widget integrates visually.

### Step 4: State Management Migration

**Current (FlutterFlow):**
```dart
context.watch<FFAppState>();
final translationsCache = FFAppState().translationsCache;
final isBoldTextEnabled = FFAppState().isBoldTextEnabled;
```

**Future (Riverpod):**
```dart
final translationsCache = ref.watch(translationsCacheProvider);
final isBoldTextEnabled = ref.watch(accessibilitySettingsProvider).isBoldTextEnabled;
```

**Do NOT migrate state management until all pages are functional.** Keep `FFAppState` pattern initially.

### Step 5: File Location and Naming

**Target Location:** `lib/widgets/opening_hours_and_weekdays.dart`

**Import Path:**
```dart
import 'package:journey_mate/widgets/opening_hours_and_weekdays.dart';
```

**Naming Convention:**
- Widget class: `OpeningHoursAndWeekdays` (matches FlutterFlow)
- File name: `opening_hours_and_weekdays.dart` (snake_case)

### Step 6: Dependency Injection

**Translation Function:**

FlutterFlow uses global function:
```dart
getTranslations(languageCode, key, cache)
```

v2 should use service:
```dart
class TranslationService {
  String get(String key, String languageCode, Map cache);
}

// In widget
final translationService = ref.read(translationServiceProvider);
final text = translationService.get('day_monday_cap', languageCode, cache);
```

### Step 7: Testing Requirements

**Before marking complete:**

1. **Widget Test:** Verify all 15 languages render correctly
2. **Integration Test:** Verify in Contact Details component (business profile)
3. **Accessibility Test:** Test with 1.5× font scale and bold text
4. **Visual Regression:** Compare rendered output with FlutterFlow screenshot

### Step 8: Documentation Requirements

**After migration, update:**

1. **`_reference/journeymate-design-system.md`:**
   - Add `OpeningHoursAndWeekdays` to widget library section
   - Document when to use vs. when to show status separately

2. **`lib/widgets/README.md`:**
   - Add widget to registry
   - Note translation dependencies

3. **`CHANGELOG.md`:**
   - Log migration completion

### Step 9: Edge Cases to Test

**From Real Data:**

1. **Restaurant with split hours (lunch + dinner):**
   ```dart
   "0": {
     "opening_time_1": "11:00", "closing_time_1": "14:30",
     "opening_time_2": "17:00", "closing_time_2": "22:00",
   }
   ```

2. **Restaurant closed multiple days:**
   ```dart
   "0": {"closed": true},
   "1": {"closed": true},
   "2": {"opening_time_1": "12:00", "closing_time_1": "20:00"},
   ```

3. **Restaurant with overnight hours:**
   ```dart
   "4": {"opening_time_1": "18:00", "closing_time_1": "02:00"},
   ```

4. **Restaurant with by-appointment days:**
   ```dart
   "0": {"by_appointment_only": true},
   ```

5. **Restaurant with multiple cutoffs:**
   ```dart
   "0": {
     "opening_time_1": "17:00", "closing_time_1": "23:00",
     "cutoff_type_1_1": "kitchen_close", "cutoff_time_1_1": "22:00",
     "cutoff_type_1_2": "last_order", "cutoff_time_1_2": "22:30",
   }
   ```

### Step 10: Integration with determineStatusAndColor

**Important:** This widget does NOT call `determineStatusAndColor`. That action runs separately to set status badge color.

**Typical Usage Pattern:**

```dart
// In business profile page

// 1. Determine current status
final statusText = await actions.determineStatusAndColor(
  (color) async => setState(() => _statusColor = color),
  widget.openingHours,
  DateTime.now(),
  FFLocalizations.of(context).languageCode,
  FFAppState().translationsCache,
);

// 2. Display status badge
StatusBadge(
  text: statusText,  // "Open", "Closed", "Closing soon"
  color: _statusColor,  // Green or red
)

// 3. Display weekly schedule (this widget)
OpeningHoursAndWeekdays(
  languageCode: FFLocalizations.of(context).languageCode,
  translationsCache: FFAppState().translationsCache,
  openingHours: widget.openingHours,
)
```

**Do NOT merge status logic into this widget.** Keep concerns separated.

---

## Related Components

### Custom Actions

#### `determineStatusAndColor`
- **Purpose:** Calculates real-time business status (open/closed)
- **Relationship:** Uses same `openingHours` data structure
- **Documentation:** `_reference/MASTER_README_determine_status_and_color.md` (if exists)
- **Key Difference:** This widget is static display; that action is dynamic computation

### Custom Widgets

#### `ContactDetailsWidget`
- **Purpose:** Displays business contact info (parent component)
- **Relationship:** Embeds `OpeningHoursAndWeekdays` to show hours
- **Documentation:** `_reference/page-audit.md` (Contact Details section)

### Pages

#### Business Profile Page
- **JSX Design:** `pages/business-profile.jsx` (when created in Phase 1)
- **Flutter Page:** `lib/pages/business_profile_page.dart` (when migrated in Phase 3)
- **Relationship:** Primary page where this widget appears

---

## Change History

| Date | Version | Change | Author |
|------|---------|--------|--------|
| 2026-02-19 | 1.0.0 | Initial documentation from FlutterFlow export | Claude Code |

---

## Summary Checklist for Implementation

Before starting Phase 3 migration of this widget, verify:

- [ ] Read FlutterFlow source file completely
- [ ] Reviewed page audit for usage context
- [ ] Viewed screenshots of rendered output
- [ ] Identified all 23 translation keys
- [ ] Verified translation keys exist in all 15 languages
- [ ] Understood language-adaptive width system
- [ ] Noted accessibility features (text scaling, bold text)
- [ ] Understood separation from status determination
- [ ] Mapped FlutterFlow values to v2 design tokens
- [ ] Planned test coverage for edge cases
- [ ] Identified integration points (ContactDetailsWidget)
- [ ] Documented known limitations
- [ ] Prepared migration plan for state management (FFAppState → Riverpod, later)

**Final Notes:**

This is a **purely presentational widget** with zero business logic. Its job is to take structured data and render it beautifully in 15 languages. The complexity lies in:
1. Translation system integration (23 keys × 15 languages = 345 strings)
2. Language-adaptive layout (15 different column widths)
3. Responsive wrapping (accessibility support)
4. Flexible data structure (5 slots × 2 cutoffs × 7 days = 70 potential fields)

Keep it simple. Copy functionality exactly from FlutterFlow source. Apply v2 design system styling. Test thoroughly with real data. Ship it.

---

**End of Documentation**
