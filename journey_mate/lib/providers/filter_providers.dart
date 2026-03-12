import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'provider_state_classes.dart';
import '../services/api_service.dart';
import '../theme/app_constants.dart';

// ============================================================
// FILTER PROVIDER (AsyncNotifier pattern for API loading)
// ============================================================

/// Filter provider (Riverpod 3.x AsyncNotifier)
final filterProvider =
    AsyncNotifierProvider<FilterNotifier, FilterState>(() {
  return FilterNotifier();
});

class FilterNotifier extends AsyncNotifier<FilterState> {
  /// Cache duration: 7 days (same as translations)
  static const int _cacheDurationDays = 7;

  /// Cache version — INCREMENT THIS when filter structure changes.
  /// Forces cache refresh for all users on next launch.
  ///
  /// Version history:
  /// - v1: Initial filter caching implementation (Mar 2026)
  static const int _cacheVersion = 1;

  @override
  Future<FilterState> build() async {
    // Return initial state synchronously
    return FilterState.initial();
  }

  /// Synchronously initialize from cached filter data (called at startup).
  /// Sets state to AsyncData with cached filters so consumers never see AsyncLoading.
  void initializeFromPrefs(FilterState cachedFilterState) {
    if (cachedFilterState.filtersForLanguage != null) {
      state = AsyncData(cachedFilterState);
    }
  }

  /// Fetch filters from API and cache to SharedPreferences only.
  /// Does NOT update provider state. Used on first launch to pre-cache
  /// a second language (e.g. English) while provider state holds the primary (Danish).
  Future<void> fetchAndCacheOnly(
    String languageCode, {
    String? cityId,
  }) async {
    try {
      final response = await ApiService.instance.getFiltersForSearch(
        languageCode: languageCode,
        cityId: cityId ?? AppConstants.kDefaultCityId.toString(),
      );

      if (response.succeeded && response.jsonBody != null) {
        final body = response.jsonBody as Map<String, dynamic>;
        final filters = body['filters'];
        final foodDrinkTypes = body['foodDrinkTypes'] ?? [];
        final foodDrinkTypesList = foodDrinkTypes is List ? foodDrinkTypes : <dynamic>[];

        // Cache only — don't set provider state
        await _saveToCache(languageCode, filters, foodDrinkTypesList);
      }
    } catch (e) {
      // Fail silently — this is a background pre-cache
    }
  }

  /// Load filters for a specific language and city from API.
  /// [cityId] defaults to [AppConstants.kDefaultCityId] (Copenhagen).
  /// When a city selector is added, pass the selected city ID here.
  ///
  /// Caching behavior:
  /// - When previous data exists: keeps it visible during refresh (no spinner flash)
  /// - When no data exists: sets AsyncLoading (first load)
  /// - After successful fetch: saves to SharedPreferences for next launch
  Future<void> loadFiltersForLanguage(
    String languageCode, {
    String? cityId,
  }) async {
    // Only show loading state if no data exists yet (first load).
    // When refreshing, keep previous data visible — no spinner flash.
    final hasData = state.when(
      data: (data) => data.filtersForLanguage != null,
      loading: () => false,
      error: (_, _) => false,
    );
    if (!hasData) {
      state = const AsyncLoading();
    }

    try {
      // Call API
      final response = await ApiService.instance.getFiltersForSearch(
        languageCode: languageCode,
        cityId: cityId ?? AppConstants.kDefaultCityId.toString(),
      );

      if (response.succeeded && response.jsonBody != null) {
        final body = response.jsonBody as Map<String, dynamic>;

        // Extract filters hierarchy and foodDrinkTypes
        final filters = body['filters'];
        final foodDrinkTypes = body['foodDrinkTypes'] ?? [];
        final foodDrinkTypesList = foodDrinkTypes is List ? foodDrinkTypes : <dynamic>[];

        // Build lookup map from hierarchy
        final lookupMap = _buildLookupMap(filters);

        // Update state with loaded data
        state = AsyncData(FilterState(
          filtersForLanguage: filters,
          filterLookupMap: lookupMap,
          foodDrinkTypes: foodDrinkTypesList,
        ));

        // Persist to cache for next launch
        _saveToCache(languageCode, filters, foodDrinkTypesList);

      } else {
        // Only set initial state if we don't already have data
        if (!hasData) {
          state = AsyncData(FilterState.initial());
        }
      }
    } catch (e, stackTrace) {
      // Only set error state if we don't already have data.
      // When refreshing, keep previous data visible.
      if (!hasData) {
        state = AsyncError(e, stackTrace);
      }
    }
  }

  /// Build flat lookup map from hierarchical filter structure
  static Map<int, dynamic> _buildLookupMap(dynamic filters) {
    final Map<int, dynamic> lookupMap = {};

    if (filters == null) return lookupMap;

    void traverse(dynamic node) {
      if (node is Map) {
        // Extract filter ID if present
        // API returns 'id' field, not 'filter_id'
        final filterId = node['id'] ?? node['filter_id'];
        if (filterId is int) {
          lookupMap[filterId] = node;
        }

        // Traverse children
        final children = node['children'];
        if (children is List) {
          for (final child in children) {
            traverse(child);
          }
        }
      } else if (node is List) {
        for (final item in node) {
          traverse(item);
        }
      }
    }

    traverse(filters);
    return lookupMap;
  }

  /// Get filter by ID from lookup map
  dynamic getFilterById(int filterId) {
    return state.when(
      data: (data) => data.filterLookupMap[filterId],
      loading: () => null,
      error: (e, _) => null,
    );
  }

  /// Check if filters are loaded
  bool isLoaded() {
    return state.when(
      data: (data) => data.filtersForLanguage != null,
      loading: () => false,
      error: (e, _) => false,
    );
  }

  /// Clear all filter data
  void clear() {
    state = AsyncData(FilterState.initial());
  }

  /// Save filter data to SharedPreferences cache with version metadata.
  /// Called after successful API fetch to persist for next launch.
  Future<void> _saveToCache(
    String languageCode,
    dynamic filters,
    List<dynamic> foodDrinkTypes,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final filtersJson = jsonEncode(filters);
      final foodDrinkTypesJson = jsonEncode(foodDrinkTypes);

      await prefs.setString('filters_$languageCode', filtersJson);
      await prefs.setString('filters_${languageCode}_foodDrinkTypes', foodDrinkTypesJson);
      await prefs.setInt('filters_${languageCode}_timestamp', DateTime.now().millisecondsSinceEpoch);
      await prefs.setInt('filters_${languageCode}_version', _cacheVersion);
    } catch (e) {
      // Non-critical — continue without caching
    }
  }

  /// Remove cached filter data for a specific language.
  /// Called when user picks a language and the other pre-fetched cache is no longer needed.
  static Future<void> clearCacheForLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('filters_$languageCode');
      await prefs.remove('filters_${languageCode}_foodDrinkTypes');
      await prefs.remove('filters_${languageCode}_timestamp');
      await prefs.remove('filters_${languageCode}_version');
    } catch (e) {
      // Fail silently
    }
  }

  /// Load cached filters from SharedPreferences (if available and valid).
  /// Returns FilterState.initial() if cache is missing or version is outdated.
  /// Rebuilds filterLookupMap from deserialized JSON (derived data, not cached).
  static Future<FilterState> loadFromCache(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = prefs.getString('filters_$languageCode');
      final foodDrinkTypesJson = prefs.getString('filters_${languageCode}_foodDrinkTypes');
      final version = prefs.getInt('filters_${languageCode}_version');

      if (filtersJson == null || filtersJson.isEmpty) {
        return FilterState.initial();
      }

      // Cache version mismatch — don't use stale cache
      if (version != _cacheVersion) {
        return FilterState.initial();
      }

      final filters = jsonDecode(filtersJson);
      final foodDrinkTypes = foodDrinkTypesJson != null
          ? (jsonDecode(foodDrinkTypesJson) as List)
          : <dynamic>[];

      // Rebuild lookup map from deserialized data (derived, not cached)
      final lookupMap = _buildLookupMap(filters);

      return FilterState(
        filtersForLanguage: filters,
        filterLookupMap: lookupMap,
        foodDrinkTypes: foodDrinkTypes,
      );
    } catch (e) {
      return FilterState.initial();
    }
  }

  /// Check if cached filters exist and are still valid.
  /// Returns false if no cache, older than 7 days, or version mismatch.
  static Future<bool> isCacheFresh(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt('filters_${languageCode}_timestamp');
      final version = prefs.getInt('filters_${languageCode}_version');

      // No cache exists
      if (timestamp == null) return false;

      // Cache version mismatch
      if (version != _cacheVersion) return false;

      // Check age
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      final cacheDuration = Duration(days: _cacheDurationDays).inMilliseconds;

      return cacheAge < cacheDuration;
    } catch (e) {
      return false;
    }
  }
}
