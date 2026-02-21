# updateCurrencyForLanguage Action

**Type:** Custom Action (Async)
**File:** `update_currency_for_language.dart` (203 lines)
**Category:** Currency & Settings
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐⭐ (High - Smart currency UX)

---

## Purpose

Smart currency updater that ensures user's currency remains compatible with their language selection. When switching languages, keeps current currency if available in new language, otherwise switches to sensible default.

**Key Features:**
- Maintains user's currency preference across language changes when possible
- Automatically switches to appropriate default when currency unavailable
- Supports 14 languages with 15 currencies
- Calls updateCurrencyWithExchangeRate for atomic updates
- Provides seamless UX without user intervention

---

## Function Signature

```dart
Future<void> updateCurrencyForLanguage(String newLanguageCode)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `newLanguageCode` | `String` | **Yes** | ISO 639-1 language code (e.g., 'en', 'da', 'de') |

### Returns

| Type | Description |
|------|-------------|
| `Future<void>` | No return value |

---

## Dependencies

### Internal Dependencies
```dart
import '/custom_code/actions/index.dart';  // updateCurrencyWithExchangeRate
```

### FFAppState Usage

#### Reads
| State Variable | Type | Purpose |
|---------------|------|---------|
| `userCurrencyCode` | `String` | Current currency preference |

#### Writes (via updateCurrencyWithExchangeRate)
| State Variable | Type | Purpose |
|---------------|------|---------|
| `userCurrencyCode` | `String` | Updated if currency changed |
| `exchangeRate` | `double` | Updated exchange rate |

---

## Smart Currency Logic

```
1. Read current currency from FFAppState
2. Get available currencies for new language
3. Check if current currency available in new language
   ├─ YES → Keep current currency (no update needed)
   └─ NO → Switch to default currency for new language
4. If currency changed → call updateCurrencyWithExchangeRate()
5. Log the change
```

---

## Language-Currency Mapping

### Available Currencies by Language

| Language | Code | Available Currencies | Default |
|----------|------|---------------------|---------|
| English | en | USD, GBP, DKK | **USD** |
| Danish | da | DKK | **DKK** |
| German | de | EUR, DKK | **EUR** |
| Swedish | sv | SEK, DKK | **SEK** |
| Norwegian | no | NOK, DKK | **NOK** |
| Italian | it | EUR, DKK | **EUR** |
| French | fr | EUR, DKK | **EUR** |
| Spanish | es | EUR, DKK | **EUR** |
| Finnish | fi | EUR, DKK | **EUR** |
| Dutch | nl | EUR, DKK | **EUR** |
| Polish | pl | PLN, EUR, DKK | **PLN** |
| Ukrainian | uk | UAH, EUR, DKK | **UAH** |
| Japanese | ja | JPY, USD, DKK | **JPY** |
| Korean | ko | KRW, USD, DKK | **KRW** |
| Chinese | zh | CNY, USD, DKK | **CNY** |

---

## Usage Examples

### Example 1: Language Selector (Primary Use Case)
```dart
// User changes language in settings
Future<void> _onLanguageSelected(String languageCode) async {
  // Update translations
  await actions.getTranslationsWithUpdate(languageCode);

  // Smart currency update (keeps if possible, switches if needed)
  await actions.updateCurrencyForLanguage(languageCode);

  // Update UI
  setState(() => _currentLanguage = languageCode);
}
```

### Example 2: Onboarding Flow
```dart
// User selects language during onboarding
Future<void> _completeLanguageStep(String language) async {
  await actions.getTranslationsWithUpdate(language);
  await actions.updateCurrencyForLanguage(language);

  // Currency is now appropriate for their language
  context.pushNamed('CurrencySelector'); // Optional: let user override
}
```

### Example 3: With Notification
```dart
Future<void> _changeLanguage(String newLanguage) async {
  final oldCurrency = FFAppState().userCurrencyCode;

  await actions.getTranslationsWithUpdate(newLanguage);
  await actions.updateCurrencyForLanguage(newLanguage);

  final newCurrency = FFAppState().userCurrencyCode;

  if (oldCurrency != newCurrency) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Currency changed to $newCurrency'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
```

---

## Real-World Scenarios

### Scenario 1: EUR User Switches German → Italian
```
Current: German, EUR
Action: Switch to Italian
Result: Keep EUR (available in Italian)
Update: No currency change ✓
```

### Scenario 2: USD User Switches English → German
```
Current: English, USD
Action: Switch to German
Result: Switch to EUR (USD not available in German)
Update: Currency changed to EUR ✓
```

### Scenario 3: DKK User Switches Between Nordic Languages
```
Current: Danish, DKK
Action: Switch to Norwegian
Result: Keep DKK (available in Norwegian)
Update: No currency change ✓
```

### Scenario 4: GBP User Switches English → Swedish
```
Current: English, GBP
Action: Switch to Swedish
Result: Switch to SEK (GBP not available in Swedish)
Update: Currency changed to SEK ✓
```

---

## Error Handling

### Error 1: Empty Language Code
```
updateCurrencyForLanguage: Empty language code provided
```
**Action:** Return immediately without updates
**Impact:** Currency unchanged

### Error 2: Unknown Language Code
```
[Fallback to DKK]
```
**Action:** Uses DKK as fallback currency
**Impact:** Currency set to DKK

### Error 3: Exception
```
Error in updateCurrencyForLanguage: [error]
[Calls updateCurrencyWithExchangeRate('DKK')]
```
**Action:** Safely fallback to DKK
**Impact:** Currency set to DKK, exchange rate updated

---

## Debug Output

### No Change Needed
```
[No log output - currency stays the same]
```

### Currency Changed
```
Currency updated: USD → EUR
✓ Saved preference: user_currency_code = EUR
✓ Auto-updated FFAppState.userCurrencyCode = EUR
✅ Currency: EUR, Rate: 7.45
```

---

## Design Philosophy

**Why This Matters:**

1. **User Preference Preservation**: Keeps user's currency when possible
2. **Sensible Defaults**: Automatically provides appropriate currency for language
3. **Seamless UX**: No manual intervention required
4. **International Support**: Works globally with multiple currency options

---

## Testing Checklist

- [ ] Switch German (EUR) → Italian (EUR) → currency unchanged
- [ ] Switch English (USD) → German (EUR) → currency changed
- [ ] Switch Danish (DKK) → Norwegian (DKK) → currency unchanged
- [ ] Switch English (GBP) → Japanese (JPY) → currency changed
- [ ] Empty language code → no crash, no update
- [ ] Unknown language code → fallback to DKK
- [ ] Verify exchange rate updated after change
- [ ] Check SharedPreferences persists new currency

---

## Migration Notes

### Phase 3 Changes

1. **Keep smart currency logic** - Well-designed UX pattern
2. **Replace FFAppState with Riverpod:**
   ```dart
   // Before:
   final currentCurrency = FFAppState().userCurrencyCode;

   // After:
   final currentCurrency = ref.read(currencyProvider).code;
   ```

3. **Consider making currency mappings configurable:**
   ```dart
   // Load from API or config file instead of hardcoded
   final currencyConfig = await _loadCurrencyConfig();
   final availableCodes = currencyConfig[newLanguageCode];
   ```

---

## Related Actions

| Action | Purpose | Relationship |
|--------|---------|--------------|
| `updateCurrencyWithExchangeRate` | Update currency + rate | Called when currency changes |
| `getTranslationsWithUpdate` | Update translations | Called before this action |
| `saveUserPreference` | Save currency | Called via updateCurrencyWithExchangeRate |

---

## Used By Pages

1. **Settings** - Language selector
2. **Welcome/Onboarding** - Language setup

---

## Known Issues

1. **Currency mappings hardcoded** - Not configurable
2. **No user notification** - Silent currency changes
3. **DKK always available** - Ensures fallback works

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Consider configurable currency mappings
