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
        child: ListView.separated(
          padding: const EdgeInsets.only(
            top: AppSpacing.lg, // 16px per JSX
            bottom: AppSpacing.xxxl, // 32px per JSX
          ),
          itemCount: _shimmerItemCount,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm), // 8px
          itemBuilder: (_, __) => const ShimmerCardWidget(),
        ),
      ),
    );
  }}
