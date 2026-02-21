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

Future<void> detectAccessibilitySettings(BuildContext context) async {
  /// Detects system accessibility settings and stores them in FFAppState.
  ///
  /// Args:
  ///   context: BuildContext from the calling widget
  ///
  /// Stores in FFAppState:
  ///   - isBoldTextEnabled: Whether system bold text is enabled
  ///   - textScaleFactor: System text scale multiplier (1.0 = normal)
  ///
  /// Call this once on app start (first page's On Page Load action).

  final mediaQuery = MediaQuery.of(context);

  final isBoldTextEnabled = mediaQuery.boldText;

  FFAppState().update(() {
    FFAppState().isBoldTextEnabled = isBoldTextEnabled;
  });

  debugPrint('♿ Accessibility settings detected:');
  debugPrint('   Bold text: $isBoldTextEnabled');
}
