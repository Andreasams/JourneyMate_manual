# updateCurrencyWithExchangeRate Action

**Type:** Custom Action (Async)
**File:** `update_currency_with_exchange_rate.dart` (76 lines)
**Category:** Currency & Settings
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐⭐ (High - Currency functionality)

---

## Purpose

Updates user's currency preference and fetches exchange rate from DKK in a single action. Combines preference saving with rate fetching for atomic updates.

**Key Features:**
- Saves currency to SharedPreferences
- Auto-updates FFAppState.userCurrencyCode
- Fetches exchange rate from BuildShip API
- Updates FFAppState.exchangeRate
- Skips API call for DKK (1:1 rate)
- Normalizes currency codes to uppercase

---

## Function Signature

```dart
Future<bool> updateCurrencyWithExchangeRate(String newCurrencyCode)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `newCurrencyCode` | `String` | **Yes** | ISO 4217 currency code (e.g., 'USD', 'EUR') |

### Returns

| Type | Description |
|------|-------------|
| `Future<bool>` | `true` if successful, `false` on error |

---

## Dependencies

### pub.dev Packages
```yaml
http: ^1.2.1              # Exchange rate API
shared_preferences: ^2.5.3 # Currency preference storage
```

### Internal Dependencies
```dart
import '/custom_code/actions/index.dart';  // saveUserPreference
```

### FFAppState Usage

#### Writes
| State Variable | Type | Purpose |
|---------------|------|---------|
| `userCurrencyCode` | `String` | Updated via saveUserPreference |
| `exchangeRate` | `double` | Exchange rate from DKK |

---

## BuildShip Endpoint

```
GET https://wvb8ww.buildship.run/getExchangeRates
```

### Query Parameters
```dart
{
  'from_currency': 'DKK',    // Always DKK (base currency)
  'to_currency': 'USD',      // Target currency
}
```

### Response Format
```json
[
  {
    "rate": 0.145
  }
]
```

---

## Usage Examples

### Example 1: Currency Selector
```dart
// User selects currency from dropdown
Future<void> _onCurrencySelected(String currency) async {
  final success = await actions.updateCurrencyWithExchangeRate(currency);

  if (success) {
    setState(() => _selectedCurrency = currency);
    _refreshPrices(); // Recalculate prices with new rate
  } else {
    _showError('Failed to update currency');
  }
}
```

### Example 2: Language Change with Currency Update
```dart
// Update currency when language changes
Future<void> _onLanguageChanged(String newLanguage) async {
  // Update language
  await actions.getTranslationsWithUpdate(newLanguage);

  // Smart currency update (keeps if available, switches if not)
  await actions.updateCurrencyForLanguage(newLanguage);

  // Exchange rate already updated ✅
}
```

### Example 3: Settings Page Init
```dart
@override
void initState() {
  super.initState();
  _loadCurrency();
}

Future<void> _loadCurrency() async {
  final saved = await actions.getUserPreference('user_currency_code');

  if (saved.isNotEmpty) {
    // Fetch latest exchange rate
    await actions.updateCurrencyWithExchangeRate(saved);
  }
}
```

---

## Workflow

```
1. Validate & normalize currency code (trim, uppercase)
2. Save to SharedPreferences via saveUserPreference()
   └─ This auto-updates FFAppState.userCurrencyCode
3. If currency == 'DKK':
   ├─ Set exchangeRate = 1.0
   └─ Return true (skip API)
4. Else:
   ├─ Call BuildShip exchange rate API
   ├─ Extract rate from response
   ├─ Update FFAppState.exchangeRate
   └─ Return success status
```

---

## DKK Special Handling

```dart
if (normalizedCode == 'DKK') {
  FFAppState().exchangeRate = 1.0;
  return true; // Skip API call
}
```

**Reason:** DKK is the base currency. No need to fetch 1:1 rate.

---

## Error Handling

### Error 1: Empty Currency Code
```
⚠️ Empty currency code
```
**Return:** `false`
**FFAppState:** Not updated

### Error 2: API Failure
```
❌ Exchange rate API failed: 500
```
**Return:** `false`
**FFAppState:** exchangeRate not updated (keeps old value)

### Error 3: Empty Response
```
⚠️ No exchange rate data returned
```
**Return:** `false`
**FFAppState:** exchangeRate not updated

### Error 4: Exception
```
❌ Error updating currency: FormatException
```
**Return:** `false`
**FFAppState:** Not updated

---

## Debug Output

### Success (Non-DKK)
```
✓ Saved preference: user_currency_code = USD
✓ Auto-updated FFAppState.userCurrencyCode = USD
✅ Currency: USD, Rate: 0.145
```

### Success (DKK)
```
✓ Saved preference: user_currency_code = DKK
✓ Auto-updated FFAppState.userCurrencyCode = DKK
✅ Currency set to DKK (rate: 1.0)
```

### Failure
```
❌ Exchange rate API failed: 404
```

---

## Exchange Rate Usage

After calling this action, use the rate to convert prices:

```dart
// Display price in user's currency
Widget _buildPrice(double priceInDKK) {
  final convertedPrice = priceInDKK * FFAppState().exchangeRate;
  final currency = FFAppState().userCurrencyCode;

  return Text('$currency ${convertedPrice.toStringAsFixed(2)}');
}
```

---

## Testing Checklist

- [ ] Update to USD → rate fetched, FFAppState updated
- [ ] Update to EUR → rate fetched, FFAppState updated
- [ ] Update to DKK → rate = 1.0, no API call
- [ ] Update with lowercase 'usd' → normalized to 'USD'
- [ ] Update with empty string → returns false
- [ ] API failure → returns false, rate unchanged
- [ ] Invalid currency code → API error handled
- [ ] Verify preference saved to SharedPreferences
- [ ] App restart → rate fetched again (not cached)

---

## Migration Notes

### Phase 3 Changes

1. **Replace FFAppState with Riverpod:**
   ```dart
   // Before:
   FFAppState().update(() {
     FFAppState().exchangeRate = rate.toDouble();
   });

   // After:
   ref.read(currencyProvider.notifier).setExchangeRate(rate);
   ```

2. **Keep BuildShip endpoint** - No changes needed

3. **Consider caching rates:**
   ```dart
   // Cache rates to avoid repeated API calls
   final cachedRate = await _getCachedRate(currency);
   if (cachedRate != null && !_isStale(cachedRate)) {
     return cachedRate.value;
   }
   ```

---

## Related Actions

| Action | Purpose | Relationship |
|--------|---------|--------------|
| `saveUserPreference` | Save currency preference | Called internally |
| `updateCurrencyForLanguage` | Smart currency update | Calls this action |
| `getUserPreference` | Retrieve saved currency | Used before updating |

---

## Used By Pages

1. **Settings** - Currency selector
2. **Welcome/Onboarding** - Currency setup
3. **Language Change Flow** - Via updateCurrencyForLanguage

---

## Known Issues

1. **No rate caching** - Fetches rate on every call
2. **No retry logic** - Single attempt only
3. **DKK hardcoded as base** - Not configurable

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Add rate caching, Riverpod migration
