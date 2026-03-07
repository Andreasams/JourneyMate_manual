import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_colors.dart';
import 'search_result_helpers.dart';

/// Generates custom dot-style map markers using Canvas drawing.
///
/// Markers are small circles with a white border, color-coded by match status.
/// Selected markers get a white ring/halo effect. Generated bitmaps are cached
/// to avoid regeneration on every rebuild.
class MapMarkerHelper {
  MapMarkerHelper._();

  /// Cache key: "color.value-selected-size-devicePixelRatio"
  static final Map<String, BitmapDescriptor> _cache = {};

  /// Creates a dot marker with the given [color], [size], and [selected] state.
  ///
  /// Uses PictureRecorder + Canvas to draw a filled circle with white border.
  /// Selected markers are slightly larger with a white ring.
  static Future<BitmapDescriptor> createDotMarker({
    required Color color,
    bool selected = false,
    double size = 22.0,
    double devicePixelRatio = 2.0,
  }) async {
    final key = '${color.toARGB32()}-$selected-$size-$devicePixelRatio';
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    // Selected markers get a halo ring
    final effectiveSize = selected ? size * 1.4 : size;
    final canvasSize = effectiveSize * devicePixelRatio;
    final center = Offset(canvasSize / 2, canvasSize / 2);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    if (selected) {
      // White halo ring
      final haloPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, canvasSize / 2, haloPaint);

      // Colored inner circle
      final fillPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, canvasSize / 2 - 4 * devicePixelRatio, fillPaint);
    } else {
      // White border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, canvasSize / 2, borderPaint);

      // Colored fill
      final fillPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, canvasSize / 2 - 2 * devicePixelRatio, fillPaint);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      canvasSize.toInt(),
      canvasSize.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    final descriptor = BitmapDescriptor.bytes(bytes);
    _cache[key] = descriptor;
    return descriptor;
  }

  /// Returns the marker color based on match variant.
  ///
  /// - Full match → Green
  /// - Partial match → Orange/accent
  /// - No filters active or no match → Neutral dark
  static Color colorForMatchVariant(String? variant) {
    switch (variant) {
      case MatchVariant.full:
        return AppColors.green;
      case MatchVariant.partial:
        return AppColors.accent;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Clears the marker cache (call when theme or scale changes).
  static void clearCache() {
    _cache.clear();
  }
}
