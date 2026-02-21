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

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Updates currency and fetches exchange rate from DKK.
///
/// Saves currency preference and fetches exchange rate in one action.
///
/// Args: newCurrencyCode: ISO 4217 currency code (e.g., 'USD', 'EUR')
///
/// Returns: bool: true if successful, false otherwise
Future<bool> updateCurrencyWithExchangeRate(String newCurrencyCode) async {
  const apiBaseUrl = 'https://wvb8ww.buildship.run/getExchangeRates';

  if (newCurrencyCode.trim().isEmpty) {
    debugPrint('⚠️ Empty currency code');
    return false;
  }

  final normalizedCode = newCurrencyCode.trim().toUpperCase();

  try {
    // Save currency preference (auto-updates FFAppState)
    await saveUserPreference('user_currency_code', normalizedCode);

    // Skip API call if currency is DKK (1:1 rate)
    if (normalizedCode == 'DKK') {
      FFAppState().update(() {
        FFAppState().exchangeRate = 1.0;
      });
      debugPrint('✅ Currency set to DKK (rate: 1.0)');
      return true;
    }

    // Fetch exchange rate
    final url =
        Uri.parse('$apiBaseUrl?from_currency=DKK&to_currency=$normalizedCode');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      debugPrint('❌ Exchange rate API failed: ${response.statusCode}');
      return false;
    }

    final List<dynamic> rates = json.decode(response.body);
    if (rates.isEmpty) {
      debugPrint('⚠️ No exchange rate data returned');
      return false;
    }

    final rate = rates[0]['rate'] as num;

    // Update FFAppState with exchange rate
    FFAppState().update(() {
      FFAppState().exchangeRate = rate.toDouble();
    });

    debugPrint('✅ Currency: $normalizedCode, Rate: $rate');
    return true;
  } catch (e) {
    debugPrint('❌ Error updating currency: $e');
    return false;
  }
}
