// ============================================================
// CONTACT US PAGE - Converted from JSX v2 Design
// Clean Flutter UI shell with no backend functionality
//
// Simpler than Share Feedback: 4 text fields, no conditional rendering
// ============================================================

import 'package:flutter/material.dart';
import '../../shared/app_theme.dart';

/// Translation helper function
String getTranslations(String languageCode, String key, Map<String, dynamic> cache) {
  return cache[key]?[languageCode] ?? key;
}

class ContactUsPage extends StatefulWidget {
  final String languageCode;
  final Map<String, dynamic> translationsCache;

  const ContactUsPage({
    super.key,
    required this.languageCode,
    required this.translationsCache,
  });

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  // Form state
  final _fullNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _contactController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  bool get _isValid {
    return _fullNameController.text.trim().isNotEmpty &&
        _contactController.text.trim().isNotEmpty &&
        _subjectController.text.trim().isNotEmpty &&
        _messageController.text.trim().isNotEmpty;
  }

  void _handleSubmit() {
    if (!_isValid) return;

    // TODO: Add BuildShip API call here
    final contactData = {
      'fullName': _fullNameController.text,
      'contact': _contactController.text,
      'subject': _subjectController.text,
      'message': _messageController.text,
    };

    debugPrint('Contact submitted: $contactData');

    // Reset form
    setState(() {
      _fullNameController.clear();
      _contactController.clear();
      _subjectController.clear();
      _messageController.clear();
    });

    // TODO: Show success snackbar
    // TODO: Navigate back after delay
  }

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
          getTranslations(widget.languageCode, 'contact_us_title', widget.translationsCache),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Full name field
              RichText(
                text: TextSpan(
                  text: getTranslations(widget.languageCode, 'contact_us_field_fullname', widget.translationsCache),
                  style: AppTypography.label,
                  children: const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: AppConstants.inputHeight,
                child: TextField(
                  controller: _fullNameController,
                  decoration: AppInputDecorations.standard(
                    hintText: getTranslations(widget.languageCode, 'contact_us_field_fullname_placeholder', widget.translationsCache),
                  ),
                  onChanged: (value) {
                    setState(() {}); // Update button state
                  },
                ),
              ),
              SizedBox(height: AppSpacing.xl),

              // Email or phone field
              RichText(
                text: TextSpan(
                  text: getTranslations(widget.languageCode, 'contact_us_field_contact', widget.translationsCache),
                  style: AppTypography.label,
                  children: const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                getTranslations(widget.languageCode, 'contact_us_field_contact_helper', widget.translationsCache),
                style: AppTypography.helper,
              ),
              SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: AppConstants.inputHeight,
                child: TextField(
                  controller: _contactController,
                  decoration: AppInputDecorations.standard(
                    hintText: getTranslations(widget.languageCode, 'contact_us_field_contact_placeholder', widget.translationsCache),
                  ),
                  onChanged: (value) {
                    setState(() {}); // Update button state
                  },
                ),
              ),
              SizedBox(height: AppSpacing.xl),

              // Subject field
              RichText(
                text: TextSpan(
                  text: getTranslations(widget.languageCode, 'contact_us_field_subject', widget.translationsCache),
                  style: AppTypography.label,
                  children: const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                getTranslations(widget.languageCode, 'contact_us_field_subject_helper', widget.translationsCache),
                style: AppTypography.helper,
              ),
              SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: AppConstants.inputHeight,
                child: TextField(
                  controller: _subjectController,
                  decoration: AppInputDecorations.standard(
                    hintText: getTranslations(widget.languageCode, 'contact_us_field_subject_placeholder', widget.translationsCache),
                  ),
                  onChanged: (value) {
                    setState(() {}); // Update button state
                  },
                ),
              ),
              SizedBox(height: AppSpacing.xl),

              // Message field
              RichText(
                text: TextSpan(
                  text: getTranslations(widget.languageCode, 'contact_us_field_message', widget.translationsCache),
                  style: AppTypography.label,
                  children: const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _messageController,
                maxLines: 6,
                decoration: AppInputDecorations.multiline(
                  hintText: getTranslations(widget.languageCode, 'contact_us_field_message_placeholder', widget.translationsCache),
                ),
                onChanged: (value) {
                  setState(() {}); // Update button state
                },
              ),
              SizedBox(height: AppSpacing.huge),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: AppConstants.buttonHeight,
                child: ElevatedButton(
                  onPressed: _isValid ? _handleSubmit : null,
                  style: AppButtonStyles.primary,
                  child: Text(
                    getTranslations(widget.languageCode, 'contact_us_button_submit', widget.translationsCache),
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
