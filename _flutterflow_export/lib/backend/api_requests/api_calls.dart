import 'dart:convert';
import 'dart:typed_data';
import '../schema/structs/index.dart';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class SearchCall {
  static Future<ApiCallResponse> call({
    String? cityId = '',
    String? searchInput = '',
    List<int>? filtersList,
    String? userLocation = '',
    bool? hasTrainStationFilter,
    int? trainStationFilterId,
    String? languageCode = '',
  }) async {
    final filters = _serializeList(filtersList);

    return ApiManager.instance.makeApiCall(
      callName: 'Search',
      apiUrl: 'https://wvb8ww.buildship.run/search',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'city_id': cityId,
        'search_input': searchInput,
        'userLocation': userLocation,
        'filters': filters,
        'hasTrainStationFilter': hasTrainStationFilter,
        'trainStationFilterId': trainStationFilterId,
        'language_code': languageCode,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: true,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List? businessHours(dynamic response) => getJsonField(
        response,
        r'''$.documents[:].business_hours''',
        true,
      ) as List?;
  static int? businessID(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.documents[:].business_id''',
      ));
  static String? businessName(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.documents[:].business_name''',
      ));
  static String? businessType(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.documents[:].business_type''',
      ));
  static int? cityID(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.documents[:].city_id''',
      ));
  static String? description(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.documents[:].description''',
      ));
  static List<int>? filters(dynamic response) => (getJsonField(
        response,
        r'''$.documents[:].filters''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  static bool? isActive(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.documents[:].is_active''',
      ));
  static double? latitude(dynamic response) => castToType<double>(getJsonField(
        response,
        r'''$.documents[:].latitude''',
      ));
  static double? longitude(dynamic response) => castToType<double>(getJsonField(
        response,
        r'''$.documents[:].longitude''',
      ));
  static String? neighbourhoodName(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.documents[:].neighbourhood_name''',
      ));
  static String? postalCode(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.documents[:].postal_code''',
      ));
  static String? profilePictureURL(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.documents[:].profile_picture_url''',
      ));
  static String? street(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.documents[:].street''',
      ));
  static List<int>? activeIDs(dynamic response) => (getJsonField(
        response,
        r'''$.activeids''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  static List? allData(dynamic response) => getJsonField(
        response,
        r'''$.documents''',
        true,
      ) as List?;
  static List<double>? location(dynamic response) => (getJsonField(
        response,
        r'''$.documents[:].location''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<double>(x))
          .withoutNulls
          .toList();
  static int? countOfSearchResults(dynamic response) =>
      castToType<int>(getJsonField(
        response,
        r'''$.resultCount''',
      ));
  static int? priceRangeMax(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.documents[:].price_range_max''',
      ));
  static int? priceRangeMin(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.documents[:].price_range_min''',
      ));
}

class UserFeedbackCall {
  static Future<ApiCallResponse> call({
    int? formid,
    String? businessName,
    String? businessAddress,
    String? message,
    String? topic,
    String? userName,
    String? contactDetails,
  }) async {
    formid ??= null!;
    businessName ??= null!;
    businessAddress ??= null!;
    message ??= null!;
    topic ??= null!;
    userName ??= null!;
    contactDetails ??= null!;

    final ffApiRequestBody = '''
{
  "formid": ${formid},
  "business_name": "${businessName}",
  "business_address": "${businessAddress}",
  "message": "${message}",
  "topic": "${topic}",
  "user_name": "${userName}",
  "contact_details": "${contactDetails}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'UserFeedback',
      apiUrl: 'https://wvb8ww.buildship.run/userfeedback',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class BusinessProfileCall {
  static Future<ApiCallResponse> call({
    int? businessId,
    String? languageCode = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'BusinessProfile',
      apiUrl: 'https://wvb8ww.buildship.run/getBusinessProfile',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'businessId': businessId,
        'language_code': languageCode,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: true,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static int? businessId(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.businessInfo.business_id''',
      ));
  static String? businessName(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.businessInfo.business_name''',
      ));
  static String? businessType(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.businessInfo.business_type''',
      ));
  static int? cityId(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.businessInfo.city_id''',
      ));
  static String? cityName(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.businessInfo.city_name''',
      ));
  static String? postalCode(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.businessInfo.postal_code''',
      ));
  static String? postalCity(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.businessInfo.postal_city''',
      ));
  static String? street(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.businessInfo.street''',
      ));
  static double? longitude(dynamic response) => castToType<double>(getJsonField(
        response,
        r'''$.businessInfo.longitude''',
      ));
  static double? latitude(dynamic response) => castToType<double>(getJsonField(
        response,
        r'''$.businessInfo.latitude''',
      ));
  static List<String>? menu(dynamic response) => (getJsonField(
        response,
        r'''$.gallery.menu''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? outdoor(dynamic response) => (getJsonField(
        response,
        r'''$.gallery.outdoor''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? food(dynamic response) => (getJsonField(
        response,
        r'''$.gallery.food''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? interior(dynamic response) => (getJsonField(
        response,
        r'''$.gallery.interior''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static String? emailReservation(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.businessInfo.reservation_email''',
      ));
  static String? emailGeneral(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.businessInfo.general_email''',
      ));
  static String? uRLReservation(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.businessInfo.reservation_url''',
      ));
  static String? uRLInstagram(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.businessInfo.instagram_url''',
      ));
  static String? phoneGeneral(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.businessInfo.general_phone''',
      ));
  static String? profilePictureURL(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.businessInfo.profile_picture_url''',
      ));
  static String? uRLGoogleMaps(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.businessInfo.google_maps_url''',
      ));
  static String? uRLWebsite(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.businessInfo.website_url''',
      ));
  static String? uRLFacebook(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.businessInfo.facebook_url''',
      ));
  static String? neighbourhoodName(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.businessInfo.neighbourhood_name''',
      ));
  static dynamic? completeMenu(dynamic response) => getJsonField(
        response,
        r'''$.menuCategories''',
      );
  static List<int>? menuID(dynamic response) => (getJsonField(
        response,
        r'''$.menuCategories[:].menu_id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  static List<int>? menuCategoryID(dynamic response) => (getJsonField(
        response,
        r'''$.menuCategories[:].menu_category_id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  static dynamic? gallery(dynamic response) => getJsonField(
        response,
        r'''$.gallery''',
      );
  static dynamic? businessInformation(dynamic response) => getJsonField(
        response,
        r'''$.businessInfo''',
      );
  static List<String>? menuDescription(dynamic response) => (getJsonField(
        response,
        r'''$.menuCategories[:].menu_description''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? categoryDescription(dynamic response) => (getJsonField(
        response,
        r'''$.menuCategories[:].category_description''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static String? description(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.businessInfo.description''',
      ));
  static String? lastReviewedAt(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.businessInfo.last_reviewed_at''',
      ));
  static double? exchangeRate(dynamic response) =>
      castToType<double>(getJsonField(
        response,
        r'''$.exchangeRate.rate''',
      ));
  static int? priceRangeMin(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.businessInfo.price_range_min''',
      ));
  static int? priceRangeMax(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.businessInfo.price_range_max''',
      ));
  static String? originalCurrency(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.exchangeRate.from_currency''',
      ));
  static String? targetCurrency(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.exchangeRate.to_currency''',
      ));
}

class MenuItemsCall {
  static Future<ApiCallResponse> call({
    int? businessId,
    String? languageCode = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Menu items',
      apiUrl: 'https://wvb8ww.buildship.run/DishesAndDrinks',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'business_id': businessId,
        'language_code': languageCode,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: true,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static int? menuItemID(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.dishes[:].menu_item_id''',
      ));
  static List<int>? availableDietaryPreferences(dynamic response) =>
      (getJsonField(
        response,
        r'''$.availablePreferences''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  static List? allergyIds(dynamic response) => getJsonField(
        response,
        r'''$.dishes[:].allergy_ids''',
        true,
      ) as List?;
  static int? menuID(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.dishes[:].menu_id''',
      ));
  static int? businessID(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.dishes[:].business_id''',
      ));
  static int? displayOrder(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.dishes[:].display_order''',
      ));
  static int? itemPrice(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.dishes[:].base_price''',
      ));
  static int? menuCategoryID(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.dishes[:].menu_category_id''',
      ));
  static bool? isBeverage(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.dishes[:].is_beverage''',
      ));
  static List<String>? itemDescription(dynamic response) => (getJsonField(
        response,
        r'''$.dishes[:].item_description''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static String? itemName(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.dishes[:].item_name''',
      ));
  static List? dietaryTypeIds(dynamic response) => getJsonField(
        response,
        r'''$.dishes[:].dietary_type_ids''',
        true,
      ) as List?;
  static String? itemImageURL(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.dishes[:].item_image_url''',
      ));
  static List? menuItems(dynamic response) => getJsonField(
        response,
        r'''$.dishes''',
        true,
      ) as List?;
  static String? languageCode(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.dishes[:].language_code''',
      ));
  static String? lastReviewedAt(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.dishes[:].last_reviewed_at''',
      ));
  static List<String>? courseDescription(dynamic response) => (getJsonField(
        response,
        r'''$.dishes[:].course_description''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? packageDescription(dynamic response) => (getJsonField(
        response,
        r'''$.packages[:].package_description''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? courseName(dynamic response) => (getJsonField(
        response,
        r'''$.dishes[:].course_name''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? itemType(dynamic response) => (getJsonField(
        response,
        r'''$.dishes[:].item_type''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<int>? availableAllergies(dynamic response) => (getJsonField(
        response,
        r'''$.availableAllergies''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  static List<int>? availableRestrictions(dynamic response) => (getJsonField(
        response,
        r'''$.availableRestrictions''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
}

class FiltersCall {
  static Future<ApiCallResponse> call({
    String? languageCode = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Filters',
      apiUrl: 'https://wvb8ww.buildship.run/filters',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'languageCode': languageCode,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: true,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ExchangeRatesCall {
  static Future<ApiCallResponse> call({
    String? fromCurrency = 'DKK',
    String? toCurrency = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Exchange rates',
      apiUrl: 'https://wvb8ww.buildship.run/getExchangeRates',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'to_currency': toCurrency,
        'from_currency': fromCurrency,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: true,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static double? exchangeRate(dynamic response) =>
      castToType<double>(getJsonField(
        response,
        r'''$[:].rate''',
      ));
}

class FilterDescriptionsCall {
  static Future<ApiCallResponse> call({
    String? languageCode = '',
    int? businessId,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'FilterDescriptions',
      apiUrl: 'https://wvb8ww.buildship.run/filterDescriptions',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'language_code': languageCode,
        'business_id': businessId,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List? allData(dynamic response) => getJsonField(
        response,
        r'''$.filterDescriptions''',
        true,
      ) as List?;
}

class MenuItemCall {
  static Future<ApiCallResponse> call({
    int? menuItemId,
    String? languageCode = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'MenuItem',
      apiUrl: 'https://wvb8ww.buildship.run/menuItem',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'menu_item_id': menuItemId,
        'language_code': languageCode,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}
