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

/// A regular widget that displays a category's name and description
///
/// This widget creates a container with a swipe bar, close button, and
/// scrollable content area, designed to look like a modal bottom sheet but
/// used as a regular widget in FlutterFlow's widget tree.
///
/// Expected JSON structure: ```json { "categoryName": "Category Name",
/// "categoryDescription": "Description text" } ```
///
/// Features: - Swipe bar indicator (visual only) - Close button with callback
/// for FlutterFlow action wiring - Scrollable content for long descriptions -
/// Graceful handling of missing descriptions - Proper user engagement
/// tracking
class CategoryDescriptionSheet extends StatefulWidget {
  const CategoryDescriptionSheet({
    Key? key,
    required this.width,
    required this.height,
    required this.categoryData,
    required this.onClose,
  }) : super(key: key);

  final double width;
  final double height;
  final dynamic categoryData;
  final Future Function() onClose;

  @override
  State<CategoryDescriptionSheet> createState() =>
      _CategoryDescriptionSheetState();
}

class _CategoryDescriptionSheetState extends State<CategoryDescriptionSheet> {
  /// =========================================================================
  /// CONSTANTS - DIMENSIONS & LAYOUT
  /// =========================================================================

  static const double _sheetBorderRadius = 20.0;

  static const double _noImageHeaderHeight = 64.0;
  static const double _swipeBarWidth = 80.0;
  static const double _swipeBarHeight = 4.0;
  static const double _swipeBarTopPadding = 8.0;
  static const double _swipeBarBottomPadding = 12.0;
  static const double _swipeBarBorderRadius = 20.0;
  static const double _closeButtonSize = 40.0;
  static const double _closeButtonPosition = 12.0;
  static const double _closeButtonBorderRadius = 20.0;
  static const double _closeIconSize = 30.0;
  static const double _contentHorizontalPadding = 28.0;
  static const double _contentTopSpacing = 12.0;
  static const double _nameToDescriptionSpacing = 8.0;
  static const double _bottomPadding = 20.0;

  /// =========================================================================
  /// CONSTANTS - TYPOGRAPHY
  /// =========================================================================

  // Category name (22px, bold) - Primary hierarchy
  static const double _categoryNameFontSize = 22.0;
  static const FontWeight _categoryNameFontWeight = FontWeight.w600;
  static const Color _categoryNameColor = Colors.black;

  // Description text (16px) - Body text
  static const double _descriptionFontSize = 16.0;
  static const FontWeight _descriptionFontWeight = FontWeight.w300;
  static const Color _descriptionColor = Color(0xFF2D3236);

  /// =========================================================================
  /// CONSTANTS - COLORS
  /// =========================================================================

  static const Color _swipeBarColor = Color(0xFF14181B);
  static const Color _closeButtonBackgroundColor = Color(0xFFF2F3F5);
  static const Color _closeIconColor = Color(0xFF14181B);

  /// =========================================================================
  /// DATA EXTRACTION HELPERS
  /// =========================================================================

  /// Safely extracts string value from category data
  String _getStringValue(String key, [String defaultValue = '']) {
    if (widget.categoryData is! Map) return defaultValue;
    final value = widget.categoryData[key];
    return (value is String && value.isNotEmpty) ? value : defaultValue;
  }

  /// =========================================================================
  /// LIFECYCLE METHODS
  /// =========================================================================

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// =========================================================================
  /// CLOSE HANDLER
  /// =========================================================================

  /// Handles closing the widget and triggering the callback
  Future<void> _handleClose() async {
    markUserEngaged();
    await widget.onClose();
  }

  /// =========================================================================
  /// UI BUILDERS - MAIN LAYOUT
  /// =========================================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: _getSheetDecoration(),
      child: Column(
        children: [
          _buildHeaderSection(),
          _buildScrollableContent(),
        ],
      ),
    );
  }

  /// Gets sheet decoration with rounded top corners
  BoxDecoration _getSheetDecoration() {
    return const BoxDecoration(
      color: Colors.white,
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(_sheetBorderRadius)),
    );
  }

  /// =========================================================================
  /// UI BUILDERS - HEADER SECTION
  /// =========================================================================

  /// Builds the header section with swipe bar and close button
  Widget _buildHeaderSection() {
    return SizedBox(
      height: _noImageHeaderHeight,
      child: Stack(
        children: [
          _buildSwipeBar(),
          _buildCloseButton(),
        ],
      ),
    );
  }

  /// Builds the swipe bar indicator for visual affordance
  Widget _buildSwipeBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(
          top: _swipeBarTopPadding,
          bottom: _swipeBarBottomPadding,
        ),
        child: Center(
          child: Container(
            width: _swipeBarWidth,
            height: _swipeBarHeight,
            decoration: BoxDecoration(
              color: _swipeBarColor,
              borderRadius: BorderRadius.circular(_swipeBarBorderRadius),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the close button that triggers callback
  Widget _buildCloseButton() {
    return Positioned(
      top: _closeButtonPosition,
      left: _closeButtonPosition,
      child: Container(
        width: _closeButtonSize,
        height: _closeButtonSize,
        decoration: BoxDecoration(
          color: _closeButtonBackgroundColor,
          borderRadius: BorderRadius.circular(_closeButtonBorderRadius),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(
            Icons.close,
            color: _closeIconColor,
            size: _closeIconSize,
          ),
          onPressed: _handleClose,
        ),
      ),
    );
  }

  /// =========================================================================
  /// UI BUILDERS - SCROLLABLE CONTENT
  /// =========================================================================

  /// Builds the scrollable content area containing category details
  Widget _buildScrollableContent() {
    return Expanded(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: _contentHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: _contentTopSpacing),
              _buildCategoryName(),
              const SizedBox(height: _nameToDescriptionSpacing),
              _buildCategoryDescription(),
              const SizedBox(height: _bottomPadding),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds category name text with fallback for missing data
  Widget _buildCategoryName() {
    final categoryName = _getStringValue('categoryName', 'Category').trim();

    return Text(
      categoryName,
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: _categoryNameFontSize,
        fontWeight: _categoryNameFontWeight,
        color: _categoryNameColor,
      ),
    );
  }

  /// Builds category description with graceful handling of null/empty values
  Widget _buildCategoryDescription() {
    final description = _getStringValue('categoryDescription').trim();

    if (description.isEmpty) {
      return const Text(
        'No description available.',
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: _descriptionFontSize,
          fontWeight: _descriptionFontWeight,
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Text(
      description,
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: _descriptionFontSize,
        fontWeight: _descriptionFontWeight,
        color: _descriptionColor,
      ),
    );
  }
}
