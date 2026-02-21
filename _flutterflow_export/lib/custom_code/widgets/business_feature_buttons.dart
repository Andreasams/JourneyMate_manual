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

import '/custom_code/widgets/index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'dart:ui' as ui;

/// Displays business feature/preference filters as interactive buttons.
///
/// Features include: - Dynamic height calculation based on content - Filter
/// grouping and hiding logic - Payment filters excluded - Special parent
/// filter handling - Info icon for filters with descriptions
class BusinessFeatureButtons extends StatefulWidget {
  const BusinessFeatureButtons({
    super.key,
    this.width,
    this.height,
    required this.containerWidth,
    required this.filters,
    this.filtersUsedForSearch,
    this.filtersOfThisBusiness,
    this.filterDescriptions,
    required this.onInitialCount,
    this.onFilterTap,
    this.onHeightCalculated,
  });

  final double? width;
  final double? height;
  final double containerWidth;
  final dynamic filters;
  final List<int>? filtersUsedForSearch;
  final List<int>? filtersOfThisBusiness;
  final dynamic filterDescriptions;
  final Future Function(int count) onInitialCount;
  final Future Function(
      int filterId, String filterName, String? filterDescription)? onFilterTap;
  final Future Function(double height)? onHeightCalculated;

  @override
  State<BusinessFeatureButtons> createState() => _BusinessFeatureButtonsState();
}

class _BusinessFeatureButtonsState extends State<BusinessFeatureButtons> {
  // --- Style Constants ---
  static const double _buttonHorizontalPadding = 16.0;
  static const double _buttonRowHeight = 32.0;
  static const double _buttonSpacing = 8.0;
  static const double _buttonRunSpacing = 8.0;
  static const double _iconSize = 16.0;
  static const double _iconSpacing = 6.0;
  static const double _fontSize = 14.0;
  static const double _borderRadius = 15.0;
  static const double _textMeasurementSafetyMargin = 4.0;

  static const TextStyle _buttonTextStyle = TextStyle(
    fontSize: _fontSize,
    fontWeight: FontWeight.w300,
    fontFamily: 'Roboto',
    letterSpacing: 0,
  );

  // --- Filter Configuration Constants ---

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

  // --- Lifecycle Methods ---

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

    final dataChanged =
        oldWidget.filterDescriptions != widget.filterDescriptions ||
            oldWidget.filters != widget.filters ||
            oldWidget.containerWidth != widget.containerWidth;

    if (dataChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateAndNotifyMetrics();
      });
    }
  }

  // --- Metrics Calculation ---

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
  double _measureTextWidth(String text) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: _buttonTextStyle),
      maxLines: 1,
      textDirection: ui.TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    return textPainter.size.width;
  }

  /// Calculates exact button width including padding and optional icon.
  double _calculateButtonWidth(int filterId, String filterName) {
    double width = _measureTextWidth(filterName);
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

  // --- Filter Data Processing ---

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
      // Handle Map with 'filters' key (same as other widgets)
      if (widget.filters is Map) {
        final filtersData = widget.filters as Map;
        final filtersList = filtersData['filters'];

        if (filtersList is List) {
          return _flattenFilters(filtersList as List<dynamic>);
        }
      }
      // Handle direct List
      else if (widget.filters is List) {
        return _flattenFilters(widget.filters as List<dynamic>);
      }
    } catch (e) {
      debugPrint('Error converting filters: $e');
    }
    return [];
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

  // --- Filter Visibility Logic ---

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
    if (widget.filtersOfThisBusiness == null) return false;

    final children = _specialParentChildren[parentId];
    if (children == null) return false;

    return children
        .any((childId) => widget.filtersOfThisBusiness!.contains(childId));
  }

  /// Gets organized and filtered list of filters to display.
  List<Map<String, dynamic>> _getOrganizedFilters() {
    try {
      final filtersList = _getFiltersList();
      if (filtersList.isEmpty) return [];

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

        if (_shouldHideFilter(filterId, widget.filtersUsedForSearch ?? [])) {
          return false;
        }

        // Handle special parents
        if (_specialParentFilters.contains(filterId)) {
          final parentInList =
              widget.filtersOfThisBusiness?.contains(filterId) ?? false;
          final shouldSynthesize = _shouldSynthesizeParent(filterId);

          return parentInList || shouldSynthesize;
        }

        // Check if filter is in business's filters
        if (widget.filtersOfThisBusiness != null) {
          if (!widget.filtersOfThisBusiness!.contains(filterId)) {
            return false;
          }
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

  // --- Filter Description Logic ---

  /// Gets filter description from filterDescriptions data.
  String? _getFilterDescription(int filterId) {
    try {
      if (widget.filterDescriptions == null) return null;

      if (widget.filterDescriptions is List<dynamic>) {
        final descriptions = widget.filterDescriptions as List<dynamic>;
        if (descriptions.isEmpty) return null;

        final descItem = descriptions.firstWhere(
          (item) => item is Map && item['filter_id'] == filterId,
          orElse: () => null,
        );

        if (descItem is Map) {
          final description = descItem['description'] as String?;
          if (description != null && description.trim().isNotEmpty) {
            return description;
          }
        }
      } else if (widget.filterDescriptions is Map) {
        final descriptions = widget.filterDescriptions as Map;
        final description = (descriptions[filterId] as String?) ??
            (descriptions[filterId.toString()] as String?);

        if (description != null && description.trim().isNotEmpty) {
          return description;
        }
      }
    } catch (e) {
      debugPrint('Error getting filter description: $e');
    }
    return null;
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
      if (widget.filtersOfThisBusiness == null) return false;

      final selectedChildren = childrenIds
          .where((id) => widget.filtersOfThisBusiness!.contains(id))
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
    if (widget.filtersUsedForSearch == null) return false;

    // Check direct selection
    if (widget.filtersUsedForSearch!.contains(filterId)) return true;

    // For special parents, check if ANY child is selected
    if (_specialParentFilters.contains(filterId)) {
      final childrenIds = _specialParentChildren[filterId];
      if (childrenIds == null) return false;

      return childrenIds
          .any((childId) => widget.filtersUsedForSearch!.contains(childId));
    }

    return false;
  }

  // --- Display Logic ---

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
    if (widget.filtersOfThisBusiness == null) return baseLabel;

    // Get selected group booking filters
    final selectedBookings = _groupBookingsChildren
        .where((id) => widget.filtersOfThisBusiness!.contains(id))
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

  // --- UI Building ---

  @override
  Widget build(BuildContext context) {
    try {
      final organizedFilters = _getOrganizedFilters();

      if (organizedFilters.isEmpty) {
        return Container(width: widget.width, height: 0);
      }

      return Container(
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
      return Container(width: widget.width, height: 0);
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
              color: isSelected
                  ? const Color(0xFFD35400)
                  : const Color(0xFF666666),
            ),
          ],
        ],
      ),
    );
  }

  /// Creates button style based on selection state.
  ButtonStyle _buildButtonStyle(bool isSelected) {
    return ButtonStyle(
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(horizontal: _buttonHorizontalPadding),
      ),
      minimumSize: MaterialStateProperty.all(const Size(0, _buttonRowHeight)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: MaterialStateProperty.resolveWith<OutlinedBorder>(
        (states) => RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          side: isSelected
              ? const BorderSide(color: Color(0xFFD35400), width: 1)
              : BorderSide(color: Colors.grey.shade500, width: 1),
        ),
      ),
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (states) =>
            isSelected ? const Color(0xFFFDF2EC) : const Color(0xFFf2f3f5),
      ),
      elevation: MaterialStateProperty.all(0),
      overlayColor: MaterialStateProperty.all(Colors.transparent),
    );
  }

  /// Creates button text style based on selection state.
  TextStyle _buildButtonTextStyle(bool isSelected) {
    return TextStyle(
      color: isSelected ? const Color(0xFFD35400) : const Color(0xFF242629),
      fontSize: _fontSize,
      fontWeight: isSelected ? FontWeight.w400 : FontWeight.w300,
    );
  }

  // --- Event Handlers ---

  /// Handles filter button tap.
  Future<void> _handleFilterTap(int filterId, String filterName) async {
    // Track user engagement
    markUserEngaged();

    // Get description (checking lowest child for special parents)
    String? description = _getFilterDescription(filterId);

    // For special parents, get description from lowest child
    if (_specialParentFilters.contains(filterId) && description == null) {
      final childrenIds = _specialParentChildren[filterId];
      if (childrenIds != null && widget.filtersOfThisBusiness != null) {
        final selectedChildren = childrenIds
            .where((id) => widget.filtersOfThisBusiness!.contains(id))
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
    trackAnalyticsEvent(
      'filter_info_clicked',
      {
        'filter_id': filterId,
        'filter_name': filterName,
        'has_description': description != null && description.isNotEmpty,
        'description_length': description?.length ?? 0,
      },
    ).catchError((error) {
      debugPrint('⚠️ Failed to track filter info click: $error');
    });
  }
}
