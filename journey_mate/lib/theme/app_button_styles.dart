import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// Button Styles - Reusable button styles
class AppButtonStyles {
  AppButtonStyles._();

  /// Primary button - Orange, full width, 50px height
  static ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.accent,
    disabledBackgroundColor: AppColors.textDisabled,
    foregroundColor: Colors.white,
    textStyle: AppTypography.button,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),
    ),
    elevation: 0,
  );

  /// Secondary button - White with border
  static ButtonStyle secondary = OutlinedButton.styleFrom(
    foregroundColor: AppColors.textPrimary,
    textStyle: AppTypography.button.copyWith(color: AppColors.textPrimary),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    side: const BorderSide(color: AppColors.border),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),
    ),
  );
}
