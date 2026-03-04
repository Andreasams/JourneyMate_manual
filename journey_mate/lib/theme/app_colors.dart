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

  /// Full-match card border - Subtle green border for full-match result cards
  static const Color fullMatchCardBorder = Color(0xFFB8D4C0);

  /// Red - Closed status, missed needs, warning states
  static const Color red = Color(0xFFC9403A);

  /// Red border - Border for missed-need chips in match cards
  static const Color redBorder = Color(0xFFF5D5D2);

  /// Red background - Subtle surface for no-match cards and error states
  static const Color redBg = Color(0xFFFEF4F3);

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

  // ============================================================
  // STATUS INDICATORS
  // ============================================================

  /// Status enabled - Green dot for enabled features (e.g., location sharing)
  static const Color statusEnabled = Color(0xFF2A9456);

  /// Status disabled - Red dot for disabled features (same as red)
  static const Color statusDisabled = red;

  /// Card background subtle - Very subtle gray for status cards (same as bgSurface)
  static const Color bgCardSubtle = bgSurface;
}
