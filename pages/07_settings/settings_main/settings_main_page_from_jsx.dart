// ============================================================
// SETTINGS MAIN PAGE - Converted from JSX v2 Design
// Clean Flutter UI shell with no backend functionality
//
// Navigation hub with three sections:
// 1. My JourneyMate (Localization)
// 2. Reach out (Missing place, Share feedback, Contact us)
// 3. Resources (Terms of use, Privacy policy)
// ============================================================

import 'package:flutter/material.dart';
import '../../../shared/app_theme.dart';

// Translation helper function
String getTranslations(
  String languageCode,
  String key,
  Map<String, Map<String, String>> translationsCache,
) {
  return translationsCache[key]?[languageCode] ?? key;
}

class SettingsMainPage extends StatelessWidget {
  final String languageCode;
  final Map<String, Map<String, String>> translationsCache;

  const SettingsMainPage({
    super.key,
    required this.languageCode,
    required this.translationsCache,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.lg,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  getTranslations(languageCode, 'settings_main_title', translationsCache),
                  style: AppTypography.pageTitle.copyWith(
                    color: AppColors.accent, // Orange accent for this page
                  ),
                ),
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // My JourneyMate section
                    _SectionHeader(
                      title: getTranslations(languageCode, 'settings_section_my_journeymate', translationsCache),
                    ),
                    _SettingsRow(
                      icon: Icons.language,
                      label: getTranslations(languageCode, 'settings_localization', translationsCache),
                      onTap: () {
                        // TODO: Navigate to localization page
                        // TODO: Add markUserEngaged() call
                      },
                    ),
                    SizedBox(height: AppSpacing.xxl),

                    // Reach out section
                    _SectionHeader(
                      title: getTranslations(languageCode, 'settings_section_reach_out', translationsCache),
                    ),
                    _SettingsRow(
                      icon: Icons.add_location_alt_outlined,
                      label: getTranslations(languageCode, 'settings_missing_place', translationsCache),
                      onTap: () {
                        // TODO: Navigate to missing place page
                        // TODO: Add markUserEngaged() call
                      },
                    ),
                    _SettingsRow(
                      icon: Icons.chat_bubble_outline,
                      label: getTranslations(languageCode, 'settings_share_feedback', translationsCache),
                      onTap: () {
                        // TODO: Navigate to share feedback page
                        // TODO: Add markUserEngaged() call
                      },
                    ),
                    _SettingsRow(
                      icon: Icons.mail_outline,
                      label: getTranslations(languageCode, 'settings_contact_us', translationsCache),
                      onTap: () {
                        // TODO: Navigate to contact us page
                        // TODO: Add markUserEngaged() call
                      },
                    ),
                    SizedBox(height: AppSpacing.xxl),

                    // Resources section
                    _SectionHeader(
                      title: getTranslations(languageCode, 'settings_section_resources', translationsCache),
                    ),
                    _SettingsRow(
                      icon: Icons.description_outlined,
                      label: getTranslations(languageCode, 'settings_terms', translationsCache),
                      onTap: () {
                        // TODO: Navigate to terms page
                        // TODO: Add markUserEngaged() call
                      },
                    ),
                    _SettingsRow(
                      icon: Icons.shield_outlined,
                      label: getTranslations(languageCode, 'settings_privacy', translationsCache),
                      onTap: () {
                        // TODO: Navigate to privacy page
                        // TODO: Add markUserEngaged() call
                      },
                    ),
                  ],
                ),
              ),
            ),

            // TODO: Add TabBar widget here (from shared widgets)
            // TabBar(activeTab: 'profil', onChangeTab: ...)
          ],
        ),
      ),
    );
  }
}

/// Section header widget
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Text(
        title,
        // Note: Using bodyMedium (14px w500) - closest token to 14px w600
        // Design system gap: No token exists for 14px w600
        style: AppTypography.bodyMedium,
      ),
    );
  }
}

/// Settings row widget with icon, label, and chevron
class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppConstants.cardPadding, // 14px - semantically correct for row padding
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.divider,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Icon
            Icon(
              icon,
              size: 18,
              color: AppColors.textTertiary, // #888 - closest semantic match to #666
            ),
            SizedBox(width: AppSpacing.md),

            // Label
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyRegular,
              ),
            ),

            // Chevron
            Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textDisabled, // #BBBBBB - exact match
            ),
          ],
        ),
      ),
    );
  }
}
