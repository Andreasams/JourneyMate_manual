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

  // Map allergen IDs to translation keys
  final allergenKeys = allergyIDs.map((id) {
    switch (id) {
      case 1:
        return 'allergen_gluten';
      case 2:
        return 'allergen_crustaceans';
      case 3:
        return 'allergen_eggs';
      case 4:
        return 'allergen_fish';
      case 5:
        return 'allergen_peanuts';
      case 6:
        return 'allergen_soybeans';
      case 7:
        return 'allergen_milk';
      case 8:
        return 'allergen_nuts';
      case 9:
        return 'allergen_celery';
      case 10:
        return 'allergen_mustard';
      case 11:
        return 'allergen_sesame';
      case 12:
        return 'allergen_sulfites';
      case 13:
        return 'allergen_lupin';
      case 14:
        return 'allergen_molluscs';
      default:
        return 'allergen_unknown';
    }
  }).toList();

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
