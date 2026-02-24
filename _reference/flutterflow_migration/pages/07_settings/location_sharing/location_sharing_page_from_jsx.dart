// ============================================================
// LOCATION SHARING PAGE - Converted from JSX v2 Design
// Clean Flutter UI shell with no backend functionality
//
// Simple CTA page to enable location sharing
// ============================================================

import 'package:flutter/material.dart';
import '../../../shared/app_theme.dart';

/// Translation helper function
String getTranslations(String languageCode, String key, Map<String, dynamic> cache) {
  return cache[key]?[languageCode] ?? key;
}

class LocationSharingPage extends StatelessWidget {
  final String languageCode;
  final Map<String, dynamic> translationsCache;

  const LocationSharingPage({
    super.key,
    required this.languageCode,
    required this.translationsCache,
  });

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
          getTranslations(languageCode, 'location_sharing_title', translationsCache),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.xxxl,
            AppSpacing.xxl,
            AppSpacing.xxl,
          ),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Heading
            // Note: 22px sits between sectionHeading (18px) and pageTitle (24px)
            // Design system gap: No token exists for 22px w700
            // Using pageTitle as closest match
            Text(
              getTranslations(languageCode, 'location_sharing_heading', translationsCache),
              style: AppTypography.pageTitle.copyWith(
                fontSize: 22, // Design gap: between sectionHeading and pageTitle
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),

            // Description
            Text(
              getTranslations(languageCode, 'location_sharing_desc', translationsCache),
              style: AppTypography.bodyRegular.copyWith(
                height: 1.43, // 20px / 14px
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xxl),

            // CTA button
            SizedBox(
              width: double.infinity,
              height: AppConstants.buttonHeight,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Request location permission
                  // TODO: Add markUserEngaged() call
                  // TODO: Navigate back or show success state
                },
                style: AppButtonStyles.primary, // ✅ Use convenience method
                child: Text(
                  getTranslations(languageCode, 'location_sharing_button_enable', translationsCache),
                  style: AppTypography.button,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xxl),

            // Privacy info
            // Note: Using bodySmall (13px w500) instead of inline 13px w400
            // Design system gap: bodySmall is w500, not w400
            Text(
              getTranslations(languageCode, 'location_sharing_privacy_note', translationsCache),
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w400, // Override to match design (w400 not w500)
                height: 1.38, // 18px / 13px
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
        ),
    );
  }
}
