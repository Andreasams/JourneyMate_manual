import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Locale provider - tracks current app locale for instant language switching
///
/// **Purpose:**
/// - Enables immediate app-wide rebuilds when language changes
/// - Pages get `Localizations.localeOf(context)` update instantly
/// - Translations load asynchronously after locale change (progressive enhancement)
///
/// **Usage:**
/// ```dart
/// // Watch locale changes in MaterialApp
/// final locale = ref.watch(localeProvider);
///
/// // Update locale immediately when language changes
/// ref.read(localeProvider.notifier).setLocale('da');
/// ```
///
/// **Flow:**
/// 1. User selects language → `setLocale()` called immediately
/// 2. MaterialApp rebuilds with new locale (instant visual feedback)
/// 3. Translations API call completes → page content updates with real text
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(() {
  return LocaleNotifier();
});

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    // Default to English locale (will be overridden by initialize())
    return const Locale('en');
  }

  /// Initialize locale from SharedPreferences on app startup
  ///
  /// Called in main.dart after provider container is created
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('user_language_code') ?? 'en';
      state = Locale(languageCode);
      debugPrint('✅ Locale initialized: $languageCode');
    } catch (e) {
      debugPrint('⚠️ Failed to load locale from preferences: $e');
      // Keep default 'en' locale
    }
  }

  /// Set locale immediately (triggers app-wide rebuild)
  ///
  /// **IMPORTANT:** Call this BEFORE loading translations for instant visual feedback
  ///
  /// This causes:
  /// - MaterialApp to rebuild with new locale
  /// - All pages to see updated `Localizations.localeOf(context)`
  /// - Immediate language change (even before translations load)
  void setLocale(String languageCode) {
    state = Locale(languageCode);
    debugPrint('🌐 Locale changed: $languageCode');
  }
}
