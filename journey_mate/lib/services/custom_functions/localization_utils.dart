import 'dart:convert';

/// Shared localization utilities for formatter functions.
///
/// Provides translation cache lookup, conjunction-based list joining,
/// and fallback string resolution used by allergen_formatter and
/// dietary_formatter.

/// Looks up a translation key in the translations cache.
///
/// Returns [translationKey] unchanged if not found (allows caller
/// to detect a miss by comparing result == key).
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

/// Gets a localized string, trying translations cache first, then English fallback.
///
/// [fallbacks] maps translation keys to their English fallback values.
String getLocalizedString(
  String key,
  String languageCode,
  dynamic translationsCache,
  Map<String, String> fallbacks,
) {
  // Try translations cache first
  final cached = getTranslations(languageCode, key, translationsCache);
  if (cached != key) return cached;

  // Fallback to English
  return fallbacks[key] ?? key;
}

/// Joins a list of names with proper conjunction handling per language.
///
/// Japanese/Chinese: uses conjunction between every pair, no spaces ("AとBとC")
/// All others (including Korean): comma-separated with conjunction before last item
String joinWithConjunction(
  List<String> names,
  String conjunction,
  String languageCode,
) {
  if (names.length == 1) return names[0];

  // Japanese and Chinese: conjunction between every pair, no spaces
  if (languageCode == 'ja' || languageCode == 'zh') {
    return names.join(conjunction);
  }

  // All other languages (including Korean): "A, B conjunction C"
  if (names.length == 2) {
    return '${names[0]} $conjunction ${names[1]}';
  }

  final allButLast = names.sublist(0, names.length - 1);
  final last = names.last;
  return '${allButLast.join(', ')} $conjunction $last';
}

/// Formats a prefix + names string with language-appropriate spacing.
///
/// Japanese/Chinese: no space between prefix and names (e.g. "含有：卵と牛乳")
/// All others (including Korean): space between prefix and names
String formatPrefixedList(
  String prefix,
  String joinedNames,
  String languageCode,
) {
  if (languageCode == 'ja' || languageCode == 'zh') {
    return '$prefix$joinedNames';
  }
  return '$prefix $joinedNames';
}
