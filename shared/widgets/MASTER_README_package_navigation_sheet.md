# PackageNavigationSheet Widget

**Source File:** `C:\Users\Rikke\Documents\JourneyMate\_flutterflow_export\lib\custom_code\widgets\package_navigation_sheet.dart`

**Widget Type:** StatefulWidget (Custom Bottom Sheet with Nested Navigation)

---

## Purpose

PackageNavigationSheet is a sophisticated bottom sheet widget that provides a two-level navigation experience for viewing menu package details and individual menu items. It creates a native navigation stack within a modal bottom sheet, allowing users to:

1. View package overview (name, price, description, image, courses)
2. Navigate to individual menu item details with platform-specific transitions
3. Navigate back from item details to package overview
4. Close the sheet entirely

The widget uses a nested `Navigator` with platform-specific transitions (iOS swipe-back gestures, Android slide animations), image display with fallback states, currency conversion, expandable information sections, and full localization support.

**Key Use Case:** When a user taps on a menu package in the Business Profile page, this sheet displays the package details and allows drill-down into individual items without leaving the sheet context.

---

## Function Signature

```dart
PackageNavigationSheet({
  super.key,
  this.width,
  this.height,
  required this.normalizedMenuData,
  required this.packageId,
  required this.chosenCurrency,
  required this.originalCurrencyCode,
  required this.exchangeRate,
  required this.currentLanguage,
  required this.businessName,
  required this.translationsCache,
})
```

---

## Parameters

### Optional Parameters

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `width` | `double?` | Width of the bottom sheet container | `null` (full width) |
| `height` | `double?` | Height of the bottom sheet container | `null` (90% of screen height) |

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `normalizedMenuData` | `dynamic` | Normalized menu data structure containing categories and menu items. Expected to be `Map<String, dynamic>` with keys `'categories'` and `'menu_items'`. |
| `packageId` | `int` | The ID of the package to display. Used to find the matching package in `normalizedMenuData`. |
| `chosenCurrency` | `String` | The currency code selected by the user (e.g., "DKK", "EUR"). Used for price display. |
| `originalCurrencyCode` | `String` | The original currency code of the menu prices. Used for conversion calculations. |
| `exchangeRate` | `double` | The exchange rate for currency conversion. Applied when `chosenCurrency` differs from `originalCurrencyCode`. |
| `currentLanguage` | `String` | The current language code (e.g., "da", "en"). Used for UI translations and content display. |
| `businessName` | `String` | The name of the business/restaurant. Used in information source disclaimers. |
| `translationsCache` | `dynamic` | The translations cache object containing all UI text translations. Passed to `getTranslations()`. |

---

## Dependencies

### Imported Packages

```dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
```

### FlutterFlow Custom Dependencies

```dart
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart';       // PackageCoursesDisplay
import '/custom_code/actions/index.dart';       // markUserEngaged()
import '/flutter_flow/custom_functions.dart';   // getTranslations(), convertAndFormatPrice()
```

### Custom Widgets Used

- **`PackageCoursesDisplay`** — Displays the courses within a package as a scrollable list with tappable items.

### Custom Functions Used

| Function | Purpose | Parameters |
|----------|---------|------------|
| `getTranslations()` | Retrieves localized UI text | `(languageCode, translationKey, translationsCache)` |
| `convertAndFormatPrice()` | Converts and formats prices with currency | `(price, originalCurrency, exchangeRate, targetCurrency)` |
| `convertDietaryPreferencesToString()` | Converts dietary type IDs to human-readable string | `(dietaryTypeIds, languageCode, isBeverage, translationsCache)` |
| `convertAllergiesToString()` | Converts allergy IDs to human-readable string | `(allergyIds, languageCode, isBeverage, translationsCache)` |

### Custom Actions Used

| Action | Purpose | Usage |
|--------|---------|-------|
| `markUserEngaged()` | Tracks user engagement for analytics | Called on close button, back button, and expand/collapse interactions |

---

## Data Structure Requirements

### normalizedMenuData Structure

Expected format:
```dart
{
  'categories': [
    {
      'category_type': 'menu_package',
      'package_id': 1,
      'package_name': 'Lunch Menu',
      'package_description': 'A delicious three-course meal',
      'package_image_url': 'https://...',
      'base_price': 250.0,
      // ... other package fields
    },
    // ... more categories
  ],
  'menu_items': [
    {
      'menu_item_id': 101,
      'item_name': 'Caesar Salad',
      'item_description': 'Fresh romaine lettuce...',
      'item_image_url': 'https://...',
      'premium_upcharge': 25.0,
      'is_beverage': false,
      'dietary_type_ids': [1, 2],
      'allergy_ids': [3, 5],
      // ... other item fields
    },
    // ... more menu items
  ]
}
```

### Package Identification Logic

The widget searches for a category where:
- `category_type == 'menu_package'`
- `package_id == widget.packageId`

If no matching package is found, an error state is displayed with the translation key `'error_package_not_found'`.

---

## State Management

### State Variables

| Variable | Type | Purpose | Scope |
|----------|------|---------|-------|
| `_navigatorKey` | `GlobalKey<NavigatorState>` | Controls the nested navigator for package/item views | Widget state |
| `_packageData` | `Map<String, dynamic>?` | Stores the extracted package data | Widget state |
| `_menuItemMap` | `Map<int, Map<String, dynamic>>` | O(1) lookup map for menu items by ID | Widget state |

### State Flow

1. **initState()** → `_extractPackageData()`
2. **_extractPackageData()** → Builds `_menuItemMap` and finds `_packageData`
3. **build()** → If `_packageData` is null, show error; otherwise show navigation sheet
4. **Navigator** → Routes between package view and item detail view

### State Updates on Widget Changes

The widget rebuilds when `translationsCache` or `currentLanguage` changes (via `didUpdateWidget`).

---

## FFAppState Usage

**None.** This widget does not directly access or modify `FFAppState`. All data is passed via constructor parameters.

---

## UI Structure & Behavior

### Overall Layout

```
Bottom Sheet Container
├── Nested Navigator
    ├── Package View Page (initial route)
    │   ├── Header Section
    │   │   ├── Package Image (if exists)
    │   │   ├── Swipe Bar
    │   │   └── Close Button
    │   ├── Content Section
    │   │   ├── Package Name
    │   │   ├── Package Price
    │   │   ├── Package Description
    │   │   └── Package Courses Display Widget
    │
    └── Item Detail Page (pushed route: '/item')
        ├── Header Section
        │   ├── Item Image (if exists)
        │   ├── Swipe Bar
        │   └── Back Button
        └── Scrollable Content
            ├── Item Name
            ├── Premium Price Badge (if exists)
            ├── Item Description
            ├── Divider
            └── Additional Information Section
                ├── Dietary Information
                ├── Allergen Information
                └── Information Source (expandable)
```

### Bottom Sheet Dimensions

- **Default Height:** 90% of screen height (`_defaultSheetHeightFactor = 0.90`)
- **Border Radius:** 20.0 (top corners only)
- **Background Color:** White

### Navigation Behavior

#### Package View → Item Detail

- **Trigger:** User taps on a menu item in `PackageCoursesDisplay`
- **Method:** `_navigateToItem(itemData)` → `_navigatorKey.currentState?.pushNamed('/item', arguments: itemData)`
- **Transition:** Platform-specific
  - **iOS:** `CupertinoPageRoute` (swipe-back gesture enabled)
  - **Android/Other:** Custom slide transition (300ms, easeInOut curve)

#### Item Detail → Package View

- **Trigger:** User taps back button or swipes back (iOS)
- **Method:** `onBack()` → `_navigatorKey.currentState?.pop()`
- **Transition:** Reverse of push transition

#### Close Sheet

- **Trigger:** User taps close button (X) on package view
- **Method:** `_handleClose(context)` → `Navigator.of(context, rootNavigator: true).pop()`
- **Effect:** Dismisses the entire bottom sheet

### Platform-Specific Transitions

#### iOS Transition (CupertinoPageRoute)

- Native iOS swipe-back gesture
- Default Cupertino page transition animation
- `maintainState: true` preserves package view state

#### Android Transition (PageRouteBuilder)

- **Push Animation:**
  - New page slides in from right (Offset(1.0, 0.0) → Offset.zero)
  - Previous page slides left slightly (Offset.zero → Offset(-0.3, 0.0))
- **Duration:** 300ms
- **Curve:** easeInOut
- **Pop Animation:** Reverse of push

### Image Display

#### Package Image

- **Display Conditions:** `package_image_url` exists and is non-empty
- **Height:** 200px when displayed, 64px header when no image
- **Fit:** `BoxFit.cover`
- **Error State:** Grey background with image icon

#### Item Image

- **Display Conditions:** `item_image_url` exists and is non-empty
- **Height:** 200px when displayed, 64px header when no image
- **Fit:** `BoxFit.cover`
- **Error State:** Grey background with image icon

### Swipe Bar Indicator

Present on both package and item views:
- **Dimensions:** 80px × 4px
- **Color:** `#14181B`
- **Position:** Top center of sheet
- **Purpose:** Visual affordance for swipe-to-dismiss gesture

### Close Button (Package View)

- **Position:** Top-left (12px from top and left)
- **Size:** 40px × 40px
- **Background:** `#F2F3F5`
- **Icon:** `Icons.close` (30px, `#14181B`)
- **Action:** Calls `markUserEngaged()` then closes entire sheet

### Back Button (Item View)

- **Position:** Top-left (12px from top and left)
- **Size:** 40px × 40px
- **Background:** `#F2F3F5`
- **Icon:** `Icons.arrow_back` (30px, `#14181B`)
- **Action:** Calls `markUserEngaged()` then pops to package view

### Package View Content

#### Package Name

- **Font:** Roboto, 22px, weight 500
- **Color:** Black

#### Package Price

- **Format:** Converted and formatted via `convertAndFormatPrice()`
- **Font:** Roboto, 18px, weight 400
- **Color:** `#E9874B` (orange)
- **Visibility:** Hidden if `formattedPrice` is null or empty

#### Package Description

- **Font:** Roboto, 18px, weight 300
- **Color:** `#14181B`
- **Visibility:** Hidden if description is empty

#### Package Courses Display

- **Widget:** `PackageCoursesDisplay` (separate custom widget)
- **Height:** 60% of screen height
- **Purpose:** Displays courses and menu items within the package
- **Interaction:** `onItemTap` callback navigates to item detail

### Item Detail Content

#### Item Name

- **Font:** Roboto, 22px, weight 600
- **Color:** Black

#### Premium Price Badge

- **Display Condition:** `premium_upcharge > 0`
- **Format:** `"+ [formatted price]"` (e.g., "+ 25 DKK")
- **Font:** Roboto, 15px, weight 500
- **Color:** `#E9874B` (orange)
- **Background:** Orange with 10% opacity
- **Padding:** 6px horizontal, 2px vertical
- **Border Radius:** 4px

#### Item Description

- **Font:** Roboto, 18px, weight 300
- **Color:** `#14181B`
- **Spacing:** 4px from premium badge (if exists), 0px otherwise
- **Visibility:** Hidden if description is empty

#### Divider

- **Color:** `#57636C`
- **Thickness:** 1px
- **Spacing:** 20px from description

#### Additional Information Section

**Display Condition:** Only shown if `is_beverage == false`

Contains three subsections:
1. **Dietary Information**
2. **Allergen Information**
3. **Information Source** (expandable accordion)

##### Dietary Information

- **Header:** Translation key `'info_header_dietary'`
- **Content:** Result of `convertDietaryPreferencesToString(dietary_type_ids, currentLanguage, isBeverage, translationsCache)`
- **Font:** Roboto, 15px, weight 300
- **Color:** Black87

##### Allergen Information

- **Header:** Translation key `'info_header_allergens'`
- **Content:** Result of `convertAllergiesToString(allergy_ids, currentLanguage, isBeverage, translationsCache)`
- **Font:** Roboto, 15px, weight 300
- **Color:** Black87

##### Information Source (Expandable)

Implemented as `_InformationSourceSection` widget:

- **Header:** Translation key `'info_header_source'`
- **Expand/Collapse Icon:** Arrow up/down (24px)
- **Animation:** 100ms linear expansion
- **Content When Expanded:**
  - **Business Disclaimer:** Translation key `'info_disclaimer_business'` with `[businessName]` replaced by actual business name
  - **JourneyMate Disclaimer:** Translation key `'info_disclaimer_journeymate'`
- **User Interaction:** Calls `markUserEngaged()` on expand/collapse

---

## Translation Keys

All translation keys are retrieved via `getTranslations(currentLanguage, key, translationsCache)`.

### Required Translation Keys

| Key | Usage Context | Example English Text |
|-----|---------------|---------------------|
| `error_package_not_found` | Error state when package ID not found | "Package not found" |
| `info_header_additional` | Header for additional information section | "Additional Information" |
| `info_header_dietary` | Label for dietary preferences | "Dietary Preferences" |
| `info_header_allergens` | Label for allergen information | "Allergens" |
| `info_header_source` | Label for information source accordion | "Information Source" |
| `info_disclaimer_business` | Business-provided disclaimer (contains `[businessName]` placeholder) | "This information is provided by [businessName] and may not be complete." |
| `info_disclaimer_journeymate` | JourneyMate platform disclaimer | "JourneyMate does not guarantee the accuracy of this information." |

---

## Analytics Events

### User Engagement Tracking

The widget calls `markUserEngaged()` in the following scenarios:

| Action | Location | Method |
|--------|----------|--------|
| Close button tapped | Package View | `_PackageViewPage._buildCloseButton()` line 512 |
| Back button tapped | Item Detail View | `_ItemDetailPage._buildBackButton()` line 834 |
| Information source expanded/collapsed | Item Detail View | `_InformationSourceSection._toggleExpanded()` line 1146 |

**Note:** No direct `trackAnalyticsEvent()` calls exist in this widget. All tracking goes through `markUserEngaged()`.

---

## Usage Examples

### Example 1: Basic Usage

```dart
// From Business Profile page when user taps on a package
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => PackageNavigationSheet(
    normalizedMenuData: normalizedMenuData,
    packageId: selectedPackageId,
    chosenCurrency: FFAppState().chosenCurrency,
    originalCurrencyCode: businessCurrencyCode,
    exchangeRate: FFAppState().exchangeRate,
    currentLanguage: FFAppState().languageCode,
    businessName: businessName,
    translationsCache: FFAppState().translationsCache,
  ),
);
```

### Example 2: With Custom Dimensions

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => PackageNavigationSheet(
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height * 0.85,
    normalizedMenuData: normalizedMenuData,
    packageId: 42,
    chosenCurrency: 'EUR',
    originalCurrencyCode: 'DKK',
    exchangeRate: 0.134,
    currentLanguage: 'en',
    businessName: 'Noma',
    translationsCache: translationsCache,
  ),
);
```

### Example 3: Integration with Menu Data Fetching

```dart
// Assume menu data comes from BuildShip API
final normalizedMenuData = await fetchNormalizedMenuData(businessId);

// User taps on package card
onPackageTap: (packageId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => PackageNavigationSheet(
      normalizedMenuData: normalizedMenuData,
      packageId: packageId,
      chosenCurrency: FFAppState().chosenCurrency,
      originalCurrencyCode: normalizedMenuData['currency_code'] ?? 'DKK',
      exchangeRate: FFAppState().exchangeRate,
      currentLanguage: FFAppState().languageCode,
      businessName: businessName,
      translationsCache: FFAppState().translationsCache,
    ),
  );
}
```

---

## Error Handling

### Error Conditions

| Condition | Handling | User Experience |
|-----------|----------|-----------------|
| `normalizedMenuData` is not a Map | Data extraction fails silently | Error state displayed |
| `packageId` not found in categories | `_packageData` remains null | "Package not found" message displayed |
| Package image URL fails to load | Image error builder triggered | Grey background with image icon |
| Item image URL fails to load | Image error builder triggered | Grey background with image icon |
| Price conversion returns null | Price display hidden | No price shown |
| Empty description | Widget hidden | No description displayed |
| Empty dietary/allergen data | Empty string displayed | Shows header with empty content |

### Defensive Programming

- **Type Checking:** All data extraction checks for proper types (`is Map<String, dynamic>`, `is List<dynamic>`)
- **Null Safety:** Extensive use of null-aware operators (`?.`, `??`) and safe casting (`.whereType<Map<String, dynamic>>()`)
- **Fallback Values:** Default values for all nullable data (empty strings, 0.0 for prices, false for booleans)
- **Optional Display:** UI elements check data availability before displaying (descriptions, prices, images)

---

## Testing Checklist

### Unit Tests

- [ ] **Data Extraction**
  - [ ] Verify `_buildMenuItemLookupMap` creates correct O(1) lookup map
  - [ ] Verify `_findTargetPackage` finds correct package by ID
  - [ ] Verify `_isTargetPackage` correctly identifies matching package
  - [ ] Test with missing package ID (should result in null `_packageData`)
  - [ ] Test with malformed data structures

- [ ] **Translation Retrieval**
  - [ ] Verify `_getUIText` returns correct translation for each key
  - [ ] Test with missing translation keys (should gracefully fallback)
  - [ ] Test with different language codes

- [ ] **Price Formatting**
  - [ ] Test `convertAndFormatPrice` with various currencies
  - [ ] Test with null/empty price values
  - [ ] Test premium upcharge formatting with "+" prefix

### Widget Tests

- [ ] **Initial Render**
  - [ ] Widget displays package view on first render
  - [ ] Error state displays when package not found
  - [ ] Package image displays when URL provided
  - [ ] No image header displays when URL missing
  - [ ] Package details (name, price, description) display correctly

- [ ] **Navigation**
  - [ ] Tapping menu item navigates to item detail view
  - [ ] Back button returns to package view
  - [ ] Close button dismisses entire sheet
  - [ ] Navigator key controls nested navigation correctly

- [ ] **Platform-Specific Transitions**
  - [ ] iOS uses CupertinoPageRoute
  - [ ] Android uses custom slide transition
  - [ ] Transition animations complete correctly

- [ ] **Item Detail View**
  - [ ] Item name, image, description display correctly
  - [ ] Premium price badge shows when upcharge > 0
  - [ ] Premium price badge hidden when upcharge = 0
  - [ ] Dietary information displays correctly
  - [ ] Allergen information displays correctly
  - [ ] Information source accordion expands/collapses

- [ ] **Information Source Accordion**
  - [ ] Starts collapsed
  - [ ] Expands on tap with correct animation
  - [ ] Collapses on second tap
  - [ ] Displays business name in disclaimer
  - [ ] Calls `markUserEngaged()` on interaction

- [ ] **Responsive Behavior**
  - [ ] Sheet height adjusts to screen size (90% default)
  - [ ] Custom height/width respected when provided
  - [ ] Content scrolls when exceeds viewport

### Integration Tests

- [ ] **End-to-End Flow**
  - [ ] Open sheet from Business Profile page
  - [ ] View package details
  - [ ] Navigate to item detail
  - [ ] Navigate back to package
  - [ ] Close sheet
  - [ ] Verify parent page state unaffected

- [ ] **Data Flow**
  - [ ] Package data extracted correctly from normalized menu data
  - [ ] Menu item lookup map provides O(1) access
  - [ ] Currency conversion applied correctly throughout
  - [ ] Translations displayed in correct language

- [ ] **State Management**
  - [ ] Package view state preserved during item detail navigation
  - [ ] Rebuilds correctly when translations/language changes
  - [ ] No memory leaks from navigator key

### Edge Cases

- [ ] Empty package description
- [ ] Empty item description
- [ ] Zero base price
- [ ] Zero premium upcharge
- [ ] Empty dietary preferences list
- [ ] Empty allergens list
- [ ] Missing image URLs (null or empty string)
- [ ] Beverage items (should hide additional information)
- [ ] Very long package/item names
- [ ] Very long descriptions
- [ ] Multiple rapid navigation actions
- [ ] Sheet dismissed during transition animation

### Accessibility Tests

- [ ] Screen reader announces package name
- [ ] Screen reader announces item name
- [ ] Close/back buttons have semantic labels
- [ ] Expandable accordion announces expanded/collapsed state
- [ ] Image error states have semantic descriptions

### Performance Tests

- [ ] O(1) menu item lookup verified
- [ ] No unnecessary rebuilds during navigation
- [ ] Smooth transition animations (60fps)
- [ ] No frame drops during image loading
- [ ] Efficient handling of large package courses lists

---

## Migration Notes for Phase 3

### State Management Migration

**Current:** Widget-level state (`_packageData`, `_menuItemMap`, `_isExpanded`)

**Phase 3 Target:** Migrate to Riverpod where appropriate

```dart
// Package data could be provided via Riverpod provider
final packageProvider = FutureProvider.family<Map<String, dynamic>, int>(
  (ref, packageId) async {
    final menuData = ref.watch(normalizedMenuDataProvider);
    return extractPackageData(menuData, packageId);
  },
);

// Usage in widget
Widget build(BuildContext context, WidgetRef ref) {
  final packageAsync = ref.watch(packageProvider(widget.packageId));

  return packageAsync.when(
    data: (package) => _buildNavigationSheet(),
    loading: () => _buildLoadingState(),
    error: (err, stack) => _buildErrorState(),
  );
}
```

**Recommendation:** Keep widget-level state for UI-only concerns (like `_isExpanded`). Consider Riverpod for shared package/menu data that might be used across multiple widgets.

### FFAppState Dependencies

**Current:** No direct `FFAppState` access (all data passed via parameters)

**Phase 3 Target:** Replace parameter passing with Riverpod providers

```dart
// Define providers for app-level state
final chosenCurrencyProvider = StateProvider<String>((ref) => 'DKK');
final languageCodeProvider = StateProvider<String>((ref) => 'da');
final translationsCacheProvider = StateProvider<Map>((ref) => {});

// Simplify widget constructor
PackageNavigationSheet({
  required this.normalizedMenuData,
  required this.packageId,
  required this.businessName,
});

// Access state via ref.watch in build method
final chosenCurrency = ref.watch(chosenCurrencyProvider);
final languageCode = ref.watch(languageCodeProvider);
```

### Translation System Migration

**Current:** Manual `getTranslations()` function calls

**Phase 3 Target:** Centralized translation service with Riverpod

```dart
// Translation provider
final translationProvider = Provider<TranslationService>((ref) {
  final languageCode = ref.watch(languageCodeProvider);
  final cache = ref.watch(translationsCacheProvider);
  return TranslationService(languageCode, cache);
});

// Usage in widget
final t = ref.watch(translationProvider);
Text(t.translate('error_package_not_found'))
```

### Analytics Migration

**Current:** Direct `markUserEngaged()` calls

**Phase 3 Target:** Analytics service with Riverpod

```dart
final analyticsProvider = Provider<AnalyticsService>((ref) => AnalyticsService());

// Usage
onPressed: () {
  ref.read(analyticsProvider).markEngaged();
  onClose();
}
```

### Custom Functions Migration

**Current:** Global functions (`convertAndFormatPrice`, `convertDietaryPreferencesToString`, `convertAllergiesToString`)

**Phase 3 Target:** Service classes or extension methods

```dart
// Price service
class PriceService {
  String formatPrice(double amount, String fromCurrency, double rate, String toCurrency) {
    // Implementation
  }
}

// Or extension method
extension PriceFormatting on double {
  String toFormattedPrice(String currency, double exchangeRate) {
    // Implementation
  }
}
```

### Navigation Migration

**Current:** Manual `Navigator` with `GlobalKey`

**Phase 3 Target:** Consider `go_router` for nested navigation

```dart
// Define routes
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/package/:id',
      builder: (context, state) => PackageViewPage(
        packageId: int.parse(state.params['id']!),
      ),
      routes: [
        GoRoute(
          path: 'item/:itemId',
          builder: (context, state) => ItemDetailPage(
            itemId: int.parse(state.params['itemId']!),
          ),
        ),
      ],
    ),
  ],
);
```

**Note:** If navigation stack complexity remains low, keeping manual `Navigator` is acceptable. Evaluate based on overall app routing strategy.

### Image Loading Migration

**Current:** `Image.network` with manual error builder

**Phase 3 Target:** Use `cached_network_image` package for performance

```dart
CachedNetworkImage(
  imageUrl: packageData['package_image_url'],
  height: _imageHeight,
  width: double.infinity,
  fit: BoxFit.cover,
  placeholder: (context, url) => _buildImagePlaceholder(),
  errorWidget: (context, url, error) => _buildImageError(),
)
```

### Platform Detection Migration

**Current:** `Theme.of(context).platform == TargetPlatform.iOS`

**Phase 3 Target:** Create platform detection service

```dart
final platformProvider = Provider<PlatformService>((ref) => PlatformService());

class PlatformService {
  bool get isIOS => Theme.of(context).platform == TargetPlatform.iOS;
  bool get isAndroid => Theme.of(context).platform == TargetPlatform.android;
}
```

### Constants Migration

**Current:** Private constants within widget classes

**Phase 3 Target:** Extract to theme/constants files

```dart
// lib/shared/constants/dimensions.dart
class Dimensions {
  static const double bottomSheetBorderRadius = 20.0;
  static const double bottomSheetDefaultHeightFactor = 0.90;
  static const double packageImageHeight = 200.0;
  // ... etc
}

// lib/shared/constants/colors.dart
class AppColors {
  static const Color swipeBar = Color(0xFF14181B);
  static const Color orangePrice = Color(0xFFE9874B);
  // ... etc
}
```

### Component Extraction

**Current:** Three widget classes in one file (`PackageNavigationSheet`, `_PackageViewPage`, `_ItemDetailPage`, `_InformationSourceSection`)

**Phase 3 Target:** Consider splitting into separate files if reusability emerges

```
lib/
  widgets/
    package_navigation/
      package_navigation_sheet.dart          (main widget)
      package_view_page.dart                 (if reused elsewhere)
      item_detail_page.dart                  (if reused elsewhere)
      information_source_section.dart        (if reused elsewhere)
```

**Recommendation:** Keep in single file unless `_PackageViewPage` or `_ItemDetailPage` need to be used independently. Current architecture is clean and maintainable as-is.

### Testing Strategy

1. **Write unit tests first** for data extraction logic (`_extractPackageData`, `_buildMenuItemLookupMap`, `_findTargetPackage`)
2. **Widget tests** for each sub-component (`_PackageViewPage`, `_ItemDetailPage`, `_InformationSourceSection`)
3. **Integration tests** for full navigation flow (package → item → back → close)
4. **Golden tests** for visual regression (package view, item view, error state)

### Breaking Changes to Anticipate

1. **Translation system change** — Will require updating all `_getUIText()` calls
2. **Price formatting change** — Will require updating `convertAndFormatPrice()` usage
3. **Analytics system change** — Will require updating `markUserEngaged()` calls
4. **State management change** — Will require refactoring constructor parameters and state access

### Compatibility Notes

- **Maintains backward compatibility** with FlutterFlow structure during migration
- **Can be migrated incrementally** — Start with translation system, then state management, then analytics
- **No external API changes** required — All data comes from parent widget via parameters
- **PackageCoursesDisplay dependency** must be migrated in parallel or before this widget

---

## Design System Alignment

### Colors

| Usage | Color Code | Hex | Design Token |
|-------|-----------|-----|--------------|
| Swipe bar | `Color(0xFF14181B)` | #14181B | Dark gray (nearly black) |
| Close/back button background | `Color(0xFFF2F3F5)` | #F2F3F5 | Light gray |
| Close/back icon | `Color(0xFF14181B)` | #14181B | Dark gray |
| Package price | `Color(0xFFE9874B)` | #E9874B | Orange (pricing color) |
| Divider | `Color(0xFF57636C)` | #57636C | Medium gray |
| Text primary | `Colors.black` | #000000 | Black |
| Text secondary | `Colors.black87` | #000000DD | Black 87% opacity |
| Description text | `Color(0xFF14181B)` | #14181B | Dark gray |
| Image error background | `Colors.grey[200]` | #EEEEEE | Light gray |
| Image error icon | `Colors.grey` | #9E9E9E | Gray |
| Sheet background | `Colors.white` | #FFFFFF | White |

**Alignment Check:**
- Orange `#E9874B` differs slightly from design system orange `#E8751A` — Consider standardizing in Phase 3
- Dark gray `#14181B` is not in the main design system — Document as UI element color

### Typography

| Element | Font | Size | Weight | Line Height |
|---------|------|------|--------|-------------|
| Package name | Roboto | 22px | 500 | Default |
| Package price | Roboto | 18px | 400 | Default |
| Package description | Roboto | 18px | 300 | Default |
| Item name | Roboto | 22px | 600 | Default |
| Premium price | Roboto | 15px | 500 | Default |
| Item description | Roboto | 18px | 300 | Default |
| Info header | Roboto | 16px | 500 | Default |
| Info label | Roboto | 15px | 400 | Default |
| Info text | Roboto | 15px | 300 | Default |

**Alignment Check:**
- Roboto font family consistent across app
- Weight 300 (light) used for body text — Verify legibility on all devices
- Consider defining typography scale in theme for consistency

### Spacing

| Usage | Value |
|-------|-------|
| Content horizontal padding | 28px |
| Content top spacing | 12px |
| Title to price spacing | 2px |
| Price to description spacing | 4px |
| Description to divider spacing | 20px |
| Divider to info spacing | 20px |
| Info header spacing | 4px |
| Dietary to allergen spacing | 12px |
| Allergen to source spacing | 12px |
| Bottom padding | 20px |

**Alignment Check:**
- 28px horizontal padding is generous — Verify consistency with other sheets
- Tight spacing (2px, 4px) between related elements — Good for visual hierarchy

### Animation

| Animation | Duration | Curve |
|-----------|----------|-------|
| Page transition | 300ms | easeInOut |
| Information source expand | 100ms | linear |

**Alignment Check:**
- 300ms is standard for page transitions
- 100ms linear for accordion is very fast — Consider easeInOut for smoother feel

---

## Performance Considerations

### Optimizations Implemented

1. **O(1) Menu Item Lookup:** `_menuItemMap` built in `initState()` for fast item access
2. **Lazy Loading:** Item detail view only built when navigated to
3. **Const Constructors:** Extensive use of `const` for static widgets
4. **Image Caching:** `Image.network` automatically caches images
5. **State Preservation:** `maintainState: true` on routes prevents rebuilds

### Potential Performance Issues

1. **Large Package Courses:** If `PackageCoursesDisplay` renders hundreds of items without lazy loading
2. **Heavy Translation Cache:** If `translationsCache` is extremely large, passing it around could be expensive
3. **Nested Navigation Overhead:** Extra navigator adds slight overhead vs. simple page replacement
4. **Image Loading:** Multiple network images could cause jank if not using image caching properly

### Recommendations for Phase 3

1. **Lazy Load Images:** Use `cached_network_image` package for better performance
2. **Profile Translation Cache:** Measure impact of passing large translation cache; consider Riverpod provider
3. **Monitor Navigator Memory:** Ensure nested navigator doesn't leak memory
4. **Implement Shimmer Loading:** Add loading states for smoother UX while data loads

---

## Related Widgets

| Widget | Relationship | Location |
|--------|--------------|----------|
| `PackageCoursesDisplay` | Child widget — displays courses within package | `lib/custom_code/widgets/package_courses_display.dart` |
| `ItemDetailSheet` | Similar pattern — single item detail sheet (no nested navigation) | `lib/custom_code/widgets/item_detail_sheet.dart` |
| Business Profile Page | Parent — triggers this sheet when package tapped | `lib/pages/business_profile_page.dart` |

---

## Known Limitations

1. **No Animations Between Text Changes:** When language changes, text updates instantly without transition
2. **No Loading State:** Package extraction happens synchronously; no loading indicator if data processing is slow
3. **No Refresh Mechanism:** If menu data changes externally, sheet won't update (must close and reopen)
4. **Limited Error Messaging:** Only displays "Package not found" — doesn't distinguish between network errors, data errors, etc.
5. **Hardcoded Dimensions:** Many dimensions are hardcoded constants rather than responsive to screen size/orientation
6. **No Orientation Handling:** Sheet height is percentage of screen height; might need adjustment for landscape
7. **No A11y Labels:** Close/back buttons lack explicit semantic labels for screen readers

---

## Future Enhancements

1. **Favorites/Bookmarking:** Add ability to favorite individual items within package
2. **Share Functionality:** Add share button to share package or item details
3. **Add to Cart:** Integrate with ordering system to add package to cart
4. **Customization:** Allow selecting substitute items or modifications within package
5. **Gallery View:** Add swipeable gallery for multiple package/item images
6. **Nutritional Information:** Expand additional information to include calories, macros
7. **Reviews/Ratings:** Show reviews/ratings for package or items (if available)
8. **Availability Display:** Show which courses/items are currently available
9. **Portion Size Selection:** Allow selecting package size (single, double, etc.)
10. **Accessibility Improvements:** Add semantic labels, improve screen reader support

---

## Conclusion

PackageNavigationSheet is a well-architected, feature-rich bottom sheet widget that provides sophisticated nested navigation within a modal context. Its use of platform-specific transitions, defensive programming, and clean separation of concerns makes it a strong candidate for direct migration to Phase 3 with minimal refactoring.

**Migration Priority:** Medium-High (required for full menu browsing experience)

**Migration Complexity:** Medium (depends on `PackageCoursesDisplay` and multiple custom functions)

**Recommended Migration Order:**
1. Migrate translation system first
2. Migrate price formatting functions
3. Migrate `PackageCoursesDisplay` widget
4. Migrate this widget
5. Update parent integration points

**Estimated Migration Effort:** 2-3 days (including tests and integration)
