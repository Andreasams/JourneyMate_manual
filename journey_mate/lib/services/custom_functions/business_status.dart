import 'package:flutter/material.dart';

/// Determines the current business status (open/closed/opening soon/closing soon)
/// and returns the appropriate status text and color.
///
/// Analyzes business hours to determine current status, handling complex scenarios:
/// - Up to 5 time slots per day
/// - Overnight hours (e.g., 22:00 to 02:00)
/// - Days marked as closed or by_appointment_only
/// - "Soon" thresholds (30 minutes before opening/closing)
/// - Seven-day weekly schedules
///
/// Args:
///   businessHoursInput: Map containing weekly business hours (keys are day numbers 0-6)
///   currentDateTime: The current date and time for status calculation
///   languageCode: Language code for translated status text (defaults to 'en')
///   translationsCache: Translation cache for localized messages
///
/// Returns:
///   Map with 'text' (String status) and 'color' (Color indicator)
///   - Green: Currently open (including "closing soon")
///   - Red: Currently closed (including "opening soon")
Map<String, dynamic> determineStatusAndColor(
  dynamic businessHoursInput,
  DateTime currentDateTime,
  String? languageCode,
  dynamic translationsCache,
) {
  const soonThresholdMinutes = 30;
  const openColor = Color(0xFF1a9456); // AppColors.success
  const closedColor = Color(0xFFFF5963); // AppColors.error

  final effectiveLanguageCode = languageCode ?? 'en';

  // Helper: Get localized message
  String getLocalizedMessage(String key, String defaultValue) {
    final lang = effectiveLanguageCode.toLowerCase();
    final translations = {
      'status_open': {'en': 'Open', 'da': 'Åben'},
      'status_closed': {'en': 'Closed', 'da': 'Lukket'},
      'status_opening_soon': {'en': 'Opening soon', 'da': 'Åbner snart'},
      'status_closing_soon': {'en': 'Closing soon', 'da': 'Lukker snart'},
    };
    return translations[key]?[lang] ?? defaultValue;
  }

  // Guard: Validate inputs
  if (businessHoursInput == null || businessHoursInput is! Map) {
    return {
      'text': getLocalizedMessage('status_closed', 'Closed'),
      'color': closedColor,
    };
  }

  // Normalize business hours
  final Map<String, dynamic> businessHours;
  try {
    businessHours = Map<String, dynamic>.from(
      businessHoursInput.map((key, value) => MapEntry(
            key.toString(),
            (value is Map)
                ? Map<String, dynamic>.from(
                    value.map((k, v) => MapEntry(k.toString(), v)))
                : value,
          )),
    );
  } catch (e) {
    return {
      'text': getLocalizedMessage('status_closed', 'Closed'),
      'color': closedColor,
    };
  }

  final currentDay = currentDateTime.weekday - 1; // Monday = 0
  final currentMinutes = currentDateTime.hour * 60 + currentDateTime.minute;
  final previousDay = (currentDay - 1 + 7) % 7;

  // Check if currently open (from today or yesterday's overnight)
  final todayStatus = _checkOpenStatus(businessHours, currentDay, currentMinutes);
  final yesterdayStatus = _checkPreviousDayOvernightStatus(
      businessHours, previousDay, currentMinutes);
  final isCurrentlyOpen = todayStatus['isOpen'] || yesterdayStatus['isOpen'];

  if (isCurrentlyOpen) {
    // Business is open - check if closing soon
    final closingInfo = todayStatus['isOpen']
        ? {'closingTime': todayStatus['nextTime'], 'isOvernight': todayStatus['isOvernightClose']}
        : {'closingTime': yesterdayStatus['nextTime'], 'isOvernight': true};

    final isClosingSoon = _isClosingSoon(closingInfo, currentMinutes, soonThresholdMinutes);

    return {
      'text': getLocalizedMessage(
          isClosingSoon ? 'status_closing_soon' : 'status_open',
          isClosingSoon ? 'Closing soon' : 'Open'),
      'color': openColor,
    };
  }

  // Business is closed - check if opening soon
  final isOpeningSoon = _isOpeningSoon(businessHours, currentDay, currentMinutes, soonThresholdMinutes);

  return {
    'text': getLocalizedMessage(
        isOpeningSoon ? 'status_opening_soon' : 'status_closed',
        isOpeningSoon ? 'Opening soon' : 'Closed'),
    'color': closedColor,
  };
}

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

Map<String, dynamic> _checkOpenStatus(
  Map<String, dynamic> businessHours,
  int day,
  int currentMinutes,
) {
  const maxTimeSlotsPerDay = 5;
  const defaultResult = {
    'isOpen': false,
    'nextTime': null,
    'isOvernightClose': false,
  };

  final dayKey = day.toString();
  if (!businessHours.containsKey(dayKey) || businessHours[dayKey] is! Map) {
    return defaultResult;
  }

  final dayHours = businessHours[dayKey] as Map<String, dynamic>;
  if (_isDayClosedForStatus(dayHours)) return defaultResult;

  for (int slot = 1; slot <= maxTimeSlotsPerDay; slot++) {
    final openingStr = dayHours['opening_time_$slot'] as String?;
    final closingStr = dayHours['closing_time_$slot'] as String?;

    if (openingStr == null || closingStr == null) continue;

    final openingMinutes = _convertTimeToMinutes(openingStr);
    final closingMinutes = _convertTimeToMinutes(closingStr);

    if (openingMinutes == -1 || closingMinutes == -1) continue;

    final isOvernight = closingMinutes < openingMinutes ||
        closingMinutes == 1440 ||
        (closingMinutes == 0 && openingMinutes > 0);

    final isOpen = isOvernight
        ? (currentMinutes >= openingMinutes || currentMinutes < closingMinutes)
        : (currentMinutes >= openingMinutes && currentMinutes < closingMinutes);

    if (isOpen) {
      return {
        'isOpen': true,
        'nextTime': closingStr.substring(0, 5),
        'isOvernightClose': isOvernight,
      };
    }
  }

  return defaultResult;
}

Map<String, dynamic> _checkPreviousDayOvernightStatus(
  Map<String, dynamic> businessHours,
  int previousDay,
  int currentMinutes,
) {
  const maxTimeSlotsPerDay = 5;
  const defaultResult = {'isOpen': false, 'nextTime': null};

  final dayKey = previousDay.toString();
  if (!businessHours.containsKey(dayKey) || businessHours[dayKey] is! Map) {
    return defaultResult;
  }

  final dayHours = businessHours[dayKey] as Map<String, dynamic>;
  if (_isDayClosedForStatus(dayHours)) return defaultResult;

  for (int slot = 1; slot <= maxTimeSlotsPerDay; slot++) {
    final openingStr = dayHours['opening_time_$slot'] as String?;
    final closingStr = dayHours['closing_time_$slot'] as String?;

    if (openingStr == null || closingStr == null) continue;

    final openingMinutes = _convertTimeToMinutes(openingStr);
    final closingMinutes = _convertTimeToMinutes(closingStr);

    if (openingMinutes == -1 || closingMinutes == -1) continue;

    final wasOvernight = closingMinutes < openingMinutes ||
        (closingMinutes == 0 && openingMinutes > 0) ||
        (closingMinutes == 1440);

    if (wasOvernight && currentMinutes < closingMinutes) {
      return {
        'isOpen': true,
        'nextTime': closingStr.substring(0, 5),
      };
    }
  }

  return defaultResult;
}

bool _isDayClosedForStatus(Map<String, dynamic> dayHours) {
  return _parseBoolValue(dayHours['closed']) ||
      _parseBoolValue(dayHours['by_appointment_only']);
}

bool _parseBoolValue(dynamic value) {
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return false;
}

int _convertTimeToMinutes(String? timeString) {
  if (timeString == null || timeString.isEmpty) return -1;

  try {
    final parts = timeString.split(':');
    if (parts.length < 2) return -1;

    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);

    if (hours == 24 && minutes == 0) return 1440;
    if (hours < 0 || hours >= 24 || minutes < 0 || minutes >= 60) return -1;

    return hours * 60 + minutes;
  } catch (e) {
    return -1;
  }
}

bool _isClosingSoon(
  Map<String, dynamic> closingInfo,
  int currentMinutes,
  int thresholdMinutes,
) {
  final closingTimeStr = closingInfo['closingTime'];
  if (closingTimeStr == null) return false;

  final closeMinutes = _convertTimeToMinutes(closingTimeStr);
  if (closeMinutes == -1) return false;

  final minutesUntilClosing = closingInfo['isOvernight'] == true
      ? (currentMinutes < closeMinutes
          ? closeMinutes - currentMinutes
          : (closeMinutes + 1440) - currentMinutes)
      : closeMinutes - currentMinutes;

  return minutesUntilClosing >= 0 && minutesUntilClosing <= thresholdMinutes;
}

bool _isOpeningSoon(
  Map<String, dynamic> businessHours,
  int currentDay,
  int currentMinutes,
  int thresholdMinutes,
) {
  final nextOpening = _findNextOpeningTime(businessHours, currentDay, currentMinutes);

  if (nextOpening['offsetDays'] != 0) return false;

  final nextOpenMinutes = _convertTimeToMinutes(nextOpening['time']);
  if (nextOpenMinutes == -1) return false;

  final minutesUntilOpening = nextOpenMinutes - currentMinutes;
  return minutesUntilOpening > 0 && minutesUntilOpening <= thresholdMinutes;
}

Map<String, dynamic> _findNextOpeningTime(
  Map<String, dynamic> businessHours,
  int startDay,
  int currentMinutes,
) {
  const maxTimeSlotsPerDay = 5;

  for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
    final checkDay = (startDay + dayOffset) % 7;
    final dayKey = checkDay.toString();

    if (!businessHours.containsKey(dayKey) || businessHours[dayKey] is! Map) {
      continue;
    }

    final dayHours = businessHours[dayKey] as Map<String, dynamic>;
    if (_isDayClosedForStatus(dayHours)) continue;

    for (int slot = 1; slot <= maxTimeSlotsPerDay; slot++) {
      final openingStr = dayHours['opening_time_$slot'] as String?;
      if (openingStr == null) continue;

      final openingMinutes = _convertTimeToMinutes(openingStr);
      if (openingMinutes == -1) continue;

      if (dayOffset > 0 || openingMinutes > currentMinutes) {
        return {
          'time': openingStr.substring(0, 5),
          'offsetDays': dayOffset,
        };
      }
    }
  }

  return {'time': 'N/A', 'offsetDays': -1};
}
