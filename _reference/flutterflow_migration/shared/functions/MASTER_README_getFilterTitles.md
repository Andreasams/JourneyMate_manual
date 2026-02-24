# getFilterTitles Function

**Type:** Custom Function (Pure)
**File:** `custom_functions.dart` (lines 394-446)
**Category:** Filter UI & Localization
**Status:** ✅ Production Ready

---

## Purpose

Returns localized filter titles with optional selection count appended in parentheses. Used on the search_results page to display filter category titles like "Type (3)" or "Preferences" when no items are selected.

**Key Features:**
- Localized filter category names
- Dynamic selection count display
- Graceful fallback for missing translations
- Debug logging for troubleshooting

---

## Function Signature

```dart
String getFilterTitles(
  int? selectedCount,
  int filterId,
  String languageCode,
  dynamic translationsCache,
)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `selectedCount` | `int?` | No | Number of active selections (null or 0 = no count shown) |
| `filterId` | `int` | **Yes** | Filter category identifier (1=Location, 2=Type, 3=Preferences) |
| `languageCode` | `String` | **Yes** | ISO language code for localization |
| `translationsCache` | `dynamic` | **Yes** | Translation cache from FFAppState |

### Returns

| Type | Description |
|------|-------------|
| `String` | Localized filter title, optionally with count (e.g., "Type (3)") |

---

## Filter ID Mapping

```dart
const filterKeyMap = {
  1: 'filter_location',     // Location filters
  2: 'filter_type',         // Business type filters
  3: 'filter_preferences',  // Dietary preferences & allergens
};
```

### Filter Categories

| ID | Translation Key | English | Danish | Purpose |
|----|----------------|---------|--------|---------|
| 1 | `filter_location` | "Location" | "Lokation" | Distance, neighborhood filters |
| 2 | `filter_type` | "Type" | "Type" | Restaurant, cafe, bar, etc. |
| 3 | `filter_preferences` | "Preferences" | "Præferencer" | Dietary & allergen filters |

---

## Implementation

```dart
String getFilterTitles(
  int? selectedCount,
  int filterId,
  String languageCode,
  dynamic translationsCache,
) {
  // Map filter IDs to translation keys
  const filterKeyMap = {
    1: 'filter_location',
    2: 'filter_type',
    3: 'filter_preferences',
  };

  // Get translation key for this filter ID
  final translationKey = filterKeyMap[filterId];

  // Guard: Invalid filter ID
  if (translationKey == null) {
    debugPrint('⚠️ Invalid filter ID: $filterId');
    return '';
  }

  // Get localized title using the getTranslation helper
  final baseTitle = getTranslations(
    languageCode,
    translationKey,
    translationsCache,
  );

  // Guard: Missing translation
  if (baseTitle == null || baseTitle.isEmpty || baseTitle.startsWith('⚠️')) {
    debugPrint('⚠️ Translation missing for filter: $translationKey');
    return '';
  }

  // Append selection count if present and non-zero
  final hasActiveSelections = selectedCount != null && selectedCount > 0;
  return hasActiveSelections ? '$baseTitle ($selectedCount)' : baseTitle;
}
```

---

## Dependencies

### pub.dev Packages
- None (pure Dart function)

### Internal Dependencies
```dart
import 'custom_functions.dart';  // Calls getTranslations()
```

---

## Usage Examples

### Example 1: Filter with No Selections
```dart
final title = functions.getFilterTitles(
  null,           // No selections
  2,              // Type filter
  'en',
  FFAppState().translationsCache,
);
// Returns: "Type"
```

---

### Example 2: Filter with Selections
```dart
final title = functions.getFilterTitles(
  3,              // 3 items selected
  2,              // Type filter
  'da',
  FFAppState().translationsCache,
);
// Returns: "Type (3)"
```

---

### Example 3: Zero Selections (Explicit)
```dart
final title = functions.getFilterTitles(
  0,              // Zero selections (same as null)
  1,              // Location filter
  'en',
  FFAppState().translationsCache,
);
// Returns: "Location" (no count shown)
```

---

### Example 4: All Three Filters
```dart
// Build filter tab headers:
final filters = [
  {
    'id': 1,
    'title': functions.getFilterTitles(2, 1, 'en', cache),  // "Location (2)"
  },
  {
    'id': 2,
    'title': functions.getFilterTitles(null, 2, 'en', cache),  // "Type"
  },
  {
    'id': 3,
    'title': functions.getFilterTitles(5, 3, 'en', cache),  // "Preferences (5)"
  },
];
```

---

### Example 5: Dynamic Count Updates
```dart
// In stateful widget:
int locationFilterCount = FFAppState().selectedLocationFilters.length;

Text(
  functions.getFilterTitles(
    locationFilterCount > 0 ? locationFilterCount : null,
    1,
    FFLocalizations.of(context).languageCode,
    FFAppState().translationsCache,
  ),
  style: TextStyle(fontSize: 16),
)
```

---

## Used By Pages

| Page | Usage | Purpose |
|------|-------|---------|
| **Search Results** | Display filter tab titles | Three-column filter header |

---

## Used By Custom Widgets

| Widget | Usage | Purpose |
|--------|-------|---------|
| `FilterTitlesRow` | Display three filter column headers | "Location (2) | Type | Preferences (5)" |
| `FilterOverlayWidget` | Display filter category names | Section headers in filter sheet |

---

## Edge Cases Handled

### Edge Case 1: Invalid Filter ID
**Input:**
```dart
getFilterTitles(null, 999, 'en', cache)
```

**Behavior:**
```
⚠️ Invalid filter ID: 999
```
**Returns:** `""` (empty string)

---

### Edge Case 2: Missing Translation
**Input:**
```dart
getFilterTitles(null, 1, 'en', emptyCache)
```

**Behavior:**
```
⚠️ Translation missing for filter: filter_location
```
**Returns:** `""` (empty string)

---

### Edge Case 3: Null Selected Count
**Input:**
```dart
getFilterTitles(null, 2, 'da', cache)
```

**Returns:** `"Type"` (no count appended)

---

### Edge Case 4: Zero Selected Count
**Input:**
```dart
getFilterTitles(0, 2, 'da', cache)
```

**Returns:** `"Type"` (treated same as null - no count)

---

### Edge Case 5: Large Selection Count
**Input:**
```dart
getFilterTitles(127, 3, 'en', cache)
```

**Returns:** `"Preferences (127)"` (no maximum limit)

---

### Edge Case 6: Negative Count (Invalid)
**Input:**
```dart
getFilterTitles(-5, 1, 'en', cache)
```

**Returns:** `"Location"` (negative treated as no selections)

**Logic:** `selectedCount != null && selectedCount > 0`

---

## UI Display Patterns

### Three-Column Filter Header

```dart
Row(
  children: [
    Expanded(
      flex: 36,
      child: Text(
        functions.getFilterTitles(
          locationCount,
          1,
          languageCode,
          translationsCache,
        ),
      ),
    ),
    Expanded(
      flex: 33,
      child: Text(
        functions.getFilterTitles(
          typeCount,
          2,
          languageCode,
          translationsCache,
        ),
      ),
    ),
    Expanded(
      flex: 31,
      child: Text(
        functions.getFilterTitles(
          preferencesCount,
          3,
          languageCode,
          translationsCache,
        ),
      ),
    ),
  ],
)
```

**Output:**
```
Location (2)  |  Type  |  Preferences (5)
```

---

### Filter Overlay Section Headers

```dart
// In filter bottom sheet:
for (var filterId in [1, 2, 3]) {
  final count = _getFilterCount(filterId);

  Text(
    functions.getFilterTitles(
      count,
      filterId,
      languageCode,
      translationsCache,
    ),
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  );

  // Display filter options...
}
```

---

## Performance Considerations

### Time Complexity
- **O(1)** - Hash map lookup + string concatenation

### Memory Usage
- **O(1)** - No dynamic allocations

### Execution Time
- **< 5 microseconds** - Very fast

### Optimization Notes
- Already optimal
- No caching needed (translation cache handled by getTranslations)
- Safe to call in build() method

---

## Translation Examples

| Language | filter_location | filter_type | filter_preferences |
|----------|----------------|-------------|-------------------|
| English | Location | Type | Preferences |
| Danish | Lokation | Type | Præferencer |
| German | Standort | Typ | Präferenzen |
| French | Emplacement | Type | Préférences |
| Italian | Posizione | Tipo | Preferenze |
| Swedish | Plats | Typ | Preferenser |
| Norwegian | Plassering | Type | Preferanser |

---

## Testing Checklist

When implementing in Flutter:

- [ ] Test filter 1 (Location) - correct translation
- [ ] Test filter 2 (Type) - correct translation
- [ ] Test filter 3 (Preferences) - correct translation
- [ ] Test invalid filter ID (999) - returns empty string
- [ ] Test null selectedCount - no count shown
- [ ] Test zero selectedCount - no count shown
- [ ] Test positive selectedCount - count shown in parentheses
- [ ] Test large count (100+) - displays correctly
- [ ] Test negative count - treated as no selections
- [ ] Test missing translation - returns empty string
- [ ] Test all supported languages - correct translations
- [ ] Test dynamic updates - count updates correctly
- [ ] Verify debug logging - invalid IDs logged
- [ ] Verify debug logging - missing translations logged

---

## Migration Notes

### Phase 3 Changes

**Keep function as-is** - pure Dart with no FlutterFlow dependencies.

**Update calling code:**
```dart
// Before (FlutterFlow):
functions.getFilterTitles(
  selectedCount,
  filterId,
  FFLocalizations.of(context).languageCode,
  FFAppState().translationsCache,
)

// After (Riverpod example):
functions.getFilterTitles(
  ref.watch(filterCountProvider(filterId)),
  filterId,
  Localizations.localeOf(context).languageCode,
  ref.watch(translationsCacheProvider),
)
```

---

## Related Functions

| Function | Relationship |
|----------|-------------|
| `getTranslations` | Called internally for localized titles |
| `generateFilterSummary` | Generates full filter summary text |

---

## Related Custom Widgets

| Widget | Relationship |
|--------|-------------|
| `FilterTitlesRow` | Primary consumer - displays three filter titles |
| `FilterOverlayWidget` | Uses for section headers |

---

## Known Issues

1. **Hard-coded filter IDs** - IDs 1, 2, 3 are hard-coded, not from database
2. **No validation for count range** - Accepts any integer including negatives
3. **Returns empty string on error** - Could return fallback text instead
4. **No plural handling** - "(1)" shown instead of "(1 item)" vs "(2 items)"

**Severity:** Low - acceptable for current UI requirements

---

## Future Enhancements

1. **Add plural support** - "(1 item)" vs "(2 items)"
2. **Add fallback text** - Return "Filter" instead of empty string on error
3. **Support custom filter IDs** - Load from database instead of hard-coded
4. **Add filter descriptions** - Tooltip text explaining each filter
5. **Add accessibility labels** - Screen reader support

---

**Last Updated:** 2026-02-19
**Migration Status:** ✅ Phase 3 - Keep as-is (production-ready)
**Priority:** ⭐⭐⭐⭐ High (used on search results filter UI)
