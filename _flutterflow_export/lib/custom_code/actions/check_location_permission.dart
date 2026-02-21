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

import 'package:geolocator/geolocator.dart';

/// Checks location permission using Geolocator and updates FFAppState
///
/// This is the WORKING version that actually detects iOS permission status.
///
/// Args: source: Context where check occurred (e.g., 'app_resume',
/// 'page_load')
///
/// Returns: bool: true if permission granted, false otherwise
Future<bool> checkLocationPermission(String source) async {
  debugPrint('📍 Checking location permission (source: $source)...');

  try {
    // Capture previous state
    final previousStatus = FFAppState().locationStatus;

    // Check location services enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('❌ Location services are disabled');

      FFAppState().update(() {
        FFAppState().locationStatus = false;
      });

      return false;
    }

    // Check permission using Geolocator (THIS WORKS!)
    LocationPermission permission = await Geolocator.checkPermission();

    debugPrint('🔍 Permission: $permission');

    // Determine if granted
    bool isGranted = permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;

    // Update FFAppState
    FFAppState().update(() {
      FFAppState().locationStatus = isGranted;
    });

    // Determine human-readable result
    String permissionResult;
    if (permission == LocationPermission.whileInUse) {
      permissionResult = 'whileInUse';
      debugPrint('✅ Location permission: While Using App');
    } else if (permission == LocationPermission.always) {
      permissionResult = 'always';
      debugPrint('✅ Location permission: Always');
    } else if (permission == LocationPermission.denied) {
      permissionResult = 'denied';
      debugPrint('❌ Location permission: Denied');
    } else if (permission == LocationPermission.deniedForever) {
      permissionResult = 'deniedForever';
      debugPrint('🚫 Location permission: Denied Forever');
    } else {
      permissionResult = 'unableToDetermine';
      debugPrint('❓ Location permission: Unable to determine');
    }

    // Track analytics if status changed
    if (previousStatus != isGranted) {
      debugPrint('📊 Permission status changed: $previousStatus → $isGranted');

      try {
        await trackAnalyticsEvent('location_permission_changed', {
          'previousStatus': previousStatus,
          'newStatus': isGranted,
          'permissionResult': permissionResult,
          'source': source,
          'wasPassiveCheck': true,
        });

        debugPrint('✅ Analytics tracked');
      } catch (e) {
        debugPrint('⚠️ Analytics tracking failed: $e');
      }
    }

    return isGranted;
  } catch (e, stackTrace) {
    debugPrint('❌ Error checking location permission: $e');
    debugPrint('Stack trace: $stackTrace');

    // Keep existing state on error
    return FFAppState().locationStatus;
  }
}
