import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import '../../services/translation_service.dart';
import '../../services/api_service.dart';
import '../../services/analytics_service.dart';
import '../../providers/settings_providers.dart';

/// Location Sharing Page (Phase 7.9)
///
/// Two-state UI for location permission management:
/// - State 1 (OFF): Encourages enabling location with instructions
/// - State 2 (ON): Confirms location is enabled with disable instructions
///
/// On page load: Checks current location permission status
/// Button action: Opens system location settings
///
/// Analytics: Tracks page_viewed with duration on dispose
class LocationSharingPage extends ConsumerStatefulWidget {
  const LocationSharingPage({super.key});

  @override
  ConsumerState<LocationSharingPage> createState() => _LocationSharingPageState();
}

class _LocationSharingPageState extends ConsumerState<LocationSharingPage> with WidgetsBindingObserver {
  DateTime? _pageStartTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _pageStartTime = DateTime.now();
      // Check location permission on page load
      await _checkLocationPermission();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Track page view analytics with duration
    if (_pageStartTime != null) {
      final durationSeconds = DateTime.now().difference(_pageStartTime!).inSeconds;
      final analytics = AnalyticsService.instance;
      // Fire-and-forget analytics call
      ApiService.instance.postAnalytics(
        eventType: 'page_viewed',
        deviceId: analytics.deviceId ?? '',
        sessionId: analytics.currentSessionId ?? '',
        userId: analytics.userId ?? '',
        timestamp: DateTime.now().toIso8601String(),
        eventData: {
          'pageName': 'locationSharingSettings',
          'durationSeconds': durationSeconds,
        },
      ).catchError((_) => ApiCallResponse.failure('Analytics failed'));
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check permission when app resumes (user returns from system settings)
    if (state == AppLifecycleState.resumed) {
      _checkLocationPermission();
    }
  }

  /// Check current location permission status
  Future<void> _checkLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    final hasPermission = permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;

    if (mounted) {
      ref.read(locationProvider.notifier).setPermission(hasPermission);
    }
  }

  /// Open system location settings
  Future<void> _openLocationSettings() async {
    await ph.openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    final hasPermission = ref.watch(locationProvider).hasPermission;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          td(ref, 'k1c3fupg'), // "Location sharing"
          style: AppTypography.categoryHeading,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Conditional rendering based on permission state
              if (!hasPermission) ...[
                // STATE 1: Location OFF
                _buildLocationOffState(context),
              ] else ...[
                // STATE 2: Location ON
                _buildLocationOnState(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the UI for location permission OFF state
  Widget _buildLocationOffState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Heading
        Text(
          td(ref, 'u0wnvdeg'), // "Turn on location sharing"
          style: AppTypography.pageTitle.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Description (instructions)
        Text(
          td(ref, 'tht0e2um'), // "To turn on location sharing, t..."
          style: AppTypography.bodyRegular,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Button
        SizedBox(
          width: 270,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
            onPressed: _openLocationSettings,
            child: Text(
              td(ref, '3r57tlpr'), // "Turn on location sharing"
              style: AppTypography.button,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Privacy note
        Text(
          td(ref, 'iucaz964'), // "Your location is exclusively u..."
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Builds the UI for location permission ON state
  Widget _buildLocationOnState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Heading
        Text(
          td(ref, 'z1v9fk1m'), // "Location sharing is turned on"
          style: AppTypography.pageTitle.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Description (instructions)
        Text(
          td(ref, 'd9nsgosc'), // "You can turn off location shar..."
          style: AppTypography.bodyRegular,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Button
        SizedBox(
          width: 270,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
            onPressed: _openLocationSettings,
            child: Text(
              td(ref, '2hj5mmov'), // "Go to Settings"
              style: AppTypography.button,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Privacy note
        Text(
          td(ref, 'bhki1oos'), // "Your location is exclusively u..."
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
