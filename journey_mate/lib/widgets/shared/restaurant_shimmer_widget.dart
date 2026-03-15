import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';

/// A shimmer loading placeholder for restaurant detail pages.
///
/// Displays animated skeleton loading states for:
/// - Restaurant logo and info section
/// - OK line indicator
/// - Gallery title and tabs
/// - Gallery image grid
/// - Menu section with category buttons
///
/// This widget uses the shimmer package to create a smooth loading animation
/// that guides users' attention while content is being fetched.
class RestaurantShimmerWidget extends StatefulWidget {
  const RestaurantShimmerWidget({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<RestaurantShimmerWidget> createState() =>
      _RestaurantShimmerWidgetState();
}

class _RestaurantShimmerWidgetState extends State<RestaurantShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // =========================================================================
  // CONSTANTS
  // =========================================================================

  /// Shimmer animation colors — white tones visible on light page backgrounds
  static final Color _baseColor = AppColors.white.withValues(alpha: 0.85);
  static final Color _highlightColor = AppColors.white.withValues(alpha: 0.98);
  static final Color _placeholderColor = AppColors.white.withValues(alpha: 0.85);

  /// Layout constants
  static const double _containerPadding = AppSpacing.lg;
  static const double _defaultBorderRadius = AppRadius.chip;

  /// Logo section dimensions
  static const double _logoSize = 107.0;
  static const double _logoToInfoSpacing = AppSpacing.sm;
  static const double _infoItemSpacing = AppSpacing.sm;

  /// Restaurant info placeholder dimensions
  static const double _restaurantNameWidth = 200.0;
  static const double _restaurantNameHeight = 24.0;
  static const double _infoLineHeight = 16.0;
  static const double _cuisineWidth = 150.0;
  static const double _addressWidth = 180.0;
  static const double _contactWidth = 160.0;

  /// Section spacing
  static const double _logoToOkLineSpacing = AppSpacing.lg;
  static const double _okLineToGallerySpacing = AppSpacing.xxl;
  static const double _galleryTitleToTabsSpacing = AppSpacing.lg;
  static const double _tabsToImagesSpacing = AppSpacing.lg;
  static const double _galleryToMenuSpacing = AppSpacing.xxl;
  static const double _menuTitleToButtonsSpacing = AppSpacing.lg;

  /// OK line dimensions
  static const double _okLineWidth = 120.0;
  static const double _okLineHeight = 16.0;

  /// Gallery section dimensions
  static const double _galleryTitleWidth = 80.0;
  static const double _galleryTitleHeight = 20.0;
  static const int _galleryTabCount = 4;
  static const double _galleryTabWidth = 80.0;
  static const double _galleryTabHeight = 32.0;
  static const double _galleryTabBorderRadius = AppRadius.card;
  static const double _galleryTabSpacing = AppSpacing.sm;
  static const double _galleryImageHeight = 100.0;
  static const int _galleryImageCount = 4;
  static const double _galleryImageSpacing = AppSpacing.sm;

  /// Menu section dimensions
  static const double _menuTitleWidth = 100.0;
  static const double _menuTitleHeight = 20.0;
  static const int _menuButtonCount = 3;
  static const double _menuButtonWidth = 100.0;
  static const double _menuButtonHeight = 36.0;
  static const double _menuButtonBorderRadius = 18.0;
  static const double _menuButtonSpacing = AppSpacing.sm;

  // =========================================================================
  // LIFECYCLE
  // =========================================================================

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // =========================================================================
  // UI BUILDERS - MAIN LAYOUT
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _baseColor,
      highlightColor: _highlightColor,
      child: _buildMainContainer(),
    );
  }

  /// Builds the main container with padding
  Widget _buildMainContainer() {
    return Container(
      width: widget.width ?? double.infinity,
      padding: const EdgeInsets.all(_containerPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogoAndInfoSection(),
          const SizedBox(height: _logoToOkLineSpacing),
          _buildOkLine(),
          const SizedBox(height: _okLineToGallerySpacing),
          _buildGallerySection(),
          const SizedBox(height: _galleryToMenuSpacing),
          _buildMenuSection(),
        ],
      ),
    );
  }

  // =========================================================================
  // UI BUILDERS - LOGO & INFO SECTION
  // =========================================================================

  /// Builds the restaurant logo and info section
  Widget _buildLogoAndInfoSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLogoPlaceholder(),
        const SizedBox(width: _logoToInfoSpacing),
        _buildRestaurantInfoColumn(),
      ],
    );
  }

  /// Builds the restaurant logo placeholder
  Widget _buildLogoPlaceholder() {
    return Container(
      width: _logoSize,
      height: _logoSize,
      decoration: BoxDecoration(
        color: _placeholderColor,
        borderRadius: BorderRadius.circular(_defaultBorderRadius),
      ),
    );
  }

  /// Builds the restaurant info column
  Widget _buildRestaurantInfoColumn() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlaceholder(
              width: _restaurantNameWidth, height: _restaurantNameHeight),
          const SizedBox(height: _infoItemSpacing),
          _buildPlaceholder(width: _cuisineWidth, height: _infoLineHeight),
          const SizedBox(height: _infoItemSpacing),
          _buildPlaceholder(width: _addressWidth, height: _infoLineHeight),
          const SizedBox(height: _infoItemSpacing),
          _buildPlaceholder(width: _contactWidth, height: _infoLineHeight),
        ],
      ),
    );
  }

  // =========================================================================
  // UI BUILDERS - OK LINE
  // =========================================================================

  /// Builds the OK line placeholder
  Widget _buildOkLine() {
    return _buildPlaceholder(width: _okLineWidth, height: _okLineHeight);
  }

  // =========================================================================
  // UI BUILDERS - GALLERY SECTION
  // =========================================================================

  /// Builds the complete gallery section
  Widget _buildGallerySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGalleryTitle(),
        const SizedBox(height: _galleryTitleToTabsSpacing),
        _buildGallerySectionTitle(),
        const SizedBox(height: _galleryTitleToTabsSpacing),
        _buildGalleryTabs(),
        const SizedBox(height: _tabsToImagesSpacing),
        _buildGalleryImageGrid(),
      ],
    );
  }

  /// Builds the gallery title placeholder
  Widget _buildGalleryTitle() {
    return _buildPlaceholder(
        width: _galleryTitleWidth, height: _galleryTitleHeight);
  }

  /// Builds the gallery section title placeholder
  Widget _buildGallerySectionTitle() {
    return _buildPlaceholder(
        width: _galleryTitleWidth, height: _galleryTitleHeight);
  }

  /// Builds the horizontal scrolling gallery tab buttons
  Widget _buildGalleryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          _galleryTabCount,
          (index) => _buildGalleryTab(index),
        ),
      ),
    );
  }

  /// Builds a single gallery tab placeholder
  Widget _buildGalleryTab(int index) {
    return Container(
      margin: const EdgeInsets.only(right: _galleryTabSpacing),
      width: _galleryTabWidth,
      height: _galleryTabHeight,
      decoration: BoxDecoration(
        color: _placeholderColor,
        borderRadius: BorderRadius.circular(_galleryTabBorderRadius),
      ),
    );
  }

  /// Builds the gallery image grid
  Widget _buildGalleryImageGrid() {
    return SizedBox(
      height: _galleryImageHeight,
      child: Row(
        children: List.generate(
          _galleryImageCount,
          (index) => _buildGalleryImagePlaceholder(index),
        ),
      ),
    );
  }

  /// Builds a single gallery image placeholder
  Widget _buildGalleryImagePlaceholder(int index) {
    final isLastItem = index == _galleryImageCount - 1;

    return Expanded(
      child: Container(
        margin: EdgeInsets.only(right: isLastItem ? 0 : _galleryImageSpacing),
        decoration: BoxDecoration(
          color: _placeholderColor,
          borderRadius: BorderRadius.circular(_defaultBorderRadius),
        ),
      ),
    );
  }

  // =========================================================================
  // UI BUILDERS - MENU SECTION
  // =========================================================================

  /// Builds the complete menu section
  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMenuTitle(),
        const SizedBox(height: _menuTitleToButtonsSpacing),
        _buildMenuButtons(),
      ],
    );
  }

  /// Builds the menu title placeholder
  Widget _buildMenuTitle() {
    return _buildPlaceholder(width: _menuTitleWidth, height: _menuTitleHeight);
  }

  /// Builds the row of menu category button placeholders
  Widget _buildMenuButtons() {
    return Row(
      children: List.generate(
        _menuButtonCount,
        (index) => _buildMenuButton(index),
      ),
    );
  }

  /// Builds a single menu button placeholder
  Widget _buildMenuButton(int index) {
    final isLastItem = index == _menuButtonCount - 1;

    return Container(
      margin: EdgeInsets.only(right: isLastItem ? 0 : _menuButtonSpacing),
      width: _menuButtonWidth,
      height: _menuButtonHeight,
      decoration: BoxDecoration(
        color: _placeholderColor,
        borderRadius: BorderRadius.circular(_menuButtonBorderRadius),
      ),
    );
  }

  // =========================================================================
  // HELPER BUILDERS
  // =========================================================================

  /// Builds a generic rectangular placeholder with specified dimensions
  Widget _buildPlaceholder({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      color: _placeholderColor,
    );
  }
}
