import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';
import '../../services/translation_service.dart';

/// Widget for selecting feedback page/location categories.
///
/// Features:
/// - Displays a horizontal list of page buttons
/// - Highlights selected page
/// - Localized labels via translation system
/// - Automatic rebuild when translations change
/// - Triggers callback with selected label when page is chosen
class UserFeedbackButtonsPage extends ConsumerStatefulWidget {
  const UserFeedbackButtonsPage({
    super.key,
    this.width,
    this.height,
    required this.onButtonSelected,
  });

  final double? width;
  final double? height;
  final Future<void> Function(String label) onButtonSelected;

  @override
  ConsumerState<UserFeedbackButtonsPage> createState() =>
      _UserFeedbackButtonsPageState();
}

class _UserFeedbackButtonsPageState extends ConsumerState<UserFeedbackButtonsPage> {
  // --- State ---
  final ScrollController _scrollController = ScrollController();
  String? _selectedLabel;

  // --- Style Constants ---
  static const double _buttonHeight = 32.0;
  static const double _buttonSpacing = AppSpacing.sm;

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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // --- Translation Helpers ---

  /// Gets all localized page labels
  List<String> _getLocalizedLabels(WidgetRef ref) {
    return _pageKeys.map((key) => td(ref, key)).toList();
  }

  // --- Event Handlers ---

  /// Handles button selection and triggers callback.
  Future<void> _handleButtonSelected(String label) async {
    // No markUserEngaged() call - ActivityScope handles this automatically

    setState(() {
      _selectedLabel = label;
    });
    await widget.onButtonSelected(label);
  }

  // --- UI Building ---

  @override
  Widget build(BuildContext context) {
    final labels = _getLocalizedLabels(ref);

    return SizedBox(
      height: _buttonHeight,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: _buttonSpacing),
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
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      ),
      minimumSize: WidgetStateProperty.all(const Size(0, _buttonHeight)),
      shape: WidgetStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
          side: BorderSide(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: 1,
          ),
        ),
      ),
      backgroundColor: WidgetStateProperty.all(
        isSelected ? AppColors.accent : AppColors.bgCard,
      ),
      elevation: WidgetStateProperty.all(0),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
    );
  }

  /// Creates text style based on selection state.
  TextStyle _buildTextStyle(bool isSelected) {
    return AppTypography.bodySmMedium.copyWith(
      color: isSelected ? Colors.white : AppColors.textSecondary,
    );
  }
}
