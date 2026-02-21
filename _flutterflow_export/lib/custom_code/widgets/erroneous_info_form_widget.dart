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

import 'dart:convert';
import 'package:http/http.dart' as http;

/// A bottom sheet form for reporting incorrect or missing business
/// information.
///
/// Displays within a modal bottom sheet and allows users to submit
/// corrections for the currently viewed business. Styled consistently with
/// ItemDetailSheet.
class ErroneousInfoFormWidget extends StatefulWidget {
  const ErroneousInfoFormWidget({
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
  State<ErroneousInfoFormWidget> createState() =>
      _ErroneousInfoFormWidgetState();
}

class _ErroneousInfoFormWidgetState extends State<ErroneousInfoFormWidget> {
  // ─────────────────────────────────────────────────────────────────────────────
  // Constants: Sheet Layout (matching ItemDetailSheet)
  // ─────────────────────────────────────────────────────────────────────────────
  static const double _sheetBorderRadius = 20.0;
  static const double _swipeBarWidth = 80.0;
  static const double _swipeBarHeight = 4.0;
  static const double _swipeBarTopPadding = 8.0;
  static const double _closeButtonSize = 40.0;
  static const double _closeButtonPosition = 12.0;
  static const double _closeButtonBorderRadius = 20.0;
  static const double _closeIconSize = 30.0;
  static const double _contentHorizontalPadding = 28.0;
  static const double _headerHeight = 56.0;

  // ─────────────────────────────────────────────────────────────────────────────
  // Constants: Colors (matching ItemDetailSheet)
  // ─────────────────────────────────────────────────────────────────────────────
  static const Color _backgroundColor = Colors.white;
  static const Color _swipeBarColor = Color(0xFF14181B);
  static const Color _closeButtonBackgroundColor = Color(0xFFF2F3F5);
  static const Color _closeIconColor = Color(0xFF14181B);
  static const Color _titleColor = Color(0xFF14181B);
  static const Color _subtitleColor = Color(0xFF57636C);
  static const Color _textFieldBackgroundColor = Color(0xFFF2F3F5);
  static const Color _submitButtonColor = Color(0xFFE9874B);
  static const Color _submitButtonTextColor = Colors.white;
  static const Color _errorColor = Colors.red;
  static const Color _successColor = Color(0xFF249689);

  // ─────────────────────────────────────────────────────────────────────────────
  // Constants: Typography (matching ItemDetailSheet hierarchy)
  // ─────────────────────────────────────────────────────────────────────────────
  static const double _mainTitleFontSize = 22.0;
  static const FontWeight _mainTitleFontWeight = FontWeight.w600;

  static const double _sectionHeaderFontSize = 16.0;
  static const FontWeight _sectionHeaderFontWeight = FontWeight.w500;

  static const double _bodyFontSize = 14.0;
  static const FontWeight _bodyFontWeight = FontWeight.w400;
  static const FontWeight _bodyLightFontWeight = FontWeight.w300;

  static const double _businessNameFontSize = 16.0;
  static const FontWeight _businessNameFontWeight = FontWeight.w500;

  static const double _buttonFontSize = 16.0;
  static const FontWeight _buttonFontWeight = FontWeight.w500;

  // ─────────────────────────────────────────────────────────────────────────────
  // Constants: Spacing
  // ─────────────────────────────────────────────────────────────────────────────
  static const double _sectionSpacing = 20.0;
  static const double _smallSpacing = 4.0;
  static const double _mediumSpacing = 8.0;
  static const double _labelToFieldSpacing = 8.0;

  // ─────────────────────────────────────────────────────────────────────────────
  // Constants: Text Field
  // ─────────────────────────────────────────────────────────────────────────────
  static const double _textFieldBorderRadius = 8.0;
  static const double _textFieldPadding = 12.0;
  static const double _textFieldMinHeight = 120.0;
  static const double _textFieldMaxHeight = 180.0;

  // ─────────────────────────────────────────────────────────────────────────────
  // Constants: Button
  // ─────────────────────────────────────────────────────────────────────────────
  static const double _submitButtonHeight = 44.0;
  static const double _submitButtonBorderRadius = 8.0;

  // ─────────────────────────────────────────────────────────────────────────────
  // Constants: API
  // ─────────────────────────────────────────────────────────────────────────────
  static const String _apiEndpoint =
      'https://wvb8ww.buildship.run/erroneousinfo';

  // ─────────────────────────────────────────────────────────────────────────────
  // State
  // ─────────────────────────────────────────────────────────────────────────────
  final TextEditingController _messageController = TextEditingController();

  String? _messageError;
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  String? _submissionError;

  // ─────────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────────
  @override
  void didUpdateWidget(ErroneousInfoFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.translationsCache != oldWidget.translationsCache ||
        widget.currentLanguage != oldWidget.currentLanguage) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Helpers: Translation
  // ─────────────────────────────────────────────────────────────────────────────
  String _getUIText(String key) {
    return getTranslations(
      widget.currentLanguage,
      key,
      widget.translationsCache,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Helpers: Business Data
  // ─────────────────────────────────────────────────────────────────────────────
  Map<String, dynamic> _getBusinessInfo() {
    final businessData = FFAppState().mostRecentlyViewedBusiness;
    return {
      'id': businessData['businessInfo']['business_id'],
      'name': businessData['businessInfo']['business_name'],
      'street': businessData['businessInfo']['street'],
      'postalCode': businessData['businessInfo']['postal_code'],
      'city': businessData['businessInfo']['postal_city'],
    };
  }

  String _formatBusinessAddress() {
    final info = _getBusinessInfo();
    return '${info['street']}, ${info['postalCode']} ${info['city']}';
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Validation
  // ─────────────────────────────────────────────────────────────────────────────
  bool _validateForm() {
    bool isValid = true;

    setState(() {
      _messageError = null;

      final message = _messageController.text.trim();
      if (message.isEmpty) {
        _messageError = _getUIText('erroneous_info_error_message_required');
        isValid = false;
      } else if (message.length < 10) {
        _messageError = _getUIText('erroneous_info_error_message_too_short');
        isValid = false;
      }
    });

    return isValid;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // API Submission
  // ─────────────────────────────────────────────────────────────────────────────
  Future<void> _submitToAPI() async {
    final businessInfo = _getBusinessInfo();
    final requestBody = {
      'businessId': businessInfo['id'],
      'businessName': businessInfo['name'],
      'message': _messageController.text.trim(),
      'languageCode': widget.currentLanguage,
    };

    final response = await http.post(
      Uri.parse(_apiEndpoint),
      headers: {'Content-Type': 'application/json'},
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
          errorData['error'] ?? 'Failed to submit erroneous info report');
    }
  }

  Future<void> _handleSubmit() async {
    markUserEngaged();

    if (_isSubmitting) return;
    if (!_validateForm()) return;

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

  void _handleClose() {
    markUserEngaged();
    Navigator.of(context).pop();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Build: Main
  // ─────────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: const BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(_sheetBorderRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _contentHorizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBusinessInfoSection(),
                    const SizedBox(height: _sectionSpacing),
                    _buildMessageSection(),
                    const SizedBox(height: _sectionSpacing),
                    _buildSubmitArea(),
                    const SizedBox(height: _sectionSpacing),
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
  // Build: Header (matching ItemDetailSheet)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return SizedBox(
      height: _headerHeight,
      child: Stack(
        children: [
          _buildSwipeBar(),
          _buildCloseButton(),
        ],
      ),
    );
  }

  Widget _buildSwipeBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.only(top: _swipeBarTopPadding),
        child: Center(
          child: Container(
            width: _swipeBarWidth,
            height: _swipeBarHeight,
            decoration: BoxDecoration(
              color: _swipeBarColor,
              borderRadius: BorderRadius.circular(_swipeBarHeight / 2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Positioned(
      top: _closeButtonPosition,
      left: _closeButtonPosition,
      child: Container(
        width: _closeButtonSize,
        height: _closeButtonSize,
        decoration: BoxDecoration(
          color: _closeButtonBackgroundColor,
          borderRadius: BorderRadius.circular(_closeButtonBorderRadius),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(
            Icons.close,
            color: _closeIconColor,
            size: _closeIconSize,
          ),
          onPressed: _handleClose,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Build: Business Info Section
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildBusinessInfoSection() {
    final businessInfo = _getBusinessInfo();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main title
        Text(
          _getUIText('erroneous_info_title_main'),
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: _mainTitleFontSize,
            fontWeight: _mainTitleFontWeight,
            color: _titleColor,
          ),
        ),
        const SizedBox(height: _sectionSpacing),

        // "Reporting information for" label
        Text(
          _getUIText('erroneous_info_subtitle_reporting_for'),
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: _bodyFontSize,
            fontWeight: _bodyFontWeight,
            color: _subtitleColor,
          ),
        ),
        const SizedBox(height: _smallSpacing),

        // Business name
        Text(
          businessInfo['name'] ?? '',
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: _businessNameFontSize,
            fontWeight: _businessNameFontWeight,
            color: _titleColor,
          ),
        ),

        // Business address
        Text(
          _formatBusinessAddress(),
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: _bodyFontSize,
            fontWeight: _bodyFontWeight,
            color: _subtitleColor,
          ),
        ),
        const SizedBox(height: _mediumSpacing),

        // Help text
        Text(
          _getUIText('erroneous_info_subtitle_main'),
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: _bodyFontSize,
            fontWeight: _bodyLightFontWeight,
            color: _titleColor,
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
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: _getUIText('erroneous_info_title_message'),
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: _sectionHeaderFontSize,
                  fontWeight: _sectionHeaderFontWeight,
                  color: _titleColor,
                ),
              ),
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  fontSize: _sectionHeaderFontSize,
                  fontWeight: _sectionHeaderFontWeight,
                  color: _errorColor,
                ),
              ),
            ],
          ),
        ),

        // Subtitle
        Text(
          _getUIText('erroneous_info_subtitle_message'),
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: _bodyFontSize,
            fontWeight: _bodyLightFontWeight,
            color: _titleColor,
          ),
        ),
        const SizedBox(height: _labelToFieldSpacing),

        // Text field with constrained height
        _buildTextField(),

        // Error text
        if (_messageError != null)
          Padding(
            padding: const EdgeInsets.only(top: _smallSpacing),
            child: Text(
              _messageError!,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12.0,
                fontWeight: _bodyFontWeight,
                color: _errorColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField() {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: _textFieldMinHeight,
        maxHeight: _textFieldMaxHeight,
      ),
      child: TextField(
        controller: _messageController,
        maxLines: null,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: _bodyFontSize,
          fontWeight: _bodyFontWeight,
          color: _titleColor,
        ),
        decoration: InputDecoration(
          hintText: _getUIText('erroneous_info_hint_message'),
          hintStyle: TextStyle(
            fontFamily: 'Roboto',
            fontSize: _bodyFontSize,
            fontWeight: _bodyFontWeight,
            color: _subtitleColor.withOpacity(0.7),
          ),
          filled: true,
          fillColor: _textFieldBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_textFieldBorderRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_textFieldBorderRadius),
            borderSide: _messageError != null
                ? const BorderSide(color: _errorColor, width: 1)
                : BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_textFieldBorderRadius),
            borderSide: _messageError != null
                ? const BorderSide(color: _errorColor, width: 1)
                : BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(_textFieldPadding),
        ),
        onChanged: (_) {
          if (_messageError != null) {
            setState(() => _messageError = null);
          }
        },
      ),
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
          const SizedBox(height: _mediumSpacing),
        ],
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(_submitButtonBorderRadius),
        border: Border.all(color: _successColor, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: _successColor,
            size: 32,
          ),
          const SizedBox(height: _mediumSpacing),
          Text(
            _getUIText('erroneous_info_success_message'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: _bodyFontSize,
              fontWeight: _sectionHeaderFontWeight,
              color: _successColor,
            ),
          ),
          const SizedBox(height: _smallSpacing),
          Text(
            _getUIText('erroneous_info_success_navigate_away'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: _bodyFontSize,
              fontWeight: _bodyLightFontWeight,
              color: _successColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: _errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(_submitButtonBorderRadius),
        border: Border.all(color: _errorColor, width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: _errorColor,
            size: 20,
          ),
          const SizedBox(width: _mediumSpacing),
          Expanded(
            child: Text(
              _getUIText('erroneous_info_error_submission'),
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: _bodyFontSize,
                fontWeight: _bodyFontWeight,
                color: _errorColor,
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
      height: _submitButtonHeight,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _submitButtonColor,
          disabledBackgroundColor: _submitButtonColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_submitButtonBorderRadius),
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
                    _submitButtonTextColor,
                  ),
                ),
              )
            : Text(
                _getUIText('erroneous_info_button_submit'),
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: _buttonFontSize,
                  fontWeight: _buttonFontWeight,
                  color: _submitButtonTextColor,
                ),
              ),
      ),
    );
  }
}
