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

import 'package:shared_preferences/shared_preferences.dart';

import 'package:provider/provider.dart';

/// A button that displays the currently selected language and opens an
/// overlay selector on tap.
///
/// Features: - Displays language flag emoji and native name - Opens overlay
/// with available language options below button - Integrates with
/// FlutterFlow's native localization system - Automatic state updates:
/// language → currency → translations - Overlay dismisses on selection or
/// outside tap - Smart positioning with 4px gap between button and overlay
class LanguageSelectorButton extends StatefulWidget {
  const LanguageSelectorButton({
    super.key,
    this.width,
    this.height,
    required this.translationsCache,
  });
  final double? width;
  final double? height;
  final dynamic translationsCache;
  @override
  State<LanguageSelectorButton> createState() => _LanguageSelectorButtonState();
}

class _LanguageSelectorButtonState extends State<LanguageSelectorButton> {
  /// =======================================================================
  /// STATE & KEYS
  /// =======================================================================

  /// Global key to get button position for overlay placement
  final GlobalKey _buttonKey = GlobalKey();

  /// Tracks overlay entry for manual dismissal
  OverlayEntry? _overlayEntry;

  /// Tracks if overlay is currently visible
  bool _isOverlayVisible = false;

  /// Prevent double taps while changing language
  bool _isBusy = false;

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

  /// =======================================================================
  /// LANGUAGE METADATA
  /// =======================================================================

  /// Language metadata (flags and active status)
  static const Map<String, Map<String, dynamic>> _languageMetadata = {
    'da': {'flag': '🇩🇰', 'is_active': true, 'display_order': 1},
    'en': {'flag': '🇬🇧', 'is_active': true, 'display_order': 2},
    'de': {'flag': '🇩🇪', 'is_active': true, 'display_order': 3},
    'sv': {'flag': '🇸🇪', 'is_active': true, 'display_order': 4},
    'no': {'flag': '🇳🇴', 'is_active': true, 'display_order': 5},
    'it': {'flag': '🇮🇹', 'is_active': true, 'display_order': 6},
    'fr': {'flag': '🇫🇷', 'is_active': true, 'display_order': 7},
    'es': {'flag': '🇪🇸', 'is_active': false, 'display_order': 999},
    'fi': {'flag': '🇫🇮', 'is_active': false, 'display_order': 999},
    'ja': {'flag': '🇯🇵', 'is_active': false, 'display_order': 999},
    'ko': {'flag': '🇰🇷', 'is_active': false, 'display_order': 999},
    'nl': {'flag': '🇳🇱', 'is_active': false, 'display_order': 999},
    'pl': {'flag': '🇵🇱', 'is_active': false, 'display_order': 999},
    'uk': {'flag': '🇺🇦', 'is_active': false, 'display_order': 999},
    'zh': {'flag': '🇨🇳', 'is_active': false, 'display_order': 999},
  };

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

  /// Gets localized language name
  String _getLanguageName(BuildContext context, String languageCode) {
    final currentLanguageCode = _getCurrentLanguageCode(context);
    return getTranslations(
      currentLanguageCode,
      'lang_name_$languageCode',
      FFAppState().translationsCache,
    );
  }

  /// =======================================================================
  /// DATA RETRIEVAL
  /// =======================================================================

  /// Returns "Flag  NativeName"
  String _getLanguageDisplayLabel(String languageCode) {
    final flag = _getLanguageFlag(languageCode);
    final nativeName = _getNativeLanguageName(languageCode);
    return '$flag  $nativeName';
  }

  String _getNativeLanguageName(String languageCode) {
    const nativeNames = {
      'da': 'Dansk',
      'de': 'Deutsch',
      'en': 'English',
      'es': 'Español',
      'fi': 'Suomi',
      'fr': 'Français',
      'it': 'Italiano',
      'ja': '日本語',
      'ko': '한국어',
      'nl': 'Nederlands',
      'no': 'Norsk',
      'pl': 'Polski',
      'sv': 'Svenska',
      'uk': 'Українська',
      'zh': '中文',
    };
    return nativeNames[languageCode] ?? languageCode.toUpperCase();
  }

  String _getLanguageFlag(String languageCode) {
    final metadata = _languageMetadata[languageCode];
    return metadata?['flag'] as String? ?? '🌐';
  }

  List<String> _getActiveLanguages() {
    final activeLanguages = _languageMetadata.entries
        .where((entry) => entry.value['is_active'] == true)
        .toList();

    activeLanguages.sort((a, b) {
      final orderA = a.value['display_order'] as int;
      final orderB = b.value['display_order'] as int;
      return orderA.compareTo(orderB);
    });

    return activeLanguages.map((entry) => entry.key).toList();
  }

  /// =======================================================================
  /// OVERLAY MANAGEMENT
  /// =======================================================================

  void _showOverlay(BuildContext context) {
    if (_isOverlayVisible || _isBusy) return;

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

  void _dismissOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    if (mounted) {
      setState(() {
        _isOverlayVisible = false;
      });
    }
  }

  /// Handles language selection
  Future<void> _handleLanguageSelection(
    BuildContext context,
    String newLanguageCode,
  ) async {
    if (_isBusy) return;
    _isBusy = true;

    final currentLanguageCode = _getCurrentLanguageCode(context);

    _dismissOverlay();

    if (newLanguageCode == currentLanguageCode) {
      _isBusy = false;
      return;
    }

    // Track user engagement and language change (fire-and-forget)
    markUserEngaged();
    _trackLanguageChange(currentLanguageCode, newLanguageCode);

    try {
      // Normalize once
      final lc = newLanguageCode.toLowerCase().trim();

      // Step 1: Persist language + apply immediately
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ff_language', lc);

      // If your build exposes this helper, it applies locale + triggers rebuild.
      // Safe to call when present.
      setAppLanguage(context, lc);

      // Step 2: Save preference via your own mechanism (optional mirror)
      await saveUserPreference('user_language_code', lc);

      // Step 3: Update currency for new language
      await updateCurrencyForLanguage(lc);

      // Step 4 & 5: Fetch translations + filters in parallel
      await Future.wait([
        getTranslationsWithUpdate(lc),
        getFiltersWithUpdate(lc),
      ]);

      // Step 6: Trigger rebuilds
      if (mounted) {
        FFAppState().update(() {});
        setState(() {});
      }
    } catch (e) {
      debugPrint('❌ Error changing language: $e');

      // Attempt rollback
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('ff_language', currentLanguageCode);
        setAppLanguage(context, currentLanguageCode);
      } catch (_) {}
    } finally {
      _isBusy = false;
    }
  }

  /// =======================================================================
  /// ANALYTICS TRACKING
  /// =======================================================================

  /// Tracks language change event to analytics backend.
  ///
  /// Captures language transitions to understand user preferences
  /// and regional usage patterns.
  void _trackLanguageChange(String fromLanguage, String toLanguage) {
    final fromLanguageName = _getNativeLanguageName(fromLanguage);
    final toLanguageName = _getNativeLanguageName(toLanguage);

    trackAnalyticsEvent(
      'language_changed',
      {
        'from_language': fromLanguage,
        'to_language': toLanguage,
        'from_language_name': fromLanguageName,
        'to_language_name': toLanguageName,
      },
    ).catchError((error) {
      debugPrint('⚠️ Failed to track language change: $error');
    });
  }

  /// =======================================================================
  /// UI BUILDERS - BUTTON
  /// =======================================================================

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    final currentLanguageCode = _getCurrentLanguageCode(context);

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
                _getLanguageDisplayLabel(currentLanguageCode),
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

  Widget _buildOverlay({
    required BuildContext context,
    required Offset buttonPosition,
    required double buttonWidth,
  }) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: _dismissOverlay,
            child: Container(color: Colors.transparent),
          ),
        ),
        Positioned(
          left: buttonPosition.dx,
          top: buttonPosition.dy + (widget.height ?? 0) + _overlayGapFromButton,
          child: _buildOverlayContent(context, buttonWidth),
        ),
      ],
    );
  }

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
        child: _buildLanguageList(context),
      ),
    );
  }

  Widget _buildLanguageList(BuildContext context) {
    final activeLanguages = _getActiveLanguages();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: activeLanguages.map((languageCode) {
        return _buildLanguageItem(context, languageCode);
      }).toList(),
    );
  }

  Widget _buildLanguageItem(BuildContext context, String languageCode) {
    return InkWell(
      onTap: () => _handleLanguageSelection(context, languageCode),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(
          left: _overlayItemPaddingLeft,
          top: _overlayItemVerticalPadding,
          bottom: _overlayItemVerticalPadding,
        ),
        child: Text(
          _getLanguageDisplayLabel(languageCode),
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
