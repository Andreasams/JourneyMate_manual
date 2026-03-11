import 'package:collection/collection.dart';
import 'package:map_launcher/map_launcher.dart';

/// Opens the user's preferred maps app with a marker at the given coordinates.
///
/// Priority: Google Maps > Apple Maps > first available.
/// Returns the map app name on success, or null if no maps are available.
Future<String?> openInPreferredMaps({
  required double latitude,
  required double longitude,
  required String title,
}) async {
  try {
    final installedMaps = await MapLauncher.installedMaps;
    if (installedMaps.isEmpty) return null;

    // Pick preferred map app: Google Maps first, then Apple Maps, then whatever is available
    final preferred = installedMaps
            .firstWhereOrNull((m) => m.mapType == MapType.google) ??
        installedMaps
            .firstWhereOrNull((m) => m.mapType == MapType.apple) ??
        installedMaps.first;

    await preferred.showMarker(
      coords: Coords(latitude, longitude),
      title: title,
    );

    return preferred.mapName;
  } catch (e) {
    return null;
  }
}
