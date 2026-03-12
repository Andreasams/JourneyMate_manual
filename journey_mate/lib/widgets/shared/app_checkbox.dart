import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';

/// A visual-only checkbox indicator for JourneyMate.
///
/// Renders a rounded square container with an optional check icon.
/// Does NOT handle tap events — callers wrap this in their own
/// [GestureDetector] or [InkWell].
///
/// Supports four visual states via [isSelected] and [isEnabled]:
///
/// | State                 | Fill            | Border          | Check |
/// |-----------------------|-----------------|-----------------|-------|
/// | selected + enabled    | [activeColor]   | none            | white |
/// | selected + disabled   | [disabledColor] | none            | white |
/// | unselected + enabled  | white           | [borderColor]   | none  |
/// | unselected + disabled | white           | [disabledColor] | none  |
///
/// Default border color matches [AppColors.border] (same as chips/containers)
/// so checkboxes feel visually consistent with the rest of the UI.
///
/// Usage:
/// ```dart
/// GestureDetector(
///   onTap: () => setState(() => _checked = !_checked),
///   child: Row(
///     children: [
///       AppCheckbox(isSelected: _checked),
///       SizedBox(width: AppSpacing.sm),
///       Text('Label'),
///     ],
///   ),
/// )
/// ```
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.isSelected,
    this.isEnabled = true,
    this.size = 18.0,
    this.activeColor,
    this.borderColor,
    this.disabledColor,
    this.checkIconSize = 11.0,
    this.borderRadius,
    this.borderWidth = 1.5,
  });

  // ---------------------------------------------------------------------------
  // PROPERTIES
  // ---------------------------------------------------------------------------

  /// Whether the checkbox shows a check mark (filled state).
  final bool isSelected;

  /// Whether the checkbox is interactive. When false, uses disabled colors.
  /// Note: This is purely visual — callers must also disable their
  /// GestureDetector when the checkbox is disabled.
  final bool isEnabled;

  /// Outer dimensions of the checkbox square. Default: 18.0
  final double size;

  /// Fill color when selected and enabled. Default: [AppColors.accent] (orange)
  final Color? activeColor;

  /// Border color when unselected and enabled. Default: [AppColors.border]
  /// Matches chip/container borders for visual consistency.
  final Color? borderColor;

  /// Fill/border color when disabled (both selected and unselected states).
  /// Default: [AppColors.buttonPressed] (light grey)
  final Color? disabledColor;

  /// Size of the check icon. Default: 11.0
  final double checkIconSize;

  /// Corner radius. Default: [AppRadius.checkbox] (4.0)
  final double? borderRadius;

  /// Border width for the unselected state. Default: 1.5
  final double borderWidth;

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final resolvedActiveColor = activeColor ?? AppColors.accent;
    final resolvedBorderColor = borderColor ?? AppColors.border;
    final resolvedDisabledColor = disabledColor ?? AppColors.buttonPressed;
    final resolvedBorderRadius = borderRadius ?? AppRadius.checkbox;

    // Determine fill color
    final Color fillColor;
    if (isSelected) {
      fillColor = isEnabled ? resolvedActiveColor : resolvedDisabledColor;
    } else {
      fillColor = AppColors.bgPage;
    }

    // Determine border (only shown when unselected)
    final Border? border;
    if (isSelected) {
      border = null;
    } else {
      border = Border.all(
        color: isEnabled ? resolvedBorderColor : resolvedDisabledColor,
        width: borderWidth,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fillColor,
        border: border,
        borderRadius: BorderRadius.circular(resolvedBorderRadius),
      ),
      child: isSelected
          ? Icon(Icons.check, size: checkIconSize, color: AppColors.bgPage)
          : null,
    );
  }
}
