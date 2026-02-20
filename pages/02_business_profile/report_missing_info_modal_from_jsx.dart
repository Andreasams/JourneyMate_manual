// ============================================================
// REPORT MISSING INFORMATION MODAL - Converted from JSX v2 Design
// Clean Flutter UI shell with no backend functionality
//
// Modal for reporting incorrect/missing business information
// Features: restaurant info display, textarea form, submit button
// This is the UI shell only - backend integration comes later
// ============================================================

import 'package:flutter/material.dart';
import '../../shared/app_theme.dart';

// TODO: Import when backend integrated
// import '/flutter_flow/flutter_flow_util.dart';
// import '/custom_code/actions/index.dart' as actions;

/// Translation helper function
/// TODO: Wire up when backend is integrated
/// For now, returns the key as a placeholder
String getTranslations(String languageCode, String key, dynamic translationsCache) {
  // TODO: Implement translation lookup from translationsCache
  // This is a placeholder that will be replaced with actual translation logic
  return key;
}

/// Shows report missing info modal
///
/// Usage:
/// ```dart
/// showReportMissingInfoModal(
///   context,
///   restaurant: restaurantData,
///   languageCode: 'da',
///   translationsCache: translationsCache,
///   onSubmit: (message) {
///     // Handle submission
///   },
/// );
/// ```
void showReportMissingInfoModal(
  BuildContext context, {
  required Map<String, dynamic> restaurant,
  String languageCode = 'da',
  dynamic translationsCache,
  required Function(String message) onSubmit,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (context) => ReportMissingInfoModal(
      restaurant: restaurant,
      languageCode: languageCode,
      translationsCache: translationsCache,
      onSubmit: onSubmit,
    ),
  );
}

class ReportMissingInfoModal extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  final String languageCode;
  final dynamic translationsCache;
  final Function(String message) onSubmit;

  const ReportMissingInfoModal({
    super.key,
    required this.restaurant,
    this.languageCode = 'da', // TODO: Get from FFLocalizations.of(context).languageCode
    this.translationsCache, // TODO: Get from FFAppState().translationsCache
    required this.onSubmit,
  });

  @override
  State<ReportMissingInfoModal> createState() => _ReportMissingInfoModalState();
}

class _ReportMissingInfoModalState extends State<ReportMissingInfoModal> {
  final TextEditingController _messageController = TextEditingController();

  bool get _isValid => _messageController.text.trim().isNotEmpty;

  void _handleSubmit() {
    if (_isValid) {
      widget.onSubmit(_messageController.text.trim());
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 360,
          maxHeight: MediaQuery.of(context).size.height * 0.7, // 70vh
        ),
        decoration: BoxDecoration(
          color: AppColors.bgPage, // JSX uses #fff for modal/sheet backgrounds
          borderRadius: BorderRadius.circular(AppRadius.card), // 16px
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Scrollable content
            SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.xxl), // 24px
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Padding(
                    padding: EdgeInsets.only(right: AppSpacing.xxxl), // 32px for close button
                    child: Text(
                      getTranslations(widget.languageCode, 'report_modal_title', widget.translationsCache),
                      // Note: JSX uses 18px w680 - using sectionHeading (18px w700)
                      style: AppTypography.sectionHeading,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md), // 12px

                  // Restaurant info
                  Text(
                    getTranslations(widget.languageCode, 'report_modal_reporting_for', widget.translationsCache),
                    style: AppTypography.bodyTiny, // 12px
                  ),
                  // Note: 2px gap - design-specific value smaller than xs (4px)
                  SizedBox(height: 2),
                  Text(
                    widget.restaurant['name'] ?? 'Unknown Restaurant',
                    style: AppTypography.label, // 14px w500
                  ),
                  // Note: 1px gap - design-specific value smaller than xs (4px)
                  SizedBox(height: 1),
                  Text(
                    widget.restaurant['address'] ?? '',
                    style: AppTypography.bodyTiny, // 12px
                  ),
                  SizedBox(height: AppSpacing.lg), // 16px

                  // Help text
                  Text(
                    getTranslations(widget.languageCode, 'report_modal_help_text', widget.translationsCache),
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.38, // 18px / 13px
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg), // 16px

                  // Form label
                  RichText(
                    text: TextSpan(
                      text: getTranslations(widget.languageCode, 'report_modal_field_label', widget.translationsCache),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      children: const [
                        TextSpan(
                          text: '*',
                          style: TextStyle(color: AppColors.red),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),

                  // Helper text
                  Text(
                    getTranslations(widget.languageCode, 'report_modal_field_helper', widget.translationsCache),
                    // Note: 11px text - no exact typography token
                    // Design system gap: Smallest token is bodyTiny (12px w400)
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm), // 8px

                  // Text area
                  TextField(
                    controller: _messageController,
                    maxLines: 5,
                    minLines: 4,
                    decoration: AppInputDecorations.multiline(
                      hintText: getTranslations(widget.languageCode, 'report_modal_field_placeholder', widget.translationsCache),
                    ),
                    style: AppTypography.input,
                    onChanged: (_) => setState(() {}), // Update button state
                  ),
                  SizedBox(height: AppSpacing.lg), // 16px

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: AppConstants.buttonHeight, // 50px
                    child: ElevatedButton(
                      onPressed: _isValid ? _handleSubmit : null,
                      // Modal submit button: JSX uses borderRadius 12px, not standard button 14px
                      // Using styleFrom directly rather than patching AppButtonStyles.primary
                      // TODO: Consider adding AppButtonStyles.primaryModal variant
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.border, // #ddd equivalent
                        disabledForegroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.input), // 12px — modal exception
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        getTranslations(widget.languageCode, 'report_modal_submit', widget.translationsCache),
                        style: AppTypography.button,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Close button - positioned absolutely
            Positioned(
              top: AppSpacing.md, // 12px
              right: AppSpacing.md,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                iconSize: 18,
                color: AppColors.textTertiary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                style: IconButton.styleFrom(
                  shape: const CircleBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
