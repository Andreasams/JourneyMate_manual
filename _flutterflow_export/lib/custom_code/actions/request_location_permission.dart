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

/// Requests location permission using Geolocator
///
/// Args: source: Context where request occurred (e.g., 'onboarding',
/// 'settings')
///
/// Returns: bool: true if permission granted, false otherwise
Future<bool> requestLocationPermission(String source) async {
  debugPrint('📍 Requesting location permission (source: $source)...');

  try {
    // Capture previous state
    final previousStatus = FFAppState().locationStatus;

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('❌ Location services are disabled');

      FFAppState().update(() {
        FFAppState().locationStatus = false;
      });

      return false;
    }

    // Request permission
    LocationPermission permission = await Geolocator.requestPermission();

    debugPrint('🔍 Permission result: $permission');

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
      debugPrint('✅ Permission granted: While Using App');
    } else if (permission == LocationPermission.always) {
      permissionResult = 'always';
      debugPrint('✅ Permission granted: Always');
    } else if (permission == LocationPermission.denied) {
      permissionResult = 'denied';
      debugPrint('❌ Permission denied');
    } else if (permission == LocationPermission.deniedForever) {
      permissionResult = 'deniedForever';
      debugPrint('🚫 Permission denied forever - user must enable in Settings');
    } else {
      permissionResult = 'unableToDetermine';
      debugPrint('❓ Unable to determine permission');
    }

    // Track analytics if status changed
    if (previousStatus != isGranted) {
      try {
        await trackAnalyticsEvent('location_permission_changed', {
          'previousStatus': previousStatus,
          'newStatus': isGranted,
          'permissionResult': permissionResult,
          'source': source,
          'wasRequest': true,
        });

        debugPrint('✅ Analytics tracked');
      } catch (e) {
        debugPrint('⚠️ Analytics tracking failed: $e');
      }
    }

    return isGranted;
  } catch (e, stackTrace) {
    debugPrint('❌ Error requesting location permission: $e');
    debugPrint('Stack trace: $stackTrace');

    FFAppState().update(() {
      FFAppState().locationStatus = false;
    });

    return false;
  }
}
