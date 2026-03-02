# Filter Greying Feature - Implementation Task

## Status
**NOT IMPLEMENTED** (Present in FlutterFlow version, missing in production Flutter app)

---

## Problem Statement

**What's Missing:**
When users browse filters in the filter bottom sheet, ALL filter options are displayed with full color/opacity, even if selecting them would return zero restaurant results. This differs from the FlutterFlow version, which visually distinguished unavailable filters.

**User Impact:**
- Users cannot see which filters are actually available for the current search context
- No visual feedback to prevent "dead-end" filter selections that would return zero results
- Users must guess-and-check which filters will work, leading to frustration
- The intended UX feature from Typesense faceting (via `activeids`) is not surfaced to users

**Exception:**
Shopping area filters ARE handled correctly - they are completely hidden if not in `activeids` (see `filter_overlay_widget.dart:418`). This task is about the OTHER filter types (cuisine, dietary, amenities, etc.).

---

## Technical Background

### What is `activeids`?

The BuildShip search API returns an `activeids` field (also called `activeFilterIds` in Flutter code) which contains the IDs of filters that are present in the current search result set.

**Example:**
- User searches with no filters → API returns 50 restaurants
- API also returns `activeids: [1, 5, 8, 12, 15, ...]` (filters present in those 50 restaurants)
- If filter ID 99 is NOT in `activeids`, selecting it would return zero results
- **Expected behavior**: Filter 99 should be greyed out to show it's unavailable

### Current Data Flow (Already Working)

1. **API Response** (`search` endpoint):
   ```json
   {
     "documents": [...],
     "activeids": [1, 5, 8, 12, 15],  ← Available filter IDs
     "resultCount": 50,
     "fullMatchCount": 20
   }
   ```

2. **State Management** (`search_page.dart:299`):
   ```dart
   ref.read(searchStateProvider.notifier).updateActiveFilterIds(activeIds);
   ```
   ✅ Data is stored in provider

3. **Widget Prop** (`search_page.dart:295`):
   ```dart
   FilterOverlayWidget(
     activeFilterIds: searchState.activeFilterIds,  ← Passed to widget
     ...
   )
   ```
   ✅ Data is passed to FilterOverlayWidget

4. **Widget State** (`filter_overlay_widget.dart:75, 363-365`):
   ```dart
   final List<int> activeFilterIds;  // Received as prop

   if (!listEquals(oldWidget.activeFilterIds, widget.activeFilterIds)) {
     debugPrint('🔍 FilterOverlay: Received ${widget.activeFilterIds.length} active filters');
   }
   ```
   ✅ Widget receives and tracks the data

### Current Usage of `activeFilterIds`

**What's Already Implemented:**

1. **Shopping Area Filtering** (line 418):
   ```dart
   if (categoryId == _shoppingAreaCategoryId) {
     return items
         .where((item) => widget.activeFilterIds.contains(item['id'] as int?))
         .toList();
   }
   ```
   ✅ Shopping areas not in `activeFilterIds` are completely hidden

2. **Badge Visibility Logic** (lines 561-616):
   ```dart
   if (widget.activeFilterIds.isEmpty && _searchPerformed) {
     return _hasActiveChildrenDuringEmptySearch(parentId, filterType);
   }
   return _hasActiveChildrenStandard(parentId, filterType);
   ```
   ✅ Category badges show/hide based on available filters

3. **Sub-item Active State** (lines 602, 609, 612):
   ```dart
   return subitems.any((subitem) =>
       widget.activeFilterIds.contains(subitem['id'] as int));
   ```
   ✅ Used to determine if parent items should show as "active"

**What's Missing:**
- ❌ Visual styling (greyed text, reduced opacity, disabled appearance) for filter chips NOT in `activeFilterIds`
- ❌ Applies to ALL filter types except shopping areas (cuisine, dietary, ambience, amenities, etc.)

---

## FlutterFlow Implementation (Reference)

**Where to look:**
The FlutterFlow export (local reference copy) likely has this implemented. Check:
- Filter panel components
- Filter chip/button styling logic
- Conditional styling based on `activeFilterIds` membership

**Key question to answer:**
- What visual style was used? (Greyed text? Reduced opacity? Different background color?)
- Was interaction disabled, or just visual feedback?
- Were unavailable filters clickable (with feedback) or truly disabled?

---

## Implementation Approach

### Files to Modify

1. **`journey_mate/lib/widgets/shared/filter_overlay_widget.dart`**
   - Primary file for filter rendering
   - Contains all filter chip/button UI logic
   - Already has access to `widget.activeFilterIds`

### Key Areas to Investigate

1. **Filter Item Rendering** (search for where filter chips/buttons are built):
   - Find where individual filter options are rendered as tappable widgets
   - Likely in methods that build ListView items for categories/items/sub-items
   - Look for `ListTile`, `GestureDetector`, `InkWell`, or custom filter widgets

2. **Current Styling Logic**:
   - Check if there's conditional styling for selected filters (`_selectedFilterIds.contains(id)`)
   - This is where we'll add parallel logic for unavailable filters

3. **Text/Color Styling**:
   - Look for `TextStyle` and `Color` properties in filter chip rendering
   - Need to add conditional logic: if NOT in `activeFilterIds`, apply grey styling

### Proposed Visual Design

**Available Filter** (IN `activeFilterIds`):
- Text color: `AppColors.primaryText` (or current normal color)
- Opacity: 1.0 (fully opaque)
- Background: Normal (white/grey based on selection state)
- Interactive: Fully clickable

**Unavailable Filter** (NOT IN `activeFilterIds`):
- Text color: `AppColors.secondaryText` or `AppColors.primaryText.withValues(alpha: 0.4)`
- Opacity: 0.4-0.5 (visually subdued)
- Background: Could remain same or use lighter grey
- Interactive: **Decision needed** - should it be clickable (with feedback) or disabled?

**Design Token Usage:**
- Use `AppColors` for all color values (no raw hex)
- Consider adding `AppColors.disabledText` if not already present
- Follow existing selected filter styling patterns

### Implementation Steps

1. **Locate filter chip rendering code** in `filter_overlay_widget.dart`
   - Search for methods that build category lists, item lists, sub-item lists
   - Find where `Text()` widgets are created for filter labels

2. **Add conditional styling logic**:
   ```dart
   // Example approach (adapt to actual code structure)
   final isAvailable = widget.activeFilterIds.contains(filterId);
   final textColor = isAvailable
       ? AppColors.primaryText
       : AppColors.primaryText.withValues(alpha: 0.4);

   Text(
     filterLabel,
     style: AppTypography.bodyMedium.copyWith(color: textColor),
   )
   ```

3. **Handle shopping areas** (already working):
   - No changes needed - shopping areas are already hidden when unavailable
   - Keep existing logic at line 418

4. **Test thoroughly**:
   - Apply filters → verify unavailable options grey out
   - Reset filters → verify all options return to normal color
   - Toggle individual filters → verify availability updates in real-time
   - Check all filter categories (cuisine, dietary, ambience, amenities, etc.)

### Edge Cases to Consider

1. **Empty Search (No Active Filters):**
   - When `activeFilterIds.isEmpty`, should all filters show as available?
   - Check existing logic at line 561: `if (widget.activeFilterIds.isEmpty && _searchPerformed)`

2. **Parent-Child Relationships:**
   - If a parent category has NO available children, should parent be greyed?
   - Already handled by badge visibility logic (lines 561-616)

3. **Selected but Unavailable:**
   - Can a filter be selected (`_selectedFilterIds`) but unavailable (`activeFilterIds`)?
   - What should visual priority be? (Probably show as selected + greyed)

4. **Real-time Updates:**
   - When user toggles filter A, `activeFilterIds` changes
   - Ensure filter B immediately greys out if it becomes unavailable
   - Already handled by `didUpdateWidget` at line 363

---

## Testing Checklist

After implementation:

- [ ] **Cuisine filters**: Unavailable options greyed out
- [ ] **Dietary filters**: Unavailable options greyed out
- [ ] **Ambience filters**: Unavailable options greyed out
- [ ] **Amenities filters**: Unavailable options greyed out
- [ ] **Shopping areas**: Continue to be hidden (not greyed, existing behavior)
- [ ] **Train stations**: Check behavior (might be special case like shopping areas)
- [ ] **Selected + unavailable**: Visual state clearly shows both states
- [ ] **Reset button**: All filters return to normal color (activeFilterIds repopulated)
- [ ] **Real-time updates**: Greying updates immediately when filters toggle
- [ ] **Empty search**: Appropriate handling when activeFilterIds is empty

---

## Code Quality Requirements

Before committing:

- [ ] All colors from `AppColors` (no raw hex values)
- [ ] All spacing from `AppSpacing` (no magic numbers)
- [ ] All typography from `AppTypography` (no inline TextStyle)
- [ ] `flutter analyze` passes with no new warnings
- [ ] Follow existing selected filter styling patterns
- [ ] Add code comments explaining greying logic
- [ ] Test on both light mode (current) and dark mode (future-proofing)

---

## References

- **BuildShip API**: `_reference/BUILDSHIP_API_REFERENCE.md` (lines 50-66) - `activeids` field documentation
- **Current Implementation**: `filter_overlay_widget.dart` (lines 363-365, 418, 561-616) - existing activeFilterIds usage
- **Design Tokens**: `DESIGN_SYSTEM_flutter.md` - color/typography standards
- **FlutterFlow Reference**: Local FlutterFlow export (check filter panel styling)

---

## Priority

**Medium-High**

This is a UX regression from the FlutterFlow version. While the app is functional without it, users lack important visual feedback that was present in the previous version. Should be implemented in next maintenance cycle.

---

## Estimated Effort

**2-4 hours**

- 30 min: Locate filter chip rendering code
- 30 min: Check FlutterFlow reference for exact styling approach
- 1 hour: Implement conditional styling logic
- 30 min: Handle edge cases (empty search, parent-child, selected+unavailable)
- 1 hour: Test all filter categories thoroughly
- 30 min: Code review, cleanup, commit

---

## Related Issues

- ✅ **FIXED** (commit 22c5033): Search results now update when filters change
- ✅ **FIXED** (commits c2a400f-bd3f4f8): Badge counts now update reactively
- ❌ **THIS TASK**: Filter greying not implemented (missing FlutterFlow feature)

---

**Created:** 2026-03-02
**Status:** Documented, Not Started
**Owner:** TBD
