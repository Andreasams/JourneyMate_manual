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

/// Updates the user's currency based on language selection with smart fallback.
///
/// This action ensures the user's selected currency remains compatible with
/// their chosen language. When switching languages:
/// 1. If the current currency is available in the new language → keep it
/// 2. If not available → switch to the default currency for that language
///
/// This provides a seamless UX where users maintain their currency preference
/// across language changes when possible, but automatically get sensible
/// defaults when switching to languages with different currency options.
///
/// Example scenarios:
/// - User has USD, switches English → German: Changes to EUR (USD not available)
/// - User has DKK, switches Danish → Norwegian: Keeps DKK (available in both)
/// - User has EUR, switches German → Italian: Keeps EUR (available in both)
///
/// Args:
///   newLanguageCode: ISO 639-1 language code for the target language
///
/// Returns:
///   Future that completes when currency is updated and exchange rate fetched
///
/// Throws:
///   No exceptions thrown; falls back to DKK on any error
Future<void> updateCurrencyForLanguage(String newLanguageCode) async {
  if (newLanguageCode.isEmpty) {
    debugPrint('updateCurrencyForLanguage: Empty language code provided');
    return;
  }

  try {
    final currentCurrency = FFAppState().userCurrencyCode.trim().toUpperCase();
    final availableCodes = _getCurrenciesForLanguage(newLanguageCode)
        .map((c) => (c['code'] as String).toUpperCase())
        .toList();

    // Determine the appropriate currency
    final newCurrency = _determineTargetCurrency(
      currentCurrency: currentCurrency,
      availableCodes: availableCodes,
      languageCode: newLanguageCode,
    );

    // Only update if currency needs to change
    if (newCurrency != currentCurrency) {
      // Use updateCurrencyWithExchangeRate to:
      // - Save to SharedPreferences
      // - Update FFAppState.userCurrencyCode
      // - Fetch exchange rate from API
      // - Update FFAppState.exchangeRate
      await updateCurrencyWithExchangeRate(newCurrency);
      debugPrint('Currency updated: $currentCurrency → $newCurrency');
    }
  } catch (e) {
    debugPrint('Error in updateCurrencyForLanguage: $e');
    await updateCurrencyWithExchangeRate('DKK');
  }
}

// ============================================================================
// CURRENCY SELECTION LOGIC
// ============================================================================

/// Determines the appropriate currency for the target language
///
/// Logic:
/// 1. If current currency is available in new language → keep it
/// 2. Otherwise → use default currency for that language
String _determineTargetCurrency({
  required String currentCurrency,
  required List<String> availableCodes,
  required String languageCode,
}) {
  // Check if current currency is available
  if (availableCodes.contains(currentCurrency)) {
    return currentCurrency;
  }

  // Fall back to default currency for this language
  return _getDefaultCurrencyForLanguage(languageCode);
}

/// Returns the default currency code for a given language
String _getDefaultCurrencyForLanguage(String languageCode) {
  const defaults = {
    'en': 'USD',
    'de': 'EUR',
    'sv': 'SEK',
    'no': 'NOK',
    'it': 'EUR',
    'fr': 'EUR',
    'da': 'DKK',
    'es': 'EUR',
    'fi': 'EUR',
    'nl': 'EUR',
    'pl': 'PLN',
    'uk': 'UAH',
    'ja': 'JPY',
    'ko': 'KRW',
    'zh': 'CNY',
  };

  return defaults[languageCode] ?? 'DKK';
}

// ============================================================================
// CURRENCY OPTIONS DATA
// ============================================================================

/// Returns available currency options for a specific language
///
/// Each currency option contains:
/// - code: ISO 4217 currency code
/// - Translation is handled via getTranslations('currency_xxx', cache)
List<Map<String, String>> _getCurrenciesForLanguage(String languageCode) {
  // Currency availability by language
  // Note: Currency names are translated via getTranslations
  const currencyOptions = {
    'en': [
      {'code': 'USD'},
      {'code': 'GBP'},
      {'code': 'DKK'},
    ],
    'de': [
      {'code': 'EUR'},
      {'code': 'DKK'},
    ],
    'sv': [
      {'code': 'SEK'},
      {'code': 'DKK'},
    ],
    'no': [
      {'code': 'NOK'},
      {'code': 'DKK'},
    ],
    'it': [
      {'code': 'EUR'},
      {'code': 'DKK'},
    ],
    'fr': [
      {'code': 'EUR'},
      {'code': 'DKK'},
    ],
    'da': [
      {'code': 'DKK'},
    ],
    'es': [
      {'code': 'EUR'},
      {'code': 'DKK'},
    ],
    'fi': [
      {'code': 'EUR'},
      {'code': 'DKK'},
    ],
    'nl': [
      {'code': 'EUR'},
      {'code': 'DKK'},
    ],
    'pl': [
      {'code': 'PLN'},
      {'code': 'EUR'},
      {'code': 'DKK'},
    ],
    'uk': [
      {'code': 'UAH'},
      {'code': 'EUR'},
      {'code': 'DKK'},
    ],
    'ja': [
      {'code': 'JPY'},
      {'code': 'USD'},
      {'code': 'DKK'},
    ],
    'ko': [
      {'code': 'KRW'},
      {'code': 'USD'},
      {'code': 'DKK'},
    ],
    'zh': [
      {'code': 'CNY'},
      {'code': 'USD'},
      {'code': 'DKK'},
    ],
  };

  return currencyOptions[languageCode] ??
      [
        {'code': 'DKK'}
      ];
}
