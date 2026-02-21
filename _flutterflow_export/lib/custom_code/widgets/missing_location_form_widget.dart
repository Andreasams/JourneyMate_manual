// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/widgets/index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class MissingLocationFormWidget extends StatefulWidget {
  const MissingLocationFormWidget({
    super.key,
    this.width,
    this.height,
    required this.currentLanguage,
    required this.translationsCache,
  });

  final double? width;
  final double? height;
  final String currentLanguage;
  final dynamic translationsCache;

  @override
  State<MissingLocationFormWidget> createState() =>
      _MissingLocationFormWidgetState();
}

class _MissingLocationFormWidgetState extends State<MissingLocationFormWidget> {
  static const Color _titleColor = Color(0xFF14181B);
  static const Color _subtitleColor = Color(0xFF14181B);
  static const Color _textFieldBackground = Color(0xFFF2F3F5);
  static const Color _submitButtonColor = Color(0xFFE9874B);
  static const Color _submitButtonTextColor = Colors.white;
  static const Color _errorColor = Colors.red;
  static const Color _successColor = Color(0xFF249689);

  static const double _mainTitleFontSize = 20.0;
  static const double _titleFontSize = 18.0;
  static const double _subtitleFontSize = 15.0;
  static const double _submitButtonFontSize = 16.0;
  static const double _textFieldFontSize = 14.0;

  static const FontWeight _titleFontWeight = FontWeight.w500;
  static const FontWeight _subtitleFontWeight = FontWeight.w300;
  static const FontWeight _submitButtonFontWeight = FontWeight.w500;

  static const double _submitButtonWidth = 200.0;
  static const double _submitButtonHeight = 40.0;
  static const double _submitButtonRadius = 8.0;
  static const double _submitButtonPadding = 16.0;
  static const double _submitButtonTopMargin = 40.0;

  static const double _sectionSpacing = 24.0;
  static const double _fieldSpacing = 8.0;
  static const double _subtitleToFieldSpacing = 6.0;
  static const double _textFieldBorderRadius = 8.0;
  static const double _textFieldPadding = 12.0;
  static const double _bottomPadding = 140.0;

  static const String _apiEndpoint =
      'https://wvb8ww.buildship.run/missingplace';

  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessAddressController =
      TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String? _businessNameError;
  String? _businessAddressError;
  String? _messageError;
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  String? _submissionError;

  @override
  void didUpdateWidget(MissingLocationFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.translationsCache != oldWidget.translationsCache ||
        widget.currentLanguage != oldWidget.currentLanguage) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String _getUIText(String key) {
    return getTranslations(
      widget.currentLanguage,
      key,
      widget.translationsCache,
    );
  }

  bool _validateForm() {
    bool isValid = true;

    setState(() {
      _businessNameError = null;
      _businessAddressError = null;
      _messageError = null;

      final businessName = _businessNameController.text.trim();
      if (businessName.isEmpty) {
        _businessNameError = _getUIText('missing_location_error_name_required');
        isValid = false;
      }

      final businessAddress = _businessAddressController.text.trim();
      if (businessAddress.isEmpty) {
        _businessAddressError =
            _getUIText('missing_location_error_address_required');
        isValid = false;
      }

      final message = _messageController.text.trim();
      if (message.isEmpty) {
        _messageError = _getUIText('missing_location_error_message_required');
        isValid = false;
      } else if (message.length < 10) {
        _messageError = _getUIText('missing_location_error_message_too_short');
        isValid = false;
      }
    });

    return isValid;
  }

  Future<void> _submitToAPI() async {
    final requestBody = {
      'businessName': _businessNameController.text.trim(),
      'businessAddress': _businessAddressController.text.trim(),
      'message': _messageController.text.trim(),
      'languageCode': widget.currentLanguage,
    };

    final response = await http.post(
      Uri.parse(_apiEndpoint),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        return;
      } else {
        throw Exception(responseData['error'] ?? 'Unknown error occurred');
      }
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
          errorData['error'] ?? 'Failed to submit missing location');
    }
  }

  Future<void> _handleSubmit() async {
    markUserEngaged();

    if (_isSubmitting) return;

    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });

    try {
      await _submitToAPI();

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isSubmitted = true;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _submissionError = error.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, _bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIntroductionSection(),
          const SizedBox(height: _sectionSpacing),
          _buildBusinessNameSection(),
          const SizedBox(height: _sectionSpacing),
          _buildBusinessAddressSection(),
          const SizedBox(height: _sectionSpacing),
          _buildMessageSection(),
          const SizedBox(height: _submitButtonTopMargin),
          _buildSubmitArea(),
        ],
      ),
    );
  }

  Widget _buildIntroductionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMainTitle(_getUIText('missing_location_title_main')),
        _buildSubtitle(_getUIText('missing_location_subtitle_main_1')),
        const SizedBox(height: 8.0),
        _buildSubtitle(_getUIText('missing_location_subtitle_main_2')),
      ],
    );
  }

  Widget _buildBusinessNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequiredTitle(_getUIText('missing_location_title_business_name')),
        const SizedBox(height: _fieldSpacing),
        _buildTextField(
          controller: _businessNameController,
          hintText: _getUIText('missing_location_hint_business_name'),
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
        _buildRequiredTitle(
            _getUIText('missing_location_title_business_address')),
        _buildSubtitle(
            _getUIText('missing_location_subtitle_business_address')),
        const SizedBox(height: _subtitleToFieldSpacing),
        _buildTextField(
          controller: _businessAddressController,
          hintText: _getUIText('missing_location_hint_business_address'),
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
        _buildRequiredTitle(_getUIText('missing_location_title_message')),
        _buildSubtitle(_getUIText('missing_location_subtitle_message')),
        const SizedBox(height: _subtitleToFieldSpacing),
        _buildTextField(
          controller: _messageController,
          hintText: _getUIText('missing_location_hint_message'),
          maxLines: 6,
          errorText: _messageError,
        ),
      ],
    );
  }

  Widget _buildSubmitArea() {
    if (_isSubmitted) {
      return _buildSuccessMessage();
    } else if (_submissionError != null) {
      return _buildErrorMessage();
    } else {
      return _buildSubmitButton();
    }
  }

  Widget _buildSuccessMessage() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: _successColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(_submitButtonRadius),
          border: Border.all(color: _successColor, width: 1),
        ),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: _successColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              _getUIText('missing_location_success_message'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _successColor,
                fontSize: _subtitleFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getUIText('missing_location_success_navigate_away'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _successColor.withOpacity(0.8),
                fontSize: 13.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Center(
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: _errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(_submitButtonRadius),
              border: Border.all(color: _errorColor, width: 1),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  color: _errorColor,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  _getUIText('missing_location_error_submission'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _errorColor,
                    fontSize: _subtitleFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: SizedBox(
        width: _submitButtonWidth,
        height: _submitButtonHeight,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (states) {
                if (states.contains(MaterialState.disabled)) {
                  return _submitButtonColor.withOpacity(0.5);
                }
                return _submitButtonColor;
              },
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_submitButtonRadius),
              ),
            ),
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(horizontal: _submitButtonPadding),
            ),
            elevation: MaterialStateProperty.all(0),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _submitButtonTextColor,
                    ),
                  ),
                )
              : Text(
                  _getUIText('missing_location_button_submit'),
                  style: const TextStyle(
                    color: _submitButtonTextColor,
                    fontSize: _submitButtonFontSize,
                    fontWeight: _submitButtonFontWeight,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildMainTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _titleColor,
        fontSize: _mainTitleFontSize,
        fontWeight: _titleFontWeight,
      ),
    );
  }

  Widget _buildRequiredTitle(String text) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: text,
            style: const TextStyle(
              color: _titleColor,
              fontSize: _titleFontSize,
              fontWeight: _titleFontWeight,
            ),
          ),
          const TextSpan(
            text: ' *',
            style: TextStyle(
              color: _errorColor,
              fontSize: _titleFontSize,
              fontWeight: _titleFontWeight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _subtitleColor,
        fontSize: _subtitleFontSize,
        fontWeight: _subtitleFontWeight,
      ),
    );
  }

  Widget _buildErrorText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _errorColor,
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
      ),
    );
  }

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
          style: const TextStyle(fontSize: _textFieldFontSize),
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: _textFieldBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_textFieldBorderRadius),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(_textFieldPadding),
            errorBorder: errorText != null
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(_textFieldBorderRadius),
                    borderSide: const BorderSide(color: _errorColor, width: 1),
                  )
                : null,
          ),
          onChanged: (_) {
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
            child: _buildErrorText(errorText),
          ),
      ],
    );
  }
}
