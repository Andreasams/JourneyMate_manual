# getCurrencyFormattingRules

**Status:** ✅ COMPLETE
**Phase:** Core Infrastructure
**Priority:** CRITICAL - Central dependency for all currency display
**Location:** `custom_functions.dart:2093-2132`

---

## Purpose

The `getCurrencyFormattingRules` function is the **single source of truth** for all currency display formatting in JourneyMate. It provides standardized formatting rules (symbol, placement, decimal precision) for 11 supported currencies, ensuring consistent price display across the entire app.

**Critical Role:**
- Acts as the central formatting authority for all currency-related functions
- Used by `convertAndFormatPrice`, `convertAndFormatPriceRange`, and `getCurrencyOptionsForLanguage`
- Ensures consistent symbol placement (prefix vs suffix) and decimal precision
- Provides graceful fallback for unsupported currencies

**Business Context:**
JourneyMate displays menu prices from restaurants using different currencies (primarily DKK, but also EUR, USD, etc.). This function ensures all prices follow region-appropriate formatting conventions while supporting currency conversion.

---

## Function Signature

```dart
String? getCurrencyFormattingRules(String currencyCode)
```

---

## Parameters

### `currencyCode` (String, required)
- **Description:** ISO 4217 currency code (e.g., 'DKK', 'EUR', 'USD')
- **Format:** Three-letter uppercase code (function normalizes input to uppercase)
- **Examples:** 'DKK', 'EUR', 'USD', 'GBP', 'JPY', 'SEK', 'NOK'
- **Edge Cases:**
  - Lowercase input is normalized to uppercase
  - Unknown currencies return default DKK-style formatting
  - Empty string returns default formatting (not null)

---

## Return Value

### Type: `String?`

**Format:** JSON string containing three fields:
```json
{
  "symbol": "kr.",      // Currency symbol
  "isPrefix": false,    // true = prefix (€100), false = suffix (100 kr.)
  "decimals": 0         // Number of decimal places to display
}
```

### Return Value Scenarios

| Input Currency | Symbol | isPrefix | decimals | Example Output |
|----------------|--------|----------|----------|----------------|
| DKK | `kr.` | `false` | `0` | `100 kr.` |
| EUR | `€` | `true` | `2` | `€13.45` |
| USD | `$` | `true` | `2` | `$12.50` |
| GBP | `£` | `true` | `1` | `£10.5` |
| SEK | `kr.` | `false` | `0` | `100 kr.` |
| NOK | `kr.` | `false` | `0` | `100 kr.` |
| JPY | `¥` | `false` | `0` | `1000 ¥` |
| CNY | `¥` | `true` | `0` | `¥100` |
| KRW | `₩` | `false` | `0` | `10000 ₩` |
| PLN | `zł` | `false` | `0` | `50 zł` |
| UAH | `₴` | `false` | `0` | `250 ₴` |
| UNKNOWN | `kr.` | `false` | `0` | `100 kr.` (default) |

**Null Return:** This function never returns null - it always returns a JSON string (even for unknown currencies, which get the default DKK-style formatting).

---

## Dependencies

### Dart Standard Library
```dart
import 'dart:convert';  // For jsonEncode()
```

**No other dependencies:**
- Does not use FFAppState
- Does not use translations cache
- Does not call other custom functions
- Self-contained logic with static configuration

---

## FFAppState Usage

**Not Applicable** - This function does NOT use FFAppState.

All currency formatting rules are defined as compile-time constants within the function. This design choice ensures:
- Fast, synchronous execution (no state lookups)
- Consistency across all currency operations
- Predictable behavior without state dependencies

---

## Implementation Details

### Currency Formatting Rules Map

The function contains a static map defining rules for 11 currencies:

```dart
const Map<String, Map<String, dynamic>> currencyFormattingRules = {
  'CNY': {'symbol': '¥', 'isPrefix': true, 'decimals': 0},
  'DKK': {'symbol': 'kr.', 'isPrefix': false, 'decimals': 0},
  'EUR': {'symbol': '€', 'isPrefix': true, 'decimals': 2},
  'GBP': {'symbol': '£', 'isPrefix': true, 'decimals': 1},
  'JPY': {'symbol': '¥', 'isPrefix': false, 'decimals': 0},
  'KRW': {'symbol': '₩', 'isPrefix': false, 'decimals': 0},
  'NOK': {'symbol': 'kr.', 'isPrefix': false, 'decimals': 0},
  'PLN': {'symbol': 'zł', 'isPrefix': false, 'decimals': 0},
  'SEK': {'symbol': 'kr.', 'isPrefix': false, 'decimals': 0},
  'UAH': {'symbol': '₴', 'isPrefix': false, 'decimals': 0},
  'USD': {'symbol': '\$', 'isPrefix': true, 'decimals': 2},
};
```

### Default Fallback Rule

For unknown currency codes, the function returns DKK-style formatting:

```dart
const Map<String, dynamic> defaultCurrencyRule = {
  'symbol': 'kr.',
  'isPrefix': false,
  'decimals': 0,
};
```

**Rationale:** JourneyMate is primarily used in Denmark, so defaulting to DKK formatting provides the most reasonable fallback behavior.

### Execution Flow

```
1. Normalize input to uppercase (e.g., 'dkk' → 'DKK')
2. Lookup currency in currencyFormattingRules map
3. If found: Use mapped rules
4. If not found: Use defaultCurrencyRule
5. Encode rules as JSON string
6. Return JSON string
```

### Symbol Placement Logic

**Prefix Currencies (isPrefix: true):**
- Western major currencies: USD, EUR, GBP
- Chinese Yuan (CNY)
- Format: `€100` or `$12.50`

**Suffix Currencies (isPrefix: false):**
- Scandinavian currencies: DKK, SEK, NOK
- Eastern European: PLN, UAH
- Asian: JPY, KRW
- Format: `100 kr.` or `1000 ¥`

### Decimal Precision Strategy

| Decimal Places | Currencies | Rationale |
|----------------|-----------|-----------|
| 0 | DKK, SEK, NOK, JPY, KRW, PLN, UAH, CNY | Low-value currencies or cultural convention |
| 1 | GBP | British pound traditionally uses one decimal place |
| 2 | USD, EUR | Standard international practice for major currencies |

---

## Usage Examples

### Example 1: Get DKK Formatting Rules

```dart
final rulesJson = getCurrencyFormattingRules('DKK');
// Returns: '{"symbol":"kr.","isPrefix":false,"decimals":0}'

final rules = jsonDecode(rulesJson);
print(rules['symbol']);    // 'kr.'
print(rules['isPrefix']);  // false
print(rules['decimals']);  // 0

// Usage in formatting:
final price = 100.0;
final formatted = '${price.toInt()} ${rules['symbol']}';
// Result: '100 kr.'
```

### Example 2: Get EUR Formatting Rules

```dart
final rulesJson = getCurrencyFormattingRules('EUR');
// Returns: '{"symbol":"€","isPrefix":true,"decimals":2}'

final rules = jsonDecode(rulesJson);
final price = 13.456;
final formatted = '${rules['symbol']}${price.toStringAsFixed(rules['decimals'])}';
// Result: '€13.46'
```

### Example 3: Handle Unknown Currency

```dart
final rulesJson = getCurrencyFormattingRules('XYZ');
// Returns: '{"symbol":"kr.","isPrefix":false,"decimals":0}' (default)

// Graceful fallback - displays as DKK-style formatting
```

### Example 4: Case-Insensitive Input

```dart
final rulesJson1 = getCurrencyFormattingRules('usd');
final rulesJson2 = getCurrencyFormattingRules('USD');
final rulesJson3 = getCurrencyFormattingRules('UsD');
// All three return identical results (normalized to uppercase)
```

### Example 5: Used by convertAndFormatPrice

```dart
// From convertAndFormatPrice function (lines 1733-1811):
String? convertAndFormatPrice(
  double basePrice,
  String originalCurrencyCode,
  double exchangeRate,
  String targetCurrencyCode,
) {
  // ... validation and conversion logic ...

  // Get currency formatting rules from central function
  final rulesJson = getCurrencyFormattingRules(targetCode);
  if (rulesJson == null) return null;

  // Parse JSON rules
  final rules = jsonDecode(rulesJson);
  final symbol = rules['symbol'] as String;
  final isPrefix = rules['isPrefix'] as bool;
  final decimals = rules['decimals'] as int;

  // Format price based on decimal places
  final formattedPrice = decimals == 0
      ? NumberFormat(pattern).format(convertedPrice.round())
      : NumberFormat(pattern).format(convertedPrice);

  // Build output string based on symbol placement
  return isPrefix ? '$symbol$formattedPrice' : '$formattedPrice $symbol';
}
```

### Example 6: Used by convertAndFormatPriceRange

```dart
// From convertAndFormatPriceRange function (lines 1359-1467):
String? convertAndFormatPriceRange(
  double minPrice,
  double maxPrice,
  String originalCurrencyCode,
  double exchangeRate,
  String targetCurrencyCode,
) {
  // ... conversion logic ...

  // Get currency formatting rules from central function
  final rulesJson = getCurrencyFormattingRules(targetCurrency);
  if (rulesJson == null) return null;

  final rules = jsonDecode(rulesJson);
  final symbol = rules['symbol'] as String;
  final isPrefix = rules['isPrefix'] as bool;

  // Build output string based on symbol placement
  if (isPrefix) {
    // Prefix: Symbol repeated for both values (e.g., "€100 - €200")
    return '$symbol$formattedMin - $symbol$formattedMax';
  } else {
    // Suffix: Single symbol at end (e.g., "100 - 200 kr.")
    return '$formattedMin - $formattedMax $symbol';
  }
}
```

### Example 7: Used by getCurrencyOptionsForLanguage

```dart
// From getCurrencyOptionsForLanguage function (lines 1469-1549):
List<dynamic> getCurrencyOptionsForLanguage(
  String languageCode,
  dynamic translationsCache,
) {
  // ... language-specific currency selection logic ...

  /// Extract symbol from getCurrencyFormattingRules().
  String _getSymbol(String code) {
    try {
      final jsonStr = getCurrencyFormattingRules(code);
      if (jsonStr == null) return code;
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final symbol = (data['symbol'] ?? '').toString().trim();
      return symbol.isEmpty ? code : symbol;
    } catch (_) {
      return code;
    }
  }

  // Build currency options with symbols
  for (final code in codes) {
    final name = _getCurrencyName(code);
    if (name == null) continue;

    final symbol = _getSymbol(code);
    options.add({
      'label': '$name ($symbol)',  // e.g., "Danish krone (kr.)"
      'code': code,
    });
  }

  return options;
}
```

---

## Edge Cases

### Edge Case 1: Unknown Currency Code
**Input:** `getCurrencyFormattingRules('XYZ')`
**Behavior:** Returns default DKK-style formatting
**Result:** `{"symbol":"kr.","isPrefix":false,"decimals":0}`
**Rationale:** Graceful fallback for unsupported currencies

### Edge Case 2: Lowercase Input
**Input:** `getCurrencyFormattingRules('dkk')`
**Behavior:** Normalized to uppercase before lookup
**Result:** Same as `getCurrencyFormattingRules('DKK')`
**Handling:** `currencyCode.toUpperCase()` at line 2125

### Edge Case 3: Empty String
**Input:** `getCurrencyFormattingRules('')`
**Behavior:** Treated as unknown currency
**Result:** Returns default DKK-style formatting
**Note:** Function never returns null

### Edge Case 4: Mixed Case Input
**Input:** `getCurrencyFormattingRules('UsD')`
**Behavior:** Normalized to 'USD' before lookup
**Result:** Returns USD formatting rules correctly

### Edge Case 5: Three-Letter Non-Currency Codes
**Input:** `getCurrencyFormattingRules('ABC')`
**Behavior:** Treated as unknown currency
**Result:** Returns default DKK-style formatting
**Safety:** No validation errors - always returns valid JSON

### Edge Case 6: Whitespace in Input
**Input:** `getCurrencyFormattingRules(' DKK ')`
**Current Behavior:** Lookup fails (spaces not trimmed)
**Result:** Returns default formatting
**Recommendation:** Add `.trim()` after `.toUpperCase()` for robustness

---

## Testing Checklist

### Unit Tests

- [ ] **Test all 11 supported currencies**
  - [ ] CNY returns correct rules (¥, prefix, 0 decimals)
  - [ ] DKK returns correct rules (kr., suffix, 0 decimals)
  - [ ] EUR returns correct rules (€, prefix, 2 decimals)
  - [ ] GBP returns correct rules (£, prefix, 1 decimal)
  - [ ] JPY returns correct rules (¥, suffix, 0 decimals)
  - [ ] KRW returns correct rules (₩, suffix, 0 decimals)
  - [ ] NOK returns correct rules (kr., suffix, 0 decimals)
  - [ ] PLN returns correct rules (zł, suffix, 0 decimals)
  - [ ] SEK returns correct rules (kr., suffix, 0 decimals)
  - [ ] UAH returns correct rules (₴, suffix, 0 decimals)
  - [ ] USD returns correct rules ($, prefix, 2 decimals)

- [ ] **Test case normalization**
  - [ ] Lowercase input ('dkk') works correctly
  - [ ] Uppercase input ('DKK') works correctly
  - [ ] Mixed case input ('DkK') works correctly

- [ ] **Test unknown currencies**
  - [ ] Unknown code ('XYZ') returns default formatting
  - [ ] Empty string ('') returns default formatting
  - [ ] Invalid code ('123') returns default formatting

- [ ] **Test JSON output validity**
  - [ ] All outputs are valid JSON strings
  - [ ] All outputs can be parsed with jsonDecode()
  - [ ] All parsed objects contain 'symbol', 'isPrefix', 'decimals' keys
  - [ ] All 'symbol' values are non-empty strings
  - [ ] All 'isPrefix' values are booleans
  - [ ] All 'decimals' values are integers (0, 1, or 2)

### Integration Tests

- [ ] **Test with convertAndFormatPrice**
  - [ ] DKK price formats correctly (suffix, no decimals)
  - [ ] EUR price formats correctly (prefix, 2 decimals)
  - [ ] USD price formats correctly (prefix, 2 decimals)
  - [ ] GBP price formats correctly (prefix, 1 decimal)
  - [ ] Unknown currency falls back gracefully

- [ ] **Test with convertAndFormatPriceRange**
  - [ ] Price range with prefix currency (€100 - €200)
  - [ ] Price range with suffix currency (100 - 200 kr.)
  - [ ] Price range respects decimal precision

- [ ] **Test with getCurrencyOptionsForLanguage**
  - [ ] Currency options display correct symbols
  - [ ] Symbol extraction works for all languages
  - [ ] Fallback to currency code when symbol extraction fails

### Edge Case Tests

- [ ] **Whitespace handling**
  - [ ] Leading whitespace (' DKK') - currently fails, should add trim()
  - [ ] Trailing whitespace ('DKK ') - currently fails, should add trim()
  - [ ] Whitespace in middle ('D KK') - should return default

- [ ] **Special characters**
  - [ ] Dollar sign ($) escapes correctly in JSON
  - [ ] Unicode symbols (€, £, ¥, ₩, ₴, zł) encode correctly
  - [ ] Period in 'kr.' symbol works correctly

### Performance Tests

- [ ] **Response time**
  - [ ] Function executes in < 1ms (static lookup)
  - [ ] No memory allocation issues with repeated calls
  - [ ] JSON encoding performance is acceptable

---

## Migration Notes

### From FlutterFlow to Pure Flutter/Dart

**Current State:** Function is already pure Dart with no FlutterFlow dependencies.

**Migration Status:** ✅ READY FOR IMMEDIATE USE

**No changes required:**
- Uses only `dart:convert` (standard library)
- No FFAppState dependencies
- No custom action dependencies
- Self-contained logic

**Integration Steps:**

1. **Copy function to pure Flutter project:**
   ```dart
   // lib/shared/currency_utils.dart
   import 'dart:convert';

   String? getCurrencyFormattingRules(String currencyCode) {
     // Copy implementation exactly as-is
   }
   ```

2. **Add import to files that need currency formatting:**
   ```dart
   import 'package:journeymate/shared/currency_utils.dart';
   ```

3. **No state management changes needed** - function is stateless

### Verification After Migration

- [ ] All 11 currencies format correctly
- [ ] Default fallback works for unknown currencies
- [ ] JSON parsing works in pure Flutter context
- [ ] No breaking changes in dependent functions

### Dependencies to Migrate

Before using this function in pure Flutter, ensure these dependent functions are also migrated:

1. **convertAndFormatPrice** (calls getCurrencyFormattingRules)
2. **convertAndFormatPriceRange** (calls getCurrencyFormattingRules)
3. **getCurrencyOptionsForLanguage** (calls getCurrencyFormattingRules)

All three functions must be migrated together as they form the currency formatting system.

### Potential Improvements for Pure Flutter Version

**Optional enhancement (not required for initial migration):**

```dart
// Consider adding input validation and trimming:
String? getCurrencyFormattingRules(String currencyCode) {
  // Normalize: trim whitespace and convert to uppercase
  final code = currencyCode.trim().toUpperCase();

  // Validate: check for 3-letter code format (optional)
  if (code.length != 3 || !RegExp(r'^[A-Z]{3}$').hasMatch(code)) {
    return jsonEncode(defaultCurrencyRule);
  }

  // Rest of implementation...
}
```

**Trade-offs:**
- **Pro:** More robust input handling
- **Con:** Adds validation overhead (currently ~1ms execution becomes ~2ms)
- **Recommendation:** Only add if input validation issues arise in production

---

## Related Documentation

### Functions That Call getCurrencyFormattingRules

1. **convertAndFormatPrice** (`custom_functions.dart:1733-1811`)
   - Formats single prices with currency conversion
   - Uses symbol, isPrefix, and decimals from this function
   - See: `MASTER_README_convert_and_format_price.md`

2. **convertAndFormatPriceRange** (`custom_functions.dart:1359-1467`)
   - Formats price ranges (min-max) with currency conversion
   - Uses symbol and isPrefix from this function
   - See: `MASTER_README_convert_and_format_price_range.md`

3. **getCurrencyOptionsForLanguage** (`custom_functions.dart:1469-1549`)
   - Generates localized currency dropdown options
   - Extracts symbol from this function for display labels
   - See: `MASTER_README_get_currency_options_for_language.md`

### Related Currency Functions

- **getLocalizedCurrencyName** (`custom_functions.dart:1186-1233`)
  - Returns localized currency names (e.g., "Danish krone")
  - Complements this function's symbol/formatting rules
  - See: `MASTER_README_get_localized_currency_name.md`

### Design System Reference

- **Typography and Spacing:** `_reference/journeymate-design-system.md`
- **Currency Display Standards:** Section 8.4 "Price Display Patterns"

---

## Analytics Integration

**Not Applicable** - This is a pure utility function with no analytics tracking.

Currency formatting decisions (e.g., which currency users select) are tracked at the UI level where currency selection occurs, not within this low-level formatting function.

---

## Change Log

### Initial Documentation (2026-02-19)
- Documented as part of Phase 3 migration preparation
- Function already exists in FlutterFlow export
- No code changes required for migration
- Identified as critical dependency for all currency display

---

## Approved By

**Technical Review:** [Pending]
**Design Review:** N/A (Pure utility function)
**Product Review:** N/A (Infrastructure component)

---

**Documentation Version:** 1.0
**Last Updated:** 2026-02-19
**Next Review:** After Phase 3 migration completion
