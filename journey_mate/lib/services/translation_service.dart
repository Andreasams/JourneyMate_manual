import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

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
/// All keys are loaded at app startup and refreshed when language changes.
///
/// Usage:
///   Text(td(ref, 'search_placeholder'))
///
/// Requires: WidgetRef (available in ConsumerWidget/ConsumerStatefulWidget)
String td(WidgetRef ref, String key) {
  final cache = ref.watch(translationsCacheProvider);
  final text = cache[key];

  if (text == null) {
    debugPrint('⚠️ td: Missing dynamic key "$key"');
    return key;
  }

  return text;
}
