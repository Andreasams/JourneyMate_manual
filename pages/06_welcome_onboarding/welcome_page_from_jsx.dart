// ============================================================
// WELCOME PAGE - Converted from JSX v2 Design
// Clean Flutter UI shell with no backend functionality
//
// Two JSX variants combined into one Flutter widget:
// 1. welcome_new_user.jsx - Shows TWO buttons
// 2. welcome_returning_user.jsx - Shows ONE button
//
// Conditional rendering based on userLanguageCode state
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

class WelcomePage extends StatefulWidget {
  final String languageCode;
  final Map<String, dynamic> translationsCache;

  const WelcomePage({
    super.key,
    required this.languageCode,
    required this.translationsCache,
  });

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  // Mock state - TODO: Replace with actual state management
  String? _userLanguageCode; // null = new user, 'en'/'da' = returning user

  @override
  Widget build(BuildContext context) {
    // Determine if user is returning (has language set)
    final isReturningUser = _userLanguageCode != null && _userLanguageCode!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.bgPage, // Pure white, but use token for consistency
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxxl), // JSX: 32px
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Heading
                Text(
                  isReturningUser
                      ? getTranslations(widget.languageCode, 'welcome_heading_returning_da', widget.translationsCache)
                      : getTranslations(widget.languageCode, 'welcome_heading_new', widget.translationsCache),
                  textAlign: TextAlign.center,
                  // Note: 28px w700 from JSX - design gap
                  // pageTitle is 24px w700, sectionHeading is 18px w700
                  // Using pageTitle with fontSize override
                  style: AppTypography.pageTitle.copyWith(
                    fontSize: 28,
                    height: 34 / 28, // JSX: 34px line-height
                  ),
                ),

                SizedBox(height: AppSpacing.huge), // JSX: 40px - exact match

                // Mascot image
                Image.asset(
                  'assets/images/journeymate_mascot.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback if image doesn't exist
                    return Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.bgInput,
                        borderRadius: BorderRadius.circular(AppRadius.chip), // 8px
                      ),
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                    );
                  },
                ),

                SizedBox(height: AppSpacing.huge), // JSX: 40px - exact match

                // Tagline - "Go out, your way."
                Text(
                  getTranslations(widget.languageCode, 'welcome_tagline', widget.translationsCache),
                  textAlign: TextAlign.center,
                  // Note: 18px w500 from JSX - design gap
                  // sectionHeading is 18px w700, need w500
                  // Using sectionHeading with fontWeight override
                  style: AppTypography.sectionHeading.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: AppSpacing.md), // JSX: 12px - exact match

                // Description
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 320), // JSX: maxWidth 320px
                  child: Text(
                    isReturningUser
                        ? getTranslations(widget.languageCode, 'welcome_description_da', widget.translationsCache)
                        : getTranslations(widget.languageCode, 'welcome_description_en', widget.translationsCache),
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyRegular.copyWith(
                      color: AppColors.textSecondary, // JSX: #555
                      height: 20 / 14, // JSX: 20px line-height / 14px font-size
                    ),
                  ),
                ),

                // Note: 48px spacing from JSX - design gap
                // No token exists (huge=40px, xxxl=32px)
                SizedBox(height: 48),

                // Buttons section
                _buildButtons(isReturningUser),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(bool isReturningUser) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 280), // JSX: maxWidth 280px
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Continue button (always shown)
          SizedBox(
            height: AppConstants.buttonHeight, // JSX: 50px height
            child: ElevatedButton(
              onPressed: () {
                // TODO: Add navigation logic
                // New user → Navigate to AppSettingsInitiateFlow
                // Returning user → Call SearchAPI + Navigate to SearchResults
              },
              style: AppButtonStyles.primary,
              child: Text(
                isReturningUser
                    ? getTranslations(widget.languageCode, 'welcome_button_continue_da', widget.translationsCache)
                    : getTranslations(widget.languageCode, 'welcome_button_continue_en', widget.translationsCache),
                style: AppTypography.button,
              ),
            ),
          ),

          // Danish button (only shown for new users)
          if (!isReturningUser) ...[
            SizedBox(height: AppSpacing.md), // JSX: 12px - exact match

            SizedBox(
              height: AppConstants.buttonHeight,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Add Danish onboarding logic
                  // Set language to 'da'
                  // Set currency to 'DKK'
                  // Load Danish translations
                  // Call SearchAPI with language='da'
                  // Navigate to SearchResults
                },
                // Note: Design system gap - accent-outlined button pattern
                // AppButtonStyles.secondary uses grey border/text (AppColors.border)
                // This button needs orange border/text (AppColors.accent)
                // TODO: Add AppButtonStyles.accentOutlined to design system
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  side: BorderSide(
                    color: AppColors.accent,
                    width: 2, // JSX: 2px border
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                ),
                child: Text(
                  getTranslations(widget.languageCode, 'welcome_button_continue_danish', widget.translationsCache),
                  style: AppTypography.button.copyWith(
                    color: AppColors.accent, // Override white to orange
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
