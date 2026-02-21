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

Future<void> trackFilterReset(int businessId) async {
  /// Tracks when a user resets/clears all menu filters.
  ///
  /// Updates session-level reset counter and sends individual reset event
  /// for understanding filter abandonment patterns and user friction.
  ///
  /// Retrieves the current menu session ID from FFAppState.menuSessionData.
  ///
  /// Args:
  ///   businessId: The ID of the business whose menu is being viewed

  try {
    // Retrieve session data from FFAppState
    final sessionData = FFAppState().menuSessionData as Map<String, dynamic>;

    // Extract menu session ID
    final menuSessionId = sessionData['menuSessionId'] as String?;

    if (menuSessionId == null || menuSessionId.isEmpty) {
      debugPrint('⚠️ Cannot track filter reset - no active menu session');
      return;
    }

    // Update session metrics
    final currentResetCount = sessionData['filterResets'] as int? ?? 0;
    final newResetCount = currentResetCount + 1;

    sessionData['filterResets'] = newResetCount;

    FFAppState().update(() {
      FFAppState().menuSessionData = sessionData;
    });

    // Track individual reset event
    await trackAnalyticsEvent(
      'menu_filters_reset',
      {
        'menu_session_id': menuSessionId,
        'business_id': businessId,
        'reset_number': newResetCount,
        'total_interactions_before_reset':
            sessionData['filterInteractions'] as int? ?? 0,
      },
    );

    // Mark user as engaged (extends engagement window)
    markUserEngaged();

    debugPrint('🔄 Menu filters reset (#$newResetCount)');
  } catch (e, stackTrace) {
    debugPrint('⚠️ Failed to track filter reset: $e');
    debugPrint('   Stack trace: $stackTrace');
  }
}
