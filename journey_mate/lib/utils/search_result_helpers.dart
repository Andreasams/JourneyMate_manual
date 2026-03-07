// Shared utilities for search result data extraction and match classification.
//
// Extracted from SearchResultsListView and SearchResultsMapView to eliminate
// duplication of document extraction and business ID parsing logic.

/// Constants for match variant identifiers used across search result views
/// and map markers.
class MatchVariant {
  MatchVariant._();

  static const String full = 'full';
  static const String partial = 'partial';
  static const String none = 'none';
}

/// Extracts the list of business documents from search results.
///
/// After `updateSearchResults()` normalization, [searchResults] is already
/// a List. Falls back to Map format with a `'documents'` key for backwards
/// compatibility.
List<dynamic> extractDocuments(dynamic searchResults) {
  if (searchResults is List) return searchResults;
  if (searchResults is Map && searchResults.containsKey('documents')) {
    final docs = searchResults['documents'];
    if (docs is List) return docs;
  }
  return [];
}

/// Extracts the business ID from a business data map.
///
/// The API returns `'business_id'` (not `'id'`). Returns 0 if the value
/// cannot be parsed.
int getBusinessId(dynamic businessData) {
  if (businessData is Map) {
    final value = businessData['business_id'];
    if (value is int) return value;
    if (value is num) return value.toInt();
  }
  return 0;
}

/// Determines the match variant for a business based on how many scoring
/// filters it matches.
///
/// Returns `null` when no filters are active (no match categorization needed).
String? getMatchVariant(dynamic businessData, List<int> scoringFilterIds) {
  if (scoringFilterIds.isEmpty) return null;
  if (businessData is! Map) return null;

  final matchCount = businessData['matchCount'];
  if (matchCount is! num) return null;

  if (matchCount >= scoringFilterIds.length) return MatchVariant.full;
  if (matchCount > 0) return MatchVariant.partial;
  return MatchVariant.none;
}

/// Type-safe field extraction from a business data map.
///
/// Handles num→int and num→double coercion. Returns `null` for missing
/// fields, type mismatches, or non-Map input.
T? getField<T>(dynamic businessData, String fieldName) {
  try {
    if (businessData is! Map) return null;
    final value = businessData[fieldName];
    if (value is T) return value;
    if (T == int && value is num) return value.toInt() as T;
    if (T == double && value is num) return value.toDouble() as T;
    return null;
  } catch (_) {
    return null;
  }
}
