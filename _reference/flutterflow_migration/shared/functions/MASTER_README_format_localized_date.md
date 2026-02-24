# formatLocalizedDate Custom Function

**Status:** Phase 2 - Ready for Migration
**Source:** `_flutterflow_export/lib/flutter_flow/custom_functions.dart` (Lines 1235-1357)
**Last Updated:** 2026-02-19

---

## Purpose

Converts ISO 8601 datetime strings into localized date formats with properly localized month names for 15 supported languages. This function provides region-specific date formatting with graceful fallback to English when parsing fails or the locale is unavailable.

**Primary Use Case:** Displaying user-facing dates in the user's preferred language (e.g., review dates, event dates, business milestones).

---

## Function Signature

```dart
String? formatLocalizedDate(
  String dateTimeString,
  String languageCode,
)
```

**Returns:** Localized date string, or `null` if input is null/empty/invalid

---

## Parameters

### `dateTimeString` (String)
- **Description:** ISO 8601 datetime string to format
- **Format:** `'YYYY-MM-DDTHH:mm:ssZ'` or any valid ISO 8601 format
- **Examples:**
  - `'2025-08-08T12:00:00Z'` - Standard UTC timestamp
  - `'2025-12-25T00:00:00+01:00'` - With timezone offset
- **Edge Cases:**
  - Empty string → Returns `null`
  - Invalid format → Returns `null`
  - Missing timezone → Parsed as local time

### `languageCode` (String)
- **Description:** ISO 639-1 language code for localization
- **Supported Values:** `'en'`, `'da'`, `'de'`, `'es'`, `'fi'`, `'fr'`, `'it'`, `'ja'`, `'ko'`, `'nl'`, `'no'`, `'pl'`, `'sv'`, `'uk'`, `'zh'`
- **Fallback:** Defaults to English (`'en'`) if unsupported language provided
- **Case Sensitivity:** Not case-sensitive (normalized internally)

---

## Return Value

### Success Cases

Returns a localized date string formatted according to the language's conventions:

| Language | Format Pattern | Example Output |
|----------|----------------|----------------|
| English (`en`) | `MMMM d, y` | `August 8, 2025` |
| Danish (`da`) | `d. MMMM y` | `8. august 2025` |
| German (`de`) | `d. MMMM y` | `8. August 2025` |
| Spanish (`es`) | `d 'de' MMMM 'de' y` | `8 de agosto de 2025` |
| Finnish (`fi`) | `d. MMMM y` | `8. elokuuta 2025` |
| French (`fr`) | `d MMMM y` | `8 août 2025` |
| Italian (`it`) | `d MMMM y` | `8 agosto 2025` |
| Japanese (`ja`) | `y年M月d日` | `2025年8月8日` |
| Korean (`ko`) | `y년 M월 d일` | `2025년 8월 8일` |
| Dutch (`nl`) | `d MMMM y` | `8 augustus 2025` |
| Norwegian (`no`) | `d. MMMM y` | `8. august 2025` |
| Polish (`pl`) | `d MMMM y` | `8 sierpnia 2025` |
| Swedish (`sv`) | `d MMMM y` | `8 augusti 2025` |
| Ukrainian (`uk`) | `d MMMM y` | `8 серпня 2025` |
| Chinese (`zh`) | `y年M月d日` | `2025年8月8日` |

### Failure Cases

Returns `null` in these scenarios:

1. **Empty Input:** `dateTimeString.isEmpty`
2. **Invalid DateTime:** Parsing fails (malformed string)
3. **Formatting Failure:** Both primary and fallback formatters fail

---

## Dependencies

### Flutter/Dart Packages
```dart
import 'package:intl/intl.dart';
```

### Internal Dependencies
- None (self-contained function)

### External Configuration
- Uses internal `dateFormatConfig` map for locale patterns

---

## FFAppState Usage

**No FFAppState Required**

This function does NOT require:
- `languageCode` from FFAppState (passed as parameter)
- `translationsCache` (uses native `intl` package)

**Note:** Unlike most translation functions, this uses Dart's built-in `intl` package instead of the custom translation system.

---

## Usage Examples

### Example 1: Display Review Date in English

```dart
final reviewTimestamp = '2025-08-08T15:30:00Z';
final languageCode = FFAppState().languageCode; // 'en'

final formattedDate = formatLocalizedDate(
  reviewTimestamp,
  languageCode,
);

// Result: "August 8, 2025"
```

**UI Display:**
```
★★★★☆ Great food!
August 8, 2025
```

---

### Example 2: Display Event Date in Danish

```dart
final eventDate = '2025-12-24T00:00:00Z';
final languageCode = 'da';

final formattedDate = formatLocalizedDate(
  eventDate,
  languageCode,
);

// Result: "24. december 2025"
```

**UI Display:**
```
🎄 Julefrokost 2025
24. december 2025
```

---

### Example 3: Display Business Opening Date

```dart
final openingDate = businessData['opening_date']; // '2023-05-15T00:00:00Z'
final currentLang = FFAppState().languageCode;

final formattedDate = formatLocalizedDate(
  openingDate,
  currentLang,
) ?? 'Date unavailable';

// English: "May 15, 2023"
// German: "15. Mai 2023"
// Japanese: "2023年5月15日"
```

---

### Example 4: Null-Safe Display with Fallback

```dart
final lastUpdated = businessData['last_updated']; // Might be null/empty

final displayDate = formatLocalizedDate(
  lastUpdated ?? '',
  FFAppState().languageCode,
) ?? getTranslations(
  FFAppState().languageCode,
  'date_unavailable',
  FFAppState().translationsCache,
);

// If lastUpdated is null/empty: "Dato ikke tilgængelig"
// If valid: "15. august 2025"
```

---

### Example 5: Handling User-Generated Dates

```dart
// User-submitted content from form
final userDate = formState['event_date']; // ISO string from date picker

final formattedDate = formatLocalizedDate(
  userDate,
  FFAppState().languageCode,
);

if (formattedDate == null) {
  // Show error: Invalid date format
  showSnackbar('Please enter a valid date');
} else {
  // Display formatted date
  setState(() {
    displayedDate = formattedDate;
  });
}
```

---

## Edge Cases

### 1. Empty or Null Input

**Scenario:** `dateTimeString` is empty or null

```dart
formatLocalizedDate('', 'en');
// Returns: null

formatLocalizedDate(null, 'en'); // Compiler error - requires String
```

**Handling:**
```dart
final formatted = formatLocalizedDate(
  dateString ?? '',
  languageCode,
) ?? 'Date not available';
```

---

### 2. Invalid DateTime Format

**Scenario:** Malformed datetime string

```dart
formatLocalizedDate('not-a-date', 'en');
// Returns: null (parsing fails)

formatLocalizedDate('2025-13-45', 'en');
// Returns: null (invalid month/day)

formatLocalizedDate('2025/08/08', 'en');
// Returns: null (wrong separator - needs ISO format)
```

**Handling:**
```dart
try {
  final formatted = formatLocalizedDate(dateString, lang);
  if (formatted == null) {
    debugPrint('Failed to parse date: $dateString');
    return 'Invalid date';
  }
  return formatted;
} catch (e) {
  // Shouldn't reach here (function handles internally)
  return 'Date error';
}
```

---

### 3. Unsupported Language Code

**Scenario:** Language not in `dateFormatConfig`

```dart
formatLocalizedDate('2025-08-08T12:00:00Z', 'ar'); // Arabic (not supported)
// Returns: "August 8, 2025" (falls back to English)

formatLocalizedDate('2025-08-08T12:00:00Z', 'xx'); // Invalid code
// Returns: "August 8, 2025" (falls back to English)
```

**Behavior:** Gracefully falls back to English format instead of throwing error.

---

### 4. Timezone Handling

**Scenario:** Different timezone formats

```dart
// UTC (Z suffix)
formatLocalizedDate('2025-08-08T12:00:00Z', 'en');
// Result: "August 8, 2025"

// With timezone offset
formatLocalizedDate('2025-08-08T12:00:00+02:00', 'en');
// Result: "August 8, 2025" (converted to UTC)

// No timezone (local time)
formatLocalizedDate('2025-08-08T12:00:00', 'en');
// Result: "August 8, 2025" (parsed as local time)
```

**Note:** Time portion is ignored - only date is formatted.

---

### 5. Locale Formatting Failure

**Scenario:** `intl` package fails to format with locale

```dart
// Primary locale fails (extremely rare)
// Function automatically falls back to English:

dateFormatConfig[languageCode] → fails
// ↓
dateFormatConfig['en'] → used instead
// ↓ (if that also fails)
return null
```

**Handling in code:**
```dart
try {
  final formatter = DateFormat(pattern, locale);
  return formatter.format(dateTime);
} catch (e) {
  // Fallback to English
  try {
    final fallbackFormatter = DateFormat(
      dateFormatConfig['en']!['pattern']!,
      dateFormatConfig['en']!['locale']!,
    );
    return fallbackFormatter.format(dateTime);
  } catch (e) {
    return null; // Complete failure
  }
}
```

---

### 6. Leap Year and Edge Dates

**Scenario:** Special dates like Feb 29, Jan 1, Dec 31

```dart
// Leap year date
formatLocalizedDate('2024-02-29T00:00:00Z', 'en');
// Result: "February 29, 2024" ✅

// Non-leap year (invalid)
formatLocalizedDate('2025-02-29T00:00:00Z', 'en');
// Result: null (invalid date)

// Year boundaries
formatLocalizedDate('2024-12-31T23:59:59Z', 'en');
// Result: "December 31, 2024"

formatLocalizedDate('2025-01-01T00:00:00Z', 'en');
// Result: "January 1, 2025"
```

---

### 7. Very Old or Future Dates

**Scenario:** Dates far from current year

```dart
// Historical date
formatLocalizedDate('1900-01-01T00:00:00Z', 'en');
// Result: "January 1, 1900"

// Far future date
formatLocalizedDate('2999-12-31T00:00:00Z', 'en');
// Result: "December 31, 2999"
```

**Note:** No date range validation - accepts any valid DateTime.

---

## Testing Checklist

### Unit Tests

- [ ] **Basic Formatting - All Languages**
  - [ ] English: Returns `"August 8, 2025"`
  - [ ] Danish: Returns `"8. august 2025"`
  - [ ] German: Returns `"8. August 2025"`
  - [ ] Spanish: Returns `"8 de agosto de 2025"`
  - [ ] Finnish: Returns `"8. elokuuta 2025"`
  - [ ] French: Returns `"8 août 2025"`
  - [ ] Italian: Returns `"8 agosto 2025"`
  - [ ] Japanese: Returns `"2025年8月8日"`
  - [ ] Korean: Returns `"2025년 8월 8일"`
  - [ ] Dutch: Returns `"8 augustus 2025"`
  - [ ] Norwegian: Returns `"8. august 2025"`
  - [ ] Polish: Returns `"8 sierpnia 2025"`
  - [ ] Swedish: Returns `"8 augusti 2025"`
  - [ ] Ukrainian: Returns `"8 серпня 2025"`
  - [ ] Chinese: Returns `"2025年8月8日"`

- [ ] **Edge Cases**
  - [ ] Empty string input returns `null`
  - [ ] Invalid datetime format returns `null`
  - [ ] Unsupported language falls back to English
  - [ ] Leap year date (Feb 29) formats correctly
  - [ ] Invalid leap year date (2025-02-29) returns `null`

- [ ] **Timezone Handling**
  - [ ] UTC timestamp (`Z` suffix) formats correctly
  - [ ] Timezone offset (`+02:00`) formats correctly
  - [ ] No timezone (local time) formats correctly
  - [ ] Multiple timezones produce same date

- [ ] **Month Name Localization**
  - [ ] January in all languages
  - [ ] December in all languages
  - [ ] Accented characters (août, серпня) render correctly

### Integration Tests

- [ ] **With Real Data**
  - [ ] Format review dates from Supabase
  - [ ] Format business opening dates
  - [ ] Format user-submitted event dates

- [ ] **With FFAppState**
  - [ ] Use current `languageCode` from state
  - [ ] Handle language changes (switch da → en)
  - [ ] Display correctly in ListView of dates

- [ ] **UI Display**
  - [ ] Dates render without truncation
  - [ ] Month names display with correct capitalization
  - [ ] Special characters (ø, ä, ç) render correctly

### Error Handling Tests

- [ ] **Graceful Degradation**
  - [ ] Null input → UI shows "Date unavailable"
  - [ ] Invalid format → UI shows error message
  - [ ] Formatting failure → Fallback to English

- [ ] **Debug Logging**
  - [ ] No debug prints on success
  - [ ] No debug prints on expected failures (null)

---

## Migration Notes

### Phase 3 Implementation Plan

#### Step 1: Review Function Source
```bash
# Read original FlutterFlow implementation
_flutterflow_export/lib/flutter_flow/custom_functions.dart:1235-1357
```

**Key aspects to preserve:**
- Exact date format patterns for all 15 languages
- Locale strings (`en_US`, `da_DK`, etc.)
- Fallback logic (primary → English → null)
- Null safety (return `null` on invalid input)

---

#### Step 2: Create Dart Implementation

**Location:** `lib/services/date_formatting_service.dart`

```dart
import 'package:intl/intl.dart';

/// Formats ISO 8601 datetime string to localized date
///
/// Returns localized date string, or null if input is invalid
String? formatLocalizedDate(
  String dateTimeString,
  String languageCode,
) {
  // Date format configuration
  const dateFormatConfig = {
    'en': {
      'pattern': 'MMMM d, y',
      'locale': 'en_US',
    },
    'da': {
      'pattern': 'd. MMMM y',
      'locale': 'da_DK',
    },
    // ... (all 15 languages as per FlutterFlow)
  };

  // Return null for empty input
  if (dateTimeString.isEmpty) return null;

  // Parse ISO 8601 datetime
  final DateTime dateTime;
  try {
    dateTime = DateTime.parse(dateTimeString);
  } catch (e) {
    return null;
  }

  // Get format config (fallback to English)
  final config = dateFormatConfig[languageCode] ?? dateFormatConfig['en']!;
  final pattern = config['pattern']!;
  final locale = config['locale']!;

  // Format with locale
  try {
    final formatter = DateFormat(pattern, locale);
    return formatter.format(dateTime);
  } catch (e) {
    // Fallback to English
    try {
      final fallbackFormatter = DateFormat(
        dateFormatConfig['en']!['pattern']!,
        dateFormatConfig['en']!['locale']!,
      );
      return fallbackFormatter.format(dateTime);
    } catch (e) {
      return null;
    }
  }
}
```

---

#### Step 3: Add to Dependencies

**pubspec.yaml:**
```yaml
dependencies:
  intl: ^0.18.0 # Or latest version used in FlutterFlow export
```

**Note:** Verify `intl` version matches FlutterFlow export to ensure consistent formatting.

---

#### Step 4: Update All Call Sites

**Search for usage:**
```bash
grep -r "formatLocalizedDate" _flutterflow_export/lib/pages/
```

**Common patterns to migrate:**

**Before (FlutterFlow):**
```dart
Text(
  formatLocalizedDate(
    reviewData['created_at'],
    FFAppState().languageCode,
  ) ?? '',
)
```

**After (Pure Flutter):**
```dart
import 'package:journeymate/services/date_formatting_service.dart';

Text(
  formatLocalizedDate(
    reviewData['created_at'],
    context.read<AppState>().languageCode,
  ) ?? '',
)
```

---

#### Step 5: Add Widget Convenience Methods

**Create helper for common use case:**

```dart
// lib/widgets/formatted_date_text.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:journeymate/services/date_formatting_service.dart';
import 'package:journeymate/state/app_state.dart';

class FormattedDateText extends StatelessWidget {
  final String? dateTimeString;
  final TextStyle? style;
  final String fallbackText;

  const FormattedDateText({
    Key? key,
    required this.dateTimeString,
    this.style,
    this.fallbackText = 'Date unavailable',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageCode = context.watch<AppState>().languageCode;

    final formattedDate = formatLocalizedDate(
      dateTimeString ?? '',
      languageCode,
    );

    return Text(
      formattedDate ?? fallbackText,
      style: style,
    );
  }
}
```

**Usage:**
```dart
FormattedDateText(
  dateTimeString: reviewData['created_at'],
  style: theme.textTheme.bodySmall,
  fallbackText: 'Date unknown',
)
```

---

### Critical Migration Requirements

#### ✅ Must Preserve
1. **Exact date format patterns** - Match FlutterFlow output exactly
2. **Locale strings** - Use identical locale codes (`en_US`, `da_DK`, etc.)
3. **Fallback behavior** - Primary locale → English → null (never throw)
4. **Null safety** - Return `null` for invalid input (no exceptions)
5. **Month name localization** - Use native `intl` package (not custom translations)

#### ⚠️ Do NOT Change
1. Date format patterns (ordering, separators, literals)
2. Locale codes for `DateFormat` constructor
3. Null-return behavior (critical for UI safety)
4. Supported language list (add new ones carefully)

#### 🔍 Test Thoroughly
1. **Visual regression:** Compare formatted output character-by-character
2. **All languages:** Test with same input date in all 15 languages
3. **Edge cases:** Empty string, invalid format, leap year dates
4. **Timezone handling:** UTC, offset, and local time inputs

---

### Known Migration Risks

#### Risk 1: `intl` Package Version Mismatch
**Symptom:** Different date formatting output
**Cause:** `intl` package version differs from FlutterFlow export
**Solution:**
```yaml
# Match exact version from FlutterFlow export
dependencies:
  intl: ^0.18.0 # Check _flutterflow_export/pubspec.yaml
```

---

#### Risk 2: Locale Data Not Loaded
**Symptom:** English month names in non-English locales
**Cause:** `intl` locale data not initialized
**Solution:**
```dart
// main.dart
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all locale data
  await initializeDateFormatting();

  runApp(MyApp());
}
```

---

#### Risk 3: Case-Sensitive Month Names
**Symptom:** Incorrect capitalization (e.g., "AUGUST" vs "August")
**Cause:** Format pattern uses wrong case pattern
**Solution:** Use exact patterns from `dateFormatConfig` (already correct)

---

#### Risk 4: Missing Locale Support
**Symptom:** Fallback to English for supported language
**Cause:** `intl` package doesn't include locale data
**Solution:**
```yaml
dependencies:
  intl: ^0.18.0
  # Locale data is included by default in intl 0.18+
```

---

### Testing Strategy

#### Unit Test Template
```dart
// test/services/date_formatting_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:journeymate/services/date_formatting_service.dart';

void main() {
  group('formatLocalizedDate', () {
    const testDate = '2025-08-08T12:00:00Z';

    test('formats English date correctly', () {
      expect(
        formatLocalizedDate(testDate, 'en'),
        'August 8, 2025',
      );
    });

    test('formats Danish date correctly', () {
      expect(
        formatLocalizedDate(testDate, 'da'),
        '8. august 2025',
      );
    });

    test('returns null for empty string', () {
      expect(formatLocalizedDate('', 'en'), isNull);
    });

    test('returns null for invalid format', () {
      expect(formatLocalizedDate('not-a-date', 'en'), isNull);
    });

    test('falls back to English for unsupported language', () {
      expect(
        formatLocalizedDate(testDate, 'ar'),
        'August 8, 2025',
      );
    });
  });
}
```

---

### Integration with Translation System

**Important:** This function does NOT use the custom translation system (`getTranslations`, `translationsCache`). It uses Dart's native `intl` package instead.

**Why separate systems?**
- Date formatting requires locale-specific grammar rules
- `intl` package provides robust, tested date formatting
- Month names are built into `intl` locale data
- Custom translation system is for app UI strings only

**When to use each:**

| Use Case | Function |
|----------|----------|
| Format dates | `formatLocalizedDate` (this function) |
| UI labels/buttons | `getTranslations` (custom system) |
| Error messages | `getTranslations` (custom system) |
| Currency symbols | `getCurrencyFormattingRules` (custom) |

---

### Performance Considerations

#### Caching Recommendations

**Do NOT cache:**
- The function itself (pure, no side effects)
- `DateFormat` instances (lightweight, fast to create)

**Consider caching:**
- Formatted dates in UI (use `memo` or `useMemoized`)
- List of formatted dates (compute once, reuse)

**Example:**
```dart
// In StatelessWidget - compute each build (fast)
Text(formatLocalizedDate(dateString, lang) ?? '')

// In ListView.builder with many dates - cache results
final _formattedDatesCache = <String, String>{};

String getFormattedDate(String dateString, String lang) {
  final cacheKey = '$dateString-$lang';
  return _formattedDatesCache.putIfAbsent(
    cacheKey,
    () => formatLocalizedDate(dateString, lang) ?? '',
  );
}
```

---

### Localization Expansion

To add a new language:

1. **Add to `dateFormatConfig`:**
```dart
'ar': {
  'pattern': 'd MMMM y',  // Arabic format
  'locale': 'ar_SA',      // Saudi Arabia locale
},
```

2. **Verify `intl` support:**
```dart
// Check if locale is available in intl package
import 'package:intl/intl_standalone.dart';

void main() async {
  final locale = await findSystemLocale();
  print('System locale: $locale');
  // Verify 'ar_SA' is supported
}
```

3. **Test with native speaker:**
- Verify date order (day/month/year)
- Check month name spelling
- Validate punctuation (periods, commas)
- Confirm capitalization rules

---

## Related Functions

### Similar Date/Time Functions
- None in custom_functions.dart (this is the only date formatting function)

### Complementary Functions
- `getTranslations` - UI string localization (different system)
- `openClosesAt` - Business hours formatting (uses time only)
- `daysDayOpeningHour` - Opening schedule display (uses day names + times)

### Data Flow
```
ISO Timestamp (DB)
    ↓
formatLocalizedDate()
    ↓
Localized Date String
    ↓
Text Widget (UI)
```

---

## Change Log

**2026-02-19:** Initial documentation created from FlutterFlow source (Lines 1235-1357)

---

## Additional Notes

### Month Name Capitalization Rules

Different languages have different capitalization conventions:

| Language | Month Name Capitalization | Example |
|----------|---------------------------|---------|
| English | Capitalized | August |
| Danish | Lowercase | august |
| German | Capitalized | August |
| French | Lowercase | août |
| Italian | Lowercase | agosto |
| Spanish | Lowercase | agosto |

**These are handled automatically by `intl` package's locale data.**

---

### Format Pattern Syntax

`DateFormat` uses ICU date format patterns:

| Symbol | Meaning | Example |
|--------|---------|---------|
| `y` | Year | 2025 |
| `M` | Month number | 8 |
| `MMMM` | Month full name | August |
| `d` | Day of month | 8 |
| `'de'` | Literal text | de (Spanish "of") |

**Examples:**
- `'MMMM d, y'` → "August 8, 2025"
- `'d. MMMM y'` → "8. August 2025"
- `'y年M月d日'` → "2025年8月8日"

---

### Timezone Behavior

**Important:** This function ignores time and timezone - only date is formatted.

```dart
// All these produce the same output:
formatLocalizedDate('2025-08-08T00:00:00Z', 'en')     // "August 8, 2025"
formatLocalizedDate('2025-08-08T12:00:00Z', 'en')     // "August 8, 2025"
formatLocalizedDate('2025-08-08T23:59:59Z', 'en')     // "August 8, 2025"
formatLocalizedDate('2025-08-08T12:00:00+05:00', 'en') // "August 8, 2025"
```

**Why?** The `DateFormat` pattern only includes `y`, `MMMM`, and `d` - no time components.

---

### Accessibility Considerations

**Screen Readers:** Formatted dates are announced correctly in all languages when using native `intl` formatting.

**Example:**
```dart
Semantics(
  label: 'Review date: ${formatLocalizedDate(date, lang)}',
  child: Text(formatLocalizedDate(date, lang) ?? ''),
)
```

**Announced as:**
- English: "Review date: August eighth, twenty twenty-five"
- Danish: "Anmeldelsesdato: ottende august to tusind og femogtyve"

---

### Comparison with Custom Translation System

| Aspect | `formatLocalizedDate` | `getTranslations` |
|--------|----------------------|-------------------|
| Package | `intl` (native) | Custom (Supabase) |
| Data source | Built-in locale data | `translations` table |
| Caching | Not needed (fast) | Required (DB call) |
| Fallback | English format | Empty string |
| Use case | Date/time formatting | UI strings |
| Updates | Dart version | Database migration |

**Key Difference:** Date formatting uses proven, standards-based localization (ICU), while UI strings use custom system for business-specific text.

---

## Summary

The `formatLocalizedDate` function is a critical utility for displaying dates in the user's language throughout the JourneyMate app. It leverages Dart's robust `intl` package to provide accurate, locale-aware date formatting with graceful fallback behavior.

**Migration Priority:** Medium (used in reviews, events, business info - visible but not critical path)

**Testing Emphasis:** Visual regression across all 15 languages to ensure perfect match with FlutterFlow output.

**Key Principle:** Preserve exact formatting behavior - do not "improve" date formats without consulting design system.

---

**End of Documentation**
