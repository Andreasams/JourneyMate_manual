import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_constants.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import 'restaurant_shimmer_widget.dart';
import 'shimmer_card_widget.dart';

/// A shimmer loading placeholder for restaurant list items.
///
/// Displays 5 animated skeleton cards with card styling (white background,
/// border, rounded corners) matching [_BusinessListItem] structure.
/// Content inside each card shimmers to indicate loading details.
class RestaurantListShimmerWidget extends StatelessWidget {
  const RestaurantListShimmerWidget({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  /// List configuration — show 5 cards to ensure bottom isn't visible while loading
  static const int _shimmerItemCount = 5;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: Colors.grey[200]!,
      child: SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: ListView.builder(
          padding: EdgeInsets.only(
            top: AppSpacing.mlg,
            bottom: AppSpacing.mlg,
          ),
          itemCount: _shimmerItemCount,
          itemBuilder: (_, index) => ShimmerCardWidget(index: index),
        ),
      ),
    );
  }}
