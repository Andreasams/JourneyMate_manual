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

import 'package:flutter/cupertino.dart';

/// A bottom sheet with nested navigation for viewing package details and menu
/// items.
///
/// Features: - Two-level navigation: Package view → Item detail view -
/// Platform-specific transitions (iOS swipe-back, Android slide) - Image
/// display with fallback states - Currency conversion support - Expandable
/// information source section - Premium upcharge display - Allergen and
/// dietary preference information - Localized UI text via translation system
class PackageNavigationSheet extends StatefulWidget {
  const PackageNavigationSheet({
    super.key,
    this.width,
    this.height,
    required this.normalizedMenuData,
    required this.packageId,
    required this.chosenCurrency,
    required this.originalCurrencyCode,
    required this.exchangeRate,
    required this.currentLanguage,
    required this.businessName,
    required this.translationsCache,
  });

  final double? width;
  final double? height;
  final dynamic normalizedMenuData;
  final int packageId;
  final String chosenCurrency;
  final String originalCurrencyCode;
  final double exchangeRate;
  final String currentLanguage;
  final String businessName;
  final dynamic translationsCache;

  @override
  State<PackageNavigationSheet> createState() => _PackageNavigationSheetState();
}

class _PackageNavigationSheetState extends State<PackageNavigationSheet> {
  /// =========================================================================
  /// STATE & CONSTANTS
  /// =========================================================================

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  Map<String, dynamic>? _packageData;
  Map<int, Map<String, dynamic>> _menuItemMap = {};

  /// Sheet dimensions
  static const double _defaultSheetHeightFactor = 0.90;
  static const double _sheetBorderRadius = 20.0;

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

  @override
  void didUpdateWidget(PackageNavigationSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Rebuild if translation cache or language changes
    if (widget.translationsCache != oldWidget.translationsCache ||
        widget.currentLanguage != oldWidget.currentLanguage) {
      setState(() {
        // Trigger rebuild with new translations
      });
    }
  }

  /// =========================================================================
  /// TRANSLATION HELPERS
  /// =========================================================================

  /// Gets localized UI text using central translation function
  String _getUIText(String key) {
    return getTranslations(
        widget.currentLanguage, key, widget.translationsCache);
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
      builder: (_) => _ItemDetailPage(
        itemData: itemData,
        chosenCurrency: widget.chosenCurrency,
        originalCurrencyCode: widget.originalCurrencyCode,
        exchangeRate: widget.exchangeRate,
        currentLanguage: widget.currentLanguage,
        businessName: widget.businessName,
        translationsCache: widget.translationsCache,
        onBack: () => _navigatorKey.currentState?.pop(),
      ),
    );
  }

  /// Builds custom route with slide transitions for Android/other platforms
  PageRouteBuilder _buildCustomItemRoute(Map<String, dynamic> itemData) {
    return PageRouteBuilder(
      maintainState: true,
      pageBuilder: (_, __, ___) => _ItemDetailPage(
        itemData: itemData,
        chosenCurrency: widget.chosenCurrency,
        originalCurrencyCode: widget.originalCurrencyCode,
        exchangeRate: widget.exchangeRate,
        currentLanguage: widget.currentLanguage,
        businessName: widget.businessName,
        translationsCache: widget.translationsCache,
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
      pageBuilder: (_, __, ___) => _PackageViewPage(
        packageData: _packageData!,
        menuItemMap: _menuItemMap,
        normalizedMenuData: widget.normalizedMenuData,
        chosenCurrency: widget.chosenCurrency,
        originalCurrencyCode: widget.originalCurrencyCode,
        exchangeRate: widget.exchangeRate,
        currentLanguage: widget.currentLanguage,
        translationsCache: widget.translationsCache,
        onClose: () => _handleClose(context),
        onItemTap: _navigateToItem,
      ),
      transitionsBuilder: (_, __, ___, child) => child,
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
        child: Text(_getUIText(_errorPackageNotFoundKey)),
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
    return const BoxDecoration(
      color: Colors.white,
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(_sheetBorderRadius)),
    );
  }
}

/// ============================================================================
/// PACKAGE VIEW PAGE
/// ============================================================================

/// Displays the package overview with courses and menu items
class _PackageViewPage extends StatelessWidget {
  const _PackageViewPage({
    required this.packageData,
    required this.menuItemMap,
    required this.normalizedMenuData,
    required this.chosenCurrency,
    required this.originalCurrencyCode,
    required this.exchangeRate,
    required this.currentLanguage,
    required this.translationsCache,
    required this.onClose,
    required this.onItemTap,
  });

  final Map<String, dynamic> packageData;
  final Map<int, Map<String, dynamic>> menuItemMap;
  final dynamic normalizedMenuData;
  final String chosenCurrency;
  final String originalCurrencyCode;
  final double exchangeRate;
  final String currentLanguage;
  final dynamic translationsCache;
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) onItemTap;

  /// Visual constants
  static const double _imageHeight = 200.0;
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
  static const double _coursesTopSpacing = 12.0;
  static const double _coursesHeightFactor = 0.6;

  /// Typography constants
  static const double _packageNameFontSize = 22.0;
  static const FontWeight _packageNameFontWeight = FontWeight.w500;
  static const double _priceFontSize = 18.0;
  static const FontWeight _priceFontWeight = FontWeight.w400;
  static const double _descriptionFontSize = 18.0;
  static const FontWeight _descriptionFontWeight = FontWeight.w300;

  /// Colors
  static const Color _swipeBarColor = Color(0xFF14181B);
  static const Color _closeButtonBackgroundColor = Color(0xFFF2F3F5);
  static const Color _closeIconColor = Color(0xFF14181B);
  static const Color _packageNameColor = Colors.black;
  static const Color _priceColor = Color(0xFFE9874B);
  static const Color _descriptionColor = Color(0xFF14181B);
  static final Color _imageErrorBackgroundColor = Colors.grey[200]!;
  static const Color _imageErrorIconColor = Colors.grey;
  static const double _imageErrorIconSize = 50.0;

  @override
  Widget build(BuildContext context) {
    final hasImage = _hasPackageImage();

    return Column(
      children: [
        _buildHeaderSection(hasImage),
        _buildContentSection(context),
      ],
    );
  }

  /// Checks if package has an image
  bool _hasPackageImage() {
    final imageUrl = packageData['package_image_url'] as String?;
    return imageUrl != null && imageUrl.isNotEmpty;
  }

  /// Builds the header section with image/swipe bar/close button
  Widget _buildHeaderSection(bool hasImage) {
    return SizedBox(
      height: hasImage ? _imageHeight : _noImageHeaderHeight,
      child: Stack(
        children: [
          if (hasImage) _buildPackageImage(),
          _buildSwipeBar(),
          _buildCloseButton(),
        ],
      ),
    );
  }

  /// Builds the package image
  Widget _buildPackageImage() {
    final imageUrl = packageData['package_image_url'] as String;

    return Image.network(
      imageUrl,
      width: double.infinity,
      height: _imageHeight,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildImageError(),
    );
  }

  /// Builds image error state
  Widget _buildImageError() {
    return Container(
      height: _imageHeight,
      color: _imageErrorBackgroundColor,
      child: const Center(
        child: Icon(Icons.image,
            size: _imageErrorIconSize, color: _imageErrorIconColor),
      ),
    );
  }

  /// Builds the swipe bar indicator
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

  /// Builds the close button
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
          icon: const Icon(Icons.close,
              color: _closeIconColor, size: _closeIconSize),
          onPressed: () {
            markUserEngaged();
            onClose();
          },
        ),
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
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: _packageNameFontSize,
        fontWeight: _packageNameFontWeight,
        color: _packageNameColor,
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
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: _priceFontSize,
        fontWeight: _priceFontWeight,
        color: _priceColor,
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
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: _descriptionFontSize,
        fontWeight: _descriptionFontWeight,
        color: _descriptionColor,
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
        languageCode: currentLanguage,
        translationsCache: translationsCache,
        onItemTap: (itemData) async => onItemTap(itemData),
      ),
    );
  }
}

/// ============================================================================
/// ITEM DETAIL PAGE
/// ============================================================================

/// Displays detailed information about a menu item
class _ItemDetailPage extends StatelessWidget {
  const _ItemDetailPage({
    required this.itemData,
    required this.chosenCurrency,
    required this.originalCurrencyCode,
    required this.exchangeRate,
    required this.currentLanguage,
    required this.businessName,
    required this.translationsCache,
    required this.onBack,
  });

  final Map<String, dynamic> itemData;
  final String chosenCurrency;
  final String originalCurrencyCode;
  final double exchangeRate;
  final String currentLanguage;
  final String businessName;
  final dynamic translationsCache;
  final VoidCallback onBack;

  /// Visual constants (reusing from package view where applicable)
  static const double _imageHeight = 200.0;
  static const double _noImageHeaderHeight = 64.0;
  static const double _swipeBarWidth = 80.0;
  static const double _swipeBarHeight = 4.0;
  static const double _swipeBarTopPadding = 8.0;
  static const double _swipeBarBottomPadding = 12.0;
  static const double _swipeBarBorderRadius = 20.0;
  static const double _backButtonSize = 40.0;
  static const double _backButtonPosition = 12.0;
  static const double _backButtonBorderRadius = 20.0;
  static const double _backIconSize = 30.0;
  static const double _contentHorizontalPadding = 28.0;
  static const double _contentTopSpacing = 12.0;
  static const double _titleToPriceSpacing = 2.0;
  static const double _priceToDescriptionSpacing = 4.0;
  static const double _descriptionToDividerSpacing = 20.0;
  static const double _dividerToInfoSpacing = 20.0;
  static const double _infoHeaderSpacing = 4.0;
  static const double _dietaryToAllergenSpacing = 12.0;
  static const double _allergenToSourceSpacing = 12.0;
  static const double _bottomPadding = 20.0;

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

  /// Colors
  static const Color _swipeBarColor = Color(0xFF14181B);
  static const Color _backButtonBackgroundColor = Color(0xFFF2F3F5);
  static const Color _backIconColor = Color(0xFF14181B);
  static const Color _itemNameColor = Colors.black;
  static const Color _premiumPriceColor = Color(0xFFE9874B);
  static const Color _descriptionColor = Color(0xFF14181B);
  static const Color _dividerColor = Color(0xFF57636C);
  static const Color _infoHeaderColor = Colors.black;
  static const Color _infoLabelColor = Colors.black;
  static const Color _infoTextColor = Colors.black87;
  static final Color _imageErrorBackgroundColor = Colors.grey[200]!;
  static const Color _imageErrorIconColor = Colors.grey;

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
  /// TRANSLATION HELPERS
  /// =========================================================================

  /// Gets localized UI text using central translation function
  String _getUIText(String key) {
    return getTranslations(currentLanguage, key, translationsCache);
  }

  /// =========================================================================
  /// UI BUILDERS
  /// =========================================================================

  @override
  Widget build(BuildContext context) {
    final hasImage = _hasItemImage();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeaderSection(hasImage),
          _buildScrollableContent(),
        ],
      ),
    );
  }

  /// Checks if item has an image
  bool _hasItemImage() {
    final imageUrl = itemData['item_image_url'] as String?;
    return imageUrl != null && imageUrl.isNotEmpty;
  }

  /// Builds the header section
  Widget _buildHeaderSection(bool hasImage) {
    return SizedBox(
      height: hasImage ? _imageHeight : _noImageHeaderHeight,
      child: Stack(
        children: [
          if (hasImage) _buildItemImage(),
          _buildSwipeBar(),
          _buildBackButton(),
        ],
      ),
    );
  }

  /// Builds the item image
  Widget _buildItemImage() {
    final imageUrl = itemData['item_image_url'] as String;

    return Image.network(
      imageUrl,
      width: double.infinity,
      height: _imageHeight,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildImageError(),
    );
  }

  /// Builds image error state
  Widget _buildImageError() {
    return Container(
      height: _imageHeight,
      color: _imageErrorBackgroundColor,
      child: const Center(
        child: Icon(Icons.image, size: 50, color: _imageErrorIconColor),
      ),
    );
  }

  /// Builds the swipe bar indicator
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

  /// Builds the back button
  Widget _buildBackButton() {
    return Positioned(
      top: _backButtonPosition,
      left: _backButtonPosition,
      child: Container(
        width: _backButtonSize,
        height: _backButtonSize,
        decoration: BoxDecoration(
          color: _backButtonBackgroundColor,
          borderRadius: BorderRadius.circular(_backButtonBorderRadius),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_back,
              color: _backIconColor, size: _backIconSize),
          onPressed: () {
            markUserEngaged();
            onBack();
          },
        ),
      ),
    );
  }

  /// Builds the scrollable content area
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
              _buildItemName(),
              _buildPremiumPrice(),
              _buildItemDescription(),
              const SizedBox(height: _descriptionToDividerSpacing),
              _buildDivider(),
              _buildAdditionalInformation(),
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
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: _itemNameFontSize,
        fontWeight: _itemNameFontWeight,
        color: _itemNameColor,
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
          color: _premiumPriceColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(_premiumBadgeBorderRadius),
        ),
        child: Text(
          displayPrice,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: _premiumPriceFontSize,
            fontWeight: _premiumPriceFontWeight,
            color: _premiumPriceColor,
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
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: _descriptionFontSize,
          fontWeight: _descriptionFontWeight,
          color: _descriptionColor,
        ),
      ),
    );
  }

  /// Builds divider
  Widget _buildDivider() {
    return const Divider(
      color: _dividerColor,
      thickness: _dividerThickness,
    );
  }

  /// Builds additional information section
  Widget _buildAdditionalInformation() {
    final isBeverage = itemData['is_beverage'] as bool? ?? false;

    if (isBeverage) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: _dividerToInfoSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoHeader(),
          const SizedBox(height: _infoHeaderSpacing),
          _buildDietaryInformation(),
          const SizedBox(height: _dietaryToAllergenSpacing),
          _buildAllergenInformation(),
          const SizedBox(height: _allergenToSourceSpacing),
          _buildInformationSource(),
        ],
      ),
    );
  }

  /// Builds additional information header
  Widget _buildInfoHeader() {
    return Text(
      _getUIText(_infoHeaderAdditionalKey),
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: _infoHeaderFontSize,
        fontWeight: _infoHeaderFontWeight,
        color: _infoHeaderColor,
      ),
    );
  }

  /// Builds dietary preferences information
  Widget _buildDietaryInformation() {
    final dietaryTypeIds = itemData['dietary_type_ids'] as List<dynamic>? ?? [];
    final isBeverage = itemData['is_beverage'] as bool? ?? false;

    final dietaryText = convertDietaryPreferencesToString(
      dietaryTypeIds.cast<int>(),
      currentLanguage,
      isBeverage,
      translationsCache,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getUIText(_infoHeaderDietaryKey),
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: _infoLabelFontSize,
            fontWeight: _infoLabelFontWeight,
            color: _infoLabelColor,
          ),
        ),
        Text(
          dietaryText ?? '',
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: _infoTextFontSize,
            fontWeight: _infoTextFontWeight,
            color: _infoTextColor,
          ),
        ),
      ],
    );
  }

  /// Builds allergen information
  Widget _buildAllergenInformation() {
    final allergyIds = itemData['allergy_ids'] as List<dynamic>? ?? [];
    final isBeverage = itemData['is_beverage'] as bool? ?? false;

    final allergyText = convertAllergiesToString(
      allergyIds.cast<int>(),
      currentLanguage,
      isBeverage,
      translationsCache,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getUIText(_infoHeaderAllergensKey),
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: _infoLabelFontSize,
            fontWeight: _infoLabelFontWeight,
            color: _infoLabelColor,
          ),
        ),
        Text(
          allergyText ?? '',
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: _infoTextFontSize,
            fontWeight: _infoTextFontWeight,
            color: _infoTextColor,
          ),
        ),
      ],
    );
  }

  /// Builds information source section
  Widget _buildInformationSource() {
    final disclaimerText = _getUIText(_infoDisclaimerBusinessKey)
        .replaceAll('[businessName]', businessName);

    final journeymateText = _getUIText(_infoDisclaimerJourneymateKey);

    return _InformationSourceSection(
      headerText: _getUIText(_infoHeaderSourceKey),
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
  static const double _expandedContentTopSpacing = 8.0;
  static const double _disclaimerToJourneymateSpacing = 8.0;

  /// Typography constants
  static const double _headerFontSize = 16.0;
  static const FontWeight _headerFontWeight = FontWeight.w400;
  static const double _contentFontSize = 15.0;
  static const FontWeight _contentFontWeight = FontWeight.w300;

  /// Colors
  static const Color _headerTextColor = Colors.black;
  static const Color _iconColor = Colors.black;
  static const Color _contentTextColor = Colors.black87;

  /// Icon size
  static const double _iconSize = 24.0;

  /// =========================================================================
  /// USER INTERACTION HANDLERS
  /// =========================================================================

  /// Toggles the expanded state
  void _toggleExpanded() {
    markUserEngaged();
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
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: _headerFontSize,
        fontWeight: _headerFontWeight,
        color: _headerTextColor,
      ),
    );
  }

  /// Builds the expand/collapse icon
  Widget _buildExpandIcon() {
    return Icon(
      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
      color: _iconColor,
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
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: _contentFontSize,
        fontWeight: _contentFontWeight,
        color: _contentTextColor,
      ),
    );
  }

  /// Builds the Journeymate text
  Widget _buildJourneymateText() {
    return Text(
      widget.journeymateText,
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: _contentFontSize,
        fontWeight: _contentFontWeight,
        color: _contentTextColor,
      ),
    );
  }
}
