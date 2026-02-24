import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../providers/search_providers.dart';
import '../providers/filter_providers.dart';
import '../providers/settings_providers.dart';
import '../providers/provider_state_classes.dart';
import '../services/api_service.dart';
import '../services/analytics_service.dart';
import '../services/translation_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../theme/app_constants.dart';
import '../widgets/shared/search_results_list_view.dart';
import '../widgets/shared/selected_filters_btns.dart';
import '../widgets/shared/filter_overlay_widget.dart';
import '../widgets/shared/filter_titles_row.dart';
import '../widgets/shared/nav_bar_widget.dart';
import '../widgets/shared/restaurant_list_shimmer_widget.dart';
import '../widgets/shared/sort_bottom_sheet.dart';

/// Search Page - Main restaurant discovery page
/// Phase 7.3.2 implementation
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  // Local state
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;
  ScrollController? _scrollController;
  DateTime? _pageStartTime;
  bool _isLoading = false;
  String? _errorMessage;
  int _requestId = 0;
  bool _searchHasFocus = false;

  // Sort state
  String _currentSort = 'match';
  bool _onlyOpen = false;
  String _viewMode = 'liste'; // 'liste' or 'kort'

  // Filter overlay state
  int _activeFilterTab = 0;

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();
    _searchFocusNode.addListener(() {
      setState(() => _searchHasFocus = _searchFocusNode.hasFocus);
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  @override
  void dispose() {
    _trackPageView();
    _debounceTimer?.cancel();
    _scrollController?.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _trackPageView() {
    if (_pageStartTime == null) return;
    final duration = DateTime.now().difference(_pageStartTime!);

    final analytics = AnalyticsService.instance;
    ApiService.instance.postAnalytics(
      eventType: 'page_viewed',
      deviceId: analytics.deviceId ?? '',
      sessionId: analytics.currentSessionId ?? '',
      userId: analytics.userId ?? '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'pageName': 'searchPage',
        'durationSeconds': duration.inSeconds,
      },
    );
  }

  Future<void> _initialize() async {
    debugPrint('🔍 SearchPage: Initializing...');

    // Check location permission
    final hasPermission = await _checkLocationPermission();
    debugPrint('🔍 Location permission: $hasPermission');
    if (mounted) {
      ref.read(locationProvider.notifier).setPermission(hasPermission);
    }

    // Load initial results if no cached results
    final searchState = ref.read(searchStateProvider);
    debugPrint('🔍 Current searchResults: ${searchState.searchResults}');
    debugPrint('🔍 searchResults is null: ${searchState.searchResults == null}');

    if (searchState.searchResults == null) {
      debugPrint('🔍 Executing initial search...');
      await _executeSearch('');
    } else {
      debugPrint('🔍 Using cached search results');
    }
  }

  Future<bool> _checkLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      debugPrint('Location permission check error: $e');
      return false;
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

  Future<void> _executeSearch(String query) async {
    debugPrint('🔍 _executeSearch called with query: "$query"');
    final currentRequestId = ++_requestId;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final searchState = ref.read(searchStateProvider);
    final locationState = ref.read(locationProvider);

    // Get user location if permission granted
    Position? position;
    if (locationState.hasPermission) {
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 5),
          ),
        );
      } catch (e) {
        debugPrint('Location error: $e');
      }
    }

    // ignore: use_build_context_synchronously
    final languageCode = Localizations.localeOf(context).languageCode;

    try {
      final response = await ApiService.instance.search(
        filters: [], // Not used per BUILDSHIP_API_REFERENCE.md
        filtersUsedForSearch: searchState.filtersUsedForSearch,
        cityId: AppConstants.kDefaultCityId.toString(),
        searchInput: query,
        userLocation: position != null
            ? '${position.latitude},${position.longitude}'
            : null,
        languageCode: languageCode,
        sortBy: _currentSort,
        sortOrder: 'desc',
        onlyOpen: _onlyOpen,
        category: 'all', // Default category
      );

      // Ignore if newer request already started
      if (_requestId != currentRequestId) return;

      if (response.succeeded && mounted) {
        final documents = response.jsonBody['documents'] as List? ?? [];
        debugPrint('🔍 Search succeeded: ${documents.length} results');
        ref.read(searchStateProvider.notifier).updateSearchResults(
          documents,
          documents.length,
        );

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
            'resultsCount': documents.length,
            'filtersActive': searchState.filtersUsedForSearch.isNotEmpty,
          },
        );
      } else if (mounted) {
        debugPrint('🔍 Search failed: ${response.error}');
        setState(() {
          _errorMessage = response.error ?? 'Search failed';
        });
      }
    } catch (e) {
      debugPrint('🔍 Search exception: $e');
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

  Future<void> _openFilterOverlay() async {
    // Get current state
    final filterState = ref.read(filterProvider);
    final searchState = ref.read(searchStateProvider);

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.bottomSheet),
              ),
            ),
            child: Column(
              children: [
                // Swipe indicator
                _buildSheetHandle(),

                // 3-tab header
                FilterTitlesRow(
                  activeTabIndex: _activeFilterTab,
                  onTabChanged: (index) {
                    setState(() => _activeFilterTab = index);
                  },
                ),

                // Filter content
                Expanded(
                  child: filterState.when(
                    data: (state) => FilterOverlayWidget(
                      filterData: state.filtersForLanguage,
                      selectedTitleID: _mapTabIndexToTitleId(_activeFilterTab),
                      activeFilterIds: searchState.filtersUsedForSearch,
                      selectedFilterIds: searchState.filtersUsedForSearch,
                      onSearchCompleted: (activeIds, count) async {
                        // FilterOverlayWidget calls API internally
                        // Just update our local state tracking
                        if (mounted) {
                          setState(() {
                            // Trigger rebuild after filter change
                          });
                        }
                      },
                      onCloseOverlay: (selectedIds) async {
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      searchTerm: searchState.currentSearchText,
                      mayLoad: true,
                      resultCount: searchState.searchResultsCount,
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (e, _) => Center(
                      child: Text('Failed to load filters: $e'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSheetHandle() {
    return Container(
      margin: EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  int _mapTabIndexToTitleId(int tabIndex) {
    // FilterTitlesRow tab index → FilterOverlayWidget title ID
    // Title IDs confirmed from GET /filters API response:
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

  void _handleClearSearch() {
    _searchController.clear();
    _onSearchTextChanged('');
  }

  void _openSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SortBottomSheet(
        currentSort: _currentSort,
        onlyOpen: _onlyOpen,
        selectedStation: null,
        onSortChanged: (sortBy, onlyOpen, station) {
          setState(() {
            _currentSort = sortBy;
            _onlyOpen = onlyOpen;
          });
          // Save search text to local variable to avoid ref access after unmount
          final searchText = ref.read(searchStateProvider).currentSearchText;
          _executeSearch(searchText);
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
    final filterCounts = _calculateFilterCounts(
      searchState.filtersUsedForSearch,
      filterState,
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
          children: [
            // Fixed header section
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xs,
                AppSpacing.lg,
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

            // Selected filters chips
            if (searchState.filtersUsedForSearch.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(
                  top: AppSpacing.md,
                  bottom: AppSpacing.xs,
                ),
                child: SelectedFiltersBtns(
                  filters: searchState.filtersUsedForSearch,
                  languageCode: Localizations.localeOf(context).languageCode,
                  translationsCache: translationsCache,
                ),
              ),

            // Location permission banner
            if (!locationState.hasPermission)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xs,
                ),
                child: _buildLocationBanner(),
              ),

            // Content with floating button
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Search results list
                  _buildContent(),

                  // Floating sort button
                  Positioned(
                    bottom: 12.0,
                    right: AppSpacing.lg,
                    child: _buildSortButton(),
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
          size: 14,
          color: AppColors.accent,
        ),
        SizedBox(width: 5),
        Text(
          td(ref, '05aeogb1'), // FlutterFlow legacy key for Copenhagen
          style: AppTypography.bodyRegular.copyWith(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(
          color: _searchHasFocus ? AppColors.accent : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: _onSearchTextChanged,
        onSubmitted: _executeSearch,
        style: AppTypography.input,
        decoration: InputDecoration(
          hintText: td(ref, 'search_placeholder'),
          hintStyle: AppTypography.placeholder,
          filled: false,
          prefixIcon: Icon(
            Icons.search,
            size: 17,
            color: AppColors.textMuted,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 11,
          ),
          border: InputBorder.none,
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: _handleClearSearch,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildPageTitle(SearchState searchState) {
    final hasActiveFiltersOrSearch =
        searchState.filtersUsedForSearch.isNotEmpty ||
        searchState.currentSearchText.isNotEmpty;

    final title = hasActiveFiltersOrSearch
        ? '${td(ref, 'feedback_page_search_results')} (${searchState.searchResultsCount})'
        : td(ref, 'search_places_near_you'); // TODO: Add this key to Supabase

    return Text(
      title,
      style: AppTypography.pageTitle.copyWith(
        fontWeight: FontWeight.w700,
      ),
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
        final isActive = _activeFilterTab == (titleId - 1);

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
        padding: EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent : AppColors.bgCard,
          border: Border.all(
            color: isActive ? AppColors.accent : AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Text(
                count > 0 && !isActive ? '$label ($count)' : label,
                style: AppTypography.bodyRegular.copyWith(
                  fontSize: 13.5,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? AppColors.bgCard : AppColors.textSecondary,
                ),
              ),
            ),
            // Orange dot indicator (top-right)
            if (count > 0 && !isActive)
              Positioned(
                top: 5,
                right: 5,
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

  Widget _buildViewToggle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          // Liste button (left)
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _viewMode = 'liste'),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _viewMode == 'liste' ? Color(0xFFf5f5f5) : Colors.white,
                  border: Border.all(color: Color(0xFFe8e8e8), width: 1.5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Text(
                  'Liste',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyRegular.copyWith(
                    fontWeight: _viewMode == 'liste' ? FontWeight.w600 : FontWeight.w400,
                    color: _viewMode == 'liste' ? AppColors.textPrimary : Color(0xFF999999),
                  ),
                ),
              ),
            ),
          ),
          // Kort button (right) - overlaps border with negative margin
          Expanded(
            child: Transform.translate(
              offset: Offset(-1.5, 0), // Overlap left border
              child: GestureDetector(
                onTap: () => setState(() => _viewMode = 'kort'),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _viewMode == 'kort' ? Color(0xFFf5f5f5) : Colors.white,
                    border: Border.all(color: Color(0xFFe8e8e8), width: 1.5),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Kort',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyRegular.copyWith(
                      fontWeight: _viewMode == 'kort' ? FontWeight.w600 : FontWeight.w400,
                      color: _viewMode == 'kort' ? AppColors.textPrimary : Color(0xFF999999),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(20), // Pill shape
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
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sort,
                  size: 12,
                  color: Colors.white,
                ),
                SizedBox(width: 5),
                Text(
                  td(ref, 'sort_$_currentSort'),
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<int, int> _calculateFilterCounts(
    List<int> activeFilters,
    AsyncValue<FilterState> filterState,
  ) {
    return filterState.when(
      data: (state) {
        final counts = <int, int>{1: 0, 2: 0, 3: 0};
        final lookupMap = state.filterLookupMap;

        for (final filterId in activeFilters) {
          final titleId = _findTitleIdForFilter(filterId, lookupMap);
          if (titleId != null) {
            counts[titleId] = (counts[titleId] ?? 0) + 1;
          }
        }

        return counts;
      },
      loading: () => {1: 0, 2: 0, 3: 0},
      error: (e, stack) => {1: 0, 2: 0, 3: 0},
    );
  }

  /// Traces a filter's parent chain up to find its title ID (1, 2, or 3).
  int? _findTitleIdForFilter(int filterId, Map<int, dynamic> lookupMap) {
    var current = lookupMap[filterId];
    for (var i = 0; i < 10 && current != null; i++) {
      final id = current['id'];
      if (id == 1 || id == 2 || id == 3) return id as int;
      final parentId = current['parent_id'];
      if (parentId == null || !lookupMap.containsKey(parentId)) return null;
      current = lookupMap[parentId];
    }
    return null;
  }

  void _openFilterOverlayAtTab(int tabIndex) {
    setState(() => _activeFilterTab = tabIndex);
    _openFilterOverlay();
  }

  Widget _buildLocationBanner() {
    return Container(
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
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final granted = await ref
                  .read(locationProvider.notifier)
                  .requestPermission();
              if (granted && mounted) {
                final searchText = ref.read(searchStateProvider).currentSearchText;
                _executeSearch(searchText);
              }
            },
            child: Text(
              td(ref, 'location_permission_enable'),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final searchState = ref.watch(searchStateProvider);

    debugPrint('📊 [5] _buildContent called: loading=$_isLoading, hasResults=${searchState.searchResults != null}, error=$_errorMessage');

    // Loading state
    if (_isLoading && searchState.searchResults == null) {
      debugPrint('📊 [5a] Returning shimmer widget');
      return const RestaurantListShimmerWidget();
    }

    // Error state
    if (_errorMessage != null) {
      debugPrint('📊 [5b] Returning error widget');
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
              style: AppTypography.bodyRegular.copyWith(
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

    // Empty state
    final searchResults = searchState.searchResults;
    final bool isEmpty = searchResults == null ||
        (searchResults is List && searchResults.isEmpty) ||
        (searchResults is Map &&
         searchResults['documents'] is List &&
         (searchResults['documents'] as List).isEmpty);

    if (isEmpty) {
      debugPrint('📊 [5c] Returning empty state widget');
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
              style: AppTypography.bodyRegular.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Map view placeholder (JSX: "Kortvisning - Kommer snart")
    if (_viewMode == 'kort') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Kortvisning - Kommer snart',
              style: AppTypography.bodyRegular.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Results list
    debugPrint('📊 [5d] Returning SearchResultsListView');
    final locationState = ref.watch(locationProvider);
    Position? userLocation;
    if (locationState.hasPermission) {
      // Will be fetched by SearchResultsListView
    }

    return SearchResultsListView(
      userLocation: userLocation,
      onBusinessTap: (businessId) {
        // Navigate to business profile
        context.push('/business/$businessId');
      },
    );
  }
}
