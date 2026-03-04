import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:map_launcher/map_launcher.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';
import '../../providers/business_providers.dart';
import '../../providers/app_providers.dart';
import '../../services/translation_service.dart';
import '../../services/api_service.dart';

/// Quick Actions Pills Widget - Horizontal scrollable row of action pills
///
/// Features:
/// - Call pill (phone icon) - opens phone dialer
/// - Website pill (globe icon) - opens browser
/// - Booking pill (calendar icon) - opens booking URL
/// - Map pill (map marker icon) - opens map app
/// - Pills conditionally shown based on data availability
/// - Self-contained (reads from businessProvider internally)
///
/// Design matches JSX lines 179-188:
/// - **White background** with 1.5px light gray border (#e8e8e8)
/// - **Dark gray text and icons** (#444 text, #666 icons)
/// - 10px border radius
/// - 8px gap between pills
/// - Pills scroll horizontally with padding
///
/// IMPORTANT: NOT orange/white like old design! JSX uses white bg + dark text.
class QuickActionsPillsWidget extends ConsumerWidget {
  const QuickActionsPillsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(businessProvider).currentBusiness;

    if (business == null) {
      return const SizedBox.shrink();
    }

    // Extract business data (real API field names)
    final phone = business['general_phone'] as String?;
    final website = business['website_url'] as String?;
    final bookingUrl = business['reservation_url'] as String?;
    final latitude = (business['latitude'] as num?)?.toDouble();
    final longitude = (business['longitude'] as num?)?.toDouble();
    final businessName = business['business_name'] as String?;

    // Build action pills (only show if data available)
    final pills = <Widget>[
      if (phone != null && phone.isNotEmpty)
        _buildPill(
          context: context,
          ref: ref,
          icon: Icons.phone,
          label: td(ref, 'action_call'),
          onTap: () => _handleCallTap(context, ref, phone),
        ),
      if (website != null && website.isNotEmpty)
        _buildPill(
          context: context,
          ref: ref,
          icon: Icons.language,
          label: td(ref, 'action_website'),
          onTap: () => _handleWebsiteTap(context, ref, website),
        ),
      if (bookingUrl != null && bookingUrl.isNotEmpty)
        _buildPill(
          context: context,
          ref: ref,
          icon: Icons.calendar_today,
          label: td(ref, 'action_booking'),
          onTap: () => _handleBookingTap(context, ref, bookingUrl),
        ),
      // Map is always shown (even if no coordinates, we can show error)
      _buildPill(
        context: context,
        ref: ref,
        icon: Icons.place,
        label: td(ref, 'action_map'),
        onTap: () => _handleMapTap(
          context,
          ref,
          latitude,
          longitude,
          businessName ?? 'Restaurant',
        ),
      ),
    ];

    if (pills.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(right: AppSpacing.xxl),
      child: Row(
        children: pills
            .expand((pill) => [pill, SizedBox(width: AppSpacing.sm)])
            .toList()
          ..removeLast(), // Remove trailing gap
      ),
    );
  }

  /// Build a single action pill (white bg, dark text/icons)
  /// JSX styling: white bg, 1.5px #e8e8e8 border, dark text/icons
  Widget _buildPill({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.filter),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.filter),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.mlg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.border,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(AppRadius.filter),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: AppSpacing.xsm),
              Text(
                label,
                style: AppTypography.chip.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // EVENT HANDLERS
  // ============================================================================

  Future<void> _handleCallTap(
      BuildContext context, WidgetRef ref, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;

    final business = ref.read(businessProvider).currentBusiness;
    final businessId = business?['business_id'] as int?;

    try {
      final uri = Uri.parse('tel:$phoneNumber');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);

        // Track call action
        final analyticsState = ref.read(analyticsProvider);
        ApiService.instance.postAnalytics(
          eventType: 'business_call_tapped',
          deviceId: analyticsState.deviceId,
          sessionId: analyticsState.sessionId ?? '',
          userId: '', // Anonymous user
          timestamp: DateTime.now().toIso8601String(),
          eventData: {
            'business_id': businessId ?? 0,
            'phone_number': phoneNumber,
          },
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(td(ref, 'error_cannot_make_call'))),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error launching phone dialer: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(td(ref, 'error_cannot_make_call'))),
        );
      }
    }
  }

  Future<void> _handleWebsiteTap(
      BuildContext context, WidgetRef ref, String? websiteUrl) async {
    if (websiteUrl == null || websiteUrl.isEmpty) return;

    final business = ref.read(businessProvider).currentBusiness;
    final businessId = business?['business_id'] as int?;

    try {
      // Ensure URL has protocol
      String url = websiteUrl;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // Track website tap
        final analyticsState = ref.read(analyticsProvider);
        ApiService.instance.postAnalytics(
          eventType: 'business_website_tapped',
          deviceId: analyticsState.deviceId,
          sessionId: analyticsState.sessionId ?? '',
          userId: '', // Anonymous user
          timestamp: DateTime.now().toIso8601String(),
          eventData: {
            'business_id': businessId ?? 0,
            'website_url': websiteUrl,
          },
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(td(ref, 'error_cannot_open_website'))),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error launching website: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(td(ref, 'error_cannot_open_website'))),
        );
      }
    }
  }

  Future<void> _handleBookingTap(
      BuildContext context, WidgetRef ref, String? bookingUrl) async {
    if (bookingUrl == null || bookingUrl.isEmpty) return;

    final business = ref.read(businessProvider).currentBusiness;
    final businessId = business?['business_id'] as int?;

    try {
      // Ensure URL has protocol
      String url = bookingUrl;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // Track booking tap
        final analyticsState = ref.read(analyticsProvider);
        ApiService.instance.postAnalytics(
          eventType: 'business_booking_tapped',
          deviceId: analyticsState.deviceId,
          sessionId: analyticsState.sessionId ?? '',
          userId: '', // Anonymous user
          timestamp: DateTime.now().toIso8601String(),
          eventData: {
            'business_id': businessId ?? 0,
            'booking_url': bookingUrl,
          },
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(td(ref, 'error_cannot_open_booking'))),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error launching booking: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(td(ref, 'error_cannot_open_booking'))),
        );
      }
    }
  }

  Future<void> _handleMapTap(
    BuildContext context,
    WidgetRef ref,
    double? latitude,
    double? longitude,
    String businessName,
  ) async {
    if (latitude == null || longitude == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(td(ref, 'error_no_location_data'))),
        );
      }
      return;
    }

    final business = ref.read(businessProvider).currentBusiness;
    final businessId = business?['business_id'] as int?;

    try {
      final availableMaps = await MapLauncher.installedMaps;

      if (!context.mounted) return;

      if (availableMaps.isEmpty) {
        // Fallback: Use Apple Maps URL scheme (always works on iOS)
        await _launchAppleMaps(context, ref, latitude, longitude, businessName);

        // Track map tap
        final analyticsState = ref.read(analyticsProvider);
        ApiService.instance.postAnalytics(
          eventType: 'business_map_tapped',
          deviceId: analyticsState.deviceId,
          sessionId: analyticsState.sessionId ?? '',
          userId: '',
          timestamp: DateTime.now().toIso8601String(),
          eventData: {
            'business_id': businessId ?? 0,
            'latitude': latitude,
            'longitude': longitude,
            'map_app': 'apple_maps_fallback',
          },
        );
        return;
      }

      // If multiple maps available, show picker dialog
      if (availableMaps.length > 1) {
        await _showMapPicker(
          context,
          ref,
          availableMaps,
          latitude,
          longitude,
          businessName,
          businessId,
        );
      } else {
        // Single map available, open it directly
        await availableMaps.first.showMarker(
          coords: Coords(latitude, longitude),
          title: businessName,
        );

        // Track map tap
        final analyticsState = ref.read(analyticsProvider);
        ApiService.instance.postAnalytics(
          eventType: 'business_map_tapped',
          deviceId: analyticsState.deviceId,
          sessionId: analyticsState.sessionId ?? '',
          userId: '',
          timestamp: DateTime.now().toIso8601String(),
          eventData: {
            'business_id': businessId ?? 0,
            'latitude': latitude,
            'longitude': longitude,
            'map_app': availableMaps.first.mapName,
          },
        );
      }
    } catch (e) {
      debugPrint('❌ Error launching map: $e');
      // Final fallback: Try Apple Maps
      if (context.mounted) {
        try {
          await _launchAppleMaps(context, ref, latitude, longitude, businessName);
        } catch (fallbackError) {
          debugPrint('❌ Fallback to Apple Maps also failed: $fallbackError');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(td(ref, 'error_cannot_open_map'))),
            );
          }
        }
      }
    }
  }

  /// Show a picker dialog to let user choose which map app to use
  Future<void> _showMapPicker(
    BuildContext context,
    WidgetRef ref,
    List<AvailableMap> availableMaps,
    double latitude,
    double longitude,
    String businessName,
    int? businessId,
  ) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.card),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: AppSpacing.mlg),
            Text(
              td(ref, 'choose_map_app'),
              style: AppTypography.sectionHeading,
            ),
            SizedBox(height: AppSpacing.mlg),
            ...availableMaps.map((map) {
              return ListTile(
                leading: Icon(Icons.map, color: AppColors.accent),
                title: Text(
                  map.mapName,
                  style: AppTypography.bodyRegular,
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await map.showMarker(
                    coords: Coords(latitude, longitude),
                    title: businessName,
                  );

                  // Track map tap with chosen app
                  final analyticsState = ref.read(analyticsProvider);
                  ApiService.instance.postAnalytics(
                    eventType: 'business_map_tapped',
                    deviceId: analyticsState.deviceId,
                    sessionId: analyticsState.sessionId ?? '',
                    userId: '',
                    timestamp: DateTime.now().toIso8601String(),
                    eventData: {
                      'business_id': businessId ?? 0,
                      'latitude': latitude,
                      'longitude': longitude,
                      'map_app': map.mapName,
                    },
                  );
                },
              );
            }),
            SizedBox(height: AppSpacing.mlg),
          ],
        ),
      ),
    );
  }

  /// Fallback method to launch Apple Maps (always available on iOS)
  Future<void> _launchAppleMaps(
    BuildContext context,
    WidgetRef ref,
    double latitude,
    double longitude,
    String businessName,
  ) async {
    final uri = Uri.parse(
      'https://maps.apple.com/?q=${Uri.encodeComponent(businessName)}&ll=$latitude,$longitude',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Cannot launch Apple Maps');
    }
  }
}
