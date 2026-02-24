# PackageCoursesDisplay Widget

**File:** `lib/custom_code/widgets/package_courses_display.dart`
**Type:** Custom StatefulWidget
**Category:** Menu Display / Package Details
**Last Updated:** 2026-02-19

---

## Purpose

Displays the hierarchical structure of menu package courses with their associated items. Used in the menu package expanded info sheet to show what's included in a multi-course meal package. Supports currency conversion, premium upcharges, and interactive item selection.

**Key Responsibilities:**
- Render package → courses → menu items hierarchy
- Display premium upcharge badges for items with extra cost
- Handle currency conversion and price formatting
- Enable item tap interactions for detailed views
- Provide visual hierarchy with styled headers and indentation
- Support translation system for UI text

**Visual Structure:**
```
Package Container
├── Course 1
│   ├── Course Name (bold, 20px)
│   ├── Course Description (italic, lighter)
│   └── Items
│       ├── Item A (with left border indicator)
│       │   ├── Name + Premium Badge (if upcharge > 0)
│       │   └── Description
│       └── Item B
│           ├── Name
│           └── Description
├── Course 2
│   └── [same structure]
└── Course 3
    └── [same structure]
```

---

## Function Signature

```dart
class PackageCoursesDisplay extends StatefulWidget {
  const PackageCoursesDisplay({
    super.key,
    this.width,
    required this.height,
    required this.menuData,
    required this.packageId,
    required this.chosenCurrency,
    required this.originalCurrencyCode,
    required this.exchangeRate,
    required this.languageCode,
    required this.translationsCache,
    this.onItemTap,
  });

  final double? width;
  final double height;
  final dynamic menuData;
  final int packageId;
  final String chosenCurrency;
  final String originalCurrencyCode;
  final double exchangeRate;
  final String languageCode;
  final dynamic translationsCache;
  final Future Function(dynamic itemData)? onItemTap;
}
```

---

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `height` | `double` | Fixed height for the scrollable container (typically 60% of screen height) |
| `menuData` | `dynamic` | Complete menu data structure containing all items and categories |
| `packageId` | `int` | ID of the package to display courses for |
| `chosenCurrency` | `String` | User's selected currency code (e.g., 'USD', 'EUR', 'DKK') |
| `originalCurrencyCode` | `String` | Restaurant's original currency code (typically 'DKK') |
| `exchangeRate` | `double` | Current exchange rate for currency conversion |
| `languageCode` | `String` | Current language code for translations (e.g., 'da', 'en') |
| `translationsCache` | `dynamic` | Cached translations map from FFAppState |

### Optional Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `width` | `double?` | Container width (defaults to parent width if not specified) |
| `onItemTap` | `Future Function(dynamic)?` | Callback when a menu item is tapped (receives item data) |

---

## Data Structure Requirements

### Input: menuData Structure

```dart
{
  "menu_items": [
    {
      "menu_item_id": 101,
      "item_name": "Grilled Salmon",
      "item_description": "Fresh Atlantic salmon...",
      "base_price": 285.0,
      "dietary_type_ids": [2, 5],
      "allergy_ids": [1],
      "item_image_url": "https://...",
      "item_modifier_groups": [...],
      "is_beverage": false
    },
    // ... more items
  ],
  "categories": [
    {
      "category_type": "menu_package",
      "package_id": 42,
      "package_name": "Chef's Tasting Menu",
      "courses": [
        {
          "course_name": "Appetizer",
          "course_description": "Choose one starter",
          "course_item_metadata": [
            {
              "menu_item_id": 101,
              "premium_upcharge": 0.0,
              "is_excluded": false
            },
            {
              "menu_item_id": 102,
              "premium_upcharge": 50.0,  // Extra cost item
              "is_excluded": false
            }
          ]
        },
        {
          "course_name": "Main Course",
          "course_description": "Your choice of entrée",
          "course_item_metadata": [...]
        }
      ]
    }
  ]
}
```

### Output: Item Data Structure (passed to onItemTap)

```dart
{
  "menu_item_id": 101,
  "item_name": "Grilled Salmon",
  "item_description": "Fresh Atlantic salmon...",
  "base_price": 285.0,
  "premium_upcharge": 50.0,  // From course metadata
  "dietary_type_ids": [2, 5],
  "allergy_ids": [1],
  "item_image_url": "https://...",
  "item_modifier_groups": [...],
  "is_beverage": false
}
```

---

## Internal State

### State Variables

```dart
/// Maps menu item IDs to their full data for O(1) lookup
Map<int, Map<String, dynamic>> _menuItemMap = {};

/// The selected package data matching the packageId
Map<String, dynamic>? _selectedPackage;
```

### State Lifecycle

1. **initState()**
   - Calls `_processMenuData()` to build lookup maps
   - Finds matching package by `packageId`

2. **didUpdateWidget()**
   - Rebuilds UI when `translationsCache` or `languageCode` changes
   - Ensures translated text updates reactively

3. **Data Processing Flow**
   ```
   _processMenuData()
   ├── _buildMenuItemLookupMap()  // Create ID → item map
   ├── _findSelectedPackage()     // Find matching package
   └── _logProcessingResults()    // Debug logging
   ```

---

## Dependencies

### Flutter/Dart Packages
- `package:flutter/material.dart` - Core Flutter widgets

### FlutterFlow Imports
- `/backend/schema/structs/index.dart` - Data structure definitions
- `/backend/schema/enums/enums.dart` - Enum types
- `/backend/supabase/supabase.dart` - Supabase client (not directly used)
- `/flutter_flow/flutter_flow_theme.dart` - Theme system (not used, uses static colors)
- `/flutter_flow/flutter_flow_util.dart` - Utility functions

### Custom Functions
- `getTranslations()` - Retrieves localized UI text
  - Location: `/flutter_flow/custom_functions.dart`
  - Called via: `_getUIText()` helper method

- `convertAndFormatPrice()` - Converts and formats prices with currency symbols
  - Location: `/flutter_flow/custom_functions.dart`
  - Used for: Premium upcharge badge formatting

### Custom Actions
- `markUserEngaged()` - Tracks user engagement for analytics
  - Location: `/custom_code/actions/mark_user_engaged.dart`
  - Called: When user taps any menu item

---

## FFAppState Usage

### Read Operations

| State Variable | Type | Purpose |
|----------------|------|---------|
| `mostRecentlyViewedBusinesMenuItems` | `dynamic` | Source for `menuData` parameter |
| `userCurrencyCode` | `String` | Source for `chosenCurrency` parameter |
| `exchangeRate` | `double` | Source for `exchangeRate` parameter |
| `translationsCache` | `dynamic` | Source for `translationsCache` parameter |

### Write Operations

**None.** This widget is read-only and does not modify global state.

---

## Translation System

### Translation Keys

| Key | Usage | Example Output |
|-----|-------|----------------|
| `error_package_not_found` | Error message when package ID not found in menu data | "Package not found" / "Pakke ikke fundet" |

### Translation Pattern

```dart
String _getUIText(String key) {
  return getTranslations(
    widget.languageCode,
    key,
    widget.translationsCache,
  );
}
```

**Translation Data Flow:**
1. Parent widget passes current `languageCode` and `translationsCache`
2. Widget calls `_getUIText(key)` for each UI string
3. `getTranslations()` looks up key in cache for current language
4. Falls back to English if translation missing

**Dynamic Content:**
- Course names, descriptions, and item text come directly from menu data
- Menu data is assumed to be pre-translated based on `languageCode`
- Only static UI elements (errors) use the translation system

---

## Visual Styling

### Color Constants

```dart
// Background & structure
_backgroundColor = Colors.white
_itemBorderColor = Color(0xFFE0E0E0)  // Light gray left border

// Text colors
_errorTextColor = Colors.red
_courseNameColor = Colors.black
_courseDescriptionColor = Colors.black87
_itemNameColor = Colors.black87
_itemDescriptionColor = Colors.black54

// Premium badge
_premiumBadgeColor = Color(0xFFE9874B)  // Orange accent
```

### Typography

| Element | Font Size | Weight | Color |
|---------|-----------|--------|-------|
| Error text | 16px | default | Red |
| Course name | 20px | w500 (medium) | Black |
| Course description | 16px | w300 (light) | Black87, italic |
| Item name | 18px | w500 (medium) | Black87 |
| Item description | 16px | w300 (light) | Black54, line-height 1.3 |
| Premium badge | 16px | w400 (regular) | Orange (#E9874B) |

### Layout Constants

```dart
// Container
_containerBorderRadius = 8.0
_listPadding = 16.0  // Top/bottom padding

// Course spacing
_courseBottomMargin = 20.0
_courseNameBottomMargin = 8.0
_courseDescriptionBottomMargin = 12.0

// Item styling
_itemBottomMargin = 10.0
_itemLeftMargin = 8.0        // Indent from course
_itemLeftPadding = 8.0       // Space after left border
_itemBorderWidth = 2.0       // Left border indicator
_itemDescriptionTopSpacing = 4.0
_itemNameToPremiumSpacing = 8.0

// Premium badge
_premiumBadgeBorderRadius = 4.0
_premiumBadgeHorizontalPadding = 6.0
_premiumBadgeVerticalPadding = 2.0
```

---

## Interaction Patterns

### Item Tap Behavior

**Trigger:** User taps anywhere on a menu item container (name, description, or premium badge area)

**Flow:**
```dart
1. GestureDetector.onTap() triggered
2. Call markUserEngaged() for analytics
3. Build item data object with all fields
4. Call widget.onItemTap?.call(itemData)
5. Parent handles the callback (typically shows ItemDetailSheet)
```

**Item Data Passed to Callback:**
```dart
{
  "menu_item_id": int,
  "item_name": String,
  "item_description": String,
  "base_price": double,
  "premium_upcharge": double,  // From course metadata
  "dietary_type_ids": List<int>,
  "allergy_ids": List<int>,
  "item_image_url": String?,
  "item_modifier_groups": List<dynamic>,
  "is_beverage": bool
}
```

### Scroll Behavior

- Uses `ScrollConfiguration` to hide scrollbars (cleaner visual)
- `ListView.builder` for efficient rendering of courses
- No pagination - all courses loaded at once (packages typically have 2-5 courses)

---

## Usage Examples

### Example 1: Basic Usage in MenuPackageExpandedInfoSheet

```dart
// From: menu_package_expanded_info_sheet_widget.dart

Flexible(
  child: Padding(
    padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
    child: Container(
      width: double.infinity,
      height: MediaQuery.sizeOf(context).height * 0.6,
      child: custom_widgets.PackageCoursesDisplay(
        width: double.infinity,
        height: MediaQuery.sizeOf(context).height * 0.6,
        chosenCurrency: FFAppState().userCurrencyCode,
        originalCurrencyCode: 'DKK',
        exchangeRate: FFAppState().exchangeRate,
        packageId: getJsonField(
          widget!.packageData,
          r'''$.package_id''',
        ),
        menuData: FFAppState().mostRecentlyViewedBusinesMenuItems,
        languageCode: FFLocalizations.of(context).languageCode,
        translationsCache: FFAppState().translationsCache,
        onItemTap: (itemData) async {
          // TODO: Show item detail sheet
        },
      ),
    ),
  ),
),
```

**Context:** Used in a bottom sheet showing package details. The widget occupies 60% of screen height within a `Flexible` wrapper to allow the sheet to resize based on content.

**Parameters Explained:**
- `width: double.infinity` - Fills parent width
- `height: MediaQuery.sizeOf(context).height * 0.6` - 60% of screen height
- `chosenCurrency: FFAppState().userCurrencyCode` - User's selected currency
- `originalCurrencyCode: 'DKK'` - All prices in menu data are in Danish Kroner
- `exchangeRate: FFAppState().exchangeRate` - Current conversion rate
- `packageId: getJsonField(widget!.packageData, r'''$.package_id''')` - Extract package ID from parent data
- `menuData: FFAppState().mostRecentlyViewedBusinesMenuItems` - Full menu data with items and categories
- `languageCode: FFLocalizations.of(context).languageCode` - Current app language
- `translationsCache: FFAppState().translationsCache` - Translation lookup map
- `onItemTap: (itemData) async {}` - Placeholder for item detail navigation

### Example 2: With Item Detail Navigation

```dart
custom_widgets.PackageCoursesDisplay(
  width: double.infinity,
  height: MediaQuery.sizeOf(context).height * 0.6,
  chosenCurrency: FFAppState().userCurrencyCode,
  originalCurrencyCode: 'DKK',
  exchangeRate: FFAppState().exchangeRate,
  packageId: selectedPackageId,
  menuData: FFAppState().mostRecentlyViewedBusinesMenuItems,
  languageCode: FFLocalizations.of(context).languageCode,
  translationsCache: FFAppState().translationsCache,
  onItemTap: (itemData) async {
    // Show item detail sheet
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ItemDetailSheet(
        itemData: itemData,
        languageCode: FFLocalizations.of(context).languageCode,
        translationsCache: FFAppState().translationsCache,
      ),
    );
  },
),
```

**Difference:** Includes full navigation logic to show item details when tapped.

### Example 3: Multiple Currency Display

```dart
// Show same package in two currencies side-by-side
Row(
  children: [
    Expanded(
      child: PackageCoursesDisplay(
        height: 400,
        packageId: selectedPackageId,
        menuData: menuData,
        chosenCurrency: 'DKK',
        originalCurrencyCode: 'DKK',
        exchangeRate: 1.0,  // No conversion
        languageCode: 'da',
        translationsCache: translationsCache,
      ),
    ),
    Expanded(
      child: PackageCoursesDisplay(
        height: 400,
        packageId: selectedPackageId,
        menuData: menuData,
        chosenCurrency: 'USD',
        originalCurrencyCode: 'DKK',
        exchangeRate: 0.15,  // DKK to USD
        languageCode: 'en',
        translationsCache: translationsCache,
      ),
    ),
  ],
)
```

**Use Case:** Educational or comparison view showing price equivalents.

---

## Error Handling

### Package Not Found

**Condition:** `packageId` doesn't match any package in `menuData.categories`

**Behavior:**
```dart
if (_selectedPackage == null) {
  return _buildErrorState();
}
```

**Error Display:**
- Shows translated error message: `error_package_not_found`
- White background container at specified height
- Red text, 16px font size
- No crash or exception thrown

### Invalid Menu Data Structure

**Condition:** `menuData` missing expected keys or has wrong types

**Behavior:**
```dart
// Defensive programming with null-coalescing
final menuItems = widget.menuData[_menuItemsKey] as List<dynamic>? ?? [];
final categories = widget.menuData[_categoriesKey] as List<dynamic>? ?? [];
```

**Handling:**
- Uses empty lists as fallbacks
- Widget displays but shows no courses
- Debug logs show 0 items/packages found

### Missing Menu Item Reference

**Condition:** Course references `menu_item_id` that doesn't exist in `menu_items` array

**Behavior:**
```dart
final menuItem = _menuItemMap[itemId];
if (menuItem == null) {
  return const SizedBox.shrink();
}
```

**Handling:**
- Item silently skipped (not shown in UI)
- No error message
- Continues rendering other items

### Excluded Items

**Condition:** `is_excluded: true` in course_item_metadata

**Behavior:**
```dart
bool _shouldSkipMenuItem(int? itemId, bool isExcluded) {
  return isExcluded || itemId == null;
}
```

**Handling:**
- Item not displayed
- Used to hide unavailable options in package

### Price Conversion Errors

**Condition:** `convertAndFormatPrice()` throws exception

**Behavior:**
```dart
try {
  final formattedAmount = convertAndFormatPrice(...);
  return '+ ${formattedAmount ?? premiumAmount.toStringAsFixed(0)}';
} catch (e) {
  return '+ ${premiumAmount.toStringAsFixed(0)}';
}
```

**Fallback:**
- Shows raw number with no currency symbol
- Still displays "+ 50" instead of "+ 50 kr"
- Widget continues functioning

---

## Performance Considerations

### Lookup Map Optimization

**Problem:** Need to match course item IDs to full menu item data efficiently.

**Solution:**
```dart
Map<int, Map<String, dynamic>> _menuItemMap = {};

void _buildMenuItemLookupMap() {
  final menuItems = widget.menuData[_menuItemsKey] as List<dynamic>? ?? [];
  _menuItemMap = {};

  for (final item in menuItems) {
    if (item is Map<String, dynamic>) {
      final itemId = item[_menuItemIdKey];
      if (itemId is int) {
        _menuItemMap[itemId] = item;
      }
    }
  }
}
```

**Complexity:**
- Build: O(n) where n = total menu items
- Lookup: O(1) per course item
- Memory: O(n) to store map

**Alternative Approach (Not Used):**
Linear search through menu_items for each course item = O(n × m) where m = items per course. Would be 100x slower for large menus.

### ListView.builder Usage

**Why ListView.builder instead of Column:**
- Efficient rendering for scrollable content
- Only builds visible course widgets
- Better for packages with many courses (though rare)

**Trade-off:**
- Courses typically number 2-5, so efficiency gain is small
- Could use Column with no performance impact
- ListView chosen for consistency with other scrollable widgets

### Widget Rebuilds

**Triggers Full Rebuild:**
- `translationsCache` changes (language switch)
- `languageCode` changes
- Parent widget rebuilds

**Does NOT Rebuild When:**
- Package tapped (state in parent widget)
- Item tapped (handled by callback)
- Price formatting changes (calculated per-build, not cached)

**Optimization Opportunity:**
- Could cache formatted premium prices in state
- Would avoid re-calculating on each build
- Not implemented due to small performance impact

---

## Testing Checklist

### Unit Tests

- [ ] **Package Finding Logic**
  - [ ] Finds package when packageId matches
  - [ ] Returns null when packageId not found
  - [ ] Handles empty categories array
  - [ ] Ignores non-package categories (type != 'menu_package')
  - [ ] Handles multiple packages (selects correct one)

- [ ] **Menu Item Lookup Map**
  - [ ] Builds map correctly from menu_items array
  - [ ] Handles duplicate IDs (last one wins)
  - [ ] Handles non-integer IDs (skipped)
  - [ ] Handles malformed item objects (skipped)
  - [ ] Works with empty menu_items array

- [ ] **Price Formatting**
  - [ ] Formats premium upcharge with currency symbol
  - [ ] Returns empty string for 0 upcharge
  - [ ] Returns empty string for negative upcharge
  - [ ] Falls back to raw number on conversion error
  - [ ] Handles null/invalid exchange rate

- [ ] **Item Filtering**
  - [ ] Skips items with is_excluded: true
  - [ ] Skips items with null menu_item_id
  - [ ] Includes items with 0 upcharge
  - [ ] Includes items with positive upcharge

### Widget Tests

- [ ] **Error State Rendering**
  - [ ] Shows error message when package not found
  - [ ] Uses translated error text
  - [ ] Error container has correct height
  - [ ] Error text styled correctly (red, 16px)

- [ ] **Course Rendering**
  - [ ] Renders course name when present
  - [ ] Renders course description when present
  - [ ] Skips course name if empty
  - [ ] Skips course description if empty
  - [ ] Maintains correct spacing between elements

- [ ] **Menu Item Rendering**
  - [ ] Shows item name
  - [ ] Shows item description if present
  - [ ] Shows premium badge when upcharge > 0
  - [ ] Hides premium badge when upcharge = 0
  - [ ] Left border displays correctly
  - [ ] Indentation from course header correct

- [ ] **Premium Badge Display**
  - [ ] Badge text formatted with currency
  - [ ] Badge shows "+ " prefix
  - [ ] Badge color matches design (orange)
  - [ ] Badge positioned on same line as item name
  - [ ] Badge doesn't wrap to new line

- [ ] **Scroll Behavior**
  - [ ] Scrolls vertically when content exceeds height
  - [ ] Scrollbars hidden
  - [ ] Smooth scrolling
  - [ ] Maintains scroll position on rebuild

### Integration Tests

- [ ] **Language Switching**
  - [ ] Error message updates when language changes
  - [ ] Widget rebuilds on translationsCache change
  - [ ] Widget rebuilds on languageCode change
  - [ ] Menu item text does not change (pre-translated)

- [ ] **Currency Conversion**
  - [ ] Premium upcharges convert correctly
  - [ ] Currency symbol matches chosenCurrency
  - [ ] Handles exchangeRate = 1.0 (no conversion)
  - [ ] Handles various exchange rates accurately

- [ ] **Item Tap Interaction**
  - [ ] onItemTap callback fired when item tapped
  - [ ] Correct item data passed to callback
  - [ ] markUserEngaged() called before callback
  - [ ] No tap event if onItemTap is null
  - [ ] Tap works on entire item container

- [ ] **Parent Widget Integration**
  - [ ] Receives correct menuData from FFAppState
  - [ ] Receives correct packageId from parent
  - [ ] Receives correct translation parameters
  - [ ] Receives correct currency parameters
  - [ ] Functions correctly in MenuPackageExpandedInfoSheet

### Visual Tests

- [ ] **Typography**
  - [ ] Course names bold and prominent
  - [ ] Course descriptions italic and lighter
  - [ ] Item names medium weight
  - [ ] Item descriptions light weight, good line-height
  - [ ] Premium badges readable and distinct

- [ ] **Spacing & Layout**
  - [ ] Course blocks visually separated (20px margin)
  - [ ] Items indented from course header
  - [ ] Left border provides visual hierarchy
  - [ ] Premium badges aligned with item names
  - [ ] Descriptions have appropriate top spacing

- [ ] **Color & Style**
  - [ ] White background
  - [ ] Black text with appropriate opacity levels
  - [ ] Orange premium badges stand out
  - [ ] Light gray left borders subtle
  - [ ] Error text clearly red

### Edge Cases

- [ ] **Empty Data**
  - [ ] Empty courses array
  - [ ] Course with no items
  - [ ] Course with all items excluded
  - [ ] Empty menu_items array

- [ ] **Extreme Values**
  - [ ] Very long course names (wrapping)
  - [ ] Very long item names (wrapping)
  - [ ] Very long item descriptions (multi-line)
  - [ ] Large premium upcharge amounts
  - [ ] Many courses (10+)
  - [ ] Many items per course (20+)

- [ ] **Special Characters**
  - [ ] Course names with special chars (é, ñ, ø)
  - [ ] Item names with emojis
  - [ ] Descriptions with HTML entities
  - [ ] Currency symbols (€, £, ¥, kr)

---

## Migration Notes (Phase 3: FlutterFlow → Pure Flutter)

### State Management Changes

**Current (FlutterFlow):**
```dart
// Data comes from FFAppState global singleton
menuData: FFAppState().mostRecentlyViewedBusinesMenuItems,
chosenCurrency: FFAppState().userCurrencyCode,
exchangeRate: FFAppState().exchangeRate,
translationsCache: FFAppState().translationsCache,
```

**Target (Riverpod):**
```dart
// Use providers instead
final menuData = ref.watch(currentRestaurantMenuProvider);
final userPrefs = ref.watch(userPreferencesProvider);
final translations = ref.watch(translationsProvider(languageCode));

PackageCoursesDisplay(
  menuData: menuData,
  chosenCurrency: userPrefs.currencyCode,
  exchangeRate: userPrefs.exchangeRate,
  translationsCache: translations,
  // ...
)
```

**Migration Steps:**
1. Create `currentRestaurantMenuProvider` to replace `mostRecentlyViewedBusinesMenuItems`
2. Create `userPreferencesProvider` for currency settings
3. Create `translationsProvider(languageCode)` for translations cache
4. Update all call sites to use providers
5. Widget code itself remains unchanged (just receives different parameter sources)

### Translation System Migration

**Current System:**
```dart
String _getUIText(String key) {
  return getTranslations(
    widget.languageCode,
    key,
    widget.translationsCache,
  );
}
```

**Target System (flutter_localizations):**
```dart
// Use context extension instead
String _getUIText(String key) {
  return context.l10n.translate(key);
}

// Or with flutter_gen
String _getUIText(String key) {
  return AppLocalizations.of(context)!.translate(key);
}
```

**Required Changes:**
1. Add `import 'package:flutter_localizations/flutter_localizations.dart'`
2. Replace `_getUIText()` implementation
3. Remove `languageCode` and `translationsCache` parameters
4. Update all call sites (parent widgets)

**Translation Key Mapping:**
- `error_package_not_found` → Keep same key in new system

### Custom Function Replacements

**convertAndFormatPrice() Migration:**

Current implementation is in `/flutter_flow/custom_functions.dart`. For Phase 3:

```dart
// Create new utility in lib/utils/currency_formatter.dart
class CurrencyFormatter {
  static String formatWithConversion({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
    required double exchangeRate,
  }) {
    final converted = amount * exchangeRate;
    return NumberFormat.currency(
      locale: _localeForCurrency(toCurrency),
      symbol: _symbolForCurrency(toCurrency),
    ).format(converted);
  }

  static String _symbolForCurrency(String code) {
    // Map currency codes to symbols
  }

  static String _localeForCurrency(String code) {
    // Map currency codes to locales
  }
}
```

**markUserEngaged() Migration:**

Current implementation is in `/custom_code/actions/mark_user_engaged.dart`. For Phase 3:

```dart
// Create new analytics service
class AnalyticsService {
  static final instance = AnalyticsService._();
  AnalyticsService._();

  void markUserEngaged() {
    // Implementation - likely Firebase Analytics
    FirebaseAnalytics.instance.logEvent(
      name: 'user_engaged',
      parameters: {'timestamp': DateTime.now().toIso8601String()},
    );
  }
}

// Usage in widget
void _handleItemTap(Map<String, dynamic> itemData) async {
  AnalyticsService.instance.markUserEngaged();
  await widget.onItemTap?.call(itemData);
}
```

### Null Safety & Type Safety

**Current Issues:**
- Uses `dynamic` for `menuData`, `translationsCache`, `itemData`
- No compile-time type checking for data structures
- Runtime errors possible if data structure changes

**Phase 3 Improvements:**
```dart
// Create data models
class MenuData {
  final List<MenuItem> menuItems;
  final List<MenuCategory> categories;

  MenuData({required this.menuItems, required this.categories});

  factory MenuData.fromJson(Map<String, dynamic> json) => ...;
}

class MenuCategory {
  final CategoryType categoryType;
  final int? packageId;
  final String? packageName;
  final List<Course> courses;

  // ...
}

class Course {
  final String courseName;
  final String? courseDescription;
  final List<CourseItemMetadata> courseItemMetadata;

  // ...
}

// Update widget signature
class PackageCoursesDisplay extends StatefulWidget {
  const PackageCoursesDisplay({
    super.key,
    this.width,
    required this.height,
    required this.menuData,  // MenuData (typed)
    required this.packageId,
    required this.chosenCurrency,
    required this.originalCurrencyCode,
    required this.exchangeRate,
    this.onItemTap,  // Remove language/translations params
  });

  final MenuData menuData;  // Typed!
  final Future Function(MenuItem itemData)? onItemTap;  // Typed!
}
```

**Benefits:**
- Compile-time type checking
- Autocomplete in IDE
- Easier refactoring
- Fewer runtime errors

### Testing Infrastructure

**Current State:**
- No tests (FlutterFlow doesn't generate tests)

**Phase 3 Requirements:**
1. **Unit Tests** - Test all logic methods:
   - `_processMenuData()`
   - `_buildMenuItemLookupMap()`
   - `_findSelectedPackage()`
   - `_formatPremiumPrice()`
   - `_buildItemData()`

2. **Widget Tests** - Test UI rendering:
   - Error state display
   - Course/item rendering
   - Premium badge display
   - Tap interactions

3. **Golden Tests** - Visual regression:
   - Standard package display
   - Package with premium items
   - Error state
   - Long text wrapping
   - Multiple courses

**Test File Structure:**
```
test/
├── widgets/
│   ├── package_courses_display_test.dart          # Widget tests
│   └── package_courses_display_golden_test.dart   # Golden tests
└── utils/
    └── test_data.dart  # Shared test fixtures
```

### Performance Optimizations

**Potential Improvements for Phase 3:**

1. **Memoize Price Formatting:**
```dart
// Current: Formats on every build
String premiumText = _formatPremiumPrice(premiumUpcharge);

// Optimized: Cache formatted prices
final Map<double, String> _priceCache = {};

String _formatPremiumPrice(double amount) {
  if (_priceCache.containsKey(amount)) {
    return _priceCache[amount]!;
  }
  final formatted = convertAndFormatPrice(...);
  _priceCache[amount] = formatted;
  return formatted;
}
```

2. **Use const Constructors:**
```dart
// Current: Creates new widget on every build
return const SizedBox.shrink();  // Already const ✓

// Can optimize:
const EdgeInsets.only(bottom: _itemBottomMargin)  // Use const
```

3. **Split into Smaller Widgets:**
```dart
// Current: Single large build() method
// Optimized: Extract sub-widgets

class _CourseItem extends StatelessWidget {
  final Course course;
  // ...

  @override
  Widget build(BuildContext context) {
    // Only rebuilds this course when needed
  }
}
```

### Breaking Changes from FlutterFlow Version

**None Planned** - Widget should remain backward compatible during migration. All changes are internal refactoring.

**Future Breaking Changes (Post-Migration):**
- Remove `languageCode` parameter (use context instead)
- Remove `translationsCache` parameter (use provider instead)
- Change `menuData` type from `dynamic` to `MenuData`
- Change `onItemTap` signature from `dynamic` to `MenuItem`

**Migration Timeline:**
1. Phase 3.1: Direct port (keep all parameters, same behavior)
2. Phase 3.2: Add typed models (parallel to dynamic data)
3. Phase 3.3: Switch to providers (remove global state)
4. Phase 3.4: Remove legacy parameters (breaking change)

---

## Related Widgets

| Widget | Relationship | Description |
|--------|--------------|-------------|
| `PackageNavigationSheet` | Sibling | Handles package course navigation/selection UI |
| `MenuPackageExpandedInfoSheet` | Parent | Contains PackageCoursesDisplay in bottom sheet |
| `ItemDetailSheet` | Child/Callback | Shown when user taps an item (via onItemTap) |
| `MenuDishesList` | Sibling | Displays regular menu items (not package format) |

**Data Flow:**
```
MenuPackageExpandedInfoSheet
├── Receives: packageData from parent
├── Extracts: packageId, businessName
└── Passes to: PackageCoursesDisplay
    ├── Receives: full menuData from FFAppState
    ├── Finds: matching package by packageId
    ├── Renders: courses and items
    └── On tap: Calls onItemTap(itemData)
        └── Shows: ItemDetailSheet (not implemented yet)
```

---

## Known Issues & Limitations

### Issue 1: No Loading State

**Problem:** If menuData is loading/null, widget shows error instead of loading indicator.

**Impact:** User sees "Package not found" briefly while data loads.

**Workaround:** Parent widget should not render PackageCoursesDisplay until menuData is ready.

**Future Fix:** Add `isLoading` parameter and show shimmer/spinner state.

### Issue 2: No Analytics Event for Package View

**Problem:** Widget calls `markUserEngaged()` on item tap, but not when package is first viewed.

**Impact:** Package views are not tracked separately from item taps.

**Workaround:** Parent widget (MenuPackageExpandedInfoSheet) should track package view.

**Future Fix:** Add analytics call in `initState()` with package view event.

### Issue 3: Static Color Values

**Problem:** Uses hardcoded colors instead of theme system.

**Impact:** Cannot customize colors per-restaurant or support dark mode.

**Workaround:** None (requires refactor).

**Future Fix:** Replace all color constants with `Theme.of(context).colorScheme.*` values.

### Issue 4: Premium Badge Overflow

**Problem:** Very long currency names (e.g., "+ 50 Dominican Pesos") can overflow on small screens.

**Impact:** Badge text cut off or wraps awkwardly.

**Workaround:** Use shorter currency symbols (DOP instead of Dominican Pesos).

**Future Fix:** Add `overflow: TextOverflow.ellipsis` to badge text or limit to symbol only.

### Issue 5: No Item Unavailability Indicator

**Problem:** If item is out of stock, no visual indicator (unless is_excluded = true, which hides it completely).

**Impact:** User might select item that's unavailable.

**Workaround:** Backend should set is_excluded = true for out-of-stock items.

**Future Fix:** Add `is_available` field and show grayed-out items with "Sold Out" label.

---

## Changelog

**2026-02-19** - Initial documentation created
- Documented all parameters, state, and behavior
- Added usage examples from codebase
- Documented translation system integration
- Identified migration path for Phase 3
- Listed testing requirements
- Noted known issues and limitations

---

## Additional Notes

### Design Rationale: Why Hierarchical Display?

Packages (multi-course meals) have inherent hierarchy:
- **Package** = the complete meal offering (e.g., "Chef's Tasting Menu")
- **Course** = each stage of the meal (e.g., "Appetizer", "Main", "Dessert")
- **Item** = specific dish options within a course (e.g., "Salmon", "Chicken", "Steak")

This widget mirrors that structure visually:
1. Course names are bold headers (20px, black)
2. Course descriptions are italic subheaders (16px, lighter)
3. Items are indented with left border (visual hierarchy)
4. Premium badges indicate additional cost for upgrades

**Alternative Approaches Considered:**
- Flat list with all items - Loses course context
- Accordion (collapsible courses) - Unnecessary complexity for 2-5 courses
- Tabs (one course per tab) - Prevents seeing full package at once

**Why This Approach Works:**
- All package content visible at once
- Clear visual hierarchy without interaction
- Scroll interaction is familiar and intuitive
- Premium items stand out with orange badges

### Menu Data Structure Context

The `menuData` object is shared across the entire app:
- **Single source of truth** for current restaurant menu
- **Stored in FFAppState** as `mostRecentlyViewedBusinesMenuItems`
- **Loaded once** when user navigates to business profile
- **Reused** by MenuDishesList, PackageCoursesDisplay, ItemDetailSheet, etc.

**Why Not Pass Only Package Data?**
- Items are stored separately in `menu_items` array
- Courses only reference `menu_item_id`, not full item data
- Widget needs to look up item details by ID
- Passing full menuData enables O(1) lookup via map

**Trade-off:**
- Larger parameter size (entire menu data)
- But avoids redundant API calls to fetch item details
- Acceptable because data is already in memory (FFAppState)

### Premium Upcharge Explanation

**What is a Premium Upcharge?**
In package meals, certain items cost extra beyond the base package price.

**Example:**
```
Chef's Tasting Menu - 500 DKK
├── Appetizer
│   ├── Soup (included)
│   └── Lobster Bisque (+ 75 DKK)  ← Premium item
├── Main Course
│   ├── Chicken (included)
│   └── Wagyu Steak (+ 150 DKK)    ← Premium item
└── Dessert
    ├── Ice Cream (included)
    └── Chocolate Soufflé (+ 50 DKK)  ← Premium item
```

**Data Structure:**
```dart
"course_item_metadata": [
  {
    "menu_item_id": 42,
    "premium_upcharge": 75.0,  // Extra cost beyond base
    "is_excluded": false
  }
]
```

**Display Logic:**
- `premium_upcharge == 0` → No badge shown (included in base)
- `premium_upcharge > 0` → Orange badge with "+ X kr" shown
- `premium_upcharge < 0` → Badge hidden (negative upcharge = discount, rare)

**Badge Purpose:**
- Helps user understand total cost
- Prevents surprise charges at checkout
- Allows informed choice between options

---

*End of Documentation*
