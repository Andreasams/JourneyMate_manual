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

import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:collection/collection.dart';
import 'dart:ui' as ui;

/// A custom scrollable list widget that displays menu items and packages
/// organized by categories.
///
/// This widget handles: - Dynamic filtering based on dietary preferences and
/// allergies (read from FFAppState) - Automatic scrolling to selected
/// categories - Tracking and reporting the currently visible category -
/// Multi-language support via centralized translation system - Currency
/// conversion and formatting - Separate handling of regular menu items and
/// multi-course packages - Variation detection and "From" pricing display
///
/// ANALYTICS TRACKING: - Tracks menu item clicks with contextual metadata -
/// Tracks package clicks - Tracks scroll depth through categories - Updates
/// FFAppState.menuSessionData for session-level metrics
///
/// NOTE: Visible item count calculation has been moved to
/// UnifiedFiltersWidget to ensure synchronous updates when filters change.
///
/// READS FROM FFAPPSTATE: - mostRecentlyViewedBusinesMenuItems (menu data) -
/// selectedDietaryRestrictionId (filter) - selectedDietaryPreferenceId
/// (filter) - excludedAllergyIds (filter) -
/// mostRecentlyViewedBusinessSelectedMenuID (navigation) -
/// mostRecentlyViewedBusinessSelectedCategoryID (navigation) -
/// userCurrencyCode (display) - exchangeRate (display) - translationsCache
/// (localization)
class MenuDishesListView extends StatefulWidget {
  const MenuDishesListView({
    super.key,
    this.width,
    this.height,
    required this.originalCurrencyCode,
    this.onItemTap,
    this.onPackageTap,
    this.onVisibleCategoryChanged,
    this.isDynamicHeight = false,
    this.onCategoryDescriptionTap,
  });

  final double? width;
  final double? height;
  final String originalCurrencyCode;
  final Future Function(
    dynamic bottomSheetInformation,
    bool isBeverage,
    List<int>? dietaryTypeIds,
    List<int>? allergyIds,
    String formattedPrice,
    bool hasVariations,
    String? formattedVariationPrice,
  )? onItemTap;
  final Future Function(dynamic packageData)? onPackageTap;
  final Future Function(dynamic selectionData)? onVisibleCategoryChanged;
  final bool isDynamicHeight;
  final Future Function(dynamic categoryData)? onCategoryDescriptionTap;

  @override
  State<MenuDishesListView> createState() => _MenuDishesListViewState();
}

class _MenuDishesListViewState extends State<MenuDishesListView> {
  /// =========================================================================
  /// CONSTANTS - SCROLL DETECTION ZONES
  /// =========================================================================

  /// Top zone threshold for detecting headers entering viewport (scrolling down)
  static const double _scrollTopZoneStart = -0.1;
  static const double _scrollTopZoneEnd = 0.3;

  /// Bottom zone threshold for detecting headers exiting viewport (scrolling up)
  static const double _scrollBottomZoneStart = 0.7;
  static const double _scrollBottomZoneEnd = 1.1;

  /// Duration for smooth scroll animations
  static const Duration _scrollAnimationDuration = Duration(milliseconds: 500);

  /// Delay after scroll completes to reset scrolling flag
  static const Duration _scrollResetDelay = Duration(milliseconds: 600);

  /// Alignment offset for scroll positioning (slight offset from top)
  static const double _scrollNonFirstItemAlignment = -0.05;
  static const double _scrollFirstItemAlignment = 0.0;

  /// =========================================================================
  /// CONSTANTS - SPECIAL IDS
  /// =========================================================================

  /// Special category ID used for multi-course packages section
  static const int _multiCourseSectionId = -1;

  /// Default fallback for missing display orders
  static const int _defaultDisplayOrder = 999;

  /// =========================================================================
  /// CONSTANTS - TRANSLATION KEYS
  /// =========================================================================

  static const String _noDishesKey = 'menu_no_dishes';
  static const String _multiCourseSingularKey = 'menu_multi_course_singular';
  static const String _multiCoursePluralKey = 'menu_multi_course_plural';
  static const String _priceFromKey = 'price_from';
  static const String _pricePerPersonKey = 'price_per_person';

  /// =========================================================================
  /// STATE - SCROLL MANAGEMENT
  /// =========================================================================

  /// Controller for programmatic scrolling to specific items
  final ItemScrollController _itemScrollController = ItemScrollController();

  /// Listener for tracking visible item positions in viewport
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  /// Maps category IDs to their index positions in the full list
  Map<int, int> _categoryIndexMap = {};

  /// Maps list indices to {categoryId, menuId} for scroll position tracking
  Map<int, Map<String, int>> _categoryMenuMap = {};

  /// Last reported category ID to prevent redundant callbacks
  int? _lastReportedCategoryId;

  /// Last reported menu ID to prevent redundant callbacks
  int? _lastReportedMenuId;

  /// Flag to indicate if a programmatic scroll is in progress
  bool _isScrolling = false;

  /// Last category ID we scrolled to (for detecting changes from FFAppState)
  int? _lastScrolledToCategoryId;

  /// =========================================================================
  /// STATE - DATA MANAGEMENT
  /// =========================================================================

  /// Regular menu categories (not packages), sorted by display order
  List<Map<String, dynamic>> _regularCategories = [];

  /// Multi-course menu packages, sorted by display order
  List<Map<String, dynamic>> _menuPackages = [];

  /// Quick lookup map for menu items by ID
  Map<int, Map<String, dynamic>> _menuItemMap = {};

  /// Complete list of widgets to display, built from processed data
  List<Widget> _fullList = [];

  /// =========================================================================
  /// STATE - ANALYTICS TRACKING
  /// =========================================================================

  /// Tracks the deepest category index reached during manual scrolling
  int _deepestCategoryIndexReached = 0;

  /// Tracks which unique category IDs have been viewed during session
  Set<int> _viewedCategoryIds = {};

  /// Business ID extracted from menu data for analytics
  int? _businessId;

  /// Flag to prevent scroll tracking until user actually scrolls
  bool _hasUserScrolled = false;

  /// =========================================================================
  /// FFAPPSTATE ACCESSORS
  /// =========================================================================

  /// Menu data from FFAppState
  dynamic get _normalizedMenuData =>
      FFAppState().mostRecentlyViewedBusinesMenuItems;

  /// Current language code
  String get _languageCode => FFLocalizations.of(context).languageCode;

  /// Translations cache
  dynamic get _translationsCache => FFAppState().translationsCache;

  /// Selected dietary restrictions (list of IDs)
  List<int> get _selectedDietaryRestrictions =>
      FFAppState().selectedDietaryRestrictionId ?? [];

  /// Selected dietary preference (single ID, null if 0 or not set)
  int? get _selectedDietaryPreference =>
      FFAppState().selectedDietaryPreferenceId == 0
          ? null
          : FFAppState().selectedDietaryPreferenceId;

  /// Excluded allergy IDs
  List<int> get _selectedAllergies => FFAppState().excludedAllergyIds;

  /// Selected menu ID
  int get _selectedMenuId =>
      FFAppState().mostRecentlyViewedBusinessSelectedMenuID;

  /// Selected category ID
  int get _selectedCategoryId =>
      FFAppState().mostRecentlyViewedBusinessSelectedCategoryID;

  /// User's chosen currency code
  String get _chosenCurrency => FFAppState().userCurrencyCode;

  /// Exchange rate for currency conversion
  double get _exchangeRate => FFAppState().exchangeRate;

  /// =========================================================================
  /// LIFECYCLE METHODS
  /// =========================================================================

  @override
  void initState() {
    super.initState();
    _extractBusinessId();

    // Process data without triggering parent callbacks
    _extractAndSortData();
    _buildCategoryIndexMap();
    _buildCategoryMenuMap();

    _itemPositionsListener.itemPositions.addListener(_onItemPositionsChanged);

    // Initialize last scrolled category
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _lastScrolledToCategoryId = _selectedCategoryId;
    });
  }

  @override
  void didUpdateWidget(covariant MenuDishesListView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Always re-process data since filters come from FFAppState
    _processData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// =========================================================================
  /// ANALYTICS - BUSINESS ID EXTRACTION
  /// =========================================================================

  /// Extracts business_id from the first available menu item
  void _extractBusinessId() {
    try {
      if (_normalizedMenuData is Map<String, dynamic>) {
        final normalizedMap = _normalizedMenuData as Map<String, dynamic>;
        final menuItems = normalizedMap['menu_items'] as List<dynamic>? ?? [];

        if (menuItems.isNotEmpty) {
          final firstItem = menuItems.first;
          if (firstItem is Map<String, dynamic>) {
            _businessId = firstItem['business_id'] as int?;
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Failed to extract business_id: $e');
    }
  }

  /// =========================================================================
  /// ANALYTICS - TRACKING HELPERS
  /// =========================================================================

  /// Updates session data in FFAppState by incrementing item click count
  void _incrementSessionItemClicks() {
    try {
      FFAppState().update(() {
        final data = FFAppState().menuSessionData as Map<String, dynamic>;
        data['itemClicks'] = (data['itemClicks'] as int? ?? 0) + 1;
      });
    } catch (e) {
      debugPrint('⚠️ Failed to increment session item clicks: $e');
    }
  }

  /// Updates session data in FFAppState by incrementing package click count
  void _incrementSessionPackageClicks() {
    try {
      FFAppState().update(() {
        final data = FFAppState().menuSessionData as Map<String, dynamic>;
        data['packageClicks'] = (data['packageClicks'] as int? ?? 0) + 1;
      });
    } catch (e) {
      debugPrint('⚠️ Failed to increment session package clicks: $e');
    }
  }

  /// Updates session data in FFAppState by adding a viewed category
  void _addViewedCategoryToSession(int categoryId) {
    try {
      FFAppState().update(() {
        final data = FFAppState().menuSessionData as Map<String, dynamic>;
        final categories =
            List<int>.from(data['categoriesViewed'] as List? ?? []);
        if (!categories.contains(categoryId)) {
          categories.add(categoryId);
          data['categoriesViewed'] = categories;
        }
      });
    } catch (e) {
      debugPrint('⚠️ Failed to add viewed category to session: $e');
    }
  }

  /// Updates session data in FFAppState with deepest scroll percentage
  void _updateSessionScrollDepth(int scrollPercent) {
    try {
      FFAppState().update(() {
        final data = FFAppState().menuSessionData as Map<String, dynamic>;
        final current = data['deepestScrollPercent'] as int? ?? 0;
        if (scrollPercent > current) {
          data['deepestScrollPercent'] = scrollPercent;
        }
      });
    } catch (e) {
      debugPrint('⚠️ Failed to update session scroll depth: $e');
    }
  }

  /// =========================================================================
  /// ANALYTICS - EVENT TRACKING
  /// =========================================================================

  /// Tracks when a menu item is clicked
  void _trackMenuItemClick({
    required int itemId,
    required String itemName,
    required int categoryId,
    required String categoryName,
    required int categoryIndex,
    required int positionInCategory,
    required bool hasImage,
    required bool hasDescription,
    required bool hasVariations,
    required bool isBeverage,
    required double price,
  }) {
    if (_businessId == null) return;

    trackAnalyticsEvent(
      'menu_item_clicked',
      {
        'business_id': _businessId,
        'item_id': itemId,
        'item_name': itemName,
        'category_id': categoryId,
        'category_name': categoryName,
        'category_index': categoryIndex,
        'position_in_category': positionInCategory,
        'has_image': hasImage,
        'has_description': hasDescription,
        'has_variations': hasVariations,
        'is_beverage': isBeverage,
        'price_range': _getPriceRange(price),
        'language': _languageCode,
      },
    ).catchError((error) {
      debugPrint('⚠️ Failed to track menu item click: $error');
    });
  }

  /// Tracks when a package is clicked
  void _trackMenuPackageClick({
    required int packageId,
    required String packageName,
    required int position,
    required int totalPackages,
  }) {
    if (_businessId == null) return;

    trackAnalyticsEvent(
      'menu_package_clicked',
      {
        'business_id': _businessId,
        'package_id': packageId,
        'package_name': packageName,
        'package_position': position,
        'total_packages': totalPackages,
        'language': _languageCode,
      },
    ).catchError((error) {
      debugPrint('⚠️ Failed to track menu package click: $error');
    });
  }

  /// Tracks when category description modal is opened
  void _trackCategoryDescriptionView(String categoryName) {
    if (_businessId == null) return;

    trackAnalyticsEvent(
      'category_description_viewed',
      {
        'business_id': _businessId,
        'category_name': categoryName,
        'language': _languageCode,
      },
    ).catchError((error) {
      debugPrint('⚠️ Failed to track category description view: $error');
    });
  }

  /// Handles tap on category description info icon
  void _handleCategoryDescriptionTap(String categoryName, String description) {
    markUserEngaged();
    _trackCategoryDescriptionView(categoryName);

    widget.onCategoryDescriptionTap?.call({
      'categoryName': categoryName,
      'categoryDescription': description,
    });
  }

  /// Tracks scroll depth when user reaches a new deepest category
  void _trackScrollDepth() {
    if (_businessId == null) return;

    final totalCategories =
        _regularCategories.length + (_menuPackages.isNotEmpty ? 1 : 0);
    final scrollPercent = totalCategories > 0
        ? ((_deepestCategoryIndexReached / totalCategories) * 100).round()
        : 0;

    // Update session scroll depth
    _updateSessionScrollDepth(scrollPercent);

    trackAnalyticsEvent(
      'menu_scroll_depth',
      {
        'business_id': _businessId,
        'deepest_category_index': _deepestCategoryIndexReached,
        'total_categories': totalCategories,
        'scroll_depth_percent': scrollPercent,
        'language': _languageCode,
      },
    ).catchError((error) {
      debugPrint('⚠️ Failed to track scroll depth: $error');
    });
  }

  /// =========================================================================
  /// ANALYTICS - HELPER FUNCTIONS
  /// =========================================================================

  /// Converts a price to a price range bucket for analytics
  String _getPriceRange(double price) {
    final convertedPrice = price * _exchangeRate;

    if (convertedPrice < 10) return '<10';
    if (convertedPrice < 20) return '10-20';
    if (convertedPrice < 30) return '20-30';
    if (convertedPrice < 50) return '30-50';
    return '>50';
  }

  /// Gets the index of a category in the _regularCategories list
  int _getCategoryIndexInList(int categoryId) {
    for (int i = 0; i < _regularCategories.length; i++) {
      if (_getCategoryId(_regularCategories[i]) == categoryId) {
        return i + 1; // +1 to account for packages section if it exists
      }
    }
    return 0;
  }

  /// =========================================================================
  /// TRANSLATION HELPERS
  /// =========================================================================

  /// Gets localized UI text using central translation function.
  String _getUIText(String key) {
    return getTranslations(_languageCode, key, _translationsCache);
  }

  /// =========================================================================
  /// SCROLL POSITION TRACKING
  /// =========================================================================

  /// Monitors visible items and reports the dominant category to parent widget.
  ///
  /// Uses a two-zone detection system:
  /// - Top zone: Headers entering at top (scrolling down)
  /// - Bottom zone: Headers exiting at bottom (scrolling up)
  ///
  /// Top zone has priority to handle edge cases with multiple visible headers.
  ///
  /// ANALYTICS: Tracks deepest category reached and updates scroll depth
  void _onItemPositionsChanged() {
    if (!_shouldProcessPositionChange()) return;

    final positions = _itemPositionsListener.itemPositions.value;

    // Track deepest category for scroll depth analytics
    if (!_isScrolling) {
      _updateDeepestCategoryReached(positions);
    }

    /// Check top zone first (priority for headers entering)
    if (_handleTopZoneHeaders(positions)) return;

    /// Check bottom zone (headers exiting when scrolling up)
    _handleBottomZoneHeaders(positions);
  }

  /// Updates the deepest category index reached during manual scrolling
  void _updateDeepestCategoryReached(Iterable<ItemPosition> positions) {
    // Mark that user has scrolled if positions indicate movement
    if (!_hasUserScrolled && _detectScrollMovement(positions)) {
      _hasUserScrolled = true;
    }

    // Guard: don't track until user has actually scrolled
    if (!_hasUserScrolled) return;

    int maxCategoryIndex = 0;

    for (final position in positions) {
      if (_isHeaderWidget(position.index)) {
        final categoryData = _categoryMenuMap[position.index];
        if (categoryData != null) {
          final categoryId = categoryData['categoryId']!;

          // Track unique categories viewed
          if (!_viewedCategoryIds.contains(categoryId)) {
            _viewedCategoryIds.add(categoryId);
            _addViewedCategoryToSession(categoryId);
          }

          // Calculate category index (0 for packages, 1+ for regular categories)
          final categoryIndex = categoryId == _multiCourseSectionId
              ? 0
              : _getCategoryIndexInList(categoryId);

          if (categoryIndex > maxCategoryIndex) {
            maxCategoryIndex = categoryIndex;
          }
        }
      }
    }

    // If we've reached a new deepest point, update and track
    if (maxCategoryIndex > _deepestCategoryIndexReached) {
      _deepestCategoryIndexReached = maxCategoryIndex;
      _trackScrollDepth();
    }
  }

  /// Detects if user has actually scrolled vs initial render positions
  ///
  /// Returns true if any item position indicates the list has moved from
  /// its initial state (not all items perfectly at top)
  bool _detectScrollMovement(Iterable<ItemPosition> positions) {
    // Check if we have any position data
    if (positions.isEmpty) return false;

    // If the first visible item is not index 0, user has scrolled
    final firstPosition = positions.first;
    if (firstPosition.index > 0) return true;

    // If first item's leading edge is negative, user has scrolled down
    // (header has moved above viewport)
    if (firstPosition.itemLeadingEdge < -0.01) return true;

    return false;
  }

  /// Determines if position changes should be processed
  bool _shouldProcessPositionChange() {
    final positions = _itemPositionsListener.itemPositions.value;
    return positions.isNotEmpty && widget.onVisibleCategoryChanged != null;
  }

  /// Handles header detection in top zone, returns true if handled
  bool _handleTopZoneHeaders(Iterable<ItemPosition> positions) {
    final topHeaders = _extractVisibleHeadersInTopZone(positions);

    if (topHeaders.isEmpty) return false;

    final dominantHeader = _findTopmost(topHeaders);
    final categoryMenuData = _categoryMenuMap[dominantHeader.index];

    if (categoryMenuData != null) {
      _reportCategoryChangeIfNeeded(categoryMenuData);
      return true;
    }

    return false;
  }

  /// Handles header detection in bottom zone
  void _handleBottomZoneHeaders(Iterable<ItemPosition> positions) {
    final bottomHeaders = _extractVisibleHeadersInBottomZone(positions);

    if (bottomHeaders.isEmpty) return;

    final exitingHeader = _findBottommost(bottomHeaders);
    final categoryAbove = _findCategoryAbove(exitingHeader.index);

    if (categoryAbove != null) {
      _reportCategoryChangeIfNeeded(categoryAbove);
    }
  }

  /// Extracts category headers visible in the top detection zone.
  ///
  /// Top zone triggers when a new category header comes into view from top.
  List<ItemPosition> _extractVisibleHeadersInTopZone(
      Iterable<ItemPosition> positions) {
    return positions.where((position) {
      return _isInTopZone(position) && _isHeaderWidget(position.index);
    }).toList();
  }

  /// Checks if position is within top detection zone
  bool _isInTopZone(ItemPosition position) {
    return position.itemLeadingEdge >= _scrollTopZoneStart &&
        position.itemLeadingEdge <= _scrollTopZoneEnd;
  }

  /// Extracts category headers visible in the bottom detection zone.
  ///
  /// Bottom zone triggers when scrolling up and a header exits viewport.
  List<ItemPosition> _extractVisibleHeadersInBottomZone(
      Iterable<ItemPosition> positions) {
    return positions.where((position) {
      return _isInBottomZone(position) && _isHeaderWidget(position.index);
    }).toList();
  }

  /// Checks if position is within bottom detection zone
  bool _isInBottomZone(ItemPosition position) {
    return position.itemLeadingEdge >= _scrollBottomZoneStart &&
        position.itemLeadingEdge <= _scrollBottomZoneEnd;
  }

  /// Checks if widget at index is a category header
  bool _isHeaderWidget(int index) {
    return index < _fullList.length && _fullList[index] is _CategoryHeader;
  }

  /// Finds the topmost header (closest to top of viewport).
  ///
  /// Used for top zone detection to find the dominant entering header.
  ItemPosition _findTopmost(List<ItemPosition> headers) {
    return headers
        .reduce((a, b) => a.itemLeadingEdge < b.itemLeadingEdge ? a : b);
  }

  /// Finds the bottommost header (closest to bottom of viewport).
  ///
  /// Used for bottom zone detection to find the exiting header.
  ItemPosition _findBottommost(List<ItemPosition> headers) {
    return headers
        .reduce((a, b) => a.itemLeadingEdge > b.itemLeadingEdge ? a : b);
  }

  /// Finds the category data for the header above an exiting header.
  ///
  /// When a header exits the bottom (scrolling up), switch to category above.
  /// Walks backwards through category map to find previous header's data.
  Map<String, int>? _findCategoryAbove(int exitingHeaderIndex) {
    if (_categoryMenuMap.isEmpty || exitingHeaderIndex <= 0) {
      return null;
    }

    /// Walk backwards from exiting header to find previous category
    for (int i = exitingHeaderIndex - 1; i >= 0; i--) {
      final categoryData = _categoryMenuMap[i];
      if (categoryData != null) {
        return categoryData;
      }
    }

    return null;
  }

  /// Reports category/menu change to parent if values have changed.
  ///
  /// Only fires callback if category ID or menu ID differs from last reported.
  void _reportCategoryChangeIfNeeded(Map<String, int> categoryMenuData) {
    final categoryId = categoryMenuData['categoryId']!;
    final menuId = categoryMenuData['menuId']!;

    if (_hasReportedValuesChanged(categoryId, menuId)) {
      _updateLastReportedValues(categoryId, menuId);
      _invokeVisibleCategoryCallback(categoryId, menuId);
    }
  }

  /// Checks if reported values differ from last reported
  bool _hasReportedValuesChanged(int categoryId, int menuId) {
    return categoryId != _lastReportedCategoryId ||
        menuId != _lastReportedMenuId;
  }

  /// Updates the last reported category and menu IDs
  void _updateLastReportedValues(int categoryId, int menuId) {
    _lastReportedCategoryId = categoryId;
    _lastReportedMenuId = menuId;
  }

  /// Invokes the visible category changed callback
  void _invokeVisibleCategoryCallback(int categoryId, int menuId) {
    final selectionData = {
      'categoryId': categoryId,
      'menuId': menuId,
    };
    widget.onVisibleCategoryChanged?.call(selectionData);
  }

  /// =========================================================================
  /// DATA PROCESSING PIPELINE
  /// =========================================================================

  /// Main data processing pipeline: extract, sort, and index.
  ///
  /// Orchestrates the complete data preparation workflow.
  /// Called whenever source data or filters change.
  void _processData() {
    _extractAndSortData();
    _buildCategoryIndexMap();
    _buildCategoryMenuMap();
  }

  /// Extracts and sorts categories and packages from normalized menu data.
  ///
  /// Separates regular categories from packages, sorts by display order,
  /// and builds a quick-lookup map for menu items.
  void _extractAndSortData() {
    try {
      if (!_isValidNormalizedData()) {
        _clearDataStructures();
        return;
      }

      final normalizedMap = _normalizedMenuData as Map<String, dynamic>;

      _buildMenuItemMap(normalizedMap);
      _extractAndSortCategories(normalizedMap);
      _extractAndSortPackages(normalizedMap);
    } catch (e) {
      _clearDataStructures();
    }
  }

  /// Validates that normalized data is a proper Map
  bool _isValidNormalizedData() {
    return _normalizedMenuData is Map<String, dynamic>;
  }

  /// Clears all data structures to empty state
  void _clearDataStructures() {
    _regularCategories = [];
    _menuPackages = [];
    _menuItemMap = {};
  }

  /// Builds a map of menu items keyed by menu_item_id for quick lookup
  void _buildMenuItemMap(Map<String, dynamic> normalizedMap) {
    final menuItems = normalizedMap['menu_items'] as List<dynamic>? ?? [];
    _menuItemMap = Map.fromEntries(
      menuItems.whereType<Map<String, dynamic>>().map(
            (item) => MapEntry(item['menu_item_id'] as int, item),
          ),
    );
  }

  /// Extracts and sorts regular (non-package) categories
  void _extractAndSortCategories(Map<String, dynamic> normalizedMap) {
    final categories = normalizedMap['categories'] as List<dynamic>? ?? [];
    final allCategories = categories.whereType<Map<String, dynamic>>().toList();

    _regularCategories = allCategories
        .where((cat) => cat['category_type'] != 'menu_package')
        .toList()
      ..sort(_compareByMenuAndDisplayOrder);
  }

  /// Extracts and sorts menu packages
  void _extractAndSortPackages(Map<String, dynamic> normalizedMap) {
    final categories = normalizedMap['categories'] as List<dynamic>? ?? [];
    final allCategories = categories.whereType<Map<String, dynamic>>().toList();

    _menuPackages = allCategories
        .where((cat) => cat['category_type'] == 'menu_package')
        .toList()
      ..sort(_compareByMenuAndDisplayOrder);
  }

  /// Comparator function for sorting by menu order, then display order.
  ///
  /// Ensures consistent ordering first by menu_display_order,
  /// then by display_order within each menu.
  int _compareByMenuAndDisplayOrder(
      Map<String, dynamic> a, Map<String, dynamic> b) {
    final menuOrderA = a['menu_display_order'] as int? ?? _defaultDisplayOrder;
    final menuOrderB = b['menu_display_order'] as int? ?? _defaultDisplayOrder;

    if (menuOrderA != menuOrderB) {
      return menuOrderA.compareTo(menuOrderB);
    }

    final orderA = a['display_order'] as int? ?? _defaultDisplayOrder;
    final orderB = b['display_order'] as int? ?? _defaultDisplayOrder;
    return orderA.compareTo(orderB);
  }

  /// =========================================================================
  /// INDEX MAP BUILDING
  /// =========================================================================

  /// Builds a map from category ID to list index for scroll positioning.
  ///
  /// Enables jumping to specific categories by translating category IDs
  /// into indices in the _fullList.
  void _buildCategoryIndexMap() {
    _categoryIndexMap = {};
    int index = 0;

    index = _indexPackagesSection(index);
    _indexRegularCategories(index);
  }

  /// Indexes packages section, returns next available index
  int _indexPackagesSection(int startIndex) {
    if (_menuPackages.isEmpty) return startIndex;

    int index = startIndex;
    index++; // For multi-course header

    for (final package in _menuPackages) {
      final packageId = package['category_id'] as int?;
      if (packageId != null) {
        _categoryIndexMap[packageId] = index;
        index++; // For the package item
      }
    }

    return index;
  }

  /// Indexes regular categories
  void _indexRegularCategories(int startIndex) {
    int index = startIndex;

    for (final category in _regularCategories) {
      final categoryId = _getCategoryId(category);
      if (categoryId == null) continue;

      _categoryIndexMap[categoryId] = index;
      index++; // For the category header

      final visibleItems = _getVisibleItemsForCategory(category);
      index += visibleItems.isEmpty ? 1 : visibleItems.length;
    }
  }

  /// Builds a map from list index to {categoryId, menuId} for tracking.
  ///
  /// Maps header indices to their category/menu IDs for determining
  /// which category is currently visible during scrolling.
  void _buildCategoryMenuMap() {
    _categoryMenuMap = {};
    int index = 0;

    index = _mapMultiCourseHeader(index);
    _mapRegularCategoryHeaders(index);
  }

  /// Maps multi-course header (if packages exist), returns next index
  int _mapMultiCourseHeader(int startIndex) {
    if (_menuPackages.isEmpty) return startIndex;

    final firstPackageMenuId = _getMenuId(_menuPackages.first);
    if (firstPackageMenuId != null) {
      _categoryMenuMap[startIndex] = {
        'categoryId': _multiCourseSectionId,
        'menuId': firstPackageMenuId,
      };
    }

    int index = startIndex;
    index++; // Move past header
    index += _menuPackages.length; // Skip package items

    return index;
  }

  /// Maps regular category headers
  void _mapRegularCategoryHeaders(int startIndex) {
    int index = startIndex;

    for (final category in _regularCategories) {
      final categoryId = _getCategoryId(category);
      final menuId = _getMenuId(category);

      if (categoryId != null && menuId != null) {
        _categoryMenuMap[index] = {
          'categoryId': categoryId,
          'menuId': menuId,
        };
      }

      index++; // Move past header

      /// Skip items in this category
      final visibleItems = _getVisibleItemsForCategory(category);
      index += visibleItems.isEmpty ? 1 : visibleItems.length;
    }
  }

  /// =========================================================================
  /// FILTERING & VISIBILITY LOGIC
  /// =========================================================================

  /// Returns items in a category that match current filter criteria.
  ///
  /// For 'a la carte' categories, filters items based on dietary preferences
  /// and allergy exclusions. Returns empty list for other category types.
  List<Map<String, dynamic>> _getVisibleItemsForCategory(
      Map<String, dynamic> category) {
    if (category['category_type'] != 'a la carte') {
      return [];
    }

    final itemIds = category['menu_item_ids'] as List<dynamic>? ?? [];
    final categoryItems = itemIds
        .whereType<int>()
        .map((itemId) => _menuItemMap[itemId])
        .whereNotNull()
        .toList();

    return categoryItems.where(_isItemVisible).toList();
  }

  /// Determines if an item should be visible based on current filters.
  ///
  /// Returns false if:
  /// - Dietary preference is selected and item doesn't have it
  /// - Item contains any of the user's excluded allergies
  bool _isItemVisible(Map<String, dynamic> item) {
    return _passesAllFilters(item);
  }

  /// Checks if item passes all active filters
  bool _passesAllFilters(Map<String, dynamic> item) {
    // Item must pass dietary filter (via either IS or CAN BE MADE)
    if (!_passesDietaryFilter(item)) {
      return false;
    }

    // Check if item qualifies for allergen override
    if (_qualifiesForAllergenOverride(item)) {
      return true; // Show item despite allergens
    }

    // Apply normal allergen filtering
    return _passesAllergyFilter(item);
  }

  /// Checks if a dietary ID is valid (not null and not 0)
  bool _isValidDietaryId(int? dietaryId) {
    return dietaryId != null && dietaryId != 0;
  }

  /// Checks if item passes dietary filters (both restrictions and preference)
  ///
  /// An item must satisfy ALL filters if active:
  /// - ALL active restrictions must be present on the item
  /// - If preference selected: item must have that preference
  bool _passesDietaryFilter(Map<String, dynamic> item) {
    final itemDietaryTypes = _extractIntList(item, 'dietary_type_ids');
    final itemCanBeMadeTypes =
        _extractIntList(item, 'dietary_type_can_be_made_ids');

    // Check ALL active restrictions (must have ALL of them via EITHER array)
    for (final restrictionId in _selectedDietaryRestrictions) {
      if (_isValidDietaryId(restrictionId)) {
        final hasInherently = itemDietaryTypes.contains(restrictionId);
        final canBeMade = itemCanBeMadeTypes.contains(restrictionId);

        if (!hasInherently && !canBeMade) {
          return false; // Item missing this restriction entirely
        }
      }
    }

    // Check preference filter (only if valid ID: not null and not 0)
    if (_isValidDietaryId(_selectedDietaryPreference)) {
      final hasInherently =
          itemDietaryTypes.contains(_selectedDietaryPreference);
      final canBeMade = itemCanBeMadeTypes.contains(_selectedDietaryPreference);

      if (!hasInherently && !canBeMade) {
        return false;
      }
    }

    return true;
  }

  bool _qualifiesForAllergenOverride(Map<String, dynamic> item) {
    final itemCanBeMadeTypes =
        _extractIntList(item, 'dietary_type_can_be_made_ids');

    // Check if ANY active restriction is in can-be-made array
    for (final restrictionId in _selectedDietaryRestrictions) {
      if (_isValidDietaryId(restrictionId)) {
        if (itemCanBeMadeTypes.contains(restrictionId)) {
          return true; // Allergen override applies
        }
      }
    }

    // Check if preference is in can-be-made array
    if (_isValidDietaryId(_selectedDietaryPreference)) {
      if (itemCanBeMadeTypes.contains(_selectedDietaryPreference)) {
        return true; // Allergen override applies
      }
    }

    return false; // No override, apply normal allergen filtering
  }

  /// Checks if item passes allergy exclusion filter
  bool _passesAllergyFilter(Map<String, dynamic> item) {
    if (_selectedAllergies.isEmpty) {
      return true;
    }

    final itemAllergies = _extractIntList(item, 'allergy_ids');
    final excludedSet = Set<int>.from(_selectedAllergies);

    return !itemAllergies.any((allergyId) => excludedSet.contains(allergyId));
  }

  /// Safely extracts a list of integers from a map
  List<int> _extractIntList(Map<String, dynamic> map, String key) {
    final value = map[key];
    return value is List ? value.whereType<int>().toList() : [];
  }

  /// =========================================================================
  /// SCROLL CONTROL
  /// =========================================================================

  /// Scrolls to the specified category with animation.
  ///
  /// Handles special case of multi-course section (categoryId = -1).
  /// Uses _categoryIndexMap to find target index and scrolls smoothly.
  void _scrollToCategory(int categoryId) {
    _isScrolling = true;

    if (_isMultiCourseSection(categoryId)) {
      _scrollToMultiCourseSection();
      return;
    }

    _scrollToRegularCategory(categoryId);
  }

  /// Checks if category ID represents multi-course section
  bool _isMultiCourseSection(int categoryId) {
    return categoryId == _multiCourseSectionId && _menuPackages.isNotEmpty;
  }

  /// Scrolls to multi-course packages section
  void _scrollToMultiCourseSection() {
    _scrollToIndex(0, isFirstItem: true);
  }

  /// Scrolls to a regular category by ID
  void _scrollToRegularCategory(int categoryId) {
    if (_shouldRebuildIndexMap()) {
      _buildCategoryIndexMap();
    }

    final index = _categoryIndexMap[categoryId];
    if (index != null) {
      _scrollToIndex(index, isFirstItem: index == 0);
    } else {
      _isScrolling = false;
    }
  }

  /// Checks if index map needs rebuilding
  bool _shouldRebuildIndexMap() {
    return _categoryIndexMap.isEmpty &&
        (_regularCategories.isNotEmpty || _menuPackages.isNotEmpty);
  }

  /// Calculates scroll alignment based on height type
  double _getScrollAlignment({required bool isFirstItem}) {
    if (isFirstItem) {
      return _scrollFirstItemAlignment;
    }

    // Use dynamic calculation for dynamic heights
    if (widget.isDynamicHeight) {
      final viewportHeight =
          widget.height ?? MediaQuery.of(context).size.height;
      // Small 8px buffer from top, converted to viewport fraction
      return -6.0 / viewportHeight;
    }

    // Use proven static value for fixed heights
    return _scrollNonFirstItemAlignment;
  }

  /// Performs the actual scroll animation to a specific index
  void _scrollToIndex(int index, {required bool isFirstItem}) {
    _itemScrollController.scrollTo(
      index: index,
      duration: _scrollAnimationDuration,
      curve: Curves.easeInOut,
      alignment: _getScrollAlignment(isFirstItem: isFirstItem),
    );

    _scheduleScrollResetFlag();
  }

  /// Schedules reset of scrolling flag after animation completes
  void _scheduleScrollResetFlag() {
    Future.delayed(_scrollResetDelay, () {
      _isScrolling = false;
    });
  }

  /// =========================================================================
  /// DATA ACCESSORS
  /// =========================================================================

  /// Extracts category ID from category map
  int? _getCategoryId(Map<String, dynamic> category) {
    return category['category_id'] as int?;
  }

  /// Extracts menu ID from category map
  int? _getMenuId(Map<String, dynamic> category) {
    return category['menu_id'] as int?;
  }

  /// Gets display name for category based on type
  String _getCategoryName(Map<String, dynamic> category) {
    if (category['category_type'] == 'menu_package') {
      return category['package_name'] ?? 'Unnamed Package';
    } else if (category['category_type'] == 'a la carte') {
      return category['category_name'] ?? 'Unnamed Category';
    }
    return 'Unnamed Category';
  }

  /// Gets description for category (returns null if empty or missing)
  String? _getCategoryDescription(Map<String, dynamic> category) {
    final description = category['category_description'] as String?;

    // Return null for empty or whitespace-only descriptions
    if (description == null || description.trim().isEmpty) {
      return null;
    }

    return description.trim();
  }

  /// =========================================================================
  /// LOCALIZATION HELPERS
  /// =========================================================================

  /// Gets localized "no dishes" message for current language
  String _getNoDishesMessage() {
    return _getUIText(_noDishesKey);
  }

  /// Gets localized multi-course header (singular or plural)
  String _getMultiCourseHeader() {
    final key = _menuPackages.length == 1
        ? _multiCourseSingularKey
        : _multiCoursePluralKey;
    return _getUIText(key);
  }

  /// =========================================================================
  /// UI BUILDING - MAIN LIST CONSTRUCTION
  /// =========================================================================

  /// Builds the complete list of widgets to display.
  ///
  /// Constructs widgets in order:
  /// 1. Multi-course header (if packages exist)
  /// 2. All package items
  /// 3. For each regular category:
  ///    - Category header
  ///    - Items (or "no dishes" message if empty after filtering)
  List<Widget> _buildFullList() {
    final fullList = <Widget>[];

    _addPackageSectionIfNeeded(fullList);
    _addRegularCategories(fullList);

    return fullList;
  }

  /// Adds multi-course packages section to the list if any exist
  void _addPackageSectionIfNeeded(List<Widget> fullList) {
    if (_menuPackages.isEmpty) return;

    /// Single header for all packages (no description for multi-course section)
    fullList.add(_CategoryHeader(
      categoryName: _getMultiCourseHeader(),
      categoryDescription: null, // No description for packages section
      isFirst: true,
      onInfoTap: null, // No callback for packages section
    ));

    /// Add all package items with position tracking
    for (int i = 0; i < _menuPackages.length; i++) {
      fullList.add(_buildPackageMenuItem(_menuPackages[i], i));
    }
  }

  /// Builds a menu item widget for a package with analytics tracking
  Widget _buildPackageMenuItem(Map<String, dynamic> package, int position) {
    return _MenuItem(
      item: package,
      onItemTap: null,
      onPackageTap: (packageData) async {
        // Mark user engaged
        markUserEngaged();

        // Update session clicks
        _incrementSessionPackageClicks();

        // Track package click
        _trackMenuPackageClick(
          packageId: packageData['package_id'] as int? ?? 0,
          packageName: packageData['package_name'] as String? ?? '',
          position: position + 1,
          totalPackages: _menuPackages.length,
        );

        // Call original callback
        return widget.onPackageTap?.call(packageData);
      },
      chosenCurrency: _chosenCurrency,
      originalCurrencyCode: widget.originalCurrencyCode,
      exchangeRate: _exchangeRate,
      languageCode: _languageCode,
      translationsCache: _translationsCache,
    );
  }

  /// Adds all regular category sections to the list
  void _addRegularCategories(List<Widget> fullList) {
    for (int catIndex = 0; catIndex < _regularCategories.length; catIndex++) {
      final category = _regularCategories[catIndex];
      final categoryId = _getCategoryId(category);
      if (categoryId == null) continue;

      _addCategorySection(fullList, category, catIndex);
    }
  }

  /// Adds a complete category section (header + items) with position tracking
  void _addCategorySection(
    List<Widget> fullList,
    Map<String, dynamic> category,
    int categoryIndex,
  ) {
    /// Extract category data including description
    final categoryName = _getCategoryName(category);
    final categoryDescription = _getCategoryDescription(category);
    final categoryId = _getCategoryId(category);

    if (categoryId == null) return;

    /// Add category header with description and tap handler
    fullList.add(_CategoryHeader(
      categoryName: categoryName,
      categoryDescription: categoryDescription,
      isFirst: fullList.isEmpty,
      onInfoTap: categoryDescription != null && categoryDescription.isNotEmpty
          ? () =>
              _handleCategoryDescriptionTap(categoryName, categoryDescription)
          : null,
    ));

    /// Add items or "no dishes" message
    final visibleItems = _getVisibleItemsForCategory(category);
    if (visibleItems.isEmpty) {
      fullList.add(_NoDishesMessage(
        message: _getNoDishesMessage(),
      ));
    } else {
      _addCategoryItems(fullList, visibleItems, category, categoryIndex);
    }
  }

  /// Adds individual items for a category to the list with analytics tracking
  void _addCategoryItems(
    List<Widget> fullList,
    List<Map<String, dynamic>> items,
    Map<String, dynamic> category,
    int categoryIndex,
  ) {
    final categoryId = _getCategoryId(category);
    final categoryName = _getCategoryName(category);

    for (int i = 0; i < items.length; i++) {
      fullList.add(_buildRegularMenuItem(
        items[i],
        categoryId ?? 0,
        categoryName,
        categoryIndex,
        i + 1, // Position is 1-indexed
      ));
    }
  }

  /// Builds a menu item widget for a regular item with analytics tracking
  Widget _buildRegularMenuItem(
    Map<String, dynamic> item,
    int categoryId,
    String categoryName,
    int categoryIndex,
    int positionInCategory,
  ) {
    return _MenuItem(
      item: item,
      onItemTap: (
        bottomSheetInfo,
        isBeverage,
        dietaryTypeIds,
        allergyIds,
        formattedPrice,
        hasVariations,
        formattedVariationPrice,
      ) async {
        // Mark user engaged
        markUserEngaged();

        // Update session clicks
        _incrementSessionItemClicks();

        // Track menu item click
        _trackMenuItemClick(
          itemId: item['menu_item_id'] as int? ?? 0,
          itemName: item['item_name'] as String? ?? '',
          categoryId: categoryId,
          categoryName: categoryName,
          categoryIndex: categoryIndex + 1, // +1 for packages section
          positionInCategory: positionInCategory,
          hasImage: (item['item_image_url'] as String?)?.isNotEmpty ?? false,
          hasDescription:
              (item['item_description'] as String?)?.isNotEmpty ?? false,
          hasVariations: hasVariations,
          isBeverage: isBeverage,
          price: (item['base_price'] as num?)?.toDouble() ?? 0.0,
        );

        // Call original callback
        return widget.onItemTap?.call(
          bottomSheetInfo,
          isBeverage,
          dietaryTypeIds,
          allergyIds,
          formattedPrice,
          hasVariations,
          formattedVariationPrice,
        );
      },
      onPackageTap: null,
      chosenCurrency: _chosenCurrency,
      originalCurrencyCode: widget.originalCurrencyCode,
      exchangeRate: _exchangeRate,
      languageCode: _languageCode,
      translationsCache: _translationsCache,
    );
  }

  /// =========================================================================
  /// BUILD METHOD
  /// =========================================================================

  @override
  Widget build(BuildContext context) {
    _fullList = _buildFullList();

    // Check if we need to scroll to a new category (detected via FFAppState)
    final currentCategoryId = _selectedCategoryId;
    if (currentCategoryId != _lastScrolledToCategoryId) {
      _lastScrolledToCategoryId = currentCategoryId;
      // Schedule scroll after build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToCategory(currentCategoryId);
        }
      });
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ScrollablePositionedList.builder(
        itemCount: _fullList.length,
        itemBuilder: (context, index) => _fullList[index],
        itemScrollController: _itemScrollController,
        itemPositionsListener: _itemPositionsListener,
      ),
    );
  }
}

// ==============================================================================
// HELPER WIDGETS
// ==============================================================================

/// Displays a single menu item or package in the list.
///
/// This widget handles rendering for both regular menu items and multi-course
/// packages, adapting its layout based on the item type and available data
/// (description, image, etc.). It supports tap callbacks for both item types.
///
/// Handles variation pricing logic:
/// - Items with variations show "From [price]" when multiple options exist
/// - Calculates minimum price from variation options when base_price is 0
/// - Shows base price without "From" when no variations exist
///
/// Layout adapts to:
/// - Presence/absence of description text
/// - Presence/absence of item image
/// - Item type (beverage vs. food)
/// - Title length
class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.item,
    required this.chosenCurrency,
    required this.originalCurrencyCode,
    required this.exchangeRate,
    required this.languageCode,
    required this.translationsCache,
    this.onItemTap,
    this.onPackageTap,
  });

  final dynamic item;
  final String chosenCurrency;
  final String originalCurrencyCode;
  final double exchangeRate;
  final String languageCode;
  final dynamic translationsCache;
  final Future Function(
    dynamic bottomSheetInformation,
    bool isBeverage,
    List<int>? dietaryTypeIds,
    List<int>? allergyIds,
    String formattedPrice,
    bool hasVariations,
    String? formattedVariationPrice,
  )? onItemTap;
  final Future Function(dynamic packageData)? onPackageTap;

  /// =========================================================================
  /// CONSTANTS - LAYOUT & STYLING
  /// =========================================================================

  /// Padding between item content sections
  static const double _verticalPadding = 8.0;
  static const double _horizontalImagePadding = 8.0;

  /// Spacing between title and description
  static const double _titleDescriptionSpacing = 2.0;

  /// Spacing between description and price (standard)
  static const double _descriptionPriceSpacingStandard = 4.0;

  /// Spacing between description and price (compact)
  static const double _descriptionPriceSpacingCompact = 2.0;

  /// Image dimensions
  static const double _itemImageWidth = 133.0;
  static const double _itemImageHeight = 75.0;
  static const double _itemImageBorderRadius = 4.0;

  /// Title text styling
  static const double _titleFontSize = 16.0;
  static const FontWeight _titleFontWeight = FontWeight.w400;
  static const int _titleMaxLinesSingle = 1;
  static const int _titleMaxLinesDouble = 2;

  /// Description text styling
  static const double _descriptionFontSize = 14.0;
  static const FontWeight _descriptionFontWeight = FontWeight.w300;
  static const int _descriptionMaxLines = 2;

  /// Price text styling
  static const double _priceFontSize = 14.0;
  static const FontWeight _priceFontWeight = FontWeight.w400;
  static const Color _priceColor = Color(0xFFEE8B60);

  /// Divider styling
  static const double _dividerHeight = 1.0;
  static const double _dividerThickness = 1.0;
  static const double _dividerOpacity = 0.7;

  /// Title length threshold for layout decisions
  static const int _longTitleThreshold = 45;

  /// Translation keys
  static const String _priceFromKey = 'price_from';
  static const String _pricePerPersonKey = 'price_per_person';

  /// =========================================================================
  /// TRANSLATION HELPERS
  /// =========================================================================

  /// Gets localized UI text using central translation function
  String _getUIText(String key) {
    return getTranslations(languageCode, key, translationsCache);
  }

  /// Gets the localized "From" prefix for the current language
  String _getFromPrefix() {
    return _getUIText(_priceFromKey);
  }

  /// Gets the localized "per person" suffix for the current language
  String _getPerPersonSuffix() {
    return _getUIText(_pricePerPersonKey);
  }

  /// =========================================================================
  /// DATA EXTRACTION HELPERS
  /// =========================================================================

  /// Safely extracts a string value from item map
  String _getString(String key, [String defaultValue = '']) {
    if (item is! Map) return defaultValue;

    final value = item[key] ??
        (key == 'item_name' ? item['package_name'] : null) ??
        (key == 'item_description' ? item['package_description'] : null) ??
        (key == 'item_image_url' ? item['package_image_url'] : null);

    return (value is String && value.isNotEmpty) ? value : defaultValue;
  }

  /// Safely extracts a boolean value from item map
  bool _getBool(String key, [bool defaultValue = false]) {
    final value = item is Map ? item[key] : null;
    return value is bool ? value : defaultValue;
  }

  /// Safely extracts a list of integers from item map
  List<int> _getIntList(String key) {
    final value = item is Map ? item[key] : null;
    return value is List ? value.whereType<int>().toList() : [];
  }

  /// Safely extracts a double value from item map
  double _getDouble(String key, [double defaultValue = 0.0]) {
    if (item is! Map) return defaultValue;
    final value = item[key];
    return value is num ? value.toDouble() : defaultValue;
  }

  /// Checks if item is a package (vs regular menu item)
  bool _isPackage() {
    return item is Map && item['category_type'] == 'menu_package';
  }

  /// =========================================================================
  /// VARIATION DETECTION & PRICING LOGIC
  /// =========================================================================

  /// Checks if the item has variation-type modifier groups.
  ///
  /// Variations represent mutually exclusive options (like "Bacon", "Halloumi",
  /// or "Salmon" for Eggs Benedict) as opposed to add-ons which augment an item.
  bool _hasVariations() {
    final modifierGroups = item is Map ? item['item_modifier_groups'] : null;
    if (modifierGroups is! List) return false;

    return modifierGroups.any((group) {
      return group is Map && group['type'] == 'Variation';
    });
  }

  /// Finds the minimum price among all variation options.
  ///
  /// Scans all variation-type modifier groups and returns the lowest
  /// add_on_price found. Used when base_price is 0 and customer must
  /// choose a variation.
  double _getMinimumVariationPrice() {
    final modifierGroups = item is Map ? item['item_modifier_groups'] : null;
    if (modifierGroups is! List) return 0.0;

    double minPrice = double.infinity;

    for (final group in modifierGroups) {
      if (!_isValidVariationGroup(group)) continue;

      minPrice = _findMinPriceInGroup(group, minPrice);
    }

    return minPrice == double.infinity ? 0.0 : minPrice;
  }

  /// Checks if modifier group is a valid variation group
  bool _isValidVariationGroup(dynamic group) {
    return group is Map && group['type'] == 'Variation';
  }

  /// Finds minimum price within a modifier group
  double _findMinPriceInGroup(Map group, double currentMin) {
    final modifiers = group['modifiers'] as List?;
    if (modifiers == null) return currentMin;

    double minPrice = currentMin;

    for (final modifier in modifiers) {
      if (modifier is! Map) continue;
      final price = modifier['price'];
      if (price is num && price > 0 && price < minPrice) {
        minPrice = price.toDouble();
      }
    }

    return minPrice;
  }

  /// Calculates the effective price to display for this item.
  ///
  /// Pricing logic:
  /// - Has variations + base_price = 0: Use minimum variation price
  /// - Has variations + base_price > 0: Use minimum of base or variation prices
  /// - No variations: Use base_price + premium_upcharge
  double _getEffectivePrice() {
    final basePrice = _getDouble('base_price', 0.0);
    final premiumUpcharge = _getDouble('premium_upcharge', 0.0);

    if (_hasVariations()) {
      return _calculateVariationPrice(basePrice);
    }

    return basePrice + premiumUpcharge;
  }

  /// Calculates price when variations exist
  double _calculateVariationPrice(double basePrice) {
    final variationMin = _getMinimumVariationPrice();

    if (basePrice > 0) {
      return basePrice < variationMin ? basePrice : variationMin;
    }

    return variationMin;
  }

  /// Determines if the "From" prefix should be shown before the price.
  ///
  /// The prefix indicates variable pricing due to customer choice.
  ///
  /// Rules:
  /// - Show "From" only when variations exist AND effective price > 0
  /// - Don't show "From" for items without variations (fixed pricing)
  /// - Don't show "From" when price is 0 (placeholder pricing)
  bool _shouldShowFromPrefix() {
    return _hasVariations() && _getEffectivePrice() > 0;
  }

  /// Helper method to detect zero prices in any currency format
  bool _isZeroPrice(String price) {
    if (price.isEmpty) return true;
    final trimmed = price.trim();

    // Handle common zero patterns
    if (trimmed == '0') return true;

    // Prefix currencies: €0, €0.00, £0, £0.0, $0, $0.00, ¥0
    if (RegExp(r'^[€£\$¥]\s*0(?:[.,]0+)?$').hasMatch(trimmed)) {
      return true;
    }

    // Suffix currencies: 0 kr., 0 zł, 0 ₩, 0 ₴
    if (RegExp(r'^0(?:[.,]0+)?\s*(?:kr\.|zł|₩|₴)$').hasMatch(trimmed)) {
      return true;
    }

    return false;
  }

  /// =========================================================================
  /// LAYOUT DECISION HELPERS
  /// =========================================================================

  /// Determines the maximum number of lines for the title text.
  ///
  /// Logic:
  /// - 2 lines if: non-beverage without description, OR beverage without
  ///   description/image but with long title
  /// - 1 line otherwise (for compactness)
  int _getTitleMaxLines({
    required bool isBeverage,
    required bool hasDescription,
    required bool hasImage,
    required bool hasLongTitle,
  }) {
    if (!isBeverage && !hasDescription) return _titleMaxLinesDouble;
    if (isBeverage && !hasDescription && !hasImage && hasLongTitle) {
      return _titleMaxLinesDouble;
    }
    return _titleMaxLinesSingle;
  }

  /// Calculates the spacing between description and price.
  ///
  /// Logic:
  /// - Standard spacing if: non-beverage, OR beverage with description, OR
  ///   beverage without description/image but with long title
  /// - Compact spacing otherwise (tighter for compact beverages)
  double _getDescriptionSpacing({
    required bool isBeverage,
    required bool hasDescription,
    required bool hasImage,
    required bool hasLongTitle,
  }) {
    if (!isBeverage) return _descriptionPriceSpacingStandard;
    if (isBeverage && hasDescription) return _descriptionPriceSpacingStandard;
    if (isBeverage && !hasDescription && !hasImage && hasLongTitle) {
      return _descriptionPriceSpacingStandard;
    }
    return _descriptionPriceSpacingCompact;
  }

  /// =========================================================================
  /// PACKAGE DATA BUILDER
  /// =========================================================================

  /// Builds a complete data map for package items to pass to callbacks.
  ///
  /// Extracts all relevant package information including courses, pricing,
  /// metadata, and identifiers into a structured map ready for consumption
  /// by the package detail view or other handlers.
  Map<String, dynamic> _buildPackageData(String formattedPrice) {
    return {
      /// Core package identification
      'package_id': item['package_id'],
      'package_name': item['package_name'] as String? ?? '',
      'package_description': item['package_description'] as String? ?? '',
      'package_image_url': item['package_image_url'] as String?,

      /// Pricing information
      'base_price': item['base_price'] as num? ?? 0,
      'formatted_price': formattedPrice,

      /// Package courses with items - key data for display
      'courses': item['courses'] as List<dynamic>? ?? [],

      /// Additional metadata
      'is_combo': item['is_combo'] as bool? ?? false,
      'is_fixed_price_menu': item['is_fixed_price_menu'] as bool? ?? false,
      'is_tasting_menu': item['is_tasting_menu'] as bool? ?? false,
      'is_sharing_menu': item['is_sharing_menu'] as bool? ?? false,

      /// Context preservation
      'business_id': item['business_id'],
      'menu_id': item['menu_id'],
    };
  }

  /// =========================================================================
  /// TAP HANDLERS
  /// =========================================================================

  /// Handles tap events, routing to appropriate callback based on item type.
  ///
  /// For regular items, calculates variation data to pass to callback:
  /// - formattedPrice: Clean base price without "From" prefix
  /// - hasVariations: Boolean flag for easy UI logic
  /// - formattedVariationPrice: Variation price WITH "From" prefix (null if none)
  void _handleTap(String formattedPrice) {
    if (_isPackage()) {
      _handlePackageTap(formattedPrice);
    } else {
      _handleRegularItemTap(formattedPrice);
    }
  }

  /// Handles tap on package item
  void _handlePackageTap(String formattedPrice) {
    final packageData = _buildPackageData(formattedPrice);
    onPackageTap?.call(packageData);
  }

  /// Handles tap on regular menu item
  void _handleRegularItemTap(String formattedPrice) {
    final allergyIds = _getIntList('allergy_ids');
    final dietaryTypeIds = _getIntList('dietary_type_ids');
    final isBeverage = _getBool('is_beverage');
    final hasVariations = _hasVariations();
    final formattedVariationPrice = _buildFormattedVariationPrice();

    _invokeItemTapCallback(
      isBeverage,
      dietaryTypeIds,
      allergyIds,
      formattedPrice,
      hasVariations,
      formattedVariationPrice,
    );
  }

  /// Builds formatted variation price with "From" prefix if applicable
  String? _buildFormattedVariationPrice() {
    if (!_hasVariations()) return null;

    final variationMinPrice = _getMinimumVariationPrice();
    if (variationMinPrice <= 0) return null;

    final variationPriceValue = convertAndFormatPrice(
      variationMinPrice,
      originalCurrencyCode,
      exchangeRate,
      chosenCurrency,
    );

    if (variationPriceValue == null) return null;

    return '${_getFromPrefix()} $variationPriceValue';
  }

  /// Invokes the item tap callback with all required parameters
  void _invokeItemTapCallback(
    bool isBeverage,
    List<int> dietaryTypeIds,
    List<int> allergyIds,
    String formattedPrice,
    bool hasVariations,
    String? formattedVariationPrice,
  ) {
    onItemTap?.call(
      item,
      isBeverage,
      dietaryTypeIds,
      allergyIds,
      formattedPrice,
      hasVariations,
      formattedVariationPrice,
    );
  }

  /// =========================================================================
  /// PRICING FLAGS
  /// =========================================================================

  /// Checks if the item price is per person
  bool _isPricePerPerson() {
    return _getBool('is_price_per_person');
  }

  /// =========================================================================
  /// PRICE CALCULATION & FORMATTING
  /// =========================================================================

  /// Calculates and formats pricing data for display and callbacks.
  ///
  /// Returns:
  ///   _PriceData with:
  ///   - displayPrice: Formatted price for UI (with "From" if variations, with "per person" suffix if applicable)
  ///   - callbackPrice: Clean price without prefixes/suffixes for callback parameter
  _PriceData _calculatePrices() {
    final effectivePrice = _getEffectivePrice();
    final showFrom = _shouldShowFromPrefix();
    final isPricePerPerson = _isPricePerPerson();

    final formattedValue = convertAndFormatPrice(
      effectivePrice,
      originalCurrencyCode,
      exchangeRate,
      chosenCurrency,
    );

    String displayPrice;
    if (formattedValue == null || formattedValue.isEmpty) {
      displayPrice = '';
    } else {
      displayPrice =
          showFrom ? '${_getFromPrefix()} $formattedValue' : formattedValue;

      if (isPricePerPerson) {
        final perPersonSuffix = _getPerPersonSuffix();
        displayPrice = '$displayPrice — $perPersonSuffix';
      }
    }

    return _PriceData(
      displayPrice: displayPrice,
      callbackPrice: formattedValue ?? '',
    );
  }

  /// =========================================================================
  /// LAYOUT CONFIGURATION
  /// =========================================================================

  /// Calculates layout configuration based on item properties.
  ///
  /// Determines:
  /// - Whether description should be shown
  /// - Whether image should be shown
  /// - Maximum lines for title text
  /// - Spacing between description and price
  _LayoutConfig _calculateLayoutConfig(
    String itemTitle,
    String description,
    String imageUrl,
    bool isBeverage,
  ) {
    final hasDescription = description.isNotEmpty;
    final hasImage = imageUrl.isNotEmpty;
    final hasLongTitle = itemTitle.length > _longTitleThreshold;

    final titleMaxLines = _getTitleMaxLines(
      isBeverage: isBeverage,
      hasDescription: hasDescription,
      hasImage: hasImage,
      hasLongTitle: hasLongTitle,
    );

    final descriptionSpacing = _getDescriptionSpacing(
      isBeverage: isBeverage,
      hasDescription: hasDescription,
      hasImage: hasImage,
      hasLongTitle: hasLongTitle,
    );

    return _LayoutConfig(
      hasDescription: hasDescription,
      hasImage: hasImage,
      titleMaxLines: titleMaxLines,
      descriptionSpacing: descriptionSpacing,
    );
  }

  /// =========================================================================
  /// UI BUILDERS - COMPONENTS
  /// =========================================================================

  /// Builds the item image widget
  Widget _buildImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_itemImageBorderRadius),
      child: Image.network(
        imageUrl,
        width: _itemImageWidth,
        height: _itemImageHeight,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: _itemImageWidth,
          height: _itemImageHeight,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      ),
    );
  }

  /// Builds the title text widget
  Widget _buildTitle(String title, int maxLines) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: _titleFontSize,
        fontWeight: _titleFontWeight,
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds the description text widget
  Widget _buildDescription(String description) {
    return Text(
      description,
      style: const TextStyle(
        fontSize: _descriptionFontSize,
        fontWeight: _descriptionFontWeight,
        color: Colors.black87,
      ),
      maxLines: _descriptionMaxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds the price text widget
  /// When price is zero, renders invisible text to maintain layout consistency
  Widget _buildPrice(String price) {
    final isZeroPrice = _isZeroPrice(price);

    return Opacity(
      opacity: isZeroPrice ? 0.0 : 1.0,
      child: Text(
        isZeroPrice
            ? '0 kr'
            : price, // Render placeholder invisibly to maintain height
        style: const TextStyle(
          fontSize: _priceFontSize,
          fontWeight: _priceFontWeight,
          color: _priceColor,
        ),
      ),
    );
  }

  /// Builds the content column (title, description, price)
  Widget _buildContentColumn(
    String title,
    String description,
    String displayPrice,
    _LayoutConfig layout,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTitle(title, layout.titleMaxLines),
        if (layout.hasDescription) ...[
          const SizedBox(height: _titleDescriptionSpacing),
          _buildDescription(description),
        ],
        SizedBox(height: layout.descriptionSpacing),
        _buildPrice(displayPrice),
      ],
    );
  }

  /// Builds the divider widget
  Widget _buildDivider() {
    return Divider(
      height: _dividerHeight,
      thickness: _dividerThickness,
      color: Colors.grey[300]?.withOpacity(_dividerOpacity),
    );
  }

  /// =========================================================================
  /// BUILD METHOD
  /// =========================================================================

  @override
  Widget build(BuildContext context) {
    if (item == null || item is! Map) {
      return const SizedBox.shrink();
    }

    /// Extract item data
    final itemTitle = _getString('item_name', 'Unnamed Item');
    final description = _getString('item_description');
    final imageUrl = _getString('item_image_url');
    final isBeverage = _getBool('is_beverage');

    /// Calculate pricing
    final priceData = _calculatePrices();

    /// Determine layout configuration
    final layout = _calculateLayoutConfig(
      itemTitle,
      description,
      imageUrl,
      isBeverage,
    );

    /// Build the item widget
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleTap(priceData.callbackPrice),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: _verticalPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: layout.hasImage ? _horizontalImagePadding : 0.0,
                      ),
                      child: _buildContentColumn(
                        itemTitle,
                        description,
                        priceData.displayPrice,
                        layout,
                      ),
                    ),
                  ),
                  if (layout.hasImage) _buildImage(imageUrl),
                ],
              ),
            ),
          ),
        ),
        _buildDivider(),
      ],
    );
  }
}

/// =========================================================================
/// HELPER DATA CLASSES FOR _MenuItem
/// =========================================================================

/// Data class for price information
class _PriceData {
  const _PriceData({
    required this.displayPrice,
    required this.callbackPrice,
  });

  final String displayPrice;
  final String callbackPrice;
}

/// Data class for layout configuration
class _LayoutConfig {
  const _LayoutConfig({
    required this.hasDescription,
    required this.hasImage,
    required this.titleMaxLines,
    required this.descriptionSpacing,
  });

  final bool hasDescription;
  final bool hasImage;
  final int titleMaxLines;
  final double descriptionSpacing;
}

/// ==============================================================================
/// CATEGORY HEADER WIDGET
/// ==============================================================================

/// Displays a category header in the menu list.
///
/// Used for both regular category headers and the multi-course menu header.
/// Adapts top padding based on whether it's the first item in the list.
/// Includes an optional single-line description below the category name.
/// The description row is only rendered when a non-empty description exists.
class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    required this.categoryName,
    this.categoryDescription,
    this.isFirst = false,
    this.onInfoTap,
  });

  final String categoryName;
  final String? categoryDescription;
  final bool isFirst;
  final VoidCallback? onInfoTap;

  /// =========================================================================
  /// CONSTANTS - STYLING
  /// =========================================================================

  static const double _topPaddingRegular = 16.0;
  static const double _topPaddingFirst = 0.0;
  static const double _bottomPadding = 8.0;
  static const double _nameFontSize = 18.0;
  static const FontWeight _nameFontWeight = FontWeight.w500;
  static const Color _nameTextColor = Colors.black;

  static const double _descriptionFontSize = 14.0;
  static const FontWeight _descriptionFontWeight = FontWeight.w300;
  static const Color _descriptionColor = Colors.black54;
  static const int _descriptionMaxLines = 1;
  static const double _nameToDescriptionSpacing = 2.0;
  static const double _descriptionRowHeight = 18.0;

  // Icon styling
  static const double _iconSize = 16.0;
  static const double _iconLeftSpacing = 4.0;
  static const double _textTruncationBuffer = 20.0;
  static const Color _iconColor = Colors.black54;

  // Layout constants
  static const double _horizontalPadding = 28.0;

  /// =========================================================================
  /// TEXT OVERFLOW DETECTION
  /// =========================================================================

  /// Checks if text will overflow given constraints
  bool _willTextOverflow({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required int maxLines,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    return textPainter.didExceedMaxLines;
  }

  /// Calculates available width for description text before truncation
  double _getAvailableDescriptionWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Reserve space for: padding (both sides) + truncation buffer + icon size + gap
    return screenWidth -
        (_horizontalPadding * 2) -
        _textTruncationBuffer -
        _iconSize -
        _iconLeftSpacing;
  }

  /// Determines if info icon should be shown (only when description overflows)
  bool _shouldShowInfoIcon(BuildContext context) {
    if (categoryDescription == null || categoryDescription!.trim().isEmpty) {
      return false;
    }

    final availableWidth = _getAvailableDescriptionWidth(context);
    return _willTextOverflow(
      text: categoryDescription!,
      style: const TextStyle(
        fontSize: _descriptionFontSize,
        fontWeight: _descriptionFontWeight,
      ),
      maxWidth: availableWidth,
      maxLines: _descriptionMaxLines,
    );
  }

  /// =========================================================================
  /// BUILD METHOD
  /// =========================================================================

  @override
  Widget build(BuildContext context) {
    final hasDescription =
        categoryDescription != null && categoryDescription!.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.only(
        top: isFirst ? _topPaddingFirst : _topPaddingRegular,
        bottom: _bottomPadding,
      ),
      alignment: AlignmentDirectional.centerStart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Category name (always shown)
          Text(
            categoryName,
            style: const TextStyle(
              fontSize: _nameFontSize,
              fontWeight: _nameFontWeight,
              color: _nameTextColor,
            ),
          ),

          // Description row (only shown when description exists)
          if (hasDescription) ...[
            const SizedBox(height: _nameToDescriptionSpacing),
            SizedBox(
              height: _descriptionRowHeight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: 0.95,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Description text
                      Flexible(
                        child: Text(
                          categoryDescription!,
                          style: const TextStyle(
                            fontSize: _descriptionFontSize,
                            fontWeight: _descriptionFontWeight,
                            color: _descriptionColor,
                          ),
                          maxLines: _descriptionMaxLines,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Info icon (only if text overflows)
                      if (_shouldShowInfoIcon(context)) ...[
                        SizedBox(width: _iconLeftSpacing),
                        GestureDetector(
                          onTap: () {
                            markUserEngaged();
                            onInfoTap?.call();
                          },
                          child: const Icon(
                            Icons.info_outline,
                            size: _iconSize,
                            color: _iconColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// ==============================================================================
/// NO DISHES MESSAGE WIDGET
/// ==============================================================================

/// Displays a message when no dishes match the current filter criteria.
///
/// Shows localized text explaining that the category has no visible items
/// based on the user's dietary preferences or allergy exclusions.
class _NoDishesMessage extends StatelessWidget {
  const _NoDishesMessage({
    required this.message,
  });

  final String message;

  /// =========================================================================
  /// CONSTANTS - STYLING
  /// =========================================================================

  static const double _verticalPadding = 8.0;
  static const double _fontSize = 14.0;
  static const FontWeight _fontWeight = FontWeight.w300;
  static const Color _textColor = Colors.grey;
  static const double _dividerHeight = 1.0;
  static const double _dividerThickness = 1.0;
  static const double _dividerOpacity = 0.7;

  /// =========================================================================
  /// BUILD METHOD
  /// =========================================================================

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: _verticalPadding),
          child: Container(
            width: double.infinity,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              message,
              style: const TextStyle(
                fontSize: _fontSize,
                fontWeight: _fontWeight,
                color: _textColor,
              ),
            ),
          ),
        ),
        Divider(
          height: _dividerHeight,
          thickness: _dividerThickness,
          color: Colors.grey[300]?.withOpacity(_dividerOpacity),
        ),
      ],
    );
  }
}
