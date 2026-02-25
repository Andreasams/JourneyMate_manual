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

/// Inline Gallery Widget - Tabbed gallery with swipeable content
///
/// Features:
/// - 4 tabs: "Mad" (food), "Inde" (interior), "Ude" (outdoor), "Menu" (menu PDFs)
/// - Horizontal tab chips (selected = orange bg, unselected = white)
/// - Swipeable PageView content area
/// - Visual indicator dots below content (current tab highlighted)
/// - Tab selection syncs with swipe gestures
/// - 3-column grid with 3px gap within each tab
/// - Variable border radii (10/12/14px alternating) for visual interest
/// - Taps open ImageGalleryWidget modal (full-screen gallery)
/// - Self-contained (reads from businessProvider internally)
///
/// Design:
/// - Tab chips: 8px gap, selected = orange bg + white text
/// - Grid spacing: 3px (custom, not from AppSpacing)
/// - Border radii: 10px, 12px, 14px alternating pattern
/// - Indicator dots: 6px diameter, 4px gap, orange = active
/// - Section heading: AppTypography.sectionHeading
/// - 24px horizontal padding (AppSpacing.xxl)
/// - Matches JSX lines 318-377 in business_profile.jsx
class InlineGalleryWidget extends ConsumerStatefulWidget {
  const InlineGalleryWidget({super.key});

  @override
  ConsumerState<InlineGalleryWidget> createState() =>
      _InlineGalleryWidgetState();
}

class _InlineGalleryWidgetState extends ConsumerState<InlineGalleryWidget> {
  late PageController _pageController;
  int _currentTabIndex = 0;

  // Tab configuration: matches JSX tab order and API keys
  static const _tabs = [
    {'key': 'food', 'labelKey': 'gallery_tab_food'}, // "Mad"
    {'key': 'menu', 'labelKey': 'gallery_tab_menu'}, // "Menu"
    {'key': 'interior', 'labelKey': 'gallery_tab_interior'}, // "Inde"
    {'key': 'outdoor', 'labelKey': 'gallery_tab_exterior'}, // "Ude"
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final business = ref.watch(businessProvider).currentBusiness;
    final galleryData = business?['gallery'] as Map<String, dynamic>?;

    // Hide if no gallery data
    if (galleryData == null || galleryData.isEmpty) {
      return const SizedBox.shrink();
    }

    // Parse gallery categories from API response
    final galleryCategories = <Map<String, dynamic>>[];
    for (final tab in _tabs) {
      final key = tab['key'] as String;
      final images = galleryData[key] as List?;
      final imageUrls = <String>[];

      if (images != null) {
        for (final image in images) {
          if (image is String && image.isNotEmpty) {
            imageUrls.add(image);
          }
        }
      }

      galleryCategories.add({
        'key': key,
        'labelKey': tab['labelKey'],
        'images': imageUrls,
      });
    }

    // Check if any category has images
    final hasAnyImages =
        galleryCategories.any((cat) => (cat['images'] as List).isNotEmpty);

    if (!hasAnyImages) {
      return const SizedBox.shrink();
    }

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

          // Tab chips
          _buildTabChips(galleryCategories),
          SizedBox(height: AppSpacing.md),

          // Swipeable content area
          SizedBox(
            height: 300, // Fixed height for PageView
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: galleryCategories.length,
              itemBuilder: (context, index) {
                final category = galleryCategories[index];
                final images = category['images'] as List<String>;
                return _buildGalleryGrid(images, category['key'] as String);
              },
            ),
          ),
          SizedBox(height: AppSpacing.sm),

          // Visual indicator dots
          _buildIndicatorDots(galleryCategories.length),
        ],
      ),
    );
  }

  /// Build horizontal tab chips
  Widget _buildTabChips(List<Map<String, dynamic>> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(categories.length, (index) {
          final category = categories[index];
          final labelKey = category['labelKey'] as String;
          final images = category['images'] as List<String>;
          final isSelected = _currentTabIndex == index;
          final hasImages = images.isNotEmpty;

          // Don't show tab if no images (graceful degradation)
          if (!hasImages) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => _onTabTapped(index),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : Colors.white,
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.border,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                child: Text(
                  td(ref, labelKey),
                  style: AppTypography.bodySmall.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Build 3-column grid for a category
  Widget _buildGalleryGrid(List<String> images, String categoryKey) {
    if (images.isEmpty) {
      return Center(
        child: Text(
          td(ref, 'gallery_no_images'),
          style: AppTypography.bodyRegular.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    // Show first 9 images in grid
    final displayedImages = images.take(9).toList();

    return GridView.builder(
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
          displayedImages[index],
          index,
          images, // All images for modal
          categoryKey,
        );
      },
    );
  }

  /// Build individual gallery image with variable border radius
  Widget _buildGalleryImage(
    String imageUrl,
    int index,
    List<String> allImages,
    String categoryKey,
  ) {
    // Variable border radii pattern: 10, 12, 14, 10, 12, 14, ...
    final radii = [10.0, 12.0, 14.0];
    final borderRadius = radii[index % 3];

    return GestureDetector(
      onTap: () => _handleImageTap(index, allImages, categoryKey),
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

  /// Build visual indicator dots
  Widget _buildIndicatorDots(int totalTabs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalTabs, (index) {
        final isActive = _currentTabIndex == index;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 2.0),
          width: 6.0,
          height: 6.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.accent : AppColors.border,
          ),
        );
      }),
    );
  }

  /// Handle tab chip tap - jump to page
  void _onTabTapped(int index) {
    setState(() {
      _currentTabIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // Track analytics
    _trackTabChange(index);
  }

  /// Handle page swipe - update selected tab
  void _onPageChanged(int index) {
    setState(() {
      _currentTabIndex = index;
    });

    // Track analytics
    _trackTabChange(index);
  }

  /// Handle image tap - open ImageGalleryWidget modal
  Future<void> _handleImageTap(
    int index,
    List<String> imageUrls,
    String categoryKey,
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
        'category': categoryKey,
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
          categoryName: td(ref, 'gallery_heading'),
        ),
      );
    }
  }

  /// Track analytics for tab change
  void _trackTabChange(int tabIndex) {
    final tabKey = _tabs[tabIndex]['key'] as String;

    final analytics = AnalyticsService.instance;
    ApiService.instance
        .postAnalytics(
      eventType: 'gallery_tab_changed',
      deviceId: analytics.deviceId ?? '',
      sessionId: analytics.currentSessionId ?? '',
      userId: analytics.userId ?? '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'pageName': 'businessProfile',
        'tabIndex': tabIndex,
        'tabKey': tabKey,
      },
    )
        .catchError((e) {
      debugPrint('Analytics error: $e');
      return ApiCallResponse.failure('Analytics failed');
    });
  }
}
