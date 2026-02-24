import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import '../../theme/app_colors.dart';
import '../../theme/app_constants.dart';
import '../../theme/app_typography.dart';
import '../../services/translation_service.dart';
import '../../services/api_service.dart';
import '../../providers/search_providers.dart';

/// Bottom navigation bar with 2 tabs: Search and Account
///
/// Features:
/// - Search tab: Triggers API search call, updates searchStateProvider, navigates to /search
/// - Account tab: Clears filters, navigates to /settings
/// - Active tab styling with accent color
/// - Location integration for search (with fallback)
/// - User engagement tracking
class NavBarWidget extends ConsumerStatefulWidget {
  /// Whether the current page is the search results page
  /// - true = Search page (search tab is active)
  /// - false = Account page (account tab is active)
  final bool pageIsSearchResults;

  const NavBarWidget({
    super.key,
    required this.pageIsSearchResults,
  });

  @override
  ConsumerState<NavBarWidget> createState() => _NavBarWidgetState();
}

class _NavBarWidgetState extends ConsumerState<NavBarWidget> {
  /// Gets current user location with fallback
  Future<Position?> _getUserLocation() async {
    try {
      // Check permission first
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return null;
      }

      // Get current position with new LocationSettings API
      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      // Return null on any error (permission denied, timeout, etc.)
      return null;
    }
  }

  /// Formats Position as LatLng string for API
  String _formatLatLng(Position? position) {
    if (position == null) {
      return 'LatLng(lat: 0.0, lng: 0.0)'; // Fallback
    }
    return 'LatLng(lat: ${position.latitude}, lng: ${position.longitude})';
  }

  /// Handles search tab tap
  /// NEW: Checks cache freshness before making API call
  Future<void> _onSearchTabTap() async {
    // Only execute if NOT already on search page
    if (widget.pageIsSearchResults) return;

    // Check if cached results are fresh
    final searchNotifier = ref.read(searchStateProvider.notifier);
    if (searchNotifier.isCacheFresh()) {
      debugPrint('🚀 NavBar: Using fresh cached results, navigating immediately');

      // Navigate immediately without API call
      if (!context.mounted) return;
      context.go('/search');
      return;
    }

    debugPrint('🚀 NavBar: Cache stale or missing, fetching in background...');

    // Navigate immediately (don't block on API)
    if (!context.mounted) return;
    context.go('/search');

    // Fetch results in background (fire-and-forget)
    // SearchPage will show loading shimmer until results arrive
    _fetchSearchResultsBackground();
  }

  /// Background search fetch (non-blocking)
  Future<void> _fetchSearchResultsBackground() async {
    try {
      // Get language code BEFORE async operations
      final languageCode = Localizations.localeOf(context).languageCode;

      // Get user location (with fallback)
      final position = await _getUserLocation();
      final userLocationString = _formatLatLng(position);

      // Call search API with empty search input
      final response = await ApiService.instance.search(
        cityId: AppConstants.kDefaultCityId.toString(),
        userLocation: userLocationString,
        searchInput: '',
        languageCode: languageCode,
        filters: [],
        filtersUsedForSearch: [],
        sortBy: 'match',
        sortOrder: 'desc',
        selectedStation: null,
        onlyOpen: false,
        category: 'all',
        page: 1,
        pageSize: 20,
      );

      if (response.statusCode == 200) {
        final jsonBody = response.jsonBody;
        final resultCount = jsonBody['resultCount'] as int? ?? 0;

        // Update searchStateProvider (will auto-update SearchPage via watch())
        ref.read(searchStateProvider.notifier).updateSearchResults(
          jsonBody,
          resultCount,
        );

        // Generate new filter session ID
        ref.read(searchStateProvider.notifier).generateNewFilterSessionId();

        debugPrint('🚀 NavBar: Background fetch completed ($resultCount results)');
      }
    } catch (e) {
      debugPrint('🚀 NavBar: Background fetch failed: $e');
      // Fail silently - SearchPage will handle error state
    }
  }

  /// Handles account tab tap
  void _onAccountTabTap() {
    // Only execute if NOT already on account page
    if (!widget.pageIsSearchResults) return;

    // Clear filters
    ref.read(searchStateProvider.notifier).clearFilters();

    // Clear filter session ID
    ref.read(searchStateProvider.notifier).setFilterSessionId('');

    // Navigate to settings page
    context.go('/settings');
  }

  @override
  Widget build(BuildContext context) {
    // Active tab colors
    final searchTabActive = widget.pageIsSearchResults;
    final accountTabActive = !widget.pageIsSearchResults;

    // No Align or SafeArea wrapper — Scaffold's bottomNavigationBar already handles
    // positioning and safe areas. Unnecessary wrappers caused excessive height.
    return Container(
      width: double.infinity,
      height: 64.0, // Standard Material bottom nav height with balanced spacing
      decoration: BoxDecoration(
        color: AppColors.bgPage,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11.0), // Equal spacing top/bottom
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search tab
            _buildTabButton(
              icon: Icons.search,
              label: td(ref, 'm4kntw8r'), // "Search"
              isActive: searchTabActive,
              onTap: _onSearchTabTap,
            ),

            // Account tab
            _buildTabButton(
              icon: Icons.person,
              label: td(ref, 'ykne5sdr'), // "Account"
              isActive: accountTabActive,
              onTap: _onAccountTabTap,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single tab button
  Widget _buildTabButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final color = isActive ? AppColors.accent : AppColors.textPrimary;

    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: SizedBox(
        width: 100.0,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Icon(
              icon,
              color: color,
              size: 24.0,
            ),
            SizedBox(height: 2), // Reduced from 4 for tighter grouping

            // Label
            Text(
              label,
              style: AppTypography.bodyRegular.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
