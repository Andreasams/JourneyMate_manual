import 'localization_utils.dart';

/// English-only fallback translations for allergen formatter strings.
/// Primary source is Supabase ui_translations cache; these cover cache misses.
const Map<String, String> _allergenFallbacks = {
  'allergen_contains': 'Contains',
  'conjunction_and': 'and',
  'allergen_none': 'No allergens listed',
  'allergen_info_none': 'No allergen information available',
};

/// Converts allergy IDs to a localized, formatted allergen list string.
String? convertAllergiesToString(
  List<int>? allergyIDs,
  String currentLanguage,
  bool isBeverage,
  dynamic translationsCache,
) {
  if (allergyIDs == null || allergyIDs.isEmpty) {
    final key = isBeverage ? 'allergen_info_none' : 'allergen_none';
    return getLocalizedString(key, currentLanguage, translationsCache, _allergenFallbacks);
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

  // Get localized prefix and conjunction
  final prefix =
      getLocalizedString('allergen_contains', currentLanguage, translationsCache, _allergenFallbacks);
  final conjunction =
      getLocalizedString('conjunction_and', currentLanguage, translationsCache, _allergenFallbacks);

  // Format with language-specific conjunction and spacing rules
  final joinedNames =
      joinWithConjunction(allergenNames, conjunction, currentLanguage);

  return formatPrefixedList(prefix, joinedNames, currentLanguage);
}
