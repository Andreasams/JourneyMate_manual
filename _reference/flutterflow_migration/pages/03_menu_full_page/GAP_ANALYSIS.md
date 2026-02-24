# Menu Full Page — Gap Analysis

**Purpose:** Identify functional differences between JSX v2 design and FlutterFlow implementation

**Methodology:** Compare DESIGN_README_menu_full_page.md (JSX v2) with PAGE_README.md + BUNDLE.md (FlutterFlow)

**Date:** 2026-02-19

---

## Gap Categories

- **A1**: Buildable with existing data (Frontend logic after API response)
- **A2**: Buildable with existing data (Backend logic in BuildShip before return)
- **B**: Requires BuildShip API changes
- **C**: Translation infrastructure gaps (new keys needed)
- **D**: Known missing features (user-identified, not in current scope)

---

## Summary

| Category | Count | Description |
|----------|-------|-------------|
| A1 | 1 | Frontend display logic |
| A2 | 0 | Backend processing logic |
| B | 0 | API endpoint changes |
| C | 6 | Translation keys needed |
| D | 0 | Known future features |
| **Total** | **7** | **Functional gaps identified** |

---

## Observation: FlutterFlow More Comprehensive Than JSX Design

The FlutterFlow implementation is **significantly more feature-rich** than the JSX v2 design. Features in FlutterFlow but NOT in JSX:

1. **Package navigation** - `PackageBottomSheetWidget` for multi-course menus
2. **Category description modal** - `CategoryDescriptionSheetWidget` for category info
3. **Menu session tracking** - `startMenuSession`, `endMenuSession`, `updateMenuSessionFilterMetrics`
4. **Visible item count display** - "Showing X items matching..." text
5. **"Ryd alle" button** - Clear all filters with one tap (in UnifiedFiltersWidget)
6. **Multi-select dietary restrictions** - Can select both gluten-free AND lactose-free
7. **Adaptive filter panel height** - Adjusts for bold text accessibility
8. **Dynamic category row height** - 1-row or 2-row layout based on content

**All of these enhancements should be preserved during migration.**

---

## Detailed Gap Analysis

### Gap A1.1: Category-Specific Info Blocks

**JSX v2 Design:**
- Shows conditional info blocks for specific categories
- Example: "Burger" category shows: "Vælg mellem fuldkorn eller glutenfri bolle (+ 10 kr.)"
- Info icon (14px circle, "i") next to text
- Code reference: `DESIGN_README_menu_full_page.md` lines 359-392

**FlutterFlow Implementation:**
- `MenuDishesListView` displays menu items
- Unknown if category-specific info blocks are implemented
- May be handled in category description sheet instead

**Gap:**
Verify if MenuDishesListView displays category-specific info blocks. If not, add:
1. Check if category data includes `info` field
2. Render conditional info block after category heading
3. Display "i" icon with tap gesture to expand explanation
4. Or use existing CategoryDescriptionSheetWidget for detailed info

**Architecture Recommendation:** Frontend (A1)
- Simple conditional rendering based on category data
- No API changes needed (info text comes from menu data)
- May already be implemented via CategoryDescriptionSheetWidget

**Implementation Notes:**
- JSX shows inline info text with "i" icon
- FlutterFlow may have moved this to CategoryDescriptionSheetWidget (modal)
- Both approaches are valid — verify which is implemented

---

### Gap C.1: Filter Section Translations

**JSX v2 Design:**
- Filter toggle: "Vis filtre" / "Skjul filtre" (already in FlutterFlow as keys `bwvizajd` / `1smig27j`)
- Filter section labels:
  - "Kostrestriktioner" (Dietary Restrictions)
  - "Kostpræferencer" (Dietary Preferences)
  - "Allergener" (Allergens)
- Explainer text for each section
- Code reference: `DESIGN_README_menu_full_page.md` lines 214-260

**FlutterFlow Implementation:**
- UnifiedFiltersWidget handles all three sections
- Translation keys exist for toggle ("Show filters" / "Hide filters")
- Unknown if section labels and explainer text are translated

**Translation Keys Needed:**

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `filter_restrictions_label` | Dietary restrictions section header | Dietary Restrictions | Kostrestriktioner |
| `filter_restrictions_explain` | Explainer text for restrictions | Show only dishes that meet the selected dietary restriction. | Vis kun retter, der overholder den valgte kostrestriktion. |
| `filter_preferences_label` | Dietary preferences section header | Dietary Preferences | Kostpræferencer |
| `filter_preferences_explain` | Explainer text for preferences | Show only dishes that meet the selected diet. | Vis kun retter, der overholder den valgte diæt. |
| `filter_allergens_label` | Allergens section header | Allergens | Allergener |
| `filter_allergens_explain` | Explainer text for allergens | Hide dishes that contain the selected allergen. | Skjul retter, der indeholder det valgte allergen. |

**Note:** Individual filter names (Vegan, Gluten-free, etc.) are already in Supabase `translations` table.

---

### Gap C.2: Menu Page Heading Translations

**JSX v2 Design:**
- Page heading: "Menu"
- Last updated prefix: "Sidst ajurført den"
- Code reference: `DESIGN_README_menu_full_page.md` lines 132-157

**FlutterFlow Implementation:**
- Translation key `foeokmwh` = "Menu"
- Translation key `sgpknl00` = "Last brought up to date on "
- These already exist

**No Gap:** These keys already exist in FlutterFlow. Verify they're in MASTER_TRANSLATION_KEYS.md for consistency.

---

### Gap C.3: Filter Chip Default State Translations

**JSX v2 Design:**
- Pre-selected allergens: "Blødyr", "Fisk", "Jordnødder"
- These are data values, not UI strings
- Code reference: `DESIGN_README_menu_full_page.md` lines 241-253

**No Gap:** Allergen names are already in Supabase `translations` table as filter data. Default selections are app logic, not translation keys.

---

### Gap C.4: Empty State Translations

**JSX v2 Design:**
- Not explicitly documented in Menu Full page design
- Should show message when no items match filters

**FlutterFlow Implementation:**
- MenuDishesListView likely has empty state
- Unknown what translation keys are used

**Translation Keys Needed:**

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `menu_no_items_title` | Empty state heading when no items match | No dishes found | Ingen retter fundet |
| `menu_no_items_body` | Empty state description | Try adjusting your filters or select 'Clear all' to see the full menu. | Prøv at justere dine filtre eller vælg 'Ryd alle' for at se hele menuen. |

**Note:** These may overlap with Business Profile empty state translations. Verify to avoid duplication.

---

### Gap C.5: Category Navigation Translations

**JSX v2 Design:**
- Category names are data-driven (from menu categories)
- Examples: "Mød", "Drikke", "Burger", "Poké bowls", "Classic bowls", "Sand"
- Code reference: `DESIGN_README_menu_full_page.md` lines 277-332

**Implementation Note:**
Category names should already be in Supabase `translations` table as part of menu data structure. Verify with BuildShip MenuItemsAPI response. If missing, add to translations table as **data**, not UI keys.

**No Gap:** Category names are data, not UI strings.

---

### Gap C.6: Visible Item Count Display Translation

**JSX v2 Design:**
- Not explicitly documented in JSX design
- FlutterFlow enhancement

**FlutterFlow Implementation:**
- Shows "Showing X items matching..." text when filters active
- Uses `generateFilterSummary()` function
- Code reference: `BUNDLE.md` lines 78-85

**Translation Keys Needed:**

| Key | Context | English (en) | Danish (da) | Parameters |
|-----|---------|--------------|-------------|------------|
| `menu_showing_count` | Filter summary text | Showing {count} items | Viser {count} retter | `{count}` |
| `menu_showing_count_filtered` | Filter summary with filter description | Showing {count} items matching your filters | Viser {count} retter der matcher dine filtre | `{count}` |

**Usage Example:**
```dart
// "Viser 12 retter der matcher dine filtre"
final text = getTranslations(lang, 'menu_showing_count_filtered', cache)
  .replaceAll('{count}', '12');
```

---

### Gap C.7: "Ryd alle" Button Translation

**JSX v2 Design:**
- Not explicitly shown in JSX Menu Full page design
- Likely inherited from filter design patterns
- Code reference: Mentioned in Business Profile filter section

**FlutterFlow Implementation:**
- "Ryd alle" button in UnifiedFiltersWidget
- Clears all filters with one tap
- Code reference: `PAGE_README.md` line 24

**Translation Keys Needed:**

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `filter_clear_all` | Clear all filters button | Clear all | Ryd alle |

**Note:** This key may already exist in Business Profile translations. Verify to avoid duplication.

---

## Features in FlutterFlow NOT in JSX Design

These are enhancements that exist in FlutterFlow but weren't specified in the JSX v2 design. They should be preserved during migration.

### Enhancement 1: Package Navigation
- **Widget:** `PackageBottomSheetWidget`
- **Purpose:** Multi-course menu package exploration
- **Usage:** Tap package item → opens package detail modal
- **Keep:** Yes, packages are a valid menu item type

### Enhancement 2: Category Description Modal
- **Widget:** `CategoryDescriptionSheetWidget`
- **Purpose:** Detailed category information and customization options
- **Usage:** Tap "i" icon next to category → opens description
- **Keep:** Yes, improves UX for complex menu categories

### Enhancement 3: Menu Session Tracking
- **Actions:** `startMenuSession`, `endMenuSession`, `updateMenuSessionFilterMetrics`
- **Purpose:** Track time spent browsing menu and filter usage patterns
- **Keep:** Yes, valuable analytics for understanding user behavior

### Enhancement 4: Visible Item Count Display
- **Feature:** "Showing X items matching..." text
- **Purpose:** Show how many items match current filters
- **Keep:** Yes, provides feedback on filter effectiveness

### Enhancement 5: Multi-Select Dietary Restrictions
- **Feature:** Can select multiple restrictions (e.g., gluten-free AND lactose-free)
- **State:** `FFAppState().selectedDietaryRestrictionId` is List<int>
- **Purpose:** Support users with multiple dietary restrictions
- **Keep:** Yes, critical for users with multiple needs

### Enhancement 6: Adaptive Filter Panel Height
- **Feature:** Filter panel height adjusts based on bold text setting
- **Logic:** `385px` if bold text enabled, `350px` otherwise
- **Purpose:** Accommodate larger text for accessibility
- **Keep:** Yes, essential for accessibility

### Enhancement 7: Dynamic Category Row Height
- **Feature:** Category chips display in 1 or 2 rows based on content
- **Logic:** Height `42px` (1 row) or `72px` (2 rows)
- **Purpose:** Optimize space for varying numbers of categories
- **Keep:** Yes, improves layout flexibility

---

## Migration Notes

### High Priority Gaps
1. **Gap C.1-C.7**: All translation keys (blocking international launch)
2. **Gap A1.1**: Category-specific info blocks (verify implementation)

### Medium Priority Gaps
None identified.

### Low Priority Gaps
None identified.

---

## Architecture Summary

### Frontend Logic (A1) - 1 gap
- Category-specific info blocks (may already be implemented via CategoryDescriptionSheetWidget)

### Backend Logic (A2) - 0 gaps
No gaps requiring backend processing before returning data to Flutter.

### API Changes (B) - 0 gaps
No API modifications needed. Menu data structure is sufficient.

### Translation Keys (C) - 6 gaps
- 13 translation keys needed across filter sections and empty states
- Most filter-related keys likely already exist in UnifiedFiltersWidget
- Need to extract and add to MASTER_TRANSLATION_KEYS.md

### Known Missing (D) - 0 gaps
No features explicitly marked as "not in current scope" by user.

---

## Next Steps

1. **Add translation keys to MASTER_TRANSLATION_KEYS.md**
   - All 13 keys identified in gaps C.1-C.7
   - Include English and Danish translations
   - Note parameters for dynamic text
   - Check for duplication with Business Profile keys

2. **Verify FlutterFlow implementations**
   - Read MenuDishesListView source for category info blocks
   - Read UnifiedFiltersWidget source for translation keys
   - Confirm which keys already exist vs need to be added

3. **Continue gap analysis for remaining pages**
   - Gallery Full page
   - Settings page
   - Welcome/Onboarding
   - Contact Details
   - User Profile
   - Map View

---

**Last Updated:** 2026-02-19
**Status:** ✅ Complete
**Total Gaps:** 7 (1 frontend + 0 backend + 0 API + 6 translation + 0 known missing)

**Key Finding:** FlutterFlow implementation is MORE comprehensive than JSX design. All enhancements should be preserved during migration.
