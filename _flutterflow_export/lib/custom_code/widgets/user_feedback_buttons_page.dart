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

/// Widget for selecting feedback page/location categories.
///
/// Features: - Displays a horizontal list of page buttons - Highlights
/// selected page - Localized labels via translation system - Automatic
/// rebuild when translations change - Triggers callback with selected label
/// when page is chosen
class UserFeedbackButtonsPage extends StatefulWidget {
  const UserFeedbackButtonsPage({
    super.key,
    this.width,
    this.height,
    required this.onButtonSelected,
    required this.currentLanguage,
    required this.translationsCache,
  });

  final double? width;
  final double? height;
  final Future Function(String label) onButtonSelected;
  final String currentLanguage;
  final dynamic translationsCache;

  @override
  State<UserFeedbackButtonsPage> createState() =>
      _UserFeedbackButtonsPageState();
}

class _UserFeedbackButtonsPageState extends State<UserFeedbackButtonsPage> {
  // --- State ---
  final ScrollController _scrollController = ScrollController();
  String? _selectedLabel;

  // --- Style Constants ---
  static const Color _selectedColor = Color(0xFFEE8B60);
  static const Color _unselectedColor = Color(0xFFf2f3f5);
  static const Color _selectedTextColor = Colors.white;
  static const Color _unselectedTextColor = Color(0xFF242629);
  static final Color _borderColor = Colors.grey[500]!;

  static const double _buttonHeight = 32.0;
  static const double _buttonSpacing = 8.0;
  static const double _fontSize = 14.0;
  static const double _borderRadius = 8.0;

  // --- Translation Keys ---
  static const List<String> _pageKeys = [
    'feedback_page_search_results',
    'feedback_page_business_profile',
    'feedback_page_settings',
    'feedback_page_other',
    'feedback_page_dont_know',
  ];

  // --- Lifecycle Methods ---

  @override
  void didUpdateWidget(UserFeedbackButtonsPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Rebuild if translation cache or language changes
    if (widget.translationsCache != oldWidget.translationsCache ||
        widget.currentLanguage != oldWidget.currentLanguage) {
      setState(() {
        // Trigger rebuild with new translations
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // --- Translation Helpers ---

  /// Gets localized UI text using central translation function
  String _getUIText(String key) {
    return getTranslations(
        widget.currentLanguage, key, widget.translationsCache);
  }

  /// Gets all localized page labels
  List<String> _getLocalizedLabels() {
    return _pageKeys.map((key) => _getUIText(key)).toList();
  }

  // --- Event Handlers ---

  /// Handles button selection and triggers callback.
  Future<void> _handleButtonSelected(String label) async {
    markUserEngaged();

    setState(() {
      _selectedLabel = label;
    });
    await widget.onButtonSelected(label);
  }

  // --- UI Building ---

  @override
  Widget build(BuildContext context) {
    final labels = _getLocalizedLabels();

    return SizedBox(
      height: _buttonHeight,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: _buttonSpacing),
        itemBuilder: (context, index) => _buildPageButton(labels[index]),
      ),
    );
  }

  /// Builds individual page button.
  Widget _buildPageButton(String label) {
    final isSelected = label == _selectedLabel;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: () => _handleButtonSelected(label),
        style: _buildButtonStyle(isSelected),
        child: Text(
          label,
          style: _buildTextStyle(isSelected),
        ),
      ),
    );
  }

  /// Creates button style based on selection state.
  ButtonStyle _buildButtonStyle(bool isSelected) {
    return ButtonStyle(
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 16),
      ),
      minimumSize: MaterialStateProperty.all(const Size(0, _buttonHeight)),
      shape: MaterialStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          side: BorderSide(
            color: isSelected ? _selectedColor : _borderColor,
            width: 1,
          ),
        ),
      ),
      backgroundColor: MaterialStateProperty.all(
        isSelected ? _selectedColor : _unselectedColor,
      ),
      elevation: MaterialStateProperty.all(0),
      overlayColor: MaterialStateProperty.all(Colors.transparent),
    );
  }

  /// Creates text style based on selection state.
  TextStyle _buildTextStyle(bool isSelected) {
    return TextStyle(
      color: isSelected ? _selectedTextColor : _unselectedTextColor,
      fontSize: _fontSize,
      fontWeight: FontWeight.w400,
    );
  }
}
