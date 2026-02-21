// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';

// ============================================================================
// CONSTANTS & CONFIGURATION
// ============================================================================

/// Layout and styling constants for the menu categories widget
class _LayoutConstants {
  static const double rowHeight = 32.0;
  static const double buttonBorderRadius = 8.0;
  static const double itemSpacing = 8.0;
  static const double horizontalPadding = 16.0;
  static const double listViewCacheExtent = 300.0;
  static const Duration animationDuration = Duration(milliseconds: 200);
  static const Duration autoScrollDuration = Duration(milliseconds: 300);

  // Multi-course category ID sentinel value
  static const int multiCourseCategoryId = -1;
  static const String multiCourseCategoryIdStr = 'multi_course';
}

/// Color constants for the menu categories widget
class _ColorConstants {
  static const Color selectedColor = Color(0xFFEE8B60);
  static const Color unselectedColor = Color(0xFFf2f3f5);
  static const Color selectedTextColor = Colors.white;
  static const Color unselectedTextColor = Color(0xFF242629);
  static final Color borderColor = Colors.grey[500]!;
}

/// Text style constants for the menu categories widget
class _TextStyles {
  static const TextStyle selected = TextStyle(
    color: _ColorConstants.selectedTextColor,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle unselected = TextStyle(
    color: _ColorConstants.unselectedTextColor,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
}

// ============================================================================
// DATA MODELS
// ============================================================================

/// Represents a menu containing categories
@immutable
class Menu {
  final String id;
  final String name;
  final String? description;
  final int businessId;
  final int displayOrder;
  final List<Category> categories;

  const Menu({
    required this.id,
    required this.name,
    this.description,
    required this.businessId,
    required this.displayOrder,
    required this.categories,
  });
}

/// Represents a category within a menu
@immutable
class Category {
  final String id;
  final String name;
  final String? description;
  final int displayOrder;
  final bool isBeverage;
  final bool isMultiCourse;

  const Category({
    required this.id,
    required this.name,
    this.description,
    required this.displayOrder,
    required this.isBeverage,
    this.isMultiCourse = false,
  });
}

// ============================================================================
// STATE MANAGEMENT
// ============================================================================

/// State for menu and category selection
class MenuCategoryState {
  final List<Menu> menus;
  final String selectedMenuId;
  final String selectedCategoryId;

  const MenuCategoryState({
    required this.menus,
    required this.selectedMenuId,
    required this.selectedCategoryId,
  });

  const MenuCategoryState.initial()
      : menus = const [],
        selectedMenuId = '',
        selectedCategoryId = '';

  MenuCategoryState copyWith({
    List<Menu>? menus,
    String? selectedMenuId,
    String? selectedCategoryId,
  }) {
    return MenuCategoryState(
      menus: menus ?? this.menus,
      selectedMenuId: selectedMenuId ?? this.selectedMenuId,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }
}

/// Cubit for managing menu and category selection state
class MenuCategoryCubit extends Cubit<MenuCategoryState> {
  MenuCategoryCubit() : super(const MenuCategoryState.initial());

  /// Loads menus and selects the first menu's appropriate category
  ///
  /// Prioritizes multi-course categories if available, otherwise selects
  /// the first regular category.
  void loadMenusAndCategories(List<Menu> menus) {
    if (menus.isEmpty) return;

    final selectedMenuId = menus.first.id;
    final firstCategory = _findInitialCategory(menus.first);

    emit(state.copyWith(
      menus: menus,
      selectedMenuId: selectedMenuId,
      selectedCategoryId: firstCategory.id,
    ));
  }

  /// Selects a specific menu and category combination
  void selectMenuAndCategory(String menuId, String categoryId) {
    emit(state.copyWith(
      selectedMenuId: menuId,
      selectedCategoryId: categoryId,
    ));
  }

  /// Finds the initial category to select (multi-course preferred)
  Category _findInitialCategory(Menu menu) {
    return menu.categories.firstWhere(
      (cat) => cat.isMultiCourse,
      orElse: () => menu.categories.first,
    );
  }
}

// ============================================================================
// HELPER DATA CLASSES
// ============================================================================

/// Configuration for determining widget display layout
class _DisplayConfiguration {
  final bool isMultipleMenus;
  final bool hasBeverages;
  final int numberOfRows;

  const _DisplayConfiguration({
    required this.isMultipleMenus,
    required this.hasBeverages,
    required this.numberOfRows,
  });

  /// Creates display configuration from a list of menus
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
}

/// Represents the source of a selection change
enum _SelectionSource {
  userTap, // User clicked a button
  scrollUpdate, // Selection changed from scroll position
}

/// Represents a selection change event
class _SelectionChange {
  final int categoryId;
  final int menuId;
  final _SelectionSource source;

  const _SelectionChange({
    required this.categoryId,
    required this.menuId,
    required this.source,
  });

  bool isSameAs(_SelectionChange? other) {
    return other != null &&
        categoryId == other.categoryId &&
        menuId == other.menuId;
  }
}

/// Represents a target selection from a user tap
/// Used to ignore intermediate scroll updates until target is reached
class _TargetSelection {
  final int categoryId;
  final int menuId;

  const _TargetSelection({
    required this.categoryId,
    required this.menuId,
  });

  /// Checks if the given selection matches this target
  bool matches(int categoryId, int menuId) {
    return this.categoryId == categoryId && this.menuId == menuId;
  }
}

/// Container for grouped menu data during API transformation
class _MenuGroupingData {
  final Map<String, List<Category>> categoriesByMenu;
  final Map<String, String> menuTitles;
  final Map<String, int> menuDisplayOrders;

  const _MenuGroupingData({
    required this.categoriesByMenu,
    required this.menuTitles,
    required this.menuDisplayOrders,
  });
}

/// Container for parsed category data from API
class _ParsedCategoryData {
  final String menuId;
  final String menuTitle;
  final int menuDisplayOrder;
  final Category category;

  const _ParsedCategoryData({
    required this.menuId,
    required this.menuTitle,
    required this.menuDisplayOrder,
    required this.category,
  });
}

// ============================================================================
// MAIN WIDGET
// ============================================================================

/// A custom widget that displays menu and category selection rows.
///
/// This widget manages a two-row layout for navigating menus and categories
/// in a restaurant menu system. It handles both single and multiple menu
/// scenarios, as well as beverage category separation.
///
/// The widget communicates bidirectionally: - Reports selection changes via
/// [onCategoryChanged] callback - Receives scroll-triggered selections via
/// [visibleSelection] JSON - Auto-scrolls to keep selected items visible when
/// selection changes from scroll
///
/// Layout behavior: - Multiple menus: First row = menus, second row =
/// categories - Single menu with beverages: First row = food categories,
/// second row = beverages - Single menu without beverages: Single row with
/// all categories
///
/// Parameters: businessID: The ID of the business whose menus are displayed
/// apiResult: Raw API response containing menu and category data
/// onCategoryChanged: Callback fired when user selects a category
/// onNumberOfRows: Callback to report the number of rows being displayed
/// languageCode: ISO language code for localized translations
/// translationsCache: Translation cache from FFAppState visibleSelection:
/// Optional JSON containing category/menu IDs from scroll events
class MenuCategoriesRows extends StatefulWidget {
  const MenuCategoriesRows({
    super.key,
    this.width,
    this.height,
    required this.businessID,
    required this.apiResult,
    required this.onCategoryChanged,
    required this.onNumberOfRows,
    required this.languageCode,
    required this.translationsCache,
    this.visibleSelection,
  });

  final double? width;
  final double? height;
  final int businessID;
  final dynamic apiResult;
  final Future Function(int categoryID, int menuID) onCategoryChanged;
  final Future Function(int numberOfRows) onNumberOfRows;
  final String languageCode;

  /// Translation cache from FFAppState containing all localized strings.
  /// Expected to contain keys like 'menu_multi_course_singular', etc.
  final dynamic translationsCache;

  final dynamic? visibleSelection;

  @override
  State<MenuCategoriesRows> createState() => _MenuCategoriesRowsState();
}

class _MenuCategoriesRowsState extends State<MenuCategoriesRows> {
  late final MenuCategoryCubit _cubit;
  final ScrollController _menuScrollController = ScrollController();
  final ScrollController _categoryScrollController = ScrollController();
  final ScrollController _beverageCategoryScrollController = ScrollController();

  late List<Menu> _transformedMenus;
  _SelectionChange? _lastSelection;

  /// Target selection from user tap - ignore scroll updates until reached
  _TargetSelection? _targetSelection;

  /// GlobalKeys for menu and category buttons to enable auto-scrolling
  final Map<String, GlobalKey> _itemKeys = {};

  // ============================================================================
  // TRANSLATION HELPERS
  // ============================================================================

  /// Gets localized UI text using central translation function
  ///
  /// Follows the same pattern as _getUIText() in sample functions.
  ///
  /// Args:
  ///   key: Translation key (e.g., 'menu_no_categories')
  ///
  /// Returns:
  ///   Localized string, or formatted fallback if translation not found
  String _getUIText(String key) {
    return getTranslations(
      widget.languageCode,
      key,
      widget.translationsCache,
    );
  }

  /// Gets localized multi-course header based on count
  ///
  /// Uses singular or plural form based on the number of packages.
  ///
  /// Args:
  ///   count: Number of multi-course packages
  ///
  /// Returns:
  ///   Localized multi-course header text
  String _getMultiCourseHeader(int count) {
    final translationKey =
        count == 1 ? 'menu_multi_course_singular' : 'menu_multi_course_plural';

    return _getUIText(translationKey);
  }

// ============================================================================
// LIFECYCLE METHODS
// ============================================================================

  @override
  void initState() {
    super.initState();
    _cubit = MenuCategoryCubit();
    _transformedMenus = _transformApiResponse(widget.apiResult);

    // Defer initialization to after the build phase to avoid
    // calling setState on parent widget during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initializeMenusAndNotifyRows();
    });
  }

  @override
  void didUpdateWidget(MenuCategoriesRows oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle API result changes
    if (widget.apiResult != oldWidget.apiResult) {
      _handleApiResultChange();
    }

    // Handle visible selection changes from page state (JSON)
    if (widget.visibleSelection != null &&
        widget.visibleSelection != oldWidget.visibleSelection) {
      _processVisibleSelection(widget.visibleSelection);
    }

    // Handle translation cache changes
    if (widget.translationsCache != oldWidget.translationsCache ||
        widget.languageCode != oldWidget.languageCode) {
      setState(() {
        // Rebuild with new translations
        _transformedMenus = _transformApiResponse(widget.apiResult);
      });
    }
  }

  @override
  void dispose() {
    _cubit.close();
    _menuScrollController.dispose();
    _categoryScrollController.dispose();
    _beverageCategoryScrollController.dispose();
    super.dispose();
  }

  // ============================================================================
  // INITIALIZATION HELPERS
  // ============================================================================

  /// Initializes menus and notifies parent of row count
  void _initializeMenusAndNotifyRows() {
    if (_transformedMenus.isEmpty) {
      widget.onNumberOfRows(0);
      return;
    }

    final displayConfig = _DisplayConfiguration.fromMenus(_transformedMenus);
    widget.onNumberOfRows(displayConfig.numberOfRows);

    if (_transformedMenus.first.categories.isEmpty) {
      return;
    }

    _cubit.loadMenusAndCategories(_transformedMenus);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final firstCategory = _transformedMenus.first.categories.first;
      final categoryId = firstCategory.isMultiCourse
          ? _LayoutConstants.multiCourseCategoryId
          : int.parse(firstCategory.id);

      await widget.onCategoryChanged(
        categoryId,
        int.parse(_transformedMenus.first.id),
      );
    });
  }

  /// Handles API result changes by re-transforming and updating state
  void _handleApiResultChange() {
    _transformedMenus = _transformApiResponse(widget.apiResult);

    if (_transformedMenus.isEmpty) {
      widget.onNumberOfRows(0);
      return;
    }

    final displayConfig = _DisplayConfiguration.fromMenus(_transformedMenus);
    widget.onNumberOfRows(displayConfig.numberOfRows);

    if (_transformedMenus.first.categories.isEmpty) {
      return;
    }

    final selectedMenu = _transformedMenus.first;
    final firstCategory = selectedMenu.categories.first;
    final categoryId = firstCategory.isMultiCourse
        ? _LayoutConstants.multiCourseCategoryIdStr
        : firstCategory.id;
    final intCategoryId = firstCategory.isMultiCourse
        ? _LayoutConstants.multiCourseCategoryId
        : int.parse(firstCategory.id);

    _cubit.selectMenuAndCategory(selectedMenu.id, categoryId);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await widget.onCategoryChanged(
        intCategoryId,
        int.parse(selectedMenu.id),
      );
    });
  }

  // ============================================================================
  // SELECTION HANDLING
  // ============================================================================

  /// Handles selection changes from user taps or scroll updates
  ///
  /// Args:
  ///  categoryId: The ID of the selected category (-1 for multi-course)
  ///  menuId: The ID of the selected menu
  ///  source: Whether this change came from user tap or scroll update
  void _handleSelection(
    int categoryId,
    int menuId,
    _SelectionSource source,
  ) {
    final change = _SelectionChange(
      categoryId: categoryId,
      menuId: menuId,
      source: source,
    );

    // Avoid processing if this is the same selection
    if (change.isSameAs(_lastSelection)) {
      return;
    }

    _lastSelection = change;

    // Convert IDs to strings for cubit
    final categoryIdStr = categoryId == _LayoutConstants.multiCourseCategoryId
        ? _LayoutConstants.multiCourseCategoryIdStr
        : categoryId.toString();
    final menuIdStr = menuId.toString();

    // Update cubit state (triggers UI rebuild)
    _cubit.selectMenuAndCategory(menuIdStr, categoryIdStr);

    // Only trigger callback if user initiated
    if (source == _SelectionSource.userTap) {
      widget.onCategoryChanged(categoryId, menuId);

      // Set target selection - ignore scroll updates until we reach this target
      _targetSelection = _TargetSelection(
        categoryId: categoryId,
        menuId: menuId,
      );
    }
  }

  /// Processes the visible selection JSON from page state and updates UI
  ///
  /// This method handles scroll-triggered selection updates from the
  /// MenuDishesListView widget. During user-initiated navigation, intermediate
  /// scroll updates are ignored until the target selection is reached.
  ///
  /// Args:
  ///  selectionData: JSON map or string containing categoryId and menuId
  ///
  /// Expected JSON format:
  /// ```json
  /// {
  ///   "categoryId": 123,
  ///   "menuId": 456
  /// }
  /// ```
  void _processVisibleSelection(dynamic selectionData) {
    if (selectionData == null) return;

    try {
      final parsedData = _parseSelectionData(selectionData);
      if (parsedData == null) return;

      final (categoryId, menuId) = parsedData;

      // If we have a target selection from a user tap
      if (_targetSelection != null) {
        if (_targetSelection!.matches(categoryId, menuId)) {
          // We've reached the target! Clear it and update the UI
          _targetSelection = null;
          _handleSelection(categoryId, menuId, _SelectionSource.scrollUpdate);
          // Note: No auto-scroll here - user already tapped, so it's visible
        }
        // Otherwise, ignore this intermediate update during scroll animation
        return;
      }

      // Normal scroll tracking (no active user-initiated navigation)
      _handleSelection(categoryId, menuId, _SelectionSource.scrollUpdate);

      // Auto-scroll to keep selected category visible
      // Only for scroll updates, not user taps
      _autoScrollToSelection(categoryId, menuId);
    } catch (e, stackTrace) {
      debugPrint('Error parsing visibleSelection: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Parses selection data from various JSON formats
  ///
  /// Returns:
  ///  A tuple of (categoryId, menuId) if successful, null otherwise
  (int, int)? _parseSelectionData(dynamic selectionData) {
    int? categoryId;
    int? menuId;

    if (selectionData is Map) {
      categoryId = selectionData['categoryId'] as int?;
      menuId = selectionData['menuId'] as int?;
    } else if (selectionData is String) {
      final parsed = jsonDecode(selectionData) as Map<String, dynamic>;
      categoryId = parsed['categoryId'] as int?;
      menuId = parsed['menuId'] as int?;
    }

    if (categoryId != null && menuId != null) {
      return (categoryId, menuId);
    }

    return null;
  }

  // ============================================================================
  // AUTO-SCROLL HELPERS
  // ============================================================================

  /// Triggers auto-scroll after frame renders to bring selection into view
  /// Only called for scroll-triggered updates, not user taps
  ///
  /// Args:
  ///  categoryId: The selected category ID
  ///  menuId: The selected menu ID
  void _autoScrollToSelection(int categoryId, int menuId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToSelectedItems(categoryId, menuId);
    });
  }

  /// Scrolls selected menu and category buttons into view if hidden
  ///
  /// Uses manual visibility detection and ScrollController.animateTo() to
  /// perform minimal horizontal scroll only when items are not fully visible.
  ///
  /// Args:
  ///  categoryId: The selected category ID
  ///  menuId: The selected menu ID
  void _scrollToSelectedItems(int categoryId, int menuId) {
    // Scroll menu button into view if multiple menus exist
    if (_transformedMenus.length > 1) {
      final menuKey = _itemKeys['menu_$menuId'];
      _scrollItemIntoView(menuKey, _menuScrollController);
    }

    // Scroll category button into view
    final categoryIdStr = categoryId == _LayoutConstants.multiCourseCategoryId
        ? _LayoutConstants.multiCourseCategoryIdStr
        : categoryId.toString();
    final categoryKey = _itemKeys['category_$categoryIdStr'];

    // Determine which controller to use based on display configuration
    final displayConfig = _DisplayConfiguration.fromMenus(_transformedMenus);
    final controller =
        _getCategoryScrollControllerForAutoScroll(displayConfig, categoryIdStr);

    _scrollItemIntoView(categoryKey, controller);
  }

  /// Gets the appropriate scroll controller for auto-scrolling categories
  ScrollController _getCategoryScrollControllerForAutoScroll(
    _DisplayConfiguration config,
    String categoryId,
  ) {
    if (config.isMultipleMenus) {
      return _categoryScrollController;
    } else if (config.hasBeverages) {
      // Determine if this is a beverage category
      final menu = _transformedMenus.first;
      final category =
          menu.categories.firstWhereOrNull((c) => c.id == categoryId);
      if (category != null && category.isBeverage && !category.isMultiCourse) {
        return _beverageCategoryScrollController;
      }
      return _categoryScrollController;
    }
    return _categoryScrollController;
  }

  /// Scrolls an item into view using its GlobalKey and ScrollController
  ///
  /// Performs minimal scroll: only scrolls if item is not fully visible,
  /// and only scrolls enough to bring it into view from the hidden edge.
  ///
  /// Args:
  ///  itemKey: GlobalKey attached to the item widget
  ///  controller: ScrollController for the containing ListView
  void _scrollItemIntoView(GlobalKey? itemKey, ScrollController controller) {
    if (itemKey?.currentContext == null) return;
    if (!controller.hasClients) return;

    try {
      final RenderBox itemBox =
          itemKey!.currentContext!.findRenderObject() as RenderBox;
      final RenderBox? scrollableBox =
          controller.position.context.notificationContext?.findRenderObject()
              as RenderBox?;

      if (scrollableBox == null) return;

      // Get item position relative to scrollable
      final itemPosition =
          itemBox.localToGlobal(Offset.zero, ancestor: scrollableBox);
      final itemExtent = controller.position.axis == Axis.horizontal
          ? itemBox.size.width
          : itemBox.size.height;

      final viewportDimension = controller.position.viewportDimension;
      final currentScroll = controller.offset;

      // Calculate if item is visible
      final itemStart = controller.position.axis == Axis.horizontal
          ? itemPosition.dx + currentScroll
          : itemPosition.dy + currentScroll;
      final itemEnd = itemStart + itemExtent;

      final viewportStart = currentScroll;
      final viewportEnd = currentScroll + viewportDimension;

      double? targetScroll;

      // Item is hidden to the left/top
      if (itemStart < viewportStart) {
        targetScroll = itemStart;
      }
      // Item is hidden to the right/bottom
      else if (itemEnd > viewportEnd) {
        targetScroll = itemEnd - viewportDimension;
      }
      // Item is fully visible - no scroll needed
      else {
        return;
      }

      // Clamp to valid scroll range
      targetScroll = targetScroll.clamp(
        controller.position.minScrollExtent,
        controller.position.maxScrollExtent,
      );

      // Only scroll if target is different from current
      if ((targetScroll - currentScroll).abs() > 0.5) {
        controller.animateTo(
          targetScroll,
          duration: _LayoutConstants.autoScrollDuration,
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      debugPrint('Error scrolling item into view: $e');
    }
  }

  /// Gets or creates a GlobalKey for an item (menu or category)
  ///
  /// Args:
  ///  itemId: Unique identifier for the item (e.g., "menu_123" or "category_456")
  ///
  /// Returns:
  ///  GlobalKey that can be attached to the widget
  GlobalKey _getOrCreateKey(String itemId) {
    return _itemKeys.putIfAbsent(itemId, () => GlobalKey());
  }

  // ============================================================================
  // API TRANSFORMATION
  // ============================================================================

  /// Transforms raw API response into structured Menu objects
  ///
  /// Handles various API response formats and groups categories by menu.
  /// Multi-course packages are given a special header category.
  ///
  /// Args:
  ///  apiResult: Raw API response (can be List or Map)
  ///
  /// Returns:
  ///  List of Menu objects sorted by display order
  List<Menu> _transformApiResponse(dynamic apiResult) {
    final categoriesData = _extractCategoriesData(apiResult);
    if (categoriesData.isEmpty) return [];

    final menuData = _groupCategoriesByMenu(categoriesData);
    return _buildMenuObjects(menuData);
  }

  /// Extracts categories data from various API response formats
  ///
  /// Supports both direct List responses and Map responses with
  /// 'menuCategories' or 'categories' keys.
  ///
  /// Returns:
  ///  List of category items or empty list if extraction fails
  List<dynamic> _extractCategoriesData(dynamic apiResult) {
    try {
      if (apiResult is List) return apiResult;

      if (apiResult is Map) {
        final apiMap = apiResult as Map<String, dynamic>;
        return apiMap['menuCategories'] ?? apiMap['categories'] ?? [];
      }

      return [];
    } catch (e) {
      debugPrint('Error extracting categories data: $e');
      return [];
    }
  }

  /// Groups categories by menu ID with associated metadata
  ///
  /// Parses each category item and organizes them into menus,
  /// tracking menu titles and display orders.
  ///
  /// Returns:
  ///  _MenuGroupingData containing categorized and menu metadata
  _MenuGroupingData _groupCategoriesByMenu(List<dynamic> categoriesData) {
    final categoriesByMenu = <String, List<Category>>{};
    final menuTitles = <String, String>{};
    final menuDisplayOrders = <String, int>{};

    for (final categoryItem in categoriesData) {
      final parsedData = _parseCategoryItem(categoryItem);

      menuTitles[parsedData.menuId] = parsedData.menuTitle;
      menuDisplayOrders[parsedData.menuId] = parsedData.menuDisplayOrder;

      categoriesByMenu
          .putIfAbsent(parsedData.menuId, () => [])
          .add(parsedData.category);
    }

    return _MenuGroupingData(
      categoriesByMenu: categoriesByMenu,
      menuTitles: menuTitles,
      menuDisplayOrders: menuDisplayOrders,
    );
  }

  /// Parses a single category item from API response
  ///
  /// Extracts all relevant data including menu metadata and category details.
  /// Handles both regular categories and multi-course packages.
  ///
  /// Returns:
  ///  _ParsedCategoryData containing all extracted information
  _ParsedCategoryData _parseCategoryItem(dynamic categoryItem) {
    final menuId = _safeString(categoryItem['menu_id'], '0');
    final menuTitle = _safeString(categoryItem['menu_title'], 'Menu');
    final menuDisplayOrder = _safeInt(categoryItem['menu_display_order'], 0);

    final categoryId = _safeString(categoryItem['menu_category_id'], '0');
    final categoryType = categoryItem['category_type'] as String?;
    final isMultiCourse = categoryType == 'menu_package';

    final categoryName = _safeString(
      categoryItem['category_name'],
      isMultiCourse ? 'Untitled Package' : 'Untitled Category',
    );

    final category = Category(
      id: categoryId,
      name: categoryName,
      description: categoryItem['category_description'] as String?,
      displayOrder: _safeInt(categoryItem['category_display_order'], 0),
      isBeverage: _safeBool(categoryItem['is_beverage'], false),
      isMultiCourse: isMultiCourse,
    );

    return _ParsedCategoryData(
      menuId: menuId,
      menuTitle: menuTitle,
      menuDisplayOrder: menuDisplayOrder,
      category: category,
    );
  }

  /// Builds Menu objects from grouped category data
  ///
  /// Creates Menu objects with organized categories (including multi-course
  /// headers if needed) and sorts them by display order.
  ///
  /// Returns:
  ///  List of Menu objects sorted by display order
  List<Menu> _buildMenuObjects(_MenuGroupingData data) {
    final menus = <Menu>[];

    data.categoriesByMenu.forEach((menuId, categories) {
      final organizedCategories = _organizeMenuCategories(categories);

      menus.add(Menu(
        id: menuId,
        name: data.menuTitles[menuId] ?? 'Untitled Menu',
        businessId: widget.businessID,
        displayOrder: data.menuDisplayOrders[menuId] ?? 999,
        categories: organizedCategories,
      ));
    });

    menus.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return menus;
  }

  /// Organizes categories with multi-course header if needed
  ///
  /// Separates multi-course packages from regular categories and adds
  /// a localized header for multi-course items if any exist.
  ///
  /// Returns:
  ///  Organized list of categories sorted by display order
  List<Category> _organizeMenuCategories(List<Category> categories) {
    final multiCoursePackages =
        categories.where((c) => c.isMultiCourse).toList();
    final regularCategories =
        categories.where((c) => !c.isMultiCourse).toList();

    final organized = <Category>[];

    if (multiCoursePackages.isNotEmpty) {
      organized.add(_createMultiCourseHeader(multiCoursePackages.length));
    }

    organized.addAll(regularCategories);
    organized.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return organized;
  }

  /// Creates the multi-course header category
  ///
  /// Generates a localized header using translations from Supabase
  /// based on the number of packages.
  ///
  /// Returns:
  ///  A Category object representing the multi-course header
  Category _createMultiCourseHeader(int packageCount) {
    return Category(
      id: _LayoutConstants.multiCourseCategoryIdStr,
      name: _getMultiCourseHeader(packageCount),
      description: 'Multi-course menu options',
      displayOrder: -1,
      isBeverage: false,
      isMultiCourse: true,
    );
  }

  // ============================================================================
  // TYPE SAFETY HELPERS
  // ============================================================================

  /// Safely extracts an integer from dynamic API data
  int _safeInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Safely extracts a string from dynamic API data
  String _safeString(dynamic value, String defaultValue) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  /// Safely extracts a boolean from dynamic API data
  bool _safeBool(dynamic value, bool defaultValue) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value != 0;
    return defaultValue;
  }

  // ============================================================================
  // UI BUILDERS
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<MenuCategoryCubit, MenuCategoryState>(
        builder: (context, state) {
          if (state.menus.isEmpty) {
            return _buildEmptyState();
          }

          final displayConfig = _DisplayConfiguration.fromMenus(state.menus);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFirstRow(context, state, displayConfig),
              const SizedBox(height: _LayoutConstants.itemSpacing),
              _buildSecondRow(context, state, displayConfig),
            ],
          );
        },
      ),
    );
  }

  /// Builds the first row based on display configuration
  Widget _buildFirstRow(
    BuildContext context,
    MenuCategoryState state,
    _DisplayConfiguration config,
  ) {
    if (config.isMultipleMenus) {
      return _buildMenuRow(context, state);
    } else if (config.hasBeverages) {
      return _buildCategoryRow(context, state, false);
    } else {
      return _buildCategoryRow(context, state, null);
    }
  }

  /// Builds the second row based on display configuration
  Widget _buildSecondRow(
    BuildContext context,
    MenuCategoryState state,
    _DisplayConfiguration config,
  ) {
    if (config.isMultipleMenus) {
      return _buildCategoryRow(context, state, null);
    } else if (config.hasBeverages) {
      return _buildCategoryRow(context, state, true);
    } else {
      return const SizedBox.shrink();
    }
  }

  /// Builds the empty state when no menus are available
  Widget _buildEmptyState() {
    return Container(
      height: _LayoutConstants.rowHeight,
      alignment: Alignment.center,
      child: Text(
        _getUIText('menu_no_categories'),
        style: _TextStyles.unselected,
      ),
    );
  }

  /// Builds a horizontal row of menu buttons
  Widget _buildMenuRow(BuildContext context, MenuCategoryState state) {
    return SizedBox(
      height: _LayoutConstants.rowHeight,
      child: ListView.separated(
        controller: _menuScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: state.menus.length,
        cacheExtent: _LayoutConstants.listViewCacheExtent,
        separatorBuilder: (_, __) =>
            const SizedBox(width: _LayoutConstants.itemSpacing),
        itemBuilder: (context, index) {
          final menu = state.menus[index];
          final isSelected = menu.id == state.selectedMenuId;

          return _buildButton(
            context: context,
            text: menu.name,
            isSelected: isSelected,
            onPressed: () => _handleMenuSelection(menu),
            selectedBorder: const BorderSide(
              color: _ColorConstants.selectedColor,
              width: 1,
            ),
            unselectedBorder: BorderSide(
              color: _ColorConstants.borderColor,
              width: 1,
            ),
            buttonKey: _getOrCreateKey('menu_${menu.id}'),
          );
        },
      ),
    );
  }

  /// Handles menu button selection
  void _handleMenuSelection(Menu menu) {
    if (menu.categories.isEmpty) return;

    final firstCategory = menu.categories.first;
    final intCategoryId = firstCategory.isMultiCourse
        ? _LayoutConstants.multiCourseCategoryId
        : int.parse(firstCategory.id);

    _handleSelection(
      intCategoryId,
      int.parse(menu.id),
      _SelectionSource.userTap,
    );
  }

  /// Builds a horizontal row of category buttons
  ///
  /// Args:
  ///  isBeverage: null = all categories, true = beverages only, false = non-beverages
  Widget _buildCategoryRow(
    BuildContext context,
    MenuCategoryState state,
    bool? isBeverage,
  ) {
    final selectedMenu = state.menus.firstWhere(
      (menu) => menu.id == state.selectedMenuId,
    );

    final categories = _filterCategories(selectedMenu.categories, isBeverage);

    return SizedBox(
      height: _LayoutConstants.rowHeight,
      child: ListView.separated(
        controller: _getCategoryScrollController(isBeverage),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        cacheExtent: _LayoutConstants.listViewCacheExtent,
        separatorBuilder: (_, __) =>
            const SizedBox(width: _LayoutConstants.itemSpacing),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.id == state.selectedCategoryId;

          return _buildButton(
            context: context,
            text: category.name,
            isSelected: isSelected,
            onPressed: () => _handleCategorySelection(category, selectedMenu),
            selectedBorder: BorderSide.none,
            unselectedBorder: BorderSide(
              color: _ColorConstants.borderColor,
              width: 1,
            ),
            buttonKey: _getOrCreateKey('category_${category.id}'),
          );
        },
      ),
    );
  }

  /// Filters categories based on beverage type
  List<Category> _filterCategories(
      List<Category> categories, bool? isBeverage) {
    if (isBeverage == null) {
      return categories;
    } else if (isBeverage) {
      return categories.where((c) => c.isBeverage && !c.isMultiCourse).toList();
    } else {
      return categories.where((c) => !c.isBeverage || c.isMultiCourse).toList();
    }
  }

  /// Gets the appropriate scroll controller for category rows
  ScrollController _getCategoryScrollController(bool? isBeverage) {
    return isBeverage == true
        ? _beverageCategoryScrollController
        : _categoryScrollController;
  }

  /// Handles category button selection
  void _handleCategorySelection(Category category, Menu selectedMenu) {
    final categoryId = category.isMultiCourse
        ? _LayoutConstants.multiCourseCategoryId
        : int.parse(category.id);

    _handleSelection(
      categoryId,
      int.parse(selectedMenu.id),
      _SelectionSource.userTap,
    );
  }

  /// Builds a styled button with consistent appearance
  Widget _buildButton({
    required BuildContext context,
    required String text,
    required bool isSelected,
    required VoidCallback onPressed,
    BorderSide? selectedBorder,
    BorderSide? unselectedBorder,
    required GlobalKey buttonKey,
  }) {
    return AnimatedContainer(
      key: buttonKey,
      duration: _LayoutConstants.animationDuration,
      child: ElevatedButton(
        onPressed: onPressed,
        style: _getButtonStyle(isSelected, selectedBorder, unselectedBorder),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: isSelected ? _TextStyles.selected : _TextStyles.unselected,
          ),
        ),
      ),
    );
  }

  /// Creates button style based on selection state
  ButtonStyle _getButtonStyle(
    bool isSelected,
    BorderSide? selectedBorder,
    BorderSide? unselectedBorder,
  ) {
    return ButtonStyle(
      padding: const MaterialStatePropertyAll(
        EdgeInsets.symmetric(horizontal: _LayoutConstants.horizontalPadding),
      ),
      minimumSize:
          const MaterialStatePropertyAll(Size(0, _LayoutConstants.rowHeight)),
      elevation: const MaterialStatePropertyAll(0),
      overlayColor: const MaterialStatePropertyAll(Colors.transparent),
      backgroundColor: MaterialStatePropertyAll(
        isSelected
            ? _ColorConstants.selectedColor
            : _ColorConstants.unselectedColor,
      ),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(_LayoutConstants.buttonBorderRadius),
          side: isSelected
              ? (selectedBorder ?? BorderSide.none)
              : (unselectedBorder ?? BorderSide.none),
        ),
      ),
    );
  }
}
