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
  @override
  LocalizationState build() {
    return LocalizationState.initial();
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

  /// Set currency code and exchange rate (persists code only)
  Future<void> setCurrency(String code, double rate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_currency_code', code);

      state = state.copyWith(
        currencyCode: code,
        exchangeRate: rate,
      );

      debugPrint('✅ Currency set: $code (rate: $rate)');
    } catch (e) {
      debugPrint('⚠️ Failed to save currency preference: $e');
    }
  }

  /// Update only the exchange rate (not persisted)
  void setExchangeRate(double rate) {
    state = state.copyWith(exchangeRate: rate);
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
}

// ============================================================
// LOCATION PROVIDER (no persistence)
// ============================================================

/// Location provider (Riverpod 3.x) - tracks permission state
final locationProvider = NotifierProvider<LocationNotifier, LocationState>(() {
  return LocationNotifier();
});

class LocationNotifier extends Notifier<LocationState> {
  @override
  LocationState build() {
    return LocationState.initial();
  }

  /// Check current location permission status
  Future<void> checkPermission() async {
    try {
      final permission = await Geolocator.checkPermission();

      final hasPermission = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      state = state.copyWith(hasPermission: hasPermission);
      debugPrint('✅ Location permission: $permission');
    } catch (e) {
      debugPrint('⚠️ Error checking location permission: $e');
      state = state.copyWith(hasPermission: false);
    }
  }

  /// Request location permission
  Future<bool> requestPermission() async {
    try {
      final status = await ph.Permission.location.request();

      final granted = status.isGranted;
      state = state.copyWith(hasPermission: granted);

      debugPrint('✅ Location permission requested: $status');
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
}
