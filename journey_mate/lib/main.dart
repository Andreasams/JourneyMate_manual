import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'services/analytics_service.dart';
import 'providers/app_providers.dart';
import 'providers/settings_providers.dart';
import 'providers/filter_providers.dart';
import 'providers/locale_provider.dart';
import 'widgets/app_lifecycle_observer.dart';
import 'widgets/activity_scope.dart';

/// Main entry point — optimized for fast startup.
///
/// Strategy: Show welcome page in <200ms by deferring network calls.
/// 1. Single SharedPreferences.getInstance() call
/// 2. Batch-read all stored keys
/// 3. AnalyticsService.initializeWithPrefs() (only async: UUID write on first launch)
/// 4. Synchronous provider initialization (no awaits)
/// 5. runApp() — user sees welcome page
/// 6. Background: load translations + filters, check location
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Single SharedPreferences load ──
  final prefs = await SharedPreferences.getInstance();

  // ── 2. Batch-read all stored keys ──
  final storedLanguage = prefs.getString('user_language_code') ?? 'en';
  final storedCurrency = prefs.getString('user_currency_code') ?? 'DKK';
  final isBoldText = prefs.getBool('is_bold_text_enabled') ?? false;
  final fontScale = prefs.getDouble('font_scale') ?? 1.0;
  final isBannerDismissed = prefs.getBool('location_banner_dismissed') ?? false;

  // ── 3. Initialize AnalyticsService (only async op: UUID write on first launch) ──
  await AnalyticsService.instance.initializeWithPrefs(prefs);

  // ── 4. Create container + synchronous provider init ──
  final container = ProviderContainer();

  // Pass AnalyticsService's device ID to AnalyticsNotifier (single device ID everywhere)
  container.read(analyticsProvider.notifier).initializeFromPrefs(
    deviceId: AnalyticsService.instance.deviceId ?? '',
  );

  container.read(accessibilityProvider.notifier).initializeFromPrefs(
    isBoldTextEnabled: isBoldText,
    fontScale: fontScale,
  );

  container.read(localeProvider.notifier).initializeFromPrefs(
    languageCode: storedLanguage,
  );

  container.read(localizationProvider.notifier).initializeFromPrefs(
    currencyCode: storedCurrency,
  );

  container.read(locationProvider.notifier).initializeFromPrefs(
    isBannerDismissed: isBannerDismissed,
  );

  // ── 5. Register lifecycle observer ──
  final appObserver = AppLifecycleObserver(container: container);
  WidgetsBinding.instance.addObserver(appObserver);

  // ── 6. runApp() — user sees welcome page immediately ──
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ActivityScope(
        child: JourneyMateApp(),
      ),
    ),
  );

  // ── 7. Background: load translations + filters (fire-and-forget with retry) ──
  unawaited(_loadAppDataInBackground(container, storedLanguage));

  // ── 8. Background: check location permission + service status ──
  unawaited(container.read(locationProvider.notifier).checkPermission());

  // ── 9. Background: fetch exchange rate for stored currency ──
  unawaited(container.read(localizationProvider.notifier).loadExchangeRateForCurrentCurrency());
}

/// Loads translations and filters in the background with retry logic.
/// App is already visible — td() returns key IDs as fallback until loaded.
Future<void> _loadAppDataInBackground(
  ProviderContainer container,
  String languageCode,
) async {
  const maxAttempts = 3;
  const retryDelay = Duration(seconds: 2);

  for (int attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      debugPrint('🔄 Loading translations + filters (attempt $attempt/$maxAttempts)');

      await Future.wait([
        container.read(translationsCacheProvider.notifier).loadTranslations(languageCode),
        container.read(filterProvider.notifier).loadFiltersForLanguage(languageCode),
      ]).timeout(const Duration(seconds: 10));

      debugPrint('✅ Translations + filters loaded successfully');
      return; // Success
    } catch (e) {
      debugPrint('⚠️ Attempt $attempt failed: $e');

      if (attempt < maxAttempts) {
        debugPrint('⏳ Waiting ${retryDelay.inSeconds}s before retry...');
        await Future.delayed(retryDelay);
      } else {
        debugPrint('⚠️ All attempts failed — app functional with key ID fallback');
      }
    }
  }
}
