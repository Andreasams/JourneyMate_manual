import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/business_providers.dart';
import '../../services/api_service.dart';
import '../../services/translation_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_constants.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';
import 'bottom_sheet_header.dart';

/// A bottom sheet form for reporting incorrect or missing business information.
///
/// Displays within a modal bottom sheet and allows users to submit corrections
/// for the currently viewed business. Styled consistently with ItemDetailSheet.
///
/// **State Management:**
/// - Uses local state variables for form validation and submission status
/// - Reads current business data from `currentBusinessProvider`
///
/// **Features:**
/// - Minimum 10-character message validation
/// - Real-time error clearing on user input
/// - Three-state UI: default / success / error
/// - API submission to BuildShip `/erroneousinfo` endpoint
/// - Graceful error handling with retry capability
class ErroneousInfoFormWidget extends ConsumerStatefulWidget {
  const ErroneousInfoFormWidget({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  ConsumerState<ErroneousInfoFormWidget> createState() =>
      _ErroneousInfoFormWidgetState();
}

class _ErroneousInfoFormWidgetState
    extends ConsumerState<ErroneousInfoFormWidget> {
  // ─────────────────────────────────────────────────────────────────────────────
  // Form State
  // ─────────────────────────────────────────────────────────────────────────────
  final _messageController = TextEditingController();

  String? _messageError;
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  String? _submissionError;

  // ─────────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Validation
  // ─────────────────────────────────────────────────────────────────────────────
  bool _validateForm() {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      setState(() {
        _messageError = td(ref, 'erroneous_info_error_message_required');
      });
      return false;
    }

    if (message.length < 10) {
      setState(() {
        _messageError = td(ref, 'contact_form_error_message_too_short');
      });
      return false;
    }

    setState(() {
      _messageError = null;
    });
    return true;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // API Submission
  // ─────────────────────────────────────────────────────────────────────────────
  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    if (!_validateForm()) return;

    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });

    try {
      final currentBusiness = ref.read(businessProvider);
      final businessId =
          currentBusiness.currentBusiness?['business_id'] as int? ?? 0;
      final businessName =
          currentBusiness.currentBusiness?['business_name'] as String? ?? '';
      final languageCode = Localizations.localeOf(context).languageCode;

      final response = await ApiService.instance.postErroneousInfo(
        businessId: businessId,
        businessName: businessName,
        message: _messageController.text.trim(),
        languageCode: languageCode,
      );

      if (!context.mounted) return;

      if (response.succeeded) {
        setState(() {
          _isSubmitted = true;
          _isSubmitting = false;
        });
      } else {
        setState(() {
          _submissionError =
              td(ref, 'erroneous_info_error_submission_failed');
          _isSubmitting = false;
        });
      }
    } catch (e) {
      if (!context.mounted) return;
      setState(() {
        _submissionError = td(ref, 'erroneous_info_error_network');
        _isSubmitting = false;
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Build: Main
  // ─────────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final currentBusiness = ref.watch(businessProvider).currentBusiness;
    final businessName = currentBusiness?['business_name'] as String? ?? '';
    final street = currentBusiness?['street'] as String? ?? '';
    final postalCode = currentBusiness?['postal_code'] as String? ?? '';
    final city = currentBusiness?['postal_city'] as String? ?? '';
    final address = '$street, $postalCode $city';

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BottomSheetHeader.sheetDecoration(color: AppColors.bgPage),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomSheetHeader(
            leftAction: BottomSheetAction(
              icon: Icons.close,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxxl - 4, // 28px
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBusinessInfoSection(businessName, address),
                    const SizedBox(height: AppSpacing.xl + 4), // 20px
                    _buildMessageSection(),
                    const SizedBox(height: AppSpacing.xl + 4), // 20px
                    _buildSubmitArea(),
                    const SizedBox(height: AppSpacing.xl + 4), // 20px
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Build: Business Info Section
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildBusinessInfoSection(String businessName, String address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main title
        Text(
          td(ref, 'about_report_incorrect_info'),
          style: AppTypography.h1.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xl + 4), // 20px

        // "Reporting information for" label
        Text(
          td(ref, 'erroneous_info_subtitle_reporting_for'),
          style: AppTypography.bodyLg.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),

        // Business name
        Text(
          businessName,
          style: AppTypography.h3,
        ),

        // Business address
        Text(
          address,
          style: AppTypography.bodyLg.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Help text
        Text(
          td(ref, 'erroneous_info_subtitle_main'),
          style: AppTypography.bodyLg.copyWith(
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Build: Message Section
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildMessageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with required indicator
        RichText(
          text: TextSpan(
            style: AppTypography.h3,
            children: [
              TextSpan(
                text: td(ref, 'erroneous_info_title_message'),
              ),
              const TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.error),
              ),
            ],
          ),
        ),

        // Subtitle
        Text(
          td(ref, 'erroneous_info_subtitle_message'),
          style: AppTypography.bodyLg.copyWith(
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Text area with minimum 5 visible lines
        TextField(
            controller: _messageController,
            minLines: 5,
            maxLines: null,
            textAlignVertical: TextAlignVertical.top,
            style: AppTypography.bodyLg,
            decoration: InputDecoration(
              hintText: td(ref, 'erroneous_info_hint_message'),
              hintStyle: AppTypography.bodyLg.copyWith(
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
              filled: true,
              fillColor: AppColors.bgSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.chip),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.chip),
                borderSide: _messageError != null
                    ? const BorderSide(color: AppColors.error, width: 1)
                    : BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.chip),
                borderSide: _messageError != null
                    ? const BorderSide(color: AppColors.error, width: 1)
                    : BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.md),
            ),
            onChanged: (_) {
              if (_messageError != null) {
                setState(() => _messageError = null);
              }
            },
          ),

        // Error text
        if (_messageError != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              _messageError!,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Build: Submit Area
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildSubmitArea() {
    if (_isSubmitted) {
      return _buildSuccessMessage();
    }

    return Column(
      children: [
        if (_submissionError != null) ...[
          _buildErrorMessage(),
          const SizedBox(height: AppSpacing.sm),
        ],
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: AppColors.success, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: 32,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            td(ref, 'erroneous_info_success_message'),
            textAlign: TextAlign.center,
            style: AppTypography.h3.copyWith(
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            td(ref, 'contact_form_success_navigate_away'),
            textAlign: TextAlign.center,
            style: AppTypography.bodyLg.copyWith(
              fontWeight: FontWeight.w300,
              color: AppColors.success.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: AppColors.error, width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _submissionError!,
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: AppConstants.buttonHeight,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              )
            : Text(
                td(ref, 'erroneous_info_button_submit'),
                style: AppTypography.button.copyWith(
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
