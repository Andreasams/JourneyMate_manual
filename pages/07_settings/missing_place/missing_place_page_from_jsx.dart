// ============================================================
// MISSING PLACE PAGE - Converted from JSX v2 Design
// Clean Flutter UI shell with no backend functionality
//
// Similar to Contact Us: 3 fields + heading/description
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

class MissingPlacePage extends StatefulWidget {
  final String languageCode;
  final Map<String, Map<String, String>> translationsCache;

  const MissingPlacePage({
    super.key,
    required this.languageCode,
    required this.translationsCache,
  });

  @override
  State<MissingPlacePage> createState() => _MissingPlacePageState();
}

class _MissingPlacePageState extends State<MissingPlacePage> {
  // Form state
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  bool get _isValid {
    return _nameController.text.trim().isNotEmpty &&
        _addressController.text.trim().isNotEmpty &&
        _messageController.text.trim().isNotEmpty;
  }

  void _handleSubmit() {
    if (!_isValid) return;

    // TODO: Add BuildShip API call here
    final placeData = {
      'name': _nameController.text,
      'address': _addressController.text,
      'message': _messageController.text,
    };

    debugPrint('Missing place submitted: $placeData');

    // Reset form
    setState(() {
      _nameController.clear();
      _addressController.clear();
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
          getTranslations(widget.languageCode, 'missing_place_title', widget.translationsCache),
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
                getTranslations(widget.languageCode, 'missing_place_heading', widget.translationsCache),
                style: AppTypography.sectionHeading,
              ),
              SizedBox(height: AppSpacing.sm),

              // Description
              Text(
                getTranslations(widget.languageCode, 'missing_place_desc_1', widget.translationsCache),
                style: AppTypography.bodyRegular,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                getTranslations(widget.languageCode, 'missing_place_desc_2', widget.translationsCache),
                style: AppTypography.bodyRegular,
              ),
              SizedBox(height: AppSpacing.xxl),

              // Name field
              RichText(
                text: TextSpan(
                  text: getTranslations(widget.languageCode, 'missing_place_field_name', widget.translationsCache),
                  style: AppTypography.label,
                  children: const [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: AppConstants.inputHeight,
                child: TextField(
                  controller: _nameController,
                  decoration: AppInputDecorations.standard(
                    hintText: getTranslations(widget.languageCode, 'missing_place_field_name_placeholder', widget.translationsCache),
                  ),
                  onChanged: (value) {
                    setState(() {}); // Update button state
                  },
                ),
              ),
              SizedBox(height: AppSpacing.xl),

              // Address field
              RichText(
                text: TextSpan(
                  text: getTranslations(widget.languageCode, 'missing_place_field_address', widget.translationsCache),
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
                getTranslations(widget.languageCode, 'missing_place_field_address_helper', widget.translationsCache),
                style: AppTypography.helper,
              ),
              SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: AppConstants.inputHeight,
                child: TextField(
                  controller: _addressController,
                  decoration: AppInputDecorations.standard(
                    hintText: getTranslations(widget.languageCode, 'missing_place_field_address_placeholder', widget.translationsCache),
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
                  text: getTranslations(widget.languageCode, 'missing_place_field_message', widget.translationsCache),
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
                getTranslations(widget.languageCode, 'missing_place_field_message_helper', widget.translationsCache),
                style: AppTypography.helper,
              ),
              SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _messageController,
                maxLines: 6,
                decoration: AppInputDecorations.multiline(
                  hintText: getTranslations(widget.languageCode, 'missing_place_field_message_placeholder', widget.translationsCache),
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
                    getTranslations(widget.languageCode, 'missing_place_button_submit', widget.translationsCache),
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
