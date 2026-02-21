import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import '../../services/translation_service.dart';
import '../../services/custom_functions/price_formatter.dart';
import '../../services/custom_functions/allergen_formatter.dart';
import '../../services/custom_functions/dietary_formatter.dart';
import '../../services/custom_functions/currency_name_formatter.dart';

/// A comprehensive modal bottom sheet that displays detailed information about
/// a single menu item from a restaurant's menu.
///
/// Features:
/// - Full-height draggable modal sheet with image header
/// - Item name, description, and base price display
/// - "From" pricing prefix for items with variations
/// - Modifier groups with hierarchical ordering (Variation → Option → Ingredient → Add-on)
/// - Selection constraints display (required, optional, choose exactly, choose up to, etc.)
/// - Dietary preferences and allergen information
/// - Currency conversion with inline exchange rate fetching (self-contained)
/// - Language switching with API data fetching and caching (self-contained)
/// - Three-dot menu for language/currency options
/// - Information source disclaimer (business + JourneyMate)
///
/// Self-contained state management: All language and currency switching occurs
/// within local state and does NOT propagate changes to parent context.
class ItemBottomSheet extends ConsumerStatefulWidget {
  const ItemBottomSheet({
    super.key,
    this.width,
    this.height,
    required this.itemData,
    required this.chosenCurrency,
    required this.originalCurrencyCode,
    required this.exchangeRate,
    required this.currentLanguage,
    required this.businessName,
    required this.translationsCache,
    this.hasVariations,
  });

  final double? width;
  final double? height;
  final dynamic itemData;
  final String chosenCurrency;
  final String originalCurrencyCode;
  final double exchangeRate;
  final String currentLanguage;
  final String businessName;
  final dynamic translationsCache;
  final bool? hasVariations;

  @override
  ConsumerState<ItemBottomSheet> createState() => _ItemBottomSheetState();
}

class _ItemBottomSheetState extends ConsumerState<ItemBottomSheet> {
  /// =========================================================================
  /// CONSTANTS - DIMENSIONS & LAYOUT
  /// =========================================================================

  static const double _defaultSheetHeightFactor = 0.90;

  static const double _imageHeight = 200.0;
  static const double _noImageHeaderHeight = 64.0;
  static const double _swipeBarWidth = 80.0;
  static const double _swipeBarHeight = 4.0;
  static const double _swipeBarTopPadding = 8.0;
  static const double _swipeBarBottomPadding = 12.0;
  static const double _closeButtonSize = 40.0;
  static const double _closeButtonPosition = 12.0;
  static const double _menuButtonSize = 40.0;
  static const double _menuButtonPosition = 12.0;

  static const double _menuItemFontSize = 15.0;
  static const FontWeight _menuItemFontWeight = FontWeight.w400;

  /// =========================================================================
  /// STATE - LANGUAGE SWITCHING
  /// =========================================================================

  /// The language code of the data currently being displayed
  late String _currentlyDisplayedLanguage;

  /// Whether currently loading language switch
  bool _isLoadingLanguage = false;

  /// Cache of fetched language data to avoid re-fetching
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
  /// LIFECYCLE METHODS
  /// =========================================================================

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  @override
  void didUpdateWidget(covariant ItemBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reset state if item changed
    if (_hasItemChanged(oldWidget)) {
      _initializeState();
    }
  }

  /// Initializes/resets the language and currency state
  void _initializeState() {
    _currentlyDisplayedLanguage = widget.currentLanguage;
    _languageDataCache = {
      widget.currentLanguage: widget.itemData,
    };
    _isLoadingLanguage = false;

    // Reset currency overrides
    _overrideCurrency = null;
    _overrideExchangeRate = null;
  }

  /// Checks if the item has changed (different menu_item_id)
  bool _hasItemChanged(ItemBottomSheet oldWidget) {
    if (widget.itemData is! Map || oldWidget.itemData is! Map) {
      return true;
    }

    final currentId = widget.itemData['menu_item_id'];
    final oldId = oldWidget.itemData['menu_item_id'];

    return currentId != oldId;
  }

  /// =========================================================================
  /// TRANSLATION HELPERS
  /// =========================================================================

  /// Gets UI translation from API response, with fallback to translation cache
  String _getUITextFromApi(String key) {
    final data = _currentItemData;

    // Try to get from API's ui_translations first
    if (data is Map) {
      final uiTranslations = data['ui_translations'];
      if (uiTranslations is Map) {
        final value = uiTranslations[key];
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
    }

    // Fallback to translation cache (using app language)
    return ts(context, key);
  }

  /// Gets human-readable language name from language code
  /// Always uses translationsCache (app language) for consistency
  String _getLanguageName(String langCode) {
    final translationKey = 'lang_name_$langCode';
    return ts(context, translationKey);
  }

  /// Gets display name for currency (e.g., "Danish Krone (kr.)")
  String _getCurrencyDisplayName(String currencyCode) {
    final localizedName = getLocalizedCurrencyName(
      widget.currentLanguage,
      currencyCode,
      widget.translationsCache,
    );

    final rulesJson = getCurrencyFormattingRules(currencyCode);
    String symbol = currencyCode;

    if (rulesJson != null) {
      try {
        final rules = json.decode(rulesJson) as Map<String, dynamic>;
        symbol = rules['symbol'] as String? ?? currencyCode;
      } catch (_) {}
    }

    return '$localizedName ($symbol)';
  }

  /// =========================================================================
  /// DATA EXTRACTION HELPERS
  /// =========================================================================

  /// Gets the currently displayed item data
  dynamic get _currentItemData {
    final cached = _languageDataCache[_currentlyDisplayedLanguage];
    return cached ?? widget.itemData;
  }

  /// Checks if item has an image
  bool _hasItemImage() {
    final imageUrl = _getStringValue('item_image_url');
    return imageUrl.isNotEmpty;
  }

  /// Safely extracts string value from CURRENT item data
  String _getStringValue(String key, [String defaultValue = '']) {
    final data = _currentItemData;
    if (data is! Map) return defaultValue;
    final value = data[key];
    return (value is String && value.isNotEmpty) ? value : defaultValue;
  }

  /// Safely extracts boolean value from CURRENT item data
  bool _getBoolValue(String key, [bool defaultValue = false]) {
    final data = _currentItemData;
    if (data is! Map) return defaultValue;
    final value = data[key];
    return value is bool ? value : defaultValue;
  }

  /// Safely extracts list value from CURRENT item data
  List<dynamic> _getListValue(String key) {
    final data = _currentItemData;
    if (data is! Map) return [];
    final value = data[key];
    return value is List ? value : [];
  }

  /// Safely extracts integer list from CURRENT item data
  List<int> _getIntListValue(String key) {
    final list = _getListValue(key);
    return list.whereType<int>().toList();
  }

  /// Gets the list of authentic languages from item data
  List<String> _getAuthenticLanguages() {
    final data = _currentItemData;
    if (data is! Map) return [];
    final authLangs = data['authentic_languages'];
    if (authLangs is List) {
      return authLangs.whereType<String>().toList();
    }
    return [];
  }

  /// =========================================================================
  /// MENU LOGIC - COMBINED LANGUAGE AND CURRENCY
  /// =========================================================================

  /// Computes which menu options should be shown (languages + currencies)
  List<_MenuOption> _computeMenuOptions() {
    final options = <_MenuOption>[];

    // Add language options
    options.addAll(_computeLanguageOptions());

    // Add currency options
    options.addAll(_computeCurrencyOptions());

    return options;
  }

  /// Computes language options
  List<_MenuOption> _computeLanguageOptions() {
    final options = <_MenuOption>[];
    final appLanguage = widget.currentLanguage;
    final displayedLanguage = _currentlyDisplayedLanguage;
    final authenticLanguages = _getAuthenticLanguages();

    // RULE 4: If viewing different language than app language, offer to go back
    if (displayedLanguage != appLanguage) {
      options.add(_MenuOption(
        type: 'language',
        code: appLanguage,
        displayName: _getLanguageName(appLanguage),
      ));
    }

    // RULE 1: App language is English → offer Danish
    if (appLanguage == 'en' && displayedLanguage != 'da') {
      options.add(_MenuOption(
        type: 'language',
        code: 'da',
        displayName: _getLanguageName('da'),
      ));
      return options;
    }

    // RULE 2: App language is Danish → offer English
    if (appLanguage == 'da' && displayedLanguage != 'en') {
      options.add(_MenuOption(
        type: 'language',
        code: 'en',
        displayName: _getLanguageName('en'),
      ));
      return options;
    }

    // RULE 3: App language is Other → offer authentic languages (up to 3)
    if (appLanguage != 'en' && appLanguage != 'da') {
      final availableAuthLangs = authenticLanguages
          .where((lang) => lang != displayedLanguage)
          .take(3)
          .toList();

      for (final langCode in availableAuthLangs) {
        options.add(_MenuOption(
          type: 'language',
          code: langCode,
          displayName: _getLanguageName(langCode),
        ));
      }
    }

    return options;
  }

  /// Computes currency options based on user's current selection
  /// Uses _effectiveCurrency to check against local override
  List<_MenuOption> _computeCurrencyOptions() {
    final options = <_MenuOption>[];
    final currentCurrency = _effectiveCurrency;
    final appLanguage = widget.currentLanguage;

    // RULE 1: If user chose USD → offer DKK only
    if (currentCurrency == 'USD') {
      options.add(_MenuOption(
        type: 'currency',
        code: 'DKK',
        displayName: _getCurrencyDisplayName('DKK'),
      ));
      return options;
    }

    // RULE 2: If user chose GBP → offer DKK only
    if (currentCurrency == 'GBP') {
      options.add(_MenuOption(
        type: 'currency',
        code: 'DKK',
        displayName: _getCurrencyDisplayName('DKK'),
      ));
      return options;
    }

    // RULE 3: If user chose English + DKK → offer USD and GBP
    if (appLanguage == 'en' && currentCurrency == 'DKK') {
      options.add(_MenuOption(
        type: 'currency',
        code: 'USD',
        displayName: _getCurrencyDisplayName('USD'),
      ));
      options.add(_MenuOption(
        type: 'currency',
        code: 'GBP',
        displayName: _getCurrencyDisplayName('GBP'),
      ));
      return options;
    }

    // RULE 4: Other currencies → offer DKK if not already selected
    if (currentCurrency != 'DKK') {
      options.add(_MenuOption(
        type: 'currency',
        code: 'DKK',
        displayName: _getCurrencyDisplayName('DKK'),
      ));
    }

    return options;
  }

  /// =========================================================================
  /// MENU HANDLERS
  /// =========================================================================

  /// Shows the action menu with available options
  void _showActionMenu() {
    final menuOptions = _computeMenuOptions();

    // If no options available, don't show menu
    if (menuOptions.isEmpty) {
      return;
    }

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
      List<_MenuOption> options) {
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
  PopupMenuItem<String> _buildMenuItem(_MenuOption option) {
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
        const Text(
          'Loading...',
          style: TextStyle(
            fontSize: _menuItemFontSize,
            fontWeight: _menuItemFontWeight,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  /// Builds the content of a menu item
  Widget _buildMenuItemContent(_MenuOption option) {
    final String displayText;

    if (option.type == 'language') {
      final template = ts(context, 'menu_view_dish_in_param');
      displayText = template.replaceAll('{language}', option.displayName);
    } else {
      final template = ts(context, 'menu_view_price_in_param');
      displayText = template.replaceAll('{currency}', option.displayName);
    }

    final finalText = displayText.isEmpty
        ? (option.type == 'language'
            ? 'View dish in ${option.displayName}'
            : 'View price in ${option.displayName}')
        : displayText;

    return Text(
      finalText,
      style: const TextStyle(
        fontSize: _menuItemFontSize,
        fontWeight: _menuItemFontWeight,
        color: AppColors.textPrimary,
      ),
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
    // Check if we already have this language cached
    if (_languageDataCache.containsKey(targetLanguageCode)) {
      setState(() {
        _currentlyDisplayedLanguage = targetLanguageCode;
      });
      return;
    }

    // Show loading state
    setState(() {
      _isLoadingLanguage = true;
    });

    try {
      // Get menu_item_id from current data
      final menuItemId = _currentItemData['menu_item_id'];

      if (menuItemId == null) {
        throw Exception('Menu item ID not found');
      }

      final response = await http.get(
        Uri.parse('https://wvb8ww.buildship.run/menuItem').replace(
          queryParameters: {
            'menu_item_id': menuItemId.toString(),
            'language_code': targetLanguageCode,
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        // Cache the fetched data
        _languageDataCache[targetLanguageCode] = data;

        // Update displayed language
        if (context.mounted) {
          setState(() {
            _currentlyDisplayedLanguage = targetLanguageCode;
            _isLoadingLanguage = false;
          });
        }
      } else {
        throw Exception('Failed to load language data: ${response.statusCode}');
      }
    } catch (e) {
      // Show error message
      if (context.mounted) {
        setState(() {
          _isLoadingLanguage = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load language: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: AppColors.error.withValues(alpha: 0.9),
          ),
        );
      }
    }
  }

  /// Handles currency switching with inline exchange rate fetching
  ///
  /// This is self-contained within the sheet - does not update parent state.
  /// Fetches exchange rate from API and stores locally in _overrideCurrency
  /// and _overrideExchangeRate.
  Future<void> _handleCurrencySwitch(String newCurrencyCode) async {
    if (newCurrencyCode == 'DKK') {
      setState(() {
        _overrideCurrency = 'DKK';
        _overrideExchangeRate = 1.0;
      });
      return;
    }

    setState(() => _isLoadingLanguage = true);

    try {
      final url = Uri.parse('https://wvb8ww.buildship.run/getExchangeRates')
          .replace(queryParameters: {
        'to_currency': newCurrencyCode,
        'from_currency': 'DKK',
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final double? rate = (data is List && data.isNotEmpty)
            ? (data[0]['rate'] as num?)?.toDouble()
            : null;

        if (rate != null && context.mounted) {
          setState(() {
            _overrideCurrency = newCurrencyCode;
            _overrideExchangeRate = rate;
            _isLoadingLanguage = false;
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not update currency'),
            duration: const Duration(seconds: 3),
            backgroundColor: AppColors.error.withValues(alpha: 0.9),
          ),
        );
      }
    }
  }

  /// =========================================================================
  /// MODIFIER GROUP HELPERS
  /// =========================================================================

  /// Defines the display order priority for modifier group types.
  static const Map<String, int> _modifierTypeHierarchy = {
    'Variation': 1,
    'Option': 2,
    'Ingredient': 3,
    'Add-on': 4,
  };

  /// Sorts modifier groups according to the defined type hierarchy
  List<Map<String, dynamic>> _sortModifierGroups(
      List<Map<String, dynamic>> groups) {
    return groups.toList()
      ..sort((a, b) {
        final typeA = a['type'] as String? ?? '';
        final typeB = b['type'] as String? ?? '';

        final priorityA = _modifierTypeHierarchy[typeA] ?? 999;
        final priorityB = _modifierTypeHierarchy[typeB] ?? 999;

        return priorityA.compareTo(priorityB);
      });
  }

  /// Checks if item has any modifier groups
  bool _hasModifierGroups() {
    final modifierGroups = _getListValue('item_modifier_groups');
    return modifierGroups.isNotEmpty;
  }

  /// Helper method to detect zero prices in any currency format
  bool _isZeroPrice(String price) {
    if (price.isEmpty) return true;
    final trimmed = price.trim();

    if (trimmed == '0') return true;

    // Prefix currencies
    if (RegExp(r'^[€£\$¥]\s*0(?:[.,]0+)?$').hasMatch(trimmed)) {
      return true;
    }

    // Suffix currencies
    if (RegExp(r'^0(?:[.,]0+)?\s*(?:kr\.|zł|₩|₴)$').hasMatch(trimmed)) {
      return true;
    }

    return false;
  }

  /// =========================================================================
  /// CLOSE HANDLER
  /// =========================================================================

  /// Handles closing the bottom sheet
  void _handleClose() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// =========================================================================
  /// UI BUILDERS - MAIN LAYOUT
  /// =========================================================================

  @override
  Widget build(BuildContext context) {
    final hasImage = _hasItemImage();

    return Container(
      width: widget.width,
      height: _calculateSheetHeight(context),
      decoration: _getSheetDecoration(),
      child: Stack(
        children: [
          Column(
            children: [
              _buildHeaderSection(hasImage),
              Expanded(child: _buildScrollableContent()),
            ],
          ),
          // Loading overlay when switching languages or currencies
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
    return BoxDecoration(
      color: Colors.white,
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(AppRadius.bottomSheet)),
    );
  }

  /// =========================================================================
  /// UI BUILDERS - HEADER SECTION
  /// =========================================================================

  /// Builds the header section with image/swipe bar/close button/menu button
  Widget _buildHeaderSection(bool hasImage) {
    return SizedBox(
      height: hasImage ? _imageHeight : _noImageHeaderHeight,
      child: Stack(
        children: [
          if (hasImage) _buildItemImage(),
          _buildSwipeBar(),
          _buildCloseButton(),
          _buildMenuButton(),
        ],
      ),
    );
  }

  /// Builds the item image
  Widget _buildItemImage() {
    final imageUrl = _getStringValue('item_image_url');

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: double.infinity,
      height: _imageHeight,
      fit: BoxFit.cover,
      errorWidget: (context, url, error) => _buildImageError(),
    );
  }

  /// Builds image error state
  Widget _buildImageError() {
    return Container(
      height: _imageHeight,
      color: AppColors.bgSurface,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 48.0,
          color: AppColors.textSecondary.withValues(alpha: 0.3),
        ),
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
        padding: EdgeInsets.only(
          top: _swipeBarTopPadding,
          bottom: _swipeBarBottomPadding,
        ),
        child: Center(
          child: Container(
            width: _swipeBarWidth,
            height: _swipeBarHeight,
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              borderRadius: BorderRadius.circular(AppRadius.bottomSheet),
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
          color: AppColors.bgInput,
          borderRadius: BorderRadius.circular(AppRadius.bottomSheet),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(Icons.close, color: AppColors.textPrimary, size: 30.0),
          onPressed: _handleClose,
        ),
      ),
    );
  }

  /// Builds the three-dot menu button (horizontal dots)
  Widget _buildMenuButton() {
    return Positioned(
      top: _menuButtonPosition,
      right: _menuButtonPosition,
      child: Container(
        width: _menuButtonSize,
        height: _menuButtonSize,
        decoration: BoxDecoration(
          color: AppColors.bgInput,
          borderRadius: BorderRadius.circular(AppRadius.bottomSheet),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.more_horiz,
            color: AppColors.textPrimary,
            size: 28.0,
          ),
          onPressed: _showActionMenu,
        ),
      ),
    );
  }

  /// =========================================================================
  /// UI BUILDERS - SCROLLABLE CONTENT
  /// =========================================================================

  /// Builds the scrollable content area
  Widget _buildScrollableContent() {
    final hasModifiers = _hasModifierGroups();

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl + AppSpacing.xs), // 28px
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSpacing.md),
            _buildItemName(),
            _buildPriceSection(),
            _buildItemDescription(),
            if (hasModifiers) ...[
              SizedBox(height: AppSpacing.lg),
              _buildModifierGroupsSection(),
              SizedBox(height: AppSpacing.xxl),
              _buildDivider(),
            ] else ...[
              SizedBox(height: AppSpacing.xxl),
              _buildDivider(),
            ],
            SizedBox(height: AppSpacing.xl),
            _buildAdditionalInformation(),
            SizedBox(height: AppSpacing.xxxl - 2), // 30px
          ],
        ),
      ),
    );
  }

  /// =========================================================================
  /// UI BUILDERS - ITEM DETAILS
  /// =========================================================================

  /// Builds item name
  Widget _buildItemName() {
    final itemName = _getStringValue('item_name', 'Unnamed Item');

    return Text(
      itemName,
      style: AppTypography.pageTitle.copyWith(
        fontSize: 22.0,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  /// Builds price section with dynamically calculated price
  /// Uses _effectiveCurrency and _effectiveExchangeRate for conversions
  Widget _buildPriceSection() {
    String displayPrice = _formatDisplayPrice();

    if (displayPrice.isEmpty || _isZeroPrice(displayPrice)) {
      return const SizedBox.shrink();
    }

    final isPricePerPerson = _getBoolValue('is_price_per_person');
    if (isPricePerPerson) {
      final perPersonSuffix = _getUITextFromApi('price_per_person');
      displayPrice = '$displayPrice — $perPersonSuffix';
    }

    return Padding(
      padding: EdgeInsets.only(top: AppSpacing.xs / 2), // 2px
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.chip / 1.33), // ~6px
        ),
        child: Text(
          displayPrice,
          style: AppTypography.label.copyWith(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }

  /// Formats display price dynamically using effective currency and exchange rate
  /// Uses _effectiveCurrency and _effectiveExchangeRate for self-contained conversions
  String _formatDisplayPrice() {
    if (_currentItemData is! Map) return '';

    final basePrice = _currentItemData['base_price'];
    if (basePrice is! num || basePrice <= 0) return '';

    final formattedPrice = convertAndFormatPrice(
      basePrice.toDouble(),
      widget.originalCurrencyCode,
      _effectiveExchangeRate,
      _effectiveCurrency,
    );

    if (formattedPrice == null || formattedPrice.isEmpty) return '';

    final hasVariations = widget.hasVariations ?? false;

    if (hasVariations) {
      final fromText = ts(context, 'price_from');
      return fromText.isNotEmpty
          ? '$fromText $formattedPrice'
          : 'From $formattedPrice';
    }

    return formattedPrice;
  }

  /// Builds item description
  Widget _buildItemDescription() {
    final itemDescription = _getStringValue('item_description');

    if (itemDescription.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: AppSpacing.xs), // 4px
      child: Text(
        itemDescription,
        style: AppTypography.bodyRegular.copyWith(
          fontSize: 16.0,
          fontWeight: FontWeight.w300,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  /// Builds divider
  Widget _buildDivider() {
    return Divider(
      color: AppColors.border,
      thickness: 1.0,
    );
  }

  /// =========================================================================
  /// UI BUILDERS - MODIFIER GROUPS SECTION
  /// =========================================================================

  /// Builds the complete modifier groups section with hierarchical ordering
  Widget _buildModifierGroupsSection() {
    final allModifierGroups = _getListValue('item_modifier_groups')
        .whereType<Map<String, dynamic>>()
        .toList();

    if (allModifierGroups.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedGroups = _sortModifierGroups(allModifierGroups);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildModifierGroupWidgets(sortedGroups),
    );
  }

  /// Builds widgets for all modifier groups with spacing
  /// Passes _effectiveCurrency and _effectiveExchangeRate for price display
  List<Widget> _buildModifierGroupWidgets(List<Map<String, dynamic>> groups) {
    final widgets = <Widget>[];

    // Extract ui_translations from current item data
    final data = _currentItemData;
    final uiTranslations =
        data is Map ? data['ui_translations'] as Map<String, dynamic>? : null;

    for (int i = 0; i < groups.length; i++) {
      widgets.add(
        _ModifierGroupDisplay(
          modifierGroup: groups[i],
          chosenCurrency: _effectiveCurrency,
          originalCurrencyCode: widget.originalCurrencyCode,
          exchangeRate: _effectiveExchangeRate,
          uiTranslations: uiTranslations,
          translationsCache: widget.translationsCache,
          currentLanguage: _currentlyDisplayedLanguage,
        ),
      );

      if (i < groups.length - 1) {
        widgets.add(SizedBox(height: AppSpacing.md));
      }
    }

    return widgets;
  }

  /// =========================================================================
  /// UI BUILDERS - ADDITIONAL INFORMATION
  /// =========================================================================

  /// Builds additional information section
  Widget _buildAdditionalInformation() {
    final isBeverage = _getBoolValue('is_beverage');

    if (isBeverage) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoHeader(),
        SizedBox(height: AppSpacing.xs),
        _buildDietaryInformation(),
        SizedBox(height: AppSpacing.md),
        _buildAllergenInformation(),
        SizedBox(height: AppSpacing.md),
        _buildInformationSource(),
      ],
    );
  }

  /// Builds additional information header
  Widget _buildInfoHeader() {
    return Text(
      _getUITextFromApi('info_header_additional'),
      style: AppTypography.label.copyWith(
        fontSize: 15.0,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// Builds dietary preferences information
  Widget _buildDietaryInformation() {
    final dietaryTypeIds = _getIntListValue('dietary_type_ids');
    final isBeverage = _getBoolValue('is_beverage');

    final dietaryText = convertDietaryPreferencesToString(
      dietaryTypeIds,
      widget.currentLanguage,
      isBeverage,
      widget.translationsCache,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getUITextFromApi('info_header_dietary'),
          style: AppTypography.bodySmall.copyWith(
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          dietaryText ?? '',
          style: AppTypography.bodySmall.copyWith(
            fontSize: 14.0,
            fontWeight: FontWeight.w300,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Builds allergen information
  Widget _buildAllergenInformation() {
    final allergyIds = _getIntListValue('allergy_ids');
    final isBeverage = _getBoolValue('is_beverage');

    final allergyText = convertAllergiesToString(
      allergyIds,
      widget.currentLanguage,
      isBeverage,
      widget.translationsCache,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getUITextFromApi('info_header_allergens'),
          style: AppTypography.bodySmall.copyWith(
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          allergyText ?? '',
          style: AppTypography.bodySmall.copyWith(
            fontSize: 14.0,
            fontWeight: FontWeight.w300,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Builds information source section
  Widget _buildInformationSource() {
    final disclaimerText = _getUITextFromApi('info_disclaimer_business')
        .replaceAll('[businessName]', widget.businessName);

    final journeymateText = _getUITextFromApi('info_disclaimer_journeymate');

    return _InformationSourceSection(
      headerText: _getUITextFromApi('info_header_source'),
      disclaimerText: disclaimerText,
      journeymateText: journeymateText,
    );
  }
}

/// ============================================================================
/// MENU OPTION DATA CLASS
/// ============================================================================

/// Represents a menu option (language or currency)
class _MenuOption {
  const _MenuOption({
    required this.type,
    required this.code,
    required this.displayName,
  });

  final String type; // 'language' or 'currency'
  final String code; // Language code or currency code
  final String displayName;
}

/// ============================================================================
/// MODIFIER GROUP DISPLAY WIDGET
/// ============================================================================

/// Displays a single modifier group with its options and selection constraints
class _ModifierGroupDisplay extends StatelessWidget {
  const _ModifierGroupDisplay({
    required this.modifierGroup,
    required this.chosenCurrency,
    required this.originalCurrencyCode,
    required this.exchangeRate,
    required this.uiTranslations,
    required this.translationsCache,
    required this.currentLanguage,
  });

  final Map<String, dynamic> modifierGroup;
  final String chosenCurrency;
  final String originalCurrencyCode;
  final double exchangeRate;
  final Map<String, dynamic>? uiTranslations;
  final dynamic translationsCache;
  final String currentLanguage;

  static const double _headerFontSize = 16.0;
  static const FontWeight _headerFontWeight = FontWeight.w500;
  static const Color _headerColor = Colors.black;
  static const double _constraintFontSize = 14.0;
  static const FontWeight _constraintFontWeight = FontWeight.w400;
  static const Color _constraintColor = Colors.black54;
  static const double _modifierFontSize = 14.0;
  static const FontWeight _modifierFontWeight = FontWeight.w400;
  static const Color _modifierColor = Colors.black87;
  static const double _headerBottomSpacing = 2.0;
  static const double _constraintBottomSpacing = 8.0;
  static const double _modifierItemSpacing = 2.0;

  /// Gets UI text: API translations first, then translationsCache
  String _getUIText(BuildContext context, String key) {
    // Try API translations first (for switched language)
    if (uiTranslations != null) {
      final value = uiTranslations![key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    // Use static translations (for initial app language)
    return ts(context, key);
  }

  String _getGroupType() {
    return modifierGroup['type'] as String? ?? '';
  }

  List<dynamic> _getModifiers() {
    return modifierGroup['modifiers'] as List<dynamic>? ?? [];
  }

  _SelectionConstraints _getConstraints() {
    final minSelections = modifierGroup['min_selections'] as int? ?? 0;
    final maxSelections = modifierGroup['max_selections'] as int? ?? 0;
    final isRequired = minSelections > 0;

    return _SelectionConstraints(
      isRequired: isRequired,
      minSelections: minSelections,
      maxSelections: maxSelections,
    );
  }

  bool _isVariationGroup() {
    return _getGroupType() == 'Variation';
  }

  String _buildConstraintText(BuildContext context, _SelectionConstraints constraints) {
    final min = constraints.minSelections;
    final max = constraints.maxSelections;

    if (constraints.isRequired && min == max && min > 0) {
      return '${_getUIText(context, 'modifier_required')} • ${_getUIText(context, 'modifier_choose_exactly')} $min';
    }

    if (constraints.isRequired && min > 0 && max > min) {
      return '${_getUIText(context, 'modifier_required')} • ${_getUIText(context, 'modifier_choose_between')} $min-$max';
    }

    if (constraints.isRequired && min > 0) {
      return '${_getUIText(context, 'modifier_required')} • ${_getUIText(context, 'modifier_choose_at_least')} $min';
    }

    if (!constraints.isRequired && max > 0) {
      return '${_getUIText(context, 'modifier_optional')} • ${_getUIText(context, 'modifier_choose_up_to')} $max';
    }

    if (!constraints.isRequired && min > 0 && max > min) {
      return '${_getUIText(context, 'modifier_optional')} • ${_getUIText(context, 'modifier_choose_between')} $min-$max';
    }

    if (!constraints.isRequired) {
      return _getUIText(context, 'modifier_optional');
    }

    return '';
  }

  String _buildDisplayText(String name, String description) {
    if (description.isEmpty) return name;
    return '$name ${description.isNotEmpty ? '($description)' : ''}';
  }

  String _getGroupTypeLabel(BuildContext context) {
    final type = _getGroupType().toLowerCase();
    final key = 'modifier_type_${type.replaceAll('-', '')}';
    return _getUIText(context, key);
  }

  @override
  Widget build(BuildContext context) {
    final modifiers = _getModifiers();
    final constraints = _getConstraints();
    final constraintText = _buildConstraintText(context, constraints);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGroupHeader(context),
        if (constraintText.isNotEmpty)
          _buildConstraintTextWidget(constraintText),
        ..._buildModifiersList(modifiers),
      ],
    );
  }

  Widget _buildGroupHeader(BuildContext context) {
    final typeLabel = _getGroupTypeLabel(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: _headerBottomSpacing),
      child: Text(
        typeLabel,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: _headerFontSize,
          fontWeight: _headerFontWeight,
          color: _headerColor,
        ),
      ),
    );
  }

  Widget _buildConstraintTextWidget(String constraintText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _constraintBottomSpacing),
      child: Text(
        constraintText,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: _constraintFontSize,
          fontWeight: _constraintFontWeight,
          color: _constraintColor,
        ),
      ),
    );
  }

  List<Widget> _buildModifiersList(List<dynamic> modifiers) {
    final widgets = <Widget>[];

    for (int i = 0; i < modifiers.length; i++) {
      final modifier = modifiers[i];
      if (modifier is Map<String, dynamic>) {
        widgets.add(_buildModifierItem(modifier));

        if (i < modifiers.length - 1) {
          widgets.add(const SizedBox(height: _modifierItemSpacing));
        }
      }
    }

    return widgets;
  }

  Widget _buildModifierItem(Map<String, dynamic> modifier) {
    final name = modifier['name'] as String? ?? '';
    final description = modifier['description'] as String? ?? '';
    final price = (modifier['price'] as num?)?.toDouble() ?? 0.0;
    final displayText = _buildDisplayText(name, description);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            displayText,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: _modifierFontSize,
              fontWeight: _modifierFontWeight,
              color: _modifierColor,
            ),
          ),
        ),
        if (price > 0) ...[
          const SizedBox(width: 8.0),
          _buildModifierPriceBadge(price),
        ],
      ],
    );
  }

  Widget _buildModifierPriceBadge(double price) {
    final formattedPrice = convertAndFormatPrice(
      price,
      originalCurrencyCode,
      exchangeRate,
      chosenCurrency,
    );

    if (formattedPrice == null) return const SizedBox.shrink();

    final priceText =
        _isVariationGroup() ? formattedPrice : '+ $formattedPrice';

    return Text(
      priceText,
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: _modifierFontSize,
        fontWeight: _modifierFontWeight,
        color: AppColors.accent,
      ),
    );
  }
}

class _SelectionConstraints {
  const _SelectionConstraints({
    required this.isRequired,
    required this.minSelections,
    required this.maxSelections,
  });

  final bool isRequired;
  final int minSelections;
  final int maxSelections;
}

/// ============================================================================
/// INFORMATION SOURCE ACCORDION SECTION
/// ============================================================================

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
  bool _isExpanded = false;

  static const Duration _expandDuration = Duration(milliseconds: 100);
  static const Curve _expandCurve = Curves.linear;
  static const double _expandedContentTopSpacing = 8.0;
  static const double _disclaimerToJourneymateSpacing = 8.0;
  static const double _headerFontSize = 14.0;
  static const FontWeight _headerFontWeight = FontWeight.w400;
  static const double _contentFontSize = 14.0;
  static const FontWeight _contentFontWeight = FontWeight.w300;
  static const Color _headerTextColor = Colors.black;
  static const Color _iconColor = Colors.black;
  static const Color _contentTextColor = Colors.black87;
  static const double _iconSize = 24.0;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

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

  Widget _buildExpandIcon() {
    return Icon(
      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
      color: _iconColor,
      size: _iconSize,
    );
  }

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
