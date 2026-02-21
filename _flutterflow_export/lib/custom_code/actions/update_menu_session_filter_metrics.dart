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

Future<void> updateMenuSessionFilterMetrics(int currentResultCount) async {
  /// Updates menu session metrics after a filter change.
  ///
  /// Tracks filter engagement, result counts, and quality metrics to understand
  /// how users interact with filters and whether they're seeing useful results.
  ///
  /// Should be called after any filter toggle that changes the displayed items.
  ///
  /// Args:
  ///   currentResultCount: Number of menu items visible after filter change

  try {
    final sessionData = FFAppState().menuSessionData as Map<String, dynamic>;

    // Mark that filters were used at least once in this session
    sessionData['everHadFiltersActive'] = true;

    // Increment total interaction counter
    final currentInteractions = sessionData['filterInteractions'] as int? ?? 0;
    sessionData['filterInteractions'] = currentInteractions + 1;

    // Track result count in history
    final resultHistory =
        List<int>.from(sessionData['filterResultHistory'] as List? ?? []);
    resultHistory.add(currentResultCount);
    sessionData['filterResultHistory'] = resultHistory;

    // Track zero-result occurrences (problematic UX)
    if (currentResultCount == 0) {
      final currentZeroCount = sessionData['zeroResultCount'] as int? ?? 0;
      sessionData['zeroResultCount'] = currentZeroCount + 1;
    }

    // Track low-result occurrences (1-2 items - suboptimal UX)
    if (currentResultCount > 0 && currentResultCount <= 2) {
      final currentLowCount = sessionData['lowResultCount'] as int? ?? 0;
      sessionData['lowResultCount'] = currentLowCount + 1;
    }

    // Persist updated metrics
    FFAppState().update(() {
      FFAppState().menuSessionData = sessionData;
    });

    // Debug logging
    debugPrint('📊 Filter metrics updated:');
    debugPrint('   Interaction #${sessionData['filterInteractions']}');
    debugPrint('   Current results: $currentResultCount');
    if (currentResultCount == 0) {
      debugPrint('   ⚠️ Zero results detected');
    } else if (currentResultCount <= 2) {
      debugPrint('   ⚠️ Low results detected');
    }
  } catch (e, stackTrace) {
    debugPrint('⚠️ Failed to update filter metrics: $e');
    debugPrint('   Stack trace: $stackTrace');
  }
}
