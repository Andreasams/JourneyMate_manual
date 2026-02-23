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
  Timer? _debounceTimer;
  ScrollController? _scrollController;
  DateTime? _pageStartTime;
  bool _isLoading = false;
  String? _errorMessage;
  int _requestId = 0;

  // Sort state
  String _currentSort = 'match';
  bool _onlyOpen = false;

  // Filter overlay state
  int _activeFilterTab = 0;

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();
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

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        elevation: 0,
        title: _buildSearchBar(),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            color: AppColors.textPrimary,
            onPressed: _openFilterOverlay,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, bodyConstraints) {
          debugPrint('📐 [1] BODY LayoutBuilder: ${bodyConstraints.maxHeight}h × ${bodyConstraints.maxWidth}w');

          // WORKAROUND: Scaffold body receiving 0h - use MediaQuery for explicit height
          final screenHeight = MediaQuery.of(context).size.height;
          final appBarHeight = kToolbarHeight; // ~56px
          final navBarHeight = 80.0; // NavBarWidget height
          final availableHeight = screenHeight - appBarHeight - navBarHeight;

          debugPrint('📐 [1b] CALCULATED: screen=${screenHeight}h, available=${availableHeight}h');

          return SizedBox(
            height: availableHeight,
            width: double.infinity,
            child: Container(
              height: availableHeight,
              width: double.infinity,
              color: const Color(0x4DFFFF00), // DEBUG: Yellow
              child: LayoutBuilder(
                builder: (context, containerConstraints) {
                  debugPrint('📐 [2] CONTAINER LayoutBuilder: ${containerConstraints.maxHeight}h × ${containerConstraints.maxWidth}w');

                return Column(
                  children: [
                    // Selected filters chips
                    if (searchState.filtersUsedForSearch.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        child: SelectedFiltersBtns(
                          filters: searchState.filtersUsedForSearch,
                          languageCode: Localizations.localeOf(context).languageCode,
                          translationsCache: translationsCache,
                        ),
                      ),

                    // Location permission banner
                    if (!locationState.hasPermission) _buildLocationBanner(),

                    // Content with floating button
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, expandedConstraints) {
                          debugPrint('📐 [3] EXPANDED LayoutBuilder: ${expandedConstraints.maxHeight}h × ${expandedConstraints.maxWidth}w');

                          return Stack(
                            children: [
                              // Search results list
                              Container(
                                color: const Color(0x4D0000FF), // DEBUG: Blue
                                child: LayoutBuilder(
                                  builder: (context, contentConstraints) {
                                    debugPrint('📐 [4] CONTENT CONTAINER LayoutBuilder: ${contentConstraints.maxHeight}h × ${contentConstraints.maxWidth}w');
                                    return _buildContent();
                                  },
                                ),
                              ),

                              // Floating sort button
                              Positioned(
                                bottom: 12.0,
                                right: AppSpacing.lg,
                                child: FloatingActionButton.extended(
                                  onPressed: _openSortBottomSheet,
                                  backgroundColor: AppColors.bgCard,
                                  elevation: 4,
                                  label: Text(
                                    td(ref, 'sort_$_currentSort'),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  icon: Icon(Icons.sort, color: AppColors.accent, size: 20),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            ),
          );
        },
      ),
      bottomNavigationBar: const NavBarWidget(pageIsSearchResults: true),
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      height: 45,
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchTextChanged,
        onSubmitted: _executeSearch,
        style: AppTypography.input,
        decoration: InputDecoration(
          hintText: td(ref, 'search_placeholder'),
          hintStyle: AppTypography.placeholder,
          filled: true,
          fillColor: AppColors.bgInput,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: BorderSide.none,
          ),
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

  Widget _buildLocationBanner() {
    return Container(
      margin: EdgeInsets.all(AppSpacing.lg),
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
