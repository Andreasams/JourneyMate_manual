# Menu Full Page

**Route:** `/ViewFullMenu/:businessId/:businessName`
**Route Name:** `ViewFullMenu`
**Status:** ✅ Production Ready

---

## Purpose

Full-screen menu page with comprehensive dietary filtering. Users can explore all menu items, filter by dietary preferences/restrictions/allergens, view item details, and navigate packages.

**Primary User Task:** Find menu items that match dietary needs and explore detailed dish information.

---

## Key Features

- **Dietary Filtering:** Vegan, vegetarian, pescetarian, gluten-free, etc.
- **Allergen Exclusion:** Filter out 14 allergen types
- **Category Navigation:** Jump to starters, mains, desserts
- **Item Details:** Bottom sheet with full descriptions, variations
- **Package Navigation:** Multi-course menu exploration
- **"Ryd alle" Button:** Clear all filters with one tap

---

## Custom Widgets Used (3)

**From FlutterFlow Source:**

| Widget | File Path | Purpose | Priority |
|--------|-----------|---------|----------|
| `MenuDishesListView` | `/custom_code/widgets/menu_dishes_list_view.dart` | Main scrollable menu list with filtering, scroll tracking, and analytics | ⭐⭐⭐⭐⭐ |
| `MenuCategoriesRows` | `/custom_code/widgets/menu_categories_rows.dart` | Multi-row category navigation chips with auto-scroll | ⭐⭐⭐⭐⭐ |
| `UnifiedFiltersWidget` | `/custom_code/widgets/unified_filters_widget.dart` | Collapsible filter panel combining dietary restrictions, preferences, and allergens | ⭐⭐⭐⭐⭐ |

**Note:** The JSX design shows three separate filter sections (`AllergiesFilterWidget`, `DietaryRestrictionsFilterWidget`, `DietaryPreferencesFilterWidget`). In FlutterFlow, these are unified in a single `UnifiedFiltersWidget` component.

---

## Bottom Sheet Widgets (3)

**From FlutterFlow Source:**

| Widget | File Path | Purpose | Priority |
|--------|-----------|---------|----------|
| `ItemBottomSheetWidget` | `/profile/menu/item_bottom_sheet/item_bottom_sheet_widget.dart` | Menu item detail overlay with full description, variations, and pricing | ⭐⭐⭐⭐⭐ |
| `PackageBottomSheetWidget` | `/profile/menu/package_bottom_sheet/package_bottom_sheet_widget.dart` | Multi-course package navigation and details | ⭐⭐⭐⭐ |
| `CategoryDescriptionSheetWidget` | `/profile/menu/category_description_sheet/category_description_sheet_widget.dart` | Category information modal (optional feature) | ⭐⭐ |

---

## Custom Actions Used (2)

**From FlutterFlow Source:**

| Action | File Path | Purpose | Called When |
|--------|-----------|---------|-------------|
| `trackAnalyticsEvent` | `/custom_code/actions/track_analytics_event.dart` | Send analytics events to PostHog | On page dispose (page_viewed event) |
| `markUserEngaged` | `/custom_code/actions/mark_user_engaged.dart` | Track user engagement state | On back button tap, filter toggle |

**Additional Menu Actions (used by custom widgets):**
- `startMenuSession` - Track menu session start time
- `endMenuSession` - Calculate menu session duration
- `updateMenuSessionFilterMetrics` - Track filter usage patterns
- `track_filter_reset` - Track "Ryd alle" button usage

---

## Custom Functions Used (3)

**From FlutterFlow Source:**

| Function | Purpose | Called Where |
|----------|---------|--------------|
| `formatLocalizedDate` | Format timestamp for display | Last updated date display |
| `generateFilterSummary` | Generate "Showing X items matching..." text | Filter summary text |
| `getSessionDurationSeconds` | Calculate page duration in seconds | Analytics on dispose |

**Additional Functions (used by custom widgets):**
- Date formatting and localization helpers
- Price conversion and formatting
- Dietary/allergen string formatting
- Filter logic helpers

---

## FFAppState Usage

**From FlutterFlow Source:**

### Read
- `mostRecentlyViewedBusiness` - Business data (name, last_reviewed_at, business_id, menu data)
- `selectedDietaryPreferenceId` - Current dietary preference filter (single int)
- `selectedDietaryRestrictionId` - Current dietary restrictions (List<int>) - **Multi-select support**
- `excludedAllergyIds` - Current allergen exclusions (List<int>)
- `mostRecentlyViewedBusinessSelectedCategoryID` - Current category selection
- `mostRecentlyViewedBusinessSelectedMenuID` - Current menu selection
- `visibleItemCount` - Count of visible items after filtering
- `translationsCache` - Localized strings for UI
- `isBoldTextEnabled` - Accessibility setting for layout adjustment

### Write
- `selectedDietaryPreferenceId` - Updated when preference filter changes
- `selectedDietaryRestrictionId` - Updated when restriction filters change
- `excludedAllergyIds` - Updated when allergen toggles change
- `mostRecentlyViewedBusinessSelectedCategoryID` - Updated when category changes
- `mostRecentlyViewedBusinessSelectedMenuID` - Updated when menu changes
- `visibleItemCount` - Updated by UnifiedFiltersWidget when filters change

---

## Translation Keys

**From FlutterFlow Source:**

| Key | English Text | Context |
|-----|--------------|---------|
| `foeokmwh` | "Menu" | Page heading |
| `sgpknl00` | "Last brought up to date on " | Timestamp prefix text |
| `1smig27j` | "Hide filters" | Filter toggle when panel is open |
| `bwvizajd` | "Show filters" | Filter toggle when panel is closed |

**Additional Keys (from custom widgets):**
- Filter section labels (Dietary Restrictions, Dietary Preferences, Allergens)
- Filter explainer text
- "Ryd alle" button text
- Empty state messages
- Category-specific information text

**Translation System Usage:**
```dart
// Always pass these parameters to custom widgets:
languageCode: FFLocalizations.of(context).languageCode,
translationsCache: FFAppState().translationsCache,
```

---

## Page State (Model)

**From FlutterFlow Source (`view_full_menu_model.dart`):**

```dart
class ViewFullMenuModel extends FlutterFlowModel<ViewFullMenuWidget> {
  // Local state fields for this page

  bool showFilters = false; // Filter panel visibility toggle

  int? selectedDietaryPreference; // (appears unused in widget code)

  List<int> selectedAllergies = []; // (appears unused in widget code)

  int numberOfCategoryRows = 2; // Dynamic category chip row count (1 or 2 rows)

  dynamic visibleSelection; // Currently visible category data

  DateTime? pageStartTime; // Page load timestamp for analytics
}
```

**Note:** `selectedDietaryPreference` and `selectedAllergies` are defined in the model but not used in the widget code. Actual filter state is managed in `FFAppState()`:
- `FFAppState().selectedDietaryPreferenceId`
- `FFAppState().selectedDietaryRestrictionId`
- `FFAppState().excludedAllergyIds`

---

## Lifecycle Events

**From FlutterFlow Source:**

**initState:**
```dart
SchedulerBinding.instance.addPostFrameCallback((_) async {
  _model.pageStartTime = getCurrentTimestamp;
  safeSetState(() {});
});
```

1. Record page start time for analytics (using `SchedulerBinding` to run after first frame)
2. Menu data is already loaded in `FFAppState().mostRecentlyViewedBusiness`
3. Custom widgets handle their own initialization

**dispose:**
```dart
() async {
  await actions.trackAnalyticsEvent(
    'page_viewed',
    <String, String>{
      'pageName': 'viewFullMenu',
      'durationSeconds': functions
          .getSessionDurationSeconds(_model.pageStartTime!)
          .toString(),
    },
  );
}();
```

1. Track analytics: `page_viewed` event with duration
2. Custom widgets handle their own cleanup (menu session tracking handled by widgets)
3. Dispose model

---

## User Interactions

**From FlutterFlow Source:**

**Back Button Tap:**
```dart
onPressed: () async {
  await actions.markUserEngaged();
  context.safePop();
}
```
- Mark user as engaged
- Pop back to Business Profile page

**Filter Toggle (Show/Hide):**
```dart
onTap: () async {
  unawaited(() async {
    await actions.markUserEngaged();
  }());
  _model.showFilters = !_model.showFilters; // Toggle visibility
  safeSetState(() {});
}
```
- Mark user as engaged
- Toggle `showFilters` state
- Rebuild to show/hide filter panel

**Filter Changes (within UnifiedFiltersWidget):**
- Apply/remove dietary preference → Update `FFAppState().selectedDietaryPreferenceId`
- Apply/remove dietary restriction → Update `FFAppState().selectedDietaryRestrictionId` (multi-select)
- Toggle allergen → Update `FFAppState().excludedAllergyIds`
- Trigger `onFiltersChanged` callback → Rebuild menu list
- Trigger `onVisibleItemCountChanged` callback → Update visible item count display

**Category Chip Tap (in MenuCategoriesRows):**
- Scroll menu list to category section
- Update `FFAppState().mostRecentlyViewedBusinessSelectedCategoryID`
- Update `FFAppState().mostRecentlyViewedBusinessSelectedMenuID`
- Trigger `onCategoryChanged` callback
- Update `onNumberOfRows` callback if layout changes

**Menu Item Tap (in MenuDishesListView):**
```dart
onItemTap: (bottomSheetInformation, ...) async {
  await showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) {
      return ItemBottomSheetWidget(
        itemData: bottomSheetInformation,
        businessName: ...,
        hasVariations: hasVariations,
        formattedPrice: formattedPrice,
        formattedVariationPrice: formattedVariationPrice,
      );
    },
  );
}
```
- Open `ItemBottomSheetWidget` modal bottom sheet
- Pass item data, business name, and pricing info

**Package Tap (in MenuDishesListView):**
```dart
onPackageTap: (packageData) async {
  await showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: false,
    context: context,
    builder: (context) {
      return PackageBottomSheetWidget(
        packageData: packageData,
        packageId: getJsonField(packageData, r'$.package_id'),
        businessName: ...,
      );
    },
  );
}
```
- Open `PackageBottomSheetWidget` modal bottom sheet
- Pass package data and ID

**Category Description Tap (in MenuDishesListView):**
```dart
onCategoryDescriptionTap: (categoryData) async {
  await showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) {
      return CategoryDescriptionSheetWidget(
        categoryInformation: categoryData,
      );
    },
  );
}
```
- Open `CategoryDescriptionSheetWidget` modal bottom sheet
- Pass category information

---

## Analytics Events

**From FlutterFlow Source:**

**Page-Level Events:**

1. **`page_viewed`** (tracked on dispose)
   ```dart
   await actions.trackAnalyticsEvent(
     'page_viewed',
     <String, String>{
       'pageName': 'viewFullMenu',
       'durationSeconds': functions
           .getSessionDurationSeconds(_model.pageStartTime!)
           .toString(),
     },
   );
   ```
   - Properties: `pageName`, `durationSeconds`
   - Fired when user leaves the page

**Widget-Level Events (from custom widgets):**

2. **`menu_item_viewed`** (from MenuDishesListView)
   - Fired when item bottom sheet is opened
   - Properties: Item ID, business ID, item type

3. **`menu_filter_applied`** (from UnifiedFiltersWidget)
   - Fired when filter is selected/deselected
   - Properties: Filter type, filter value, visible item count

4. **`menu_filter_cleared`** (from UnifiedFiltersWidget)
   - Fired when "Ryd alle" is tapped
   - Properties: Number of filters cleared

5. **`menu_category_selected`** (from MenuCategoriesRows)
   - Fired when category chip is tapped
   - Properties: Category ID, menu ID

**Session Tracking (from custom actions):**
- `startMenuSession` - Initialize menu session tracking
- `endMenuSession` - Calculate and log menu session metrics
- `updateMenuSessionFilterMetrics` - Track filter usage patterns

---

## Migration Priority

⭐⭐⭐⭐⭐ **Critical** - Core menu experience

---

## Critical Implementation Notes

### 1. UnifiedFiltersWidget vs Separate Filter Widgets

**Ground Truth (FlutterFlow):** Single `UnifiedFiltersWidget` combining all three filter types.

**JSX Design:** Three separate filter sections shown visually.

**Implementation:** Follow FlutterFlow pattern (ground truth), apply JSX visual design to the unified widget.

### 2. Multi-Restriction Support

**CRITICAL:** Dietary restrictions now support MULTI-SELECT (can select both gluten-free AND lactose-free).

- `FFAppState().selectedDietaryRestrictionId` is a **List<int>** (not single int)
- `UnifiedFiltersWidget` handles cumulative allergen logic
- Auto-selection validates ALL restrictions whose allergen requirements are met

### 3. Filter Panel Height Adjustment

**Adaptive height based on accessibility settings:**

```dart
height: valueOrDefault<double>(
  FFAppState().isBoldTextEnabled ? 385.0 : 350.0,
  340.0,
)
```

This accommodates larger text when bold text accessibility setting is enabled.

### 4. Category Row Count

**Dynamic height based on number of rows:**

```dart
height: _model.numberOfCategoryRows == 1 ? 42.0 : 72.0
```

The `MenuCategoriesRows` widget reports row count via `onNumberOfRows` callback.

### 5. Translation System

**CRITICAL:** Always pass `languageCode` and `translationsCache` to custom widgets.

```dart
custom_widgets.MenuDishesListView(
  // ... other params
  languageCode: FFLocalizations.of(context).languageCode,
  translationsCache: FFAppState().translationsCache,
)
```

### 6. Menu Data Flow

**Data is read from FFAppState, NOT fetched on this page:**

```dart
FFAppState().mostRecentlyViewedBusiness // Business info + menu data
```

The Business Profile page fetches this data before navigating to Menu Full page.

### 7. Bottom Sheet Configuration

**Different configurations for each sheet type:**

- **ItemBottomSheet:** `isScrollControlled: true`, `backgroundColor: Colors.transparent`
- **PackageBottomSheet:** `isScrollControlled: true`, `enableDrag: false`
- **CategoryDescriptionSheet:** `isScrollControlled: true`

All use `MediaQuery.viewInsetsOf(context)` for keyboard avoidance padding.

---

**Last Updated:** 2026-02-19 (Verified against FlutterFlow source code)
