/// Lightweight in-memory LRU cache for business preview data.
/// Used to show instant preview when navigating from search results.
///
/// Eviction: When the cache exceeds [_maxEntries], the oldest entry
/// (by insertion order) is removed. Accessing an entry via
/// [getBusinessPreview] promotes it to most-recent.
class BusinessCache {
  static final BusinessCache instance = BusinessCache._internal();
  BusinessCache._internal();

  static const int _maxEntries = 50;

  /// LinkedHashMap preserves insertion order for LRU eviction.
  final Map<int, Map<String, dynamic>> _cache = {};

  /// Cache preview data from search results for instant display
  void cacheBusinessPreview(Map<String, dynamic> searchResult) {
    final id = searchResult['business_id'] as int?;
    if (id == null) return;

    // Remove first so re-insert moves to end (most-recent)
    _cache.remove(id);

    _cache[id] = {
      'business_id': id,
      'business_name': searchResult['business_name'],
      'business_type': searchResult['business_type'],
      'profile_picture_url': searchResult['profile_picture_url'],
      'business_hours': searchResult['business_hours'],
      'price_range_min': searchResult['price_range_min'],
      'price_range_max': searchResult['price_range_max'],
      'price_range_currency_code': searchResult['price_range_currency_code'] ?? 'DKK',
      'street': searchResult['street'],
      'neighbourhood_name': searchResult['neighbourhood_name'],
      'postal_code': searchResult['postal_code'],
      'postal_city': searchResult['postal_city'],
      'latitude': searchResult['latitude'],
      'longitude': searchResult['longitude'],
      'tags': searchResult['tags'],
      'cached_at': DateTime.now().toIso8601String(),
    };

    // Evict oldest entry if over limit
    if (_cache.length > _maxEntries) {
      _cache.remove(_cache.keys.first);
    }
  }

  /// Get cached preview data for a business.
  /// Promotes the entry to most-recent (LRU touch).
  Map<String, dynamic>? getBusinessPreview(int id) {
    final entry = _cache.remove(id);
    if (entry != null) {
      _cache[id] = entry; // Re-insert at end
    }
    return entry;
  }

  /// Clear all cached preview data
  void clear() => _cache.clear();

  /// Remove a specific business from cache
  void remove(int id) => _cache.remove(id);
}
