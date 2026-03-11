import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

/// Returns installed map apps filtered to only Google Maps and Apple Maps.
Future<List<AvailableMap>> getAvailableMapApps() async {
  final installed = await MapLauncher.installedMaps;
  return installed
      .where(
          (m) => m.mapType == MapType.google || m.mapType == MapType.apple)
      .toList();
}

/// Opens the actual venue listing in the selected map app.
///
/// For Google Maps: uses [googleMapsUrl] (the venue's direct link) when
/// available, otherwise falls back to a search URL built from the business
/// name and address.
///
/// For Apple Maps: always builds a search URL with name, address, and
/// coordinates so iOS resolves the real place card.
///
/// Returns `true` on success.
Future<bool> openVenueInMapApp({
  required AvailableMap map,
  required double latitude,
  required double longitude,
  required String businessName,
  String? googleMapsUrl,
  String? street,
  String? postalCode,
  String? city,
}) async {
  final uri = _buildVenueUri(
    mapType: map.mapType,
    latitude: latitude,
    longitude: longitude,
    businessName: businessName,
    googleMapsUrl: googleMapsUrl,
    street: street,
    postalCode: postalCode,
    city: city,
  );

  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// Builds a URI that opens the venue listing (not a generic pin) in the
/// target map app.
Uri _buildVenueUri({
  required MapType mapType,
  required double latitude,
  required double longitude,
  required String businessName,
  String? googleMapsUrl,
  String? street,
  String? postalCode,
  String? city,
}) {
  if (mapType == MapType.google) {
    // Prefer the direct venue URL from the API
    if (googleMapsUrl != null && googleMapsUrl.isNotEmpty) {
      return Uri.parse(googleMapsUrl);
    }
    // Fallback: search by name + address
    final query = _buildSearchQuery(businessName, street, postalCode, city);
    return Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );
  }

  // Apple Maps — search with address + coordinates for best match
  final addressParts = <String>[
    if (street != null && street.isNotEmpty) street,
    if (postalCode != null && postalCode.isNotEmpty) postalCode,
    if (city != null && city.isNotEmpty) city,
  ];
  final address = addressParts.join(', ');
  final encodedName = Uri.encodeComponent(businessName);

  if (address.isNotEmpty) {
    return Uri.parse(
      'https://maps.apple.com/?q=$encodedName'
      '&address=${Uri.encodeComponent(address)}'
      '&ll=$latitude,$longitude&z=16',
    );
  }
  return Uri.parse(
    'https://maps.apple.com/?q=$encodedName&ll=$latitude,$longitude&z=16',
  );
}

/// Combines business name with available address parts into a single search
/// string.
String _buildSearchQuery(
  String name,
  String? street,
  String? postalCode,
  String? city,
) {
  final parts = <String>[
    name,
    if (street != null && street.isNotEmpty) street,
    if (postalCode != null && postalCode.isNotEmpty) postalCode,
    if (city != null && city.isNotEmpty) city,
  ];
  return parts.join(' ');
}
