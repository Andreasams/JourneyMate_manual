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

Future<void> updatePreviousFilterState(
  List<int> currentFilters,
  String? currentSearchText,
) async {
  /// Updates previous state tracking for next refinement comparison
  ///
  /// PURPOSE: Stores current state as previous for next change detection
  /// BUSINESS LOGIC: Updates both filter state AND timestamp for timing calculations
  /// DEPENDENCIES: FFAppState
  /// USAGE: Call AFTER trackAnalyticsEvent('filter_applied', ...)
  ///
  /// CRITICAL: This action now updates lastRefinementTime to enable
  /// timeSincePreviousRefinement calculations in buildFilterAppliedEventData

  FFAppState().update(() {
    // Store filter state
    FFAppState().previousActiveFilters = List<int>.from(currentFilters);
    FFAppState().previousSearchText = currentSearchText ?? '';

    // CRITICAL: Update timestamp for next refinement timing
    FFAppState().lastRefinementTime = DateTime.now();
  });

  debugPrint('📝 Updated previous state: ${currentFilters.length} filters');
  debugPrint(
      '⏰ Updated lastRefinementTime: ${FFAppState().lastRefinementTime}');
}
