# UnifiedFiltersWidget — MASTER README

**Last Updated:** 2026-02-19
**FlutterFlow Source:** `_flutterflow_export/lib/custom_code/widgets/unified_filters_widget.dart`
**Status:** ✅ Production — Multi-restriction filtering with allergen coordination

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Parameters](#parameters)
4. [State Management](#state-management)
5. [Filter Types & Logic](#filter-types--logic)
6. [Allergen-Dietary Coordination](#allergen-dietary-coordination)
7. [Visible Item Count Calculation](#visible-item-count-calculation)
8. [User Interactions](#user-interactions)
9. [Analytics Tracking](#analytics-tracking)
10. [Translation Support](#translation-support)
11. [Visual Design](#visual-design)
12. [Implementation Notes](#implementation-notes)
13. [Migration Checklist](#migration-checklist)

---

## Overview

### Purpose

`UnifiedFiltersWidget` is a comprehensive filtering interface that combines three filter types into a single, coordinated widget for menu item filtering:

1. **Dietary Restrictions** (multi-select) — gluten-free, lactose-free, halal, kosher
2. **Dietary Preferences** (single-select) — vegan, vegetarian, pescatarian
3. **Allergen Exclusions** (multi-select) — 14 allergen types to hide items containing them

### Key Capabilities

- **Multi-restriction support** — users can select multiple dietary restrictions simultaneously (e.g., gluten-free + lactose-free)
- **Auto-coordination logic** — automatically selects/deselects dietary filters when allergens are toggled to maintain logical consistency
- **Real-time item count** — calculates and reports the number of visible menu items based on current filter state
- **Can-be-made override** — shows items that can be adapted to meet dietary needs, even if they contain allergens
- **Comprehensive analytics** — tracks every filter interaction with detailed event metadata

### Context

This widget appears on the Full Menu page and provides the primary filtering mechanism for users to narrow down menu items based on their dietary needs and allergen sensitivities. It replaces the simpler filter approach from v1 with a unified, intelligent system.

---

## Architecture

### Component Hierarchy

```
UnifiedFiltersWidget (StatefulWidget)
└── Container (rounded, semi-transparent background)
    └── Column
        ├── Header Row (title + reset button)
        ├── Dietary Restrictions Section
        │   ├── Header + Description
        │   └── Horizontal ListView (scrollable pills)
        ├── Dietary Preferences Section
        │   ├── Header + Description
        │   └── Horizontal ListView (scrollable pills)
        └── Allergen Exclusions Section
            ├── Header + Description
            └── Horizontal ListView (scrollable pills)
```

### Data Flow

```
FFAppState (global filter state)
    ↓
UnifiedFiltersWidget (reads state)
    ↓
User Interaction (tap pill)
    ↓
Validation & Coordination Logic
    ↓
FFAppState update (new filter values)
    ↓
Menu Data Filtering (calculate visible count)
    ↓
Parent Notification (onFiltersChanged, onVisibleItemCountChanged)
    ↓
Parent Widget Rebuilds (updates menu display)
```

### State Dependencies

**Reads from FFAppState:**
- `selectedDietaryRestrictionId` — List<int> of active restriction IDs
- `selectedDietaryPreferenceId` — int (0 = none, >0 = active preference)
- `excludedAllergyIds` — List<int> of allergen IDs to filter out
- `mostRecentlyViewedBusinessAvailableDietaryRestrictions` — List<int> of restrictions this business supports
- `mostRecentlyViewedBusinessAvailableDietaryPreferences` — List<int> of preferences this business supports
- `mostRecentlyViewedBusinesMenuItems` — Map<String, dynamic> containing full menu structure for count calculation
- `translationsCache` — dynamic translations object for localized strings

**Writes to FFAppState:**
- `selectedDietaryRestrictionId` — updates when restrictions toggled
- `selectedDietaryPreferenceId` — updates when preference toggled
- `excludedAllergyIds` — updates when allergens toggled

---

## Parameters

### Input Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `width` | double? | No | null | Explicit width (null = fill available) |
| `height` | double? | No | null | Explicit height (null = wrap content) |
| `businessId` | int | Yes | — | Current business ID for analytics tracking |
| `onFiltersChanged` | Future Function()? | No | null | Callback invoked after filter state changes |
| `onVisibleItemCountChanged` | Future Function(int count)? | No | null | Callback invoked with new visible item count |

### Usage Example

```dart
UnifiedFiltersWidget(
  businessId: FFAppState().currentBusinessId,
  onFiltersChanged: () async {
    // Rebuild menu display
    setState(() {});
  },
  onVisibleItemCountChanged: (int count) async {
    // Update count badge or header
    setState(() {
      _visibleItemCount = count;
    });
  },
)
```

---

## State Management

### Internal State Variables

```dart
// Scroll Controllers (3 separate horizontal scrollers)
ScrollController _restrictionScrollController;
ScrollController _preferenceScrollController;
ScrollController _allergyScrollController;

// Initialization Flag
bool _isInitializing = true;  // Prevents validation during startup

// Menu Data Cache (for count calculation)
Map<int, Map<String, dynamic>> _menuItemMap;       // menu_item_id → item data
List<Map<String, dynamic>> _regularCategories;      // non-package categories
List<Map<String, dynamic>> _menuPackages;           // package categories
int _lastCalculatedCount;                           // cached count value
```

### Lifecycle Management

**initState():**
1. Initialize scroll controllers
2. Extract menu data from FFAppState into cache
3. Schedule post-frame validation callback
4. Calculate initial visible count

**didUpdateWidget():**
1. Check if `businessId` changed
2. If changed, re-extract menu data
3. Recalculate visible count

**dispose():**
1. Dispose all three scroll controllers
2. Clear cached menu data

---

## Filter Types & Logic

### 1. Dietary Restrictions (Multi-Select)

**Purpose:** Dietary needs that can be combined (e.g., gluten-free + lactose-free).

**IDs & Names:**
- `1` — Gluten-free
- `3` — Halal
- `4` — Lactose-free
- `5` — Kosher

**Display Order:** Fixed order (gluten-free, lactose-free, halal, kosher), not alphabetical.

**Auto-Selectable:** Gluten-free and lactose-free can be auto-selected when corresponding allergens are excluded.

**Selection Logic:**
```dart
// On select:
1. Add to selectedDietaryRestrictionId list
2. Add implied allergens to excludedAllergyIds
3. Update FFAppState
4. Notify parent

// On deselect:
1. Remove from selectedDietaryRestrictionId list
2. Calculate allergens still needed by remaining filters
3. Remove only allergens not needed by other filters
4. Update FFAppState
5. Validate remaining filters
6. Notify parent
```

### 2. Dietary Preferences (Single-Select)

**Purpose:** Exclusive dietary choices (can only pick one).

**IDs & Names:**
- `2` — Pescatarian
- `6` — Vegan
- `7` — Vegetarian

**Auto-Selectable:** Vegan and vegetarian can be auto-selected when sufficient allergens are excluded.

**Selection Logic:**
```dart
// On select:
1. Set selectedDietaryPreferenceId to new value
2. Add implied allergens to excludedAllergyIds
3. Add implied restrictions (vegan → lactose-free)
4. Update FFAppState
5. Notify parent

// On deselect:
1. Set selectedDietaryPreferenceId to 0
2. Remove implied restrictions (vegan → remove lactose-free)
3. Calculate allergens still needed by remaining filters
4. Remove only allergens not needed by other filters
5. Update FFAppState
6. Notify parent
```

### 3. Allergen Exclusions (Multi-Select)

**Purpose:** Hide menu items containing specific allergens.

**IDs & Names:** 1-14 (translated via `allergen_{id}_cap` keys)

**Commonly Mapped:**
- `2` — Gluten
- `3` — Crustaceans
- `4` — Eggs
- `5` — Fish
- `7` — Milk
- `8` — Molluscs

**Selection Logic:**
```dart
// On toggle:
1. Add/remove from excludedAllergyIds
2. Run validation to auto-select/deselect dietary filters
3. Update FFAppState
4. Notify parent
```

---

## Allergen-Dietary Coordination

### Dietary-to-Allergen Mapping

This map defines which allergens are implied by each dietary filter:

```dart
static const Map<int, List<int>> _dietaryToAllergensMap = {
  1: [2],              // Gluten-free → excludes gluten
  4: [7],              // Lactose-free → excludes milk
  3: [],               // Halal → no allergen exclusions
  5: [],               // Kosher → no allergen exclusions
  6: [7, 4, 5, 3, 8],  // Vegan → excludes milk, eggs, fish, crustaceans, molluscs
  7: [5, 3, 8],        // Vegetarian → excludes fish, crustaceans, molluscs
  2: [],               // Pescatarian → no allergen exclusions
};
```

### Dietary-to-Dietary Mapping

Defines which dietary restrictions are implied by preferences:

```dart
static const Map<int, List<int>> _dietaryImpliesOtherDietaryMap = {
  6: [4],  // Vegan implies lactose-free
};
```

### Auto-Selection Logic

**When allergens are excluded:**

```dart
void _validateAllFiltersAgainstAllergens() {
  // Find all restrictions whose allergen requirements are now met
  for (restriction in autoSelectableRestrictions) {
    if (all required allergens are excluded) {
      add restriction to selectedDietaryRestrictionId
    }
  }

  // Find the preference with the most allergen requirements met
  // (e.g., if milk+eggs+fish excluded, select vegan over lactose-free)
  for (preference in autoSelectablePreferences) {
    if (all required allergens are excluded) {
      if (allergen count > current best) {
        select this preference
      }
    }
  }

  // Preserve manually-selected preferences (halal, kosher, pescatarian)
  // that have no allergen requirements
}
```

**When deselecting restrictions:**

```dart
void _deselectRestriction(int restrictionId) {
  // Calculate which allergens are still needed by remaining filters
  allergensStillNeeded = getAllergensNeededByRestrictions(remaining)
  if (preference is selected) {
    allergensStillNeeded.addAll(preference allergens)
  }

  // Only remove allergens not needed by other filters
  for (allergen in restriction allergens) {
    if (!allergensStillNeeded.contains(allergen)) {
      remove allergen from excludedAllergyIds
    }
  }
}
```

### Auto-Selectable Sets

```dart
// Restrictions that can be auto-selected
static const Set<int> _autoSelectableRestrictions = {1, 4};  // gluten-free, lactose-free

// Preferences that can be auto-selected
static const Set<int> _autoSelectablePreferences = {6, 7};  // vegan, vegetarian
```

**Non-auto-selectable filters** (halal, kosher, pescatarian) are preserved when selected manually and never auto-removed.

---

## Visible Item Count Calculation

### Menu Data Extraction

**On widget initialization and business change:**

```dart
void _extractMenuData() {
  // Read menu structure from FFAppState
  final normalizedData = FFAppState().mostRecentlyViewedBusinesMenuItems;

  // Build lookup map: menu_item_id → item data
  _menuItemMap = Map.fromEntries(
    menuItems.map((item) => MapEntry(item['menu_item_id'], item))
  );

  // Separate regular categories from packages
  _regularCategories = categories.where(type != 'menu_package');
  _menuPackages = categories.where(type == 'menu_package');
}
```

### Count Calculation Logic

```dart
int _calculateVisibleItemCount() {
  int count = 0;

  // Count visible items in regular categories
  for (category in _regularCategories) {
    if (category['category_type'] != 'a la carte') continue;

    for (itemId in category['menu_item_ids']) {
      final item = _menuItemMap[itemId];
      if (item != null && _isItemVisible(item)) {
        count++;
      }
    }
  }

  // Add package count (packages are always visible)
  count += _menuPackages.length;

  return count;
}
```

### Item Visibility Logic

**Ported from MenuDishesListView:**

```dart
bool _isItemVisible(Map<String, dynamic> item) {
  // STEP 1: Check dietary filter (restrictions + preference)
  if (!_passesDietaryFilter(item)) {
    return false;  // Item doesn't meet dietary needs
  }

  // STEP 2: Check allergen override (can-be-made logic)
  if (_qualifiesForAllergenOverride(item)) {
    return true;  // Show despite allergens (can be adapted)
  }

  // STEP 3: Apply normal allergen filtering
  return _passesAllergyFilter(item);
}
```

**Dietary Filter Logic:**

```dart
bool _passesDietaryFilter(Map<String, dynamic> item) {
  final itemDietaryTypes = item['dietary_type_ids'];
  final itemCanBeMadeTypes = item['dietary_type_can_be_made_ids'];

  // Check ALL active restrictions (must pass all)
  for (restrictionId in _selectedRestrictionIds) {
    if (!itemDietaryTypes.contains(restrictionId) &&
        !itemCanBeMadeTypes.contains(restrictionId)) {
      return false;  // Doesn't meet this restriction
    }
  }

  // Check preference filter
  if (_selectedPreferenceId != null) {
    if (!itemDietaryTypes.contains(_selectedPreferenceId) &&
        !itemCanBeMadeTypes.contains(_selectedPreferenceId)) {
      return false;  // Doesn't meet preference
    }
  }

  return true;
}
```

**Allergen Override Logic:**

```dart
bool _qualifiesForAllergenOverride(Map<String, dynamic> item) {
  final itemCanBeMadeTypes = item['dietary_type_can_be_made_ids'];

  // If ANY active dietary filter is in can-be-made array,
  // show the item despite allergen content
  for (restrictionId in _selectedRestrictionIds) {
    if (itemCanBeMadeTypes.contains(restrictionId)) {
      return true;
    }
  }

  if (_selectedPreferenceId != null) {
    if (itemCanBeMadeTypes.contains(_selectedPreferenceId)) {
      return true;
    }
  }

  return false;
}
```

**Allergen Filter Logic:**

```dart
bool _passesAllergyFilter(Map<String, dynamic> item) {
  if (_excludedAllergyIds.isEmpty) {
    return true;  // No allergen filters active
  }

  final itemAllergies = item['allergy_ids'];
  final excludedSet = Set<int>.from(_excludedAllergyIds);

  // Hide if item contains any excluded allergen
  return !itemAllergies.any((allergyId) => excludedSet.contains(allergyId));
}
```

### Notification Flow

```dart
void _notifyFiltersChanged() {
  // 1. Calculate count synchronously
  _calculateAndNotifyVisibleCount();

  // 2. Notify parent to rebuild
  widget.onFiltersChanged?.call();
}

void _calculateAndNotifyVisibleCount() {
  _extractMenuData();  // Refresh cache
  final count = _calculateVisibleItemCount();

  if (count != _lastCalculatedCount) {
    _lastCalculatedCount = count;
    widget.onVisibleItemCountChanged?.call(count);
  }
}
```

---

## User Interactions

### Tap Handlers

#### Restriction Toggle

```dart
Future<void> _handleRestrictionTap(int restrictionId) async {
  final isCurrentlySelected = _selectedRestrictionIds.contains(restrictionId);

  markUserEngaged();
  _trackRestrictionToggle(restrictionId, isCurrentlySelected);

  if (isCurrentlySelected) {
    _deselectRestriction(restrictionId);  // Complex removal logic
  } else {
    _selectRestriction(restrictionId);     // Simple addition logic
  }

  _notifyFiltersChanged();
}
```

#### Preference Toggle

```dart
Future<void> _handlePreferenceTap(int preferenceId) async {
  final isDeselecting = _selectedPreferenceId == preferenceId;

  markUserEngaged();
  _trackPreferenceToggle(preferenceId, isDeselecting);

  if (isDeselecting) {
    _setPreferenceId(null);
    // Remove implied restrictions
    // Remove allergens not needed by remaining filters
  } else {
    _setPreferenceId(preferenceId);
    // Add implied allergens
    // Add implied restrictions
  }

  _notifyFiltersChanged();
}
```

#### Allergen Toggle

```dart
Future<void> _handleAllergenTap(int allergenId) async {
  final isCurrentlyExcluded = _excludedAllergyIds.contains(allergenId);

  markUserEngaged();
  _trackAllergenToggle(allergenId, isCurrentlyExcluded);

  // Toggle allergen in/out of exclusion list
  final newExcludedSet = Set<int>.from(_excludedAllergyIds);
  if (isCurrentlyExcluded) {
    newExcludedSet.remove(allergenId);
  } else {
    newExcludedSet.add(allergenId);
  }

  _setExcludedAllergyIds(newExcludedSet.toList());
  _validateAllFiltersAgainstAllergens();  // Auto-select/deselect dietary filters

  _notifyFiltersChanged();
}
```

#### Reset Button

```dart
Future<void> _handleResetTap() async {
  markUserEngaged();
  trackAnalyticsEvent('unified_filters_reset', {'business_id': widget.businessId});

  _setRestrictionIds([]);
  _setPreferenceId(null);
  _setExcludedAllergyIds([]);

  setState(() {});
  _notifyFiltersChanged();
}
```

### Reset Button Visibility

The reset button only appears when **any filter is active**:

```dart
bool _hasActiveFilters() {
  return _selectedRestrictionIds.isNotEmpty ||
         _selectedPreferenceId != null ||
         _excludedAllergyIds.isNotEmpty;
}
```

---

## Analytics Tracking

### Event: `unified_filter_restriction_toggled`

**Triggered:** When user taps a dietary restriction pill.

**Properties:**
```dart
{
  'business_id': int,                  // Current business ID
  'restriction_id': int,               // ID of restriction toggled
  'restriction_name': String,          // Localized name
  'action': 'selected' | 'deselected', // User action
  'is_now_selected': bool,             // New state
  'total_restrictions_active': int,    // Count after change
  'language': String,                  // Current language code
}
```

### Event: `unified_filter_preference_toggled`

**Triggered:** When user taps a dietary preference pill.

**Properties:**
```dart
{
  'business_id': int,
  'preference_id': int,
  'preference_name': String,
  'action': 'selected' | 'deselected',
  'is_now_selected': bool,
  'language': String,
}
```

### Event: `unified_filter_allergen_toggled`

**Triggered:** When user taps an allergen pill.

**Properties:**
```dart
{
  'business_id': int,
  'allergen_id': int,
  'allergen_name': String,
  'action': 'included' | 'excluded',
  'is_now_excluded': bool,
  'language': String,
}
```

### Event: `unified_filters_reset`

**Triggered:** When user taps "Reset" button.

**Properties:**
```dart
{
  'business_id': int,
}
```

### Error Handling

All analytics events use `.catchError()` to prevent tracking failures from affecting UX:

```dart
trackAnalyticsEvent('event_name', properties).catchError((error) {
  debugPrint('⚠️ Failed to track event: $error');
});
```

---

## Translation Support

### Translation Keys Used

**Widget reads these keys via `getTranslations()`:**

| Key | Purpose | Example (English) |
|-----|---------|-------------------|
| `menu_dishes_filter_title` | Widget header | "Filter" |
| `menu_dishes_filter_reset` | Reset button | "Reset" |
| `menu_dishes_filter_restrictions_title` | Restrictions header | "Dietary Restrictions" |
| `menu_dishes_filter_restrictions_subtitle` | Restrictions description | "Multi-select" |
| `menu_dishes_filter_preferences_title` | Preferences header | "Dietary Preferences" |
| `menu_dishes_filter_preferences_subtitle` | Preferences description | "Single-select" |
| `menu_dishes_filter_allergens_title` | Allergens header | "Allergens" |
| `menu_dishes_filter_allergens_subtitle` | Allergens description | "Hide items containing" |
| `dietary_{id}_cap` | Dietary option name | "Gluten-free", "Vegan" |
| `allergen_{id}_cap` | Allergen name | "Gluten", "Milk" |

### Translation Helper

```dart
String _getUIText(String key) {
  return getTranslations(_currentLanguage, key, _translationsCache);
}

String _getDietaryName(int id) {
  return _getUIText('dietary_${id}_cap');
}

String? _getAllergenName(int id) {
  final name = _getUIText('allergen_${id}_cap');
  // Return null if translation missing
  return name.isEmpty || name.startsWith('⚠️') ? null : name;
}
```

### Current Language

```dart
String get _currentLanguage => FFLocalizations.of(context).languageCode;
```

---

## Visual Design

### Container Styling

```dart
static const Color _containerColor = Color(0x1957636C);  // Semi-transparent gray
static const double _containerBorderRadius = 15.0;
static const EdgeInsets _containerPadding = EdgeInsets.fromLTRB(16, 18, 16, 18);
```

### Pill Button Styling

**Selected State:**
```dart
backgroundColor: Color(0xFFEE8B60)  // Orange
textColor: Colors.white
border: none
```

**Unselected State:**
```dart
backgroundColor: Color(0xFFf2f3f5)  // Light gray
textColor: Color(0xFF242629)        // Dark gray
border: 1px solid Colors.grey[500]
```

**Button Properties:**
```dart
padding: EdgeInsets.symmetric(horizontal: 16)
minimumSize: Size(0, 32)
borderRadius: 15.0
fontSize: 14.0
fontWeight: FontWeight.w400
fontFamily: 'Roboto'
spacing: 8.0 (between pills)
```

**Animation:**
```dart
duration: Duration(milliseconds: 200)
// Smooth color transition on selection
```

### Typography

**Header (title + reset):**
```dart
fontSize: 18.0
fontWeight: FontWeight.w500  (Medium)
color: Colors.black
```

**Section Headers:**
```dart
fontSize: 16.0
fontWeight: FontWeight.w400  (Regular)
color: Colors.black
```

**Section Descriptions:**
```dart
fontSize: 14.0
fontWeight: FontWeight.w300  (Light)
color: Colors.black
```

### Layout Spacing

```dart
sectionSpacing: 16.0  (between filter sections)
widgetTopPadding: 4.0  (above pill rows)
widgetHeight: 28.0     (pill row height)
```

### Scroll Behavior

- Three independent horizontal scrollers
- No scroll bars visible
- Smooth horizontal scrolling
- Pills aligned left, scroll right to see more

---

## Implementation Notes

### Key Changes from v1

**Multi-Restriction Support:**
- v1: Single dietary restriction
- v2: Multiple restrictions can be active simultaneously

**Auto-Coordination:**
- v1: Manual filter selection only
- v2: Automatic selection/deselection based on allergen state

**Visible Count Calculation:**
- v1: Parent widget calculated count
- v2: Widget calculates and reports count directly

**Can-Be-Made Logic:**
- v1: Simple hide/show based on allergens
- v2: Shows items that can be adapted, overriding allergen filter

### FFAppState Dependencies

**Critical:** Widget directly reads and writes to FFAppState. Migration must preserve this pattern until state management refactor.

```dart
// Reading
FFAppState().selectedDietaryRestrictionId
FFAppState().selectedDietaryPreferenceId
FFAppState().excludedAllergyIds
FFAppState().mostRecentlyViewedBusinessAvailableDietaryRestrictions
FFAppState().mostRecentlyViewedBusinessAvailableDietaryPreferences
FFAppState().mostRecentlyViewedBusinesMenuItems
FFAppState().translationsCache

// Writing
FFAppState().update(() {
  FFAppState().selectedDietaryRestrictionId = newValue;
  FFAppState().selectedDietaryPreferenceId = newValue;
  FFAppState().excludedAllergyIds = newValue;
});
```

### Menu Data Structure

**Widget expects this structure in `mostRecentlyViewedBusinesMenuItems`:**

```dart
{
  'menu_items': [
    {
      'menu_item_id': int,
      'dietary_type_ids': List<int>,          // Inherently has these dietary types
      'dietary_type_can_be_made_ids': List<int>,  // Can be adapted to these types
      'allergy_ids': List<int>,               // Contains these allergens
      // ... other fields
    },
  ],
  'categories': [
    {
      'category_type': 'a la carte' | 'menu_package',
      'menu_item_ids': List<int>,
      // ... other fields
    },
  ],
}
```

### Edge Cases Handled

**Empty Available Lists:**
- Widget gracefully handles business with no dietary options
- Sections don't render if no options available

**Invalid Dietary IDs:**
- Treats 0 as "not selected"
- Ignores null values

**Missing Translations:**
- Allergen name returns null if translation missing
- Those allergens are excluded from display

**Initialization Race Condition:**
- `_isInitializing` flag prevents validation during widget startup
- Validation runs in post-frame callback

**Business Change:**
- `didUpdateWidget` re-extracts menu data if businessId changes
- Recalculates visible count after re-extraction

---

## Migration Checklist

### Pre-Migration

- [ ] Review FlutterFlow source code (`unified_filters_widget.dart`)
- [ ] Understand allergen-dietary coordination logic
- [ ] Study item visibility logic (dietary + allergen + can-be-made)
- [ ] Map all translation keys required
- [ ] Verify FFAppState variable types (List<int> vs int)

### Core Implementation

- [ ] Create StatefulWidget with proper parameters
- [ ] Implement three scroll controllers
- [ ] Build menu data extraction logic
- [ ] Port visible item count calculation
- [ ] Implement dietary-to-allergen mapping constants
- [ ] Build auto-selection validation logic
- [ ] Implement cumulative allergen logic for deselection
- [ ] Handle restriction tap (select/deselect with allergen coordination)
- [ ] Handle preference tap (single-select with implications)
- [ ] Handle allergen tap (with auto-dietary selection)
- [ ] Build reset functionality
- [ ] Implement parent notification callbacks

### UI Components

- [ ] Build container with proper styling
- [ ] Create reusable pill button widget
- [ ] Build header row with conditional reset button
- [ ] Build filter section component (reusable for 2 sections)
- [ ] Build allergen section (custom variation)
- [ ] Implement horizontal scroll lists
- [ ] Apply proper spacing and padding
- [ ] Animate selection state changes

### Analytics

- [ ] Implement `unified_filter_restriction_toggled` event
- [ ] Implement `unified_filter_preference_toggled` event
- [ ] Implement `unified_filter_allergen_toggled` event
- [ ] Implement `unified_filters_reset` event
- [ ] Add error handling for analytics failures
- [ ] Verify event properties match spec

### Translation Support

- [ ] Wire up `getTranslations()` helper
- [ ] Map all UI text keys
- [ ] Map dietary name keys (`dietary_{id}_cap`)
- [ ] Map allergen name keys (`allergen_{id}_cap`)
- [ ] Handle missing translations gracefully

### Testing

- [ ] Test multi-restriction selection
- [ ] Test auto-selection when allergens excluded
- [ ] Test deselection with cumulative allergen logic
- [ ] Test preference selection (single-select)
- [ ] Test vegan → lactose-free implication
- [ ] Test reset functionality
- [ ] Test visible count calculation accuracy
- [ ] Test with empty menu data
- [ ] Test with missing translations
- [ ] Test business ID change behavior
- [ ] Verify analytics events fire correctly

### Integration

- [ ] Wire up to Full Menu page
- [ ] Connect to menu display update logic
- [ ] Verify state persistence across navigation
- [ ] Test filter state restored after back navigation
- [ ] Verify count displayed correctly in parent widget

### Edge Cases

- [ ] Handle business with no dietary options
- [ ] Handle empty menu data
- [ ] Handle null/0 dietary IDs
- [ ] Handle missing allergen translations
- [ ] Prevent validation during initialization
- [ ] Handle rapid tap interactions
- [ ] Test allergen override (can-be-made) logic

---

## Related Documentation

- **Page Audit:** `_reference/page-audit.md` — Full Menu page section
- **Design System:** `_reference/journeymate-design-system.md` — Filter interaction patterns
- **Menu Data Structure:** `MASTER_README_menu_dishes_list_view.md` — Item visibility logic
- **Filter Description Sheet:** `MASTER_README_filter_description_sheet.md` — Related filtering UI
- **Translation System:** `MASTER_README_translations_system.md` — getTranslations() usage

---

**End of README**
