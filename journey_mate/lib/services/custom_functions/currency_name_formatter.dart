import 'dart:convert';

/// Helper function to get translations from cache
String getTranslations(
  String languageCode,
  String translationKey,
  dynamic translationsCache,
) {
  if (languageCode.isEmpty || translationKey.isEmpty) {
    return translationKey;
  }

  if (translationsCache == null) {
    return translationKey;
  }

  try {
    Map<String, dynamic> translationsMap;

    if (translationsCache is String) {
      translationsMap = jsonDecode(translationsCache) as Map<String, dynamic>;
    } else if (translationsCache is Map<String, dynamic>) {
      translationsMap = translationsCache;
    } else {
      return translationKey;
    }

    final value = translationsMap[translationKey];
    if (value is String && value.isNotEmpty) {
      return value;
    }

    return translationKey;
  } catch (e) {
    return translationKey;
  }
}

/// Returns localized currency name for the given currency code.
///
/// This is a simplified implementation for Phase 7. Full implementation
/// should be ported from _flutterflow_export/lib/flutter_flow/custom_functions.dart
/// when needed.
String getLocalizedCurrencyName(
  String languageCode,
  String? currencyCode,
  dynamic translationsCache,
) {
  // Return currency code if null
  if (currencyCode == null) return '';

  // Normalize currency code to uppercase
  final normalizedCode = currencyCode.toUpperCase();

  // Build translation key (e.g., 'currency_dkk')
  final translationKey = 'currency_${normalizedCode.toLowerCase()}';

  // Get translation using central function with cache
  final translatedName = getTranslations(
    languageCode,
    translationKey,
    translationsCache,
  );

  // If translation key is returned unchanged, return the currency code as fallback
  if (translatedName == translationKey || translatedName.isEmpty) {
    return normalizedCode;
  }

  return translatedName;
}
