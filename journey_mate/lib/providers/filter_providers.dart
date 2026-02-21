import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'provider_state_classes.dart';
import '../services/api_service.dart';

// ============================================================
// FILTER PROVIDER (AsyncNotifier pattern for API loading)
// ============================================================

/// Filter provider (Riverpod 3.x AsyncNotifier)
final filterProvider =
    AsyncNotifierProvider<FilterNotifier, FilterState>(() {
  return FilterNotifier();
});

class FilterNotifier extends AsyncNotifier<FilterState> {
  @override
  Future<FilterState> build() async {
    // Return initial state synchronously
    return FilterState.initial();
  }

  /// Load filters for a specific language from API
  Future<void> loadFiltersForLanguage(String languageCode) async {
    // Set loading state
    state = const AsyncLoading();

    try {
      // Call API
      final response = await ApiService.instance.getFiltersForSearch(
        languageCode: languageCode,
      );

      if (response.succeeded && response.jsonBody != null) {
        final body = response.jsonBody as Map<String, dynamic>;

        // Extract filters hierarchy and foodDrinkTypes
        final filters = body['filters'];
        final foodDrinkTypes = body['foodDrinkTypes'] ?? [];

        // Build lookup map from hierarchy
        final lookupMap = _buildLookupMap(filters);

        // Update state with loaded data
        state = AsyncData(FilterState(
          filtersForLanguage: filters,
          filterLookupMap: lookupMap,
          foodDrinkTypes: foodDrinkTypes is List ? foodDrinkTypes : [],
        ));

        debugPrint('✅ Filters loaded for $languageCode: ${lookupMap.length} items');
      } else {
        debugPrint('⚠️ Failed to load filters: API returned error');
        state = AsyncData(FilterState.initial());
      }
    } catch (e, stackTrace) {
      debugPrint('⚠️ Error loading filters: $e');
      state = AsyncError(e, stackTrace);
    }
  }

  /// Build flat lookup map from hierarchical filter structure
  Map<int, dynamic> _buildLookupMap(dynamic filters) {
    final Map<int, dynamic> lookupMap = {};

    if (filters == null) return lookupMap;

    void traverse(dynamic node) {
      if (node is Map) {
        // Extract filter ID if present
        final filterId = node['filter_id'];
        if (filterId is int) {
          lookupMap[filterId] = node;
        }

        // Traverse children
        final children = node['children'];
        if (children is List) {
          for (final child in children) {
            traverse(child);
          }
        }
      } else if (node is List) {
        for (final item in node) {
          traverse(item);
        }
      }
    }

    traverse(filters);
    return lookupMap;
  }

  /// Get filter by ID from lookup map
  dynamic getFilterById(int filterId) {
    return state.when(
      data: (data) => data.filterLookupMap[filterId],
      loading: () => null,
      error: (e, _) => null,
    );
  }

  /// Check if filters are loaded
  bool isLoaded() {
    return state.when(
      data: (data) => data.filtersForLanguage != null,
      loading: () => false,
      error: (e, _) => false,
    );
  }

  /// Clear all filter data
  void clear() {
    state = AsyncData(FilterState.initial());
  }
}
