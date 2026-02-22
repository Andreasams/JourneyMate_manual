import 'dart:ui' show Color;

/// Analyzes business hours to determine real-time open/closed status and sets status indicator colors.
///
/// Handles sophisticated scheduling scenarios including multiple daily time slots, overnight hours,
/// appointment-only periods, and "soon" thresholds (30 minutes).
///
/// Args:
///   statuscolor: Callback to set status indicator color
///   businessHoursInput: Business hours map (see structure below)
///   currentDateTime: Current date/time for status calculation
///   languageCode: ISO 639-1 language code (defaults to 'en')
///   translationsCache: Translation cache from app state
///
/// Returns:
///   Translated status text: "Open", "Closed", "Opening soon", "Closing soon"
Future<String> determineStatusAndColor(
  Future<void> Function(Color color) statuscolor,
  dynamic businessHoursInput,
  DateTime currentDateTime,
  String? languageCode,
  dynamic translationsCache,
) async {
  // Constants
  const int soonThresholdMinutes = 30;
  const int maxTimeSlotsPerDay = 5;
  const Color openColor = Color(0xFF518751); // Green
  const Color closedColor = Color(0xFFFF5963); // Red

  // Helper: Get localized message
  String getLocalizedMessage(String key, String defaultValue) {
    // TODO: Implement translation cache lookup
    // For now, return default values based on language
    final lang = languageCode?.toLowerCase() ?? 'en';

    final translations = {
      'status_open': {'en': 'Open', 'da': 'Åben'},
      'status_closed': {'en': 'Closed', 'da': 'Lukket'},
      'status_opening_soon': {'en': 'Opening soon', 'da': 'Åbner snart'},
      'status_closing_soon': {'en': 'Closing soon', 'da': 'Lukker snart'},
    };

    return translations[key]?[lang] ?? defaultValue;
  }

  // Helper: Convert time string to minutes
  int convertTimeToMinutes(String? time) {
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

  // Helper: Parse bool
  bool parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  // Helper: Check if day is closed
  bool isDayClosed(Map<String, dynamic> dayHours) {
    return parseBool(dayHours['closed']) ||
        parseBool(dayHours['by_appointment_only']);
  }

  // Helper: Check if overnight time slot
  bool isOvernightTimeSlot(int openMinutes, int closeMinutes) {
    return closeMinutes < openMinutes ||
        closeMinutes == 1440 ||
        (closeMinutes == 0 && openMinutes > 0);
  }

  // Helper: Check if currently in time slot
  bool isCurrentlyInTimeSlot(
    int currentMinutes,
    int openMinutes,
    int closeMinutes,
    bool isOvernight,
  ) {
    if (isOvernight) {
      return currentMinutes >= openMinutes || currentMinutes < closeMinutes;
    } else {
      return currentMinutes >= openMinutes && currentMinutes < closeMinutes;
    }
  }

  // Helper: Get time slot info
  Map<String, dynamic>? getTimeSlot(Map<String, dynamic> dayHours, int slot) {
    final openKey = 'opening_time_$slot';
    final closeKey = 'closing_time_$slot';

    final openTimeStr = dayHours[openKey]?.toString();
    final closeTimeStr = dayHours[closeKey]?.toString();

    if (openTimeStr == null || closeTimeStr == null) return null;

    final openMinutes = convertTimeToMinutes(openTimeStr);
    final closeMinutes = convertTimeToMinutes(closeTimeStr);

    if (openMinutes == -1 || closeMinutes == -1) return null;

    final isOvernight = isOvernightTimeSlot(openMinutes, closeMinutes);

    return {
      'open': openMinutes,
      'close': closeMinutes,
      'closeStr': closeTimeStr,
      'isOvernight': isOvernight,
    };
  }

  // Helper: Get day hours
  Map<String, dynamic>? getDayHours(
    Map<String, dynamic> businessHours,
    int day,
  ) {
    final dayKey = day.toString();
    final dayHours = businessHours[dayKey];

    if (dayHours == null || dayHours is! Map) return null;

    return Map<String, dynamic>.from(dayHours);
  }

  // Helper: Check open status for today
  Map<String, dynamic> checkOpenStatus(
    Map<String, dynamic> businessHours,
    int day,
    int currentMinutes,
  ) {
    final dayHours = getDayHours(businessHours, day);

    if (dayHours == null || isDayClosed(dayHours)) {
      return {'isOpen': false};
    }

    for (int slot = 1; slot <= maxTimeSlotsPerDay; slot++) {
      final timeSlot = getTimeSlot(dayHours, slot);
      if (timeSlot == null) continue;

      final isOpen = isCurrentlyInTimeSlot(
        currentMinutes,
        timeSlot['open'] as int,
        timeSlot['close'] as int,
        timeSlot['isOvernight'] as bool,
      );

      if (isOpen) {
        return {
          'isOpen': true,
          'nextTime': timeSlot['closeStr'],
          'isOvernightClose': timeSlot['isOvernight'],
          'slotIndex': slot,
        };
      }
    }

    return {'isOpen': false};
  }

  // Helper: Check previous day overnight status
  Map<String, dynamic> checkPreviousDayOvernightStatus(
    Map<String, dynamic> businessHours,
    int previousDay,
    int currentMinutes,
  ) {
    final dayHours = getDayHours(businessHours, previousDay);

    if (dayHours == null || isDayClosed(dayHours)) {
      return {'isOpen': false};
    }

    for (int slot = 1; slot <= maxTimeSlotsPerDay; slot++) {
      final timeSlot = getTimeSlot(dayHours, slot);
      if (timeSlot == null) continue;

      final isOvernight = timeSlot['isOvernight'] as bool;
      if (isOvernight && currentMinutes < (timeSlot['close'] as int)) {
        return {
          'isOpen': true,
          'nextTime': timeSlot['closeStr'],
          'isOvernightClose': true,
        };
      }
    }

    return {'isOpen': false};
  }

  // Helper: Get closing time info
  Map<String, dynamic> getClosingTimeInfo(
    Map<String, dynamic> todayStatus,
    Map<String, dynamic> yesterdayStatus,
  ) {
    if (todayStatus['isOpen'] == true) {
      return {
        'closingTime': todayStatus['nextTime'],
        'isOvernight': todayStatus['isOvernightClose'] ?? false,
      };
    }

    if (yesterdayStatus['isOpen'] == true) {
      return {
        'closingTime': yesterdayStatus['nextTime'],
        'isOvernight': yesterdayStatus['isOvernightClose'] ?? false,
      };
    }

    return {
      'closingTime': null,
      'isOvernight': false,
    };
  }

  // Helper: Calculate minutes until closing
  int calculateMinutesUntilClosing(
    int currentMinutes,
    int closeMinutes,
    bool isOvernight,
  ) {
    if (isOvernight) {
      if (currentMinutes < closeMinutes) {
        return closeMinutes - currentMinutes;
      } else {
        return (closeMinutes + 1440) - currentMinutes;
      }
    } else {
      return closeMinutes - currentMinutes;
    }
  }

  // Helper: Check if closing soon
  bool isClosingSoon(
    Map<String, dynamic> closingInfo,
    int currentMinutes,
    int thresholdMinutes,
  ) {
    final closingTime = closingInfo['closingTime'] as String?;
    if (closingTime == null) return false;

    final closeMinutes = convertTimeToMinutes(closingTime);
    if (closeMinutes == -1) return false;

    final isOvernight = closingInfo['isOvernight'] as bool;
    final minutesUntilClosing = calculateMinutesUntilClosing(
      currentMinutes,
      closeMinutes,
      isOvernight,
    );

    return minutesUntilClosing <= thresholdMinutes && minutesUntilClosing > 0;
  }

  // Helper: Find next opening time
  Map<String, dynamic> findNextOpeningTime(
    Map<String, dynamic> businessHours,
    int startDay,
    int currentMinutes,
  ) {
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final checkDay = (startDay + dayOffset) % 7;
      final dayHours = getDayHours(businessHours, checkDay);

      if (dayHours == null || isDayClosed(dayHours)) continue;

      for (int slot = 1; slot <= maxTimeSlotsPerDay; slot++) {
        final timeSlot = getTimeSlot(dayHours, slot);
        if (timeSlot == null) continue;

        final openMinutes = timeSlot['open'] as int;

        if (dayOffset == 0 && openMinutes <= currentMinutes) {
          continue;
        }

        return {
          'time': '${(openMinutes ~/ 60).toString().padLeft(2, '0')}:${(openMinutes % 60).toString().padLeft(2, '0')}',
          'offsetDays': dayOffset,
        };
      }
    }

    return {
      'time': 'N/A',
      'offsetDays': -1,
    };
  }

  // Helper: Check if opening soon
  bool isOpeningSoon(
    Map<String, dynamic> businessHours,
    int currentDay,
    int currentMinutes,
    int thresholdMinutes,
  ) {
    final nextOpening = findNextOpeningTime(
      businessHours,
      currentDay,
      currentMinutes,
    );

    final offsetDays = nextOpening['offsetDays'] as int;
    if (offsetDays != 0) return false;

    final nextTime = nextOpening['time'] as String;
    final nextOpenMinutes = convertTimeToMinutes(nextTime);
    if (nextOpenMinutes == -1) return false;

    final minutesUntilOpening = nextOpenMinutes - currentMinutes;
    return minutesUntilOpening <= thresholdMinutes && minutesUntilOpening > 0;
  }

  // Validate input
  bool isValidBusinessHoursInput(dynamic input) {
    return input != null && input is Map;
  }

  // Normalize business hours
  Map<String, dynamic> normalizeBusinessHours(dynamic input) {
    try {
      if (input is Map) {
        return Map<String, dynamic>.from(input);
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  // Main logic
  try {
    if (!isValidBusinessHoursInput(businessHoursInput)) {
      await statuscolor(closedColor);
      return getLocalizedMessage('status_closed', 'Closed');
    }

    final businessHours = normalizeBusinessHours(businessHoursInput);

    if (businessHours.isEmpty) {
      await statuscolor(closedColor);
      return getLocalizedMessage('status_closed', 'Closed');
    }

    final currentDay = (currentDateTime.weekday - 1) % 7;
    final currentMinutes = currentDateTime.hour * 60 + currentDateTime.minute;
    final previousDay = (currentDay - 1 + 7) % 7;

    final todayStatus = checkOpenStatus(businessHours, currentDay, currentMinutes);
    final yesterdayStatus = checkPreviousDayOvernightStatus(
      businessHours,
      previousDay,
      currentMinutes,
    );

    final isCurrentlyOpen = todayStatus['isOpen'] == true || yesterdayStatus['isOpen'] == true;

    if (isCurrentlyOpen) {
      final closingInfo = getClosingTimeInfo(todayStatus, yesterdayStatus);
      final isClosingSoonStatus = isClosingSoon(
        closingInfo,
        currentMinutes,
        soonThresholdMinutes,
      );

      await statuscolor(openColor);

      if (isClosingSoonStatus) {
        return getLocalizedMessage('status_closing_soon', 'Closing soon');
      } else {
        return getLocalizedMessage('status_open', 'Open');
      }
    } else {
      final isOpeningSoonStatus = isOpeningSoon(
        businessHours,
        currentDay,
        currentMinutes,
        soonThresholdMinutes,
      );

      await statuscolor(closedColor);

      if (isOpeningSoonStatus) {
        return getLocalizedMessage('status_opening_soon', 'Opening soon');
      } else {
        return getLocalizedMessage('status_closed', 'Closed');
      }
    }
  } catch (e) {
    await statuscolor(closedColor);
    return getLocalizedMessage('status_closed', 'Closed');
  }
}
