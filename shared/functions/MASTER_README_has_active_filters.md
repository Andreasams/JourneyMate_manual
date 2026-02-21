# hasActiveFilters Function

**Type:** Custom Function (Pure)
**File:** `custom_functions.dart` (lines 2352-2383)
**Category:** Menu Filtering
**Status:** ✅ Production Ready

---

## Purpose

Determines if any menu filters are currently active. Checks both dietary type filters (preferences/restrictions) and allergen exclusion filters.

**Key Feature:** Single source of truth for determining if "Ryd alle" (Clear all) button should be visible and if menu items need filtering.

---

## Function Signature

```dart
bool hasActiveFilters(
  int? selectedDietaryTypeId,
  List<int>? excludedAllergyIds,
)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `selectedDietaryTypeId` | `int?` | No | Currently selected dietary preference or restriction ID, or null if none |
| `excludedAllergyIds` | `List<int>?` | No | List of excluded allergen IDs, or null/empty if none |

**Note:** Dietary preferences (vegan/vegetarian/pescetarian) and dietary restrictions (gluten-free/lactose-free/halal/kosher) are mutually exclusive in the UI but share the same underlying `dietary_type_id` system, so they're tracked by a single ID parameter.

### Returns

| Type | Description |
|------|-------------|
| `bool` | `true` if any filter is active, `false` if all filters are cleared |

---

## Implementation

```dart
bool hasActiveFilters(
  int? selectedDietaryTypeId,
  List<int>? excludedAllergyIds,
) {
  // Check dietary type filter (preference OR restriction)
  final hasDietaryType = selectedDietaryTypeId != null;

  // Check allergen exclusion filters
  final hasAllergenExclusions =
      excludedAllergyIds != null && excludedAllergyIds.isNotEmpty;

  // Return true if ANY filter is active
  return hasDietaryType || hasAllergenExclusions;
}
```

**Logic:** Returns true if **either** dietary type OR allergen exclusions exist.

---

## Dependencies

### pub.dev Packages
- None (pure Dart function)

### Internal Dependencies
- None

---

## Filter Type Breakdown

### Dietary Type Filter (One Selection)

**Dietary Preferences (Mutually Exclusive):**
- ID 1: Vegan
- ID 2: Vegetarian
- ID 3: Pescetarian

**Dietary Restrictions (Mutually Exclusive with Preferences):**
- ID 4: Gluten-free
- ID 5: Lactose-free
- ID 6: Halal
- ID 7: Kosher

**UI Behavior:**
- User can select **ONE** dietary type at a time
- Selecting a preference clears any restriction, and vice versa
- Stored as single `int?` value

### Allergen Exclusions (Multiple Selection)

**14 Allergen Types:**
1. Gluten (cereals)
2. Crustaceans
3. Eggs
4. Fish
5. Peanuts
6. Soybeans
7. Milk (dairy)
8. Nuts (tree nuts)
9. Celery
10. Mustard
11. Sesame seeds
12. Sulfur dioxide/sulfites
13. Lupin
14. Mollusks

**UI Behavior:**
- User can select **MULTIPLE** allergens
- Stored as `List<int>`

---

## Usage Examples

### Example 1: No Filters Active
```dart
final hasFilters = functions.hasActiveFilters(
  null,  // No dietary type
  null,  // No allergen exclusions
);
// Returns: false
```

### Example 2: Only Dietary Type Active
```dart
final hasFilters = functions.hasActiveFilters(
  1,     // Vegan selected
  null,  // No allergen exclusions
);
// Returns: true
```

### Example 3: Only Allergen Exclusions Active
```dart
final hasFilters = functions.hasActiveFilters(
  null,        // No dietary type
  [1, 7, 8],   // Gluten, Milk, Nuts excluded
);
// Returns: true
```

### Example 4: Both Filters Active
```dart
final hasFilters = functions.hasActiveFilters(
  2,           // Vegetarian selected
  [3, 4],      // Eggs and Fish excluded
);
// Returns: true
```

### Example 5: Empty Allergen List
```dart
final hasFilters = functions.hasActiveFilters(
  null,  // No dietary type
  [],    // Empty allergen list
);
// Returns: false (empty list treated same as null)
```

---

## Used By Pages

| Page | Purpose | Controls |
|------|---------|----------|
| **Menu Full Page** | Determine if "Ryd alle" button should show | Button visibility |
| **Menu Full Page** | Determine if menu items need filtering | Item visibility logic |

---

## Used By Custom Widgets

| Widget | Purpose | Implementation |
|--------|---------|----------------|
| `MenuDishesListView` | Apply filters to menu items | Iterates items, checks against filters |
| `AllergiesFilterWidget` | Show active allergen count | Badge display |
| `DietaryPreferencesFilterWidgets` | Show selected dietary type | Highlight selected option |

---

## Edge Cases Handled

### Edge Case 1: Null Parameters
**Input:**
```dart
hasActiveFilters(null, null)
```
**Returns:** `false`
**Meaning:** No filters active

### Edge Case 2: Empty List vs Null
**Input:**
```dart
hasActiveFilters(null, [])
```
**Returns:** `false`
**Meaning:** Empty list treated same as null - no filters active

### Edge Case 3: Zero as Dietary Type ID
**Input:**
```dart
hasActiveFilters(0, null)
```
**Returns:** `true`
**Meaning:** `0` is considered a valid ID (though not used in practice)
**Recommendation:** Validate dietary IDs are positive before calling

### Edge Case 4: Negative Dietary Type ID
**Input:**
```dart
hasActiveFilters(-1, null)
```
**Returns:** `true`
**Meaning:** Function doesn't validate ID values - any non-null int returns true
**Recommendation:** Validate IDs in calling code

---

## UI Integration

### "Ryd alle" Button Visibility

```dart
// Show "Clear all" button only if filters active
if (functions.hasActiveFilters(
  FFAppState().selectedDietaryTypeId,
  FFAppState().excludedAllergenIds,
)) {
  // Show button
  FFButtonWidget(
    text: FFLocalizations.of(context).getText('ryd_alle'),
    onPressed: () {
      // Clear filters
      FFAppState().selectedDietaryTypeId = null;
      FFAppState().excludedAllergenIds = [];
      safeSetState(() {});
    },
  )
}
```

### Filter Badge Count

```dart
// Show count of active filters
final activeCount =
    (FFAppState().selectedDietaryTypeId != null ? 1 : 0) +
    (FFAppState().excludedAllergenIds?.length ?? 0);

if (activeCount > 0) {
  Badge(
    label: Text('$activeCount'),
    // ...
  )
}
```

### Menu Item Filtering

```dart
// Filter menu items based on active filters
final filteredItems = allMenuItems.where((item) {
  // If no filters, show all items
  if (!functions.hasActiveFilters(
    FFAppState().selectedDietaryTypeId,
    FFAppState().excludedAllergenIds,
  )) {
    return true;
  }

  // Apply dietary type filter
  if (FFAppState().selectedDietaryTypeId != null) {
    if (!item.dietaryTypes.contains(FFAppState().selectedDietaryTypeId)) {
      return false;
    }
  }

  // Apply allergen exclusions
  if (FFAppState().excludedAllergenIds != null) {
    for (final allergenId in FFAppState().excludedAllergenIds!) {
      if (item.allergens.contains(allergenId)) {
        return false; // Item contains excluded allergen
      }
    }
  }

  return true;
}).toList();
```

---

## Performance Considerations

### Time Complexity
- **O(1)** - Two null checks, one isEmpty check

### Memory Usage
- **O(1)** - No allocations

### Execution Time
- **< 1 microsecond** - Extremely fast

### Optimization Notes
- Already optimal
- Pure function - safe to call frequently
- No caching needed

---

## Testing Checklist

When implementing in Flutter:

- [ ] Test with both parameters null - returns false
- [ ] Test with dietary type only - returns true
- [ ] Test with allergens only - returns true
- [ ] Test with both active - returns true
- [ ] Test with empty allergen list - returns false
- [ ] Test with dietary type = 0 - returns true
- [ ] Test with dietary type = -1 - returns true (no validation)
- [ ] Test button visibility - appears/disappears correctly
- [ ] Test filter badge count - shows correct number
- [ ] Test menu filtering - items filtered correctly
- [ ] Test clearing filters - hasActiveFilters returns false
- [ ] Test rapid calls - consistent results

---

## Migration Notes

### Phase 3 Changes

**No changes needed** - pure Dart function with no FlutterFlow dependencies.

**Update calling code** to use new state management:
```dart
// Before (FFAppState):
functions.hasActiveFilters(
  FFAppState().selectedDietaryTypeId,
  FFAppState().excludedAllergenIds,
)

// After (Riverpod example):
functions.hasActiveFilters(
  ref.watch(dietaryFilterProvider),
  ref.watch(allergenFiltersProvider),
)
```

---

## Related Functions

| Function | Relationship |
|----------|-------------|
| `convertAllergiesToString` | Formats allergen list for display |
| `convertDietaryPreferencesToString` | Formats dietary type for display |
| `getDietaryAndAllergyTitleTranslations` | Gets section headers for filter UI |

---

## Related Actions

| Action | Relationship |
|--------|-------------|
| `updateMenuSessionFilterMetrics` | Tracks filter usage stats |
| `mergeAllergenLists` | Combines allergen lists from menu items |

---

## Known Issues

1. **No ID validation** - Accepts any integer, including negative/invalid IDs
2. **No maximum allergen limit** - Could accept 1000+ allergen IDs (unrealistic but not prevented)
3. **Treats 0 as valid** - Zero dietary type ID returns true (though 0 not used in practice)

**None of these are critical** - calling code should validate IDs before passing to function.

---

**Last Updated:** 2026-02-19
**Migration Status:** ✅ Phase 3 - No changes needed (pure Dart)
**Priority:** ⭐⭐⭐ Medium-High (critical for menu filtering UX)
