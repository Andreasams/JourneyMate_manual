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
  void updateSearchResults(dynamic results, int count) {
    state = state.copyWith(
      searchResults: results,
      searchResultsCount: count,
      hasActiveSearch: true,
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
    state = state.copyWith(
      currentRefinementSequence: 0,
      lastRefinementTime: null,
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

  /// Mark search as inactive (results cleared)
  void markSearchInactive() {
    state = state.copyWith(
      hasActiveSearch: false,
      searchResults: null,
      searchResultsCount: 0,
    );
  }
}
