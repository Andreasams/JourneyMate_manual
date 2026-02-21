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

import 'package:uuid/uuid.dart';

Future<String> startMenuSession(int businessId) async {
  /// Starts a menu browsing session and tracks the session start event.
  ///
  /// Initializes session metrics including both browsing and filter engagement
  /// tracking. Stores the unique session ID in FFAppState for later retrieval.
  /// Returns the session ID for immediate use if needed.
  ///
  /// Args:
  ///   businessId: The ID of the business whose menu is being viewed
  ///
  /// Returns:
  ///   String: Unique menu session ID (UUID v4 format)

  try {
    // Generate unique session ID
    final menuSessionId = const Uuid().v4();

    // Initialize comprehensive session data in FFAppState
    FFAppState().update(() {
      FFAppState().menuSessionData = {
        // Session identification
        'menuSessionId': menuSessionId,

        // Browsing metrics
        'itemClicks': 0,
        'packageClicks': 0,
        'categoriesViewed': [],
        'deepestScrollPercent': 0,

        // Filter engagement tracking
        'filterInteractions': 0, // Total filter toggles across all filter types
        'filterResets': 0, // Times "Clear All" was pressed
        'everHadFiltersActive': false, // Was any filter ever used in session?

        // Filter result quality metrics
        'zeroResultCount': 0, // Times filters resulted in 0 items
        'lowResultCount': 0, // Times filters resulted in 1-2 items
        'filterResultHistory': [], // List of result counts after each change
      };
    });

    // Track session start event
    await trackAnalyticsEvent(
      'menu_session_started',
      {
        'menu_session_id': menuSessionId,
        'business_id': businessId,
      },
    );

    debugPrint('📋 Menu session started: $menuSessionId');
    debugPrint('   Business ID: $businessId');

    return menuSessionId;
  } catch (e, stackTrace) {
    debugPrint('⚠️ Failed to start menu session: $e');
    debugPrint('   Stack trace: $stackTrace');

    // Return error session ID as fallback to maintain app flow
    return 'error-${DateTime.now().millisecondsSinceEpoch}';
  }
}
