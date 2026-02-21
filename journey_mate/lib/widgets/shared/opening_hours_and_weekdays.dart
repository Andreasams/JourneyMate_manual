import 'package:flutter/material.dart';
import '../../theme/app_typography.dart';
import '../../services/translation_service.dart';

/// Displays weekly opening hours with localized day names, typed cutoff
/// times, and support for closed/by_appointment_only day states.
///
/// Features:
/// - Supports multiple languages via translation system
/// - Displays up to 5 time slots per day
/// - Shows up to 2 typed cutoff times per slot (e.g. kitchen_close, last_order)
/// - Handles closed and by_appointment_only day states
/// - Responsive layout: cutoff times wrap to next line when font scale >= 1.1
/// - Dynamically adjusts column width based on language character length
/// - Automatically rebuilds when translations change
class OpeningHoursAndWeekdays extends StatefulWidget {
  const OpeningHoursAndWeekdays({
    super.key,
    this.width,
    this.height,
    this.openingHours,
  });

  final double? width;
  final double? height;
  final dynamic openingHours;

  @override
  State<OpeningHoursAndWeekdays> createState() =>
      _OpeningHoursAndWeekdaysState();
}

class _OpeningHoursAndWeekdaysState extends State<OpeningHoursAndWeekdays> {
  /// =========================================================================
  /// CONSTANTS
  /// =========================================================================

  static const int _daysInWeek = 7;
  static const int _maxTimeSlotsPerDay = 5;
  static const int _maxCutoffsPerSlot = 2;

  static const double _dayNameToHoursSpacing = 20.0;
  static const double _rowSpacing = 2.0;
  static const double _timeSlotSpacing = 1.0;
  static const double _multiSlotBottomPadding = 4.0;
  static const double _kitchenWrapThreshold = 1.1;

  static const Map<String, double> _languageWidths = {
    'zh': 75.0,
    'ko': 75.0,
    'ja': 75.0,
    'da': 85.0,
    'es': 85.0,
    'fr': 85.0,
    'it': 85.0,
    'nl': 85.0,
    'no': 85.0,
    'sv': 85.0,
    'uk': 85.0,
    'de': 110.0,
    'en': 110.0,
    'pl': 125.0,
    'fi': 125.0,
  };

  static const double _defaultContainerWidth = 85.0;

  static const List<String> _weekdayTranslationKeys = [
    'day_monday_cap',
    'day_tuesday_cap',
    'day_wednesday_cap',
    'day_thursday_cap',
    'day_friday_cap',
    'day_saturday_cap',
    'day_sunday_cap',
  ];

  static const String _closedTranslationKey = 'hours_closed';

  /// Maps cutoff_type enum values to their translation keys
  static const Map<String, String> _cutoffTypeTranslationKeys = {
    'kitchen_close': 'hours_kitchen',
    'last_arrival': 'hours_last_arrival',
    'last_order': 'hours_last_order',
    'last_booking': 'hours_last_booking',
    'first_seating': 'hours_first_seating',
    'second_seating': 'hours_second_seating',
    'third_seating': 'hours_third_seating',
    'call_for_hours': 'hours_call_for_hours',
  };

  /// =========================================================================
  /// LIFECYCLE METHODS
  /// =========================================================================

  @override
  void didUpdateWidget(OpeningHoursAndWeekdays oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Rebuild if opening hours data changes
    if (widget.openingHours != oldWidget.openingHours) {
      setState(() {});
    }
  }

  /// =========================================================================
  /// TRANSLATION HELPERS
  /// =========================================================================

  String _getUIText(BuildContext context, String key) {
    return ts(context, key);
  }

  String _getDayName(BuildContext context, int dayIndex) {
    if (dayIndex < 0 || dayIndex >= _weekdayTranslationKeys.length) {
      return '';
    }
    return _getUIText(context, _weekdayTranslationKeys[dayIndex]);
  }

  /// Returns the localized label for a cutoff type enum value
  String _getCutoffLabel(BuildContext context, String cutoffType) {
    final translationKey = _cutoffTypeTranslationKeys[cutoffType];
    if (translationKey == null) return cutoffType;
    return _getUIText(context, translationKey);
  }

  /// =========================================================================
  /// COMPUTED PROPERTIES
  /// =========================================================================

  double _getContainerWidth(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final languageCode = locale.languageCode;
    return _languageWidths[languageCode] ?? _defaultContainerWidth;
  }

  Map<String, dynamic> get _openingHoursData {
    return Map<String, dynamic>.from(widget.openingHours ?? {});
  }

  /// =========================================================================
  /// DATA HELPERS
  /// =========================================================================

  String _formatTime(String? time) {
    if (time == null) return '';
    if (time.length < 5) return time;
    return time.substring(0, 5);
  }

  bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  Map<String, dynamic> _getDayHours(int dayIndex) {
    return Map<String, dynamic>.from(
        _openingHoursData[dayIndex.toString()] ?? {});
  }

  /// A day is effectively closed if explicitly marked closed, by_appointment_only,
  /// or has no opening times defined in any slot
  bool _isDayClosed(Map<String, dynamic> dayHours) {
    if (_parseBool(dayHours['closed']) ||
        _parseBool(dayHours['by_appointment_only'])) {
      return true;
    }
    // No explicit flag — check if any opening time exists
    for (int slot = 1; slot <= _maxTimeSlotsPerDay; slot++) {
      if (dayHours['opening_time_$slot'] != null) return false;
    }
    return true;
  }

  bool _isByAppointmentOnly(Map<String, dynamic> dayHours) {
    return _parseBool(dayHours['by_appointment_only']);
  }

  bool _hasMultipleTimeSlots(Map<String, dynamic> dayHours) {
    for (int slot = 2; slot <= _maxTimeSlotsPerDay; slot++) {
      if (dayHours['opening_time_$slot'] != null) return true;
    }
    return false;
  }

  /// Collects all cutoffs for a given slot that have both type and time defined
  List<Map<String, String>> _getSlotCutoffs(
      Map<String, dynamic> dayHours, int slotNumber) {
    final cutoffs = <Map<String, String>>[];
    for (int c = 1; c <= _maxCutoffsPerSlot; c++) {
      final type = dayHours['cutoff_type_${slotNumber}_$c'] as String?;
      final time = dayHours['cutoff_time_${slotNumber}_$c'] as String?;
      if (type != null && time != null) {
        final note = dayHours['cutoff_note_${slotNumber}_$c'] as String?;
        cutoffs.add({
          'type': type,
          'time': time,
          ...?note != null ? {'note': note} : null,
        });
      }
    }
    return cutoffs;
  }

  /// =========================================================================
  /// UI BUILDERS
  /// =========================================================================

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: _buildWeekdaysList(context),
    );
  }

  Widget _buildWeekdaysList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _daysInWeek,
      separatorBuilder: (_, _) => const SizedBox(height: _rowSpacing),
      itemBuilder: (_, index) => _buildWeekdayRow(context, index),
    );
  }

  Widget _buildWeekdayRow(BuildContext context, int dayIndex) {
    final dayHours = _getDayHours(dayIndex);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDayNameColumn(context, dayIndex),
        const SizedBox(width: _dayNameToHoursSpacing),
        _buildOpeningHoursColumn(context, dayHours),
      ],
    );
  }

  Widget _buildDayNameColumn(BuildContext context, int dayIndex) {
    return SizedBox(
      width: _getContainerWidth(context),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          _getDayName(context, dayIndex),
          style: AppTypography.label,
        ),
      ),
    );
  }

  Widget _buildOpeningHoursColumn(
      BuildContext context, Map<String, dynamic> dayHours) {
    if (_isDayClosed(dayHours)) {
      // Show "By appointment" if that flag is set, otherwise "Closed"
      final label = _isByAppointmentOnly(dayHours)
          ? _getUIText(context, 'hours_by_appointment')
          : _getUIText(context, _closedTranslationKey);
      return Text(
        label,
        style: AppTypography.bodyRegular,
      );
    }

    return Expanded(
      child: Container(
        padding: EdgeInsets.only(
          bottom: _hasMultipleTimeSlots(dayHours) ? _multiSlotBottomPadding : 0,
        ),
        child: _buildTimeSlotsList(context, dayHours),
      ),
    );
  }

  Widget _buildTimeSlotsList(
      BuildContext context, Map<String, dynamic> dayHours) {
    final timeSlots = _buildTimeSlotWidgets(context, dayHours);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: timeSlots,
    );
  }

  List<Widget> _buildTimeSlotWidgets(
      BuildContext context, Map<String, dynamic> dayHours) {
    final timeSlots = <Widget>[];

    for (int slotNumber = 1; slotNumber <= _maxTimeSlotsPerDay; slotNumber++) {
      if (dayHours['opening_time_$slotNumber'] != null) {
        if (timeSlots.isNotEmpty) {
          timeSlots.add(const SizedBox(height: _timeSlotSpacing));
        }

        final cutoffs = _getSlotCutoffs(dayHours, slotNumber);

        timeSlots.add(_buildTimeSlotWidget(
          context,
          dayHours['opening_time_$slotNumber'] as String?,
          dayHours['closing_time_$slotNumber'] as String?,
          cutoffs,
        ));
      }
    }

    return timeSlots;
  }

  Widget _buildTimeSlotWidget(
    BuildContext context,
    String? openingTime,
    String? closingTime,
    List<Map<String, String>> cutoffs,
  ) {
    final hoursText =
        '${_formatTime(openingTime)} - ${_formatTime(closingTime)}';

    if (cutoffs.isEmpty) {
      return Text(
        hoursText,
        style: AppTypography.bodyRegular,
      );
    }

    final textScaleFactor = MediaQuery.textScalerOf(context).scale(1.0);

    // Check if bold text is enabled via MediaQuery
    final boldText = MediaQuery.boldTextOf(context);
    final shouldWrap =
        textScaleFactor >= _kitchenWrapThreshold || boldText;

    // Build cutoff text parts: "(Kitchen: 22:00)" or "(Kitchen: 22:00, Last order: 23:30)"
    final cutoffParts = cutoffs.map((c) {
      final label = _getCutoffLabel(context, c['type']!);
      return '$label: ${_formatTime(c['time'])}';
    }).join(', ');
    final cutoffText = '($cutoffParts)';

    if (shouldWrap) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            hoursText,
            style: AppTypography.bodyRegular,
          ),
          Text(
            cutoffText,
            style: AppTypography.bodySmall,
          ),
        ],
      );
    }

    return Text(
      '$hoursText $cutoffText',
      style: AppTypography.bodyRegular,
    );
  }
}
