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

/// Ends a menu browsing session and tracks comprehensive session metrics.
///
/// **UPDATED FOR UNIFIED FILTERS**: Now reads filter state directly from
/// FFAppState, accounting for the new unified filter widget structure that
/// includes dietary restrictions.
///
/// Captures both browsing behavior (clicks, scrolling) and filter usage
/// patterns (interactions, resets, result quality) from FFAppState.
///
/// Filter state is determined by checking:
/// - selectedDietaryRestrictionId (0 = inactive, >0 = active)
/// - selectedDietaryPreferenceId (0 = inactive, >0 = active)
/// - excludedAllergyIds (empty = inactive, non-empty = active)
///
/// Args:
///   businessId: The ID of the business whose menu was viewed
Future<void> endMenuSession(int businessId) async {
  try {
    // Read accumulated metrics from FFAppState
    final sessionData = FFAppState().menuSessionData as Map<String, dynamic>;

    // Extract menu session ID
    final menuSessionId = sessionData['menuSessionId'] as String?;

    if (menuSessionId == null || menuSessionId.isEmpty) {
      debugPrint('⚠️ Cannot end menu session - no active session ID found');
      return;
    }

    // ========================================================================
    // READ FILTER STATE FROM FFAPPSTATE
    // ========================================================================

    // Check if any filters are currently active
    final hasRestrictionActive =
        FFAppState().selectedDietaryRestrictionId?.isNotEmpty ?? false;
    final hasPreferenceActive =
        (FFAppState().selectedDietaryPreferenceId ?? 0) > 0;
    final hasAllergiesExcluded =
        FFAppState().excludedAllergyIds?.isNotEmpty ?? false;

    final currentlyHasFiltersActive =
        hasRestrictionActive || hasPreferenceActive || hasAllergiesExcluded;

    // ========================================================================
    // EXTRACT BROWSING METRICS
    // ========================================================================

    final itemsClicked = sessionData['itemClicks'] as int? ?? 0;
    final packagesClicked = sessionData['packageClicks'] as int? ?? 0;
    final categoriesViewed =
        (sessionData['categoriesViewed'] as List?)?.length ?? 0;
    final deepestScrollPercent =
        sessionData['deepestScrollPercent'] as int? ?? 0;

    // ========================================================================
    // EXTRACT FILTER ENGAGEMENT METRICS
    // ========================================================================

    final everHadFiltersActive =
        sessionData['everHadFiltersActive'] as bool? ?? false;
    final filterInteractions = sessionData['filterInteractions'] as int? ?? 0;
    final filterResets = sessionData['filterResets'] as int? ?? 0;

    // ========================================================================
    // EXTRACT FILTER RESULT QUALITY METRICS
    // ========================================================================

    final zeroResultCount = sessionData['zeroResultCount'] as int? ?? 0;
    final lowResultCount = sessionData['lowResultCount'] as int? ?? 0;
    final resultHistory = sessionData['filterResultHistory'] as List? ?? [];

    // Calculate aggregate statistics
    final avgResultCount = _calculateAverageResultCount(resultHistory);
    final minResultCount = _calculateMinResultCount(resultHistory);
    final maxResultCount = _calculateMaxResultCount(resultHistory);

    // Calculate filter engagement score (0-100)
    final filterEngagementScore = _calculateFilterEngagementScore(
      interactions: filterInteractions,
      resets: filterResets,
      zeroResults: zeroResultCount,
    );

    // ========================================================================
    // TRACK COMPREHENSIVE SESSION END EVENT
    // ========================================================================

    await trackAnalyticsEvent(
      'menu_session_ended',
      {
        'menu_session_id': menuSessionId,
        'business_id': businessId,

        // Browsing metrics
        'items_clicked': itemsClicked,
        'packages_clicked': packagesClicked,
        'categories_viewed': categoriesViewed,
        'deepest_scroll_percent': deepestScrollPercent,
        'total_interactions': itemsClicked + packagesClicked,

        // Filter usage metrics
        'ever_had_filters_active': everHadFiltersActive,
        'filters_active_at_end': currentlyHasFiltersActive,
        'filter_interactions': filterInteractions,
        'filter_resets': filterResets,
        'filter_engagement_score': filterEngagementScore,

        // Filter result quality metrics
        'zero_result_count': zeroResultCount,
        'low_result_count': lowResultCount,
        'avg_result_count': avgResultCount,
        'min_result_count': minResultCount,
        'max_result_count': maxResultCount,
        'total_filter_changes': resultHistory.length,
      },
    );

    // ========================================================================
    // DEBUG LOGGING
    // ========================================================================

    _logSessionMetrics(
      menuSessionId: menuSessionId,
      itemsClicked: itemsClicked,
      packagesClicked: packagesClicked,
      categoriesViewed: categoriesViewed,
      filterInteractions: filterInteractions,
      filterResets: filterResets,
      zeroResultCount: zeroResultCount,
      lowResultCount: lowResultCount,
      filterEngagementScore: filterEngagementScore,
      currentlyHasFiltersActive: currentlyHasFiltersActive,
    );

    // ========================================================================
    // RESET SESSION DATA FOR NEXT SESSION
    // ========================================================================

    _resetSessionData();
  } catch (e, stackTrace) {
    debugPrint('⚠️ Failed to end menu session: $e');
    debugPrint('   Stack trace: $stackTrace');
  }
}

// =============================================================================
// HELPER FUNCTIONS - RESULT CALCULATIONS
// =============================================================================

/// Calculates the average result count from result history.
///
/// Returns null if result history is empty to indicate no data available.
int? _calculateAverageResultCount(List resultHistory) {
  if (resultHistory.isEmpty) return null;

  final sum = resultHistory.fold<num>(0, (sum, value) => sum + (value as num));
  return (sum / resultHistory.length).round();
}

/// Finds the minimum result count from result history.
///
/// Returns null if result history is empty to indicate no data available.
int? _calculateMinResultCount(List resultHistory) {
  if (resultHistory.isEmpty) return null;

  return resultHistory.fold<num>(
    resultHistory.first as num,
    (min, value) => (value as num) < min ? value : min,
  ) as int;
}

/// Finds the maximum result count from result history.
///
/// Returns null if result history is empty to indicate no data available.
int? _calculateMaxResultCount(List resultHistory) {
  if (resultHistory.isEmpty) return null;

  return resultHistory.fold<num>(
    resultHistory.first as num,
    (max, value) => (value as num) > max ? value : max,
  ) as int;
}

// =============================================================================
// HELPER FUNCTIONS - ENGAGEMENT SCORING
// =============================================================================

/// Calculates a 0-100 engagement score based on filter behavior.
///
/// Scoring logic:
/// - Positive: Each interaction adds 10 points (indicates exploration)
/// - Negative: Each reset subtracts 15 points (indicates frustration)
/// - Negative: Each zero-result subtracts 5 points (indicates poor UX)
///
/// Higher scores indicate successful filter usage, lower scores indicate
/// user friction or overly restrictive filter combinations.
///
/// Args:
///   interactions: Total number of filter toggles
///   resets: Number of times filters were cleared
///   zeroResults: Number of times filters resulted in no items
///
/// Returns:
///   int: Engagement score clamped between 0-100
int _calculateFilterEngagementScore({
  required int interactions,
  required int resets,
  required int zeroResults,
}) {
  // Return 0 if no interactions occurred
  if (interactions == 0) return 0;

  // Weighted scoring formula
  final rawScore = (interactions * 10) - (resets * 15) - (zeroResults * 5);

  // Clamp to valid 0-100 range
  return rawScore.clamp(0, 100);
}

// =============================================================================
// HELPER FUNCTIONS - LOGGING & STATE MANAGEMENT
// =============================================================================

/// Logs session metrics to console for development debugging.
void _logSessionMetrics({
  required String menuSessionId,
  required int itemsClicked,
  required int packagesClicked,
  required int categoriesViewed,
  required int filterInteractions,
  required int filterResets,
  required int zeroResultCount,
  required int lowResultCount,
  required int filterEngagementScore,
  required bool currentlyHasFiltersActive,
}) {
  debugPrint('📋 Menu session ended: $menuSessionId');
  debugPrint('   Items clicked: $itemsClicked');
  debugPrint('   Packages clicked: $packagesClicked');
  debugPrint('   Categories viewed: $categoriesViewed');
  debugPrint('   Filter interactions: $filterInteractions');
  debugPrint('   Filter resets: $filterResets');
  debugPrint('   Zero results: $zeroResultCount times');
  debugPrint('   Low results (1-2): $lowResultCount times');
  debugPrint('   Filter engagement score: $filterEngagementScore/100');
  debugPrint('   Filters active at end: $currentlyHasFiltersActive');
}

/// Resets FFAppState session data for the next session.
void _resetSessionData() {
  FFAppState().update(() {
    FFAppState().menuSessionData = {
      'menuSessionId': '', // Clear session ID
      'itemClicks': 0,
      'packageClicks': 0,
      'categoriesViewed': [],
      'deepestScrollPercent': 0,
      'filterInteractions': 0,
      'filterResets': 0,
      'everHadFiltersActive': false,
      'zeroResultCount': 0,
      'lowResultCount': 0,
      'filterResultHistory': [],
    };
  });
}
