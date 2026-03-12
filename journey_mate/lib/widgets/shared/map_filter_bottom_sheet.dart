import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/search_providers.dart';
import '../../services/translation_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import '../../utils/search_result_helpers.dart';
import 'app_checkbox.dart';

/// Bottom sheet for map view filtering.
///
/// Combines the "only open" toggle (triggers API re-fetch) with match
/// visibility options (client-side marker filtering, no API call).
class MapFilterBottomSheet extends ConsumerStatefulWidget {
  const MapFilterBottomSheet({
    super.key,
    required this.onlyOpen,
    required this.matchVisibility,
    required this.partialMatchCount,
    required this.onOnlyOpenChanged,
    required this.onMatchVisibilityChanged,
  });

  final bool onlyOpen;
  final MapMatchVisibility matchVisibility;
  final int partialMatchCount;
  final Future<void> Function(bool onlyOpen) onOnlyOpenChanged;
  final void Function(MapMatchVisibility visibility) onMatchVisibilityChanged;

  @override
  ConsumerState<MapFilterBottomSheet> createState() =>
      _MapFilterBottomSheetState();
}

class _MapFilterBottomSheetState extends ConsumerState<MapFilterBottomSheet> {
  late bool _onlyOpen;
  late MapMatchVisibility _matchVisibility;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _onlyOpen = widget.onlyOpen;
    _matchVisibility = widget.matchVisibility;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.bottomSheet),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildOnlyOpenToggle(),
          _buildVisibilityOption(
            MapMatchVisibility.all,
            'map_filter_show_all',
          ),
          _buildVisibilityOption(
            MapMatchVisibility.fullOnly,
            'map_filter_show_full',
          ),
          if (widget.partialMatchCount > 0)
            _buildVisibilityOption(
              MapMatchVisibility.fullAndPartial,
              'map_filter_show_full_partial',
            ),
          // Bottom safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.dragHandle,
                borderRadius: BorderRadius.circular(AppRadius.handle),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            td(ref, 'map_filter_title'),
            style: AppTypography.h4,
          ),
        ],
      ),
    );
  }

  Widget _buildOnlyOpenToggle() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            setState(() {
              _onlyOpen = !_onlyOpen;
              _isSearching = true;
            });
            await widget.onOnlyOpenChanged(_onlyOpen);
            if (mounted) {
              setState(() => _isSearching = false);
            }
          },
          borderRadius: BorderRadius.circular(AppRadius.chip),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: _onlyOpen ? AppColors.greenBg : AppColors.bgCard,
              border: Border.all(
                color: _onlyOpen ? AppColors.greenBorder : AppColors.border,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
            child: Row(
              children: [
                AppCheckbox(
                  isSelected: _onlyOpen,
                  size: 20,
                  activeColor: AppColors.green,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    td(ref, 'filter_only_open'),
                    style: AppTypography.bodyLg.copyWith(
                      fontWeight: _onlyOpen ? FontWeight.w600 : FontWeight.w400,
                      color: _onlyOpen
                          ? AppColors.green
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (_onlyOpen && !_isSearching)
                  Text(
                    '${ref.watch(searchStateProvider).visibleResultCount} ${td(ref, 'sort_places_label')}',
                    style: AppTypography.bodySmMedium.copyWith(
                      color: AppColors.green,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisibilityOption(
      MapMatchVisibility value, String translationKey) {
    final isSelected = _matchVisibility == value;
    return Container(
      color: isSelected ? AppColors.bgSurface : Colors.transparent,
      child: ListTile(
        title: Text(
          td(ref, translationKey),
          style: AppTypography.bodyLg.copyWith(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        trailing: isSelected
            ? Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 11,
                ),
              )
            : null,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        onTap: () {
          setState(() => _matchVisibility = value);
          widget.onMatchVisibilityChanged(value);
        },
      ),
    );
  }
}
