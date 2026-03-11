import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:map_launcher/map_launcher.dart';

import '../../services/translation_service.dart';
import '../../theme/app_colors.dart';
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
            // Swipe bar
            const BottomSheetHeader(),

            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                td(ref, 'map_select_app'),
                style: AppTypography.h6,
              ),
            ),

            SizedBox(height: AppSpacing.md),

            // Google Maps row
            if (googleMap != null)
              _MapRow(
                icon: Icons.map,
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
                icon: Icons.apple,
                label: td(ref, 'map_app_apple'),
                onTap: () {
                  Navigator.of(context).pop();
                  onMapSelected(appleMap);
                },
              ),

            SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

/// A single selectable row inside [MapSelectionSheet].
class _MapRow extends StatelessWidget {
  const _MapRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: AppColors.textPrimary),
            SizedBox(width: AppSpacing.md),
            Text(label, style: AppTypography.body),
            const Spacer(),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
