import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:map_launcher/map_launcher.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import '../../providers/business_providers.dart';
import '../../services/translation_service.dart';
import '../../services/analytics_service.dart';
import '../../services/api_service.dart';

/// Quick Actions Widget - Horizontal scrollable row of 4 action pills
///
/// Features:
/// - Call pill (phone icon) - opens phone dialer
/// - Website pill (language icon) - opens browser
/// - Booking pill (restaurant icon) - opens booking URL
/// - Map pill (map icon) - opens map app
/// - Pills conditionally enabled based on data availability
/// - Self-contained (reads from businessProvider internally)
///
/// Design:
/// - 4 pills with 8px gap between them
/// - 24px horizontal page padding
/// - borderRadius: 14px (AppRadius.button)
/// - padding: 12px vertical, 16px horizontal
/// - Disabled pills have reduced opacity
class QuickActionsWidget extends ConsumerWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(businessProvider).currentBusiness;

    if (business == null) {
      return const SizedBox.shrink();
    }

    // Extract business data
    final phone = business['phone_number'] as String?;
    final website = business['website'] as String?;
    final bookingUrl = business['booking_url'] as String?;
    final latitude = business['address']?['latitude'] as double?;
    final longitude = business['address']?['longitude'] as double?;
    final businessName = business['business_name'] as String?;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildPill(
              context: context,
              ref: ref,
              icon: Icons.phone,
              label: td(ref, 'action_call'),
              enabled: phone != null && phone.isNotEmpty,
              onTap: () => _handleCallTap(context, ref, phone),
            ),
            SizedBox(width: AppSpacing.sm),
            _buildPill(
              context: context,
              ref: ref,
              icon: Icons.language,
              label: td(ref, 'action_website'),
              enabled: website != null && website.isNotEmpty,
              onTap: () => _handleWebsiteTap(context, ref, website),
            ),
            SizedBox(width: AppSpacing.sm),
            _buildPill(
              context: context,
              ref: ref,
              icon: Icons.restaurant,
              label: td(ref, 'action_booking'),
              enabled: bookingUrl != null && bookingUrl.isNotEmpty,
              onTap: () => _handleBookingTap(context, ref, bookingUrl),
            ),
            SizedBox(width: AppSpacing.sm),
            _buildPill(
              context: context,
              ref: ref,
              icon: Icons.map,
              label: td(ref, 'action_map'),
              enabled: latitude != null && longitude != null,
              onTap: () => _handleMapTap(
                context,
                ref,
                latitude,
                longitude,
                businessName ?? 'Restaurant',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual action pill
  Widget _buildPill({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: enabled ? AppColors.accent : AppColors.bgSurface,
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: enabled ? Colors.white : AppColors.textTertiary,
                size: 18,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: enabled ? Colors.white : AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle call tap - open phone dialer
  Future<void> _handleCallTap(
    BuildContext context,
    WidgetRef ref,
    String? phone,
  ) async {
    if (phone == null || phone.isEmpty) return;

    // Track analytics
    _trackQuickAction(ref, 'call');

    // Remove all non-numeric characters except '+'
    final cleanedPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanedPhone');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(td(ref, 'error_cannot_make_call')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Handle website tap - open browser
  Future<void> _handleWebsiteTap(
    BuildContext context,
    WidgetRef ref,
    String? website,
  ) async {
    if (website == null || website.isEmpty) return;

    // Track analytics
    _trackQuickAction(ref, 'website');

    // Ensure URL has scheme
    String url = website;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(td(ref, 'error_cannot_open_website')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Handle booking tap - open booking URL
  Future<void> _handleBookingTap(
    BuildContext context,
    WidgetRef ref,
    String? bookingUrl,
  ) async {
    if (bookingUrl == null || bookingUrl.isEmpty) return;

    // Track analytics
    _trackQuickAction(ref, 'booking');

    // Ensure URL has scheme
    String url = bookingUrl;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(td(ref, 'error_cannot_open_booking')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Handle map tap - open map app
  Future<void> _handleMapTap(
    BuildContext context,
    WidgetRef ref,
    double? latitude,
    double? longitude,
    String businessName,
  ) async {
    if (latitude == null || longitude == null) return;

    // Track analytics
    _trackQuickAction(ref, 'map');

    try {
      final coords = Coords(latitude, longitude);
      final availableMaps = await MapLauncher.installedMaps;

      if (availableMaps.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(td(ref, 'error_no_map_app')),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // Show map picker if multiple apps available
      if (context.mounted) {
        await availableMaps.first.showMarker(
          coords: coords,
          title: businessName,
        );
      }
    } catch (e) {
      debugPrint('Error opening map: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(td(ref, 'error_cannot_open_map')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Track quick action analytics
  void _trackQuickAction(WidgetRef ref, String actionType) {
    final analytics = AnalyticsService.instance;
    ApiService.instance
        .postAnalytics(
      eventType: 'quick_action_tapped',
      deviceId: analytics.deviceId ?? '',
      sessionId: analytics.currentSessionId ?? '',
      userId: analytics.userId ?? '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'pageName': 'businessProfile',
        'actionType': actionType,
      },
    )
        .catchError((e) {
      debugPrint('Analytics error: $e');
      return ApiCallResponse.failure('Analytics failed');
    });
  }
}
