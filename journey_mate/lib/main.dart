import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'services/analytics_service.dart';
import 'providers/app_providers.dart';
import 'providers/settings_providers.dart';
import 'widgets/app_lifecycle_observer.dart';
import 'widgets/activity_scope.dart';

/// Main entry point with full Riverpod 3.x infrastructure
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize analytics service BEFORE building app
  await AnalyticsService.instance.initialize();

  // ⚠️ CRITICAL: Create ProviderContainer BEFORE runApp
  final container = ProviderContainer();

  // Initialize providers (order: Analytics → Accessibility → Localization → Translations → Location)
  await container.read(analyticsProvider.notifier).initialize();
  await container.read(accessibilityProvider.notifier).loadFromPreferences();
  await container.read(localizationProvider.notifier).loadFromPreferences();

  // Load translations in user's stored language (or default to 'en')
  final prefs = await SharedPreferences.getInstance();
  final storedLanguage = prefs.getString('user_language_code') ?? 'en';
  await container.read(translationsCacheProvider.notifier).loadTranslations(storedLanguage);

  await container.read(locationProvider.notifier).checkPermission();

  // Register lifecycle observer
  final appObserver = AppLifecycleObserver(container: container);
  WidgetsBinding.instance.addObserver(appObserver);

  // ⚠️ CRITICAL: Use UncontrolledProviderScope (NOT ProviderScope)
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ActivityScope(
        child: JourneyMateApp(),
      ),
    ),
  );
}
