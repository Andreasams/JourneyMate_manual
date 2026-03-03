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

/// Main entry point — optimized for fast startup with translation caching.
///
/// Strategy: Show welcome page in <200ms with translations loaded instantly on ALL launches.
/// 1. Single SharedPreferences.getInstance() call
/// 2. Batch-read all stored keys + cached translations (7-day cache with versioning)
/// 3. AnalyticsService.initializeWithPrefs() (only async: UUID write on first launch)
/// 4. Synchronous provider initialization:
///    - FIRST LAUNCH: Welcome page fallbacks (5 keys, instant display)
///    - SUBSEQUENT LAUNCHES: Full cached translations (<100ms)
/// 5. runApp() — user sees welcome page with full translations immediately
/// 6. Background: refresh translations if stale (>7 days or version mismatch), load filters, check location
///
/// CACHE VERSIONING: Increment TranslationsCacheNotifier._cacheVersion when adding new features
/// to force cache refresh for all users (prevents 7-day wait for new translation keys)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Single SharedPreferences load ──
  final prefs = await SharedPreferences.getInstance();

  // ── 2. Batch-read all stored keys + cached translations ──
  final storedLanguage = prefs.getString('user_language_code') ?? 'en';
  final storedCurrency = prefs.getString('user_currency_code') ?? 'DKK';
  final storedExchangeRate = prefs.getDouble('user_exchange_rate'); // null if not set
  final isBoldText = prefs.getBool('is_bold_text_enabled') ?? false;
  final fontScale = prefs.getDouble('font_scale') ?? 1.0;
  final isBannerDismissed = prefs.getBool('location_banner_dismissed') ?? false;

  // Distance unit: Default to 'imperial' for English, 'metric' for others
  final defaultDistanceUnit = storedLanguage == 'en' ? 'imperial' : 'metric';
  final storedDistanceUnit = prefs.getString('user_distance_unit') ?? defaultDistanceUnit;

  // Load cached translations from SharedPreferences (if available)
  final cachedTranslations = await TranslationsCacheNotifier.loadFromCache(storedLanguage);
  final isCacheFresh = await TranslationsCacheNotifier.isCacheFresh(storedLanguage);

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
    exchangeRate: storedExchangeRate,
    distanceUnit: storedDistanceUnit,
  );

  container.read(locationProvider.notifier).initializeFromPrefs(
    isBannerDismissed: isBannerDismissed,
  );

  container.read(translationsCacheProvider.notifier).initializeFromPrefs(
    cachedTranslations,
    storedLanguage,
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

  // ── 7. Background: refresh translations + load filters (skip translations if cache is fresh) ──
  unawaited(_loadAppDataInBackground(container, storedLanguage, isCacheFresh));

  // ── 8. Background: check location permission + service status ──
  unawaited(container.read(locationProvider.notifier).checkPermission());

  // ── 9. Background: refresh exchange rate if not cached ──
  // If cached rate exists (from previous session), skip fetch
  // If no cache, fetch latest rate (fire-and-forget)
  if (storedExchangeRate == null && storedCurrency != 'DKK') {
    unawaited(container.read(localizationProvider.notifier).loadExchangeRateForCurrentCurrency());
  }
}

/// Loads translations and filters in the background with retry logic.
/// App is already visible — cached translations are shown immediately.
/// [skipTranslations] - If true, skip translation refresh (cache is fresh)
Future<void> _loadAppDataInBackground(
  ProviderContainer container,
  String languageCode,
  bool skipTranslations,
) async {
  const maxAttempts = 3;
  const retryDelay = Duration(seconds: 2);

  for (int attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      if (skipTranslations) {
        debugPrint('🔄 Loading filters (translations cached, skipping refresh)');
        await container.read(filterProvider.notifier).loadFiltersForLanguage(languageCode)
            .timeout(const Duration(seconds: 10));
      } else {
        debugPrint('🔄 Loading translations + filters (attempt $attempt/$maxAttempts)');
        await Future.wait([
          container.read(translationsCacheProvider.notifier).loadTranslations(languageCode),
          container.read(filterProvider.notifier).loadFiltersForLanguage(languageCode),
        ]).timeout(const Duration(seconds: 10));
      }

      debugPrint('✅ Background data loaded successfully');
      return; // Success
    } catch (e) {
      debugPrint('⚠️ Attempt $attempt failed: $e');

      if (attempt < maxAttempts) {
        debugPrint('⏳ Waiting ${retryDelay.inSeconds}s before retry...');
        await Future.delayed(retryDelay);
      } else {
        debugPrint('⚠️ All attempts failed — app functional with cached data');
      }
    }
  }
}
