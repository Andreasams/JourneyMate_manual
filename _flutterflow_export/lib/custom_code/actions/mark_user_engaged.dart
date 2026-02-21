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

import 'package:shared_preferences/shared_preferences.dart';

/// Marks user as actively engaged
///
/// This updates the "last active" timestamp used by the engagement tracker
/// to extend the user's engaged time window by 15 seconds.
///
/// Call this on key user interactions:
/// - Search bar text change/submit
/// - Filter applied/removed
/// - Business clicked
/// - Navigation events
///
/// Implementation Note:
/// Since FlutterFlow custom code can't directly access the engagementTracker
/// from main.dart, we use SharedPreferences as a communication channel.
/// The engagement tracker checks this timestamp on each heartbeat.
///
/// Performance: O(1) SharedPreferences write, ~1-2ms overhead
Future<void> markUserEngaged() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;

    // Store timestamp that engagement tracker will read
    await prefs.setInt('last_user_activity', now);

    // Optional: Uncomment for debugging
    debugPrint('👆 User engagement marked at $now');
  } catch (e) {
    // Fail silently - engagement tracking is non-critical
    debugPrint('⚠️ Failed to mark user engaged: $e');
  }
}
