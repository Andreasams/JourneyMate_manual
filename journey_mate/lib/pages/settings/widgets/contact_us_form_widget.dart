import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_constants.dart';
import '../../../services/translation_service.dart';

/// Contact form widget for user inquiries
///
/// Provides a complete contact form interface with:
/// - Four input fields: Name, Contact (email/phone), Subject, Message
/// - Client-side validation for required fields
/// - API submission to BuildShip /contact endpoint
/// - Success/error state handling
/// - User engagement tracking
class ContactUsFormWidget extends ConsumerStatefulWidget {
  const ContactUsFormWidget({super.key});

  @override
  ConsumerState<ContactUsFormWidget> createState() => _ContactUsFormWidgetState();
}

class _ContactUsFormWidgetState extends ConsumerState<ContactUsFormWidget> {
  // API endpoint
  static const String _apiEndpoint = 'https://wvb8ww.buildship.run/contact';

  // Text editing controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // Validation errors
  String? _nameError;
  String? _contactError;
  String? _subjectError;
  String? _messageError;

  // Submission state
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  String? _submissionError;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  /// Validates all form fields
  bool _validateForm() {
    setState(() {
      // Clear all errors first
      _nameError = null;
      _contactError = null;
      _subjectError = null;
      _messageError = null;

      // Validate name
      if (_nameController.text.trim().isEmpty) {
        _nameError = td(ref, 'contact_form_error_name_required');
      }

      // Validate contact (email or phone)
      if (_contactController.text.trim().isEmpty) {
        _contactError = td(ref, 'contact_form_error_contact_required');
      }

      // Validate subject
      if (_subjectController.text.trim().isEmpty) {
        _subjectError = td(ref, 'contact_form_error_subject_required');
      }

      // Validate message (required and minimum length)
      if (_messageController.text.trim().isEmpty) {
        _messageError = td(ref, 'contact_form_error_message_required');
      } else if (_messageController.text.trim().length < 10) {
        _messageError = td(ref, 'contact_form_error_message_too_short');
      }
    });

    return _nameError == null &&
        _contactError == null &&
        _subjectError == null &&
        _messageError == null;
  }

  /// Submits the form to BuildShip API
  Future<void> _submitForm() async {
    if (!_validateForm()) return;

    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });

    final languageCode = Localizations.localeOf(context).languageCode;

    try {
      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _nameController.text.trim(),
          'contact': _contactController.text.trim(),
          'subject': _subjectController.text.trim(),
          'message': _messageController.text.trim(),
          'languageCode': languageCode,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isSubmitted = true;
          _submissionError = null;
        });
      } else {
        setState(() {
          _submissionError = td(ref, 'contact_form_error_submission');
        });
      }
    } catch (e) {
      setState(() {
        _submissionError = td(ref, 'contact_form_error_submission');
      });
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = keyboardHeight > 0
        ? keyboardHeight + AppSpacing.lg
        : AppSpacing.xxxl;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
        bottom: bottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main title
          Text(
            td(ref, 'contact_form_title_main'),
            style: AppTypography.h2,
          ),
          SizedBox(height: AppSpacing.sm),

          // Main subtitle
          Text(
            td(ref, 'contact_form_subtitle_main'),
            style: AppTypography.bodyLg,
          ),
          SizedBox(height: 28), // xxxl (32) minus 4px for tighter first gap

          // Success state
          if (_isSubmitted) _buildSuccessMessage(),

          // Error state
          if (_submissionError != null && !_isSubmitted) _buildErrorMessage(),

          // Form (hidden when submitted)
          if (!_isSubmitted) ...[
            // Name field
            _buildFieldSection(
              title: td(ref, 'contact_form_title_name'),
              subtitle: null,
              controller: _nameController,
              error: _nameError,
              hint: td(ref, 'contact_form_hint_name'),
              maxLines: 1,
              onChanged: () {
                if (_nameError != null) {
                  setState(() => _nameError = null);
                }
              },
            ),
            SizedBox(height: AppSpacing.xxl), // Increased from xl (20) to xxl (24)

            // Contact field (email or phone)
            _buildFieldSection(
              title: td(ref, 'contact_form_title_contact'),
              subtitle: td(ref, 'contact_form_subtitle_contact'),
              controller: _contactController,
              error: _contactError,
              hint: td(ref, 'contact_form_hint_contact'),
              maxLines: 1,
              onChanged: () {
                if (_contactError != null) {
                  setState(() => _contactError = null);
                }
              },
            ),
            SizedBox(height: AppSpacing.xxl), // Increased from xl (20) to xxl (24)

            // Subject field
            _buildFieldSection(
              title: td(ref, 'contact_form_title_subject'),
              subtitle: td(ref, 'contact_form_subtitle_subject'),
              controller: _subjectController,
              error: _subjectError,
              hint: td(ref, 'contact_form_hint_subject'),
              maxLines: 1,
              onChanged: () {
                if (_subjectError != null) {
                  setState(() => _subjectError = null);
                }
              },
            ),
            SizedBox(height: AppSpacing.xxl), // Increased from xl (20) to xxl (24)

            // Message field (multiline)
            _buildFieldSection(
              title: td(ref, 'contact_form_title_message'),
              subtitle: td(ref, 'contact_form_subtitle_message'),
              controller: _messageController,
              error: _messageError,
              hint: td(ref, 'contact_form_hint_message'),
              maxLines: 6,
              onChanged: () {
                if (_messageError != null) {
                  setState(() => _messageError = null);
                }
              },
            ),
            SizedBox(height: 40),

            // Submit button
            _buildSubmitButton(),
          ],
        ],
      ),
    );
  }

  /// Builds a form field section with title, subtitle, input, and error
  Widget _buildFieldSection({
    required String title,
    String? subtitle,
    required TextEditingController controller,
    String? error,
    required String hint,
    required int maxLines,
    required VoidCallback onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field title with required asterisk
        RichText(
          text: TextSpan(
            text: title,
            style: AppTypography.bodyLgMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.error),
              ),
            ],
          ),
        ),

        // Subtitle (if provided)
        if (subtitle != null) ...[
          SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTypography.bodyLg,
          ),
        ],

        SizedBox(height: AppSpacing.sm),

        // Text field
        TextField(
          controller: controller,
          onChanged: (_) => onChanged(),
          maxLines: maxLines,
          style: AppTypography.bodyLg,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyLg.copyWith(fontSize: 14),
            filled: true,
            fillColor: AppColors.bgInput,
            contentPadding: EdgeInsets.all(maxLines > 1 ? 12 : 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: BorderSide(color: AppColors.accent, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
          ),
        ),

        // Error message
        if (error != null) ...[
          SizedBox(height: AppSpacing.sm),
          Text(
            error,
            style: AppTypography.bodySm.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }

  /// Builds the submit button
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: AppConstants.buttonHeight,
      child: TextButton(
        onPressed: _isSubmitting ? null : _submitForm,
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
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.bgPage),
                ),
              )
            : Text(td(ref, 'contact_form_button_submit')),
      ),
    );
  }

  /// Builds the success message
  Widget _buildSuccessMessage() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.success),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 48,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            td(ref, 'contact_form_success_message'),
            textAlign: TextAlign.center,
            style: AppTypography.bodyLgMedium.copyWith(
              color: AppColors.success,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            td(ref, 'contact_form_success_navigate_away'),
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  /// Builds the error message
  Widget _buildErrorMessage() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      margin: EdgeInsets.only(bottom: AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.error),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 24,
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              _submissionError!,
              style: AppTypography.bodyLg.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
