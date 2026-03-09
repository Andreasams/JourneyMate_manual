/// Returns a localized opening hours status string for the current day/time.
///
/// Produces human-readable messages like:
/// - Open: "Monday - 11:00 - 22:00" (capitalized day + time range)
/// - Closed, opens later today: "Closed - opens later at 15:00"
/// - Closed, opens tomorrow: "Closed - opens again tomorrow at 11:00"
/// - Closed, opens on future day: "Closed - opens again on wednesday at 11:00"
/// - Fully closed: "Closed"
///
/// Args:
///   currentDateTime: The current date and time for status calculation
///   businessHoursInput: Map with day indices (0-6, Mon-Sun) as keys
///   languageCode: Language code for translated text (defaults to 'en')
///   translationsCache: Translation cache map for localized messages
///
/// Returns:
///   Localized status string describing current opening hours state
String daysDayOpeningHour(
  DateTime currentDateTime,
  dynamic businessHoursInput,
  String languageCode,
  dynamic translationsCache,
) {
  const maxTimeSlotsPerDay = 5;

  // ---------------------------------------------------------------------------
  // Translation helper (inline pattern — same as business_status.dart)
  // ---------------------------------------------------------------------------
  String getLocalizedMessage(String key, String defaultValue) {
    if (translationsCache != null && translationsCache is Map) {
      try {
        final cache = translationsCache as Map<String, dynamic>;
        final translation = cache[key];
        if (translation != null &&
            translation is String &&
            translation.isNotEmpty) {
          return translation;
        }
      } catch (e) {
        // Fall through to default
      }
    }
    return defaultValue;
  }

  // ---------------------------------------------------------------------------
  // Day name lookup tables (index 0-6 = Mon-Sun)
  // ---------------------------------------------------------------------------
  const capitalizedDayKeys = [
    'day_monday_cap',
    'day_tuesday_cap',
    'day_wednesday_cap',
    'day_thursday_cap',
    'day_friday_cap',
    'day_saturday_cap',
    'day_sunday_cap',
  ];
  const capitalizedDayDefaults = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  const lowerDayKeys = [
    'day_monday_lower',
    'day_tuesday_lower',
    'day_wednesday_lower',
    'day_thursday_lower',
    'day_friday_lower',
    'day_saturday_lower',
    'day_sunday_lower',
  ];
  const lowerDayDefaults = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  String getCapitalizedDayName(int dayIndex) {
    final i = dayIndex.clamp(0, 6);
    return getLocalizedMessage(capitalizedDayKeys[i], capitalizedDayDefaults[i]);
  }

  String getLowerDayName(int dayIndex) {
    final i = dayIndex.clamp(0, 6);
    return getLocalizedMessage(lowerDayKeys[i], lowerDayDefaults[i]);
  }

  // ---------------------------------------------------------------------------
  // Time helpers
  // ---------------------------------------------------------------------------
  int convertTimeToMinutes(String? time) {
    if (time == null || time.isEmpty) return -1;
    try {
      final parts = time.split(':');
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

  String formatTime(String? time) {
    if (time == null || time.isEmpty) return '';
    try {
      final parts = time.split(':');
      if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
      return time;
    } catch (e) {
      return time;
    }
  }

  bool parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  bool isDayClosed(Map<String, dynamic> dayHours) {
    return parseBool(dayHours['closed']) ||
        parseBool(dayHours['by_appointment_only']);
  }

  // ---------------------------------------------------------------------------
  // Guard: validate input
  // ---------------------------------------------------------------------------
  if (businessHoursInput == null || businessHoursInput is! Map) {
    return getLocalizedMessage('closed', 'Closed');
  }

  final Map<String, dynamic> businessHours;
  try {
    businessHours = Map<String, dynamic>.from(
      businessHoursInput.map(
        (key, value) => MapEntry(
          key.toString(),
          (value is Map)
              ? Map<String, dynamic>.from(
                  value.map((k, v) => MapEntry(k.toString(), v)))
              : value,
        ),
      ),
    );
  } catch (e) {
    return getLocalizedMessage('closed', 'Closed');
  }

  final currentDay = currentDateTime.weekday - 1; // Monday = 0
  final currentMinutes = currentDateTime.hour * 60 + currentDateTime.minute;
  final previousDay = (currentDay - 1 + 7) % 7;

  // ---------------------------------------------------------------------------
  // Check if currently open (today's hours or yesterday's overnight)
  // ---------------------------------------------------------------------------
  String? currentOpeningTime;
  String? currentClosingTime;
  bool isCurrentlyOpen = false;
  bool isFromPreviousDay = false; // Track if open slot belongs to yesterday

  // Check today's slots
  final todayKey = currentDay.toString();
  if (businessHours.containsKey(todayKey) && businessHours[todayKey] is Map) {
    final todayHours =
        Map<String, dynamic>.from(businessHours[todayKey] as Map);
    if (!isDayClosed(todayHours)) {
      for (int slot = 1; slot <= maxTimeSlotsPerDay; slot++) {
        final openStr = todayHours['opening_time_$slot'] as String?;
        final closeStr = todayHours['closing_time_$slot'] as String?;
        if (openStr == null || closeStr == null) continue;

        final openMin = convertTimeToMinutes(openStr);
        final closeMin = convertTimeToMinutes(closeStr);
        if (openMin == -1 || closeMin == -1) continue;

        final isOvernight = closeMin < openMin ||
            closeMin == 1440 ||
            (closeMin == 0 && openMin > 0);

        final isOpen = isOvernight
            ? (currentMinutes >= openMin || currentMinutes < closeMin)
            : (currentMinutes >= openMin && currentMinutes < closeMin);

        if (isOpen) {
          isCurrentlyOpen = true;
          currentOpeningTime = openStr;
          currentClosingTime = closeStr;
          break;
        }
      }
    }
  }

  // Check yesterday's overnight hours if not already open
  if (!isCurrentlyOpen) {
    final prevKey = previousDay.toString();
    if (businessHours.containsKey(prevKey) && businessHours[prevKey] is Map) {
      final prevHours =
          Map<String, dynamic>.from(businessHours[prevKey] as Map);
      if (!isDayClosed(prevHours)) {
        for (int slot = 1; slot <= maxTimeSlotsPerDay; slot++) {
          final openStr = prevHours['opening_time_$slot'] as String?;
          final closeStr = prevHours['closing_time_$slot'] as String?;
          if (openStr == null || closeStr == null) continue;

          final openMin = convertTimeToMinutes(openStr);
          final closeMin = convertTimeToMinutes(closeStr);
          if (openMin == -1 || closeMin == -1) continue;

          final isOvernight = closeMin < openMin ||
              closeMin == 1440 ||
              (closeMin == 0 && openMin > 0);

          if (isOvernight && currentMinutes < closeMin) {
            isCurrentlyOpen = true;
            isFromPreviousDay = true;
            currentOpeningTime = openStr;
            currentClosingTime = closeStr;
            break;
          }
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Open: return "DayName - opening - closing"
  // ---------------------------------------------------------------------------
  if (isCurrentlyOpen && currentOpeningTime != null && currentClosingTime != null) {
    // Use the day the schedule belongs to (yesterday for overnight slots)
    final scheduleDay = isFromPreviousDay ? previousDay : currentDay;
    final dayName = getCapitalizedDayName(scheduleDay);
    return '$dayName - ${formatTime(currentOpeningTime)} - ${formatTime(currentClosingTime)}';
  }

  // ---------------------------------------------------------------------------
  // Closed: find next opening
  // ---------------------------------------------------------------------------
  final closed = getLocalizedMessage('closed', 'Closed');

  for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
    final checkDay = (currentDay + dayOffset) % 7;
    final dayKey = checkDay.toString();

    if (!businessHours.containsKey(dayKey) || businessHours[dayKey] is! Map) {
      continue;
    }

    final dayHours = Map<String, dynamic>.from(businessHours[dayKey] as Map);
    if (isDayClosed(dayHours)) continue;

    for (int slot = 1; slot <= maxTimeSlotsPerDay; slot++) {
      final openStr = dayHours['opening_time_$slot'] as String?;
      if (openStr == null) continue;

      final openMin = convertTimeToMinutes(openStr);
      if (openMin == -1) continue;

      // For today, only consider future opening times
      if (dayOffset == 0 && openMin <= currentMinutes) continue;

      final nextTime = formatTime(openStr);
      final atWord = getLocalizedMessage('hours_at', 'at');

      if (dayOffset == 0) {
        // Opens later today
        final opensLater =
            getLocalizedMessage('hours_opens_later', 'opens later at');
        return '$closed - $opensLater $nextTime';
      } else if (dayOffset == 1) {
        // Opens tomorrow
        final opensAgain =
            getLocalizedMessage('hours_opens_again', 'opens again');
        final tomorrow = getLocalizedMessage('hours_tomorrow', 'tomorrow');
        return '$closed - $opensAgain $tomorrow $atWord $nextTime';
      } else {
        // Opens on a future day
        final opensAgain =
            getLocalizedMessage('hours_opens_again', 'opens again');
        final onWord = getLocalizedMessage('hours_on', 'on');
        final dayName = getLowerDayName(checkDay);
        return '$closed - $opensAgain $onWord $dayName $atWord $nextTime';
      }
    }
  }

  // No opening times found at all
  return closed;
}
