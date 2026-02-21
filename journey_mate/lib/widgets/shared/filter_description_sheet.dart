import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';

/// A bottom sheet that displays a filter or feature description.
///
/// Used in Business Profile and Business Information pages when user taps
/// info icon on filter chips.
///
/// **Design notes:**
/// - Fixed 400px height container
/// - White background with 22px top corner radius
/// - Drag handle (80×4) centered at top
/// - Close button (40×40 circle) at top-left
/// - Content padded 28px horizontally
///
/// **FlutterFlow source:**
/// `_flutterflow_export/lib/profile/business_information/filter_description_sheet/filter_description_sheet_widget.dart`
///
/// **Usage:**
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   backgroundColor: Colors.transparent,
///   builder: (context) => SizedBox(
///     height: 400,
///     child: FilterDescriptionSheet(
///       filterName: 'Vegan Options',
///       filterDescription: 'This restaurant offers...',
///     ),
///   ),
/// );
/// ```
class FilterDescriptionSheet extends StatefulWidget {
  const FilterDescriptionSheet({
    super.key,
    required this.filterName,
    required this.filterDescription,
  });

  /// The name of the filter (e.g., "Vegan Options")
  /// Should be pre-translated by parent widget
  final String filterName;

  /// The detailed description of what this filter means
  /// Should be pre-translated by parent widget
  final String filterDescription;

  @override
  State<FilterDescriptionSheet> createState() => _FilterDescriptionSheetState();
}

class _FilterDescriptionSheetState extends State<FilterDescriptionSheet> {
  @override
  Widget build(BuildContext context) {
    // DO NOT use AnimatedContainer here - showModalBottomSheet already
    // provides slide-up animation. Using AnimatedContainer creates
    // double animation (janky UX).
    return Container(
      width: double.infinity,
      height: 400.0,
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.bottomSheet),
          topRight: Radius.circular(AppRadius.bottomSheet),
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section: Drag handle + Close button (stacked)
          _buildTopSection(),

          // Content section: Filter name + description
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Filter name (heading)
                  Text(
                    widget.filterName,
                    textAlign: TextAlign.start,
                    style: AppTypography.sectionHeading,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Filter description (body text with light weight)
                  Text(
                    widget.filterDescription,
                    style: AppTypography.bodyRegular.copyWith(
                      fontWeight: FontWeight.w300,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the top section with drag handle and close button
  Widget _buildTopSection() {
    return Stack(
      children: [
        // Drag handle (centered)
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Container(
              width: 80.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ),
        ),

        // Close button (top-left)
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 12.0),
            child: Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.textPrimary,
                  size: 30.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
