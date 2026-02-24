# getVariationModifiers() Function Documentation

**FlutterFlow Custom Function | Menu Item Display**

---

## Purpose

Extracts variation modifiers from menu item data for display in the menu interface.

**Problem Solved:**
Menu items can have multiple modifier groups (e.g., toppings, sides, sizes). This function specifically extracts only the "Variation" type modifiers (typically size options like Small/Medium/Large) which need to be displayed inline with the menu item.

**Use Cases:**
- Display size variations in menu item list views
- Show price differences for variations
- Enable variation selection in menu item detail sheets
- Filter and present only relevant modifier data to UI components

**Related Functions:**
- None directly (standalone utility for data extraction)

**FlutterFlow Location:**
`C:\Users\Rikke\Documents\JourneyMate\_flutterflow_export\lib\flutter_flow\custom_functions.dart` (lines 2134-2159)

---

## Function Signature

```dart
List<dynamic>? getVariationModifiers(dynamic itemData)
```

**Return Type:** `List<dynamic>?`
- Returns `null` if no variation modifiers exist
- Returns list of modifier objects when variation-type modifiers are found

**Nullability:** Can return `null` (indicates no variations available)

---

## Parameters

### itemData
- **Type:** `dynamic`
- **Required:** Yes
- **Description:** The complete menu item JSON object from the API
- **Expected Structure:**
```json
{
  "item_id": 123,
  "item_name": "Pizza Margherita",
  "price": 89,
  "item_modifier_groups": [
    {
      "type": "Variation",
      "modifiers": [
        {
          "modifier_id": 1,
          "modifier_name": "Small",
          "price": 0
        },
        {
          "modifier_id": 2,
          "modifier_name": "Medium",
          "price": 10
        },
        {
          "modifier_id": 3,
          "modifier_name": "Large",
          "price": 20
        }
      ]
    },
    {
      "type": "Addition",
      "modifiers": [
        {
          "modifier_id": 4,
          "modifier_name": "Extra Cheese",
          "price": 15
        }
      ]
    }
  ]
}
```

**Validation:**
- Must be a `Map` type
- Must contain `item_modifier_groups` key
- `item_modifier_groups` must be a `List`

---

## Return Value

### Success Cases

**Case 1: Variations Found**
```dart
[
  {
    "modifier_id": 1,
    "modifier_name": "Small",
    "price": 0
  },
  {
    "modifier_id": 2,
    "modifier_name": "Medium",
    "price": 10
  },
  {
    "modifier_id": 3,
    "modifier_name": "Large",
    "price": 20
  }
]
```

**Returned when:**
- Item has `item_modifier_groups` array
- At least one group has `type == "Variation"`
- That group has non-empty `modifiers` array

### Null Cases

**Case 1: Invalid Input**
```dart
null
```
**Returned when:** `itemData` is not a `Map`

**Case 2: No Modifier Groups**
```dart
null
```
**Returned when:** `item_modifier_groups` key is missing or null

**Case 3: Empty Modifier Groups**
```dart
null
```
**Returned when:** `item_modifier_groups` is an empty array

**Case 4: No Variation Type**
```dart
null
```
**Returned when:** No modifier group has `type == "Variation"`

**Case 5: Empty Variations**
```dart
null
```
**Returned when:** Variation group exists but has empty `modifiers` array

---

## Dependencies

### Dart Packages
None (uses only built-in Dart types)

### FlutterFlow Packages
None

### Custom Functions
None

### External APIs
None (pure data extraction function)

---

## FFAppState Usage

**State Variables Used:** None

**State Variables Modified:** None

**Justification:** This is a pure utility function that only reads and extracts data from the provided parameter. It does not interact with application state.

---

## Algorithm & Logic Flow

### Step 1: Validate Input Type
```dart
if (itemData is! Map) return null;
```
**Guard clause:** Ensures input is a Map before attempting to access properties.

### Step 2: Extract Modifier Groups
```dart
final modifierGroups = itemData['item_modifier_groups'] as List?;
if (modifierGroups == null || modifierGroups.isEmpty) return null;
```
**Safe extraction:** Uses nullable cast (`as List?`) and checks for null/empty.

### Step 3: Iterate Through Groups
```dart
for (final group in modifierGroups) {
  if (group is Map && group['type'] == 'Variation') {
    // Found variation group
  }
}
```
**Type filtering:** Only processes groups where `type == "Variation"`.

### Step 4: Extract Modifiers
```dart
final modifiers = group['modifiers'] as List?;
if (modifiers != null && modifiers.isNotEmpty) {
  return modifiers;
}
```
**Early return:** Returns immediately upon finding first valid variation group.

### Step 5: Fallback
```dart
return null;
```
**Default case:** No valid variation groups found.

---

## Data Structure Details

### Input Structure: itemData

**Root Level:**
```dart
{
  "item_id": int,
  "item_name": String,
  "price": double,
  "item_modifier_groups": List<Map>  // Can contain multiple groups
}
```

**Modifier Group Structure:**
```dart
{
  "modifier_group_id": int,
  "modifier_group_name": String,
  "type": String,  // Values: "Variation", "Addition", "Substitution", etc.
  "selection_required": bool,
  "min_selections": int,
  "max_selections": int,
  "modifiers": List<Map>
}
```

**Modifier Structure (what gets returned):**
```dart
{
  "modifier_id": int,
  "modifier_name": String,
  "price": double,  // Additional price on top of base item price
  "is_default": bool?,  // Optional: indicates default selection
  "is_available": bool?  // Optional: indicates current availability
}
```

### Type Values

**Common Modifier Types:**
- `"Variation"` - Size options (Small/Medium/Large) - **This is what the function returns**
- `"Addition"` - Extra toppings, sides
- `"Substitution"` - Alternative ingredients
- `"Removal"` - Remove ingredients
- `"Side"` - Side dish options

**Only "Variation" type is extracted by this function.**

---

## Usage Examples

### Example 1: Display Size Options in Menu ListView

**Context:** MenuDishesListView widget showing menu items with size variations

```dart
// FlutterFlow ListView Builder
ListView.builder(
  itemCount: menuItems.length,
  itemBuilder: (context, index) {
    final item = menuItems[index];
    final variations = getVariationModifiers(item);

    return MenuItemCard(
      name: item['item_name'],
      basePrice: item['price'],
      variations: variations,  // Pass to card widget
      onTap: () {
        // Show detail sheet with variations
        showMenuItemSheet(item, variations);
      },
    );
  },
)
```

**Expected Result:**
- If variations exist: Card displays size options with prices
- If no variations: Card displays single base price

### Example 2: Variation Selection in Bottom Sheet

**Context:** Menu item detail bottom sheet with size selector

```dart
// In menu item detail sheet
Widget buildVariationSelector(dynamic itemData) {
  final variations = getVariationModifiers(itemData);

  if (variations == null || variations.isEmpty) {
    // No variations - display single price
    return Text('${itemData['price']} kr.');
  }

  // Display variation selector
  return Column(
    children: [
      Text('Choose size:'),
      ...variations.map((variation) {
        return RadioListTile(
          title: Text(variation['modifier_name']),
          subtitle: Text('+${variation['price']} kr.'),
          value: variation['modifier_id'],
          groupValue: selectedVariationId,
          onChanged: (value) {
            setState(() {
              selectedVariationId = value;
              totalPrice = itemData['price'] + variation['price'];
            });
          },
        );
      }).toList(),
    ],
  );
}
```

**Expected Result:**
- Radio buttons for each size option
- Price updates when selection changes

### Example 3: Variation Indicator in Search Results

**Context:** Search results showing which items have size options

```dart
// In search result card
Widget buildSearchResultCard(dynamic itemData) {
  final hasVariations = getVariationModifiers(itemData) != null;

  return Card(
    child: Column(
      children: [
        Text(itemData['item_name']),
        if (hasVariations)
          Chip(
            label: Text('Multiple sizes available'),
            backgroundColor: Colors.orange.shade100,
          ),
        Text('From ${itemData['price']} kr.'),
      ],
    ),
  );
}
```

**Expected Result:**
- Shows "Multiple sizes available" badge if variations exist
- Shows "From [price]" to indicate base price with variations

### Example 4: Filtering Items with Variations

**Context:** Filter menu to show only items with size options

```dart
// In menu page controller
List<dynamic> getItemsWithVariations(List<dynamic> allItems) {
  return allItems.where((item) {
    final variations = getVariationModifiers(item);
    return variations != null && variations.isNotEmpty;
  }).toList();
}

// Usage
final variableItems = getItemsWithVariations(menuData['items']);
```

**Expected Result:**
- Returns only items that have variation-type modifiers
- Useful for specialty menus or filtering options

---

## Edge Cases

### Edge Case 1: Null itemData
**Input:**
```dart
getVariationModifiers(null);
```

**Expected Behavior:**
- Returns `null` immediately
- No error thrown

**Reason:** Function checks `itemData is! Map` first

### Edge Case 2: Missing item_modifier_groups Key
**Input:**
```dart
{
  "item_id": 123,
  "item_name": "Simple Item",
  "price": 50
  // No item_modifier_groups key
}
```

**Expected Behavior:**
- Returns `null`
- No error thrown

**Reason:** Safe nullable cast (`as List?`) handles missing key

### Edge Case 3: Empty Modifier Groups Array
**Input:**
```dart
{
  "item_id": 123,
  "item_name": "Item",
  "price": 50,
  "item_modifier_groups": []
}
```

**Expected Behavior:**
- Returns `null`
- Early exit after checking `isEmpty`

### Edge Case 4: Multiple Variation Groups
**Input:**
```dart
{
  "item_modifier_groups": [
    {
      "type": "Addition",
      "modifiers": [...]
    },
    {
      "type": "Variation",  // First variation group
      "modifiers": [
        {"modifier_id": 1, "modifier_name": "Small", "price": 0},
        {"modifier_id": 2, "modifier_name": "Large", "price": 10}
      ]
    },
    {
      "type": "Variation",  // Second variation group (ignored)
      "modifiers": [
        {"modifier_id": 3, "modifier_name": "Thin Crust", "price": 0},
        {"modifier_id": 4, "modifier_name": "Thick Crust", "price": 5}
      ]
    }
  ]
}
```

**Expected Behavior:**
- Returns modifiers from the **first** variation group only
- Second variation group is ignored

**Reason:** Function returns immediately upon finding first match

**Note:** If the API can return multiple variation groups (e.g., size AND crust type), this function would need to be updated to handle multiple groups or the UI would need multiple calls with different type filters.

### Edge Case 5: Variation Group with Null Modifiers
**Input:**
```dart
{
  "item_modifier_groups": [
    {
      "type": "Variation",
      "modifiers": null
    }
  ]
}
```

**Expected Behavior:**
- Returns `null`
- Check `modifiers != null` prevents error

### Edge Case 6: Variation Group with Empty Modifiers Array
**Input:**
```dart
{
  "item_modifier_groups": [
    {
      "type": "Variation",
      "modifiers": []
    }
  ]
}
```

**Expected Behavior:**
- Returns `null`
- Check `modifiers.isNotEmpty` handles empty array

### Edge Case 7: Non-Map Group Objects
**Input:**
```dart
{
  "item_modifier_groups": [
    "invalid",
    123,
    {
      "type": "Variation",
      "modifiers": [...]
    }
  ]
}
```

**Expected Behavior:**
- Skips invalid entries
- Returns modifiers from the valid variation group
- No error thrown

**Reason:** Check `group is Map` filters out invalid entries

### Edge Case 8: Case-Sensitive Type Matching
**Input:**
```dart
{
  "item_modifier_groups": [
    {
      "type": "variation",  // lowercase
      "modifiers": [...]
    }
  ]
}
```

**Expected Behavior:**
- Returns `null` (does NOT match)
- Type comparison is case-sensitive

**Important:** The function expects exactly `"Variation"` with capital V. If the API returns lowercase or other casing, the function will not match.

---

## Testing Checklist

### Unit Tests

- [ ] **Test 1: Valid item with variations**
  - Input: Complete item with variation-type modifiers
  - Expected: Returns list of modifier objects
  - Validates: Basic happy path

- [ ] **Test 2: Null input**
  - Input: `null`
  - Expected: Returns `null`
  - Validates: Null safety

- [ ] **Test 3: Empty map input**
  - Input: `{}`
  - Expected: Returns `null`
  - Validates: Missing keys handling

- [ ] **Test 4: Missing modifier_groups key**
  - Input: `{"item_id": 123, "item_name": "Test"}`
  - Expected: Returns `null`
  - Validates: Safe key access

- [ ] **Test 5: Empty modifier_groups array**
  - Input: `{"item_modifier_groups": []}`
  - Expected: Returns `null`
  - Validates: Empty array handling

- [ ] **Test 6: No variation type groups**
  - Input: Item with only "Addition" and "Substitution" groups
  - Expected: Returns `null`
  - Validates: Type filtering

- [ ] **Test 7: Variation group with empty modifiers**
  - Input: Variation group with `"modifiers": []`
  - Expected: Returns `null`
  - Validates: Empty modifiers handling

- [ ] **Test 8: Multiple variation groups**
  - Input: Item with two variation-type groups
  - Expected: Returns modifiers from **first** group only
  - Validates: Early return behavior

- [ ] **Test 9: Mixed valid and invalid groups**
  - Input: Array with strings, numbers, and valid maps
  - Expected: Skips invalid, returns valid variations
  - Validates: Type checking robustness

- [ ] **Test 10: Case-sensitive type matching**
  - Input: `{"type": "variation"}` (lowercase)
  - Expected: Returns `null`
  - Validates: Exact string matching

### Integration Tests

- [ ] **Test 11: Real menu API response**
  - Input: Actual API response from BuildShip menu endpoint
  - Expected: Correctly extracts variations
  - Validates: Production data compatibility

- [ ] **Test 12: Menu item without variations**
  - Input: Simple item from API (no modifiers)
  - Expected: Returns `null`, UI displays single price
  - Validates: Null handling in UI

- [ ] **Test 13: Menu item with size options**
  - Input: Pizza item with Small/Medium/Large
  - Expected: Returns 3 modifier objects
  - Validates: Common use case

- [ ] **Test 14: Display in ListView**
  - Input: Menu data with mixed items (some with/without variations)
  - Expected: Cards render correctly for both cases
  - Validates: UI rendering integration

- [ ] **Test 15: Bottom sheet variation selector**
  - Input: Item with 3 size variations
  - Expected: Radio buttons render, selection updates price
  - Validates: Interactive UI integration

### Performance Tests

- [ ] **Test 16: Large modifier groups array**
  - Input: Item with 50+ modifier groups
  - Expected: Returns first variation group efficiently
  - Validates: Early return optimization

- [ ] **Test 17: ListView with 100+ items**
  - Input: Menu with 100 items calling function for each
  - Expected: Smooth scrolling, no lag
  - Validates: Function performance at scale

### Edge Case Tests

- [ ] **Test 18: Malformed price values**
  - Input: Variation with `"price": "invalid"`
  - Expected: Function returns data, price validation handled by UI
  - Validates: Function doesn't validate modifier content

- [ ] **Test 19: Missing modifier_name**
  - Input: Variation modifier without name field
  - Expected: Function returns data, UI handles missing name
  - Validates: Function passes data as-is

- [ ] **Test 20: Extra fields in modifiers**
  - Input: Modifiers with additional unknown fields
  - Expected: Returns all fields, UI uses what it needs
  - Validates: Forward compatibility

---

## Migration Notes

### FlutterFlow → Pure Dart Migration

**Current Usage in FlutterFlow:**
- Custom function called in ListView builders
- Used in conditional visibility expressions
- Referenced in bottom sheet builders

**Migration Steps:**

1. **Copy function to shared utilities**
   ```dart
   // lib/shared/menu_utils.dart
   List<dynamic>? getVariationModifiers(dynamic itemData) {
     // ... existing implementation
   }
   ```

2. **Update imports in pages**
   ```dart
   import 'package:journeymate/shared/menu_utils.dart';
   ```

3. **Test in isolation**
   - Create unit tests first
   - Verify return values match FlutterFlow behavior

4. **Update UI components**
   - Replace FlutterFlow function calls with utility import
   - Test rendering in development environment

5. **Verify in production scenarios**
   - Test with real API data
   - Check all menu pages and sheets

### Type Safety Improvements

**Current Implementation:**
```dart
List<dynamic>? getVariationModifiers(dynamic itemData)
```

**Recommended Improvement:**
```dart
// Define strict types for menu data
class MenuItem {
  final int itemId;
  final String itemName;
  final double price;
  final List<ModifierGroup>? modifierGroups;
}

class ModifierGroup {
  final int groupId;
  final String type;
  final List<Modifier> modifiers;
}

class Modifier {
  final int modifierId;
  final String modifierName;
  final double price;
}

// Type-safe version
List<Modifier>? getVariationModifiers(MenuItem item) {
  if (item.modifierGroups == null) return null;

  for (final group in item.modifierGroups!) {
    if (group.type == ModifierType.variation && group.modifiers.isNotEmpty) {
      return group.modifiers;
    }
  }

  return null;
}
```

**Benefits:**
- Compile-time type checking
- Auto-completion in IDE
- Eliminates runtime type errors
- Better code documentation

### Error Handling Enhancement

**Current Implementation:**
- Silent failures (returns `null`)
- No error logging
- UI must handle null gracefully

**Recommended Improvement:**
```dart
import 'package:flutter/foundation.dart';

List<dynamic>? getVariationModifiers(dynamic itemData) {
  // Existing validation with logging
  if (itemData is! Map) {
    debugPrint('⚠️ getVariationModifiers: Invalid itemData type (${itemData.runtimeType})');
    return null;
  }

  final modifierGroups = itemData['item_modifier_groups'] as List?;
  if (modifierGroups == null) {
    debugPrint('⚠️ getVariationModifiers: Missing item_modifier_groups for item ${itemData['item_id']}');
    return null;
  }

  // ... rest of implementation
}
```

**Benefits:**
- Debugging visibility in development
- Production error tracking via logging service
- Helps identify API data issues

### Performance Optimization

**Current Implementation:**
- Linear search through all modifier groups
- No caching

**Recommended Optimization (if needed):**
```dart
// Cache variations at data parsing time
class MenuItem {
  // ... other fields

  late final List<Modifier>? _cachedVariations;

  List<Modifier>? get variations {
    _cachedVariations ??= _extractVariations();
    return _cachedVariations;
  }

  List<Modifier>? _extractVariations() {
    // ... extraction logic
  }
}
```

**When to use:**
- Menu items are accessed multiple times
- Large menus (100+ items)
- Variation display in multiple UI locations

**Trade-off:**
- Increased memory usage
- Complexity in data models
- Only worth it if profiling shows performance issues

---

## Common Pitfalls

### Pitfall 1: Assuming Variations Always Exist

**Incorrect:**
```dart
// This will crash if variations is null
final variations = getVariationModifiers(item);
final firstVariation = variations[0];
```

**Correct:**
```dart
final variations = getVariationModifiers(item);
if (variations != null && variations.isNotEmpty) {
  final firstVariation = variations[0];
  // Use firstVariation
} else {
  // Handle no variations case
}
```

### Pitfall 2: Case-Insensitive Type Matching

**Incorrect Assumption:**
```dart
// Function will match "Variation", "variation", "VARIATION"
```

**Reality:**
```dart
// Function ONLY matches exactly "Variation"
if (group['type'] == 'Variation') {  // Case-sensitive
```

**Solution:** If API returns different casing, update comparison:
```dart
if (group['type']?.toString().toLowerCase() == 'variation') {
```

### Pitfall 3: Modifying Returned Data

**Incorrect:**
```dart
final variations = getVariationModifiers(item);
variations?.add({'modifier_id': 999, 'modifier_name': 'New Size'});
// This modifies the original item data!
```

**Correct:**
```dart
final variations = getVariationModifiers(item);
if (variations != null) {
  final modifiedVariations = List.from(variations);
  modifiedVariations.add({'modifier_id': 999, 'modifier_name': 'New Size'});
  // Now safe to modify
}
```

### Pitfall 4: Not Handling Multiple Variation Groups

**Current Limitation:**
```dart
// Function returns ONLY the first variation group
// If item has multiple variation groups (e.g., size AND crust type),
// only the first one is returned
```

**Workaround (if API supports multiple groups):**
```dart
List<dynamic> getAllVariationGroups(dynamic itemData) {
  if (itemData is! Map) return [];

  final modifierGroups = itemData['item_modifier_groups'] as List?;
  if (modifierGroups == null) return [];

  final allVariations = <dynamic>[];
  for (final group in modifierGroups) {
    if (group is Map && group['type'] == 'Variation') {
      final modifiers = group['modifiers'] as List?;
      if (modifiers != null && modifiers.isNotEmpty) {
        allVariations.add(modifiers);
      }
    }
  }

  return allVariations;
}
```

### Pitfall 5: Ignoring Price Type

**Potential Issue:**
```dart
// Assuming price is always a number
final variation = variations[0];
final price = variation['price'] + 10;  // May fail if price is string
```

**Defensive Approach:**
```dart
final variation = variations[0];
final priceValue = variation['price'];
final price = priceValue is num ? priceValue.toDouble() : 0.0;
final total = price + 10;
```

---

## Related Documentation

**Other Menu Functions:**
- `convertAndFormatPrice()` - Formats prices with currency conversion
- `convertAndFormatPriceRange()` - Formats price ranges for items with variations
- `hasActiveFilters()` - Checks if menu filters are applied

**Menu Data Models:**
- Menu Item Structure - See `_reference/page-audit.md` → Menu Section
- Modifier Group Types - See API documentation for all modifier types

**UI Components:**
- MenuDishesListView - Uses this function to display variations
- MenuItemBottomSheet - Uses this function for variation selection
- SearchResultCard - Uses this function for variation indicators

**API Endpoints:**
- BuildShip Menu Endpoint - Returns menu data with modifier groups
- Menu Item Details Endpoint - Returns individual item with full modifier data

---

**Documentation Version:** 1.0
**Last Updated:** 2026-02-19
**Documented By:** Claude Code
**FlutterFlow Version:** Latest Export
**Migration Status:** Not yet migrated (still in FlutterFlow)
