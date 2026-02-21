import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'provider_state_classes.dart';

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
