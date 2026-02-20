// ============================================================
// SHARE FEEDBACK PAGE - Converted from JSX v2 Design
// Clean Flutter UI shell with no backend functionality
//
// This is the "chassis" - add functionality incrementally:
// 1. Translation system (15 keys from BUNDLE)
// 2. markUserEngaged() action on back button
// 3. BuildShip API call for form submission
// 4. Analytics tracking (page_viewed event)
// 5. Form validation and error handling
// ============================================================

import 'package:flutter/material.dart';
import '../../shared/app_theme.dart';

// Translation helper function
String getTranslations(
  String languageCode,
  String key,
  Map<String, Map<String, String>> translationsCache,
) {
  return translationsCache[key]?[languageCode] ?? key;
}

class ShareFeedbackPage extends StatefulWidget {
  final String languageCode;
  final Map<String, Map<String, String>> translationsCache;

  const ShareFeedbackPage({
    super.key,
    required this.languageCode,
    required this.translationsCache,
  });

  @override
  State<ShareFeedbackPage> createState() => _ShareFeedbackPageState();
}

class _ShareFeedbackPageState extends State<ShareFeedbackPage> {
  // Form state
  String? _selectedCategory;
  final _messageController = TextEditingController();
  bool _allowContact = false;
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();

  // Category translation keys
  List<String> get _categoryKeys => [
    'feedback_category_wrong_info',
    'feedback_category_ideas',
    'feedback_category_bug',
    'feedback_category_missing_place',
    'feedback_category_suggestion',
    'feedback_category_praise',
    'feedback_category_other',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  bool get _isValid {
    return _selectedCategory != null && _messageController.text.trim().isNotEmpty;
  }

  void _handleSubmit() {
    if (!_isValid) return;

    // TODO: Add BuildShip API call here
    // For now, just print the data and reset form
    final feedback = {
      'category': _selectedCategory,
      'message': _messageController.text,
      if (_allowContact) ...{
        'name': _nameController.text,
        'contact': _contactController.text,
      },
    };

    debugPrint('Feedback submitted: $feedback');

    // Reset form
    setState(() {
      _selectedCategory = null;
      _messageController.clear();
      _allowContact = false;
      _nameController.clear();
      _contactController.clear();
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
          getTranslations(widget.languageCode, 'feedback_form_title', widget.translationsCache),
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
              // Heading
              Text(
                getTranslations(widget.languageCode, 'feedback_form_heading', widget.translationsCache),
                style: AppTypography.sectionHeading,
              ),
              SizedBox(height: AppSpacing.sm),

              // Description
              Text(
                getTranslations(widget.languageCode, 'feedback_form_description', widget.translationsCache),
                style: AppTypography.bodyRegular,
              ),
              SizedBox(height: AppSpacing.xxl),

              // Category selection
              RichText(
                text: TextSpan(
                  text: getTranslations(widget.languageCode, 'feedback_form_field_category', widget.translationsCache),
                  style: AppTypography.label,
                  children: const [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                getTranslations(widget.languageCode, 'feedback_form_field_category_description', widget.translationsCache),
                style: AppTypography.helper,
              ),
              SizedBox(height: AppSpacing.md),

              // Category chips
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _categoryKeys.map((categoryKey) {
                  final categoryLabel = getTranslations(widget.languageCode, categoryKey, widget.translationsCache);
                  final isSelected = _selectedCategory == categoryKey;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = categoryKey;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.accent : Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.filter),
                        border: Border.all(
                          color: isSelected ? AppColors.accent : AppColors.border,
                        ),
                      ),
                      child: Text(
                        categoryLabel,
                        style: AppTypography.chip.copyWith(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: AppSpacing.xxl),

              // Message field
              RichText(
                text: TextSpan(
                  text: getTranslations(widget.languageCode, 'feedback_form_field_message', widget.translationsCache),
                  style: AppTypography.label,
                  children: const [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                getTranslations(widget.languageCode, 'feedback_form_field_message_description', widget.translationsCache),
                style: AppTypography.helper,
              ),
              SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _messageController,
                maxLines: 6,
                decoration: AppInputDecorations.multiline(
                  hintText: getTranslations(widget.languageCode, 'feedback_form_field_message_placeholder', widget.translationsCache),
                ),
                onChanged: (value) {
                  setState(() {}); // Rebuild to update button state
                },
              ),
              SizedBox(height: AppSpacing.xxl),

              // Contact permission checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _allowContact,
                    onChanged: (value) {
                      setState(() {
                        _allowContact = value ?? false;
                      });
                    },
                    activeColor: AppColors.accent,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: const VisualDensity(
                      horizontal: -4,
                      vertical: -4,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getTranslations(widget.languageCode, 'feedback_form_checkbox_contact', widget.translationsCache),
                          style: AppTypography.label,
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          getTranslations(widget.languageCode, 'feedback_form_checkbox_contact_description', widget.translationsCache),
                          style: AppTypography.helper,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Conditional contact fields
              if (_allowContact) ...[
                SizedBox(height: AppSpacing.xl),

                // Name field
                Text(
                  getTranslations(widget.languageCode, 'feedback_form_field_name', widget.translationsCache),
                  style: AppTypography.label,
                ),
                SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: AppConstants.inputHeight,
                  child: TextField(
                    controller: _nameController,
                    decoration: AppInputDecorations.standard(
                      hintText: getTranslations(widget.languageCode, 'feedback_form_field_name_placeholder', widget.translationsCache),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.xxl),

                // Contact info field
                Text(
                  getTranslations(widget.languageCode, 'feedback_form_field_contact', widget.translationsCache),
                  style: AppTypography.label,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  getTranslations(widget.languageCode, 'feedback_form_field_contact_description', widget.translationsCache),
                  style: AppTypography.helper,
                ),
                SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: AppConstants.inputHeight,
                  child: TextField(
                    controller: _contactController,
                    decoration: AppInputDecorations.standard(
                      hintText: getTranslations(widget.languageCode, 'feedback_form_field_contact_placeholder', widget.translationsCache),
                    ),
                  ),
                ),
              ],

              SizedBox(height: AppSpacing.huge),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: AppConstants.buttonHeight,
                child: ElevatedButton(
                  onPressed: _isValid ? _handleSubmit : null,
                  style: AppButtonStyles.primary,
                  child: Text(
                    getTranslations(widget.languageCode, 'feedback_form_button_submit', widget.translationsCache),
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
