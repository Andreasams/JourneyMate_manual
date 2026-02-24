import 'dart:math';
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

/// Main entry point with full Riverpod 3.x infrastructure
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize analytics service BEFORE building app
  await AnalyticsService.instance.initialize();

  // ⚠️ CRITICAL: Create ProviderContainer BEFORE runApp
  final container = ProviderContainer();

  // Initialize providers (order: Analytics → Accessibility → Locale → Localization → Translations+Filters → Location)
  await container.read(analyticsProvider.notifier).initialize();
  await container.read(accessibilityProvider.notifier).loadFromPreferences();
  await container.read(localeProvider.notifier).initialize(); // ✅ Phase 3: Initialize locale first
  await container.read(localizationProvider.notifier).loadFromPreferences();

  // Load translations + filters in user's stored language (or default to 'en')
  final prefs = await SharedPreferences.getInstance();
  final storedLanguage = prefs.getString('user_language_code') ?? 'en';

  // Helper function for retry logic (handles early network not ready)
  Future<void> loadWithRetry() async {
    const maxAttempts = 3;
    const retryDelay = Duration(seconds: 2);

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        debugPrint('🔄 Loading translations + filters (attempt $attempt/$maxAttempts)');

        await Future.wait([
          container.read(translationsCacheProvider.notifier).loadTranslations(storedLanguage),
          container.read(filterProvider.notifier).loadFiltersForLanguage(storedLanguage),
        ]).timeout(const Duration(seconds: 10));

        debugPrint('✅ Translations + filters loaded successfully');
        return; // Success!
      } catch (e) {
        debugPrint('⚠️ Attempt $attempt failed: $e');

        if (attempt < maxAttempts) {
          debugPrint('⏳ Waiting ${retryDelay.inSeconds}s before retry...');
          await Future.delayed(retryDelay);
        } else {
          rethrow; // Give up after max attempts
        }
      }
    }
  }

  try {
    await loadWithRetry();
    // Success: Continue with normal app startup
  } catch (e) {
    debugPrint('⚠️ CRITICAL: Failed to load app data: $e');

    // Show error screen instead of broken app
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFFF7F4F0), // AppColors.bgPage
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 80, color: Color(0xFFE8751A)),
                    const SizedBox(height: 24),
                    const Text(
                      'Unable to Connect',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF000000),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'JourneyMate couldn\'t load required data from the server.',
                      style: TextStyle(fontSize: 16, color: Color(0xFF000000)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please check your internet connection and restart the app.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        // Retry loading
                        try {
                          await Future.wait([
                            container.read(translationsCacheProvider.notifier).loadTranslations(storedLanguage),
                            container.read(filterProvider.notifier).loadFiltersForLanguage(storedLanguage),
                          ]).timeout(const Duration(seconds: 10));

                          // Success! Launch the real app
                          runApp(
                            UncontrolledProviderScope(
                              container: container,
                              child: const ActivityScope(
                                child: JourneyMateApp(),
                              ),
                            ),
                          );
                        } catch (retryError) {
                          debugPrint('⚠️ Retry failed: $retryError');
                          // Error screen remains visible
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8751A),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${e.toString().substring(0, min(100, e.toString().length))}',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return; // Stop app initialization
  }

  // Load location permission and banner dismissal state in parallel
  await Future.wait([
    container.read(locationProvider.notifier).checkPermission(),
    container.read(locationProvider.notifier).loadFromPreferences(),
  ]);

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
