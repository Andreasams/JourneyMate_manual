// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/widgets/index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'package:shimmer/shimmer.dart';

/// A shimmer loading placeholder for restaurant list items.
///
/// Displays animated skeleton loading states for a list of restaurants, each
/// showing: - Square restaurant logo placeholder - Restaurant name
/// placeholder - Price range placeholder - Distance placeholder - Location
/// placeholder
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
    extends State<RestaurantListShimmerWidget> {
  /// =========================================================================
  /// CONSTANTS
  /// =========================================================================

  /// Shimmer animation colors
  static final Color _baseColor = Colors.grey[300]!;
  static final Color _highlightColor = Colors.grey[100]!;
  static const Color _placeholderColor = Colors.white;

  /// List configuration
  static const int _shimmerItemCount = 6;

  /// Divider styling
  static const double _dividerHeight = 12.0;
  static const double _dividerThickness = 1.0;
  static const Color _dividerColor = Color(0xFFF1F4F8);

  /// Item layout constants
  static const double _itemVerticalPadding = 4.0;
  static const double _logoToInfoSpacing = 8.0;
  static const double _infoItemSpacing = 8.0;

  /// Logo dimensions
  static const double _logoSize = 100.0;
  static const double _logoBorderRadius = 4.0;

  /// Info placeholder dimensions
  static const double _infoPlaceholderHeight = 16.0;
  static const double _restaurantNameWidth = 100.0;
  static const double _priceRangeWidth = 200.0;
  static const double _distanceWidth = 150.0;
  static const double _locationWidth = 120.0;

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
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      child: _buildShimmerList(),
    );
  }

  /// Builds the scrollable list of shimmer items
  Widget _buildShimmerList() {
    return ListView.separated(
      itemCount: _shimmerItemCount,
      separatorBuilder: (_, __) => _buildDivider(),
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
