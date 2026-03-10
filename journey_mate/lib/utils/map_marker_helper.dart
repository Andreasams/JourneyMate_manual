import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_colors.dart';
import 'search_result_helpers.dart';

/// Generates Google Maps-style teardrop pin markers with a utensils icon.
///
/// Pins are color-coded by match status and drawn as vector paths on Canvas.
/// Selected pins get a white halo effect. Generated bitmaps are cached
/// to avoid regeneration on every rebuild.
class MapMarkerHelper {
  MapMarkerHelper._();

  /// Cache key: "color.value-selected-size-devicePixelRatio"
  static final Map<String, BitmapDescriptor> _cache = {};

  /// Creates a teardrop pin marker with utensils icon.
  ///
  /// Uses PictureRecorder + Canvas to draw a pin shape with fork-and-knife.
  /// Selected markers are slightly larger with a white halo.
  static Future<BitmapDescriptor> createDotMarker({
    required Color color,
    bool selected = false,
    double size = 12.0,
    double devicePixelRatio = 2.0,
  }) async {
    final key = '${color.toARGB32()}-$selected-$size-$devicePixelRatio';
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    final scale = devicePixelRatio;
    // Pin proportions: width = size, height = size * 1.35
    final effectiveSize = selected ? size * 1.2 : size;
    final pinWidth = effectiveSize * scale;
    final pinHeight = effectiveSize * 1.35 * scale;
    // Extra padding for selected halo
    final padding = selected ? 3.0 * scale : 1.0 * scale;
    final canvasWidth = pinWidth + padding * 2;
    final canvasHeight = pinHeight + padding * 2;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Center the pin horizontally, align to top with padding
    final cx = canvasWidth / 2;
    final circleRadius = pinWidth / 2;
    final circleCenter = Offset(cx, padding + circleRadius);
    final tipY = padding + pinHeight;

    if (selected) {
      // White halo behind the pin
      _drawPinPath(canvas, cx, padding, circleRadius + 2 * scale,
          tipY + 2 * scale, Paint()..color = Colors.white);
    }

    // Pin body
    _drawPinPath(
        canvas, cx, padding, circleRadius, tipY, Paint()..color = color);

    // Utensils icon (white fork and knife in the circle area)
    _drawUtensils(canvas, circleCenter, circleRadius, scale);

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      canvasWidth.ceil(),
      canvasHeight.ceil(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    final descriptor = BitmapDescriptor.bytes(bytes);
    _cache[key] = descriptor;
    return descriptor;
  }

  /// Draws a teardrop pin path: circular top + pointed bottom.
  static void _drawPinPath(
    Canvas canvas,
    double cx,
    double topPadding,
    double radius,
    double tipY,
    Paint paint,
  ) {
    final cy = topPadding + radius;
    // Angle where the circle meets the tip tangent lines
    final tangentAngle = math.asin(radius / (tipY - cy)).clamp(0.3, 1.2);

    final path = Path();
    // Arc from lower-right around the top to lower-left
    path.arcTo(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      math.pi / 2 - tangentAngle, // start angle (right side, below center)
      -(math.pi + 2 * tangentAngle), // sweep (counter-clockwise, nearly full)
      false,
    );
    // Line to tip
    path.lineTo(cx, tipY);
    path.close();

    canvas.drawPath(path, paint);
  }

  /// Draws a simplified fork-and-knife icon inside the circle area.
  static void _drawUtensils(
    Canvas canvas,
    Offset center,
    double radius,
    double scale,
  ) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 * scale
      ..strokeCap = StrokeCap.round;

    final iconRadius = radius * 0.45;
    final cx = center.dx;
    final cy = center.dy;

    // Fork (left side): three short tines + handle
    final forkX = cx - iconRadius * 0.4;
    final tineTop = cy - iconRadius;
    final tineBottom = cy - iconRadius * 0.2;
    final handleBottom = cy + iconRadius;
    final tineSpacing = iconRadius * 0.3;

    // Three tines
    for (var i = -1; i <= 1; i++) {
      final tx = forkX + i * tineSpacing;
      canvas.drawLine(Offset(tx, tineTop), Offset(tx, tineBottom), paint);
    }
    // Fork handle
    canvas.drawLine(
        Offset(forkX, tineBottom), Offset(forkX, handleBottom), paint);

    // Knife (right side): blade + handle
    final knifeX = cx + iconRadius * 0.4;
    final bladeTop = cy - iconRadius;
    final bladeBottom = cy - iconRadius * 0.1;

    // Blade (slightly thicker)
    final bladePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(knifeX, bladeTop), Offset(knifeX, bladeBottom), bladePaint);

    // Knife handle
    canvas.drawLine(
        Offset(knifeX, bladeBottom), Offset(knifeX, handleBottom), paint);
  }

  /// Returns the marker color based on match variant.
  ///
  /// - Full match → Green
  /// - Partial match → Orange/accent
  /// - No match (filters active) → Gray
  /// - No filters active (null) → Brand orange
  static Color colorForMatchVariant(String? variant) {
    switch (variant) {
      case MatchVariant.full:
        return AppColors.green;
      case MatchVariant.partial:
        return AppColors.accent;
      case MatchVariant.none:
        return AppColors.textSecondary;
      default:
        // No filters active — use brand orange
        return AppColors.accent;
    }
  }

  /// Clears the marker cache (call when theme or scale changes).
  static void clearCache() {
    _cache.clear();
  }
}
