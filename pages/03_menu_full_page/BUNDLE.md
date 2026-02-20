# Menu Full Page — Complete Implementation Bundle

**Document Version:** 1.0
**Last Updated:** February 19, 2026
**Status:** Ready for Implementation

---

## Overview

This document consolidates all information needed to implement the Menu Full page in pure Flutter/Dart. It combines:

1. **FlutterFlow Source Code** (ground truth for functionality)
2. **JSX Design Specification** (v2 visual design)
3. **Page Audit** (functionality requirements)

This is the single source of truth for implementing this page.

---

## Three-Source Method Implementation

### 1. FlutterFlow Source (Ground Truth)

**Location:** `C:\Users\Rikke\Documents\JourneyMate\_flutterflow_export\lib\profile\menu\view_full_menu\view_full_menu_widget.dart`

**Key Findings:**

#### Imports Required
```dart
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/profile/menu/category_description_sheet/category_description_sheet_widget.dart';
import '/profile/menu/item_bottom_sheet/item_bottom_sheet_widget.dart';
import '/profile/menu/package_bottom_sheet/package_bottom_sheet_widget.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
```

#### Custom Widgets Used

| Widget | File Path | Purpose | Priority |
|--------|-----------|---------|----------|
| `MenuDishesListView` | `/custom_code/widgets/menu_dishes_list_view.dart` | Main scrollable menu list with filtering | ⭐⭐⭐⭐⭐ |
| `MenuCategoriesRows` | `/custom_code/widgets/menu_categories_rows.dart` | Category navigation chips | ⭐⭐⭐⭐⭐ |
| `UnifiedFiltersWidget` | `/custom_code/widgets/unified_filters_widget.dart` | Collapsible filter panel (preferences, restrictions, allergens) | ⭐⭐⭐⭐⭐ |

**Note:** The JSX design shows three separate filter sections. In FlutterFlow, these are unified in the `UnifiedFiltersWidget`.

#### Bottom Sheet Widgets

| Widget | File Path | Purpose | Priority |
|--------|-----------|---------|----------|
| `ItemBottomSheetWidget` | `/profile/menu/item_bottom_sheet/item_bottom_sheet_widget.dart` | Menu item detail overlay | ⭐⭐⭐⭐⭐ |
| `PackageBottomSheetWidget` | `/profile/menu/package_bottom_sheet/package_bottom_sheet_widget.dart` | Multi-course package navigation | ⭐⭐⭐⭐ |
| `CategoryDescriptionSheetWidget` | `/profile/menu/category_description_sheet/category_description_sheet_widget.dart` | Category information modal | ⭐⭐ |

#### Custom Actions Used

| Action | File Path | Purpose |
|--------|-----------|---------|
| `trackAnalyticsEvent` | `/custom_code/actions/track_analytics_event.dart` | Analytics tracking |
| `markUserEngaged` | `/custom_code/actions/mark_user_engaged.dart` | Engagement tracking |
| `startMenuSession` | `/custom_code/actions/start_menu_session.dart` | Menu session tracking |
| `endMenuSession` | `/custom_code/actions/end_menu_session.dart` | Menu session metrics |
| `updateMenuSessionFilterMetrics` | `/custom_code/actions/update_menu_session_filter_metrics.dart` | Filter usage tracking |

#### Custom Functions Used

| Function | Purpose |
|----------|---------|
| `formatLocalizedDate` | Format timestamp for display |
| `generateFilterSummary` | Generate "Showing X items" text |
| `getSessionDurationSeconds` | Calculate page duration |

#### Translation Keys

**From FlutterFlow source:**

| Key | English Text | Context |
|-----|--------------|---------|
| `foeokmwh` | "Menu" | Page heading |
| `sgpknl00` | "Last brought up to date on " | Timestamp prefix |
| `1smig27j` | "Hide filters" | Filter toggle (open) |
| `bwvizajd` | "Show filters" | Filter toggle (closed) |

**Additional keys needed (from JSX design):**
- Filter section labels (Kostrestriktioner, Kostpræferencer, Allergener)
- Filter explainer text
- Empty state messages
- Category-specific info text

---

### 2. JSX Design Specification

**Location:** `C:\Users\Rikke\Documents\JourneyMate-Organized\pages\03_menu_full_page\DESIGN_README_menu_full_page.md`

**Key Design Decisions:**

#### Visual Layout
- **Frame:** 390×844px (iPhone 14/15)
- **Header:** 60px with back button and centered restaurant name
- **No tab bar** — full-screen modal page
- **Horizontal padding:** 20px for content area

#### Filter Panel (Collapsible)
- **Background:** `#fafafa`
- **Border radius:** 12px
- **Padding:** 16px internal
- **Three sections:**
  1. Kostrestriktioner (Restrictions) — exclusive selection
  2. Kostpræferencer (Preferences) — exclusive selection
  3. Allergener (Allergens) — multiple selection, inverted logic (hide items)

**Default State:** Allergens pre-selected: "Blødyr", "Fisk", "Jordnødder"

#### Category Navigation
- **Horizontal scrollable chips**
- **Active state:** Orange background, white text
- **Inactive state:** White background, grey text
- **Gap:** 8px between chips

#### Menu Items
- **Layout:** Name (15px, weight 590), Description (13px), Price (13.5px, orange)
- **Spacing:** 20px between items
- **No images** — text-only design

#### Color Tokens
- Orange (`#e8751a`) = interactive elements, prices
- Green (`#1a9456`) = not used on this page
- Grey scale for text hierarchy

---

### 3. Page Audit Specifications

**Location:** `C:\Users\Rikke\Documents\JourneyMate-Organized\pages\03_menu_full_page\PAGE_README.md`

**Functional Requirements:**

#### Primary User Task
Find menu items that match dietary needs and explore detailed dish information.

#### Key Features
1. **Dietary Filtering** — Vegan, vegetarian, pescetarian, gluten-free, etc.
2. **Allergen Exclusion** — Filter out 14 allergen types
3. **Category Navigation** — Jump to starters, mains, desserts
4. **Item Details** — Bottom sheet with full descriptions, variations
5. **Package Navigation** — Multi-course menu exploration
6. **"Ryd alle" Button** — Clear all filters with one tap

#### FFAppState Usage

**Read:**
- `mostRecentlyViewedBusiness` — Business data (name, last_reviewed_at)
- `mostRecentlyViewedBusinesMenuItems` — Menu data
- `mostRecentlyViewedBusinessAvailableDietaryPreferences` — Available filter options
- `mostRecentlyViewedBusinessAvailableDietaryRestrictions` — Available filter options
- `selectedDietaryPreferenceId` — Current dietary filter (single int)
- `selectedDietaryRestrictionId` — Current restrictions (List<int>)
- `excludedAllergenIds` — Current allergen exclusions (List<int>)
- `mostRecentlyViewedBusinessSelectedCategoryID` — Current category
- `mostRecentlyViewedBusinessSelectedMenuID` — Current menu
- `visibleItemCount` — Count of visible items after filtering
- `translationsCache` — Localized strings
- `userCurrencyCode` — User's currency
- `exchangeRate` — Conversion rate
- `isBoldTextEnabled` — Accessibility setting

**Write:**
- `selectedDietaryPreferenceId` — Updated on filter selection
- `excludedAllergenIds` — Updated on allergen toggles
- `selectedDietaryRestrictionId` — Updated on restriction toggles
- `mostRecentlyViewedBusinessSelectedCategoryID` — Updated on category change
- `mostRecentlyViewedBusinessSelectedMenuID` — Updated on menu change
- `visibleItemCount` — Updated when filters change

---

## Implementation Checklist

### Step 1: Review All Three Sources ✓

- [x] Read FlutterFlow source code
- [x] Read JSX design specification
- [x] Read page audit requirements

### Step 2: Map All Aspects

#### Parameters to Pass
- `languageCode` — From `FFLocalizations.of(context).languageCode`
- `translationsCache` — From `FFAppState().translationsCache`
- `businessId` — From `FFAppState().mostRecentlyViewedBusiness`
- `originalCurrencyCode` — "DKK" (hardcoded)
- `userCurrencyCode` — From `FFAppState().userCurrencyCode`
- `exchangeRate` — From `FFAppState().exchangeRate`

#### Translation Keys Needed
```dart
// Page-level translations
FFLocalizations.of(context).getText('foeokmwh') // "Menu"
FFLocalizations.of(context).getText('sgpknl00') // "Last brought up to date on "
FFLocalizations.of(context).getText('1smig27j') // "Hide filters"
FFLocalizations.of(context).getText('bwvizajd') // "Show filters"

// Filter section translations (from UnifiedFiltersWidget)
// - Dietary restrictions label
// - Dietary preferences label
// - Allergens label
// - Explainer text for each section
```

#### Analytics Events
```dart
// Page view tracking
await actions.trackAnalyticsEvent(
  'page_viewed',
  <String, String>{
    'pageName': 'viewFullMenu',
    'durationSeconds': functions
        .getSessionDurationSeconds(_model.pageStartTime!)
        .toString(),
  },
);

// Menu item viewed (from MenuDishesListView widget)
// Menu filter applied (from UnifiedFiltersWidget)
// Menu filter cleared
// Menu session ended (from endMenuSession action)
```

#### State Variables

**Page-level state:**
```dart
late ViewFullMenuModel _model;
final scaffoldKey = GlobalKey<ScaffoldState>();
```

**Model state (in view_full_menu_model.dart):**
```dart
class ViewFullMenuModel extends FlutterFlowModel<ViewFullMenuWidget> {
  bool showFilters = false; // Filter panel visibility
  int numberOfCategoryRows = 1; // Category chip row count
  dynamic visibleSelection; // Currently visible category data
  DateTime? pageStartTime; // For analytics
}
```

#### API Integration
**No direct API calls on this page.**

Menu data is already loaded in `FFAppState().mostRecentlyViewedBusinesMenuItems` from Business Profile page.

#### Navigation Logic

**Back Button:**
```dart
onPressed: () async {
  await actions.markUserEngaged();
  context.safePop();
}
```

**Bottom Sheet Navigation:**
- Item tap → `ItemBottomSheetWidget` (modal bottom sheet)
- Package tap → `PackageBottomSheetWidget` (modal bottom sheet)
- Category info tap → `CategoryDescriptionSheetWidget` (modal bottom sheet)

#### Custom Actions/Functions to Port

**From FlutterFlow:**
1. `markUserEngaged()` — Track user engagement
2. `trackAnalyticsEvent()` — Send analytics
3. `formatLocalizedDate()` — Format date for display
4. `generateFilterSummary()` — Generate filter summary text
5. `getSessionDurationSeconds()` — Calculate session duration

**Custom widgets to port:**
1. `MenuDishesListView` — Complex widget with scroll tracking, filtering, analytics
2. `MenuCategoriesRows` — Multi-row category chips with auto-scroll
3. `UnifiedFiltersWidget` — Filter panel with three sections

#### Widget Composition

**Layout structure:**
```
Scaffold
└── AppBar
    ├── leading: FlutterFlowIconButton (back)
    └── title: Text (restaurant name)
└── body: SafeArea
    └── Column
        └── Expanded
            └── Padding (12px horizontal)
                └── Column
                    ├── Row (heading + timestamp)
                    ├── Column (filter summary + toggle)
                    │   ├── Text (filter summary) [conditional]
                    │   ├── InkWell (show/hide filters toggle)
                    │   └── Container (UnifiedFiltersWidget) [conditional]
                    ├── Container (MenuCategoriesRows)
                    └── Expanded (MenuDishesListView)
```

#### Edge Cases Handled

1. **No menu data:** Show empty state
2. **No filters match:** Show "No items found" message
3. **Bold text enabled:** Adjust filter panel height (385px vs 350px)
4. **Multiple category rows:** Dynamic height for MenuCategoriesRows (42px or 72px)
5. **Missing timestamp:** Fallback to "missing date"

---

## Implementation Plan

### Phase 1: Port Custom Widgets (Days 1-3)

**Priority Order:**
1. `MenuDishesListView` — Core functionality
2. `MenuCategoriesRows` — Navigation
3. `UnifiedFiltersWidget` — Filtering UI

**For each widget:**
- Copy FlutterFlow source
- Adapt imports for pure Flutter
- Test with mock data
- Verify analytics tracking
- Run `flutter analyze`

### Phase 2: Build Page Structure (Day 4)

1. Create `view_full_menu_widget.dart`
2. Create `view_full_menu_model.dart`
3. Implement AppBar with back button
4. Add heading section
5. Add filter toggle
6. Integrate custom widgets
7. Connect callbacks

### Phase 3: Apply v2 Design (Day 5)

1. Update color tokens to match JSX design
2. Adjust spacing to match JSX layout
3. Update typography weights
4. Verify filter panel styling
5. Test category chip styling
6. Test menu item card styling

### Phase 4: Testing & Polish (Day 6)

1. Test filtering logic
2. Test category navigation
3. Test bottom sheet interactions
4. Verify analytics events
5. Test accessibility (bold text, font scaling)
6. Test empty states
7. Test with real data

---

## Critical Implementation Notes

### 1. Filter Logic Differences

**JSX Design vs FlutterFlow:**

- **JSX:** Three separate state variables (`selectedRestrictions`, `selectedPreferences`, `selectedAllergens`)
- **FlutterFlow:** Unified in `FFAppState` (`selectedDietaryRestrictionId`, `selectedDietaryPreferenceId`, `excludedAllergenIds`)

**Implementation:** Follow FlutterFlow pattern (ground truth), apply JSX visual design.

### 2. Translation System

**CRITICAL:** Always pass `languageCode` and `translationsCache` to custom widgets.

```dart
custom_widgets.MenuDishesListView(
  // ... other params
  languageCode: FFLocalizations.of(context).languageCode,
  translationsCache: FFAppState().translationsCache,
)
```

### 3. Filter Panel Height

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

The `MenuCategoriesRows` widget reports row count via callback.

### 5. Visible Item Count

**Updated by `UnifiedFiltersWidget`:**

```dart
onVisibleItemCountChanged: (count) async {
  FFAppState().visibleItemCount = count;
  safeSetState(() {});
}
```

This displays "Showing X items" text when filters are active.

### 6. Menu Data Flow

**Data is read from FFAppState, NOT fetched on this page:**

```dart
FFAppState().mostRecentlyViewedBusiness // Business info
FFAppState().mostRecentlyViewedBusinesMenuItems // Menu data
```

The Business Profile page fetches this data before navigating to Menu Full page.

---

## Analytics Tracking

### Page-Level Events

**On page load (initState):**
```dart
_model.pageStartTime = getCurrentTimestamp;
```

**On page dispose:**
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

### Widget-Level Events

**From MenuDishesListView:**
- `menu_item_viewed` — Item ID, business ID, item type
- Scroll depth tracking

**From UnifiedFiltersWidget:**
- `menu_filter_applied` — Filter type, filter value
- `menu_filter_cleared` — Filters cleared count

**From MenuCategoriesRows:**
- Category selection tracking

---

## Accessibility Considerations

### 1. Bold Text Support

**Detected in ActivityScope (main.dart):**
```dart
FFAppState().isBoldTextEnabled = textScaleFactor > 1.1;
FFAppState().fontScale = textScaleFactor > 1.1;
```

**Used for adaptive layout:**
- Filter panel height adjustment
- Spacing adjustments in custom widgets

### 2. Screen Reader Support

**Add semantic labels:**
```dart
Semantics(
  label: 'Back to business profile',
  button: true,
  child: FlutterFlowIconButton(...),
)
```

### 3. Touch Targets

**Ensure minimum 44×44pt touch targets:**
- Category chips
- Filter chips
- Menu item cards
- Toggle buttons

---

## Testing Checklist

### Functional Tests

- [ ] Page loads with menu data
- [ ] Back button returns to Business Profile
- [ ] Filter toggle shows/hides panel
- [ ] Filter selections update visible items
- [ ] "Ryd alle" clears all filters
- [ ] Category chips navigate to section
- [ ] Menu items open detail sheet
- [ ] Package items open package sheet
- [ ] Category info icon opens description sheet
- [ ] Filter summary text updates correctly
- [ ] Visible item count updates correctly
- [ ] Last updated timestamp displays correctly

### Visual Tests

- [ ] Colors match JSX design
- [ ] Typography matches JSX design
- [ ] Spacing matches JSX layout
- [ ] Filter chips styled correctly
- [ ] Category chips styled correctly
- [ ] Menu items styled correctly
- [ ] Bottom sheets styled correctly

### Analytics Tests

- [ ] Page view tracked on load
- [ ] Page duration tracked on exit
- [ ] Menu item clicks tracked
- [ ] Filter changes tracked
- [ ] Category changes tracked

### Edge Case Tests

- [ ] Empty menu data
- [ ] No filters match
- [ ] Bold text enabled
- [ ] Long category names
- [ ] Many categories (>10)
- [ ] Long item descriptions
- [ ] Missing timestamp
- [ ] Missing price data

### Accessibility Tests

- [ ] Bold text layout adapts
- [ ] Font scaling works
- [ ] Screen reader announces correctly
- [ ] Touch targets are adequate
- [ ] Color contrast meets WCAG AA

---

## File Locations

### FlutterFlow Source Files

**Page:**
- `_flutterflow_export/lib/profile/menu/view_full_menu/view_full_menu_widget.dart`
- `_flutterflow_export/lib/profile/menu/view_full_menu/view_full_menu_model.dart`

**Custom Widgets:**
- `_flutterflow_export/lib/custom_code/widgets/menu_dishes_list_view.dart`
- `_flutterflow_export/lib/custom_code/widgets/menu_categories_rows.dart`
- `_flutterflow_export/lib/custom_code/widgets/unified_filters_widget.dart`

**Bottom Sheets:**
- `_flutterflow_export/lib/profile/menu/item_bottom_sheet/item_bottom_sheet_widget.dart`
- `_flutterflow_export/lib/profile/menu/package_bottom_sheet/package_bottom_sheet_widget.dart`
- `_flutterflow_export/lib/profile/menu/category_description_sheet/category_description_sheet_widget.dart`

**Custom Actions:**
- `_flutterflow_export/lib/custom_code/actions/track_analytics_event.dart`
- `_flutterflow_export/lib/custom_code/actions/mark_user_engaged.dart`
- `_flutterflow_export/lib/custom_code/actions/start_menu_session.dart`
- `_flutterflow_export/lib/custom_code/actions/end_menu_session.dart`
- `_flutterflow_export/lib/custom_code/actions/update_menu_session_filter_metrics.dart`

### Pure Flutter Target Files

**Page:**
- `lib/pages/view_full_menu_page.dart`
- `lib/pages/view_full_menu_model.dart`

**Custom Widgets:**
- `lib/widgets/menu_dishes_list_view.dart`
- `lib/widgets/menu_categories_rows.dart`
- `lib/widgets/unified_filters_widget.dart`

**Bottom Sheets:**
- `lib/widgets/item_bottom_sheet.dart`
- `lib/widgets/package_bottom_sheet.dart`
- `lib/widgets/category_description_sheet.dart`

---

## Migration Status

- [ ] FlutterFlow source reviewed
- [ ] JSX design reviewed
- [ ] Page audit reviewed
- [ ] Custom widgets ported
- [ ] Page structure built
- [ ] v2 design applied
- [ ] Testing complete
- [ ] Documentation updated
- [ ] Code review passed
- [ ] Merged to main

---

## Related Documentation

- **Design System:** `C:\Users\Rikke\Documents\JourneyMate\_reference\journeymate-design-system.md`
- **Page Audit:** `C:\Users\Rikke\Documents\JourneyMate\_reference\page-audit.md`
- **JSX Design:** `pages/business_profile/menu_full_page.jsx`
- **PAGE_README:** `C:\Users\Rikke\Documents\JourneyMate-Organized\pages\03_menu_full_page\PAGE_README.md`
- **DESIGN_README:** `C:\Users\Rikke\Documents\JourneyMate-Organized\pages\03_menu_full_page\DESIGN_README_menu_full_page.md`

---

**Last Updated:** February 19, 2026
**Status:** Ready for Implementation

---

## Riverpod State

> Cross-reference: `_reference/MASTER_STATE_MAP.md`

### Reads
| Provider | Field | Used for |
|----------|-------|----------|
| `ref.watch(businessProvider)` | `currentBusiness` | Business name, last reviewed date in app bar heading (mostRecentlyViewedBusiness) |
| `ref.watch(businessProvider)` | `menuItems` | Full menu data passed to MenuDishesListView (mostRecentlyViewedBusinesMenuItems) |
| `ref.watch(businessProvider)` | `availableDietaryPreferences` | Available preference filter options in UnifiedFiltersWidget |
| `ref.watch(businessProvider)` | `availableDietaryRestrictions` | Available restriction filter options in UnifiedFiltersWidget |
| `ref.watch(translationsCacheProvider)` | `translationsCache` | All translated text; passed to all custom widgets |
| `ref.watch(localizationProvider)` | `currencyCode` | Menu price display in user's currency |
| `ref.watch(localizationProvider)` | `exchangeRate` | Price conversion for non-DKK currencies |
| `ref.watch(analyticsProvider)` | `menuSessionData` | Read by endMenuSession on dispose to compute session duration |
| `ref.watch(accessibilityProvider)` | `fontScaleLarge` | Filter panel height: 385px (true) or 350px (false) |
| `ref.watch(accessibilityProvider)` | `isBoldTextEnabled` | All text rendered one weight heavier |

### Writes
| Provider | Notifier method | Trigger |
|----------|----------------|---------|
| `ref.read(analyticsProvider.notifier).updateMenuSessionFilterMetrics(...)` | `updateMenuSessionFilterMetrics` | User applies/removes a dietary filter in UnifiedFiltersWidget |
| `ref.read(analyticsProvider.notifier).clearMenuSession()` | `clearMenuSession` | endMenuSession called on page dispose |

### Local state (NOT in providers)
| Variable | Type | Purpose |
|----------|------|---------|
| `_selectedCategoryId` | `int` | Which category tab is active (mostRecentlyViewedBusinessSelectedCategoryID) |
| `_selectedMenuId` | `int` | Which menu tab is active (mostRecentlyViewedBusinessSelectedMenuID) |
| `_selectedDietaryPreferenceId` | `int` | Active dietary preference filter (selectedDietaryPreferenceId) |
| `_excludedAllergyIds` | `List<int>` | Active allergy exclusions (excludedAllergyIds) |
| `_selectedRestrictionIds` | `List<int>` | Active restriction filters (selectedDietaryRestrictionId) |
| `_visibleItemCount` | `int` | "Show more" item count (visibleItemCount) |
| `_pageStartTime` | `DateTime` | Analytics duration calculation |
