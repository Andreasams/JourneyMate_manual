import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'provider_state_classes.dart';
import '../services/api_service.dart';
import '../services/custom_functions/language_currency_config.dart';

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
  /// Loads currency code, cached exchange rate (if available), and distance unit
  void initializeFromPrefs({
    required String currencyCode,
    double? exchangeRate,
    required String distanceUnit,
  }) {
    state = state.copyWith(
      currencyCode: currencyCode,
      exchangeRate: exchangeRate ?? 1.0,
      distanceUnit: distanceUnit,
    );
  }

  /// Load currency code from SharedPreferences
  Future<void> loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currencyCode = prefs.getString('user_currency_code') ?? 'DKK';

      state = state.copyWith(currencyCode: currencyCode);
    } catch (e) {
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
      return;
    }

    try {
      final rate = await _fetchExchangeRate(currencyCode);
      setExchangeRate(rate);
    } catch (e) {
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

    } catch (e) {
      // Fail silently
    }
  }

  /// Update exchange rate and persist to SharedPreferences
  Future<void> setExchangeRate(double rate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('user_exchange_rate', rate);
      state = state.copyWith(exchangeRate: rate);
    } catch (e) {
      // Still update in-memory state
      state = state.copyWith(exchangeRate: rate);
    }
  }

  /// Reset to default currency
  Future<void> resetToDefault() async {
    await setCurrency('DKK', 1.0);
  }

  /// Set distance unit preference and persist to SharedPreferences
  Future<void> setDistanceUnit(String unit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_distance_unit', unit);
      state = state.copyWith(distanceUnit: unit);
    } catch (e) {
      // Still update in-memory state (graceful degradation)
      state = state.copyWith(distanceUnit: unit);
    }
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
      }
    } catch (e) {
      // Fail silently
    }
  }

  /// Returns filtered currency codes based on language.
  /// Delegates to shared [getCurrenciesForLanguage] config (all 15 languages).
  static List<String> _getCurrenciesForLanguage(String languageCode) {
    return getCurrenciesForLanguage(languageCode);
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
        return _exchangeRateCache[currencyCode]!;
      }

      // Call BuildShip API: GET /exchangerate?to_currency={code}
      final response = await ApiService.instance.getExchangeRate(
        toCurrency: currencyCode,
      );

      if (!response.succeeded) {
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
        return 1.0; // Fallback
      }

      // Cache the rate for future use
      _exchangeRateCache[currencyCode] = rate;

      return rate;
    } catch (e) {
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
    } catch (e) {
      state = state.copyWith(hasPermission: false, isServiceEnabled: false);
    }
  }

  /// Fetches current GPS position if location is usable.
  /// Returns cached position if < 5 minutes old.
  /// Returns null if location not usable or fetch fails.
  /// Safe to call multiple times - won't spam GPS.
  Future<Position?> getCurrentPosition() async {
    // Check if location is usable (service + permission)
    if (!state.isLocationUsable) {
      return null;
    }

    // Return cached position if < 5 minutes old
    if (state.currentPosition != null && state.lastPositionFetch != null) {
      final age = DateTime.now().difference(state.lastPositionFetch!);
      if (age.inMinutes < 5) {
        return state.currentPosition;
      }
    }

    // Fetch fresh position
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );

      // Update state with fresh position
      state = state.copyWith(
        currentPosition: position,
        lastPositionFetch: DateTime.now(),
      );

      return position;
    } catch (e) {
      return null;  // Defensive: don't throw, return null
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
    } catch (e) {
      // Fail silently
    }
  }

  /// Dismiss the location permission banner
  Future<void> dismissBanner() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kBannerDismissedKey, true);
      state = state.copyWith(isBannerDismissed: true);
    } catch (e) {
      state = state.copyWith(isBannerDismissed: true);
    }
  }

  /// Reset banner dismissal flag (used when permission is granted via Settings)
  Future<void> resetBannerDismissal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kBannerDismissedKey, false);
      state = state.copyWith(isBannerDismissed: false);
    } catch (e) {
      // Fail silently
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
      // Fail silently
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
      // Fail silently
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
      // Fail silently
    }
  }
}
