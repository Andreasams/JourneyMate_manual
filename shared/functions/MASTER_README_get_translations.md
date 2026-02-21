# getTranslations Function

**Type:** Custom Function (Pure)
**File:** `custom_functions.dart` (lines 2161-2235)
**Category:** Localization & Translations
**Status:** ✅ Production Ready

---

## Purpose

Retrieves localized translation strings from the Supabase translations cache. This is part of the **Supabase dynamic content translation system**, separate from FlutterFlow's UI translations.

**Critical:** This function handles **dynamic content** (filter names, dietary preferences, allergen names, menu items) that is **NOT** part of the FlutterFlow `kTranslationsMap`. See "Translation System Architecture" section below.

---

## Function Signature

```dart
String getTranslations(
  String languageCode,
  String translationKey,
  dynamic translationsCache,
)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `languageCode` | `String` | **Yes** | ISO 639-1 language code ('en', 'da', 'de', 'it', 'sv', 'no', 'fr') |
| `translationKey` | `String` | **Yes** | The key to look up (e.g., 'filter_location', 'dietary_vegan') |
| `translationsCache` | `dynamic` | **Yes** | Cache object from FFAppState or Supabase response |

### Returns

| Type | Description |
|------|-------------|
| `String` | The translated string, or fallback value if not found |

---

## Dependencies

### pub.dev Packages
- None (pure Dart function)

### Internal Dependencies
```dart
import 'dart:convert'; // For JSON parsing
```

### No External Dependencies
This is a pure function with no side effects.

---

## Translation System Architecture

⚠️ **CRITICAL:** JourneyMate uses **TWO separate translation systems**. Understanding this is essential for proper implementation.

### System 1: FlutterFlow UI Text (Static)
**Purpose:** Static UI labels, buttons, page titles
**Location:** `lib/flutter_flow/internationalization.dart`
**Total Strings:** 191
**Usage:** `FFLocalizations.of(context).getText('key')`

**Examples:**
- "Search" / "Søg" / "Suche"
- "Menu" / "Menu" / "Menü"
- "Opening hours" / "Åbningstider" / "Öffnungszeiten"

### System 2: Supabase Dynamic Content (THIS FUNCTION)
**Purpose:** Business data, menu items, filter names
**Location:** Supabase database + custom translation cache
**Storage:** `FFAppState().translationsCache`
**Usage:** `functions.getTranslations(languageCode, key, translationsCache)`

**Examples:**
- Filter names: "filter_location", "filter_outdoor_seating"
- Dietary preferences: "dietary_vegan", "dietary_vegetarian"
- Allergen names: "allergen_gluten", "allergen_nuts"
- Menu item descriptions
- Business type names

**Why Separate?**
- Dynamic content changes frequently (filters, menu items)
- Requires database updates without app redeployment
- Translations managed in Supabase, not hardcoded

---

## FFAppState Usage

### Read Properties
```dart
FFAppState().translationsCache  // Main translations cache (dynamic JSON)
```

**Cache Structure:**
```dart
{
  "filter_location": "Location",
  "filter_outdoor_seating": "Outdoor seating",
  "dietary_vegan": "Vegan",
  "dietary_vegetarian": "Vegetarian",
  "allergen_gluten": "Gluten",
  "allergen_nuts": "Nuts",
  // ... hundreds more keys
}
```

**Cache Loading:**
The cache is loaded by custom actions:
- `getTranslationsWithUpdate` - Fetches latest translations from Supabase
- `getFiltersWithUpdate` - Fetches filter translations specifically

**Cache Lifecycle:**
- Loaded on app start (Welcome page)
- Refreshed when language changes
- Persists in FFAppState for session duration

---

## Usage Examples

### Example 1: Get Filter Name
```dart
final filterName = functions.getTranslations(
  FFLocalizations.of(context).languageCode,
  'filter_outdoor_seating',
  FFAppState().translationsCache,
);
// Returns: "Outdoor seating" (en) or "Udendørs sidepladser" (da)
```

### Example 2: Get Dietary Preference
```dart
final dietaryName = functions.getTranslations(
  FFLocalizations.of(context).languageCode,
  'dietary_vegan',
  FFAppState().translationsCache,
);
// Returns: "Vegan" (en) or "Vegansk" (da)
```

### Example 3: Get Allergen Name
```dart
final allergenName = functions.getTranslations(
  'da',  // Danish
  'allergen_gluten',
  FFAppState().translationsCache,
);
// Returns: "Gluten" (same in most languages)
```

### Example 4: Dynamic Loop Through Filters
```dart
for (final filterKey in selectedFilters) {
  final displayName = functions.getTranslations(
    FFLocalizations.of(context).languageCode,
    filterKey,
    FFAppState().translationsCache,
  );

  // Display chip with displayName
  FilterChip(label: Text(displayName));
}
```

---

## Error Handling & Fallbacks

### Error 1: Empty Language Code
```
⚠️ getTranslations: Empty language code
```
**Return:** `translationKey` (original key as fallback)

### Error 2: Empty Translation Key
```
⚠️ getTranslations: Empty translation key
```
**Return:** `''` (empty string)

### Error 3: Null Cache
```
⚠️ Translation cache is null for key: filter_location
```
**Return:** `''` (empty string)

### Error 4: Translation Missing
```
Translation missing: da.filter_location
   Cache contains 245 keys
   Sample keys: [filter_outdoor_seating, dietary_vegan, ...]
```
**Return:** `''` (empty string)

### Error 5: Cache Parsing Error
```
❌ Error retrieving translation:
   Language: da
   Key: filter_location
   Error: FormatException: Unexpected character
```
**Fallback:** Converts snake_case to Title Case
- `filter_location` → `"Filter Location"`
- `dietary_vegan` → `"Dietary Vegan"`

---

## Cache Structure Handling

The function handles multiple cache formats:

### Format 1: JSON String
```dart
translationsCache = '{"filter_location":"Location","dietary_vegan":"Vegan"}'
```
**Handling:** `json.decode()` to Map

### Format 2: Map<String, dynamic>
```dart
translationsCache = {
  "filter_location": "Location",
  "dietary_vegan": "Vegan",
}
```
**Handling:** Direct access

### Format 3: Unexpected Type
```
⚠️ Unexpected cache type: _InternalLinkedHashMap<String, Object>
   Key: filter_location
```
**Return:** `''` (empty string)

---

## Translation Key Naming Conventions

### Filter Keys
```
filter_{category}_{name}
```
**Examples:**
- `filter_location` - Location filter
- `filter_outdoor_seating` - Outdoor seating filter
- `filter_wheelchair_accessible` - Accessibility filter

### Dietary Preference Keys
```
dietary_{name}
```
**Examples:**
- `dietary_vegan` - Vegan option
- `dietary_vegetarian` - Vegetarian option
- `dietary_gluten_free` - Gluten-free option

### Allergen Keys
```
allergen_{name}
```
**Examples:**
- `allergen_gluten` - Gluten allergen
- `allergen_nuts` - Nut allergen
- `allergen_dairy` - Dairy allergen

### Menu Item Keys
```
menu_{business_id}_{item_id}_{field}
```
**Examples:**
- `menu_123_456_name` - Menu item name
- `menu_123_456_description` - Menu item description

---

## Common Translation Keys

| Key | English | Danish | German |
|-----|---------|--------|--------|
| `filter_location` | Location | Lokation | Standort |
| `filter_outdoor_seating` | Outdoor seating | Udendørs sidepladser | Außensitzplätze |
| `filter_wheelchair_accessible` | Wheelchair accessible | Kørestolsvenlig | Rollstuhlgerecht |
| `dietary_vegan` | Vegan | Vegansk | Vegan |
| `dietary_vegetarian` | Vegetarian | Vegetar | Vegetarisch |
| `allergen_gluten` | Gluten | Gluten | Gluten |
| `allergen_nuts` | Nuts | Nødder | Nüsse |
| `allergen_dairy` | Dairy | Mælkeprodukter | Milchprodukte |

---

## Performance Considerations

### Pure Function
`getTranslations()` is a **pure function**:
- No side effects
- No state modifications
- Deterministic output for same inputs
- Safe to call multiple times

### Cache Lookup Performance
- **O(1)** lookup time (HashMap access)
- No network calls (cache pre-loaded)
- No database queries
- Instant translation retrieval

### Optimization Opportunities

**Current:** Cache is JSON parsed on every call if string
```dart
if (translationsCache is String) {
  translationsMap = json.decode(translationsCache); // Parses every time!
}
```

**Optimization:** Parse cache once and store as Map in FFAppState
```dart
// In getTranslationsWithUpdate action:
final parsedCache = json.decode(response.body);
FFAppState().translationsCache = parsedCache; // Store as Map, not String
```

---

## Used By Custom Widgets

| Widget | Usage | Keys Used |
|--------|-------|-----------|
| `FilterOverlayWidget` | Display filter names | `filter_*` keys |
| `SelectedFiltersBtns` | Display selected filter chips | `filter_*` keys |
| `FilterTitlesRow` | Display filter category titles | `filter_*` keys |
| `AllergiesFilterWidget` | Display allergen names | `allergen_*` keys |
| `DietaryRestrictionsFilterWidget` | Display dietary names | `dietary_*` keys |
| `MenuDishesListView` | Display menu item names | `menu_*` keys |
| `BusinessFeatureButtons` | Display feature labels | `feature_*` keys |

---

## Used By Custom Functions

| Function | Usage | Purpose |
|----------|-------|---------|
| `getFilterTitles` | Calls getTranslations | Get localized filter titles with counts |
| `getDietaryAndAllergyTitleTranslations` | Calls getTranslations | Get section headers for menu filters |
| `openClosesAt` | Calls getTranslations | Get "til", "opens at" translations |

---

## Testing Checklist

When implementing in Flutter:

- [ ] Load translations cache on app start
- [ ] Test with valid language code ('en', 'da', 'de')
- [ ] Test with valid translation key from cache
- [ ] Test with missing translation key - verify empty string returned
- [ ] Test with null cache - verify empty string returned
- [ ] Test with empty language code - verify key returned as fallback
- [ ] Test with empty translation key - verify empty string returned
- [ ] Test cache as JSON string - verify parsing works
- [ ] Test cache as Map - verify direct access works
- [ ] Test snake_case fallback - verify Title Case conversion
- [ ] Change language - verify cache updates and translations change
- [ ] Test with 100+ translation lookups - verify performance
- [ ] Verify no side effects (call same key multiple times)

---

## Migration Notes

### Phase 3 Changes

1. **Keep Supabase system** - don't migrate to .arb files (this is for dynamic content)
2. **Maintain cache structure** - keep FFAppState.translationsCache
3. **Keep function signature** - no changes needed
4. **Update state management**:
   ```dart
   // Before:
   FFAppState().translationsCache

   // After (Riverpod example):
   ref.watch(translationsCacheProvider)
   ```

5. **Optimize cache parsing**:
   - Parse JSON once when fetched
   - Store as Map<String, dynamic>, not String
   - Eliminates repeated json.decode() calls

### Integration with FlutterFlow Translation Migration

When migrating FlutterFlow translations to .arb files, **keep this Supabase system separate**:

```dart
// FlutterFlow UI translations (static):
AppLocalizations.of(context)!.searchPageTitle

// Supabase translations (dynamic):
functions.getTranslations(
  Localizations.localeOf(context).languageCode,
  'filter_location',
  ref.watch(translationsCacheProvider),
)
```

### Translation Cache Initialization

Ensure translations are loaded before using this function:

```dart
// In Welcome page or main():
await actions.getTranslationsWithUpdate(
  FFLocalizations.of(context).languageCode,
);
// Now FFAppState().translationsCache is populated
```

---

## Related Actions

| Action | Purpose | Relationship |
|--------|---------|--------------|
| `getTranslationsWithUpdate` | Fetch latest translations from Supabase | Populates cache used by this function |
| `getFiltersWithUpdate` | Fetch filter-specific translations | Alternative cache loader |

---

## Related Functions

| Function | Purpose | Relationship |
|----------|---------|--------------|
| `getFilterTitles` | Get localized filter titles | Calls this function repeatedly |
| `getDietaryAndAllergyTitleTranslations` | Get menu section headers | Calls this function for headers |
| `openClosesAt` | Get timing text | Uses this for "til", "opens at" translations |

---

## Known Issues

1. **No cache invalidation** - Cache persists for session, even if Supabase data changes
2. **No fallback language** - Missing translation returns empty string, not English fallback
3. **No offline support** - Cache cleared on app restart, requires network
4. **Repeated JSON parsing** - If cache is String, parses on every call (see Performance section)

---

## Security Notes

✅ **Safe:**
- No user input accepted
- No network calls
- No database access
- Pure function with no side effects

---

## Debug Output Examples

### Success
```
// No output (silent on success)
```

### Missing Translation
```
Translation missing: da.filter_new_feature
   Cache contains 245 keys
   Sample keys: [filter_location, dietary_vegan, allergen_gluten, filter_outdoor_seating, dietary_vegetarian]
```

### Null Cache
```
⚠️ Translation cache is null for key: filter_location
```

### Error with Fallback
```
❌ Error retrieving translation:
   Language: da
   Key: filter_location
   Error: FormatException: Unexpected end of input
```
**Returns:** `"Filter Location"` (Title Case conversion)

---

## Future Enhancements

1. **Add English fallback** instead of empty string
2. **Cache validation** on load (verify structure)
3. **Type-safe cache** with proper Dart class
4. **Offline persistence** with SharedPreferences
5. **Cache versioning** for incremental updates
6. **Translation metrics** (track missing keys)

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Keep as-is (Supabase dynamic system)

**Translation Analysis Reference:** See `TRANSLATION_ANALYSIS.md` for complete translation system overview.
