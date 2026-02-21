import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

// ============================================================
// STATIC TRANSLATIONS (Sample keys for Phase 4 — full map in Phase 6)
// ============================================================

const Map<String, Map<String, String>> kStaticTranslations = {
  'key_home': {
    'en': 'Home',
    'da': 'Hjem',
    'de': 'Startseite',
    'it': 'Casa',
    'sv': 'Hem',
    'no': 'Hjem',
    'fr': 'Accueil',
  },
  'key_search': {
    'en': 'Search',
    'da': 'Søg',
    'de': 'Suchen',
    'it': 'Cerca',
    'sv': 'Sök',
    'no': 'Søk',
    'fr': 'Rechercher',
  },
  'key_settings': {
    'en': 'Settings',
    'da': 'Indstillinger',
    'de': 'Einstellungen',
    'it': 'Impostazioni',
    'sv': 'Inställningar',
    'no': 'Innstillinger',
    'fr': 'Paramètres',
  },
  'key_filter': {
    'en': 'Filter',
    'da': 'Filter',
    'de': 'Filter',
    'it': 'Filtro',
    'sv': 'Filter',
    'no': 'Filter',
    'fr': 'Filtre',
  },
  'key_menu': {
    'en': 'Menu',
    'da': 'Menu',
    'de': 'Menü',
    'it': 'Menu',
    'sv': 'Meny',
    'no': 'Meny',
    'fr': 'Menu',
  },
};

// ============================================================
// HELPER FUNCTIONS FOR WIDGETS
// Note: translationsCacheProvider is now in providers/app_providers.dart
// ============================================================

/// Static translation lookup (ts = "translation static")
/// Use this for keys that are hardcoded in the app (Phase 4 sample keys)
String ts(String key, String languageCode) {
  return kStaticTranslations[key]?[languageCode] ?? key;
}

/// Dynamic translation lookup (td = "translation dynamic")
/// Use this for keys fetched from BuildShip (Phase 6 full integration)
/// Requires WidgetRef to watch the provider
String td(WidgetRef ref, String key) {
  final cache = ref.watch(translationsCacheProvider);
  return cache[key] ?? key;
}

/// Preload translations for app startup
/// Call this in main.dart before runApp
Future<void> preloadTranslations(WidgetRef ref, String languageCode) async {
  await ref
      .read(translationsCacheProvider.notifier)
      .loadTranslations(languageCode);
}
