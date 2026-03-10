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

/// Converts allergy IDs to a localized, formatted allergen list string.
///
/// This is a simplified implementation for Phase 7. Full implementation
/// should be ported from _flutterflow_export/lib/flutter_flow/custom_functions.dart
/// when needed.
String? convertAllergiesToString(
  List<int>? allergyIDs,
  String currentLanguage,
  bool isBeverage,
  dynamic translationsCache,
) {
  if (allergyIDs == null || allergyIDs.isEmpty) {
    // Return fallback message
    return isBeverage
        ? 'No allergen information available'
        : 'No allergens listed';
  }

  // Map allergen IDs to translation keys (matches Supabase allergen ID order)
  const allergenIdToKey = {
    1: 'allergen_celery',
    2: 'allergen_gluten',
    3: 'allergen_crustaceans',
    4: 'allergen_eggs',
    5: 'allergen_fish',
    6: 'allergen_lupin',
    7: 'allergen_milk',
    8: 'allergen_molluscs',
    9: 'allergen_mustard',
    10: 'allergen_nuts',
    11: 'allergen_peanuts',
    12: 'allergen_sesame',
    13: 'allergen_soybeans',
    14: 'allergen_sulfites',
  };

  final allergenKeys = allergyIDs
      .map((id) => allergenIdToKey[id] ?? 'allergen_unknown')
      .toList();

  // Get localized names
  final allergenNames = allergenKeys
      .map((key) => getTranslations(currentLanguage, key, translationsCache))
      .toList();

  // Format as comma-separated list with "and" before last item
  if (allergenNames.length == 1) {
    return 'Contains ${allergenNames[0]}';
  } else if (allergenNames.length == 2) {
    return 'Contains ${allergenNames[0]} and ${allergenNames[1]}';
  } else {
    final allButLast = allergenNames.sublist(0, allergenNames.length - 1);
    final last = allergenNames.last;
    return 'Contains ${allButLast.join(', ')} and $last';
  }
}
