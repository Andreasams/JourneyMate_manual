import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_providers.dart';
import '../../services/translation_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';

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
  // State & Keys
  // ─────────────────────────────────────────────────────────────────────────────

  /// Global key to get button position for overlay placement
  final GlobalKey _buttonKey = GlobalKey();

  /// Tracks overlay entry for manual dismissal
  OverlayEntry? _overlayEntry;

  /// Tracks if overlay is currently visible
  bool _isOverlayVisible = false;

  /// Available distance units (always both options, no filtering)
  static const List<String> _unitOrder = ['imperial', 'metric'];

  // ─────────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _dismissOverlay();
    super.dispose();
  }

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
  // Overlay Management
  // ─────────────────────────────────────────────────────────────────────────────

  /// Shows the distance unit selection overlay
  void _showOverlay(BuildContext context) {
    if (_isOverlayVisible) return;

    final renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final buttonSize = renderBox.size;
    final buttonPosition = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => _buildOverlay(
        context: context,
        buttonPosition: buttonPosition,
        buttonWidth: buttonSize.width,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOverlayVisible = true;
    });
  }

  /// Dismisses the overlay
  void _dismissOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      try {
        setState(() {
          _isOverlayVisible = false;
        });
      } catch (e) {
        // Widget already disposed - silently ignore
        debugPrint('⚠️ setState called on disposed DistanceUnitSelectorButton: $e');
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Distance Unit Selection
  // ─────────────────────────────────────────────────────────────────────────────

  /// Handles distance unit selection from overlay
  Future<void> _handleUnitSelection(String newUnit) async {
    final currentUnit = _getCurrentDistanceUnit();

    // Dismiss overlay immediately for responsive feel
    _dismissOverlay();

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

    return GestureDetector(
      onTap: () => _showOverlay(context),
      child: Container(
        key: _buttonKey,
        width: widget.width,
        height: widget.height ?? 50.0,
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getUnitDisplayLabel(context, currentUnit),
                style: AppTypography.bodyRegular.copyWith(
                  fontWeight: FontWeight.w300,
                ),
              ),
              Icon(
                _isOverlayVisible
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
                size: 24.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Build: Overlay
  // ─────────────────────────────────────────────────────────────────────────────

  /// Builds the complete overlay positioned below the button
  Widget _buildOverlay({
    required BuildContext context,
    required Offset buttonPosition,
    required double buttonWidth,
  }) {
    return Stack(
      children: [
        // Invisible barrier to detect outside taps
        Positioned.fill(
          child: GestureDetector(
            onTap: _dismissOverlay,
            child: Container(color: Colors.transparent),
          ),
        ),
        // Distance unit selection overlay
        Positioned(
          left: buttonPosition.dx,
          top: buttonPosition.dy + (widget.height ?? 50.0) + AppSpacing.xs,
          child: _buildOverlayContent(context, buttonWidth),
        ),
      ],
    );
  }

  /// Builds the overlay content container
  Widget _buildOverlayContent(BuildContext context, double width) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4.0,
              spreadRadius: 1.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.xs,
          bottom: AppSpacing.xs,
        ),
        child: _buildUnitList(context),
      ),
    );
  }

  /// Builds the list of distance unit options
  Widget _buildUnitList(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _unitOrder.map((unit) {
        return _buildUnitItem(context, unit);
      }).toList(),
    );
  }

  /// Builds a single distance unit item
  Widget _buildUnitItem(BuildContext context, String unit) {
    return InkWell(
      onTap: () => _handleUnitSelection(unit),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(
          left: AppSpacing.xs,
          top: AppSpacing.md,
          bottom: AppSpacing.md,
        ),
        child: Text(
          _getUnitDisplayLabel(context, unit),
          style: AppTypography.bodyRegular.copyWith(
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}
