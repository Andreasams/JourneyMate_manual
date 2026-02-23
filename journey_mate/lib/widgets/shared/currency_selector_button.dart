import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_providers.dart';
import '../../services/api_service.dart';
import '../../services/translation_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';

/// A button that displays the currently selected currency and opens an
/// overlay selector on tap.
///
/// **State Management:**
/// - Uses local state for overlay management (GlobalKey, OverlayEntry)
/// - Reads currency from `localizationProvider`
/// - Updates currency via `localizationProvider.notifier.setCurrency()`
///
/// **Features:**
/// - Displays currency name and symbol (e.g., "Danish Krone (kr.)")
/// - Opens overlay with language-specific currencies:
///   - Danish: DKK only
///   - English: USD, GBP, DKK
///   - German/French/Italian: EUR, DKK
///   - Swedish: SEK, DKK
///   - Norwegian: NOK, DKK
/// - Auto-switches currency when language changes (if current currency not available)
/// - Fetches exchange rates via BuildShip API
/// - Overlay dismisses on selection or outside tap
/// - Smart positioning with 4px gap between button and overlay
/// - Analytics tracking for currency changes
///
/// **FlutterFlow Migration Notes:**
/// - Migrated from FFAppState to localizationProvider (Riverpod 3.x)
/// - Removed markUserEngaged() calls (ActivityScope handles automatically)
/// - Added language-specific currency filtering (getCurrencyOptionsForLanguage logic)
/// - Uses BuildShip API for exchange rates
class CurrencySelectorButton extends ConsumerStatefulWidget {
  const CurrencySelectorButton({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  ConsumerState<CurrencySelectorButton> createState() =>
      _CurrencySelectorButtonState();
}

class _CurrencySelectorButtonState
    extends ConsumerState<CurrencySelectorButton> {
  // ─────────────────────────────────────────────────────────────────────────────
  // State & Keys
  // ─────────────────────────────────────────────────────────────────────────────

  /// Global key to get button position for overlay placement
  final GlobalKey _buttonKey = GlobalKey();

  /// Tracks overlay entry for manual dismissal
  OverlayEntry? _overlayEntry;

  /// Tracks if overlay is currently visible
  bool _isOverlayVisible = false;

  /// Tracks the last known language to detect changes
  String? _lastKnownLanguage;

  /// Default currency code
  static const String _defaultCurrencyCode = 'DKK';

  // ─────────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _dismissOverlay();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Currency Configuration
  // ─────────────────────────────────────────────────────────────────────────────

  /// Returns filtered currency codes based on language
  /// Uses same logic as FlutterFlow getCurrencyOptionsForLanguage()
  static List<String> _getCurrenciesForLanguage(String languageCode) {
    const currencyConfigByLanguage = {
      'en': ['USD', 'GBP', 'DKK'],
      'da': ['DKK'],
      'de': ['EUR', 'DKK'],
      'fr': ['EUR', 'DKK'],
      'it': ['EUR', 'DKK'],
      'no': ['NOK', 'DKK'],
      'sv': ['SEK', 'DKK'],
    };
    return currencyConfigByLanguage[languageCode.toLowerCase()] ?? ['DKK'];
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Data Retrieval
  // ─────────────────────────────────────────────────────────────────────────────

  /// Gets the effective currency code to use for display
  String _getEffectiveCurrencyCode() {
    final localization = ref.read(localizationProvider);
    final userCurrency = localization.currencyCode;

    if (userCurrency.trim().isEmpty) {
      return _defaultCurrencyCode;
    }

    return userCurrency;
  }

  /// Gets the currency display label: "Currency Name (Symbol)"
  String _getCurrencyDisplayLabel(BuildContext context, String currencyCode) {
    final currencyName = td(ref, 'currency_${currencyCode.toLowerCase()}_cap');
    final currencySymbol = _getCurrencySymbol(currencyCode);

    // If translation not found (fallback key returned), use code as fallback
    if (currencyName == 'currency_${currencyCode.toLowerCase()}_cap') {
      return '$currencyCode ($currencySymbol)';
    }

    return '$currencyName ($currencySymbol)';
  }

  /// Gets the currency symbol
  /// Only includes symbols for currencies available in _getCurrenciesForLanguage()
  String _getCurrencySymbol(String currencyCode) {
    const symbols = {
      'DKK': 'kr.',
      'USD': '\$',
      'GBP': '£',
      'EUR': '€',
      'SEK': 'kr.',
      'NOK': 'kr.',
    };

    return symbols[currencyCode] ?? currencyCode;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Overlay Management
  // ─────────────────────────────────────────────────────────────────────────────

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

  // ─────────────────────────────────────────────────────────────────────────────
  // Currency Selection & Exchange Rate
  // ─────────────────────────────────────────────────────────────────────────────

  /// Handles currency selection from overlay
  Future<void> _handleCurrencySelection(String newCurrencyCode) async {
    final currentCurrency = _getEffectiveCurrencyCode();

    // Dismiss overlay immediately for responsive feel
    _dismissOverlay();

    // Skip if selecting same currency
    if (newCurrencyCode == currentCurrency) return;

    // Fetch exchange rate and update provider
    await _updateCurrency(newCurrencyCode);
  }

  /// Updates currency code and fetches exchange rate
  Future<void> _updateCurrency(String currencyCode) async {
    try {
      // Fetch exchange rate from BuildShip API
      final exchangeRate = await _fetchExchangeRate(currencyCode);

      // Update provider (persists currency code, sets exchange rate)
      await ref.read(localizationProvider.notifier).setCurrency(
            currencyCode,
            exchangeRate,
          );

      if (!mounted) return;

      // Capture language code AFTER await to ensure accuracy
      final languageCode = Localizations.localeOf(context).languageCode;

      // Track analytics (fire-and-forget using unawaited)
      unawaited(
        ApiService.instance.postAnalytics(
          eventType: 'currency_changed',
          deviceId: '', // Handled by ApiService
          sessionId: '', // Handled by ApiService
          userId: '', // Handled by ApiService
          eventData: {
            'to_currency': currencyCode,
            'language_code': languageCode,
          },
          timestamp: DateTime.now().toIso8601String(),
        ).catchError((e) {
          debugPrint('⚠️ Analytics tracking failed: $e');
          return ApiCallResponse.failure('Analytics failed');
        }),
      );
    } catch (e) {
      debugPrint('❌ Currency update failed: $e');
      // Graceful degradation - keep current currency
    }
  }

  /// Fetches exchange rate from BuildShip API
  Future<double> _fetchExchangeRate(String currencyCode) async {
    try {
      // DKK has 1:1 rate (base currency)
      if (currencyCode == 'DKK') {
        return 1.0;
      }

      // Call BuildShip API: GET /exchangerate?to_currency={code}
      final response = await ApiService.instance.getExchangeRate(
        toCurrency: currencyCode,
      );

      if (!response.succeeded) {
        debugPrint('⚠️ Exchange rate API failed: ${response.statusCode}');

        // Track failed currency change (fire-and-forget)
        unawaited(
          ApiService.instance.postAnalytics(
            eventType: 'currency_change_failed',
            deviceId: '',
            sessionId: '',
            userId: '',
            eventData: {
              'to_currency': currencyCode,
              'reason': 'api_failed',
              'status_code': response.statusCode.toString(),
            },
            timestamp: DateTime.now().toIso8601String(),
          ).catchError((e) => ApiCallResponse.failure('Analytics failed')),
        );

        return 1.0; // Fallback
      }

      // Response format: [{"rate": 7.5}] or {"rate": 7.5}
      final dynamic body = response.jsonBody;

      if (body is List && body.isNotEmpty) {
        final rate = body[0]['rate'] as num;
        return rate.toDouble();
      } else if (body is Map && body.containsKey('rate')) {
        final rate = body['rate'] as num;
        return rate.toDouble();
      }

      debugPrint('⚠️ Unexpected exchange rate response format');
      return 1.0; // Fallback
    } catch (e) {
      debugPrint('❌ Exchange rate fetch failed: $e');
      return 1.0; // Fallback
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Language Change Detection
  // ─────────────────────────────────────────────────────────────────────────────

  /// Updates currency when language changes (auto-switches to language default)
  Future<void> _updateCurrencyForLanguageChange(String newLanguageCode) async {
    try {
      final currentCurrency = _getEffectiveCurrencyCode();
      final availableCurrencies = _getCurrenciesForLanguage(newLanguageCode);

      // If current currency not available in new language, switch to default (first option)
      if (!availableCurrencies.contains(currentCurrency)) {
        final defaultCurrency = availableCurrencies.first;
        await _updateCurrency(defaultCurrency);
        debugPrint('💱 Auto-switched currency to $defaultCurrency for language $newLanguageCode');
      }
    } catch (e) {
      debugPrint('❌ Error updating currency for language change: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Build: Main
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Watch for localization changes
    final localization = ref.watch(localizationProvider);
    final currentLanguageCode = Localizations.localeOf(context).languageCode;
    final currentCurrency = localization.currencyCode.isEmpty
        ? _defaultCurrencyCode
        : localization.currencyCode;

    // Check if language has changed since last build
    if (_lastKnownLanguage != null &&
        _lastKnownLanguage != currentLanguageCode) {
      // Update currency for new language asynchronously
      // NOTE: This is safe from build loops because _updateCurrencyForLanguageChange()
      // only updates provider state (not widget state), so it doesn't trigger setState.
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
        height: widget.height ?? 50.0, // ← FIXED: respect parameter
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getCurrencyDisplayLabel(context, currentCurrency),
                style: AppTypography.bodyRegular.copyWith(
                  fontWeight: FontWeight.w300,
                ),
              ),
              Icon(
                _isOverlayVisible
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
                size: 24.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Build: Overlay
  // ─────────────────────────────────────────────────────────────────────────────

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
          top: buttonPosition.dy + (widget.height ?? 50.0) + AppSpacing.xs,
          child: _buildOverlayContent(context, buttonWidth),
        ),
      ],
    );
  }

  /// Builds the overlay content container
  Widget _buildOverlayContent(BuildContext context, double width) {
    // Get filtered currencies for current language
    final currentLanguageCode = Localizations.localeOf(context).languageCode;
    final availableCurrencies = _getCurrenciesForLanguage(currentLanguageCode);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4.0,
              spreadRadius: 1.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.xs,
          bottom: AppSpacing.xs,
        ),
        child: _buildCurrencyList(context, availableCurrencies),
      ),
    );
  }

  /// Builds the list of currency options
  Widget _buildCurrencyList(BuildContext context, List<String> currencies) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: currencies.map((currencyCode) {
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
          left: AppSpacing.xs,
          top: AppSpacing.md,
          bottom: AppSpacing.md,
        ),
        child: Text(
          _getCurrencyDisplayLabel(context, currencyCode),
          style: AppTypography.bodyRegular.copyWith(
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}
