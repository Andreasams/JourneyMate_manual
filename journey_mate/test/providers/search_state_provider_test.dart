import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journey_mate/providers/search_providers.dart';

void main() {
  group('SearchStateProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is correct', () {
      final state = container.read(searchStateProvider);

      expect(state.searchResults, null);
      expect(state.searchResultsCount, 0);
      expect(state.hasActiveSearch, false);
      expect(state.currentSearchText, '');
      expect(state.filtersUsedForSearch, isEmpty);
      expect(state.currentFilterSessionId, '');
      expect(state.previousActiveFilters, isEmpty);
      expect(state.previousSearchText, '');
      expect(state.previousFilterSessionId, '');
      expect(state.currentRefinementSequence, 0);
      expect(state.lastRefinementTime, null);
    });

    test('updateSearchResults() sets results and marks search active', () {
      final mockResults = {'items': []};
      container.read(searchStateProvider.notifier).updateSearchResults(mockResults, 5, 3, []);

      final state = container.read(searchStateProvider);
      expect(state.searchResults, mockResults);
      expect(state.searchResultsCount, 5);
      expect(state.hasActiveSearch, true);
    });

    test('setSearchText() updates search text', () {
      container.read(searchStateProvider.notifier).setSearchText('pizza');

      final state = container.read(searchStateProvider);
      expect(state.currentSearchText, 'pizza');
    });

    test('toggleFilter() adds filter if not present', () {
      container.read(searchStateProvider.notifier).toggleFilter(10);

      final state = container.read(searchStateProvider);
      expect(state.filtersUsedForSearch, [10]);
    });

    test('toggleFilter() removes filter if present', () {
      container.read(searchStateProvider.notifier).toggleFilter(10);
      container.read(searchStateProvider.notifier).toggleFilter(10);

      final state = container.read(searchStateProvider);
      expect(state.filtersUsedForSearch, isEmpty);
    });

    test('toggleFilter() handles multiple filters', () {
      container.read(searchStateProvider.notifier).toggleFilter(10);
      container.read(searchStateProvider.notifier).toggleFilter(20);
      container.read(searchStateProvider.notifier).toggleFilter(30);

      var state = container.read(searchStateProvider);
      expect(state.filtersUsedForSearch, [10, 20, 30]);

      container.read(searchStateProvider.notifier).toggleFilter(20);
      state = container.read(searchStateProvider);
      expect(state.filtersUsedForSearch, [10, 30]);
    });

    test('addFilters() adds multiple filters', () {
      container.read(searchStateProvider.notifier).addFilters([10, 20, 30]);

      final state = container.read(searchStateProvider);
      expect(state.filtersUsedForSearch, [10, 20, 30]);
    });

    test('addFilters() does not add duplicates', () {
      container.read(searchStateProvider.notifier).addFilters([10, 20]);
      container.read(searchStateProvider.notifier).addFilters([20, 30]);

      final state = container.read(searchStateProvider);
      expect(state.filtersUsedForSearch, [10, 20, 30]);
    });

    test('removeFilters() removes multiple filters', () {
      container.read(searchStateProvider.notifier).addFilters([10, 20, 30, 40]);
      container.read(searchStateProvider.notifier).removeFilters([20, 40]);

      final state = container.read(searchStateProvider);
      expect(state.filtersUsedForSearch, [10, 30]);
    });

    test('clearFilters() removes all filters', () {
      container.read(searchStateProvider.notifier).addFilters([10, 20, 30]);
      container.read(searchStateProvider.notifier).clearFilters();

      final state = container.read(searchStateProvider);
      expect(state.filtersUsedForSearch, isEmpty);
    });

    test('setFilterSessionId() updates session ID', () {
      container.read(searchStateProvider.notifier).setFilterSessionId('session-123');

      final state = container.read(searchStateProvider);
      expect(state.currentFilterSessionId, 'session-123');
    });

    test('generateNewFilterSessionId() creates UUID', () {
      container.read(searchStateProvider.notifier).generateNewFilterSessionId();

      final state = container.read(searchStateProvider);
      expect(state.currentFilterSessionId.isNotEmpty, true);
      expect(state.currentFilterSessionId.length, 36); // UUID length
    });

    test('updatePreviousState() snapshots current to previous', () {
      container.read(searchStateProvider.notifier).setSearchText('burger');
      container.read(searchStateProvider.notifier).addFilters([10, 20]);
      container.read(searchStateProvider.notifier).setFilterSessionId('session-abc');

      container.read(searchStateProvider.notifier).updatePreviousState();

      final state = container.read(searchStateProvider);
      expect(state.previousSearchText, 'burger');
      expect(state.previousActiveFilters, [10, 20]);
      expect(state.previousFilterSessionId, 'session-abc');
    });

    test('incrementRefinementSequence() increases counter and sets timestamp', () {
      container.read(searchStateProvider.notifier).incrementRefinementSequence();

      var state = container.read(searchStateProvider);
      expect(state.currentRefinementSequence, 1);
      expect(state.lastRefinementTime, isNotNull);

      container.read(searchStateProvider.notifier).incrementRefinementSequence();
      state = container.read(searchStateProvider);
      expect(state.currentRefinementSequence, 2);
    });

    test('resetRefinementSequence() resets counter and timestamp', () {
      container.read(searchStateProvider.notifier).incrementRefinementSequence();
      container.read(searchStateProvider.notifier).incrementRefinementSequence();

      container.read(searchStateProvider.notifier).resetRefinementSequence();

      final state = container.read(searchStateProvider);
      expect(state.currentRefinementSequence, 0);
      expect(state.lastRefinementTime, null);
    });

    test('clearSearch() resets all state', () {
      container.read(searchStateProvider.notifier).updateSearchResults({'items': []}, 5, 3, []);
      container.read(searchStateProvider.notifier).setSearchText('pizza');
      container.read(searchStateProvider.notifier).addFilters([10, 20]);
      container.read(searchStateProvider.notifier).incrementRefinementSequence();

      container.read(searchStateProvider.notifier).clearSearch();

      final state = container.read(searchStateProvider);
      expect(state.searchResults, null);
      expect(state.searchResultsCount, 0);
      expect(state.hasActiveSearch, false);
      expect(state.currentSearchText, '');
      expect(state.filtersUsedForSearch, isEmpty);
      expect(state.currentRefinementSequence, 0);
    });

    test('setFilters() replaces entire filter list', () {
      container.read(searchStateProvider.notifier).addFilters([10, 20]);
      container.read(searchStateProvider.notifier).setFilters([30, 40, 50]);

      final state = container.read(searchStateProvider);
      expect(state.filtersUsedForSearch, [30, 40, 50]);
    });

    test('isFilterActive() returns correct boolean', () {
      container.read(searchStateProvider.notifier).addFilters([10, 20]);

      final notifier = container.read(searchStateProvider.notifier);
      expect(notifier.isFilterActive(10), true);
      expect(notifier.isFilterActive(20), true);
      expect(notifier.isFilterActive(30), false);
    });

    test('getActiveFilterCount() returns correct count', () {
      container.read(searchStateProvider.notifier).addFilters([10, 20, 30]);

      final notifier = container.read(searchStateProvider.notifier);
      expect(notifier.getActiveFilterCount(), 3);
    });

    test('markSearchInactive() clears results and count', () {
      container.read(searchStateProvider.notifier).updateSearchResults({'items': []}, 5, 3, []);

      var state = container.read(searchStateProvider);
      expect(state.hasActiveSearch, true);

      container.read(searchStateProvider.notifier).markSearchInactive();

      state = container.read(searchStateProvider);
      expect(state.hasActiveSearch, false);
      expect(state.searchResults, null);
      expect(state.searchResultsCount, 0);
    });

    test('full search flow with refinements', () {
      // Initial search
      container.read(searchStateProvider.notifier).setSearchText('pizza');
      container.read(searchStateProvider.notifier).generateNewFilterSessionId();
      container.read(searchStateProvider.notifier).updateSearchResults({'items': []}, 10, 5, []);

      // First refinement
      container.read(searchStateProvider.notifier).updatePreviousState();
      container.read(searchStateProvider.notifier).incrementRefinementSequence();
      container.read(searchStateProvider.notifier).addFilters([10]);
      container.read(searchStateProvider.notifier).updateSearchResults({'items': []}, 5, 3, []);

      // Second refinement
      container.read(searchStateProvider.notifier).updatePreviousState();
      container.read(searchStateProvider.notifier).incrementRefinementSequence();
      container.read(searchStateProvider.notifier).addFilters([20]);
      container.read(searchStateProvider.notifier).updateSearchResults({'items': []}, 2, 1, []);

      final state = container.read(searchStateProvider);
      expect(state.currentSearchText, 'pizza');
      expect(state.filtersUsedForSearch, [10, 20]);
      expect(state.searchResultsCount, 2);
      expect(state.currentRefinementSequence, 2);
      expect(state.previousActiveFilters, [10]);
    });
  });

  group('visibleResultCount calculation', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('shows all results when only open filter is inactive', () {
      container.read(searchStateProvider.notifier).updateSearchResults(
        [{'id': 1}, {'id': 2}, {'id': 3}],
        3, // resultCount
        0, // fullMatchCount
        [],
        isOnlyOpenFilterActive: false,
        onlyOpenCount: 0,
      );

      final state = container.read(searchStateProvider);
      expect(state.visibleResultCount, 3); // Shows all results
    });

    test('shows onlyOpenCount when filter is active, even if zero', () {
      container.read(searchStateProvider.notifier).updateSearchResults(
        [{'id': 1}, {'id': 2}, {'id': 3}],
        3, // resultCount
        0, // fullMatchCount
        [],
        isOnlyOpenFilterActive: true,
        onlyOpenCount: 0, // No open restaurants
      );

      final state = container.read(searchStateProvider);
      expect(
        state.visibleResultCount,
        0, // BUG FIX: Should show 0, not 3
      );
    });

    test('shows onlyOpenCount when filter is active with positive count', () {
      container.read(searchStateProvider.notifier).updateSearchResults(
        [{'id': 1}, {'id': 2}],
        3, // Total results
        0, // fullMatchCount
        [],
        isOnlyOpenFilterActive: true,
        onlyOpenCount: 2, // 2 are open
      );

      final state = container.read(searchStateProvider);
      expect(state.visibleResultCount, 2);
    });

    test('tracks isOnlyOpenFilterActive state correctly', () {
      container.read(searchStateProvider.notifier).updateSearchResults(
        [{'id': 1}],
        1,
        0,
        [],
        isOnlyOpenFilterActive: true,
        onlyOpenCount: 0,
      );

      var state = container.read(searchStateProvider);
      expect(state.isOnlyOpenFilterActive, true);

      container.read(searchStateProvider.notifier).updateSearchResults(
        [{'id': 1}],
        1,
        0,
        [],
        isOnlyOpenFilterActive: false,
        onlyOpenCount: 0,
      );

      state = container.read(searchStateProvider);
      expect(state.isOnlyOpenFilterActive, false);
    });
  });
}
