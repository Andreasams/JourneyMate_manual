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

import 'package:shared_preferences/shared_preferences.dart';

/// Saves a user preference to persistent local storage.
///
/// This action provides a flexible key-value storage mechanism for user
/// preferences such as language choice, currency selection, theme settings,
/// or any other app configuration that should persist across sessions.
///
/// The data is stored locally on the device using SharedPreferences and
/// is not synchronized across devices. For cross-device sync, use Supabase
/// user preferences instead.
///
/// Special Behavior:
/// - When key = 'user_currency_code': Also updates FFAppState().userCurrencyCode
///
/// Common use cases:
/// - Language selection: saveUserPreference('user_language_code', 'da')
/// - Currency choice: saveUserPreference('user_currency_code', 'DKK')
/// - Theme mode: saveUserPreference('theme_mode', 'dark')
/// - Last selected filter: saveUserPreference('last_filter_id', '123')
///
/// Args:
///   key: Unique identifier for the preference (use snake_case convention)
///   value: String value to store (convert non-strings before passing)
///
/// Returns:
///   Future that completes when save operation finishes
///
/// Side Effects:
///   - If key = 'user_currency_code': Updates FFAppState().userCurrencyCode
///
/// Throws:
///   No exceptions thrown; errors are logged and handled gracefully
Future<void> saveUserPreference(String key, String value) async {
  // Guard: Validate inputs
  if (key.isEmpty) {
    debugPrint('saveUserPreference: Cannot save with empty key');
    return;
  }

  if (value.isEmpty) {
    debugPrint(
        'saveUserPreference: Warning - saving empty value for key "$key"');
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    final success = await prefs.setString(key, value);

    if (success) {
      debugPrint('✓ Saved preference: $key = $value');

      // Special handling: Auto-update FFAppState for currency code
      if (key == 'user_currency_code') {
        FFAppState().update(() {
          FFAppState().userCurrencyCode = value.toUpperCase();
        });
        debugPrint(
            '✓ Auto-updated FFAppState.userCurrencyCode = ${value.toUpperCase()}');
      }
    } else {
      debugPrint('✗ Failed to save preference: $key');
    }
  } catch (e) {
    debugPrint('Error saving preference for key "$key": $e');
  }
}
