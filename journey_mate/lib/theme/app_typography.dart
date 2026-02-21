import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography - Text styles from design system
class AppTypography {
  AppTypography._();

  // ============================================================
  // HEADINGS
  // ============================================================

  /// Page title (h2) - 24px, weight 720 → w800
  static const TextStyle pageTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.6, // -0.025em × 24px
    height: 1.2,
  );

  /// Restaurant name (h1) - 24px, weight 750 → w800
  static const TextStyle restaurantName = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.72, // -0.03em × 24px
    height: 1.2,
  );

  /// Section heading (h3) - 18px, weight 680 → w700
  static const TextStyle sectionHeading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// Category heading (h4) - 16px, weight 650 → w700
  static const TextStyle categoryHeading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // ============================================================
  // BODY TEXT
  // ============================================================

  /// Body regular - 14px, weight 400
  static const TextStyle bodyRegular = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.43, // 20px line height
  );

  /// Body medium - 14px, weight 500
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.43,
  );

  /// Body small - 13px, weight 460 → w500
  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  /// Body tiny - 12px, weight 400
  static const TextStyle bodyTiny = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.33, // 16px line height
  );

  // ============================================================
  // UI ELEMENTS
  // ============================================================

  /// Label - Form field labels (14px, weight 500)
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// Helper text - Below form fields (12px, weight 400)
  static const TextStyle helper = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.33,
  );

  /// Input text - Text inside input fields (14px, weight 400)
  static const TextStyle input = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// Placeholder - Input placeholder text (14px, weight 400)
  static const TextStyle placeholder = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.4,
  );

  /// Button text - Primary buttons (16px, weight 600)
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.2,
  );

  /// Chip text - Small chips (12.5px, weight 540 → w600)
  static const TextStyle chip = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  /// Status text - Open/Closed (12.5px, weight 560 → w600)
  static const TextStyle status = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // ============================================================
  // CARD ELEMENTS
  // ============================================================

  /// Card restaurant name - 15.5px, weight 630 → w700
  static const TextStyle cardRestaurantName = TextStyle(
    fontSize: 15.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// Menu item name - 15px, weight 590 → w600
  static const TextStyle menuItemName = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// Price - 13.5px, weight 540 → w600, ACCENT color
  static const TextStyle price = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    color: AppColors.accent,
    height: 1.2,
  );
}
