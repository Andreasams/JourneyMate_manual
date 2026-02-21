import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';
import '../../services/translation_service.dart';

/// Widget for selecting feedback topic categories.
///
/// Features:
/// - Displays a horizontal list of topic buttons
/// - Highlights selected topic
/// - Localized labels via translation system (dynamic keys from BuildShip API)
/// - Automatic rebuild when translations change
/// - Triggers callback with selected label when topic is chosen
class UserFeedbackButtonsTopic extends ConsumerStatefulWidget {
  const UserFeedbackButtonsTopic({
    super.key,
    this.width,
    this.height,
    required this.onButtonSelected,
  });

  final double? width;
  final double? height;
  final Future<void> Function(String label) onButtonSelected;

  @override
  ConsumerState<UserFeedbackButtonsTopic> createState() =>
      _UserFeedbackButtonsTopicState();
}

class _UserFeedbackButtonsTopicState
    extends ConsumerState<UserFeedbackButtonsTopic> {
  // --- State ---
  final ScrollController _scrollController = ScrollController();
  String? _selectedLabel;

  // --- Style Constants ---
  static const double _buttonHeight = 32.0;
  static const double _buttonSpacing = AppSpacing.sm;

  // --- Translation Keys ---
  static const List<String> _topicKeys = [
    'feedback_topic_wrong_info',
    'feedback_topic_app_ideas',
    'feedback_topic_bug',
    'feedback_topic_missing_place',
    'feedback_topic_suggestion',
    'feedback_topic_praise',
    'feedback_topic_other',
  ];

  // --- Lifecycle Methods ---

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // --- Translation Helpers ---

  /// Gets all localized topic labels (using dynamic translations)
  List<String> _getLocalizedLabels() {
    return _topicKeys.map((key) => td(ref, key)).toList();
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
    final labels = _getLocalizedLabels();

    return SizedBox(
      height: _buttonHeight,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: _buttonSpacing),
        itemBuilder: (context, index) => _buildTopicButton(labels[index]),
      ),
    );
  }

  /// Builds individual topic button.
  Widget _buildTopicButton(String label) {
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
    return AppTypography.chip.copyWith(
      color: isSelected ? Colors.white : AppColors.textSecondary,
    );
  }
}
