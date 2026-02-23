import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/translation_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';

/// Sort Bottom Sheet
/// Allows users to change sort order and toggle "only open" filter
/// Phase 7.3.2 implementation
class SortBottomSheet extends ConsumerStatefulWidget {
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
  ConsumerState<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends ConsumerState<SortBottomSheet> {
  late String _selectedSort;
  late bool _onlyOpen;
  String _view = 'options'; // 'options' or 'stations'

  // Mock train station data (TODO: Replace with real data)
  final List<Map<String, dynamic>> _trainStations = [
    {'id': 1, 'name': 'København H'},
    {'id': 2, 'name': 'Nørreport'},
    {'id': 3, 'name': 'Østerport'},
    {'id': 4, 'name': 'Vesterport'},
    {'id': 5, 'name': 'Christianshavn'},
  ];

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
      child: _view == 'options' ? _buildOptionsView() : _buildStationsView(),
    );
  }

  Widget _buildOptionsView() {
    return Column(
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
              _buildSortOptionWithSubmenu('station', 'sort_station'),
              _buildSortOption('price_low', 'sort_price_low'),
              _buildSortOption('price_high', 'sort_price_high'),
              _buildSortOption('newest', 'sort_newest'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStationsView() {
    return Column(
      children: [
        _buildStationsHeader(),
        Divider(height: 1, color: AppColors.border),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: _trainStations.length,
            itemBuilder: (context, index) {
              final station = _trainStations[index];
              return _buildStationOption(station);
            },
          ),
        ),
        _buildStationsFooter(),
      ],
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
            td(ref, 'sort_sheet_title'),
            style: AppTypography.sectionHeading,
          ),
        ],
      ),
    );
  }

  Widget _buildOnlyOpenToggle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: GestureDetector(
        onTap: () {
          setState(() => _onlyOpen = !_onlyOpen);
          widget.onSortChanged(_selectedSort, _onlyOpen, widget.selectedStation);
        },
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _onlyOpen ? AppColors.accent : Colors.transparent,
                border: Border.all(
                  color: _onlyOpen ? AppColors.accent : AppColors.border,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: _onlyOpen
                  ? Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            SizedBox(width: AppSpacing.sm),
            // Label
            Expanded(
              child: Text(
                td(ref, 'filter_only_open'),
                style: AppTypography.bodyRegular,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String sortKey, String translationKey) {
    final isSelected = _selectedSort == sortKey;
    return ListTile(
      title: Text(
        td(ref, translationKey),
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

  Widget _buildSortOptionWithSubmenu(String sortKey, String translationKey) {
    final isSelected = _selectedSort == sortKey;
    return ListTile(
      title: Text(
        td(ref, translationKey),
        style: AppTypography.bodyRegular.copyWith(
          color: isSelected ? AppColors.accent : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
        size: 24,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      onTap: () {
        setState(() => _view = 'stations');
      },
    );
  }

  Widget _buildStationsHeader() {
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
          // Back button + Title
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => setState(() => _view = 'options'),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  td(ref, 'sort_select_station'),
                  style: AppTypography.sectionHeading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStationOption(Map<String, dynamic> station) {
    final stationId = station['id'] as int;
    final stationName = station['name'] as String;
    final isSelected = widget.selectedStation == stationId;

    return ListTile(
      title: Text(
        stationName,
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
        setState(() => _selectedSort = 'station');
        widget.onSortChanged('station', _onlyOpen, stationId);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildStationsFooter() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            '💡',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'I den færdige app vil dette sortere steder efter afstand til den valgte station via Typesense & BuildShip.',
              style: AppTypography.bodyRegular.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
