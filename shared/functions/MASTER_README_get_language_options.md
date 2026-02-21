# getLanguageOptions() - Language Selection Configuration

**Function Type:** UI Configuration
**Location:** `lib/flutter_flow/custom_functions.dart` (lines 1551-1731)
**Category:** Localization / Language Management
**Migration Status:** Phase 3 Ready

---

## Purpose

Returns the list of active language options available for user selection, filtered by `is_active` status and sorted by `display_order`. This function serves as the central source of truth for language selection dropdowns throughout the app, ensuring only supported languages with complete translations are presented to users.

The function maintains a complete catalog of all planned languages (15 total), but only exposes those marked as active. This design allows for progressive language rollout and easy activation of new translations without code changes.

---

## Function Signature

```dart
List<dynamic> getLanguageOptions()
```

**Parameters:** None

**Return Value:**
- Type: `List<dynamic>` (list of maps)
- Structure: Each map contains:
  - `'label'` (String): Display text with flag emoji + native language name (e.g., '🇩🇰 Dansk')
  - `'code'` (String): ISO 639-1 language code (e.g., 'da')
- Ordered by: `display_order` field (ascending)
- Filtered: Only languages where `is_active == true`

---

## Dependencies

**Flutter/Dart:**
- None (pure Dart function, no external dependencies)

**Constants:**
- `allLanguages` (internal): Complete language catalog with metadata

---

## FFAppState Usage

**State Read:** None
**State Modified:** None

**Note:** This function is stateless and does not interact with FFAppState. The selected language code is stored separately in `FFAppState.appLanguageCode`.

---

## Language Configuration Structure

### Active Languages (7 languages)

As of migration, these languages are marked `is_active: true`:

| Display Order | Code | Name | Flag | Notes |
|--------------|------|------|------|-------|
| 1 | `da` | Dansk | 🇩🇰 | Primary language (Danish) |
| 2 | `en` | English | 🇬🇧 | Secondary language |
| 3 | `de` | Deutsch | 🇩🇪 | German |
| 4 | `sv` | Svenska | 🇸🇪 | Swedish |
| 5 | `no` | Norsk | 🇳🇴 | Norwegian |
| 6 | `it` | Italiano | 🇮🇹 | Italian |
| 7 | `fr` | Français | 🇫🇷 | French |

### Inactive Languages (8 languages)

These languages are prepared but not yet active (`is_active: false`):

| Code | Name | Flag | Display Order |
|------|------|------|--------------|
| `es` | Español | 🇪🇸 | 999 |
| `fi` | Suomi | 🇫🇮 | 999 |
| `ja` | 日本語 | 🇯🇵 | 999 |
| `ko` | 한국어 | 🇰🇷 | 999 |
| `nl` | Nederlands | 🇳🇱 | 999 |
| `pl` | Polski | 🇵🇱 | 999 |
| `uk` | Українська | 🇺🇦 | 999 |
| `zh` | 中文 | 🇨🇳 | 999 |

**Note:** Inactive languages use `display_order: 999` to keep them at the end of the sorted list if accidentally included.

### Language Metadata Fields

Each language entry contains:

```dart
{
  'idx': int,              // Original database index (historical reference)
  'language_code': String, // ISO 639-1 code ('da', 'en', etc.)
  'name': String,          // Native language name ('Dansk', 'English')
  'flag': String,          // Unicode flag emoji ('🇩🇰', '🇬🇧')
  'display_order': int,    // Sort priority (1 = first, 999 = inactive)
  'is_active': bool,       // Whether language is available to users
  'is_rtl': bool,          // Right-to-left writing direction (all false currently)
}
```

---

## Return Format Example

```dart
[
  {'label': '🇩🇰 Dansk', 'code': 'da'},
  {'label': '🇬🇧 English', 'code': 'en'},
  {'label': '🇩🇪 Deutsch', 'code': 'de'},
  {'label': '🇸🇪 Svenska', 'code': 'sv'},
  {'label': '🇳🇴 Norsk', 'code': 'no'},
  {'label': '🇮🇹 Italiano', 'code': 'it'},
  {'label': '🇫🇷 Français', 'code': 'fr'}
]
```

**Usage in UI:**
- Displayed in language selection dropdown (onboarding and profile pages)
- `label` shown to user
- `code` stored in `FFAppState.appLanguageCode` when selected

---

## Usage Examples

### Example 1: Basic Usage in Dropdown

**FlutterFlow Context:**
```dart
// In dropdown widget items property
final options = getLanguageOptions();
// Returns list of maps for dropdown items
```

**Pure Flutter Equivalent:**
```dart
// In build method
final languageOptions = getLanguageOptions();

DropdownButton<String>(
  value: currentLanguageCode,
  items: languageOptions.map((option) {
    return DropdownMenuItem<String>(
      value: option['code'] as String,
      child: Text(option['label'] as String),
    );
  }).toList(),
  onChanged: (newCode) {
    setState(() {
      FFAppState().appLanguageCode = newCode!;
    });
  },
)
```

### Example 2: Language Selector Widget

**Widget:** `LanguageSelectorWidget` (Profile page)

```dart
final languageOptions = getLanguageOptions();
final currentCode = FFAppState().appLanguageCode;

// Display current language
final currentLanguage = languageOptions.firstWhere(
  (option) => option['code'] == currentCode,
  orElse: () => languageOptions[0], // Fallback to first (Danish)
);

Text(currentLanguage['label']); // Shows "🇩🇰 Dansk"
```

### Example 3: Onboarding Language Selection

**Page:** `OnboardingPageWidget` (Step 1 of 3)

```dart
final languageOptions = getLanguageOptions();

// Wrap list items in a selectable widget
Column(
  children: languageOptions.map((option) {
    final code = option['code'] as String;
    final label = option['label'] as String;
    final isSelected = FFAppState().appLanguageCode == code;

    return GestureDetector(
      onTap: () {
        setState(() {
          FFAppState().appLanguageCode = code;
          // Reload translations cache...
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(label),
      ),
    );
  }).toList(),
)
```

### Example 4: Validation Check

**Use Case:** Verify stored language code is still valid

```dart
final storedCode = FFAppState().appLanguageCode;
final availableLanguages = getLanguageOptions();
final validCodes = availableLanguages.map((opt) => opt['code']).toList();

if (!validCodes.contains(storedCode)) {
  // Stored language was deactivated - reset to default
  FFAppState().appLanguageCode = 'da';
  print('Invalid language code, reset to Danish');
}
```

---

## Edge Cases

### Case 1: No Active Languages

**Scenario:** All languages marked `is_active: false` (should never happen)

**Behavior:**
```dart
final options = getLanguageOptions();
// Returns: []
```

**Handling:** App should have a minimum of one active language (Danish as default). If this occurs, it indicates a configuration error.

**Migration Note:** Add validation in app startup to ensure at least one active language exists.

### Case 2: Invalid display_order Values

**Scenario:** Two languages have same `display_order`

**Behavior:**
```dart
// Dart's sort is stable - maintains original order for equal values
// Languages with same display_order will appear in their original catalog order
```

**Best Practice:** Ensure unique `display_order` values for all active languages.

### Case 3: Missing Metadata Fields

**Scenario:** Language entry missing required fields

**Behavior:**
```dart
// Will throw runtime error when accessing missing keys
// Example: option['label'] on entry without 'flag' or 'name'
```

**Migration Note:** Validate language catalog completeness during app initialization.

### Case 4: RTL Language Support

**Current Status:** All languages have `is_rtl: false`

**Future Consideration:** Arabic and Hebrew support would require:
1. Set `is_rtl: true` for those languages
2. Update UI to conditionally flip layout direction
3. Verify text alignment in all widgets

**Example:**
```dart
final option = getLanguageOptions().firstWhere((o) => o['code'] == currentCode);
final isRtl = option['is_rtl'] as bool;

return Directionality(
  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
  child: YourWidget(),
);
```

### Case 5: Language Activation/Deactivation

**Scenario:** Language is deactivated after being selected by users

**Impact:**
- Existing users with that language saved will lose their preference
- `getLanguageOptions()` no longer returns that language
- App should detect and reset to default

**Recommended Pattern:**
```dart
// On app startup / language selector screen
final currentCode = FFAppState().appLanguageCode;
final availableOptions = getLanguageOptions();
final isStillAvailable = availableOptions.any((opt) => opt['code'] == currentCode);

if (!isStillAvailable) {
  FFAppState().appLanguageCode = 'da'; // Reset to Danish
  // Show snackbar: "Your selected language is no longer available"
}
```

---

## Testing Checklist

### Unit Tests

- [ ] Returns non-empty list when active languages exist
- [ ] Filters out inactive languages (`is_active: false`)
- [ ] Sorts by `display_order` (ascending)
- [ ] Each returned map contains 'label' and 'code' keys
- [ ] Label format is "{flag} {name}" (e.g., "🇩🇰 Dansk")
- [ ] Code matches ISO 639-1 format (2-letter lowercase)
- [ ] Returns empty list if no active languages (edge case)
- [ ] Inactive languages with `display_order: 999` are excluded

### Integration Tests

- [ ] Language dropdown displays all active languages
- [ ] Selecting language updates `FFAppState.appLanguageCode`
- [ ] Selected language persists across app restarts
- [ ] Onboarding language selector shows correct options
- [ ] Profile language selector matches onboarding options
- [ ] Flag emojis render correctly on all platforms
- [ ] Language name displays in native script (e.g., "日本語")

### UI Tests

- [ ] Dropdown items are tappable
- [ ] Current language is visually highlighted
- [ ] Flag emojis align correctly with text
- [ ] Scrolling works if list exceeds screen height
- [ ] No empty states or placeholder items
- [ ] Works on iOS, Android, and web (if applicable)

### Localization Tests

- [ ] Each active language has complete translation coverage
- [ ] Switching language updates all visible UI text
- [ ] No fallback to English mid-screen (incomplete translations)
- [ ] Currency and date formats adjust to language
- [ ] Direction remains LTR for all current languages

---

## Migration Notes

### Phase 3 Migration Requirements

**1. Port Function As-Is**
- Copy function verbatim from FlutterFlow custom_functions.dart
- No logic changes needed
- Keep `allLanguages` constant structure intact

**2. Integration Points**

Update these widgets to use the function:

| Widget | Page | Usage |
|--------|------|-------|
| `LanguageSelectorWidget` | Onboarding (Step 1) | Displays language options |
| `LanguageSelectorWidget` | Profile | Allows language change |
| App Startup | `main.dart` | Validates stored language code |

**3. State Management**

Ensure `FFAppState.appLanguageCode` is:
- Initialized with default ('da')
- Persisted with SharedPreferences
- Validated against active languages on startup

**4. Testing Strategy**

```dart
void testLanguageOptions() {
  final options = getLanguageOptions();

  // Assert: Non-empty list
  expect(options.isNotEmpty, true);

  // Assert: All have required keys
  for (final option in options) {
    expect(option.containsKey('label'), true);
    expect(option.containsKey('code'), true);
  }

  // Assert: Sorted by display order
  final codes = options.map((o) => o['code']).toList();
  expect(codes[0], 'da'); // Danish first
  expect(codes[1], 'en'); // English second

  // Assert: No inactive languages
  expect(codes.contains('es'), false); // Spanish inactive
}
```

**5. Future Enhancements**

Consider these improvements post-migration:

- **Dynamic Language Loading:** Fetch active languages from API instead of hardcoded list
- **A/B Testing:** Allow toggling language availability remotely
- **User Metrics:** Track language selection for localization prioritization
- **Fallback Chain:** If translation missing, try English, then Danish, then key

**6. Breaking Changes**

**None expected.** This function is a pure data provider with no external dependencies.

**Compatibility Note:** If migrating from FlutterFlow AppState to Provider/Riverpod, ensure `appLanguageCode` remains accessible at the same path.

---

## Related Functions

| Function | Purpose | Relationship |
|----------|---------|--------------|
| `getTranslations()` | Fetches translation string for key + language | Consumes language codes returned by `getLanguageOptions()` |
| `formatLocalizedDate()` | Formats dates with locale-specific patterns | Uses language code to determine date format |
| `getLocalizedCurrencyName()` | Returns currency name in user's language | Uses language code for localization |
| `getCurrencyOptionsForLanguage()` | Filters currency options by language | Uses language code to determine available currencies |

**Typical Usage Flow:**

1. User selects language from `getLanguageOptions()` → Returns `[{label: '🇩🇰 Dansk', code: 'da'}, ...]`
2. Selected `code` stored in `FFAppState.appLanguageCode` → Persists as `'da'`
3. `getTranslations('da', 'filter_location', cache)` → Returns "Placering"
4. `formatLocalizedDate('2025-08-08', 'da')` → Returns "8. august 2025"

---

## Migration Checklist

**Pre-Migration:**
- [x] Function located in FlutterFlow custom_functions.dart
- [x] Function signature documented
- [x] Language catalog structure understood
- [x] Active vs inactive languages identified
- [x] Integration points mapped

**During Migration:**
- [ ] Copy function to `lib/shared/custom_functions.dart`
- [ ] Import function in widgets that need language selection
- [ ] Update `LanguageSelectorWidget` (onboarding)
- [ ] Update `LanguageSelectorWidget` (profile)
- [ ] Add validation check in `main.dart` startup

**Post-Migration:**
- [ ] Unit tests pass (filtering, sorting, return format)
- [ ] Integration tests pass (dropdown displays correctly)
- [ ] Language selection persists across app restarts
- [ ] Selected language applies to all UI text
- [ ] Flag emojis render on iOS and Android
- [ ] No console errors related to missing keys
- [ ] Code review completed
- [ ] QA approval on staging build

---

## Common Issues

### Issue 1: Flag Emojis Not Displaying

**Symptom:** Square boxes (☐) instead of flags

**Cause:** Device lacks emoji font support (rare on modern devices)

**Solution:**
```dart
// Fallback to text-only labels if flags don't render
final supportsEmoji = Platform.isAndroid || Platform.isIOS;
final label = supportsEmoji
  ? '${option['flag']} ${option['name']}'
  : option['name']; // Just name, no flag
```

### Issue 2: Language Not Updating After Selection

**Symptom:** User selects new language but UI text doesn't change

**Cause:** Translations cache not reloaded after language change

**Solution:**
```dart
// After updating appLanguageCode
FFAppState().appLanguageCode = newCode;
await FFAppState().loadTranslationsForLanguage(newCode); // Reload cache
setState(() {}); // Trigger rebuild
```

### Issue 3: Stale Language Code Stored

**Symptom:** App crashes or shows empty dropdowns after language deactivation

**Cause:** User had selected a language that was later deactivated

**Solution:**
```dart
// In main.dart initialization
final storedCode = FFAppState().appLanguageCode;
final validCodes = getLanguageOptions().map((o) => o['code']).toList();

if (!validCodes.contains(storedCode)) {
  FFAppState().appLanguageCode = 'da'; // Reset to default
}
```

### Issue 4: Display Order Inconsistency

**Symptom:** Language order differs between devices or app versions

**Cause:** Sort algorithm changed or `display_order` values modified

**Solution:** Maintain consistent `display_order` values in source code. Avoid dynamic reordering based on user locale.

---

## Performance Considerations

**Function Complexity:** O(n log n) where n = number of languages (15 max)

**Execution Time:** < 1ms (negligible - small dataset)

**Memory Usage:** ~2KB (entire language catalog loaded)

**Optimization Notes:**
- Function is stateless and deterministic - safe to call multiple times
- Consider caching result in a provider if called frequently (e.g., on every frame)
- No network calls or async operations

**Recommended Pattern:**
```dart
// Cache in Provider (not re-evaluated on every build)
class LanguageProvider with ChangeNotifier {
  List<dynamic>? _cachedOptions;

  List<dynamic> get languageOptions {
    _cachedOptions ??= getLanguageOptions();
    return _cachedOptions!;
  }
}
```

---

## Security Considerations

**No security risks identified.**

- Function does not access user data
- No network requests or API calls
- No sensitive information in language catalog
- Read-only operation (does not modify state)

**Safe for client-side execution.**

---

## Accessibility Notes

**Screen Reader Support:**
- Ensure dropdown items are read correctly (flag + name)
- Consider adding `Semantics` widget with label: "Select language: Danish"

**Keyboard Navigation:**
- Dropdown should be navigable with Tab key
- Space/Enter should open dropdown and select items

**Example:**
```dart
Semantics(
  label: 'Select language: ${currentLanguage['name']}',
  child: DropdownButton<String>(
    // ... dropdown implementation
  ),
)
```

---

## Documentation Change Log

| Date | Change | Author |
|------|--------|--------|
| 2026-02-19 | Initial documentation created | Claude Code |

---

**End of Documentation**
