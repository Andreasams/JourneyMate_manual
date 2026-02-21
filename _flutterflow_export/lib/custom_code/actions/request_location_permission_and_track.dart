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

/// Requests location permission, updates FFAppState, and tracks analytics.
///
/// This action provides a comprehensive solution for managing location
/// permissions in your FlutterFlow app. It handles the entire permission
/// lifecycle: - Requests permission from the system - Updates
/// FFAppState.locationStatus - Tracks analytics for permission changes -
/// Provides detailed logging for debugging
///
/// The action is smart about tracking: it only sends analytics events when
/// the permission status actually CHANGES, preventing duplicate events.
///
/// Usage Scenarios: 1. First-time onboarding flow 2. Settings page "Enable
/// Location" button 3. Feature-gated screens that require location 4. App
/// resume checks (use checkLocationPermissionAndTrack instead)
///
/// Args: source: Context where permission was requested. Examples:
/// 'onboarding' - Initial app setup flow 'settings_page' - User clicked
/// enable in settings 'map_feature' - Gated feature requiring location
/// 'search_page' - Search functionality needs location
///
/// Returns: bool - true if permission is granted, false otherwise
///
/// Side Effects: - Updates FFAppState().locationStatus - May trigger system
/// permission dialog - Sends 'location_permission_changed' analytics event
/// (if status changed) - Logs permission status to debug console
Future<bool> requestLocationPermissionAndTrack(String source) async {
  debugPrint('📍 Requesting location permission (source: $source)...');

  // Validate source parameter
  if (source.isEmpty) {
    debugPrint('⚠️ Warning: source parameter is empty, using "unknown"');
    source = 'unknown';
  }

  try {
    // Capture previous state BEFORE requesting
    final previousStatus = FFAppState().locationStatus;

    // Request location permission
    final permissionStatus = await Permission.location.request();

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
      debugPrint('✅ Location permission granted');
    } else if (permissionStatus.isDenied) {
      permissionResult = 'denied';
      debugPrint('❌ Location permission denied');
    } else if (permissionStatus.isPermanentlyDenied) {
      permissionResult = 'permanentlyDenied';
      debugPrint('🚫 Location permission permanently denied');
      debugPrint('   User must enable in device settings');
    } else if (permissionStatus.isRestricted) {
      permissionResult = 'restricted';
      debugPrint('⚠️ Location permission restricted (parental controls?)');
    } else if (permissionStatus.isLimited) {
      permissionResult = 'limited';
      debugPrint('⚡ Location permission limited (iOS approximate location)');
    } else {
      permissionResult = 'unknown';
      debugPrint('❓ Location permission status unknown');
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
        });

        debugPrint('✅ Analytics tracked: $permissionResult from $source');
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
    debugPrint('❌ Error requesting location permission: $error');

    // Update state to false on error
    FFAppState().update(() {
      FFAppState().locationStatus = false;
    });

    // Track error in analytics
    try {
      await trackAnalyticsEvent('location_permission_changed', {
        'previousStatus': FFAppState().locationStatus,
        'newStatus': false,
        'permissionResult': 'error',
        'source': source,
        'error': error.toString(),
      });
    } catch (analyticsError) {
      debugPrint('⚠️ Failed to track error in analytics: $analyticsError');
    }

    return false;
  }
}
