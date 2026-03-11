import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_constants.dart';
import '../../../services/translation_service.dart';
import '../../../widgets/shared/app_checkbox.dart';

/// Feedback form widget for user feedback submission
///
/// Provides a complete feedback form interface with:
/// - Topic selection (7 chips)
/// - Message textarea
/// - Optional contact consent with name/contact fields
/// - Client-side validation
/// - API submission to BuildShip /feedbackform endpoint
/// - Success/error state handling
/// - User engagement tracking (3 points: topic, checkbox, submit)
class FeedbackFormWidget extends ConsumerStatefulWidget {
  const FeedbackFormWidget({super.key});

  @override
  ConsumerState<FeedbackFormWidget> createState() => _FeedbackFormWidgetState();
}

class _FeedbackFormWidgetState extends ConsumerState<FeedbackFormWidget> {
  // Topic keys (for translation lookup)
  static const List<String> _topicKeys = [
    'feedback_topic_wrong_info',
    'feedback_topic_app_ideas',
    'feedback_topic_bug',
    'feedback_topic_missing_place',
    'feedback_topic_suggestion',
    'feedback_topic_praise',
    'feedback_topic_other',
  ];

  // Topic selection
  String? _selectedTopic;

  // Text editing controllers
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  // Contact consent checkbox
  bool _requireContact = false;

  // Validation errors
  String? _topicError;
  String? _messageError;
  String? _nameError;
  String? _contactError;

  // Submission state
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  String? _submissionError;

  @override
  void dispose() {
    _messageController.dispose();
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  /// Validates all form fields
  bool _validateForm() {
    setState(() {
      // Clear all errors first
      _topicError = null;
      _messageError = null;
      _nameError = null;
      _contactError = null;

      // Validate topic selection
      if (_selectedTopic == null) {
        _topicError = td(ref, 'feedback_form_error_topic_required');
      }

      // Validate message (required and minimum length)
      if (_messageController.text.trim().isEmpty) {
        _messageError = td(ref, 'feedback_form_error_message_required');
      } else if (_messageController.text.trim().length < 10) {
        _messageError = td(ref, 'contact_form_error_message_too_short');
      }

      // Conditional validation: if requireContact is true, name and contact are required
      if (_requireContact) {
        if (_nameController.text.trim().isEmpty) {
          _nameError = td(ref, 'feedback_form_error_name_required');
        }
        if (_contactController.text.trim().isEmpty) {
          _contactError = td(ref, 'feedback_form_error_contact_required');
        }
      }
    });

    return _topicError == null &&
        _messageError == null &&
        _nameError == null &&
        _contactError == null;
  }

  /// Submits the form to BuildShip API
  Future<void> _submitForm() async {
    if (!_validateForm()) return;

    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });

    final languageCode = Localizations.localeOf(context).languageCode;

    // Get localized topic label (sent as-is to API)
    final topicLabel = td(ref, _selectedTopic!);

    try {
      final response = await ApiService.instance.submitFeedback(
        topic: topicLabel, // Localized label (e.g., "Bug" or "Fejl")
        message: _messageController.text.trim(),
        allowContact: _requireContact,
        name: _requireContact ? _nameController.text.trim() : null,
        contact: _requireContact ? _contactController.text.trim() : null,
        languageCode: languageCode,
      );

      if (response.succeeded) {
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
            td(ref, 'feedback_form_title_main'),
            style: AppTypography.h4,
          ),
          SizedBox(height: AppSpacing.sm),

          // Main subtitle
          Text(
            td(ref, 'feedback_form_subtitle_main'),
            style: AppTypography.bodyLg,
          ),
          SizedBox(height: 28), // xxxl (32) minus 4px for tighter first gap

          // Success state
          if (_isSubmitted) _buildSuccessMessage(),

          // Error state
          if (_submissionError != null && !_isSubmitted) _buildErrorMessage(),

          // Form (hidden when submitted)
          if (!_isSubmitted) ...[
            // Topic selection
            _buildTopicSection(),
            SizedBox(height: AppSpacing.xxl), // Increased from xl (20) to xxl (24)

            // Message field
            _buildMessageField(),
            SizedBox(height: 26), // xxl (24) + 2px breathing room before checkbox

            // Contact consent checkbox
            _buildContactConsentSection(),

            // Conditional contact fields (shown only if checkbox enabled)
            if (_requireContact) ...[
              SizedBox(height: AppSpacing.xxl), // Increased from xl (20) to xxl (24)
              _buildContactFields(),
            ],

            SizedBox(height: 40),

            // Submit button
            _buildSubmitButton(),
          ],
        ],
      ),
    );
  }

  /// Builds the topic selection section
  Widget _buildTopicSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          td(ref, 'feedback_form_title_topic'),
          style: AppTypography.bodyLgMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.xs),

        // Section subtitle
        Text(
          td(ref, 'feedback_form_subtitle_topic'),
          style: AppTypography.bodyLg,
        ),
        SizedBox(height: AppSpacing.sm),

        // Topic chips
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _topicKeys.map((topicKey) {
            final isSelected = _selectedTopic == topicKey;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTopic = topicKey;
                  _topicError = null; // Clear error on selection
                });
              },
              child: AnimatedContainer(
                duration: AppConstants.animationFast,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md + 2, // 14px
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.border,
                  ),
                ),
                child: Text(
                  td(ref, topicKey),
                  style: AppTypography.bodySmMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // Error message
        if (_topicError != null) ...[
          SizedBox(height: AppSpacing.sm),
          Text(
            _topicError!,
            style: AppTypography.bodySm.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }

  /// Builds the message field
  Widget _buildMessageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field title with required asterisk
        RichText(
          text: TextSpan(
            text: td(ref, 'feedback_form_title_message'),
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
        SizedBox(height: AppSpacing.xs),

        // Subtitle
        Text(
          td(ref, 'feedback_form_subtitle_message'),
          style: AppTypography.bodyLg,
        ),
        SizedBox(height: AppSpacing.sm),

        // Text field (multiline)
        TextField(
          controller: _messageController,
          onChanged: (_) {
            if (_messageError != null) {
              setState(() => _messageError = null);
            }
          },
          maxLines: 6,
          style: AppTypography.body,
          decoration: InputDecoration(
            hintText: td(ref, 'feedback_form_hint_message'),
            hintStyle: AppTypography.body.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
            filled: true,
            fillColor: AppColors.bgInput,
            contentPadding: EdgeInsets.all(12),
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
        if (_messageError != null) ...[
          SizedBox(height: AppSpacing.sm),
          Text(
            _messageError!,
            style: AppTypography.bodySm.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }

  /// Builds the contact consent section
  Widget _buildContactConsentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          td(ref, 'feedback_form_title_contact_consent'),
          style: AppTypography.bodyLgMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.xs),

        // Section subtitle
        Text(
          td(ref, 'feedback_form_subtitle_contact_consent'),
          style: AppTypography.bodyLg,
        ),
        SizedBox(height: AppSpacing.sm),

        // Checkbox row (tapping anywhere on the row toggles)
        GestureDetector(
          onTap: () {
            setState(() {
              _requireContact = !_requireContact;
              // Clear conditional errors when unchecking
              if (!_requireContact) {
                _nameError = null;
                _contactError = null;
              }
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCheckbox(isSelected: _requireContact),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  td(ref, 'feedback_form_checkbox_label'),
                  style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the conditional contact fields (name and contact)
  Widget _buildContactFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Field title with required asterisk
            RichText(
              text: TextSpan(
                text: td(ref, 'feedback_form_title_name'),
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
            SizedBox(height: AppSpacing.sm),

            // Text field
            TextField(
              controller: _nameController,
              onChanged: (_) {
                if (_nameError != null) {
                  setState(() => _nameError = null);
                }
              },
              maxLines: 1,
              style: AppTypography.body,
              decoration: InputDecoration(
                hintText: td(ref, 'feedback_form_hint_name'),
                hintStyle: AppTypography.body.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
                filled: true,
                fillColor: AppColors.bgInput,
                contentPadding: EdgeInsets.all(16),
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
            if (_nameError != null) ...[
              SizedBox(height: AppSpacing.sm),
              Text(
                _nameError!,
                style: AppTypography.bodySm.copyWith(color: AppColors.error),
              ),
            ],
          ],
        ),

        SizedBox(height: AppSpacing.xl),

        // Contact field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Field title with required asterisk
            RichText(
              text: TextSpan(
                text: td(ref, 'feedback_form_title_contact'),
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
            SizedBox(height: AppSpacing.xs),

            // Subtitle
            Text(
              td(ref, 'feedback_form_subtitle_contact'),
              style: AppTypography.bodyLg,
            ),
            SizedBox(height: AppSpacing.sm),

            // Text field
            TextField(
              controller: _contactController,
              onChanged: (_) {
                if (_contactError != null) {
                  setState(() => _contactError = null);
                }
              },
              maxLines: 1,
              style: AppTypography.body,
              decoration: InputDecoration(
                hintText: td(ref, 'feedback_form_hint_contact'),
                hintStyle: AppTypography.body.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
                filled: true,
                fillColor: AppColors.bgInput,
                contentPadding: EdgeInsets.all(16),
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
            if (_contactError != null) ...[
              SizedBox(height: AppSpacing.sm),
              Text(
                _contactError!,
                style: AppTypography.bodySm.copyWith(color: AppColors.error),
              ),
            ],
          ],
        ),
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
            : Text(td(ref, 'feedback_form_button_submit')),
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
            td(ref, 'feedback_form_success_message'),
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
