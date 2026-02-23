import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_providers.dart';
import '../../services/api_service.dart';
import '../../services/translation_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';

/// A button that displays the currently selected currency and opens a
/// dropdown selector on tap.
///
/// **State Management:**
/// - Uses local state for language change detection
/// - Reads currency from `localizationProvider`
/// - Updates currency via `localizationProvider.notifier.setCurrency()`
///
/// **Features:**
/// - Displays currency name and symbol (e.g., "Danish Krone (kr.)")
/// - Opens Material Design dropdown with language-specific currencies
/// - Currency filtering by language:
///   - Danish: DKK only
///   - English: USD, GBP, DKK
///   - German/French/Italian: EUR, DKK
///   - Swedish: SEK, DKK
///   - Norwegian: NOK, DKK
/// - Auto-switches currency when language changes (if current currency not available)
/// - Fetches exchange rates via BuildShip API
/// - Analytics tracking for currency changes
///
/// **FlutterFlow Migration Notes:**
/// - Migrated from overlay to Material Design DropdownButtonFormField
/// - Added language-specific currency filtering (getCurrencyOptionsForLanguage logic)
/// - Removed markUserEngaged() calls (ActivityScope handles automatically)
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
  // State
  // ─────────────────────────────────────────────────────────────────────────────

  /// Tracks the last known language to detect changes
  String? _lastKnownLanguage;

  /// Default currency code
  static const String _defaultCurrencyCode = 'DKK';

  // ─────────────────────────────────────────────────────────────────────────────
  // Currency Configuration
  // ─────────────────────────────────────────────────────────────────────────────

  /// Default currency by language (used for language change fallback)
  // ignore: unused_element
  String _getDefaultCurrencyForLanguage(String languageCode) {
    const defaults = {
      'en': 'USD',
      'de': 'EUR',
      'sv': 'SEK',
      'no': 'NOK',
      'da': 'DKK',
      'es': 'EUR',
      'fi': 'EUR',
      'nl': 'EUR',
      'pl': 'PLN',
      'uk': 'UAH',
      'ja': 'JPY',
      'ko': 'USD', // No KRW in list, fallback to USD
      'zh': 'CNY',
    };

    return defaults[languageCode] ?? _defaultCurrencyCode;
  }

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
  String _getCurrencySymbol(String currencyCode) {
    const symbols = {
      'DKK': 'kr.',
      'USD': '\$',
      'GBP': '£',
      'EUR': '€',
      'SEK': 'kr.',
      'NOK': 'kr.',
      'PLN': 'zł',
      'JPY': '¥',
      'CNY': '¥',
      'UAH': '₴',
      'CHF': 'CHF',
    };

    return symbols[currencyCode] ?? currencyCode;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Currency Selection & Exchange Rate
  // ─────────────────────────────────────────────────────────────────────────────

  /// Handles currency selection from dropdown
  Future<void> _handleCurrencySelection(String newCurrencyCode) async {
    final currentCurrency = _getEffectiveCurrencyCode();

    // Skip if selecting same currency
    if (newCurrencyCode == currentCurrency) return;

    // Fetch exchange rate and update provider
    await _updateCurrency(newCurrencyCode);
  }

  /// Updates currency code and fetches exchange rate
  Future<void> _updateCurrency(String currencyCode) async {
    // Capture language code before async operations
    final languageCode = Localizations.localeOf(context).languageCode;

    try {
      // Fetch exchange rate from BuildShip API
      final exchangeRate = await _fetchExchangeRate(currencyCode);

      // Update provider (persists currency code, sets exchange rate)
      await ref.read(localizationProvider.notifier).setCurrency(
            currencyCode,
            exchangeRate,
          );

      if (!mounted) return;

      // Track analytics (fire-and-forget)
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
      });
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
      }
    } catch (e) {
      debugPrint('❌ Error updating currency for language change: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Build
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateCurrencyForLanguageChange(currentLanguageCode);
      });
    }

    // Update last known language
    _lastKnownLanguage = currentLanguageCode;

    // Get filtered currencies for current language
    final availableCurrencies = _getCurrenciesForLanguage(currentLanguageCode);

    final effectiveValue = availableCurrencies.contains(currentCurrency)
        ? currentCurrency
        : availableCurrencies.first;

    return GestureDetector(
      onTap: () {
        // Open dropdown programmatically by using a hidden button
        // We'll trigger the dropdown via the actual DropdownButton below
      },
      child: Container(
        width: widget.width,
        height: 50.0,
        decoration: BoxDecoration(
          color: AppColors.bgInput,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(color: AppColors.border, width: 1.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getCurrencyDisplayLabel(context, effectiveValue),
              style: AppTypography.bodyRegular.copyWith(
                fontWeight: FontWeight.w300,
              ),
            ),
            DropdownButton<String>(
              value: effectiveValue,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
                size: 24.0,
              ),
              dropdownColor: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(AppRadius.chip),
              elevation: 4,
              underline: const SizedBox.shrink(),
              selectedItemBuilder: (context) {
                // Return empty widgets for selected item (we show it separately)
                return availableCurrencies.map((code) => const SizedBox.shrink()).toList();
              },
              items: availableCurrencies.map((code) {
                return DropdownMenuItem<String>(
                  value: code,
                  child: Text(
                    _getCurrencyDisplayLabel(context, code),
                    style: AppTypography.bodyRegular.copyWith(
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newCurrency) {
                if (newCurrency != null && newCurrency != effectiveValue) {
                  _handleCurrencySelection(newCurrency);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
