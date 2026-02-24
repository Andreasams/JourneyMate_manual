# MenuDishesListView Widget

**Type:** Custom Widget
**File:** `menu_dishes_list_view.dart` (2400 lines)
**Category:** Menu Display & Navigation
**Status:** ✅ Production Ready

---

## Purpose

A sophisticated scrollable list widget that displays menu items and multi-course packages organized by categories. Handles dynamic filtering based on dietary preferences and allergies, automatic scrolling to selected categories, tracking and reporting the currently visible category, and comprehensive analytics tracking.

**Key Features:**
- Real-time filtering by dietary restrictions, preferences, and allergen exclusions
- Programmatic scrolling to specific categories from external navigation
- Automatic detection and reporting of visible category during user scroll
- Separate handling of regular menu items vs. multi-course packages
- Variation detection and "From" pricing display
- Multi-language support via centralized translation system
- Currency conversion and formatting
- Deep analytics tracking (item clicks, package clicks, scroll depth, category views)
- Session-level metrics tracking in FFAppState

---

## Parameters

```dart
MenuDishesListView({
  super.key,
  this.width,                              // Optional container width
  this.height,                             // Optional container height
  required this.originalCurrencyCode,      // Base currency from business
  this.onItemTap,                          // Callback for regular item taps
  this.onPackageTap,                       // Callback for package taps
  this.onVisibleCategoryChanged,           // Callback when visible category changes
  this.isDynamicHeight = false,            // Adjust scroll alignment for dynamic heights
  this.onCategoryDescriptionTap,           // Callback for category description info icon
})
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `width` | `double?` | No | Container width (default: unbounded) |
| `height` | `double?` | No | Container height (default: unbounded) |
| `originalCurrencyCode` | `String` | **Yes** | Business's base currency code (e.g., "DKK") |
| `onItemTap` | `Future Function(...)` | No | Called when regular menu item is tapped |
| `onPackageTap` | `Future Function(dynamic)` | No | Called when package is tapped |
| `onVisibleCategoryChanged` | `Future Function(dynamic)` | No | Called when visible category changes during scroll |
| `isDynamicHeight` | `bool` | No | Set true for dynamic height containers (adjusts scroll alignment) |
| `onCategoryDescriptionTap` | `Future Function(dynamic)` | No | Called when category description info icon is tapped |

### onItemTap Signature
```dart
Future Function(
  dynamic bottomSheetInformation,    // Full item data
  bool isBeverage,                   // Item type flag
  List<int>? dietaryTypeIds,         // Dietary type IDs
  List<int>? allergyIds,             // Allergy IDs
  String formattedPrice,             // Base price (no "From" prefix)
  bool hasVariations,                // Variation flag
  String? formattedVariationPrice,   // Variation price with "From" prefix
)
```

### onVisibleCategoryChanged Signature
```dart
Future Function(dynamic selectionData)
// selectionData = {
//   'categoryId': 123,
//   'menuId': 456,
// }
```

---

## Dependencies

### pub.dev Packages
- `scrollable_positioned_list: ^0.3.8` - Programmatic scrolling and position tracking
- `collection: ^1.18.0` - Collection utilities (whereNotNull)

### Internal Dependencies
```dart
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';
```

### Custom Actions Used
- `markUserEngaged()` - Tracks user engagement on item/package/description tap
- `trackAnalyticsEvent()` - Tracks analytics events (item clicks, package clicks, scroll depth, description views)
- `getTranslations()` - Fetches localized UI text from centralized translation system

### Custom Functions Used
- `convertAndFormatPrice(price, originalCurrency, exchangeRate, targetCurrency)` - Formats prices with currency symbols

---

## FFAppState Usage

### Read Properties
```dart
FFAppState().mostRecentlyViewedBusinesMenuItems          // Main menu data source
FFAppState().selectedDietaryRestrictionId                // Array of dietary restriction IDs (e.g., [1, 3])
FFAppState().selectedDietaryPreferenceId                 // Single dietary preference ID (0 = none)
FFAppState().excludedAllergyIds                          // Array of allergy IDs to exclude
FFAppState().mostRecentlyViewedBusinessSelectedMenuID    // Currently selected menu ID (for scrolling)
FFAppState().mostRecentlyViewedBusinessSelectedCategoryID // Currently selected category ID (for scrolling)
FFAppState().userCurrencyCode                            // User's selected currency
FFAppState().exchangeRate                                // Exchange rate for conversion
FFAppState().translationsCache                           // Translation data cache
FFLocalizations.of(context).languageCode                 // Current language code
```

### Write Properties (Session Tracking)
```dart
FFAppState().menuSessionData = {
  'itemClicks': 0,                      // Incremented on item tap
  'packageClicks': 0,                   // Incremented on package tap
  'categoriesViewed': [],               // Category IDs viewed during session
  'deepestScrollPercent': 0,            // Deepest scroll percentage reached
};
```

**NOTE:** The widget does NOT listen to FFAppState changes. It reads state in `didUpdateWidget()` to detect filter changes and `build()` to detect navigation changes.

---

## Data Structure

### Expected mostRecentlyViewedBusinesMenuItems Format
```json
{
  "menu_items": [
    {
      "menu_item_id": 123,
      "item_name": "Eggs Benedict",
      "item_description": "Poached eggs on English muffin...",
      "item_image_url": "https://...",
      "base_price": 95.0,
      "premium_upcharge": 0.0,
      "is_beverage": false,
      "is_price_per_person": false,
      "business_id": 456,
      "menu_id": 789,
      "dietary_type_ids": [1, 2],        // IDs item inherently satisfies
      "dietary_type_can_be_made_ids": [3], // IDs item can be made to satisfy
      "allergy_ids": [7, 8],              // Allergen IDs present
      "item_modifier_groups": [
        {
          "type": "Variation",            // "Variation" or "Add-on"
          "modifiers": [
            {
              "name": "Bacon",
              "price": 0.0
            },
            {
              "name": "Salmon",
              "price": 25.0
            }
          ]
        }
      ]
    }
  ],
  "categories": [
    {
      "category_id": 101,
      "category_name": "Breakfast",
      "category_description": "Served from 8am to 12pm",
      "category_type": "a la carte",
      "menu_id": 789,
      "display_order": 1,
      "menu_display_order": 1,
      "menu_item_ids": [123, 124, 125]
    },
    {
      "category_id": 102,
      "category_type": "menu_package",
      "package_id": 999,
      "package_name": "Chef's Tasting Menu",
      "package_description": "5-course journey...",
      "package_image_url": "https://...",
      "base_price": 750.0,
      "is_price_per_person": true,
      "is_tasting_menu": true,
      "courses": [
        {
          "course_number": 1,
          "course_name": "Amuse-bouche",
          "items": ["Oyster", "Caviar"]
        }
      ],
      "menu_id": 789,
      "display_order": 2,
      "menu_display_order": 1
    }
  ]
}
```

---

## Lifecycle Events

### initState (lines 226-241)
```dart
@override
void initState() {
  super.initState();
  _extractBusinessId();
  _extractAndSortData();
  _buildCategoryIndexMap();
  _buildCategoryMenuMap();
  _itemPositionsListener.itemPositions.addListener(_onItemPositionsChanged);

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _lastScrolledToCategoryId = _selectedCategoryId;
  });
}
```

**Actions:**
1. Extracts business_id from menu data for analytics
2. Processes menu data (sorts categories, builds item map)
3. Builds category index map (for scrolling)
4. Builds category-menu map (for tracking visible category)
5. Attaches scroll position listener
6. Initializes last scrolled category ID

### didUpdateWidget (lines 244-249)
```dart
@override
void didUpdateWidget(covariant MenuDishesListView oldWidget) {
  super.didUpdateWidget(oldWidget);
  _processData();
}
```

**Actions:**
- Re-processes data whenever parent widget updates
- Rebuilds filtered item lists based on current FFAppState filters

### dispose (lines 252-254)
```dart
@override
void dispose() {
  super.dispose();
}
```

**Actions:**
- No explicit cleanup needed (listeners auto-disposed)

---

## Filtering Logic

### Filter Workflow

The widget applies **THREE filter types** in order:

#### 1. Dietary Restrictions (AND logic)
**Source:** `FFAppState().selectedDietaryRestrictionId` (array)

**Rule:** Item must satisfy **ALL** active restrictions via **EITHER**:
- `dietary_type_ids` (inherently satisfies)
- `dietary_type_can_be_made_ids` (can be modified to satisfy)

**Example:**
```dart
selectedDietaryRestrictionId = [1, 3]  // Gluten-free AND Vegan
// Item must have (1 in dietary_type_ids OR 1 in dietary_type_can_be_made_ids)
//        AND (3 in dietary_type_ids OR 3 in dietary_type_can_be_made_ids)
```

#### 2. Dietary Preference (OR logic)
**Source:** `FFAppState().selectedDietaryPreferenceId` (single int)

**Rule:** If preference selected (not 0), item must satisfy it via **EITHER**:
- `dietary_type_ids`
- `dietary_type_can_be_made_ids`

**Example:**
```dart
selectedDietaryPreferenceId = 5  // Vegetarian
// Item must have 5 in dietary_type_ids OR 5 in dietary_type_can_be_made_ids
```

#### 3. Allergen Exclusions (AND NOT logic)
**Source:** `FFAppState().excludedAllergyIds` (array)

**Rule:** Item must **NOT** contain **ANY** excluded allergen in `allergy_ids`

**CRITICAL EXCEPTION - Allergen Override:**
If an item can be made to satisfy **ANY** active restriction or preference (present in `dietary_type_can_be_made_ids`), **allergen filtering is bypassed**. This allows items like "Can be made gluten-free" to show even if they contain gluten by default.

**Example:**
```dart
excludedAllergyIds = [7, 8]  // Exclude dairy and eggs
dietary_type_can_be_made_ids = [1]  // Can be made gluten-free

// Allergen filter skipped because item qualifies for override
// Item shows even if allergy_ids contains [7, 8]
```

### Filter Implementation (lines 989-1053)

```dart
bool _passesAllFilters(Map<String, dynamic> item) {
  // 1. Must pass dietary filter
  if (!_passesDietaryFilter(item)) {
    return false;
  }

  // 2. Check allergen override
  if (_qualifiesForAllergenOverride(item)) {
    return true; // Show item despite allergens
  }

  // 3. Apply normal allergen filtering
  return _passesAllergyFilter(item);
}
```

---

## Scrolling System

### Two-Source Scrolling

The widget supports scrolling from **two sources**:

#### 1. External Navigation (FFAppState)
**Trigger:** `mostRecentlyViewedBusinessSelectedCategoryID` changes

**Detection:** In `build()` method, compares current category ID with `_lastScrolledToCategoryId`

**Implementation (lines 1406-1416):**
```dart
final currentCategoryId = _selectedCategoryId;
if (currentCategoryId != _lastScrolledToCategoryId) {
  _lastScrolledToCategoryId = currentCategoryId;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      _scrollToCategory(currentCategoryId);
    }
  });
}
```

#### 2. User Manual Scrolling
**Trigger:** User swipes/drags list

**Detection:** `ItemPositionsListener` tracks visible items

**Reporting:** Calls `onVisibleCategoryChanged` callback with dominant visible category

### Scroll Position Detection (Two-Zone System)

The widget uses a **two-zone detection system** to determine which category is dominant:

#### Top Zone (Scrolling Down)
**Purpose:** Detect headers entering viewport from top

**Threshold:** Leading edge between `-0.1` and `0.3`

**Priority:** Takes precedence over bottom zone

**Logic:** Finds topmost header in zone → reports that category

#### Bottom Zone (Scrolling Up)
**Purpose:** Detect headers exiting viewport from bottom

**Threshold:** Leading edge between `0.7` and `1.1`

**Priority:** Only checked if top zone has no headers

**Logic:** Finds bottommost exiting header → reports category **above** it

### Scroll Alignment

The widget calculates alignment based on:
1. Whether item is first in list (align to top)
2. Whether container uses dynamic height (`isDynamicHeight = true`)

**Implementation (lines 1111-1126):**
```dart
double _getScrollAlignment({required bool isFirstItem}) {
  if (isFirstItem) {
    return 0.0; // Perfectly at top
  }

  if (widget.isDynamicHeight) {
    final viewportHeight = widget.height ?? MediaQuery.of(context).size.height;
    return -6.0 / viewportHeight; // 6px buffer from top
  }

  return -0.05; // Slight offset from top
}
```

---

## Visible Item Count Calculation

**IMPORTANT:** Visible item count calculation has been **moved out of this widget** to `UnifiedFiltersWidget` to ensure synchronous updates when filters change.

**Reason:** The widget rebuilds asynchronously after filter changes, causing a delay in updating the count badge. Moving calculation to the filter widget provides instant feedback.

---

## Analytics Tracking

### Session-Level Metrics (FFAppState)

The widget updates `FFAppState().menuSessionData` for session-level tracking:

```dart
{
  'itemClicks': 5,              // Total regular items clicked
  'packageClicks': 2,           // Total packages clicked
  'categoriesViewed': [1, 2, 5], // Unique category IDs viewed
  'deepestScrollPercent': 75,   // Deepest scroll percentage (0-100)
}
```

### Event: menu_item_clicked
**Tracked on:** Regular menu item tap

**Event Data (lines 359-378):**
```dart
{
  'business_id': 456,
  'item_id': 123,
  'item_name': 'Eggs Benedict',
  'category_id': 101,
  'category_name': 'Breakfast',
  'category_index': 1,              // Position in full category list (+1 for packages section)
  'position_in_category': 3,        // Position within category (1-indexed)
  'has_image': true,
  'has_description': true,
  'has_variations': true,
  'is_beverage': false,
  'price_range': '10-20',           // Bucketed price range
  'language': 'en',
}
```

### Event: menu_package_clicked
**Tracked on:** Package tap

**Event Data (lines 390-401):**
```dart
{
  'business_id': 456,
  'package_id': 999,
  'package_name': "Chef's Tasting Menu",
  'package_position': 1,            // Position in packages list (1-indexed)
  'total_packages': 3,
  'language': 'en',
}
```

### Event: category_description_viewed
**Tracked on:** Category description info icon tap

**Event Data (lines 409-417):**
```dart
{
  'business_id': 456,
  'category_name': 'Breakfast',
  'language': 'en',
}
```

### Event: menu_scroll_depth
**Tracked on:** User reaches new deepest category during scroll

**Event Data (lines 444-455):**
```dart
{
  'business_id': 456,
  'deepest_category_index': 5,      // Deepest category reached (0-indexed)
  'total_categories': 8,
  'scroll_depth_percent': 62,       // (5/8)*100 = 62%
  'language': 'en',
}
```

**Scroll Depth Tracking Logic:**
- Only tracks during **manual user scrolling** (not programmatic)
- Uses `_hasUserScrolled` flag to distinguish initial render from user interaction
- Detects scroll movement by checking if first visible item is not index 0 or has moved above viewport
- Tracks unique categories viewed in `_viewedCategoryIds` Set
- Updates session data with deepest scroll percentage

---

## User Interactions

### onTap Regular Menu Item (lines 1355-1387)

**Trigger:** User taps anywhere on a regular menu item card

**Actions:**
1. Calls `markUserEngaged()` (non-blocking)
2. Increments `menuSessionData.itemClicks` in FFAppState
3. Tracks `menu_item_clicked` analytics event (non-blocking)
4. Invokes `onItemTap` callback with:
   - `bottomSheetInformation`: Full item data
   - `isBeverage`: Boolean flag
   - `dietaryTypeIds`: Array of dietary type IDs
   - `allergyIds`: Array of allergy IDs
   - `formattedPrice`: Base price (no "From" prefix)
   - `hasVariations`: Boolean flag
   - `formattedVariationPrice`: Price with "From" prefix (null if no variations)

### onTap Package (lines 1244-1261)

**Trigger:** User taps anywhere on a package card

**Actions:**
1. Calls `markUserEngaged()` (non-blocking)
2. Increments `menuSessionData.packageClicks` in FFAppState
3. Tracks `menu_package_clicked` analytics event (non-blocking)
4. Invokes `onPackageTap` callback with package data map:
   ```dart
   {
     'package_id': 999,
     'package_name': "Chef's Tasting Menu",
     'package_description': "5-course journey...",
     'package_image_url': "https://...",
     'base_price': 750.0,
     'formatted_price': "750 kr",
     'courses': [...],  // Array of course objects
     'is_combo': false,
     'is_fixed_price_menu': false,
     'is_tasting_menu': true,
     'is_sharing_menu': false,
     'business_id': 456,
     'menu_id': 789,
   }
   ```

### onTap Category Description Info Icon (lines 422-430)

**Trigger:** User taps info icon next to category description (only shown if description overflows)

**Actions:**
1. Calls `markUserEngaged()` (non-blocking)
2. Tracks `category_description_viewed` analytics event (non-blocking)
3. Invokes `onCategoryDescriptionTap` callback with:
   ```dart
   {
     'categoryName': 'Breakfast',
     'categoryDescription': 'Served from 8am to 12pm',
   }
   ```

---

## Display Components

### 1. Multi-Course Packages Section (lines 1222-1237)

**Condition:** `_menuPackages.isNotEmpty`

**Display:**
- Single category header (no description, no info icon)
- Header text: Singular "Multi-course menu" or Plural "Multi-course menus" (localized)
- Package cards in display order

**Structure:**
```
┌────────────────────────────────┐
│ Multi-course menus             │ ← Header (isFirst: true)
├────────────────────────────────┤
│ [Image] Chef's Tasting Menu    │ ← Package 1
│  133x75 5-course journey...    │
│         750 kr — per person    │
├────────────────────────────────┤
│ [Image] Weekend Brunch         │ ← Package 2
│  133x75 3-course brunch...     │
│         450 kr — per person    │
└────────────────────────────────┘
```

### 2. Regular Categories (lines 1271-1314)

**Display:** For each category in `_regularCategories`:
- Category header with name and optional description
- Optional info icon (if description overflows)
- Items matching current filters OR "No dishes" message

**Structure:**
```
┌────────────────────────────────┐
│ Breakfast                      │ ← Header
│ Served from 8am to 12pm [i]    │ ← Description + info icon
├────────────────────────────────┤
│ [Image] Eggs Benedict          │ ← Item 1
│  133x75 Poached eggs on...     │
│         From 95 kr             │
├────────────────────────────────┤
│ [Image] Pancakes               │ ← Item 2
│  133x75 Fluffy buttermilk...   │
│         75 kr                  │
└────────────────────────────────┘
```

### 3. Empty State (lines 1307-1310)

**Condition:** Category has no items after filtering

**Display:** "No dishes match your filters" (localized)

---

## Menu Item Card (_MenuItem Widget)

### Layout Logic (lines 1451-2127)

The card adapts layout based on:
- **Has description:** Shows 2-line description below title
- **Has image:** Shows 133x75px image on right
- **Is beverage:** Adjusts spacing and title lines
- **Title length:** Long titles (>45 chars) get 2 lines in certain conditions

### Variation Pricing Logic (lines 1591-1687)

The widget implements sophisticated variation detection and pricing:

#### Variation Detection
**Method:** Scans `item_modifier_groups` for groups with `type: "Variation"`

**Purpose:** Distinguish variations (mutually exclusive options) from add-ons (augmentations)

#### Effective Price Calculation
**Logic:**
1. If has variations AND `base_price == 0`: Use minimum variation price
2. If has variations AND `base_price > 0`: Use minimum of base or variation prices
3. If no variations: Use `base_price + premium_upcharge`

#### "From" Prefix Display
**Rule:** Show "From" prefix **only when**:
- Item has variations
- Effective price > 0

**Examples:**
```
base_price: 95, variations: [0, 25, 40] → "From 95 kr"
base_price: 0, variations: [25, 40] → "From 25 kr"
base_price: 120, variations: [] → "120 kr" (no prefix)
base_price: 0, variations: [] → "" (hidden via opacity: 0)
```

#### Zero Price Handling (lines 1690-1708)
**Rule:** When price is zero, render invisible text to maintain layout consistency

**Detection:** Handles multiple currency formats:
- Prefix currencies: `€0`, `€0.00`, `£0`, `$0`, `¥0`
- Suffix currencies: `0 kr.`, `0 zł`, `0 ₩`, `0 ₴`

**Implementation:**
```dart
Opacity(
  opacity: isZeroPrice ? 0.0 : 1.0,
  child: Text(isZeroPrice ? '0 kr' : price, ...),
)
```

### Per Person Pricing (lines 1875-1877)

**Condition:** `is_price_per_person == true`

**Display:** Appends " — per person" (localized) to price

**Example:** `750 kr — per person`

### Card Layout Constants (lines 1483-1528)

```dart
_verticalPadding = 8.0
_horizontalImagePadding = 8.0
_titleDescriptionSpacing = 2.0
_descriptionPriceSpacingStandard = 4.0
_descriptionPriceSpacingCompact = 2.0

_itemImageWidth = 133.0
_itemImageHeight = 75.0
_itemImageBorderRadius = 4.0

_titleFontSize = 16.0
_titleFontWeight = FontWeight.w400
_titleMaxLinesSingle = 1
_titleMaxLinesDouble = 2

_descriptionFontSize = 14.0
_descriptionFontWeight = FontWeight.w300
_descriptionMaxLines = 2

_priceFontSize = 14.0
_priceFontWeight = FontWeight.w400
_priceColor = Color(0xFFEE8B60)  // Orange accent
```

---

## Category Header (_CategoryHeader Widget)

### Layout (lines 2169-2339)

**Structure:**
```
┌────────────────────────────────┐
│ Category Name                  │ ← 18px, FontWeight.w500
│ Category description text [i]  │ ← 14px, FontWeight.w300 (only if exists)
└────────────────────────────────┘
```

### Padding Logic
- **First header:** 0px top padding
- **Subsequent headers:** 16px top padding
- **All headers:** 8px bottom padding

### Info Icon Display Logic (lines 2242-2257)

**Rule:** Info icon shown **only when**:
1. Category has a non-empty description
2. Description text **overflows** (exceeds 1 line)

**Implementation:**
- Uses `TextPainter` to measure text width
- Calculates available width: `screenWidth - (padding * 2) - buffer - iconSize - gap`
- Shows icon only if `textPainter.didExceedMaxLines`

**Purpose:** Avoid clutter for short descriptions that fit on one line

---

## Translation Keys

The widget uses **Supabase translations** via `getTranslations()`:

| Key | English | Purpose |
|-----|---------|---------|
| `menu_no_dishes` | "No dishes match your filters" | Empty state message |
| `menu_multi_course_singular` | "Multi-course menu" | Package section header (1 package) |
| `menu_multi_course_plural` | "Multi-course menus" | Package section header (2+ packages) |
| `price_from` | "From" | Variation price prefix |
| `price_per_person` | "per person" | Per-person pricing suffix |

---

## Performance Optimizations

### 1. Index Map Caching (lines 829-874)
**Purpose:** Fast category lookup for scrolling

**Structure:**
```dart
_categoryIndexMap = {
  101: 1,   // Category ID → List index
  102: 5,
  103: 12,
}
```

**Rebuild Trigger:** Data changes or filter updates

### 2. Category-Menu Map Caching (lines 880-928)
**Purpose:** Fast category identification during scroll

**Structure:**
```dart
_categoryMenuMap = {
  0: {'categoryId': -1, 'menuId': 789},  // Multi-course header
  5: {'categoryId': 101, 'menuId': 789}, // Category 101 header
  12: {'categoryId': 102, 'menuId': 789}, // Category 102 header
}
```

**Usage:** Maps list index to category/menu IDs for reporting

### 3. Menu Item Map (lines 776-784)
**Purpose:** O(1) lookup of items by ID

**Structure:**
```dart
_menuItemMap = {
  123: { /* full item data */ },
  124: { /* full item data */ },
}
```

**Usage:** Fast item retrieval when processing category item IDs

### 4. Scroll Debouncing (lines 506-521)
**Purpose:** Prevent reporting category changes during programmatic scrolls

**Implementation:**
- `_isScrolling` flag set during programmatic scrolls
- Resets after 600ms delay
- Scroll depth tracking paused during programmatic scrolls

### 5. Redundant Callback Prevention (lines 698-706)
**Purpose:** Avoid calling `onVisibleCategoryChanged` unnecessarily

**Implementation:**
```dart
if (categoryId != _lastReportedCategoryId || menuId != _lastReportedMenuId) {
  _lastReportedCategoryId = categoryId;
  _lastReportedMenuId = menuId;
  widget.onVisibleCategoryChanged?.call(...);
}
```

---

## Edge Cases Handled

### 1. Missing Business ID (line 277)
**Scenario:** Menu data has no business_id
**Handling:** Logs warning, analytics events skipped gracefully

### 2. Empty Categories (lines 1307-1310)
**Scenario:** All items filtered out by dietary/allergy filters
**Handling:** Shows "No dishes" message (localized)

### 3. Multi-Course Section Special ID (line 104)
**Scenario:** Packages section needs unique category ID
**Handling:** Uses special ID `-1` for tracking/scrolling

### 4. Missing Display Orders (line 107)
**Scenario:** Categories missing `display_order` or `menu_display_order`
**Handling:** Falls back to `999` to sort at end

### 5. Zero Base Price with Variations (lines 1666-1674)
**Scenario:** Item has `base_price: 0` but has variation options
**Handling:** Calculates minimum variation price, shows with "From" prefix

### 6. Invalid Dietary IDs (lines 980-982)
**Scenario:** `selectedDietaryPreferenceId: 0` or null
**Handling:** Treated as "no preference selected", filter skipped

### 7. Allergen Override (lines 1020-1041)
**Scenario:** Item can be made to satisfy restriction but contains allergen
**Handling:** Shows item despite allergen presence (customer can request modification)

### 8. Category Description Overflow (lines 2214-2257)
**Scenario:** Category description too long for single line
**Handling:** Truncates with ellipsis, shows info icon for full text

### 9. Missing Item Images (lines 1976-1982)
**Scenario:** `item_image_url` null or load error
**Handling:** Shows grey placeholder with broken image icon

### 10. Dynamic Height Scrolling (lines 1111-1126)
**Scenario:** Container uses dynamic height (changes based on content)
**Handling:** Calculates alignment as pixel offset / viewport height

---

## Usage Example

### In Business Profile Page

```dart
import '/custom_code/widgets/index.dart' as custom_widgets;

// In build method:
custom_widgets.MenuDishesListView(
  width: double.infinity,
  height: 600,
  originalCurrencyCode: 'DKK',
  isDynamicHeight: false,
  onItemTap: (
    bottomSheetInfo,
    isBeverage,
    dietaryTypeIds,
    allergyIds,
    formattedPrice,
    hasVariations,
    formattedVariationPrice,
  ) async {
    // Open item detail bottom sheet
    await showModalBottomSheet(
      context: context,
      builder: (context) => MenuItemDetailSheet(
        itemData: bottomSheetInfo,
        formattedPrice: formattedPrice,
        hasVariations: hasVariations,
        variationPrice: formattedVariationPrice,
      ),
    );
  },
  onPackageTap: (packageData) async {
    // Navigate to package detail page
    context.pushNamed(
      'PackageDetail',
      extra: packageData,
    );
  },
  onVisibleCategoryChanged: (selectionData) async {
    // Update selected category in navigation tabs
    setState(() {
      selectedCategoryId = selectionData['categoryId'];
      selectedMenuId = selectionData['menuId'];
    });
  },
  onCategoryDescriptionTap: (categoryData) async {
    // Show full description in modal
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(categoryData['categoryName']),
        content: Text(categoryData['categoryDescription']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  },
)
```

### Required Setup
1. FFAppState must have `mostRecentlyViewedBusinesMenuItems` populated
2. Currency and exchange rate must be set
3. Translation cache must be initialized
4. Menu session data must be initialized before rendering

---

## Migration Notes

### Phase 3 Implementation Checklist

**Before writing ANY code:**
1. ✅ Review FlutterFlow source (`menu_dishes_list_view.dart`)
2. ✅ Review page audit specifications (if applicable)
3. ✅ Review screenshots (if available)
4. ✅ Map all aspects (parameters, translations, analytics, state, navigation)
5. ✅ Plan implementation approach

**Translation System:**
- Uses centralized `getTranslations()` function
- All translation keys are constants at top of file
- No FlutterFlow inline translations

**State Management:**
- Currently uses `FFAppState()` singleton for filters and selected category
- Consider migrating to Riverpod providers for reactive filter updates
- Session data tracking can remain in global state

**Navigation:**
- Currently uses callbacks to parent page
- No direct navigation from widget
- Maintain callback pattern in Flutter implementation

**Analytics:**
- All events use `trackAnalyticsEvent()` custom action
- Events are non-blocking (don't await)
- Session metrics update FFAppState synchronously

---

## Testing Checklist

When implementing in Flutter:

### Data Processing
- [ ] Load menu with regular categories only - verify display
- [ ] Load menu with packages only - verify display
- [ ] Load menu with both categories and packages - verify order
- [ ] Load menu with missing display_order fields - verify fallback

### Filtering
- [ ] Select single dietary restriction - verify items filter correctly
- [ ] Select multiple dietary restrictions - verify AND logic
- [ ] Select dietary preference - verify filtering
- [ ] Select allergen exclusions - verify items hide
- [ ] Combine all filters - verify correct results
- [ ] Test allergen override (item with can_be_made) - verify shows despite allergen

### Scrolling
- [ ] Programmatic scroll to category - verify smooth scroll
- [ ] Programmatic scroll to first category - verify alignment at top
- [ ] Programmatic scroll to multi-course section - verify correct target
- [ ] Manual scroll down - verify visible category reported
- [ ] Manual scroll up - verify visible category reported
- [ ] Change selected category externally - verify auto-scroll

### Pricing
- [ ] Item with variations (base > 0) - verify "From" prefix
- [ ] Item with variations (base = 0) - verify minimum variation price
- [ ] Item without variations - verify no "From" prefix
- [ ] Item with zero price - verify invisible but layout maintained
- [ ] Package with per-person pricing - verify suffix

### Analytics
- [ ] Tap menu item - verify menu_item_clicked event
- [ ] Tap package - verify menu_package_clicked event
- [ ] Tap category info icon - verify category_description_viewed event
- [ ] Scroll to new deepest category - verify menu_scroll_depth event
- [ ] Check session data - verify itemClicks, packageClicks, categoriesViewed updated

### Translation
- [ ] Change language - verify all UI text updates
- [ ] Verify "No dishes" message localizes
- [ ] Verify "From" prefix localizes
- [ ] Verify "per person" suffix localizes
- [ ] Verify singular/plural package header localizes

### Edge Cases
- [ ] Category with all items filtered - verify "No dishes" message
- [ ] Item with missing image - verify placeholder shows
- [ ] Category with overflowing description - verify info icon shows
- [ ] Category with short description - verify no info icon
- [ ] Dynamic height container - verify scroll alignment adjusts

---

## Known Issues

None currently documented.

---

## Related Elements

### Used By Pages
- **BusinessProfile** (`business_profile_widget.dart`) - Main implementation

### Related Widgets
- `UnifiedFiltersWidget` - Filter UI (triggers filter updates)
- `MenuItemDetailSheet` - Item detail bottom sheet (called from onItemTap)
- `PackageDetailPage` - Package detail page (called from onPackageTap)

### Related Actions
- `markUserEngaged` - User interaction tracking
- `trackAnalyticsEvent` - Event logging
- `getTranslations` - Translation fetching

### Related Functions
- `convertAndFormatPrice` - Price formatting
- `determineStatusAndColor` - Business status (not used in menu widget)
- `openClosesAt` - Opening hours text (not used in menu widget)

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Flutter Implementation
