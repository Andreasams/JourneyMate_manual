import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../providers/business_providers.dart';
import '../../providers/locale_provider.dart';
import '../../services/translation_service.dart';
import '../../services/analytics_service.dart';
import '../../services/api_service.dart';

/// Opening Hours & Contact Widget - Collapsible section combining hours and contact info
///
/// Features:
/// - Collapsed: Shows title + today's preview (e.g., "I dag: 07:00–10:00, 11:30–14:30")
/// - Expanded: Shows full hours table + contact section in styled container
/// - Phone: Tappable (call) + long-pressable (copy to clipboard)
/// - Links: Website, Instagram, Booking open in external browser
/// - Chevron rotates 180° on expansion
/// - Self-contained (reads from businessProvider internally)
///
/// JSX reference: _reference/jsx_design/business_profile/_shared.jsx lines 464-718
class OpeningHoursContactWidget extends ConsumerStatefulWidget {
  const OpeningHoursContactWidget({super.key});

  @override
  ConsumerState<OpeningHoursContactWidget> createState() =>
      _OpeningHoursContactWidgetState();
}

class _OpeningHoursContactWidgetState
    extends ConsumerState<OpeningHoursContactWidget> {
  // ============================================================================
  // CONSTANTS
  // ============================================================================

  static const int _maxTimeSlotsPerDay = 5;
  static const int _maxCutoffsPerSlot = 2;

  /// Translation keys for weekdays (Monday first, Sunday last)
  static const List<String> _weekdayTranslationKeys = [
    'day_monday_cap',
    'day_tuesday_cap',
    'day_wednesday_cap',
    'day_thursday_cap',
    'day_friday_cap',
    'day_saturday_cap',
    'day_sunday_cap',
  ];

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

  // ============================================================================
  // LOCAL STATE
  // ============================================================================

  bool _isExpanded = false;

  // ============================================================================
  // HARDCODED TRANSLATIONS (temporary - to be moved to database)
  // ============================================================================

  /// Temporary hardcoded translations for Phase 3 keys
  /// TODO: Add these to ui_translations table (see translation_keys_phase3.txt)
  String _t(String key) {
    final locale = ref.read(localeProvider);
    final lang = locale.languageCode;

    // Hardcoded translations for new Phase 3 keys
    const translations = {
      'opening_hours_and_contact': {
        'da': 'Åbningstider og kontakt',
        'en': 'Opening Hours & Contact',
      },
      'opening_hours_label': {
        'da': 'ÅBNINGSTIDER',
        'en': 'OPENING HOURS',
      },
      'contact_label': {
        'da': 'KONTAKT',
        'en': 'CONTACT',
      },
      'today_prefix': {
        'da': 'I dag: ',
        'en': 'Today: ',
      },
      'closed': {
        'da': 'Lukket',
        'en': 'Closed',
      },
      'phone': {
        'da': 'Telefon',
        'en': 'Phone',
      },
      'phone_number_label': {
        'da': 'Telefonnummer',
        'en': 'Phone Number',
      },
      'email_label': {
        'da': 'E-mail',
        'en': 'Email',
      },
      'facebook_label': {
        'da': 'Facebook',
        'en': 'Facebook',
      },
      'tiktok_label': {
        'da': 'TikTok',
        'en': 'TikTok',
      },
      'send_email_action': {
        'da': 'Send e-mail',
        'en': 'Send email',
      },
      'visit_website_action': {
        'da': 'Besøg hjemmeside',
        'en': 'Visit website',
      },
      'make_reservation_action': {
        'da': 'Foretag en reservation',
        'en': 'Make reservation',
      },
      'view_instagram_action': {
        'da': 'Se på Instagram',
        'en': 'View on Instagram',
      },
      'view_facebook_action': {
        'da': 'Se på Facebook',
        'en': 'View on Facebook',
      },
      'view_tiktok_action': {
        'da': 'Se på TikTok',
        'en': 'View on TikTok',
      },
      'error_cannot_open_email': {
        'da': 'Kan ikke åbne e-mail app',
        'en': 'Cannot open email app',
      },
      'website': {
        'da': 'Hjemmeside',
        'en': 'Website',
      },
      'booking': {
        'da': 'Booking',
        'en': 'Booking',
      },
      'instagram': {
        'da': 'Instagram',
        'en': 'Instagram',
      },
      'copied_to_clipboard': {
        'da': 'Kopieret til udklipsholder',
        'en': 'Copied to clipboard',
      },
    };

    // Try to get from hardcoded translations first
    if (translations.containsKey(key)) {
      return translations[key]?[lang] ?? translations[key]?['en'] ?? key;
    }

    // Fall back to translation service for existing keys
    return td(ref, key);
  }

  // ============================================================================
  // DATA HELPERS
  // ============================================================================

  /// Get day hours data for a specific day index (0 = Monday, 6 = Sunday)
  Map<String, dynamic> _getDayHours(int dayIndex, Map<String, dynamic> openingHours) {
    return Map<String, dynamic>.from(openingHours[dayIndex.toString()] ?? {});
  }

  /// Check if a day is closed
  bool _isDayClosed(Map<String, dynamic> dayHours) {
    // Check if explicitly marked closed
    if (_parseBool(dayHours['closed'])) {
      return true;
    }
    // Check if no opening times are defined
    for (int slot = 1; slot <= _maxTimeSlotsPerDay; slot++) {
      if (dayHours['opening_time_$slot'] != null) return false;
    }
    return true;
  }

  /// Parse bool value from dynamic (handles String "true"/"false")
  bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  /// Format time string (extract HH:mm from HH:mm:ss)
  String _formatTime(String? time) {
    if (time == null) return '';
    if (time.length < 5) return time;
    return time.substring(0, 5);
  }

  /// Get localized day name for a day index (0 = Monday, 6 = Sunday in our array)
  String _getDayName(int dayIndex) {
    if (dayIndex < 0 || dayIndex >= _weekdayTranslationKeys.length) {
      return '';
    }
    return td(ref, _weekdayTranslationKeys[dayIndex]);
  }

  /// Get localized cutoff label
  String _getCutoffLabel(String cutoffType) {
    final translationKey = _cutoffTypeTranslationKeys[cutoffType];
    if (translationKey == null) return cutoffType;
    return td(ref, translationKey);
  }

  /// Build today's preview string (e.g., "I dag: 07:00–10:00, 11:30–14:30" or "I dag: Lukket")
  String _getTodayPreview(Map<String, dynamic> openingHours) {
    // Calculate today's weekday (Monday=1, Sunday=7)
    final now = DateTime.now();
    final weekday = now.weekday;

    // Convert to 0-indexed matching API keys: "0"=Monday, "6"=Sunday
    final todayIndex = weekday - 1;

    final dayHours = _getDayHours(todayIndex, openingHours);

    if (_isDayClosed(dayHours)) {
      return '${_t('today_prefix')}${_t('closed')}';
    }

    // Build time slots string
    final slots = <String>[];
    for (int slot = 1; slot <= _maxTimeSlotsPerDay; slot++) {
      final openingTime = dayHours['opening_time_$slot'] as String?;
      final closingTime = dayHours['closing_time_$slot'] as String?;

      if (openingTime != null && closingTime != null) {
        slots.add('${_formatTime(openingTime)}–${_formatTime(closingTime)}');
      }
    }

    return '${_t('today_prefix')}${slots.join(', ')}';
  }

  /// Get all cutoffs for a specific slot
  List<Map<String, String>> _getSlotCutoffs(
      Map<String, dynamic> dayHours, int slotNumber) {
    final cutoffs = <Map<String, String>>[];
    for (int c = 1; c <= _maxCutoffsPerSlot; c++) {
      final type = dayHours['cutoff_type_${slotNumber}_$c'] as String?;
      final time = dayHours['cutoff_time_${slotNumber}_$c'] as String?;
      if (type != null && time != null) {
        cutoffs.add({
          'type': type,
          'time': time,
        });
      }
    }
    return cutoffs;
  }

  // ============================================================================
  // EVENT HANDLERS
  // ============================================================================

  void _handleToggle() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    _trackExpandToggle();
  }

  Future<void> _handlePhoneTap(String phone) async {
    _trackContactLinkTap('phone');

    final cleanedPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: '+45$cleanedPhone');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(td(ref, 'error_cannot_make_call')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handlePhoneLongPress(String phone) async {
    await Clipboard.setData(ClipboardData(text: '+45$phone'));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_t('copied_to_clipboard')),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleLinkTap(String type, String url) async {
    _trackContactLinkTap(type);

    String fullUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      fullUrl = 'https://$url';
    }

    final uri = Uri.parse(fullUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(td(ref, 'error_cannot_open_website')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleEmailTap(String email) async {
    _trackContactLinkTap('email');

    final uri = Uri(scheme: 'mailto', path: email);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_t('error_cannot_open_email')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleEmailLongPress(String email) async {
    await Clipboard.setData(ClipboardData(text: email));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_t('copied_to_clipboard')),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ============================================================================
  // ANALYTICS
  // ============================================================================

  void _trackExpandToggle() {
    final analytics = AnalyticsService.instance;
    ApiService.instance
        .postAnalytics(
      eventType: 'business_contact_toggled',
      deviceId: analytics.deviceId ?? '',
      sessionId: analytics.currentSessionId ?? '',
      userId: analytics.userId ?? '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'action': _isExpanded ? 'expanded' : 'collapsed',
        'pageName': 'businessProfile',
      },
    )
        .catchError((e) {
      debugPrint('Analytics error: $e');
      return ApiCallResponse.failure('Analytics failed');
    });
  }

  void _trackContactLinkTap(String linkType) {
    final analytics = AnalyticsService.instance;
    final businessId = ref.read(businessProvider.notifier).getCurrentBusinessId();

    ApiService.instance
        .postAnalytics(
      eventType: 'social_link_clicked',
      deviceId: analytics.deviceId ?? '',
      sessionId: analytics.currentSessionId ?? '',
      userId: analytics.userId ?? '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'link_type': linkType, // 'phone', 'email', 'website', 'booking', 'instagram', 'facebook', 'tiktok'
        'business_id': businessId?.toString() ?? '',
        'pageName': 'businessProfile',
      },
    )
        .catchError((e) {
      debugPrint('Analytics error: $e');
      return ApiCallResponse.failure('Analytics failed');
    });
  }

  // ============================================================================
  // UI BUILDERS
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final openingHours = ref.watch(businessProvider).openingHours;

    // Hide widget if no opening hours data
    if (openingHours == null || openingHours.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(openingHours),
        _buildExpandedContent(openingHours),
      ],
    );
  }

  /// Collapsible header (always visible)
  Widget _buildHeader(Map<String, dynamic> openingHours) {
    final todayPreview = _getTodayPreview(openingHours);
    final isClosed = todayPreview.contains(_t('closed'));

    return GestureDetector(
      onTap: _handleToggle,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t('opening_hours_and_contact'),
                  style: AppTypography.sectionHeading,
                ),
                if (!_isExpanded)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      todayPreview,
                      style: AppTypography.chip.copyWith(
                        fontWeight: FontWeight.w400,
                        color: isClosed ? AppColors.red : AppColors.textTertiary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          AnimatedRotation(
            turns: _isExpanded ? 0.5 : 0.0,
            duration: const Duration(milliseconds: 150),
            child: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textMuted,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  /// Expanded content container
  Widget _buildExpandedContent(Map<String, dynamic> openingHours) {
    final business = ref.watch(businessProvider).currentBusiness;

    if (!_isExpanded) {
      return const SizedBox.shrink();
    }

    return AnimatedOpacity(
      opacity: _isExpanded ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 150),
      child: Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgSurface, // #fafafa
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHoursSection(openingHours),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            const SizedBox(height: 16),
            _buildContactSection(business),
          ],
        ),
      ),
    );
  }

  /// Hours section
  Widget _buildHoursSection(Map<String, dynamic> openingHours) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          _t('opening_hours_label'),
          style: AppTypography.chip.copyWith(
            color: const Color(0xFF666666), // Section label gray (not in AppColors)
          ),
        ),
        const SizedBox(height: 10),
        // Days list
        Column(
          children: List.generate(7, (index) {
            final isLastRow = index == 6;
            return Column(
              children: [
                _buildDayRow(index, openingHours),
                if (!isLastRow)
                  const Divider(height: 1, thickness: 1, color: Color(0xFFECECEC)), // Lighter divider for row separation
              ],
            );
          }),
        ),
      ],
    );
  }

  /// Single day row (day name + time slots)
  Widget _buildDayRow(int dayIndex, Map<String, dynamic> openingHours) {
    final dayHours = _getDayHours(dayIndex, openingHours);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              _getDayName(dayIndex),
              style: AppTypography.bodyTiny.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF333333),
              ),
            ),
          ),
          Expanded(
            child: _buildTimeSlots(dayHours),
          ),
        ],
      ),
    );
  }

  /// Time slots for a day
  Widget _buildTimeSlots(Map<String, dynamic> dayHours) {
    if (_isDayClosed(dayHours)) {
      return Text(
        _t('closed'),
        style: AppTypography.bodyTiny.copyWith(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: AppColors.red,
        ),
      );
    }

    // Build list of time slots
    final slots = <Widget>[];
    for (int slot = 1; slot <= _maxTimeSlotsPerDay; slot++) {
      final openingTime = dayHours['opening_time_$slot'] as String?;
      final closingTime = dayHours['closing_time_$slot'] as String?;

      if (openingTime != null && closingTime != null) {
        final cutoffs = _getSlotCutoffs(dayHours, slot);

        if (slots.isNotEmpty) {
          slots.add(const SizedBox(height: 2));
        }

        slots.add(_buildTimeSlot(openingTime, closingTime, cutoffs));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: slots,
    );
  }

  /// Single time slot with optional cutoff notes
  Widget _buildTimeSlot(
    String openingTime,
    String closingTime,
    List<Map<String, String>> cutoffs,
  ) {
    final hoursText = '${_formatTime(openingTime)}–${_formatTime(closingTime)}';

    if (cutoffs.isEmpty) {
      return Text(
        hoursText,
        style: AppTypography.bodyTiny.copyWith(
          fontSize: 13.5,
          color: const Color(0xFF444444),
        ),
      );
    }

    // Build cutoff text: "(Kitchen: 22:00, Last order: 23:30)"
    final cutoffParts = cutoffs.map((c) {
      final label = _getCutoffLabel(c['type']!);
      return '$label: ${_formatTime(c['time'])}';
    }).join(', ');
    final cutoffText = '($cutoffParts)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hoursText,
          style: AppTypography.bodyTiny.copyWith(
            fontSize: 13.5,
            color: const Color(0xFF444444),
          ),
        ),
        Text(
          cutoffText,
          style: AppTypography.chip.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  /// Contact section
  Widget _buildContactSection(Map<String, dynamic>? business) {
    if (business == null) return const SizedBox.shrink();

    final phone = business['general_phone'] as String?;
    final email = business['general_email'] as String?;
    final website = business['website_url'] as String?;
    final instagram = business['instagram_url'] as String?;
    final facebook = business['facebook_url'] as String?;
    final tiktok = business['tiktok_url'] as String?; // Not in API yet, but UI ready
    final booking = business['reservation_url'] as String?;

    // Collect available contact fields
    final contactFields = <Widget>[];

    if (phone != null && phone.isNotEmpty) {
      // Format phone with +45 prefix and preserve spacing
      final formattedPhone = '+45 ${phone.replaceAll(RegExp(r'\s+'), ' ')}';
      contactFields.add(_buildContactRow(
        label: _t('phone_number_label'),
        value: formattedPhone,
        valueColor: AppColors.accent,
        onTap: () => _handlePhoneTap(phone),
        onLongPress: () => _handlePhoneLongPress(phone),
      ));
    }

    if (email != null && email.isNotEmpty) {
      contactFields.add(_buildContactRow(
        label: _t('email_label'),
        value: _t('send_email_action'),
        valueColor: AppColors.accent,
        onTap: () => _handleEmailTap(email),
        onLongPress: () => _handleEmailLongPress(email),
      ));
    }

    if (website != null && website.isNotEmpty) {
      contactFields.add(_buildContactRow(
        label: _t('website'),
        value: _t('visit_website_action'),
        valueColor: AppColors.accent,
        onTap: () => _handleLinkTap('website', website),
      ));
    }

    if (instagram != null && instagram.isNotEmpty) {
      contactFields.add(_buildContactRow(
        label: _t('instagram'),
        value: _t('view_instagram_action'),
        valueColor: AppColors.accent,
        onTap: () => _handleLinkTap('instagram', instagram),
      ));
    }

    if (facebook != null && facebook.isNotEmpty) {
      contactFields.add(_buildContactRow(
        label: _t('facebook_label'),
        value: _t('view_facebook_action'),
        valueColor: AppColors.accent,
        onTap: () => _handleLinkTap('facebook', facebook),
      ));
    }

    if (tiktok != null && tiktok.isNotEmpty) {
      contactFields.add(_buildContactRow(
        label: _t('tiktok_label'),
        value: _t('view_tiktok_action'),
        valueColor: AppColors.accent,
        onTap: () => _handleLinkTap('tiktok', tiktok),
      ));
    }

    if (booking != null && booking.isNotEmpty) {
      contactFields.add(_buildContactRow(
        label: _t('booking'),
        value: _t('make_reservation_action'),
        valueColor: AppColors.accent,
        onTap: () => _handleLinkTap('booking', booking),
      ));
    }

    // Hide section if no contact fields
    if (contactFields.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          _t('contact_label'),
          style: AppTypography.chip.copyWith(
            color: const Color(0xFF666666), // Section label gray (not in AppColors)
          ),
        ),
        const SizedBox(height: 10),
        // Contact fields with dividers
        Column(
          children: List.generate(contactFields.length, (index) {
            final isLastRow = index == contactFields.length - 1;
            return Column(
              children: [
                contactFields[index],
                if (!isLastRow)
                  const Divider(height: 1, thickness: 1, color: Color(0xFFECECEC)), // Lighter divider for row separation
              ],
            );
          }),
        ),
      ],
    );
  }

  /// Single contact row
  Widget _buildContactRow({
    required String label,
    required String value,
    required Color valueColor,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyRegular.copyWith(
              fontSize: 14,
              color: const Color(0xFF555555),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Text(
              value,
              style: AppTypography.bodyRegular.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
