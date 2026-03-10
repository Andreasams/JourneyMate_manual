import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'bottom_sheet_header.dart';

/// DescriptionSheet — Shared bottom sheet for displaying title + body text.
///
/// Canonical JourneyMate bottom sheet pattern: swipe bar, 40px close button
/// top-right, self-sizing height based on content.
///
/// Replaces FacilitiesInfoSheet, CategoryDescriptionSheet, and
/// FilterDescriptionSheet with a single, design-system-aligned widget.
///
/// The sheet sizes itself to fit content, with a minimum height of 40% and
/// maximum of 80% of screen height. Scrolls automatically when content
/// exceeds the maximum.
///
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   backgroundColor: Colors.transparent,
///   builder: (context) => DescriptionSheet(
///     title: 'Appetizers',
///     description: 'Start your meal with...',
///   ),
/// );
/// ```
///
/// Design:
/// - Background: AppColors.bgCard
/// - Top corners: AppRadius.bottomSheet (22px)
/// - Swipe bar: 80×4px, centered, 8px top padding, AppColors.textPrimary
/// - Close button: 40×40px circle, top-right, 12px from edges
/// - Header height: 64px
/// - Content: 24px horizontal padding, sectionHeading title, bodyRegular body
/// - Fallback: italic text in textTertiary when description is null/empty
class DescriptionSheet extends StatefulWidget {
  const DescriptionSheet({
    super.key,
    required this.title,
    this.description,
    this.scrollController,
    this.fallbackDescription = 'No description available.',
    this.width,
  });

  /// Heading text displayed at the top of the sheet.
  final String title;

  /// Body text. When null or empty, [fallbackDescription] is shown instead.
  final String? description;

  /// Optional scroll controller (for external scroll coordination).
  final ScrollController? scrollController;

  /// Text shown when [description] is null or empty.
  final String? fallbackDescription;

  /// Optional width override for the sheet container.
  final double? width;

  @override
  State<DescriptionSheet> createState() => _DescriptionSheetState();
}

class _DescriptionSheetState extends State<DescriptionSheet> {
  static const double _contentHorizontalPadding = 24.0;
  static const double _minHeightFraction = 0.4;
  static const double _maxHeightFraction = 0.8;

  bool get _hasDescription =>
      widget.description != null && widget.description!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: screenHeight * _minHeightFraction,
        maxHeight: screenHeight * _maxHeightFraction,
      ),
      child: Container(
        width: widget.width,
        decoration: BottomSheetHeader.sheetDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BottomSheetHeader(
              rightAction: BottomSheetAction(
                icon: Icons.close,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                controller: widget.scrollController,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: _contentHorizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppSpacing.md),
                    Text(
                      widget.title,
                      style: AppTypography.h4,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      _hasDescription
                          ? widget.description!
                          : (widget.fallbackDescription ??
                              'No description available.'),
                      style: AppTypography.bodyLg.copyWith(
                        color: _hasDescription
                            ? AppColors.textSecondary
                            : AppColors.textTertiary,
                        fontStyle: _hasDescription
                            ? FontStyle.normal
                            : FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
