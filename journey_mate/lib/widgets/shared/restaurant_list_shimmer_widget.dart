import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// A shimmer loading placeholder for restaurant list items.
///
/// Displays animated skeleton loading states for a list of restaurants, each
/// showing:
/// - Square restaurant logo placeholder
/// - Restaurant name placeholder
/// - Price range placeholder
/// - Distance placeholder
/// - Location placeholder
class RestaurantListShimmerWidget extends StatefulWidget {
  const RestaurantListShimmerWidget({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<RestaurantListShimmerWidget> createState() =>
      _RestaurantListShimmerWidgetState();
}

class _RestaurantListShimmerWidgetState
    extends State<RestaurantListShimmerWidget>
    with SingleTickerProviderStateMixin {
  /// =========================================================================
  /// CONSTANTS
  /// =========================================================================

  /// Shimmer animation colors — grey base sweeps to white for visible animation
  static const Color _baseColor = AppColors.border;
  static const Color _highlightColor = AppColors.white;
  static const Color _placeholderColor = AppColors.border;

  /// List configuration
  static const int _shimmerItemCount = 6;

  /// Animation configuration
  static const Duration _animationDuration = Duration(milliseconds: 1500);

  /// Divider styling
  static const double _dividerHeight = AppSpacing.md;
  static const double _dividerThickness = 1.0;
  static const Color _dividerColor = AppColors.divider;

  /// Item layout constants
  static const double _itemVerticalPadding = AppSpacing.xs;
  static const double _logoToInfoSpacing = AppSpacing.sm;
  static const double _infoItemSpacing = AppSpacing.sm;

  /// Logo dimensions
  static const double _logoSize = 100.0;
  static const double _logoBorderRadius = 4.0;

  /// Info placeholder dimensions
  static const double _infoPlaceholderHeight = 16.0;
  static const double _restaurantNameWidth = 100.0;
  static const double _priceRangeWidth = 200.0;
  static const double _distanceWidth = 150.0;
  static const double _locationWidth = 120.0;

  late AnimationController _controller;

  /// =========================================================================
  /// LIFECYCLE METHODS
  /// =========================================================================

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// =========================================================================
  /// UI BUILDERS - MAIN LAYOUT
  /// =========================================================================

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _baseColor,
      highlightColor: _highlightColor,
      child: _buildMainContainer(),
    );
  }

  /// Builds the main container with shimmer list
  Widget _buildMainContainer() {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height,
      child: _buildShimmerList(),
    );
  }

  /// Builds the scrollable list of shimmer items
  Widget _buildShimmerList() {
    return ListView.separated(
      itemCount: _shimmerItemCount,
      separatorBuilder: (_, _) => _buildDivider(),
      itemBuilder: (_, index) => _buildShimmerListItem(),
    );
  }

  /// =========================================================================
  /// UI BUILDERS - LIST ITEM
  /// =========================================================================

  /// Builds a single shimmer list item
  Widget _buildShimmerListItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _itemVerticalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogoPlaceholder(),
          const SizedBox(width: _logoToInfoSpacing),
          _buildInfoColumn(),
        ],
      ),
    );
  }

  /// Builds the restaurant logo placeholder
  Widget _buildLogoPlaceholder() {
    return Container(
      width: _logoSize,
      height: _logoSize,
      decoration: BoxDecoration(
        color: _placeholderColor,
        borderRadius: BorderRadius.circular(_logoBorderRadius),
      ),
    );
  }

  /// Builds the restaurant info column with multiple text placeholders
  Widget _buildInfoColumn() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRestaurantNamePlaceholder(),
          const SizedBox(height: _infoItemSpacing),
          _buildPriceRangePlaceholder(),
          const SizedBox(height: _infoItemSpacing),
          _buildDistancePlaceholder(),
          const SizedBox(height: _infoItemSpacing),
          _buildLocationPlaceholder(),
        ],
      ),
    );
  }

  /// =========================================================================
  /// UI BUILDERS - INFO PLACEHOLDERS
  /// =========================================================================

  /// Builds the restaurant name placeholder (first row)
  Widget _buildRestaurantNamePlaceholder() {
    return _buildInfoPlaceholder(width: _restaurantNameWidth);
  }

  /// Builds the price range placeholder (second row)
  Widget _buildPriceRangePlaceholder() {
    return _buildInfoPlaceholder(width: _priceRangeWidth);
  }

  /// Builds the distance placeholder (third row)
  Widget _buildDistancePlaceholder() {
    return _buildInfoPlaceholder(width: _distanceWidth);
  }

  /// Builds the location placeholder (fourth row)
  Widget _buildLocationPlaceholder() {
    return _buildInfoPlaceholder(width: _locationWidth);
  }

  /// =========================================================================
  /// HELPER BUILDERS
  /// =========================================================================

  /// Builds a generic info placeholder with specified width
  Widget _buildInfoPlaceholder({required double width}) {
    return Container(
      width: width,
      height: _infoPlaceholderHeight,
      color: _placeholderColor,
    );
  }

  /// Builds the divider between list items
  Widget _buildDivider() {
    return const Divider(
      height: _dividerHeight,
      thickness: _dividerThickness,
      color: _dividerColor,
    );
  }
}
