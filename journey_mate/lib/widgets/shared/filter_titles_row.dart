import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/translation_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// FilterTitlesRow - Horizontal row with 3 filter category tabs
///
/// Displays three filter category titles (Location, Type, Needs)
/// with visual feedback for the active tab. Used in search page and business
/// profile filter bottom sheet.
///
/// Props:
/// - activeTabIndex: Currently selected tab (0, 1, or 2)
/// - onTabChanged: Callback when user taps a title
/// - width: Row width
/// - height: Row height (typically 50px)
///
/// Design:
/// - 3 equal-width columns (36% / 33% / 31% per design system)
/// - Active tab: orange text + 2px bottom border
/// - Inactive tabs: gray text, no border
/// - Uses ts(context, key) for translation
class FilterTitlesRow extends ConsumerWidget {
  const FilterTitlesRow({
    super.key,
    required this.activeTabIndex,
    required this.onTabChanged,
    this.width,
    this.height = 50.0,
  });

  final int activeTabIndex;
  final Function(int) onTabChanged;
  final double? width;
  final double height;

  // Tab indices
  static const int _locationTabIndex = 0;
  static const int _typeTabIndex = 1;
  static const int _needsTabIndex = 2;

  // Translation keys
  static const String _locationKey = 'filter_location';
  static const String _typeKey = 'filter_type';
  static const String _needsKey = 'filter_preferences';

  // Layout constants
  static const double _borderThickness = 2.0;

  /// Returns whether the given tab is currently selected
  bool _isSelected(int tabIndex) => activeTabIndex == tabIndex;

  /// Returns the text color based on selection state
  Color _getTitleColor(int tabIndex) {
    return _isSelected(tabIndex) ? AppColors.accent : AppColors.textSecondary;
  }

  /// Returns the translation key for the given tab index
  String _getTranslationKey(int tabIndex) {
    switch (tabIndex) {
      case _locationTabIndex:
        return _locationKey;
      case _typeTabIndex:
        return _typeKey;
      case _needsTabIndex:
        return _needsKey;
      default:
        return _locationKey;
    }
  }

  /// Builds a single tab button with appropriate styling and borders
  Widget _buildTabButton(WidgetRef ref, int tabIndex, double width) {
    final isSelected = _isSelected(tabIndex);
    final title = td(ref, _getTranslationKey(tabIndex));

    return GestureDetector(
      onTap: () => onTabChanged(tabIndex),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.accent : Colors.transparent,
              width: _borderThickness,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: AppTypography.label.copyWith(
            color: _getTitleColor(tabIndex),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalWidth = width ?? MediaQuery.of(context).size.width;

    // Exact column widths per design system: 36% / 33% / 31%
    final locationWidth = totalWidth * 0.36;
    final typeWidth = totalWidth * 0.33;
    final needsWidth = totalWidth * 0.31;

    return SizedBox(
      width: totalWidth,
      height: height,
      child: Row(
        children: [
          _buildTabButton(ref, _locationTabIndex, locationWidth),
          _buildTabButton(ref, _typeTabIndex, typeWidth),
          _buildTabButton(ref, _needsTabIndex, needsWidth),
        ],
      ),
    );
  }
}
