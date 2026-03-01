import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class RemoteLogger {
  static const String _kLogEndpoint = 'https://wvb8ww.buildship.run/log-debug';
  static String? _deviceId;

  /// Initialize with device ID from SharedPreferences
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _deviceId = prefs.getString('analytics_device_id');
    } catch (e) {
      debugPrint('RemoteLogger init failed: $e');
    }
  }

  /// Log a debug message to BuildShip
  static Future<void> log({
    required String tag,
    required String message,
    String level = 'debug',
    Map<String, dynamic>? data,
  }) async {
    // Always print locally first
    debugPrint('[$level][$tag] $message');

    try {
      final body = {
        'device_id': _deviceId ?? 'unknown',
        'timestamp': DateTime.now().toIso8601String(),
        'level': level,
        'tag': tag,
        'message': message,
        ...?data != null ? {'data': data} : null,
      };

      // Fire-and-forget (don't await, don't block app)
      http.post(
        Uri.parse(_kLogEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('⚠️ Remote log timeout');
          return http.Response('timeout', 408);
        },
      );
    } catch (e) {
      // Silent failure - don't break app if logging fails
      debugPrint('Remote log failed: $e');
    }
  }

  /// Convenience methods
  static Future<void> debug(String tag, String message, [Map<String, dynamic>? data]) =>
      log(tag: tag, message: message, level: 'debug', data: data);

  static Future<void> info(String tag, String message, [Map<String, dynamic>? data]) =>
      log(tag: tag, message: message, level: 'info', data: data);

  static Future<void> warning(String tag, String message, [Map<String, dynamic>? data]) =>
      log(tag: tag, message: message, level: 'warning', data: data);

  static Future<void> error(String tag, String message, [Map<String, dynamic>? data]) =>
      log(tag: tag, message: message, level: 'error', data: data);
}
