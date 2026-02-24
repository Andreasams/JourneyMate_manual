# saveUserPreference Action

**Type:** Custom Action (Async)
**File:** `save_user_preference.dart` (80 lines)
**Category:** User Preferences & Settings
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐⭐ (High - Core settings functionality)

---

## Purpose

Saves user preferences to persistent local storage using SharedPreferences. Provides flexible key-value storage for settings like language, currency, theme, or any configuration that should persist across app sessions.

**Key Features:**
- Stores data locally on device (not synchronized across devices)
- Special handling for currency: auto-updates FFAppState.userCurrencyCode
- Validates inputs and handles errors gracefully
- Uses snake_case naming convention for keys

---

## Function Signature

```dart
Future<void> saveUserPreference(String key, String value)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `key` | `String` | **Yes** | Unique identifier (use snake_case) |
| `value` | `String` | **Yes** | String value to store |

### Returns

| Type | Description |
|------|-------------|
| `Future<void>` | No return value |

---

## Dependencies

### pub.dev Packages
```yaml
shared_preferences: ^2.5.3  # Local storage
```

### FFAppState Usage

#### Writes (Conditional)
| State Variable | Type | Condition | Purpose |
|---------------|------|-----------|---------|
| `userCurrencyCode` | `String` | If key = 'user_currency_code' | Auto-synced with preference |

---

## Usage Examples

### Example 1: Language Selection
```dart
// User selects language
Future<void> _onLanguageChanged(String languageCode) async {
  await actions.saveUserPreference('user_language_code', languageCode);

  // Reload translations
  await actions.getTranslationsWithUpdate(languageCode);

  setState(() => _currentLanguage = languageCode);
}
```

### Example 2: Currency Selection
```dart
// User selects currency
Future<void> _onCurrencyChanged(String currencyCode) async {
  // This automatically updates FFAppState().userCurrencyCode
  await actions.saveUserPreference('user_currency_code', currencyCode);

  // FFAppState().userCurrencyCode is now updated ✅
  debugPrint('Currency saved: ${FFAppState().userCurrencyCode}');
}
```

### Example 3: Multiple Preferences
```dart
// Save multiple settings
Future<void> _saveUserSettings({
  String? language,
  String? currency,
  String? theme,
}) async {
  if (language != null) {
    await actions.saveUserPreference('user_language_code', language);
  }

  if (currency != null) {
    await actions.saveUserPreference('user_currency_code', currency);
  }

  if (theme != null) {
    await actions.saveUserPreference('theme_mode', theme);
  }
}
```

---

## Common Preference Keys

| Key | Value Examples | Description |
|-----|---------------|-------------|
| `user_language_code` | 'en', 'da', 'de' | User's language |
| `user_currency_code` | 'USD', 'DKK', 'EUR' | User's currency (⚠️ special handling) |
| `theme_mode` | 'light', 'dark', 'system' | Theme preference |
| `last_search_text` | 'pizza' | Last search query |
| `last_filter_ids` | '[1,2,3]' | Last active filters (JSON) |
| `onboarding_complete` | 'true', 'false' | Onboarding status |

---

## Special Handling: user_currency_code

When `key = 'user_currency_code'`:

```dart
1. Save to SharedPreferences
2. Auto-update FFAppState().userCurrencyCode (uppercase)
3. Log both operations
```

**Example:**
```dart
await saveUserPreference('user_currency_code', 'usd');

// Result:
// SharedPreferences: 'user_currency_code' = 'usd'
// FFAppState().userCurrencyCode = 'USD' (uppercase!)
```

---

## Error Handling

### Error 1: Empty Key
```
saveUserPreference: Cannot save with empty key
```
**Return:** Silently returns without saving
**Impact:** No data saved

### Error 2: Empty Value
```
saveUserPreference: Warning - saving empty value for key "theme_mode"
```
**Return:** Continues and saves empty string
**Impact:** Preference saved as empty

### Error 3: Save Failed
```
✗ Failed to save preference: user_language_code
```
**Cause:** SharedPreferences error (rare)
**Impact:** Data not persisted

### Error 4: Exception
```
Error saving preference for key "user_currency_code": [error]
```
**Cause:** System error or permission issue
**Impact:** Data not saved, error logged

---

## Debug Output

### Success
```
✓ Saved preference: user_language_code = da
```

### Success (Currency)
```
✓ Saved preference: user_currency_code = USD
✓ Auto-updated FFAppState.userCurrencyCode = USD
```

### Warning
```
saveUserPreference: Warning - saving empty value for key "theme_mode"
✓ Saved preference: theme_mode =
```

---

## Testing Checklist

- [ ] Save language preference → stored correctly
- [ ] Save currency preference → FFAppState updates
- [ ] Save currency (lowercase) → FFAppState uppercase
- [ ] Save with empty key → no crash, error logged
- [ ] Save with empty value → stored as empty string
- [ ] Retrieve saved preference → correct value returned
- [ ] App restart → preference persists
- [ ] Uninstall app → preferences cleared

---

## Migration Notes

### Phase 3 Changes

1. **Keep SharedPreferences** - Standard Flutter storage, no changes needed

2. **Replace FFAppState with Riverpod (for currency):**
   ```dart
   // Before:
   if (key == 'user_currency_code') {
     FFAppState().update(() {
       FFAppState().userCurrencyCode = value.toUpperCase();
     });
   }

   // After:
   if (key == 'user_currency_code') {
     ref.read(settingsProvider.notifier).setCurrency(value.toUpperCase());
   }
   ```

3. **Consider adding type-safe preferences:**
   ```dart
   Future<void> saveLanguagePreference(String lang) async {
     await saveUserPreference('user_language_code', lang);
   }

   Future<void> saveCurrencyPreference(String currency) async {
     await saveUserPreference('user_currency_code', currency.toUpperCase());
   }
   ```

---

## Related Actions

| Action | Purpose | Relationship |
|--------|---------|--------------|
| `getUserPreference` | Retrieve saved preference | Counterpart action |
| `updateCurrencyWithExchangeRate` | Update currency + fetch rate | Calls saveUserPreference |
| `updateCurrencyForLanguage` | Smart currency update | Calls saveUserPreference |

---

## Used By Pages

1. **Settings** - All preference updates
2. **Welcome/Onboarding** - Language/currency setup
3. **Throughout app** - Any setting that persists

---

## Known Issues

1. **Only stores strings** - Must convert numbers/booleans to strings
2. **No encryption** - Preferences stored in plain text
3. **Device-only** - Not synchronized across devices

---

## Security Notes

⚠️ **DO NOT store sensitive data:**
- Passwords
- API keys
- Credit card numbers
- Personal identification numbers

✅ **Safe to store:**
- Language preferences
- Currency choices
- Theme settings
- UI state
- Feature flags

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Riverpod migration for FFAppState sync
