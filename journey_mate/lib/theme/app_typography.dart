import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography — 17-style type scale.
///
/// Sizes snap to 14 / 15 / 16 / 18 / 20 / 26. Every style uses
/// textPrimary except [button] (white) and [price] (accent).
class AppTypography {
  AppTypography._();

  // ============================================================
  // HEADINGS
  // ============================================================

  /// 26/w700 — page titles, hero headings
  static const TextStyle h1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.65,
  );

  /// 26/w800 — restaurant name on profile
  static const TextStyle h1Heavy = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.78,
  );

  /// 20/w700 — section headings
  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// 18/w700 — category headings
  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // ============================================================
  // BODY
  // ============================================================

  /// 16/w400 — long-form text, descriptions
  static const TextStyle bodyLg = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  /// 16/w500 — labels, emphasized body
  static const TextStyle bodyLgMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  /// 16/w700 — bold body text, strong emphasis
  static const TextStyle bodyLgHeavy = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  /// 15/w400 — standard body text
  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  /// 15/w500 — card names, menu items
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  /// 15/w700 — bold card names, section labels
  static const TextStyle bodyHeavy = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  /// 14/w400 — helper text, card details
  static const TextStyle bodySm = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  /// 14/w500 — chips, status, distance
  static const TextStyle bodySmMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  /// 14/w700 — bold small text, highlighted details
  static const TextStyle bodySmHeavy = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  // ============================================================
  // UI
  // ============================================================

  /// 18/w600/white — primary buttons
  static const TextStyle button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.2,
  );

  /// 14/w600/accent — prices
  static const TextStyle price = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.accent,
    height: 1.45,
  );
}
