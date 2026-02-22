import 'package:flutter/material.dart';
import '../../services/translation_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';

/// Sort Bottom Sheet
/// Allows users to change sort order and toggle "only open" filter
/// Phase 7.3.2 implementation
class SortBottomSheet extends StatefulWidget {
  const SortBottomSheet({
    super.key,
    required this.currentSort,
    required this.onlyOpen,
    this.selectedStation,
    required this.onSortChanged,
  });

  final String currentSort;
  final bool onlyOpen;
  final int? selectedStation;
  final void Function(String sortBy, bool onlyOpen, int? station)
      onSortChanged;

  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  late String _selectedSort;
  late bool _onlyOpen;

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.currentSort;
    _onlyOpen = widget.onlyOpen;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.62,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.bottomSheet),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildOnlyOpenToggle(),
          Divider(height: 1, color: AppColors.border),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSortOption('match', 'sort_match'),
                _buildSortOption('nearest', 'sort_nearest'),
                _buildSortOption('station', 'sort_station'),
                _buildSortOption('price_low', 'sort_price_low'),
                _buildSortOption('price_high', 'sort_price_high'),
                _buildSortOption('newest', 'sort_newest'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // Swipe indicator
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          // Title
          Text(
            ts(context, 'sort_sheet_title'),
            style: AppTypography.sectionHeading,
          ),
        ],
      ),
    );
  }

  Widget _buildOnlyOpenToggle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: SwitchListTile(
        title: Text(
          ts(context, 'filter_only_open'),
          style: AppTypography.bodyRegular,
        ),
        value: _onlyOpen,
        activeColor: AppColors.accent,
        activeTrackColor: AppColors.accent.withValues(alpha: 0.5),
        contentPadding: EdgeInsets.zero,
        onChanged: (value) {
          setState(() => _onlyOpen = value);
          widget.onSortChanged(_selectedSort, value, widget.selectedStation);
        },
      ),
    );
  }

  Widget _buildSortOption(String sortKey, String translationKey) {
    final isSelected = _selectedSort == sortKey;
    return ListTile(
      title: Text(
        ts(context, translationKey),
        style: AppTypography.bodyRegular.copyWith(
          color: isSelected ? AppColors.accent : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: AppColors.accent, size: 24)
          : null,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      onTap: () {
        setState(() => _selectedSort = sortKey);
        widget.onSortChanged(sortKey, _onlyOpen, widget.selectedStation);
        Navigator.pop(context);
      },
    );
  }
}
