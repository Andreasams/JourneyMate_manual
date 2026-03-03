import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_providers.dart';
import '../../services/translation_service.dart';
import 'overlay_dropdown_selector.dart';

/// A button that displays the currently selected distance unit and opens an
/// overlay selector on tap.
///
/// **State Management:**
/// - Uses local state for overlay management (GlobalKey, OverlayEntry)
/// - Reads distance unit from `localizationProvider`
/// - Updates distance unit via `localizationProvider.notifier.setDistanceUnit()`
///
/// **Features:**
/// - Displays distance unit label (e.g., "Imperial – miles (mi.)")
/// - Opens overlay with two options: Imperial and Metric
/// - Both options always available (no language-based filtering)
/// - Overlay dismisses on selection or outside tap
/// - Smart positioning with 4px gap between button and overlay
///
/// **Usage:**
/// - Only visible when language is English (handled by parent widget)
/// - Simpler than CurrencySelectorButton (no API calls, no analytics)
class DistanceUnitSelectorButton extends ConsumerStatefulWidget {
  const DistanceUnitSelectorButton({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  ConsumerState<DistanceUnitSelectorButton> createState() =>
      _DistanceUnitSelectorButtonState();
}

class _DistanceUnitSelectorButtonState
    extends ConsumerState<DistanceUnitSelectorButton> {
  // ─────────────────────────────────────────────────────────────────────────────
  // State (Business Logic Only - UI managed by OverlayDropdownSelector)
  // ─────────────────────────────────────────────────────────────────────────────

  /// Available distance units (always both options, no filtering)
  static const List<String> _unitOrder = ['imperial', 'metric'];

  // ─────────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────────
  // (No dispose needed - overlay managed by OverlayDropdownSelector)

  // ─────────────────────────────────────────────────────────────────────────────
  // Data Retrieval
  // ─────────────────────────────────────────────────────────────────────────────

  /// Gets the current distance unit from provider
  String _getCurrentDistanceUnit() {
    final localization = ref.read(localizationProvider);
    return localization.distanceUnit;
  }

  /// Gets the distance unit display label
  /// Format: "Imperial – miles (mi.)" or "Metric – kilometers (km.)"
  String _getUnitDisplayLabel(BuildContext context, String unit) {
    return td(ref, 'distance_unit_$unit');
  }


  // ─────────────────────────────────────────────────────────────────────────────
  // Distance Unit Selection
  // ─────────────────────────────────────────────────────────────────────────────

  /// Handles distance unit selection from overlay
  Future<void> _handleUnitSelection(String newUnit) async {
    final currentUnit = _getCurrentDistanceUnit();

    // Skip if selecting same unit
    if (newUnit == currentUnit) return;

    // Update provider (persists to SharedPreferences)
    await ref.read(localizationProvider.notifier).setDistanceUnit(newUnit);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Build: Main
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Watch localization changes (distance unit updates)
    final localization = ref.watch(localizationProvider);
    final currentUnit = localization.distanceUnit;

    return OverlayDropdownSelector<String>(
      items: _unitOrder,
      selectedItem: currentUnit,
      onItemSelected: _handleUnitSelection,
      itemDisplayBuilder: (unit) => _getUnitDisplayLabel(context, unit),
      width: widget.width,
      height: widget.height,
    );
  }
}
