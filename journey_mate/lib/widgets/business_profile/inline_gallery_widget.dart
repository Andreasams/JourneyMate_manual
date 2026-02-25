import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import '../../providers/business_providers.dart';
import '../../services/translation_service.dart';
import '../../services/analytics_service.dart';
import '../../services/api_service.dart';
import '../shared/image_gallery_widget.dart';

/// Inline Gallery Widget - 3-column grid showing business photos
///
/// Features:
/// - 3-column grid with 3px gap between images
/// - Variable border radii (10/12/14px alternating) for visual interest
/// - Shows first 9 images by default
/// - "View all N photos" button if more than 9 images exist
/// - Tap opens ImageGalleryWidget modal (full-screen gallery)
/// - Self-contained (reads from businessProvider internally)
/// - Shrink-wrapped and non-scrollable (part of main CustomScrollView)
///
/// Design:
/// - Grid spacing: 3px (custom, not from AppSpacing)
/// - Border radii: 10px, 12px, 14px alternating pattern
/// - Section heading: AppTypography.sectionHeading
/// - 24px horizontal padding (AppSpacing.xxl)
/// - 16px vertical spacing (AppSpacing.lg)
class InlineGalleryWidget extends ConsumerWidget {
  const InlineGalleryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(businessProvider).currentBusiness;
    final gallery = business?['gallery'] as List?;

    // Hide if no gallery images
    if (gallery == null || gallery.isEmpty) {
      return const SizedBox.shrink();
    }

    // Build flat list of all image URLs
    final allImageUrls = <String>[];
    for (final image in gallery) {
      final imageUrl = image['image_url'] as String?;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        allImageUrls.add(imageUrl);
      }
    }

    if (allImageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show first 9 images
    final displayedImages = allImageUrls.take(9).toList();
    final hasMore = allImageUrls.length > 9;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section heading
          Text(
            td(ref, 'gallery_heading'),
            style: AppTypography.sectionHeading,
          ),
          SizedBox(height: AppSpacing.sm),

          // 3-column grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 3.0,
              mainAxisSpacing: 3.0,
              childAspectRatio: 1.0, // Square images
            ),
            itemCount: displayedImages.length,
            itemBuilder: (context, index) {
              return _buildGalleryImage(
                context,
                ref,
                displayedImages[index],
                index,
                allImageUrls,
              );
            },
          ),

          // "View all N photos" button (if more than 9)
          if (hasMore) ...[
            SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _handleViewAllTap(context, ref, allImageUrls),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.bgSurface,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                ),
                child: Text(
                  td(ref, 'gallery_view_all')
                      .replaceAll('{count}', allImageUrls.length.toString()),
                  style: AppTypography.bodyRegular.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build individual gallery image with variable border radius
  Widget _buildGalleryImage(
    BuildContext context,
    WidgetRef ref,
    String imageUrl,
    int index,
    List<String> allImageUrls,
  ) {
    // Variable border radii pattern: 10, 12, 14, 10, 12, 14, ...
    final radii = [10.0, 12.0, 14.0];
    final borderRadius = radii[index % 3];

    return GestureDetector(
      onTap: () => _handleImageTap(context, ref, index, allImageUrls),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          memCacheWidth: 400, // Limit decoded size for performance
          placeholder: (context, url) => Container(
            color: AppColors.bgSurface,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: AppColors.bgSurface,
            child: Icon(
              Icons.broken_image,
              color: AppColors.textTertiary,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }

  /// Handle image tap - open ImageGalleryWidget modal
  Future<void> _handleImageTap(
    BuildContext context,
    WidgetRef ref,
    int index,
    List<String> imageUrls,
  ) async {
    // Track analytics
    final analytics = AnalyticsService.instance;
    ApiService.instance
        .postAnalytics(
      eventType: 'gallery_image_tapped',
      deviceId: analytics.deviceId ?? '',
      sessionId: analytics.currentSessionId ?? '',
      userId: analytics.userId ?? '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'pageName': 'businessProfile',
        'imageIndex': index,
      },
    )
        .catchError((e) {
      debugPrint('Analytics error: $e');
      return ApiCallResponse.failure('Analytics failed');
    });

    // Open full-screen gallery modal
    if (context.mounted) {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ImageGalleryWidget(
          currentIndex: index,
          imageUrls: imageUrls,
          categoryName: td(ref, 'gallery_heading'), // "Gallery"
        ),
      );
    }
  }

  /// Handle "View all" button tap - open gallery at first image
  Future<void> _handleViewAllTap(
    BuildContext context,
    WidgetRef ref,
    List<String> imageUrls,
  ) async {
    // Track analytics
    final analytics = AnalyticsService.instance;
    ApiService.instance
        .postAnalytics(
      eventType: 'gallery_view_all_tapped',
      deviceId: analytics.deviceId ?? '',
      sessionId: analytics.currentSessionId ?? '',
      userId: analytics.userId ?? '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'pageName': 'businessProfile',
        'totalImages': imageUrls.length,
      },
    )
        .catchError((e) {
      debugPrint('Analytics error: $e');
      return ApiCallResponse.failure('Analytics failed');
    });

    // Open full-screen gallery modal at first image
    if (context.mounted) {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ImageGalleryWidget(
          currentIndex: 0,
          imageUrls: imageUrls,
          categoryName: td(ref, 'gallery_heading'),
        ),
      );
    }
  }
}
