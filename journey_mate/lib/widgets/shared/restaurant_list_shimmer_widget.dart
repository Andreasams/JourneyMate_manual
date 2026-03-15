import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_constants.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import 'restaurant_shimmer_widget.dart';

/// A shimmer loading placeholder for restaurant list items.
///
/// Displays animated skeleton cards matching the layout of [_BusinessListItem]:
/// - Card with border and rounded corners
/// - 50×50 logo placeholder with 12px border radius
/// - 3 info lines: name, status, details (with 2px spacing)
class RestaurantListShimmerWidget extends StatelessWidget {
  const RestaurantListShimmerWidget({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  /// List configuration
  static const int _shimmerItemCount = 6;

  /// Card styling — matches _BusinessListItem
  static const double _cardBorderWidth = 1.5;
  static const double _cardPadding = AppSpacing.mlg; // 14px

  /// Logo dimensions — matches AppConstants.logoCircleSize (50px)
  static const double _logoSize = AppConstants.logoCircleSize;
  static const double _logoBorderRadius = AppRadius.logoSmall; // 12px
  static const double _logoToInfoSpacing = AppSpacing.md; // 12px

  /// Info row spacing — matches _BusinessListItem _rowSpacing (2px)
  static const double _infoItemSpacing = AppSpacing.xxs; // 2px

  /// Info placeholder dimensions
  static const double _nameHeight = 14.0;
  static const double _lineHeight = 12.0;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: RestaurantShimmerWidget.baseColor,
      highlightColor: RestaurantShimmerWidget.highlightColor,
      child: SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: ListView.separated(
          itemCount: _shimmerItemCount,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, index) => _buildShimmerCard(),
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: _logoSize),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border.all(color: AppColors.border, width: _cardBorderWidth),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      padding: const EdgeInsets.all(_cardPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: _logoSize,
            height: _logoSize,
            decoration: BoxDecoration(
              color: RestaurantShimmerWidget.placeholderColor,
              borderRadius: BorderRadius.circular(_logoBorderRadius),
            ),
          ),
          const SizedBox(width: _logoToInfoSpacing),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPlaceholder(width: w * 0.6, height: _nameHeight),
                    const SizedBox(height: _infoItemSpacing),
                    _buildPlaceholder(width: w * 0.4, height: _lineHeight),
                    const SizedBox(height: _infoItemSpacing),
                    _buildPlaceholder(width: w * 0.7, height: _lineHeight),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildPlaceholder(
      {required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: RestaurantShimmerWidget.placeholderColor,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
    );
  }
}
