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

import 'package:uuid/uuid.dart';

/// Generates a new filter session ID and stores it in app state.
///
/// This action creates a unique UUID v4 identifier and immediately saves it
/// to FFAppState.currentFilterSessionId. Use this when starting a new filter
/// session to ensure proper tracking throughout the filter flow.
///
/// Returns: The newly generated session ID string
Future<String> generateAndStoreFilterSessionId() async {
  // Generate unique session ID
  final newSessionId = const Uuid().v4();

  // Store in app state
  FFAppState().update(() {
    FFAppState().currentFilterSessionId = newSessionId;
  });

  debugPrint('✅ Generated new filter session ID: $newSessionId');

  return newSessionId;
}
