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

import 'package:permission_handler/permission_handler.dart';

/// Checks current location permission status and updates FFAppState.
///
/// This is a PASSIVE check - it does NOT request permission, only checks the
/// current status. Use this when you want to verify permission state without
/// showing a system dialog.
///
/// Common use cases: - App resume: Check if user enabled location in device
/// settings - Page navigation: Verify permission before showing location
/// features - Initial app load: Set correct state without prompting user
///
/// This action tracks analytics when it detects a status CHANGE, which
/// happens when: - User enables permission in iOS Settings and returns to app
/// - User disables permission in iOS Settings and returns to app - Permission
/// state changes due to system policy
///
/// Args: source: Context where check occurred. Examples: 'app_resume' - App
/// returned to foreground 'page_load' - Checking on page initialization
/// 'feature_gate' - Verifying before showing location feature
///
/// Returns: bool - true if permission is currently granted, false otherwise
///
/// Side Effects: - Updates FFAppState().locationStatus - Sends
/// 'location_permission_changed' analytics (if status changed) - Logs
/// permission status to debug console
Future<bool> checkLocationPermissionAndTrack(String source) async {
  debugPrint('📍 Checking location permission status (source: $source)...');

  // Validate source parameter
  if (source.isEmpty) {
    debugPrint('⚠️ Warning: source parameter is empty, using "unknown"');
    source = 'unknown';
  }

  try {
    // Capture previous state BEFORE checking
    final previousStatus = FFAppState().locationStatus;

    // Check current permission status (NO REQUEST)
    final permissionStatus = await Permission.location.status;

    // Determine if permission is granted
    final isGranted = permissionStatus.isGranted;

    // Update app state
    FFAppState().update(() {
      FFAppState().locationStatus = isGranted;
    });

    // Determine human-readable permission result
    String permissionResult;
    if (permissionStatus.isGranted) {
      permissionResult = 'granted';
      debugPrint('✅ Location permission: granted');
    } else if (permissionStatus.isDenied) {
      permissionResult = 'denied';
      debugPrint('❌ Location permission: denied');
    } else if (permissionStatus.isPermanentlyDenied) {
      permissionResult = 'permanentlyDenied';
      debugPrint('🚫 Location permission: permanently denied');
    } else if (permissionStatus.isRestricted) {
      permissionResult = 'restricted';
      debugPrint('⚠️ Location permission: restricted');
    } else if (permissionStatus.isLimited) {
      permissionResult = 'limited';
      debugPrint('⚡ Location permission: limited (approximate)');
    } else {
      permissionResult = 'unknown';
      debugPrint('❓ Location permission: unknown');
    }

    // Track analytics ONLY if status changed
    if (previousStatus != isGranted) {
      debugPrint('📊 Permission status changed, tracking analytics...');

      try {
        await trackAnalyticsEvent('location_permission_changed', {
          'previousStatus': previousStatus,
          'newStatus': isGranted,
          'permissionResult': permissionResult,
          'source': source,
          'wasPassiveCheck': true, // Flag to distinguish from active requests
        });

        debugPrint(
            '✅ Analytics tracked: $permissionResult from $source (passive)');
      } catch (analyticsError) {
        debugPrint('⚠️ Analytics tracking failed: $analyticsError');
        // Don't fail the entire operation if analytics fails
      }
    } else {
      debugPrint(
          '⏭️  Permission status unchanged ($isGranted), skipping analytics');
    }

    return isGranted;
  } catch (error) {
    debugPrint('❌ Error checking location permission: $error');

    // Don't change state on check errors - keep existing state
    debugPrint('   Maintaining existing state: ${FFAppState().locationStatus}');

    return FFAppState().locationStatus;
  }
}
