import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'provider_state_classes.dart';
import '../services/api_service.dart';
import '../constants/welcome_fallback_translations.dart';

// ============================================================
// ACCESSIBILITY PROVIDER
// ============================================================

/// Accessibility provider (Riverpod 3.x)
final accessibilityProvider =
    NotifierProvider<AccessibilityNotifier, AccessibilityState>(() {
  return AccessibilityNotifier();
});

class AccessibilityNotifier extends Notifier<AccessibilityState> {
  @override
  AccessibilityState build() {
    return AccessibilityState.initial();
  }

  /// Synchronous initialization from pre-read SharedPreferences values
  void initializeFromPrefs({required bool isBoldTextEnabled, required double fontScale}) {
    state = AccessibilityState(isBoldTextEnabled: isBoldTextEnabled, fontScale: fontScale);
  }

  /// Load accessibility settings from preferences
  Future<void> loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isBold = prefs.getBool('is_bold_text_enabled') ?? false;
      final scale = prefs.getDouble('font_scale') ?? 1.0;

      state = AccessibilityState(isBoldTextEnabled: isBold, fontScale: scale);
    } catch (e) {
      debugPrint('⚠️ Failed to load accessibility preferences: $e');
      // Fail silently, keep default state
    }
  }

  /// Set bold text preference
  Future<void> setBoldText(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_bold_text_enabled', enabled);
      state = state.copyWith(isBoldTextEnabled: enabled);
    } catch (e) {
      debugPrint('⚠️ Failed to save bold text preference: $e');
    }
  }

  /// Set font scale preference
  Future<void> setFontScale(double scale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('font_scale', scale);
      state = state.copyWith(fontScale: scale);
    } catch (e) {
      debugPrint('⚠️ Failed to save font scale preference: $e');
    }
  }
}

// ============================================================
// ANALYTICS PROVIDER
// ============================================================

/// Analytics provider (Riverpod 3.x)
final analyticsProvider =
    NotifierProvider<AnalyticsNotifier, AnalyticsState>(() {
  return AnalyticsNotifier();
});

class AnalyticsNotifier extends Notifier<AnalyticsState> {
  @override
  AnalyticsState build() {
    return AnalyticsState.initial();
  }

  /// Synchronous initialization from pre-read device ID
  void initializeFromPrefs({required String deviceId}) {
    state = state.copyWith(deviceId: deviceId);
  }

  /// Initialize analytics (load or create device ID)
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString('device_id');

      if (deviceId == null) {
        deviceId = const Uuid().v4();
        await prefs.setString('device_id', deviceId);
      }

      state = state.copyWith(deviceId: deviceId);
    } catch (e) {
      debugPrint('⚠️ Failed to initialize analytics: $e');
    }
  }

  /// Start a new session
  void startSession() {
    final sessionId = const Uuid().v4();
    final sessionStartTime = DateTime.now();

    state = state.copyWith(
      sessionId: sessionId,
      sessionStartTime: sessionStartTime,
    );
  }

  /// End the current session
  void endSession() {
    state = state.copyWithNullable(
      clearSession: true,
      clearMenuSession: true,
    );
  }

  // ============================================================
  // MENU SESSION TRACKING (11 fields)
  // ============================================================

  /// Start a new menu session
  void startMenuSession(int businessId) {
    final sessionId = const Uuid().v4();
    state = state.copyWith(
      menuSessionData: MenuSessionData.initial(sessionId),
    );
  }

  /// End the menu session and send analytics
  /// Note: Actual analytics sending is handled by AnalyticsService
  void endMenuSession(int businessId) {
    state = state.copyWithNullable(clearMenuSession: true);
  }

  /// Increment item click count
  void incrementItemClick() {
    final currentData = state.menuSessionData;
    if (currentData == null) return;

    state = state.copyWith(
      menuSessionData: currentData.copyWith(
        itemClicks: currentData.itemClicks + 1,
      ),
    );
  }

  /// Increment package click count
  void incrementPackageClick() {
    final currentData = state.menuSessionData;
    if (currentData == null) return;

    state = state.copyWith(
      menuSessionData: currentData.copyWith(
        packageClicks: currentData.packageClicks + 1,
      ),
    );
  }

  /// Record a category as viewed (de-duped)
  void recordCategoryViewed(int categoryId) {
    final currentData = state.menuSessionData;
    if (currentData == null) return;

    if (!currentData.categoriesViewed.contains(categoryId)) {
      state = state.copyWith(
        menuSessionData: currentData.copyWith(
          categoriesViewed: [...currentData.categoriesViewed, categoryId],
        ),
      );
    }
  }

  /// Update deepest scroll percentage if new value is higher
  void updateDeepestScroll(int percent) {
    final currentData = state.menuSessionData;
    if (currentData == null) return;

    if (percent > currentData.deepestScrollPercent) {
      state = state.copyWith(
        menuSessionData: currentData.copyWith(
          deepestScrollPercent: percent,
        ),
      );
    }
  }

  /// Increment filter reset count
  void incrementFilterReset() {
    final currentData = state.menuSessionData;
    if (currentData == null) return;

    state = state.copyWith(
      menuSessionData: currentData.copyWith(
        filterResets: currentData.filterResets + 1,
      ),
    );
  }

  /// Update filter metrics after a filter change
  ///
  /// [currentResultCount] - Number of results after filter change
  /// [hasActiveFilters] - Whether any filters are currently active
  void updateMenuSessionFilterMetrics(int currentResultCount, bool hasActiveFilters) {
    final currentData = state.menuSessionData;
    if (currentData == null) return;

    // Increment filter interactions
    final newInteractions = currentData.filterInteractions + 1;

    // Track if any filter has ever been active
    final everHadActive = currentData.everHadFiltersActive || hasActiveFilters;

    // Track zero and low result counts
    int newZeroCount = currentData.zeroResultCount;
    int newLowCount = currentData.lowResultCount;

    if (currentResultCount == 0) {
      newZeroCount++;
    } else if (currentResultCount >= 1 && currentResultCount <= 2) {
      newLowCount++;
    }

    // Append to result history
    final newHistory = [...currentData.filterResultHistory, currentResultCount];

    state = state.copyWith(
      menuSessionData: currentData.copyWith(
        filterInteractions: newInteractions,
        everHadFiltersActive: everHadActive,
        zeroResultCount: newZeroCount,
        lowResultCount: newLowCount,
        filterResultHistory: newHistory,
      ),
    );
  }
}

// ============================================================
// TRANSLATIONS CACHE PROVIDER
// ============================================================

/// Translations cache provider (moved from translation_service.dart)
final translationsCacheProvider =
    NotifierProvider<TranslationsCacheNotifier, Map<String, String>>(() {
  return TranslationsCacheNotifier();
});

class TranslationsCacheNotifier extends Notifier<Map<String, String>> {
  /// Cache duration: 7 days
  static const int _cacheDurationDays = 7;

  /// Cache version — INCREMENT THIS when adding new translation keys or features
  /// This forces cache refresh for all users on next launch.
  ///
  /// Version history:
  /// - v1: Initial caching implementation (Feb 2025)
  ///
  /// **When to increment:**
  /// - Adding new features with new translation keys
  /// - Fixing translation errors that affect UX
  /// - Major app updates that change translation structure
  static const int _cacheVersion = 1;

  @override
  Map<String, String> build() => {};

  /// Synchronously initialize from cached translations (called at startup)
  /// Falls back to welcome page translations on first launch
  void initializeFromPrefs(Map<String, String> cachedTranslations, String languageCode) {
    if (cachedTranslations.isEmpty) {
      // First launch — use welcome page fallbacks for instant display
      final fallbacks = kWelcomeFallbackTranslations[languageCode] ?? {};
      state = fallbacks;
      debugPrint('🎯 Using welcome fallbacks for first launch ($languageCode)');
    } else {
      state = cachedTranslations;
    }
  }

  /// Loads translations from BuildShip for a specific language
  /// Saves to SharedPreferences cache after successful fetch
  Future<void> loadTranslations(String languageCode) async {
    try {
      final response =
          await ApiService.instance.getUiTranslations(languageCode: languageCode);

      if (response.succeeded && response.jsonBody is Map) {
        final translations = Map<String, String>.from(response.jsonBody);
        state = translations;

        // Save to cache for next launch (with version metadata)
        _saveToCache(languageCode, translations);

        debugPrint('✅ Loaded ${translations.length} translations for $languageCode');
      } else {
        debugPrint('⚠️ Failed to load translations for $languageCode');
        // Keep current state (fallbacks or cached translations)
      }
    } catch (e) {
      debugPrint('⚠️ Error loading translations: $e');
      // Keep current state (fallbacks or cached translations)
    }
  }

  /// Save translations to SharedPreferences cache with version metadata
  Future<void> _saveToCache(String languageCode, Map<String, String> translations) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert map to JSON string using dart:convert
      final jsonString = jsonEncode(translations);

      await prefs.setString('translations_$languageCode', jsonString);
      await prefs.setInt('translations_${languageCode}_timestamp', DateTime.now().millisecondsSinceEpoch);
      await prefs.setInt('translations_${languageCode}_version', _cacheVersion);

      debugPrint('✅ Cached ${translations.length} translations for $languageCode (v$_cacheVersion)');
    } catch (e) {
      debugPrint('⚠️ Failed to cache translations: $e');
      // Non-critical error - continue without caching
    }
  }

  /// Check if cached translations exist and are valid
  /// Returns false if:
  /// - No cache exists
  /// - Cache is older than 7 days
  /// - Cache version is outdated (forces refresh when app adds new features)
  static Future<bool> isCacheFresh(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt('translations_${languageCode}_timestamp');
      final version = prefs.getInt('translations_${languageCode}_version');

      // No cache exists
      if (timestamp == null) return false;

      // Cache version mismatch — new features added, force refresh
      if (version != _cacheVersion) {
        debugPrint('🔄 Cache version mismatch (cached: $version, current: $_cacheVersion) — forcing refresh');
        return false;
      }

      // Check age
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      final cacheDuration = Duration(days: _cacheDurationDays).inMilliseconds;

      return cacheAge < cacheDuration;
    } catch (e) {
      return false;
    }
  }

  /// Load cached translations from SharedPreferences (if available and valid)
  /// Returns empty map if cache is missing or version is outdated
  static Future<Map<String, String>> loadFromCache(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString('translations_$languageCode');
      final version = prefs.getInt('translations_${languageCode}_version');

      if (cachedJson == null || cachedJson.isEmpty) {
        return {};
      }

      // Cache version mismatch — don't use stale cache
      if (version != _cacheVersion) {
        debugPrint('🗑️ Ignoring stale cache (v$version, current: v$_cacheVersion)');
        return {};
      }

      // Parse JSON using dart:convert
      final decoded = jsonDecode(cachedJson);
      final translations = Map<String, String>.from(decoded as Map);

      debugPrint('✅ Loaded ${translations.length} cached translations for $languageCode (v$version)');
      return translations;
    } catch (e) {
      debugPrint('⚠️ Failed to load cached translations: $e');
      return {};
    }
  }

  /// Clear cached translations for a specific language (debug/admin use)
  static Future<void> clearCacheForLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('translations_$languageCode');
      await prefs.remove('translations_${languageCode}_timestamp');
      await prefs.remove('translations_${languageCode}_version');
      debugPrint('🗑️ Cleared translation cache for $languageCode');
    } catch (e) {
      debugPrint('⚠️ Failed to clear cache for $languageCode: $e');
    }
  }

  /// Clear all cached translations across all languages (debug/admin use)
  static Future<void> clearAllCaches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languages = ['en', 'da', 'de', 'fr', 'it', 'no', 'sv'];

      for (final lang in languages) {
        await prefs.remove('translations_$lang');
        await prefs.remove('translations_${lang}_timestamp');
        await prefs.remove('translations_${lang}_version');
      }

      debugPrint('🗑️ Cleared all translation caches');
    } catch (e) {
      debugPrint('⚠️ Failed to clear all caches: $e');
    }
  }

  /// Clear in-memory state (current translations)
  void clear() {
    state = {};
  }
}
