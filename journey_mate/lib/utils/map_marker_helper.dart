import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_colors.dart';
import 'search_result_helpers.dart';

/// Generates map pin markers: a round ball with a short pointer at the bottom.
///
/// Pins are color-coded by match status and drawn as vector paths on Canvas.
/// All pins have a white border; selected pins are larger. Generated bitmaps
/// are cached to avoid regeneration on every rebuild.
class MapMarkerHelper {
  MapMarkerHelper._();

  /// Cache key: "color.value-selected-size-devicePixelRatio"
  static final Map<String, BitmapDescriptor> _cache = {};

  /// Internal render multiplier — draws the canvas at 3x the display size
  /// then tells [BitmapDescriptor] the true pixel ratio. This gives the
  /// rasteriser enough pixels to produce smooth, anti-aliased curves.
  static const double _renderScale = 3.0;

  /// Creates a pin marker: round ball with a short pointer at the bottom.
  ///
  /// Uses PictureRecorder + Canvas to draw a clean pin shape.
  /// All markers get a white border; selected markers are larger.
  /// Size difference is the only selection indicator.
  static Future<BitmapDescriptor> createDotMarker({
    required Color color,
    bool selected = false,
    double size = 9.0,
    double devicePixelRatio = 2.0,
  }) async {
    final key = '${color.toARGB32()}-$selected-$size-$devicePixelRatio';
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    // Render at _renderScale × devicePixelRatio for crisp edges
    final scale = devicePixelRatio * _renderScale;
    // Selected markers are larger — size difference is the selection indicator
    final effectiveSize = selected ? size * 1.4 : size;
    // Pin proportions: width = size, height = size * 1.15 (ball + short pointer)
    final pinWidth = effectiveSize * scale;
    final pinHeight = effectiveSize * 1.15 * scale;
    // Padding for white border (always present on all markers)
    final padding = 3.0 * scale;
    final canvasWidth = pinWidth + padding * 2;
    final canvasHeight = pinHeight + padding * 2;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Center the pin horizontally, align to top with padding
    final cx = canvasWidth / 2;
    final circleRadius = pinWidth / 2;
    final tipY = padding + pinHeight;

    // White border behind the pin — always drawn for visual clarity
    const borderWidth = 2.0;
    _drawPinPath(
      canvas,
      cx,
      padding - borderWidth * scale,
      circleRadius + borderWidth * scale,
      tipY + borderWidth * scale,
      Paint()..color = Colors.white,
    );

    // Pin body
    _drawPinPath(
      canvas, cx, padding, circleRadius, tipY, Paint()..color = color,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      canvasWidth.ceil(),
      canvasHeight.ceil(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    // Tell the descriptor the true pixel ratio so it displays at
    // the intended logical size despite the oversized bitmap.
    final descriptor = BitmapDescriptor.bytes(
      bytes,
      imagePixelRatio: devicePixelRatio * _renderScale,
    );
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
