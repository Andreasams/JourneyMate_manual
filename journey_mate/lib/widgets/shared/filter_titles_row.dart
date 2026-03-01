import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/translation_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../utils/filter_count_helper.dart';
import '../../providers/search_providers.dart';
import '../../providers/filter_providers.dart';

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
///
/// Badge counts are calculated reactively by watching searchStateProvider
/// and filterProvider. This enables real-time badge updates when filters
/// are toggled, without needing to close and reopen the filter sheet.
///
/// Design:
/// - 3 columns with equal 33% distribution
/// - Active tab: orange background + white text
/// - Inactive tabs: white background + grey border + dark grey text
/// - Button-style containers with 10px border radius
/// - Count badges: 18px circle, orange when active, grey when inactive
/// - Uses td(ref, key) for translation
class FilterTitlesRow extends ConsumerWidget {
  const FilterTitlesRow({
    super.key,
    required this.activeTabIndex,
    required this.onTabChanged,
    this.width,
  });

  final int activeTabIndex;
  final Function(int) onTabChanged;
  final double? width;

  // Tab indices
  static const int _locationTabIndex = 0;
  static const int _typeTabIndex = 1;
  static const int _needsTabIndex = 2;

  // Translation keys
  static const String _locationKey = 'filter_location';
  static const String _typeKey = 'filter_type';
  static const String _needsKey = 'filter_preferences';

  // Layout constants
  static const double _verticalPadding = 9.0; // Internal padding (text to button edge)
  static const double _buttonSpacing = AppSpacing.sm; // 8px between buttons

  /// Returns whether the given tab is currently selected
  bool _isSelected(int tabIndex) => activeTabIndex == tabIndex;

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

  /// Calculate the badge count for a specific tab by watching providers.
  ///
  /// This method makes the widget reactive to filter state changes,
  /// enabling real-time badge updates when filters are toggled.
  int _getCountForTab(WidgetRef ref, int titleId) {
    // Watch search state for active filters and routed locations
    final searchState = ref.watch(searchStateProvider);

    // Watch filter state for lookup map
    final filterState = ref.watch(filterProvider);

    return filterState.when(
      data: (state) {
        // Calculate extra location count for routed filters
        final extraLocationCount = titleId == 1
            ? (searchState.selectedNeighbourhoodId != null ? 1 : 0) +
              (searchState.selectedShoppingAreaId != null ? 1 : 0)
            : 0;

        // Use shared utility to calculate counts
        final allCounts = calculateFilterCounts(
          searchState.filtersUsedForSearch,
          state.filterLookupMap,
          extraLocationCount: extraLocationCount,
        );

        return allCounts[titleId] ?? 0;
      },
      loading: () => 0,
      error: (_, __) => 0,
    );
  }

  /// Builds a single tab button with appropriate styling and borders
  Widget _buildTabButton(WidgetRef ref, int tabIndex, int flex) {
    final isSelected = _isSelected(tabIndex);
    final title = td(ref, _getTranslationKey(tabIndex));

    // Get count for this tab reactively from providers (titleId = tabIndex + 1)
    final titleId = tabIndex + 1;
    final count = _getCountForTab(ref, titleId);
    final showBadge = count > 0;

    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.only(
          right: tabIndex < 2 ? _buttonSpacing : 0, // 8px spacing between buttons
        ),
        child: GestureDetector(
          onTap: () => onTabChanged(tabIndex),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: _verticalPadding),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accent : AppColors.bgCard,
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.border,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(AppRadius.filter), // 10px
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyRegular.copyWith(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.bgCard : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                if (showBadge) ...[
                  SizedBox(width: 5),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.bgCard : AppColors.textDisabled,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? AppColors.accent : Colors.white,
                        height: 1.0,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: width ?? MediaQuery.of(context).size.width,
      child: Row(
        children: [
          // Experimenting with equal 33% widths instead of 36%/33%/31%
          _buildTabButton(ref, _locationTabIndex, 1), // 33% flex
          _buildTabButton(ref, _typeTabIndex, 1),     // 33% flex
          _buildTabButton(ref, _needsTabIndex, 1),    // 33% flex
        ],
      ),
    );
  }
}
