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

/// Fetches translations from Buildship API endpoint and updates FFAppState.
///
/// This action fetches translations via HTTP GET with language code as a
/// query parameter, then directly updates FFAppState.translationsCache with
/// the result.
///
/// This eliminates the need for a separate "Update State" action in
/// FlutterFlow's action flow - just call this action and the cache is
/// automatically updated.
///
/// Args: languageCode: ISO 639-1 language code (e.g., 'en', 'da', 'de')
///
/// Returns: bool: true if translations were successfully fetched and cached,
/// false on error (cache will be set to empty map)
///
/// Side Effects: - Updates FFAppState().translationsCache with fetched
/// translations - On error, sets FFAppState().translationsCache to empty map
///
/// Usage: Simply call this action when language changes. No need to manually
/// update FFAppState afterwards - it's done automatically.
Future<bool> getTranslationsWithUpdate(String languageCode) async {
  const apiBaseUrl = 'https://wvb8ww.buildship.run/languageText';

  // Guard: Validate language code
  if (languageCode.isEmpty) {
    debugPrint('⚠️ getTranslationsWithUpdate: Empty language code provided');

    // Set empty cache on error
    FFAppState().update(() {
      FFAppState().translationsCache = <String, dynamic>{};
    });

    return false;
  }

  try {
    debugPrint('📡 Fetching translations for: $languageCode');

    // Use GET request with query parameter (same pattern as filters)
    final url = Uri.parse('$apiBaseUrl?languageCode=$languageCode');
    final response = await http.get(url);

    // Handle non-200 responses
    if (response.statusCode != 200) {
      debugPrint(
        '❌ Buildship failed. Status: ${response.statusCode}\n'
        '   URL: $url\n'
        '   Response: ${response.body}',
      );

      // Set empty cache on error
      FFAppState().update(() {
        FFAppState().translationsCache = <String, dynamic>{};
      });

      return false;
    }

    // Parse and validate response
    final translationsMap = json.decode(response.body) as Map<String, dynamic>;

    if (translationsMap.isEmpty) {
      debugPrint('⚠️ Buildship returned empty data for $languageCode');

      // Set empty cache if no translations returned
      FFAppState().update(() {
        FFAppState().translationsCache = <String, dynamic>{};
      });

      return false;
    }

    // Update FFAppState with fetched translations
    FFAppState().update(() {
      FFAppState().translationsCache = translationsMap;
    });

    debugPrint(
      '✅ Successfully fetched and cached ${translationsMap.length} translations for $languageCode',
    );

    return true;
  } catch (e, stackTrace) {
    debugPrint(
      '❌ Error fetching translations: $e\n'
      '   Stack trace: $stackTrace',
    );

    // Set empty cache on error
    FFAppState().update(() {
      FFAppState().translationsCache = <String, dynamic>{};
    });

    return false;
  }
}
