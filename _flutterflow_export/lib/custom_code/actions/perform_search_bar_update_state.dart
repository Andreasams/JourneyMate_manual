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

/// Performs search from search bar and updates app state with results
///
/// This action is specifically designed for search bar interactions (text change
/// and submit events). It mirrors performSearchAndUpdateState but derives filter
/// context from FFAppState rather than accepting filter parameters.
///
/// Key Features:
/// - Uses existing filters from FFAppState.filtersUsedForSearch
/// - Auto-detects train station filters from current filter state
/// - Always tracks analytics with 'searchTrigger' to distinguish onChange vs onSubmit
/// - Updates FFAppState identically to filter-based searches
///
/// Workflow:
/// 1. Retrieves user's current location
/// 2. Gets active filters from FFAppState.filtersUsedForSearch
/// 3. Detects train station filter if present
/// 4. Calls the search API with all parameters
/// 5. Updates FFAppState with search results and timestamps
/// 6. Tracks analytics with search trigger source
/// 7. Returns metadata for page state updates
///
/// Args:
///   searchText: The search query text from search bar
///   searchTrigger: Source of search event ('text_change' or 'submit')
///
/// Returns:
///   JSON object with structure:
///   {
///     "activeFilterIds": [1, 2, 3],
///     "resultCount": 42,
///     "timestamp": "2025-10-23T10:30:00.000Z",
///     "hasTrainStation": true,
///     "trainStationId": 5,
///     "searchTrigger": "text_change"
///   }
Future<dynamic> performSearchBarUpdateState(
  String searchText,
  String searchTrigger,
  String languageCode,
) async {
  const apiBaseUrl = 'https://wvb8ww.buildship.run/search';

  debugPrint('🔍 Starting search bar action');
  debugPrint('   Query: "$searchText"');
  debugPrint('   Trigger: $searchTrigger');

  try {
    // =========================================================================
    // 1. GET USER LOCATION
    // =========================================================================
    final userLocation = await getCurrentUserLocation(
      defaultLocation: LatLng(0.0, 0.0),
    );

    debugPrint('📍 User location: ${userLocation.toString()}');

    // =========================================================================
    // 2. GET CURRENT FILTERS FROM APPSTATE
    // =========================================================================
    final filterIds = List<int>.from(FFAppState().filtersUsedForSearch);

    debugPrint('🔖 Active filters: ${filterIds.length}');

    // =========================================================================
    // 3. DETECT TRAIN STATION FILTER
    // =========================================================================
    final trainStationDetection = _detectTrainStationFilter(filterIds);
    final hasTrainStation = trainStationDetection.$1;
    final trainStationId = trainStationDetection.$2;

    if (hasTrainStation) {
      debugPrint('🚉 Train station detected: ID $trainStationId');
    }

    // =========================================================================
// 4. BUILD QUERY PARAMETERS FOR GET REQUEST
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
    debugPrint('   Query params: $queryParams');

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
// 5. EXTRACT DATA FROM API RESPONSE
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

    final activeFilterIds =
        (responseBody['activeids'] as List?)?.cast<int>().toList() ?? <int>[];

    debugPrint('📊 Search results:');
    debugPrint('   Total items: $resultCount');
    debugPrint('   Active filters: ${activeFilterIds.length}');

    // =========================================================================
    // 6. UPDATE FFAPPSTATE
    // =========================================================================
    FFAppState().update(() {
      FFAppState().searchResults = responseBody;
      FFAppState().searchResultsCount = resultCount;
      FFAppState().currentSearchText = searchText;
      FFAppState().filtersUsedForSearch = List<int>.from(filterIds);
    });

    debugPrint('✅ FFAppState updated with search results');

    // =========================================================================
    // 7. TRACK ANALYTICS (ALWAYS - with searchTrigger included)
    // =========================================================================
    debugPrint('📈 Tracking search bar analytics...');

    try {
      // Check if we need to reset the filter session
      await checkAndResetFilterSession(searchText, filterIds);

      // Build analytics event data
      final analyticsEventData = buildFilterAppliedEventData(
        FFAppState().currentFilterSessionId,
        filterIds,
        searchText,
        FFAppState().searchResults,
        false, // filterOverlayWasOpen - always false for search bar
        FFAppState().previousActiveFilters,
        FFAppState().previousSearchText,
        FFAppState().currentRefinementSequence,
        FFAppState().lastRefinementTime,
      );

      // ADD SEARCH TRIGGER TO EVENT DATA
      analyticsEventData['searchTrigger'] = searchTrigger;

      // Send analytics event
      await trackAnalyticsEvent('filter_applied', analyticsEventData);

      // Update previous state for next comparison
      await updatePreviousFilterState(filterIds, searchText);

      // Update timestamp for next refinement timing
      FFAppState().update(() {
        FFAppState().lastRefinementTime = DateTime.now();
      });

      debugPrint('✅ Analytics tracked with trigger: $searchTrigger');
    } catch (analyticsError) {
      // Don't fail the entire action if analytics fails
      debugPrint('⚠️ Analytics tracking failed: $analyticsError');
    }

    // =========================================================================
    // 8. RETURN METADATA FOR PAGE STATE
    // =========================================================================
    final resultMetadata = {
      'activeFilterIds': activeFilterIds,
      'resultCount': resultCount,
      'timestamp': DateTime.now().toIso8601String(),
      'hasTrainStation': hasTrainStation,
      'trainStationId': trainStationId,
      'searchTrigger': searchTrigger,
    };

    debugPrint('✅ Search bar action completed successfully');
    return resultMetadata;
  } catch (error, stackTrace) {
    debugPrint('❌ Error in performSearchBarUpdateState:');
    debugPrint('   Error: $error');
    debugPrint('   Stack trace: $stackTrace');

    return {
      'activeFilterIds': <int>[],
      'resultCount': 0,
      'timestamp': DateTime.now().toIso8601String(),
      'hasTrainStation': false,
      'trainStationId': null,
      'searchTrigger': searchTrigger,
      'error': error.toString(),
    };
  }
}

/// Helper function to detect train station filter from filter list
///
/// Scans the provided filter IDs using FFAppState.filterLookupMap to determine
/// if a train station filter is present. Train stations are identified by having
/// parent_id = 7 (train station category ID).
///
/// This enables distance-based sorting when a train station filter is active,
/// ensuring search results are ordered by proximity to the selected station.
///
/// Args:
///   filterIds: List of active filter IDs to scan
///
/// Returns:
///   Tuple of (hasTrainStation, trainStationId)
///   - hasTrainStation: true if train station filter found
///   - trainStationId: the ID of the train station filter, or null if none
(bool, int?) _detectTrainStationFilter(List<int> filterIds) {
  const trainStationCategoryId = 7;

  // Access the filter lookup map from FFAppState
  final lookupMap = FFAppState().filterLookupMap;

  // If lookup map is empty/null, return no train station
  if (lookupMap == null || lookupMap is! Map) {
    debugPrint(
        '⚠️ filterLookupMap not available - train station detection skipped');
    return (false, null);
  }

  // Scan filter IDs for train station category
  for (int filterId in filterIds) {
    final filter = lookupMap[filterId];

    // Check if this filter has train station category as parent
    if (filter != null &&
        filter is Map &&
        filter['parent_id'] == trainStationCategoryId) {
      debugPrint('🚉 Detected train station filter: $filterId');
      return (true, filterId);
    }
  }

  // No train station filter found
  return (false, null);
}
