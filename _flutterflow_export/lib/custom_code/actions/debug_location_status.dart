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

Future<String> debugLocationStatus() async {
  // Add your function code here!
  final buffer = StringBuffer();

  try {
    buffer.writeln('=== LOCATION DEBUG ===');
    buffer.writeln('');

    // 1. Check FFAppState BEFORE
    final beforeValue = FFAppState().locationStatus;
    buffer.writeln('FFAppState BEFORE: $beforeValue');
    buffer.writeln('');

    // 2. Check iOS permission
    final status = await Permission.location.status;
    buffer.writeln('iOS Permission Status:');
    buffer.writeln('  isGranted: ${status.isGranted}');
    buffer.writeln('  isDenied: ${status.isDenied}');
    buffer.writeln('  isPermanentlyDenied: ${status.isPermanentlyDenied}');
    buffer.writeln('  isRestricted: ${status.isRestricted}');
    buffer.writeln('  isLimited: ${status.isLimited}');
    buffer.writeln('');

    // 3. Try to update FFAppState
    final isGranted = status.isGranted;
    buffer.writeln('Attempting update to: $isGranted');

    FFAppState().update(() {
      FFAppState().locationStatus = isGranted;
    });

    buffer.writeln('Update call completed');
    buffer.writeln('');

    // 4. Wait a moment
    await Future.delayed(Duration(milliseconds: 100));

    // 5. Check FFAppState AFTER
    final afterValue = FFAppState().locationStatus;
    buffer.writeln('FFAppState AFTER: $afterValue');
    buffer.writeln('');

    // 6. Analysis
    buffer.writeln('--- ANALYSIS ---');
    if (status.isGranted && !afterValue) {
      buffer.writeln('PROBLEM: iOS granted but');
      buffer.writeln('FFAppState is false');
    } else if (!status.isGranted && afterValue) {
      buffer.writeln('PROBLEM: iOS denied but');
      buffer.writeln('FFAppState is true');
    } else if (beforeValue != afterValue) {
      buffer.writeln('SUCCESS: Value changed');
      buffer.writeln('from $beforeValue to $afterValue');
    } else if (status.isGranted && afterValue) {
      buffer.writeln('OK: Both show granted');
    } else {
      buffer.writeln('OK: Both show denied');
    }
  } catch (e) {
    buffer.writeln('');
    buffer.writeln('ERROR: $e');
  }

  return buffer.toString();
}
