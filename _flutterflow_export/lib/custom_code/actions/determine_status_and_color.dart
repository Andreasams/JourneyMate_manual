// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'dart:ui' show Color;

/// Determines the current business status and sets the appropriate status color.
///
/// Analyzes business hours data to determine if a business is currently
/// open, closed, opening soon, or closing soon. Handles complex scenarios including:
/// - Up to 5 time slots per day
/// - Overnight hours (e.g., 22:00 to 02:00)
/// - Days marked as closed or by_appointment_only (both treated as closed)
/// - "Soon" thresholds (30 minutes before opening/closing)
/// - Seven-day weekly schedules
///
/// Args:
///   statuscolor: Callback function to set the status indicator color
///   businessHoursInput: Map containing weekly business hours with structure:
///     {
///       "0": {"closed": false, "by_appointment_only": false,
///             "opening_time_1": "09:00", "closing_time_1": "17:00",
///             "cutoff_type_1_1": "kitchen_close", "cutoff_time_1_1": "16:00", ...},
///       "1": {...},
///       ...
///     }
///     where keys are day numbers (0=Monday, 6=Sunday)
///   currentDateTime: The current date and time for status calculation
///   languageCode: Language code for translated status text (defaults to 'en')
///   translationsCache: Translation cache from FFAppState
///
/// Returns:
///   Translated status text: "Open", "Closed", "Opening soon", or "Closing soon"
///
/// Color Meanings:
///   - Green (0xFF518751): Currently open (including "closing soon")
///   - Red (0xFFFF5963): Currently closed (including "opening soon")
Future<String> determineStatusAndColor(
  Future Function(Color color) statuscolor,
  dynamic businessHoursInput,
  DateTime currentDateTime,
  String? languageCode,
  dynamic translationsCache,
) async {
  const int soonThresholdMinutes = 30;
  const Color openColor = Color(0xFF518751);
  const Color closedColor = Color(0xFFFF5963);

  final effectiveLanguageCode = languageCode ?? 'en';

  // Guard: Validate inputs
  if (!_isValidBusinessHoursInput(businessHoursInput) ||
      currentDateTime == null) {
    await statuscolor(closedColor);
    return getTranslations(
      effectiveLanguageCode,
      'status_closed',
      translationsCache,
    );
  }

  // Prepare data
  final businessHours = _normalizeBusinessHours(businessHoursInput);
  final currentDay = currentDateTime.weekday - 1; // Monday = 0, Sunday = 6
  final currentMinutes = currentDateTime.hour * 60 + currentDateTime.minute;

  // Determine status and color
  final statusInfo = _determineBusinessStatus(
    businessHours,
    currentDay,
    currentMinutes,
    soonThresholdMinutes,
  );

  // Set color and return translated text
  final color = statusInfo['isOpen'] ? openColor : closedColor;
  await statuscolor(color);
  return getTranslations(
    effectiveLanguageCode,
    statusInfo['statusKey'],
    translationsCache,
  );
}

// ============================================================================
// CONSTANTS
// ============================================================================

const int _maxTimeSlotsPerDay = 5;

// ============================================================================
// CORE BUSINESS LOGIC
// ============================================================================

/// Determines the complete business status
///
/// Returns a map with:
/// - isOpen: Whether currently open (true) or closed (false)
/// - statusKey: Translation key for the status text
Map<String, dynamic> _determineBusinessStatus(
  Map<String, dynamic> businessHours,
  int currentDay,
  int currentMinutes,
  int soonThreshold,
) {
  final previousDay = (currentDay - 1 + 7) % 7;

  // Check if currently open (from today or yesterday's overnight)
  final todayStatus =
      _checkOpenStatus(businessHours, currentDay, currentMinutes);
  final yesterdayStatus = _checkPreviousDayOvernightStatus(
      businessHours, previousDay, currentMinutes);
  final isCurrentlyOpen = todayStatus['isOpen'] || yesterdayStatus['isOpen'];

  if (isCurrentlyOpen) {
    return _determineOpenStatus(
        todayStatus, yesterdayStatus, currentMinutes, soonThreshold);
  }

  return _determineClosedStatus(
      businessHours, currentDay, currentMinutes, soonThreshold);
}

/// Determines specific status when business is currently open
Map<String, dynamic> _determineOpenStatus(
  Map<String, dynamic> todayStatus,
  Map<String, dynamic> yesterdayStatus,
  int currentMinutes,
  int soonThreshold,
) {
  final closingInfo = _getClosingTimeInfo(todayStatus, yesterdayStatus);
  final isClosingSoon =
      _isClosingSoon(closingInfo, currentMinutes, soonThreshold);

  return {
    'isOpen': true,
    'statusKey': isClosingSoon ? 'status_closing_soon' : 'status_open',
  };
}

/// Determines specific status when business is currently closed
Map<String, dynamic> _determineClosedStatus(
  Map<String, dynamic> businessHours,
  int currentDay,
  int currentMinutes,
  int soonThreshold,
) {
  final isOpeningSoon =
      _isOpeningSoon(businessHours, currentDay, currentMinutes, soonThreshold);

  return {
    'isOpen': false,
    'statusKey': isOpeningSoon ? 'status_opening_soon' : 'status_closed',
  };
}

// ============================================================================
// VALIDATION & NORMALIZATION
// ============================================================================

bool _isValidBusinessHoursInput(dynamic input) {
  return input != null && input is Map;
}

Map<String, dynamic> _normalizeBusinessHours(dynamic input) {
  try {
    return Map<String, dynamic>.from(input.map((key, value) => MapEntry(
        key.toString(),
        (value is Map)
            ? Map<String, dynamic>.from(
                value.map((k, v) => MapEntry(k.toString(), v)))
            : value)));
  } catch (e) {
    debugPrint('DSAC Error normalizing business hours: $e');
    return {};
  }
}

// ============================================================================
// DAY STATUS HELPERS
// ============================================================================

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

// ============================================================================
// TIME CONVERSION & VALIDATION
// ============================================================================

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
    debugPrint('DSAC Error parsing time "$timeString": $e');
    return -1;
  }
}

bool _isOvernightTimeSlot(int openMinutes, int closeMinutes) {
  return closeMinutes < openMinutes ||
      closeMinutes == 1440 ||
      (closeMinutes == 0 && openMinutes > 0);
}

// ============================================================================
// OPEN STATUS CHECKING
// ============================================================================

Map<String, dynamic> _checkOpenStatus(
  Map<String, dynamic> businessHours,
  int day,
  int currentMinutes,
) {
  const defaultResult = {
    'isOpen': false,
    'nextTime': null,
    'isOvernightClose': false,
    'slotIndex': -1,
  };

  final dayHours = _getDayHours(businessHours, day);
  if (dayHours == null) return defaultResult;

  // Day explicitly closed or by_appointment_only
  if (_isDayClosed(dayHours)) return defaultResult;

  for (int slot = 1; slot <= _maxTimeSlotsPerDay; slot++) {
    final timeSlot = _getTimeSlot(dayHours, slot);
    if (timeSlot == null) continue;

    if (_isCurrentlyInTimeSlot(currentMinutes, timeSlot['open'],
        timeSlot['close'], timeSlot['isOvernight'])) {
      return {
        'isOpen': true,
        'nextTime': timeSlot['closeStr'],
        'isOvernightClose': timeSlot['isOvernight'],
        'slotIndex': slot,
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
  const defaultResult = {
    'isOpen': false,
    'nextTime': null,
    'slotIndex': -1,
  };

  final prevDayHours = _getDayHours(businessHours, previousDay);
  if (prevDayHours == null) return defaultResult;

  // Previous day explicitly closed means no overnight possible
  if (_isDayClosed(prevDayHours)) return defaultResult;

  for (int slot = 1; slot <= _maxTimeSlotsPerDay; slot++) {
    final timeSlot = _getTimeSlot(prevDayHours, slot);
    if (timeSlot == null) continue;

    if (timeSlot['isOvernight'] && currentMinutes < timeSlot['close']) {
      return {
        'isOpen': true,
        'nextTime': timeSlot['closeStr'],
        'slotIndex': slot,
      };
    }
  }

  return defaultResult;
}

Map<String, dynamic>? _getDayHours(
    Map<String, dynamic> businessHours, int day) {
  final dayKey = day.toString();
  final dayData = businessHours[dayKey];
  return (dayData is Map) ? dayData as Map<String, dynamic> : null;
}

Map<String, dynamic>? _getTimeSlot(Map<String, dynamic> dayHours, int slot) {
  final openingTime = dayHours['opening_time_$slot'] as String?;
  final closingTime = dayHours['closing_time_$slot'] as String?;

  if (openingTime == null || closingTime == null) return null;

  final openMinutes = _convertTimeToMinutes(openingTime);
  final closeMinutes = _convertTimeToMinutes(closingTime);

  if (openMinutes == -1 || closeMinutes == -1) return null;

  return {
    'open': openMinutes,
    'close': closeMinutes,
    'closeStr': closingTime.substring(0, 5),
    'isOvernight': _isOvernightTimeSlot(openMinutes, closeMinutes),
  };
}

bool _isCurrentlyInTimeSlot(
  int currentMinutes,
  int openMinutes,
  int closeMinutes,
  bool isOvernight,
) {
  return isOvernight
      ? (currentMinutes >= openMinutes || currentMinutes < closeMinutes)
      : (currentMinutes >= openMinutes && currentMinutes < closeMinutes);
}

// ============================================================================
// CLOSING TIME LOGIC
// ============================================================================

Map<String, dynamic> _getClosingTimeInfo(
  Map<String, dynamic> todayStatus,
  Map<String, dynamic> yesterdayStatus,
) {
  if (todayStatus['isOpen']) {
    return {
      'closingTime': todayStatus['nextTime'],
      'isOvernight': todayStatus['isOvernightClose'],
    };
  }

  return {
    'closingTime': yesterdayStatus['nextTime'],
    'isOvernight': true,
  };
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

  final minutesUntilClosing = _calculateMinutesUntilClosing(
    currentMinutes,
    closeMinutes,
    closingInfo['isOvernight'],
  );

  return minutesUntilClosing >= 0 && minutesUntilClosing <= thresholdMinutes;
}

int _calculateMinutesUntilClosing(
  int currentMinutes,
  int closeMinutes,
  bool isOvernight,
) {
  if (!isOvernight) return closeMinutes - currentMinutes;

  return currentMinutes < closeMinutes
      ? closeMinutes - currentMinutes
      : (closeMinutes + 1440) - currentMinutes;
}

// ============================================================================
// OPENING TIME LOGIC
// ============================================================================

bool _isOpeningSoon(
  Map<String, dynamic> businessHours,
  int currentDay,
  int currentMinutes,
  int thresholdMinutes,
) {
  final nextOpening =
      _findNextOpeningTime(businessHours, currentDay, currentMinutes);

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
  for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
    final checkDay = (startDay + dayOffset) % 7;
    final dayHours = _getDayHours(businessHours, checkDay);
    if (dayHours == null) continue;

    // Skip days explicitly closed or by_appointment_only
    if (_isDayClosed(dayHours)) continue;

    for (int slot = 1; slot <= _maxTimeSlotsPerDay; slot++) {
      final timeSlot = _getTimeSlot(dayHours, slot);
      if (timeSlot == null) continue;

      if (dayOffset > 0 || timeSlot['open'] > currentMinutes) {
        return {
          'time': dayHours['opening_time_$slot'].toString().substring(0, 5),
          'offsetDays': dayOffset,
        };
      }
    }
  }

  return {'time': 'N/A', 'offsetDays': -1};
}
