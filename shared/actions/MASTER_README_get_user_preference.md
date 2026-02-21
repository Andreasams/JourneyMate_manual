# getUserPreference Action

**Type:** Custom Action (Async)
**File:** `get_user_preference.dart` (108 lines)
**Category:** User Preferences & Settings
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐⭐ (High - Core settings functionality)

---

## Purpose

Retrieves user preferences from persistent local storage. Counterpart to `saveUserPreference` that reads previously stored values.

**Key Features:**
- Retrieves values from SharedPreferences
- Returns empty string if not found (safe default)
- Special handling for currency: auto-updates FFAppState + sets default (DKK)
- Never throws exceptions (graceful error handling)

---

## Function Signature

```dart
Future<String> getUserPreference(String key)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `key` | `String` | **Yes** | Unique identifier (same as used in saveUserPreference) |

### Returns

| Type | Description |
|------|-------------|
| `Future<String>` | Stored value, or empty string if not found/error |

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
| `userCurrencyCode` | `String` | If key = 'user_currency_code' | Auto-synced with preference, defaults to 'DKK' |

---

## Usage Examples

### Example 1: App Initialization
```dart
// Restore user preferences on app start
@override
void initState() {
  super.initState();
  _restorePreferences();
}

Future<void> _restorePreferences() async {
  final language = await actions.getUserPreference('user_language_code');
  final currency = await actions.getUserPreference('user_currency_code');

  if (language.isNotEmpty) {
    // Load translations for saved language
    await actions.getTranslationsWithUpdate(language);
  }

  // FFAppState().userCurrencyCode already updated automatically!
}
```

### Example 2: With Default Values
```dart
// Get preference with fallback
Future<String> _getThemeMode() async {
  final theme = await actions.getUserPreference('theme_mode');
  return theme.isEmpty ? 'light' : theme; // Default to 'light'
}

// Or inline
final theme = await actions.getUserPreference('theme_mode');
final effectiveTheme = theme.isEmpty ? 'light' : theme;
```

### Example 3: Boolean Preferences
```dart
// Store boolean as string
await actions.saveUserPreference('onboarding_complete', 'true');

// Retrieve and convert
final completed = await actions.getUserPreference('onboarding_complete');
final isComplete = completed == 'true';

if (isComplete) {
  context.pushNamed('Home');
} else {
  context.pushNamed('Onboarding');
}
```

---

## Return Values

| Scenario | Return Value | FFAppState Update |
|----------|-------------|-------------------|
| Key exists with value | Stored value | Yes (if currency) |
| Key doesn't exist | Empty string `''` | Yes (if currency → 'DKK') |
| Empty key parameter | Empty string `''` | No |
| Error reading storage | Empty string `''` | Yes (if currency → 'DKK') |

---

## Special Handling: user_currency_code

When `key = 'user_currency_code'`:

### Case 1: Value Found
```dart
1. Read from SharedPreferences
2. Auto-update FFAppState().userCurrencyCode (uppercase)
3. Return value
```

### Case 2: Value Not Found
```dart
1. Set FFAppState().userCurrencyCode = 'DKK'
2. Return empty string ''
```

### Case 3: Error
```dart
1. Set FFAppState().userCurrencyCode = 'DKK'
2. Save 'DKK' to SharedPreferences (for next time)
3. Return empty string ''
```

**Example:**
```dart
// User's first app launch - no currency saved
final currency = await getUserPreference('user_currency_code');

// Result:
// currency = '' (empty string)
// FFAppState().userCurrencyCode = 'DKK' (default)
```

---

## Error Handling

### Error 1: Empty Key
```
getUserPreference: Cannot retrieve with empty key
```
**Return:** `''` (empty string)
**FFAppState:** Not updated

### Error 2: Key Not Found
```
✗ No preference found for key: theme_mode
```
**Return:** `''` (empty string)
**FFAppState:** Updated to 'DKK' if currency key

### Error 3: Exception
```
Error retrieving preference for key "user_language_code": [error]
```
**Return:** `''` (empty string)
**FFAppState:** Updated to 'DKK' if currency key

---

## Debug Output

### Success
```
✓ Retrieved preference: user_language_code = da
```

### Success (Currency)
```
✓ Retrieved preference: user_currency_code = USD
✓ Auto-updated FFAppState.userCurrencyCode = USD
```

### Not Found
```
✗ No preference found for key: theme_mode
```

### Not Found (Currency)
```
✗ No preference found for key: user_currency_code
✓ Auto-set FFAppState.userCurrencyCode to default: DKK
```

---

## Common Patterns

### Pattern 1: Restore on App Start
```dart
Future<void> _restoreAllPreferences() async {
  final language = await actions.getUserPreference('user_language_code');
  final theme = await actions.getUserPreference('theme_mode');

  if (language.isNotEmpty) {
    setState(() => _currentLanguage = language);
    await actions.getTranslationsWithUpdate(language);
  }

  if (theme.isNotEmpty) {
    setState(() => _themeMode = theme);
  }

  // Currency automatically loaded into FFAppState
}
```

### Pattern 2: Check if First Launch
```dart
Future<bool> _isFirstLaunch() async {
  final completed = await actions.getUserPreference('onboarding_complete');
  return completed.isEmpty; // Empty = first launch
}
```

### Pattern 3: Get with Validation
```dart
Future<String> _getValidatedLanguage() async {
  final lang = await actions.getUserPreference('user_language_code');
  final validLanguages = ['en', 'da', 'de', 'sv', 'no'];

  return validLanguages.contains(lang) ? lang : 'en';
}
```

---

## Testing Checklist

- [ ] Get saved preference → returns correct value
- [ ] Get non-existent preference → returns empty string
- [ ] Get with empty key → returns empty string, logs warning
- [ ] Get currency (exists) → updates FFAppState
- [ ] Get currency (not exists) → sets FFAppState to 'DKK'
- [ ] App restart → preferences persist
- [ ] After saveUserPreference → getUserPreference returns new value

---

## Migration Notes

### Phase 3 Changes

1. **Keep SharedPreferences** - Standard Flutter storage

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

3. **Consider type-safe wrappers:**
   ```dart
   Future<String> getLanguagePreference() async {
     final lang = await getUserPreference('user_language_code');
     return lang.isEmpty ? 'en' : lang;
   }

   Future<bool> getOnboardingComplete() async {
     final completed = await getUserPreference('onboarding_complete');
     return completed == 'true';
   }
   ```

---

## Related Actions

| Action | Purpose | Relationship |
|--------|---------|--------------|
| `saveUserPreference` | Save preference | Counterpart action |
| `updateCurrencyWithExchangeRate` | Update currency + rate | Uses saveUserPreference internally |

---

## Used By Pages

1. **Main App** - Restore preferences on launch
2. **Settings** - Display current preferences
3. **Welcome/Onboarding** - Check if first launch

---

## Known Issues

1. **Returns empty string (not null)** - Must check `isEmpty` not `== null`
2. **Type conversion required** - Everything is a string
3. **Default 'DKK' hardcoded** - Not configurable

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Riverpod migration
