import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography — 20-style type scale.
///
/// Headings: 6-level hierarchy (26→16, 2px steps, all w700).
/// Body:     14 / 15 / 16 at w300–w700.
/// UI:       button (18/w600/white), price (14/w600/accent).
///
/// Every heading/body style uses textPrimary except [button] and [price].
class AppTypography {
  AppTypography._();

  // ============================================================
  // HEADINGS — 2px step system, all w700
  //
  //   h1 (26) — app-section entry titles (Search, Settings)
  //   h2 (24) — featured entity names (restaurant, coupon, blog)
  //   h3 (22) — sheet / overlay titles
  //   h4 (20) — section headings, sub-headings
  //   h5 (18) — AppBar titles (deliberately understated)
  //   h6 (16) — sub-section labels (e.g. inside collapsibles)
  // ============================================================

  /// 28/w800 — hero titles (welcome page)
  static const TextStyle hero = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  /// 26/w700 — app-section entry titles (Search, Settings)
  static const TextStyle h1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  /// 24/w700 — featured entity names (restaurant, coupon, blog post)
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  /// 22/w700 — sheet / overlay titles
  static const TextStyle h3 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// 20/w700 — section headings, sub-headings
  static const TextStyle h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// 18/w700 — AppBar titles (deliberately understated)
  static const TextStyle h5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// 16/w700 — sub-section labels (e.g. inside collapsibles)
  static const TextStyle h6 = TextStyle(
    fontSize: 16,
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

  /// 15/w300 — light body text, secondary info
  static const TextStyle bodyLight = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w300,
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

  /// 15/w600 — emphasized card names, section labels
  static const TextStyle bodyHeavy = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  /// 15/w700 — bold card names, section labels
  static const TextStyle bodyExtraHeavy = TextStyle(
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
