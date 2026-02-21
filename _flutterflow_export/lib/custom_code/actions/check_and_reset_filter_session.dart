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

Future<void> checkAndResetFilterSession(
  String searchText,
  List<int> activeFilters,
) async {
  /// PURPOSE: Manage filter session lifecycle with refinement tracking
  /// BUSINESS LOGIC: Tracks session start/end/reset, increments refinement sequence
  /// DEPENDENCIES: FFAppState, trackAnalyticsEvent custom action

  // Check if BOTH are now empty after having content (complete reset)
  if (FFAppState().hasActiveSearch &&
      searchText.isEmpty &&
      activeFilters.isEmpty) {
    debugPrint('🔄 Reset detected - ending current session');

    // Track session end before reset
    await trackAnalyticsEvent(
      'filter_session_ended',
      {
        'filterSessionId': FFAppState().currentFilterSessionId,
        'reason': 'user_cleared',
        'totalRefinements': FFAppState().currentRefinementSequence,
        'resultedInClicks':
            false, // Will be updated by business_clicked if applicable
      },
    );

    // Store current session ID before generating new one
    final oldSessionId = FFAppState().currentFilterSessionId;

    // Generate new session ID
    await generateAndStoreFilterSessionId();

    // Track new session start with link to previous
    await trackAnalyticsEvent(
      'filter_session_started',
      {
        'filterSessionId': FFAppState().currentFilterSessionId,
        'previousSessionId': oldSessionId,
      },
    );

    // Reset state
    FFAppState().update(() {
      FFAppState().hasActiveSearch = false;
      FFAppState().previousActiveFilters = [];
      FFAppState().previousSearchText = '';
      FFAppState().currentRefinementSequence = 0;
      FFAppState().lastRefinementTime = null;
      FFAppState().previousFilterSessionId = oldSessionId;
    });

    debugPrint(
        '✅ Reset complete - new session: ${FFAppState().currentFilterSessionId.substring(0, 8)}...');
  } else if (searchText.isNotEmpty || activeFilters.isNotEmpty) {
    // Has content - mark as active and increment refinement

    final wasActive = FFAppState().hasActiveSearch;

    if (!wasActive) {
      // First refinement in new session
      debugPrint('🆕 First refinement in session');

      FFAppState().update(() {
        FFAppState().hasActiveSearch = true;
        FFAppState().currentRefinementSequence = 1;
        FFAppState().lastRefinementTime = DateTime.now();
      });
    } else {
      // Subsequent refinement
      FFAppState().update(() {
        FFAppState().currentRefinementSequence += 1;
        FFAppState().lastRefinementTime = DateTime.now();
      });

      debugPrint('🔄 Refinement #${FFAppState().currentRefinementSequence}');
    }
  } else {
    // Both empty and wasn't active - no-op
    debugPrint('⚪ No active search state');
  }
}
