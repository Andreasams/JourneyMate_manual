// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/// Retrieves filter data with intelligent caching and background updates.
///
/// This action implements a sophisticated caching strategy that: - Returns
/// cached data immediately for instant UI response - Automatically refreshes
/// stale cache in the background - Handles network failures gracefully with
/// cached fallback - Uses a 4-hour staleness threshold for optimal freshness
/// - Auto-updates FFAppState.filtersForUserLanguage - Builds filter lookup
/// map for O(1) filter metadata access
///
/// Cache Strategy: 1. If cache exists: Return immediately, trigger background
/// update if stale 2. If no cache: Fetch from network and cache the result 3.
/// If network fails: Return cached data or empty list
///
/// Args: languageCode: ISO 639-1 language code for localized filters
///
/// Returns: bool: true if filters were successfully loaded, false on error
///
/// Side Effects: - Updates FFAppState().filtersForUserLanguage (full response
/// including filters and foodDrinkTypes) - Updates
/// FFAppState().filterLookupMap (for train station detection, etc.) - Caches
/// filters in SharedPreferences
Future<bool> getFiltersWithUpdate(String languageCode) async {
  const staleCacheThresholdMs = 14400000; // 4 hours in milliseconds
  const apiBaseUrl = 'https://wvb8ww.buildship.run/filters';

  if (languageCode.isEmpty) {
    debugPrint('getFiltersWithUpdate: Empty language code provided');
    FFAppState().update(() {
      FFAppState().filtersForUserLanguage = {};
      FFAppState().filterLookupMap = {};
    });
    return false;
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final cacheKeys = _getCacheKeys(languageCode);

    final cachedData = _getCachedFilters(prefs, cacheKeys.data);
    if (cachedData != null) {
      debugPrint('Returning cached filters for $languageCode');

      if (_isCacheStale(
          prefs, cacheKeys.timestamp, now, staleCacheThresholdMs)) {
        debugPrint(
            'Cache is stale. Initiating background update for $languageCode');
        _updateFiltersInBackground(prefs, now, languageCode, apiBaseUrl);
      }

      return true;
    }

    debugPrint(
        'No cache found. Fetching filters from network for $languageCode');
    return await _fetchAndCacheFilters(prefs, now, languageCode, apiBaseUrl);
  } catch (e) {
    debugPrint('Error in getFiltersWithUpdate: $e');
    FFAppState().update(() {
      FFAppState().filtersForUserLanguage = {};
      FFAppState().filterLookupMap = {};
    });
    return false;
  }
}

// ============================================================================
// CACHE MANAGEMENT
// ============================================================================

/// Generates cache keys for a given language code
({String data, String timestamp}) _getCacheKeys(String languageCode) {
  return (
    data: 'cached_filters_$languageCode',
    timestamp: 'last_filter_update_$languageCode',
  );
}

/// Retrieves and parses cached filter data
///
/// Returns the full response object or null if cache doesn't exist or is invalid
/// Auto-updates FFAppState.filtersForUserLanguage and filterLookupMap when cache is found
dynamic _getCachedFilters(SharedPreferences prefs, String cacheKey) {
  final cachedData = prefs.getString(cacheKey);
  if (cachedData == null) return null;

  try {
    final cachedJson = json.decode(cachedData);
    final filters = cachedJson['filters'] ?? [];

    final lookupMap = _buildFilterLookupMap(filters);

    FFAppState().update(() {
      FFAppState().filtersForUserLanguage = cachedJson;
      FFAppState().filterLookupMap = lookupMap;
    });

    debugPrint(
        'Loaded cached filters with ${lookupMap.length} entries in lookup map');
    debugPrint(
        'Response contains ${(cachedJson['foodDrinkTypes'] as List?)?.length ?? 0} food/drink types');

    return cachedJson;
  } catch (e) {
    debugPrint('Error parsing cached filters: $e');
    return null;
  }
}

/// Checks if cached data is stale and needs refresh
bool _isCacheStale(
  SharedPreferences prefs,
  String timestampKey,
  int currentTimeMs,
  int thresholdMs,
) {
  final lastUpdate = prefs.getInt(timestampKey) ?? 0;
  return (currentTimeMs - lastUpdate) > thresholdMs;
}

// ============================================================================
// NETWORK OPERATIONS
// ============================================================================

/// Fetches filters from the API and caches the result
///
/// Returns true on success, false on error
/// Auto-updates FFAppState.filtersForUserLanguage and filterLookupMap on success
Future<bool> _fetchAndCacheFilters(
  SharedPreferences prefs,
  int timestamp,
  String languageCode,
  String baseUrl,
) async {
  try {
    final url = Uri.parse('$baseUrl?languageCode=$languageCode');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      debugPrint('Failed to fetch filters. Status: ${response.statusCode}');
      FFAppState().update(() {
        FFAppState().filtersForUserLanguage = {};
        FFAppState().filterLookupMap = {};
      });
      return false;
    }

    final cacheKeys = _getCacheKeys(languageCode);
    await prefs.setString(cacheKeys.data, response.body);
    await prefs.setInt(cacheKeys.timestamp, timestamp);

    final responseJson = json.decode(response.body);
    final filters = responseJson['filters'] ?? [];

    final lookupMap = _buildFilterLookupMap(filters);

    FFAppState().update(() {
      FFAppState().filtersForUserLanguage = responseJson;
      FFAppState().filterLookupMap = lookupMap;
    });

    debugPrint('Successfully fetched and cached filters for $languageCode');
    debugPrint('Built lookup map with ${lookupMap.length} entries');
    debugPrint(
        'Response contains ${(responseJson['foodDrinkTypes'] as List?)?.length ?? 0} food/drink types');
    return true;
  } catch (e) {
    debugPrint('Error fetching filters: $e');
    FFAppState().update(() {
      FFAppState().filtersForUserLanguage = {};
      FFAppState().filterLookupMap = {};
    });
    return false;
  }
}

/// Updates filters in the background without blocking the UI
///
/// This function is fire-and-forget - it doesn't return a value
/// and any errors are logged but don't affect the user experience
/// Auto-updates FFAppState.filtersForUserLanguage and filterLookupMap on success
Future<void> _updateFiltersInBackground(
  SharedPreferences prefs,
  int timestamp,
  String languageCode,
  String baseUrl,
) async {
  try {
    final url = Uri.parse('$baseUrl?languageCode=$languageCode');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final cacheKeys = _getCacheKeys(languageCode);
      await prefs.setString(cacheKeys.data, response.body);
      await prefs.setInt(cacheKeys.timestamp, timestamp);

      final responseJson = json.decode(response.body);
      final filters = responseJson['filters'] ?? [];

      final lookupMap = _buildFilterLookupMap(filters);

      FFAppState().update(() {
        FFAppState().filtersForUserLanguage = responseJson;
        FFAppState().filterLookupMap = lookupMap;
      });

      debugPrint('Background update successful for $languageCode');
      debugPrint('Updated lookup map with ${lookupMap.length} entries');
      debugPrint(
          'Response contains ${(responseJson['foodDrinkTypes'] as List?)?.length ?? 0} food/drink types');
    } else {
      debugPrint('Background update failed. Status: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Background update failed with exception: $e');
  }
}

// ============================================================================
// FILTER LOOKUP MAP BUILDER
// ============================================================================

/// Builds a flat lookup map from nested filter structure for O(1) access
///
/// This enables instant filter metadata lookups without traversing the tree.
/// Essential for train station detection, filter validation, and other
/// operations that need quick access to filter properties.
///
/// The map structure is:
/// ```dart
/// {
///   filterId: {
///     'id': 123,
///     'name': 'Filter Name',
///     'parent_id': 456,
///     'type': 'item',
///     // ... all other filter properties
///   }
/// }
/// ```
///
/// Args:
///   filterData: The nested filter structure (list or single object)
///
/// Returns:
///   Map<int, dynamic> indexed by filter ID for O(1) lookup
///
/// Performance:
///   - Time: O(n) where n is total number of filters
///   - Space: O(n) - one entry per filter
///   - Lookup: O(1) after building
Map<int, dynamic> _buildFilterLookupMap(dynamic filterData) {
  final map = <int, dynamic>{};

  void traverse(dynamic node) {
    if (node is! Map || node['id'] is! int) {
      return;
    }

    final filterId = node['id'] as int;
    map[filterId] = node;

    final children = node['children'];
    if (children is List && children.isNotEmpty) {
      for (final child in children) {
        traverse(child);
      }
    }
  }

  if (filterData is List) {
    for (final item in filterData) {
      traverse(item);
    }
  } else {
    traverse(filterData);
  }

  return map;
}
