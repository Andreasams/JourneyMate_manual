# convertDietaryPreferencesToString

**Location:** `_flutterflow_export/lib/flutter_flow/custom_functions.dart` (lines 541-672)

**Type:** Custom formatting function with translation support

**Purpose:** Converts dietary preference IDs to localized, grammatically correct strings with context-appropriate phrasing and intelligent sorting by category (disease-related → religious → diet-based).

---

## Function Signature

```dart
String? convertDietaryPreferencesToString(
  List<int>? dietaryIDs,
  String currentLanguage,
  bool isBeverage,
  dynamic translationsCache,
)
```

---

## Parameters

### `dietaryIDs` (List<int>?)
- **Type:** Nullable list of integers
- **Purpose:** List of dietary preference IDs to convert to text
- **Valid IDs:** 1-7 (see ID mapping below)
- **Null/Empty Handling:** Returns localized empty message

**ID Mapping:**
```
1 = Gluten-free (disease-related)
2 = Pescetarian (diet-based)
3 = Halal (religious)
4 = Lactose-free (disease-related)
5 = Kosher (religious)
6 = Vegan (diet-based)
7 = Vegetarian (diet-based)
```

### `currentLanguage` (String)
- **Type:** Non-null string
- **Purpose:** ISO 639-1 language code for localization
- **Supported Languages:** da, en, de, fr, it, no, sv (15 total in translation system)
- **Examples:** 'en', 'da', 'de'

### `isBeverage` (bool)
- **Type:** Non-null boolean
- **Purpose:** Determines context-specific phrasing
- **Impact:**
  - `true` → Uses beverage-specific phrasing and empty messages
  - `false` → Uses food-specific phrasing and empty messages
- **Translation Keys Affected:**
  - Empty state: `dietary_empty_beverage` vs `dietary_empty_food`
  - Prefix: `dietary_prefix_beverage` vs `dietary_prefix_food`

### `translationsCache` (dynamic)
- **Type:** Dynamic (accepts Map<String, dynamic> or JSON string)
- **Purpose:** Translation cache from FFAppState containing all localized strings
- **Required Keys:**
  - `dietary_1` through `dietary_7` (preference names)
  - `dietary_prefix_food` / `dietary_prefix_beverage` (context phrasing)
  - `dietary_empty_food` / `dietary_empty_beverage` (fallback messages)
  - `dietary_and` (conjunction for list formatting)
- **Source:** FFAppState.translationsCache

---

## Return Value

### Type: `String?`

### Possible Outputs:

**1. Empty State (no preferences provided):**
```dart
// isBeverage = false
"No dietary information available for this dish"

// isBeverage = true
"No dietary information available for this beverage"
```

**2. Single Preference:**
```dart
// Food example (en, isBeverage=false, dietaryIDs=[6])
"This dish is vegan"

// Beverage example (en, isBeverage=true, dietaryIDs=[4])
"This beverage is lactose-free"
```

**3. Two Preferences:**
```dart
// dietaryIDs=[1, 6] → gluten-free and vegan
"This dish is gluten-free and vegan"
```

**4. Three+ Preferences (with sorting):**
```dart
// dietaryIDs=[2, 3, 4] → pescetarian, halal, lactose-free
// Sorted: lactose-free (disease), halal (religious), pescetarian (diet)
"This dish is lactose-free, halal and pescetarian"
```

**5. Invalid IDs Filtered Out:**
```dart
// dietaryIDs=[1, 999, 4] → only 1 and 4 are valid
"This dish is gluten-free and lactose-free"
```

**6. All Invalid IDs:**
```dart
// dietaryIDs=[888, 999]
"No dietary information available for this dish"
```

---

## Dependencies

### Internal Dependencies

**1. `getTranslations()` function**
```dart
String getTranslations(
  String languageCode,
  String translationKey,
  dynamic translationsCache,
)
```
- **Purpose:** Retrieves localized strings from translation cache
- **Usage:** Called via helper function `_getUIText()`
- **Fallback:** Returns empty string with warning prefix ('⚠️') if key not found

### External Dependencies

**1. FFAppState**
- **Field:** `translationsCache`
- **Type:** Map<String, dynamic> or String (JSON)
- **Purpose:** Provides all localized text for dietary preferences

---

## FFAppState Usage

### Read-Only Access

```dart
// Function receives translationsCache as parameter
convertDietaryPreferencesToString(
  [1, 6],              // IDs
  'en',                // Language
  false,               // Is beverage
  FFAppState().translationsCache,  // ← Read from FFAppState
)
```

### Required Translation Keys

**Dietary Preference Names (1-7):**
```dart
'dietary_1'  // "Gluten-free" / "Glutenfri" / "Glutenfrei"
'dietary_2'  // "Pescetarian" / "Pescetar" / "Pescetarier"
'dietary_3'  // "Halal"
'dietary_4'  // "Lactose-free" / "Laktosefri" / "Laktosefrei"
'dietary_5'  // "Kosher"
'dietary_6'  // "Vegan" / "Vegansk" / "Vegan"
'dietary_7'  // "Vegetarian" / "Vegetar" / "Vegetarisch"
```

**Context Phrasing:**
```dart
'dietary_prefix_food'      // "This dish is" / "Denne ret er" / "Dieses Gericht ist"
'dietary_prefix_beverage'  // "This beverage is" / "Denne drik er"
```

**List Formatting:**
```dart
'dietary_and'  // "and" / "og" / "und" / "et"
```

**Empty State Messages:**
```dart
'dietary_empty_food'       // "No dietary information available for this dish"
'dietary_empty_beverage'   // "No dietary information available for this beverage"
```

---

## Core Logic

### Step 1: Validate Input
```dart
// Return empty message if no dietary preferences provided
if (dietaryIDs == null || dietaryIDs.isEmpty) {
  final emptyKey = isBeverage
    ? 'dietary_empty_beverage'
    : 'dietary_empty_food';
  return _getUIText(emptyKey);
}
```

### Step 2: Convert IDs to Localized Names
```dart
final validIDs = <int>[];

for (final id in dietaryIDs) {
  final translationKey = 'dietary_$id';  // e.g., 'dietary_1'
  final dietaryName = getTranslations(
    currentLanguage,
    translationKey,
    translationsCache,
  );

  // Only add if translation exists and is not empty
  if (dietaryName.isNotEmpty && !dietaryName.startsWith('⚠️')) {
    validIDs.add(id);
  }
}
```

### Step 3: Handle All Invalid IDs
```dart
// Return empty message if all IDs were invalid
if (validIDs.isEmpty) {
  final emptyKey = isBeverage
    ? 'dietary_empty_beverage'
    : 'dietary_empty_food';
  return _getUIText(emptyKey);
}
```

### Step 4: Sort by Priority (CRITICAL)
```dart
// Priority order configuration
const sortOrder = [1, 4, 3, 5, 2, 7, 6];

// Sort IDs: disease-related → religious → diet-based
final sortedIDs = _sortByPriority(validIDs);

// Sorting algorithm
List<int> _sortByPriority(List<int> ids) {
  final sortedIds = List<int>.from(ids);
  sortedIds.sort((a, b) {
    final aIndex = sortOrder.indexOf(a);
    final bIndex = sortOrder.indexOf(b);
    // If ID not in sort order, place at end
    final aPriority = aIndex == -1 ? sortOrder.length : aIndex;
    final bPriority = bIndex == -1 ? sortOrder.length : bIndex;
    return aPriority.compareTo(bPriority);
  });
  return sortedIds;
}
```

**Sort Order Rationale:**
1. **Disease-related (1, 4)** — Most critical health information
   - 1 = Gluten-free
   - 4 = Lactose-free
2. **Religious (3, 5)** — Next priority for dietary requirements
   - 3 = Halal
   - 5 = Kosher
3. **Diet-based (2, 7, 6)** — Lifestyle choices
   - 2 = Pescetarian
   - 7 = Vegetarian
   - 6 = Vegan

### Step 5: Convert to Localized Text
```dart
final preferenceTexts = sortedIDs
  .map((id) {
    final translationKey = 'dietary_$id';
    return getTranslations(
      currentLanguage,
      translationKey,
      translationsCache,
    );
  })
  .where((text) => text.isNotEmpty)
  .toList();
```

### Step 6: Format with Grammar
```dart
final prefix = isBeverage
  ? _getUIText('dietary_prefix_beverage')
  : _getUIText('dietary_prefix_food');
final conjunction = _getUIText('dietary_and');
final formattedList = _formatPreferenceList(preferenceTexts, conjunction);

return '$prefix $formattedList';
```

**Grammar Rules:**
```dart
String _formatPreferenceList(List<String> preferences, String conjunction) {
  // Single: "vegan"
  if (preferences.length == 1) return preferences[0];

  // Two: "gluten-free and vegan"
  if (preferences.length == 2) {
    return '${preferences[0]} $conjunction ${preferences[1]}';
  }

  // Three+: "gluten-free, halal, and vegan"
  final allButLast = preferences.sublist(0, preferences.length - 1).join(', ');
  return '$allButLast, $conjunction ${preferences.last}';
}
```

---

## Usage Examples

### Example 1: Single Preference (Food)
```dart
convertDietaryPreferencesToString(
  [6],                           // Vegan
  'en',                          // English
  false,                         // Food
  FFAppState().translationsCache,
);
// Returns: "This dish is vegan"
```

### Example 2: Multiple Preferences with Sorting (Food)
```dart
convertDietaryPreferencesToString(
  [2, 1, 3],                     // Pescetarian, Gluten-free, Halal
  'da',                          // Danish
  false,                         // Food
  FFAppState().translationsCache,
);
// Input order:  [2, 1, 3] (pescetarian, gluten-free, halal)
// Sorted order: [1, 3, 2] (gluten-free, halal, pescetarian)
// Returns: "Denne ret er glutenfri, halal og pescetar"
```

### Example 3: Beverage Context
```dart
convertDietaryPreferencesToString(
  [4, 6],                        // Lactose-free, Vegan
  'de',                          // German
  true,                          // Beverage
  FFAppState().translationsCache,
);
// Returns: "Dieses Getränk ist laktosefrei und vegan"
```

### Example 4: Empty State (No Preferences)
```dart
convertDietaryPreferencesToString(
  [],                            // No preferences
  'en',                          // English
  false,                         // Food
  FFAppState().translationsCache,
);
// Returns: "No dietary information available for this dish"
```

### Example 5: Invalid IDs Filtered
```dart
convertDietaryPreferencesToString(
  [1, 999, 4],                   // Gluten-free, INVALID, Lactose-free
  'en',                          // English
  false,                         // Food
  FFAppState().translationsCache,
);
// IDs 999 is filtered out (no translation)
// Returns: "This dish is gluten-free and lactose-free"
```

### Example 6: All Disease-Related + Religious + Diet
```dart
convertDietaryPreferencesToString(
  [6, 4, 1, 3],                  // Vegan, Lactose-free, Gluten-free, Halal
  'en',                          // English
  false,                         // Food
  FFAppState().translationsCache,
);
// Sorted: [1, 4, 3, 6] (disease → religious → diet)
// Returns: "This dish is gluten-free, lactose-free, halal and vegan"
```

---

## Real-World Usage in Codebase

### 1. Full Menu Page (Dish Detail)
**File:** `_flutterflow_export/lib/pages/full_menu/full_menu_widget.dart`

**Context:** Displaying dietary information in dish bottom sheet

```dart
// Inside MenuDishesListView → Bottom sheet content
Text(
  convertDietaryPreferencesToString(
    getJsonField(dishItem, r'$.dietary_description')
        ?.toList()
        ?.map<int>((e) => e as int)
        .toList(),                      // dietary_description from API
    FFAppState().languageCode,          // Current language
    false,                              // Is food (not beverage)
    FFAppState().translationsCache,     // Translation cache
  ) ?? '',
  style: FlutterFlowTheme.of(context).bodyMedium,
)
```

**API Response Structure:**
```json
{
  "name": "Caesar Salad",
  "dietary_description": [7, 4],  // Vegetarian, Lactose-free
  "allergen_description": [2, 7]
}
```

**Rendered Output:**
```
"This dish is lactose-free and vegetarian"
```

### 2. Business Profile Page (Menu Items)
**File:** `_flutterflow_export/lib/pages/business_profile/business_profile_widget.dart`

**Context:** Showing dietary info in menu item cards

```dart
// Inside business menu section
if (dietaryIds != null && dietaryIds.isNotEmpty)
  Text(
    convertDietaryPreferencesToString(
      dietaryIds,
      FFAppState().languageCode,
      isBeverage,                       // Based on item type
      FFAppState().translationsCache,
    ) ?? '',
    style: FlutterFlowTheme.of(context).labelSmall,
  )
```

---

## Edge Cases and Special Handling

### Edge Case 1: Null Input
```dart
convertDietaryPreferencesToString(null, 'en', false, cache);
// Returns: "No dietary information available for this dish"
```

### Edge Case 2: Empty List
```dart
convertDietaryPreferencesToString([], 'en', false, cache);
// Returns: "No dietary information available for this dish"
```

### Edge Case 3: All Invalid IDs
```dart
convertDietaryPreferencesToString([888, 999], 'en', false, cache);
// All IDs filtered out (no translations)
// Returns: "No dietary information available for this dish"
```

### Edge Case 4: Mixed Valid/Invalid IDs
```dart
convertDietaryPreferencesToString([1, 999, 4, 888], 'en', false, cache);
// Invalid IDs (999, 888) are filtered during conversion
// Valid IDs (1, 4) proceed to formatting
// Returns: "This dish is gluten-free and lactose-free"
```

### Edge Case 5: Single Invalid ID
```dart
convertDietaryPreferencesToString([999], 'en', false, cache);
// ID 999 has no translation → filtered out → empty validIDs list
// Returns: "No dietary information available for this dish"
```

### Edge Case 6: Duplicate IDs
```dart
convertDietaryPreferencesToString([1, 1, 4], 'en', false, cache);
// Duplicates preserved through conversion (no deduplication in function)
// Both '1's get same translation → "gluten-free, gluten-free and lactose-free"
// NOTE: This is unexpected behavior - deduplication should happen at data source
```

### Edge Case 7: Translation Cache Null
```dart
convertDietaryPreferencesToString([1, 4], 'en', false, null);
// getTranslations() returns empty string for null cache
// All IDs filtered out → validIDs.isEmpty
// Returns: "No dietary information available for this dish"
```

### Edge Case 8: Missing Translation Key
```dart
// Translation cache lacks 'dietary_1' key
convertDietaryPreferencesToString([1, 4], 'en', false, cache);
// getTranslations() returns '⚠️' for missing key
// ID 1 filtered out (starts with '⚠️')
// ID 4 proceeds if translation exists
// Returns: "This dish is lactose-free"
```

### Edge Case 9: Language Mismatch
```dart
// Translation cache is in Danish, but request is in English
convertDietaryPreferencesToString([1, 4], 'en', false, danishCache);
// getTranslations('en', 'dietary_1', danishCache) likely returns empty/warning
// Both IDs filtered out
// Returns: "No dietary information available for this dish"
```

### Edge Case 10: Beverage vs Food Context
```dart
// Same IDs, different context
convertDietaryPreferencesToString([6], 'en', false, cache);
// Returns: "This dish is vegan"

convertDietaryPreferencesToString([6], 'en', true, cache);
// Returns: "This beverage is vegan"
```

---

## Difference from convertAllergiesToString

### Functional Differences

| Aspect | convertDietaryPreferencesToString | convertAllergiesToString |
|--------|-----------------------------------|--------------------------|
| **Purpose** | What the dish IS | What the dish CONTAINS |
| **Prefix** | "This dish is..." | "Contains..." |
| **ID Range** | 1-7 (dietary preferences) | 1-14 (allergen types) |
| **Sorting** | By category (disease→religious→diet) | Alphabetically |
| **Phrasing** | Descriptive (is/can be made) | Declarative (contains) |
| **Context** | Positive attributes | Warnings/restrictions |
| **Empty Message** | No dietary information | No allergens listed |

### Code Differences

**1. Translation Keys:**
```dart
// Dietary
'dietary_1', 'dietary_2', ..., 'dietary_7'
'dietary_prefix_food' / 'dietary_prefix_beverage'
'dietary_empty_food' / 'dietary_empty_beverage'
'dietary_and'

// Allergen
'allergen_1', 'allergen_2', ..., 'allergen_14'
'allergen_contains'
'allergen_empty_food' / 'allergen_empty_beverage'
'allergen_and'
```

**2. Sorting Logic:**
```dart
// Dietary: Priority-based sorting
const sortOrder = [1, 4, 3, 5, 2, 7, 6];
final sortedIDs = _sortByPriority(validIDs);

// Allergen: Alphabetical sorting
allergenTexts.sort();
```

**3. Output Format:**
```dart
// Dietary
return '$prefix $formattedList';
// "This dish is gluten-free and vegan"

// Allergen
return '$containsText $formattedList';
// "Contains milk protein, eggs and fish"
```

---

## Testing Checklist

### Basic Functionality
- [ ] Single dietary preference (ID 1-7) returns correct translation
- [ ] Multiple preferences formatted with commas and conjunction
- [ ] Null input returns empty message
- [ ] Empty list returns empty message
- [ ] Invalid IDs are filtered out (no error thrown)
- [ ] All invalid IDs return empty message

### Sorting Logic
- [ ] Disease-related (1, 4) appear first
- [ ] Religious (3, 5) appear second
- [ ] Diet-based (2, 7, 6) appear last
- [ ] Mixed categories sorted correctly: [6,1,3] → [1,3,6]
- [ ] Single category maintains order: [7,2,6] → [2,7,6]

### Localization
- [ ] English translations load correctly
- [ ] Danish translations load correctly
- [ ] German translations load correctly
- [ ] Missing translation key returns empty (filtered out)
- [ ] Translation cache null handled gracefully
- [ ] Language mismatch handled (returns empty message)

### Context Switching
- [ ] Food context uses 'dietary_prefix_food'
- [ ] Beverage context uses 'dietary_prefix_beverage'
- [ ] Food context uses 'dietary_empty_food' for empty state
- [ ] Beverage context uses 'dietary_empty_beverage' for empty state

### Edge Cases
- [ ] Duplicate IDs handled (currently NOT deduplicated - note for data source)
- [ ] Mixed valid/invalid IDs: valid ones proceed
- [ ] IDs outside 1-7 range filtered out
- [ ] Very long preference lists formatted correctly (3+ items)
- [ ] Translation returns '⚠️' prefix → filtered out

### Grammar and Formatting
- [ ] Single item: no conjunction ("vegan")
- [ ] Two items: conjunction only ("gluten-free and vegan")
- [ ] Three+ items: commas + conjunction ("gluten-free, halal and vegan")
- [ ] Conjunction varies by language ('and', 'og', 'und', 'et')

### Integration Points
- [ ] Works with getTranslations() function
- [ ] Accepts FFAppState().translationsCache
- [ ] Accepts FFAppState().languageCode
- [ ] Returns null-safe String? type
- [ ] Output renders correctly in Text widgets
- [ ] Output updates when language changes

### Performance
- [ ] Handles 7 IDs (maximum) efficiently
- [ ] Sorting completes in reasonable time
- [ ] Translation lookups complete quickly
- [ ] No memory leaks with repeated calls

---

## Migration Notes

### Phase 3 Migration Requirements

**1. Keep Exact Logic:**
- Preserve sort order configuration: `[1, 4, 3, 5, 2, 7, 6]`
- Maintain grammar formatting rules (commas, conjunctions)
- Keep validation logic (empty check, invalid ID filtering)

**2. Adapt FlutterFlow Patterns:**

**FFAppState → Provider:**
```dart
// FlutterFlow pattern
FFAppState().translationsCache

// Pure Flutter with Riverpod
final translationsCache = ref.watch(translationsCacheProvider);
```

**getTranslations() Integration:**
```dart
// Function already exists in custom_functions.dart
// Port to lib/shared/translation_helpers.dart
// Maintain exact signature and behavior
```

**3. Translation Keys Required:**
```dart
// Ensure all keys exist in Supabase translations table
'dietary_1' through 'dietary_7'
'dietary_prefix_food', 'dietary_prefix_beverage'
'dietary_empty_food', 'dietary_empty_beverage'
'dietary_and'
```

**4. Testing Strategy:**
- Copy existing unit tests from FlutterFlow project
- Add widget tests for Text rendering
- Test all 7 dietary IDs × all languages
- Test sorting with all category combinations
- Test food vs beverage context switching

**5. Design System Alignment:**
```dart
// Apply v2 design system typography
Text(
  convertDietaryPreferencesToString(...),
  style: TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFF0F0F0F),  // From design system
  ),
)
```

**6. Known Issues to Address:**
- **Duplicate IDs:** Function does not deduplicate. Ensure data source provides unique IDs.
- **ID Validation:** Function silently filters invalid IDs. Consider logging warnings in debug mode.
- **Translation Fallback:** Currently returns empty string. Consider fallback to English or ID number.

**7. Future Enhancements (Post-Migration):**
- Add ID deduplication at function entry
- Add debug logging for filtered IDs
- Add fallback to English translations if current language missing
- Consider caching sorted ID order for performance
- Add analytics tracking for missing translations

---

## Summary

**convertDietaryPreferencesToString** is a critical localization function that transforms dietary preference IDs into user-friendly, grammatically correct strings. Its intelligent sorting by category (disease → religious → diet) ensures the most critical information appears first, while its context awareness (food vs beverage) provides appropriate phrasing.

**Key Strengths:**
- Robust validation (filters invalid IDs gracefully)
- Smart sorting (prioritizes health information)
- Context-aware phrasing (food vs beverage)
- Multi-language support (15 languages)
- Grammatically correct output (proper commas and conjunctions)

**Key Dependencies:**
- getTranslations() function (for localization)
- FFAppState.translationsCache (for translation data)
- Translation keys: dietary_1-7, prefixes, empty messages, conjunctions

**Migration Priority:** HIGH — Used extensively in menu displays, directly impacts user experience for dietary information.
