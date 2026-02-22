/// Determines if a business is currently open/closed and returns a localized status message.
///
/// Handles complex business hour scenarios including multiple time slots per day, overnight hours,
/// and special closure conditions.
///
/// Args:
///   businessHours: Map with day indices (0-6) as keys containing time slots and closure flags
///   currentDateTime: The reference time for checking status
///   languageCode: ISO language code (defaults to 'en' if null or unsupported)
///   translationsCache: Translation cache for localized messages
///
/// Returns:
///   Localized message indicating current status and next time change
String openClosesAt(
  dynamic businessHours,
  DateTime currentDateTime,
  String? languageCode,
  dynamic translationsCache,
) {
  const maxTimeSlotsPerDay = 5;

  // Helper: Get localized message from translation cache
  String getLocalizedMessage(String key, String defaultValue) {
    // TODO: Implement translation cache lookup
    // For now, return default values based on language
    final lang = languageCode?.toLowerCase() ?? 'en';

    final translations = {
      'hours_closes_at': {'en': 'til', 'da': 'til'},
      'hours_closes_tomorrow': {
        'en': 'closes tomorrow at',
        'da': 'lukker i morgen kl.'
      },
      'hours_closes_tonight': {
        'en': 'closes tonight at',
        'da': 'lukker i nat kl.'
      },
      'hours_opens_at': {'en': 'opens at', 'da': 'åbner kl.'},
      'hours_opens_tomorrow': {
        'en': 'opens tomorrow at',
        'da': 'åbner i morgen kl.'
      },
      'hours_no_data': {
        'en': 'No hours available',
        'da': 'Ingen åbningstider'
      },
    };

    return translations[key]?[lang] ?? defaultValue;
  }

  // Helper: Convert "HH:MM" time string to minutes since midnight
  int convertTimeToMinutes(String? time) {
    if (time == null || time.isEmpty) return -1;

    try {
      final parts = time.split(':');
      if (parts.length < 2) return -1;

      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);

      // Special case: 24:00 = 1440 minutes
      if (hours == 24 && minutes == 0) return 1440;

      // Validate range
      if (hours >= 0 && hours < 24 && minutes >= 0 && minutes < 60) {
        return hours * 60 + minutes;
      }

      return -1;
    } catch (e) {
      return -1;
    }
  }

  // Helper: Parse dynamic bool value
  bool parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return false;
  }

  // Helper: Check if day is closed
  bool isDayClosed(Map<String, dynamic> dayHours) {
    final closed = parseBool(dayHours['closed']);
    final byAppointment = parseBool(dayHours['by_appointment_only']);
    return closed || byAppointment;
  }

  // Helper: Check if business is open at current time
  Map<String, dynamic> checkDayOpenStatus(
    Map<String, dynamic> businessHoursMap,
    int dayIndex,
    int currentMinutes,
  ) {
    final dayKey = dayIndex.toString();
    final dayHours = businessHoursMap[dayKey];

    if (dayHours == null || dayHours is! Map) {
      return {'isOpen': false};
    }

    final dayHoursMap = Map<String, dynamic>.from(dayHours);

    // Check if day is explicitly closed
    if (isDayClosed(dayHoursMap)) {
      return {'isOpen': false};
    }

    // Check all time slots
    for (int slot = 1; slot <= maxTimeSlotsPerDay; slot++) {
      final openKey = 'opening_time_$slot';
      final closeKey = 'closing_time_$slot';

      final openTimeStr = dayHoursMap[openKey]?.toString();
      final closeTimeStr = dayHoursMap[closeKey]?.toString();

      if (openTimeStr == null || closeTimeStr == null) continue;

      final openingMinutes = convertTimeToMinutes(openTimeStr);
      final closingMinutes = convertTimeToMinutes(closeTimeStr);

      if (openingMinutes == -1 || closingMinutes == -1) continue;

      // Determine if overnight slot
      bool isOvernightType = false;

      if (closingMinutes < openingMinutes) {
        isOvernightType = true;
      } else if (closingMinutes == 1440) {
        isOvernightType = true;
      } else if (closingMinutes == 0 && openingMinutes > 0 && openingMinutes < 1440) {
        isOvernightType = true;
      }

      // Check if currently open
      bool isOpen = false;

      if (isOvernightType) {
        // Overnight hours: open if after opening time OR before closing time
        isOpen = currentMinutes >= openingMinutes || currentMinutes < closingMinutes;
      } else {
        // Normal hours: open if between opening and closing
        isOpen = currentMinutes >= openingMinutes && currentMinutes < closingMinutes;
      }

      if (isOpen) {
        return {
          'isOpen': true,
          'closingTime': closeTimeStr,
          'isOvernightClose': isOvernightType,
          'slotIndex': slot,
        };
      }
    }

    return {'isOpen': false};
  }

  // Helper: Check previous day's overnight hours
  Map<String, dynamic> checkPreviousDayOvernight(
    Map<String, dynamic> businessHoursMap,
    int previousDayIndex,
    int currentMinutes,
  ) {
    final dayKey = previousDayIndex.toString();
    final dayHours = businessHoursMap[dayKey];

    if (dayHours == null || dayHours is! Map) {
      return {'isOpen': false};
    }

    final dayHoursMap = Map<String, dynamic>.from(dayHours);

    if (isDayClosed(dayHoursMap)) {
      return {'isOpen': false};
    }

    // Check all time slots for overnight hours
    for (int slot = 1; slot <= maxTimeSlotsPerDay; slot++) {
      final openKey = 'opening_time_$slot';
      final closeKey = 'closing_time_$slot';

      final openTimeStr = dayHoursMap[openKey]?.toString();
      final closeTimeStr = dayHoursMap[closeKey]?.toString();

      if (openTimeStr == null || closeTimeStr == null) continue;

      final openingMinutes = convertTimeToMinutes(openTimeStr);
      final closingMinutes = convertTimeToMinutes(closeTimeStr);

      if (openingMinutes == -1 || closingMinutes == -1) continue;

      // Only check overnight slots
      final isOvernight = closingMinutes < openingMinutes ||
          closingMinutes == 1440 ||
          (closingMinutes == 0 && openingMinutes > 0);

      if (isOvernight && currentMinutes < closingMinutes) {
        return {
          'isOpen': true,
          'closingTime': closeTimeStr,
          'isOvernightClose': true,
        };
      }
    }

    return {'isOpen': false};
  }

  // Helper: Find next opening time
  Map<String, dynamic> findNextOpening(
    Map<String, dynamic> businessHoursMap,
    int startDayIndex,
    int currentMinutes,
  ) {
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final checkDayIndex = (startDayIndex + dayOffset) % 7;
      final dayKey = checkDayIndex.toString();
      final dayHours = businessHoursMap[dayKey];

      if (dayHours == null || dayHours is! Map) continue;

      final dayHoursMap = Map<String, dynamic>.from(dayHours);

      if (isDayClosed(dayHoursMap)) continue;

      // Check all time slots
      for (int slot = 1; slot <= maxTimeSlotsPerDay; slot++) {
        final openKey = 'opening_time_$slot';
        final openTimeStr = dayHoursMap[openKey]?.toString();

        if (openTimeStr == null) continue;

        final openingMinutes = convertTimeToMinutes(openTimeStr);
        if (openingMinutes == -1) continue;

        // For today (dayOffset == 0), only consider times after current time
        if (dayOffset == 0 && openingMinutes <= currentMinutes) {
          continue;
        }

        // Found next opening
        return {
          'time': openTimeStr,
          'offsetDays': dayOffset,
        };
      }
    }

    return {
      'time': 'N/A',
      'offsetDays': -1,
    };
  }

  // Main logic
  try {
    // Validate input
    if (businessHours == null || businessHours is! Map) {
      return getLocalizedMessage('hours_no_data', 'No hours available');
    }

    final businessHoursMap = Map<String, dynamic>.from(businessHours);

    if (businessHoursMap.isEmpty) {
      return getLocalizedMessage('hours_no_data', 'No hours available');
    }

    // Calculate current day and time
    final currentDay = (currentDateTime.weekday - 1) % 7; // Monday = 0
    final currentMinutes =
        currentDateTime.hour * 60 + currentDateTime.minute;
    final previousDay = (currentDay - 1 + 7) % 7;

    // Check if currently open (today's hours)
    final todayStatus = checkDayOpenStatus(
      businessHoursMap,
      currentDay,
      currentMinutes,
    );

    // Check if currently open (yesterday's overnight hours)
    final yesterdayStatus = checkPreviousDayOvernight(
      businessHoursMap,
      previousDay,
      currentMinutes,
    );

    // Determine if open and which closing time to use
    if (todayStatus['isOpen'] == true) {
      final closingTime = todayStatus['closingTime'];
      final isOvernight = todayStatus['isOvernightClose'] == true;

      if (isOvernight) {
        return '${getLocalizedMessage('hours_closes_tomorrow', 'closes tomorrow at')} $closingTime';
      } else {
        return '${getLocalizedMessage('hours_closes_at', 'til')} $closingTime';
      }
    }

    if (yesterdayStatus['isOpen'] == true) {
      final closingTime = yesterdayStatus['closingTime'];
      return '${getLocalizedMessage('hours_closes_at', 'til')} $closingTime';
    }

    // Currently closed - find next opening
    final nextOpening = findNextOpening(
      businessHoursMap,
      currentDay,
      currentMinutes,
    );

    final nextOpenTime = nextOpening['time'];
    final offsetDays = nextOpening['offsetDays'] as int;

    if (offsetDays == -1) {
      return getLocalizedMessage('hours_no_data', 'No hours available');
    }

    if (offsetDays == 0) {
      return '${getLocalizedMessage('hours_opens_at', 'opens at')} $nextOpenTime';
    } else if (offsetDays == 1) {
      return '${getLocalizedMessage('hours_opens_tomorrow', 'opens tomorrow at')} $nextOpenTime';
    } else {
      // Opens in 2+ days
      return '${getLocalizedMessage('hours_opens_at', 'opens at')} $nextOpenTime';
    }
  } catch (e) {
    return getLocalizedMessage('hours_no_data', 'No hours available');
  }
}
