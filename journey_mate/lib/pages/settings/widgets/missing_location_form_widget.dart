import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';
import '../../../services/translation_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_constants.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_radius.dart';

/// A form widget that allows users to report missing restaurant locations.
///
/// **Features:**
/// - 3 required fields: business name, address, message (10+ chars)
/// - Client-side validation with inline error messages
/// - Real-time error clearing on user input
/// - API submission to BuildShip `/missingplace` endpoint
/// - 3 UI states: default form, success message, error message
/// - Full translation support (18 translation keys)
///
/// **FlutterFlow source:**
/// `_flutterflow_export/lib/custom_code/widgets/missing_location_form_widget.dart`
///
/// **MASTER_README:**
/// `shared/widgets/MASTER_README_missing_location_form_widget.md`
///
/// **Design decisions:**
/// - FlutterFlow used #E9874B for button and #249689 for success state
/// - This implementation uses AppColors.accent (#e8751a) and AppColors.success (#1a9456)
/// - Rationale: Design system compliance > pixel-perfect FlutterFlow match
///
/// **Usage:**
/// ```dart
/// // In bottom sheet:
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   builder: (context) => const MissingLocationFormWidget(),
/// );
/// ```
class MissingLocationFormWidget extends ConsumerStatefulWidget {
  const MissingLocationFormWidget({super.key});

  @override
  ConsumerState<MissingLocationFormWidget> createState() =>
      _MissingLocationFormWidgetState();
}

class _MissingLocationFormWidgetState
    extends ConsumerState<MissingLocationFormWidget> {
  // ============================================================
  // CONTROLLERS
  // ============================================================
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessAddressController =
      TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // ============================================================
  // STATE VARIABLES
  // ============================================================
  String? _businessNameError;
  String? _businessAddressError;
  String? _messageError;
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  String? _submissionError;

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // ============================================================
  // VALIDATION LOGIC
  // ============================================================

  /// Validates all form fields and updates error state.
  /// Returns true if all fields are valid, false otherwise.
  bool _validateForm() {
    bool isValid = true;

    setState(() {
      // Clear all errors first
      _businessNameError = null;
      _businessAddressError = null;
      _messageError = null;

      // Validate business name
      final businessName = _businessNameController.text.trim();
      if (businessName.isEmpty) {
        _businessNameError =
            td(ref, 'missing_location_error_name_required');
        isValid = false;
      }

      // Validate business address
      final businessAddress = _businessAddressController.text.trim();
      if (businessAddress.isEmpty) {
        _businessAddressError =
            td(ref, 'missing_location_error_address_required');
        isValid = false;
      }

      // Validate message
      final message = _messageController.text.trim();
      if (message.isEmpty) {
        _messageError = td(ref, 'missing_location_error_message_required');
        isValid = false;
      } else if (message.length < 10) {
        _messageError = td(ref, 'missing_location_error_message_too_short');
        isValid = false;
      }
    });

    return isValid;
  }

  // ============================================================
  // API SUBMISSION
  // ============================================================

  /// Handles form submission: validates, calls API, updates UI state.
  Future<void> _handleSubmit() async {
    // Prevent double-submission
    if (_isSubmitting) return;

    // Validate all fields
    if (!_validateForm()) return;

    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });

    try {
      // Get language code from Flutter's locale system
      final locale = Localizations.localeOf(context);
      final languageCode = locale.languageCode;

      final response = await ApiService.instance.submitMissingPlace(
        businessName: _businessNameController.text.trim(),
        businessAddress: _businessAddressController.text.trim(),
        message: _messageController.text.trim(),
        languageCode: languageCode,
      );

      if (!response.succeeded) {
        throw Exception(response.error ?? 'Submission failed');
      }

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isSubmitted = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _submissionError = e.toString();
        });
      }
    }
  }

  // ============================================================
  // BUILD METHOD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = keyboardHeight > 0
        ? keyboardHeight + AppSpacing.lg
        : AppSpacing.xxxl;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        bottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIntroductionSection(),
          const SizedBox(height: 28), // xxxl (32) minus 4px for tighter first gap
          _buildBusinessNameSection(),
          const SizedBox(height: AppSpacing.xxl), // Increased from xxxl (32) to xxl (24)
          _buildBusinessAddressSection(),
          const SizedBox(height: AppSpacing.xxl), // Increased from xxxl (32) to xxl (24)
          _buildMessageSection(),
          const SizedBox(height: AppSpacing.huge),
          _buildSubmitArea(),
        ],
      ),
    );
  }

  // ============================================================
  // UI SECTIONS
  // ============================================================

  Widget _buildIntroductionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          td(ref, 'missing_location_title_main'),
          style: AppTypography.sectionHeading,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          td(ref, 'missing_location_subtitle_main_1'),
          style: AppTypography.subtitle,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          td(ref, 'missing_location_subtitle_main_2'),
          style: AppTypography.subtitle,
        ),
      ],
    );
  }

  Widget _buildBusinessNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequiredLabel(
          td(ref, 'missing_location_title_business_name'),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildTextField(
          controller: _businessNameController,
          hintText: td(ref, 'missing_location_hint_business_name'),
          maxLines: 1,
          errorText: _businessNameError,
        ),
      ],
    );
  }

  Widget _buildBusinessAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequiredLabel(
          td(ref, 'missing_location_title_business_address'),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          td(ref, 'missing_location_subtitle_business_address'),
          style: AppTypography.subtitle,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildTextField(
          controller: _businessAddressController,
          hintText: td(ref, 'missing_location_hint_business_address'),
          maxLines: 1,
          errorText: _businessAddressError,
        ),
      ],
    );
  }

  Widget _buildMessageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequiredLabel(
          td(ref, 'missing_location_title_message'),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          td(ref, 'missing_location_subtitle_message'),
          style: AppTypography.subtitle,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildTextField(
          controller: _messageController,
          hintText: td(ref, 'missing_location_hint_message'),
          maxLines: 6,
          errorText: _messageError,
        ),
      ],
    );
  }

  // ============================================================
  // SUBMIT AREA (3 STATES)
  // ============================================================

  Widget _buildSubmitArea() {
    if (_isSubmitted) {
      return _buildSuccessMessage();
    } else if (_submissionError != null) {
      return _buildErrorMessage();
    } else {
      return _buildSubmitButton();
    }
  }

  /// State 1: Default submit button
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: AppConstants.buttonHeight,
      child: TextButton(
        onPressed: _isSubmitting ? null : _handleSubmit,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.textDisabled;
            }
            return AppColors.accent;
          }),
          foregroundColor: WidgetStateProperty.all(AppColors.bgPage),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          elevation: WidgetStateProperty.all(0),
          minimumSize: WidgetStateProperty.all(Size.zero),
          shape: WidgetStateProperty.resolveWith((states) {
            final borderColor = states.contains(WidgetState.disabled)
                ? AppColors.textDisabled
                : AppColors.accent;
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.filter),
              side: BorderSide(color: borderColor, width: 1.5),
            );
          }),
          textStyle: WidgetStateProperty.all(AppTypography.button),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.bgPage),
                ),
              )
            : Text(td(ref, 'missing_location_button_submit')),
      ),
    );
  }

  /// State 2: Success message
  Widget _buildSuccessMessage() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(AppRadius.filter),
          border: Border.all(color: AppColors.success, width: 1),
        ),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: AppColors.success,
              size: 32.0,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              td(ref, 'missing_location_success_message'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.success,
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              td(ref, 'missing_location_success_navigate_away'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.success.withValues(alpha:0.8),
                fontSize: 13.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// State 3: Error message with retry button
  Widget _buildErrorMessage() {
    return Center(
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(AppRadius.filter),
              border: Border.all(color: AppColors.error, width: 1),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 32.0,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  td(ref, 'missing_location_error_submission'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildSubmitButton(), // Retry button
        ],
      ),
    );
  }

  // ============================================================
  // REUSABLE UI BUILDERS
  // ============================================================

  /// Builds a label with red asterisk for required fields
  Widget _buildRequiredLabel(String text) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text,
            style: AppTypography.label.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a text field with optional error state
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required int maxLines,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14.0),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 14.0, color: Color(0xFFAAAAAA)),
            filled: true,
            fillColor: AppColors.bgInput,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.chip),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.chip),
              borderSide: errorText != null
                  ? BorderSide(color: AppColors.error, width: 1)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.chip),
              borderSide: BorderSide(
                color: errorText != null ? AppColors.error : AppColors.accent,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.all(12.0),
          ),
          onChanged: (_) {
            // Real-time error clearing: clear error as user types
            if (errorText != null) {
              setState(() {
                if (controller == _businessNameController) {
                  _businessNameError = null;
                } else if (controller == _businessAddressController) {
                  _businessAddressError = null;
                } else if (controller == _messageController) {
                  _messageError = null;
                }
              });
            }
          },
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              errorText,
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }
}
