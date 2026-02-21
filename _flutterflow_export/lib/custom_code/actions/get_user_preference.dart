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

/// Retrieves a user preference from persistent local storage.
///
/// This action is the counterpart to saveUserPreference and retrieves values
/// that were previously stored. It's designed to work seamlessly with the
/// preference saving workflow.
///
/// Special Behavior: - When key = 'user_currency_code': Automatically updates
/// FFAppState().userCurrencyCode with the retrieved value (or 'DKK' if not
/// found)
///
/// The function returns an empty string if: - The key doesn't exist
/// (preference was never saved) - An error occurs during retrieval - The
/// stored value is null
///
/// This makes it safe to use without additional null checks in FlutterFlow.
///
/// Common use cases: - Language restoration:
/// getUserPreference('user_language_code') - Currency retrieval:
/// getUserPreference('user_currency_code') - Theme mode:
/// getUserPreference('theme_mode') - Last selected filter:
/// getUserPreference('last_filter_id')
///
/// Args: key: Unique identifier for the preference (same key used in
/// saveUserPreference)
///
/// Returns: The stored string value, or empty string if not found/error
///
/// Side Effects: - If key = 'user_currency_code': Updates
/// FFAppState().userCurrencyCode
///
/// Throws: No exceptions thrown; errors are logged and empty string is
/// returned
Future<String> getUserPreference(String key) async {
  const defaultCurrency = 'DKK';

  // Guard: Validate input
  if (key.isEmpty) {
    debugPrint('getUserPreference: Cannot retrieve with empty key');
    return '';
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key);

    if (value != null && value.isNotEmpty) {
      debugPrint('✓ Retrieved preference: $key = $value');

      // Special handling: Auto-update FFAppState for currency code
      if (key == 'user_currency_code') {
        FFAppState().update(() {
          FFAppState().userCurrencyCode = value.toUpperCase();
        });
        debugPrint(
            '✓ Auto-updated FFAppState.userCurrencyCode = ${value.toUpperCase()}');
      }

      return value;
    } else {
      debugPrint('✗ No preference found for key: $key');

      // Special handling: Set default currency if not found
      if (key == 'user_currency_code') {
        FFAppState().update(() {
          FFAppState().userCurrencyCode = defaultCurrency;
        });
        debugPrint(
            '✓ Auto-set FFAppState.userCurrencyCode to default: $defaultCurrency');
      }

      return '';
    }
  } catch (e) {
    debugPrint('Error retrieving preference for key "$key": $e');

    // Special handling: Set default currency on error
    if (key == 'user_currency_code') {
      try {
        final prefs = await SharedPreferences.getInstance();
        FFAppState().update(() {
          FFAppState().userCurrencyCode = defaultCurrency;
        });
        await prefs.setString(key, defaultCurrency);
        debugPrint(
            '✓ Auto-set and saved FFAppState.userCurrencyCode to default: $defaultCurrency');
      } catch (saveError) {
        debugPrint('Failed to save default currency: $saveError');
      }
    }

    return '';
  }
}
