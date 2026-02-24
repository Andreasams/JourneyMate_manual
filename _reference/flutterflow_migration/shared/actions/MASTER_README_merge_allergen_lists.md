# mergeAllergenLists Action

**Type:** Custom Action (Async)
**File:** `merge_allergen_lists.dart` (33 lines)
**Category:** Menu Filters (Utility)
**Status:** ✅ Production Ready
**Priority:** ⭐⭐ (Low - Simple utility)

---

## Purpose

Merges two allergen lists and removes duplicates. Used when dietary restrictions imply additional allergen exclusions (e.g., "Vegan" implies excluding dairy, eggs, honey).

**Key Features:**
- Combines current excluded allergens with new implied allergens
- Automatically removes duplicates using Set
- Simple, focused utility with no side effects

---

## Function Signature

```dart
Future<List<int>> mergeAllergenLists(
  List<int> currentExcludedAllergens,
  List<int> newImpliedAllergens,
)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `currentExcludedAllergens` | `List<int>` | **Yes** | Existing excluded allergen IDs |
| `newImpliedAllergens` | `List<int>` | **Yes** | New allergen IDs to add from dietary selection |

### Returns

| Type | Description |
|------|-------------|
| `Future<List<int>>` | Combined list with duplicates removed |

---

## Dependencies

**No external dependencies** - Pure Dart logic

---

## Usage Examples

### Example 1: User Selects Vegan Diet
```dart
// Current state: User manually excluded peanuts (ID 5)
final currentAllergens = [5];

// User selects "Vegan" dietary restriction
// Vegan implies: dairy (1), eggs (2), honey (3)
final veganImpliedAllergens = [1, 2, 3];

// Merge lists
final merged = await actions.mergeAllergenLists(
  currentAllergens,
  veganImpliedAllergens,
);

// Result: [5, 1, 2, 3] - peanuts + vegan allergens
```

### Example 2: Duplicate Handling
```dart
// User already excluded dairy manually
final currentAllergens = [1, 5]; // dairy, peanuts

// User selects "Vegetarian"
// Vegetarian implies: [1] (dairy - but already present)
final vegetarianImplied = [1];

// Merge
final merged = await actions.mergeAllergenLists(
  currentAllergens,
  vegetarianImplied,
);

// Result: [1, 5] - duplicates automatically removed
```

### Example 3: Empty Lists
```dart
// No current allergens
final merged = await actions.mergeAllergenLists([], [1, 2, 3]);
// Result: [1, 2, 3]

// No new allergens
final merged = await actions.mergeAllergenLists([1, 2, 3], []);
// Result: [1, 2, 3]

// Both empty
final merged = await actions.mergeAllergenLists([], []);
// Result: []
```

---

## Algorithm

```dart
1. Create a Set from currentExcludedAllergens (removes duplicates)
2. Add all newImpliedAllergens to Set (Set automatically handles duplicates)
3. Convert Set back to List
4. Return combined list
```

**Time Complexity:** O(n + m) where n = current list size, m = new list size
**Space Complexity:** O(n + m) for the Set

---

## Common Use Cases

### Dietary Restriction Mappings

| Dietary Restriction | Implied Allergens |
|--------------------|-------------------|
| Vegan | Dairy, Eggs, Honey |
| Vegetarian | None (or Dairy if strict) |
| Gluten-Free | Wheat, Barley, Rye |
| Lactose Intolerant | Dairy |
| Pescatarian | Red Meat, Poultry |

**Example Integration:**
```dart
Future<void> _onDietaryRestrictionSelected(int restrictionId) async {
  // Get implied allergens for this restriction
  final impliedAllergens = _getImpliedAllergens(restrictionId);

  // Merge with current allergens
  final mergedList = await actions.mergeAllergenLists(
    FFAppState().excludedAllergyIds,
    impliedAllergens,
  );

  // Update state
  FFAppState().update(() {
    FFAppState().excludedAllergyIds = mergedList;
  });

  // Refresh menu items
  _filterMenuItems();
}
```

---

## Testing Checklist

- [ ] Merge empty lists → returns empty list
- [ ] Merge with one empty list → returns other list
- [ ] Merge lists with no overlap → returns combined list
- [ ] Merge lists with complete overlap → returns deduplicated list
- [ ] Merge lists with partial overlap → returns union
- [ ] Verify order doesn't matter (Set unordered)
- [ ] Test with large lists (performance)

---

## Migration Notes

### Phase 3 Changes

**No changes needed** - Pure utility function, works with any state management.

```dart
// Works with FFAppState
final merged = await mergeAllergenLists(
  FFAppState().excludedAllergyIds,
  impliedIds,
);

// Works with Riverpod
final merged = await mergeAllergenLists(
  ref.read(menuFilterProvider).excludedAllergens,
  impliedIds,
);
```

---

## Related Actions

| Action | Purpose | Relationship |
|--------|---------|--------------|
| `updateMenuSessionFilterMetrics` | Track filter changes | Called after merge updates filters |
| `trackFilterReset` | Track filter resets | Called when merged list cleared |

---

## Used By Pages

1. **Menu Full Page** - Dietary restriction selector

---

## Known Issues

**None** - Simple, well-defined utility function.

---

**Last Updated:** 2026-02-19
**Migration Status:** ✅ No migration needed - Pure utility
**Next Step:** Phase 3 - Use as-is
