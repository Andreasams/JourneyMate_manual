import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/translation_service.dart';
import '../../providers/filter_providers.dart';
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
    required this.openPlacesCount,
  });

  final String currentSort;
  final bool onlyOpen;
  final int? selectedStation;
  final int openPlacesCount; // Count of open places matching current filters
  final void Function(String sortBy, bool onlyOpen, int? station)
      onSortChanged;

  @override
  ConsumerState<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends ConsumerState<SortBottomSheet> {
  late String _selectedSort;
  late bool _onlyOpen;
  String _view = 'options'; // 'options' or 'stations'

  // Train station category ID (parent filter)
  static const int _trainStationCategoryId = 7;

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.currentSort;
    _onlyOpen = widget.onlyOpen;
  }

  /// Gets train station list from filter provider
  /// Train stations have filter IDs in 10000+ range with parent_id = 7
  List<Map<String, dynamic>> _getTrainStations() {
    final filterState = ref.watch(filterProvider);

    return filterState.when(
      data: (state) {
        final filterLookupMap = state.filterLookupMap;

        // Get all filters with parent_id = 7 (Train Stations)
        // Null-safe: some station entries may have null filter_name
        final stations = filterLookupMap.entries
            .where((entry) => entry.value['parent_id'] == _trainStationCategoryId)
            .map((entry) => {
                  'id': entry.key,
                  'name': (entry.value['filter_name'] as String?) ?? '',
                })
            .where((s) => (s['name'] as String).isNotEmpty)
            .toList();

        // Sort alphabetically by name
        stations.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));

        return stations;
      },
      loading: () => [],
      error: (e, stack) => [],
    );
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
    final trainStations = _getTrainStations();

    return Column(
      children: [
        _buildStationsHeader(),
        Divider(height: 1, color: AppColors.border),
        Expanded(
          child: trainStations.isEmpty
              ? Center(
                  child: Text(
                    td(ref, 'hours_no_data'), // Generic "No data" message
                    style: AppTypography.bodyRegular.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: trainStations.length,
                  itemBuilder: (context, index) {
                    final station = trainStations[index];
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
        crossAxisAlignment: CrossAxisAlignment.start, // Left-align title
        children: [
          // Swipe indicator
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          // Title - left-aligned
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
          onTap: () {
            setState(() => _onlyOpen = !_onlyOpen);
            widget.onSortChanged(_selectedSort, _onlyOpen, widget.selectedStation);
          },
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: _onlyOpen ? AppColors.greenBg : AppColors.bgCard,
              border: Border.all(
                color: _onlyOpen
                    ? AppColors.greenBorder
                    : AppColors.border,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
                // Checkbox - green when selected
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _onlyOpen ? AppColors.green : Colors.transparent,
                    border: _onlyOpen
                        ? null
                        : Border.all(
                            color: AppColors.border,
                            width: 1.5,
                          ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: _onlyOpen
                      ? Icon(Icons.check, size: 11, color: Colors.white)
                      : null,
                ),
                SizedBox(width: AppSpacing.sm),
                // Label
                Expanded(
                  child: Text(
                    td(ref, 'filter_only_open'),
                    style: AppTypography.bodyRegular.copyWith(
                      fontWeight: _onlyOpen ? FontWeight.w600 : FontWeight.w400,
                      color: _onlyOpen
                          ? AppColors.green
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                // Count display when selected
                if (_onlyOpen)
                  Text(
                    '${widget.openPlacesCount} ${td(ref, 'sort_places_label')}',
                    style: AppTypography.bodyRegular.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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

  Widget _buildSortOption(String sortKey, String translationKey) {
    final isSelected = _selectedSort == sortKey;
    return Container(
      color: isSelected ? AppColors.bgPage : Colors.transparent,
      child: ListTile(
        title: Text(
          td(ref, translationKey),
          style: AppTypography.bodyRegular.copyWith(
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
          vertical: AppSpacing.md,
        ),
        onTap: () {
          setState(() => _selectedSort = sortKey);
          widget.onSortChanged(sortKey, _onlyOpen, widget.selectedStation);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildSortOptionWithSubmenu(String sortKey, String translationKey) {
    final isSelected = _selectedSort == sortKey;
    return Container(
      color: isSelected ? AppColors.bgPage : Colors.transparent,
      child: ListTile(
        title: Text(
          td(ref, translationKey),
          style: AppTypography.bodyRegular.copyWith(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
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
          vertical: AppSpacing.md,
        ),
        onTap: () {
          setState(() => _view = 'stations');
        },
      ),
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

    return Container(
      color: isSelected ? AppColors.bgPage : Colors.transparent,
      child: ListTile(
        title: Text(
          stationName,
          style: AppTypography.bodyRegular.copyWith(
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
          vertical: AppSpacing.md,
        ),
        onTap: () {
          setState(() => _selectedSort = 'station');
          widget.onSortChanged('station', _onlyOpen, stationId);
          Navigator.pop(context);
        },
      ),
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
