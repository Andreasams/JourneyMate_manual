import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/analytics_service.dart';
import 'providers/app_providers.dart';
import 'widgets/app_lifecycle_observer.dart';
import 'widgets/activity_scope.dart';

/// Main entry point with full Riverpod 3.x infrastructure
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize analytics service BEFORE building app
  await AnalyticsService.instance.initialize();

  // ⚠️ CRITICAL: Create ProviderContainer BEFORE runApp
  final container = ProviderContainer();

  // Initialize providers
  await container.read(analyticsProvider.notifier).initialize();
  await container.read(accessibilityProvider.notifier).loadFromPreferences();

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
