import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';
import '../../providers/search_providers.dart';
import '../../providers/filter_providers.dart';
import '../../providers/settings_providers.dart';
import '../../providers/provider_state_classes.dart';
import '../../services/api_service.dart';
import '../../services/analytics_service.dart';
import '../../services/translation_service.dart';
import '../../utils/filter_count_helper.dart';
import '../../utils/search_result_helpers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_constants.dart';
import '../../widgets/shared/search_results_list_view.dart';
import '../../widgets/shared/search_results_map_view.dart';
import '../../widgets/shared/selected_filters_btns.dart';
import '../../widgets/shared/filter_overlay_widget.dart';
import '../../widgets/shared/filter_titles_row.dart';
import '../../widgets/shared/nav_bar_widget.dart';
import '../../widgets/shared/restaurant_list_shimmer_widget.dart';
import '../../widgets/shared/search_bar_widget.dart';
import '../../widgets/shared/sort_bottom_sheet.dart';
import '../../widgets/shared/map_filter_bottom_sheet.dart';

/// Search Page - Main restaurant discovery page
/// Phase 7.3.2 implementation
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

/// Search results display mode.
enum _ViewMode { list, map }

class _SearchPageState extends ConsumerState<SearchPage> {
  // Local state
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  DateTime? _pageStartTime;
  bool _isLoading = false;
  String? _errorMessage;
  int _requestId = 0;
  int _currentPage = 1;
  // Sort state
  String _currentSort = 'nearest';
  bool _onlyOpen = false;
  int? _selectedStation;
  _ViewMode _viewMode = _ViewMode.list;
  MapMatchVisibility _matchVisibility = MapMatchVisibility.all;
  /// Tracks the pageSize used for the most recent search.
  /// Map view needs all results (200); list view uses default (20).
  int _lastSearchPageSize = 20;
  static const int _listPageSize = 20;
  static const int _mapPageSize = 200;

  // Filter overlay state
  int _activeFilterTab = 0;
  bool _isFilterSheetOpen = false;

  // Banner swipe state
  double _bannerDragOffset = 0.0;      // Current horizontal offset during drag
  bool _isBannerDismissing = false;    // Dismiss animation in progress
  double _bannerWidth = 0.0;           // Captured banner width for threshold calculation

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  /// Normalizes sort value to ensure valid sort option
  /// Falls back to 'nearest' if sort is null, empty, or invalid
  /// This ensures "nearest you" is always the default sort, even when
  /// location permission is not granted (UI will hide the option but
  /// backend will still use it for sorting)
  String _normalizeSort(String? sortValue) {
    if (sortValue == null || sortValue.isEmpty) {
      return 'nearest';
    }

    // Validate against allowed sort options
    const validSorts = ['nearest', 'station', 'price_low', 'price_high'];
    if (!validSorts.contains(sortValue)) {
      return 'nearest';
    }

    return sortValue;
  }

  @override
  void dispose() {
    _trackPageView();
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _trackPageView() {
    if (_pageStartTime == null) return;
    final duration = DateTime.now().difference(_pageStartTime!);

    final analytics = AnalyticsService.instance;
    unawaited(ApiService.instance.postAnalytics(
      eventType: 'page_viewed',
      deviceId: analytics.deviceId ?? '',
      sessionId: analytics.currentSessionId ?? '',
      userId: analytics.userId ?? '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'pageName': 'searchPage',
        'durationSeconds': duration.inSeconds,
      },
    ));
  }

  Future<void> _initialize() async {
    // Refresh location state (checks both service + permission)
    final locationNotifier = ref.read(locationProvider.notifier);
    await locationNotifier.checkPermission();

    // Pre-fetch location for immediate availability
    await locationNotifier.getCurrentPosition();

    // Load initial results, or re-fetch if cached results lack location data.
    // The welcome page pre-fetches results, but if location wasn't available yet
    // those results are sorted alphabetically instead of by "near me".
    final searchState = ref.read(searchStateProvider);
    final locationState = ref.read(locationProvider);
    final needsFresh = searchState.searchResults == null ||
        (locationState.isLocationUsable && !searchState.fetchedWithLocation);

    if (needsFresh) {
      await _executeSearch('');
    }
  }

  void _onSearchTextChanged(String text) {
    // Update provider state immediately (for UI display)
    ref.read(searchStateProvider.notifier).setSearchText(text);

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new timer (200ms delay)
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        _executeSearch(text);
      }
    });
  }

  Future<void> _executeSearch(String query, {int? pageSize}) async {
    final effectivePageSize = pageSize ??
        (_viewMode == _ViewMode.map ? _mapPageSize : _listPageSize);
    final currentRequestId = ++_requestId;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _matchVisibility = MapMatchVisibility.all;
      _currentPage = 1;
    });

    final searchState = ref.read(searchStateProvider);

    // Get user location from provider (cached for 5 minutes)
    final position = await ref.read(locationProvider.notifier).getCurrentPosition();

    // ignore: use_build_context_synchronously
    final languageCode = Localizations.localeOf(context).languageCode;

    try {
      final response = await ApiService.instance.search(
        filters: searchState.filtersUsedForSearch,
        cityId: AppConstants.kDefaultCityId.toString(),
        searchInput: query,
        userLocation: position != null
            ? 'LatLng(lat: ${position.latitude}, lng: ${position.longitude})'
            : null,
        languageCode: languageCode,
        sortBy: _normalizeSort(_currentSort),
        sortOrder: 'desc',
        selectedStation: _selectedStation,
        onlyOpen: _onlyOpen,
        pageSize: effectivePageSize,
        neighbourhoodId: searchState.selectedNeighbourhoodId,
        shoppingAreaId: searchState.selectedShoppingAreaId,
      );

      // Ignore if newer request already started
      if (_requestId != currentRequestId) return;

      if (response.succeeded && mounted) {
        final jsonBody = response.jsonBody;
        final documents = jsonBody['documents'] as List? ?? [];
        final resultCount = jsonBody['resultCount'] as int? ?? documents.length;
        final fullMatchCount = (jsonBody['fullMatchCount'] as num?)?.toInt() ?? 0;
        final activeIds = (jsonBody['activeids'] as List?)
            ?.map((e) => (e as num).toInt())
            .toList() ?? [];
        final scoringFilterIds = (jsonBody['scoringFilterIds'] as List?)
            ?.map((e) => (e as num).toInt())
            .toList() ?? [];
        final hasMore = jsonBody['pagination']?['hasMore'] == true;

        ref.read(searchStateProvider.notifier).updateSearchResults(
          documents,
          resultCount,
          fullMatchCount,
          scoringFilterIds,
          fetchedWithLocation: position != null,
          hasMore: hasMore,
        );

        _lastSearchPageSize = effectivePageSize;

        // Store API's active filter IDs
        ref.read(searchStateProvider.notifier).updateActiveFilterIds(activeIds);

        // Track analytics
        final analytics = AnalyticsService.instance;
        ApiService.instance.postAnalytics(
          eventType: 'search_performed',
          deviceId: analytics.deviceId ?? '',
          sessionId: analytics.currentSessionId ?? '',
          userId: analytics.userId ?? '',
          timestamp: DateTime.now().toIso8601String(),
          eventData: {
            'query': query,
            'resultsCount': resultCount,
            'filtersActive': searchState.filtersUsedForSearch.isNotEmpty,
          },
        );
      } else if (mounted) {
        setState(() {
          _errorMessage = response.error ?? 'Search failed';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Loads the next page of search results and appends to the existing list.
  /// Guards against duplicate requests, non-list views, and no-more-pages.
  Future<void> _loadMoreResults() async {
    final searchState = ref.read(searchStateProvider);
    if (searchState.isLoadingMore || !searchState.hasMore) return;
    if (_viewMode != _ViewMode.list) return;

    final currentRequestId = ++_requestId;
    ref.read(searchStateProvider.notifier).setLoadingMore(true);

    final position = await ref.read(locationProvider.notifier).getCurrentPosition();
    // ignore: use_build_context_synchronously
    final languageCode = Localizations.localeOf(context).languageCode;
    final nextPage = _currentPage + 1;

    try {
      final response = await ApiService.instance.search(
        filters: searchState.filtersUsedForSearch,
        cityId: AppConstants.kDefaultCityId.toString(),
        searchInput: searchState.currentSearchText,
        userLocation: position != null
            ? 'LatLng(lat: ${position.latitude}, lng: ${position.longitude})'
            : null,
        languageCode: languageCode,
        sortBy: _normalizeSort(_currentSort),
        sortOrder: 'desc',
        selectedStation: _selectedStation,
        onlyOpen: _onlyOpen,
        pageSize: _listPageSize,
        page: nextPage,
        neighbourhoodId: searchState.selectedNeighbourhoodId,
        shoppingAreaId: searchState.selectedShoppingAreaId,
      );

      // Discard if a newer request started (user triggered fresh search)
      if (_requestId != currentRequestId) return;

      if (response.succeeded && mounted) {
        final jsonBody = response.jsonBody;
        final documents = jsonBody['documents'] as List? ?? [];
        final hasMore = jsonBody['pagination']?['hasMore'] == true;

        ref.read(searchStateProvider.notifier).appendSearchResults(
          documents,
          hasMore,
        );
        _currentPage = nextPage;
      } else if (mounted) {
        // Silent failure for load-more — don't show full-page error
        ref.read(searchStateProvider.notifier).setLoadingMore(false);
      }
    } catch (_) {
      if (mounted) {
        ref.read(searchStateProvider.notifier).setLoadingMore(false);
      }
    }
  }

  Future<void> _openFilterOverlay() async {
    // Get filter state (needed for FilterOverlayWidget props)
    final filterState = ref.read(filterProvider);

    if (!mounted) return;

    setState(() => _isFilterSheetOpen = true);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.84,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          // Use StatefulBuilder to manage local state within bottom sheet
          return StatefulBuilder(
            builder: (context, setBottomSheetState) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.bottomSheet),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    // Swipe indicator
                    _buildSheetHandle(),

                    // 3-tab header
                    Padding(
                      padding: EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xsm),
                      child: FilterTitlesRow(
                        activeTabIndex: _activeFilterTab,
                        onTabChanged: (index) {
                          // Update both SearchPage state and bottom sheet state
                          setState(() => _activeFilterTab = index);
                          setBottomSheetState(() => _activeFilterTab = index);
                        },
                      ),
                    ),

                    // Selected filter chips (visible only when filters are active)
                    Consumer(
                      builder: (context, ref, _) {
                        final currentSearchState = ref.watch(searchStateProvider);
                        final hasFilters = currentSearchState.filtersUsedForSearch.isNotEmpty ||
                            currentSearchState.selectedNeighbourhoodId != null ||
                            currentSearchState.selectedShoppingAreaId != null;
                        if (!hasFilters) return const SizedBox.shrink();
                        // Force full width so SingleChildScrollView gets a
                        // full-width viewport and chips stay left-aligned
                        // (matches search page's CrossAxisAlignment.stretch)
                        return SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: EdgeInsets.zero,
                            child: filterState.when(
                              data: (state) => SelectedFiltersBtns(
                                filters: state.filtersForLanguage,
                                languageCode: Localizations.localeOf(context).languageCode,
                                translationsCache: ref.watch(translationsCacheProvider),
                                onClearAll: () {
                                  final searchText = ref.read(searchStateProvider).currentSearchText;
                                  _executeSearch(searchText);
                                },
                                onFilterRemoved: (_) {
                                  final searchText = ref.read(searchStateProvider).currentSearchText;
                                  _executeSearch(searchText);
                                },
                              ),
                              loading: () => const SizedBox.shrink(),
                              error: (_, _) => const SizedBox.shrink(),
                            ),
                          ),
                        );
                      },
                    ),

                    // Filter content
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, _) {
                          final currentSearchState = ref.watch(searchStateProvider);
                          return filterState.when(
                            data: (state) => FilterOverlayWidget(
                              filterData: state.filtersForLanguage,
                              selectedTitleID: _mapTabIndexToTitleId(_activeFilterTab),
                              activeFilterIds: currentSearchState.activeFilterIds,
                              selectedFilterIds: currentSearchState.filtersUsedForSearch,
                              onSearchCompleted: (activeIds, count, fullMatchCount, documents, scoringFilterIds) async {
                                // Update active filter IDs
                                ref.read(searchStateProvider.notifier).updateActiveFilterIds(activeIds);

                                // Update search results with restaurant documents
                                ref.read(searchStateProvider.notifier).updateSearchResults(
                                  documents,
                                  count,
                                  fullMatchCount,
                                  scoringFilterIds,
                                );

                                if (mounted) {
                                  setState(() {
                                    // Trigger rebuild with new search results
                                  });
                                }
                              },
                              onCloseOverlay: (selectedIds) async {
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                              searchTerm: currentSearchState.currentSearchText,
                              mayLoad: true,
                              resultCount: currentSearchState.visibleResultCount,
                              activeTabIndex: _activeFilterTab,
                              onShoppingAreaSelected: () {
                                // Reset sort to nearest if currently using station sort
                                if (_currentSort == 'station') {
                                  setState(() {
                                    _currentSort = 'nearest';
                                    _selectedStation = null;
                                  });
                                  // Trigger new search with updated sort
                                  final currentSearchText = ref.read(searchStateProvider).currentSearchText;
                                  _executeSearch(currentSearchText);
                                }
                              },
                              onNeighbourhoodSelected: () {
                                // Check if selected station is still valid for the new neighbourhood(s)
                                if (_currentSort == 'station' && _selectedStation != null) {
                                  final searchState = ref.read(searchStateProvider);
                                  final neighbourhoodIds = searchState.selectedNeighbourhoodId;

                                  if (neighbourhoodIds != null && neighbourhoodIds.isNotEmpty) {
                                    // Check if station belongs to any of the selected neighbourhoods
                                    final filterState = ref.read(filterProvider);
                                    final isStationInNeighbourhood = filterState.when(
                                      data: (state) {
                                        final stationData = state.filterLookupMap[_selectedStation];
                                        if (stationData != null) {
                                          final neighbourhoodId1 = stationData['neighbourhood_id_1'] as int?;
                                          final neighbourhoodId2 = stationData['neighbourhood_id_2'] as int?;
                                          return neighbourhoodIds.any((nId) =>
                                              neighbourhoodId1 == nId || neighbourhoodId2 == nId);
                                        }
                                        return false;
                                      },
                                      loading: () => true, // Keep station while loading
                                      error: (e, s) => true, // Keep station on error
                                    );

                                    // Reset to nearest if station is not in any selected neighbourhood
                                    if (!isStationInNeighbourhood) {
                                      setState(() {
                                        _currentSort = 'nearest';
                                        _selectedStation = null;
                                      });
                                      // Trigger new search with updated sort
                                      final currentSearchText = searchState.currentSearchText;
                                      _executeSearch(currentSearchText);
                                    }
                                  }
                                }
                              },
                            ),
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (e, _) => Center(
                              child: Text(td(ref, 'error_load_filters')),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );

    // Reset state when sheet closes and re-trigger search with updated filters
    if (mounted) {
      setState(() => _isFilterSheetOpen = false);
      // Re-execute search with updated filter state (same pattern as _openSortBottomSheet)
      final searchText = ref.read(searchStateProvider).currentSearchText;
      _executeSearch(searchText);
    }
  }

  Widget _buildSheetHandle() {
    return Container(
      margin: EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.dragHandle,
        borderRadius: BorderRadius.circular(AppRadius.handle),
      ),
    );
  }

  int _mapTabIndexToTitleId(int tabIndex) {
    // FilterTitlesRow tab index → FilterOverlayWidget title ID
    // Title IDs confirmed from GET /filters API response (params: language_code, city_id):
    //   id:1 = Location (Lage), id:2 = Type (Typ), id:3 = Preferences (Præferencer)
    switch (tabIndex) {
      case 0:
        return 1; // Location
      case 1:
        return 2; // Business Type
      case 2:
        return 3; // Food/Dietary Preferences
      default:
        return 1;
    }
  }

  void _openSortBottomSheet() {
    final searchState = ref.read(searchStateProvider);

    // Use visibleResultCount: the exact number of items rendered by SearchResultsListView
    final openPlacesCount = _onlyOpen ? searchState.visibleResultCount : 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SortBottomSheet(
        currentSort: _currentSort,
        onlyOpen: _onlyOpen,
        selectedStation: _selectedStation,
        openPlacesCount: openPlacesCount,
        onSortChanged: (sortBy, onlyOpen, station) async {
          setState(() {
            _currentSort = _normalizeSort(sortBy);
            _onlyOpen = onlyOpen;
            _selectedStation = station;
          });
          // Save search text to local variable to avoid ref access after unmount
          final searchText = ref.read(searchStateProvider).currentSearchText;
          await _executeSearch(searchText);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchStateProvider);
    final translationsCache = ref.watch(translationsCacheProvider);
    final locationState = ref.watch(locationProvider);
    final filterState = ref.watch(filterProvider);

    // Calculate filter counts per category for badges
    // Include routed neighbourhood/shopping area in Location tab badge count
    final extraLocationCount = (searchState.selectedNeighbourhoodId?.length ?? 0)
                             + (searchState.selectedShoppingAreaId != null ? 1 : 0);
    final filterCounts = _calculateFilterCounts(
      searchState.filtersUsedForSearch,
      filterState,
      extraLocationCount: extraLocationCount,
    );

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        elevation: 0,
        toolbarHeight: 0, // Minimal AppBar (status bar only)
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fixed header section
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl, // 20px per JSX
                8, // 8px (increased from 6px for better visibility)
                AppSpacing.xl, // 20px per JSX
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // City header
                  _buildCityHeader(),
                  SizedBox(height: AppSpacing.md),

                  // Search bar
                  _buildSearchBar(),
                  SizedBox(height: AppSpacing.lg),

                  // Page title
                  _buildPageTitle(searchState),
                  SizedBox(height: AppSpacing.md),

                  // 3-button filter row
                  _buildFilterButtonRow(filterCounts),
                  SizedBox(height: AppSpacing.md),

                  // Liste/Kort view toggle
                  _buildViewToggle(),
                ],
              ),
            ),

            // Selected filters chips (include routed neighbourhood/shopping area IDs)
            if (searchState.filtersUsedForSearch.isNotEmpty ||
                searchState.selectedNeighbourhoodId != null ||
                searchState.selectedShoppingAreaId != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl), // 20px per JSX
                child: filterState.when(
                  data: (state) => SelectedFiltersBtns(
                    filters: state.filtersForLanguage,
                    languageCode: Localizations.localeOf(context).languageCode,
                    translationsCache: translationsCache,
                    onClearAll: () {
                      final searchText = ref.read(searchStateProvider).currentSearchText;
                      _executeSearch(searchText);
                    },
                    onFilterRemoved: (_) {
                      final searchText = ref.read(searchStateProvider).currentSearchText;
                      _executeSearch(searchText);
                    },
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ),

            // Add consistent spacing when filters are not visible
            if (searchState.filtersUsedForSearch.isEmpty &&
                searchState.selectedNeighbourhoodId == null &&
                searchState.selectedShoppingAreaId == null)
              SizedBox(height: AppSpacing.md), // 12px - matches filter bottom padding

            // Location permission banner (show if location not usable AND not dismissed)
            if (!locationState.isLocationUsable && !locationState.isBannerDismissed)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl), // 20px per JSX
                child: _buildLocationBanner(),
              ),

            // Spacing after location banner (if shown)
            if (!locationState.hasPermission && !locationState.isBannerDismissed)
              SizedBox(height: AppSpacing.md),

            // Content with floating button
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Search results list
                  _buildContent(),

                  // Floating button: sort (list view) or open-only chip (map view)
                  Positioned(
                    bottom: 12.0,
                    right: AppSpacing.xl, // 20px per JSX
                    child: _viewMode == _ViewMode.map
                        ? _buildMapFloatingButton()
                        : _buildSortButton(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavBarWidget(pageIsSearchResults: true),
    );
  }

  Widget _buildCityHeader() {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: 15, // Increased from 14 to match JSX
          color: AppColors.accent,
        ),
        SizedBox(width: AppSpacing.xs),
        Text(
          td(ref, 'city_copenhagen'), // FlutterFlow legacy key for Copenhagen
          style: AppTypography.bodyLg.copyWith(
            fontSize: 15, // Increased from 13.5 to match JSX
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SearchBarWidget(
      hintTextKey: 'search_placeholder_restaurants',
      controller: _searchController,
      onChanged: _onSearchTextChanged,
      onSubmitted: _executeSearch,
    );
  }

  Widget _buildPageTitle(SearchState searchState) {
    final hasActiveFiltersOrSearch =
        searchState.filtersUsedForSearch.isNotEmpty ||
        searchState.selectedNeighbourhoodId != null ||
        searchState.selectedShoppingAreaId != null ||
        searchState.currentSearchText.isNotEmpty;

    // Use visibleResultCount (matches what SearchResultsListView displays)
    final count = searchState.visibleResultCount;

    String title;
    if (hasActiveFiltersOrSearch) {
      title = '${td(ref, 'feedback_page_search_results')} ($count)';
    } else if (_currentSort == 'station' && _selectedStation != null) {
      // Show "Places near [station]" when sorting by train station
      final stationName = ref.read(filterProvider).whenOrNull(
        data: (state) {
          final data = state.filterLookupMap[_selectedStation];
          return (data?['name'] as String?) ??
                 (data?['filter_name'] as String?);
        },
      );
      if (stationName != null) {
        final template = td(ref, 'search_places_near_station');
        // Use template if translation exists and contains placeholder,
        // otherwise fall back to default
        title = template != 'search_places_near_station' &&
                template.contains('{station}')
            ? template.replaceAll('{station}', stationName)
            : td(ref, 'search_places_near_you');
      } else {
        title = td(ref, 'search_places_near_you');
      }
    } else {
      title = td(ref, 'search_places_near_you');
    }

    return Text(
      title,
      style: AppTypography.h1,
    );
  }

  Widget _buildFilterButtonRow(Map<int, int> filterCounts) {
    // Use same translation keys as FilterTitlesRow widget
    final filterCategories = [
      {'titleId': 1, 'translationKey': 'filter_location'},
      {'titleId': 2, 'translationKey': 'filter_type'},
      {'titleId': 3, 'translationKey': 'filter_preferences'},
    ];

    return Row(
      children: filterCategories.map((category) {
        final titleId = category['titleId'] as int;
        final translationKey = category['translationKey'] as String;
        final label = td(ref, translationKey);
        final count = filterCounts[titleId] ?? 0;
        final isActive = _isFilterSheetOpen && _activeFilterTab == (titleId - 1);

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: titleId < 3 ? AppSpacing.sm : 0,
            ),
            child: _buildFilterButton(
              label: label,
              count: count,
              isActive: isActive,
              onTap: () => _openFilterOverlayAtTab(titleId - 1),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required int count,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent : AppColors.bgCard,
          border: Border.all(
            color: isActive ? AppColors.accent : AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(AppRadius.filter),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Text(
                count > 0 && !isActive ? '$label ($count)' : label,
                style: AppTypography.bodySmMedium.copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? AppColors.bgCard : AppColors.textSecondary,
                ),
              ),
            ),
            // Orange dot indicator (top-right)
            // Negative top value accounts for 9px vertical padding to position in visual corner
            if (count > 0 && !isActive)
              Positioned(
                top: -1,
                right: 8,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Switches between list and map view modes.
  ///
  /// Map view needs all results (pageSize 200) to populate markers.
  /// List view uses the default 20. Re-fetches when the current results
  /// were fetched with the wrong pageSize for the new mode.
  void _switchViewMode(_ViewMode newMode) {
    if (_viewMode == newMode) return;
    setState(() => _viewMode = newMode);

    final neededPageSize = newMode == _ViewMode.map ? _mapPageSize : _listPageSize;
    if (_lastSearchPageSize != neededPageSize) {
      final query = ref.read(searchStateProvider).currentSearchText;
      _executeSearch(query, pageSize: neededPageSize);
    }
  }

  Widget _buildViewToggle() {
    return Row(
      children: [
        // Liste button (left)
        Expanded(
          child: GestureDetector(
            onTap: () => _switchViewMode(_ViewMode.list),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: _viewMode == _ViewMode.list ? AppColors.white : AppColors.bgInput,
                border: Border.all(color: AppColors.border, width: 1.5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.format_list_bulleted,
                    size: 16,
                    color: _viewMode == _ViewMode.list ? AppColors.accent : AppColors.textPrimary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    td(ref, 'view_toggle_list'), // Use translation key
                    style: AppTypography.bodySmMedium.copyWith(
                      fontWeight: _viewMode == _ViewMode.list ? FontWeight.w600 : FontWeight.w500,
                      color: _viewMode == _ViewMode.list ? AppColors.accent : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Kort button (right) - overlaps border with negative margin
        Expanded(
          child: Transform.translate(
            offset: Offset(-1.5, 0), // Overlap left border
            child: GestureDetector(
              onTap: () => _switchViewMode(_ViewMode.map),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _viewMode == _ViewMode.map ? AppColors.white : AppColors.bgInput,
                  border: Border.all(color: AppColors.border, width: 1.5),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: _viewMode == _ViewMode.map ? AppColors.accent : AppColors.textPrimary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      td(ref, 'action_map'), // Use translation key
                      style: AppTypography.bodySmMedium.copyWith(
                        fontWeight: _viewMode == _ViewMode.map ? FontWeight.w600 : FontWeight.w500,
                        color: _viewMode == _ViewMode.map ? AppColors.accent : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSortButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppRadius.pill), // Pill shape
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openSortBottomSheet,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.mlg, vertical: AppSpacing.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sort,
                  size: 12,
                  color: Colors.white,
                ),
                SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    _getSortButtonText(),
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Floating "open only" chip for map view — mirrors the sort sheet toggle.
  Widget _buildOpenOnlyChip() {
    return Container(
      decoration: BoxDecoration(
        color: _onlyOpen ? AppColors.greenBg : AppColors.bgCard,
        border: Border.all(
          color: _onlyOpen ? AppColors.greenBorder : AppColors.border,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(AppRadius.pill), // Pill shape
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _onlyOpen = !_onlyOpen);
            final searchText =
                ref.read(searchStateProvider).currentSearchText;
            _executeSearch(searchText);
          },
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.mlg,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Checkbox indicator
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _onlyOpen ? AppColors.green : Colors.transparent,
                    border: _onlyOpen
                        ? null
                        : Border.all(color: AppColors.border, width: 1.5),
                    borderRadius: BorderRadius.circular(AppRadius.checkbox),
                  ),
                  child: _onlyOpen
                      ? Icon(Icons.check, size: 10, color: Colors.white)
                      : null,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  td(ref, 'filter_only_open'),
                  style: AppTypography.bodyMedium.copyWith(
                    color: _onlyOpen
                        ? AppColors.green
                        : AppColors.textSecondary,
                    fontWeight:
                        _onlyOpen ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Floating button for map view — shows simple open-only chip when no scored
  /// search is active, or a filter pill when scoring filters are present.
  Widget _buildMapFloatingButton() {
    final searchState = ref.watch(searchStateProvider);
    if (searchState.scoringFilterIds.isEmpty) {
      return _buildOpenOnlyChip();
    }
    return _buildMapFilterPill();
  }

  /// Accent pill button that opens the map filter bottom sheet.
  Widget _buildMapFilterPill() {
    // Label shows current match visibility
    final String label;
    switch (_matchVisibility) {
      case MapMatchVisibility.all:
        label = td(ref, 'map_filter_show_all');
      case MapMatchVisibility.fullOnly:
        label = td(ref, 'map_filter_show_full');
      case MapMatchVisibility.fullAndPartial:
        label = td(ref, 'map_filter_show_full_partial');
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openMapFilterBottomSheet,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.mlg, vertical: AppSpacing.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tune, size: 14, color: Colors.white),
                SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    label,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openMapFilterBottomSheet() {
    final searchState = ref.read(searchStateProvider);
    final documents = extractDocuments(searchState.searchResults);
    final counts =
        computeMatchCounts(documents, searchState.scoringFilterIds);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MapFilterBottomSheet(
        onlyOpen: _onlyOpen,
        matchVisibility: _matchVisibility,
        partialMatchCount: counts['partial'] ?? 0,
        onOnlyOpenChanged: (onlyOpen) async {
          setState(() => _onlyOpen = onlyOpen);
          final searchText =
              ref.read(searchStateProvider).currentSearchText;
          await _executeSearch(searchText);
        },
        onMatchVisibilityChanged: (visibility) {
          setState(() => _matchVisibility = visibility);
        },
      ),
    );
  }

  /// Get text for sort button - shows station name when station sort is active
  String _getSortButtonText() {
    if (_currentSort == 'station' && _selectedStation != null) {
      // Get station name from filter provider
      final filterState = ref.read(filterProvider);
      return filterState.when(
        data: (state) {
          final filterLookupMap = state.filterLookupMap;
          final stationData = filterLookupMap[_selectedStation];
          if (stationData != null) {
            final stationName = (stationData['name'] as String?) ??
                               (stationData['filter_name'] as String?) ??
                               td(ref, 'sort_station');
            return stationName;
          }
          return td(ref, 'sort_station');
        },
        loading: () => td(ref, 'sort_station'),
        error: (_, _) => td(ref, 'sort_station'),
      );
    }

    // When location is off and sort is 'nearest' (default), show generic "Sort" text
    // since "Nearest you" option is hidden from the menu when location is unavailable
    final locationState = ref.read(locationProvider);
    if (_currentSort == 'nearest' && !locationState.isLocationUsable) {
      return td(ref, 'sort_sheet_title'); // Generic "Sort" label
    }

    return td(ref, 'sort_$_currentSort');
  }

  /// Calculate filter counts using the shared utility.
  /// This is used for the main filter button row on the search page.
  Map<int, int> _calculateFilterCounts(
    List<int> activeFilters,
    AsyncValue<FilterState> filterState, {
    int extraLocationCount = 0,
  }) {
    return filterState.when(
      data: (state) => calculateFilterCounts(
        activeFilters,
        state.filterLookupMap,
        extraLocationCount: extraLocationCount,
      ),
      loading: () => {1: 0, 2: 0, 3: 0},
      error: (e, stack) => {1: 0, 2: 0, 3: 0},
    );
  }

  void _openFilterOverlayAtTab(int tabIndex) {
    setState(() => _activeFilterTab = tabIndex);
    _openFilterOverlay();
  }

  Widget _buildLocationBanner() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Capture banner width for threshold calculation
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted && _bannerWidth != constraints.maxWidth) {
            setState(() {
              _bannerWidth = constraints.maxWidth;
            });
          }
        });

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: _handleBannerDragStart,
          onHorizontalDragUpdate: _handleBannerDragUpdate,
          onHorizontalDragEnd: _handleBannerDragEnd,
          child: AnimatedContainer(
            duration: Duration(
              milliseconds: _isBannerDismissing
                ? 250
                : (_bannerDragOffset == 0.0 ? 300 : 0),
            ),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(_bannerDragOffset, 0.0, 0.0),
            child: Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.orangeBg,
                borderRadius: BorderRadius.circular(AppRadius.filter),
                border: Border.all(color: AppColors.orangeBorder),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_off,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      td(ref, 'location_permission_denied'),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  TextButton(
                    onPressed: _isBannerDismissing ? null : () async {
                      // Use enableLocation (smart enable: dialog if first time, Settings if denied)
                      // Same pattern as LocationStatusCard - fires analytics internally
                      await ref
                          .read(locationProvider.notifier)
                          .enableLocation();

                      // Check if permission was granted by reading updated state
                      if (mounted) {
                        final locationState = ref.read(locationProvider);
                        if (locationState.hasPermission) {
                          final searchText = ref.read(searchStateProvider).currentSearchText;
                          _executeSearch(searchText);
                        }
                      }
                    },
                    child: Text(
                      td(ref, 'location_permission_enable'),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleBannerDragStart(DragStartDetails details) {
    // Cancel any ongoing dismiss animation
    if (mounted) {
      setState(() {
        _isBannerDismissing = false;
      });
    }
  }

  void _handleBannerDragUpdate(DragUpdateDetails details) {
    // Early return if dismissing or width not captured yet
    if (_isBannerDismissing || _bannerWidth == 0.0) return;

    // Accumulate delta and clamp to prevent right-swipe (only negative values allowed)
    if (mounted) {
      setState(() {
        _bannerDragOffset = (_bannerDragOffset + details.delta.dx).clamp(-_bannerWidth, 0.0);
      });
    }
  }

  void _handleBannerDragEnd(DragEndDetails details) {
    // Early return if dismissing or width not captured yet
    if (_isBannerDismissing || _bannerWidth == 0.0) return;

    // Calculate threshold: 30% of banner width
    final dismissThreshold = _bannerWidth * 0.3;

    // Check velocity: fast swipe left
    final velocity = details.velocity.pixelsPerSecond.dx;
    final fastSwipeLeft = velocity < -500;

    // Dismiss if: swipe distance > 30% OR fast swipe left
    if (_bannerDragOffset.abs() > dismissThreshold || fastSwipeLeft) {
      _dismissBanner();
    } else {
      _resetBanner();
    }
  }

  void _dismissBanner() {
    // Set dismissing state and slide fully off-screen
    if (mounted) {
      setState(() {
        _isBannerDismissing = true;
        _bannerDragOffset = -_bannerWidth;
      });
    }

    // Wait for animation to complete, then persist dismissal
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        // Persist dismissal to SharedPreferences
        ref.read(locationProvider.notifier).dismissBanner();

        // Reset all state
        setState(() {
          _bannerDragOffset = 0.0;
          _isBannerDismissing = false;
          _bannerWidth = 0.0;
        });
      }
    });
  }

  void _resetBanner() {
    // Animate back to original position
    if (mounted) {
      setState(() {
        _bannerDragOffset = 0.0;
      });
    }
  }

  Widget _buildContent() {
    final searchState = ref.watch(searchStateProvider);

    // Loading state
    if (_isLoading && searchState.searchResults == null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: const RestaurantListShimmerWidget(),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              _errorMessage!,
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => _executeSearch(searchState.currentSearchText),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
              ),
              child: Text(td(ref, 'search_error_retry')),
            ),
          ],
        ),
      );
    }

    // Map view — Google Map with dot markers for each search result.
    // Shown even when results are empty so the map persists without markers;
    // the "no results" message only appears in the list tab.
    if (_viewMode == _ViewMode.map) {
      return SearchResultsMapView(
        matchVisibility: _matchVisibility,
        onBusinessTap: (businessId) {
          context.push('/business/$businessId');
        },
      );
    }

    // Empty state (list view only — map view handles this by showing no markers)
    final searchResults = searchState.searchResults;
    final bool isEmpty = searchResults == null ||
        extractDocuments(searchResults).isEmpty;

    if (isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              searchState.currentSearchText.isNotEmpty
                  ? td(ref, 'search_no_results_with_query')
                      .replaceAll('{query}', searchState.currentSearchText)
                  : td(ref, 'search_no_results'),
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Results list
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl), // 20px per JSX
      child: SearchResultsListView(
        onBusinessTap: (businessId) {
          // Navigate to business profile
          context.push('/business/$businessId');
        },
        onLoadMore: _loadMoreResults,
      ),
    );
  }
}
