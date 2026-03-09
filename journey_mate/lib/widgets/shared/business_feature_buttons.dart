import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../providers/business_providers.dart';
import '../../providers/filter_providers.dart';
import '../../providers/search_providers.dart';
import '../../services/analytics_service.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';

/// Displays business feature/preference filters as interactive buttons.
///
/// Features:
/// - Dynamic height calculation based on content
/// - Filter grouping and hiding logic
/// - Payment filters excluded
/// - Special parent filter handling
/// - Info icon for filters with descriptions
///
/// This widget is critical for helping users understand WHY a restaurant
/// matched their search criteria by displaying the business's matching filters.
class BusinessFeatureButtons extends ConsumerStatefulWidget {
  const BusinessFeatureButtons({
    super.key,
    this.width,
    this.height,
    required this.containerWidth,
    required this.onInitialCount,
    this.onFilterTap,
    this.onHeightCalculated,
  });

  final double? width;
  final double? height;
  final double containerWidth;
  final Future<void> Function(int count) onInitialCount;
  final Future<void> Function(
      int filterId, String filterName, String? filterDescription)? onFilterTap;
  final Future<void> Function(double height)? onHeightCalculated;

  @override
  ConsumerState<BusinessFeatureButtons> createState() =>
      _BusinessFeatureButtonsState();
}

class _BusinessFeatureButtonsState
    extends ConsumerState<BusinessFeatureButtons> {
  // ========================================
  // STYLE CONSTANTS
  // ========================================

  static const double _buttonHorizontalPadding = 16.0;
  static const double _buttonRowHeight = 32.0;
  static const double _buttonSpacing = 8.0;
  static const double _buttonRunSpacing = 8.0;
  static const double _iconSize = 16.0;
  static const double _iconSpacing = 6.0;
  static const double _fontSize = 14.0;
  // AppRadius.facility (9px) — unified with payment_options_widget
  static const double _borderRadius = AppRadius.facility;
  static const double _textMeasurementSafetyMargin = 4.0;

  // Text style for measurement (use unselected w300 for more conservative calculation)
  static const TextStyle _buttonTextStyleUnselected = TextStyle(
    fontSize: _fontSize,
    fontWeight: FontWeight.w300,
    fontFamily: 'Roboto',
    letterSpacing: 0,
  );

  // ========================================
  // FILTER CONFIGURATION CONSTANTS
  // ========================================

  /// Group bookings parent and children
  static const int _groupBookingsParentId = 543;
  static const List<int> _groupBookingsChildren = [
    544,
    545,
    546,
    547,
    548,
    549,
    550
  ];

  /// Payment category and all payment-related filters to exclude
  static const int _paymentCategoryId = 21;
  static const List<int> _allPaymentFilters = [
    _paymentCategoryId,
    139, 140, 141, 142, 423, 434, 435, 445, // Payment methods
    425, 426, 427, 428, 429, 430, 431, 432, // Payment card types
  ];

  /// Category 11 and all its children/grandchildren to exclude
  static const int _excludedCategoryId = 11;
  static const List<int> _excludedCategoryChildren = [
    90, 91, 92, 93, 94, 95, 96, 97, // Direct children of category 11
  ];

  /// Filter pairs for mutual exclusion (if second exists, hide first)
  static const Map<int, int> _mutuallyExclusivePairs = {
    109: 110,
    174: 173,
    176: 175,
    181: 180,
    183: 182,
  };

  /// Parent filters that should display instead of their children
  static const List<int> _specialParentFilters = [
    100, // Shared Menu
    101, // Multi-course Menu
    20, // Outdoor Seating
    22, // Private Seating
    4, // Michelin Rated
    543, // Group bookings
  ];

  /// Children to hide under special parents
  static const Map<int, List<int>> _specialParentChildren = {
    100: [110, 111, 112, 113, 114],
    101: [116, 117, 118, 119, 120],
    20: [133, 136, 137, 138],
    22: [143, 144, 145, 146, 147, 148, 149],
    4: [24, 25, 26, 27],
    543: [544, 545, 546, 547, 548, 549, 550],
  };

  // Flattened list for quick lookups
  static final List<int> _allSpecialParentChildren =
      _specialParentChildren.values.expand((list) => list).toList();

  // ========================================
  // LIFECYCLE METHODS
  // ========================================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateAndNotifyMetrics();
    });
  }

  @override
  void didUpdateWidget(covariant BusinessFeatureButtons oldWidget) {
    super.didUpdateWidget(oldWidget);

    final dataChanged = oldWidget.containerWidth != widget.containerWidth;

    if (dataChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateAndNotifyMetrics();
      });
    }
  }

  // ========================================
  // METRICS CALCULATION
  // ========================================

  /// Calculates filter count and required height, then notifies parent.
  Future<void> _calculateAndNotifyMetrics() async {
    try {
      final organizedFilters = _getOrganizedFilters();
      debugPrint(
          '📋 Filters to display: ${organizedFilters.map((f) => f['name']).toList()}');

      await widget.onInitialCount(organizedFilters.length);

      final calculatedHeight = _calculateRequiredHeight(
        organizedFilters,
        widget.containerWidth,
      );

      await widget.onHeightCalculated?.call(calculatedHeight);
    } catch (e) {
      debugPrint('Error in _calculateAndNotifyMetrics: $e');
      await widget.onInitialCount(0);
      await widget.onHeightCalculated?.call(0.0);
    }
  }

  /// Measures exact text width using TextPainter.
  double _measureTextWidth(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: ui.TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    return textPainter.size.width;
  }

  /// Calculates exact button width including padding and optional icon.
  double _calculateButtonWidth(int filterId, String filterName) {
    // Use unselected style for measurement (more conservative)
    double width = _measureTextWidth(filterName, _buttonTextStyleUnselected);
    width += _buttonHorizontalPadding * 2;

    if (_hasFilterDescription(filterId)) {
      width += _iconSpacing + _iconSize;
    }

    width += _textMeasurementSafetyMargin;
    return width;
  }

  /// Calculates total height required for filter buttons in wrap layout.
  double _calculateRequiredHeight(
    List<Map<String, dynamic>> filters,
    double containerWidth,
  ) {
    if (filters.isEmpty) return 0.0;

    double currentRowWidth = 0;
    int rowCount = 1;

    for (final filter in filters) {
      final filterId = filter['filter_id'] as int? ?? 0;
      final filterName = _getDisplayName(filter);
      final buttonWidth = _calculateButtonWidth(filterId, filterName);

      // Calculate space needed: include spacing if not first item on row
      final spaceNeeded =
          currentRowWidth > 0 ? buttonWidth + _buttonSpacing : buttonWidth;

      // Check if button fits on current row
      if (currentRowWidth + spaceNeeded > containerWidth) {
        rowCount++;
        currentRowWidth = buttonWidth;
      } else {
        currentRowWidth += spaceNeeded;
      }
    }

    double totalHeight = rowCount * _buttonRowHeight;
    if (rowCount > 1) {
      totalHeight += (rowCount - 1) * _buttonRunSpacing;
    }

    debugPrint(
        '📐 Height calc: $rowCount rows, ${filters.length} filters, height=$totalHeight, containerWidth=$containerWidth');

    return totalHeight;
  }

  // ========================================
  // FILTER DATA PROCESSING
  // ========================================

  /// Checks if a filter ID should be excluded (payment or category 11 related).
  bool _isExcludedFilter(int filterId, int? parentId) {
    // Exclude payment filters
    if (_allPaymentFilters.contains(filterId)) return true;

    // Exclude category 11 itself
    if (filterId == _excludedCategoryId) return true;

    // Exclude direct children of category 11 (90-97)
    if (_excludedCategoryChildren.contains(filterId)) return true;

    // Exclude grandchildren (items with parent_id 90-97)
    if (parentId != null && _excludedCategoryChildren.contains(parentId)) {
      return true;
    }

    return false;
  }

  /// Flattens hierarchical filter structure into a list.
  List<Map<String, dynamic>> _flattenFilters(List<dynamic> filters) {
    final flatList = <Map<String, dynamic>>[];

    void traverse(
      dynamic node, {
      int? parentId,
      String? parentName,
    }) {
      if (node == null || node is! Map<String, dynamic>) return;

      final nodeId = node['id'] as int?;
      final nodeType = node['type'] as String?;
      final nodeName = node['name'] as String?;
      final children = node['children'] as List<dynamic>?;
      final hasChildren = children != null && children.isNotEmpty;

      // Skip non-Preferences title nodes
      if (nodeType == 'title' && nodeId != 3) return;

      // Skip excluded categories and their entire subtrees
      if (nodeId != null && _isExcludedFilter(nodeId, parentId)) return;

      final isSpecialParent =
          nodeId != null && _specialParentFilters.contains(nodeId);

      // Add item/sub_item nodes (excluding payment and category 11 filters)
      if ((nodeType == 'item' || nodeType == 'sub_item') &&
          nodeId != null &&
          nodeName != null &&
          !_isExcludedFilter(nodeId, parentId)) {
        // Add if: sub_item, parent without children, or special parent
        if (nodeType == 'sub_item' || !hasChildren || isSpecialParent) {
          flatList.add({
            'filter_id': nodeId,
            'name': nodeName,
            'parent_id': parentId,
            'parent_name': parentName,
            'filter_type': nodeType,
            'has_children': hasChildren,
          });
        }
      }

      // Process children
      if (hasChildren) {
        for (var child in children) {
          traverse(child, parentId: nodeId, parentName: nodeName);
        }
      }
    }

    for (var filter in filters) {
      traverse(filter);
    }

    return flatList;
  }

  /// Gets flattened filter list from hierarchical data.
  List<Map<String, dynamic>> _getFiltersList() {
    try {
      final filterState = ref.watch(filterProvider);

      return filterState.when(
        data: (state) {
          final filters = state.filtersForLanguage;
          if (filters == null) return [];

          // Handle Map with 'filters' key
          if (filters is Map) {
            final filtersList = filters['filters'];
            if (filtersList is List<dynamic>) {
              return _flattenFilters(filtersList);
            }
          }
          // Handle direct List
          else if (filters is List<dynamic>) {
            return _flattenFilters(filters);
          }
          return [];
        },
        loading: () => [],
        error: (e, _) {
          debugPrint('Error loading filters: $e');
          return [];
        },
      );
    } catch (e) {
      debugPrint('Error converting filters: $e');
      return [];
    }
  }

  /// Retrieves filter data by ID.
  Map<String, dynamic>? _getFilterById(int id) {
    final filtersList = _getFiltersList();
    if (filtersList.isEmpty) return null;

    for (final filter in filtersList) {
      if (filter['filter_id'] == id) {
        return filter;
      }
    }

    return null;
  }

  /// Checks if a filter ID is a composite dietary filter
  /// Composites are 6-digit IDs starting with 592-597 (e.g., 592057, 596009)
  bool _isCompositeDietaryFilter(int filterId) {
    final filterIdStr = filterId.toString();

    return filterIdStr.length == 6 &&
        (filterIdStr.startsWith('592') ||
            filterIdStr.startsWith('593') ||
            filterIdStr.startsWith('594') ||
            filterIdStr.startsWith('595') ||
            filterIdStr.startsWith('596') ||
            filterIdStr.startsWith('597'));
  }

  // ========================================
  // FILTER VISIBILITY LOGIC
  // ========================================

  /// Determines if a filter should be hidden based on business rules.
  bool _shouldHideFilter(int filterId, List<int> activeFilters) {
    try {
      // Always hide excluded filters (payment and category 11)
      if (_allPaymentFilters.contains(filterId) ||
          filterId == _excludedCategoryId ||
          _excludedCategoryChildren.contains(filterId)) {
        return true;
      }

      // Check mutual exclusion pairs
      for (var entry in _mutuallyExclusivePairs.entries) {
        if (filterId == entry.key && activeFilters.contains(entry.value)) {
          return true;
        }
      }

      // Don't hide special parents
      if (_specialParentFilters.contains(filterId)) return false;

      // Hide children under special parents
      if (_allSpecialParentChildren.contains(filterId)) {
        final filtersList = _getFiltersList();
        final hasSpecialParent = filtersList.any((f) =>
            f['filter_id'] == filterId &&
            _specialParentFilters.contains(f['parent_id']));

        if (hasSpecialParent) return true;
      }

      // Hide parents if children are active (except special parents)
      final filtersList = _getFiltersList();
      final hasActiveChildren = filtersList.any((filter) =>
          filter['parent_id'] == filterId &&
          activeFilters.contains(filter['filter_id']));

      if (hasActiveChildren && !_specialParentFilters.contains(filterId)) {
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error in _shouldHideFilter: $e');
      return false;
    }
  }

  /// Checks if a special parent should be synthesized.
  bool _shouldSynthesizeParent(int parentId) {
    final businessState = ref.watch(businessProvider);
    final filtersOfThisBusiness = businessState.businessFilterIds;

    final children = _specialParentChildren[parentId];
    if (children == null) return false;

    return children.any((childId) => filtersOfThisBusiness.contains(childId));
  }

  /// Gets organized and filtered list of filters to display.
  List<Map<String, dynamic>> _getOrganizedFilters() {
    try {
      final filtersList = _getFiltersList();
      if (filtersList.isEmpty) return [];

      final businessState = ref.watch(businessProvider);
      final searchState = ref.watch(searchStateProvider);
      final filtersOfThisBusiness = businessState.businessFilterIds;
      final filtersUsedForSearch = searchState.filtersUsedForSearch;

      // Synthesize special parents if needed
      final synthesizedFilters = <Map<String, dynamic>>[];
      for (final parentId in _specialParentFilters) {
        if (_shouldSynthesizeParent(parentId)) {
          final parentExists =
              filtersList.any((f) => f['filter_id'] == parentId);

          if (!parentExists) {
            final children =
                filtersList.where((f) => f['parent_id'] == parentId).toList();

            if (children.isNotEmpty) {
              final parentName =
                  children.first['parent_name'] as String? ?? 'Unknown';
              synthesizedFilters.add({
                'filter_id': parentId,
                'name': parentName,
                'parent_id': null,
                'parent_name': null,
                'filter_type': 'item',
                'has_children': true,
              });
            }
          }
        }
      }

      final allFilters = [...filtersList, ...synthesizedFilters];

      // Apply filtering logic
      final visibleFilters = allFilters.where((filter) {
        final filterId = filter['filter_id'] as int?;
        if (filterId == null) return false;

        final filterType = filter['filter_type'] as String?;
        if (filterType != 'item' && filterType != 'sub_item') return false;

        // Exclude composite dietary filters (6-digit IDs like 592057, 596009)
        if (_isCompositeDietaryFilter(filterId)) return false;

        if (_shouldHideFilter(filterId, filtersUsedForSearch)) {
          return false;
        }

        // Handle special parents
        if (_specialParentFilters.contains(filterId)) {
          final parentInList = filtersOfThisBusiness.contains(filterId);
          final shouldSynthesize = _shouldSynthesizeParent(filterId);

          return parentInList || shouldSynthesize;
        }

        // Check if filter is in business's filters
        if (!filtersOfThisBusiness.contains(filterId)) {
          return false;
        }

        return true;
      }).toList();

      // Sort by parent_id, then by name
      visibleFilters.sort((a, b) {
        final parentCompare =
            (a['parent_id'] ?? 0).compareTo(b['parent_id'] ?? 0);
        if (parentCompare != 0) return parentCompare;
        return (a['name'] ?? '').compareTo(b['name'] ?? '');
      });

      return visibleFilters;
    } catch (e) {
      debugPrint('Error in _getOrganizedFilters: $e');
      return [];
    }
  }

  // ========================================
  // FILTER DESCRIPTION LOGIC
  // ========================================

  /// Gets filter description from filterDescriptions data.
  String? _getFilterDescription(int filterId) {
    try {
      final filterState = ref.watch(filterProvider);

      return filterState.when(
        data: (state) {
          final filterData = state.filterLookupMap[filterId];
          if (filterData == null) return null;

          final description = filterData['description'] as String?;
          if (description != null && description.trim().isNotEmpty) {
            return description;
          }
          return null;
        },
        loading: () => null,
        error: (e, _) => null,
      );
    } catch (e) {
      debugPrint('Error getting filter description: $e');
      return null;
    }
  }

  /// Checks if filter or any of its special parent children have descriptions.
  /// For special parents, checks the LOWEST child ID where comment is stored.
  bool _hasFilterDescription(int filterId) {
    // Check if this filter itself has a description
    if (_getFilterDescription(filterId) != null) return true;

    // Special handling for special parents - check lowest child ID
    if (_specialParentFilters.contains(filterId)) {
      // Get the children for this special parent
      final childrenIds = _specialParentChildren[filterId];
      if (childrenIds == null || childrenIds.isEmpty) return false;

      // Check if business has any of these children
      final businessState = ref.watch(businessProvider);
      final filtersOfThisBusiness = businessState.businessFilterIds;

      final selectedChildren = childrenIds
          .where((id) => filtersOfThisBusiness.contains(id))
          .toList();

      if (selectedChildren.isEmpty) return false;

      // Check LOWEST selected child ID for description (storage convention)
      final lowestChildId = selectedChildren.reduce((a, b) => a < b ? a : b);
      return _getFilterDescription(lowestChildId) != null;
    }

    return false;
  }

  /// Determines if a filter is selected in the current search.
  /// For special parents, checks if ANY child is selected.
  bool _isFilterSelected(int filterId) {
    final searchState = ref.watch(searchStateProvider);
    final filtersUsedForSearch = searchState.filtersUsedForSearch;

    // Check direct selection
    if (filtersUsedForSearch.contains(filterId)) return true;

    // For special parents, check if ANY child is selected
    if (_specialParentFilters.contains(filterId)) {
      final childrenIds = _specialParentChildren[filterId];
      if (childrenIds == null) return false;

      return childrenIds.any((childId) => filtersUsedForSearch.contains(childId));
    }

    return false;
  }

  // ========================================
  // DISPLAY LOGIC
  // ========================================

  /// Gets display name for a filter with special handling for group bookings.
  String _getDisplayName(Map<String, dynamic> filter) {
    try {
      final filterId = filter['filter_id'] as int?;
      final filterName = filter['name'] as String? ?? '';

      // Special handling for group bookings parent (543)
      if (filterId == _groupBookingsParentId) {
        return _getGroupBookingsDisplayName(filterName);
      }

      return filterName;
    } catch (e) {
      debugPrint('Error in _getDisplayName: $e');
      return '';
    }
  }

  /// Calculates the group bookings display name based on selected ranges.
  String _getGroupBookingsDisplayName(String baseLabel) {
    final businessState = ref.watch(businessProvider);
    final filtersOfThisBusiness = businessState.businessFilterIds;

    // Get selected group booking filters
    final selectedBookings = _groupBookingsChildren
        .where((id) => filtersOfThisBusiness.contains(id))
        .toList();

    if (selectedBookings.isEmpty) return baseLabel;

    // Extract numbers from selected ranges
    final numbers = <int>[];
    for (final id in selectedBookings) {
      final filter = _getFilterById(id);
      if (filter != null) {
        final name = filter['name'] as String? ?? '';
        final match = RegExp(r'^(\d+)').firstMatch(name);
        if (match != null) {
          numbers.add(int.parse(match.group(1)!));
        }
      }
    }

    if (numbers.isEmpty) return baseLabel;

    final min = numbers.reduce((a, b) => a < b ? a : b);
    final max = numbers.reduce((a, b) => a > b ? a : b);

    // Check if "40+" is selected (ID 550)
    final hasFortyPlus = selectedBookings.contains(550);

    if (hasFortyPlus && min == max) {
      return '$baseLabel: 40+';
    } else if (hasFortyPlus) {
      return '$baseLabel: $min+';
    } else if (min == max) {
      return '$baseLabel: $min-${max + 4}';
    } else {
      return '$baseLabel: $min-${max + 4}';
    }
  }

  // ========================================
  // UI BUILDING
  // ========================================

  @override
  Widget build(BuildContext context) {
    try {
      final organizedFilters = _getOrganizedFilters();

      if (organizedFilters.isEmpty) {
        return SizedBox(width: widget.width, height: 0);
      }

      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: SingleChildScrollView(
          child: Wrap(
            spacing: _buttonSpacing,
            runSpacing: _buttonRunSpacing,
            alignment: WrapAlignment.start,
            children: _buildFilterButtons(organizedFilters),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error in build method: $e');
      return SizedBox(width: widget.width, height: 0);
    }
  }

  /// Builds list of filter button widgets.
  List<Widget> _buildFilterButtons(List<Map<String, dynamic>> filters) {
    try {
      return filters.map((filter) {
        final filterId = filter['filter_id'] as int? ?? 0;
        final filterName = _getDisplayName(filter);
        final hasDescription = _hasFilterDescription(filterId);
        final isSelected = _isFilterSelected(filterId);

        return _buildSingleFilterButton(
          filterId: filterId,
          filterName: filterName,
          hasDescription: hasDescription,
          isSelected: isSelected,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error in _buildFilterButtons: $e');
      return [];
    }
  }

  /// Builds a single filter button.
  Widget _buildSingleFilterButton({
    required int filterId,
    required String filterName,
    required bool hasDescription,
    required bool isSelected,
  }) {
    return ElevatedButton(
      onPressed:
          hasDescription ? () => _handleFilterTap(filterId, filterName) : null,
      style: _buildButtonStyle(isSelected),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              filterName,
              style: _buildButtonTextStyle(isSelected),
            ),
          ),
          if (hasDescription) ...[
            const SizedBox(width: _iconSpacing),
            Icon(
              Icons.info_outline,
              size: _iconSize,
              // Use AppColors.accent for design system compliance
              // (FlutterFlow uses #D35400 but design system is #e8751a)
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
            ),
          ],
        ],
      ),
    );
  }

  /// Creates button style based on selection state.
  ButtonStyle _buildButtonStyle(bool isSelected) {
    return ButtonStyle(
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: _buttonHorizontalPadding),
      ),
      minimumSize: WidgetStateProperty.all(const Size(0, _buttonRowHeight)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: WidgetStateProperty.resolveWith<OutlinedBorder>(
        (states) => RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          side: isSelected
              // Use AppColors.accent for design system compliance
              ? BorderSide(color: AppColors.accent, width: 1)
              : BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (states) => isSelected ? AppColors.orangeBg : AppColors.bgSurface,
      ),
      elevation: WidgetStateProperty.all(0),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
    );
  }

  /// Creates button text style based on selection state.
  TextStyle _buildButtonTextStyle(bool isSelected) {
    return TextStyle(
      // Use AppColors.accent for design system compliance
      color: isSelected ? AppColors.accent : AppColors.textPrimary,
      fontSize: _fontSize,
      fontWeight: isSelected ? FontWeight.w400 : FontWeight.w300,
    );
  }

  // ========================================
  // EVENT HANDLERS
  // ========================================

  /// Handles filter button tap.
  Future<void> _handleFilterTap(int filterId, String filterName) async {
    // Get description (checking lowest child for special parents)
    String? description = _getFilterDescription(filterId);

    // For special parents, get description from lowest child
    if (_specialParentFilters.contains(filterId) && description == null) {
      final childrenIds = _specialParentChildren[filterId];
      if (childrenIds != null) {
        final businessState = ref.read(businessProvider);
        final filtersOfThisBusiness = businessState.businessFilterIds;

        final selectedChildren = childrenIds
            .where((id) => filtersOfThisBusiness.contains(id))
            .toList();

        if (selectedChildren.isNotEmpty) {
          final lowestChildId =
              selectedChildren.reduce((a, b) => a < b ? a : b);
          description = _getFilterDescription(lowestChildId);
        }
      }
    }

    // Track analytics event
    _trackFilterInfoClick(filterId, filterName, description);

    try {
      if (widget.onFilterTap != null) {
        await widget.onFilterTap!(filterId, filterName, description);
      }
    } catch (e) {
      debugPrint('Error in button onPressed: $e');
    }
  }

  /// Tracks filter info icon click to analytics backend.
  ///
  /// Captures which filter's description was viewed to understand
  /// which features users want to learn more about.
  void _trackFilterInfoClick(
      int filterId, String filterName, String? description) {
    // Get analytics data
    final analyticsState = ref.read(analyticsProvider);
    final deviceId = AnalyticsService.instance.deviceId ?? 'unknown';
    final sessionId = analyticsState.sessionId ?? 'unknown';
    final userId = AnalyticsService.instance.userId ?? 'unknown';

    // Track event (fire and forget)
    ApiService.instance.postAnalytics(
      eventType: 'filter_info_clicked',
      deviceId: deviceId,
      sessionId: sessionId,
      userId: userId,
      eventData: {
        'filter_id': filterId,
        'filter_name': filterName,
        'has_description': description != null && description.isNotEmpty,
        'description_length': description?.length ?? 0,
      },
      timestamp: DateTime.now().toIso8601String(),
    );
  }
}
