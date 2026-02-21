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

Future<String> checkLocationByFetching() async {
  final buffer = StringBuffer();

  try {
    buffer.writeln('=== LOCATION FETCH TEST ===');
    buffer.writeln('');

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    buffer.writeln('Service enabled: $serviceEnabled');

    if (!serviceEnabled) {
      buffer.writeln('');
      buffer.writeln('RESULT: Location services OFF');
      return buffer.toString();
    }

    // Check permission
    LocationPermission permission = await Geolocator.checkPermission();
    buffer.writeln('Permission: $permission');
    buffer.writeln('');

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      buffer.writeln('RESULT: Permission DENIED');
      return buffer.toString();
    }

    // Try to get actual location
    buffer.writeln('Attempting to fetch location...');

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 5),
    );

    buffer.writeln('');
    buffer.writeln('SUCCESS!');
    buffer.writeln('Lat: ${position.latitude}');
    buffer.writeln('Lng: ${position.longitude}');
    buffer.writeln('');
    buffer.writeln('RESULT: Permission GRANTED');
  } catch (e) {
    buffer.writeln('');
    buffer.writeln('ERROR: $e');
    buffer.writeln('');
    buffer.writeln('RESULT: Cannot get location');
  }

  return buffer.toString();
}
