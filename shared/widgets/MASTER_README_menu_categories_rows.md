# MenuCategoriesRows Widget

## Overview

**Purpose:** Provides horizontal scrolling navigation for menu and category selection in restaurant menu displays

**Location:** `lib/custom_code/widgets/menu_categories_rows.dart`

**Type:** StatefulWidget with BLoC state management

**Primary Use Cases:**
- Navigating between multiple restaurant menus
- Selecting categories within a menu to scroll to that section
- Displaying separate rows for food and beverage categories
- Auto-scrolling to keep selected categories visible
- Tracking visible category as user scrolls the menu list

---

## Core Functionality

### Navigation Patterns

The widget supports three distinct layout modes based on restaurant menu structure:

1. **Multiple Menus**
   - First row: Menu selection buttons (e.g., "Lunch Menu", "Dinner Menu")
   - Second row: Category selection buttons (e.g., "Starters", "Mains", "Desserts")

2. **Single Menu with Beverages**
   - First row: Food categories (non-beverage items)
   - Second row: Beverage categories (drinks)

3. **Single Menu without Beverages**
   - Single row: All categories

### Bidirectional Communication

**Outgoing:** User taps category → fires `onCategoryChanged` callback → MenuDishesListView scrolls to that section

**Incoming:** User scrolls menu → MenuDishesListView detects visible category → sends `visibleSelection` JSON → MenuCategoriesRows highlights that category

### Auto-Scroll Behavior

When the menu list scrolls and reports a new visible category, this widget automatically scrolls horizontally to keep the selected category button in view. This ensures the active category indicator remains visible even in long category lists.

---

## Widget Architecture

### State Management (BLoC Pattern)

**MenuCategoryCubit** manages selection state:

```dart
class MenuCategoryState {
  final List<Menu> menus;
  final String selectedMenuId;
  final String selectedCategoryId;
}
```

**Actions:**
- `loadMenusAndCategories(List<Menu> menus)` — Initial load, selects first menu and category
- `selectMenuAndCategory(String menuId, String categoryId)` — Updates selection

### Data Models

**Menu Model:**

```dart
class Menu {
  final String id;
  final String name;
  final String? description;
  final int businessId;
  final int displayOrder;
  final List<Category> categories;
}
```

**Category Model:**

```dart
class Category {
  final String id;
  final String name;
  final String? description;
  final int displayOrder;
  final bool isBeverage;
  final bool isMultiCourse;
}
```

### Selection Tracking System

**Purpose:** Prevent feedback loops during bidirectional updates

**Mechanism:**

1. User taps category → sets `_targetSelection` → ignores intermediate scroll updates
2. MenuDishesListView scrolls to target → sends final `visibleSelection` matching target
3. Widget clears `_targetSelection` → resumes normal scroll tracking

**Result:** Smooth navigation without competing updates

---

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `businessID` | `int` | ✓ | The restaurant's business ID |
| `apiResult` | `dynamic` | ✓ | Raw API response containing menu and category data |
| `onCategoryChanged` | `Future Function(int, int)` | ✓ | Callback when user selects a category (categoryId, menuId) |
| `onNumberOfRows` | `Future Function(int)` | ✓ | Callback to report number of rows displayed (0, 1, or 2) |
| `languageCode` | `String` | ✓ | ISO language code (e.g., "en", "da") |
| `translationsCache` | `dynamic` | ✓ | Translation cache from FFAppState |
| `visibleSelection` | `dynamic?` | | JSON containing `{categoryId, menuId}` from scroll events |
| `width` | `double?` | | Widget width (optional) |
| `height` | `double?` | | Widget height (optional) |

---

## API Response Format

The widget accepts API responses in multiple formats:

**Direct List:**

```json
[
  {
    "menu_id": "1",
    "menu_title": "Lunch Menu",
    "menu_display_order": 0,
    "menu_category_id": "101",
    "category_name": "Starters",
    "category_description": "Light appetizers",
    "category_display_order": 0,
    "category_type": "regular",
    "is_beverage": false
  },
  {
    "menu_id": "1",
    "menu_title": "Lunch Menu",
    "menu_display_order": 0,
    "menu_category_id": "102",
    "category_name": "Mains",
    "category_display_order": 1,
    "category_type": "regular",
    "is_beverage": false
  }
]
```

**Wrapped Map:**

```json
{
  "menuCategories": [
    // Same format as above
  ]
}
```

### Category Types

- `"regular"` — Standard food/drink category
- `"menu_package"` — Multi-course menu (e.g., "3-course menu")

Multi-course categories receive special handling:
- Given ID `-1` (or "multi_course" string)
- Grouped under a localized header (e.g., "Multi-course menus")
- Displayed first in category list

---

## Translation Keys

All UI text uses the translation system:

| Key | Purpose | Example |
|-----|---------|---------|
| `menu_multi_course_singular` | Header for 1 multi-course package | "Multi-course menu" |
| `menu_multi_course_plural` | Header for multiple packages | "Multi-course menus" |
| `menu_no_categories` | Empty state message | "No categories available" |

**Usage Pattern:**

```dart
String _getUIText(String key) {
  return getTranslations(
    widget.languageCode,
    key,
    widget.translationsCache,
  );
}
```

---

## Visual Design

### Layout Constants

```dart
class _LayoutConstants {
  static const double rowHeight = 32.0;
  static const double buttonBorderRadius = 8.0;
  static const double itemSpacing = 8.0;
  static const double horizontalPadding = 16.0;
  static const Duration animationDuration = Duration(milliseconds: 200);
  static const Duration autoScrollDuration = Duration(milliseconds: 300);
}
```

### Color Scheme

```dart
class _ColorConstants {
  static const Color selectedColor = Color(0xFFEE8B60);  // Orange
  static const Color unselectedColor = Color(0xFFf2f3f5);  // Light gray
  static const Color selectedTextColor = Colors.white;
  static const Color unselectedTextColor = Color(0xFF242629);  // Dark gray
  static final Color borderColor = Colors.grey[500]!;
}
```

### Button States

**Selected:**
- Background: Orange (`#EE8B60`)
- Text: White
- Border: None (categories) or orange 1px (menus)

**Unselected:**
- Background: Light gray (`#f2f3f5`)
- Text: Dark gray (`#242629`)
- Border: Gray 1px

### Animations

- Background color transition: 200ms
- Auto-scroll to visible item: 300ms with easeInOut curve

---

## Key Algorithms

### 1. Menu Transformation

**Input:** Raw API response with flat category list

**Output:** Hierarchical Menu objects with organized categories

**Process:**

1. Extract categories data from various API formats
2. Group categories by menu ID
3. Identify multi-course packages (category_type = "menu_package")
4. Create synthetic multi-course header category
5. Sort menus by display_order
6. Sort categories by display_order within each menu

**Multi-Course Header Logic:**

```dart
if (multiCoursePackages.isNotEmpty) {
  organized.add(Category(
    id: 'multi_course',
    name: _getMultiCourseHeader(multiCoursePackages.length),
    displayOrder: -1,  // Always first
    isMultiCourse: true,
  ));
}
```

### 2. Display Configuration Detection

**Decision Logic:**

```dart
factory _DisplayConfiguration.fromMenus(List<Menu> menus) {
  final isMultipleMenus = menus.length > 1;
  final hasBeverages = !isMultipleMenus && menus.isNotEmpty
      ? menus.first.categories.any((c) => c.isBeverage && !c.isMultiCourse)
      : false;
  final numberOfRows = (isMultipleMenus || hasBeverages) ? 2 : 1;

  return _DisplayConfiguration(
    isMultipleMenus: isMultipleMenus,
    hasBeverages: hasBeverages,
    numberOfRows: numberOfRows,
  );
}
```

**Result:** Determines which layout pattern to use

### 3. Auto-Scroll to Visible Item

**Purpose:** Keep selected category button in view when selection changes from scrolling

**Algorithm:**

```dart
void _scrollItemIntoView(GlobalKey itemKey, ScrollController controller) {
  // 1. Get item position and size using GlobalKey
  final RenderBox itemBox = itemKey.currentContext!.findRenderObject() as RenderBox;
  final itemStart = /* calculate position relative to viewport */;
  final itemEnd = itemStart + itemExtent;

  // 2. Get viewport bounds
  final viewportStart = controller.offset;
  final viewportEnd = controller.offset + controller.position.viewportDimension;

  // 3. Calculate target scroll position
  double? targetScroll;

  if (itemStart < viewportStart) {
    // Item hidden to the left → scroll left
    targetScroll = itemStart;
  } else if (itemEnd > viewportEnd) {
    // Item hidden to the right → scroll right
    targetScroll = itemEnd - viewportDimension;
  } else {
    // Item fully visible → no scroll needed
    return;
  }

  // 4. Animate to target position
  controller.animateTo(
    targetScroll.clamp(minScrollExtent, maxScrollExtent),
    duration: Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );
}
```

**GlobalKey Management:**

```dart
final Map<String, GlobalKey> _itemKeys = {};

GlobalKey _getOrCreateKey(String itemId) {
  return _itemKeys.putIfAbsent(itemId, () => GlobalKey());
}
```

Each button gets a unique GlobalKey (e.g., "menu_1", "category_102") for position tracking.

### 4. Selection Change Handling

**Challenge:** Prevent feedback loops between widget and parent page

**Solution:** Target selection mechanism

```dart
void _handleSelection(int categoryId, int menuId, _SelectionSource source) {
  // Skip if duplicate
  if (change.isSameAs(_lastSelection)) return;

  _lastSelection = change;
  _cubit.selectMenuAndCategory(menuIdStr, categoryIdStr);

  if (source == _SelectionSource.userTap) {
    // User tapped → notify parent and set target
    widget.onCategoryChanged(categoryId, menuId);
    _targetSelection = _TargetSelection(categoryId, menuId);
  }
}
```

**Visible Selection Processing:**

```dart
void _processVisibleSelection(dynamic selectionData) {
  final (categoryId, menuId) = _parseSelectionData(selectionData);

  if (_targetSelection != null) {
    if (_targetSelection!.matches(categoryId, menuId)) {
      // Reached target → clear and update
      _targetSelection = null;
      _handleSelection(categoryId, menuId, _SelectionSource.scrollUpdate);
    } else {
      // Still scrolling → ignore
      return;
    }
  }

  // Normal scroll tracking → update and auto-scroll
  _handleSelection(categoryId, menuId, _SelectionSource.scrollUpdate);
  _autoScrollToSelection(categoryId, menuId);
}
```

---

## Usage Example

### Basic Implementation

```dart
MenuCategoriesRows(
  businessID: restaurant.id,
  apiResult: menuCategoriesApiResponse,
  languageCode: FFAppState().currentLanguageCode,
  translationsCache: FFAppState().translationsCache,
  visibleSelection: _model.visibleCategorySelection,
  onCategoryChanged: (categoryId, menuId) async {
    // Scroll MenuDishesListView to this category
    setState(() {
      _model.selectedCategoryId = categoryId;
      _model.selectedMenuId = menuId;
    });
  },
  onNumberOfRows: (numberOfRows) async {
    // Adjust layout spacing based on number of rows
    setState(() {
      _model.menuNavigationHeight = numberOfRows * 40.0;
    });
  },
)
```

### Integration with MenuDishesListView

**Page State Variables:**

```dart
class _BusinessProfilePageState extends State<BusinessProfilePage> {
  int? selectedCategoryId;
  int? selectedMenuId;
  dynamic visibleCategorySelection;  // JSON: {categoryId, menuId}
}
```

**MenuCategoriesRows → MenuDishesListView:**

```dart
// User taps category in MenuCategoriesRows
MenuCategoriesRows(
  onCategoryChanged: (categoryId, menuId) async {
    setState(() {
      selectedCategoryId = categoryId;
      selectedMenuId = menuId;
      // MenuDishesListView watches these and scrolls to category
    });
  },
  // ...
)
```

**MenuDishesListView → MenuCategoriesRows:**

```dart
// User scrolls menu list, new category becomes visible
MenuDishesListView(
  onVisibleCategoryChanged: (categoryId, menuId) async {
    setState(() {
      visibleCategorySelection = jsonEncode({
        'categoryId': categoryId,
        'menuId': menuId,
      });
      // MenuCategoriesRows watches this and highlights category
    });
  },
  // ...
)
```

---

## State Flow Diagrams

### User Taps Category

```
User taps "Starters" button
  ↓
_handleSelection(101, 1, userTap)
  ↓
_cubit.selectMenuAndCategory("1", "101")  // Update UI immediately
  ↓
widget.onCategoryChanged(101, 1)  // Notify parent
  ↓
_targetSelection = TargetSelection(101, 1)  // Ignore intermediate updates
  ↓
Parent updates selectedCategoryId/selectedMenuId
  ↓
MenuDishesListView scrolls to category 101
  ↓
(During scroll: MenuDishesListView sends visibleSelection updates)
  ↓
_processVisibleSelection ignores intermediate updates
  ↓
MenuDishesListView reaches category 101
  ↓
_processVisibleSelection receives {categoryId: 101, menuId: 1}
  ↓
Matches _targetSelection → clear _targetSelection
  ↓
_handleSelection(101, 1, scrollUpdate)
  ↓
(No auto-scroll — user already sees the button they tapped)
```

### User Scrolls Menu List

```
User scrolls menu content
  ↓
MenuDishesListView detects "Mains" is now most visible
  ↓
MenuDishesListView calls onVisibleCategoryChanged(102, 1)
  ↓
Parent updates visibleCategorySelection JSON
  ↓
widget.visibleSelection changes
  ↓
didUpdateWidget detects change
  ↓
_processVisibleSelection({categoryId: 102, menuId: 1})
  ↓
No _targetSelection active (normal scroll tracking)
  ↓
_handleSelection(102, 1, scrollUpdate)
  ↓
_cubit.selectMenuAndCategory("1", "102")  // Highlight "Mains" button
  ↓
_autoScrollToSelection(102, 1)
  ↓
WidgetsBinding.instance.addPostFrameCallback
  ↓
_scrollToSelectedItems(102, 1)
  ↓
Get GlobalKey for "category_102"
  ↓
Calculate if button is fully visible in ListView viewport
  ↓
If hidden → _scrollItemIntoView animates to bring it into view
  ↓
"Mains" button now visible and highlighted
```

---

## Edge Cases and Error Handling

### Empty Menu Data

```dart
if (state.menus.isEmpty) {
  return _buildEmptyState();  // Shows localized "No categories available"
}
```

### Menu with No Categories

```dart
if (_transformedMenus.first.categories.isEmpty) {
  widget.onNumberOfRows(0);  // Notify parent to hide widget
  return;
}
```

### Invalid visibleSelection JSON

```dart
try {
  final (categoryId, menuId) = _parseSelectionData(selectionData);
  // Process selection
} catch (e, stackTrace) {
  debugPrint('Error parsing visibleSelection: $e');
  // Fail silently, don't crash
}
```

### Missing GlobalKey

```dart
void _scrollItemIntoView(GlobalKey? itemKey, ScrollController controller) {
  if (itemKey?.currentContext == null) return;  // Exit gracefully
  if (!controller.hasClients) return;
  // Proceed with scroll calculation
}
```

### Scroll Controller Not Ready

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (!mounted) return;  // Widget disposed during frame callback
  _scrollToSelectedItems(categoryId, menuId);
});
```

### Multiple Rapid Taps

```dart
void _handleSelection(int categoryId, int menuId, _SelectionSource source) {
  final change = _SelectionChange(categoryId, menuId, source);

  if (change.isSameAs(_lastSelection)) {
    return;  // Ignore duplicate selection
  }

  _lastSelection = change;
  // Process selection
}
```

### API Response Variations

```dart
List<dynamic> _extractCategoriesData(dynamic apiResult) {
  if (apiResult is List) return apiResult;

  if (apiResult is Map) {
    final apiMap = apiResult as Map<String, dynamic>;
    return apiMap['menuCategories'] ?? apiMap['categories'] ?? [];
  }

  return [];  // Unsupported format → empty list
}
```

### Type Safety for Dynamic API Data

```dart
int _safeInt(dynamic value, int defaultValue) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

String _safeString(dynamic value, String defaultValue) {
  if (value == null) return defaultValue;
  return value.toString();
}

bool _safeBool(dynamic value, bool defaultValue) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true' || value == '1';
  if (value is int) return value != 0;
  return defaultValue;
}
```

---

## Performance Optimizations

### ListView Caching

```dart
ListView.separated(
  cacheExtent: 300.0,  // Pre-render buttons 300px beyond viewport
  // Reduces jank during scroll
)
```

### Minimal Rebuilds

Uses BLoC pattern to rebuild only when state actually changes. Button widgets don't rebuild during scroll unless selection changes.

### Efficient Auto-Scroll

Only scrolls when item is not fully visible. Calculates minimal scroll distance required.

```dart
if (itemStart < viewportStart) {
  targetScroll = itemStart;  // Just enough to show left edge
} else if (itemEnd > viewportEnd) {
  targetScroll = itemEnd - viewportDimension;  // Just enough to show right edge
} else {
  return;  // Fully visible, no scroll needed
}
```

### Frame Callback Deferral

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (!mounted) return;
  _initializeMenusAndNotifyRows();
});
```

Prevents calling `setState` on parent during child's build phase, which would cause errors.

---

## Testing Considerations

### Unit Tests

**State Management:**

```dart
test('MenuCategoryCubit loads menus and selects first category', () {
  final cubit = MenuCategoryCubit();
  final menus = [
    Menu(
      id: '1',
      name: 'Lunch',
      businessId: 123,
      displayOrder: 0,
      categories: [
        Category(id: '101', name: 'Starters', displayOrder: 0, isBeverage: false),
      ],
    ),
  ];

  cubit.loadMenusAndCategories(menus);

  expect(cubit.state.selectedMenuId, '1');
  expect(cubit.state.selectedCategoryId, '101');
});
```

**API Transformation:**

```dart
test('transforms API response with multi-course header', () {
  final widget = MenuCategoriesRowsState();
  final apiResult = [
    {
      'menu_id': '1',
      'menu_title': 'Dinner',
      'menu_category_id': '101',
      'category_name': '3-course menu',
      'category_type': 'menu_package',
      'is_beverage': false,
    },
  ];

  final menus = widget._transformApiResponse(apiResult);

  expect(menus.length, 1);
  expect(menus[0].categories[0].isMultiCourse, true);
  expect(menus[0].categories[0].id, 'multi_course');
});
```

### Widget Tests

**Button Rendering:**

```dart
testWidgets('renders menu buttons correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MenuCategoriesRows(
        businessID: 123,
        apiResult: mockApiResult,
        languageCode: 'en',
        translationsCache: mockTranslations,
        onCategoryChanged: (_, __) async {},
        onNumberOfRows: (_) async {},
      ),
    ),
  );

  expect(find.text('Lunch Menu'), findsOneWidget);
  expect(find.text('Dinner Menu'), findsOneWidget);
});
```

**Selection Changes:**

```dart
testWidgets('fires onCategoryChanged when category tapped', (tester) async {
  int? receivedCategoryId;
  int? receivedMenuId;

  await tester.pumpWidget(
    MaterialApp(
      home: MenuCategoriesRows(
        // ...
        onCategoryChanged: (catId, menuId) async {
          receivedCategoryId = catId;
          receivedMenuId = menuId;
        },
      ),
    ),
  );

  await tester.tap(find.text('Starters'));
  await tester.pumpAndSettle();

  expect(receivedCategoryId, 101);
  expect(receivedMenuId, 1);
});
```

### Integration Tests

**Bidirectional Communication:**

```dart
testWidgets('updates selection when visibleSelection changes', (tester) async {
  final visibleSelection = ValueNotifier<dynamic>(null);

  await tester.pumpWidget(
    MaterialApp(
      home: ValueListenableBuilder(
        valueListenable: visibleSelection,
        builder: (context, value, _) {
          return MenuCategoriesRows(
            // ...
            visibleSelection: value,
          );
        },
      ),
    ),
  );

  // Simulate scroll event from MenuDishesListView
  visibleSelection.value = jsonEncode({'categoryId': 102, 'menuId': 1});
  await tester.pumpAndSettle();

  // Verify "Mains" button is now highlighted
  final mainsButton = tester.widget<ElevatedButton>(
    find.widgetWithText(ElevatedButton, 'Mains'),
  );
  final buttonStyle = mainsButton.style!;
  final bgColor = buttonStyle.backgroundColor!.resolve({});

  expect(bgColor, const Color(0xFFEE8B60));  // Selected orange color
});
```

---

## Common Issues and Solutions

### Issue: Categories Not Highlighting During Scroll

**Symptom:** User scrolls menu list but category buttons don't update

**Diagnosis:**
- Check if `visibleSelection` prop is being passed correctly
- Verify MenuDishesListView is calling `onVisibleCategoryChanged`
- Ensure JSON format matches `{categoryId: int, menuId: int}`

**Solution:**

```dart
// In parent page
MenuDishesListView(
  onVisibleCategoryChanged: (categoryId, menuId) async {
    setState(() {
      _model.visibleCategorySelection = jsonEncode({
        'categoryId': categoryId,
        'menuId': menuId,
      });
    });
  },
  // ...
)
```

### Issue: Feedback Loop (Rapid Updates)

**Symptom:** Erratic behavior when tapping categories, scrolling seems to fight itself

**Cause:** Target selection mechanism not working correctly

**Solution:** Ensure `_targetSelection` is set on user tap and cleared when target reached:

```dart
if (source == _SelectionSource.userTap) {
  _targetSelection = _TargetSelection(categoryId, menuId);
}

// In _processVisibleSelection
if (_targetSelection != null) {
  if (_targetSelection!.matches(categoryId, menuId)) {
    _targetSelection = null;  // MUST clear when target reached
  } else {
    return;  // Ignore intermediate updates
  }
}
```

### Issue: Auto-Scroll Not Working

**Symptom:** Selected category button goes off-screen during scroll tracking

**Diagnosis:**
- Check if GlobalKeys are properly assigned to buttons
- Verify `_autoScrollToSelection` is called for scroll updates
- Ensure `_autoScrollToSelection` is NOT called for user taps

**Solution:**

```dart
if (source == _SelectionSource.scrollUpdate) {
  // Auto-scroll only for scroll updates, not user taps
  _autoScrollToSelection(categoryId, menuId);
}
```

### Issue: Buttons Not Rendering Correctly

**Symptom:** Buttons overlap or have incorrect styling

**Cause:** Layout constants may not match design specs

**Solution:** Verify constants:

```dart
static const double rowHeight = 32.0;
static const double buttonBorderRadius = 8.0;
static const double itemSpacing = 8.0;
static const double horizontalPadding = 16.0;
```

### Issue: Multi-Course Header Not Showing

**Symptom:** Multi-course packages appear as individual categories instead of grouped

**Diagnosis:**
- Check if API returns `category_type: "menu_package"`
- Verify `_organizeMenuCategories` creates header

**Solution:**

```dart
// Ensure API response has correct category_type
{
  "category_type": "menu_package",  // NOT "regular"
  "is_beverage": false
}
```

### Issue: Translation Keys Not Found

**Symptom:** "[TRANSLATION_MISSING]" or raw keys displayed

**Cause:** Translation cache doesn't contain required keys

**Solution:** Verify translation keys exist in Supabase translations:

```sql
SELECT * FROM translations
WHERE translation_key IN (
  'menu_multi_course_singular',
  'menu_multi_course_plural',
  'menu_no_categories'
);
```

---

## Migration Notes

### Differences from FlutterFlow Version

This widget is a **custom widget** in FlutterFlow, meaning the code is identical. However, when migrating to pure Flutter:

1. **Import Path Changes:**
   ```dart
   // FlutterFlow
   import '/backend/schema/structs/index.dart';
   import '/flutter_flow/flutter_flow_theme.dart';

   // Pure Flutter
   import 'package:journeymate/models/menu.dart';
   import 'package:journeymate/theme/app_theme.dart';
   ```

2. **Translation Function:**
   ```dart
   // FlutterFlow
   getTranslations(languageCode, key, translationsCache)

   // Pure Flutter (with Provider)
   context.read<TranslationService>().getText(key, languageCode)
   ```

3. **State Management:**
   Current implementation uses `flutter_bloc` package. Consider migrating to Riverpod for consistency with rest of app.

### Preserving Functionality

**Critical Elements to Maintain:**

1. **Bidirectional communication pattern** (user tap vs. scroll update)
2. **Target selection mechanism** (prevents feedback loops)
3. **Auto-scroll to visible item** (uses GlobalKeys and RenderBox positions)
4. **Multi-course header logic** (synthetic category with ID -1)
5. **Three layout modes** (multiple menus / single with beverages / single without)

**Testing After Migration:**

- [ ] Tapping category scrolls menu to that section
- [ ] Scrolling menu highlights corresponding category
- [ ] Auto-scroll keeps selected category visible
- [ ] No feedback loops during navigation
- [ ] Multi-course packages display with localized header
- [ ] Beverage categories display in separate row when applicable
- [ ] Empty state displays correctly
- [ ] Translation keys resolve correctly

---

## Related Widgets

- **MenuDishesListView** — Displays menu items in scrollable list, communicates visible category back to this widget
- **MenuCategoryItems** — Renders individual menu items within categories (used by MenuDishesListView)

---

## References

**Source File:** `C:\Users\Rikke\Documents\JourneyMate\_flutterflow_export\lib\custom_code\widgets\menu_categories_rows.dart`

**Dependencies:**
- `flutter_bloc` — State management (MenuCategoryCubit)
- `collection` — Helper methods (firstWhereOrNull)

**Design System:** See `_reference/journeymate-design-system.md` for color and spacing rules

---

*Last Updated: 2026-02-19*
*Widget Version: FlutterFlow Custom Widget*
*Documentation Format: Streamlined Widget README (350-450 lines)*
