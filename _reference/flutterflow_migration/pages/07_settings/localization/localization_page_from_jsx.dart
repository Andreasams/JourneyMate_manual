// ============================================================
// LOCALIZATION PAGE - Converted from JSX v2 Design
// Clean Flutter UI shell with no backend functionality
//
// Two main sections:
// 1. Language & Currency - Dropdown selectors
// 2. Location - Status card + enable/manage button
// ============================================================

import 'package:flutter/material.dart';
import '../../../shared/app_theme.dart';

/// Translation helper function
String getTranslations(String languageCode, String key, Map<String, dynamic> cache) {
  return cache[key]?[languageCode] ?? key;
}

class LocalizationPage extends StatefulWidget {
  final String languageCode;
  final Map<String, dynamic> translationsCache;

  const LocalizationPage({
    super.key,
    required this.languageCode,
    required this.translationsCache,
  });

  @override
  State<LocalizationPage> createState() => _LocalizationPageState();
}

class _LocalizationPageState extends State<LocalizationPage> {
  // State
  String _selectedLanguage = 'da';
  String _selectedCurrency = 'DKK';
  bool _locationEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () {
            // TODO: Add markUserEngaged() call here
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          getTranslations(widget.languageCode, 'localization_title', widget.translationsCache),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language & Currency Section
            Text(
              getTranslations(widget.languageCode, 'localization_section_language_currency', widget.translationsCache),
              style: AppTypography.sectionHeading,
            ),
            SizedBox(height: AppSpacing.lg),

            // TODO: Implement LanguageCurrencyDropdowns widget
            // TODO: Pass showDescriptions: true (shows subtext under labels)
            // This differs from App Settings Initiate Flow where descriptions are hidden
            // For now, placeholder UI showing selected values
            _LanguageCurrencyPlaceholder(
              languageCode: widget.languageCode,
              translationsCache: widget.translationsCache,
              selectedLanguage: _selectedLanguage,
              selectedCurrency: _selectedCurrency,
              onLanguageChange: (value) => setState(() => _selectedLanguage = value),
              onCurrencyChange: (value) => setState(() => _selectedCurrency = value),
            ),

            SizedBox(height: AppSpacing.huge),

            // Divider
            Container(
              height: 1,
              color: AppColors.divider, // ✅ Changed from borderSubtle
            ),
            SizedBox(height: AppSpacing.xxxl),

            // Location Section
            Text(
              getTranslations(widget.languageCode, 'localization_section_location', widget.translationsCache),
              style: AppTypography.sectionHeading,
            ),
            SizedBox(height: AppSpacing.sm),

            // Description
            Text(
              getTranslations(widget.languageCode, 'localization_location_desc', widget.translationsCache),
              style: AppTypography.bodySmall.copyWith(
                height: 1.38, // 18px / 13px
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            // Current Status Card
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.card), // ✅ Changed from AppRadius.input
                border: Border.all(
                  color: AppColors.border,
                  width: 1.5,
                ),
                color: AppColors.bgSurface,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Icon + Label
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 20,
                            color: AppColors.textTertiary, // ✅ Changed from hardcoded #666
                          ),
                          SizedBox(width: AppSpacing.sm), // ✅ Changed from hardcoded 10
                          Text(
                            getTranslations(widget.languageCode, 'localization_location_sharing', widget.translationsCache),
                            style: AppTypography.label,
                          ),
                        ],
                      ),

                      // Status indicator
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _locationEnabled ? AppColors.green : AppColors.red,
                            ),
                          ),
                          // Note: Using 6px spacing between indicator dot and text
                          // Design system gap: No exact token (xs=4px, sm=8px)
                          SizedBox(width: 6),
                          Text(
                            _locationEnabled
                              ? getTranslations(widget.languageCode, 'localization_location_enabled', widget.translationsCache)
                              : getTranslations(widget.languageCode, 'localization_location_disabled', widget.translationsCache),
                            style: AppTypography.bodySmall.copyWith(
                              color: _locationEnabled ? AppColors.green : AppColors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.xs),

                  // Status description
                  Text(
                    _locationEnabled
                        ? getTranslations(widget.languageCode, 'localization_location_desc_enabled', widget.translationsCache)
                        : getTranslations(widget.languageCode, 'localization_location_desc_disabled', widget.translationsCache),
                    style: AppTypography.bodyTiny,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.md),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: AppConstants.buttonHeight, // ✅ Changed from hardcoded 48
              child: _locationEnabled
                  ? OutlinedButton(
                      onPressed: () {
                        // TODO: Navigate to location-sharing page
                        // TODO: Add markUserEngaged() call
                      },
                      style: AppButtonStyles.secondary, // Already defines AppRadius.button
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            getTranslations(widget.languageCode, 'localization_button_manage', widget.translationsCache),
                            // Note: 15px w600 button text - no exact typography token
                            // Design system gap: Closest is button (16px w600)
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: AppColors.textDisabled, // ✅ Changed from hardcoded #BBB
                          ),
                        ],
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        // TODO: Request location permission
                        // TODO: Add markUserEngaged() call
                        setState(() => _locationEnabled = true);
                      },
                      style: AppButtonStyles.primary, // ✅ Use convenience method
                      child: Text(
                        getTranslations(widget.languageCode, 'localization_button_enable', widget.translationsCache),
                        // Note: 15px w600 button text - no exact typography token
                        // Design system gap: Closest is button (16px w600)
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),

            // Privacy note (only shown when disabled)
            if (!_locationEnabled) ...[
              SizedBox(height: AppSpacing.md),
              Text(
                getTranslations(widget.languageCode, 'localization_privacy_note', widget.translationsCache),
                // Note: 11px privacy text - no exact typography token
                // Design system gap: Smallest token is bodyTiny (12px w400)
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textPlaceholder,
                  height: 1.27, // 14px / 11px
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Placeholder for LanguageCurrencyDropdowns component
/// TODO: Implement full dropdown functionality with proper UI
class _LanguageCurrencyPlaceholder extends StatelessWidget {
  final String languageCode;
  final Map<String, dynamic> translationsCache;
  final String selectedLanguage;
  final String selectedCurrency;
  final ValueChanged<String> onLanguageChange;
  final ValueChanged<String> onCurrencyChange;

  const _LanguageCurrencyPlaceholder({
    required this.languageCode,
    required this.translationsCache,
    required this.selectedLanguage,
    required this.selectedCurrency,
    required this.onLanguageChange,
    required this.onCurrencyChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Language selector
        // Note: Using categoryHeading (16px w700) with w600 override
        // Design system gap: No token for 16px w600
        Text(
          getTranslations(languageCode, 'localization_field_language', translationsCache),
          style: AppTypography.categoryHeading.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          getTranslations(languageCode, 'localization_field_language_desc', translationsCache),
          style: AppTypography.bodySmall.copyWith(
            height: 1.38, // 18px / 13px
          ),
        ),
        SizedBox(height: AppSpacing.md),

        // TODO: Replace with actual dropdown
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppConstants.cardPadding, // 14px - semantically correct for UI chrome padding
          ),
          decoration: BoxDecoration(
            // Note: 10px radius is canonical for language/currency selector widgets
            // JSX design specifies 10px (AppRadius.filter), not 12px (AppRadius.input)
            borderRadius: BorderRadius.circular(AppRadius.filter), // 10px
            border: Border.all(color: AppColors.border),
            color: AppColors.bgInput,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getLanguageName(selectedLanguage),
                style: AppTypography.input,
              ),
              Icon(
                Icons.arrow_drop_down,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.xxxl),

        // Currency selector
        // Note: Using categoryHeading (16px w700) with w600 override
        // Design system gap: No token for 16px w600
        Text(
          getTranslations(languageCode, 'localization_field_currency', translationsCache),
          style: AppTypography.categoryHeading.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          getTranslations(languageCode, 'localization_field_currency_desc', translationsCache),
          style: AppTypography.bodySmall.copyWith(
            height: 1.38, // 18px / 13px
          ),
        ),
        SizedBox(height: AppSpacing.md),

        // TODO: Replace with actual dropdown
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppConstants.cardPadding, // 14px - semantically correct for UI chrome padding
          ),
          decoration: BoxDecoration(
            // Note: 10px radius is canonical for language/currency selector widgets
            // JSX design specifies 10px (AppRadius.filter), not 12px (AppRadius.input)
            borderRadius: BorderRadius.circular(AppRadius.filter), // 10px
            border: Border.all(color: AppColors.border),
            color: AppColors.bgInput,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getCurrencyName(selectedCurrency),
                style: AppTypography.input,
              ),
              Icon(
                Icons.arrow_drop_down,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getLanguageName(String code) {
    final languages = {
      'en': '🇬🇧 English',
      'da': '🇩🇰 Dansk',
      'de': '🇩🇪 Deutsch',
      'sv': '🇸🇪 Svenska',
      'no': '🇳🇴 Norsk',
      'it': '🇮🇹 Italiano',
      'fr': '🇫🇷 Français',
    };
    return languages[code] ?? languages['en']!;
  }

  String _getCurrencyName(String code) {
    final currencies = {
      'USD': '\$ US dollar',
      'GBP': '£ British pound',
      'DKK': 'kr. Danish krone',
    };
    return currencies[code] ?? currencies['USD']!;
  }
}
