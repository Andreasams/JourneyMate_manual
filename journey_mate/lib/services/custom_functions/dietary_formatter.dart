import 'localization_utils.dart';

/// English-only fallback translations for dietary formatter strings.
/// Primary source is Supabase ui_translations cache; these cover cache misses.
const Map<String, String> _dietaryFallbacks = {
  'dietary_prefix_dish': 'This dish is',
  'dietary_prefix_beverage': 'This beverage is',
  'conjunction_and': 'and',
  'dietary_restrictions_none': 'No dietary restrictions specified',
  'dietary_info_none': 'Dietary information not specified',
};

/// Converts dietary preference IDs to a localized, formatted string.
String? convertDietaryPreferencesToString(
  List<int>? dietaryIDs,
  String currentLanguage,
  bool isBeverage,
  dynamic translationsCache,
) {
  if (dietaryIDs == null || dietaryIDs.isEmpty) {
    final key = isBeverage ? 'dietary_info_none' : 'dietary_restrictions_none';
    return getLocalizedString(key, currentLanguage, translationsCache, _dietaryFallbacks);
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

  // Get localized prefix and conjunction
  final prefixKey =
      isBeverage ? 'dietary_prefix_beverage' : 'dietary_prefix_dish';
  final prefix =
      getLocalizedString(prefixKey, currentLanguage, translationsCache, _dietaryFallbacks);
  final conjunction =
      getLocalizedString('conjunction_and', currentLanguage, translationsCache, _dietaryFallbacks);

  // Format with language-specific conjunction and spacing rules
  final joinedNames =
      joinWithConjunction(dietaryNames, conjunction, currentLanguage);

  return formatPrefixedList(prefix, joinedNames, currentLanguage);
}
