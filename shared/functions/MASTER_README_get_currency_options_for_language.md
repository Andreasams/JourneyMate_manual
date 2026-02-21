# getCurrencyOptionsForLanguage

**Function Documentation**
**Version:** FlutterFlow Export v1.0
**Category:** Custom Functions
**Location:** `lib/flutter_flow/custom_functions.dart` (lines 1469-1549)

---

## Purpose

Returns localized currency options for dropdown/selection UI based on the user's selected language. The function provides region-appropriate currency choices with localized names and symbols dynamically retrieved from the currency formatting system.

**Primary use case:** Populating the currency selector dropdown in language/region settings, ensuring users only see currencies relevant to their selected language/region.

**Design principle:** Each language offers 1-3 currencies based on regional relevance:
- Primary market currency (e.g., DKK for Danish users)
- Regional alternatives (e.g., EUR for German/French/Italian users)
- International options (e.g., USD/GBP for English users)

---

## Function Signature

```dart
List<dynamic> getCurrencyOptionsForLanguage(
  String languageCode,
  dynamic translationsCache,
)
```

**Returns:** `List<dynamic>` containing maps with `label` (display string) and `code` (ISO currency code) keys.

---

## Parameters

### 1. `languageCode` (String)
**Type:** ISO 639-1 language code (e.g., 'en', 'da', 'de')
**Required:** Yes
**Normalized:** Converted to lowercase and trimmed internally

**Purpose:** Determines which currency options to show based on regional relevance.

**Validation:**
- Must be a valid language code string
- Automatically normalized to lowercase
- Unsupported languages return empty list (no fallback)

---

### 2. `translationsCache` (dynamic)
**Type:** Translation cache object from FFAppState
**Required:** Yes
**Source:** `FFAppState().translationsCache`

**Purpose:** Provides localized currency names for the display labels.

**Cache structure:**
```json
{
  "currency_dkk_cap": "Danske Kroner",
  "currency_eur_cap": "Euro",
  "currency_usd_cap": "US Dollar",
  ...
}
```

**Translation key pattern:** `currency_{code}_cap` (e.g., `currency_dkk_cap`)

---

## Return Value

### Success Case

```dart
[
  {
    'label': 'Danske Kroner (kr.)',
    'code': 'DKK'
  },
  {
    'label': 'Euro (€)',
    'code': 'EUR'
  }
]
```

**Structure:**
- `label` (String): Localized currency name + symbol in parentheses (e.g., "Danske Kroner (kr.)")
- `code` (String): ISO 4217 currency code (e.g., "DKK")

**Order:** Currencies returned in the order defined in `currencyConfigByLanguage` (primary first)

---

### Empty List Case

Returns `[]` (empty list) when:
- Language code not found in `currencyConfigByLanguage` mapping
- All currency translations missing from cache (unlikely)
- Language code is null/empty after normalization

---

## Language-to-Currencies Mapping

### Configuration Table

| Language Code | Currencies Offered | Rationale |
|--------------|-------------------|-----------|
| `'en'` | USD, GBP, DKK | International users + UK market + Danish base |
| `'da'` | DKK | Primary Danish market (no alternatives) |
| `'de'` | EUR, DKK | German users + Danish base |
| `'fr'` | EUR, DKK | French users + Danish base |
| `'it'` | EUR, DKK | Italian users + Danish base |
| `'no'` | NOK, DKK | Norwegian users + Danish base |
| `'sv'` | SEK, DKK | Swedish users + Danish base |

**Unsupported languages:** All other languages return empty list (no fallback to English).

---

### Configuration Source (Internal)

```dart
const currencyConfigByLanguage = {
  'en': ['USD', 'GBP', 'DKK'],
  'da': ['DKK'],
  'de': ['EUR', 'DKK'],
  'fr': ['EUR', 'DKK'],
  'it': ['EUR', 'DKK'],
  'no': ['NOK', 'DKK'],
  'sv': ['SEK', 'DKK'],
};
```

**To add new language:** Extend this mapping with appropriate currency codes.

---

## Dependencies

### 1. Translation System

**Function:** `getTranslations(languageCode, translationKey, translationsCache)`

**Purpose:** Retrieves localized currency names.

**Translation key pattern:**
- `'currency_{code}_cap'` (e.g., `'currency_dkk_cap'`)
- Returns capitalized currency names (e.g., "Danske Kroner", "Euro")

**Fallback behavior:**
- If translation missing: currency skipped from results (not shown)
- Empty/warning string (`⚠️`): currency skipped from results

---

### 2. Currency Formatting Rules

**Function:** `getCurrencyFormattingRules(code)`

**Purpose:** Retrieves currency symbols dynamically.

**Returns:** JSON string containing `{symbol, isPrefix, decimals}`

**Example:**
```dart
getCurrencyFormattingRules('DKK')
// → '{"symbol":"kr.","isPrefix":false,"decimals":0}'

getCurrencyFormattingRules('EUR')
// → '{"symbol":"€","isPrefix":true,"decimals":2}'
```

**Fallback behavior:**
- If symbol extraction fails: uses currency code as symbol (e.g., "DKK")
- If `getCurrencyFormattingRules()` returns null: uses currency code

---

### 3. JSON Decoding

**Package:** `dart:convert`

**Usage:** Parsing `getCurrencyFormattingRules()` output to extract symbol.

**Error handling:** Try-catch block returns currency code if parsing fails.

---

## FFAppState Usage

### Required State Variables

**1. `translationsCache`**
- **Type:** `dynamic` (Map<String, dynamic> or JSON string)
- **Purpose:** Provides localized currency names
- **Update trigger:** Language change via `updateCurrencyForLanguage` action
- **Persistence:** Session-only (reloaded on app start)

**2. `selectedCurrency`** (used by calling UI)
- **Type:** `String` (ISO 4217 code)
- **Purpose:** Tracks user's selected currency
- **Default value:** 'DKK' (set in app initialization)
- **Update trigger:** User selection in currency dropdown
- **Persistence:** Persisted via SharedPreferences

---

### State Synchronization

**Language change flow:**

1. User selects new language in settings
2. `updateCurrencyForLanguage` custom action runs
3. Checks if current `selectedCurrency` is valid for new language
4. If not valid: auto-switches to first available currency for new language
5. Currency selector UI calls `getCurrencyOptionsForLanguage()` to refresh options
6. Dropdown displays currencies for new language with localized names

**Example scenario:**

```dart
// User is on German ('de') with EUR selected
// Available options: [EUR, DKK]

// User switches to Danish ('da')
// updateCurrencyForLanguage checks: EUR not in ['DKK'] for Danish
// Auto-switches selectedCurrency to 'DKK'
// getCurrencyOptionsForLanguage('da', cache) returns [DKK only]
```

---

## Usage Examples

### Example 1: Currency Selector Dropdown

**Context:** User opens language settings, sees currency dropdown.

```dart
// In the dropdown widget's listview builder

final currencyOptions = getCurrencyOptionsForLanguage(
  FFAppState().appLanguage,
  FFAppState().translationsCache,
);

ListView.builder(
  itemCount: currencyOptions.length,
  itemBuilder: (context, index) {
    final option = currencyOptions[index];
    final label = option['label'] as String;
    final code = option['code'] as String;

    return RadioListTile(
      title: Text(label), // "Danske Kroner (kr.)"
      value: code,         // "DKK"
      groupValue: FFAppState().selectedCurrency,
      onChanged: (newCode) {
        setState(() => FFAppState().selectedCurrency = newCode);
      },
    );
  },
);
```

**Output for Danish user (`languageCode = 'da'`):**
```
[○] Danske Kroner (kr.)
```

**Output for German user (`languageCode = 'de'`):**
```
[○] Euro (€)
[○] Danske Kroner (kr.)
```

---

### Example 2: First Currency as Default

**Context:** Selecting first available currency when switching languages.

```dart
// In updateCurrencyForLanguage custom action

final currencyOptions = getCurrencyOptionsForLanguage(
  newLanguageCode,
  FFAppState().translationsCache,
);

if (currencyOptions.isNotEmpty) {
  final firstCurrency = currencyOptions.first['code'] as String;
  FFAppState().selectedCurrency = firstCurrency;
} else {
  // Fallback to DKK if no currencies available (shouldn't happen)
  FFAppState().selectedCurrency = 'DKK';
}
```

---

### Example 3: Validating Selected Currency

**Context:** Checking if user's current currency is valid for new language.

```dart
// In language change handler

final availableCurrencies = getCurrencyOptionsForLanguage(
  newLanguageCode,
  FFAppState().translationsCache,
);

final currentCurrency = FFAppState().selectedCurrency;

final isValidForNewLanguage = availableCurrencies.any(
  (option) => option['code'] == currentCurrency,
);

if (!isValidForNewLanguage) {
  // Switch to first available currency
  final firstCurrency = availableCurrencies.first['code'] as String;
  setState(() => FFAppState().selectedCurrency = firstCurrency);
}
```

---

### Example 4: Displaying Currency Count

**Context:** Showing how many currency options are available.

```dart
final currencyOptions = getCurrencyOptionsForLanguage(
  FFAppState().appLanguage,
  FFAppState().translationsCache,
);

Text(
  '${currencyOptions.length} currency option${currencyOptions.length == 1 ? '' : 's'} available',
  style: TextStyle(fontSize: 12, color: Colors.grey),
);
// For Danish: "1 currency option available"
// For German: "2 currency options available"
```

---

## Edge Cases

### 1. Unsupported Language Code

**Input:**
```dart
getCurrencyOptionsForLanguage('es', translationsCache)
// Spanish not configured
```

**Output:**
```dart
[] // Empty list
```

**Behavior:**
- No error thrown
- Returns empty list silently
- UI should handle empty list gracefully (show message or hide selector)

---

### 2. Missing Translation in Cache

**Input:**
```dart
getCurrencyOptionsForLanguage('de', translationsCache)
// But translationsCache is missing 'currency_eur_cap'
```

**Output:**
```dart
[
  {
    'label': 'Danske Kroner (kr.)',
    'code': 'DKK'
  }
  // EUR skipped due to missing translation
]
```

**Behavior:**
- Currency with missing translation is silently omitted
- Other currencies with valid translations still included
- No error/warning in output

---

### 3. Symbol Extraction Failure

**Input:**
```dart
getCurrencyOptionsForLanguage('da', translationsCache)
// But getCurrencyFormattingRules('DKK') returns null
```

**Output:**
```dart
[
  {
    'label': 'Danske Kroner (DKK)', // Code used as fallback symbol
    'code': 'DKK'
  }
]
```

**Behavior:**
- Falls back to currency code as symbol if extraction fails
- Still includes currency in results (doesn't skip)

---

### 4. Empty Translation Cache

**Input:**
```dart
getCurrencyOptionsForLanguage('de', {})
// Empty cache object
```

**Output:**
```dart
[] // Empty list - all currencies skipped
```

**Behavior:**
- All translations fail → all currencies skipped
- Returns empty list (not error)

---

### 5. Null/Empty Language Code

**Input:**
```dart
getCurrencyOptionsForLanguage('', translationsCache)
getCurrencyOptionsForLanguage('   ', translationsCache)
```

**Output:**
```dart
[] // Empty list
```

**Behavior:**
- After normalization (toLowerCase + trim), becomes empty string
- Empty string not in mapping → returns empty list

---

### 6. Case-Insensitive Language Codes

**Input:**
```dart
getCurrencyOptionsForLanguage('DA', translationsCache)
getCurrencyOptionsForLanguage('De', translationsCache)
```

**Output:**
```dart
// Same as 'da' and 'de' respectively
[{'label': 'Danske Kroner (kr.)', 'code': 'DKK'}]
[{'label': 'Euro (€)', 'code': 'EUR'}, {'label': 'Danske Kroner (kr.)', 'code': 'DKK'}]
```

**Behavior:**
- Language code normalized to lowercase internally
- Mapping keys are all lowercase
- Case doesn't matter in input

---

## Testing Checklist

### Unit Tests

- [ ] **Danish user gets DKK only**
  - Input: `languageCode = 'da'`
  - Expected: 1 option (DKK)

- [ ] **German user gets EUR and DKK**
  - Input: `languageCode = 'de'`
  - Expected: 2 options (EUR, DKK) in that order

- [ ] **English user gets USD, GBP, DKK**
  - Input: `languageCode = 'en'`
  - Expected: 3 options (USD, GBP, DKK) in that order

- [ ] **Unsupported language returns empty list**
  - Input: `languageCode = 'es'`
  - Expected: `[]`

- [ ] **Case-insensitive language codes**
  - Input: `languageCode = 'DE'` vs `'de'`
  - Expected: Same output

- [ ] **Label format is correct**
  - Expected format: `"{Name} ({Symbol})"`
  - Example: `"Euro (€)"`, not `"Euro €"` or `"(€) Euro"`

- [ ] **Missing translation skips currency**
  - Setup: Remove `currency_usd_cap` from cache
  - Input: `languageCode = 'en'`
  - Expected: Only GBP and DKK shown (USD skipped)

- [ ] **Empty cache returns empty list**
  - Input: `translationsCache = {}`
  - Expected: `[]`

- [ ] **Symbol extraction fallback**
  - Mock: `getCurrencyFormattingRules()` returns null
  - Expected: Currency code used as symbol (e.g., "Danske Kroner (DKK)")

---

### Integration Tests

- [ ] **Currency selector UI displays options**
  - Navigate to settings → language/currency section
  - Verify dropdown shows correct number of currencies for selected language
  - Verify labels are localized to selected language

- [ ] **Language change updates currency options**
  - Switch from English to Danish
  - Verify dropdown options change from [USD, GBP, DKK] to [DKK]

- [ ] **Selected currency auto-switches if invalid**
  - Start with German + EUR selected
  - Switch to Danish
  - Verify `selectedCurrency` auto-switches to DKK (EUR not available in Danish)

- [ ] **Symbols displayed correctly**
  - Verify all currency symbols render correctly (€, kr., £, $)
  - Check on both iOS and Android

---

### Edge Case Tests

- [ ] **Whitespace-only language code**
  - Input: `languageCode = '   '`
  - Expected: `[]`

- [ ] **Null language code**
  - Input: `languageCode = null`
  - Expected: Runtime error or handled gracefully (depends on null safety)

- [ ] **Very long language code**
  - Input: `languageCode = 'de-DE-1996'`
  - Expected: `[]` (not in mapping, no substring matching)

- [ ] **Mixed case translation keys in cache**
  - Setup: Cache has `'CURRENCY_DKK_CAP'` instead of `'currency_dkk_cap'`
  - Expected: Currency skipped (key mismatch)

---

### Performance Tests

- [ ] **Function execution time < 10ms**
  - Test with all supported languages
  - Measure time from call to return

- [ ] **No memory leaks in repeated calls**
  - Call function 1000 times in loop
  - Monitor memory usage (should be stable)

---

## Migration Notes

### Phase 3 Implementation Checklist

#### 1. Create Dart Function

**Location:** `lib/shared/currency_utils.dart`

```dart
import 'dart:convert';
import 'package:journeymate/shared/translation_utils.dart';
import 'package:journeymate/shared/currency_formatting_utils.dart';

/// Returns localized currency options for dropdown/selection UI.
List<Map<String, String>> getCurrencyOptionsForLanguage(
  String languageCode,
  Map<String, String> translationsCache,
) {
  // Copy implementation from FlutterFlow custom_functions.dart
  // Lines 1469-1549
}
```

**Differences from FlutterFlow version:**
- Change `dynamic translationsCache` → `Map<String, String> translationsCache` (type-safe)
- Change `List<dynamic>` return type → `List<Map<String, String>>` (type-safe)
- Import dependencies explicitly

---

#### 2. Update Currency Selector Widget

**File:** `lib/pages/settings_page.dart` (or wherever currency selector lives)

**Before (FlutterFlow):**
```dart
FFAppState().currencyOptions // Static list
```

**After (Flutter):**
```dart
final currencyOptions = getCurrencyOptionsForLanguage(
  context.read<AppState>().appLanguage,
  context.read<AppState>().translationsCache,
);
```

---

#### 3. Implement State Synchronization

**File:** `lib/actions/update_currency_for_language.dart`

```dart
void updateCurrencyForLanguage(BuildContext context, String newLanguageCode) {
  final appState = context.read<AppState>();

  // Get available currencies for new language
  final availableCurrencies = getCurrencyOptionsForLanguage(
    newLanguageCode,
    appState.translationsCache,
  );

  // Check if current currency is valid for new language
  final currentCurrency = appState.selectedCurrency;
  final isValid = availableCurrencies.any(
    (option) => option['code'] == currentCurrency,
  );

  // If invalid, switch to first available currency
  if (!isValid && availableCurrencies.isNotEmpty) {
    appState.updateSelectedCurrency(availableCurrencies.first['code']!);
  }
}
```

---

#### 4. Add Translation Keys to Supabase

**Required keys per currency:**

```sql
-- DKK
INSERT INTO translations (key, da, en, de, fr, it, no, sv)
VALUES ('currency_dkk_cap', 'Danske Kroner', 'Danish Krone', 'Dänische Krone', 'Couronne danoise', 'Corona danese', 'Dansk krone', 'Dansk krona');

-- EUR
INSERT INTO translations (key, da, en, de, fr, it, no, sv)
VALUES ('currency_eur_cap', 'Euro', 'Euro', 'Euro', 'Euro', 'Euro', 'Euro', 'Euro');

-- USD
INSERT INTO translations (key, da, en, de, fr, it, no, sv)
VALUES ('currency_usd_cap', 'Amerikanske Dollar', 'US Dollar', 'US-Dollar', 'Dollar américain', 'Dollaro USA', 'Amerikansk dollar', 'Amerikansk dollar');

-- GBP
INSERT INTO translations (key, da, en, de, fr, it, no, sv)
VALUES ('currency_gbp_cap', 'Britiske Pund', 'British Pound', 'Britisches Pfund', 'Livre sterling', 'Sterlina britannica', 'Britisk pund', 'Brittiskt pund');

-- NOK
INSERT INTO translations (key, da, en, de, fr, it, no, sv)
VALUES ('currency_nok_cap', 'Norske Kroner', 'Norwegian Krone', 'Norwegische Krone', 'Couronne norvégienne', 'Corona norvegese', 'Norsk krone', 'Norsk krona');

-- SEK
INSERT INTO translations (key, da, en, de, fr, it, no, sv)
VALUES ('currency_sek_cap', 'Svenske Kroner', 'Swedish Krona', 'Schwedische Krone', 'Couronne suédoise', 'Corona svedese', 'Svensk krone', 'Svensk krona');
```

---

#### 5. Test Coverage Requirements

**Required test file:** `test/shared/currency_utils_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:journeymate/shared/currency_utils.dart';

void main() {
  group('getCurrencyOptionsForLanguage', () {
    final mockCache = {
      'currency_dkk_cap': 'Danske Kroner',
      'currency_eur_cap': 'Euro',
      'currency_usd_cap': 'US Dollar',
      'currency_gbp_cap': 'British Pound',
      'currency_nok_cap': 'Norsk krone',
      'currency_sek_cap': 'Svensk krona',
    };

    test('Danish user gets DKK only', () {
      final result = getCurrencyOptionsForLanguage('da', mockCache);
      expect(result.length, 1);
      expect(result.first['code'], 'DKK');
    });

    test('German user gets EUR and DKK', () {
      final result = getCurrencyOptionsForLanguage('de', mockCache);
      expect(result.length, 2);
      expect(result[0]['code'], 'EUR');
      expect(result[1]['code'], 'DKK');
    });

    test('Unsupported language returns empty list', () {
      final result = getCurrencyOptionsForLanguage('es', mockCache);
      expect(result, isEmpty);
    });

    // Add remaining tests from Testing Checklist
  });
}
```

**Minimum coverage:** 90% line coverage, 100% branch coverage.

---

#### 6. Breaking Changes

**None.** This function is purely additive and doesn't modify existing state.

**Migration path:** Straightforward copy from FlutterFlow with type annotations.

---

#### 7. Related Custom Actions to Migrate

**`updateCurrencyForLanguage`**
- Custom action (not function)
- Called when user changes language
- Validates and updates `selectedCurrency` based on new language
- Must be migrated alongside `getCurrencyOptionsForLanguage()`

**Location in FlutterFlow:** `lib/custom_code/actions/update_currency_for_language.dart`

---

## Relationship to Other Functions

### 1. `getCurrencyFormattingRules(code)`

**Purpose:** Provides symbol, placement, and decimal rules for a currency.

**Used by `getCurrencyOptionsForLanguage`:** Extracts currency symbol for display label.

**Example flow:**
```dart
// getCurrencyOptionsForLanguage calls:
final symbol = _getSymbol('DKK');

// Which internally calls:
final jsonStr = getCurrencyFormattingRules('DKK');
// → '{"symbol":"kr.","isPrefix":false,"decimals":0}'

// Extracts symbol:
final data = json.decode(jsonStr);
final symbol = data['symbol']; // → "kr."

// Builds label:
final label = '$name ($symbol)'; // → "Danske Kroner (kr.)"
```

---

### 2. `getTranslations(languageCode, key, cache)`

**Purpose:** Retrieves localized strings from translation cache.

**Used by `getCurrencyOptionsForLanguage`:** Gets localized currency names.

**Translation key pattern:** `currency_{code}_cap`

**Example:**
```dart
final name = getTranslations('da', 'currency_dkk_cap', translationsCache);
// → "Danske Kroner"
```

---

### 3. `updateCurrencyForLanguage` (Custom Action)

**Purpose:** Validates and updates selected currency when language changes.

**Depends on `getCurrencyOptionsForLanguage`:** Uses it to get valid currencies for new language.

**Workflow:**
1. User changes language from German to Danish
2. `updateCurrencyForLanguage` action runs
3. Calls `getCurrencyOptionsForLanguage('da', cache)`
4. Gets available currencies: `[{code: 'DKK'}]`
5. Checks if current currency (EUR) is in list
6. Not found → switches to first available (DKK)

---

### 4. `convertAndFormatPrice(basePrice, originalCode, rate, targetCode)`

**Purpose:** Converts and formats prices with currency symbols.

**Indirect relationship:** Both use `getCurrencyFormattingRules()` for symbol data.

**Use case:** After user selects currency via `getCurrencyOptionsForLanguage()`, menu prices are formatted using `convertAndFormatPrice()`.

---

## Analytics Considerations

**Events to track:**

1. **Currency Option Viewed**
   - Event: `currency_selector_opened`
   - Properties:
     - `languageCode`: Current language
     - `availableCurrencies`: List of currency codes shown
     - `currencyCount`: Number of options available

2. **Currency Changed**
   - Event: `currency_changed`
   - Properties:
     - `previousCurrency`: Old selected currency
     - `newCurrency`: New selected currency
     - `languageCode`: Current language
     - `wasAutoSwitched`: Boolean (true if switched due to language change)

**Implementation example:**

```dart
// In currency selector widget
@override
void initState() {
  super.initState();

  final options = getCurrencyOptionsForLanguage(
    FFAppState().appLanguage,
    FFAppState().translationsCache,
  );

  trackAnalyticsEvent(
    'currency_selector_opened',
    {
      'languageCode': FFAppState().appLanguage,
      'availableCurrencies': options.map((o) => o['code']).toList(),
      'currencyCount': options.length,
    },
  );
}
```

---

## Security Considerations

**Low security risk.** Function only reads from:
- Static configuration map (hardcoded in function)
- Translation cache (read-only from FFAppState)
- Currency formatting rules (hardcoded in another function)

**No user input processing:** Language code comes from validated FFAppState.

**No external API calls:** All data is local/cached.

**No sensitive data exposure:** Currency codes and symbols are public information.

---

## Performance Optimization

**Current implementation is efficient:**

- **Time complexity:** O(n) where n = number of currencies for language (max 3)
- **Space complexity:** O(n) for output list
- **No loops over translation cache:** Direct key lookups via `getTranslations()`
- **Symbol extraction cached:** `getCurrencyFormattingRules()` returns static data (no computation)

**No optimization needed.** Function execution time < 1ms in typical case.

---

## Future Extensions

### 1. Adding New Languages

**To add Spanish support:**

1. Add mapping to `currencyConfigByLanguage`:
```dart
'es': ['EUR', 'USD', 'DKK'],
```

2. Add translation keys to Supabase:
```sql
-- For each currency used in Spanish
INSERT INTO translations (key, es)
VALUES
  ('currency_eur_cap', 'Euro'),
  ('currency_usd_cap', 'Dólar estadounidense'),
  ('currency_dkk_cap', 'Corona danesa');
```

3. No code changes needed (configuration-driven).

---

### 2. Adding New Currencies

**To add Japanese Yen (JPY):**

1. Add currency formatting rules to `getCurrencyFormattingRules()`:
```dart
'JPY': {'symbol': '¥', 'isPrefix': false, 'decimals': 0},
```

2. Add translations for all languages:
```sql
INSERT INTO translations (key, da, en, de, fr, it, no, sv)
VALUES ('currency_jpy_cap', 'Japansk Yen', 'Japanese Yen', 'Japanischer Yen', ...);
```

3. Add JPY to relevant language mappings:
```dart
'ja': ['JPY', 'USD', 'DKK'], // New Japanese language support
```

---

### 3. Regional Currency Preferences

**Future enhancement:** Allow users to customize which currencies appear.

**Current limitation:** Currencies are hardcoded per language.

**Proposed addition:**
```dart
// New parameter
List<dynamic> getCurrencyOptionsForLanguage(
  String languageCode,
  dynamic translationsCache,
  {List<String>? customCurrencies}, // Optional user override
)

// Implementation
final codes = customCurrencies ?? currencyConfigByLanguage[languageCode] ?? [];
```

---

## Version History

**v1.0 (FlutterFlow Export)**
- Initial implementation
- 7 languages supported (da, en, de, fr, it, no, sv)
- 6 currencies supported (DKK, EUR, USD, GBP, NOK, SEK)
- Dependent on `getTranslations()` and `getCurrencyFormattingRules()`

---

## Documentation Updates

**When to update this document:**

1. New language added to `currencyConfigByLanguage`
2. New currency added to any language's currency list
3. Translation key pattern changes
4. Symbol extraction logic changes
5. Return type or parameter changes

**Maintenance owner:** Backend/Functions team

**Last updated:** 2026-02-19
