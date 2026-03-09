import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';

/// A widget that displays payment options as non-interactive informational buttons.
///
/// Features:
/// - Displays payment methods in a predefined ordered layout
/// - Auto-calculates required height based on content wrapping
/// - Highlights selected payment filters (matching user's search criteria)
/// - Supports card types, digital wallets, cash, and other features
/// - Excludes parent card category (ID 423) from display
///
/// This is a display-only widget - buttons are non-interactive (onPressed: null).
/// Payment methods shown here are informational context, not actionable filters.
class PaymentOptionsWidget extends StatefulWidget {
  const PaymentOptionsWidget({
    super.key,
    this.width,
    this.height,
    required this.containerWidth,
    required this.filters,
    this.filtersUsedForSearch,
    this.filtersOfThisBusiness,
    required this.onInitialCount,
    this.onHeightCalculated,
  });

  final double? width;
  final double? height;
  final double containerWidth;
  final dynamic filters;
  final List<int>? filtersUsedForSearch;
  final List<int>? filtersOfThisBusiness;
  final Future Function(int count) onInitialCount;
  final Future Function(double height)? onHeightCalculated;

  @override
  State<PaymentOptionsWidget> createState() => _PaymentOptionsWidgetState();
}

class _PaymentOptionsWidgetState extends State<PaymentOptionsWidget> {
  /// =========================================================================
  /// CONSTANTS
  /// =========================================================================

  /// Payment category and filter IDs
  static const int _paymentCategoryId = 21;
  static const int _paymentCardParentId = 423; // Excluded from display

  /// Predefined display order for payment filters
  static const List<int> _orderedPaymentFilters = [
    // Card types (without parent category)
    425, // VISA
    426, // MasterCard
    429, // Dankort
    427, // American Express
    428, // Diners Club
    430, // UnionPay
    431, // JCB
    432, // V Pay
    // Digital wallets
    141, // Accepts MobilePay
    434, // Accepts AliPay
    435, // Accepts WeChat
    445, // Accepts Klarna
    // Cash
    142, // Accepts cash
    // Other features
    139, // Accepts bill splitting
    140, // Can issue invoice
  ];

  /// Layout constants (using design system tokens)
  static const double _buttonHorizontalPadding = AppSpacing.lg;
  static const double _buttonRowHeight = 32.0;
  static const double _buttonSpacing = AppSpacing.sm;
  static const double _buttonRunSpacing = AppSpacing.sm;
  static const double _buttonBorderRadius = AppRadius.facility;
  static const double _buttonBorderWidth = 1.0;
  static const double _textWidthSafetyMargin = 4.0;

  /// Visual styling constants (using design system colors)
  static const Color _selectedBorderColor = AppColors.accent;
  static const Color _unselectedBorderColor = AppColors.border;
  static const Color _selectedBackgroundColor = AppColors.orangeBg;
  static const Color _unselectedBackgroundColor = AppColors.bgSurface;
  static const Color _selectedTextColor = AppColors.accent;
  static const Color _unselectedTextColor = AppColors.textPrimary;

  static const double _selectedFontSize = 14.0;
  static const FontWeight _selectedFontWeight = FontWeight.w300;
  static const FontWeight _unselectedFontWeight = FontWeight.w200;

  /// Text measurement style
  static const TextStyle _buttonTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w200,
    fontFamily: 'Roboto',
    letterSpacing: 0,
  );

  /// Error fallback constants
  static const double _defaultErrorHeight = 50.0;

  /// =========================================================================
  /// LIFECYCLE METHODS
  /// =========================================================================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateMetricsAndNotify();
    });
  }

  @override
  void didUpdateWidget(covariant PaymentOptionsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final filtersChanged = _haveFiltersChanged(oldWidget);
    final widthChanged = _hasWidthChanged(oldWidget);

    if (filtersChanged || widthChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateMetricsAndNotify();
      });
    }
  }

  /// Checks if filters have changed
  bool _haveFiltersChanged(PaymentOptionsWidget oldWidget) {
    return oldWidget.filters != widget.filters;
  }

  /// Checks if container width has changed
  bool _hasWidthChanged(PaymentOptionsWidget oldWidget) {
    return oldWidget.containerWidth != widget.containerWidth;
  }

  /// =========================================================================
  /// METRICS CALCULATION & CALLBACKS
  /// =========================================================================

  /// Calculates payment filter count and required height, then notifies parent
  Future<void> _calculateMetricsAndNotify() async {
    try {
      final filters = _getOrganizedPaymentFilters();
      await _notifyFilterCount(filters.length);
      await _notifyCalculatedHeight(filters);
    } catch (e) {
      debugPrint('Error in _calculateMetricsAndNotify: $e');
      await _notifyErrorState();
    }
  }

  /// Notifies parent of filter count
  Future<void> _notifyFilterCount(int count) async {
    await widget.onInitialCount(count);
  }

  /// Calculates and notifies parent of required height
  Future<void> _notifyCalculatedHeight(
      List<Map<String, dynamic>> filters) async {
    final calculatedHeight =
        _calculateRequiredHeight(filters, widget.containerWidth);
    await widget.onHeightCalculated?.call(calculatedHeight);
  }

  /// Notifies parent of error state with fallback values
  Future<void> _notifyErrorState() async {
    await widget.onInitialCount(0);
    await widget.onHeightCalculated?.call(_defaultErrorHeight);
  }

  /// =========================================================================
  /// HEIGHT CALCULATION
  /// =========================================================================

  /// Calculates the required height for displaying all payment filters
  ///
  /// Simulates text wrapping to determine how many rows are needed
  double _calculateRequiredHeight(
    List<Map<String, dynamic>> filters,
    double containerWidth,
  ) {
    if (filters.isEmpty) return 0.0;

    final rowCount = _calculateRowCount(filters, containerWidth);
    return _calculateTotalHeight(rowCount);
  }

  /// Calculates the number of rows needed for the filters
  int _calculateRowCount(
      List<Map<String, dynamic>> filters, double containerWidth) {
    double currentRowWidth = 0;
    int rowCount = 1;

    for (final filter in filters) {
      final filterName = filter['name'] as String? ?? '';
      final buttonWidth = _calculateButtonWidth(filterName);

      if (_shouldStartNewRow(currentRowWidth, buttonWidth, containerWidth)) {
        rowCount++;
        currentRowWidth = buttonWidth + _buttonSpacing;
      } else {
        currentRowWidth = _addButtonToCurrentRow(
            currentRowWidth, buttonWidth, containerWidth);
      }
    }

    return rowCount;
  }

  /// Determines if a new row should be started
  bool _shouldStartNewRow(
      double currentRowWidth, double buttonWidth, double containerWidth) {
    return currentRowWidth > 0 &&
        currentRowWidth + buttonWidth > containerWidth;
  }

  /// Adds button width to current row width
  double _addButtonToCurrentRow(
      double currentRowWidth, double buttonWidth, double containerWidth) {
    currentRowWidth += buttonWidth;
    if (currentRowWidth < containerWidth) {
      currentRowWidth += _buttonSpacing;
    }
    return currentRowWidth;
  }

  /// Calculates total height based on row count
  double _calculateTotalHeight(int rowCount) {
    double totalHeight = rowCount * _buttonRowHeight;
    if (rowCount > 1) {
      totalHeight += (rowCount - 1) * _buttonRunSpacing;
    }
    return totalHeight;
  }

  /// =========================================================================
  /// TEXT & BUTTON WIDTH MEASUREMENT
  /// =========================================================================

  /// Measures the width of text using TextPainter
  double _measureTextWidth(String text) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: _buttonTextStyle),
      maxLines: 1,
      textDirection: ui.TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    return textPainter.size.width;
  }

  /// Calculates the total button width including padding and margins
  double _calculateButtonWidth(String filterName) {
    double width = _measureTextWidth(filterName);
    width += _buttonHorizontalPadding * 2;
    width += _textWidthSafetyMargin;
    return width;
  }

  /// =========================================================================
  /// FILTER DATA PROCESSING
  /// =========================================================================

  List<Map<String, dynamic>> _getFiltersList() {
    try {
      // Handle Map with 'filters' key
      if (widget.filters is Map) {
        final filtersData = widget.filters as Map;
        final filtersList = filtersData['filters'];

        if (filtersList is List<dynamic>) {
          return _flattenFilters(filtersList);
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

  /// Flattens hierarchical filter structure into a flat list
  List<Map<String, dynamic>> _flattenFilters(List<dynamic> filters) {
    final flatList = <Map<String, dynamic>>[];

    try {
      for (var filter in filters) {
        _traverseFilterTree(filter, flatList);
      }
    } catch (e) {
      debugPrint('Error in _flattenFilters: $e');
    }

    return flatList;
  }

  /// Recursively traverses the filter tree structure
  void _traverseFilterTree(
    dynamic node,
    List<Map<String, dynamic>> flatList, {
    int? parentId,
  }) {
    if (node == null || node is! Map<String, dynamic>) return;

    final nodeId = node['id'] as int?;
    final nodeType = node['type'] as String?;
    final nodeName = node['name'] as String?;
    final children = node['children'] as List<dynamic>?;

    if (_isPaymentCategory(nodeType, nodeId)) {
      _traverseChildren(children, flatList, nodeId);
      return;
    }

    if (_shouldIncludeFilter(nodeType, nodeId, nodeName)) {
      _addFilterToList(flatList, nodeId!, nodeName!, parentId, nodeType!);
    }

    _traverseChildren(children, flatList, nodeId);
  }

  /// Checks if node is the payment category
  bool _isPaymentCategory(String? nodeType, int? nodeId) {
    return nodeType == 'category' && nodeId == _paymentCategoryId;
  }

  /// Checks if filter should be included in the list
  bool _shouldIncludeFilter(String? nodeType, int? nodeId, String? nodeName) {
    return (nodeType == 'item' || nodeType == 'sub_item') &&
        nodeId != null &&
        nodeName != null &&
        nodeId != _paymentCardParentId &&
        _orderedPaymentFilters.contains(nodeId);
  }

  /// Adds a filter to the flat list
  void _addFilterToList(
    List<Map<String, dynamic>> flatList,
    int nodeId,
    String nodeName,
    int? parentId,
    String nodeType,
  ) {
    flatList.add({
      'filter_id': nodeId,
      'name': nodeName,
      'parent_id': parentId,
      'filter_type': nodeType,
    });
  }

  /// Traverses child nodes recursively
  void _traverseChildren(
    List<dynamic>? children,
    List<Map<String, dynamic>> flatList,
    int? parentId,
  ) {
    if (children != null && children.isNotEmpty) {
      for (var child in children) {
        _traverseFilterTree(child, flatList, parentId: parentId);
      }
    }
  }

  /// Gets organized and sorted payment filters
  List<Map<String, dynamic>> _getOrganizedPaymentFilters() {
    try {
      final filtersList = _getFiltersList();
      if (filtersList.isEmpty) return [];

      final availableFilters = _filterAvailableFilters(filtersList);
      return _sortFiltersByPredefinedOrder(availableFilters);
    } catch (e) {
      debugPrint('Error in _getOrganizedPaymentFilters: $e');
      return [];
    }
  }

  /// Filters to only include payment filters available for this business
  List<Map<String, dynamic>> _filterAvailableFilters(
      List<Map<String, dynamic>> filtersList) {
    return filtersList.where((filter) {
      final filterId = filter['filter_id'] as int?;
      if (filterId == null) return false;

      if (widget.filtersOfThisBusiness != null) {
        return widget.filtersOfThisBusiness!.contains(filterId);
      }

      return true;
    }).toList();
  }

  /// Sorts filters by predefined display order
  List<Map<String, dynamic>> _sortFiltersByPredefinedOrder(
      List<Map<String, dynamic>> filters) {
    return filters
      ..sort((a, b) {
        final aId = a['filter_id'] as int? ?? 0;
        final bId = b['filter_id'] as int? ?? 0;
        final aIndex = _orderedPaymentFilters.indexOf(aId);
        final bIndex = _orderedPaymentFilters.indexOf(bId);
        return aIndex.compareTo(bIndex);
      });
  }

  /// =========================================================================
  /// UI BUILDERS
  /// =========================================================================

  @override
  Widget build(BuildContext context) {
    try {
      final paymentFilters = _getOrganizedPaymentFilters();

      if (paymentFilters.isEmpty) {
        return _buildEmptyState();
      }

      return _buildPaymentOptionsContainer(paymentFilters);
    } catch (e) {
      debugPrint('Error in build method: $e');
      return _buildErrorState();
    }
  }

  /// Builds the main payment options container
  Widget _buildPaymentOptionsContainer(
      List<Map<String, dynamic>> paymentFilters) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: SingleChildScrollView(
        child: Wrap(
          spacing: _buttonSpacing,
          runSpacing: _buttonRunSpacing,
          alignment: WrapAlignment.start,
          children: _buildPaymentButtons(paymentFilters),
        ),
      ),
    );
  }

  /// Builds the list of payment option buttons
  List<Widget> _buildPaymentButtons(List<Map<String, dynamic>> filters) {
    try {
      return filters.map((filter) => _buildPaymentButton(filter)).toList();
    } catch (e) {
      debugPrint('Error in _buildPaymentButtons: $e');
      return [_buildErrorWidget()];
    }
  }

  /// Builds a single payment option button
  Widget _buildPaymentButton(Map<String, dynamic> filter) {
    final filterId = filter['filter_id'] as int? ?? 0;
    final filterName = filter['name'] as String? ?? '';
    final isSelected = _isFilterSelected(filterId);

    return ElevatedButton(
      onPressed: null, // Not tappable - display only
      style: _getButtonStyle(isSelected),
      child: _buildButtonText(filterName, isSelected),
    );
  }

  /// Checks if a filter is currently selected
  bool _isFilterSelected(int filterId) {
    return widget.filtersUsedForSearch?.contains(filterId) ?? false;
  }

  /// Gets the button style based on selection state
  ButtonStyle _getButtonStyle(bool isSelected) {
    return ButtonStyle(
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: _buttonHorizontalPadding),
      ),
      minimumSize: WidgetStateProperty.all(const Size(0, _buttonRowHeight)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: WidgetStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonBorderRadius),
          side: BorderSide(
            color: isSelected ? _selectedBorderColor : _unselectedBorderColor,
            width: _buttonBorderWidth,
          ),
        ),
      ),
      backgroundColor: WidgetStateProperty.all<Color>(
        isSelected ? _selectedBackgroundColor : _unselectedBackgroundColor,
      ),
      elevation: WidgetStateProperty.all(0),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
    );
  }

  /// Builds the button text with appropriate styling
  Widget _buildButtonText(String filterName, bool isSelected) {
    return Text(
      filterName,
      style: TextStyle(
        color: isSelected ? _selectedTextColor : _unselectedTextColor,
        fontSize: _selectedFontSize,
        fontWeight: isSelected ? _selectedFontWeight : _unselectedFontWeight,
      ),
    );
  }

  /// Builds the empty state widget
  Widget _buildEmptyState() {
    return SizedBox(
      width: widget.width,
      height: widget.height ?? _defaultErrorHeight,
      child: const SizedBox.shrink(),
    );
  }

  /// Builds the error state widget
  Widget _buildErrorState() {
    return Container(
      width: widget.width,
      height: widget.height ?? _defaultErrorHeight,
      alignment: Alignment.center,
      child: const Text('Error displaying payment options.'),
    );
  }

  /// Builds an error widget for button list
  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: const Text('Error loading payment options'),
    );
  }
}
