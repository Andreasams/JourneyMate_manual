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

/// Converts dietary preference IDs to a localized, formatted string.
///
/// This is a simplified implementation for Phase 7. Full implementation
/// should be ported from _flutterflow_export/lib/flutter_flow/custom_functions.dart
/// when needed.
String? convertDietaryPreferencesToString(
  List<int>? dietaryIDs,
  String currentLanguage,
  bool isBeverage,
  dynamic translationsCache,
) {
  if (dietaryIDs == null || dietaryIDs.isEmpty) {
    // Return fallback message
    return isBeverage
        ? 'Dietary information not specified'
        : 'No dietary restrictions specified';
  }

  // Map dietary IDs to translation keys
  // IDs: 1=gluten-free, 2=pescetarian, 3=halal, 4=lactose-free, 5=kosher, 6=vegan, 7=vegetarian
  final dietaryKeys = dietaryIDs.map((id) {
    switch (id) {
      case 1:
        return 'dietary_glutenfree';
      case 2:
        return 'dietary_pescetarian';
      case 3:
        return 'dietary_halal';
      case 4:
        return 'dietary_lactosefree';
      case 5:
        return 'dietary_kosher';
      case 6:
        return 'dietary_vegan';
      case 7:
        return 'dietary_vegetarian';
      default:
        return 'dietary_unknown';
    }
  }).toList();

  // Get localized names
  final dietaryNames = dietaryKeys
      .map((key) => getTranslations(currentLanguage, key, translationsCache))
      .toList();

  // Format as comma-separated list with "and" before last item
  final prefix =
      isBeverage ? 'This beverage is' : 'This dish is';

  if (dietaryNames.length == 1) {
    return '$prefix ${dietaryNames[0]}';
  } else if (dietaryNames.length == 2) {
    return '$prefix ${dietaryNames[0]} and ${dietaryNames[1]}';
  } else {
    final allButLast = dietaryNames.sublist(0, dietaryNames.length - 1);
    final last = dietaryNames.last;
    return '$prefix ${allButLast.join(', ')} and $last';
  }
}
