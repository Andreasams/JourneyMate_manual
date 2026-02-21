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

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Performs search and updates app state with results
///
/// This action coordinates the search workflow:
/// 1. Retrieves user's current location
/// 2. Calls the search API with filters and location
/// 3. Updates FFAppState with search results and timestamps
/// 4. Optionally tracks analytics with proper timing data
/// 5. Returns metadata for page state updates
///
/// Args:
///   searchText: The search query text
///   filterIds: List of selected filter IDs
///   hasTrainStation: Whether train station filter is active
///   trainStationId: ID of selected train station (null if none)
///   shouldTrackAnalytics: Whether to log this search in analytics
///   filterOverlayWasOpen: Whether filter overlay was open (for analytics)
///
/// Returns:
///   JSON object with structure:
///   {
///     "activeFilterIds": [1, 2, 3],
///     "resultCount": 42,
///     "timestamp": "2025-10-23T10:30:00.000Z",
///     "hasTrainStation": true,
///     "trainStationId": 5
///   }
Future<dynamic> performSearchAndUpdateState(
  String searchText,
  List<int> filterIds,
  bool hasTrainStation,
  int? trainStationId,
  bool shouldTrackAnalytics,
  bool filterOverlayWasOpen,
  String languageCode,
) async {
  const apiBaseUrl = 'https://wvb8ww.buildship.run/search';

  debugPrint('🔍 Starting search action');
  debugPrint('   Query: "$searchText"');
  debugPrint('   Filters: ${filterIds.length} active');
  debugPrint('   Track analytics: $shouldTrackAnalytics');

  try {
    // =========================================================================
    // 1. GET USER LOCATION
    // =========================================================================
    final userLocation = await getCurrentUserLocation(
      defaultLocation: LatLng(0.0, 0.0),
    );

    debugPrint('📍 User location: ${userLocation.toString()}');

// =========================================================================
// 2. BUILD QUERY PARAMETERS FOR GET REQUEST
// =========================================================================
    final queryParams = {
      'city_id': FFAppState().CityID.toString(),
      'search_input': searchText,
      'filters': json.encode(filterIds),
      'userLocation': userLocation.toString(),
      'hasTrainStationFilter': hasTrainStation.toString(),
      'trainStationFilterId': trainStationId?.toString() ?? '',
      'language': languageCode,
    };

    final uri = Uri.parse(apiBaseUrl).replace(queryParameters: queryParams);

    debugPrint('📤 Sending GET request to: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    );

    // Validate API response
    if (response.statusCode != 200) {
      debugPrint('❌ Search API failed: ${response.statusCode}');
      debugPrint('   Response: ${response.body}');
      throw Exception('Search failed with status ${response.statusCode}');
    }

    debugPrint('✅ Search API successful');

    // =========================================================================
// 3. EXTRACT DATA FROM API RESPONSE
// =========================================================================
    final responseBody = json.decode(response.body) as Map<String, dynamic>;

// ROBUST EXTRACTION: Check multiple possible locations
    int resultCount = 0;

// Try direct field first
    if (responseBody.containsKey('resultCount')) {
      resultCount = responseBody['resultCount'] as int? ?? 0;
    }

// Fallback to document count
    if (resultCount == 0 && responseBody.containsKey('documents')) {
      final docs = responseBody['documents'] as List?;
      resultCount = docs?.length ?? 0;
    }

// Safely extract active filter IDs as primitive List<int>
    final activeFilterIds = <int>[];
    final rawActiveIds = responseBody['activeids'];
    if (rawActiveIds is List) {
      for (final item in rawActiveIds) {
        if (item is int) {
          activeFilterIds.add(item);
        }
      }
    }

    debugPrint('📊 Search results:');
    debugPrint('   Total items: $resultCount');
    debugPrint('   Active filters: ${activeFilterIds.length}');

    // =========================================================================
    // 4. UPDATE FFAPPSTATE
    // =========================================================================
    FFAppState().update(() {
      // Store complete API response (includes documents, counts, metadata)
      FFAppState().searchResults = responseBody;

      // Store commonly accessed values for convenience
      FFAppState().searchResultsCount = resultCount;
      FFAppState().currentSearchText = searchText;
      FFAppState().filtersUsedForSearch = List<int>.from(filterIds);
    });

    debugPrint('✅ FFAppState updated with search results');

    // =========================================================================
    // 5. TRACK ANALYTICS (IF ENABLED)
    // =========================================================================
    if (shouldTrackAnalytics) {
      debugPrint('📈 Tracking search analytics...');

      try {
        // Check if we need to reset the filter session
        await checkAndResetFilterSession(searchText, filterIds);

        // Build analytics event data (uses lastRefinementTime from FFAppState)
        final analyticsEventData = buildFilterAppliedEventData(
          FFAppState().currentFilterSessionId,
          filterIds,
          searchText,
          FFAppState().searchResults,
          filterOverlayWasOpen,
          FFAppState().previousActiveFilters,
          FFAppState().previousSearchText,
          FFAppState().currentRefinementSequence,
          FFAppState()
              .lastRefinementTime, // This is used for timing calculations
        );

        // Send analytics event
        await trackAnalyticsEvent('filter_applied', analyticsEventData);

        // Update previous state for next comparison
        await updatePreviousFilterState(filterIds, searchText);

        // CRITICAL: Update timestamp for next refinement timing
        FFAppState().update(() {
          FFAppState().lastRefinementTime = DateTime.now();
        });

        debugPrint('✅ Analytics tracked successfully with timestamp');
      } catch (analyticsError) {
        // Don't fail the entire action if analytics fails
        debugPrint('⚠️ Analytics tracking failed: $analyticsError');
      }
    } else {
      debugPrint('⏭️  Skipping analytics tracking');
    }

    // =========================================================================
    // 6. RETURN METADATA FOR PAGE STATE
    // =========================================================================
    final resultMetadata = {
      'activeFilterIds': activeFilterIds,
      'resultCount': resultCount,
      'timestamp': DateTime.now().toIso8601String(),
      'hasTrainStation': hasTrainStation,
      'trainStationId': trainStationId,
    };

    debugPrint('✅ Search action completed successfully');
    return resultMetadata;
  } catch (error, stackTrace) {
    debugPrint('❌ Error in performSearchAndUpdateState:');
    debugPrint('   Error: $error');
    debugPrint('   Stack trace: $stackTrace');

    // Return empty result on error
    return {
      'activeFilterIds': <int>[],
      'resultCount': 0,
      'timestamp': DateTime.now().toIso8601String(),
      'hasTrainStation': false,
      'trainStationId': null,
      'error': error.toString(),
    };
  }
}
