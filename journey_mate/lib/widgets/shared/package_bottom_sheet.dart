import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import '../../providers/app_providers.dart';
import '../../services/translation_service.dart';
import '../../services/custom_functions/price_formatter.dart';
import '../../services/custom_functions/dietary_formatter.dart';
import '../../services/custom_functions/allergen_formatter.dart';
import '../../services/custom_functions/menu_language_currency_utils.dart';
import 'bottom_sheet_header.dart';
import 'information_source_section.dart';
import 'package_courses_display.dart';

/// A bottom sheet with nested navigation for viewing package details and menu items.
///
/// Features:
/// - Two-level navigation: Package view → Item detail view
/// - Platform-specific transitions (iOS swipe-back, Android slide)
/// - Image display with fallback states
/// - Currency conversion support with inline exchange rate fetching (self-contained)
/// - Language switching with API data fetching and caching (self-contained)
/// - Three-dot menu for language/currency options
/// - Expandable information source section
/// - Premium upcharge display
/// - Allergen and dietary preference information
/// - Localized UI text via translation system
///
/// Self-contained state management: All language and currency switching occurs
/// within local state and does NOT propagate changes to parent context.
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
    required this.currentLanguage,
    required this.translationsCache,
  });

  final double? width;
  final double? height;
  final dynamic normalizedMenuData;
  final int packageId;
  final String chosenCurrency;
  final String originalCurrencyCode;
  final double exchangeRate;
  final String businessName;
  final String currentLanguage;
  final dynamic translationsCache;

  @override
  ConsumerState<PackageBottomSheet> createState() =>
      _PackageBottomSheetState();
}

class _PackageBottomSheetState extends ConsumerState<PackageBottomSheet> {
  /// =========================================================================
  /// STATE & CONSTANTS
  /// =========================================================================

  /// Navigator key — reassigned on language/currency switch to force rebuild
  GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

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
  /// STATE - LANGUAGE SWITCHING
  /// =========================================================================

  /// The language code of the data currently being displayed
  late String _currentlyDisplayedLanguage;

  /// Whether currently loading language or currency switch
  bool _isLoadingLanguage = false;

  /// Cache of fetched language data to avoid re-fetching
  /// Key: language code, Value: API response from /menupackage
  late Map<String, dynamic> _languageDataCache;

  /// =========================================================================
  /// STATE - CURRENCY SWITCHING (SELF-CONTAINED)
  /// =========================================================================

  /// Override currency selected within this sheet (null = use widget prop)
  String? _overrideCurrency;

  /// Override exchange rate fetched within this sheet (null = use widget prop)
  double? _overrideExchangeRate;

  /// Effective currency: local override takes precedence over widget prop
  String get _effectiveCurrency => _overrideCurrency ?? widget.chosenCurrency;

  /// Effective exchange rate: local override takes precedence over widget prop
  double get _effectiveExchangeRate =>
      _overrideExchangeRate ?? widget.exchangeRate;

  /// =========================================================================
  /// EFFECTIVE DATA GETTERS
  /// =========================================================================

  /// Gets the effective normalized menu data (original or synthetic from API)
  dynamic get _effectiveNormalizedMenuData {
    if (_currentlyDisplayedLanguage == widget.currentLanguage) {
      return widget.normalizedMenuData;
    }
    final cached = _languageDataCache[_currentlyDisplayedLanguage];
    if (cached != null) {
      return _buildSyntheticMenuData(cached);
    }
    return widget.normalizedMenuData;
  }

  /// Gets the effective package data for the current language
  Map<String, dynamic>? get _effectivePackageData {
    if (_currentlyDisplayedLanguage == widget.currentLanguage) {
      return _packageData;
    }
    final cached = _languageDataCache[_currentlyDisplayedLanguage];
    if (cached != null) {
      // The API response IS the package data
      return cached;
    }
    return _packageData;
  }

  /// Gets the effective menu item map for the current language
  Map<int, Map<String, dynamic>> get _effectiveMenuItemMap {
    if (_currentlyDisplayedLanguage == widget.currentLanguage) {
      return _menuItemMap;
    }
    final cached = _languageDataCache[_currentlyDisplayedLanguage];
    if (cached != null) {
      final menuItems = cached[_menuItemsKey] as List<dynamic>? ?? [];
      return Map.fromEntries(
        menuItems.whereType<Map<String, dynamic>>().map(
              (item) => MapEntry(item[_menuItemIdKey] as int, item),
            ),
      );
    }
    return _menuItemMap;
  }

  /// =========================================================================
  /// LIFECYCLE METHODS
  /// =========================================================================

  @override
  void initState() {
    super.initState();
    _extractPackageData();
    _initializeLanguageCurrencyState();
  }

  /// Initializes language and currency state
  void _initializeLanguageCurrencyState() {
    _currentlyDisplayedLanguage = widget.currentLanguage;
    _languageDataCache = {};
    _isLoadingLanguage = false;
    _overrideCurrency = null;
    _overrideExchangeRate = null;
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
  /// SYNTHETIC DATA BUILDERS
  /// =========================================================================

  /// Builds synthetic normalizedMenuData from a /menupackage API response.
  /// Injects `category_type: 'menu_package'` so PackageCoursesDisplay
  /// can find the package via its existing _findSelectedPackage() logic.
  Map<String, dynamic> _buildSyntheticMenuData(Map<String, dynamic> apiResponse) {
    return {
      'menu_items': apiResponse['menu_items'] ?? [],
      'categories': [
        {...apiResponse, 'category_type': 'menu_package'},
      ],
    };
  }

  /// =========================================================================
  /// TRANSLATION HELPERS
  /// =========================================================================

  /// Gets human-readable language name from language code
  String _getLanguageName(String langCode) {
    final translationKey = 'lang_name_$langCode';
    return td(ref, translationKey);
  }

  /// Gets display name for currency (e.g., "Danish Krone (kr.)")
  String _getCurrencyDisplayName(String currencyCode) {
    return formatCurrencyDisplayName(
      widget.currentLanguage,
      currencyCode,
      widget.translationsCache,
    );
  }

  /// Gets the list of authentic languages from the original package data
  /// or from the first menu item in the original normalized data
  List<String> _getAuthenticLanguages() {
    // Try package data first
    if (_packageData is Map) {
      final authLangs = _packageData!['authentic_languages'];
      if (authLangs is List) {
        return authLangs.whereType<String>().toList();
      }
    }

    // Fallback: check first menu item in original normalized data
    if (widget.normalizedMenuData is Map<String, dynamic>) {
      final normalizedMap = widget.normalizedMenuData as Map<String, dynamic>;
      final menuItems = normalizedMap[_menuItemsKey] as List<dynamic>? ?? [];
      if (menuItems.isNotEmpty && menuItems.first is Map) {
        final authLangs = (menuItems.first as Map)['authentic_languages'];
        if (authLangs is List) {
          return authLangs.whereType<String>().toList();
        }
      }
    }

    return [];
  }

  /// =========================================================================
  /// MENU LOGIC - COMBINED LANGUAGE AND CURRENCY
  /// =========================================================================

  /// Computes which menu options should be shown (languages + currencies)
  List<MenuOption> _computeMenuOptions() {
    final options = <MenuOption>[];
    options.addAll(computeLanguageOptions(
      appLanguage: widget.currentLanguage,
      displayedLanguage: _currentlyDisplayedLanguage,
      authenticLanguages: _getAuthenticLanguages(),
      getLanguageName: _getLanguageName,
    ));
    options.addAll(computeCurrencyOptions(
      currentCurrency: _effectiveCurrency,
      appLanguage: widget.currentLanguage,
      getCurrencyDisplayName: _getCurrencyDisplayName,
    ));
    return options;
  }

  /// =========================================================================
  /// MENU HANDLERS
  /// =========================================================================

  /// Shows the action menu with available options
  void _showActionMenu() {
    final menuOptions = _computeMenuOptions();

    if (menuOptions.isEmpty) return;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 60,
        60,
        12,
        0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      color: AppColors.bgInput,
      elevation: 8,
      items: _buildMenuItemsWithDividers(menuOptions),
    ).then((value) {
      if (value != null) {
        _handleMenuSelection(value);
      }
    });
  }

  /// Builds menu items with dividers between each option
  List<PopupMenuEntry<String>> _buildMenuItemsWithDividers(
      List<MenuOption> options) {
    final items = <PopupMenuEntry<String>>[];

    for (int i = 0; i < options.length; i++) {
      items.add(_buildMenuItem(options[i]));

      if (i < options.length - 1) {
        items.add(const PopupMenuDivider(height: 1));
      }
    }

    return items;
  }

  /// Builds a menu item (language or currency)
  PopupMenuItem<String> _buildMenuItem(MenuOption option) {
    return PopupMenuItem<String>(
      value: '${option.type}:${option.code}',
      enabled: !_isLoadingLanguage,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _isLoadingLanguage
          ? _buildLoadingMenuItem()
          : _buildMenuItemContent(option),
    );
  }

  /// Builds the loading state for menu items
  Widget _buildLoadingMenuItem() {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.black54,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Loading...',
          style: AppTypography.body.copyWith(
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  /// Builds the content of a menu item
  Widget _buildMenuItemContent(MenuOption option) {
    final String displayText;

    if (option.type == 'language') {
      final template = td(ref, 'menu_view_dish_in_param');
      displayText = template.replaceAll('{language}', option.displayName);
    } else {
      final template = td(ref, 'menu_view_price_in_param');
      displayText = template.replaceAll('{currency}', option.displayName);
    }

    final finalText = displayText.isEmpty
        ? (option.type == 'language'
            ? 'View dish in ${option.displayName}'
            : 'View price in ${option.displayName}')
        : displayText;

    return Text(
      finalText,
      style: AppTypography.body,
    );
  }

  /// Handles menu selection (language or currency)
  Future<void> _handleMenuSelection(String selection) async {
    final parts = selection.split(':');
    if (parts.length != 2) return;

    final type = parts[0];
    final code = parts[1];

    if (type == 'language') {
      await _handleLanguageSwitch(code);
    } else if (type == 'currency') {
      await _handleCurrencySwitch(code);
    }
  }

  /// Handles switching to a different language
  Future<void> _handleLanguageSwitch(String targetLanguageCode) async {
    // Switching back to app language → use original widget data
    if (targetLanguageCode == widget.currentLanguage) {
      setState(() {
        _currentlyDisplayedLanguage = targetLanguageCode;
        _navigatorKey = GlobalKey<NavigatorState>();
      });
      return;
    }

    // Check if we already have this language cached
    if (_languageDataCache.containsKey(targetLanguageCode)) {
      setState(() {
        _currentlyDisplayedLanguage = targetLanguageCode;
        _navigatorKey = GlobalKey<NavigatorState>();
      });
      return;
    }

    // Show loading state
    setState(() {
      _isLoadingLanguage = true;
    });

    try {
      final response = await ApiService.instance.getMenuPackage(
        packageId: widget.packageId,
        languageCode: targetLanguageCode,
      );

      if (response.succeeded && response.jsonBody != null) {
        final data = response.jsonBody as Map<String, dynamic>;

        // Cache the fetched data
        _languageDataCache[targetLanguageCode] = data;

        if (context.mounted) {
          setState(() {
            _currentlyDisplayedLanguage = targetLanguageCode;
            _isLoadingLanguage = false;
            _navigatorKey = GlobalKey<NavigatorState>();
          });
        }
      } else {
        throw Exception(response.error ?? td(ref, 'error_load_language'));
      }
    } catch (e) {
      if (context.mounted) {
        setState(() {
          _isLoadingLanguage = false;
        });

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(td(ref, 'error_load_language')),
            duration: const Duration(seconds: 3),
            backgroundColor: AppColors.error.withValues(alpha: 0.9),
          ),
        );
      }
    }
  }

  /// Handles currency switching with inline exchange rate fetching
  Future<void> _handleCurrencySwitch(String newCurrencyCode) async {
    if (newCurrencyCode == 'DKK') {
      setState(() {
        _overrideCurrency = 'DKK';
        _overrideExchangeRate = 1.0;
        _navigatorKey = GlobalKey<NavigatorState>();
      });
      return;
    }

    setState(() => _isLoadingLanguage = true);

    try {
      final response = await ApiService.instance.getExchangeRate(
        toCurrency: newCurrencyCode,
      );

      if (response.succeeded && response.jsonBody != null) {
        final data = response.jsonBody;

        final double? rate = (data is List && data.isNotEmpty)
            ? (data[0]['rate'] as num?)?.toDouble()
            : null;

        if (rate != null && context.mounted) {
          setState(() {
            _overrideCurrency = newCurrencyCode;
            _overrideExchangeRate = rate;
            _isLoadingLanguage = false;
            _navigatorKey = GlobalKey<NavigatorState>();
          });
          return;
        }
        throw Exception('Invalid rate in response');
      } else {
        throw Exception('Status: ${response.statusCode}');
      }
    } catch (e) {
      if (context.mounted) {
        setState(() {
          _isLoadingLanguage = false;
        });

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(td(ref, 'error_update_currency')),
            duration: const Duration(seconds: 3),
            backgroundColor: AppColors.error.withValues(alpha: 0.9),
          ),
        );
      }
    }
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
        chosenCurrency: _effectiveCurrency,
        originalCurrencyCode: widget.originalCurrencyCode,
        exchangeRate: _effectiveExchangeRate,
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
        chosenCurrency: _effectiveCurrency,
        originalCurrencyCode: widget.originalCurrencyCode,
        exchangeRate: _effectiveExchangeRate,
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
        packageData: _effectivePackageData!,
        menuItemMap: _effectiveMenuItemMap,
        normalizedMenuData: _effectiveNormalizedMenuData,
        chosenCurrency: _effectiveCurrency,
        originalCurrencyCode: widget.originalCurrencyCode,
        exchangeRate: _effectiveExchangeRate,
        onClose: () => _handleClose(context),
        onItemTap: _navigateToItem,
        onShowMenu: _showActionMenu,
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
      child: Stack(
        children: [
          Navigator(
            key: _navigatorKey,
            onGenerateRoute: _onGenerateRoute,
          ),
          if (_isLoadingLanguage) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  /// Builds loading overlay during language/currency switch
  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
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
    required this.onShowMenu,
  });

  final Map<String, dynamic> packageData;
  final Map<int, Map<String, dynamic>> menuItemMap;
  final dynamic normalizedMenuData;
  final String chosenCurrency;
  final String originalCurrencyCode;
  final double exchangeRate;
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) onItemTap;
  final VoidCallback onShowMenu;

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
          rightAction: BottomSheetAction(
            icon: Icons.more_horiz,
            onPressed: onShowMenu,
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
  static const double _descriptionToDividerSpacing = AppSpacing.xl;
  static const double _dividerToInfoSpacing = AppSpacing.xl;
  static const double _infoHeaderSpacing = 4.0;
  static const double _dietaryToAllergenSpacing = AppSpacing.md;
  static const double _allergenToSourceSpacing = AppSpacing.md;
  static const double _bottomPadding = AppSpacing.xl;

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
      style: AppTypography.h4,
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
      padding: EdgeInsets.only(top: AppSpacing.xs), // 4px
      child: Text(
        displayPrice,
        style: AppTypography.bodySm.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.accent,
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

    if (itemDescription.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: AppSpacing.sm), // 8px
      child: Text(
        itemDescription,
        style: AppTypography.body.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  /// Builds divider
  Widget _buildDivider() {
    return const Divider(
      color: AppColors.border,
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
      style: AppTypography.h5,
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
          style: AppTypography.h6,
        ),
        Text(
          dietaryText ?? '',
          style: AppTypography.body,
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
          style: AppTypography.h6,
        ),
        Text(
          allergyText ?? '',
          style: AppTypography.body,
        ),
      ],
    );
  }

  /// Builds information source section
  Widget _buildInformationSource(WidgetRef ref) {
    final disclaimerText = td(ref, _infoDisclaimerBusinessKey)
        .replaceAll('[businessName]', businessName);

    final journeymateText = td(ref, _infoDisclaimerJourneymateKey);

    return InformationSourceSection(
      headerText: td(ref, _infoHeaderSourceKey),
      disclaimerText: disclaimerText,
      journeymateText: journeymateText,
    );
  }
}
