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

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks analytics events to Buildship endpoint
///
/// UPDATED for engagement tracking system:
/// - Gets sessionId from FFAppState (set by engagement tracker)
/// - Maintains backward compatibility
/// - Handles missing session gracefully
///
/// Args:
///   eventType: Type of event (e.g., 'business_clicked', 'filter_applied')
///   eventData: Optional event metadata (Map or JSON)
///
/// Returns:
///   bool: true if event tracked successfully, false on error
Future<bool> trackAnalyticsEvent(
  String eventType,
  dynamic eventData,
) async {
  const buildshipEndpoint = 'https://wvb8ww.buildship.run/analytics';

  if (eventType.isEmpty) {
    debugPrint('❌ eventType cannot be empty');
    return false;
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = prefs.getString('analytics_device_id');

    if (deviceId == null) {
      debugPrint('❌ Missing deviceId - analytics not initialized');
      return false;
    }

    final sessionId = prefs.getString('current_session_id');

    if (sessionId == null || sessionId.isEmpty) {
      debugPrint('⚠️ No active session - event may not be tracked properly');
      debugPrint('   Event type: $eventType');
    }

    // Safely serialize eventData to avoid IdentityMap issues
    final Map<String, dynamic> safeEventData = _sanitizeEventData(eventData);

    final payload = {
      'eventType': eventType,
      'deviceId': deviceId,
      'sessionId': sessionId ?? 'no-session',
      'userId': deviceId,
      'eventData': safeEventData,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };

    final url = Uri.parse(buildshipEndpoint);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      debugPrint('✅ Event tracked: $eventType');
      return true;
    } else {
      debugPrint('❌ Failed to track event. Status: ${response.statusCode}');
      debugPrint('   Response: ${response.body}');
      return false;
    }
  } catch (e, stackTrace) {
    debugPrint('❌ Error tracking event: $e');
    debugPrint('   Stack trace: $stackTrace');
    return false;
  }
}

/// Converts eventData to a safely serializable Map.
/// Handles IdentityMap, nested objects, and other non-serializable types.
Map<String, dynamic> _sanitizeEventData(dynamic data) {
  if (data == null) return {};

  try {
    if (data is Map<String, String?>) {
      // Already a safe map type (common FlutterFlow pattern)
      return Map<String, dynamic>.from(
        data.map((k, v) => MapEntry(k, v)),
      );
    }

    if (data is Map) {
      // Convert any Map type to safe Map<String, dynamic>
      final result = <String, dynamic>{};
      data.forEach((key, value) {
        final safeKey = key?.toString() ?? 'null_key';
        result[safeKey] = _sanitizeValue(value);
      });
      return result;
    }

    // If it's not a map, wrap it
    return {'value': _sanitizeValue(data)};
  } catch (e) {
    debugPrint('⚠️ Error sanitizing eventData: $e');
    return {
      'error': 'Failed to serialize eventData',
      'type': data.runtimeType.toString()
    };
  }
}

/// Recursively sanitizes individual values for JSON serialization.
dynamic _sanitizeValue(dynamic value) {
  if (value == null) return null;
  if (value is String || value is num || value is bool) return value;
  if (value is DateTime) return value.toUtc().toIso8601String();

  if (value is List) {
    return value.map((e) => _sanitizeValue(e)).toList();
  }

  if (value is Map) {
    final result = <String, dynamic>{};
    value.forEach((k, v) {
      result[k?.toString() ?? 'null'] = _sanitizeValue(v);
    });
    return result;
  }

  // Fallback: convert to string
  return value.toString();
}
