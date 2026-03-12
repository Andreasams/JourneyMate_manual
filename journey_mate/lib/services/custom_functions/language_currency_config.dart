// Shared language/currency configuration
//
// Single source of truth for the language→currency mapping used by both
// LocalizationNotifier (auto-switch on language change) and
// CurrencySelectorButton (dropdown options). Eliminates the previous
// duplication between settings_providers.dart and currency_selector_button.dart.
//
// All 15 database languages are mapped here. Only the 7 currently active
// languages appear in the language selector UI — but the infrastructure is
// ready for activation of any language without code changes here.

/// Returns the list of currency codes available for a given language.
///
/// DKK is always included (Copenhagen is the default city).
/// Fallback for unknown language codes is `['DKK']`.
List<String> getCurrenciesForLanguage(String languageCode) {
  const currencyConfigByLanguage = {
    // ── Active languages ──
    'da': ['DKK'],
    'de': ['EUR', 'DKK'],
    'en': ['USD', 'GBP', 'DKK'],
    'fr': ['EUR', 'DKK'],
    'it': ['EUR', 'DKK'],
    'no': ['NOK', 'DKK'],
    'sv': ['SEK', 'DKK'],
    // ── Inactive languages (ready for activation) ──
    'es': ['EUR', 'DKK'],
    'fi': ['EUR', 'DKK'],
    'ja': ['JPY', 'DKK'],
    'ko': ['KRW', 'DKK'],
    'nl': ['EUR', 'DKK'],
    'pl': ['PLN', 'DKK'],
    'uk': ['UAH', 'DKK'],
    'zh': ['CNY', 'DKK'],
  };
  return currencyConfigByLanguage[languageCode.toLowerCase()] ?? ['DKK'];
}

/// All 15 language codes in the database.
///
/// Used by cache-clearing and any logic that must iterate over every
/// possible language (not just the currently active ones).
const List<String> kAllLanguageCodes = [
  'da', 'de', 'en', 'es', 'fi', 'fr', 'it',
  'ja', 'ko', 'nl', 'no', 'pl', 'sv', 'uk', 'zh',
];
