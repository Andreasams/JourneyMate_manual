import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'provider_state_classes.dart';
import '../services/api_service.dart';

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
  @override
  Map<String, String> build() => {};

  /// Loads translations from BuildShip for a specific language
  Future<void> loadTranslations(String languageCode) async {
    try {
      final response =
          await ApiService.instance.getUiTranslations(languageCode: languageCode);

      if (response.succeeded && response.jsonBody is Map) {
        state = Map<String, String>.from(response.jsonBody);
      } else {
        debugPrint('⚠️ Failed to load translations for $languageCode');
        state = {};
      }
    } catch (e) {
      debugPrint('⚠️ Error loading translations: $e');
      state = {};
    }
  }

  /// Clears all cached translations
  void clear() {
    state = {};
  }
}
