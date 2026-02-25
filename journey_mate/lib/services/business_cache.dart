/// Lightweight in-memory cache for business preview data
/// Used to show instant preview when navigating from search results
class BusinessCache {
  static final BusinessCache instance = BusinessCache._internal();
  BusinessCache._internal();

  final Map<int, Map<String, dynamic>> _cache = {};

  /// Cache preview data from search results for instant display
  void cacheBusinessPreview(Map<String, dynamic> searchResult) {
    final id = searchResult['business_id'] as int?;
    if (id == null) return;

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
  }

  /// Get cached preview data for a business
  Map<String, dynamic>? getBusinessPreview(int id) {
    return _cache[id];
  }

  /// Clear all cached preview data
  void clear() => _cache.clear();

  /// Remove a specific business from cache
  void remove(int id) => _cache.remove(id);
}
