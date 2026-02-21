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

import 'dart:convert';
import 'package:http/http.dart' as http;

/// A bottom sheet that displays detailed information about a single menu
/// item.
///
/// Features: - Item image with fallback states - Title, description, and base
/// price display - "From" pricing prefix for items with variations -
/// Expandable variation options with individual prices - Expandable add-on
/// modifier groups - Dietary preferences and allergen information - Currency
/// conversion support (self-contained within sheet) - Information source
/// disclaimer section - Language switching with three-dot menu - Currency
/// switching with three-dot menu (fetches exchange rates inline) - Localized
/// UI text via translation system
///
/// This widget is designed to be shown as a modal bottom sheet when users tap
/// on menu items in the MenuDishesListView.
class ItemDetailSheet extends StatefulWidget {
  const ItemDetailSheet({
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
    this.formattedPrice,
    this.hasVariations,
    this.formattedVariationPrice,
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
  final String? formattedPrice;
  final bool? hasVariations;
  final String? formattedVariationPrice;

  @override
  State<ItemDetailSheet> createState() => _ItemDetailSheetState();
}

class _ItemDetailSheetState extends State<ItemDetailSheet> {
  /// =========================================================================
  /// CONSTANTS - DIMENSIONS & LAYOUT
  /// =========================================================================

  static const double _defaultSheetHeightFactor = 0.90;
  static const double _sheetBorderRadius = 20.0;

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
  static const double _titleToPriceSpacing = 2.0;
  static const double _priceToDescriptionSpacing = 4.0;
  static const double _descriptionToModifiersSpacing = 16.0;
  static const double _modifiersToInfoSpacing = 24.0;
  static const double _dividerToInfoSpacing = 20.0;
  static const double _infoHeaderSpacing = 4.0;
  static const double _dietaryToAllergenSpacing = 12.0;
  static const double _allergenToSourceSpacing = 12.0;
  static const double _bottomPadding = 30.0;

  /// =========================================================================
  /// CONSTANTS - ACTION MENU
  /// =========================================================================

  static const double _menuButtonSize = 40.0;
  static const double _menuButtonPosition = 12.0;
  static const double _menuButtonBorderRadius = 20.0;
  static const double _menuIconSize = 28.0;
  static const Color _menuButtonBackgroundColor = Color(0xFFF2F3F5);
  static const Color _menuIconColor = Color(0xFF14181B);

  /// =========================================================================
  /// CONSTANTS - MENU ITEM STYLING
  /// =========================================================================

  static const Color _menuItemBackgroundColor = Color(0xFFF2F3F5);
  static const Color _menuItemTextColor = Colors.black;
  static const FontWeight _menuItemFontWeight = FontWeight.w400;
  static const double _menuItemFontSize = 15.0;

  /// =========================================================================
  /// CONSTANTS - TYPOGRAPHY
  /// =========================================================================

  static const double _itemNameFontSize = 22.0;
  static const FontWeight _itemNameFontWeight = FontWeight.w600;
  static const double _priceFontSize = 16.0;
  static const FontWeight _priceFontWeight = FontWeight.w500;
  static const double _descriptionFontSize = 16.0;
  static const FontWeight _descriptionFontWeight = FontWeight.w300;
  static const double _sectionHeaderFontSize = 15.0;
  static const FontWeight _sectionHeaderFontWeight = FontWeight.w500;
  static const double _bodyTextFontSize = 14.0;
  static const double _modifierContentFontSize = 14.0;
  static const double _infoTxtFontSize = 14.0;
  static const double _infoHeaderFontSize = _sectionHeaderFontSize;
  static const FontWeight _infoHeaderFontWeight = _sectionHeaderFontWeight;
  static const double _infoLabelFontSize = _infoTxtFontSize;
  static const FontWeight _infoLabelFontWeight = FontWeight.w400;
  static const double _infoTextFontSize = _infoTxtFontSize;
  static const FontWeight _infoTextFontWeight = FontWeight.w300;

  /// =========================================================================
  /// CONSTANTS - COLORS
  /// =========================================================================

  static const Color _swipeBarColor = Color(0xFF14181B);
  static const Color _closeButtonBackgroundColor = Color(0xFFF2F3F5);
  static const Color _closeIconColor = Color(0xFF14181B);
  static const Color _itemNameColor = Colors.black;
  static const Color _priceColor = Color(0xFFE9874B);
  static const Color _descriptionColor = Color(0xFF2D3236);
  static const Color _dividerColor = Color(0xFFE0E0E0);
  static const Color _sectionHeaderColor = Colors.black;
  static const Color _infoHeaderColor = Colors.black;
  static const Color _infoLabelColor = Colors.black;
  static const Color _infoTextColor = Colors.black87;
  static final Color _imageErrorBackgroundColor = Colors.grey[200]!;
  static const Color _imageErrorIconColor = Colors.grey;
  static const Color _menuDividerColor = Color(0xFF9E9E9E);

  /// =========================================================================
  /// CONSTANTS - PRICE BADGE STYLING
  /// =========================================================================

  static const double _priceContainerHorizontalPadding = 8.0;
  static const double _priceContainerVerticalPadding = 4.0;
  static const double _priceContainerBorderRadius = 6.0;

  /// =========================================================================
  /// CONSTANTS - STYLING
  /// =========================================================================

  static const double _dividerThickness = 1.0;
  static const double _imageErrorIconSize = 50.0;

  /// =========================================================================
  /// CONSTANTS - TRANSLATION KEYS
  /// =========================================================================

  static const String _infoHeaderAdditionalKey = 'info_header_additional';
  static const String _infoHeaderDietaryKey = 'info_header_dietary';
  static const String _infoHeaderAllergensKey = 'info_header_allergens';
  static const String _infoHeaderSourceKey = 'info_header_source';
  static const String _infoDisclaimerBusinessKey = 'info_disclaimer_business';
  static const String _infoDisclaimerJourneymateKey =
      'info_disclaimer_journeymate';
  static const String _pricePerPersonKey = 'price_per_person';

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
  void didUpdateWidget(covariant ItemDetailSheet oldWidget) {
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
  bool _hasItemChanged(ItemDetailSheet oldWidget) {
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

  /// Gets localized UI text using central translation function
  String _getUIText(String key) {
    return getTranslations(
      widget.currentLanguage,
      key,
      widget.translationsCache,
    );
  }

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
    return _getUIText(key);
  }

  /// Gets human-readable language name from language code
  /// Always uses translationsCache (app language) for consistency
  String _getLanguageName(String langCode) {
    final translationKey = 'lang_name_$langCode';
    return getTranslations(
      widget.currentLanguage,
      translationKey,
      widget.translationsCache,
    );
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
  Map<String, dynamic> get _currentItemData {
    return _languageDataCache[_currentlyDisplayedLanguage] ?? widget.itemData;
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
    markUserEngaged();

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
        borderRadius: BorderRadius.circular(12),
      ),
      color: _menuButtonBackgroundColor,
      elevation: 8,
      menuPadding: EdgeInsets.symmetric(vertical: 2),
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
      final template = _getUIText('menu_view_dish_in_param');
      displayText = template.replaceAll('{language}', option.displayName);
    } else {
      final template = _getUIText('menu_view_price_in_param');
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
        color: _menuItemTextColor,
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
        if (mounted) {
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
      if (mounted) {
        setState(() {
          _isLoadingLanguage = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load language: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  /// Handles currency switching with inline exchange rate fetching
  ///
  /// This is self-contained within the sheet - does not update FFAppState.
  /// Fetches exchange rate from API and stores locally in _overrideCurrency
  /// and _overrideExchangeRate.
  Future<void> _handleCurrencySwitch(String newCurrencyCode) async {
    markUserEngaged();

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

        if (rate != null && mounted) {
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
      if (mounted) {
        setState(() {
          _isLoadingLanguage = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not update currency'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red[700],
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
    markUserEngaged();
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
              _buildScrollableContent(),
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
        color: Colors.black.withOpacity(0.3),
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
    return const BoxDecoration(
      color: Colors.white,
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(_sheetBorderRadius)),
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
          color: _menuButtonBackgroundColor,
          borderRadius: BorderRadius.circular(_menuButtonBorderRadius),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(
            Icons.more_horiz,
            color: _menuIconColor,
            size: _menuIconSize,
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
              _buildPriceSection(),
              _buildItemDescription(),
              if (hasModifiers) ...[
                const SizedBox(height: _descriptionToModifiersSpacing),
                _buildModifierGroupsSection(),
                const SizedBox(height: _modifiersToInfoSpacing),
                _buildDivider(),
              ] else ...[
                const SizedBox(height: _modifiersToInfoSpacing),
                _buildDivider(),
              ],
              const SizedBox(height: _dividerToInfoSpacing),
              _buildAdditionalInformation(),
              const SizedBox(height: _bottomPadding),
            ],
          ),
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
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: _itemNameFontSize,
        fontWeight: _itemNameFontWeight,
        color: _itemNameColor,
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
      final perPersonSuffix = _getUITextFromApi(_pricePerPersonKey);
      displayPrice = '$displayPrice — $perPersonSuffix';
    }

    return Padding(
      padding: const EdgeInsets.only(top: _titleToPriceSpacing),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: _priceContainerHorizontalPadding,
          vertical: _priceContainerVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: _priceColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(_priceContainerBorderRadius),
        ),
        child: Text(
          displayPrice,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: _priceFontSize,
            fontWeight: _priceFontWeight,
            color: _priceColor,
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
      final fromText = _getUIText('price_from');
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
      padding: const EdgeInsets.only(top: _priceToDescriptionSpacing),
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
        _ModifierGroupsDisplay(
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
        widgets.add(const SizedBox(height: _dietaryToAllergenSpacing));
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
        const SizedBox(height: _infoHeaderSpacing),
        _buildDietaryInformation(),
        const SizedBox(height: _dietaryToAllergenSpacing),
        _buildAllergenInformation(),
        const SizedBox(height: _allergenToSourceSpacing),
        _buildInformationSource(),
      ],
    );
  }

  /// Builds additional information header
  Widget _buildInfoHeader() {
    return Text(
      _getUITextFromApi(_infoHeaderAdditionalKey),
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
          _getUITextFromApi(_infoHeaderDietaryKey),
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
          _getUITextFromApi(_infoHeaderAllergensKey),
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
    final disclaimerText = _getUITextFromApi(_infoDisclaimerBusinessKey)
        .replaceAll('[businessName]', widget.businessName);

    final journeymateText = _getUITextFromApi(_infoDisclaimerJourneymateKey);

    return _InformationSourceSection(
      headerText: _getUITextFromApi(_infoHeaderSourceKey),
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
/// MODIFIER GROUPS DISPLAY WIDGET
/// ============================================================================

/// Displays a single modifier group with its options and selection constraints
class _ModifierGroupsDisplay extends StatelessWidget {
  const _ModifierGroupsDisplay({
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

  static const double _unifiedContentFontSize = 14.0;
  static const double _headerFontSize = 16.0;
  static const FontWeight _headerFontWeight = FontWeight.w500;
  static const Color _headerColor = Colors.black;
  static const double _constraintFontSize = _unifiedContentFontSize;
  static const FontWeight _constraintFontWeight = FontWeight.w400;
  static const Color _constraintColor = Colors.black54;
  static const double _modifierFontSize = _unifiedContentFontSize;
  static const FontWeight _modifierFontWeight = FontWeight.w400;
  static const Color _modifierColor = Colors.black87;
  static const Color _priceColor = Color(0xFFE9874B);
  static const double _headerBottomSpacing = 2.0;
  static const double _constraintBottomSpacing = 8.0;
  static const double _modifierItemSpacing = 2.0;
  static const double _modifierLeftPadding = 0.0;

  static const String _requiredKey = 'modifier_required';
  static const String _optionalKey = 'modifier_optional';
  static const String _chooseUpToKey = 'modifier_choose_up_to';
  static const String _chooseExactlyKey = 'modifier_choose_exactly';
  static const String _chooseAtLeastKey = 'modifier_choose_at_least';
  static const String _chooseBetweenKey = 'modifier_choose_between';

  /// Gets UI text: API translations first, then translationsCache
  String _getUIText(String key) {
    // Try API translations first (for switched language)
    if (uiTranslations != null) {
      final value = uiTranslations![key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    // Use translationsCache (for initial app language)
    return getTranslations(
      currentLanguage,
      key,
      translationsCache,
    );
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

  String _buildConstraintText(_SelectionConstraints constraints) {
    final min = constraints.minSelections;
    final max = constraints.maxSelections;

    if (constraints.isRequired && min == max && min > 0) {
      return '${_getUIText(_requiredKey)} • ${_getUIText(_chooseExactlyKey)} $min';
    }

    if (constraints.isRequired && min > 0 && max > min) {
      return '${_getUIText(_requiredKey)} • ${_getUIText(_chooseBetweenKey)} $min-$max';
    }

    if (constraints.isRequired && min > 0) {
      return '${_getUIText(_requiredKey)} • ${_getUIText(_chooseAtLeastKey)} $min';
    }

    if (!constraints.isRequired && max > 0) {
      return '${_getUIText(_optionalKey)} • ${_getUIText(_chooseUpToKey)} $max';
    }

    if (!constraints.isRequired && min > 0 && max > min) {
      return '${_getUIText(_optionalKey)} • ${_getUIText(_chooseBetweenKey)} $min-$max';
    }

    if (!constraints.isRequired) {
      return _getUIText(_optionalKey);
    }

    return '';
  }

  String _buildDisplayText(String name, String description) {
    if (description.isEmpty) return name;
    return '$name ${description.isNotEmpty ? '($description)' : ''}';
  }

  String _getGroupTypeLabel() {
    final type = _getGroupType().toLowerCase();
    final key = 'modifier_type_${type.replaceAll('-', '')}';
    return _getUIText(key);
  }

  @override
  Widget build(BuildContext context) {
    final modifiers = _getModifiers();
    final constraints = _getConstraints();
    final constraintText = _buildConstraintText(constraints);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGroupHeader(),
        if (constraintText.isNotEmpty)
          _buildConstraintTextWidget(constraintText),
        ..._buildModifiersList(modifiers),
      ],
    );
  }

  Widget _buildGroupHeader() {
    final typeLabel = _getGroupTypeLabel();

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

    return Padding(
      padding: const EdgeInsets.only(left: _modifierLeftPadding),
      child: Row(
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
      ),
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
        color: _priceColor,
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
    markUserEngaged();
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
