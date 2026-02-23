import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_constants.dart';
import '../../providers/search_providers.dart';
import '../../providers/app_providers.dart';
import '../../services/api_service.dart';
import '../../services/translation_service.dart';

/// FilterSelectionType enum for tracking current selection mode
enum FilterSelectionType { none, neighborhood, shoppingArea, trainStation }

/// =============================================================================
/// FilterOverlayWidget - 3-Column Hierarchical Filter Interface
/// =============================================================================
///
/// PURPOSE:
/// Comprehensive filter overlay that enables users to browse and select filters
/// across multiple categories with real-time result count updates.
///
/// KEY FEATURES:
/// - Three-column hierarchical interface (categories → items → sub-items)
/// - Real-time result count updates during filter selection
/// - Selected filters displayed as removable chips
/// - Auto-coordination of location filters (neighborhood/shopping/train)
/// - Debounced search execution (300ms delay)
/// - Complex filter relationships and parent-child structures
/// - Grey left column with white selection background
/// - Orange accent bar on selected category
/// - Selected items use bold font (+100 weight)
///
/// PRESENTATION CHANGE (FlutterFlow → New design):
/// - FlutterFlow: Inline modal overlay (embedded in page with `mayLoad` parameter)
/// - New design: Bottom sheet (`showModalBottomSheet` + `DraggableScrollableSheet`)
/// - Content is 100% identical - only presentation layer changes
///
/// ALL FUNCTIONALITY PRESERVED:
/// - All 20+ edge cases handled
/// - All complex coordination logic preserved
/// - All display logic for filter chips
/// - All analytics tracking
/// - Production-ready quality
/// =============================================================================
class FilterOverlayWidget extends ConsumerStatefulWidget {
  /// Static flag for first launch cleanup
  static bool isFirstLaunch = true;

  const FilterOverlayWidget({
    super.key,
    this.width,
    this.height,
    required this.filterData,
    required this.selectedTitleID,
    required this.activeFilterIds,
    required this.selectedFilterIds,
    required this.onSearchCompleted,
    this.onCloseOverlay,
    required this.searchTerm,
    required this.mayLoad,
    required this.resultCount,
  });

  final double? width;
  final double? height;
  final dynamic filterData;
  final int selectedTitleID;
  final List<int> activeFilterIds;
  final List<int>? selectedFilterIds;
  final Future Function(List<int> activeFilterIds, int resultCount)
      onSearchCompleted;
  final Future Function(List<int>? selectedFilterIds)? onCloseOverlay;
  final String? searchTerm;
  final bool mayLoad;
  final int? resultCount;

  @override
  ConsumerState<FilterOverlayWidget> createState() =>
      _FilterOverlayWidgetState();
}

class _FilterOverlayWidgetState extends ConsumerState<FilterOverlayWidget>
    with WidgetsBindingObserver {
  /// =========================================================================
  /// STATE VARIABLES
  /// =========================================================================

  /// Filter lookup map for O(1) access to any filter by ID
  final Map<int, dynamic> _filterMap = {};

  /// Currently selected filter IDs (widget-local state)
  final Set<int> _selectedFilterIds = {};

  /// Currently selected category and item IDs
  int? selectedCategoryId;
  int? selectedItemId;

  /// Search state tracking
  bool _isInitialState = true;
  bool _searchPerformed = false;
  bool _receivedActiveIdsAfterSearch = true;

  /// Optimistic result count for immediate feedback
  int? _optimisticResultCount;

  /// Debounce timer for search execution
  Timer? _debounceTimer;

  /// Initial state for reset functionality
  List<int>? _initialFilterIds;
  int? _initialCategoryId;
  int? _initialItemId;

  /// Selection type tracking (neighborhood/shopping/train station)
  FilterSelectionType _currentSelectionType = FilterSelectionType.none;
  int? _selectedNeighborhoodId;

  /// =========================================================================
  /// CONSTANTS - STYLING
  /// =========================================================================

  // Base colors
  static const Color _whiteColor = Colors.white;
  static const Color _blackColor = Colors.black;
  static const Color _transparentColor = Colors.transparent;

  // Brand/accent colors
  final Color _accentColor = AppColors.accent; // Orange - active selections

  // Interactive button states (touch feedback)
  static const Color _buttonPressedColor = Color(0xFFdcdee0); // Light grey
  final Color _buttonDefaultColor = AppColors.bgSurface; // Lighter grey
  static const Color _buttonBorderColor = Color(0xFF9E9E9E); // Grey[500]

  // Column backgrounds
  final Color _leftColumnBackgroundColor = AppColors.bgSurface;
  static const Color _middleRightColumnBackgroundColor = _whiteColor;
  static const Color _categorySelectionBackgroundColor = _whiteColor;

  // Column dividers
  static const Color _columnDividerColor = _blackColor;
  static const double _columnDividerThickness = 1.0;

  // Text colors (content state)
  final Color _textEnabledColor = AppColors.textPrimary;
  static const Color _textDisabledColor = _buttonPressedColor;

  // Selected category visual accents
  final Color _selectedCategoryTextColor = AppColors.accent;
  final Color _selectedCategoryAccentBarColor = AppColors.accent;
  static const double _orangeAccentBarWidth = 2.0;
  static const double _orangeAccentBarMargin = 3.0;

  // Spacing
  static const double _itemPaddingHorizontal = 8.0;
  static const double _headerHeight = 44.0;
  static const double _closeButtonSize = 32.0;
  static const double _buttonBorderRadius = 8.0;
  static const double _filterButtonHeight = 32.0;
  static const double _footerButtonHeight = 44.0;

  // Timing
  static const Duration _debounceDuration = Duration(milliseconds: 300);

  /// =========================================================================
  /// CONSTANTS - CATEGORY IDs
  /// =========================================================================

  static const int _neighborhoodCategoryId = 5;
  static const int _shoppingAreaCategoryId = 6;
  static const int _trainStationCategoryId = 7;
  static const int _businessTypeCategoryId = 8;
  static const int _foodCategoryId = 10;

  /// =========================================================================
  /// CONSTANTS - TRANSLATION KEYS
  /// =========================================================================

  static const String _resultsSingularKey = 'search_results_singular';
  static const String _resultsPluralKey = 'search_results_plural';
  static const String _browseNearbyKey = 'search_browse_nearby';
  static const String _noResultsKey = 'search_no_results';
  static const String _resetKey = 'search_reset';

  /// =========================================================================
  /// ACCESSIBILITY HELPERS
  /// =========================================================================

  bool get _shouldReduceTextSize {
    final accessibility = ref.read(accessibilityProvider);
    return accessibility.fontScale > 1.0 || accessibility.isBoldTextEnabled;
  }

  double _adjustedFontSize(double baseSize) =>
      _shouldReduceTextSize ? baseSize - 1 : baseSize;

  /// =========================================================================
  /// LIFECYCLE
  /// =========================================================================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _handleFirstLaunchCleanup();
    _setupFilterData();

    if (widget.resultCount != null) {
      _optimisticResultCount = widget.resultCount;
    }
  }

  @override
  void didUpdateWidget(FilterOverlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    _handleDataChanges(oldWidget);
    _handleSearchChanges(oldWidget);
    _handleResultCountChanges(oldWidget);
    _handleActiveFilterChanges(oldWidget);
    _handleTitleChanges(oldWidget);
    _handleSelectedFilterChanges(oldWidget);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      FilterOverlayWidget.isFirstLaunch = true;
    }
  }

  @override
  void dispose() {
    // Sync selected filters to provider if changed
    final currentFilters = ref.read(searchStateProvider).filtersUsedForSearch;
    if (!listEquals(_selectedFilterIds.toList(), currentFilters)) {
      ref.read(searchStateProvider.notifier).setFilters(
            List<int>.from(_selectedFilterIds),
          );
    }

    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// =========================================================================
  /// INITIALIZATION
  /// =========================================================================

  void _handleFirstLaunchCleanup() {
    if (FilterOverlayWidget.isFirstLaunch) {
      _selectedFilterIds.clear();
      FilterOverlayWidget.isFirstLaunch = false;
    }
  }

  void _setupFilterData() {
    _rebuildFilterLookupMap();
    _initializeStateFromProps();
    _selectFirstCategory();
    _captureInitialState();
  }

  void _rebuildFilterLookupMap() {
    _filterMap.clear();
    final filters = _extractFiltersArray();
    _populateFilterMap(filters);
  }

  dynamic _extractFiltersArray() {
    if (widget.filterData is Map) {
      return widget.filterData['filters'];
    }
    return widget.filterData;
  }

  void _populateFilterMap(dynamic data) {
    if (data == null) return;
    final items = data is List ? data : [data];
    for (final item in items) {
      if (item != null && item is Map && item['id'] is int) {
        _filterMap[item['id'] as int] = item;
        final children = item['children'];
        if (children != null && children is List && children.isNotEmpty) {
          _populateFilterMap(children);
        }
      }
    }
  }

  void _initializeStateFromProps() {
    final hasSearchTerm = widget.searchTerm?.isNotEmpty ?? false;
    final hasSelectedFilters = widget.selectedFilterIds != null &&
        widget.selectedFilterIds!.isNotEmpty;
    _isInitialState = !hasSearchTerm && !hasSelectedFilters;
    _searchPerformed = !_isInitialState;
    _initialFilterIds = List<int>.from(widget.selectedFilterIds ?? []);
    if (widget.selectedFilterIds != null) {
      _selectedFilterIds.clear();
      _selectedFilterIds.addAll(widget.selectedFilterIds!);
    }
  }

  void _captureInitialState() {
    _initialCategoryId = selectedCategoryId;
    _initialItemId = selectedItemId;
  }

  /// =========================================================================
  /// WIDGET UPDATE HANDLERS
  /// =========================================================================

  void _handleDataChanges(FilterOverlayWidget oldWidget) {
    if (oldWidget.filterData != widget.filterData) {
      _setupFilterData();
    }
  }

  void _handleSearchChanges(FilterOverlayWidget oldWidget) {
    final isNewSearch = widget.searchTerm != oldWidget.searchTerm &&
        (widget.searchTerm?.isNotEmpty ?? false);
    if (isNewSearch) {
      _receivedActiveIdsAfterSearch = false;
    }
    _searchPerformed = (widget.searchTerm?.isNotEmpty ?? false) ||
        (widget.selectedFilterIds != null &&
            widget.selectedFilterIds!.isNotEmpty);
    _isInitialState = !_searchPerformed;
  }

  void _handleResultCountChanges(FilterOverlayWidget oldWidget) {
    if (oldWidget.resultCount != widget.resultCount &&
        widget.resultCount != null) {
      setState(() {
          _optimisticResultCount = widget.resultCount;
      });
    }
  }

  void _handleActiveFilterChanges(FilterOverlayWidget oldWidget) {
    if (!listEquals(oldWidget.activeFilterIds, widget.activeFilterIds)) {
      _receivedActiveIdsAfterSearch = true;
      setState(() {});
    }
  }

  void _handleTitleChanges(FilterOverlayWidget oldWidget) {
    if (oldWidget.selectedTitleID != widget.selectedTitleID) {
      _selectFirstCategory();
      _captureInitialState();
    }
  }

  void _handleSelectedFilterChanges(FilterOverlayWidget oldWidget) {
    if (!listEquals(oldWidget.selectedFilterIds, widget.selectedFilterIds)) {
      _selectedFilterIds.clear();
      if (widget.selectedFilterIds != null) {
        _selectedFilterIds.addAll(widget.selectedFilterIds!);
      }
    }
  }

  /// =========================================================================
  /// FILTER DATA ACCESS
  /// =========================================================================

  dynamic _findFilterById(int filterId) => _filterMap[filterId];

  dynamic _findTitle(int titleId) {
    final filters = _extractFiltersArray();
    final matchingTitles =
        (filters as List?)?.where((title) => title['id'] == titleId).toList();
    return (matchingTitles?.isNotEmpty ?? false) ? matchingTitles?.first : null;
  }

  List<dynamic> _getChildren(dynamic parent) {
    if (parent == null) return [];
    return parent['children'] ?? [];
  }

  List<dynamic> _getCategories(int titleId) {
    final title = _findTitle(titleId);
    if (title == null) return [];
    return _sortItems(title['children'] ?? []);
  }

  List<dynamic> _getItems(int categoryId) {
    final items = _getItemsWithoutActiveFiltering(categoryId);
    if (_selectedNeighborhoodId == null) return items;

    if (categoryId == _shoppingAreaCategoryId) {
      return items
          .where((item) => widget.activeFilterIds.contains(item['id'] as int?))
          .toList();
    } else if (categoryId == _trainStationCategoryId) {
      return items
          .where((item) =>
              item['neighbourhood_id_1'] == _selectedNeighborhoodId ||
              item['neighbourhood_id_2'] == _selectedNeighborhoodId)
          .toList();
    }
    return items;
  }

  List<dynamic> _getItemsWithoutActiveFiltering(int categoryId) {
    final filters = _extractFiltersArray();
    for (var title in (filters as List? ?? [])) {
      final categories = _getChildren(title);
      final matchingCategories = categories
          .where((cat) => cat['id'] == categoryId && cat['type'] == 'category')
          .toList();
      if (matchingCategories.isNotEmpty) {
        final category = matchingCategories.first;
        return _sortItems(category['children'] ?? [], parentId: categoryId);
      }
    }
    return [];
  }

  List<dynamic> _getSubItems(int itemId) {
    final filters = _extractFiltersArray();

    for (var title in (filters as List? ?? [])) {
      for (var category in _getChildren(title)) {
        final items = _getChildren(category);
        final matchingItems = items
            .where((it) => it['id'] == itemId && it['type'] == 'item')
            .toList();

        if (matchingItems.isNotEmpty) {
          final item = matchingItems.first;
          final children = item['children'] ?? [];
          return _sortItems(children, parentId: category['id']);
        }
      }
    }

    return [];
  }

  int? _findExpandedItemInCategory(int categoryId) {
    final items = _getItems(categoryId);

    for (var item in items) {
      final itemId = item['id'] as int;
      final subitems = _getSubItems(itemId);

      if (subitems.isEmpty) continue;

      final hasSelectedSubitem = subitems.any(
        (subitem) => _selectedFilterIds.contains(subitem['id'] as int),
      );

      if (hasSelectedSubitem) {
        return itemId;
      }
    }

    return null;
  }

  List<dynamic> _sortItems(List<dynamic> items, {int? parentId}) {
    return List<dynamic>.from(items)
      ..sort((a, b) {
        final shouldSortAlphabetically = parentId == _neighborhoodCategoryId ||
            parentId == _foodCategoryId ||
            parentId == _trainStationCategoryId ||
            _isDietaryParent(parentId);
        if (shouldSortAlphabetically) {
          return (a['name'] ?? '').compareTo(b['name'] ?? '');
        }
        final aOrder = a['display_order'];
        final bOrder = b['display_order'];
        if (aOrder != null && bOrder != null) return aOrder.compareTo(bOrder);
        if (aOrder != null) return -1;
        if (bOrder != null) return 1;
        return (a['name'] ?? '').compareTo(b['name'] ?? '');
      });
  }

  bool _isDietaryParent(int? parentId) {
    if (parentId == null) return false;
    return parentId >= 592 && parentId <= 597;
  }

  /// =========================================================================
  /// FILTER TYPE DETECTION
  /// =========================================================================

  FilterSelectionType _getFilterSelectionType(int filterId) {
    final filter = _findFilterById(filterId);
    if (filter == null) return FilterSelectionType.none;
    final parentId = filter['parent_id'];
    if (parentId == _trainStationCategoryId) {
      return FilterSelectionType.trainStation;
    }
    if (parentId == _shoppingAreaCategoryId) {
      return FilterSelectionType.shoppingArea;
    }
    if (filter['is_neighborhood'] == true) {
      return FilterSelectionType.neighborhood;
    }
    return FilterSelectionType.none;
  }

  bool _isSearchableParentItem(int filterId) {
    final filter = _findFilterById(filterId);
    return filter?['parent_id'] == _businessTypeCategoryId;
  }

  bool _shouldMarkCategoryInactive(int categoryId) {
    if (_currentSelectionType == FilterSelectionType.shoppingArea &&
        categoryId == _trainStationCategoryId) {
      return true;
    }
    if (_currentSelectionType == FilterSelectionType.trainStation &&
        categoryId == _shoppingAreaCategoryId) {
      return true;
    }
    return false;
  }

  /// =========================================================================
  /// ACTIVE STATE DETECTION
  /// =========================================================================

  bool _hasActiveChildren(int parentId, String filterType) {
    if (_isInitialState) return true;
    if (!_receivedActiveIdsAfterSearch &&
        widget.searchTerm?.isNotEmpty == true) {
      return true;
    }
    if (filterType == 'category' && parentId == _trainStationCategoryId) {
      return _hasActiveTrainStations(parentId);
    }
    if (widget.activeFilterIds.isEmpty && _searchPerformed) {
      return _hasActiveChildrenDuringEmptySearch(parentId, filterType);
    }
    return _hasActiveChildrenStandard(parentId, filterType);
  }

  bool _hasActiveTrainStations(int categoryId) {
    if (_selectedNeighborhoodId == null) return true;
    final allTrainStations = _getItemsWithoutActiveFiltering(categoryId);
    return allTrainStations.any((station) =>
        station['neighbourhood_id_1'] == _selectedNeighborhoodId ||
        station['neighbourhood_id_2'] == _selectedNeighborhoodId);
  }

  bool _hasActiveChildrenDuringEmptySearch(int parentId, String filterType) {
    if (filterType == 'category') {
      final items = _getItems(parentId);
      return items.any((item) {
        final itemId = item['id'] as int;
        if (_selectedFilterIds.contains(itemId) &&
            _getSubItems(itemId).isEmpty) {
          return true;
        }
        return _getSubItems(itemId).any(
            (subitem) => _selectedFilterIds.contains(subitem['id'] as int));
      });
    }
    return _selectedFilterIds.contains(parentId);
  }

  bool _hasActiveChildrenStandard(int parentId, String filterType) {
    switch (filterType) {
      case 'category':
        final items = _getItems(parentId);
        if (items.isEmpty) return false;
        return items
            .any((item) => _hasActiveChildren(item['id'] as int, 'item'));
      case 'item':
        final subitems = _getSubItems(parentId);
        if (subitems.isNotEmpty) {
          return subitems.any((subitem) =>
              widget.activeFilterIds.contains(subitem['id'] as int));
        } else {
          final filter = _findFilterById(parentId);
          if (filter != null &&
              filter['parent_id'] == _trainStationCategoryId) {
            return true;
          }
          return widget.activeFilterIds.contains(parentId);
        }
      case 'sub_item':
        return widget.activeFilterIds.contains(parentId);
      default:
        return false;
    }
  }

  /// =========================================================================
  /// FILTER SELECTION HANDLERS
  /// =========================================================================

  Future<void> _handleFilterSelection(dynamic filter) async {
    final filterId = filter['id'] as int;
    final filterType = filter['type'] as String;
    final hasSubitems = _getSubItems(filterId).isNotEmpty;

    setState(() {
      _processFilterSelection(filterId, filterType, hasSubitems);
    });

    ref.read(searchStateProvider.notifier).setFilters(
          List<int>.from(_selectedFilterIds),
        );

    _triggerCallbackIfNeeded(filterType, hasSubitems, filterId);
  }

  void _processFilterSelection(
      int filterId, String filterType, bool hasSubitems) {
    switch (filterType) {
      case 'category':
        _handleCategorySelection(filterId);
        break;
      case 'item':
        _handleItemSelection(filterId, hasSubitems);
        break;
      case 'sub_item':
        _toggleFilter(filterId);
        break;
    }
  }

  void _handleCategorySelection(int categoryId) {
    selectedCategoryId = categoryId;
    selectedItemId = _findExpandedItemInCategory(categoryId);
  }

  void _handleItemSelection(int itemId, bool hasSubitems) {
    if (_isSearchableParentItem(itemId)) {
      final isCurrentlySelected = _selectedFilterIds.contains(itemId);
      final isColumnThreeShowing = selectedItemId == itemId;

      if (isCurrentlySelected) {
        // Deselecting - remove parent and all sub-items, hide column 3
        _toggleFilter(itemId);
        if (hasSubitems) {
          _removeAllSubItems(itemId);
          if (isColumnThreeShowing) {
            selectedItemId = null;
          }
        }
      } else {
        // Selecting - add parent
        _toggleFilter(itemId);
        // Only show column 3 if it's not already showing
        if (hasSubitems && !isColumnThreeShowing) {
          selectedItemId = itemId;
        }
      }
    } else if (hasSubitems) {
      selectedItemId = itemId == selectedItemId ? null : itemId;
    } else {
      _handleSpecialFilterTypeSelection(itemId);
    }
  }

  void _handleSpecialFilterTypeSelection(int filterId) {
    final selectionType = _getFilterSelectionType(filterId);
    switch (selectionType) {
      case FilterSelectionType.trainStation:
        _handleTrainStationSelection(filterId);
        break;
      case FilterSelectionType.shoppingArea:
        _handleShoppingAreaSelection(filterId);
        break;
      case FilterSelectionType.neighborhood:
        _handleNeighborhoodSelection(filterId);
        break;
      default:
        _toggleFilter(filterId);
        break;
    }
  }

  void _handleTrainStationSelection(int filterId) {
    if (_selectedFilterIds.contains(filterId)) {
      _selectedFilterIds.remove(filterId);
      _currentSelectionType = _selectedNeighborhoodId != null
          ? FilterSelectionType.neighborhood
          : FilterSelectionType.none;
    } else {
      _removeConflictingFilters(
          [_shoppingAreaCategoryId, _trainStationCategoryId]);
      _selectedFilterIds.add(filterId);
      _currentSelectionType = FilterSelectionType.trainStation;
    }
  }

  void _removeAllSubItems(int parentItemId) {
    final subItems = _getSubItems(parentItemId);
    final subItemIds = subItems.map((subItem) => subItem['id'] as int).toList();
    _selectedFilterIds.removeAll(subItemIds);
  }

  void _handleShoppingAreaSelection(int filterId) {
    if (_selectedFilterIds.contains(filterId)) {
      _selectedFilterIds.remove(filterId);
      _currentSelectionType = _selectedNeighborhoodId != null
          ? FilterSelectionType.neighborhood
          : FilterSelectionType.none;
    } else {
      _removeConflictingFilters(
          [_trainStationCategoryId, _shoppingAreaCategoryId]);
      _selectedFilterIds.add(filterId);
      _currentSelectionType = FilterSelectionType.shoppingArea;
    }
  }

  void _handleNeighborhoodSelection(int filterId) {
    _toggleFilter(filterId);
    if (_selectedFilterIds.contains(filterId)) {
      _currentSelectionType = FilterSelectionType.neighborhood;
      _selectedNeighborhoodId = filterId;
    } else {
      _currentSelectionType = FilterSelectionType.none;
      _selectedNeighborhoodId = null;
    }
  }

  void _removeConflictingFilters(List<int> conflictingCategoryIds) {
    final toRemove = <int>[];
    for (final id in _selectedFilterIds) {
      final filter = _findFilterById(id);
      if (filter != null &&
          conflictingCategoryIds.contains(filter['parent_id'])) {
        toRemove.add(id);
      }
    }
    _selectedFilterIds.removeAll(toRemove);
  }

  void _toggleFilter(int filterId) {
    final filter = _findFilterById(filterId);

    if (filter == null) {
      debugPrint('⚠️ _toggleFilter: Filter $filterId not found in _filterMap!');
      return;
    }

    if (filter['type'] == 'item' && _getSubItems(filterId).isEmpty) {
      if (!_selectedFilterIds.contains(filterId) && selectedItemId != null) {
        selectedItemId = null;
      }
    }

    final wasSelected = _selectedFilterIds.contains(filterId);

    _selectedFilterIds.contains(filterId)
        ? _selectedFilterIds.remove(filterId)
        : _selectedFilterIds.add(filterId);

    // Auto-add category 8 parent when sub-item is selected
    if (!wasSelected && filter['type'] == 'sub_item') {
      final parentId = filter['parent_id'] as int?;
      if (parentId != null && _isSearchableParentItem(parentId)) {
        if (!_selectedFilterIds.contains(parentId)) {
          _selectedFilterIds.add(parentId);
        }
      }
    }
  }

  void _triggerCallbackIfNeeded(
      String filterType, bool hasSubitems, int filterId) {
    final shouldTrigger = (filterType == 'item' && !hasSubitems) ||
        filterType == 'sub_item' ||
        (filterType == 'item' && _isSearchableParentItem(filterId));

    if (shouldTrigger) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(_debounceDuration, () {
        _executeSearchAndTrackAnalytics();
      });
    }
  }

  /// =========================================================================
  /// SEARCH EXECUTION
  /// =========================================================================

  Future<void> _executeSearchAndTrackAnalytics() async {
    try {
      // Generate filter session ID if needed
      final searchState = ref.read(searchStateProvider);
      if (searchState.currentFilterSessionId.isEmpty) {
        ref.read(searchStateProvider.notifier).generateNewFilterSessionId();

        // Track filter session start
        final newSearchState = ref.read(searchStateProvider);
        unawaited(ApiService.instance.postAnalytics(
          eventType: 'filter_session_started',
          deviceId: '', // ApiService handles defaults
          sessionId: '', // ApiService handles defaults
          userId: '', // ApiService handles defaults
          timestamp: DateTime.now().toIso8601String(),
          eventData: {
            'filterSessionId': newSearchState.currentFilterSessionId,
            'entryPoint': 'filter_overlay',
          },
        ));
      }

      // Detect train station filter
      final trainStationInfo = _detectTrainStationFilter();
      final trainStationId = trainStationInfo.$2;

      // Execute search via API
      final searchTerm = ref.read(searchStateProvider).currentSearchText;
      final languageCode = Localizations.localeOf(context).languageCode;

      final result = await ApiService.instance.search(
        searchInput: searchTerm,
        filters: List<int>.from(_selectedFilterIds),
        filtersUsedForSearch: List<int>.from(_selectedFilterIds),
        cityId: AppConstants.kDefaultCityId.toString(),
        languageCode: languageCode,
        selectedStation: trainStationId,
      );

      if (result.succeeded) {
        final activeFilterIds = <int>[];
        final rawActiveFilters = result.jsonBody['activeids'];

        if (rawActiveFilters is List) {
          for (final item in rawActiveFilters) {
            if (item is int) {
              activeFilterIds.add(item);
            }
          }
        }

        final resultCount = result.jsonBody['resultCount'] is int
            ? result.jsonBody['resultCount'] as int
            : 0;

        if (mounted) {
          setState(() {
            _optimisticResultCount = resultCount;
                });
        }

        await widget.onSearchCompleted(activeFilterIds, resultCount);
      }
    } catch (e) {
      debugPrint('❌ FilterOverlay: Error in _executeSearchAndTrackAnalytics: $e');
    }
  }

  (bool, int?) _detectTrainStationFilter() {
    for (int filterId in _selectedFilterIds) {
      final filter = _findFilterById(filterId);
      if (filter != null && filter['parent_id'] == _trainStationCategoryId) {
        return (true, filterId);
      }
    }
    return (false, null);
  }

  /// =========================================================================
  /// FILTER REMOVAL
  /// =========================================================================

  Future<void> _handleFilterRemoval(int filterId) async {
    setState(() {
      // If removing a category 8 parent, also remove its sub-items
      if (_isSearchableParentItem(filterId)) {
        _removeAllSubItems(filterId);
      }

      _updateSelectionTypeOnRemoval(filterId);
      _selectedFilterIds.remove(filterId);
    });

    ref.read(searchStateProvider.notifier).setFilters(
          List<int>.from(_selectedFilterIds),
        );

    await _executeSearchAndTrackAnalytics();
  }

  void _updateSelectionTypeOnRemoval(int filterId) {
    final selectionType = _getFilterSelectionType(filterId);
    if (selectionType == FilterSelectionType.neighborhood) {
      _selectedNeighborhoodId = null;
      _reevaluateSelectionType();
    }
    if ((selectionType == FilterSelectionType.shoppingArea ||
            selectionType == FilterSelectionType.trainStation) &&
        _selectedNeighborhoodId == null) {
      _currentSelectionType = FilterSelectionType.none;
    }
  }

  void _reevaluateSelectionType() {
    if (_selectedFilterIds.any((id) =>
        _getFilterSelectionType(id) == FilterSelectionType.shoppingArea)) {
      _currentSelectionType = FilterSelectionType.shoppingArea;
    } else if (_selectedFilterIds.any((id) =>
        _getFilterSelectionType(id) == FilterSelectionType.trainStation)) {
      _currentSelectionType = FilterSelectionType.trainStation;
    } else {
      _currentSelectionType = FilterSelectionType.none;
    }
  }

  /// =========================================================================
  /// RESET AND CLOSE
  /// =========================================================================

  Future<void> _handleReset() async {
    setState(() {
      _selectedFilterIds.clear();
      _initialFilterIds = [];
      _initialCategoryId = null;
      _initialItemId = null;
      _currentSelectionType = FilterSelectionType.none;
      _selectedNeighborhoodId = null;

      if (selectedItemId != null && _isSearchableParentItem(selectedItemId!)) {
        selectedItemId = null;
      }
    });

    ref.read(searchStateProvider.notifier).setFilters(<int>[]);

    await _executeSearchAndTrackAnalytics();
  }

  Future<void> _handleCloseButton() async {
    setState(() {
      _selectedFilterIds.clear();
      if (_initialFilterIds != null && _initialFilterIds!.isNotEmpty) {
        _selectedFilterIds.addAll(_initialFilterIds!);
      }
      selectedCategoryId = _initialCategoryId;
      selectedItemId = _initialItemId;
    });

    ref.read(searchStateProvider.notifier).setFilters(
          List<int>.from(_selectedFilterIds),
        );

    widget.onCloseOverlay?.call(List<int>.from(_selectedFilterIds));

    await _executeSearchAndTrackAnalytics();
  }

  void _selectFirstCategory() {
    final categories = _getCategories(widget.selectedTitleID);
    if (categories.isEmpty) {
      setState(() {
        selectedCategoryId = null;
        selectedItemId = null;
      });
      return;
    }
    int? firstActiveCategory;
    for (var category in categories) {
      final categoryId = category['id'] as int;
      if (_hasActiveChildren(categoryId, 'category')) {
        firstActiveCategory = categoryId;
        break;
      }
    }

    final newCategoryId =
        firstActiveCategory ?? (categories.first['id'] as int);
    final expandedItemId = _findExpandedItemInCategory(newCategoryId);

    setState(() {
      selectedCategoryId = newCategoryId;
      selectedItemId = expandedItemId;
    });
  }

  /// =========================================================================
  /// UI TEXT HELPERS
  /// =========================================================================

  String _getUIText(String key) {
    return td(ref, key);
  }

  int? _currentCount() => _optimisticResultCount ?? widget.resultCount;

  String _getResultsButtonText() {
    if (widget.searchTerm?.isNotEmpty == true) {
      return _getSearchResultsText();
    }
    return _getFilterResultsText();
  }

  String _getSearchResultsText() {
    final count = _currentCount();
    if (count == null || count == 0) {
      return _getUIText(_noResultsKey);
    }
    if (count == 1) {
      return _getUIText(_resultsSingularKey).replaceAll('{{count}}', '1');
    }
    return _getUIText(_resultsPluralKey).replaceAll('{{count}}', '$count');
  }

  String _getFilterResultsText() {
    final count = _currentCount();
    if (_selectedFilterIds.isEmpty) {
      return _getUIText(_browseNearbyKey);
    }
    if (count == null) {
      return _getUIText(_browseNearbyKey);
    }
    if (count == 0) {
      return _getUIText(_noResultsKey);
    }
    if (count == 1) {
      return _getUIText(_resultsSingularKey).replaceAll('{{count}}', '1');
    }
    return _getUIText(_resultsPluralKey).replaceAll('{{count}}', '$count');
  }

  String _getDisplayName(dynamic filter) {
    if (filter == null) return '';

    final filterId = filter['id'] as int?;
    final parentId = filter['parent_id'] as int?;
    final name = filter['name'] as String? ?? '';

    if (filterId == null) return name;

    final filterIdStr = filterId.toString();
    final isDietaryComposite = filterIdStr.length == 6 &&
        filterId != 592 &&
        (filterIdStr.startsWith('593') ||
            filterIdStr.startsWith('594') ||
            filterIdStr.startsWith('595') ||
            filterIdStr.startsWith('596') ||
            filterIdStr.startsWith('597'));

    if (isDietaryComposite && parentId != null) {
      final parentFilter = _findFilterById(parentId);
      final parentName = parentFilter?['name'] as String?;

      if (parentName != null) {
        final lowercasedName = _lowercaseFirstLetter(name);
        return '$parentName $lowercasedName';
      }
    }

    return name;
  }

  String _lowercaseFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toLowerCase() + text.substring(1);
  }

  /// =========================================================================
  /// BUILD METHOD
  /// =========================================================================

  @override
  Widget build(BuildContext context) {
    if (!widget.mayLoad) {
      return const SizedBox.shrink();
    }

    return Container(
      color: _whiteColor,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildHeader(),
          _buildFilterColumns(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: _headerHeight,
      child: _buildSelectedFiltersRow(),
    );
  }

  Widget _buildFilterColumns() {
    return Expanded(
      child: Column(
        children: [
          // Top border spanning all three columns
          Container(
            height: 1,
            color: _columnDividerColor,
          ),
          // The three columns
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left column (categories) - grey background
                Expanded(
                  flex: 1,
                  child: _buildFilterColumn(
                    _getCategories(widget.selectedTitleID),
                    'category',
                  ),
                ),
                // Divider between left and middle
                Container(
                  width: _columnDividerThickness,
                  color: _columnDividerColor,
                ),
                // Middle column (items) - white background
                Expanded(
                  flex: 1,
                  child: _buildFilterColumn(
                    selectedCategoryId != null
                        ? _getItems(selectedCategoryId!)
                        : [],
                    'item',
                  ),
                ),
                // Divider between middle and right
                Container(
                  width: _columnDividerThickness,
                  color: _columnDividerColor,
                ),
                // Right column (sub-items) - white background
                Expanded(
                  flex: 1,
                  child: _buildFilterColumn(
                    selectedItemId != null ? _getSubItems(selectedItemId!) : [],
                    'sub_item',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Row(
        children: [
          Expanded(child: _buildViewResultsButton()),
          const SizedBox(width: 6),
          Expanded(child: _buildResetButton()),
        ],
      ),
    );
  }

  /// =========================================================================
  /// HEADER WIDGETS
  /// =========================================================================

  Widget _buildSelectedFiltersRow() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildCloseButtonWithGradient(),
        _buildSelectedFiltersScrollView(),
      ],
    );
  }

  Widget _buildCloseButtonWithGradient() {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: Center(
        child: Container(
          width: 44,
          height: _filterButtonHeight,
          padding: const EdgeInsets.only(right: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context)
                    .scaffoldBackgroundColor
                    .withValues(alpha: 0.9),
                Theme.of(context)
                    .scaffoldBackgroundColor
                    .withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.7, 0.85, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: _whiteColor.withValues(alpha: 0.04),
                blurRadius: 2,
                offset: const Offset(2, 0),
                spreadRadius: 1,
              ),
            ],
          ),
          child: _buildCloseButton(),
        ),
      ),
    );
  }

  Widget _buildSelectedFiltersScrollView() {
    return Positioned(
      left: 46,
      top: 0,
      bottom: 0,
      right: 0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: _buildSelectedFilterButtons(),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return ElevatedButton(
      onPressed: widget.onCloseOverlay != null ? _handleCloseButton : null,
      style: _getCloseButtonStyle(),
      child: Center(
        child: Icon(Icons.close, size: 18, color: _textEnabledColor),
      ),
    );
  }

  ButtonStyle _getCloseButtonStyle() {
    return ButtonStyle(
      padding: WidgetStateProperty.all(EdgeInsets.zero),
      fixedSize: WidgetStateProperty.all(
          const Size(_closeButtonSize, _closeButtonSize)),
      minimumSize: WidgetStateProperty.all(
          const Size(_closeButtonSize, _closeButtonSize)),
      shape: WidgetStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonBorderRadius),
          side: const BorderSide(color: _buttonBorderColor, width: 1),
        ),
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) =>
          states.contains(WidgetState.pressed)
              ? _buttonPressedColor
              : _buttonDefaultColor),
      elevation: WidgetStateProperty.all(0),
      overlayColor: WidgetStateProperty.all(_transparentColor),
    );
  }

  List<Widget> _buildSelectedFilterButtons() {
    if (_selectedFilterIds.isEmpty) return [];

    // IDs that get "Parent + subitem" treatment
    const parentPlusSubitemIds = {585, 586, 158, 159, 588};

    // Group category 8 by parent
    final cat8Parents = <int, List<int>>{}; // parentId -> [subitemIds]
    final otherFilters = <int>[];

    for (final filterId in _selectedFilterIds) {
      final filter = _findFilterById(filterId);
      if (filter == null) continue;

      final parentId = filter['parent_id'] as int?;

      // Check if this is a category 8 parent
      if (_isSearchableParentItem(filterId)) {
        cat8Parents.putIfAbsent(filterId, () => []);
      }
      // Check if this is a category 8 sub-item
      else if (filter['type'] == 'sub_item' &&
          parentId != null &&
          _isSearchableParentItem(parentId)) {
        cat8Parents.putIfAbsent(parentId, () => []);
        cat8Parents[parentId]!.add(filterId);
      } else {
        otherFilters.add(filterId);
      }
    }

    final widgets = <Widget>[];

    // Build category 8 buttons
    for (final entry in cat8Parents.entries) {
      final parentId = entry.key;
      final subitemIds = entry.value;

      if (subitemIds.isEmpty) {
        // Parent only - show parent button
        widgets.add(_buildSelectedFilterButton(parentId));
      } else {
        final hasParentPlusSubitems =
            subitemIds.any((id) => parentPlusSubitemIds.contains(id));

        if (hasParentPlusSubitems) {
          // Behavior 1: Combined button(s)
          final behavior1Ids = subitemIds
              .where((id) => parentPlusSubitemIds.contains(id))
              .toList();
          final behavior2Ids = subitemIds
              .where((id) => !parentPlusSubitemIds.contains(id))
              .toList();

          // Add combined button for behavior 1 items
          widgets.add(_buildCombinedCat8Button(parentId, behavior1Ids));

          // Add individual buttons for behavior 2 items
          for (final subId in behavior2Ids) {
            widgets.add(_buildSelectedFilterButton(subId));
          }
        } else {
          // Behavior 2: Subitem only buttons
          for (final subId in subitemIds) {
            widgets.add(_buildSelectedFilterButton(subId));
          }
        }
      }
    }

    // Build other filter buttons
    for (final filterId in otherFilters) {
      widgets.add(_buildSelectedFilterButton(filterId));
    }

    return widgets;
  }

  Widget _buildCombinedCat8Button(int parentId, List<int> subitemIds) {
    final parentFilter = _findFilterById(parentId);
    final parentName = parentFilter?['name'] as String? ?? '';

    // Build combined name
    final subitemNames = subitemIds
        .map((id) => _findFilterById(id)?['name'] as String?)
        .where((name) => name != null)
        .map((name) => _lowercaseFirstLetter(name!))
        .toList();

    String displayName;
    if (parentId == 55) {
      // Food truck uses dash
      displayName = '$parentName - ${subitemNames.join(' and ')}';
    } else {
      // Bakery, Café - first item keeps its prefix, subsequent items drop "with"
      final firstSubitem = subitemNames.first;
      final remainingSubitems = subitemNames.skip(1).map((name) {
        return name.startsWith('with ') ? name.substring(5) : name;
      }).toList();

      final allSubitems = [firstSubitem, ...remainingSubitems].join(' and ');
      displayName = '$parentName $allSubitems';
    }

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: SizedBox(
        height: _filterButtonHeight,
        child: ElevatedButton(
          onPressed: () => _handleCombinedCat8Removal(parentId, subitemIds),
          style: _getFilterButtonStyle(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayName,
                style: TextStyle(
                  fontSize: _adjustedFontSize(12),
                  fontWeight: FontWeight.w400,
                  color: _textEnabledColor,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.close, size: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCombinedCat8Removal(
      int parentId, List<int> subitemIds) async {
    setState(() {
      // Remove all sub-items in this combined button
      _selectedFilterIds.removeAll(subitemIds);
    });

    ref.read(searchStateProvider.notifier).setFilters(
          List<int>.from(_selectedFilterIds),
        );

    await _executeSearchAndTrackAnalytics();
  }

  Widget _buildSelectedFilterButton(int filterId) {
    final filter = _findFilterById(filterId);
    if (filter == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: SizedBox(
        height: _filterButtonHeight,
        child: ElevatedButton(
          onPressed: () => _handleFilterRemoval(filterId),
          style: _getFilterButtonStyle(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getDisplayName(filter),
                style: TextStyle(
                    fontSize: _adjustedFontSize(12),
                    fontWeight: FontWeight.w400,
                    color: _textEnabledColor),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.close, size: 12),
            ],
          ),
        ),
      ),
    );
  }

  ButtonStyle _getFilterButtonStyle() {
    return ButtonStyle(
      padding:
          WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 12)),
      minimumSize: WidgetStateProperty.all(const Size(0, _filterButtonHeight)),
      shape: WidgetStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonBorderRadius),
          side: const BorderSide(color: _buttonBorderColor, width: 1),
        ),
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) =>
          states.contains(WidgetState.pressed)
              ? _buttonPressedColor
              : _buttonDefaultColor),
      elevation: WidgetStateProperty.all(0),
      overlayColor: WidgetStateProperty.all(_transparentColor),
    );
  }

  /// =========================================================================
  /// FILTER COLUMN WIDGETS
  /// =========================================================================

  Widget _buildFilterColumn(List<dynamic> filters, String filterType) {
    // Apply grey background only to left column (categories)
    final backgroundColor = filterType == 'category'
        ? _leftColumnBackgroundColor
        : _middleRightColumnBackgroundColor;

    return Container(
      color: backgroundColor,
      child: ListView.builder(
        padding: _getColumnPadding(filterType),
        itemCount: filters.length,
        itemBuilder: (context, index) =>
            _buildFilterItem(filters[index], filterType),
      ),
    );
  }

  EdgeInsets _getColumnPadding(String filterType) {
    if (filterType == 'category') {
      return const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 8);
    } else {
      return EdgeInsets.only(
        left: 0,
        right: filterType == 'item' ? 7 : 0,
        top: 0,
        bottom: 8,
      );
    }
  }

  Widget _buildFilterItem(dynamic filter, String filterType) {
    final filterId = filter['id'] as int;
    final isInactiveFromSelection =
        filterType == 'category' && _shouldMarkCategoryInactive(filterId);
    final isActive =
        !isInactiveFromSelection && _hasActiveChildren(filterId, filterType);
    final isSelected = _isFilterSelected(filterId, filterType);
    final displayText = _getFilterDisplayText(filter, filterId, filterType);

    // Special handling for left column categories
    if (filterType == 'category' && isSelected) {
      return GestureDetector(
        onTap: isActive ? () => _handleFilterSelection(filter) : null,
        child: Stack(
          children: [
            // White background box for selected category
            Container(
              margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              padding: const EdgeInsets.only(
                left: _itemPaddingHorizontal,
                right: _itemPaddingHorizontal,
                top: 12,
                bottom: 12,
              ),
              decoration: const BoxDecoration(
                color: _categorySelectionBackgroundColor,
                borderRadius: BorderRadius.zero,
              ),
              width: double.infinity,
              child: Text(
                displayText,
                style: _getFilterTextStyle(isSelected, isActive),
              ),
            ),
            // Orange accent bar (positioned within the left padding space)
            Positioned(
              left: _orangeAccentBarMargin,
              top: 12,
              bottom: 12,
              child: Container(
                width: _orangeAccentBarWidth,
                color: _selectedCategoryAccentBarColor,
              ),
            ),
          ],
        ),
      );
    }

    // Standard rendering for non-selected categories and all other columns
    return GestureDetector(
      onTap: isActive ? () => _handleFilterSelection(filter) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: _itemPaddingHorizontal,
          vertical: 12,
        ),
        child: Text(
          displayText,
          style: _getFilterTextStyle(isSelected, isActive),
        ),
      ),
    );
  }

  bool _isFilterSelected(int filterId, String filterType) {
    if (filterType == 'category') {
      return selectedCategoryId == filterId;
    } else if (filterType == 'item') {
      final hasSubitems = _getSubItems(filterId).isNotEmpty;
      if (hasSubitems) {
        return selectedItemId == filterId ||
            _getSubItems(filterId).any(
                (subitem) => _selectedFilterIds.contains(subitem['id'] as int));
      } else {
        return _selectedFilterIds.contains(filterId);
      }
    } else {
      return _selectedFilterIds.contains(filterId);
    }
  }

  String _getFilterDisplayText(
      dynamic filter, int filterId, String filterType) {
    String displayText = filter['name'] as String;

    if (filterType == 'category') {
      final totalSelected = _countSelectedInCategory(filterId);
      if (totalSelected > 0) {
        displayText += ' ($totalSelected)';
      }
    }
    return displayText;
  }

  int _countSelectedInCategory(int categoryId) {
    int totalSelected = 0;
    final items = _getItems(categoryId);
    for (var item in items) {
      final itemId = item['id'] as int;
      final subitems = _getSubItems(itemId);
      if (subitems.isEmpty) {
        if (_selectedFilterIds.contains(itemId)) totalSelected++;
      } else {
        if (_isSearchableParentItem(itemId) &&
            _selectedFilterIds.contains(itemId)) {
          totalSelected++;
        }
        totalSelected += subitems
            .where(
                (subitem) => _selectedFilterIds.contains(subitem['id'] as int))
            .length;
      }
    }
    return totalSelected;
  }

  TextStyle _getFilterTextStyle(bool isSelected, bool isActive) {
    const baseFontWeight = FontWeight.w400;
    // When selected, use next heavier weight (w500)
    final fontWeight = isSelected ? FontWeight.w500 : baseFontWeight;

    return TextStyle(
      fontSize: _adjustedFontSize(14),
      color: isSelected
          ? _selectedCategoryTextColor
          : (isActive ? _textEnabledColor : _textDisabledColor),
      fontWeight: fontWeight,
    );
  }

  /// =========================================================================
  /// FOOTER WIDGETS
  /// =========================================================================

  Widget _buildViewResultsButton() {
    return TextButton(
      onPressed: () {
        widget.onCloseOverlay?.call(List<int>.from(_selectedFilterIds));
      },
      style: _getViewResultsButtonStyle(),
      child: Text(_getResultsButtonText()),
    );
  }

  ButtonStyle _getViewResultsButtonStyle() {
    final count = _currentCount();
    final hasSearchResults = widget.searchTerm?.isNotEmpty == true;
    final hasValidCount = count != null && count > 0;
    final hasSelectedFilters = _selectedFilterIds.isNotEmpty;

    final shouldHighlight = hasSearchResults
        ? hasValidCount
        : (hasSelectedFilters && hasValidCount);

    return ButtonStyle(
      backgroundColor:
          WidgetStateProperty.all(shouldHighlight ? _accentColor : _whiteColor),
      foregroundColor:
          WidgetStateProperty.all(shouldHighlight ? _whiteColor : _accentColor),
      padding:
          WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 12)),
      minimumSize: WidgetStateProperty.all(const Size(0, _footerButtonHeight)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          side: BorderSide(color: _accentColor, width: 1.5),
        ),
      ),
      elevation: WidgetStateProperty.all(0),
      overlayColor: WidgetStateProperty.all(_transparentColor),
      textStyle: WidgetStateProperty.all(
        TextStyle(
          fontSize: _adjustedFontSize(16),
          fontWeight: shouldHighlight ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return TextButton(
      onPressed: _handleReset,
      style: _getResetButtonStyle(),
      child: Text(_getUIText(_resetKey)),
    );
  }

  ButtonStyle _getResetButtonStyle() {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.all(_whiteColor),
      foregroundColor: WidgetStateProperty.all(_blackColor),
      padding:
          WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 12)),
      minimumSize: WidgetStateProperty.all(const Size(0, _footerButtonHeight)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          side: const BorderSide(color: _blackColor, width: 1),
        ),
      ),
      elevation: WidgetStateProperty.all(0),
      overlayColor: WidgetStateProperty.all(_transparentColor),
      textStyle: WidgetStateProperty.all(
        TextStyle(
          fontSize: _adjustedFontSize(16),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
