import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/auth/supabase_auth/auth_util.dart';

double returnDistance(
  LatLng currentDeviceLocation,
  double businessLatitude,
  double businessLongitude,
  String languageCode,
) {
  /// Calculates the distance between two geographical points using the Haversine formula.
  /// The unit of the returned distance (kilometers or miles) depends on the language code.
  ///
  /// Args:
  ///   currentDeviceLocation: The current location of the device as a LatLng object.
  ///   businessLatitude: The latitude of the business location.
  ///   businessLongitude: The longitude of the business location.
  ///   languageCode: The language code (e.g., 'en' for English).
  ///
  /// Returns:
  ///   The distance as a double, rounded to one decimal place, in either kilometers or miles.

  // Validate latitude and longitude
  if (businessLatitude < -90 || businessLatitude > 90) {
    throw Exception("Invalid business latitude: $businessLatitude");
  }
  if (businessLongitude < -180 || businessLongitude > 180) {
    throw Exception("Invalid business longitude: $businessLongitude");
  }

  // Conversion factor for degrees to radians
  var p = 0.017453292519943295;

  // Convert latitudes and longitudes from degrees to radians
  double lat1 = currentDeviceLocation.latitude * p;
  double lon1 = currentDeviceLocation.longitude * p;
  double lat2 = businessLatitude * p;
  double lon2 = businessLongitude * p;

  // Haversine formula to calculate the distance
  double a = 0.5 -
      math.cos(lat2 - lat1) / 2 +
      math.cos(lat1) * math.cos(lat2) * (1 - math.cos(lon2 - lon1)) / 2;

  // Distance in kilometers
  double result = 12742 * math.asin(math.sqrt(a));

  // If the language code is English, convert to miles.
  if (languageCode.toLowerCase() == 'en') {
    result = result * 0.621371;
  }

  // Round to one decimal place and return
  return double.parse(result.toStringAsFixed(1));
}

LatLng latLongcombine(
  double lat,
  double long,
) {
  // Assuming lat and long are single values
  double latValue =
      double.parse(double.parse(lat.toString()).toStringAsFixed(4));
  double longValue =
      double.parse(double.parse(long.toString()).toStringAsFixed(4));

  // Return the LatLng object
  return LatLng(latValue, longValue);
}

String openClosesAt(
  dynamic businessHours,
  DateTime currentDateTime,
  String? languageCode,
  dynamic translationsCache,
) {
  /// Determines if a business is currently open/closed and returns a localized status message.
  ///
  /// Handles complex business hour scenarios including:
  /// - Up to 5 time slots per day
  /// - Overnight hours (e.g., 22:00-02:00)
  /// - Special cases (00:00, 24:00 closing times)
  /// - Days marked as closed or by_appointment_only (both treated as closed)
  /// - Multi-language support (15 languages)
  ///
  /// Args:
  ///  businessHours: Map with day indices (0-6) as keys, each containing:
  ///    closed, by_appointment_only flags,
  ///    opening_time_N/closing_time_N (N=1..5),
  ///    cutoff_type_N_M/cutoff_time_N_M/cutoff_note_N_M (N=1..5, M=1..2)
  ///  currentDateTime: The reference time for checking status
  ///  languageCode: Optional language code (defaults to 'en' if null or unsupported)
  ///  translationsCache: Translation cache from FFAppState
  ///
  /// Returns:
  ///  Localized message indicating current status and next time change

  // ============================================================================
  // CONSTANTS
  // ============================================================================

  const int maxTimeSlotsPerDay = 5;

  // ============================================================================
  // HELPER FUNCTIONS
  // ============================================================================

  String _getLocalizedMessage(String translationKey, String? lang) {
    final effectiveLang = lang ?? 'en';
    return getTranslations(effectiveLang, translationKey, translationsCache);
  }

  int _convertTimeToMinutes(String? time) {
    if (time == null || time.isEmpty) return -1;

    try {
      final parts = time.split(':');
      if (parts.length < 2) return -1;

      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);

      if (hours == 24 && minutes == 0) return 1440;

      if (hours >= 0 && hours < 24 && minutes >= 0 && minutes < 60) {
        return hours * 60 + minutes;
      }

      return -1;
    } catch (e) {
      return -1;
    }
  }

  /// Parses a boolean from dynamic input (handles both bool and string "true"/"false")
  bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  /// A day is effectively closed if explicitly marked closed or by_appointment_only
  bool _isDayClosed(Map<String, dynamic> dayHours) {
    return _parseBool(dayHours['closed']) ||
        _parseBool(dayHours['by_appointment_only']);
  }

  Map<String, dynamic> _checkDayOpenStatus(
    Map<String, dynamic> businessHoursMap,
    int dayIndex,
    int currentMinutes,
  ) {
    final result = {
      'isOpen': false,
      'nextTime': null,
      'isOvernightClose': false,
      'slotIndex': -1
    };

    final dayKey = dayIndex.toString();
    if (!businessHoursMap.containsKey(dayKey) ||
        businessHoursMap[dayKey] is! Map) {
      return result;
    }

    final dayHours = businessHoursMap[dayKey] as Map<String, dynamic>;

    if (_isDayClosed(dayHours)) return result;

    for (int slotNum = 1; slotNum <= maxTimeSlotsPerDay; slotNum++) {
      final openingStr = dayHours['opening_time_$slotNum'] as String?;
      final closingStr = dayHours['closing_time_$slotNum'] as String?;

      if (openingStr == null || closingStr == null) continue;

      final openingMinutes = _convertTimeToMinutes(openingStr);
      final closingMinutes = _convertTimeToMinutes(closingStr);

      if (openingMinutes == -1 || closingMinutes == -1) continue;

      bool isOpen = false;
      bool isOvernightType = false;

      if (closingMinutes < openingMinutes) {
        isOvernightType = true;
        isOpen =
            currentMinutes >= openingMinutes || currentMinutes < closingMinutes;
      } else if (closingMinutes == 1440) {
        isOvernightType = true;
        isOpen =
            currentMinutes >= openingMinutes && currentMinutes < closingMinutes;
      } else if (closingMinutes == 0 &&
          openingMinutes > 0 &&
          openingMinutes < 1440) {
        isOvernightType = true;
        isOpen = currentMinutes >= openingMinutes;
      } else {
        isOpen =
            currentMinutes >= openingMinutes && currentMinutes < closingMinutes;
      }

      if (isOpen) {
        return {
          'isOpen': true,
          'nextTime': closingStr.substring(0, 5),
          'isOvernightClose': isOvernightType,
          'slotIndex': slotNum
        };
      }
    }

    return result;
  }

  Map<String, dynamic> _checkPreviousDayOvernight(
    Map<String, dynamic> businessHoursMap,
    int previousDayIndex,
    int currentMinutes,
  ) {
    final result = {'isOpen': false, 'nextTime': null, 'slotIndex': -1};

    final prevDayKey = previousDayIndex.toString();
    if (!businessHoursMap.containsKey(prevDayKey) ||
        businessHoursMap[prevDayKey] is! Map) {
      return result;
    }

    final prevDayHours = businessHoursMap[prevDayKey] as Map<String, dynamic>;

    if (_isDayClosed(prevDayHours)) return result;

    for (int slotNum = 1; slotNum <= maxTimeSlotsPerDay; slotNum++) {
      final openingStr = prevDayHours['opening_time_$slotNum'] as String?;
      final closingStr = prevDayHours['closing_time_$slotNum'] as String?;

      if (openingStr == null || closingStr == null) continue;

      final openingMinutes = _convertTimeToMinutes(openingStr);
      final closingMinutes = _convertTimeToMinutes(closingStr);

      if (openingMinutes == -1 || closingMinutes == -1) continue;

      final wasOvernight = (closingMinutes < openingMinutes) ||
          (closingMinutes == 0 &&
              openingMinutes > 0 &&
              openingMinutes < 1440) ||
          (closingMinutes == 1440 && openingMinutes < 1440);

      if (wasOvernight && currentMinutes < closingMinutes) {
        return {
          'isOpen': true,
          'nextTime': closingStr.substring(0, 5),
          'slotIndex': slotNum
        };
      }
    }

    return result;
  }

  Map<String, dynamic> _findNextOpening(
    Map<String, dynamic> businessHoursMap,
    int currentDayIndex,
    int currentMinutes,
  ) {
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final checkDayIndex = (currentDayIndex + dayOffset) % 7;
      final dayKey = checkDayIndex.toString();

      if (!businessHoursMap.containsKey(dayKey) ||
          businessHoursMap[dayKey] is! Map) {
        continue;
      }

      final dayHours = businessHoursMap[dayKey] as Map<String, dynamic>;

      if (_isDayClosed(dayHours)) continue;

      for (int slotNum = 1; slotNum <= maxTimeSlotsPerDay; slotNum++) {
        final openingStr = dayHours['opening_time_$slotNum'] as String?;
        if (openingStr == null) continue;

        final openingMinutes = _convertTimeToMinutes(openingStr);
        if (openingMinutes == -1) continue;

        if (dayOffset > 0 ||
            (dayOffset == 0 && openingMinutes > currentMinutes)) {
          return {'time': openingStr.substring(0, 5), 'offsetDays': dayOffset};
        }
      }
    }

    return {'time': 'N/A', 'offsetDays': -1};
  }

  // ============================================================================
  // MAIN LOGIC
  // ============================================================================

  if (businessHours == null || businessHours is! Map) {
    return _getLocalizedMessage('hours_no_data', languageCode);
  }

  final Map<String, dynamic> typedBusinessHours;
  try {
    typedBusinessHours = Map<String, dynamic>.from(
      (businessHours as Map).map((key, value) => MapEntry(
            key.toString(),
            (value is Map)
                ? Map<String, dynamic>.from(
                    value.map((k, v) => MapEntry(k.toString(), v)))
                : value,
          )),
    );
  } catch (e) {
    return _getLocalizedMessage('hours_no_data', languageCode);
  }

  final currentDayIndex = currentDateTime.weekday - 1;
  final currentMinutes = currentDateTime.hour * 60 + currentDateTime.minute;
  final previousDayIndex = (currentDayIndex - 1 + 7) % 7;

  final todayStatus = _checkDayOpenStatus(
    typedBusinessHours,
    currentDayIndex,
    currentMinutes,
  );

  final yesterdayStatus = _checkPreviousDayOvernight(
    typedBusinessHours,
    previousDayIndex,
    currentMinutes,
  );

  final isOpen =
      todayStatus['isOpen'] as bool || yesterdayStatus['isOpen'] as bool;

  if (isOpen) {
    if (todayStatus['isOpen'] as bool) {
      final closingTime = todayStatus['nextTime'] as String;
      final isOvernightType = todayStatus['isOvernightClose'] as bool;

      if (isOvernightType) {
        if (closingTime == '00:00') {
          return '${_getLocalizedMessage('hours_closes_tonight', languageCode)} $closingTime';
        } else if (closingTime == '24:00') {
          return '${_getLocalizedMessage('hours_closes_at', languageCode)} $closingTime';
        }
        return '${_getLocalizedMessage('hours_closes_tomorrow', languageCode)} $closingTime';
      }

      return '${_getLocalizedMessage('hours_closes_at', languageCode)} $closingTime';
    }

    final closingTime = yesterdayStatus['nextTime'] as String;
    return '${_getLocalizedMessage('hours_closes_at', languageCode)} $closingTime';
  }

  final nextOpening = _findNextOpening(
    typedBusinessHours,
    currentDayIndex,
    currentMinutes,
  );

  if (nextOpening['time'] == 'N/A') {
    return _getLocalizedMessage('hours_no_data', languageCode);
  }

  final nextTime = nextOpening['time'] as String;
  final offsetDays = nextOpening['offsetDays'] as int;

  if (offsetDays == 0) {
    return '${_getLocalizedMessage('hours_opens_at', languageCode)} $nextTime';
  }

  if (offsetDays == 1) {
    return '${_getLocalizedMessage('hours_opens_tomorrow', languageCode)} $nextTime';
  }

  return '${_getLocalizedMessage('hours_opens_at', languageCode)} $nextTime';
}

String getFilterTitles(
  int? selectedCount,
  int filterId,
  String languageCode,
  dynamic translationsCache,
) {
  /// Returns localized filter title with optional selection count.
  ///
  /// Used on the "search_results" page to display filter category titles.
  /// Appends the number of active selections in parentheses when applicable.
  ///
  /// Args:
  ///   selectedCount: Number of active selections (null or 0 = no count shown)
  ///   filterId: Filter category identifier (1=Location, 2=Type, 3=Preferences)
  ///   languageCode: ISO language code for localization
  ///   translationsCache: Translation cache from FFAppState
  ///
  /// Returns:
  ///   Localized filter title, optionally with count (e.g., "Type (3)")

  // Map filter IDs to translation keys
  const filterKeyMap = {
    1: 'filter_location',
    2: 'filter_type',
    3: 'filter_preferences',
  };

  // Get translation key for this filter ID
  final translationKey = filterKeyMap[filterId];

  // Guard: Invalid filter ID
  if (translationKey == null) {
    debugPrint('⚠️ Invalid filter ID: $filterId');
    return '';
  }

  // Get localized title using the getTranslation helper
  final baseTitle = getTranslations(
    languageCode,
    translationKey,
    translationsCache,
  );

  // Guard: Missing translation
  if (baseTitle == null || baseTitle.isEmpty || baseTitle.startsWith('⚠️')) {
    debugPrint('⚠️ Translation missing for filter: $translationKey');
    return '';
  }

  // Append selection count if present and non-zero
  final hasActiveSelections = selectedCount != null && selectedCount > 0;
  return hasActiveSelections ? '$baseTitle ($selectedCount)' : baseTitle;
}

String? convertAllergiesToString(
  List<int>? allergyIDs,
  String currentLanguage,
  bool isBeverage,
  dynamic translationsCache,
) {
  /// Converts allergy IDs to a localized, formatted allergen list string.
  ///
  /// Returns a grammatically correct list of allergens in the specified language,
  /// prefixed with "Contains" (localized). Falls back to an informational message
  /// if no allergens are listed.
  ///
  /// Args:
  ///  allergyIDs: List of allergen IDs (1-14) to convert to text
  ///  currentLanguage: ISO language code for localization
  ///  isBeverage: If true, uses beverage-specific empty messages
  ///  translationsCache: Translation cache from FFAppState
  ///
  /// Returns:
  ///  Formatted allergen string (e.g., "Contains milk protein, eggs and fish")
  ///  or fallback message if no allergens provided

  // ============================================================================
  // HELPER FUNCTIONS
  // ============================================================================

  /// Gets localized UI text
  String _getUIText(String key) {
    return getTranslations(currentLanguage, key, translationsCache);
  }

  /// Formats allergen list with proper grammar (commas and conjunction)
  String _formatAllergenList(List<String> allergens, String conjunction) {
    // Single allergen: just return it
    if (allergens.length == 1) return allergens[0];

    // Two allergens: join with conjunction only
    if (allergens.length == 2) {
      return '${allergens[0]} $conjunction ${allergens[1]}';
    }

    // Three or more: comma-separated with conjunction before last
    final allButLast = allergens.sublist(0, allergens.length - 1).join(', ');
    return '$allButLast, $conjunction ${allergens.last}';
  }

  // ============================================================================
  // MAIN LOGIC
  // ============================================================================

  // Return empty message if no allergens provided
  if (allergyIDs == null || allergyIDs.isEmpty) {
    final emptyKey =
        isBeverage ? 'allergen_empty_beverage' : 'allergen_empty_food';
    return _getUIText(emptyKey);
  }

  // Convert IDs to localized names, filtering invalid IDs
  final allergenTexts = <String>[];

  for (final id in allergyIDs) {
    // Build translation key (e.g., 'allergen_1', 'allergen_2')
    final translationKey = 'allergen_$id';
    final allergenName = getTranslations(
      currentLanguage,
      translationKey,
      translationsCache,
    );

    // Only add if translation exists and is not empty
    if (allergenName.isNotEmpty && !allergenName.startsWith('⚠️')) {
      allergenTexts.add(allergenName);
    }
  }

  // Return empty message if all IDs were invalid
  if (allergenTexts.isEmpty) {
    final emptyKey =
        isBeverage ? 'allergen_empty_beverage' : 'allergen_empty_food';
    return _getUIText(emptyKey);
  }

  // Sort allergens alphabetically for consistent display
  allergenTexts.sort();

  // Build formatted string
  final containsText = _getUIText('allergen_contains');
  final conjunction = _getUIText('allergen_and');
  final formattedList = _formatAllergenList(allergenTexts, conjunction);

  return '$containsText $formattedList';
}

String? convertDietaryPreferencesToString(
  List<int>? dietaryIDs,
  String currentLanguage,
  bool isBeverage,
  dynamic translationsCache,
) {
  /// Converts dietary preference IDs to a localized, formatted string.
  ///
  /// Returns a grammatically correct list of dietary preferences in the specified
  /// language, prefixed with context-appropriate text (e.g., "This dish is gluten-free
  /// and vegan"). Preferences are sorted by category: disease-related (gluten/lactose),
  /// religious (halal/kosher), then diet-based (pescetarian/vegetarian/vegan).
  ///
  /// Args:
  ///  dietaryIDs: List of dietary preference IDs (1-7) to convert
  ///  currentLanguage: ISO language code for localization
  ///  isBeverage: If true, uses beverage-specific phrasing
  ///  translationsCache: Translation cache from FFAppState
  ///
  /// Returns:
  ///  Formatted dietary string (e.g., "This dish is gluten-free, halal and vegan")
  ///  or fallback message if no preferences provided

  // ============================================================================
  // CONFIGURATION
  // ============================================================================

  /// Priority order for sorting dietary preferences by category:
  /// Disease-related (gluten-free, lactose-free) → Religious (halal, kosher) →
  /// Diet-based (pescetarian, vegetarian, vegan)
  const sortOrder = [1, 4, 3, 5, 2, 7, 6];

  // ============================================================================
  // HELPER FUNCTIONS
  // ============================================================================

  /// Gets localized UI text
  String _getUIText(String key) {
    return getTranslations(currentLanguage, key, translationsCache);
  }

  /// Formats dietary preference list with proper grammar (commas and conjunction)
  String _formatPreferenceList(List<String> preferences, String conjunction) {
    // Single preference: just return it
    if (preferences.length == 1) return preferences[0];

    // Two preferences: join with conjunction only
    if (preferences.length == 2) {
      return '${preferences[0]} $conjunction ${preferences[1]}';
    }

    // Three or more: comma-separated with conjunction before last
    final allButLast =
        preferences.sublist(0, preferences.length - 1).join(', ');
    return '$allButLast, $conjunction ${preferences.last}';
  }

  /// Sorts dietary IDs by priority: disease-based → religious → diet-based
  List<int> _sortByPriority(List<int> ids) {
    final sortedIds = List<int>.from(ids);
    sortedIds.sort((a, b) {
      final aIndex = sortOrder.indexOf(a);
      final bIndex = sortOrder.indexOf(b);
      // If ID not in sort order, place at end
      final aPriority = aIndex == -1 ? sortOrder.length : aIndex;
      final bPriority = bIndex == -1 ? sortOrder.length : bIndex;
      return aPriority.compareTo(bPriority);
    });
    return sortedIds;
  }

  // ============================================================================
  // MAIN LOGIC
  // ============================================================================

  // Return empty message if no dietary preferences provided
  if (dietaryIDs == null || dietaryIDs.isEmpty) {
    final emptyKey =
        isBeverage ? 'dietary_empty_beverage' : 'dietary_empty_food';
    return _getUIText(emptyKey);
  }

  // Convert IDs to localized names, filtering invalid IDs
  final validIDs = <int>[];

  for (final id in dietaryIDs) {
    // Build translation key (e.g., 'dietary_1', 'dietary_2')
    final translationKey = 'dietary_$id';
    final dietaryName = getTranslations(
      currentLanguage,
      translationKey,
      translationsCache,
    );

    // Only add if translation exists and is not empty
    if (dietaryName.isNotEmpty && !dietaryName.startsWith('⚠️')) {
      validIDs.add(id);
    }
  }

  // Return empty message if all IDs were invalid
  if (validIDs.isEmpty) {
    final emptyKey =
        isBeverage ? 'dietary_empty_beverage' : 'dietary_empty_food';
    return _getUIText(emptyKey);
  }

  // Sort IDs by priority (disease → religious → diet)
  final sortedIDs = _sortByPriority(validIDs);

  // Convert sorted IDs to localized text
  final preferenceTexts = sortedIDs
      .map((id) {
        final translationKey = 'dietary_$id';
        return getTranslations(
          currentLanguage,
          translationKey,
          translationsCache,
        );
      })
      .where((text) => text.isNotEmpty)
      .toList();

  // Build formatted string
  final prefix = isBeverage
      ? _getUIText('dietary_prefix_beverage')
      : _getUIText('dietary_prefix_food');
  final conjunction = _getUIText('dietary_and');
  final formattedList = _formatPreferenceList(preferenceTexts, conjunction);

  return '$prefix $formattedList';
}

String daysDayOpeningHour(
  DateTime currentTime,
  dynamic openingHours,
  String languageCode,
  dynamic translationsCache,
) {
  /// Returns localized opening hours status and schedule information.
  ///
  /// Displays current status in format:
  /// - If open: "[DayName] - [OpenTime] - [CloseTime]"
  /// - If closed but opens later today: "Closed - opens later at [Time]"
  /// - If closed until future day: "Closed - opens again [tomorrow/on DayName] at [Time]"
  ///
  /// Days marked closed or by_appointment_only are treated as closed.
  /// Supports up to 5 time slots per day.

  // ============================================================================
  // CONSTANTS
  // ============================================================================

  const int maxTimeSlotsPerDay = 5;

  // ============================================================================
  // HELPER FUNCTIONS
  // ============================================================================

  String _getUIText(String key) {
    return getTranslations(languageCode, key, translationsCache);
  }

  String _getDayKey(int dayIndex) {
    const dayKeys = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];
    return dayKeys[dayIndex];
  }

  String _getDayNameCapitalized(int dayIndex) {
    final translationKey = 'day_${_getDayKey(dayIndex)}_cap';
    return getTranslations(languageCode, translationKey, translationsCache);
  }

  String _getDayNameLowercase(int dayIndex) {
    final translationKey = 'day_${_getDayKey(dayIndex)}_lower';
    return getTranslations(languageCode, translationKey, translationsCache);
  }

  int _convertTimeToMinutes(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return -1;

    try {
      final parts = timeStr.split(':');
      if (parts.length < 2) return -1;

      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);

      if (hours == 24 && minutes == 0) return 1440;

      if (hours >= 0 && hours < 24 && minutes >= 0 && minutes < 60) {
        return hours * 60 + minutes;
      }

      return -1;
    } catch (e) {
      return -1;
    }
  }

  String _formatTimeForDisplay(String? timeStr) {
    if (timeStr == null || timeStr.length < 5) return '';
    return timeStr.substring(0, 5);
  }

  bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  bool _isDayClosed(dynamic dayHoursRaw) {
    if (dayHoursRaw == null || dayHoursRaw is! Map) return false;
    return _parseBool(dayHoursRaw['closed']) ||
        _parseBool(dayHoursRaw['by_appointment_only']);
  }

  Map<String, String>? _checkIfOpenNow(
    Map<String, String?> dayHours,
    int currentMinutes,
  ) {
    for (int slotNum = 1; slotNum <= maxTimeSlotsPerDay; slotNum++) {
      final openTimeStr = dayHours['opening_time_$slotNum'];
      final closeTimeStr = dayHours['closing_time_$slotNum'];

      if (openTimeStr == null || closeTimeStr == null) continue;

      final openMinutes = _convertTimeToMinutes(openTimeStr);
      final closeMinutesRaw = _convertTimeToMinutes(closeTimeStr);

      if (openMinutes == -1 || closeMinutesRaw == -1) continue;

      final closeMinutes = closeMinutesRaw == 0 ? 1440 : closeMinutesRaw;

      final isOpen = closeMinutes < openMinutes
          ? (currentMinutes >= openMinutes || currentMinutes < closeMinutes)
          : (currentMinutes >= openMinutes && currentMinutes < closeMinutes);

      if (isOpen) {
        return {
          'openTime': openTimeStr,
          'closeTime': closeTimeStr,
        };
      }
    }

    return null;
  }

  String? _findLaterOpeningToday(
    Map<String, String?> dayHours,
    int currentMinutes,
  ) {
    for (int slotNum = 1; slotNum <= maxTimeSlotsPerDay; slotNum++) {
      final openTimeStr = dayHours['opening_time_$slotNum'];
      final closeTimeStr = dayHours['closing_time_$slotNum'];

      if (openTimeStr == null || closeTimeStr == null) continue;

      final openMinutes = _convertTimeToMinutes(openTimeStr);
      final closeMinutes = _convertTimeToMinutes(closeTimeStr);

      if (openMinutes == -1 || closeMinutes == -1) continue;

      if (currentMinutes < openMinutes) return openTimeStr;
    }

    return null;
  }

  String? _findFutureOpening(Map<String, String?> dayHours) {
    for (int slotNum = 1; slotNum <= maxTimeSlotsPerDay; slotNum++) {
      final openTimeStr = dayHours['opening_time_$slotNum'];

      if (openTimeStr != null &&
          openTimeStr.isNotEmpty &&
          _convertTimeToMinutes(openTimeStr) != -1) {
        return openTimeStr;
      }
    }

    return null;
  }

  // ============================================================================
  // MAIN LOGIC
  // ============================================================================

  if (openingHours == null || openingHours is! Map) {
    return _getUIText('hours_closed');
  }

  final Map<String, dynamic> hoursMap;
  try {
    hoursMap = Map<String, dynamic>.from(openingHours);
  } catch (e) {
    return _getUIText('hours_closed');
  }

  final currentDayIndex = currentTime.weekday - 1;
  final currentMinutes = currentTime.hour * 60 + currentTime.minute;

  final todayHoursRaw = hoursMap[currentDayIndex.toString()];

  // If today is not explicitly closed/by_appointment_only, check normal hours
  if (todayHoursRaw != null &&
      todayHoursRaw is Map &&
      !_isDayClosed(todayHoursRaw)) {
    final todayHours = Map<String, String?>.from(
      todayHoursRaw
          .map((key, value) => MapEntry(key.toString(), value?.toString())),
    );

    final openStatus = _checkIfOpenNow(todayHours, currentMinutes);

    if (openStatus != null) {
      final dayName = _getDayNameCapitalized(currentDayIndex);
      final openTime = _formatTimeForDisplay(openStatus['openTime']);
      final closeTime = _formatTimeForDisplay(openStatus['closeTime']);
      return '$dayName - $openTime - $closeTime';
    }

    final laterOpening = _findLaterOpeningToday(todayHours, currentMinutes);

    if (laterOpening != null) {
      final opensLaterText = _getUIText('hours_opens_later');
      final timeFormatted = _formatTimeForDisplay(laterOpening);
      return '${_getUIText('hours_closed')} - $opensLaterText $timeFormatted';
    }
  }

  // Find next opening on future days, skipping closed/by_appointment_only days
  for (int dayOffset = 1; dayOffset <= 7; dayOffset++) {
    final nextDayIndex = (currentDayIndex + dayOffset) % 7;
    final nextDayHoursRaw = hoursMap[nextDayIndex.toString()];

    if (nextDayHoursRaw != null &&
        nextDayHoursRaw is Map &&
        !_isDayClosed(nextDayHoursRaw)) {
      final nextDayHours = Map<String, String?>.from(
        nextDayHoursRaw
            .map((key, value) => MapEntry(key.toString(), value?.toString())),
      );

      final nextOpening = _findFutureOpening(nextDayHours);

      if (nextOpening != null) {
        final closedText = _getUIText('hours_closed');
        final opensAgainText = _getUIText('hours_opens_again');
        final atText = _getUIText('hours_at');
        final timeFormatted = _formatTimeForDisplay(nextOpening);

        if (dayOffset == 1) {
          final tomorrowText = _getUIText('hours_tomorrow');
          return '$closedText - $opensAgainText $tomorrowText $atText $timeFormatted';
        }

        final onText = _getUIText('hours_on');
        final dayName = _getDayNameLowercase(nextDayIndex);
        return '$closedText - $opensAgainText $onText $dayName $atText $timeFormatted';
      }
    }
  }

  return _getUIText('hours_closed');
}

String? generateFilterSummary(
  int itemCount,
  int? selectedPreferenceId,
  List<int>? excludedAllergyIdsList,
  String currentLanguageCode,
  dynamic translationsCache,
  List<int>? selectedRestrictionIds,
) {
  /// Generates localized filter summary with proper grammatical structure.
  ///
  /// LOGICAL TREE:
  /// 1. Start with item count
  /// 2. Dietary involved?
  ///    YES → Use dietary prefix + list dietary items with conjunctions
  ///    NO → Skip to allergen check
  /// 3. Allergen involved?
  ///    If dietary present → Add "and are free from" + allergen list
  ///    If no dietary → Use standalone "that are free from" + allergen list
  /// 4. Format allergen list (1, 2, or 3+ with "X other allergens")
  ///
  /// Examples:
  /// - "Showing the 34 items that are or can be made lactose-free."
  /// - "Showing the 34 items that are or can be made gluten-free and lactose-free."
  /// - "Showing the 34 items that are free from peanuts."
  /// - "Showing the 34 items that are or can be made lactose-free and are free from peanuts and fish."

  // ============================================================================
  // CONFIGURATION
  // ============================================================================

  const impliedAllergenExclusions = {
    1: [2], // Gluten-free → cereals containing gluten
    4: [7], // Lactose-free → milk
    6: [7, 4, 5, 3, 8], // Vegan → milk, eggs, fish, crustaceans, molluscs
    7: [5, 3, 8], // Vegetarian → fish, crustaceans, molluscs
  };

  const lowercaseLanguages = {
    'da',
    'en',
    'es',
    'de',
    'fr',
    'nl',
    'no',
    'sv',
    'it',
    'pl',
    'fi',
  };

  const noSpaceBeforeCount = {'zh', 'ja'};

  // ============================================================================
  // HELPER FUNCTIONS
  // ============================================================================

  String _getUIText(String key) {
    return getTranslations(currentLanguageCode, key, translationsCache);
  }

  String? _getDietaryPreferenceNameSafe(int? prefId) {
    if (prefId == null || prefId == 0) return null;

    final translationKey = 'dietary_$prefId';
    final dietaryName = getTranslations(
      currentLanguageCode,
      translationKey,
      translationsCache,
    );

    if (dietaryName.isEmpty || dietaryName.startsWith('⚠️')) {
      return null;
    }

    return dietaryName;
  }

  String _formatAllergenList(
    List<String> allergens,
    String allergyAnd,
    String othersSingular,
    String othersPlural,
    bool noSpaceBeforeCountNeeded,
  ) {
    if (allergens.isEmpty) return '';
    if (allergens.length == 1) return allergens.first;
    if (allergens.length == 2) return allergens.join(allergyAnd);

    final firstTwo = allergens.sublist(0, 2).join(', ');
    final othersCount = allergens.length - 2;
    final othersNoun = othersCount == 1 ? othersSingular : othersPlural;

    if (noSpaceBeforeCountNeeded) {
      return '$firstTwo$allergyAnd$othersCount$othersNoun';
    }

    return '$firstTwo$allergyAnd$othersCount $othersNoun';
  }

  String _formatDietaryList(List<String> items, String conjunction) {
    if (items.isEmpty) return '';
    if (items.length == 1) return items.first;
    if (items.length == 2) return items.join(conjunction);

    final allButLast = items.sublist(0, items.length - 1).join(', ');
    final last = items.last;
    return '$allButLast$conjunction$last';
  }

  String _applyCapitalization(String text) {
    return lowercaseLanguages.contains(currentLanguageCode)
        ? text.toLowerCase()
        : text;
  }

  String? _getAllergenNameSafe(int allergenId) {
    final translationKey = 'allergen_$allergenId';
    final allergenName = getTranslations(
      currentLanguageCode,
      translationKey,
      translationsCache,
    );

    if (allergenName.isEmpty || allergenName.startsWith('⚠️')) {
      return null;
    }

    return allergenName;
  }

  bool _isValidDietaryId(int? dietaryId) {
    return dietaryId != null && dietaryId != 0;
  }

  // ============================================================================
  // MAIN LOGIC
  // ============================================================================

  final isPlural = itemCount > 1;
  final itemCountKey = isPlural ? 'filter_item_plural' : 'filter_item_singular';
  final itemCountText =
      _getUIText(itemCountKey).replaceAll('{}', itemCount.toString());

  // ============================================================================
  // STEP 1: COLLECT DIETARY FILTERS
  // ============================================================================

  final dietaryFilters = <String>[];

  // Add dietary restrictions (IDs: 1,3,4,5)
  final restrictionIds = selectedRestrictionIds ?? [];
  for (final restrictionId in restrictionIds) {
    if (_isValidDietaryId(restrictionId)) {
      final restrictionText = _getDietaryPreferenceNameSafe(restrictionId);
      if (restrictionText != null) {
        var formattedText = _applyCapitalization(restrictionText);
        if (currentLanguageCode == 'de') {
          formattedText += isPlural ? ' sind' : ' ist';
        }
        dietaryFilters.add(formattedText);
      }
    }
  }

  // Add dietary preference (IDs: 2,6,7)
  if (_isValidDietaryId(selectedPreferenceId)) {
    final preferenceText = _getDietaryPreferenceNameSafe(selectedPreferenceId);
    if (preferenceText != null) {
      var formattedText = _applyCapitalization(preferenceText);
      if (currentLanguageCode == 'de') {
        formattedText += isPlural ? ' sind' : ' ist';
      }
      dietaryFilters.add(formattedText);
    }
  }

  final hasDietaryFilters = dietaryFilters.isNotEmpty;

  // ============================================================================
  // STEP 2: COLLECT ALLERGEN FILTERS
  // ============================================================================

  final excludedAllergyIds = excludedAllergyIdsList ?? [];

  // Calculate implied allergens from dietary filters
  final impliedAllergens = <int>{};
  for (final restrictionId in restrictionIds) {
    if (_isValidDietaryId(restrictionId) &&
        impliedAllergenExclusions.containsKey(restrictionId)) {
      impliedAllergens.addAll(impliedAllergenExclusions[restrictionId]!);
    }
  }
  if (_isValidDietaryId(selectedPreferenceId) &&
      impliedAllergenExclusions.containsKey(selectedPreferenceId)) {
    impliedAllergens.addAll(impliedAllergenExclusions[selectedPreferenceId]!);
  }

  // Build allergen display list (excluding implied ones)
  final allergensToShow = <String>[];
  for (final allergenId in excludedAllergyIds) {
    if (impliedAllergens.contains(allergenId)) continue;

    final allergenName = _getAllergenNameSafe(allergenId);
    if (allergenName == null) continue;

    allergensToShow.add(_applyCapitalization(allergenName));
  }

  allergensToShow.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  final hasAllergenFilters = allergensToShow.isNotEmpty;

  // ============================================================================
  // STEP 3: BUILD SENTENCE BASED ON LOGICAL TREE
  // ============================================================================

  // CASE 1: No filters at all
  if (!hasDietaryFilters && !hasAllergenFilters) {
    return '$itemCountText.';
  }

  // CASE 2: Dietary only (no allergens)
  if (hasDietaryFilters && !hasAllergenFilters) {
    final prefixKey = isPlural
        ? 'filter_dietary_prefix_plural'
        : 'filter_dietary_prefix_singular';
    final prefix = _getUIText(prefixKey);
    final dietaryList = _formatDietaryList(
      dietaryFilters,
      _getUIText('filter_and'),
    );
    return '$itemCountText$prefix$dietaryList.';
  }

  // CASE 3: Allergen only (no dietary)
  if (!hasDietaryFilters && hasAllergenFilters) {
    final connectorKey =
        isPlural ? 'filter_connector_plural' : 'filter_connector_singular';
    final connector = _getUIText(connectorKey);
    final allergenList = _formatAllergenList(
      allergensToShow,
      _getUIText('filter_and'),
      _getUIText('filter_other_singular'),
      _getUIText('filter_other_plural'),
      noSpaceBeforeCount.contains(currentLanguageCode),
    );
    return '$itemCountText$connector$allergenList.';
  }

  // CASE 4: Both dietary AND allergen
  final prefixKey = isPlural
      ? 'filter_dietary_prefix_plural'
      : 'filter_dietary_prefix_singular';
  final prefix = _getUIText(prefixKey);
  final dietaryList = _formatDietaryList(
    dietaryFilters,
    _getUIText('filter_and'),
  );
  final andAreFreeFrom = _getUIText('filter_and_are_free_from');
  final allergenList = _formatAllergenList(
    allergensToShow,
    _getUIText('filter_and'),
    _getUIText('filter_other_singular'),
    _getUIText('filter_other_plural'),
    noSpaceBeforeCount.contains(currentLanguageCode),
  );

  return '$itemCountText$prefix$dietaryList$andAreFreeFrom$allergenList.';
}

String? getLocalizedCurrencyName(
  String languageCode,
  String? currencyCode,
  dynamic translationsCache,
) {
  /// Returns localized currency name for the given currency code.
  ///
  /// Provides human-readable currency names in the user's language,
  /// falling back to the currency code itself if no translation exists.
  ///
  /// Args:
  ///  languageCode: ISO language code for localization
  ///  currencyCode: ISO 4217 currency code (e.g., 'USD', 'EUR', 'DKK')
  ///  translationsCache: Translation cache from FFAppState
  ///
  /// Returns:
  ///  Localized currency name, or the currency code if not found/null
  ///
  /// Examples:
  ///  - getLocalizedCurrencyName('da', 'DKK', cache) → 'danske kroner'
  ///  - getLocalizedCurrencyName('en', 'USD', cache) → 'US Dollar'
  ///  - getLocalizedCurrencyName('en', 'XYZ', cache) → 'XYZ' (fallback)
  ///  - getLocalizedCurrencyName('en', null, cache) → null

  // Return null if currency code is null
  if (currencyCode == null) return null;

  // Normalize currency code to uppercase for consistency
  final normalizedCode = currencyCode.toUpperCase();

  // Build translation key (e.g., 'currency_dkk')
  final translationKey = 'currency_${normalizedCode.toLowerCase()}';

  // Get translation using central function with cache
  final translatedName = getTranslations(
    languageCode,
    translationKey,
    translationsCache,
  );

  // If translation not found (empty or starts with ⚠️), fallback to currency code
  if (translatedName.isEmpty || translatedName.startsWith('⚠️')) {
    return normalizedCode;
  }

  // Return translated name
  return translatedName;
}

String? formatLocalizedDate(
  String dateTimeString,
  String languageCode,
) {
  /// Formats ISO 8601 datetime string to localized date with native month names.
  ///
  /// Converts dates to region-specific formats with properly localized month names.
  /// Falls back to English format if parsing fails or locale is unavailable.
  ///
  /// Args:
  ///  dateTimeString: ISO 8601 datetime string (e.g., '2025-08-08T12:00:00Z')
  ///  languageCode: ISO language code for localization
  ///
  /// Returns:
  ///  Localized date string, or null if input is null/empty/invalid
  ///
  /// Examples:
  ///  - formatLocalizedDate('2025-08-08T12:00:00Z', 'en') → 'August 8, 2025'
  ///  - formatLocalizedDate('2025-08-08T12:00:00Z', 'da') → '8. august 2025'
  ///  - formatLocalizedDate('2025-08-08T12:00:00Z', 'zh') → '2025年8月8日'
  ///  - formatLocalizedDate('', 'en') → null

  // --- Translation Data ---

  /// Date format patterns and locale strings by language
  const dateFormatConfig = {
    'en': {
      'pattern': 'MMMM d, y', // August 8, 2025
      'locale': 'en_US',
    },
    'da': {
      'pattern': 'd. MMMM y', // 8. august 2025
      'locale': 'da_DK',
    },
    'de': {
      'pattern': 'd. MMMM y', // 8. August 2025
      'locale': 'de_DE',
    },
    'es': {
      'pattern': 'd \'de\' MMMM \'de\' y', // 8 de agosto de 2025
      'locale': 'es_ES',
    },
    'fi': {
      'pattern': 'd. MMMM y', // 8. elokuuta 2025
      'locale': 'fi_FI',
    },
    'fr': {
      'pattern': 'd MMMM y', // 8 août 2025
      'locale': 'fr_FR',
    },
    'it': {
      'pattern': 'd MMMM y', // 8 agosto 2025
      'locale': 'it_IT',
    },
    'ja': {
      'pattern': 'y年M月d日', // 2025年8月8日
      'locale': 'ja_JP',
    },
    'ko': {
      'pattern': 'y년 M월 d일', // 2025년 8월 8일
      'locale': 'ko_KR',
    },
    'nl': {
      'pattern': 'd MMMM y', // 8 augustus 2025
      'locale': 'nl_NL',
    },
    'no': {
      'pattern': 'd. MMMM y', // 8. august 2025
      'locale': 'nb_NO', // Norwegian Bokmål
    },
    'pl': {
      'pattern': 'd MMMM y', // 8 sierpnia 2025
      'locale': 'pl_PL',
    },
    'sv': {
      'pattern': 'd MMMM y', // 8 augusti 2025
      'locale': 'sv_SE',
    },
    'uk': {
      'pattern': 'd MMMM y', // 8 серпня 2025
      'locale': 'uk_UA',
    },
    'zh': {
      'pattern': 'y年M月d日', // 2025年8月8日
      'locale': 'zh_CN',
    },
  };

  // --- Main Logic ---

  // Return null for empty or null input
  if (dateTimeString.isEmpty) return null;

  // Parse ISO 8601 datetime string
  final DateTime dateTime;
  try {
    dateTime = DateTime.parse(dateTimeString);
  } catch (e) {
    return null; // Invalid datetime format
  }

  // Get format configuration for language (fallback to English)
  final config = dateFormatConfig[languageCode] ?? dateFormatConfig['en']!;
  final pattern = config['pattern']!;
  final locale = config['locale']!;

  // Format date with locale-specific pattern
  try {
    final formatter = DateFormat(pattern, locale);
    return formatter.format(dateTime);
  } catch (e) {
    // Fallback to English if locale formatting fails
    try {
      final fallbackFormatter = DateFormat(
        dateFormatConfig['en']!['pattern']!,
        dateFormatConfig['en']!['locale']!,
      );
      return fallbackFormatter.format(dateTime);
    } catch (e) {
      return null; // Formatting completely failed
    }
  }
}

String? convertAndFormatPriceRange(
  double minPrice,
  double maxPrice,
  String originalCurrencyCode,
  double exchangeRate,
  String targetCurrencyCode,
) {
  /// Converts and formats price range with currency conversion and localized formatting.
  ///
  /// Handles currency conversion using exchange rates and formats the output
  /// according to currency-specific rules (symbol placement, formatting).
  /// Skips conversion if original and target currencies match.
  ///
  /// Args:
  ///  minPrice: Minimum price in original currency
  ///  maxPrice: Maximum price in original currency
  ///  originalCurrencyCode: ISO 4217 currency code of the original price
  ///  exchangeRate: Exchange rate from original to target currency
  ///  targetCurrencyCode: ISO 4217 currency code for output
  ///
  /// Returns:
  ///  Formatted price range string with appropriate currency symbol and placement
  ///
  /// Examples:
  ///  - (100, 200, 'USD', 7.0, 'DKK') → '700 - 1,400 kr.'
  ///  - (100, 200, 'DKK', 1.0, 'EUR') → '€13 - €27'
  ///  - (100, 200, 'DKK', 1.0, 'DKK') → '100 - 200 kr.' (no conversion)

  // ============================================================================
  // HELPER FUNCTIONS
  // ============================================================================

  /// Converts price using exchange rate, or returns original if currencies match
  double _convertPrice(
    double price,
    String fromCurrency,
    String toCurrency,
    double rate,
  ) {
    return fromCurrency.toUpperCase() == toCurrency.toUpperCase()
        ? price
        : price * rate;
  }

  /// Formats number as integer with thousands separator
  String _formatPrice(double price) {
    return NumberFormat('###,###').format(price.round());
  }

  // ============================================================================
  // MAIN LOGIC
  // ============================================================================

  // Validate inputs
  if (minPrice < 0 || maxPrice < 0 || exchangeRate <= 0) {
    return null; // Invalid input
  }

  if (minPrice > maxPrice) {
    return null; // Invalid range
  }

  // Normalize currency codes
  final targetCurrency = targetCurrencyCode.toUpperCase();

  // Convert prices
  final convertedMin = _convertPrice(
    minPrice,
    originalCurrencyCode,
    targetCurrencyCode,
    exchangeRate,
  );

  final convertedMax = _convertPrice(
    maxPrice,
    originalCurrencyCode,
    targetCurrencyCode,
    exchangeRate,
  );

  // Get currency formatting rules from central function
  final rulesJson = getCurrencyFormattingRules(targetCurrency);

  if (rulesJson == null) return null;

  // Parse JSON rules
  final Map<String, dynamic> rules;
  try {
    rules = jsonDecode(rulesJson);
  } catch (e) {
    return null; // Failed to parse rules
  }

  final symbol = rules['symbol'] as String;
  final isPrefix = rules['isPrefix'] as bool;

  // Format prices
  final formattedMin = _formatPrice(convertedMin);
  final formattedMax = _formatPrice(convertedMax);

  // Build output string based on symbol placement
  if (isPrefix) {
    // Prefix: Symbol repeated for both values (e.g., "€100 - €200")
    return '$symbol$formattedMin - $symbol$formattedMax';
  } else {
    // Suffix: Single symbol at end (e.g., "100 - 200 kr.")
    return '$formattedMin - $formattedMax $symbol';
  }
}

List<dynamic> getCurrencyOptionsForLanguage(
  String languageCode,
  dynamic translationsCache,
) {
  /// Returns localized currency options for dropdown/selection UI.
  ///
  /// Uses getCurrencyFormattingRules() to determine symbols dynamically
  /// and getTranslations() for localized names.
  ///
  /// Args:
  ///   languageCode: ISO language code (e.g., 'en', 'da', 'de')
  ///   translationsCache: Translation cache from FFAppState
  ///
  /// Returns:
  ///   List of maps with 'label' and 'code' keys.

  // ============================================================================
  // CONFIGURATION
  // ============================================================================

  languageCode = languageCode.toLowerCase().trim();

  const currencyConfigByLanguage = {
    'en': ['USD', 'GBP', 'DKK'],
    'da': ['DKK'],
    'de': ['EUR', 'DKK'],
    'fr': ['EUR', 'DKK'],
    'it': ['EUR', 'DKK'],
    'no': ['NOK', 'DKK'],
    'sv': ['SEK', 'DKK'],
  };

  // ============================================================================
  // HELPER FUNCTIONS
  // ============================================================================

  /// Get localized currency name using translation system.
  String? _getCurrencyName(String code) {
    final translationKey = 'currency_${code.toLowerCase()}_cap';
    final translatedName =
        getTranslations(languageCode, translationKey, translationsCache);

    if (translatedName.isEmpty || translatedName.startsWith('⚠️')) {
      return null;
    }
    return translatedName;
  }

  /// Extract symbol from getCurrencyFormattingRules().
  String _getSymbol(String code) {
    try {
      final jsonStr = getCurrencyFormattingRules(code);
      if (jsonStr == null) return code;
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final symbol = (data['symbol'] ?? '').toString().trim();
      return symbol.isEmpty ? code : symbol;
    } catch (_) {
      return code;
    }
  }

  // ============================================================================
  // MAIN LOGIC
  // ============================================================================

  final codes = currencyConfigByLanguage[languageCode] ?? [];
  final List<Map<String, String>> options = [];

  for (final code in codes) {
    final name = _getCurrencyName(code);
    if (name == null) continue;

    final symbol = _getSymbol(code);
    options.add({
      'label': '$name ($symbol)',
      'code': code,
    });
  }

  return options;
}

List<dynamic> getLanguageOptions() {
  /// Returns active language options for UI selection, sorted by display order.
  ///
  /// Filters languages marked as active and sorts them by their display_order
  /// property. Returns formatted options suitable for dropdown/selection widgets.
  ///
  /// Returns:
  ///  List of maps with 'label' (flag + name) and 'code' (ISO language code) keys.
  ///  Only includes languages where is_active is true, sorted by display_order.
  ///
  /// Examples:
  ///  Returns: [
  ///    {'label': '🇩🇰 Dansk', 'code': 'da'},
  ///    {'label': '🇬🇧 English', 'code': 'en'},
  ///    {'label': '🇩🇪 Deutsch', 'code': 'de'},
  ///    ...
  ///  ]

  // --- Language Configuration ---

  /// Complete language catalog with metadata
  /// Only languages with is_active=true will be returned
  /// display_order determines sort order (lower = higher priority)
  const allLanguages = [
    {
      'idx': 0,
      'language_code': 'da',
      'name': 'Dansk',
      'flag': '🇩🇰',
      'display_order': 1,
      'is_active': true,
      'is_rtl': false,
    },
    {
      'idx': 2,
      'language_code': 'en',
      'name': 'English',
      'flag': '🇬🇧',
      'display_order': 2,
      'is_active': true,
      'is_rtl': false,
    },
    {
      'idx': 1,
      'language_code': 'de',
      'name': 'Deutsch',
      'flag': '🇩🇪',
      'display_order': 3,
      'is_active': true,
      'is_rtl': false,
    },
    {
      'idx': 12,
      'language_code': 'sv',
      'name': 'Svenska',
      'flag': '🇸🇪',
      'display_order': 4,
      'is_active': true,
      'is_rtl': false,
    },
    {
      'idx': 10,
      'language_code': 'no',
      'name': 'Norsk',
      'flag': '🇳🇴',
      'display_order': 5,
      'is_active': true,
      'is_rtl': false,
    },
    {
      'idx': 6,
      'language_code': 'it',
      'name': 'Italiano',
      'flag': '🇮🇹',
      'display_order': 6,
      'is_active': true,
      'is_rtl': false,
    },
    {
      'idx': 5,
      'language_code': 'fr',
      'name': 'Français',
      'flag': '🇫🇷',
      'display_order': 7,
      'is_active': true,
      'is_rtl': false,
    },
    // Inactive languages (kept for future activation)
    {
      'idx': 3,
      'language_code': 'es',
      'name': 'Español',
      'flag': '🇪🇸',
      'display_order': 999,
      'is_active': false,
      'is_rtl': false,
    },
    {
      'idx': 4,
      'language_code': 'fi',
      'name': 'Suomi',
      'flag': '🇫🇮',
      'display_order': 999,
      'is_active': false,
      'is_rtl': false,
    },
    {
      'idx': 7,
      'language_code': 'ja',
      'name': '日本語',
      'flag': '🇯🇵',
      'display_order': 999,
      'is_active': false,
      'is_rtl': false,
    },
    {
      'idx': 8,
      'language_code': 'ko',
      'name': '한국어',
      'flag': '🇰🇷',
      'display_order': 999,
      'is_active': false,
      'is_rtl': false,
    },
    {
      'idx': 9,
      'language_code': 'nl',
      'name': 'Nederlands',
      'flag': '🇳🇱',
      'display_order': 999,
      'is_active': false,
      'is_rtl': false,
    },
    {
      'idx': 11,
      'language_code': 'pl',
      'name': 'Polski',
      'flag': '🇵🇱',
      'display_order': 999,
      'is_active': false,
      'is_rtl': false,
    },
    {
      'idx': 13,
      'language_code': 'uk',
      'name': 'Українська',
      'flag': '🇺🇦',
      'display_order': 999,
      'is_active': false,
      'is_rtl': false,
    },
    {
      'idx': 14,
      'language_code': 'zh',
      'name': '中文',
      'flag': '🇨🇳',
      'display_order': 999,
      'is_active': false,
      'is_rtl': false,
    },
  ];

  // --- Main Logic ---

  // Filter active languages
  final activeLanguages =
      allLanguages.where((lang) => lang['is_active'] == true).toList();

  // Sort by display order (lower numbers first)
  activeLanguages.sort(
    (a, b) => (a['display_order'] as int).compareTo(b['display_order'] as int),
  );

  // Transform to UI-friendly format: "Flag Name" + code
  return activeLanguages
      .map((lang) => {
            'label': '${lang['flag']} ${lang['name']}',
            'code': lang['language_code'],
          })
      .toList();
}

String? convertAndFormatPrice(
  double basePrice,
  String originalCurrencyCode,
  double exchangeRate,
  String targetCurrencyCode,
) {
  /// Converts and formats a single price with currency conversion and localized formatting.
  ///
  /// Used in the "MenuDishesListView" widget to display prices in the user's preferred currency.
  /// Handles currency conversion using exchange rates and formats according to currency-specific rules.
  ///
  /// Args:
  ///  basePrice: Price in original currency
  ///  originalCurrencyCode: ISO 4217 currency code of the original price
  ///  exchangeRate: Exchange rate from original to target currency
  ///  targetCurrencyCode: ISO 4217 currency code for output
  ///
  /// Returns:
  ///  Formatted price string with appropriate currency symbol, decimals, and placement

  // ============================================================================
  // HELPER FUNCTIONS
  // ============================================================================

  /// Gets format pattern based on decimal places
  String _getFormatPattern(int decimals) {
    switch (decimals) {
      case 0:
        return '###,###';
      case 1:
        return '###,##0.0';
      case 2:
        return '###,##0.00';
      default:
        return '###,###';
    }
  }

  // ============================================================================
  // MAIN LOGIC
  // ============================================================================

  // Validate inputs
  if (basePrice < 0 || exchangeRate <= 0) return null;

  // Normalize currency codes
  final targetCode = targetCurrencyCode.toUpperCase();
  final originalCode = originalCurrencyCode.toUpperCase();

  // Convert price (skip conversion if same currency)
  final convertedPrice =
      originalCode == targetCode ? basePrice : basePrice * exchangeRate;

  // Get currency formatting rules from central function
  final rulesJson = getCurrencyFormattingRules(targetCode);

  if (rulesJson == null) return null;

  // Parse JSON rules
  final Map<String, dynamic> rules;
  try {
    rules = jsonDecode(rulesJson);
  } catch (e) {
    return null; // Failed to parse rules
  }

  final symbol = rules['symbol'] as String;
  final isPrefix = rules['isPrefix'] as bool;
  final decimals = rules['decimals'] as int;

  // Format price based on decimal places
  final pattern = _getFormatPattern(decimals);
  final formattedPrice = decimals == 0
      ? NumberFormat(pattern).format(convertedPrice.round())
      : NumberFormat(pattern).format(convertedPrice);

  // Build output string based on symbol placement
  return isPrefix ? '$symbol$formattedPrice' : '$formattedPrice $symbol';
}

double dishBottomSheetMinHeight(
  double screenHeight,
  List<int>? dietaryDescription,
  String? dishDescription,
  bool hasImage,
) {
  /// Calculates minimum collapsed height for dish bottom sheet.
  ///
  /// Determines initial bottom sheet height based on content (image, descriptions, dietary info)
  /// to show key information without scrolling, while capping at a maximum percentage.
  ///
  /// Args:
  ///  screenHeight: Total screen height in pixels
  ///  dietaryDescription: Optional list of dietary preference IDs
  ///  dishDescription: Optional dish description text
  ///  hasImage: Whether dish has an image to display
  ///
  /// Returns:
  ///  Minimum height in pixels, capped at 65% of screen height

  // --- Constants ---

  const baseHeightFactor = 0.60; // Base height (60% of screen)
  const maxHeightFactor = 0.65; // Maximum height cap (65% of screen)
  const imageHeight = 200.0; // Fixed height for image
  const textHeightPerChar = 0.3; // Estimated height per character
  const dietaryWithItemsHeight = 25.0; // Height when dietary items present
  const dietaryEmptyHeight = 50.0; // Height when no dietary items

  // --- Calculate Heights ---

  // Base height for essential elements (title, rating, etc.)
  final baseHeight = screenHeight * baseHeightFactor;

  // Image height if present
  final imageSpace = hasImage ? imageHeight : 0.0;

  // Dish description height estimate
  final descriptionHeight = (dishDescription?.length ?? 0) * textHeightPerChar;

  // Dietary section height
  final hasDietaryItems =
      dietaryDescription != null && dietaryDescription.isNotEmpty;
  final dietaryHeight =
      hasDietaryItems ? dietaryWithItemsHeight : dietaryEmptyHeight;

  // Calculate total height
  final totalHeight =
      baseHeight + imageSpace + descriptionHeight + dietaryHeight;

  // Cap at maximum height
  return math.min(totalHeight, screenHeight * maxHeightFactor);
}

double dishBottomSheetMaxHeight(
  String? dishDescription,
  double screenHeight,
  bool hasImage,
  List<int>? dietaryDescription,
) {
  /// Calculates maximum expanded height for dish bottom sheet.
  ///
  /// Determines fully expanded bottom sheet height to fit all content including
  /// header, description, image, dietary info, and expandable disclaimer.
  ///
  /// Args:
  ///  dishDescription: Optional dish description text
  ///  screenHeight: Total screen height in pixels
  ///  hasImage: Whether dish has an image to display
  ///  dietaryDescription: Optional list of dietary preference IDs
  ///
  /// Returns:
  ///  Maximum height in pixels, capped at 90% of screen height

  // --- Constants ---

  const baseHeightFactor = 0.60; // Base height (60% of screen)
  const maxHeightFactor = 0.90; // Maximum height cap (90% of screen)
  const imageHeight = 200.0; // Fixed height for image
  const textHeightPerChar = 0.35; // Estimated height per character
  const dietaryWithItemsHeight = 25.0; // Height when dietary items present
  const dietaryEmptyHeight = 50.0; // Height when no dietary items
  const expandableHeight = 90.0; // Fixed height for disclaimer section

  // --- Calculate Heights ---

  // Base height for header, title, and rating
  final baseHeight = screenHeight * baseHeightFactor;

  // Dish description height estimate
  final descriptionHeight = (dishDescription?.length ?? 0) * textHeightPerChar;

  // Image height if present
  final imageSpace = hasImage ? imageHeight : 0.0;

  // Dietary section height
  final hasDietaryItems =
      dietaryDescription != null && dietaryDescription.isNotEmpty;
  final dietaryHeight =
      hasDietaryItems ? dietaryWithItemsHeight : dietaryEmptyHeight;

  // Calculate total height including expandable disclaimer
  final totalHeight = baseHeight +
      descriptionHeight +
      imageSpace +
      dietaryHeight +
      expandableHeight;

  // Cap at maximum height
  return math.min(totalHeight, screenHeight * maxHeightFactor);
}

String getDietaryAndAllergyTitleTranslations(
  String key,
  String languageCode,
) {
  /// Returns localized translations for dietary and allergen section headers/disclaimers.
  ///
  /// Args:
  ///  key: Translation key identifier
  ///  languageCode: ISO language code for localization
  ///
  /// Returns:
  ///  Localized translation string, falling back to English then key itself

  const staticTranslations = {
    'additional_info_header': {
      'en': 'Additional Information',
      'da': 'Yderligere Information',
      'de': 'Weitere Informationen',
      'fr': 'Informations Complémentaires',
      'it': 'Informazioni aggiuntive',
      'no': 'Tilleggsinformasjon',
      'sv': 'Ytterligare Information',
    },
    'dietary_header': {
      'en': 'Dietary preferences and restrictions',
      'da': 'Kostpræferencer og restriktioner',
      'de': 'Ernährungspräferenzen und -einschränkungen',
      'fr': 'Préférences et restrictions alimentaires',
      'it': 'Preferenze e restrizioni dietetiche',
      'no': 'Kostholdsreferanser og restriksjoner',
      'sv': 'Kostpreferenser och restriktioner',
    },
    'allergens_header': {
      'en': 'Allergens',
      'da': 'Allergener',
      'de': 'Allergene',
      'fr': 'Allergènes',
      'it': 'Allergeni',
      'no': 'Allergener',
      'sv': 'Allergener',
    },
    'information_source_header': {
      'en': 'Information source',
      'da': 'Informationskilde',
      'de': 'Informationsquelle',
      'fr': 'Source d\'information',
      'it': 'Fonte di informazione',
      'no': 'Informasjonskilde',
      'sv': 'Informationskälla',
    },
    'information_disclaimer': {
      'en':
          'Ingredient, allergy and dietary information provided by [businessName]. Always verify with staff before ordering as ingredients may change and cross-contamination can occur.',
      'da':
          'Ingrediens- og diætoplysninger leveret af [businessName]. Verificer altid med personalet før bestilling, da ingredienser kan ændre sig og krydskontaminering kan forekomme.',
      'de':
          'Informationen zu Inhaltsstoffen, Allergien und Ernährung bereitgestellt von [businessName]. Verifizieren Sie vor der Bestellung immer mit den Mitarbeitern, da sich Inhaltsstoffe ändern können und Kreuzkontaminationen auftreten können.',
      'fr':
          'Informations sur les ingrédients, les allergies et le régime alimentaire fournies par [businessName]. Toujours vérifier auprès du personnel avant de commander, car les ingrédients peuvent changer et une contamination croisée peut se produire.',
      'it':
          'Informazioni su ingredienti, allergie e dieta fornite da [businessName]. Verificare sempre con il personale prima di ordinare poiché gli ingredienti possono cambiare e può verificarsi una contaminazione incrociata.',
      'no':
          'Ingrediens-, allergi- og diettinformasjon levert av [businessName]. Verifiser alltid med personalet før du bestiller, da ingredienser kan endre seg og krysskontaminering kan oppstå.',
      'sv':
          'Ingrediens-, allergi- och kostinformation tillhandahållen av [businessName]. Verifiera alltid med personalen innan du beställer, eftersom ingredienser kan ändras och korskontaminering kan uppstå.',
    },
    'journeymate_disclaimer': {
      'en':
          'JourneyMate does its best to verify this information but cannot be held responsible for its accuracy.',
      'da':
          'JourneyMate gør sit bedste for at verificere disse oplysninger, men kan ikke holdes ansvarlig for deres nøjagtighed.',
      'de':
          'JourneyMate bemüht sich, diese Informationen zu verifizieren, kann jedoch nicht für deren Richtigkeit haftbar gemacht werden.',
      'fr':
          'JourneyMate fait de son mieux pour vérifier ces informations, mais ne peut être tenu responsable de leur exactitude.',
      'it':
          'JourneyMate fa del suo meglio per verificare queste informazioni, ma non può essere ritenuto responsabile della loro accuratezza.',
      'no':
          'JourneyMate gjør sitt beste for å verifisere denne informasjonen, men kan ikke holdes ansvarlig for nøyaktigheten.',
      'sv':
          'JourneyMate gör sitt bästa för att verifiera den här informationen, men kan inte hållas ansvarig för dess riktighet.',
    },
  };

  final lang = languageCode.toLowerCase();
  final translations = staticTranslations[key];

  // Return translation for language, fallback to English, then key
  return translations?[lang] ?? translations?['en'] ?? key;
}

String streetAndNeighbourhoodLength(
  String neighbourhood,
  String streetName,
) {
  /// Formats street address with neighbourhood based on street name length.
  ///
  /// Determines whether to show full neighbourhood, abbreviated version, or omit it
  /// based on street name length to fit UI constraints. Copenhagen neighbourhoods
  /// have abbreviated alternatives; others are omitted if street name is too long.
  ///
  /// Args:
  ///  neighbourhood: Full neighbourhood name
  ///  streetName: Street name and number
  ///
  /// Returns:
  ///  Formatted address string with appropriate neighbourhood handling

  // --- Configuration ---

  /// Copenhagen neighbourhoods with abbreviated alternatives
  const neighbourhoodAbbreviations = {
    'Carlsberg Byen': 'Kbh V',
    'Christianshavn': 'Kbh K',
    'Grøndal': 'Kbh N',
    'Indre by': 'Kbh K',
    'Islands brygge': 'Kbh S',
    'Kongens Nytorv': 'Kbh K',
    'Nordhavn': 'Kbh Ø',
    'Nordvest': 'Kbh N',
    'Nyhavn': 'Kbh K',
    'Nørrebro': 'Kbh N',
    'Sydhavnen': 'Kbh S',
    'Vesterbro': 'Kbh V',
    'Østerbro': 'Kbh Ø',
  };

  /// Neighbourhoods without abbreviations (omitted if street too long)
  const neighbourhoodsWithoutAbbreviations = {
    'Amager',
    'Bispebjerg',
    'Brønshøj-Husum',
    'Frederiksberg',
    'Valby',
    'Vanløse',
    'Ørestad',
  };

  /// Length thresholds for formatting decisions
  const lengthForAbbreviation = 20;
  const lengthForOmission = 27;

  // --- Main Logic ---

  final streetLength = streetName.length;

  // Neighbourhoods with abbreviations
  if (neighbourhoodAbbreviations.containsKey(neighbourhood)) {
    if (streetLength >= lengthForOmission) {
      return streetName; // Street only
    } else if (streetLength >= lengthForAbbreviation) {
      return '$streetName, ${neighbourhoodAbbreviations[neighbourhood]}'; // Abbreviated
    } else {
      return '$streetName, $neighbourhood'; // Full
    }
  }

  // Neighbourhoods without abbreviations
  if (neighbourhoodsWithoutAbbreviations.contains(neighbourhood)) {
    return streetLength >= lengthForAbbreviation
        ? streetName // Street only
        : '$streetName, $neighbourhood'; // Full
  }

  // Unknown neighbourhoods - always show full
  return '$streetName, $neighbourhood';
}

String? getCurrencyFormattingRules(String currencyCode) {
  /// Returns the formatting rules (symbol, placement, decimals) for a given currency code.
  ///
  /// This function acts as the central source of truth for all currency display rules.
  ///
  /// Args:
  ///   currencyCode: The ISO 4217 currency code (e.g., 'DKK', 'EUR').
  ///
  /// Returns:
  ///   A JSON string containing 'symbol' (String), 'isPrefix' (bool), and 'decimals' (int).

  const Map<String, Map<String, dynamic>> currencyFormattingRules = {
    'CNY': {'symbol': '¥', 'isPrefix': true, 'decimals': 0},
    'DKK': {'symbol': 'kr.', 'isPrefix': false, 'decimals': 0},
    'EUR': {'symbol': '€', 'isPrefix': true, 'decimals': 2},
    'GBP': {'symbol': '£', 'isPrefix': true, 'decimals': 1},
    'JPY': {'symbol': '¥', 'isPrefix': false, 'decimals': 0},
    'KRW': {'symbol': '₩', 'isPrefix': false, 'decimals': 0},
    'NOK': {'symbol': 'kr.', 'isPrefix': false, 'decimals': 0},
    'PLN': {'symbol': 'zł', 'isPrefix': false, 'decimals': 0},
    'SEK': {'symbol': 'kr.', 'isPrefix': false, 'decimals': 0},
    'UAH': {'symbol': '₴', 'isPrefix': false, 'decimals': 0},
    'USD': {'symbol': '\$', 'isPrefix': true, 'decimals': 2},
  };

  const Map<String, dynamic> defaultCurrencyRule = {
    'symbol': 'kr.',
    'isPrefix': false,
    'decimals': 0,
  };

  // Normalize the input code to uppercase
  final code = currencyCode.toUpperCase();

  // Get the rule or use default
  final rule = currencyFormattingRules[code] ?? defaultCurrencyRule;

  // Return as JSON string for FlutterFlow compatibility
  return jsonEncode(rule);
}

List<dynamic>? getVariationModifiers(dynamic itemData) {
  /// Extracts variation modifiers from item data for display
  ///
  /// Args:
  ///   itemData: The complete item JSON with modifier groups
  ///
  /// Returns:
  ///   List of modifier objects with name, price, etc., or null if no variations

  if (itemData is! Map) return null;

  final modifierGroups = itemData['item_modifier_groups'] as List?;
  if (modifierGroups == null || modifierGroups.isEmpty) return null;

  // Find the variation-type modifier group
  for (final group in modifierGroups) {
    if (group is Map && group['type'] == 'Variation') {
      final modifiers = group['modifiers'] as List?;
      if (modifiers != null && modifiers.isNotEmpty) {
        return modifiers;
      }
    }
  }

  return null;
}

String getTranslations(
  String languageCode,
  String translationKey,
  dynamic translationsCache,
) {
  /// Retrieves a localized translation string from the cache.
  ///
  /// Returns the translated value for the given key and language,
  /// with graceful fallback behavior when translations are missing.
  ///
  /// Args:
  ///   languageCode: ISO 639-1 language code (e.g., 'en', 'da')
  ///   translationKey: The key to look up (e.g., 'filter_location')
  ///   translationsCache: Cache object from FFAppState
  ///
  /// Returns:
  ///   The translated string, or a fallback value if not found

  // Guard: Validate inputs
  if (languageCode.isEmpty) {
    debugPrint('⚠️ getTranslations: Empty language code');
    return translationKey;
  }

  if (translationKey.isEmpty) {
    debugPrint('⚠️ getTranslations: Empty translation key');
    return '';
  }

  // Guard: Check if cache exists
  if (translationsCache == null) {
    debugPrint('⚠️ Translation cache is null for key: $translationKey');
    return '';
  }

  try {
    // Handle different possible cache structures
    Map<String, dynamic> translationsMap;

    if (translationsCache is String) {
      // Cache might be a JSON string
      translationsMap = json.decode(translationsCache) as Map<String, dynamic>;
    } else if (translationsCache is Map<String, dynamic>) {
      // Cache is already a map
      translationsMap = translationsCache;
    } else {
      debugPrint(
          '⚠️ Unexpected cache type: ${translationsCache.runtimeType}\n   Key: $translationKey');
      return '';
    }

    // Look up the translation
    final translation = translationsMap[translationKey];

    if (translation == null) {
      debugPrint(
          'Translation missing: $languageCode.$translationKey\n   Cache contains ${translationsMap.length} keys\n   Sample keys: ${translationsMap.keys.take(5).toList()}');
      return '';
    }

    // Return the translation as a string
    return translation.toString();
  } catch (e) {
    debugPrint('❌ Error retrieving translation:\n'
        '   Language: $languageCode\n'
        '   Key: $translationKey\n'
        '   Error: $e');
    // Fallback: Convert snake_case to Title Case
    return translationKey
        .split('_')
        .map((word) =>
            word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}

int getSessionDurationSeconds(DateTime sessionStartTime) {
  return DateTime.now().difference(sessionStartTime).inSeconds;
}

dynamic buildFilterAppliedEventData(
  String filterSessionId,
  List<int> currentFilters,
  String? currentSearchText,
  dynamic searchResults,
  bool filterOverlayWasOpen,
  List<int> previousFilters,
  String? previousSearchText,
  int refinementSequence,
  DateTime? lastRefinementTime,
) {
  /// Builds comprehensive analytics event data for filter application tracking.
  ///
  /// Analyzes the difference between current and previous filter/search states
  /// to categorize the type of change (added, removed, modified, cleared) and
  /// extracts relevant metadata from search results.
  ///
  /// Args:
  ///   filterSessionId: Unique identifier for current filter session
  ///   currentFilters: List of currently active filter IDs
  ///   currentSearchText: Current search query (null/empty if none)
  ///   searchResults: Full API response containing {documents, resultCount, activeids}
  ///   filterOverlayWasOpen: Whether filter overlay was visible when applied
  ///   previousFilters: List of previously active filter IDs
  ///   previousSearchText: Previous search query (null/empty if none)
  ///   refinementSequence: Sequential number of refinements in session
  ///   lastRefinementTime: Timestamp of previous refinement (null if first)
  ///
  /// Returns:
  ///   Map containing event data for analytics tracking

  // Normalize null/empty strings
  final currentSearch =
      currentSearchText?.isEmpty ?? true ? null : currentSearchText;
  final previousSearch =
      previousSearchText?.isEmpty ?? true ? null : previousSearchText;

  // Detect added filters
  final addedFilters =
      currentFilters.where((f) => !previousFilters.contains(f)).toList();

  // Detect removed filters
  final removedFilters =
      previousFilters.where((f) => !currentFilters.contains(f)).toList();

  // Determine change type
  String changeType;
  if (currentFilters.isEmpty && previousFilters.isNotEmpty) {
    changeType = 'cleared';
  } else if (currentFilters.isEmpty && previousFilters.isEmpty) {
    changeType = 'unchanged';
  } else if (addedFilters.isNotEmpty && removedFilters.isEmpty) {
    changeType = 'added';
  } else if (removedFilters.isNotEmpty && addedFilters.isEmpty) {
    changeType = 'removed';
  } else if (addedFilters.isNotEmpty && removedFilters.isNotEmpty) {
    changeType = 'modified';
  } else {
    changeType = 'unchanged';
  }

  // Check if search text changed
  final searchTextChanged = currentSearch != previousSearch;

  // Extract business IDs from search results (NULL SAFE)
  final List<int> businessIds = [];
  if (searchResults != null && searchResults['documents'] is List) {
    for (var doc in searchResults['documents']) {
      if (doc['business_id'] != null) {
        businessIds.add(doc['business_id'] as int);
      }
    }
  }

  // Get results count (NULL SAFE)
  final resultsCount = searchResults?['resultCount'] ?? 0;

  // Calculate time since previous refinement
  int? timeSincePreviousRefinement;
  if (lastRefinementTime != null) {
    timeSincePreviousRefinement =
        DateTime.now().difference(lastRefinementTime).inSeconds;
  }

  return {
    'filterSessionId': filterSessionId,
    'refinementSequence': refinementSequence,

    // Current state
    'filters': currentFilters,
    'searchText': currentSearch,
    'resultsCount': resultsCount,
    'returnedBusinessIds': businessIds,
    'isZeroResults': resultsCount == 0,

    // Previous state
    'previousFilters': previousFilters,
    'previousSearchText': previousSearch,

    // Change detection
    'changeType': changeType,
    'addedFilters': addedFilters,
    'removedFilters': removedFilters,
    'searchTextChanged': searchTextChanged,

    // Context
    'filterOverlayWasOpen': filterOverlayWasOpen,
    'timeSincePreviousRefinement': timeSincePreviousRefinement,
  };
}

bool hasActiveFilters(
  int? selectedDietaryTypeId,
  List<int>? excludedAllergyIds,
) {
  /// Determines if any menu filters are currently active.
  ///
  /// Checks both filter types:
  /// - Dietary type (preferences: vegan/vegetarian/pescetarian OR
  ///   restrictions: gluten-free/lactose-free/halal/kosher)
  /// - Allergen exclusions (any of the 14 allergen types)
  ///
  /// Note: Dietary preferences and restrictions are mutually exclusive in the UI
  /// but share the same underlying dietary_type_id system, so they're tracked
  /// by a single ID parameter.
  ///
  /// Args:
  ///   selectedDietaryTypeId: Currently selected preference or restriction ID, or null
  ///   excludedAllergyIds: List of excluded allergen IDs, or null/empty
  ///
  /// Returns:
  ///   bool: true if any filter is active, false if all filters are cleared

  // Check dietary type filter (preference OR restriction)
  final hasDietaryType = selectedDietaryTypeId != null;

  // Check allergen exclusion filters
  final hasAllergenExclusions =
      excludedAllergyIds != null && excludedAllergyIds.isNotEmpty;

  // Return true if ANY filter is active
  return hasDietaryType || hasAllergenExclusions;
}

bool hasLocationPermission(LatLng? currentDeviceLocation) {
  /// FlutterFlow's currentDeviceLocation returns (0,0) when:
  /// - Permission was never granted
  /// - Permission was revoked
  /// - Location services are disabled
  ///
  /// Returns real coordinates when permission is granted.
  ///
  /// Args:
  ///   currentDeviceLocation: The device's current location from FlutterFlow
  ///
  /// Returns:
  ///   true if location permission is granted (non-zero coordinates)
  ///   false if permission is denied or location unavailable (0,0 coordinates)

  // Handle null case (location unavailable)
  if (currentDeviceLocation == null) {
    return false;
  }

  // Check if coordinates are (0, 0) - indicates no permission
  // Using small epsilon for floating point comparison
  const epsilon = 0.0001;

  final isZeroLat = currentDeviceLocation.latitude.abs() < epsilon;
  final isZeroLng = currentDeviceLocation.longitude.abs() < epsilon;

  // If both are zero, no permission
  if (isZeroLat && isZeroLng) {
    return false;
  }

  // Has real coordinates = has permission
  return true;
}

String? getSnackbarMessage(
  String messageType,
  String formType,
  String currentLanguage,
  dynamic translationsCache,
) {
  String translationKey;

  if (messageType == 'error') {
    translationKey = 'snackbar_error';
  } else if (messageType == 'success') {
    if (formType == 'feedback') {
      translationKey = 'snackbar_feedback_success';
    } else if (formType == 'contact') {
      translationKey = 'snackbar_contact_success';
    } else if (formType == 'missing_location') {
      translationKey = 'snackbar_missing_location_success';
    } else if (formType == 'erroneous_info') {
      translationKey = 'snackbar_erroneous_info_success';
    } else {
      return 'Invalid form type';
    }
  } else {
    return 'Invalid message type';
  }

  return getTranslations(
    currentLanguage,
    translationKey,
    translationsCache,
  );
}
