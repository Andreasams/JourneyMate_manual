# `generateFilterSummary` Custom Function

**Source:** `_flutterflow_export/lib/flutter_flow/custom_functions.dart` (Lines 916-1184)

**Function Signature:**
```dart
String? generateFilterSummary(
  int itemCount,
  int? selectedPreferenceId,
  List<int>? excludedAllergyIdsList,
  String currentLanguageCode,
  dynamic translationsCache,
  List<int>? selectedRestrictionIds,
)
```

---

## Purpose

Generates a **grammatically correct, localized filter summary string** that describes the active menu filters to the user. This summary appears on filtered menu views to clearly communicate which dietary preferences/restrictions and allergen exclusions are currently applied.

The function implements **complex natural language generation logic** across 15 languages, handling:
- Singular vs. plural grammatical forms
- Proper conjunction usage ("and", "or")
- Language-specific capitalization rules
- Multi-allergen abbreviation ("X and Y and 3 other allergens")
- German-specific verb conjugation ("ist" vs "sind")
- CJK language spacing rules (Chinese, Japanese)
- Implied allergen filtering (e.g., vegan automatically excludes milk, eggs, fish)

---

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `itemCount` | `int` | Yes | Number of menu items matching the filters. Used for singular/plural grammar. |
| `selectedPreferenceId` | `int?` | No | ID of selected dietary **preference** (2=Pescetarian, 6=Vegan, 7=Vegetarian). Mutually exclusive with restrictions. |
| `excludedAllergyIdsList` | `List<int>?` | No | List of allergen IDs to exclude (1-14). See allergen ID mapping below. |
| `currentLanguageCode` | `String` | Yes | ISO 639-1 language code for localization ('en', 'da', 'de', etc.). |
| `translationsCache` | `dynamic` | Yes | Translation cache from `FFAppState` for retrieving localized strings. |
| `selectedRestrictionIds` | `List<int>?` | No | List of selected dietary **restriction** IDs (1=Gluten-free, 3=Halal, 4=Lactose-free, 5=Kosher). |

**Allergen ID Mapping:**
```dart
1 = Cereals containing gluten
2 = Crustaceans
3 = Eggs
4 = Fish
5 = Peanuts
6 = Soybeans
7 = Milk
8 = Nuts
9 = Celery
10 = Mustard
11 = Sesame seeds
12 = Sulphur dioxide
13 = Lupin
14 = Molluscs
```

**Dietary ID Mapping:**
```dart
// Restrictions (selectedRestrictionIds)
1 = Gluten-free
3 = Halal
4 = Lactose-free
5 = Kosher

// Preferences (selectedPreferenceId)
2 = Pescetarian
6 = Vegan
7 = Vegetarian
```

---

## Return Value

**Type:** `String?`

**Format Examples:**

```dart
// No filters
"Showing the 34 items."

// Dietary only (single)
"Showing the 34 items that are or can be made lactose-free."

// Dietary only (multiple)
"Showing the 34 items that are or can be made gluten-free and lactose-free."

// Allergen only (two items)
"Showing the 34 items that are free from peanuts and fish."

// Allergen only (3+ items - abbreviated)
"Showing the 34 items that are free from peanuts, fish and 2 other allergens."

// Both dietary and allergen
"Showing the 34 items that are or can be made lactose-free and are free from peanuts and fish."

// German example with verb conjugation
"Zeigt die 34 Gerichte, die glutenfrei sind und laktosefrei sind."

// Chinese example (no space before count)
"显示符合条件的34道菜，不含花生和鱼和2种其他过敏原。"
```

---

## Dependencies

### Translation Keys Required

**Item Count:**
- `filter_item_singular` - "Showing the {} item" (replacement marker: `{}`)
- `filter_item_plural` - "Showing the {} items"

**Dietary Prefix:**
- `filter_dietary_prefix_singular` - " that is or can be made "
- `filter_dietary_prefix_plural` - " that are or can be made "

**Allergen Connector:**
- `filter_connector_singular` - " that is free from "
- `filter_connector_plural` - " that are free from "

**Conjunctions:**
- `filter_and` - " and "
- `filter_and_are_free_from` - " and are free from "

**Allergen Abbreviation:**
- `filter_other_singular` - " other allergen"
- `filter_other_plural` - " other allergens"

**Dietary Names:**
- `dietary_1` through `dietary_7` - Localized names (e.g., "gluten-free", "vegan")

**Allergen Names:**
- `allergen_1` through `allergen_14` - Localized names (e.g., "peanuts", "milk")

### External Functions

- **`getTranslations()`** - Retrieves localized strings from cache
  - Called repeatedly for each translation key
  - Handles missing translations gracefully

---

## FFAppState Usage

**Read:**
- `FFAppState().translationsCache` - Passed as `translationsCache` parameter
- Cache contains all localized strings indexed by translation key

**Write:**
- None (function is read-only)

---

## Core Logic Flow

### Step 1: Item Count Formatting

```dart
// Determine singular vs plural
final isPlural = itemCount > 1;

// Get localized item count text
final itemCountKey = isPlural ? 'filter_item_plural' : 'filter_item_singular';
final itemCountText = _getUIText(itemCountKey).replaceAll('{}', itemCount.toString());
// Result: "Showing the 34 items"
```

### Step 2: Collect Dietary Filters

```dart
final dietaryFilters = <String>[];

// Process restrictions (IDs: 1, 3, 4, 5)
for (final restrictionId in restrictionIds) {
  final restrictionText = _getDietaryPreferenceNameSafe(restrictionId);
  if (restrictionText != null) {
    var formattedText = _applyCapitalization(restrictionText); // Lowercase for some languages

    // German: Add verb conjugation
    if (currentLanguageCode == 'de') {
      formattedText += isPlural ? ' sind' : ' ist';
    }

    dietaryFilters.add(formattedText);
  }
}

// Process preference (IDs: 2, 6, 7) - same logic
if (_isValidDietaryId(selectedPreferenceId)) {
  // Add to dietaryFilters list
}
```

### Step 3: Collect Allergen Filters (with Implied Exclusions)

```dart
// Define implied allergens for each dietary type
const impliedAllergenExclusions = {
  1: [2],              // Gluten-free → excludes cereals
  4: [7],              // Lactose-free → excludes milk
  6: [7, 4, 5, 3, 8],  // Vegan → excludes milk, eggs, fish, crustaceans, molluscs
  7: [5, 3, 8],        // Vegetarian → excludes fish, crustaceans, molluscs
};

// Calculate which allergens are implied by dietary choices
final impliedAllergens = <int>{};
for (final dietaryId in [...restrictionIds, selectedPreferenceId]) {
  if (impliedAllergenExclusions.containsKey(dietaryId)) {
    impliedAllergens.addAll(impliedAllergenExclusions[dietaryId]!);
  }
}

// Build allergen display list (exclude implied ones to avoid redundancy)
final allergensToShow = <String>[];
for (final allergenId in excludedAllergyIds) {
  if (impliedAllergens.contains(allergenId)) continue; // Skip if implied

  final allergenName = _getAllergenNameSafe(allergenId);
  if (allergenName != null) {
    allergensToShow.add(_applyCapitalization(allergenName));
  }
}

// Sort alphabetically for consistent display
allergensToShow.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
```

**Implied Allergen Logic Example:**

If user selects "Vegan" (ID 6), the function automatically knows this excludes milk (7), eggs (4), fish (5), crustaceans (3), and molluscs (8). If the user **also** manually selects "milk" as an excluded allergen, the summary will **not** show "milk" redundantly since it's already implied by "vegan".

This prevents summaries like:
- ❌ "Items that are vegan and are free from milk" (redundant)
- ✅ "Items that are vegan" (clean)

But if the user selects "vegan" AND "peanuts", it shows:
- ✅ "Items that are vegan and are free from peanuts" (peanuts not implied by vegan)

### Step 4: Build Sentence (Decision Tree)

```dart
// CASE 1: No filters at all
if (!hasDietaryFilters && !hasAllergenFilters) {
  return '$itemCountText.';
  // "Showing the 34 items."
}

// CASE 2: Dietary only (no allergens)
if (hasDietaryFilters && !hasAllergenFilters) {
  final prefix = _getUIText('filter_dietary_prefix_plural'); // " that are or can be made "
  final dietaryList = _formatDietaryList(dietaryFilters, _getUIText('filter_and'));
  // dietaryList = "gluten-free and lactose-free"
  return '$itemCountText$prefix$dietaryList.';
  // "Showing the 34 items that are or can be made gluten-free and lactose-free."
}

// CASE 3: Allergen only (no dietary)
if (!hasDietaryFilters && hasAllergenFilters) {
  final connector = _getUIText('filter_connector_plural'); // " that are free from "
  final allergenList = _formatAllergenList(allergensToShow, ...);
  // allergenList = "peanuts and fish" OR "peanuts, fish and 2 other allergens"
  return '$itemCountText$connector$allergenList.';
  // "Showing the 34 items that are free from peanuts and fish."
}

// CASE 4: Both dietary AND allergen
final prefix = _getUIText('filter_dietary_prefix_plural'); // " that are or can be made "
final dietaryList = _formatDietaryList(dietaryFilters, _getUIText('filter_and'));
final andAreFreeFrom = _getUIText('filter_and_are_free_from'); // " and are free from "
final allergenList = _formatAllergenList(allergensToShow, ...);
return '$itemCountText$prefix$dietaryList$andAreFreeFrom$allergenList.';
// "Showing the 34 items that are or can be made lactose-free and are free from peanuts and fish."
```

---

## Helper Functions

### `_formatAllergenList()`

Formats 1-N allergens with proper grammar and optional abbreviation for long lists.

**Logic:**
- **1 allergen:** "peanuts"
- **2 allergens:** "peanuts and fish"
- **3+ allergens:** "peanuts, fish and 2 other allergens"

**CJK Language Handling:**

Chinese, Japanese, and Korean (CJK) languages don't use spaces before numbers. The function detects this:

```dart
const noSpaceBeforeCount = {'zh', 'ja'};

if (noSpaceBeforeCountNeeded) {
  return '$firstTwo$allergyAnd$othersCount$othersNoun';
  // Chinese: "花生、鱼和2种其他过敏原"
} else {
  return '$firstTwo$allergyAnd$othersCount $othersNoun';
  // English: "peanuts, fish and 2 other allergens"
}
```

### `_formatDietaryList()`

Formats 1-N dietary items with proper grammar (no abbreviation).

**Logic:**
- **1 dietary:** "gluten-free"
- **2 dietary:** "gluten-free and lactose-free"
- **3+ dietary:** "gluten-free, lactose-free and vegan"

### `_applyCapitalization()`

Applies language-specific capitalization rules to dietary and allergen names.

**Logic:**

```dart
const lowercaseLanguages = {
  'da', 'en', 'es', 'de', 'fr', 'nl', 'no', 'sv', 'it', 'pl', 'fi',
};

String _applyCapitalization(String text) {
  return lowercaseLanguages.contains(currentLanguageCode)
      ? text.toLowerCase()  // "Gluten-Free" → "gluten-free"
      : text;               // Keep as-is for other languages
}
```

**Examples:**
- English: "Gluten-Free" → "gluten-free"
- German: "Glutenfrei" → "glutenfrei"
- Chinese: "无麸质" → "无麸质" (unchanged)

---

## Language-Specific Features

### German Verb Conjugation

German requires adding "ist" (singular) or "sind" (plural) after dietary adjectives.

**English:**
```
"Items that are or can be made gluten-free."
```

**German (without conjugation - INCORRECT):**
```
"Gerichte, die glutenfrei gemacht werden können."
```

**German (with conjugation - CORRECT):**
```dart
if (currentLanguageCode == 'de') {
  formattedText += isPlural ? ' sind' : ' ist';
}
// Result: "Gerichte, die glutenfrei sind."
```

### CJK Spacing Rules

Chinese, Japanese, and Korean don't use spaces before numbers in counts.

**English:** "2 other allergens" (space before 2)
**Chinese:** "2种其他过敏原" (no space before 2)

```dart
const noSpaceBeforeCount = {'zh', 'ja'};

if (noSpaceBeforeCount.contains(currentLanguageCode)) {
  return '$firstTwo$allergyAnd$othersCount$othersNoun';
} else {
  return '$firstTwo$allergyAnd$othersCount $othersNoun';
}
```

### Capitalization Rules

Most Western languages lowercase dietary/allergen names in sentence context, but some languages preserve capitalization.

**Languages that lowercase:** da, en, es, de, fr, nl, no, sv, it, pl, fi
**Languages that preserve case:** zh, ja, ko, uk (and others not in lowercase list)

---

## Usage Examples

### Example 1: Dietary Only (Single)

**Input:**
```dart
generateFilterSummary(
  34,                    // itemCount
  null,                  // selectedPreferenceId
  null,                  // excludedAllergyIdsList
  'en',                  // currentLanguageCode
  translationsCache,     // translationsCache
  [4],                   // selectedRestrictionIds (4 = Lactose-free)
)
```

**Output:**
```
"Showing the 34 items that are or can be made lactose-free."
```

**Flow:**
1. `isPlural = true` (34 > 1)
2. `dietaryFilters = ["lactose-free"]` (ID 4 translated and lowercased)
3. `allergensToShow = []` (no allergens)
4. Case 2: Dietary only
5. Prefix: " that are or can be made "
6. Dietary list: "lactose-free"
7. Final: "Showing the 34 items that are or can be made lactose-free."

---

### Example 2: Dietary Multiple

**Input:**
```dart
generateFilterSummary(
  18,                    // itemCount
  null,                  // selectedPreferenceId
  null,                  // excludedAllergyIdsList
  'da',                  // currentLanguageCode
  translationsCache,     // translationsCache
  [1, 4],                // selectedRestrictionIds (1=Gluten-free, 4=Lactose-free)
)
```

**Output (Danish):**
```
"Viser de 18 retter, der er eller kan laves glutenfri og laktosfri."
```

**Flow:**
1. `isPlural = true` (18 > 1)
2. `dietaryFilters = ["glutenfri", "laktosfri"]` (IDs 1, 4 translated to Danish and lowercased)
3. `allergensToShow = []`
4. Case 2: Dietary only
5. Prefix: " der er eller kan laves "
6. Dietary list: "glutenfri og laktosfri" (formatted with Danish "og" = "and")
7. Final: "Viser de 18 retter, der er eller kan laves glutenfri og laktosfri."

---

### Example 3: Allergen Only (Two Items)

**Input:**
```dart
generateFilterSummary(
  12,                    // itemCount
  null,                  // selectedPreferenceId
  [5, 4],                // excludedAllergyIdsList (5=Peanuts, 4=Fish)
  'en',                  // currentLanguageCode
  translationsCache,     // translationsCache
  null,                  // selectedRestrictionIds
)
```

**Output:**
```
"Showing the 12 items that are free from fish and peanuts."
```

**Flow:**
1. `isPlural = true` (12 > 1)
2. `dietaryFilters = []`
3. `allergensToShow = ["fish", "peanuts"]` (sorted alphabetically)
4. Case 3: Allergen only
5. Connector: " that are free from "
6. Allergen list: "fish and peanuts" (2 items, simple join)
7. Final: "Showing the 12 items that are free from fish and peanuts."

---

### Example 4: Allergen Multiple (3+ Abbreviated)

**Input:**
```dart
generateFilterSummary(
  8,                     // itemCount
  null,                  // selectedPreferenceId
  [5, 4, 7, 8, 9],       // excludedAllergyIdsList (5 allergens)
  'en',                  // currentLanguageCode
  translationsCache,     // translationsCache
  null,                  // selectedRestrictionIds
)
```

**Output:**
```
"Showing the 8 items that are free from celery, fish and 3 other allergens."
```

**Flow:**
1. `isPlural = true` (8 > 1)
2. `dietaryFilters = []`
3. `allergensToShow = ["celery", "fish", "milk", "nuts", "peanuts"]` (sorted alphabetically)
4. Case 3: Allergen only
5. Connector: " that are free from "
6. Allergen list: Only first two shown, rest abbreviated
   - `firstTwo = ["celery", "fish"]`
   - `othersCount = 3`
   - Result: "celery, fish and 3 other allergens"
7. Final: "Showing the 8 items that are free from celery, fish and 3 other allergens."

---

### Example 5: Both Dietary and Allergen

**Input:**
```dart
generateFilterSummary(
  22,                    // itemCount
  null,                  // selectedPreferenceId
  [5, 4],                // excludedAllergyIdsList (5=Peanuts, 4=Fish)
  'en',                  // currentLanguageCode
  translationsCache,     // translationsCache
  [4],                   // selectedRestrictionIds (4=Lactose-free)
)
```

**Output:**
```
"Showing the 22 items that are or can be made lactose-free and are free from fish and peanuts."
```

**Flow:**
1. `isPlural = true` (22 > 1)
2. `dietaryFilters = ["lactose-free"]`
3. Implied allergens: Lactose-free (ID 4) → implies milk (ID 7)
4. `allergensToShow = ["fish", "peanuts"]` (IDs 4, 5 → sorted; milk not in list so no exclusion)
5. Case 4: Both dietary and allergen
6. Prefix: " that are or can be made "
7. Dietary list: "lactose-free"
8. Connector: " and are free from "
9. Allergen list: "fish and peanuts"
10. Final: "Showing the 22 items that are or can be made lactose-free and are free from fish and peanuts."

---

### Example 6: Vegan with Implied Allergen Filtering

**Input:**
```dart
generateFilterSummary(
  15,                    // itemCount
  6,                     // selectedPreferenceId (6=Vegan)
  [7, 5],                // excludedAllergyIdsList (7=Milk, 5=Peanuts)
  'en',                  // currentLanguageCode
  translationsCache,     // translationsCache
  null,                  // selectedRestrictionIds
)
```

**Output:**
```
"Showing the 15 items that are or can be made vegan and are free from peanuts."
```

**Key Insight:** Milk (ID 7) is **not shown** in the allergen list because it's implied by vegan. Only peanuts is shown.

**Flow:**
1. `isPlural = true` (15 > 1)
2. `dietaryFilters = ["vegan"]`
3. Implied allergens from vegan (ID 6): [7, 4, 5, 3, 8] (milk, eggs, fish, crustaceans, molluscs)
4. `allergensToShow`:
   - Milk (7) → **skipped** (implied by vegan)
   - Peanuts (5) → **included** (not implied by vegan)
5. Case 4: Both dietary and allergen
6. Final: "Showing the 15 items that are or can be made vegan and are free from peanuts."

---

### Example 7: German with Verb Conjugation

**Input:**
```dart
generateFilterSummary(
  10,                    // itemCount
  null,                  // selectedPreferenceId
  null,                  // excludedAllergyIdsList
  'de',                  // currentLanguageCode
  translationsCache,     // translationsCache
  [1, 4],                // selectedRestrictionIds (1=Gluten-free, 4=Lactose-free)
)
```

**Output (German):**
```
"Zeigt die 10 Gerichte, die glutenfrei sind und laktosefrei sind."
```

**Flow:**
1. `isPlural = true` (10 > 1)
2. `dietaryFilters`:
   - Gluten-free (ID 1) → "glutenfrei" (lowercased)
   - Add " sind" (plural verb) → "glutenfrei sind"
   - Lactose-free (ID 4) → "laktosefrei" (lowercased)
   - Add " sind" (plural verb) → "laktosefrei sind"
3. Result: `["glutenfrei sind", "laktosefrei sind"]`
4. Dietary list formatted: "glutenfrei sind und laktosefrei sind"
5. Final: "Zeigt die 10 Gerichte, die glutenfrei sind und laktosefrei sind."

---

### Example 8: Chinese with CJK Spacing

**Input:**
```dart
generateFilterSummary(
  6,                     // itemCount
  null,                  // selectedPreferenceId
  [5, 4, 7, 8],          // excludedAllergyIdsList (4 allergens)
  'zh',                  // currentLanguageCode
  translationsCache,     // translationsCache
  null,                  // selectedRestrictionIds
)
```

**Output (Chinese):**
```
"显示符合条件的6道菜，不含花生、鱼和2种其他过敏原。"
```

**Key Insight:** No space before "2" due to CJK spacing rules.

**Flow:**
1. `isPlural = true` (6 > 1)
2. `dietaryFilters = []`
3. `allergensToShow = ["花生", "鱼", "牛奶", "坚果"]` (4 allergens, sorted)
4. Case 3: Allergen only
5. Allergen list formatting:
   - First two: "花生、鱼"
   - Others count: 2
   - CJK language detected (`noSpaceBeforeCount.contains('zh')`)
   - Result: "花生、鱼和2种其他过敏原" (no space before "2")
6. Final: "显示符合条件的6道菜，不含花生、鱼和2种其他过敏原。"

---

### Example 9: No Filters (Baseline)

**Input:**
```dart
generateFilterSummary(
  42,                    // itemCount
  null,                  // selectedPreferenceId
  null,                  // excludedAllergyIdsList
  'en',                  // currentLanguageCode
  translationsCache,     // translationsCache
  null,                  // selectedRestrictionIds
)
```

**Output:**
```
"Showing the 42 items."
```

**Flow:**
1. `isPlural = true` (42 > 1)
2. `dietaryFilters = []`
3. `allergensToShow = []`
4. Case 1: No filters at all
5. Final: "Showing the 42 items."

---

### Example 10: Singular Item

**Input:**
```dart
generateFilterSummary(
  1,                     // itemCount
  null,                  // selectedPreferenceId
  [5],                   // excludedAllergyIdsList (5=Peanuts)
  'en',                  // currentLanguageCode
  translationsCache,     // translationsCache
  null,                  // selectedRestrictionIds
)
```

**Output:**
```
"Showing the 1 item that is free from peanuts."
```

**Flow:**
1. `isPlural = false` (1 == 1)
2. Item count key: `filter_item_singular` → "Showing the {} item"
3. Connector key: `filter_connector_singular` → " that is free from "
4. Final: "Showing the 1 item that is free from peanuts."

---

## Edge Cases

### Empty Filters

**Input:**
```dart
generateFilterSummary(0, null, null, 'en', translationsCache, null)
```

**Output:**
```
"Showing the 0 items."
```

**Behavior:** Treats 0 as plural (standard English grammar).

---

### Invalid Dietary/Allergen IDs

**Input:**
```dart
generateFilterSummary(
  10,
  999,                   // Invalid dietary ID
  [999, 5],              // Invalid allergen ID 999, valid ID 5
  'en',
  translationsCache,
  null,
)
```

**Output:**
```
"Showing the 10 items that are free from peanuts."
```

**Behavior:** Invalid IDs are silently ignored. Only valid IDs with translations are included.

---

### All Allergens Implied by Dietary

**Input:**
```dart
generateFilterSummary(
  8,
  6,                     // Vegan (implies milk, eggs, fish, crustaceans, molluscs)
  [7, 4, 5],             // Milk, eggs, fish - all implied
  'en',
  translationsCache,
  null,
)
```

**Output:**
```
"Showing the 8 items that are or can be made vegan."
```

**Behavior:** All allergens are filtered out as implied. Only dietary preference is shown.

---

### Missing Translations

**Input:**
```dart
generateFilterSummary(10, null, null, 'xx', translationsCache, [1])
// 'xx' = unsupported language
```

**Output:**
```
"" (empty string or fallback)
```

**Behavior:** If translation keys are missing, helper functions return empty strings or defaults. The summary may be incomplete or empty.

---

### Unsupported Language Code

**Input:**
```dart
generateFilterSummary(10, null, [5], 'xyz', translationsCache, null)
```

**Output:**
```
"Showing the 10 items that are free from peanuts."
```

**Behavior:** Falls back to English or default behavior if language not recognized. Capitalization rules default to "preserve case" (not in `lowercaseLanguages` set).

---

### Zero Results

**Input:**
```dart
generateFilterSummary(0, null, [5, 4, 7, 8, 9], 'en', translationsCache, null)
```

**Output:**
```
"Showing the 0 items that are free from celery, fish and 3 other allergens."
```

**Behavior:** Function doesn't handle zero-results messaging differently. UI layer should detect `itemCount == 0` and show appropriate empty state.

---

## Real-World Usage

### Location in Codebase

**File:** `_flutterflow_export/lib/pages/full_menu/full_menu_widget.dart`

**Context:** Used in the filtered menu view to display a summary above the list of menu items.

**Typical Call Pattern:**

```dart
// In FullMenuWidget build method
final filterSummary = generateFilterSummary(
  filteredMenuItems.length,
  FFAppState().selectedDietaryTypeId,
  FFAppState().excludedAllergyIds,
  FFAppState().currentLanguage,
  FFAppState().translationsCache,
  FFAppState().selectedRestrictionIds,
);

// Display in UI
Text(
  filterSummary ?? '',
  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
)
```

---

### Integration Points

1. **Menu Filtering:**
   - Called after applying dietary/allergen filters to menu items
   - Recalculated whenever filters change
   - Summary updates in real-time as user adds/removes filters

2. **Filter Sheet:**
   - Summary appears at top of filtered menu view
   - Helps users understand current filter state
   - Provides confirmation of applied selections

3. **State Management:**
   - Reads from `FFAppState()`:
     - `selectedDietaryTypeId` (dietary preference)
     - `selectedRestrictionIds` (dietary restrictions)
     - `excludedAllergyIds` (allergen exclusions)
     - `currentLanguage` (UI language)
     - `translationsCache` (translation strings)

---

## Testing Checklist

### Functional Tests

- [ ] **No filters:** Returns item count only
- [ ] **Single dietary:** Shows correct prefix and dietary name
- [ ] **Multiple dietary:** Joins with "and" correctly
- [ ] **Single allergen:** Shows "free from X"
- [ ] **Two allergens:** Shows "free from X and Y"
- [ ] **3+ allergens:** Abbreviates correctly ("X, Y and N other allergens")
- [ ] **Dietary + allergen:** Both parts connected with "and are free from"
- [ ] **Implied allergens:** Milk not shown when vegan selected
- [ ] **All implied allergens:** Only dietary shown, allergen section omitted
- [ ] **Invalid IDs:** Gracefully ignored, no errors

### Language Tests

- [ ] **English:** Lowercase dietary/allergen names, proper grammar
- [ ] **Danish:** Correct Danish translations and "og" conjunction
- [ ] **German:** Verb conjugation ("ist" vs "sind") applied
- [ ] **Chinese:** No space before count in allergen abbreviation
- [ ] **Japanese:** No space before count in allergen abbreviation
- [ ] **French:** Proper French grammar and accents preserved
- [ ] **Italian:** Correct Italian translations
- [ ] **Norwegian:** Correct Norwegian translations
- [ ] **Swedish:** Correct Swedish translations

### Grammar Tests

- [ ] **Singular (1 item):** Uses "item" (singular) and "is" (singular verb)
- [ ] **Plural (2+ items):** Uses "items" (plural) and "are" (plural verb)
- [ ] **Zero items:** Treats as plural (standard English)

### Edge Cases

- [ ] **Zero results:** Returns summary with 0 count
- [ ] **Invalid language code:** Falls back gracefully
- [ ] **Missing translations:** Returns empty or fallback strings
- [ ] **Null parameters:** Handles gracefully (null allergen/dietary lists)
- [ ] **Empty lists:** Handles gracefully (empty allergen/dietary lists)

### Integration Tests

- [ ] **Menu filter changes:** Summary updates correctly
- [ ] **Language switch:** Summary re-renders in new language
- [ ] **Clear filters:** Summary resets to item count only
- [ ] **Mixed filters:** All combinations of dietary + allergen work

---

## Migration Notes

### Phase 3: Flutter Implementation

**High-Level Approach:**

1. **Port core logic** from custom function to Flutter helper
2. **Keep FlutterFlow logic identical** - do not simplify or optimize prematurely
3. **Use Provider for state** instead of `FFAppState()`
4. **Test extensively** across all 15 languages before release

---

### Implementation Strategy

**Step 1: Create Helper Function**

```dart
// lib/helpers/filter_summary_helper.dart

class FilterSummaryHelper {
  static String? generateFilterSummary({
    required int itemCount,
    int? selectedPreferenceId,
    List<int>? excludedAllergyIds,
    required String languageCode,
    required Map<String, dynamic> translationsCache,
    List<int>? selectedRestrictionIds,
  }) {
    // Port logic from custom_functions.dart
    // Keep structure identical for maintainability
  }

  static String _getUIText(String key, String lang, Map<String, dynamic> cache) {
    return TranslationHelper.getTranslation(lang, key, cache);
  }

  static String _formatAllergenList(...) {
    // Port allergen formatting logic
  }

  static String _formatDietaryList(...) {
    // Port dietary formatting logic
  }

  static String _applyCapitalization(String text, String lang) {
    const lowercaseLanguages = {'da', 'en', 'es', 'de', 'fr', 'nl', 'no', 'sv', 'it', 'pl', 'fi'};
    return lowercaseLanguages.contains(lang) ? text.toLowerCase() : text;
  }
}
```

---

**Step 2: Integrate with UI**

```dart
// In FullMenuPage widget

final filterSummary = FilterSummaryHelper.generateFilterSummary(
  itemCount: filteredMenuItems.length,
  selectedPreferenceId: context.read<AppState>().selectedDietaryTypeId,
  excludedAllergyIds: context.read<AppState>().excludedAllergyIds,
  languageCode: context.read<AppState>().currentLanguage,
  translationsCache: context.read<AppState>().translationsCache,
  selectedRestrictionIds: context.read<AppState>().selectedRestrictionIds,
);

// Display summary
if (filterSummary != null && filterSummary.isNotEmpty) {
  Padding(
    padding: EdgeInsets.all(16),
    child: Text(
      filterSummary,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[600],
      ),
    ),
  );
}
```

---

**Step 3: Test Coverage**

```dart
// test/helpers/filter_summary_helper_test.dart

void main() {
  group('FilterSummaryHelper', () {
    test('No filters returns item count only', () {
      final result = FilterSummaryHelper.generateFilterSummary(
        itemCount: 10,
        languageCode: 'en',
        translationsCache: mockTranslations,
      );
      expect(result, 'Showing the 10 items.');
    });

    test('Dietary only shows correct prefix', () {
      final result = FilterSummaryHelper.generateFilterSummary(
        itemCount: 10,
        selectedRestrictionIds: [4], // Lactose-free
        languageCode: 'en',
        translationsCache: mockTranslations,
      );
      expect(result, contains('that are or can be made lactose-free'));
    });

    test('Implied allergens filtered correctly', () {
      final result = FilterSummaryHelper.generateFilterSummary(
        itemCount: 10,
        selectedPreferenceId: 6, // Vegan
        excludedAllergyIds: [7, 5], // Milk (implied), Peanuts (not implied)
        languageCode: 'en',
        translationsCache: mockTranslations,
      );
      expect(result, contains('vegan'));
      expect(result, contains('peanuts'));
      expect(result, isNot(contains('milk'))); // Milk should be filtered out
    });

    test('German verb conjugation applied', () {
      final result = FilterSummaryHelper.generateFilterSummary(
        itemCount: 10,
        selectedRestrictionIds: [1], // Gluten-free
        languageCode: 'de',
        translationsCache: mockTranslationsDE,
      );
      expect(result, contains('glutenfrei sind')); // Plural verb
    });

    test('CJK spacing rules applied', () {
      final result = FilterSummaryHelper.generateFilterSummary(
        itemCount: 10,
        excludedAllergyIds: [5, 4, 7, 8], // 4 allergens
        languageCode: 'zh',
        translationsCache: mockTranslationsZH,
      );
      expect(result, matches(RegExp(r'和2种'))); // No space before count
    });
  });
}
```

---

### Critical Validation Points

**Before declaring migration complete:**

1. **Visual comparison:** Generate summaries in FlutterFlow and Flutter for identical inputs across all 15 languages. They must match **exactly**.

2. **Translation key coverage:** Ensure all required translation keys exist in Supabase for all active languages:
   - `filter_item_singular`, `filter_item_plural`
   - `filter_dietary_prefix_singular`, `filter_dietary_prefix_plural`
   - `filter_connector_singular`, `filter_connector_plural`
   - `filter_and`, `filter_and_are_free_from`
   - `filter_other_singular`, `filter_other_plural`
   - `dietary_1` through `dietary_7`
   - `allergen_1` through `allergen_14`

3. **Regression testing:** Test all edge cases (zero results, invalid IDs, implied allergens, singular/plural, etc.) in both FlutterFlow and Flutter.

4. **Language-specific features:** Verify German verb conjugation, CJK spacing, capitalization rules work correctly.

5. **Performance:** Function is called frequently (on every filter change). Ensure it's fast (< 5ms).

---

### Known Gotchas

1. **Implied allergen map must stay synchronized:**
   - If new dietary types are added (e.g., "Flexitarian"), update `impliedAllergenExclusions` map
   - If allergen definitions change, review implied relationships

2. **Translation cache structure:**
   - FlutterFlow uses dynamic JSON cache from `FFAppState()`
   - Flutter must replicate this structure (Map<String, dynamic>)
   - Cache invalidation strategy must match (language switch triggers reload)

3. **German verb conjugation edge case:**
   - Currently adds "ist/sind" for all dietary types
   - If dietary names already include verbs, this may cause duplication
   - Review all German dietary translations before launch

4. **CJK language detection:**
   - Currently only checks for 'zh' and 'ja'
   - Korean ('ko') also doesn't use spaces before counts but not in set
   - Verify Korean translations and add to set if needed

5. **Capitalization rules:**
   - `lowercaseLanguages` set may need updates for new languages
   - Some languages use title case in different contexts
   - Test carefully when adding new languages

---

### Maintenance Considerations

1. **Adding New Languages:**
   - Add language code to `lowercaseLanguages` set if it uses lowercase dietary/allergen names
   - Add to `noSpaceBeforeCount` set if it's a CJK language
   - Test grammar rules (singular/plural, conjunctions)
   - Add all required translation keys to Supabase

2. **Adding New Dietary Types:**
   - Add ID to either restrictions or preferences group
   - Update `impliedAllergenExclusions` map if it excludes allergens
   - Add translation keys (`dietary_X`) for all languages

3. **Adding New Allergen Types:**
   - Add ID to allergen ID mapping (15+)
   - Add translation keys (`allergen_X`) for all languages
   - Review implied allergen relationships (does any dietary type exclude this?)

4. **Changing Grammar Rules:**
   - Document changes in this README
   - Update test cases
   - Test across all languages

---

## Related Documentation

- **`getTranslations` function:** `MASTER_README_get_translations.md`
- **Translation system:** `_reference/translation-system.md`
- **Menu filtering logic:** `_reference/menu-filtering.md`
- **Dietary and allergen IDs:** `_reference/dietary-allergen-mapping.md`

---

**Last Updated:** 2026-02-19
**Documented By:** Claude Code
**Review Status:** ✅ Complete
