// ============================================================
// APP SETTINGS INITIATE FLOW - Converted from JSX v2 Design
// Clean Flutter UI shell with no backend functionality
//
// Multi-step onboarding with language and currency setup
// This is the UI shell only - backend integration comes later
// ============================================================

import 'package:flutter/material.dart';
import '../../shared/app_theme.dart';

/// Helper function to retrieve translations
/// TODO: Replace with actual translation service once integrated
String getTranslations(
  String languageCode,
  String key,
  Map<String, dynamic> translationsCache,
) {
  // Temporary implementation - returns key until translation service is integrated
  return translationsCache[key]?[languageCode] ?? key;
}

class AppSettingsInitiateFlowPage extends StatefulWidget {
  final String languageCode;
  final Map<String, dynamic> translationsCache;

  const AppSettingsInitiateFlowPage({
    super.key,
    required this.languageCode,
    required this.translationsCache,
  });

  @override
  State<AppSettingsInitiateFlowPage> createState() =>
      _AppSettingsInitiateFlowPageState();
}

class _AppSettingsInitiateFlowPageState
    extends State<AppSettingsInitiateFlowPage> {
  // Mock state - TODO: Replace with actual state management
  String _selectedLanguage = 'en';
  String _selectedCurrency = 'DKK';

  // TODO: Replace with actual language/currency data
  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'da', 'name': 'Dansk', 'flag': '🇩🇰'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'sv', 'name': 'Svenska', 'flag': '🇸🇪'},
    {'code': 'no', 'name': 'Norsk', 'flag': '🇳🇴'},
    {'code': 'it', 'name': 'Italiano', 'flag': '🇮🇹'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
  ];

  final List<Map<String, String>> _currencies = [
    {'code': 'USD', 'name': 'US dollar', 'symbol': '\$'},
    {'code': 'GBP', 'name': 'British pound', 'symbol': '£'},
    {'code': 'DKK', 'name': 'Danish krone', 'symbol': 'kr.'},
  ];

  // Helper method to get language display name
  String _getLanguageDisplay(String code) {
    final lang = _languages.firstWhere(
      (l) => l['code'] == code,
      orElse: () => _languages[0],
    );
    return '${lang['flag']} ${lang['name']}';
  }

  // Helper method to get currency display name
  String _getCurrencyDisplay(String code) {
    final curr = _currencies.firstWhere(
      (c) => c['code'] == code,
      orElse: () => _currencies[2],
    );
    return '${curr['name']} (${curr['symbol']})';
  }

  // TODO: Add actual complete setup handler with SearchAPI call
  void _handleCompleteSetup() {
    debugPrint('Complete setup tapped');
    debugPrint('Selected language: $_selectedLanguage');
    debugPrint('Selected currency: $_selectedCurrency');
    // TODO: Call SearchAPI with selected language
    // TODO: Store results in FFAppState().businesses
    // TODO: Navigate to SearchResults
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.xxl), // 24px
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Simple divider at top
              Container(
                height: 1,
                color: AppColors.divider, // #f2f2f2
              ),
              SizedBox(height: AppSpacing.xxxl), // 32px

              // Heading
              Text(
                getTranslations(widget.languageCode, 'onboarding_localization_heading', widget.translationsCache),
                style: AppTypography.pageTitle.copyWith(
                  fontSize: 22, // Design gap: between sectionHeading (18px) and pageTitle (24px)
                ),
              ),
              SizedBox(height: AppSpacing.sm), // 8px

              // Description
              Text(
                getTranslations(widget.languageCode, 'onboarding_localization_desc', widget.translationsCache),
                style: AppTypography.bodyRegular,
              ),
              SizedBox(height: AppSpacing.xxxl), // 32px

              // Language & Currency Dropdowns
              // TODO: Replace with actual LanguageSelectorButton and CurrencySelectorButton
              // TODO: Pass translationsCache and currentLanguage/currentCurrency props
              // TODO: CRITICAL - Pass showDescriptions: false (no subtext under labels)
              // This differs from Localization settings page where descriptions ARE shown
              _LanguageCurrencyDropdownsPlaceholder(
                languageCode: widget.languageCode,
                translationsCache: widget.translationsCache,
                selectedLanguage: _selectedLanguage,
                selectedCurrency: _selectedCurrency,
                languageDisplay: _getLanguageDisplay(_selectedLanguage),
                currencyDisplay: _getCurrencyDisplay(_selectedCurrency),
                onLanguageChange: (code) {
                  setState(() {
                    _selectedLanguage = code;
                  });
                },
                onCurrencyChange: (code) {
                  setState(() {
                    _selectedCurrency = code;
                  });
                },
                languages: _languages,
                currencies: _currencies,
              ),

              SizedBox(height: AppSpacing.huge), // 40px

              // Complete setup button
              SizedBox(
                width: double.infinity,
                height: AppConstants.buttonHeight, // 50px
                child: ElevatedButton(
                  onPressed: _handleCompleteSetup,
                  style: AppButtonStyles.primary,
                  child: Text(
                    getTranslations(widget.languageCode, 'onboarding_complete_setup', widget.translationsCache),
                    style: AppTypography.button,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PLACEHOLDER WIDGET FOR LANGUAGE & CURRENCY DROPDOWNS
// TODO: Replace with actual LanguageSelectorButton and CurrencySelectorButton
// ============================================================

/// Placeholder for LanguageCurrencyDropdowns component
/// Shows basic dropdown UI structure, non-interactive for now
class _LanguageCurrencyDropdownsPlaceholder extends StatelessWidget {
  final String languageCode;
  final Map<String, dynamic> translationsCache;
  final String selectedLanguage;
  final String selectedCurrency;
  final String languageDisplay;
  final String currencyDisplay;
  final Function(String) onLanguageChange;
  final Function(String) onCurrencyChange;
  final List<Map<String, String>> languages;
  final List<Map<String, String>> currencies;

  const _LanguageCurrencyDropdownsPlaceholder({
    required this.languageCode,
    required this.translationsCache,
    required this.selectedLanguage,
    required this.selectedCurrency,
    required this.languageDisplay,
    required this.currencyDisplay,
    required this.onLanguageChange,
    required this.onCurrencyChange,
    required this.languages,
    required this.currencies,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Language Section
        Text(
          getTranslations(widget.languageCode, 'onboarding_language_label', widget.translationsCache),
          // Note: Using categoryHeading (16px w700) with w600 override
          // Design system gap: No token for 16px w600
          style: AppTypography.categoryHeading.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.md), // 12px

        // Language Dropdown
        _DropdownButton(
          displayText: languageDisplay,
          onTap: () {
            // TODO: Implement actual dropdown with LanguageSelectorButton
            debugPrint('Language dropdown tapped');
          },
        ),
        SizedBox(height: AppSpacing.xxxl), // 32px (built into component)

        // Currency Section
        Text(
          getTranslations(widget.languageCode, 'onboarding_currency_label', widget.translationsCache),
          // Note: Using categoryHeading (16px w700) with w600 override
          // Design system gap: No token for 16px w600
          style: AppTypography.categoryHeading.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.md), // 12px

        // Currency Dropdown
        _DropdownButton(
          displayText: currencyDisplay,
          onTap: () {
            // TODO: Implement actual dropdown with CurrencySelectorButton
            debugPrint('Currency dropdown tapped');
          },
        ),
      ],
    );
  }
}

/// Placeholder dropdown button matching JSX styling
class _DropdownButton extends StatelessWidget {
  final String displayText;
  final VoidCallback onTap;

  const _DropdownButton({
    required this.displayText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      // Note: 10px radius is canonical for language/currency selector widgets
      // JSX design specifies 10px (AppRadius.filter), not 12px (AppRadius.input)
      borderRadius: BorderRadius.circular(AppRadius.filter), // 10px
      child: Container(
        height: AppConstants.inputHeight, // 50px
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg), // 16px
        decoration: BoxDecoration(
          color: AppColors.bgInput, // #f5f5f5
          // Note: 10px radius is canonical for language/currency selector widgets
          borderRadius: BorderRadius.circular(AppRadius.filter), // 10px
          border: Border.all(color: AppColors.border), // #e8e8e8
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              displayText,
              style: AppTypography.input,
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: AppColors.textTertiary, // #888
            ),
          ],
        ),
      ),
    );
  }
}
