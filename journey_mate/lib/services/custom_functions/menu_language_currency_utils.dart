import 'dart:convert';

import 'currency_name_formatter.dart';
import 'language_currency_config.dart';
import 'price_formatter.dart' show getCurrencyFormattingRules;

/// Represents a menu option (language or currency) for the 3-dot menu
/// in ItemBottomSheet and PackageBottomSheet.
class MenuOption {
  const MenuOption({
    required this.type,
    required this.code,
    required this.displayName,
  });

  final String type; // 'language' or 'currency'
  final String code; // Language code or currency code
  final String displayName;
}

/// Computes which language options should appear in the menu.
///
/// Rules:
/// - RULE 4: If viewing different language than app language, offer to go back
/// - RULE 1: App language is English → offer Danish
/// - RULE 2: App language is Danish → offer English
/// - RULE 3: App language is Other → offer authentic languages (up to 3)
List<MenuOption> computeLanguageOptions({
  required String appLanguage,
  required String displayedLanguage,
  required List<String> authenticLanguages,
  required String Function(String langCode) getLanguageName,
}) {
  final options = <MenuOption>[];

  // RULE 4: If viewing different language than app language, offer to go back
  if (displayedLanguage != appLanguage) {
    options.add(MenuOption(
      type: 'language',
      code: appLanguage,
      displayName: getLanguageName(appLanguage),
    ));
  }

  // RULE 1: App language is English → offer Danish
  if (appLanguage == 'en' && displayedLanguage != 'da') {
    options.add(MenuOption(
      type: 'language',
      code: 'da',
      displayName: getLanguageName('da'),
    ));
    return options;
  }

  // RULE 2: App language is Danish → offer English
  if (appLanguage == 'da' && displayedLanguage != 'en') {
    options.add(MenuOption(
      type: 'language',
      code: 'en',
      displayName: getLanguageName('en'),
    ));
    return options;
  }

  // RULE 3: App language is Other → offer authentic languages (up to 3)
  if (appLanguage != 'en' && appLanguage != 'da') {
    final availableAuthLangs = authenticLanguages
        .where((lang) => lang != displayedLanguage)
        .take(3)
        .toList();

    for (final langCode in availableAuthLangs) {
      options.add(MenuOption(
        type: 'language',
        code: langCode,
        displayName: getLanguageName(langCode),
      ));
    }
  }

  return options;
}

/// Computes which currency options should appear in the menu.
///
/// Uses getCurrenciesForLanguage() to determine available currencies for the
/// user's language, then offers all alternatives except the currently displayed
/// one. This enables bidirectional switching (e.g., EUR↔DKK for German users)
/// regardless of which currency is currently active.
List<MenuOption> computeCurrencyOptions({
  required String currentCurrency,
  required String appLanguage,
  required String Function(String currencyCode) getCurrencyDisplayName,
}) {
  final availableCurrencies = getCurrenciesForLanguage(appLanguage);

  // Only one currency available (e.g., Danish with DKK only) — no switching
  if (availableCurrencies.length <= 1) {
    return [];
  }

  // Offer all available currencies except the one currently displayed
  return availableCurrencies
      .where((code) => code != currentCurrency)
      .map((code) => MenuOption(
            type: 'currency',
            code: code,
            displayName: getCurrencyDisplayName(code),
          ))
      .toList();
}

/// Gets display name for currency (e.g., "Danish Krone (kr.)")
///
/// Pure function: takes language code, currency code, and translations cache,
/// returns formatted display string.
String formatCurrencyDisplayName(
  String languageCode,
  String currencyCode,
  dynamic translationsCache,
) {
  final localizedName = getLocalizedCurrencyName(
    languageCode,
    currencyCode,
    translationsCache,
  );

  final rulesJson = getCurrencyFormattingRules(currencyCode);
  String symbol = currencyCode;

  if (rulesJson != null) {
    try {
      final rules = json.decode(rulesJson) as Map<String, dynamic>;
      symbol = rules['symbol'] as String? ?? currencyCode;
    } catch (_) {}
  }

  return '$localizedName ($symbol)';
}
