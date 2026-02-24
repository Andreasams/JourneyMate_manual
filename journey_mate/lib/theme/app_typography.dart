import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography - Text styles from design system
class AppTypography {
  AppTypography._();

  // ============================================================
  // HEADINGS
  // ============================================================

  /// Page title (h2) - 26px, weight 720 → w800
  static const TextStyle pageTitle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.65, // -0.025em × 26px
    height: 1.2,
  );

  /// Restaurant name (h1) - 26px, weight 750 → w800
  static const TextStyle restaurantName = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.78, // -0.03em × 26px
    height: 1.2,
  );

  /// Section heading (h3) - 20px, weight 680 → w700
  static const TextStyle sectionHeading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// Category heading (h4) - 18px, weight 650 → w700
  static const TextStyle categoryHeading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // ============================================================
  // BODY TEXT
  // ============================================================

  /// Body regular - 16px, weight 400
  static const TextStyle bodyRegular = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5, // 24px line height
  );

  /// Body medium - 16px, weight 500
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  /// Body small - 15px, weight 460 → w500
  static const TextStyle bodySmall = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  /// Body tiny - 14px, weight 400
  static const TextStyle bodyTiny = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.43, // ~20px line height
  );

  // ============================================================
  // UI ELEMENTS
  // ============================================================

  /// Label - Form field labels (16px, weight 500)
  static const TextStyle label = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// Helper text - Below form fields (14px, weight 400)
  static const TextStyle helper = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.43,
  );

  /// Input text - Text inside input fields (16px, weight 400)
  static const TextStyle input = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// Placeholder - Input placeholder text (16px, weight 400)
  static const TextStyle placeholder = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.4,
  );

  /// Button text - Primary buttons (18px, weight 600)
  static const TextStyle button = TextStyle(
    fontSize: 18,
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

  /// Card detail text - Status, cuisine, price (12.5px, weight 400)
  static const TextStyle cardDetail = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  /// Card distance - Right-aligned distance label (12px, weight 500)
  static const TextStyle cardDistance = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.3,
  );
}
