import 'dart:math' as math;
import '../../../models/lat_lng.dart';

/// Calculates the great-circle distance between two geographical points using the Haversine formula.
///
/// Returns distance in kilometers by default. Converts to miles when distanceUnit is 'imperial'.
///
/// Args:
///   currentDeviceLocation: The current location of the device as a LatLng object
///   businessLatitude: The latitude of the business location (-90 to 90)
///   businessLongitude: The longitude of the business location (-180 to 180)
///   distanceUnit: Distance unit preference ('imperial' for miles, 'metric' for kilometers)
///
/// Returns:
///   Distance rounded to one decimal place in kilometers (metric) or miles (imperial)
///
/// Throws:
///   Exception if latitude or longitude values are out of valid bounds
double returnDistance(
  LatLng currentDeviceLocation,
  double businessLatitude,
  double businessLongitude,
  String distanceUnit,
) {
  // Validate latitude bounds
  if (businessLatitude < -90 || businessLatitude > 90) {
    throw Exception("Invalid business latitude: $businessLatitude");
  }

  // Validate longitude bounds
  if (businessLongitude < -180 || businessLongitude > 180) {
    throw Exception("Invalid business longitude: $businessLongitude");
  }

  // Conversion factor for degrees to radians
  const p = 0.017453292519943295;

  // Convert latitudes and longitudes from degrees to radians
  final lat1 = currentDeviceLocation.latitude * p;
  final lon1 = currentDeviceLocation.longitude * p;
  final lat2 = businessLatitude * p;
  final lon2 = businessLongitude * p;

  // Haversine formula to calculate the distance
  final a = 0.5 -
      math.cos(lat2 - lat1) / 2 +
      math.cos(lat1) * math.cos(lat2) * (1 - math.cos(lon2 - lon1)) / 2;

  // Distance in kilometers (Earth's diameter = 12742 km)
  var result = 12742 * math.asin(math.sqrt(a));

  // Convert to miles if imperial unit is selected
  // If metric, skip conversion (keep kilometers)
  if (distanceUnit.toLowerCase() == 'imperial') {
    result = result * 0.621371;
  }

  // Round to one decimal place and return
  return double.parse(result.toStringAsFixed(1));
}
