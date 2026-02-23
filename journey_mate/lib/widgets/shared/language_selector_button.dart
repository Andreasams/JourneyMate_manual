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
/// Displays current language with a chevron icon. Tapping opens a modal bottom
/// sheet with 7 language options (en, da, de, fr, it, no, sv). Selecting a new
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
/// - Button: white background, border (#e8e8e8), 50px height
/// - Displays current language name (e.g., "English", "Dansk")
/// - Chevron icon on right
/// - Bottom sheet with 7 language options (radio-style selection)
/// - Language names in native form (Dansk, not Danish)
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
  static const String _selectLanguageTitleKey = 'settings_select_language_title';

  // Layout constants
  static const double _buttonHeight = 50.0;
  static const double _borderRadius = 12.0;
  static const double _iconSize = 24.0;

  /// Opens the language selector bottom sheet
  void _showLanguageSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.bottomSheet),
            ),
          ),
          child: Column(
            children: [
              _buildSheetHeader(context, ref),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  itemCount: _languageOrder.length,
                  itemBuilder: (context, index) {
                    final languageCode = _languageOrder[index];
                    return _buildLanguageOption(
                      context,
                      ref,
                      languageCode,
                      currentLanguageCode == languageCode,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the sheet header with title and close button
  Widget _buildSheetHeader(BuildContext context, WidgetRef ref) {
    return Container(
      height: 64.0,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Stack(
        children: [
          // Swipe bar indicator
          Positioned(
            top: 8.0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 80.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          // Title
          Center(
            child: Text(
              td(ref, _selectLanguageTitleKey),
              style: AppTypography.sectionHeading,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single language option with radio button
  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref,
    String languageCode,
    bool isSelected,
  ) {
    final languageName = _languageNames[languageCode] ?? languageCode.toUpperCase();

    return InkWell(
      onTap: () async {
        Navigator.of(context).pop();
        await _handleLanguageChange(context, ref, languageCode);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 24.0,
              height: 24.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.border,
                  width: 2.0,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12.0,
                        height: 12.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: AppSpacing.md),
            // Language name
            Text(
              languageName,
              style: AppTypography.bodyRegular.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
      onTap: () => _showLanguageSelector(context, ref),
      child: Container(
        width: width,
        height: _buttonHeight,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  td(ref, _languageLabelKey),
                  style: AppTypography.helper.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  languageName,
                  style: AppTypography.bodyRegular,
                ),
              ],
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
              size: _iconSize,
            ),
          ],
        ),
      ),
    );
  }
}
