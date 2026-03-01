import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'provider_state_classes.dart';
import '../services/api_service.dart';

// ============================================================
// LOCALIZATION PROVIDER (with persistence)
// ============================================================

/// Localization provider (Riverpod 3.x) - persists currencyCode
final localizationProvider =
    NotifierProvider<LocalizationNotifier, LocalizationState>(() {
  return LocalizationNotifier();
});

class LocalizationNotifier extends Notifier<LocalizationState> {
  /// Cache for exchange rates to reduce API calls
  final Map<String, double> _exchangeRateCache = {};

  @override
  LocalizationState build() {
    return LocalizationState.initial();
  }

  /// Synchronous initialization from pre-read SharedPreferences values
  /// Loads both currency code and cached exchange rate (if available)
  void initializeFromPrefs({required String currencyCode, double? exchangeRate}) {
    state = state.copyWith(
      currencyCode: currencyCode,
      exchangeRate: exchangeRate ?? 1.0,
    );
    debugPrint('✅ Loaded currency: $currencyCode (rate: ${exchangeRate ?? 1.0})');
  }

  /// Load currency code from SharedPreferences
  Future<void> loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currencyCode = prefs.getString('user_currency_code') ?? 'DKK';

      state = state.copyWith(currencyCode: currencyCode);
      debugPrint('✅ Loaded currency: $currencyCode');
    } catch (e) {
      debugPrint('⚠️ Failed to load currency preference: $e');
      // Fail silently, keep default state
    }
  }

  /// Fetches exchange rate for the current currency code and updates state.
  /// Called at app startup to ensure exchange rate matches stored currency.
  /// Gracefully handles failures (rate stays at 1.0 if fetch fails).
  Future<void> loadExchangeRateForCurrentCurrency() async {
    final currencyCode = state.currencyCode;

    // Skip if no currency set or if DKK (base currency, rate = 1.0)
    if (currencyCode.isEmpty || currencyCode == 'DKK') {
      debugPrint('💱 Exchange rate load skipped (currency: $currencyCode)');
      return;
    }

    try {
      debugPrint('💱 Fetching exchange rate for $currencyCode...');
      final rate = await _fetchExchangeRate(currencyCode);
      setExchangeRate(rate);
      debugPrint('✅ Exchange rate loaded: $currencyCode = $rate');
    } catch (e) {
      debugPrint('⚠️ Failed to load exchange rate for $currencyCode: $e');
      // Graceful failure - rate stays at 1.0 (acceptable for DKK base)
    }
  }

  /// Set currency code and exchange rate (persists both to SharedPreferences)
  Future<void> setCurrency(String code, double rate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_currency_code', code);
      await prefs.setDouble('user_exchange_rate', rate);

      state = state.copyWith(
        currencyCode: code,
        exchangeRate: rate,
      );

      debugPrint('✅ Currency set: $code (rate: $rate)');
    } catch (e) {
      debugPrint('⚠️ Failed to save currency preference: $e');
    }
  }

  /// Update exchange rate and persist to SharedPreferences
  Future<void> setExchangeRate(double rate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('user_exchange_rate', rate);
      state = state.copyWith(exchangeRate: rate);
    } catch (e) {
      debugPrint('⚠️ Failed to save exchange rate: $e');
      // Still update in-memory state
      state = state.copyWith(exchangeRate: rate);
    }
  }

  /// Reset to default currency
  Future<void> resetToDefault() async {
    await setCurrency('DKK', 1.0);
  }

  /// Auto-suggests currency based on language change
  /// If current currency is not available in new language, switches to default
  Future<void> updateCurrencyForLanguageChange(String newLanguageCode) async {
    try {
      final currentCurrency = state.currencyCode.isEmpty ? 'DKK' : state.currencyCode;
      final availableCurrencies = _getCurrenciesForLanguage(newLanguageCode);

      // If current currency not available in new language, switch to default (first option)
      if (!availableCurrencies.contains(currentCurrency)) {
        final defaultCurrency = availableCurrencies.first;

        // Fetch exchange rate for new currency
        final exchangeRate = await _fetchExchangeRate(defaultCurrency);

        // Update currency with new rate
        await setCurrency(defaultCurrency, exchangeRate);
        debugPrint('💱 Auto-switched currency to $defaultCurrency for language $newLanguageCode');
      } else {
        debugPrint('✓ Currency $currentCurrency is available for language $newLanguageCode, no change needed');
      }
    } catch (e) {
      debugPrint('❌ Error updating currency for language change: $e');
    }
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

  /// Fetches exchange rate from BuildShip API (with caching)
  Future<double> _fetchExchangeRate(String currencyCode) async {
    try {
      // DKK has 1:1 rate (base currency)
      if (currencyCode == 'DKK') {
        return 1.0;
      }

      // Check cache first
      if (_exchangeRateCache.containsKey(currencyCode)) {
        debugPrint('💾 Using cached exchange rate for $currencyCode: ${_exchangeRateCache[currencyCode]}');
        return _exchangeRateCache[currencyCode]!;
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

      double rate = 1.0;
      if (body is List && body.isNotEmpty) {
        rate = (body[0]['rate'] as num).toDouble();
      } else if (body is Map && body.containsKey('rate')) {
        rate = (body['rate'] as num).toDouble();
      } else {
        debugPrint('⚠️ Unexpected exchange rate response format');
        return 1.0; // Fallback
      }

      // Cache the rate for future use
      _exchangeRateCache[currencyCode] = rate;
      debugPrint('✅ Cached exchange rate for $currencyCode: $rate');

      return rate;
    } catch (e) {
      debugPrint('❌ Exchange rate fetch failed: $e');
      return 1.0; // Fallback
    }
  }
}

// ============================================================
// LOCATION PROVIDER (no persistence)
// ============================================================

/// Location provider (Riverpod 3.x) - tracks permission state
final locationProvider = NotifierProvider<LocationNotifier, LocationState>(() {
  return LocationNotifier();
});

class LocationNotifier extends Notifier<LocationState> {
  static const String _kBannerDismissedKey = 'location_banner_dismissed';

  @override
  LocationState build() {
    return LocationState.initial();
  }

  /// Check current location permission and service status
  Future<void> checkPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      final permission = await Geolocator.checkPermission();

      final hasPermission = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      state = state.copyWith(
        hasPermission: hasPermission,
        isServiceEnabled: serviceEnabled,
      );
      debugPrint('✅ Location service: $serviceEnabled, permission: $permission');
    } catch (e) {
      debugPrint('⚠️ Error checking location permission: $e');
      state = state.copyWith(hasPermission: false, isServiceEnabled: false);
    }
  }

  /// Synchronous initialization from pre-read SharedPreferences values
  void initializeFromPrefs({required bool isBannerDismissed}) {
    state = state.copyWith(isBannerDismissed: isBannerDismissed);
  }

  /// Load banner dismissal state from SharedPreferences
  Future<void> loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDismissed = prefs.getBool(_kBannerDismissedKey) ?? false;
      state = state.copyWith(isBannerDismissed: isDismissed);
      debugPrint('✅ Loaded banner dismissal state: $isDismissed');
    } catch (e) {
      debugPrint('⚠️ Failed to load banner dismissal preference: $e');
    }
  }

  /// Dismiss the location permission banner
  Future<void> dismissBanner() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kBannerDismissedKey, true);
      state = state.copyWith(isBannerDismissed: true);
      debugPrint('✅ Banner dismissed and persisted');
    } catch (e) {
      debugPrint('⚠️ Failed to persist banner dismissal: $e');
      state = state.copyWith(isBannerDismissed: true);
    }
  }

  /// Reset banner dismissal flag (used when permission is granted via Settings)
  Future<void> resetBannerDismissal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kBannerDismissedKey, false);
      state = state.copyWith(isBannerDismissed: false);
      debugPrint('✅ Banner dismissal reset');
    } catch (e) {
      debugPrint('⚠️ Failed to reset banner dismissal: $e');
    }
  }

  /// Request location permission
  Future<bool> requestPermission() async {
    try {
      final status = await ph.Permission.locationWhenInUse.request();
      final granted = status.isGranted;

      if (granted) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_kBannerDismissedKey, false);
        state = state.copyWith(
          hasPermission: true,
          isServiceEnabled: serviceEnabled,
          isBannerDismissed: false,
        );
      } else {
        state = state.copyWith(hasPermission: false);
      }

      return granted;
    } catch (e) {
      debugPrint('⚠️ Error requesting location permission: $e');
      state = state.copyWith(hasPermission: false);
      return false;
    }
  }

  /// Manually set permission state (for testing or external updates)
  void setPermission(bool hasPermission) {
    state = state.copyWith(hasPermission: hasPermission);
  }

  /// Open app settings for manual permission grant
  Future<void> openSettings() async {
    try {
      await ph.openAppSettings();
    } catch (e) {
      debugPrint('⚠️ Error opening app settings: $e');
    }
  }

  /// Smart enable: shows permission dialog if first time, opens Settings if permanently denied
  Future<void> enableLocation() async {
    try {
      final status = await ph.Permission.locationWhenInUse.status;

      if (status.isGranted) {
        // Already enabled — reset dismissal flag and open settings for management
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_kBannerDismissedKey, false);
        state = state.copyWith(
          hasPermission: true,
          isServiceEnabled: serviceEnabled,
          isBannerDismissed: false,
        );
        await ph.openAppSettings();
        return;
      }

      if (status.isPermanentlyDenied) {
        // User previously denied — dialog won't appear, must use Settings
        await ph.openAppSettings();
        return;
      }

      // First time or soft-denied — show native iOS permission dialog
      final result = await ph.Permission.locationWhenInUse.request();

      // Reset dismissal flag if permission granted
      if (result.isGranted) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_kBannerDismissedKey, false);
        state = state.copyWith(
          hasPermission: true,
          isServiceEnabled: serviceEnabled,
          isBannerDismissed: false,
        );
      } else {
        state = state.copyWith(hasPermission: false);
      }

      // If dialog resulted in permanent denial, open Settings as fallback
      if (result.isPermanentlyDenied) {
        await ph.openAppSettings();
      }
    } catch (e) {
      debugPrint('⚠️ Error enabling location: $e');
    }
  }

  /// Request permission if never asked before (safe to call on every launch).
  /// On iOS: status == denied means "never asked". After first denial,
  /// status becomes permanentlyDenied, so this becomes a no-op.
  Future<void> requestPermissionIfNeeded() async {
    try {
      final status = await ph.Permission.locationWhenInUse.status;

      if (status.isDenied) {
        final result = await ph.Permission.locationWhenInUse.request();

        if (result.isGranted) {
          final serviceEnabled = await Geolocator.isLocationServiceEnabled();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_kBannerDismissedKey, false);
          state = state.copyWith(
            hasPermission: true,
            isServiceEnabled: serviceEnabled,
            isBannerDismissed: false,
          );
        } else {
          state = state.copyWith(hasPermission: false);
        }
      } else if (status.isGranted) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        state = state.copyWith(
          hasPermission: true,
          isServiceEnabled: serviceEnabled,
        );
      }
    } catch (e) {
      debugPrint('⚠️ Error in requestPermissionIfNeeded: $e');
    }
  }
}
