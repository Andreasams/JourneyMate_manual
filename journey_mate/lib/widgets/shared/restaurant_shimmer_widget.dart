import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';

/// A shimmer loading placeholder for the business profile page.
///
/// Mirrors the actual page layout:
/// 1. Hero section (64×64 logo + name + 3 info rows) in a SectionCard
/// 2. Quick action pills (4 horizontal pill buttons)
/// 3. Opening hours placeholder card
/// 4. Gallery section (title + 4 tabs + 4-image grid)
/// 5. Menu section (title + 3 pill buttons)
///
/// Section content builders are exposed as static methods so the business
/// profile page can reuse them for per-section loading states, ensuring
/// identical appearance between full-page and per-section shimmer.
///
/// Call [wrapWithShimmer] to add the Shimmer.fromColors animation wrapper.
class RestaurantShimmerWidget extends StatelessWidget {
  const RestaurantShimmerWidget({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  // =========================================================================
  // SHARED CONSTANTS — used by both full-page and per-section shimmers
  // =========================================================================

  static const Color baseColor = AppColors.border;
  static const Color highlightColor = AppColors.white;
  static const Color placeholderColor = AppColors.border;

  // =========================================================================
  // SHIMMER WRAPPER — shared by section shimmers on business profile page
  // =========================================================================

  /// Wraps [child] in a single Shimmer.fromColors with the shared palette.
  /// Used by business_profile_page_v2.dart to wrap multiple section shimmers
  /// in one animation (synchronized sweep, single ticker).
  static Widget wrapWithShimmer({required Widget child}) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }

  // =========================================================================
  // STATIC SECTION CONTENT BUILDERS — reused by business_profile_page_v2.dart
  // =========================================================================

  /// Gallery section content: title + 4 category tabs + 4-image grid.
  /// Returns bare content — caller wraps in [wrapWithShimmer] + Padding.
  static Widget buildGallerySectionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _staticPlaceholder(width: 80, height: 20),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: List.generate(4, (index) {
            return Container(
              margin:
                  EdgeInsets.only(right: index == 3 ? 0 : AppSpacing.sm),
              width: 80,
              height: 32,
              decoration: BoxDecoration(
                color: placeholderColor,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 100,
          child: Row(
            children: List.generate(4, (index) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                      right: index == 3 ? 0 : AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: placeholderColor,
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  /// Menu section content: title + 3 pill-shaped buttons.
  /// Returns bare content — caller wraps in [wrapWithShimmer] + Padding.
  static Widget buildMenuSectionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _staticPlaceholder(width: 100, height: 20),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: List.generate(3, (index) {
            return Container(
              margin:
                  EdgeInsets.only(right: index == 2 ? 0 : AppSpacing.sm),
              width: 100,
              height: 36,
              decoration: BoxDecoration(
                color: placeholderColor,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Generic section content: title bar + content block.
  /// Used for facilities, payments, about sections.
  /// Returns bare content — caller wraps in [wrapWithShimmer] + Padding.
  static Widget buildGenericSectionContent({
    required double titleWidth,
    double titleHeight = 20.0,
    double contentHeight = 80.0,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _staticPlaceholder(width: titleWidth, height: titleHeight),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          height: contentHeight,
          decoration: BoxDecoration(
            color: placeholderColor,
            borderRadius: BorderRadius.circular(AppRadius.chip),
          ),
        ),
      ],
    );
  }

  /// Shared placeholder builder.
  static Widget _staticPlaceholder(
      {required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: placeholderColor,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
    );
  }

  // =========================================================================
  // FULL-PAGE SHIMMER BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroCard(),
              const SizedBox(height: AppSpacing.md),
              _buildQuickActionPills(),
              const SizedBox(height: AppSpacing.md),
              _buildOpeningHoursCard(),
              const SizedBox(height: AppSpacing.xxl),
              // Reuse shared gallery/menu content builders (no duplication)
              buildGallerySectionContent(),
              const SizedBox(height: AppSpacing.xxl),
              buildMenuSectionContent(),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // FULL-PAGE ONLY SECTIONS (hero, pills, hours — not needed per-section)
  // =========================================================================

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: placeholderColor,
              borderRadius: BorderRadius.circular(AppRadius.logoLarge),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _staticPlaceholder(width: 160, height: 20),
                const SizedBox(height: AppSpacing.xs),
                _staticPlaceholder(width: 120, height: 14),
                const SizedBox(height: AppSpacing.xxs),
                _staticPlaceholder(width: 180, height: 14),
                const SizedBox(height: AppSpacing.xxs),
                _staticPlaceholder(width: 140, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionPills() {
    return Row(
      children: List.generate(4, (index) {
        return Container(
          margin: EdgeInsets.only(right: index == 3 ? 0 : AppSpacing.sm),
          width: 80,
          height: 36,
          decoration: BoxDecoration(
            color: placeholderColor,
            borderRadius: BorderRadius.circular(AppRadius.filter),
          ),
        );
      }),
    );
  }

  Widget _buildOpeningHoursCard() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _staticPlaceholder(width: 100, height: 14),
          const SizedBox(height: AppSpacing.xs),
          _staticPlaceholder(width: 180, height: 12),
        ],
      ),
    );
  }
}
