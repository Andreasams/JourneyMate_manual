// ============================================================
// JOURNEYMATE FLUTTER DESIGN SYSTEM
// Complete implementation of journeymate-design-system.md
//
// This is the single source of truth for all design tokens.
// Based on: C:\Users\Rikke\Documents\JourneyMate-v2\journeymate-design-system.md
// Version: 1.0 - February 2026
// ============================================================

import 'package:flutter/material.dart';

/// App Colors - Complete palette from design system
class AppColors {
  AppColors._(); // Prevent instantiation

  // ============================================================
  // PRIMARY PALETTE
  // ============================================================

  /// Orange - Interactive elements, CTAs, filter selections, brand identity
  /// Usage: "Tap me" or "This is JourneyMate"
  /// NEVER use for match status (use green for matches)
  static const Color accent = Color(0xFFE8751A);

  /// Green - Match confirmation, need-match pills, facility highlights
  /// Usage: "This matches your needs"
  /// NEVER use for CTAs or interactive chrome
  static const Color green = Color(0xFF1A9456);

  /// Green background - Subtle surface for full-match cards and pills
  static const Color greenBg = Color(0xFFF0F9F3);

  /// Green border - Border accent for full-match cards and green pills
  static const Color greenBorder = Color(0xFFD0ECD8);

  /// Red - Closed status, missed needs, warning states
  static const Color red = Color(0xFFC9403A);

  /// Orange background - Warm surface for partial-match cards
  static const Color orangeBg = Color(0xFFFEF8F2);

  /// Orange border - Border for partial-match cards
  static const Color orangeBorder = Color(0xFFF0DCC8);

  // ============================================================
  // NEUTRALS - Text Colors
  // ============================================================

  /// Primary text - Headings, labels, important content
  static const Color textPrimary = Color(0xFF0F0F0F);

  /// Secondary text - Body text, descriptions
  static const Color textSecondary = Color(0xFF555555);

  /// Tertiary text - Hints, helper text
  static const Color textTertiary = Color(0xFF888888);

  /// Muted text - Less important information
  static const Color textMuted = Color(0xFF999999);

  /// Placeholder text - Input placeholders, disabled text
  static const Color textPlaceholder = Color(0xFFAAAAAA);

  /// Disabled text - Fully disabled elements
  static const Color textDisabled = Color(0xFFBBBBBB);

  // ============================================================
  // NEUTRALS - UI Elements
  // ============================================================

  /// Page background - Primary white background
  static const Color bgPage = Color(0xFFFFFFFF);

  /// Card background - Same as page (white cards)
  static const Color bgCard = Color(0xFFFFFFFF);

  /// Input background - Off-white for text fields
  static const Color bgInput = Color(0xFFF5F5F5);

  /// Surface background - Alternative light background
  static const Color bgSurface = Color(0xFFFAFAFA);

  /// Border - Default border color for inputs, cards
  static const Color border = Color(0xFFE8E8E8);

  /// Border subtle - Very light borders
  static const Color borderSubtle = Color(0xFFF0F0F0);

  /// Divider - Separator lines
  static const Color divider = Color(0xFFF2F2F2);

  // ============================================================
  // SEMANTIC COLORS (Aliases for clarity)
  // ============================================================

  /// Error state - Form errors, required asterisks (same as red)
  static const Color error = red;

  /// Success state - Confirmations (same as green)
  static const Color success = green;
}

/// Spacing - Standard spacing scale
class AppSpacing {
  AppSpacing._();

  /// 4px - Minimal spacing
  static const double xs = 4.0;

  /// 8px - Small spacing (label to input, between paragraphs)
  static const double sm = 8.0;

  /// 12px - Medium spacing (heading to description, between chips)
  static const double md = 12.0;

  /// 16px - Standard spacing
  static const double lg = 16.0;

  /// 20px - Large spacing (between form fields)
  static const double xl = 20.0;

  /// 24px - Extra large spacing (page padding, before submit button)
  static const double xxl = 24.0;

  /// 32px - Section spacing
  static const double xxxl = 32.0;

  /// 40px - Major section spacing
  static const double huge = 40.0;
}

/// Border Radii - Standard corner radius scale
class AppRadius {
  AppRadius._();

  /// 7-8px - Chips
  static const double chip = 8.0;

  /// 9px - Facilities/payments
  static const double facility = 9.0;

  /// 10px - Filter buttons, gallery inner corners
  static const double filter = 10.0;

  /// 12px - Input fields
  static const double input = 12.0;

  /// 13px - Logo circle (50x50px)
  static const double logoSmall = 13.0;

  /// 14px - Primary buttons
  static const double button = 14.0;

  /// 16px - Cards
  static const double card = 16.0;

  /// 18px - Profile logo
  static const double logoLarge = 18.0;

  /// 22px - Bottom sheets (top only)
  static const double bottomSheet = 22.0;
}

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

/// Input Decorations - Reusable input styles
class AppInputDecorations {
  AppInputDecorations._();

  /// Standard input decoration for text fields
  static InputDecoration standard({
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      hintStyle: AppTypography.placeholder,
      labelStyle: AppTypography.label,
      filled: true,
      fillColor: AppColors.bgInput,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  /// Multiline input decoration for textareas
  static InputDecoration multiline({
    String? hintText,
    String? labelText,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      hintStyle: AppTypography.placeholder,
      labelStyle: AppTypography.label,
      filled: true,
      fillColor: AppColors.bgInput,
      contentPadding: const EdgeInsets.all(12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}

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

/// Design System Constants
class AppConstants {
  AppConstants._();

  // Screen dimensions (reference - iPhone 14/15 standard)
  static const double screenWidth = 390.0;
  static const double screenHeight = 844.0;

  // Component heights
  static const double statusBarHeight = 54.0;
  static const double tabBarHeight = 80.0;
  static const double inputHeight = 50.0;
  static const double buttonHeight = 50.0;

  // Card dimensions
  static const double logoCircleSize = 50.0;
  static const double cardPadding = 14.0;

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
}
