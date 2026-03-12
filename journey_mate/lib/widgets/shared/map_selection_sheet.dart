import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:map_launcher/map_launcher.dart';

import '../../services/translation_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'bottom_sheet_header.dart';

/// Bottom sheet that lets the user choose between Google Maps and Apple Maps.
///
/// Always shown (even with a single option) so the user gets a consistent
/// experience. Each row fires [onMapSelected] and pops the sheet.
class MapSelectionSheet extends ConsumerWidget {
  const MapSelectionSheet({
    super.key,
    required this.availableMaps,
    required this.onMapSelected,
  });

  final List<AvailableMap> availableMaps;
  final void Function(AvailableMap) onMapSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final googleMap = availableMaps
        .where((m) => m.mapType == MapType.google)
        .firstOrNull;
    final appleMap = availableMaps
        .where((m) => m.mapType == MapType.apple)
        .firstOrNull;

    return Container(
      decoration: BottomSheetHeader.sheetDecoration(),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: swipe bar + close button
            _buildHeader(context),

            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                td(ref, 'map_select_app'),
                style: AppTypography.h6,
              ),
            ),

            SizedBox(height: AppSpacing.lg),

            // Google Maps row
            if (googleMap != null)
              _MapRow(
                asset: 'assets/images/google_maps_pin.png',
                label: td(ref, 'map_app_google'),
                onTap: () {
                  Navigator.of(context).pop();
                  onMapSelected(googleMap);
                },
              ),

            if (googleMap != null && appleMap != null)
              Divider(height: 1, color: AppColors.border),

            // Apple Maps row
            if (appleMap != null)
              _MapRow(
                asset: 'assets/images/apple_maps_logo.png',
                label: td(ref, 'map_app_apple'),
                onTap: () {
                  Navigator.of(context).pop();
                  onMapSelected(appleMap);
                },
              ),

            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppSpacing.lg,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.md,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Swipe indicator — centered
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.dragHandle,
                borderRadius: BorderRadius.circular(AppRadius.handle),
              ),
            ),
          ),
          // Close button — top right
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                Icons.close,
                size: 24,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single selectable row inside [MapSelectionSheet].
class _MapRow extends StatelessWidget {
  const _MapRow({
    required this.asset,
    required this.label,
    required this.onTap,
  });

  final String asset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xxl,
        ),
        child: Row(
          children: [
            Image.asset(
              asset,
              width: 32,
              height: 32,
            ),
            SizedBox(width: AppSpacing.md),
            Text(label, style: AppTypography.body),
          ],
        ),
      ),
    );
  }
}
