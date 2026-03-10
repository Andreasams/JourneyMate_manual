import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';

/// Generic overlay dropdown selector with custom button and list rendering.
///
/// Displays a button showing the currently selected item. Tapping the button
/// opens a custom overlay dropdown positioned below the button. Selecting an
/// item from the overlay calls the onItemSelected callback and dismisses the
/// overlay.
///
/// **Features:**
/// - Generic type-safe implementation for any selectable items
/// - Custom overlay positioning (4px gap below button by default)
/// - Tap-outside-to-dismiss behavior
/// - Animated chevron icon (down/up)
/// - Flexible display via itemDisplayBuilder callback
///
/// **Usage:**
/// ```dart
/// OverlayDropdownSelector<String>(
///   items: ['en', 'da', 'de'],
///   selectedItem: 'en',
///   onItemSelected: (languageCode) => updateLanguage(languageCode),
///   itemDisplayBuilder: (code) => getLanguageName(code),
///   width: 200,
///   height: 50,
/// )
/// ```
///
/// **Design:**
/// - Button: white background (AppColors.bgSurface), rounded corners
/// - Overlay: matches button width, positioned below with configurable gap
/// - List items: InkWell with padding, lightweight text style
///
/// **Migration Notes:**
/// Extracted from LanguageSelectorButton, CurrencySelectorButton, and
/// DistanceUnitSelectorButton to eliminate 540 lines of duplicated UI code.
/// Each selector now wraps this component and only handles business logic.
class OverlayDropdownSelector<T> extends StatefulWidget {
  const OverlayDropdownSelector({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onItemSelected,
    required this.itemDisplayBuilder,
    this.width,
    this.height,
    this.overlayGap,
  });

  /// List of selectable items
  final List<T> items;

  /// Currently selected item
  final T selectedItem;

  /// Callback when item is selected (NOT async - parent handles async operations)
  final void Function(T item) onItemSelected;

  /// Builder for button and list item display text
  final String Function(T item) itemDisplayBuilder;

  /// Optional button width (defaults to widget width)
  final double? width;

  /// Optional button height (defaults to 50.0)
  final double? height;

  /// Optional gap between button and overlay (defaults to AppSpacing.xs = 4px)
  final double? overlayGap;

  @override
  State<OverlayDropdownSelector<T>> createState() =>
      _OverlayDropdownSelectorState<T>();
}

class _OverlayDropdownSelectorState<T>
    extends State<OverlayDropdownSelector<T>> {
  // ─────────────────────────────────────────────────────────────────────────────
  // State & Keys
  // ─────────────────────────────────────────────────────────────────────────────

  /// Global key to get button position for overlay placement
  final GlobalKey _buttonKey = GlobalKey();

  /// Tracks overlay entry for manual dismissal
  OverlayEntry? _overlayEntry;

  /// Tracks if overlay is currently visible
  bool _isOverlayVisible = false;

  // ─────────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    // Clean up overlay entry directly without setState (widget is disposing)
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Overlay Management
  // ─────────────────────────────────────────────────────────────────────────────

  /// Shows the selection overlay
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
      setState(() {
        _isOverlayVisible = false;
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Item Selection
  // ─────────────────────────────────────────────────────────────────────────────

  /// Handles item selection from overlay
  void _handleItemSelection(T item) {
    // Dismiss overlay immediately for responsive feel
    _dismissOverlay();

    // Notify parent callback
    widget.onItemSelected(item);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Build: Main
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final displayText = widget.itemDisplayBuilder(widget.selectedItem);

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
                displayText,
                style: AppTypography.bodyLg.copyWith(
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
        // Item selection overlay
        Positioned(
          left: buttonPosition.dx,
          top: buttonPosition.dy +
              (widget.height ?? 50.0) +
              (widget.overlayGap ?? AppSpacing.xs),
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
        child: _buildItemList(context),
      ),
    );
  }

  /// Builds the list of item options
  Widget _buildItemList(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widget.items.map((item) {
        return _buildItem(context, item);
      }).toList(),
    );
  }

  /// Builds a single item
  Widget _buildItem(BuildContext context, T item) {
    return InkWell(
      onTap: () => _handleItemSelection(item),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(
          left: AppSpacing.xs,
          top: AppSpacing.md,
          bottom: AppSpacing.md,
        ),
        child: Text(
          widget.itemDisplayBuilder(item),
          style: AppTypography.bodyLg.copyWith(
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}
