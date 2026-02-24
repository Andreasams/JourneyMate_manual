# getTranslationsWithUpdate Action

**Type:** Custom Action (Async)
**File:** `get_translations_with_update.dart` (112 lines)
**Category:** Translations & Localization
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐⭐⭐ (Critical - All dynamic text)

---

## Purpose

Fetches dynamic translations from BuildShip API and automatically updates FFAppState cache. Provides localized strings for filter names, dietary preferences, allergens, and menu content.

**Key Features:**
- Fetches translations via HTTP GET
- Automatically updates FFAppState.translationsCache
- No separate state update action needed
- Returns success/failure boolean
- Sets empty cache on errors (safe failure mode)

**Critical:** This is for **dynamic content** (filters, menu items). Static UI text uses `FFLocalizations`.

---

## Function Signature

```dart
Future<bool> getTranslationsWithUpdate(String languageCode)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `languageCode` | `String` | **Yes** | ISO 639-1 code ('en', 'da', 'de', etc.) |

### Returns

| Type | Description |
|------|-------------|
| `Future<bool>` | `true` if successful, `false` on error |

---

## Dependencies

### pub.dev Packages
```yaml
http: ^1.2.1              # API calls
```

### FFAppState Usage

#### Writes
| State Variable | Type | Purpose |
|---------------|------|---------|
| `translationsCache` | `Map<String, dynamic>` | Translation key-value pairs |

---

## BuildShip Endpoint

```
GET https://wvb8ww.buildship.run/languageText
```

### Query Parameters
```dart
{
  'languageCode': 'da'
}
```

### Response Format
```json
{
  "filter_vegetarian": "Vegetarisk",
  "filter_vegan": "Vegansk",
  "allergen_peanuts": "Jordnødder",
  "dietary_gluten_free": "Glutenfri",
  ...
}
```

---

## Usage Examples

### Example 1: Language Change
```dart
// User switches language
Future<void> _onLanguageChanged(String newLanguage) async {
  final success = await actions.getTranslationsWithUpdate(newLanguage);

  if (success) {
    // Update currency if needed
    await actions.updateCurrencyForLanguage(newLanguage);

    // Refresh UI
    setState(() {});
  } else {
    _showError('Failed to load translations');
  }
}
```

### Example 2: App Initialization
```dart
@override
void initState() {
  super.initState();
  _loadTranslations();
}

Future<void> _loadTranslations() async {
  final savedLanguage = await actions.getUserPreference('user_language_code');
  final language = savedLanguage.isEmpty ? 'en' : savedLanguage;

  await actions.getTranslationsWithUpdate(language);
}
```

### Example 3: With Loading State
```dart
Future<void> _loadLanguage(String lang) async {
  setState(() => _isLoading = true);

  try {
    final success = await actions.getTranslationsWithUpdate(lang);

    if (success) {
      await actions.saveUserPreference('user_language_code', lang);
      setState(() => _currentLanguage = lang);
    }
  } finally {
    setState(() => _isLoading = false);
  }
}
```

---

## Translation Usage

After calling this action, get translations using the custom function:

```dart
// Get translated text
final text = getTranslations(
  languageCode,
  'filter_vegetarian',
  FFAppState().translationsCache,
);

// Example result: "Vegetarisk" (if Danish)
```

---

## Dual Translation System

JourneyMate uses **TWO separate translation systems**:

### 1. FFLocalizations (Static UI Text)
```dart
// Location: lib/flutter_flow/internationalization.dart
// Usage:
FFLocalizations.of(context).getText('button_search')

// Content: Button labels, page titles, static text
// Count: 191 strings, 7 languages
```

### 2. Supabase Dynamic Content (This Action)
```dart
// Location: FFAppState().translationsCache
// Usage:
getTranslations(languageCode, 'filter_vegetarian', translationsCache)

// Content: Filter names, allergens, dietary preferences, menu items
// Count: Variable, fetched from database
```

**Why Two Systems?**
- Static text: Bundled with app (offline)
- Dynamic content: Updated without app release

---

## Error Handling

### Error 1: Empty Language Code
```
⚠️ getTranslationsWithUpdate: Empty language code provided
```
**Return:** `false`
**FFAppState:** `translationsCache = {}`

### Error 2: API Failure
```
❌ Buildship failed. Status: 500
   URL: https://wvb8ww.buildship.run/languageText?languageCode=da
   Response: {"error": "Internal server error"}
```
**Return:** `false`
**FFAppState:** `translationsCache = {}`

### Error 3: Empty Response
```
⚠️ Buildship returned empty data for da
```
**Return:** `false`
**FFAppState:** `translationsCache = {}`

### Error 4: Exception
```
❌ Error fetching translations: FormatException...
   Stack trace: ...
```
**Return:** `false`
**FFAppState:** `translationsCache = {}`

---

## Debug Output

### Success
```
📡 Fetching translations for: da
✅ Successfully fetched and cached 245 translations for da
```

### Failure
```
📡 Fetching translations for: de
❌ Buildship failed. Status: 404
```

---

## Safe Failure Mode

On any error, sets `translationsCache = {}`:

```dart
FFAppState().update(() {
  FFAppState().translationsCache = <String, dynamic>{};
});
```

**Result:** `getTranslations()` function returns keys as fallback:
```dart
getTranslations('da', 'filter_vegetarian', {}) // Returns: 'filter_vegetarian'
```

---

## Performance Considerations

### No Caching
- Fetches fresh data on every call
- Consider calling only when language changes
- Don't call on every page load

### Recommended Pattern
```dart
// ✅ GOOD - Once per language change
await actions.getTranslationsWithUpdate(newLanguage);

// ❌ BAD - Every page load
@override
void initState() {
  actions.getTranslationsWithUpdate(currentLanguage); // Unnecessary!
}
```

---

## Testing Checklist

- [ ] Fetch English translations → cache populated
- [ ] Fetch Danish translations → cache updated
- [ ] Empty language code → returns false, cache empty
- [ ] API returns 404 → returns false, cache empty
- [ ] API returns malformed JSON → returns false, cache empty
- [ ] Switch languages back and forth → cache updates correctly
- [ ] Use getTranslations() after fetch → returns translated text
- [ ] Offline mode → returns false, cache empty

---

## Migration Notes

### Phase 3 Changes

1. **Add caching to reduce API calls:**
   ```dart
   // Cache in SharedPreferences with timestamp
   final cached = prefs.getString('translations_$languageCode');
   final timestamp = prefs.getInt('translations_timestamp_$languageCode');

   if (cached != null && !_isStale(timestamp)) {
     FFAppState().translationsCache = json.decode(cached);
     return true;
   }
   ```

2. **Replace FFAppState with Riverpod:**
   ```dart
   // Before:
   FFAppState().update(() {
     FFAppState().translationsCache = translationsMap;
   });

   // After:
   ref.read(translationsProvider.notifier).setTranslations(translationsMap);
   ```

3. **Keep dual system** - Both FFLocalizations and dynamic translations needed

---

## Related Actions

| Action | Purpose | Relationship |
|--------|---------|--------------|
| `getFiltersWithUpdate` | Fetch filter data | Separate but related |
| `updateCurrencyForLanguage` | Update currency | Called after language change |
| `saveUserPreference` | Save language | Called after successful fetch |

---

## Used By Pages

1. **Welcome/Onboarding** - Language setup
2. **Settings** - Language selector
3. **App Initialization** - Load saved language

---

## Known Issues

1. **No caching** - Fetches on every call
2. **No retry logic** - Single attempt only
3. **No offline support** - Requires network connection

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Add caching, Riverpod migration
