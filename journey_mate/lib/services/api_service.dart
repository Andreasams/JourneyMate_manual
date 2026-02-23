import 'dart:convert';
import 'package:http/http.dart' as http;

/// API response wrapper
class ApiCallResponse {
  final int statusCode;
  final dynamic jsonBody;
  final String? error;

  bool get succeeded => statusCode >= 200 && statusCode < 300;

  const ApiCallResponse(this.statusCode, this.jsonBody, {this.error});

  ApiCallResponse.failure(String errorMessage)
      : statusCode = -1,
        jsonBody = null,
        error = errorMessage;
}

/// API Service - Singleton wrapper for all BuildShip endpoints
class ApiService {
  static final ApiService instance = ApiService._internal();
  ApiService._internal();

  final String _baseUrl = 'https://wvb8ww.buildship.run';
  final Map<String, ApiCallResponse> _cache = {};

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Makes a GET request with optional caching
  Future<ApiCallResponse> _makeGetRequest(
    String endpoint,
    Map<String, dynamic> params, {
    bool cache = true,
  }) async {
    try {
      // Build URI with query parameters
      final uri = Uri.parse('$_baseUrl$endpoint').replace(
        queryParameters: params.map(
          (key, value) => MapEntry(
            key,
            value == null ? '' : value.toString(),
          ),
        ),
      );

      // Check cache
      if (cache) {
        final cacheKey = uri.toString();
        if (_cache.containsKey(cacheKey)) {
          return _cache[cacheKey]!;
        }
      }

      // Make request
      final response = await http.get(uri, headers: {});

      // Parse response
      final jsonBody = response.statusCode >= 200 && response.statusCode < 300
          ? json.decode(response.body)
          : null;

      final apiResponse = ApiCallResponse(
        response.statusCode,
        jsonBody,
        error: response.statusCode >= 400 ? response.body : null,
      );

      // Store in cache if successful
      if (cache && apiResponse.succeeded) {
        _cache[uri.toString()] = apiResponse;
      }

      return apiResponse;
    } catch (e) {
      return ApiCallResponse.failure('GET request failed: $e');
    }
  }

  /// Makes a POST request (never cached)
  Future<ApiCallResponse> _makePostRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      final jsonBody = response.statusCode >= 200 && response.statusCode < 300
          ? json.decode(response.body)
          : null;

      return ApiCallResponse(
        response.statusCode,
        jsonBody,
        error: response.statusCode >= 400 ? response.body : null,
      );
    } catch (e) {
      return ApiCallResponse.failure('POST request failed: $e');
    }
  }

  /// Clears all cached responses
  void clearCache() {
    _cache.clear();
  }

  // ============================================================
  // ENDPOINT #1: SEARCH
  // ============================================================

  Future<ApiCallResponse> search({
    required List<int> filters,
    required List<int> filtersUsedForSearch,
    required String cityId,
    required String searchInput,
    String? userLocation,
    required String languageCode,
    String sortBy = 'match',
    String sortOrder = 'desc',
    int? selectedStation,
    bool onlyOpen = false,
    String category = 'all',
    int page = 1,
    int pageSize = 20,
  }) {
    return _makeGetRequest('/search', {
      'filters': filters.join(','),
      'filtersUsedForSearch': filtersUsedForSearch.join(','),
      'city_id': cityId,
      'search_input': searchInput,
      'userLocation': userLocation,
      'language_code': languageCode,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
      'selectedStation': selectedStation,
      'onlyOpen': onlyOpen,
      'category': category,
      'page': page,
      'pageSize': pageSize,
    });
  }

  // ============================================================
  // ENDPOINT #2: GET_BUSINESS_PROFILE
  // ============================================================

  Future<ApiCallResponse> getBusinessProfile({
    required int businessId,
    required String languageCode,
  }) {
    return _makeGetRequest('/businessprofile', {
      'businessId': businessId,
      'language_code': languageCode,
    });
  }

  // ============================================================
  // ENDPOINT #3: GET_RESTAURANT_MENU
  // ============================================================

  Future<ApiCallResponse> getRestaurantMenu({
    required int businessId,
    required String languageCode,
  }) {
    return _makeGetRequest('/menu', {
      'businessId': businessId,
      'languageCode': languageCode,
    });
  }

  // ============================================================
  // ENDPOINT #4: GET_FILTERS_FOR_SEARCH
  // ============================================================

  Future<ApiCallResponse> getFiltersForSearch({
    required String languageCode,
  }) {
    return _makeGetRequest('/filters', {
      'languageCode': languageCode,
    });
  }

  // ============================================================
  // ENDPOINT #5: GET_EXCHANGE_RATE
  // ============================================================

  Future<ApiCallResponse> getExchangeRate({
    required String toCurrency,
    String fromCurrency = 'DKK', // Base currency (always DKK for JourneyMate)
  }) {
    return _makeGetRequest('/getExchangeRates', { // Fixed: plural endpoint
      'from_currency': fromCurrency,
      'to_currency': toCurrency,
    });
  }

  // ============================================================
  // ENDPOINT #6: GET_FILTER_DESCRIPTIONS
  // ============================================================

  Future<ApiCallResponse> getFilterDescriptions({
    required int businessId,
    required String languageCode,
  }) {
    return _makeGetRequest('/filterdescriptions', {
      'businessId': businessId,
      'languageCode': languageCode,
    });
  }

  // ============================================================
  // ENDPOINT #7: GET_SINGLE_MENU_ITEM
  // ============================================================

  Future<ApiCallResponse> getSingleMenuItem({
    required int menuItemId,
    required String languageCode,
  }) {
    return _makeGetRequest('/menuitem', {
      'menuItemId': menuItemId,
      'languageCode': languageCode,
    });
  }

  // ============================================================
  // ENDPOINT #8: GET_UI_TRANSLATIONS
  // ============================================================

  Future<ApiCallResponse> getUiTranslations({
    required String languageCode,
  }) {
    return _makeGetRequest('/languageText', {
      'languageCode': languageCode,
    });
  }

  // ============================================================
  // ENDPOINT #9: POST_ANALYTICS
  // ============================================================

  Future<ApiCallResponse> postAnalytics({
    required String eventType,
    required String deviceId,
    required String sessionId,
    required String userId,
    required Map<String, dynamic> eventData,
    required String timestamp,
  }) {
    return _makePostRequest('/analytics', {
      'eventType': eventType,
      'deviceId': deviceId,
      'sessionId': sessionId,
      'userId': userId,
      'eventData': eventData,
      'timestamp': timestamp,
    });
  }

  // ============================================================
  // ENDPOINT #10: SUBMIT_MISSING_PLACE
  // ============================================================

  Future<ApiCallResponse> submitMissingPlace({
    required String businessName,
    required String businessAddress,
    required String message,
    required String languageCode,
  }) {
    return _makePostRequest('/missingplace', {
      'businessName': businessName,
      'businessAddress': businessAddress,
      'message': message,
      'languageCode': languageCode,
    });
  }

  // ============================================================
  // ENDPOINT #11: SUBMIT_CONTACT_US
  // ============================================================

  Future<ApiCallResponse> submitContactUs({
    required String name,
    required String contact,
    required String subject,
    required String message,
    required String languageCode,
  }) {
    return _makePostRequest('/contact', {
      'name': name,
      'contact': contact,
      'subject': subject,
      'message': message,
      'languageCode': languageCode,
    });
  }

  // ============================================================
  // ENDPOINT #12: SUBMIT_FEEDBACK
  // ============================================================

  Future<ApiCallResponse> submitFeedback({
    required String topic,
    required String message,
    required bool allowContact,
    String? name,
    String? contact,
    required String languageCode,
  }) {
    final body = {
      'topic': topic,
      'message': message,
      'allowContact': allowContact,
      'languageCode': languageCode,
    };

    // Only include optional fields if provided
    if (name != null && name.isNotEmpty) {
      body['name'] = name;
    }
    if (contact != null && contact.isNotEmpty) {
      body['contact'] = contact;
    }

    return _makePostRequest('/feedbackform', body);
  }

  // ============================================================
  // ENDPOINT #13: SUBMIT_ERRONEOUS_INFO
  // ============================================================

  Future<ApiCallResponse> postErroneousInfo({
    required int businessId,
    required String businessName,
    required String message,
    required String languageCode,
  }) {
    return _makePostRequest('/erroneousinfo', {
      'businessId': businessId,
      'businessName': businessName,
      'message': message,
      'languageCode': languageCode,
    });
  }
}
