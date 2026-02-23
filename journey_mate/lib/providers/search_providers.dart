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

  /// Update search results from API response
  /// Accepts either:
  /// - A List of documents directly
  /// - A Map containing a 'documents' key (full API response)
  void updateSearchResults(dynamic results, int count) {
    // Normalize input: extract documents array if full response object passed
    dynamic normalizedResults = results;
    if (results is Map && results.containsKey('documents')) {
      normalizedResults = results['documents'];
    }

    state = state.copyWith(
      searchResults: normalizedResults,
      searchResultsCount: count,
      hasActiveSearch: true,
      lastFetchTime: DateTime.now(), // Record fetch timestamp
    );
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

  /// Clear all active filters
  void clearFilters() {
    state = state.copyWith(filtersUsedForSearch: []);
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
      clearResults: true,
    );
  }
}
