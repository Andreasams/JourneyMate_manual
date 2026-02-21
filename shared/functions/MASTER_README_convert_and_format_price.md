# convertAndFormatPrice Function Documentation

## Purpose

Converts a price from one currency to another using exchange rates and formats the result according to currency-specific display rules (symbol placement, decimal places, spacing). This function is used throughout JourneyMate wherever menu item prices need to be displayed in the user's preferred currency.

**Primary Use Case:** Menu item price display in the `MenuDishesListView` widget, allowing users to view prices in their preferred currency regardless of the restaurant's base currency (DKK).

## Function Signature

```dart
String? convertAndFormatPrice(
  double basePrice,
  String originalCurrencyCode,
  double exchangeRate,
  String targetCurrencyCode,
)
```

**Location:** `C:\Users\Rikke\Documents\JourneyMate\_flutterflow_export\lib\flutter_flow\custom_functions.dart` (lines 1733-1811)

## Parameters

### basePrice
- **Type:** `double`
- **Required:** Yes
- **Description:** The price in the original currency (typically DKK for JourneyMate restaurants)
- **Valid Range:** `>= 0` (negative prices return `null`)
- **Example:** `125.0` (125 DKK)

### originalCurrencyCode
- **Type:** `String`
- **Required:** Yes
- **Description:** ISO 4217 currency code of the original price
- **Format:** 3-letter uppercase code (normalized internally if lowercase)
- **Common Values:** `'DKK'`, `'EUR'`, `'USD'`, `'GBP'`
- **Example:** `'DKK'`

### exchangeRate
- **Type:** `double`
- **Required:** Yes
- **Description:** Exchange rate from original currency to target currency
- **Valid Range:** `> 0` (zero or negative returns `null`)
- **Calculation:** `targetCurrencyAmount = basePriceAmount * exchangeRate`
- **Special Case:** If `originalCurrencyCode == targetCurrencyCode`, rate is ignored and price passes through unchanged
- **Example:** `0.13` (DKK → EUR conversion rate)

### targetCurrencyCode
- **Type:** `String`
- **Required:** Yes
- **Description:** ISO 4217 currency code for the output format
- **Format:** 3-letter code (normalized to uppercase internally)
- **Supported Currencies:** `DKK`, `EUR`, `USD`, `GBP`, `NOK`, `SEK`, `CNY`, `JPY`, `KRW`, `PLN`, `UAH`
- **Example:** `'EUR'`

## Return Value

### Type
`String?` (nullable string)

### Format
The returned string follows currency-specific formatting rules:

#### Prefix Currencies (symbol before number)
- **Currencies:** `EUR`, `USD`, `GBP`, `CNY`
- **Format:** `[symbol][formattedPrice]`
- **Examples:**
  - `"€17"` (EUR with 2 decimals)
  - `"$25.50"` (USD with 2 decimals)
  - `"£15.5"` (GBP with 1 decimal)
  - `"¥125"` (CNY with 0 decimals)

#### Suffix Currencies (symbol after number with space)
- **Currencies:** `DKK`, `NOK`, `SEK`, `JPY`, `KRW`, `PLN`, `UAH`
- **Format:** `[formattedPrice] [symbol]`
- **Examples:**
  - `"125 kr."` (DKK with 0 decimals)
  - `"1,250 kr."` (NOK with 0 decimals)
  - `"15,000 ¥"` (JPY with 0 decimals)
  - `"50 zł"` (PLN with 0 decimals)

#### Thousands Separator
All currencies use comma (`,`) as thousands separator:
- `1000` → `"1,000"`
- `25000` → `"25,000"`
- `125000` → `"125,000"`

### Null Return Cases
Returns `null` when:
1. `basePrice < 0` (negative price)
2. `exchangeRate <= 0` (invalid rate)
3. `getCurrencyFormattingRules()` returns `null` (unsupported currency)
4. JSON parsing fails for formatting rules

## Dependencies

### Internal Functions

#### getCurrencyFormattingRules(String currencyCode)
**Purpose:** Returns formatting rules for a currency as JSON string

**Location:** Lines 2093-2132 in `custom_functions.dart`

**Returns:**
```json
{
  "symbol": "kr.",
  "isPrefix": false,
  "decimals": 0
}
```

**Supported Currencies:**
| Currency | Symbol | Prefix? | Decimals |
|----------|--------|---------|----------|
| CNY | ¥ | Yes | 0 |
| DKK | kr. | No | 0 |
| EUR | € | Yes | 2 |
| GBP | £ | Yes | 1 |
| JPY | ¥ | No | 0 |
| KRW | ₩ | No | 0 |
| NOK | kr. | No | 0 |
| PLN | zł | No | 0 |
| SEK | kr. | No | 0 |
| UAH | ₴ | No | 0 |
| USD | $ | Yes | 2 |

**Default Rule (Unknown Currency):**
```json
{
  "symbol": "kr.",
  "isPrefix": false,
  "decimals": 0
}
```

### External Dependencies

#### NumberFormat (from `package:intl/intl.dart`)
**Purpose:** Formats numbers with thousands separators and decimal places

**Patterns Used:**
- `###,###` — Integer with thousands separator (0 decimals)
- `###,##0.0` — One decimal place with thousands separator
- `###,##0.00` — Two decimal places with thousands separator

#### jsonDecode (from `dart:convert`)
**Purpose:** Parses JSON string from `getCurrencyFormattingRules()`

## FFAppState Usage

**Does NOT use FFAppState.**

This function is stateless and receives all required data through parameters. Exchange rates and currency preferences are typically stored in `FFAppState` but are passed into this function by calling widgets.

**Typical FFAppState Fields Used by Calling Code:**
- `FFAppState().preferredCurrency` → `targetCurrencyCode`
- `FFAppState().exchangeRates[targetCurrency]` → `exchangeRate`

## Usage Examples

### Example 1: Basic DKK → EUR Conversion
```dart
// Convert 125 DKK to EUR with exchange rate 0.13
final result = convertAndFormatPrice(
  125.0,        // basePrice: 125 DKK
  'DKK',        // originalCurrencyCode
  0.13,         // exchangeRate: 1 DKK = 0.13 EUR
  'EUR',        // targetCurrencyCode
);

// Result: "€16.25"
// Calculation: 125 * 0.13 = 16.25 EUR
// Format: EUR uses prefix symbol with 2 decimals
```

### Example 2: Same Currency (No Conversion)
```dart
// Display price in original currency (DKK → DKK)
final result = convertAndFormatPrice(
  250.0,        // basePrice: 250 DKK
  'DKK',        // originalCurrencyCode
  1.0,          // exchangeRate: irrelevant when same currency
  'DKK',        // targetCurrencyCode
);

// Result: "250 kr."
// No conversion performed (currencies match)
// Format: DKK uses suffix symbol with 0 decimals
```

### Example 3: Large Amount with Thousands Separator
```dart
// Convert 15,000 DKK to USD
final result = convertAndFormatPrice(
  15000.0,      // basePrice: 15,000 DKK
  'DKK',        // originalCurrencyCode
  0.14,         // exchangeRate: 1 DKK = 0.14 USD
  'USD',        // targetCurrencyCode
);

// Result: "$2,100.00"
// Calculation: 15,000 * 0.14 = 2,100 USD
// Format: USD uses prefix symbol with 2 decimals and comma separator
```

### Example 4: GBP with Single Decimal
```dart
// Convert 200 DKK to GBP
final result = convertAndFormatPrice(
  200.0,        // basePrice: 200 DKK
  'DKK',        // originalCurrencyCode
  0.11,         // exchangeRate: 1 DKK = 0.11 GBP
  'GBP',        // targetCurrencyCode
);

// Result: "£22.0"
// Calculation: 200 * 0.11 = 22.0 GBP
// Format: GBP uses prefix symbol with 1 decimal place
```

### Example 5: Real-World Widget Usage
```dart
// Inside MenuDishesListView widget
ListView.builder(
  itemCount: menuItems.length,
  itemBuilder: (context, index) {
    final item = menuItems[index];

    // Get user's preferred currency and exchange rate from state
    final targetCurrency = FFAppState().preferredCurrency;
    final exchangeRate = FFAppState().exchangeRates[targetCurrency] ?? 1.0;

    // Convert and format the price
    final displayPrice = convertAndFormatPrice(
      item['base_price'].toDouble(),
      'DKK',              // All JourneyMate prices are in DKK
      exchangeRate,
      targetCurrency,
    );

    return ListTile(
      title: Text(item['name']),
      trailing: Text(displayPrice ?? 'N/A'),
    );
  },
);
```

### Example 6: Price Range Formatting (Related Function)
```dart
// For price ranges, use convertAndFormatPriceRange instead
final priceRange = convertAndFormatPriceRange(
  100.0,        // minPrice
  200.0,        // maxPrice
  'DKK',        // originalCurrencyCode
  0.13,         // exchangeRate
  'EUR',        // targetCurrencyCode
);

// Result: "€13.00 - €26.00"
// Note: Uses convertAndFormatPrice logic for each bound
```

## Edge Cases

### Case 1: Negative Price
```dart
final result = convertAndFormatPrice(-50.0, 'DKK', 0.13, 'EUR');
// Returns: null
// Validation fails at line 1776
```

### Case 2: Zero Exchange Rate
```dart
final result = convertAndFormatPrice(125.0, 'DKK', 0.0, 'EUR');
// Returns: null
// Validation fails at line 1776
```

### Case 3: Negative Exchange Rate
```dart
final result = convertAndFormatPrice(125.0, 'DKK', -0.5, 'EUR');
// Returns: null
// Validation fails at line 1776
```

### Case 4: Zero Price (Valid)
```dart
final result = convertAndFormatPrice(0.0, 'DKK', 0.13, 'EUR');
// Returns: "€0.00"
// Zero is valid, formats normally
```

### Case 5: Unsupported Currency
```dart
final result = convertAndFormatPrice(125.0, 'DKK', 0.5, 'XYZ');
// Returns: "62 kr." (uses default rule)
// getCurrencyFormattingRules returns default for unknown currency
```

### Case 6: Lowercase Currency Codes
```dart
final result = convertAndFormatPrice(125.0, 'dkk', 0.13, 'eur');
// Returns: "€16.25"
// Currency codes are normalized to uppercase (lines 1779-1780)
```

### Case 7: Very Large Numbers
```dart
final result = convertAndFormatPrice(999999.0, 'DKK', 0.13, 'EUR');
// Returns: "€129,999.87"
// NumberFormat handles large numbers correctly with commas
```

### Case 8: Fractional Cents (Rounding)
```dart
final result = convertAndFormatPrice(100.0, 'DKK', 0.137, 'EUR');
// Returns: "€13.70"
// Calculation: 100 * 0.137 = 13.7 EUR
// NumberFormat handles decimal precision based on currency rules
```

### Case 9: JSON Parsing Failure
```dart
// If getCurrencyFormattingRules returns malformed JSON
// (Should never happen in production, but handled defensively)
final result = convertAndFormatPrice(125.0, 'DKK', 0.13, 'EUR');
// Returns: null
// Caught at lines 1793-1796
```

### Case 10: Same Currency with Different Cases
```dart
final result = convertAndFormatPrice(125.0, 'dkk', 0.13, 'DKK');
// Returns: "125 kr."
// Comparison at line 1783 is case-insensitive (both normalized to uppercase)
```

## Internal Logic Flow

### Step 1: Input Validation
```dart
// Lines 1776-1776
if (basePrice < 0 || exchangeRate <= 0) return null;
```
**Purpose:** Reject invalid inputs before processing

**Guards Against:**
- Negative prices
- Zero or negative exchange rates

### Step 2: Currency Code Normalization
```dart
// Lines 1779-1780
final targetCode = targetCurrencyCode.toUpperCase();
final originalCode = originalCurrencyCode.toUpperCase();
```
**Purpose:** Ensure case-insensitive currency matching

**Handles:** `'dkk'` → `'DKK'`, `'eur'` → `'EUR'`

### Step 3: Price Conversion (with Optimization)
```dart
// Lines 1783-1784
final convertedPrice =
    originalCode == targetCode ? basePrice : basePrice * exchangeRate;
```
**Purpose:** Convert price to target currency or pass through unchanged

**Optimization:** Skips multiplication when currencies match (avoids floating-point precision loss)

**Examples:**
- `DKK → EUR`: `125 * 0.13 = 16.25`
- `DKK → DKK`: `125` (unchanged)

### Step 4: Retrieve Formatting Rules
```dart
// Line 1787
final rulesJson = getCurrencyFormattingRules(targetCode);
```
**Purpose:** Get currency-specific display rules

**Returns:** JSON string like `'{"symbol":"kr.","isPrefix":false,"decimals":0}'`

**Fallback:** Returns default rule for unknown currencies

### Step 5: Parse JSON Rules
```dart
// Lines 1792-1796
final Map<String, dynamic> rules;
try {
  rules = jsonDecode(rulesJson);
} catch (e) {
  return null; // Failed to parse rules
}
```
**Purpose:** Convert JSON string to usable map

**Safety:** Wrapped in try-catch to handle malformed JSON

### Step 6: Extract Rule Components
```dart
// Lines 1799-1801
final symbol = rules['symbol'] as String;
final isPrefix = rules['isPrefix'] as bool;
final decimals = rules['decimals'] as int;
```
**Purpose:** Extract individual formatting properties

**Properties:**
- `symbol`: Currency symbol (`"€"`, `"kr."`, `"$"`)
- `isPrefix`: Symbol placement (`true` = before, `false` = after)
- `decimals`: Decimal places to show (`0`, `1`, or `2`)

### Step 7: Format Price with Decimals
```dart
// Lines 1804-1807
final pattern = _getFormatPattern(decimals);
final formattedPrice = decimals == 0
    ? NumberFormat(pattern).format(convertedPrice.round())
    : NumberFormat(pattern).format(convertedPrice);
```
**Purpose:** Format number with appropriate decimal places and thousands separators

**Helper Function:**
```dart
String _getFormatPattern(int decimals) {
  switch (decimals) {
    case 0:
      return '###,###';
    case 1:
      return '###,##0.0';
    case 2:
      return '###,##0.00';
    default:
      return '###,###';
  }
}
```

**Logic:**
- **0 decimals:** Round to nearest integer, then format
- **1-2 decimals:** Format with exact decimal places
- **Thousands:** Always use comma separator

**Examples:**
- `125.0` with 0 decimals → `"125"`
- `125.5` with 0 decimals → `"126"` (rounded)
- `125.5` with 1 decimal → `"125.5"`
- `125.567` with 2 decimals → `"125.57"` (rounded)
- `1250.0` with 0 decimals → `"1,250"`

### Step 8: Build Output String
```dart
// Line 1810
return isPrefix ? '$symbol$formattedPrice' : '$formattedPrice $symbol';
```
**Purpose:** Combine symbol and formatted price in correct order

**Prefix Currencies (no space):**
```dart
'$symbol$formattedPrice'  // "€125.50"
```

**Suffix Currencies (with space):**
```dart
'$formattedPrice $symbol'  // "125 kr."
```

## Testing Checklist

### Input Validation Tests
- [ ] Negative price returns `null`
- [ ] Zero price formats correctly (`"€0.00"` for EUR)
- [ ] Zero exchange rate returns `null`
- [ ] Negative exchange rate returns `null`
- [ ] Positive values process successfully

### Currency Matching Tests
- [ ] Same currency skips conversion (DKK → DKK)
- [ ] Case-insensitive matching works (`'dkk'` == `'DKK'`)
- [ ] Different currencies apply conversion correctly

### Conversion Tests
- [ ] DKK → EUR: `125 * 0.13 = €16.25`
- [ ] DKK → USD: `100 * 0.14 = $14.00`
- [ ] DKK → GBP: `200 * 0.11 = £22.0`
- [ ] EUR → DKK: `100 * 7.5 = 750 kr.`

### Formatting Tests
- [ ] EUR shows 2 decimals: `"€16.25"`
- [ ] USD shows 2 decimals: `"$14.00"`
- [ ] GBP shows 1 decimal: `"£22.0"`
- [ ] DKK shows 0 decimals: `"125 kr."`
- [ ] NOK shows 0 decimals: `"250 kr."`
- [ ] JPY shows 0 decimals: `"15,000 ¥"`

### Symbol Placement Tests
- [ ] EUR prefix: `"€16.25"` (no space)
- [ ] USD prefix: `"$14.00"` (no space)
- [ ] DKK suffix: `"125 kr."` (with space)
- [ ] NOK suffix: `"250 kr."` (with space)

### Thousands Separator Tests
- [ ] 1,000 displays as `"1,000"`
- [ ] 15,000 displays as `"15,000"`
- [ ] 125,000 displays as `"125,000"`
- [ ] 1,000,000 displays as `"1,000,000"`

### Decimal Precision Tests
- [ ] 0 decimals rounds: `125.7 kr.` → `"126 kr."`
- [ ] 1 decimal shows: `125.75 GBP` → `"£125.8"`
- [ ] 2 decimals show: `125.755 EUR` → `"€125.76"`
- [ ] Trailing zeros preserved: `125.0 EUR` → `"€125.00"`

### Edge Case Tests
- [ ] Unsupported currency uses default rule
- [ ] Malformed JSON returns `null`
- [ ] Very large numbers format correctly
- [ ] Very small fractions round correctly
- [ ] Exact currency match optimization works

### Integration Tests
- [ ] Works in `MenuDishesListView` widget
- [ ] Works with `FFAppState().preferredCurrency`
- [ ] Works with `FFAppState().exchangeRates`
- [ ] Handles missing exchange rate gracefully
- [ ] Updates when user changes currency preference

## Migration Notes

### Phase 3 Implementation Requirements

#### 1. Copy Function Exactly
**DO NOT modify logic.** The conversion and formatting logic must remain identical to FlutterFlow version.

```dart
// Migrate to: lib/shared/currency_formatting.dart

/// Place this function in a dedicated currency utilities file
/// alongside getCurrencyFormattingRules() and convertAndFormatPriceRange()
```

#### 2. FlutterFlow → Flutter Adaptations

**No Changes Needed:**
- Function signature remains identical
- All parameters remain the same
- Return type remains `String?`
- Internal logic remains unchanged

**Only Change: Import Statements**
```dart
// FlutterFlow version imports
import 'package:intl/intl.dart';
import 'dart:convert';

// Flutter version imports (same)
import 'package:intl/intl.dart';
import 'dart:convert';
```

#### 3. Dependency Management

**Required Package:**
```yaml
# pubspec.yaml
dependencies:
  intl: ^0.18.0  # For NumberFormat
```

**Internal Dependencies:**
- `getCurrencyFormattingRules()` must be migrated first
- Place both functions in same file for easy access

#### 4. State Management Integration

**FFAppState → Provider Pattern:**

**Before (FlutterFlow):**
```dart
final displayPrice = convertAndFormatPrice(
  item['base_price'],
  'DKK',
  FFAppState().exchangeRates[FFAppState().preferredCurrency],
  FFAppState().preferredCurrency,
);
```

**After (Provider):**
```dart
final appState = Provider.of<AppState>(context);

final displayPrice = convertAndFormatPrice(
  item.basePrice,
  'DKK',
  appState.exchangeRates[appState.preferredCurrency] ?? 1.0,
  appState.preferredCurrency,
);
```

#### 5. Widget Usage Pattern

**MenuDishesListView Integration:**
```dart
class MenuDishesListView extends StatelessWidget {
  final List<MenuItem> items;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        // Convert price to user's preferred currency
        final displayPrice = convertAndFormatPrice(
          item.basePrice,
          'DKK',                                // JourneyMate base currency
          appState.getExchangeRate(appState.preferredCurrency),
          appState.preferredCurrency,
        );

        return ListTile(
          title: Text(item.name),
          trailing: Text(displayPrice ?? 'N/A'),
        );
      },
    );
  }
}
```

#### 6. Testing Strategy

**Unit Tests (lib/tests/currency_formatting_test.dart):**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:journeymate/shared/currency_formatting.dart';

void main() {
  group('convertAndFormatPrice', () {
    test('converts DKK to EUR correctly', () {
      final result = convertAndFormatPrice(125.0, 'DKK', 0.13, 'EUR');
      expect(result, '€16.25');
    });

    test('handles same currency without conversion', () {
      final result = convertAndFormatPrice(125.0, 'DKK', 1.0, 'DKK');
      expect(result, '125 kr.');
    });

    test('returns null for negative price', () {
      final result = convertAndFormatPrice(-50.0, 'DKK', 0.13, 'EUR');
      expect(result, isNull);
    });

    test('formats thousands separator correctly', () {
      final result = convertAndFormatPrice(15000.0, 'DKK', 0.14, 'USD');
      expect(result, '\$2,100.00');
    });
  });
}
```

#### 7. Common Pitfalls to Avoid

**NEVER:**
- Change conversion calculation logic
- Modify decimal rounding behavior
- Alter symbol placement rules
- Remove input validation
- Skip error handling

**ALWAYS:**
- Use exact same formatting patterns
- Preserve null-safety checks
- Keep helper function structure
- Maintain currency code normalization
- Test with real exchange rates

#### 8. Performance Considerations

**Optimization Already Present:**
- Same-currency check skips conversion (line 1783)
- Single-pass formatting (no redundant conversions)
- Efficient pattern caching in NumberFormat

**Additional Optimization (Optional):**
```dart
// Cache formatting rules to avoid repeated JSON parsing
class CurrencyFormatter {
  static final Map<String, Map<String, dynamic>> _rulesCache = {};

  static String? formatPrice(
    double basePrice,
    String originalCurrency,
    double exchangeRate,
    String targetCurrency,
  ) {
    // Get or cache formatting rules
    if (!_rulesCache.containsKey(targetCurrency)) {
      final rulesJson = getCurrencyFormattingRules(targetCurrency);
      if (rulesJson != null) {
        _rulesCache[targetCurrency] = jsonDecode(rulesJson);
      }
    }

    // Use cached rules
    final rules = _rulesCache[targetCurrency];
    // ... rest of formatting logic
  }
}
```

#### 9. Related Functions to Migrate Together

**Should be in same file:**
1. `getCurrencyFormattingRules()` (dependency)
2. `convertAndFormatPrice()` (this function)
3. `convertAndFormatPriceRange()` (sibling function)
4. `getLocalizedCurrencyName()` (related utility)
5. `getCurrencyOptionsForLanguage()` (related utility)

**Suggested File Structure:**
```
lib/
  shared/
    currency_formatting.dart  ← All 5 functions here
    translations.dart         ← getTranslations() here
```

#### 10. Documentation for Developers

**Add Inline Comments:**
```dart
/// Converts and formats a single price with currency conversion.
///
/// This function is stateless and receives all data through parameters.
/// Exchange rates must be provided by the caller (typically from AppState).
///
/// Returns `null` for invalid inputs (negative price, zero exchange rate).
///
/// Example:
/// ```dart
/// final price = convertAndFormatPrice(125.0, 'DKK', 0.13, 'EUR');
/// // Returns: "€16.25"
/// ```
String? convertAndFormatPrice(
  double basePrice,
  String originalCurrencyCode,
  double exchangeRate,
  String targetCurrencyCode,
) {
  // Implementation...
}
```

## Relationship to Other Currency Functions

### getCurrencyFormattingRules()
**Dependency:** Required by `convertAndFormatPrice()`

**Purpose:** Returns formatting rules (symbol, placement, decimals) for each currency

**Usage:** Called once per price formatting to determine display rules

### convertAndFormatPriceRange()
**Sibling Function:** Similar logic for price ranges

**Differences:**
- Takes `minPrice` and `maxPrice` instead of single `basePrice`
- Calls `convertAndFormatPrice()` logic internally (duplicated)
- Returns range format like `"€13 - €27"` or `"100 - 200 kr."`

**Location:** Lines 1359-1467

### getLocalizedCurrencyName()
**Related Utility:** Gets currency name in user's language

**Purpose:** Used in currency selection dropdowns

**Example:** `getLocalizedCurrencyName('da', 'DKK', cache)` → `"danske kroner"`

**Location:** Lines 1186-1233

### getCurrencyOptionsForLanguage()
**Related Utility:** Gets available currencies for language/region

**Purpose:** Populates currency selection UI

**Returns:** List of maps with `label` and `code` keys

**Location:** Lines 1469-1549

## Real-World Usage Locations

### 1. MenuDishesListView Widget
**File:** `lib/custom_code/widgets/menu_dishes_list_view.dart`

**Usage:**
```dart
// Display price for each menu item
final displayPrice = convertAndFormatPrice(
  dish['base_price'],
  'DKK',
  FFAppState().exchangeRates[FFAppState().preferredCurrency],
  FFAppState().preferredCurrency,
);
```

### 2. DishBottomSheet Widget
**File:** `lib/custom_code/widgets/dish_bottom_sheet.dart`

**Usage:**
```dart
// Show converted price in bottom sheet header
final priceText = convertAndFormatPrice(
  widget.dish['base_price'],
  'DKK',
  widget.exchangeRate,
  widget.targetCurrency,
);
```

### 3. Business Profile Page
**File:** `lib/pages/business_profile_page.dart`

**Usage:**
```dart
// Display price range for restaurant
final minPriceFormatted = convertAndFormatPrice(
  business['min_price'],
  'DKK',
  currentExchangeRate,
  preferredCurrency,
);

final maxPriceFormatted = convertAndFormatPrice(
  business['max_price'],
  'DKK',
  currentExchangeRate,
  preferredCurrency,
);

Text('$minPriceFormatted - $maxPriceFormatted');
```

### 4. Search Results Cards
**File:** `lib/pages/search_page.dart`

**Usage:**
```dart
// Show approximate price range in restaurant card
final avgPrice = (restaurant['min_price'] + restaurant['max_price']) / 2;
final displayPrice = convertAndFormatPrice(
  avgPrice,
  'DKK',
  exchangeRate,
  userCurrency,
);
```

## Key Design Decisions

### Decision 1: Base Currency is Always DKK
**Rationale:** JourneyMate focuses on Copenhagen restaurants, all prices stored in DKK

**Impact:** `originalCurrencyCode` parameter will almost always be `'DKK'`

**Future-Proofing:** Function supports any origin currency for potential expansion

### Decision 2: Exchange Rates Stored in FFAppState
**Rationale:** Rates need to be fetched once and reused across app

**Implementation:** Function receives rate as parameter (doesn't fetch it)

**Separation of Concerns:** Function does conversion/formatting, caller manages data fetching

### Decision 3: Same-Currency Optimization
**Rationale:** Avoid floating-point precision loss when no conversion needed

**Code:**
```dart
originalCode == targetCode ? basePrice : basePrice * exchangeRate
```

**Benefit:** `125.0 DKK → 125.0 DKK` preserves exact value

### Decision 4: Null Return for Invalid Inputs
**Rationale:** Fail gracefully rather than show incorrect prices

**Invalid Cases:**
- Negative price
- Zero/negative exchange rate
- JSON parsing failure

**UI Handling:** Calling code should display `"N/A"` or `"—"` when result is null

### Decision 5: Centralized Formatting Rules
**Rationale:** Single source of truth for currency display

**Implementation:** `getCurrencyFormattingRules()` contains all rules

**Maintainability:** Adding new currency only requires updating rules function

### Decision 6: NumberFormat for Localization
**Rationale:** Leverage proven library for number formatting

**Benefits:**
- Handles decimal precision correctly
- Supports thousands separators
- Cross-platform consistency

**Trade-off:** Requires `intl` package dependency

### Decision 7: Rounding Only for Zero-Decimal Currencies
**Rationale:** Match user expectations for currency precision

**Logic:**
```dart
decimals == 0
  ? NumberFormat(pattern).format(convertedPrice.round())
  : NumberFormat(pattern).format(convertedPrice);
```

**Examples:**
- DKK (0 decimals): `125.7` → `"126 kr."` (rounded)
- EUR (2 decimals): `125.755` → `"€125.76"` (rounded by NumberFormat)

---

**Document Version:** 1.0
**Last Updated:** 2026-02-19
**Function Location:** `custom_functions.dart` lines 1733-1811
**Related Documentation:**
- `MASTER_README_get_currency_formatting_rules.md`
- `MASTER_README_convert_and_format_price_range.md`
- `MASTER_README_get_localized_currency_name.md`
