import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../providers/locale_provider.dart';
import '../constants/welcome_fallback_translations.dart';
import '../constants/business_profile_fallback_translations.dart';

// ============================================================
// TRANSLATION SERVICE (Phase 8 — 100% Dynamic Translations)
// ============================================================
//
// All translations are now loaded dynamically from Supabase via BuildShip API.
// Translation cache is managed by `translationsCacheProvider`.
//
// Usage in widgets:
//   td(ref, 'translation_key') — fetches translation from cache
//
// Migration complete: All 355 app translation keys are in Supabase ui_translations table.
// Supported languages: en, da, de, fr, it, no, sv
//
// ============================================================

/// Dynamic translation lookup (td = "translation dynamic")
///
/// Fetches translations from BuildShip API cache (stored in translationsCacheProvider).
/// Falls back to welcome page translations on first launch.
/// All keys are loaded at app startup and refreshed when language changes.
///
/// Usage:
///   Text(td(ref, 'search_placeholder'))
///
/// Requires: WidgetRef (available in ConsumerWidget/ConsumerStatefulWidget)
String td(WidgetRef ref, String key) {
  final cache = ref.watch(translationsCacheProvider);
  final text = cache[key];

  if (text != null && text.isNotEmpty) {
    return text;
  }

  // Fallback chain: welcome page → business profile
  final locale = ref.watch(localeProvider);
  final lang = locale.languageCode;

  final welcomeFallback = kWelcomeFallbackTranslations[lang]?[key];
  if (welcomeFallback != null) {
    return welcomeFallback;
  }

  final businessFallback = kBusinessProfileFallbackTranslations[lang]?[key];
  if (businessFallback != null) {
    return businessFallback;
  }

  // Last resort: return the key itself
  debugPrint('⚠️ td: Missing translation key "$key"');
  return key;
}
