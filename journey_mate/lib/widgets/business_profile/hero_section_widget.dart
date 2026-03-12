import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/lat_lng.dart';
import '../../providers/app_providers.dart';
import '../../providers/business_providers.dart';
import '../../providers/settings_providers.dart';
import '../../services/custom_functions/address_formatter.dart';
import '../../services/custom_functions/business_status.dart';
import '../../services/custom_functions/distance_calculator.dart';
import '../../services/custom_functions/hours_formatter.dart';
import '../../services/custom_functions/price_formatter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';

/// Hero Section Widget - Business logo, name, and key details
///
/// Displays (matching FlutterFlow ProfileTopBusinessBlockWidget):
/// - Business logo (64x64 circle with colored background + initial)
/// - Business name (large heading)
/// - Row 1: Open/Closed status + timing (e.g. "Åben • til 18:00")
/// - Row 2: Business type + price range + distance (e.g. "Restaurant • 140-230 kr. • 1.2 km.")
/// - Row 3: Address with neighbourhood (via streetAndNeighbourhoodLength)
///
/// Self-contained: reads from businessProvider internally
/// Status/timing computed via shared utilities (same as search cards)
class HeroSectionWidget extends ConsumerWidget {
  const HeroSectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessState = ref.watch(businessProvider);
    final business = businessState.currentBusiness;

    if (business == null) {
      return const SizedBox.shrink();
    }

    // --- Data extraction (real API fields) ---
    final businessName = business['business_name'] as String? ?? '';
    final street = business['street'] as String? ?? '';
    final neighbourhoodName = business['neighbourhood_name'] as String? ?? '';
    final businessType = business['business_type'] as String? ?? '';
    final latitude = business['latitude'] as double?;
    final longitude = business['longitude'] as double?;

    // --- Logo / Profile picture ---
    final profilePictureUrl = business['profile_picture_url'] as String?;
    final logoInitial = _getBusinessInitial(businessName);
    final logoColor = _getLogoColor(business);

    // --- Status & timing (same utilities as search cards) ---
    final openingHours = businessState.openingHours;
    final languageCode = Localizations.localeOf(context).languageCode;
    final translationsCache = ref.watch(mergedTranslationsCacheProvider);

    String? statusText;
    Color? statusColor;
    String? timingText;

    if (openingHours != null) {
      final now = DateTime.now();
      final statusResult = determineStatusAndColor(
        openingHours,
        now,
        languageCode,
        translationsCache,
      );
      statusText = statusResult['text'] as String?;
      statusColor = statusResult['color'] as Color?;

      timingText = openClosesAt(
        openingHours,
        now,
        languageCode,
        translationsCache,
      );
    }

    // --- Price range (same utility as search cards) ---
    final priceRangeMin = business['price_range_min'] as num?;
    final priceRangeMax = business['price_range_max'] as num?;
    final localization = ref.watch(localizationProvider);
    final exchangeRate = localization.exchangeRate;
    final userCurrencyCode = localization.currencyCode;

    String? priceRangeText;
    if (priceRangeMin != null && priceRangeMax != null) {
      priceRangeText = convertAndFormatPriceRange(
        priceRangeMin.toDouble(),
        priceRangeMax.toDouble(),
        'DKK',
        exchangeRate,
        userCurrencyCode,
        forceNoDecimals: true,
      );
    }

    // --- Distance (same logic as search cards) ---
    final distanceText = _getDistanceText(
      ref: ref,
      languageCode: languageCode,
      latitude: latitude,
      longitude: longitude,
    );

    // --- Address with neighbourhood (same as FlutterFlow) ---
    final addressText = (street.isNotEmpty && neighbourhoodName.isNotEmpty)
        ? streetAndNeighbourhoodLength(neighbourhoodName, street)
        : street;

    // Whether Row 2 has any content (to avoid empty row + spacing)
    final hasRow2 = businessType.isNotEmpty ||
        (priceRangeText != null && priceRangeText.isNotEmpty) ||
        distanceText != null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile picture (with colored initial fallback)
        _buildProfileImage(profilePictureUrl, logoColor, logoInitial),
        SizedBox(width: AppSpacing.lg),

        // Business details (name, 3 info rows)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Business name
              Text(
                businessName,
                style: AppTypography.h2,
              ),
              SizedBox(height: AppSpacing.xs),

              // Row 1: Open/Closed status + timing
              Row(
                children: [
                  if (statusText != null && statusText.isNotEmpty)
                    Text(
                      statusText,
                      style: AppTypography.body.copyWith(
                        color: statusColor ?? AppColors.green,
                      ),
                    ),
                  if (timingText != null && timingText.isNotEmpty) ...[
                    SizedBox(width: AppSpacing.xsm),
                    _buildDot(),
                    SizedBox(width: AppSpacing.xsm),
                    Flexible(
                      child: Text(
                        timingText,
                        style: AppTypography.body,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              // Row 2: Business type + price range + distance
              if (hasRow2) ...[
                SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    if (businessType.isNotEmpty)
                      Flexible(
                        child: Text(
                          businessType,
                          style: AppTypography.body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (priceRangeText != null &&
                        priceRangeText.isNotEmpty) ...[
                      if (businessType.isNotEmpty) ...[
                        SizedBox(width: AppSpacing.xsm),
                        _buildDot(),
                        SizedBox(width: AppSpacing.xsm),
                      ],
                      Text(
                        priceRangeText,
                        style: AppTypography.body,
                      ),
                    ],
                    if (distanceText != null) ...[
                      if (businessType.isNotEmpty ||
                          (priceRangeText != null &&
                              priceRangeText.isNotEmpty)) ...[
                        SizedBox(width: AppSpacing.xsm),
                        _buildDot(),
                        SizedBox(width: AppSpacing.xsm),
                      ],
                      Text(
                        distanceText,
                        style: AppTypography.body,
                      ),
                    ],
                  ],
                ),
              ],
              SizedBox(height: AppSpacing.xxs),

              // Row 3: Address with neighbourhood
              if (addressText.isNotEmpty)
                Text(
                  addressText,
                  style: AppTypography.body,
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build profile image: real photo if available, colored initial fallback
  Widget _buildProfileImage(
    String? profilePictureUrl,
    Color logoColor,
    String logoInitial,
  ) {
    Widget fallback() {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: logoColor,
          borderRadius: BorderRadius.circular(AppRadius.logoLarge),
        ),
        child: Center(
          child: Text(
            logoInitial,
            style: AppTypography.h4.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    if (profilePictureUrl == null || profilePictureUrl.isEmpty) {
      return fallback();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.logoLarge),
      child: CachedNetworkImage(
        imageUrl: profilePictureUrl,
        width: 64,
        height: 64,
        fit: BoxFit.scaleDown,
        placeholder: (context, url) => fallback(),
        errorWidget: (context, url, error) => fallback(),
      ),
    );
  }

  /// Get business initial (first letter of name)
  String _getBusinessInitial(String name) {
    if (name.isEmpty) return '?';
    return name[0].toUpperCase();
  }

  /// Get logo background color from business data
  /// Falls back to accent color if no color specified
  Color _getLogoColor(Map<String, dynamic> business) {
    final logoColorHex = business['logo_color'] as String?;
    if (logoColorHex != null && logoColorHex.isNotEmpty) {
      try {
        final hexColor = logoColorHex.replaceAll('#', '');
        return Color(int.parse('FF$hexColor', radix: 16));
      } catch (_) { // ignore: empty_catches
      }
    }
    return AppColors.accent;
  }

  /// Get distance text from user location to business.
  /// Uses shared formatDistanceText from distance_calculator.dart.
  /// Same logic as search cards: imperial only for English, metric for all others.
  String? _getDistanceText({
    required WidgetRef ref,
    required String languageCode,
    required double? latitude,
    required double? longitude,
  }) {
    final userLocation = ref.read(locationProvider).currentPosition;

    if (userLocation == null || latitude == null || longitude == null) {
      return null;
    }

    // Non-English: ALWAYS metric. English: use stored preference.
    final distanceUnit = languageCode == 'en'
        ? ref.read(localizationProvider).distanceUnit
        : 'metric';

    final userLatLng = LatLng(
      userLocation.latitude,
      userLocation.longitude,
    );

    final distance = returnDistance(
      userLatLng,
      latitude,
      longitude,
      distanceUnit,
    );

    return formatDistanceText(distance, distanceUnit);
  }

  /// Build a dot separator (3x3 circle, light gray)
  Widget _buildDot() {
    return Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        color: AppColors.dotSeparator,
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }
}
