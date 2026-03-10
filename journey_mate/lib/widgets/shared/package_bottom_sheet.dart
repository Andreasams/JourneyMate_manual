import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../providers/app_providers.dart';
import '../../services/translation_service.dart';
import '../../services/custom_functions/price_formatter.dart';
import '../../services/custom_functions/dietary_formatter.dart';
import '../../services/custom_functions/allergen_formatter.dart';
import 'bottom_sheet_header.dart';
import 'package_courses_display.dart';

/// A bottom sheet with nested navigation for viewing package details and menu items.
///
/// Features:
/// - Two-level navigation: Package view → Item detail view
/// - Platform-specific transitions (iOS swipe-back, Android slide)
/// - Image display with fallback states
/// - Currency conversion support
/// - Expandable information source section
/// - Premium upcharge display
/// - Allergen and dietary preference information
/// - Localized UI text via translation system
class PackageBottomSheet extends ConsumerStatefulWidget {
  const PackageBottomSheet({
    super.key,
    this.width,
    this.height,
    required this.normalizedMenuData,
    required this.packageId,
    required this.chosenCurrency,
    required this.originalCurrencyCode,
    required this.exchangeRate,
    required this.businessName,
  });

  final double? width;
  final double? height;
  final dynamic normalizedMenuData;
  final int packageId;
  final String chosenCurrency;
  final String originalCurrencyCode;
  final double exchangeRate;
  final String businessName;

  @override
  ConsumerState<PackageBottomSheet> createState() =>
      _PackageBottomSheetState();
}

class _PackageBottomSheetState extends ConsumerState<PackageBottomSheet> {
  /// =========================================================================
  /// STATE & CONSTANTS
  /// =========================================================================

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  Map<String, dynamic>? _packageData;
  Map<int, Map<String, dynamic>> _menuItemMap = {};

  /// Sheet dimensions
  static const double _defaultSheetHeightFactor = 0.90;

  /// Navigation constants
  static const String _itemRoute = '/item';
  static const Duration _transitionDuration = Duration(milliseconds: 300);
  static const Curve _transitionCurve = Curves.easeInOut;

  /// Slide transition offsets
  static const Offset _slideInBegin = Offset(1.0, 0.0);
  static const Offset _slideInEnd = Offset.zero;
  static const Offset _slideOutBegin = Offset.zero;
  static const Offset _slideOutEnd = Offset(-0.3, 0.0);

  /// Data structure keys
  static const String _menuItemsKey = 'menu_items';
  static const String _categoriesKey = 'categories';
  static const String _menuItemIdKey = 'menu_item_id';
  static const String _categoryTypeKey = 'category_type';
  static const String _packageIdKey = 'package_id';
  static const String _menuPackageType = 'menu_package';

  /// Translation keys
  static const String _errorPackageNotFoundKey = 'error_package_not_found';

  /// =========================================================================
  /// LIFECYCLE METHODS
  /// =========================================================================

  @override
  void initState() {
    super.initState();
    _extractPackageData();
  }

  /// =========================================================================
  /// DATA EXTRACTION
  /// =========================================================================

  /// Extracts package data and builds menu item lookup map
  void _extractPackageData() {
    if (widget.normalizedMenuData is! Map<String, dynamic>) return;

    final normalizedMap = widget.normalizedMenuData as Map<String, dynamic>;
    _buildMenuItemLookupMap(normalizedMap);
    _findTargetPackage(normalizedMap);
  }

  /// Builds O(1) lookup map for menu items
  void _buildMenuItemLookupMap(Map<String, dynamic> normalizedMap) {
    final menuItems = normalizedMap[_menuItemsKey] as List<dynamic>? ?? [];
    _menuItemMap = Map.fromEntries(
      menuItems.whereType<Map<String, dynamic>>().map(
            (item) => MapEntry(item[_menuItemIdKey] as int, item),
          ),
    );
  }

  /// Finds the specific package by ID
  void _findTargetPackage(Map<String, dynamic> normalizedMap) {
    final categories = normalizedMap[_categoriesKey] as List<dynamic>? ?? [];

    for (final category in categories) {
      if (_isTargetPackage(category)) {
        _packageData = category as Map<String, dynamic>;
        break;
      }
    }
  }

  /// Checks if category matches target package
  bool _isTargetPackage(dynamic category) {
    if (category is! Map<String, dynamic>) return false;
    return category[_categoryTypeKey] == _menuPackageType &&
        category[_packageIdKey] == widget.packageId;
  }

  /// =========================================================================
  /// NAVIGATION HANDLERS
  /// =========================================================================

  /// Handles navigation to item detail
  void _navigateToItem(Map<String, dynamic> itemData) {
    _navigatorKey.currentState?.pushNamed(_itemRoute, arguments: itemData);
  }

  /// Handles closing the sheet
  void _handleClose(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// =========================================================================
  /// ROUTE GENERATION
  /// =========================================================================

  /// Generates routes for the nested navigator
  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    if (settings.name == _itemRoute) {
      return _buildItemRoute(settings);
    }
    return _buildPackageRoute();
  }

  /// Builds the item detail route with platform-specific transitions
  Route<dynamic> _buildItemRoute(RouteSettings settings) {
    final itemData = settings.arguments as Map<String, dynamic>;

    if (_shouldUseCupertinoTransition()) {
      return _buildCupertinoItemRoute(itemData);
    }

    return _buildCustomItemRoute(itemData);
  }

  /// Checks if platform should use Cupertino transitions
  bool _shouldUseCupertinoTransition() {
    return Theme.of(context).platform == TargetPlatform.iOS;
  }

  /// Builds Cupertino-style route for iOS
  CupertinoPageRoute _buildCupertinoItemRoute(Map<String, dynamic> itemData) {
    return CupertinoPageRoute(
      maintainState: true,
      builder: (context) => _ItemDetailPage(
        itemData: itemData,
        chosenCurrency: widget.chosenCurrency,
        originalCurrencyCode: widget.originalCurrencyCode,
        exchangeRate: widget.exchangeRate,
        businessName: widget.businessName,
        onBack: () => _navigatorKey.currentState?.pop(),
      ),
    );
  }

  /// Builds custom route with slide transitions for Android/other platforms
  PageRouteBuilder _buildCustomItemRoute(Map<String, dynamic> itemData) {
    return PageRouteBuilder(
      maintainState: true,
      pageBuilder: (context, animation, secondaryAnimation) => _ItemDetailPage(
        itemData: itemData,
        chosenCurrency: widget.chosenCurrency,
        originalCurrencyCode: widget.originalCurrencyCode,
        exchangeRate: widget.exchangeRate,
        businessName: widget.businessName,
        onBack: () => _navigatorKey.currentState?.pop(),
      ),
      transitionsBuilder: _buildSlideTransition,
      transitionDuration: _transitionDuration,
    );
  }

  /// Builds slide transition animation
  Widget _buildSlideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final slideIn = _createSlideTween(_slideInBegin, _slideInEnd);
    final slideOut = _createSlideTween(_slideOutBegin, _slideOutEnd);

    return SlideTransition(
      position: animation.drive(slideIn),
      child: SlideTransition(
        position: secondaryAnimation.drive(slideOut),
        child: child,
      ),
    );
  }

  /// Creates a slide tween with curve
  Animatable<Offset> _createSlideTween(Offset begin, Offset end) {
    return Tween(begin: begin, end: end)
        .chain(CurveTween(curve: _transitionCurve));
  }

  /// Builds the package view route
  PageRouteBuilder _buildPackageRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => _PackageViewPage(
        packageData: _packageData!,
        menuItemMap: _menuItemMap,
        normalizedMenuData: widget.normalizedMenuData,
        chosenCurrency: widget.chosenCurrency,
        originalCurrencyCode: widget.originalCurrencyCode,
        exchangeRate: widget.exchangeRate,
        onClose: () => _handleClose(context),
        onItemTap: _navigateToItem,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
    );
  }

  /// =========================================================================
  /// UI BUILDERS
  /// =========================================================================

  @override
  Widget build(BuildContext context) {
    if (_packageData == null) {
      return _buildErrorState(context);
    }

    return _buildNavigationSheet();
  }

  /// Builds error state when package not found
  Widget _buildErrorState(BuildContext context) {
    final sheetHeight = _calculateSheetHeight(context);

    return Container(
      width: widget.width,
      height: sheetHeight,
      decoration: _getSheetDecoration(),
      child: Center(
        child: Text(td(ref, _errorPackageNotFoundKey)),
      ),
    );
  }

  /// Builds the navigation sheet container
  Widget _buildNavigationSheet() {
    return Container(
      width: widget.width,
      height: _calculateSheetHeight(context),
      decoration: _getSheetDecoration(),
      child: Navigator(
        key: _navigatorKey,
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  /// Calculates sheet height
  double _calculateSheetHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return widget.height ?? screenHeight * _defaultSheetHeightFactor;
  }

  /// Gets sheet decoration with rounded top corners
  BoxDecoration _getSheetDecoration() {
    return BottomSheetHeader.sheetDecoration(color: AppColors.bgPage);
  }
}

/// ============================================================================
/// PACKAGE VIEW PAGE
/// ============================================================================

/// Displays the package overview with courses and menu items
class _PackageViewPage extends ConsumerWidget {
  const _PackageViewPage({
    required this.packageData,
    required this.menuItemMap,
    required this.normalizedMenuData,
    required this.chosenCurrency,
    required this.originalCurrencyCode,
    required this.exchangeRate,
    required this.onClose,
    required this.onItemTap,
  });

  final Map<String, dynamic> packageData;
  final Map<int, Map<String, dynamic>> menuItemMap;
  final dynamic normalizedMenuData;
  final String chosenCurrency;
  final String originalCurrencyCode;
  final double exchangeRate;
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) onItemTap;

  /// Visual constants
  static const double _imageHeight = 200.0;
  static const double _contentHorizontalPadding = AppSpacing.xxl + 4;
  static const double _contentTopSpacing = AppSpacing.md;
  static const double _coursesTopSpacing = AppSpacing.md;
  static const double _coursesHeightFactor = 0.6;

  /// Typography constants
  static const double _packageNameFontSize = 22.0;
  static const FontWeight _packageNameFontWeight = FontWeight.w500;
  static const double _priceFontSize = 18.0;
  static const FontWeight _priceFontWeight = FontWeight.w400;
  static const double _descriptionFontSize = 18.0;
  static const FontWeight _descriptionFontWeight = FontWeight.w300;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasImage = _hasPackageImage();

    return Column(
      children: [
        BottomSheetHeader(
          leftAction: BottomSheetAction(
            icon: Icons.close,
            onPressed: onClose,
          ),
          image: hasImage ? _buildPackageImage() : null,
        ),
        _buildContentSection(context),
      ],
    );
  }

  /// Checks if package has an image
  bool _hasPackageImage() {
    final imageUrl = packageData['package_image_url'] as String?;
    return imageUrl != null && imageUrl.isNotEmpty;
  }

  /// Builds the package image
  Widget _buildPackageImage() {
    final imageUrl = packageData['package_image_url'] as String;

    return Image.network(
      imageUrl,
      width: double.infinity,
      height: _imageHeight,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildImageError(),
    );
  }

  /// Builds image error state
  Widget _buildImageError() {
    return Container(
      height: _imageHeight,
      color: AppColors.bgInput,
      child: const Center(
        child: Icon(Icons.image, size: 50, color: AppColors.textTertiary),
      ),
    );
  }

  /// Builds the content section
  Widget _buildContentSection(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Expanded(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: _contentHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: _contentTopSpacing),
            _buildPackageName(),
            _buildPackagePrice(),
            _buildPackageDescription(),
            const SizedBox(height: _coursesTopSpacing),
            _buildCoursesDisplay(screenHeight),
          ],
        ),
      ),
    );
  }

  /// Builds package name
  Widget _buildPackageName() {
    final packageName = packageData['package_name'] as String? ?? '';

    return Text(
      packageName,
      style: AppTypography.bodyLg.copyWith(
        fontSize: _packageNameFontSize,
        fontWeight: _packageNameFontWeight,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// Builds package price
  Widget _buildPackagePrice() {
    final basePrice = (packageData['base_price'] as num?)?.toDouble() ?? 0.0;
    final formattedPrice = convertAndFormatPrice(
      basePrice,
      originalCurrencyCode,
      exchangeRate,
      chosenCurrency,
    );

    if (formattedPrice == null || formattedPrice.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      formattedPrice,
      style: AppTypography.bodyLg.copyWith(
        fontSize: _priceFontSize,
        fontWeight: _priceFontWeight,
        color: AppColors.accent,
      ),
    );
  }

  /// Builds package description
  Widget _buildPackageDescription() {
    final packageDescription =
        packageData['package_description'] as String? ?? '';

    if (packageDescription.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      packageDescription,
      style: AppTypography.bodyLg.copyWith(
        fontSize: _descriptionFontSize,
        fontWeight: _descriptionFontWeight,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// Builds the courses display widget
  Widget _buildCoursesDisplay(double screenHeight) {
    final packageId = packageData['package_id'] as int? ?? 0;

    return Expanded(
      child: PackageCoursesDisplay(
        height: screenHeight * _coursesHeightFactor,
        menuData: normalizedMenuData,
        packageId: packageId,
        chosenCurrency: chosenCurrency,
        originalCurrencyCode: originalCurrencyCode,
        exchangeRate: exchangeRate,
        onItemTap: (itemData) async => onItemTap(itemData),
      ),
    );
  }
}

/// ============================================================================
/// ITEM DETAIL PAGE
/// ============================================================================

/// Displays detailed information about a menu item
class _ItemDetailPage extends ConsumerWidget {
  const _ItemDetailPage({
    required this.itemData,
    required this.chosenCurrency,
    required this.originalCurrencyCode,
    required this.exchangeRate,
    required this.businessName,
    required this.onBack,
  });

  final Map<String, dynamic> itemData;
  final String chosenCurrency;
  final String originalCurrencyCode;
  final double exchangeRate;
  final String businessName;
  final VoidCallback onBack;

  /// Visual constants
  static const double _imageHeight = 200.0;
  static const double _contentHorizontalPadding = AppSpacing.xxl + 4;
  static const double _contentTopSpacing = AppSpacing.md;
  static const double _titleToPriceSpacing = 2.0;
  static const double _priceToDescriptionSpacing = 4.0;
  static const double _descriptionToDividerSpacing = AppSpacing.xl;
  static const double _dividerToInfoSpacing = AppSpacing.xl;
  static const double _infoHeaderSpacing = 4.0;
  static const double _dietaryToAllergenSpacing = AppSpacing.md;
  static const double _allergenToSourceSpacing = AppSpacing.md;
  static const double _bottomPadding = AppSpacing.xl;

  /// Typography constants
  static const double _itemNameFontSize = 22.0;
  static const FontWeight _itemNameFontWeight = FontWeight.w600;
  static const double _premiumPriceFontSize = 15.0;
  static const FontWeight _premiumPriceFontWeight = FontWeight.w500;
  static const double _descriptionFontSize = 18.0;
  static const FontWeight _descriptionFontWeight = FontWeight.w300;
  static const double _infoHeaderFontSize = 16.0;
  static const FontWeight _infoHeaderFontWeight = FontWeight.w500;
  static const double _infoLabelFontSize = 15.0;
  static const FontWeight _infoLabelFontWeight = FontWeight.w400;
  static const double _infoTextFontSize = 15.0;
  static const FontWeight _infoTextFontWeight = FontWeight.w300;

  /// Premium badge styling
  static const double _premiumBadgeHorizontalPadding = 6.0;
  static const double _premiumBadgeVerticalPadding = 2.0;
  static const double _premiumBadgeBorderRadius = 4.0;

  /// Divider styling
  static const double _dividerThickness = 1.0;

  /// Translation keys
  static const String _infoHeaderAdditionalKey = 'info_header_additional';
  static const String _infoHeaderDietaryKey = 'info_header_dietary';
  static const String _infoHeaderAllergensKey = 'info_header_allergens';
  static const String _infoHeaderSourceKey = 'info_header_source';
  static const String _infoDisclaimerBusinessKey = 'info_disclaimer_business';
  static const String _infoDisclaimerJourneymateKey =
      'info_disclaimer_journeymate';

  /// =========================================================================
  /// UI BUILDERS
  /// =========================================================================

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasImage = _hasItemImage();

    return Container(
      decoration: BottomSheetHeader.sheetDecoration(color: AppColors.bgPage),
      child: Column(
        children: [
          BottomSheetHeader(
            leftAction: BottomSheetAction(
              icon: Icons.arrow_back,
              onPressed: onBack,
            ),
            image: hasImage ? _buildItemImage() : null,
          ),
          _buildScrollableContent(context, ref),
        ],
      ),
    );
  }

  /// Checks if item has an image
  bool _hasItemImage() {
    final imageUrl = itemData['item_image_url'] as String?;
    return imageUrl != null && imageUrl.isNotEmpty;
  }

  /// Builds the item image
  Widget _buildItemImage() {
    final imageUrl = itemData['item_image_url'] as String;

    return Image.network(
      imageUrl,
      width: double.infinity,
      height: _imageHeight,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildImageError(),
    );
  }

  /// Builds image error state
  Widget _buildImageError() {
    return Container(
      height: _imageHeight,
      color: AppColors.bgInput,
      child: const Center(
        child: Icon(Icons.image, size: 50, color: AppColors.textTertiary),
      ),
    );
  }

  /// Builds the scrollable content area
  Widget _buildScrollableContent(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: _contentHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: _contentTopSpacing),
              _buildItemName(),
              _buildPremiumPrice(),
              _buildItemDescription(),
              const SizedBox(height: _descriptionToDividerSpacing),
              _buildDivider(),
              _buildAdditionalInformation(context, ref),
              const SizedBox(height: _bottomPadding),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds item name
  Widget _buildItemName() {
    final itemName = itemData['item_name'] as String? ?? '';

    return Text(
      itemName,
      style: AppTypography.bodyLg.copyWith(
        fontSize: _itemNameFontSize,
        fontWeight: _itemNameFontWeight,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// Builds premium price badge
  Widget _buildPremiumPrice() {
    final premiumUpcharge =
        (itemData['premium_upcharge'] as num?)?.toDouble() ?? 0.0;

    if (premiumUpcharge <= 0) {
      return const SizedBox.shrink();
    }

    final displayPrice = _formatPremiumPrice(premiumUpcharge);

    return Padding(
      padding: const EdgeInsets.only(top: _titleToPriceSpacing),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: _premiumBadgeHorizontalPadding,
          vertical: _premiumBadgeVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(_premiumBadgeBorderRadius),
        ),
        child: Text(
          displayPrice,
          style: AppTypography.bodyLg.copyWith(
            fontSize: _premiumPriceFontSize,
            fontWeight: _premiumPriceFontWeight,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }

  /// Formats premium price with currency conversion
  String _formatPremiumPrice(double premiumAmount) {
    final formattedUpcharge = convertAndFormatPrice(
      premiumAmount,
      originalCurrencyCode,
      exchangeRate,
      chosenCurrency,
    );
    return '+ ${formattedUpcharge ?? premiumAmount.toStringAsFixed(0)}';
  }

  /// Builds item description
  Widget _buildItemDescription() {
    final itemDescription = itemData['item_description'] as String? ?? '';
    final premiumUpcharge =
        (itemData['premium_upcharge'] as num?)?.toDouble() ?? 0.0;

    if (itemDescription.isEmpty) {
      return const SizedBox.shrink();
    }

    final topPadding = premiumUpcharge > 0 ? _priceToDescriptionSpacing : 0.0;

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Text(
        itemDescription,
        style: AppTypography.bodyLg.copyWith(
          fontSize: _descriptionFontSize,
          fontWeight: _descriptionFontWeight,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  /// Builds divider
  Widget _buildDivider() {
    return Divider(
      color: AppColors.textSecondary,
      thickness: _dividerThickness,
    );
  }

  /// Builds additional information section
  Widget _buildAdditionalInformation(BuildContext context, WidgetRef ref) {
    final isBeverage = itemData['is_beverage'] as bool? ?? false;

    if (isBeverage) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: _dividerToInfoSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoHeader(ref),
          const SizedBox(height: _infoHeaderSpacing),
          _buildDietaryInformation(context, ref),
          const SizedBox(height: _dietaryToAllergenSpacing),
          _buildAllergenInformation(context, ref),
          const SizedBox(height: _allergenToSourceSpacing),
          _buildInformationSource(ref),
        ],
      ),
    );
  }

  /// Builds additional information header
  Widget _buildInfoHeader(WidgetRef ref) {
    return Text(
      td(ref, _infoHeaderAdditionalKey),
      style: AppTypography.bodyLg.copyWith(
        fontSize: _infoHeaderFontSize,
        fontWeight: _infoHeaderFontWeight,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// Builds dietary preferences information
  Widget _buildDietaryInformation(BuildContext context, WidgetRef ref) {
    // Extract dietary data from item
    final dietaryTypeIds = itemData['dietary_type_ids'] as List<dynamic>?;
    final dietaryIds = dietaryTypeIds?.whereType<int>().toList();
    final isBeverage = itemData['is_beverage'] as bool? ?? false;

    // Get translations cache from provider
    final translationsCache = ref.watch(translationsCacheProvider);

    // Format dietary preferences
    final dietaryText = convertDietaryPreferencesToString(
      dietaryIds,
      Localizations.localeOf(context).languageCode,
      isBeverage,
      translationsCache,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          td(ref, _infoHeaderDietaryKey),
          style: AppTypography.bodyLg.copyWith(
            fontSize: _infoLabelFontSize,
            fontWeight: _infoLabelFontWeight,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          dietaryText ?? '',
          style: AppTypography.bodyLg.copyWith(
            fontSize: _infoTextFontSize,
            fontWeight: _infoTextFontWeight,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Builds allergen information
  Widget _buildAllergenInformation(BuildContext context, WidgetRef ref) {
    // Extract allergen data from item
    final allergyTypeIds = itemData['allergy_ids'] as List<dynamic>?;
    final allergyIds = allergyTypeIds?.whereType<int>().toList();
    final isBeverage = itemData['is_beverage'] as bool? ?? false;

    // Get translations cache from provider
    final translationsCache = ref.watch(translationsCacheProvider);

    // Format allergens
    final allergyText = convertAllergiesToString(
      allergyIds,
      Localizations.localeOf(context).languageCode,
      isBeverage,
      translationsCache,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          td(ref, _infoHeaderAllergensKey),
          style: AppTypography.bodyLg.copyWith(
            fontSize: _infoLabelFontSize,
            fontWeight: _infoLabelFontWeight,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          allergyText ?? '',
          style: AppTypography.bodyLg.copyWith(
            fontSize: _infoTextFontSize,
            fontWeight: _infoTextFontWeight,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Builds information source section
  Widget _buildInformationSource(WidgetRef ref) {
    final disclaimerText = td(ref, _infoDisclaimerBusinessKey)
        .replaceAll('[businessName]', businessName);

    final journeymateText = td(ref, _infoDisclaimerJourneymateKey);

    return _InformationSourceSection(
      headerText: td(ref, _infoHeaderSourceKey),
      disclaimerText: disclaimerText,
      journeymateText: journeymateText,
    );
  }
}

/// ============================================================================
/// INFORMATION SOURCE ACCORDION SECTION
/// ============================================================================

/// An expandable accordion section for displaying information source disclaimers
class _InformationSourceSection extends StatefulWidget {
  const _InformationSourceSection({
    required this.headerText,
    required this.disclaimerText,
    required this.journeymateText,
  });

  final String headerText;
  final String disclaimerText;
  final String journeymateText;

  @override
  State<_InformationSourceSection> createState() =>
      _InformationSourceSectionState();
}

class _InformationSourceSectionState extends State<_InformationSourceSection> {
  /// =========================================================================
  /// STATE & CONSTANTS
  /// =========================================================================

  bool _isExpanded = false;

  /// Animation constants
  static const Duration _expandDuration = Duration(milliseconds: 100);
  static const Curve _expandCurve = Curves.linear;

  /// Spacing constants
  static const double _expandedContentTopSpacing = AppSpacing.sm;
  static const double _disclaimerToJourneymateSpacing = AppSpacing.sm;

  /// Typography constants
  static const double _headerFontSize = 16.0;
  static const FontWeight _headerFontWeight = FontWeight.w400;
  static const double _contentFontSize = 15.0;
  static const FontWeight _contentFontWeight = FontWeight.w300;

  /// Icon size
  static const double _iconSize = 24.0;

  /// =========================================================================
  /// USER INTERACTION HANDLERS
  /// =========================================================================

  /// Toggles the expanded state
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  /// =========================================================================
  /// UI BUILDERS
  /// =========================================================================

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderRow(),
        _buildExpandableContent(),
      ],
    );
  }

  /// Builds the header row with tap handler
  Widget _buildHeaderRow() {
    return InkWell(
      onTap: _toggleExpanded,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHeaderText(),
          _buildExpandIcon(),
        ],
      ),
    );
  }

  /// Builds the header text
  Widget _buildHeaderText() {
    return Text(
      widget.headerText,
      style: AppTypography.bodyLg.copyWith(
        fontSize: _headerFontSize,
        fontWeight: _headerFontWeight,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// Builds the expand/collapse icon
  Widget _buildExpandIcon() {
    return Icon(
      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
      color: AppColors.textPrimary,
      size: _iconSize,
    );
  }

  /// Builds the expandable content with animation
  Widget _buildExpandableContent() {
    return ClipRect(
      child: AnimatedAlign(
        duration: _expandDuration,
        curve: _expandCurve,
        heightFactor: _isExpanded ? 1.0 : 0.0,
        alignment: Alignment.topCenter,
        child: _buildExpandedContent(),
      ),
    );
  }

  /// Builds the expanded content
  Widget _buildExpandedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: _expandedContentTopSpacing),
        _buildDisclaimerText(),
        const SizedBox(height: _disclaimerToJourneymateSpacing),
        _buildJourneymateText(),
      ],
    );
  }

  /// Builds the disclaimer text
  Widget _buildDisclaimerText() {
    return Text(
      widget.disclaimerText,
      style: AppTypography.bodyLg.copyWith(
        fontSize: _contentFontSize,
        fontWeight: _contentFontWeight,
        color: AppColors.textSecondary,
      ),
    );
  }

  /// Builds the Journeymate text
  Widget _buildJourneymateText() {
    return Text(
      widget.journeymateText,
      style: AppTypography.bodyLg.copyWith(
        fontSize: _contentFontSize,
        fontWeight: _contentFontWeight,
        color: AppColors.textSecondary,
      ),
    );
  }
}
