import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'provider_state_classes.dart';

// ============================================================
// SEARCH STATE PROVIDER
// ============================================================

/// Search state provider (Riverpod 3.x)
final searchStateProvider =
    NotifierProvider<SearchStateNotifier, SearchState>(() {
  return SearchStateNotifier();
});

class SearchStateNotifier extends Notifier<SearchState> {
  @override
  SearchState build() {
    return SearchState.initial();
  }

  /// Update search results from API response. Also accepts scoringFilterIds so
  /// visibleResultCount (the display count used by the sort sheet Open Now badge)
  /// can be computed atomically alongside the results — avoiding a stale-state
  /// window if updateScoringFilterIds() were called separately afterward.
  ///
  /// Accepts either:
  /// - A List of documents directly
  /// - A Map containing a 'documents' key (full API response)
  void updateSearchResults(
    dynamic results,
    int count,
    int fullMatchCount,
    List<int> scoringFilterIds,
  ) {
    // Normalize input: extract documents array if full response object passed
    dynamic normalizedResults = results;
    if (results is Map && results.containsKey('documents')) {
      normalizedResults = results['documents'];
    }

    // Compute the display count using the same logic as the page title and
    // filter overlay: full-match count when scoring filters are active,
    // total count otherwise. This equals the number of items in the top
    // (full-match) section of the ListView when sections are shown.
    final hasActiveFiltersOrSearch = state.filtersUsedForSearch.isNotEmpty ||
        state.selectedNeighbourhoodId?.isNotEmpty == true ||
        state.selectedShoppingAreaId != null ||
        state.currentSearchText.isNotEmpty;
    final visibleResultCount = (hasActiveFiltersOrSearch && scoringFilterIds.isNotEmpty)
        ? fullMatchCount
        : count;

    state = state.copyWith(
      searchResults: normalizedResults,
      searchResultsCount: count,
      visibleResultCount: visibleResultCount,
      fullMatchCount: fullMatchCount,
      scoringFilterIds: List<int>.from(scoringFilterIds),
      hasActiveSearch: true,
      lastFetchTime: DateTime.now(),
    );
  }

  /// Update active filter IDs from API response
  void updateActiveFilterIds(List<int> activeIds) {
    state = state.copyWith(activeFilterIds: List<int>.from(activeIds));
  }

  /// Update scoring filter IDs from API response
  /// These are all filter IDs the node used for match scoring (dietary, cuisine, etc.)
  void updateScoringFilterIds(List<int> scoringIds) {
    state = state.copyWith(scoringFilterIds: List<int>.from(scoringIds));
  }

  /// Set current search text
  void setSearchText(String text) {
    state = state.copyWith(currentSearchText: text);
  }

  /// Toggle a filter (add if not present, remove if present)
  void toggleFilter(int filterId) {
    final currentFilters = List<int>.from(state.filtersUsedForSearch);

    if (currentFilters.contains(filterId)) {
      currentFilters.remove(filterId);
    } else {
      currentFilters.add(filterId);
    }

    state = state.copyWith(filtersUsedForSearch: currentFilters);
  }

  /// Add multiple filters at once
  void addFilters(List<int> filterIds) {
    final currentFilters = List<int>.from(state.filtersUsedForSearch);

    for (final id in filterIds) {
      if (!currentFilters.contains(id)) {
        currentFilters.add(id);
      }
    }

    state = state.copyWith(filtersUsedForSearch: currentFilters);
  }

  /// Remove multiple filters at once
  void removeFilters(List<int> filterIds) {
    final currentFilters = List<int>.from(state.filtersUsedForSearch);
    currentFilters.removeWhere((id) => filterIds.contains(id));

    state = state.copyWith(filtersUsedForSearch: currentFilters);
  }

  /// Clear all active filters (including routed neighbourhood/shopping area)
  void clearFilters() {
    state = state.copyWithNullable(
      filtersUsedForSearch: [],
      clearNeighbourhoodId: true,
      clearShoppingAreaId: true,
      clearResults: true,           // Triggers shimmer display
      clearScoringFilterIds: true,  // Removes match sections
      searchResultsCount: 0,        // Resets result count
      visibleResultCount: 0,        // Resets visible count
      fullMatchCount: 0,            // Resets full-match count
    );
  }

  /// Set the current filter session ID
  void setFilterSessionId(String sessionId) {
    state = state.copyWith(currentFilterSessionId: sessionId);
  }

  /// Generate a new filter session ID
  void generateNewFilterSessionId() {
    final newSessionId = const Uuid().v4();
    state = state.copyWith(currentFilterSessionId: newSessionId);
  }

  /// Snapshot current state to "previous" fields
  /// Call this before making a refinement to preserve the previous state
  void updatePreviousState() {
    state = state.copyWith(
      previousActiveFilters: List<int>.from(state.filtersUsedForSearch),
      previousSearchText: state.currentSearchText,
      previousFilterSessionId: state.currentFilterSessionId,
    );
  }

  /// Increment the refinement sequence counter
  void incrementRefinementSequence() {
    state = state.copyWith(
      currentRefinementSequence: state.currentRefinementSequence + 1,
      lastRefinementTime: DateTime.now(),
    );
  }

  /// Reset refinement sequence to 0
  void resetRefinementSequence() {
    state = state.copyWithNullable(
      currentRefinementSequence: 0,
      clearRefinementTime: true,
    );
  }

  /// Clear all search state (full reset)
  void clearSearch() {
    state = SearchState.initial();
  }

  /// Set filters directly (replace entire list)
  void setFilters(List<int> filterIds) {
    state = state.copyWith(filtersUsedForSearch: List<int>.from(filterIds));
  }

  /// Route filter IDs based on type, splitting them into the correct state fields:
  /// - is_neighborhood == true → selectedNeighbourhoodId (API param, not in filters array)
  /// - id >= 20000 → selectedShoppingAreaId (API param, not in filters array)
  /// - id >= 10000 && < 20000 → dropped (train stations handled via selectedStation param)
  /// - everything else → filtersUsedForSearch
  void setFiltersWithRouting(List<int> allIds, Map<int, dynamic> filterLookup) {
    final List<int> neighbourhoodIds = [];
    int? shoppingAreaId;
    final regularFilters = <int>[];

    for (final id in allIds) {
      if (id >= 20000) {
        shoppingAreaId = id;
      } else if (id >= 10000) {
        // Train station — skip (handled via selectedStation param)
        continue;
      } else {
        final meta = filterLookup[id];
        if (meta != null && meta['is_neighborhood'] == true) {
          neighbourhoodIds.add(id);
        } else {
          regularFilters.add(id);
        }
      }
    }

    state = state.copyWithNullable(
      filtersUsedForSearch: regularFilters,
      selectedNeighbourhoodId: neighbourhoodIds.isEmpty ? null : neighbourhoodIds,
      selectedShoppingAreaId: shoppingAreaId,
      clearNeighbourhoodId: neighbourhoodIds.isEmpty,
      clearShoppingAreaId: shoppingAreaId == null,
    );
  }

  /// Clear the routed neighbourhood ID only
  void clearRoutedNeighbourhoodId() {
    state = state.copyWithNullable(clearNeighbourhoodId: true);
  }

  /// Clear the routed shopping area ID only
  void clearRoutedShoppingAreaId() {
    state = state.copyWithNullable(clearShoppingAreaId: true);
  }

  /// Check if a specific filter is active
  bool isFilterActive(int filterId) {
    return state.filtersUsedForSearch.contains(filterId);
  }

  /// Get count of active filters
  int getActiveFilterCount() {
    return state.filtersUsedForSearch.length;
  }

  /// Check if cached search results are fresh (< 5 minutes old)
  bool isCacheFresh() {
    if (state.searchResults == null || state.lastFetchTime == null) {
      return false;
    }

    final age = DateTime.now().difference(state.lastFetchTime!);
    return age.inMinutes < 5;
  }

  /// Invalidate cached search results (sets timestamp to null)
  void invalidateCache() {
    state = state.copyWithNullable(clearFetchTime: true);
    debugPrint('🔍 Search cache invalidated');
  }

  /// Mark search as inactive (results cleared)
  void markSearchInactive() {
    state = state.copyWithNullable(
      hasActiveSearch: false,
      searchResultsCount: 0,
      visibleResultCount: 0,
      clearResults: true,
    );
  }
}
