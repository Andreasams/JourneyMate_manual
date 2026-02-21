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

import 'dart:convert';
import 'package:provider/provider.dart';

/// A button that displays the currently selected currency and opens an
/// overlay selector on tap.
///
/// Features: - Displays currency name and symbol - Opens overlay with
/// available currency options for current language - Updates
/// FFAppState.userCurrencyCode on selection - Fetches exchange rates via
/// updateCurrencyWithExchangeRate action - Automatically updates currency
/// when language changes - Overlay dismisses on selection or outside tap -
/// Smart positioning with 4px gap between button and overlay
class CurrencySelectorButton extends StatefulWidget {
  const CurrencySelectorButton({
    super.key,
    this.width,
    this.height,
    required this.translationsCache,
  });

  final double? width;
  final double? height;
  final dynamic translationsCache;

  @override
  State<CurrencySelectorButton> createState() => _CurrencySelectorButtonState();
}

class _CurrencySelectorButtonState extends State<CurrencySelectorButton> {
  /// =======================================================================
  /// STATE & KEYS
  /// =======================================================================

  /// Global key to get button position for overlay placement
  final GlobalKey _buttonKey = GlobalKey();

  /// Tracks overlay entry for manual dismissal
  OverlayEntry? _overlayEntry;

  /// Tracks if overlay is currently visible
  bool _isOverlayVisible = false;

  /// Tracks the last known language to detect changes
  String? _lastKnownLanguage;

  /// =======================================================================
  /// STYLING CONSTANTS
  /// =======================================================================

  // Button styling
  static const Color _buttonBackgroundColor = Color(0xFFF2F3F5);
  static const Color _buttonTextColor = Color(0xFF14181B);
  static const Color _buttonIconColor = Color(0xFF57636C);
  static const double _buttonBorderRadius = 8.0;
  static const double _buttonHorizontalPadding = 12.0;
  static const double _buttonVerticalPadding = 8.0;
  static const double _buttonFontSize = 14.0;
  static const FontWeight _buttonFontWeight = FontWeight.w300;
  static const double _buttonIconSize = 24.0;

  // Overlay styling
  static const Color _overlayBackgroundColor = Color(0xFFF2F3F5);
  static const Color _overlayTextColor = Color(0xFF14181B);
  static const double _overlayBorderRadius = 8.0;
  static const double _overlayPaddingLeftRight = 12.0;
  static const double _overlayPaddingTop = 4.0;
  static const double _overlayItemFontSize = 14.0;
  static const FontWeight _overlayItemFontWeight = FontWeight.w300;
  static const double _overlayItemPaddingLeft = 4.0;
  static const double _overlayItemVerticalPadding = 12.0;
  static const double _overlayGapFromButton = 4.0;

  // Overlay shadow
  static const Color _overlayShadowColor = Color(0x33000000);
  static const double _overlayShadowBlurRadius = 4.0;
  static const double _overlayShadowSpreadRadius = 1.0;
  static const Offset _overlayShadowOffset = Offset(0, 2);

  /// Default currency code
  static const String _defaultCurrencyCode = 'DKK';

  /// =======================================================================
  /// LIFECYCLE METHODS
  /// =======================================================================

  @override
  void dispose() {
    _dismissOverlay();
    super.dispose();
  }

  /// =======================================================================
  /// TRANSLATION HELPERS
  /// =======================================================================

  /// Gets current language code from FlutterFlow's localization system
  String _getCurrentLanguageCode(BuildContext context) {
    return FFLocalizations.of(context).languageCode;
  }

  /// Gets localized UI text using central translation function
  String _getUIText(BuildContext context, String key) {
    final languageCode = _getCurrentLanguageCode(context);
    return getTranslations(languageCode, key, FFAppState().translationsCache);
  }

  /// Gets localized currency name
  String _getCurrencyName(BuildContext context, String currencyCode) {
    final languageCode = _getCurrentLanguageCode(context);
    final key = 'currency_${currencyCode.toLowerCase()}_cap';
    return getTranslations(languageCode, key, FFAppState().translationsCache);
  }

  /// =======================================================================
  /// DATA RETRIEVAL
  /// =======================================================================

  /// Gets the effective currency code to use for display
  String _getEffectiveCurrencyCode() {
    final userCurrency = FFAppState().userCurrencyCode;

    if (userCurrency.trim().isEmpty) {
      return _defaultCurrencyCode;
    }

    return userCurrency;
  }

  /// Gets the currency display label: "Currency Name (Symbol)"
  String _getCurrencyDisplayLabel(BuildContext context, String currencyCode) {
    final currencyName = _getCurrencyName(context, currencyCode);
    final currencySymbol = _getCurrencySymbol(currencyCode);

    // If translation not found, use code as fallback
    if (currencyName.isEmpty || currencyName.startsWith('⚠️')) {
      return '$currencyCode ($currencySymbol)';
    }

    return '$currencyName ($currencySymbol)';
  }

  /// Gets the currency symbol from formatting rules
  String _getCurrencySymbol(String currencyCode) {
    final formattingRules = getCurrencyFormattingRules(currencyCode);

    if (formattingRules == null) {
      return currencyCode;
    }

    try {
      final Map<String, dynamic> rules =
          Map<String, dynamic>.from(jsonDecode(formattingRules));
      return rules['symbol'] as String? ?? currencyCode;
    } catch (e) {
      return currencyCode;
    }
  }

  /// Gets available currencies for the current language
  List<String> _getAvailableCurrencies(BuildContext context) {
    final languageCode = _getCurrentLanguageCode(context);
    return _getCurrenciesForLanguage(languageCode);
  }

  /// Returns available currency codes for a specific language
  List<String> _getCurrenciesForLanguage(String languageCode) {
    const currencyOptions = {
      'en': ['USD', 'GBP', 'DKK'],
      'de': ['EUR', 'DKK'],
      'sv': ['SEK', 'DKK'],
      'no': ['NOK', 'DKK'],
      'it': ['EUR', 'DKK'],
      'fr': ['EUR', 'DKK'],
      'da': ['DKK'],
      'es': ['EUR', 'DKK'],
      'fi': ['EUR', 'DKK'],
      'nl': ['EUR', 'DKK'],
      'pl': ['PLN', 'EUR', 'DKK'],
      'uk': ['UAH', 'EUR', 'DKK'],
      'ja': ['JPY', 'USD', 'DKK'],
      'ko': ['KRW', 'USD', 'DKK'],
      'zh': ['CNY', 'USD', 'DKK'],
    };

    return currencyOptions[languageCode] ?? ['DKK'];
  }

  /// =======================================================================
  /// OVERLAY MANAGEMENT
  /// =======================================================================

  /// Shows the currency selection overlay
  void _showOverlay(BuildContext context) {
    if (_isOverlayVisible) return;

    final renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final buttonSize = renderBox.size;
    final buttonPosition = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => _buildOverlay(
        context: context,
        buttonPosition: buttonPosition,
        buttonWidth: buttonSize.width,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOverlayVisible = true;
    });
  }

  /// Dismisses the overlay
  void _dismissOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isOverlayVisible = false;
      });
    }
  }

  /// Handles currency selection from overlay
  ///
  /// Calls the updateCurrencyWithExchangeRate action which:
  /// 1. Updates FFAppState.userCurrencyCode
  /// 2. Triggers exchange rate API call (configured in FlutterFlow)
  /// 3. Updates FFAppState.exchangeRate
  Future<void> _handleCurrencySelection(String newCurrencyCode) async {
    final currentCurrency = _getEffectiveCurrencyCode();

    // Dismiss overlay immediately for responsive feel
    _dismissOverlay();

    // Skip if selecting same currency
    if (newCurrencyCode == currentCurrency) return;

    // Track user engagement
    markUserEngaged();

    // Track currency change with language context
    await trackAnalyticsEvent(
      'currency_changed',
      {
        'from_currency': currentCurrency,
        'to_currency': newCurrencyCode,
        'language': _getCurrentLanguageCode(context),
      },
    ).catchError((error) {
      debugPrint('⚠️ Failed to track currency change: $error');
    });

    try {
      // Call the custom action to update currency and fetch exchange rate
      // The API call is configured in FlutterFlow's Action Flow Editor
      final success = await updateCurrencyWithExchangeRate(newCurrencyCode);

      if (!success) {
        debugPrint('⚠️ Failed to update currency to: $newCurrencyCode');
      }

      // Trigger widget rebuild to show new currency
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('❌ Error in currency selection: $e');
      // Widget will continue showing previous currency on error
    }
  }

  /// Tracks currency change event to analytics backend.
  ///
  /// Captures currency change with language context to understand
  /// currency preferences by language/region.
  void _trackCurrencyChange(String fromCurrency, String toCurrency) {
    final currentLanguage = FFLocalizations.of(context).languageCode;

    trackAnalyticsEvent(
      'currency_changed',
      {
        'from_currency': fromCurrency,
        'to_currency': toCurrency,
        'current_language': currentLanguage,
        'currency_display_name': _getCurrencyDisplayName(toCurrency),
      },
    ).catchError((error) {
      debugPrint('⚠️ Failed to track currency change: $error');
    });
  }

  /// Gets display name for currency
  String _getCurrencyDisplayName(String currencyCode) {
    final currencies = {
      'DKK': 'Danish Krone',
      'EUR': 'Euro',
      'GBP': 'British Pound',
      'USD': 'US Dollar',
      'SEK': 'Swedish Krona',
      'NOK': 'Norwegian Krone',
    };
    return currencies[currencyCode] ?? currencyCode;
  }

  /// Updates currency when language changes
  ///
  /// Uses smart fallback logic:
  /// 1. If current currency is available in new language → keep it
  /// 2. Otherwise → use default currency for that language
  ///
  /// Also fetches the exchange rate for the new currency via the
  /// updateCurrencyWithExchangeRate action
  Future<void> _updateCurrencyForLanguageChange(String newLanguageCode) async {
    try {
      final currentCurrency = _getEffectiveCurrencyCode();
      final availableCurrencies = _getCurrenciesForLanguage(newLanguageCode);

      // Determine the appropriate currency
      final newCurrency = _determineTargetCurrency(
        currentCurrency: currentCurrency,
        availableCodes: availableCurrencies,
        languageCode: newLanguageCode,
      );

      // Only update if currency needs to change
      if (newCurrency != currentCurrency) {
        // Use the action to update currency and fetch exchange rate
        final success = await updateCurrencyWithExchangeRate(newCurrency);

        if (!success) {
          debugPrint(
              '⚠️ Failed to update currency for language: $newLanguageCode');
        }

        // Trigger widget rebuild to show new currency
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint('❌ Error updating currency for language change: $e');
      // Fallback to DKK on error
      await updateCurrencyWithExchangeRate('DKK');
    }
  }

  /// Determines the appropriate currency for the target language
  ///
  /// Logic:
  /// 1. If current currency is available in new language → keep it
  /// 2. Otherwise → use default currency for that language
  String _determineTargetCurrency({
    required String currentCurrency,
    required List<String> availableCodes,
    required String languageCode,
  }) {
    // Check if current currency is available
    if (availableCodes.contains(currentCurrency)) {
      return currentCurrency;
    }

    // Fall back to default currency for this language
    return _getDefaultCurrencyForLanguage(languageCode);
  }

  /// Returns the default currency code for a given language
  String _getDefaultCurrencyForLanguage(String languageCode) {
    const defaults = {
      'en': 'USD',
      'de': 'EUR',
      'sv': 'SEK',
      'no': 'NOK',
      'it': 'EUR',
      'fr': 'EUR',
      'da': 'DKK',
      'es': 'EUR',
      'fi': 'EUR',
      'nl': 'EUR',
      'pl': 'PLN',
      'uk': 'UAH',
      'ja': 'JPY',
      'ko': 'KRW',
      'zh': 'CNY',
    };

    return defaults[languageCode] ?? 'DKK';
  }

  /// =======================================================================
  /// UI BUILDERS - BUTTON
  /// =======================================================================

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final currentLanguageCode = _getCurrentLanguageCode(context);
    final currentCurrency = _getEffectiveCurrencyCode();

    // Check if language has changed since last build
    if (_lastKnownLanguage != null &&
        _lastKnownLanguage != currentLanguageCode) {
      // Update currency for new language asynchronously
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateCurrencyForLanguageChange(currentLanguageCode);
      });
    }

    // Update last known language
    _lastKnownLanguage = currentLanguageCode;

    return GestureDetector(
      onTap: () => _showOverlay(context),
      child: Container(
        key: _buttonKey,
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: _buttonBackgroundColor,
          borderRadius: BorderRadius.circular(_buttonBorderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _buttonHorizontalPadding,
            vertical: _buttonVerticalPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getCurrencyDisplayLabel(context, currentCurrency),
                style: const TextStyle(
                  color: _buttonTextColor,
                  fontWeight: _buttonFontWeight,
                  fontSize: _buttonFontSize,
                ),
              ),
              Icon(
                _isOverlayVisible
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: _buttonIconColor,
                size: _buttonIconSize,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// =======================================================================
  /// UI BUILDERS - OVERLAY
  /// =======================================================================

  /// Builds the complete overlay positioned below the button
  Widget _buildOverlay({
    required BuildContext context,
    required Offset buttonPosition,
    required double buttonWidth,
  }) {
    return Stack(
      children: [
        // Invisible barrier to detect outside taps
        Positioned.fill(
          child: GestureDetector(
            onTap: _dismissOverlay,
            child: Container(color: Colors.transparent),
          ),
        ),
        // Currency selection overlay
        Positioned(
          left: buttonPosition.dx,
          top: buttonPosition.dy + (widget.height ?? 0) + _overlayGapFromButton,
          child: _buildOverlayContent(context, buttonWidth),
        ),
      ],
    );
  }

  /// Builds the overlay content container
  Widget _buildOverlayContent(BuildContext context, double width) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: _overlayBackgroundColor,
          borderRadius: BorderRadius.circular(_overlayBorderRadius),
          boxShadow: const [
            BoxShadow(
              color: _overlayShadowColor,
              blurRadius: _overlayShadowBlurRadius,
              spreadRadius: _overlayShadowSpreadRadius,
              offset: _overlayShadowOffset,
            ),
          ],
        ),
        padding: const EdgeInsets.only(
          left: _overlayPaddingLeftRight,
          right: _overlayPaddingLeftRight,
          top: _overlayPaddingTop,
          bottom: _overlayPaddingTop,
        ),
        child: _buildCurrencyList(context),
      ),
    );
  }

  /// Builds the list of currency options
  Widget _buildCurrencyList(BuildContext context) {
    final availableCurrencies = _getAvailableCurrencies(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: availableCurrencies.map((currencyCode) {
        return _buildCurrencyItem(context, currencyCode);
      }).toList(),
    );
  }

  /// Builds a single currency item
  Widget _buildCurrencyItem(BuildContext context, String currencyCode) {
    return InkWell(
      onTap: () => _handleCurrencySelection(currencyCode),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(
          left: _overlayItemPaddingLeft,
          top: _overlayItemVerticalPadding,
          bottom: _overlayItemVerticalPadding,
        ),
        child: Text(
          _getCurrencyDisplayLabel(context, currencyCode),
          style: TextStyle(
            color: _overlayTextColor,
            fontSize: _overlayItemFontSize,
            fontWeight: _overlayItemFontWeight,
          ),
        ),
      ),
    );
  }
}
