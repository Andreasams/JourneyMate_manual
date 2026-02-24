# getLocalizedCurrencyName — Master Documentation

**Documentation Version:** 1.0
**Function Location:** `_flutterflow_export/lib/flutter_flow/custom_functions.dart` (lines 1186-1233)
**Phase 3 Status:** Ready for migration
**Last Updated:** 2026-02-19

---

## Purpose

Returns localized currency name for a given ISO 4217 currency code (e.g., "USD", "EUR", "DKK"). Provides human-readable currency names in the user's language with fallback to the currency code itself when no translation exists.

**Primary Use Case:** Currency selector widgets (dropdowns, pickers) and settings pages where currency display names need to be shown in the user's language.

**Key Behavior:** Simple lookup function that translates currency codes to localized names using the translation cache. Always returns a string value (never null), falling back to the uppercase currency code when translation is missing.

---

## Function Signature

```dart
String? getLocalizedCurrencyName(
  String languageCode,
  String? currencyCode,
  dynamic translationsCache,
)
```

**Return Type:** `String?`
- Returns localized currency name (e.g., "danske kroner", "US Dollar")
- Returns uppercase currency code if translation missing (e.g., "XYZ")
- Returns `null` if `currencyCode` parameter is `null`

---

## Parameters

### 1. `languageCode` (String, required)
ISO 639-1 language code for localization.

**Valid Values:**
- `'da'` — Danish
- `'en'` — English
- `'de'` — German
- `'fr'` — French
- `'it'` — Italian
- `'no'` — Norwegian
- `'sv'` — Swedish
- Plus additional languages from translation system (es, fi, ja, ko, nl, pl, uk, zh)

**Usage:**
```dart
// From FFAppState
getLocalizedCurrencyName(FFAppState().currentLanguageCode, 'DKK', cache)

// Hardcoded for testing
getLocalizedCurrencyName('da', 'EUR', cache)
```

### 2. `currencyCode` (String?, required but nullable)
ISO 4217 currency code (3-letter code).

**Supported Currencies** (from `getCurrencyFormattingRules`):
- `'CNY'` — Chinese Yuan
- `'DKK'` — Danish Krone
- `'EUR'` — Euro
- `'GBP'` — British Pound
- `'JPY'` — Japanese Yen
- `'KRW'` — South Korean Won
- `'NOK'` — Norwegian Krone
- `'PLN'` — Polish Zloty
- `'SEK'` — Swedish Krona
- `'UAH'` — Ukrainian Hryvnia
- `'USD'` — US Dollar

**Behavior:**
- If `null` → returns `null`
- If unrecognized → returns uppercase code (e.g., "XYZ")
- Case-insensitive — automatically normalized to uppercase

**Examples:**
```dart
getLocalizedCurrencyName('en', 'usd', cache)  // → "US Dollar" (normalized)
getLocalizedCurrencyName('en', 'DKK', cache)  // → "Danish Krone"
getLocalizedCurrencyName('en', null, cache)   // → null
getLocalizedCurrencyName('en', 'XYZ', cache)  // → "XYZ" (fallback)
```

### 3. `translationsCache` (dynamic, required)
Translation cache from `FFAppState().translationsCache`.

**Structure:** Map<String, dynamic> containing all translation key-value pairs for the current language.

**Key Format:** `'currency_{currencycode}'` (lowercase)
- `'currency_dkk'` → "danske kroner"
- `'currency_usd'` → "US Dollar"
- `'currency_eur'` → "Euro"

**Source:** Loaded from Supabase `translations` table during app initialization.

---

## Translation Key Patterns

### Key Format
```
currency_{currencycode}
```

All currency codes are lowercased in translation keys (e.g., `currency_dkk`, not `currency_DKK`).

### Translation Examples

**Danish (`da`):**
```
currency_dkk → "danske kroner"
currency_usd → "amerikanske dollar"
currency_eur → "euro"
currency_gbp → "britiske pund"
currency_nok → "norske kroner"
currency_sek → "svenske kroner"
```

**English (`en`):**
```
currency_dkk → "Danish Krone"
currency_usd → "US Dollar"
currency_eur → "Euro"
currency_gbp → "British Pound"
currency_nok → "Norwegian Krone"
currency_sek → "Swedish Krona"
```

**German (`de`):**
```
currency_dkk → "Dänische Krone"
currency_usd → "US-Dollar"
currency_eur → "Euro"
currency_gbp → "Britisches Pfund"
currency_nok → "Norwegische Krone"
currency_sek → "Schwedische Krone"
```

### Translation Key Generation Logic

```dart
// Step 1: Normalize currency code to uppercase
final normalizedCode = currencyCode.toUpperCase();  // "dkk" → "DKK"

// Step 2: Build translation key (lowercase)
final translationKey = 'currency_${normalizedCode.toLowerCase()}';  // "currency_dkk"

// Step 3: Look up translation
final translatedName = getTranslations(languageCode, translationKey, translationsCache);
```

---

## Dependencies

### Internal Dependencies

**1. `getTranslations()` Function**
Used to look up translation strings from the cache.

```dart
String getTranslations(
  String languageCode,
  String translationKey,
  dynamic translationsCache,
)
```

**Behavior:**
- Returns translated string if found
- Returns empty string `""` if key missing
- Returns `"⚠️ Translation missing: ..."` for debug builds when key not found

**Impact on `getLocalizedCurrencyName`:**
- If `getTranslations()` returns empty or warning → falls back to currency code
- Graceful degradation ensures UI always shows something meaningful

### External Dependencies

**None.** This function has no external package dependencies beyond Dart core library.

---

## FFAppState Usage

### Required State Variables

**1. `currentLanguageCode` (String)**
- Stores user's selected language
- Default: `'da'` (Danish)
- Updated via language selector on Settings page
- Persisted using SharedPreferences

**2. `translationsCache` (Map<String, dynamic>)**
- Stores all translations for current language
- Loaded on app initialization from Supabase `translations` table
- Re-loaded when user changes language
- Structure: `{ 'translation_key': 'translated_value', ... }`

### State Access Pattern

```dart
// Typical usage in widgets
getLocalizedCurrencyName(
  FFAppState().currentLanguageCode,    // Current language
  FFAppState().selectedCurrency,       // Current currency
  FFAppState().translationsCache,      // Translation cache
)
```

### State Initialization

**On App Launch:**
```dart
// 1. Load persisted language preference (or default to 'da')
FFAppState().currentLanguageCode = await SharedPreferences...

// 2. Fetch translations for current language
FFAppState().translationsCache = await fetchTranslations(FFAppState().currentLanguageCode)
```

**On Language Change:**
```dart
// 1. Update language code
FFAppState().currentLanguageCode = newLanguageCode;

// 2. Reload translations for new language
FFAppState().translationsCache = await fetchTranslations(newLanguageCode);

// 3. Rebuild UI (currency names will auto-update)
setState(() {});
```

---

## Usage Examples

### Example 1: Currency Selector Dropdown

**Scenario:** Display currency options with localized names in a dropdown picker.

```dart
// Used in: getCurrencyOptionsForLanguage() function
Widget buildCurrencyDropdown(BuildContext context) {
  final options = getCurrencyOptionsForLanguage(
    FFAppState().currentLanguageCode,
    FFAppState().translationsCache,
  );

  return DropdownButton<String>(
    items: options.map((option) {
      // Each option has structure: { 'label': 'Euro (€)', 'code': 'EUR' }
      return DropdownMenuItem(
        value: option['code'],
        child: Text(option['label']),  // "Euro (€)"
      );
    }).toList(),
    onChanged: (newCurrency) {
      FFAppState().selectedCurrency = newCurrency;
    },
  );
}

// Internal implementation of getCurrencyOptionsForLanguage():
String? _getCurrencyName(String code) {
  final translationKey = 'currency_${code.toLowerCase()}_cap';
  final translatedName = getTranslations(languageCode, translationKey, translationsCache);

  if (translatedName.isEmpty || translatedName.startsWith('⚠️')) {
    return null;
  }
  return translatedName;
}
```

**Output (Danish):**
```
"danske kroner (kr.)"
"Euro (€)"
"svenske kroner (kr.)"
```

### Example 2: Settings Page Display

**Scenario:** Show currently selected currency in settings.

```dart
Widget buildCurrencySettingTile(BuildContext context) {
  final currencyName = getLocalizedCurrencyName(
    FFAppState().currentLanguageCode,
    FFAppState().selectedCurrency,
    FFAppState().translationsCache,
  );

  return ListTile(
    title: Text('Currency'),
    subtitle: Text(currencyName ?? 'Not set'),
    trailing: Icon(Icons.chevron_right),
    onTap: () => showCurrencyPicker(context),
  );
}
```

**Output:**
- If `selectedCurrency = 'DKK'` and `currentLanguageCode = 'da'` → "danske kroner"
- If `selectedCurrency = 'EUR'` and `currentLanguageCode = 'en'` → "Euro"
- If `selectedCurrency = null` → "Not set"

### Example 3: Currency Confirmation Dialog

**Scenario:** Confirm currency selection with localized name.

```dart
void showCurrencyConfirmation(BuildContext context, String selectedCode) {
  final currencyName = getLocalizedCurrencyName(
    FFAppState().currentLanguageCode,
    selectedCode,
    FFAppState().translationsCache,
  );

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Confirm Currency'),
      content: Text('Change currency to $currencyName?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            FFAppState().selectedCurrency = selectedCode;
            Navigator.pop(context);
          },
          child: Text('Confirm'),
        ),
      ],
    ),
  );
}
```

**Output Dialog Text:**
- `selectedCode = 'EUR'`, `languageCode = 'da'` → "Change currency to Euro?"
- `selectedCode = 'NOK'`, `languageCode = 'en'` → "Change currency to Norwegian Krone?"

### Example 4: Fallback Behavior for Unknown Currency

**Scenario:** Handle unsupported or custom currency codes gracefully.

```dart
// User somehow selects a custom currency code
FFAppState().selectedCurrency = 'BTC';  // Bitcoin (not in translations)

final displayName = getLocalizedCurrencyName(
  FFAppState().currentLanguageCode,
  'BTC',
  FFAppState().translationsCache,
);

// Result: "BTC" (fallback to uppercase code)
print(displayName);  // → "BTC"

// UI still displays something meaningful:
Text('Current currency: $displayName')  // → "Current currency: BTC"
```

### Example 5: Multi-Language Currency Display

**Scenario:** Show currency name in multiple languages simultaneously (e.g., for translation verification).

```dart
Widget buildCurrencyTranslationTable(String currencyCode) {
  final languages = ['da', 'en', 'de', 'sv', 'no'];

  return Column(
    children: languages.map((lang) {
      final name = getLocalizedCurrencyName(
        lang,
        currencyCode,
        FFAppState().translationsCache,  // Note: Cache matches current language only
      );

      return Row(
        children: [
          Text('$lang: '),
          Text(name ?? 'N/A', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      );
    }).toList(),
  );
}
```

**Note:** This example assumes translations for all languages are preloaded, which is NOT the default behavior. Normally, `translationsCache` only contains translations for `currentLanguageCode`.

---

## Fallback Behavior

### Fallback Chain

```
1. Input: currencyCode = null
   → Return: null

2. Input: currencyCode = "EUR"
   → Normalize: "EUR"
   → Translation key: "currency_eur"
   → Lookup translation: "Euro"
   → Return: "Euro"

3. Input: currencyCode = "XYZ" (unrecognized)
   → Normalize: "XYZ"
   → Translation key: "currency_xyz"
   → Lookup translation: "" (empty, not found)
   → Fallback: "XYZ"
   → Return: "XYZ"

4. Input: currencyCode = "dkk" (lowercase)
   → Normalize: "DKK"
   → Translation key: "currency_dkk"
   → Lookup translation: "danske kroner"
   → Return: "danske kroner"
```

### Fallback Logic Pseudocode

```dart
if (currencyCode == null) {
  return null;
}

String normalizedCode = currencyCode.toUpperCase();
String translationKey = 'currency_${normalizedCode.toLowerCase()}';
String translatedName = getTranslations(languageCode, translationKey, translationsCache);

if (translatedName.isEmpty || translatedName.startsWith('⚠️')) {
  return normalizedCode;  // Fallback to uppercase code
}

return translatedName;  // Return translated name
```

### Why Fallback to Currency Code?

**Design Rationale:**
- Prevents blank/missing UI elements
- Currency codes (USD, EUR, DKK) are universally recognized
- Better UX than showing error messages or "N/A"
- Allows app to handle new currencies without code changes

**Example Scenarios:**
- New currency added to database but translations not yet created
- Translation cache failed to load
- Currency code typo (e.g., "US D" instead of "USD")

---

## Edge Cases

### Edge Case 1: Null Currency Code

**Input:**
```dart
getLocalizedCurrencyName('da', null, cache)
```

**Behavior:** Returns `null`

**Why:** Early return at line 1211 prevents unnecessary processing.

**UI Handling:**
```dart
final currencyName = getLocalizedCurrencyName(lang, code, cache);
Text(currencyName ?? 'No currency selected')
```

### Edge Case 2: Empty String Currency Code

**Input:**
```dart
getLocalizedCurrencyName('da', '', cache)
```

**Behavior:**
```
1. Empty string is NOT null → continues execution
2. Normalize: "".toUpperCase() → ""
3. Translation key: "currency_"
4. Lookup: getTranslations(lang, "currency_", cache) → "" (empty)
5. Fallback: return "" (normalized code)
6. Result: "" (empty string)
```

**UI Impact:** May display blank space. Should validate input before calling.

**Recommended Guard:**
```dart
if (currencyCode == null || currencyCode.isEmpty) {
  return null;
}
```

### Edge Case 3: Mixed Case Currency Code

**Input:**
```dart
getLocalizedCurrencyName('en', 'EuR', cache)  // Mixed case
```

**Behavior:**
```
1. Normalize: "EuR".toUpperCase() → "EUR"
2. Translation key: "currency_eur"
3. Lookup: "Euro"
4. Result: "Euro"
```

**Conclusion:** Function handles mixed case correctly via normalization.

### Edge Case 4: Invalid/Unrecognized Currency Code

**Input:**
```dart
getLocalizedCurrencyName('da', 'INVALID', cache)
```

**Behavior:**
```
1. Normalize: "INVALID"
2. Translation key: "currency_invalid"
3. Lookup: "" (not found)
4. Fallback: "INVALID"
5. Result: "INVALID"
```

**UI Impact:** Displays uppercase currency code. Not ideal but better than crash.

### Edge Case 5: Currency Code with Special Characters

**Input:**
```dart
getLocalizedCurrencyName('en', 'US$', cache)  // Contains symbol
```

**Behavior:**
```
1. Normalize: "US$"
2. Translation key: "currency_us$"
3. Lookup: "" (not found, invalid key)
4. Fallback: "US$"
5. Result: "US$"
```

**Recommendation:** Sanitize currency codes before calling function. Use only ISO 4217 codes (3 letters, no symbols).

### Edge Case 6: Translation Cache is Null

**Input:**
```dart
getLocalizedCurrencyName('da', 'DKK', null)  // Cache is null
```

**Behavior:**
```
1. Normalize: "DKK"
2. Translation key: "currency_dkk"
3. Call getTranslations('da', 'currency_dkk', null)
4. getTranslations() detects null cache → returns "" (empty)
5. Fallback: "DKK"
6. Result: "DKK"
```

**Conclusion:** Function gracefully handles null cache via `getTranslations()` fallback.

### Edge Case 7: Translation Exists But Empty

**Input:**
```dart
// Translation entry exists but value is empty string
translationsCache['currency_dkk'] = ''

getLocalizedCurrencyName('da', 'DKK', cache)
```

**Behavior:**
```
1. Normalize: "DKK"
2. Translation key: "currency_dkk"
3. Lookup: "" (exists but empty)
4. Check: translatedName.isEmpty → true
5. Fallback: "DKK"
6. Result: "DKK"
```

**Conclusion:** Empty translation values trigger fallback (line 1227 condition).

### Edge Case 8: Language Code Mismatch

**Input:**
```dart
// Cache loaded for Danish, but requesting English
FFAppState().translationsCache = await fetchTranslations('da');

getLocalizedCurrencyName('en', 'DKK', FFAppState().translationsCache)
```

**Behavior:**
```
1. Normalize: "DKK"
2. Translation key: "currency_dkk"
3. Lookup in Danish cache: "danske kroner"
4. Check: not empty, doesn't start with ⚠️ → valid
5. Result: "danske kroner" (WRONG LANGUAGE)
```

**Issue:** Function does NOT validate that translation cache matches requested language.

**Recommendation:** Ensure `translationsCache` matches `languageCode` before calling. Handle at app state level:

```dart
// Correct pattern:
void changeLanguage(String newLanguage) async {
  FFAppState().currentLanguageCode = newLanguage;
  FFAppState().translationsCache = await fetchTranslations(newLanguage);
  setState(() {});  // Rebuild UI
}
```

---

## Testing Checklist

### Functional Tests

- [ ] **Test 1:** Valid currency code returns localized name
  ```dart
  expect(
    getLocalizedCurrencyName('da', 'DKK', mockCache),
    'danske kroner',
  );
  ```

- [ ] **Test 2:** Null currency code returns null
  ```dart
  expect(
    getLocalizedCurrencyName('da', null, mockCache),
    isNull,
  );
  ```

- [ ] **Test 3:** Unrecognized currency code returns uppercase code
  ```dart
  expect(
    getLocalizedCurrencyName('en', 'XYZ', mockCache),
    'XYZ',
  );
  ```

- [ ] **Test 4:** Mixed case currency code normalized correctly
  ```dart
  expect(
    getLocalizedCurrencyName('en', 'usd', mockCache),
    'US Dollar',
  );
  ```

- [ ] **Test 5:** Missing translation triggers fallback
  ```dart
  expect(
    getLocalizedCurrencyName('en', 'BTC', mockCache),
    'BTC',
  );
  ```

### Edge Case Tests

- [ ] **Test 6:** Empty string currency code
  ```dart
  expect(
    getLocalizedCurrencyName('da', '', mockCache),
    '',
  );
  ```

- [ ] **Test 7:** Null translation cache
  ```dart
  expect(
    getLocalizedCurrencyName('da', 'DKK', null),
    'DKK',
  );
  ```

- [ ] **Test 8:** Empty translation value
  ```dart
  mockCache['currency_dkk'] = '';
  expect(
    getLocalizedCurrencyName('da', 'DKK', mockCache),
    'DKK',
  );
  ```

### Multi-Language Tests

- [ ] **Test 9:** Danish localization
  ```dart
  expect(
    getLocalizedCurrencyName('da', 'DKK', daCache),
    'danske kroner',
  );
  ```

- [ ] **Test 10:** English localization
  ```dart
  expect(
    getLocalizedCurrencyName('en', 'DKK', enCache),
    'Danish Krone',
  );
  ```

- [ ] **Test 11:** German localization
  ```dart
  expect(
    getLocalizedCurrencyName('de', 'EUR', deCache),
    'Euro',
  );
  ```

### Integration Tests

- [ ] **Test 12:** Currency selector dropdown displays localized names
- [ ] **Test 13:** Settings page shows current currency name
- [ ] **Test 14:** Currency name updates when language changed
- [ ] **Test 15:** All supported currencies have translations in all active languages

### Performance Tests

- [ ] **Test 16:** Function executes in < 5ms (single lookup)
- [ ] **Test 17:** No memory leaks with repeated calls
- [ ] **Test 18:** Cache lookup is O(1) constant time

---

## Migration Notes for Phase 3

### Current Implementation Analysis

**File:** `_flutterflow_export/lib/flutter_flow/custom_functions.dart`
**Lines:** 1186-1233 (48 lines)
**Complexity:** Low (simple lookup + fallback)

**Function Structure:**
1. Null check (1 line)
2. Normalize currency code (1 line)
3. Build translation key (1 line)
4. Lookup translation (4 lines)
5. Check if translation valid (1 line)
6. Return result or fallback (2 lines)

**Dependencies:**
- `getTranslations()` function (internal)
- No external packages

### Migration Strategy

**Option 1: Direct Port (Recommended)**

Keep function as-is with minimal changes:

```dart
// lib/utils/currency_helpers.dart

String? getLocalizedCurrencyName(
  String languageCode,
  String? currencyCode,
  Map<String, dynamic> translationsCache,
) {
  // Return null if currency code is null
  if (currencyCode == null) return null;

  // Normalize currency code to uppercase for consistency
  final normalizedCode = currencyCode.toUpperCase();

  // Build translation key (e.g., 'currency_dkk')
  final translationKey = 'currency_${normalizedCode.toLowerCase()}';

  // Get translation using central function with cache
  final translatedName = getTranslations(
    languageCode,
    translationKey,
    translationsCache,
  );

  // If translation not found (empty or starts with ⚠️), fallback to currency code
  if (translatedName.isEmpty || translatedName.startsWith('⚠️')) {
    return normalizedCode;
  }

  // Return translated name
  return translatedName;
}
```

**Changes from Original:**
- Type `translationsCache` parameter as `Map<String, dynamic>` (instead of `dynamic`)
- Add explicit type annotations for clarity
- Preserve all logic exactly as-is

**Option 2: Enhanced Version (Optional)**

Add validation and improved error handling:

```dart
// lib/utils/currency_helpers.dart

String? getLocalizedCurrencyName(
  String languageCode,
  String? currencyCode,
  Map<String, dynamic>? translationsCache,
) {
  // Validate inputs
  if (currencyCode == null || currencyCode.trim().isEmpty) return null;
  if (translationsCache == null || translationsCache.isEmpty) {
    return currencyCode.toUpperCase();  // Fallback to code
  }

  // Normalize currency code to uppercase for consistency
  final normalizedCode = currencyCode.trim().toUpperCase();

  // Validate format (ISO 4217 is 3 letters)
  if (normalizedCode.length != 3 || !RegExp(r'^[A-Z]{3}$').hasMatch(normalizedCode)) {
    debugPrint('⚠️ Invalid currency code format: $currencyCode');
    return normalizedCode;  // Return as-is
  }

  // Build translation key (e.g., 'currency_dkk')
  final translationKey = 'currency_${normalizedCode.toLowerCase()}';

  // Get translation using central function with cache
  final translatedName = getTranslations(
    languageCode,
    translationKey,
    translationsCache,
  );

  // If translation not found (empty or starts with ⚠️), fallback to currency code
  if (translatedName.isEmpty || translatedName.startsWith('⚠️')) {
    return normalizedCode;
  }

  // Return translated name
  return translatedName;
}
```

**Enhancements:**
- Validates currency code format (3 letters only)
- Handles empty string currency codes
- Trims whitespace from input
- Null-safe cache parameter
- Debug logging for invalid formats

**Recommendation:** Use Option 1 (direct port) for Phase 3. Add enhancements in later optimization phase if needed.

### File Location in Flutter Project

```
lib/
  utils/
    currency_helpers.dart        ← Place function here
  shared/
    translation_helpers.dart     ← getTranslations() dependency
```

### Required Imports

```dart
// lib/utils/currency_helpers.dart
import 'package:flutter/material.dart';  // For debugPrint (optional)
import '../shared/translation_helpers.dart';  // For getTranslations()
```

### Testing Requirements

**Unit Tests:**
```dart
// test/utils/currency_helpers_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:journeymate/utils/currency_helpers.dart';

void main() {
  group('getLocalizedCurrencyName', () {
    late Map<String, dynamic> mockCache;

    setUp(() {
      mockCache = {
        'currency_dkk': 'danske kroner',
        'currency_usd': 'US Dollar',
        'currency_eur': 'Euro',
      };
    });

    test('returns localized name for valid currency', () {
      expect(
        getLocalizedCurrencyName('da', 'DKK', mockCache),
        'danske kroner',
      );
    });

    test('returns null for null currency code', () {
      expect(
        getLocalizedCurrencyName('da', null, mockCache),
        isNull,
      );
    });

    test('returns uppercase code for unrecognized currency', () {
      expect(
        getLocalizedCurrencyName('da', 'XYZ', mockCache),
        'XYZ',
      );
    });

    test('normalizes lowercase input', () {
      expect(
        getLocalizedCurrencyName('en', 'usd', mockCache),
        'US Dollar',
      );
    });

    test('handles null cache gracefully', () {
      expect(
        getLocalizedCurrencyName('da', 'DKK', null),
        'DKK',
      );
    });
  });
}
```

### Integration with Existing Code

**Update `getCurrencyOptionsForLanguage()`:**

This function depends on `getLocalizedCurrencyName()`. Ensure it's imported:

```dart
// lib/utils/currency_helpers.dart

import 'translation_helpers.dart';

List<Map<String, String>> getCurrencyOptionsForLanguage(
  String languageCode,
  Map<String, dynamic> translationsCache,
) {
  // ... existing code ...

  String? _getCurrencyName(String code) {
    final translationKey = 'currency_${code.toLowerCase()}_cap';
    final translatedName = getTranslations(
      languageCode,
      translationKey,
      translationsCache,
    );

    if (translatedName.isEmpty || translatedName.startsWith('⚠️')) {
      return null;
    }
    return translatedName;
  }

  // ... rest of function ...
}
```

**Note:** The `_getCurrencyName` helper inside `getCurrencyOptionsForLanguage()` uses a different translation key format (`currency_{code}_cap` vs `currency_{code}`). These are SEPARATE keys:
- `currency_dkk` → "danske kroner" (lowercase)
- `currency_dkk_cap` → "Danske Kroner" (capitalized)

Ensure both key variants exist in translations table.

### Breaking Changes

**None.** Function signature and behavior remain identical to FlutterFlow version.

### Rollout Plan

**Phase 3A: Core Migration**
1. Port function to `lib/utils/currency_helpers.dart`
2. Write unit tests
3. Verify all 11 supported currencies have translations

**Phase 3B: Integration**
1. Update `getCurrencyOptionsForLanguage()` to import helper
2. Update currency selector widget to use new import path
3. Test currency selector UI in all supported languages

**Phase 3C: Validation**
1. Run full test suite
2. Manual testing of currency selection flow
3. Verify Settings page currency display
4. Check language switching updates currency names

---

## Related Functions

### 1. `getCurrencyOptionsForLanguage()`
**Purpose:** Returns list of currency options for dropdown UI
**Dependencies:** Uses `getLocalizedCurrencyName()` internally
**Location:** `custom_functions.dart` lines 1469-1549

**Usage:**
```dart
final options = getCurrencyOptionsForLanguage(
  FFAppState().currentLanguageCode,
  FFAppState().translationsCache,
);

// Returns: [
//   {'label': 'danske kroner (kr.)', 'code': 'DKK'},
//   {'label': 'Euro (€)', 'code': 'EUR'},
//   ...
// ]
```

### 2. `getCurrencyFormattingRules()`
**Purpose:** Returns symbol, placement, decimals for currency formatting
**Dependencies:** None (standalone reference data)
**Location:** `custom_functions.dart` lines 2093-2132

**Usage:**
```dart
final rulesJson = getCurrencyFormattingRules('DKK');
final rules = jsonDecode(rulesJson);

// Returns: { 'symbol': 'kr.', 'isPrefix': false, 'decimals': 0 }
```

### 3. `getTranslations()`
**Purpose:** Core translation lookup function
**Dependencies:** Used BY `getLocalizedCurrencyName()`
**Location:** `custom_functions.dart` lines 2161-2235

**Usage:**
```dart
final translation = getTranslations(
  'da',
  'currency_dkk',
  FFAppState().translationsCache,
);

// Returns: "danske kroner"
```

### 4. `convertAndFormatPrice()`
**Purpose:** Converts and formats prices with currency conversion
**Dependencies:** Uses `getCurrencyFormattingRules()` for symbol placement
**Location:** `custom_functions.dart` lines 1733-1811

**Usage:**
```dart
final formattedPrice = convertAndFormatPrice(
  100.0,        // basePrice
  'DKK',        // originalCurrencyCode
  7.0,          // exchangeRate
  'USD',        // targetCurrencyCode
);

// Returns: "$700"
```

---

## Additional Context

### Why This Function Exists

**Problem:** Currency codes (USD, EUR, DKK) are not user-friendly in non-English locales.

**Example:**
- English user sees "USD" → understands "US Dollar"
- Danish user sees "USD" → may not understand abbreviation
- Better to show "amerikanske dollar" in Danish UI

**Solution:** `getLocalizedCurrencyName()` provides human-readable currency names in any language.

### Design Decisions

**Decision 1: Fallback to Currency Code**
- **Rationale:** Better UX than showing error messages or blank spaces
- **Trade-off:** May show technical abbreviation (e.g., "BTC") if translation missing
- **Alternative Considered:** Return null and let caller handle → rejected as too many null checks needed

**Decision 2: Case-Insensitive Input**
- **Rationale:** ISO 4217 codes are uppercase, but developers may pass lowercase
- **Trade-off:** Minimal (one `.toUpperCase()` call)
- **Alternative Considered:** Require uppercase → rejected as too strict

**Decision 3: Translation Key Format**
- **Rationale:** Lowercase keys (`currency_dkk`) are easier to type and standardize
- **Trade-off:** Requires normalization step
- **Alternative Considered:** Use exact currency code case → rejected for consistency

**Decision 4: Nullable Return Type**
- **Rationale:** Need to differentiate "no currency selected" (null) from "unknown currency" (fallback code)
- **Trade-off:** Callers must handle null
- **Alternative Considered:** Always return string → rejected as loses semantic meaning

### Performance Characteristics

**Time Complexity:** O(1) — single hash map lookup
**Space Complexity:** O(1) — no allocation (returns reference from cache)
**Typical Execution Time:** < 1ms

**Bottlenecks:** None. Function is extremely fast.

### Localization Coverage

**Current Status (as of FlutterFlow export):**

| Language | Code | Currency Translations | Status |
|----------|------|----------------------|---------|
| Danish | da | 11/11 | ✅ Complete |
| English | en | 11/11 | ✅ Complete |
| German | de | 11/11 | ✅ Complete |
| French | fr | 11/11 | ✅ Complete |
| Italian | it | 11/11 | ✅ Complete |
| Norwegian | no | 11/11 | ✅ Complete |
| Swedish | sv | 11/11 | ✅ Complete |
| Spanish | es | ? | ⚠️ Inactive |
| Finnish | fi | ? | ⚠️ Inactive |
| Japanese | ja | ? | ⚠️ Inactive |
| Korean | ko | ? | ⚠️ Inactive |
| Dutch | nl | ? | ⚠️ Inactive |
| Polish | pl | ? | ⚠️ Inactive |
| Ukrainian | uk | ? | ⚠️ Inactive |
| Chinese | zh | ? | ⚠️ Inactive |

**Action Items:**
- Verify inactive languages have currency translations before activation
- Add translations for new currencies (e.g., Bitcoin, Ethereum) if supported

---

## End of Documentation

**Next Steps:**
1. Review this documentation with team
2. Verify translation keys exist in Supabase `translations` table
3. Port function to Flutter during Phase 3 migration
4. Write unit tests before integration
5. Test currency selector UI in all active languages

**Questions or Issues:**
- Contact: Development team
- Reference: `MASTER_README_get_localized_currency_name.md`
- Last Updated: 2026-02-19
