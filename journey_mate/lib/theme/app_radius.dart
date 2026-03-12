/// Border Radii — Unified scale: 2 · 4 · 8 · 12 · 16 · 20
///
/// Every radius in the app maps to one of these six values.
/// Semantic names give context; the underlying scale keeps visuals
/// consistent.
class AppRadius {
  AppRadius._();

  // ── 2px ──────────────────────────────────────────────────────
  /// Drag handles in bottom sheets
  static const double handle = 2.0;

  // ── 4px ──────────────────────────────────────────────────────
  /// Checkbox corners (filter columns, sort sheet, feedback form)
  static const double checkbox = 4.0;

  // ── 8px ──────────────────────────────────────────────────────
  /// Chips, facility tags, payment badges
  static const double chip = 8.0;

  /// Facility / payment containers (same visual weight as chips)
  static const double facility = 8.0;

  // ── 12px ─────────────────────────────────────────────────────
  /// Filter buttons, tab selectors
  static const double filter = 12.0;

  /// Text inputs, text areas, dropdowns
  static const double input = 12.0;

  /// Primary / secondary action buttons
  static const double button = 12.0;

  /// Small logo containers (50×50)
  static const double logoSmall = 12.0;

  // ── 16px ─────────────────────────────────────────────────────
  /// Cards (search results, settings, match cards)
  static const double card = 16.0;

  /// Large logo / avatar containers
  static const double logoLarge = 16.0;

  // ── 20px ─────────────────────────────────────────────────────
  /// Bottom sheet top corners
  static const double bottomSheet = 20.0;

  /// Pill-shaped floating buttons (sort, open-only)
  static const double pill = 20.0;
}
