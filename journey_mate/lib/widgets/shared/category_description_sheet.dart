import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';

/// CategoryDescriptionSheet - Bottom sheet displaying menu category description
///
/// Shows a category's name and description in a modal bottom sheet with
/// drag handle and close button. Used when user taps a category name in
/// the menu page.
///
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   backgroundColor: Colors.transparent,
///   builder: (context) => DraggableScrollableSheet(
///     initialChildSize: 0.4,
///     maxChildSize: 0.9,
///     minChildSize: 0.25,
///     builder: (context, scrollController) => CategoryDescriptionSheet(
///       categoryName: 'Appetizers',
///       categoryDescription: 'Start your meal...',
///       scrollController: scrollController,
///     ),
///   ),
/// );
/// ```
///
/// Props:
/// - categoryName: Category name to display
/// - categoryDescription: Category description text
/// - width: Sheet width (usually full width)
/// - scrollController: Required for DraggableScrollableSheet
///
/// Design:
/// - DraggableScrollableSheet (initial 40%, max 90%, min 25%)
/// - Rounded top corners (22px)
/// - Swipe bar indicator at top
/// - Close button at top-right
/// - Category name: sectionHeading style (18px, w700)
/// - Description: bodyRegular style (14px, w400)
/// - No translation needed (data from API)
class CategoryDescriptionSheet extends StatefulWidget {
  const CategoryDescriptionSheet({
    super.key,
    required this.categoryName,
    required this.categoryDescription,
    required this.scrollController,
    this.width,
  });

  final String categoryName;
  final String categoryDescription;
  final ScrollController scrollController;
  final double? width;

  @override
  State<CategoryDescriptionSheet> createState() =>
      _CategoryDescriptionSheetState();
}

class _CategoryDescriptionSheetState extends State<CategoryDescriptionSheet> {
  // Layout constants
  static const double _swipeBarWidth = 80.0;
  static const double _swipeBarHeight = 4.0;
  static const double _swipeBarTopPadding = 8.0;
  static const double _closeButtonSize = 40.0;
  static const double _closeButtonTopPosition = 12.0;
  static const double _closeButtonRightPosition = 12.0;
  static const double _closeIconSize = 24.0;
  static const double _contentHorizontalPadding = 24.0;
  static const double _headerHeight = 64.0;

  /// Builds the header section with swipe bar and close button
  Widget _buildHeader() {
    return SizedBox(
      height: _headerHeight,
      child: Stack(
        children: [
          // Swipe bar indicator
          Positioned(
            top: _swipeBarTopPadding,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: _swipeBarWidth,
                height: _swipeBarHeight,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          // Close button
          Positioned(
            top: _closeButtonTopPosition,
            right: _closeButtonRightPosition,
            child: Container(
              width: _closeButtonSize,
              height: _closeButtonSize,
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.close,
                  color: AppColors.textPrimary,
                  size: _closeIconSize,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.bottomSheet),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
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
                    widget.categoryName,
                    style: AppTypography.sectionHeading,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    widget.categoryDescription.isNotEmpty
                        ? widget.categoryDescription
                        : 'No description available.',
                    style: AppTypography.bodyRegular.copyWith(
                      color: widget.categoryDescription.isNotEmpty
                          ? AppColors.textSecondary
                          : AppColors.textTertiary,
                      fontStyle: widget.categoryDescription.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
