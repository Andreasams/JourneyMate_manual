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

/// Main entry point — optimized for fast startup with translation + filter caching.
///
/// Strategy: Show welcome page in <200ms with translations and filters loaded instantly.
/// 1. Single SharedPreferences.getInstance() call
/// 2. Batch-read all stored keys + cached translations + cached filters (7-day cache with versioning)
/// 3. AnalyticsService.initializeWithPrefs() (only async: UUID write on first launch)
/// 4. Synchronous provider initialization:
///    - FIRST LAUNCH: Welcome page fallbacks, no filter cache yet
///    - SUBSEQUENT LAUNCHES: Full cached translations + filters (<100ms)
/// 5. runApp() — user sees welcome page with full translations immediately
/// 6. Background: refresh stale caches; first launch dual-fetches Danish + English filters
///
/// CACHE VERSIONING: Increment _cacheVersion in TranslationsCacheNotifier / FilterNotifier
/// to force cache refresh for all users (prevents 7-day wait for new keys)
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

  // Load cached filters from SharedPreferences
  // Always try cache — returns FilterState.initial() when no cache exists
  final isFirstLaunch = prefs.getString('user_language_code') == null;
  final cachedFilters = await FilterNotifier.loadFromCache(storedLanguage);
  final isFilterCacheFresh = await FilterNotifier.isCacheFresh(storedLanguage);

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

  // Initialize filter state from cache (returning users get instant filters)
  // On first launch, cachedFilters has filtersForLanguage == null, so this is a no-op
  container.read(filterProvider.notifier).initializeFromPrefs(cachedFilters);

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

  // ── 7. Background: refresh translations + filters (skip if caches are fresh) ──
  unawaited(_loadAppDataInBackground(
    container,
    storedLanguage,
    isCacheFresh,
    isFilterCacheFresh,
    isFirstLaunch,
  ));

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
/// App is already visible — cached data is shown immediately.
///
/// [skipTranslations] - If true, skip translation refresh (cache is fresh)
/// [skipFilters] - If true, skip filter refresh (cache is fresh)
/// [isFirstLaunch] - If true, load filters for user's language + pre-cache Danish
Future<void> _loadAppDataInBackground(
  ProviderContainer container,
  String languageCode,
  bool skipTranslations,
  bool skipFilters,
  bool isFirstLaunch,
) async {
  const maxAttempts = 3;
  const retryDelay = Duration(seconds: 2);

  for (int attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      final futures = <Future>[];

      if (!skipTranslations) {
        futures.add(container.read(translationsCacheProvider.notifier).loadTranslations(languageCode));
      }

      if (isFirstLaunch) {
        // First launch: load filters for user's language (sets provider state)
        // + pre-cache Danish for welcome page's "Fortsæt på dansk" path
        futures.add(container.read(filterProvider.notifier).loadFiltersForLanguage(languageCode));
        if (languageCode != 'da') {
          futures.add(container.read(filterProvider.notifier).fetchAndCacheOnly('da'));
        }
      } else if (!skipFilters) {
        // Returning user, stale cache: refresh from API
        futures.add(container.read(filterProvider.notifier).loadFiltersForLanguage(languageCode));
      }

      if (futures.isNotEmpty) {
        await Future.wait(futures).timeout(const Duration(seconds: 10));
      }

      return; // Success
    } catch (e) {
      if (attempt < maxAttempts) {
        await Future.delayed(retryDelay);
      }
    }
  }
}
