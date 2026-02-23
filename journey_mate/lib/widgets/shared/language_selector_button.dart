import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/filter_providers.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';

/// LanguageSelectorButton - Settings button for language selection
///
/// Displays current language in a Material Design dropdown. Selecting a new
/// language triggers localization update, translation reload, and filter reload.
///
/// Props:
/// - currentLanguageCode: Current language code (e.g., 'en', 'da')
/// - onLanguageSelected: Callback with new language code
/// - width: Button width
///
/// Provider Dependencies:
/// - localizationProvider: Read current language
/// - translationsCacheProvider: Trigger reload after language change
/// - filterProvider: Trigger reload after language change
///
/// Design:
/// - Material Design DropdownButton
/// - Floating label: "Language" (from translation key)
/// - 7 language options: da, en, de, sv, no, it, fr
/// - Native language names (Dansk, English, Deutsch, etc.)
/// - 50px height, white background, border, orange focus state
class LanguageSelectorButton extends ConsumerWidget {
  const LanguageSelectorButton({
    super.key,
    required this.currentLanguageCode,
    required this.onLanguageSelected,
    this.width,
  });

  final String currentLanguageCode;
  final Function(String) onLanguageSelected;
  final double? width;

  // Language names in their native form (MUST NOT be translated)
  static const Map<String, String> _languageNames = {
    'en': 'English',
    'da': 'Dansk',
    'de': 'Deutsch',
    'fr': 'Français',
    'it': 'Italiano',
    'no': 'Norsk',
    'sv': 'Svenska',
  };

  // Language order (same as FlutterFlow)
  static const List<String> _languageOrder = [
    'da', // Danish first (Denmark is the target market)
    'en', // English second (international)
    'de', // German
    'sv', // Swedish
    'no', // Norwegian
    'it', // Italian
    'fr', // French
  ];

  /// Handles language change: reload translations + filters
  Future<void> _handleLanguageChange(
    BuildContext context,
    WidgetRef ref,
    String newLanguageCode,
  ) async {
    if (newLanguageCode == currentLanguageCode) return;

    try {
      // Reload translations for new language
      await ref.read(translationsCacheProvider.notifier).loadTranslations(newLanguageCode);

      // Reload filters for new language
      await ref.read(filterProvider.notifier).loadFiltersForLanguage(newLanguageCode);

      // Notify parent callback
      onLanguageSelected(newLanguageCode);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language changed to ${_languageNames[newLanguageCode]}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error changing language: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to change language'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageName = _languageNames[currentLanguageCode] ?? currentLanguageCode.toUpperCase();

    return GestureDetector(
      onTap: () {
        // Open dropdown programmatically by using a hidden button
        // We'll trigger the dropdown via the actual DropdownButton below
      },
      child: Container(
        width: width,
        height: 50.0,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(color: AppColors.border, width: 1.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              languageName,
              style: AppTypography.bodyRegular,
            ),
            DropdownButton<String>(
              value: currentLanguageCode,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textTertiary,
                size: 24.0,
              ),
              dropdownColor: AppColors.bgCard,
              borderRadius: BorderRadius.circular(AppRadius.input),
              elevation: 4,
              underline: const SizedBox.shrink(),
              selectedItemBuilder: (context) {
                // Return empty widgets for selected item (we show it separately)
                return _languageOrder.map((code) => const SizedBox.shrink()).toList();
              },
              items: _languageOrder.map((code) {
                final name = _languageNames[code] ?? code.toUpperCase();
                return DropdownMenuItem<String>(
                  value: code,
                  child: Text(
                    name,
                    style: AppTypography.bodyRegular,
                  ),
                );
              }).toList(),
              onChanged: (newLanguage) async {
                if (newLanguage != null && newLanguage != currentLanguageCode) {
                  await _handleLanguageChange(context, ref, newLanguage);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
