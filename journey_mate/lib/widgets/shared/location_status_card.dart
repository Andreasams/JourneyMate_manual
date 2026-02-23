import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import '../../services/translation_service.dart';
import '../../providers/settings_providers.dart';

/// Location Status Card
///
/// Displays current location permission status with:
/// - Location pin icon
/// - Status indicator (red dot = disabled, green dot = enabled)
/// - Status text ("Enabled" or "Disabled")
/// - Context message explaining current state
///
/// Used on Localization page to show location sharing status at-a-glance.
class LocationStatusCard extends ConsumerWidget {
  const LocationStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPermission = ref.watch(locationProvider).hasPermission;

    return Container(
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
                      style: AppTypography.bodyMedium.copyWith(
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
                      style: AppTypography.bodySmall.copyWith(
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
                  style: AppTypography.helper.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
