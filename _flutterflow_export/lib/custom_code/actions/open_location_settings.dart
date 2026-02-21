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

import 'package:permission_handler/permission_handler.dart';

/// Opens device settings for the user to manually enable location permission.
///
/// This is the recommended approach when:
/// - Permission was previously denied
/// - Permission is permanently denied
/// - User wants to enable location after initial setup
///
/// This action:
/// 1. Checks current permission status
/// 2. Opens device settings directly (no system dialog)
/// 3. Tracks analytics for the action
///
/// Note: After returning from settings, the app will automatically
/// detect the permission change on app resume via checkLocationPermissionAndTrack.
///
/// Args:
///   source: Context where settings was opened (e.g., 'settings_page')
///
/// Returns:
///   void - Always opens settings regardless of current status
Future<void> openLocationSettings(String source) async {
  debugPrint('⚙️ Opening device settings for location (source: $source)');

  try {
    // Check current status for analytics
    final currentStatus = await Permission.location.status;

    // Track the action
    await trackAnalyticsEvent('location_settings_opened', {
      'source': source,
      'currentStatus': currentStatus.toString(),
      'isGranted': currentStatus.isGranted,
    });

    // Open device settings
    // User will manually enable location there
    await openAppSettings();

    debugPrint('✅ Device settings opened');
    debugPrint('   User can enable location manually');
    debugPrint('   Permission will be detected on app resume');
  } catch (error) {
    debugPrint('❌ Error opening settings: $error');

    // Track error
    try {
      await trackAnalyticsEvent('location_settings_error', {
        'source': source,
        'error': error.toString(),
      });
    } catch (analyticsError) {
      debugPrint('⚠️ Failed to track error: $analyticsError');
    }
  }
}
