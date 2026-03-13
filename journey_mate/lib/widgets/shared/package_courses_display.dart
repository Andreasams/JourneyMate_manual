import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:collection';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';
import '../../services/translation_service.dart';
import '../../services/custom_functions/price_formatter.dart' show convertAndFormatPrice;

/// A widget that displays menu package courses with their associated items.
///
/// Features:
/// - Hierarchical display: Package → Courses → Menu Items
/// - Premium upcharge badges for items with extra cost
/// - Currency conversion support
/// - Item tap handler for detailed views
/// - Styled course headers and descriptions
/// - Visual hierarchy with indentation and borders
/// - Localized UI text via translation system
class PackageCoursesDisplay extends ConsumerStatefulWidget {
  const PackageCoursesDisplay({
    super.key,
    this.width,
    required this.height,
    required this.menuData,
    required this.packageId,
    required this.chosenCurrency,
    required this.originalCurrencyCode,
    required this.exchangeRate,
    this.onItemTap,
  });

  final double? width;
  final double height;
  final dynamic menuData;
  final int packageId;
  final String chosenCurrency;
  final String originalCurrencyCode;
  final double exchangeRate;
  final Future<void> Function(Map<String, dynamic> itemData)? onItemTap;

  @override
  ConsumerState<PackageCoursesDisplay> createState() =>
      _PackageCoursesDisplayState();
}

class _PackageCoursesDisplayState
    extends ConsumerState<PackageCoursesDisplay> {
  /// =========================================================================
  /// STATE & CONSTANTS
  /// =========================================================================

  /// Maps menu item IDs to their full data for O(1) lookup
  Map<int, Map<String, dynamic>> _menuItemMap = {};

  /// The selected package data matching the packageId
  Map<String, dynamic>? _selectedPackage;

  /// Visual styling constants
  static const Color _courseNameColor = AppColors.textPrimary;
  static const Color _courseDescriptionColor = AppColors.textSecondary;
  static const Color _itemNameColor = AppColors.textSecondary;
  static const Color _itemDescriptionColor = AppColors.textTertiary;
  static const Color _itemBorderColor = AppColors.accent;

  /// Typography constants
  static const double _courseNameFontSize = 20.0;
  static const double _courseDescriptionFontSize = 16.0;
  static const double _itemNameFontSize = 18.0;
  static const double _itemDescriptionFontSize = 16.0;
  static const double _premiumBadgeFontSize = 16.0;

  static const FontWeight _courseNameFontWeight = FontWeight.w500;
  static const FontWeight _courseDescriptionFontWeight = FontWeight.w300;
  static const FontWeight _itemNameFontWeight = FontWeight.w500;
  static const FontWeight _itemDescriptionFontWeight = FontWeight.w300;
  static const FontWeight _premiumBadgeFontWeight = FontWeight.w400;

  /// Layout constants
  static const double _containerBorderRadius = AppRadius.chip;
  static const double _listPadding = AppSpacing.lg;
  static const double _courseBottomMargin = AppSpacing.xl;
  static const double _courseNameBottomMargin = AppSpacing.sm;
  static const double _courseDescriptionBottomMargin = AppSpacing.md;
  static const double _itemBottomMargin = 10.0;
  static const double _itemLeftMargin = AppSpacing.sm;
  static const double _itemLeftPadding = AppSpacing.sm;
  static const double _itemBorderWidth = 4.0;
  static const double _itemDescriptionTopSpacing = AppSpacing.xs;
  static const double _itemNameToPremiumSpacing = AppSpacing.sm;
  static const double _premiumBadgeBorderRadius = 4.0;
  static const double _premiumBadgeHorizontalPadding = 6.0;
  static const double _premiumBadgeVerticalPadding = 2.0;
  static const double _itemDescriptionLineHeight = 1.3;

  /// Data structure keys
  static const String _menuItemsKey = 'menu_items';
  static const String _categoriesKey = 'categories';
  static const String _menuItemIdKey = 'menu_item_id';
  static const String _categoryTypeKey = 'category_type';
  static const String _packageIdKey = 'package_id';
  static const String _coursesKey = 'courses';
  static const String _courseNameKey = 'course_name';
  static const String _courseDescriptionKey = 'course_description';
  static const String _courseItemMetadataKey = 'course_item_metadata';
  static const String _premiumUpchargeKey = 'premium_upcharge';
  static const String _isExcludedKey = 'is_excluded';
  static const String _itemNameKey = 'item_name';
  static const String _itemDescriptionKey = 'item_description';
  static const String _basePriceKey = 'base_price';
  static const String _dietaryTypeIdsKey = 'dietary_type_ids';
  static const String _allergyIdsKey = 'allergy_ids';
  static const String _itemImageUrlKey = 'item_image_url';
  static const String _itemModifierGroupsKey = 'item_modifier_groups';
  static const String _isBeverageKey = 'is_beverage';

  static const String _menuPackageType = 'menu_package';

  /// Translation keys
  static const String _errorPackageNotFoundKey = 'error_package_not_found';

  /// =========================================================================
  /// LIFECYCLE METHODS
  /// =========================================================================

  @override
  void initState() {
    super.initState();
    _processMenuData();
  }

  /// =========================================================================
  /// DATA PROCESSING
  /// =========================================================================

  /// Processes menu data to build lookup maps and find selected package
  void _processMenuData() {
    try {
      _buildMenuItemLookupMap();
      _findSelectedPackage();
    } catch (_) { // ignore: empty_catches
    }
  }

  /// Builds a lookup map of menu items by ID for O(1) access
  void _buildMenuItemLookupMap() {
    final menuItems = widget.menuData[_menuItemsKey] as List<dynamic>? ?? [];
    _menuItemMap = HashMap<int, Map<String, dynamic>>.from({
      for (final item in menuItems)
        if (item is Map<String, dynamic> && item[_menuItemIdKey] is int)
          item[_menuItemIdKey] as int: item
    });
  }

  /// Finds the package matching the widget's packageId
  void _findSelectedPackage() {
    final categories = widget.menuData[_categoriesKey] as List<dynamic>? ?? [];

    for (final category in categories) {
      if (_isTargetPackage(category)) {
        _selectedPackage = category as Map<String, dynamic>;
        break;
      }
    }
  }

  /// Checks if a category is the target package
  bool _isTargetPackage(dynamic category) {
    if (category is! Map<String, dynamic>) return false;
    return category[_categoryTypeKey] == _menuPackageType &&
        category[_packageIdKey] == widget.packageId;
  }

  /// =========================================================================
  /// PRICE FORMATTING
  /// =========================================================================

  /// Formats premium upcharge amount with currency conversion
  ///
  /// Returns empty string if amount is 0 or negative
  String _formatPremiumPrice(double premiumAmount) {
    if (premiumAmount <= 0) return '';

    try {
      final formattedAmount = convertAndFormatPrice(
        premiumAmount,
        widget.originalCurrencyCode,
        widget.exchangeRate,
        widget.chosenCurrency,
      );
      return '+ ${formattedAmount ?? premiumAmount.toStringAsFixed(0)}';
    } catch (e) {
      return '+ ${premiumAmount.toStringAsFixed(0)}';
    }
  }

  /// =========================================================================
  /// USER INTERACTION HANDLERS
  /// =========================================================================

  /// Handles tap on a menu item
  Future<void> _handleItemTap(Map<String, dynamic> itemData) async {
    await widget.onItemTap?.call(itemData);
  }

  /// =========================================================================
  /// UI BUILDERS - MAIN LAYOUT
  /// =========================================================================

  @override
  Widget build(BuildContext context) {
    if (_selectedPackage == null) {
      return _buildErrorState();
    }

    return _buildPackageContainer();
  }

  /// Builds the error state when package is not found
  Widget _buildErrorState() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: AppColors.bgPage,
      padding: const EdgeInsets.symmetric(vertical: _listPadding),
      child: Text(
        td(ref, _errorPackageNotFoundKey),
        style: AppTypography.bodyLg.copyWith(
          fontSize: 16.0,
          color: AppColors.error,
        ),
      ),
    );
  }

  /// Builds the main package container
  Widget _buildPackageContainer() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        borderRadius: BorderRadius.circular(_containerBorderRadius),
      ),
      child: _buildScrollableContent(),
    );
  }

  /// Builds the scrollable content area
  Widget _buildScrollableContent() {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: _buildCoursesList(),
    );
  }

  /// Builds the list of courses
  Widget _buildCoursesList() {
    final courses = _selectedPackage![_coursesKey] as List<dynamic>? ?? [];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: _listPadding),
      itemCount: courses.length,
      itemBuilder: (_, index) => _buildCourseItem(courses[index]),
    );
  }

  /// =========================================================================
  /// UI BUILDERS - COURSE ITEMS
  /// =========================================================================

  /// Builds a single course item
  Widget _buildCourseItem(dynamic course) {
    if (course is! Map<String, dynamic>) {
      return const SizedBox.shrink();
    }

    final courseName = course[_courseNameKey]?.toString() ?? '';
    final courseDescription = course[_courseDescriptionKey]?.toString() ?? '';
    final courseItemMetadata =
        course[_courseItemMetadataKey] as List<dynamic>? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: _courseBottomMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (courseName.isNotEmpty) _buildCourseName(courseName),
          if (courseDescription.isNotEmpty)
            _buildCourseDescription(courseDescription),
          if (courseItemMetadata.isNotEmpty)
            _buildCourseMenuItems(courseItemMetadata),
        ],
      ),
    );
  }

  /// Builds the course name header
  Widget _buildCourseName(String courseName) {
    return Container(
      margin: const EdgeInsets.only(bottom: _courseNameBottomMargin),
      child: Text(
        courseName,
        style: AppTypography.bodyLg.copyWith(
          fontSize: _courseNameFontSize,
          fontWeight: _courseNameFontWeight,
          color: _courseNameColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  /// Builds the course description
  Widget _buildCourseDescription(String courseDescription) {
    return Container(
      margin: const EdgeInsets.only(bottom: _courseDescriptionBottomMargin),
      child: Text(
        courseDescription,
        style: AppTypography.bodyLg.copyWith(
          fontSize: _courseDescriptionFontSize,
          fontWeight: _courseDescriptionFontWeight,
          color: _courseDescriptionColor,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  /// Builds the list of menu items for a course
  Widget _buildCourseMenuItems(List<dynamic> courseItemMetadata) {
    return Column(
      children: courseItemMetadata
          .map<Widget>((itemMeta) => _buildMenuItem(itemMeta))
          .toList(),
    );
  }

  /// =========================================================================
  /// UI BUILDERS - MENU ITEMS
  /// =========================================================================

  /// Builds a single menu item
  Widget _buildMenuItem(dynamic itemMeta) {
    if (itemMeta is! Map<String, dynamic>) {
      return const SizedBox.shrink();
    }

    final itemId = itemMeta[_menuItemIdKey] as int?;
    final premiumUpcharge =
        (itemMeta[_premiumUpchargeKey] as num?)?.toDouble() ?? 0.0;
    final isExcluded = itemMeta[_isExcludedKey] as bool? ?? false;

    if (_shouldSkipMenuItem(itemId, isExcluded)) {
      return const SizedBox.shrink();
    }

    final menuItem = _menuItemMap[itemId];
    if (menuItem == null) {
      return const SizedBox.shrink();
    }

    return _buildMenuItemTile(menuItem, itemId!, premiumUpcharge);
  }

  /// Checks if menu item should be skipped
  bool _shouldSkipMenuItem(int? itemId, bool isExcluded) {
    return isExcluded || itemId == null;
  }

  /// Builds the complete menu item tile
  Widget _buildMenuItemTile(
    Map<String, dynamic> menuItem,
    int itemId,
    double premiumUpcharge,
  ) {
    final itemName = menuItem[_itemNameKey]?.toString() ?? '';
    final itemDescription = menuItem[_itemDescriptionKey]?.toString() ?? '';
    final premiumText = _formatPremiumPrice(premiumUpcharge);

    return GestureDetector(
      onTap: () =>
          _handleItemTap(_buildItemData(menuItem, itemId, premiumUpcharge)),
      child: _buildMenuItemContainer(itemName, itemDescription, premiumText),
    );
  }

  /// Builds the item data object for callbacks
  Map<String, dynamic> _buildItemData(
    Map<String, dynamic> menuItem,
    int itemId,
    double premiumUpcharge,
  ) {
    return {
      _menuItemIdKey: itemId,
      _itemNameKey: menuItem[_itemNameKey] ?? '',
      _itemDescriptionKey: menuItem[_itemDescriptionKey] ?? '',
      _basePriceKey: menuItem[_basePriceKey] ?? 0,
      _premiumUpchargeKey: premiumUpcharge,
      _dietaryTypeIdsKey: menuItem[_dietaryTypeIdsKey] ?? [],
      _allergyIdsKey: menuItem[_allergyIdsKey] ?? [],
      _itemImageUrlKey: menuItem[_itemImageUrlKey],
      _itemModifierGroupsKey: menuItem[_itemModifierGroupsKey] ?? [],
      _isBeverageKey: menuItem[_isBeverageKey] ?? false,
    };
  }

  /// Builds the menu item container with border styling
  Widget _buildMenuItemContainer(
    String itemName,
    String itemDescription,
    String premiumText,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: _itemBottomMargin,
        left: _itemLeftMargin,
      ),
      padding: const EdgeInsets.only(left: _itemLeftPadding),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(
            color: _itemBorderColor,
            width: _itemBorderWidth,
          ),
        ),
      ),
      child: _buildMenuItemContent(itemName, itemDescription, premiumText),
    );
  }

  /// Builds the menu item content (name, description, premium badge)
  Widget _buildMenuItemContent(
    String itemName,
    String itemDescription,
    String premiumText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMenuItemHeader(itemName, premiumText),
        if (itemDescription.isNotEmpty)
          _buildMenuItemDescription(itemDescription),
      ],
    );
  }

  /// Builds the menu item header row (name + premium badge)
  Widget _buildMenuItemHeader(String itemName, String premiumText) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildItemName(itemName)),
        if (premiumText.isNotEmpty) ...[
          const SizedBox(width: _itemNameToPremiumSpacing),
          _buildPremiumBadge(premiumText),
        ],
      ],
    );
  }

  /// Builds the item name text
  Widget _buildItemName(String itemName) {
    return Text(
      itemName,
      style: AppTypography.bodyLg.copyWith(
        fontSize: _itemNameFontSize,
        fontWeight: _itemNameFontWeight,
        color: _itemNameColor,
      ),
    );
  }

  /// Builds the premium upcharge badge
  Widget _buildPremiumBadge(String premiumText) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _premiumBadgeHorizontalPadding,
        vertical: _premiumBadgeVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.accent, width: 1.0),
        borderRadius: BorderRadius.circular(_premiumBadgeBorderRadius),
      ),
      child: Text(
        premiumText,
        style: AppTypography.bodyLg.copyWith(
          fontSize: _premiumBadgeFontSize,
          fontWeight: _premiumBadgeFontWeight,
          color: AppColors.accent,
        ),
      ),
    );
  }

  /// Builds the item description text
  Widget _buildMenuItemDescription(String itemDescription) {
    return Padding(
      padding: const EdgeInsets.only(top: _itemDescriptionTopSpacing),
      child: Text(
        itemDescription,
        style: AppTypography.bodyLg.copyWith(
          fontSize: _itemDescriptionFontSize,
          fontWeight: _itemDescriptionFontWeight,
          color: _itemDescriptionColor,
          height: _itemDescriptionLineHeight,
        ),
      ),
    );
  }
}
