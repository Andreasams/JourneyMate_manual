import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';

/// Data class describing an action button (close, back, menu, etc.)
class BottomSheetAction {
  const BottomSheetAction({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;
}

/// Shared header for all JourneyMate bottom sheets.
///
/// Renders a swipe bar indicator and up to two action buttons (left/right)
/// over an optional image background. Provides static constants and a
/// [sheetDecoration] helper so every bottom sheet container uses identical
/// styling.
///
/// Usage:
/// ```dart
/// BottomSheetHeader(
///   rightAction: BottomSheetAction(
///     icon: Icons.close,
///     onPressed: () => Navigator.of(context).pop(),
///   ),
/// )
/// ```
class BottomSheetHeader extends StatelessWidget {
  const BottomSheetHeader({
    super.key,
    this.leftAction,
    this.rightAction,
    this.image,
    this.imageHeight = 200.0,
    this.noImageHeight = 64.0,
  });

  /// Optional action button at top-left (e.g. close or back).
  final BottomSheetAction? leftAction;

  /// Optional action button at top-right (e.g. close or menu).
  final BottomSheetAction? rightAction;

  /// Optional image widget that fills the header background.
  final Widget? image;

  /// Header height when [image] is provided.
  final double imageHeight;

  /// Header height when no image.
  final double noImageHeight;

  // ---- Public constants (reusable by consuming widgets) --------------------

  static const double swipeBarWidth = 40.0;
  static const double swipeBarHeight = 4.0;
  static const double swipeBarTopPadding = 8.0;
  static const double actionButtonSize = 40.0;
  static const double actionButtonPosition = 12.0;
  static const double actionIconSize = 24.0;
  static const double actionButtonBorderRadius = 20.0;

  /// Canonical container decoration for JourneyMate bottom sheets.
  static BoxDecoration sheetDecoration({Color? color}) => BoxDecoration(
        color: color ?? AppColors.bgCard,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.bottomSheet),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final hasImage = image != null;
    final height = hasImage ? imageHeight : noImageHeight;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // Optional image background
          if (hasImage)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.bottomSheet),
                ),
                child: image!,
              ),
            ),

          // Swipe bar indicator (always visible)
          Positioned(
            top: swipeBarTopPadding,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: swipeBarWidth,
                height: swipeBarHeight,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.handle),
                ),
              ),
            ),
          ),

          // Left action button
          if (leftAction != null)
            Positioned(
              top: actionButtonPosition,
              left: actionButtonPosition,
              child: _buildActionButton(leftAction!),
            ),

          // Right action button
          if (rightAction != null)
            Positioned(
              top: actionButtonPosition,
              right: actionButtonPosition,
              child: _buildActionButton(rightAction!),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BottomSheetAction action) {
    return Container(
      width: actionButtonSize,
      height: actionButtonSize,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(actionButtonBorderRadius),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          action.icon,
          color: AppColors.textPrimary,
          size: actionIconSize,
        ),
        onPressed: action.onPressed,
      ),
    );
  }
}
