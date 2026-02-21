import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'dart:ui' as ui;

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import '../../providers/business_providers.dart';
import '../../providers/app_providers.dart';
import '../../providers/settings_providers.dart';
import '../../services/translation_service.dart';
import '../../services/analytics_service.dart';
import '../../services/api_service.dart';
import '../../services/custom_functions/price_formatter.dart';

/// A custom scrollable list widget that displays menu items and packages
/// organized by categories.
///
/// This widget handles:
/// - Dynamic filtering based on dietary preferences and allergies
/// - Automatic scrolling to selected categories
/// - Tracking and reporting the currently visible category
/// - Multi-language support via centralized translation system
/// - Currency conversion and formatting
/// - Separate handling of regular menu items and multi-course packages
/// - Variation detection and "From" pricing display
///
/// ANALYTICS TRACKING:
/// - Tracks menu item clicks with contextual metadata
/// - Tracks package clicks
/// - Tracks scroll depth through categories
/// - Updates analyticsProvider for session-level metrics
class MenuDishesListView extends ConsumerStatefulWidget {
  const MenuDishesListView({
    super.key,
    this.width,
    this.height,
    required this.originalCurrencyCode,
    this.isDynamicHeight = false,
    this.onItemTap,
    this.onPackageTap,
    this.onVisibleCategoryChanged,
    this.onCategoryDescriptionTap,
  });

  final double? width;
  final double? height;
  final String originalCurrencyCode;
  final bool isDynamicHeight;
  final Future<void> Function(
    dynamic bottomSheetInformation,
    bool isBeverage,
    List<int>? dietaryTypeIds,
    List<int>? allergyIds,
    String formattedPrice,
    bool hasVariations,
    String? formattedVariationPrice,
  )? onItemTap;
  final Future<void> Function(dynamic packageData)? onPackageTap;
  final Future<void> Function(dynamic selectionData)? onVisibleCategoryChanged;
  final Future<void> Function(dynamic categoryData)? onCategoryDescriptionTap;

  @override
  ConsumerState<MenuDishesListView> createState() => _MenuDishesListViewState();
}

class _MenuDishesListViewState extends ConsumerState<MenuDishesListView> {
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

  /// =========================================================================
  /// STATE - SCROLL MANAGEMENT (7 variables)
  /// =========================================================================

  /// Controller for programmatic scrolling to specific items
  late ItemScrollController _itemScrollController;

  /// Listener for tracking visible item positions in viewport
  late ItemPositionsListener _itemPositionsListener;

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

  /// Last category ID we scrolled to (for detecting changes from provider)
  int? _lastScrolledToCategoryId;

  /// =========================================================================
  /// STATE - DATA MANAGEMENT (4 variables)
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
  /// STATE - ANALYTICS TRACKING (4 variables)
  /// =========================================================================

  /// Tracks the deepest category index reached during manual scrolling
  int _deepestCategoryIndexReached = 0;

  /// Tracks which unique category IDs have been viewed during session
  final Set<int> _viewedCategoryIds = {};

  /// Business ID extracted from menu data for analytics
  int? _businessId;

  /// Flag to prevent scroll tracking until user actually scrolls
  bool _hasUserScrolled = false;

  /// =========================================================================
  /// LIFECYCLE METHODS
  /// =========================================================================

  @override
  void initState() {
    super.initState();
    _itemScrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();

    _extractBusinessId();

    // Process data without triggering parent callbacks
    _extractAndSortData();
    _buildCategoryIndexMap();
    _buildCategoryMenuMap();

    _itemPositionsListener.itemPositions.addListener(_onItemPositionsChanged);

    // Initialize last scrolled category
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _lastScrolledToCategoryId = _getSelectedCategoryId();
      }
    });
  }

  @override
  void didUpdateWidget(covariant MenuDishesListView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Always re-process data since filters come from provider
    _processData();
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_onItemPositionsChanged);
    super.dispose();
  }

  /// =========================================================================
  /// PROVIDER ACCESSORS (Read from Riverpod providers)
  /// =========================================================================

  /// Gets menu data from businessProvider
  dynamic _getMenuData() {
    return ref.read(businessProvider).menuItems;
  }

  /// Gets current language code from context
  String _getLanguageCode() {
    return Localizations.localeOf(context).languageCode;
  }

  /// Gets selected dietary restrictions from businessProvider
  List<int> _getSelectedDietaryRestrictions() {
    return ref.read(businessProvider).selectedDietaryRestrictionIds;
  }

  /// Gets selected dietary preference from businessProvider
  int? _getSelectedDietaryPreference() {
    final pref = ref.read(businessProvider).selectedDietaryPreferenceId;
    return (pref == null || pref == 0) ? null : pref;
  }

  /// Gets excluded allergy IDs from businessProvider
  List<int> _getSelectedAllergies() {
    return ref.read(businessProvider).excludedAllergyIds;
  }

  /// Gets selected category ID (placeholder - TODO: determine source)
  int _getSelectedCategoryId() {
    // TODO: Determine if this should come from businessProvider or as a prop
    return 0;
  }

  /// Gets user's chosen currency code from localizationProvider
  String _getChosenCurrency() {
    return ref.read(localizationProvider).currencyCode;
  }

  /// Gets exchange rate from localizationProvider
  double _getExchangeRate() {
    return ref.read(localizationProvider).exchangeRate;
  }

  /// =========================================================================
  /// ANALYTICS - BUSINESS ID EXTRACTION
  /// =========================================================================

  /// Extracts business_id from the first available menu item
  void _extractBusinessId() {
    try {
      final menuData = _getMenuData();
      if (menuData is Map<String, dynamic>) {
        final menuItems = menuData['menu_items'] as List<dynamic>? ?? [];

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

  /// Updates analyticsProvider by incrementing item click count
  void _incrementSessionItemClicks() {
    try {
      ref.read(analyticsProvider.notifier).incrementItemClick();
    } catch (e) {
      debugPrint('⚠️ Failed to increment session item clicks: $e');
    }
  }

  /// Updates analyticsProvider by incrementing package click count
  void _incrementSessionPackageClicks() {
    try {
      ref.read(analyticsProvider.notifier).incrementPackageClick();
    } catch (e) {
      debugPrint('⚠️ Failed to increment session package clicks: $e');
    }
  }

  /// Updates analyticsProvider by adding a viewed category
  void _addViewedCategoryToSession(int categoryId) {
    try {
      ref.read(analyticsProvider.notifier).recordCategoryViewed(categoryId);
    } catch (e) {
      debugPrint('⚠️ Failed to add viewed category to session: $e');
    }
  }

  /// Updates analyticsProvider with deepest scroll percentage
  void _updateSessionScrollDepth(int scrollPercent) {
    try {
      ref.read(analyticsProvider.notifier).updateDeepestScroll(scrollPercent);
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

    // Get analytics data
    final analyticsState = ref.read(analyticsProvider);
    final deviceId = AnalyticsService.instance.deviceId ?? 'unknown';
    final sessionId = analyticsState.sessionId ?? 'unknown';
    final userId = AnalyticsService.instance.userId ?? 'unknown';

    // Track event (fire and forget)
    ApiService.instance.postAnalytics(
      eventType: 'menu_item_clicked',
      deviceId: deviceId,
      sessionId: sessionId,
      userId: userId,
      eventData: {
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
        'language': _getLanguageCode(),
      },
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  /// Tracks when a package is clicked
  void _trackMenuPackageClick({
    required int packageId,
    required String packageName,
    required int position,
    required int totalPackages,
  }) {
    if (_businessId == null) return;

    // Get analytics data
    final analyticsState = ref.read(analyticsProvider);
    final deviceId = AnalyticsService.instance.deviceId ?? 'unknown';
    final sessionId = analyticsState.sessionId ?? 'unknown';
    final userId = AnalyticsService.instance.userId ?? 'unknown';

    // Track event (fire and forget)
    ApiService.instance.postAnalytics(
      eventType: 'menu_package_clicked',
      deviceId: deviceId,
      sessionId: sessionId,
      userId: userId,
      eventData: {
        'business_id': _businessId,
        'package_id': packageId,
        'package_name': packageName,
        'package_position': position,
        'total_packages': totalPackages,
        'language': _getLanguageCode(),
      },
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  /// Tracks when category description modal is opened
  void _trackCategoryDescriptionView(String categoryName) {
    if (_businessId == null) return;

    // Get analytics data
    final analyticsState = ref.read(analyticsProvider);
    final deviceId = AnalyticsService.instance.deviceId ?? 'unknown';
    final sessionId = analyticsState.sessionId ?? 'unknown';
    final userId = AnalyticsService.instance.userId ?? 'unknown';

    // Track event (fire and forget)
    ApiService.instance.postAnalytics(
      eventType: 'category_description_viewed',
      deviceId: deviceId,
      sessionId: sessionId,
      userId: userId,
      eventData: {
        'business_id': _businessId,
        'category_name': categoryName,
        'language': _getLanguageCode(),
      },
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  /// Handles tap on category description info icon
  /// ⚠️ NOTE: markUserEngaged() call removed - ActivityScope handles it automatically
  void _handleCategoryDescriptionTap(String categoryName, String description) {
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

    // Get analytics data
    final analyticsState = ref.read(analyticsProvider);
    final deviceId = AnalyticsService.instance.deviceId ?? 'unknown';
    final sessionId = analyticsState.sessionId ?? 'unknown';
    final userId = AnalyticsService.instance.userId ?? 'unknown';

    // Track event (fire and forget)
    ApiService.instance.postAnalytics(
      eventType: 'menu_scroll_depth',
      deviceId: deviceId,
      sessionId: sessionId,
      userId: userId,
      eventData: {
        'business_id': _businessId,
        'deepest_category_index': _deepestCategoryIndexReached,
        'total_categories': totalCategories,
        'scroll_depth_percent': scrollPercent,
        'language': _getLanguageCode(),
      },
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  /// =========================================================================
  /// ANALYTICS - HELPER FUNCTIONS
  /// =========================================================================

  /// Converts a price to a price range bucket for analytics
  String _getPriceRange(double price) {
    final convertedPrice = price * _getExchangeRate();

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

  /// Gets localized UI text using translation helper
  String _getUIText(String key) {
    return td(ref, key);
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

    // Check top zone first (priority for headers entering)
    if (_handleTopZoneHeaders(positions)) return;

    // Check bottom zone (headers exiting when scrolling up)
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

    // Walk backwards from exiting header to find previous category
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

      final normalizedMap = _getMenuData() as Map<String, dynamic>;

      _buildMenuItemMap(normalizedMap);
      _extractAndSortCategories(normalizedMap);
      _extractAndSortPackages(normalizedMap);
    } catch (e) {
      _clearDataStructures();
    }
  }

  /// Validates that normalized data is a proper Map
  bool _isValidNormalizedData() {
    return _getMenuData() is Map<String, dynamic>;
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

      // Skip items in this category
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
        .where((item) => item != null)
        .cast<Map<String, dynamic>>()
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
    for (final restrictionId in _getSelectedDietaryRestrictions()) {
      if (_isValidDietaryId(restrictionId)) {
        final hasInherently = itemDietaryTypes.contains(restrictionId);
        final canBeMade = itemCanBeMadeTypes.contains(restrictionId);

        if (!hasInherently && !canBeMade) {
          return false; // Item missing this restriction entirely
        }
      }
    }

    // Check preference filter (only if valid ID: not null and not 0)
    final preference = _getSelectedDietaryPreference();
    if (_isValidDietaryId(preference)) {
      final hasInherently = itemDietaryTypes.contains(preference);
      final canBeMade = itemCanBeMadeTypes.contains(preference);

      if (!hasInherently && !canBeMade) {
        return false;
      }
    }

    return true;
  }

  /// CRITICAL: Allergen override exception
  /// If item can be made to satisfy ANY active restriction/preference,
  /// bypass allergen filtering (e.g., "gluten-free available" shows despite gluten)
  bool _qualifiesForAllergenOverride(Map<String, dynamic> item) {
    final itemCanBeMadeTypes =
        _extractIntList(item, 'dietary_type_can_be_made_ids');

    // Check if ANY active restriction is in can-be-made array
    for (final restrictionId in _getSelectedDietaryRestrictions()) {
      if (_isValidDietaryId(restrictionId)) {
        if (itemCanBeMadeTypes.contains(restrictionId)) {
          return true; // Allergen override applies
        }
      }
    }

    // Check if preference is in can-be-made array
    final preference = _getSelectedDietaryPreference();
    if (_isValidDietaryId(preference)) {
      if (itemCanBeMadeTypes.contains(preference)) {
        return true; // Allergen override applies
      }
    }

    return false; // No override, apply normal allergen filtering
  }

  /// Checks if item passes allergy exclusion filter
  bool _passesAllergyFilter(Map<String, dynamic> item) {
    final excludedAllergies = _getSelectedAllergies();
    if (excludedAllergies.isEmpty) {
      return true;
    }

    final itemAllergies = _extractIntList(item, 'allergy_ids');
    final excludedSet = Set<int>.from(excludedAllergies);

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
      if (mounted) {
        _isScrolling = false;
      }
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

    // Single header for all packages (no description for multi-course section)
    fullList.add(_CategoryHeader(
      categoryName: _getMultiCourseHeader(),
      categoryDescription: null, // No description for packages section
      isFirst: true,
      onInfoTap: null, // No callback for packages section
    ));

    // Add all package items with position tracking
    for (int i = 0; i < _menuPackages.length; i++) {
      fullList.add(_buildPackageMenuItem(_menuPackages[i], i));
    }
  }

  /// Builds a menu item widget for a package with analytics tracking
  /// ⚠️ NOTE: markUserEngaged() call removed - ActivityScope handles it automatically
  Widget _buildPackageMenuItem(Map<String, dynamic> package, int position) {
    return _MenuItem(
      item: package,
      onItemTap: null,
      onPackageTap: (packageData) async {
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
      chosenCurrency: _getChosenCurrency(),
      originalCurrencyCode: widget.originalCurrencyCode,
      exchangeRate: _getExchangeRate(),
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
    // Extract category data including description
    final categoryName = _getCategoryName(category);
    final categoryDescription = _getCategoryDescription(category);
    final categoryId = _getCategoryId(category);

    if (categoryId == null) return;

    // Add category header with description and tap handler
    fullList.add(_CategoryHeader(
      categoryName: categoryName,
      categoryDescription: categoryDescription,
      isFirst: fullList.isEmpty,
      onInfoTap: categoryDescription != null && categoryDescription.isNotEmpty
          ? () =>
              _handleCategoryDescriptionTap(categoryName, categoryDescription)
          : null,
    ));

    // Add items or "no dishes" message
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
  /// ⚠️ NOTE: markUserEngaged() call removed - ActivityScope handles it automatically
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
      chosenCurrency: _getChosenCurrency(),
      originalCurrencyCode: widget.originalCurrencyCode,
      exchangeRate: _getExchangeRate(),
    );
  }

  /// =========================================================================
  /// BUILD METHOD
  /// =========================================================================

  @override
  Widget build(BuildContext context) {
    _fullList = _buildFullList();

    // Check if we need to scroll to a new category (detected via provider)
    final currentCategoryId = _getSelectedCategoryId();
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Container(
            width: double.infinity,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              message,
              style: AppTypography.bodyRegular.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
        Divider(
          height: 1.0,
          thickness: 1.0,
          color: AppColors.divider.withValues(alpha: 0.7),
        ),
      ],
    );
  }
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
    const horizontalPadding = 28.0;
    const textTruncationBuffer = 20.0;
    const iconSize = 16.0;
    const iconLeftSpacing = 4.0;

    return screenWidth -
        (horizontalPadding * 2) -
        textTruncationBuffer -
        iconSize -
        iconLeftSpacing;
  }

  /// Determines if info icon should be shown (only when description overflows)
  bool _shouldShowInfoIcon(BuildContext context) {
    if (categoryDescription == null || categoryDescription!.trim().isEmpty) {
      return false;
    }

    final availableWidth = _getAvailableDescriptionWidth(context);
    const descriptionStyle = TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w300,
    );

    return _willTextOverflow(
      text: categoryDescription!,
      style: descriptionStyle,
      maxWidth: availableWidth,
      maxLines: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasDescription =
        categoryDescription != null && categoryDescription!.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.only(
        top: isFirst ? 0.0 : AppSpacing.lg,
        bottom: AppSpacing.sm,
      ),
      alignment: AlignmentDirectional.centerStart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Category name (always shown)
          Text(
            categoryName,
            style: AppTypography.sectionHeading.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),

          // Description row (only shown when description exists)
          if (hasDescription) ...[
            SizedBox(height: AppSpacing.xs / 2), // 2px
            SizedBox(
              height: 18.0,
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
                            fontSize: 14.0,
                            fontWeight: FontWeight.w300,
                            color: Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Info icon (only if text overflows)
                      // ⚠️ NOTE: markUserEngaged() call removed - ActivityScope handles it
                      if (_shouldShowInfoIcon(context)) ...[
                        const SizedBox(width: 4.0),
                        GestureDetector(
                          onTap: onInfoTap,
                          child: const Icon(
                            Icons.info_outline,
                            size: 16.0,
                            color: Colors.black54,
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
/// MENU ITEM WIDGET
/// ==============================================================================

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
class _MenuItem extends ConsumerWidget {
  const _MenuItem({
    required this.item,
    required this.chosenCurrency,
    required this.originalCurrencyCode,
    required this.exchangeRate,
    this.onItemTap,
    this.onPackageTap,
  });

  final dynamic item;
  final String chosenCurrency;
  final String originalCurrencyCode;
  final double exchangeRate;
  final Future<void> Function(
    dynamic bottomSheetInformation,
    bool isBeverage,
    List<int>? dietaryTypeIds,
    List<int>? allergyIds,
    String formattedPrice,
    bool hasVariations,
    String? formattedVariationPrice,
  )? onItemTap;
  final Future<void> Function(dynamic packageData)? onPackageTap;

  /// =========================================================================
  /// CONSTANTS - LAYOUT & STYLING
  /// =========================================================================

  static const double _verticalPadding = 8.0;
  static const double _horizontalImagePadding = 8.0;
  static const double _titleDescriptionSpacing = 2.0;
  static const double _descriptionPriceSpacingStandard = 4.0;
  static const double _descriptionPriceSpacingCompact = 2.0;
  static const double _itemImageWidth = 133.0;
  static const double _itemImageHeight = 75.0;
  static const int _titleMaxLinesSingle = 1;
  static const int _titleMaxLinesDouble = 2;
  static const int _descriptionMaxLines = 2;
  static const int _longTitleThreshold = 45;

  /// =========================================================================
  /// HELPER METHODS
  /// =========================================================================

  String _getUIText(WidgetRef ref, String key) {
    return td(ref, key);
  }

  String _getString(String key, [String defaultValue = '']) {
    if (item is! Map) return defaultValue;
    final value = item[key] ??
        (key == 'item_name' ? item['package_name'] : null) ??
        (key == 'item_description' ? item['package_description'] : null) ??
        (key == 'item_image_url' ? item['package_image_url'] : null);
    return (value is String && value.isNotEmpty) ? value : defaultValue;
  }

  bool _getBool(String key, [bool defaultValue = false]) {
    final value = item is Map ? item[key] : null;
    return value is bool ? value : defaultValue;
  }

  List<int> _getIntList(String key) {
    final value = item is Map ? item[key] : null;
    return value is List ? value.whereType<int>().toList() : [];
  }

  double _getDouble(String key, [double defaultValue = 0.0]) {
    if (item is! Map) return defaultValue;
    final value = item[key];
    return value is num ? value.toDouble() : defaultValue;
  }

  bool _isPackage() => item is Map && item['category_type'] == 'menu_package';

  bool _hasVariations() {
    final modifierGroups = item is Map ? item['item_modifier_groups'] : null;
    if (modifierGroups is! List) return false;
    return modifierGroups.any((g) => g is Map && g['type'] == 'Variation');
  }

  double _getMinimumVariationPrice() {
    final modifierGroups = item is Map ? item['item_modifier_groups'] : null;
    if (modifierGroups is! List) return 0.0;
    double minPrice = double.infinity;
    for (final group in modifierGroups) {
      if (group is! Map || group['type'] != 'Variation') continue;
      final modifiers = group['modifiers'] as List?;
      if (modifiers != null) {
        for (final mod in modifiers) {
          if (mod is! Map) continue;
          final price = mod['price'];
          if (price is num && price > 0 && price < minPrice) {
            minPrice = price.toDouble();
          }
        }
      }
    }
    return minPrice == double.infinity ? 0.0 : minPrice;
  }

  double _getEffectivePrice() {
    final basePrice = _getDouble('base_price');
    final premiumUpcharge = _getDouble('premium_upcharge');
    if (_hasVariations()) {
      final variationMin = _getMinimumVariationPrice();
      if (basePrice > 0) {
        return basePrice < variationMin ? basePrice : variationMin;
      }
      return variationMin;
    }
    return basePrice + premiumUpcharge;
  }

  bool _shouldShowFromPrefix() => _hasVariations() && _getEffectivePrice() > 0;

  bool _isZeroPrice(String price) {
    if (price.isEmpty) return true;
    final trimmed = price.trim();
    if (trimmed == '0') return true;
    if (RegExp(r'^[€£\$¥]\s*0(?:[.,]0+)?$').hasMatch(trimmed)) return true;
    if (RegExp(r'^0(?:[.,]0+)?\s*(?:kr\.|zł|₩|₴)$').hasMatch(trimmed)) {
      return true;
    }
    return false;
  }

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

  Map<String, dynamic> _buildPackageData(String formattedPrice) {
    return {
      'package_id': item['package_id'],
      'package_name': item['package_name'] as String? ?? '',
      'package_description': item['package_description'] as String? ?? '',
      'package_image_url': item['package_image_url'] as String?,
      'base_price': item['base_price'] as num? ?? 0,
      'formatted_price': formattedPrice,
      'courses': item['courses'] as List<dynamic>? ?? [],
      'is_combo': item['is_combo'] as bool? ?? false,
      'is_fixed_price_menu': item['is_fixed_price_menu'] as bool? ?? false,
      'is_tasting_menu': item['is_tasting_menu'] as bool? ?? false,
      'is_sharing_menu': item['is_sharing_menu'] as bool? ?? false,
      'business_id': item['business_id'],
      'menu_id': item['menu_id'],
    };
  }

  void _handleTap(WidgetRef ref, String formattedPrice) {
    if (_isPackage()) {
      final packageData = _buildPackageData(formattedPrice);
      onPackageTap?.call(packageData);
    } else {
      final allergyIds = _getIntList('allergy_ids');
      final dietaryTypeIds = _getIntList('dietary_type_ids');
      final isBeverage = _getBool('is_beverage');
      final hasVariations = _hasVariations();
      String? formattedVariationPrice;
      if (hasVariations) {
        final variationMinPrice = _getMinimumVariationPrice();
        if (variationMinPrice > 0) {
          final variationPriceValue = convertAndFormatPrice(
            variationMinPrice,
            originalCurrencyCode,
            exchangeRate,
            chosenCurrency,
          );
          if (variationPriceValue != null) {
            formattedVariationPrice =
                '${_getUIText(ref, 'price_from')} $variationPriceValue';
          }
        }
      }
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
  }

  /// =========================================================================
  /// BUILD METHOD
  /// =========================================================================

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (item == null || item is! Map) {
      return const SizedBox.shrink();
    }

    final itemTitle = _getString('item_name', 'Unnamed Item');
    final description = _getString('item_description');
    final imageUrl = _getString('item_image_url');
    final isBeverage = _getBool('is_beverage');
    final isPricePerPerson = _getBool('is_price_per_person');

    final effectivePrice = _getEffectivePrice();
    final showFrom = _shouldShowFromPrefix();

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
      displayPrice = showFrom
          ? '${_getUIText(ref, 'price_from')} $formattedValue'
          : formattedValue;
      if (isPricePerPerson) {
        final perPersonSuffix = _getUIText(ref, 'price_per_person');
        displayPrice = '$displayPrice — $perPersonSuffix';
      }
    }

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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleTap(ref, formattedValue ?? ''),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: _verticalPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: hasImage ? _horizontalImagePadding : 0.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            itemTitle,
                            style: AppTypography.menuItemName.copyWith(
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: titleMaxLines,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (hasDescription) ...[
                            const SizedBox(height: _titleDescriptionSpacing),
                            Text(
                              description,
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w300,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: _descriptionMaxLines,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          SizedBox(height: descriptionSpacing),
                          Opacity(
                            opacity: _isZeroPrice(displayPrice) ? 0.0 : 1.0,
                            child: Text(
                              _isZeroPrice(displayPrice) ? '0 kr' : displayPrice,
                              style: AppTypography.price.copyWith(
                                fontWeight: FontWeight.w400,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (hasImage)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.chip / 2),
                      child: Image.network(
                        imageUrl,
                        width: _itemImageWidth,
                        height: _itemImageHeight,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: _itemImageWidth,
                          height: _itemImageHeight,
                          color: AppColors.bgInput,
                          child: Icon(Icons.broken_image,
                              color: AppColors.textMuted),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Divider(
          height: 1.0,
          thickness: 1.0,
          color: AppColors.divider.withValues(alpha: 0.7),
        ),
      ],
    );
  }
}


