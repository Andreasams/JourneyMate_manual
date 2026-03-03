import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/business_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';

/// Hero Section Widget - Business logo, name, and key details
///
/// Displays:
/// - Business logo (64x64 circle with colored background + initial)
/// - Business name (large heading)
/// - Cuisine type (gray subtitle)
/// - Status row: Open/Closed + closing time + price range
/// - Address
///
/// Design matches JSX lines 161-176
/// Self-contained: reads from businessProvider internally
class HeroSectionWidget extends ConsumerWidget {
  const HeroSectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(businessProvider).currentBusiness;

    if (business == null) {
      return const SizedBox.shrink();
    }

    // Extract business data
    final businessName = business['business_name'] as String? ?? '';
    final cuisineType = business['cuisine_type'] as String? ?? '';
    final priceRange = business['price_range'] as String? ?? '';
    final statusOpen = business['status_open'] as bool? ?? false;
    final closingTime = business['closing_time'] as String? ?? '';
    final addressLine = business['address']?['address_line'] as String? ?? '';

    // Logo data
    final logoInitial = _getBusinessInitial(businessName);
    final logoColor = _getLogoColor(business);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo circle
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: logoColor,
            borderRadius: BorderRadius.circular(AppRadius.logoLarge),
          ),
          child: Center(
            child: Text(
              logoInitial,
              style: AppTypography.sectionHeading.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.lg),

        // Business details (name, cuisine, status, address)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Business name
              Text(
                businessName,
                style: AppTypography.restaurantName.copyWith(
                  fontSize: 24,
                  letterSpacing: -0.72,
                ),
              ),
              SizedBox(height: AppSpacing.xs),

              // Cuisine type
              Text(
                cuisineType,
                style: AppTypography.viewToggle.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppColors.textTertiary,
                ),
              ),
              SizedBox(height: AppSpacing.xxs),

              // Status row: Open/Closed + dots + closing time + price range
              Row(
                children: [
                  // Status (Open/Closed)
                  Text(
                    statusOpen ? 'Åben' : 'Lukket',
                    style: AppTypography.chip.copyWith(
                      fontSize: 13,
                      color: statusOpen ? AppColors.green : AppColors.red,
                    ),
                  ),

                  if (closingTime.isNotEmpty) ...[
                    SizedBox(width: AppSpacing.xsm),
                    _buildDot(),
                    SizedBox(width: AppSpacing.xsm),
                    Text(
                      'til $closingTime',
                      style: AppTypography.viewToggle.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],

                  if (priceRange.isNotEmpty) ...[
                    SizedBox(width: AppSpacing.xsm),
                    _buildDot(),
                    SizedBox(width: AppSpacing.xsm),
                    Text(
                      priceRange,
                      style: AppTypography.viewToggle.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 3),

              // Address
              if (addressLine.isNotEmpty)
                Text(
                  addressLine,
                  style: AppTypography.viewToggle.copyWith(
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPlaceholder,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Get business initial (first letter or first 2 letters)
  String _getBusinessInitial(String name) {
    if (name.isEmpty) return '?';

    // Check if name has multiple words
    final words = name.trim().split(' ');
    if (words.length >= 2 && words[0].isNotEmpty && words[1].isNotEmpty) {
      // Use first letter of first two words
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }

    // Use first two letters if available, otherwise just first letter
    if (name.length >= 2) {
      return name.substring(0, 2).toUpperCase();
    }
    return name[0].toUpperCase();
  }

  /// Get logo background color from business data
  /// Falls back to accent color if no color specified
  Color _getLogoColor(Map<String, dynamic> business) {
    final logoColorHex = business['logo_color'] as String?;
    if (logoColorHex != null && logoColorHex.isNotEmpty) {
      try {
        // Remove '#' if present and parse hex color
        final hexColor = logoColorHex.replaceAll('#', '');
        return Color(int.parse('FF$hexColor', radix: 16));
      } catch (e) {
        debugPrint('⚠️ Invalid logo color: $logoColorHex');
      }
    }
    return AppColors.accent;
  }

  /// Build a dot separator (3x3 circle, light gray)
  Widget _buildDot() {
    return Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        color: const Color(0xFFD0D0D0),
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }
}
