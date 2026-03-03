import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/translation_service.dart';
import '../../providers/filter_providers.dart';
import '../../providers/search_providers.dart';
import '../../providers/settings_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import './search_bar_widget.dart';

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
  late int? _selectedStation; // Track selected station locally for immediate visual feedback
  String _view = 'options'; // 'options' or 'stations'

  final TextEditingController _stationSearchController = TextEditingController();
  String _stationSearchText = '';

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.currentSort;
    _onlyOpen = widget.onlyOpen;
    _selectedStation = widget.selectedStation;
  }

  @override
  void dispose() {
    _stationSearchController.dispose();
    super.dispose();
  }

  /// Gets train station list from filter provider
  /// Train stations have 'type' == 'train_station' or specific parent_id
  /// Filters by active neighbourhood when present
  List<Map<String, dynamic>> _getTrainStations() {
    final filterState = ref.read(filterProvider);
    final searchState = ref.read(searchStateProvider);

    return filterState.when(
      data: (state) {
        final filterLookupMap = state.filterLookupMap;
        final activeNeighbourhoodIds = searchState.selectedNeighbourhoodId;

        // Get filters that are train stations
        // Check type field or parent_id to distinguish from food items
        final stations = filterLookupMap.entries
            .where((entry) {
              final value = entry.value;
              final type = value['type'] as String?;
              final parentId = value['parent_id'];

              // Check if it's a train station
              final isTrainStation = type == 'train_station' ||
                     (entry.key >= 10000 && parentId == 7);

              // Apply neighbourhood filter if active
              if (isTrainStation && activeNeighbourhoodIds != null && activeNeighbourhoodIds.isNotEmpty) {
                final neighbourhoodId1 = value['neighbourhood_id_1'] as int?;
                final neighbourhoodId2 = value['neighbourhood_id_2'] as int?;

                // Station belongs to neighbourhood if EITHER field matches any selected neighbourhood
                return activeNeighbourhoodIds.any((nId) =>
                    neighbourhoodId1 == nId || neighbourhoodId2 == nId);
              }

              return isTrainStation;
            })
            .map((entry) => {
                  'id': entry.key,
                  'name': (entry.value['name'] as String?) ??
                          (entry.value['filter_name'] as String?) ?? '',
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
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    // When keyboard is visible, expand sheet to show more content
    // Otherwise use 65% of screen height
    final sheetHeight = keyboardHeight > 0
        ? MediaQuery.of(context).size.height * 0.85 // 85% when keyboard visible
        : MediaQuery.of(context).size.height * 0.65;

    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping on the sheet background
        FocusScope.of(context).unfocus();
      },
      child: Container(
        height: sheetHeight,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.bottomSheet),
          ),
        ),
        child: _view == 'options' ? _buildOptionsView() : _buildStationsView(),
      ),
    );
  }

  Widget _buildOptionsView() {
    // Only show "Nearest you" when location is available
    final locationState = ref.watch(locationProvider);
    final hasLocation = locationState.isLocationUsable;

    return Column(
      children: [
        _buildHeader(),
        _buildOnlyOpenToggle(),
        Divider(height: 1, color: AppColors.border),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              if (hasLocation)
                _buildSortOption('nearest', 'sort_nearest'),
              _buildSortOptionWithSubmenu('station', 'sort_station', widget.selectedStation),
              _buildSortOption('price_low', 'sort_price_low'),
              _buildSortOption('price_high', 'sort_price_high'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStationsView() {
    final allStations = _getTrainStations();
    final filteredStations = _stationSearchText.isEmpty
        ? allStations
        : allStations
            .where((s) => (s['name'] as String)
                .toLowerCase()
                .contains(_stationSearchText.toLowerCase()))
            .toList();

    return Column(
      children: [
        _buildStationsHeader(),
        Divider(height: 1, color: AppColors.border),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: SearchBarWidget(
            hintTextKey: 'search_placeholder_train_station',
            controller: _stationSearchController,
            onChanged: (text) => setState(() => _stationSearchText = text),
          ),
        ),
        Expanded(
          child: filteredStations.isEmpty
              ? Center(
                  child: Text(
                    td(ref, 'hours_no_data'),
                    style: AppTypography.bodyRegular.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.only(
                    bottom: AppSpacing.md, // Standard padding - sheet height handles keyboard
                  ),
                  itemCount: filteredStations.length,
                  itemBuilder: (context, index) {
                    return _buildStationOption(filteredStations[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: 0, // No bottom padding - toggle container controls gap
      ),
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
          borderRadius: BorderRadius.circular(AppRadius.chip),
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
              borderRadius: BorderRadius.circular(AppRadius.chip),
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
      color: isSelected ? AppColors.bgSurface : Colors.transparent,
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
          vertical: AppSpacing.sm,
        ),
        onTap: () {
          // Toggle behavior: if already selected, deselect (return to 'nearest' default)
          // Backend handles degradation to alphabetical when location is off
          final newSort = isSelected ? 'nearest' : sortKey;
          setState(() => _selectedSort = newSort);
          widget.onSortChanged(newSort, _onlyOpen, widget.selectedStation);
          // Only close on selection; deselection keeps sheet open so user sees the reset state
          if (!isSelected) Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildSortOptionWithSubmenu(String sortKey, String translationKey, int? selectedStationId) {
    final isSelected = _selectedSort == sortKey;
    final searchState = ref.read(searchStateProvider);
    final hasShoppingArea = searchState.selectedShoppingAreaId != null;

    // Get station name if a station is selected (use local state for immediate visual feedback)
    String displayText = td(ref, translationKey);
    if (_selectedStation != null) {
      final trainStations = _getTrainStations();
      final selectedStation = trainStations.firstWhere(
        (s) => s['id'] == _selectedStation,
        orElse: () => <String, Object>{},
      );
      if (selectedStation.isNotEmpty) {
        final stationName = selectedStation['name'] as String;
        displayText = '${td(ref, translationKey)}: $stationName';
      }
    }

    return Container(
      color: isSelected ? AppColors.bgSurface : Colors.transparent,
      child: Opacity(
        opacity: hasShoppingArea ? 0.4 : 1.0,
        child: IgnorePointer(
          ignoring: hasShoppingArea,
          child: ListTile(
            title: Text(
              displayText,
              style: AppTypography.bodyRegular.copyWith(
                color: hasShoppingArea
                    ? AppColors.textSecondary.withValues(alpha: 0.5)
                    : (isSelected ? AppColors.textPrimary : AppColors.textSecondary),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: hasShoppingArea
                  ? AppColors.textSecondary.withValues(alpha: 0.5)
                  : AppColors.textSecondary,
              size: 24,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            onTap: () {
              setState(() => _view = 'stations');
            },
          ),
        ),
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
                onPressed: () {
                  _stationSearchController.clear();
                  setState(() {
                    _view = 'options';
                    _stationSearchText = '';
                  });
                },
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
    final isSelected = _selectedStation == stationId; // Use local state for immediate visual feedback

    return Container(
      color: isSelected ? AppColors.bgSurface : Colors.transparent,
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
          vertical: AppSpacing.sm,
        ),
        onTap: () {
          // Toggle behavior: if already selected, deselect (return to 'nearest' default)
          // Backend handles degradation to alphabetical when location is off
          if (isSelected) {
            setState(() {
              _selectedSort = 'nearest';
              _selectedStation = null; // Clear local station selection
            });
            widget.onSortChanged('nearest', _onlyOpen, null);
            // Keep sheet open on deselection so user sees the reset state
          } else {
            setState(() {
              _selectedSort = 'station';
              _selectedStation = stationId; // Update local station selection
            });
            widget.onSortChanged('station', _onlyOpen, stationId);
            Navigator.pop(context);
          }
        },
      ),
    );
  }

}
