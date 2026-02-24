# convertAndFormatPriceRange — Custom Function Documentation

**Function Type:** Price Formatting & Currency Conversion
**Source:** `_flutterflow_export\lib\flutter_flow\custom_functions.dart` (lines 1359-1467)
**Phase 3 Status:** Ready for migration
**Last Updated:** 2026-02-19

---

## Purpose

Converts and formats a price range (min-max) with currency conversion and localized formatting rules.

**What it does:**
- Accepts a min/max price pair in an original currency
- Converts both values using an exchange rate to a target currency
- Formats the range according to currency-specific rules (symbol placement, decimals, thousands separators)
- Returns a properly formatted price range string (e.g., "100 - 200 kr." or "€13 - €27")

**Business context:**
- Used on restaurant cards and profiles to display price ranges in the user's preferred currency
- Supports international users by converting prices from restaurant's local currency (typically DKK) to user's selected display currency
- Maintains consistent formatting across all price displays in the app

**Related functions:**
- `convertAndFormatPrice` (single price conversion) — lines 1733-1811
- `getCurrencyFormattingRules` (currency formatting rules) — lines 2093-2132

---

## Function Signature

```dart
String? convertAndFormatPriceRange(
  double minPrice,
  double maxPrice,
  String originalCurrencyCode,
  double exchangeRate,
  String targetCurrencyCode,
)
```

**Return Type:** `String?` (nullable)
- Returns formatted price range string on success
- Returns `null` on validation failure (invalid inputs, invalid range)

---

## Parameters

### `minPrice` — double
**Purpose:** Minimum price value in the original currency
**Validation:** Must be >= 0, must be <= maxPrice
**Example:** `100.0` (100 DKK)

**Usage context:**
- Represents the lowest-priced item/option at the restaurant
- Stored in the database as `min_price_range` field on businesses table

### `maxPrice` — double
**Purpose:** Maximum price value in the original currency
**Validation:** Must be >= 0, must be >= minPrice
**Example:** `200.0` (200 DKK)

**Usage context:**
- Represents the highest-priced main course at the restaurant
- Stored in the database as `max_price_range` field on businesses table

### `originalCurrencyCode` — String
**Purpose:** ISO 4217 currency code of the input prices
**Format:** Three-letter uppercase code (e.g., "DKK", "USD", "EUR")
**Example:** `"DKK"` (Danish Krone — most common in Copenhagen restaurants)

**Usage context:**
- Typically stored as `local_currency` field on businesses table
- Allows restaurants to store prices in their native currency
- Normalized to uppercase internally for comparison

### `exchangeRate` — double
**Purpose:** Conversion rate from original currency to target currency
**Validation:** Must be > 0
**Example:** `0.13` (DKK to EUR rate: 1 DKK = 0.13 EUR)

**Usage context:**
- Retrieved from FFAppState or API call at app startup
- Updated periodically (daily or on demand) to maintain accuracy
- Set to `1.0` when original and target currencies are the same (no conversion needed)

**Calculation logic:**
- `convertedPrice = originalPrice * exchangeRate`
- If `originalCurrencyCode == targetCurrencyCode`, conversion is skipped (returns original)

### `targetCurrencyCode` — String
**Purpose:** ISO 4217 currency code for output display
**Format:** Three-letter uppercase code
**Example:** `"EUR"` (if user selected Euro as display currency)

**Usage context:**
- Retrieved from FFAppState.selectedCurrencyCode
- User selects this in settings/preferences
- Determines output formatting rules (symbol, placement, decimals)

---

## Return Value

### Success Cases

**Type:** `String` (formatted price range)

**Format depends on currency rules:**

#### Prefix Symbol Currencies (EUR, USD, GBP)
- Symbol appears before each price value
- Format: `"{symbol}{min} - {symbol}{max}"`
- Examples:
  - `"€100 - €200"` (EUR with 2 decimals)
  - `"$100.00 - $200.00"` (USD with 2 decimals)
  - `"£100.0 - £200.0"` (GBP with 1 decimal)

#### Suffix Symbol Currencies (DKK, NOK, SEK, JPY)
- Single symbol appears after both values
- Format: `"{min} - {max} {symbol}"`
- Examples:
  - `"100 - 200 kr."` (DKK with 0 decimals)
  - `"700 - 1,400 kr."` (DKK with thousands separator)
  - `"10,000 - 20,000 ¥"` (JPY with 0 decimals)

**Formatting rules applied:**
- Thousands separators: `,` for values >= 1,000
- Decimal places: 0, 1, or 2 based on currency
- Rounding: Rounds to nearest integer for 0-decimal currencies
- No trailing zeros for decimal currencies

### Failure Cases

**Type:** `null`

**Returns null when:**
1. **Negative prices:** `minPrice < 0` OR `maxPrice < 0`
2. **Invalid exchange rate:** `exchangeRate <= 0`
3. **Invalid range:** `minPrice > maxPrice`
4. **Unknown currency:** `targetCurrencyCode` not in formatting rules
5. **JSON parse failure:** `getCurrencyFormattingRules()` returns invalid JSON

**Error handling:**
- Function fails silently (returns null)
- UI should handle null case with fallback display (e.g., "Price unavailable")
- No exceptions thrown — safe for widget builds

---

## Dependencies

### Internal Functions

#### `getCurrencyFormattingRules(String currencyCode)` — lines 2093-2132
**Purpose:** Central source of truth for currency display rules
**Returns:** JSON string with formatting rules:
```dart
{
  "symbol": "kr.",      // Display symbol
  "isPrefix": false,    // Symbol placement (true = before, false = after)
  "decimals": 0         // Number of decimal places (0, 1, or 2)
}
```

**Supported currencies:**
| Code | Symbol | Placement | Decimals | Example Output |
|------|--------|-----------|----------|----------------|
| CNY  | ¥      | Prefix    | 0        | ¥100 - ¥200    |
| DKK  | kr.    | Suffix    | 0        | 100 - 200 kr.  |
| EUR  | €      | Prefix    | 2        | €13.45 - €26.90|
| GBP  | £      | Prefix    | 1        | £13.5 - £27.0  |
| JPY  | ¥      | Suffix    | 0        | 10,000 - 20,000 ¥|
| KRW  | ₩      | Suffix    | 0        | 100,000 - 200,000 ₩|
| NOK  | kr.    | Suffix    | 0        | 100 - 200 kr.  |
| PLN  | zł     | Suffix    | 0        | 100 - 200 zł   |
| SEK  | kr.    | Suffix    | 0        | 100 - 200 kr.  |
| UAH  | ₴      | Suffix    | 0        | 100 - 200 ₴    |
| USD  | $      | Prefix    | 2        | $13.45 - $26.90|

**Default rule (unknown currencies):**
- Symbol: `"kr."`
- Placement: Suffix
- Decimals: 0

#### `_convertPrice()` — Helper Function (lines 1392-1401)
**Purpose:** Converts price using exchange rate, or returns original if same currency
**Logic:**
```dart
double _convertPrice(double price, String from, String to, double rate) {
  return from.toUpperCase() == to.toUpperCase() ? price : price * rate;
}
```

**Optimization:**
- Skips multiplication when currencies match
- Case-insensitive comparison for safety

#### `_formatPrice()` — Helper Function (lines 1404-1406)
**Purpose:** Formats number as integer with thousands separator
**Logic:**
```dart
String _formatPrice(double price) {
  return NumberFormat('###,###').format(price.round());
}
```

**Note:** This helper only handles integer formatting. Decimal formatting is done separately in the main function based on currency rules.

### External Packages

#### `dart:convert`
**Used for:** JSON parsing of currency formatting rules
**Import:** `import 'dart:convert';`
**Functions used:** `jsonDecode()`

#### `package:intl/intl.dart`
**Used for:** Number formatting with locale support
**Import:** `import 'package:intl/intl.dart';`
**Class used:** `NumberFormat`

**Format patterns:**
- `'###,###'` — Integer with thousands separator, no decimals
- `'###,##0.0'` — One decimal place, thousands separator
- `'###,##0.00'` — Two decimal places, thousands separator

---

## FFAppState Usage

### Read Access

#### `FFAppState.selectedCurrencyCode` — String
**Purpose:** User's preferred display currency
**Type:** App-level persistent state
**Default:** `"DKK"` (Danish market)
**Set by:** User in settings/preferences page

**Usage in function call:**
```dart
final formattedRange = convertAndFormatPriceRange(
  minPrice,
  maxPrice,
  originalCurrency,
  exchangeRate,
  FFAppState().selectedCurrencyCode, // ← Read here
);
```

#### `FFAppState.exchangeRates` — Map<String, double>
**Purpose:** Current exchange rates from base currency (DKK) to all supported currencies
**Type:** App-level session state (updated daily)
**Structure:**
```dart
{
  "EUR": 0.134,
  "USD": 0.145,
  "GBP": 0.116,
  "NOK": 1.49,
  "SEK": 1.51,
  // ... etc
}
```

**Usage in function call:**
```dart
final rate = FFAppState().exchangeRates[FFAppState().selectedCurrencyCode] ?? 1.0;
final formattedRange = convertAndFormatPriceRange(
  minPrice,
  maxPrice,
  originalCurrency,
  rate, // ← Read here
  FFAppState().selectedCurrencyCode,
);
```

### Write Access

**None** — This function is read-only and does not modify FFAppState.

---

## Usage Examples

### Example 1: Restaurant Card (DKK to DKK — No Conversion)

**Context:** Danish user viewing Copenhagen restaurant prices

```dart
// Restaurant data from database
final minPrice = 125.0;  // 125 DKK
final maxPrice = 245.0;  // 245 DKK
final restaurantCurrency = "DKK";

// User preferences
final selectedCurrency = "DKK";
final exchangeRate = 1.0;  // Same currency, no conversion

// Format price range
final priceRange = convertAndFormatPriceRange(
  minPrice,
  maxPrice,
  restaurantCurrency,
  exchangeRate,
  selectedCurrency,
);

// Result: "125 - 245 kr."
```

**Output:** `"125 - 245 kr."`

**Formatting applied:**
- No conversion (1.0 rate, same currency)
- Rounded to integers (0 decimals for DKK)
- Symbol placed after range (suffix)
- No thousands separator needed (values < 1,000)

---

### Example 2: Restaurant Card (DKK to EUR — Conversion)

**Context:** German tourist viewing Copenhagen restaurant prices in Euros

```dart
// Restaurant data (Copenhagen)
final minPrice = 100.0;  // 100 DKK
final maxPrice = 200.0;  // 200 DKK
final restaurantCurrency = "DKK";

// User preferences (German tourist)
final selectedCurrency = "EUR";
final exchangeRate = 0.134;  // 1 DKK = 0.134 EUR

// Format price range
final priceRange = convertAndFormatPriceRange(
  minPrice,
  maxPrice,
  restaurantCurrency,
  exchangeRate,
  selectedCurrency,
);

// Conversion: 100 DKK * 0.134 = 13.4 EUR → rounds to 13.40
//             200 DKK * 0.134 = 26.8 EUR → rounds to 26.80

// Result: "€13 - €27"
```

**Output:** `"€13 - €27"`

**Formatting applied:**
- Currency conversion: 100 DKK → 13.4 EUR, 200 DKK → 26.8 EUR
- Rounded and formatted with 2 decimals (EUR rule)
- Symbol placed before each value (prefix)
- Display shows rounded integers for readability (actual values: €13.40, €26.80)

---

### Example 3: Restaurant Card (DKK to USD — With Thousands Separator)

**Context:** American tourist viewing expensive restaurant prices

```dart
// Restaurant data (high-end restaurant)
final minPrice = 700.0;   // 700 DKK
final maxPrice = 1400.0;  // 1,400 DKK
final restaurantCurrency = "DKK";

// User preferences (American tourist)
final selectedCurrency = "USD";
final exchangeRate = 0.145;  // 1 DKK = 0.145 USD

// Format price range
final priceRange = convertAndFormatPriceRange(
  minPrice,
  maxPrice,
  restaurantCurrency,
  exchangeRate,
  selectedCurrency,
);

// Conversion: 700 DKK * 0.145 = 101.5 USD → 101.50
//             1400 DKK * 0.145 = 203.0 USD → 203.00

// Result: "$101.50 - $203.00"
```

**Output:** `"$101.50 - $203.00"`

**Formatting applied:**
- Currency conversion applied
- Formatted with 2 decimals (USD rule)
- Symbol placed before each value (prefix)
- Thousands separator not needed (values < 1,000)

---

### Example 4: Business Profile (Same Currency, Large Values)

**Context:** Local user viewing high-end restaurant with DKK prices

```dart
// Restaurant data (luxury restaurant)
final minPrice = 800.0;   // 800 DKK
final maxPrice = 1500.0;  // 1,500 DKK
final restaurantCurrency = "DKK";

// User preferences (local)
final selectedCurrency = "DKK";
final exchangeRate = 1.0;  // No conversion

// Format price range
final priceRange = convertAndFormatPriceRange(
  minPrice,
  maxPrice,
  restaurantCurrency,
  exchangeRate,
  selectedCurrency,
);

// Result: "800 - 1,500 kr."
```

**Output:** `"800 - 1,500 kr."`

**Formatting applied:**
- No conversion (same currency)
- Integer formatting (0 decimals)
- Thousands separator on max value (1,500)
- Single suffix symbol after range

---

### Example 5: Error Handling (Invalid Range)

**Context:** Database corruption or bad API response

```dart
// Invalid data (min > max)
final minPrice = 300.0;
final maxPrice = 150.0;  // ERROR: max < min
final restaurantCurrency = "DKK";
final selectedCurrency = "EUR";
final exchangeRate = 0.134;

// Attempt to format
final priceRange = convertAndFormatPriceRange(
  minPrice,
  maxPrice,
  restaurantCurrency,
  exchangeRate,
  selectedCurrency,
);

// Result: null (validation failure)
```

**Output:** `null`

**Fallback UI handling:**
```dart
final displayText = priceRange ?? "Price unavailable";
// Shows: "Price unavailable"
```

---

### Example 6: Error Handling (Negative Price)

**Context:** Database validation missed negative value

```dart
// Invalid data (negative price)
final minPrice = -50.0;  // ERROR: negative
final maxPrice = 200.0;
final restaurantCurrency = "DKK";
final selectedCurrency = "EUR";
final exchangeRate = 0.134;

// Attempt to format
final priceRange = convertAndFormatPriceRange(
  minPrice,
  maxPrice,
  restaurantCurrency,
  exchangeRate,
  selectedCurrency,
);

// Result: null (validation failure)
```

**Output:** `null`

---

### Example 7: Real-World Restaurant Card Widget

**Context:** Complete implementation on search results page

```dart
// In RestaurantCard widget build method
Widget build(BuildContext context) {
  // Get exchange rate for selected currency
  final selectedCurrency = FFAppState().selectedCurrencyCode;
  final exchangeRate = FFAppState().exchangeRates[selectedCurrency] ?? 1.0;

  // Format price range
  final priceRange = convertAndFormatPriceRange(
    restaurant.minPriceRange,       // From database
    restaurant.maxPriceRange,       // From database
    restaurant.localCurrency,       // From database
    exchangeRate,                   // From FFAppState
    selectedCurrency,               // From FFAppState
  );

  return Card(
    child: Column(
      children: [
        Text(restaurant.name),
        // Display price range with fallback
        Text(
          priceRange ?? 'Price unavailable',
          style: TextStyle(
            color: priceRange != null ? Colors.black87 : Colors.grey,
            fontSize: 14,
          ),
        ),
        // ... rest of card
      ],
    ),
  );
}
```

---

## Edge Cases

### Edge Case 1: Zero Price Range (Free Items)

**Scenario:** Restaurant offers free items (e.g., complimentary bread)

```dart
final minPrice = 0.0;
final maxPrice = 0.0;
final result = convertAndFormatPriceRange(0.0, 0.0, "DKK", 1.0, "DKK");
// Result: "0 - 0 kr."
```

**Behavior:** Valid, formats as `"0 - 0 kr."`
**UI consideration:** Widget should detect zero range and display "Free" instead

---

### Edge Case 2: Same Min and Max (Fixed Price)

**Scenario:** Restaurant offers single-price menu (e.g., buffet)

```dart
final minPrice = 150.0;
final maxPrice = 150.0;
final result = convertAndFormatPriceRange(150.0, 150.0, "DKK", 1.0, "DKK");
// Result: "150 - 150 kr."
```

**Behavior:** Valid, formats as `"150 - 150 kr."`
**UI consideration:** Widget should detect equal values and display as single price: `"150 kr."`

---

### Edge Case 3: Very Large Price Values

**Scenario:** High-end restaurant with expensive tasting menus

```dart
final minPrice = 5000.0;
final maxPrice = 12000.0;
final result = convertAndFormatPriceRange(5000.0, 12000.0, "DKK", 1.0, "DKK");
// Result: "5,000 - 12,000 kr."
```

**Behavior:** Valid, includes thousands separators
**Formatting:** `NumberFormat('###,###')` handles values up to millions

---

### Edge Case 4: Very Small Converted Values

**Scenario:** Converting small DKK amounts to high-value currency (e.g., JPY)

```dart
final minPrice = 10.0;    // 10 DKK
final maxPrice = 25.0;    // 25 DKK
final exchangeRate = 21.5; // 1 DKK = 21.5 JPY
final result = convertAndFormatPriceRange(10.0, 25.0, "DKK", 21.5, "JPY");
// Conversion: 10 * 21.5 = 215 JPY, 25 * 21.5 = 537.5 JPY
// Result: "215 - 538 ¥"
```

**Behavior:** Valid, rounds to integers (JPY has 0 decimals)
**Rounding:** 537.5 rounds to 538

---

### Edge Case 5: Currency Code Case Sensitivity

**Scenario:** Mixed-case currency codes from API

```dart
// Lowercase target currency
final result1 = convertAndFormatPriceRange(100.0, 200.0, "DKK", 1.0, "dkk");
// Result: "100 - 200 kr." (normalized to uppercase)

// Uppercase original currency
final result2 = convertAndFormatPriceRange(100.0, 200.0, "dkk", 1.0, "DKK");
// Result: "100 - 200 kr." (normalized to uppercase)
```

**Behavior:** Function normalizes to uppercase internally
**Comparison:** Case-insensitive currency matching works correctly

---

### Edge Case 6: Unknown Target Currency

**Scenario:** User selects unsupported currency (e.g., future currency addition)

```dart
final result = convertAndFormatPriceRange(100.0, 200.0, "DKK", 1.0, "XYZ");
// getCurrencyFormattingRules("XYZ") returns default rule
// Result: "100 - 200 kr." (default suffix format)
```

**Behavior:** Falls back to default formatting rule (DKK-style)
**Symbol:** Uses "kr." suffix with 0 decimals

---

### Edge Case 7: Exchange Rate Exactly Zero

**Scenario:** Bad exchange rate data (should never happen, but technically possible)

```dart
final result = convertAndFormatPriceRange(100.0, 200.0, "DKK", 0.0, "EUR");
// Result: null (validation fails)
```

**Behavior:** Returns `null` (invalid exchange rate)
**Validation:** `exchangeRate <= 0` check catches this

---

### Edge Case 8: Extremely High Exchange Rate

**Scenario:** Converting to hyperinflated currency

```dart
final minPrice = 1.0;      // 1 DKK
final maxPrice = 5.0;      // 5 DKK
final exchangeRate = 10000.0; // Hypothetical extreme rate
final result = convertAndFormatPriceRange(1.0, 5.0, "DKK", 10000.0, "XYZ");
// Conversion: 1 * 10000 = 10,000, 5 * 10000 = 50,000
// Result: "10,000 - 50,000 kr." (default format)
```

**Behavior:** Valid, handles large numbers with thousands separators
**Limitation:** No scientific notation — may truncate extremely large values

---

### Edge Case 9: Rounding Precision for Decimal Currencies

**Scenario:** EUR conversion results in repeating decimals

```dart
final minPrice = 99.0;    // 99 DKK
final maxPrice = 199.0;   // 199 DKK
final exchangeRate = 0.134222; // More precise rate
final result = convertAndFormatPriceRange(99.0, 199.0, "DKK", 0.134222, "EUR");
// Conversion: 99 * 0.134222 = 13.287978 → 13.29 EUR
//             199 * 0.134222 = 26.710178 → 26.71 EUR
// Result: "€13.29 - €26.71"
```

**Behavior:** NumberFormat handles rounding automatically
**Precision:** Two decimal places for EUR (as per formatting rules)

---

## Testing Checklist

### Unit Tests

- [ ] **Basic conversion (same currency)**: Verify no conversion when `originalCurrencyCode == targetCurrencyCode`
- [ ] **Basic conversion (different currency)**: Verify correct multiplication by exchange rate
- [ ] **Suffix symbol formatting**: Test DKK output format `"100 - 200 kr."`
- [ ] **Prefix symbol formatting**: Test EUR output format `"€13 - €27"`
- [ ] **Thousands separator**: Test values >= 1,000 include commas (e.g., `"1,000 - 2,000 kr."`)
- [ ] **Zero decimal formatting (DKK)**: Verify no decimal places, integer rounding
- [ ] **One decimal formatting (GBP)**: Verify single decimal place `"£100.0 - £200.0"`
- [ ] **Two decimal formatting (EUR/USD)**: Verify two decimal places `"€13.45 - €26.90"`
- [ ] **Validation: negative minPrice**: Verify returns `null`
- [ ] **Validation: negative maxPrice**: Verify returns `null`
- [ ] **Validation: minPrice > maxPrice**: Verify returns `null`
- [ ] **Validation: zero exchange rate**: Verify returns `null`
- [ ] **Validation: negative exchange rate**: Verify returns `null`
- [ ] **Edge case: zero range**: Test `(0, 0)` returns `"0 - 0 kr."`
- [ ] **Edge case: equal min/max**: Test `(150, 150)` returns `"150 - 150 kr."`
- [ ] **Edge case: large values**: Test thousands separator on values >= 1,000
- [ ] **Edge case: case sensitivity**: Verify currency codes normalized to uppercase
- [ ] **Edge case: unknown currency**: Verify falls back to default formatting
- [ ] **Helper function: _convertPrice**: Test skips conversion when currencies match
- [ ] **Helper function: _formatPrice**: Test integer formatting with thousands separator
- [ ] **JSON parsing**: Test getCurrencyFormattingRules returns valid JSON
- [ ] **JSON parsing failure**: Test handles invalid JSON (returns null)

### Integration Tests

- [ ] **Restaurant card widget**: Verify price range displays correctly on search results
- [ ] **Business profile widget**: Verify price range displays correctly on detail page
- [ ] **Currency switching**: Change FFAppState.selectedCurrencyCode and verify UI updates
- [ ] **Exchange rate update**: Update FFAppState.exchangeRates and verify conversion changes
- [ ] **Null price handling**: Test restaurant with null min/max prices (widget fallback)
- [ ] **Invalid data handling**: Test restaurant with invalid price range (UI shows fallback)
- [ ] **Multi-currency listing**: Test list view with restaurants in different original currencies
- [ ] **Performance**: Test formatting 100+ restaurants in list view (should be instant)

### Visual Regression Tests

- [ ] **DKK output**: Screenshot and verify `"100 - 200 kr."` format
- [ ] **EUR output**: Screenshot and verify `"€13 - €27"` format
- [ ] **USD output**: Screenshot and verify `"$100.00 - $200.00"` format
- [ ] **GBP output**: Screenshot and verify `"£100.0 - £200.0"` format
- [ ] **Thousands separator**: Screenshot and verify `"1,000 - 2,000 kr."` format
- [ ] **Restaurant card layout**: Verify price range fits within card width
- [ ] **Business profile layout**: Verify price range aligns with other text elements
- [ ] **Fallback text**: Verify "Price unavailable" displays when function returns null

### Manual Testing Scenarios

- [ ] **Real Copenhagen restaurant**: Verify accurate conversion to EUR/USD/GBP
- [ ] **Compare with Google Finance**: Verify exchange rate accuracy within 1%
- [ ] **User flow: Change currency setting**: Verify all prices update immediately
- [ ] **User flow: Browse restaurants**: Verify consistent formatting across all listings
- [ ] **Accessibility**: Verify screen reader announces price range correctly
- [ ] **Dark mode**: Verify price range text remains readable

---

## Migration Notes

### Phase 3 Migration Checklist

- [ ] **Read FlutterFlow source**: Review this function (lines 1359-1467) before implementing
- [ ] **Copy logic exactly**: Preserve all conversion and formatting logic
- [ ] **Port helper functions**: Include `_convertPrice()` and `_formatPrice()` helpers
- [ ] **Maintain validation**: Keep all input validation checks (negative, invalid range, etc.)
- [ ] **Use getCurrencyFormattingRules**: Call shared function for currency rules
- [ ] **Import dependencies**: Add `dart:convert` and `package:intl/intl.dart`
- [ ] **Test all currencies**: Verify output for DKK, EUR, USD, GBP, NOK, SEK
- [ ] **Test edge cases**: Validate zero range, equal min/max, large values, negative inputs
- [ ] **Update restaurant card**: Integrate into Card widget on search results page
- [ ] **Update business profile**: Integrate into detail page price display
- [ ] **Handle null returns**: Add fallback text ("Price unavailable") in UI
- [ ] **Verify with screenshots**: Compare Flutter output to FlutterFlow screenshots

### Implementation Strategy

**Step 1: Create shared function file**
```dart
// lib/shared/functions/price_formatting.dart
String? convertAndFormatPriceRange(
  double minPrice,
  double maxPrice,
  String originalCurrencyCode,
  double exchangeRate,
  String targetCurrencyCode,
) {
  // Copy implementation from FlutterFlow source
}
```

**Step 2: Port helper functions**
- Include `_convertPrice()` helper
- Include `_formatPrice()` helper
- Ensure both are private (underscore prefix)

**Step 3: Add to shared barrel file**
```dart
// lib/shared/functions/functions.dart
export 'price_formatting.dart';
```

**Step 4: Import in widgets**
```dart
import 'package:journeymate/shared/functions/functions.dart';
```

**Step 5: Replace widget logic**
- Find all widgets displaying price ranges
- Replace inline formatting with function call
- Add null handling with fallback text

**Step 6: Test thoroughly**
- Run unit tests for all currency combinations
- Test in restaurant card widget
- Test in business profile widget
- Verify with visual regression tests

### Code Quality Standards

**Follow these rules during migration:**
- Preserve exact conversion logic from FlutterFlow source
- Keep validation checks identical
- Maintain helper function structure
- Use same variable names where possible
- Add comprehensive dartdoc comments
- Include usage examples in documentation
- Write unit tests before widget integration
- Test all supported currencies (11 total)
- Verify thousands separator behavior
- Test with real restaurant data

### Potential Migration Issues

#### Issue 1: NumberFormat Locale Dependency
**Problem:** NumberFormat might format differently based on device locale
**Solution:** Explicitly specify locale or use locale-independent pattern
**Fix:**
```dart
// Instead of:
NumberFormat('###,###').format(price.round())

// Use:
NumberFormat('###,###', 'en_US').format(price.round())
```

#### Issue 2: JSON Parsing Robustness
**Problem:** getCurrencyFormattingRules might return invalid JSON
**Solution:** Wrap jsonDecode in try-catch (already implemented)
**Verify:** Test with invalid JSON strings in unit tests

#### Issue 3: Null Safety Violations
**Problem:** Dynamic types from FlutterFlow might not translate cleanly
**Solution:** Add explicit type checks and null assertions
**Example:**
```dart
final symbol = rules['symbol'] as String;  // May throw if null
// Better:
final symbol = (rules['symbol'] as String?) ?? '';  // Safe
```

#### Issue 4: FFAppState Access Patterns
**Problem:** FlutterFlow uses FFAppState() directly, Flutter might use Provider/Riverpod
**Solution:** Abstract state access through getter functions
**Example:**
```dart
// In widget:
final selectedCurrency = context.read<AppState>().selectedCurrencyCode;
final exchangeRate = context.read<AppState>().exchangeRates[selectedCurrency];
```

### Testing Strategy

**Test in this order:**
1. Unit tests for function in isolation (all currencies, all edge cases)
2. Integration tests for state access (FFAppState/Provider)
3. Widget tests for restaurant card display
4. Widget tests for business profile display
5. Visual regression tests (screenshot comparison)
6. Manual testing with real restaurant data
7. Performance testing with large lists (100+ restaurants)

### Documentation Requirements

**Must document:**
- All supported currencies (11 total) with examples
- All validation rules and failure cases
- Expected output format for each currency type
- Edge cases and their behavior
- FFAppState dependencies (selectedCurrencyCode, exchangeRates)
- Widget integration examples (restaurant card, business profile)
- Fallback UI handling for null returns

### Success Criteria

**Migration is complete when:**
- [ ] Function passes all unit tests (20+ test cases)
- [ ] Restaurant card widget displays prices correctly
- [ ] Business profile widget displays prices correctly
- [ ] All 11 currencies format correctly
- [ ] Thousands separators work for large values
- [ ] Decimal formatting matches currency rules
- [ ] Null handling works (shows "Price unavailable")
- [ ] Currency switching updates UI immediately
- [ ] Visual regression tests pass (matches FlutterFlow screenshots)
- [ ] No performance degradation (instant formatting for 100+ restaurants)
- [ ] Code review approved (follows Flutter best practices)
- [ ] Documentation complete (this file + dartdoc comments)

---

## Related Functions

### `convertAndFormatPrice` (Single Price)
**Location:** lines 1733-1811
**Purpose:** Formats a single price value (not a range)
**Used in:** Menu item prices, add-on prices, variation prices
**Key difference:** Formats one value instead of min-max pair

### `getCurrencyFormattingRules` (Formatting Rules)
**Location:** lines 2093-2132
**Purpose:** Central source of truth for currency display rules
**Returns:** JSON with symbol, placement, decimals
**Critical dependency:** Both price functions rely on this

### `getLocalizedCurrencyName` (Currency Names)
**Location:** lines 1186-1233
**Purpose:** Returns localized currency name (e.g., "US Dollar", "danske kroner")
**Used in:** Settings page, currency picker dropdown
**Complementary:** Displays currency names; this function displays values

### `getCurrencyOptionsForLanguage` (Currency Selection)
**Location:** lines 1469-1549
**Purpose:** Returns available currencies for dropdown/picker
**Used in:** Settings page currency selection
**Related:** User selects currency here; this function formats values for it

---

**End of Documentation**
