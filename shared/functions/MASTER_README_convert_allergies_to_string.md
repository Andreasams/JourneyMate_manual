# convertAllergiesToString Function Documentation

**Package:** `lib/flutter_flow/custom_functions.dart`
**Category:** String Formatting / Localization
**Phase 3 Status:** Ready for migration
**Last Updated:** 2026-02-19

---

## Purpose

Converts a list of allergen IDs into a localized, grammatically correct string that displays allergen information to users. The function:

- Translates numeric allergen IDs (1-14) into human-readable allergen names
- Formats the list with proper grammar (commas and conjunctions)
- Prefixes the list with a localized "Contains" label
- Provides context-appropriate fallback messages for empty lists
- Supports food/beverage-specific empty state messages
- Sorts allergens alphabetically for consistent display
- Handles multi-language support via the translation system

This function is used extensively in:
- Menu item detail sheets
- Restaurant profile pages
- Menu item cards
- Filter descriptions
- Dietary information displays

---

## Function Signature

```dart
String? convertAllergiesToString(
  List<int>? allergyIDs,
  String currentLanguage,
  bool isBeverage,
  dynamic translationsCache,
)
```

**Returns:** `String?`
- Formatted allergen string if allergens exist
- Empty state message if no allergens provided
- `null` if critical error occurs (rare)

---

## Parameters

### allergyIDs
- **Type:** `List<int>?`
- **Description:** List of allergen identifiers to convert
- **Valid IDs:** 1-14 (maps to EU allergen categories)
- **Can be:** `null`, empty list `[]`, or list with IDs

**Allergen ID Mapping:**
```
1  → Cereals containing gluten
2  → Crustaceans
3  → Eggs
4  → Fish
5  → Peanuts
6  → Soybeans
7  → Milk (including lactose)
8  → Nuts (tree nuts)
9  → Celery
10 → Mustard
11 → Sesame seeds
12 → Sulphur dioxide and sulphites
13 → Lupin
14 → Molluscs
```

### currentLanguage
- **Type:** `String`
- **Description:** ISO 639-1 language code for localization
- **Valid Values:** 'en', 'da', 'de', 'fr', 'it', 'no', 'sv', etc.
- **Example:** `'da'` → Returns Danish allergen names

### isBeverage
- **Type:** `bool`
- **Description:** Context flag for empty state messaging
- **Usage:**
  - `true` → Uses beverage-specific empty message
  - `false` → Uses food-specific empty message
- **Why:** Different messages needed for "This beer contains no allergens" vs "This dish contains no allergens"

### translationsCache
- **Type:** `dynamic`
- **Description:** Translation cache object from `FFAppState`
- **Structure:** Map containing all translation strings
- **Source:** Loaded at app startup from Supabase
- **Access Pattern:** `FFAppState().translationsCache`

---

## Return Value

### When allergens exist
Returns formatted string: `"Contains [allergen1], [allergen2] and [allergen3]"`

**Examples:**
```dart
// Single allergen
"Contains milk protein"

// Two allergens
"Contains milk protein and eggs"

// Three allergens
"Contains milk protein, eggs and fish"

// Many allergens (sorted alphabetically)
"Contains celery, eggs, fish, milk protein and peanuts"
```

### When allergens list is null or empty
Returns context-appropriate message based on `isBeverage` flag:

**Food items:**
```dart
// Translation key: 'allergen_empty_food'
"No allergens listed for this dish"  // English
"Ingen allergener angivet for denne ret"  // Danish
```

**Beverage items:**
```dart
// Translation key: 'allergen_empty_beverage'
"No allergens listed for this beverage"  // English
"Ingen allergener angivet for denne drik"  // Danish
```

### Edge cases
- **Invalid IDs:** Silently filtered out (e.g., ID 99 would be ignored)
- **All invalid IDs:** Returns empty state message
- **Null cache:** Returns empty string (logged warning)
- **Missing translations:** Allergen skipped (logged warning)

---

## Dependencies

### Internal Functions
```dart
// Translation lookup (from custom_functions.dart)
String getTranslations(
  String languageCode,
  String translationKey,
  dynamic translationsCache,
)
```

### External Packages
```dart
import 'package:flutter/material.dart';  // For debugPrint
```

### Translation Keys Used

**UI Text:**
```dart
'allergen_contains'          // "Contains" prefix
'allergen_and'               // Conjunction word (e.g., "and", "og", "und")
'allergen_empty_food'        // Empty state for food
'allergen_empty_beverage'    // Empty state for beverages
```

**Allergen Names (1-14):**
```dart
'allergen_1'   // Cereals containing gluten
'allergen_2'   // Crustaceans
'allergen_3'   // Eggs
'allergen_4'   // Fish
'allergen_5'   // Peanuts
'allergen_6'   // Soybeans
'allergen_7'   // Milk
'allergen_8'   // Nuts (tree nuts)
'allergen_9'   // Celery
'allergen_10'  // Mustard
'allergen_11'  // Sesame seeds
'allergen_12'  // Sulphur dioxide/sulphites
'allergen_13'  // Lupin
'allergen_14'  // Molluscs
```

**Translation Structure Example (English):**
```json
{
  "allergen_contains": "Contains",
  "allergen_and": " and ",
  "allergen_empty_food": "No allergens listed for this dish",
  "allergen_empty_beverage": "No allergens listed for this beverage",
  "allergen_1": "cereals containing gluten",
  "allergen_2": "crustaceans",
  "allergen_3": "eggs",
  "allergen_4": "fish",
  "allergen_5": "peanuts",
  "allergen_6": "soybeans",
  "allergen_7": "milk protein",
  "allergen_8": "tree nuts",
  "allergen_9": "celery",
  "allergen_10": "mustard",
  "allergen_11": "sesame seeds",
  "allergen_12": "sulphur dioxide and sulphites",
  "allergen_13": "lupin",
  "allergen_14": "molluscs"
}
```

---

## FFAppState Usage

### Reading Translation Cache
```dart
// At function call site
final allergenText = convertAllergiesToString(
  dishData['allergens'] as List<int>?,
  FFAppState().languageCode,
  dishData['is_beverage'] ?? false,
  FFAppState().translationsCache,  // ← Pass entire cache
);
```

### Cache Structure
```dart
// FFAppState schema
class FFAppState {
  // Language settings
  String languageCode = 'da';  // Current UI language

  // Translation cache (loaded at startup)
  dynamic translationsCache;  // Map<String, dynamic>

  // Cache is populated by:
  // 1. Supabase query on app init
  // 2. Structured as { 'key': 'translated_value' }
  // 3. Updated when language changes
}
```

### Translation Loading Flow
```
1. App launches → main.dart
2. FFAppState initialized
3. getCurrentUserLanguage() checks saved preference
4. loadTranslations() queries Supabase for that language
5. translationsCache populated with all strings
6. convertAllergiesToString() can now access translations
```

---

## Usage Examples

### Example 1: Menu Item Detail Sheet
```dart
// In DishBottomSheet widget
Widget build(BuildContext context) {
  final dishData = widget.dishData;

  // Get allergen display string
  final allergenText = convertAllergiesToString(
    dishData['allergens'] as List<int>?,
    FFAppState().languageCode,
    dishData['is_beverage'] ?? false,
    FFAppState().translationsCache,
  );

  return Container(
    child: Column(
      children: [
        // ... other dish details ...

        // Allergen section
        if (allergenText != null && allergenText.isNotEmpty)
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              allergenText,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
      ],
    ),
  );
}
```

**Input:**
```dart
allergyIDs: [7, 3, 4]
currentLanguage: 'en'
isBeverage: false
```

**Output:**
```
"Contains eggs, fish and milk protein"
```

---

### Example 2: Restaurant Profile Page
```dart
// In BusinessProfilePage
class BusinessProfilePage extends StatefulWidget {
  final Map<String, dynamic> restaurantData;

  @override
  Widget build(BuildContext context) {
    // Get common allergens for this restaurant
    final commonAllergens = restaurantData['common_allergens'] as List<int>?;

    final allergenSummary = convertAllergiesToString(
      commonAllergens,
      FFAppState().languageCode,
      false,  // Restaurant context, not beverage-specific
      FFAppState().translationsCache,
    );

    return Scaffold(
      body: Column(
        children: [
          // ... restaurant info ...

          if (allergenSummary != null && allergenSummary.isNotEmpty)
            Card(
              child: ListTile(
                leading: Icon(Icons.warning_amber),
                title: Text('Common Allergens'),
                subtitle: Text(allergenSummary),
              ),
            ),
        ],
      ),
    );
  }
}
```

**Input:**
```dart
allergyIDs: [1, 2, 5, 7, 8]
currentLanguage: 'da'
isBeverage: false
```

**Output:**
```
"Indeholder fisk, gluten, mælkeprotein, nødder og peanuts"
```

---

### Example 3: Beverage Menu Item
```dart
// In BeverageCard widget
Widget build(BuildContext context) {
  final bevData = widget.beverageData;

  final allergenInfo = convertAllergiesToString(
    bevData['allergens'] as List<int>?,
    FFAppState().languageCode,
    true,  // ← isBeverage = true
    FFAppState().translationsCache,
  );

  return Card(
    child: Column(
      children: [
        Text(bevData['name']),
        Text(bevData['description']),

        // Allergen info for beverage
        if (allergenInfo != null)
          Text(
            allergenInfo,
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    ),
  );
}
```

**Input (no allergens):**
```dart
allergyIDs: null
currentLanguage: 'de'
isBeverage: true  // ← Beverage context
```

**Output:**
```
"Keine Allergene für dieses Getränk aufgeführt"
```

---

### Example 4: Filter Description
```dart
// In FilterSummaryWidget
class FilterSummaryWidget extends StatelessWidget {
  final List<int> excludedAllergens;

  @override
  Widget build(BuildContext context) {
    if (excludedAllergens.isEmpty) {
      return SizedBox.shrink();
    }

    // Show which allergens user is filtering OUT
    final allergenList = convertAllergiesToString(
      excludedAllergens,
      FFAppState().languageCode,
      false,
      FFAppState().translationsCache,
    );

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Hiding items with: ${allergenList?.replaceFirst("Contains ", "") ?? ""}',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
```

**Input:**
```dart
allergyIDs: [5, 8]
currentLanguage: 'en'
isBeverage: false
```

**Output:**
```
"Hiding items with: peanuts and tree nuts"
```

---

## Edge Cases

### Empty or Null Input
```dart
// Test case 1: Null list
convertAllergiesToString(null, 'en', false, cache)
// Returns: "No allergens listed for this dish"

// Test case 2: Empty list
convertAllergiesToString([], 'en', true, cache)
// Returns: "No allergens listed for this beverage"
```

### Invalid Allergen IDs
```dart
// Test case: Mix of valid and invalid IDs
convertAllergiesToString([3, 99, 7, -1, 0], 'en', false, cache)
// Returns: "Contains eggs and milk protein"
// (IDs 99, -1, 0 are ignored)
```

### All Invalid IDs
```dart
// Test case: All IDs invalid
convertAllergiesToString([99, 100, 200], 'en', false, cache)
// Returns: "No allergens listed for this dish"
```

### Single Allergen
```dart
// Test case: One allergen
convertAllergiesToString([7], 'en', false, cache)
// Returns: "Contains milk protein"
// (No comma or conjunction needed)
```

### Two Allergens
```dart
// Test case: Two allergens
convertAllergiesToString([3, 7], 'da', false, cache)
// Returns: "Indeholder æg og mælkeprotein"
// (Conjunction only, no comma)
```

### Many Allergens (Alphabetical Sorting)
```dart
// Test case: Multiple allergens (unsorted input)
convertAllergiesToString([7, 3, 5, 8, 4], 'en', false, cache)
// Returns: "Contains eggs, fish, milk protein, peanuts and tree nuts"
// (Sorted alphabetically for consistency)
```

### Language-Specific Conjunction Handling
```dart
// English: " and " (with spaces)
convertAllergiesToString([3, 7], 'en', false, cache)
// Returns: "Contains eggs and milk protein"

// Danish: " og " (with spaces)
convertAllergiesToString([3, 7], 'da', false, cache)
// Returns: "Indeholder æg og mælkeprotein"

// German: " und " (with spaces)
convertAllergiesToString([3, 7], 'de', false, cache)
// Returns: "Enthält Eier und Milcheiweiß"
```

### Missing Translation Keys
```dart
// If 'allergen_7' translation missing in cache
convertAllergiesToString([3, 7, 4], 'en', false, cache)
// Returns: "Contains eggs and fish"
// (ID 7 skipped, warning logged)

// Console output:
// ⚠️ Translation missing: en.allergen_7
```

### Null Translation Cache
```dart
// If translationsCache is null
convertAllergiesToString([3, 7], 'en', false, null)
// Returns: "No allergens listed for this dish"
// (Graceful fallback to empty message)

// Console output:
// ⚠️ Translation cache is null for key: allergen_contains
```

---

## Testing Checklist

### Functional Tests
- [ ] **Single allergen display**
  - Input: `[7]`, Language: `'en'`
  - Expected: `"Contains milk protein"`

- [ ] **Two allergens (conjunction only)**
  - Input: `[3, 7]`, Language: `'da'`
  - Expected: `"Indeholder æg og mælkeprotein"`

- [ ] **Three+ allergens (commas + conjunction)**
  - Input: `[3, 7, 4]`, Language: `'en'`
  - Expected: `"Contains eggs, fish and milk protein"`

- [ ] **Alphabetical sorting**
  - Input: `[7, 3, 5]` (unsorted)
  - Expected: `"Contains eggs, milk protein and peanuts"` (sorted)

- [ ] **Empty list (food context)**
  - Input: `[]`, isBeverage: `false`
  - Expected: `"No allergens listed for this dish"`

- [ ] **Empty list (beverage context)**
  - Input: `null`, isBeverage: `true`
  - Expected: `"No allergens listed for this beverage"`

### Edge Case Tests
- [ ] **Invalid IDs filtered out**
  - Input: `[3, 99, 7, -1]`
  - Expected: `"Contains eggs and milk protein"`

- [ ] **All invalid IDs**
  - Input: `[99, 100]`
  - Expected: Empty state message

- [ ] **Duplicate IDs handled**
  - Input: `[7, 7, 3]`
  - Expected: `"Contains eggs and milk protein"` (deduplicated)

### Localization Tests
- [ ] **Danish translation**
  - Input: `[3, 7]`, Language: `'da'`
  - Expected: Danish allergen names and conjunction

- [ ] **German translation**
  - Input: `[3, 7]`, Language: `'de'`
  - Expected: German allergen names and conjunction

- [ ] **Unsupported language (fallback)**
  - Input: `[3]`, Language: `'xx'` (invalid code)
  - Behavior: Should use fallback language (English)

### Error Handling Tests
- [ ] **Null translation cache**
  - Input: cache = `null`
  - Expected: Empty state message, logged warning

- [ ] **Missing translation keys**
  - Input: Incomplete cache (missing allergen translations)
  - Expected: Allergen skipped, remaining allergens shown

- [ ] **Malformed cache structure**
  - Input: Invalid cache format
  - Expected: Graceful degradation

### Integration Tests
- [ ] **Used in DishBottomSheet**
  - Display allergen info in dish detail view
  - Verify formatting matches design

- [ ] **Used in MenuDishesListView**
  - Display allergen badges in menu list
  - Verify truncation for long lists

- [ ] **Used in FilterDescriptionSheet**
  - Show excluded allergens in filter summary
  - Verify prefix removal logic works

- [ ] **Language switching**
  - Change app language
  - Verify allergen strings update immediately

### Performance Tests
- [ ] **Large allergen lists**
  - Input: All 14 allergen IDs
  - Expected: Formatted correctly, no lag

- [ ] **Repeated calls**
  - Call function 100 times with same input
  - Expected: Consistent output, no memory leak

---

## Migration Notes

### Phase 3 Implementation

**Status:** Ready for direct port from FlutterFlow

**Migration Steps:**
1. Copy function signature and logic from `custom_functions.dart`
2. Ensure `getTranslations()` helper is already migrated
3. Update imports to use new project structure
4. Add to `lib/shared/custom_functions.dart` or equivalent
5. Run `flutter analyze` to check for errors
6. Execute test checklist above
7. Integrate with existing widgets that use allergen display

**Dependencies to Migrate First:**
```dart
1. getTranslations() function
2. FFAppState.translationsCache setup
3. FFAppState.languageCode setup
4. Translation loading logic
```

### Key Differences from FlutterFlow

**FlutterFlow Version:**
- Used in Custom Functions section
- Auto-generated type handling
- Built-in translation cache access

**Pure Flutter Version:**
- Must be in standalone Dart file
- Explicit type conversions needed
- Manual FFAppState access pattern

**Example Migration Pattern:**
```dart
// FlutterFlow (original)
String? convertAllergiesToString(
  List<int>? allergyIDs,
  String currentLanguage,
  bool isBeverage,
  dynamic translationsCache,
) {
  // ... function body ...
}

// Pure Flutter (migrated)
import 'package:flutter/material.dart';
import '../state/app_state.dart';  // For FFAppState
import 'translations.dart';        // For getTranslations()

String? convertAllergiesToString(
  List<int>? allergyIDs,
  String currentLanguage,
  bool isBeverage,
  dynamic translationsCache,
) {
  // Same function body, no changes needed
  // Logic is pure Dart, works identically
}
```

### Breaking Changes
**None.** Function logic is pure Dart and can be migrated 1:1.

### Widget Integration Pattern
```dart
// Before migration (FlutterFlow)
Text(
  convertAllergiesToString(
    widget.allergens,
    FFAppState().languageCode,
    widget.isBeverage,
    FFAppState().translationsCache,
  ) ?? '',
)

// After migration (Pure Flutter)
// Same code! No changes needed at call sites.
Text(
  convertAllergiesToString(
    widget.allergens,
    FFAppState().languageCode,
    widget.isBeverage,
    FFAppState().translationsCache,
  ) ?? '',
)
```

### Testing Requirements for Migration
- [ ] Unit tests for all allergen counts (1, 2, 3, 14)
- [ ] Unit tests for all supported languages
- [ ] Unit tests for edge cases (null, empty, invalid)
- [ ] Integration tests with DishBottomSheet
- [ ] Integration tests with MenuDishesListView
- [ ] Visual regression tests for formatting
- [ ] Language switching smoke test

### Gotchas and Common Issues

**Issue 1: Missing Translation Keys**
```dart
// Symptom: Allergens not showing up
// Cause: Translation cache not loaded yet
// Solution: Ensure translations loaded before first call

// Add loading check in widget:
if (FFAppState().translationsCache == null) {
  return CircularProgressIndicator();
}
```

**Issue 2: Wrong Conjunction Language**
```dart
// Symptom: "Contains eggs and milk" in Danish app
// Cause: Passing wrong language code
// Solution: Always pass FFAppState().languageCode

// Wrong:
convertAllergiesToString(ids, 'en', false, cache)

// Right:
convertAllergiesToString(ids, FFAppState().languageCode, false, cache)
```

**Issue 3: Not Updating on Language Change**
```dart
// Symptom: Allergen text stays in old language
// Cause: Text not rebuilt when language changes
// Solution: Trigger rebuild when FFAppState changes

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use FFAppState() inside build() to reactive updates
    return Text(
      convertAllergiesToString(
        allergens,
        FFAppState().languageCode,  // ← Rebuilds on language change
        isBeverage,
        FFAppState().translationsCache,
      ) ?? '',
    );
  }
}
```

**Issue 4: Beverage Flag Misuse**
```dart
// Symptom: Wrong empty message shown
// Cause: isBeverage flag set incorrectly
// Solution: Check item type from data

// Wrong: Always false
convertAllergiesToString(ids, lang, false, cache)

// Right: Check item type
final isBev = itemData['category']?.toLowerCase() == 'beverage';
convertAllergiesToString(ids, lang, isBev, cache)
```

---

## Related Functions

### Similar Functions in Codebase
```dart
// 1. convertDietaryPreferencesToString (lines 541-672)
//    Same pattern, but for dietary preferences instead of allergens
//    Uses sorted display order (disease → religious → diet-based)

// 2. generateFilterSummary (lines 916-1184)
//    Builds complete filter summary including allergens
//    Uses convertAllergiesToString internally for allergen display

// 3. getTranslations (lines 2161-2235)
//    Core translation lookup function
//    Used by convertAllergiesToString for all text translations
```

### Function Relationships
```
┌─────────────────────────────────────┐
│      DishBottomSheet Widget         │
│  (needs allergen display string)    │
└────────────────┬────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────┐
│   convertAllergiesToString()        │
│  - Takes allergen IDs               │
│  - Formats into readable string     │
│  - Returns localized output         │
└────────────────┬────────────────────┘
                 │
                 ├─────► getTranslations()
                 │       (for allergen names,
                 │        "Contains", "and")
                 │
                 └─────► FFAppState.translationsCache
                         (source of all translation data)
```

---

## Additional Notes

### EU Allergen Compliance
This function implements the **EU Food Information Regulation (EU) No 1169/2011**, which mandates disclosure of 14 major allergen categories. The allergen IDs (1-14) correspond to these regulated categories.

**Regulatory Context:**
- Restaurants must disclose presence of any of the 14 allergens
- "Free from" claims require verified absence
- Cross-contamination warnings are separate (handled by disclaimer text)

### Design Decisions

**Why alphabetical sorting?**
- Consistent display across all instances
- Easier for users to scan long lists
- No implied priority (medical vs dietary preferences)

**Why separate food/beverage empty messages?**
- Different user expectations (beverages less likely to contain allergens)
- Allows context-appropriate language ("drink" vs "dish")
- Future-proofing for drink-specific allergen rules

**Why filter invalid IDs silently?**
- Prevents errors from data inconsistencies
- Graceful degradation when ID system changes
- User sees accurate info (present allergens) vs error state

**Why lowercase allergen names?**
- Grammatically correct in sentence context ("Contains eggs and milk")
- Matches style of other dietary info displays
- Capital case reserved for standalone labels ("Allergens: Eggs, Milk")

### Future Enhancements

**Potential improvements for future versions:**

1. **Short allergen display mode**
   ```dart
   // Current: "Contains milk protein, eggs and fish"
   // Proposed: "Contains 3 allergens: milk, eggs, fish"
   bool useShortFormat = false;  // New parameter
   ```

2. **Allergen icon support**
   ```dart
   // Add emoji or icon mappings
   final allergenIcons = {
     7: '🥛',  // Milk
     3: '🥚',  // Eggs
     5: '🥜',  // Peanuts
   };
   ```

3. **Severity levels**
   ```dart
   // Highlight critical allergens differently
   final criticalAllergens = [5, 8];  // Peanuts, tree nuts
   // Rendering: "Contains eggs, **PEANUTS** and fish"
   ```

4. **Custom conjunction styles**
   ```dart
   // Support Oxford comma for specific languages
   // "eggs, fish, and milk" vs "eggs, fish and milk"
   ```

---

## Contact & Support

**Function Owner:** Core functionality team
**Documentation Author:** Claude (2026-02-19)
**Review Status:** Pending Phase 3 review
**Questions:** See `_reference/journeymate-design-system.md` for design rationale
