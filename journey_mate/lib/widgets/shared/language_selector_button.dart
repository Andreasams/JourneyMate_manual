import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/translation_service.dart';
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

  // Translation keys
  static const String _languageLabelKey = 'settings_language_label';

  // Layout constants
  static const double _buttonHeight = 50.0;

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
    return Container(
      height: _buttonHeight,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Floating label
          Text(
            td(ref, _languageLabelKey),
            style: AppTypography.helper.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          // Dropdown
          DropdownButton<String>(
            value: currentLanguageCode,
            style: AppTypography.bodyRegular,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textTertiary,
              size: 24.0,
            ),
            dropdownColor: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppRadius.input),
            elevation: 4,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            items: _languageOrder.map((code) {
              final languageName = _languageNames[code] ?? code.toUpperCase();
              return DropdownMenuItem<String>(
                value: code,
                child: Text(
                  languageName,
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
    );
  }
}
