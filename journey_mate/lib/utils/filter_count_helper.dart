/// Shared utility for calculating filter badge counts across the app.
///
/// Used by FilterTitlesRow, SearchPage, and any other component that needs
/// to display active filter counts for the three main filter categories:
/// - Location (titleId: 1)
/// - Type (titleId: 2)
/// - Preferences/Needs (titleId: 3)
library;

/// Calculate badge counts for the three filter category tabs (Location, Type, Needs).
///
/// Returns `Map<int, int>` where keys are titleIds (1, 2, 3) and values are selection counts.
///
/// [activeFilters] - List of currently selected filter IDs
/// [filterLookupMap] - Flat map of filterId → filter metadata (from FilterState)
/// [extraLocationCount] - Additional count to add to Location tab (for routed neighbourhood/shopping area)
Map<int, int> calculateFilterCounts(
  List<int> activeFilters,
  Map<int, dynamic> filterLookupMap, {
  int extraLocationCount = 0,
}) {
  final counts = <int, int>{1: 0, 2: 0, 3: 0};

  // Deduplicate parent+child combos to prevent double-counting
  final deduplicatedFilters = _deduplicateParentChildCombos(activeFilters);

  for (final filterId in deduplicatedFilters) {
    final titleId = _findTitleIdForFilter(filterId, filterLookupMap);
    if (titleId != null) {
      counts[titleId] = (counts[titleId] ?? 0) + 1;
    }
  }

  // Add routed neighbourhood/shopping area to Location tab (titleId: 1)
  // These IDs are not in filtersUsedForSearch (routed to separate API params)
  // but the user still needs visual feedback that Location selections are active
  counts[1] = (counts[1] ?? 0) + extraLocationCount;

  return counts;
}

/// Traces a filter's parent chain up to find its title ID (1, 2, or 3).
///
/// Walks up the parent_id chain until it reaches a top-level title.
/// Returns null if title ID cannot be found (orphaned filter or invalid chain).
///
/// Title IDs confirmed from GET /filters API response (params: language_code, city_id):
/// - id:1 = Location (Lage)
/// - id:2 = Type (Typ)
/// - id:3 = Preferences (Præferencer)
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

/// Deduplicates parent+child filter combos to prevent double-counting.
///
/// When both parent and child are selected, removes the parent from the list
/// (child remains, representing the combined selection).
///
/// NOTE: Parent-child relationships duplicated from selected_filters_btns.dart.
/// If adding new relationships, update both files.
///
/// Example: [56, 585] → [585] (Bakery + With seating → just 585)
///          [100, 196, 197] → [196, 197] (Sharing menu + 2 courses → just children)
List<int> _deduplicateParentChildCombos(List<int> activeFilters) {
  const parentChildRelationships = <int, List<int>>{
    56: [585, 586],
    58: [158, 159],
    55: [588],
    100: [196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207],
    101: [184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195],
  };

  final activeSet = activeFilters.toSet();
  final parentsToRemove = <int>{};

  // For each parent-child relationship
  for (final entry in parentChildRelationships.entries) {
    final parentId = entry.key;
    final childrenIds = entry.value;

    // If parent is selected AND any child is selected, remove parent
    if (activeSet.contains(parentId)) {
      final hasSelectedChild = childrenIds.any((childId) => activeSet.contains(childId));
      if (hasSelectedChild) {
        parentsToRemove.add(parentId);
      }
    }
  }

  // Return list without the redundant parents
  return activeFilters.where((id) => !parentsToRemove.contains(id)).toList();
}
