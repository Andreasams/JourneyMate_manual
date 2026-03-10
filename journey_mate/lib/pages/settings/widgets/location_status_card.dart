import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_radius.dart';
import '../../../services/translation_service.dart';
import '../../../services/api_service.dart';
import '../../../services/analytics_service.dart';
import '../../../providers/settings_providers.dart';

/// Location Status Card
///
/// Displays current location permission status with:
/// - Location pin icon
/// - Status indicator (red dot = disabled, green dot = enabled)
/// - Status text ("Enabled" or "Disabled")
/// - Context message explaining current state
/// - Chevron icon indicating tappability
///
/// Tapping the card:
/// - When disabled: shows iOS permission dialog (first time) or opens Settings (if denied)
/// - When enabled: opens Settings for management
///
/// Used on Localization page to show location sharing status at-a-glance.
class LocationStatusCard extends ConsumerWidget {
  const LocationStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPermission = ref.watch(locationProvider).isLocationUsable;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Fire-and-forget analytics
          final analytics = AnalyticsService.instance;
          ApiService.instance.postAnalytics(
            eventType: hasPermission
                ? 'location_manage_tapped'
                : 'location_enable_tapped',
            deviceId: analytics.deviceId ?? '',
            sessionId: analytics.currentSessionId ?? '',
            userId: analytics.userId ?? '',
            timestamp: DateTime.now().toIso8601String(),
            eventData: {'source': 'localization_page'},
          ).catchError((_) => ApiCallResponse.failure('Analytics failed'));

          // Smart enable: dialog if first time, Settings if denied
          ref.read(locationProvider.notifier).enableLocation();
        },
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.bgCardSubtle,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: AppColors.border,
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location pin icon
              Icon(
                Icons.location_on,
                size: 20,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: AppSpacing.sm),

              // Content column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label + Status row
                    Row(
                      children: [
                        Text(
                          td(ref, 'location_label_sharing'), // "Location sharing"
                          style: AppTypography.bodyLgMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Status dot
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: hasPermission
                                ? AppColors.statusEnabled
                                : AppColors.statusDisabled,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Status text
                        Text(
                          hasPermission
                              ? td(ref, 'location_status_enabled') // "Enabled"
                              : td(ref, 'location_status_disabled'), // "Disabled"
                          style: AppTypography.bodyMedium.copyWith(
                            color: hasPermission
                                ? AppColors.statusEnabled
                                : AppColors.statusDisabled,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Context message
                    Text(
                      hasPermission
                          ? td(ref,
                              'location_hint_enabled') // "We can show you restaurants near you"
                          : td(ref,
                              'location_hint_disabled'), // "Enable to see nearby restaurants"
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              // Chevron to indicate tappability
              Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
