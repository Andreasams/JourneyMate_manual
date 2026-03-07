import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

import '../../providers/business_providers.dart';
import '../../services/translation_service.dart';
import '../../services/analytics_service.dart';
import '../../services/api_service.dart';
import '../shared/image_gallery_widget.dart';

/// Inline Gallery Widget - Tabbed gallery with swipeable content
///
/// Features:
/// - 4 tabs: "Mad" (food), "Inde" (interior), "Ude" (outdoor), "Menu" (menu PDFs)
/// - Underline-style tab bar (text + 2px orange indicator, matching GalleryTabWidget)
/// - Swipeable PageView content area
/// - Tab selection syncs with swipe gestures
/// - 4-column × 2-row grid (8 images) with 4px gap within each tab
/// - Uniform 4px border radius on images
/// - Taps open ImageGalleryWidget modal (full-screen gallery)
/// - Self-contained (reads from businessProvider internally)
///
/// Design:
/// - Tab bar: underline style with 2px orange indicator for selected tab
/// - Tab font: 18px, w400 selected / w300 unselected
/// - Tab colors: accent for selected, textPrimary for unselected
/// - Grid spacing: 4px (AppSpacing.xs)
/// - Border radii: uniform 4px
/// - Section heading: AppTypography.sectionHeading
/// - 24px horizontal padding (AppSpacing.xxl)
class InlineGalleryWidget extends ConsumerStatefulWidget {
  const InlineGalleryWidget({super.key});

  @override
  ConsumerState<InlineGalleryWidget> createState() =>
      _InlineGalleryWidgetState();
}

class _InlineGalleryWidgetState extends ConsumerState<InlineGalleryWidget> {
  late PageController _pageController;
  int _currentTabIndex = 0;
  List<Map<String, dynamic>> _activeCategories = [];

  // Tab bar styling constants (matching GalleryTabWidget)
  static const double _tabBarBottomMargin = AppSpacing.md;
  static const double _tabBarBorderWidth = 2.0;
  static const double _tabPaddingTop = AppSpacing.md;
  static const double _tabIndicatorHeight = 2.0;
  static const double _tabIndicatorSpacing = 6.0;
  static const double _tabIndicatorWidthPerChar = 10.0;
  static const double _tabWidth = 0.25; // 25% of parent width
  static const double _selectedTabFontSize = 18.0;
  static const FontWeight _selectedTabFontWeight = FontWeight.w400;
  static const FontWeight _unselectedTabFontWeight = FontWeight.w300;
  static const double _gridSpacing = AppSpacing.xs; // 4px
  static const double _imageBorderRadius = 4.0;

  // Tab configuration: matches JSX tab order and API keys
  static const _tabs = [
    {'key': 'food', 'labelKey': 'gallery_food'}, // "Mad"
    {'key': 'menu', 'labelKey': 'gallery_menu'}, // "Menu"
    {'key': 'interior', 'labelKey': 'gallery_interior'}, // "Inde"
    {'key': 'outdoor', 'labelKey': 'gallery_outdoor'}, // "Ude"
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
    // Only include categories that have images
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

      // Only add category if it has images (hide empty categories)
      if (imageUrls.isNotEmpty) {
        galleryCategories.add({
          'key': key,
          'labelKey': tab['labelKey'],
          'images': imageUrls,
        });
      }
    }

    // If no categories have images, hide the entire gallery section
    if (galleryCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    // Store for analytics (so _trackTabChange uses correct keys)
    _activeCategories = galleryCategories;

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

          // Underline tab bar (matching GalleryTabWidget style)
          _buildFixedTabBar(galleryCategories),

          // Swipeable content area with calculated height for 4x2 grid
          _buildGalleryPageView(galleryCategories),
          SizedBox(height: AppSpacing.md),

          // "Se alle billeder →" link to full gallery page
          _buildViewAllButton(business?['business_id'] as int?),
        ],
      ),
    );
  }

  /// Build gallery page view with calculated height for 4x2 grid
  Widget _buildGalleryPageView(List<Map<String, dynamic>> categories) {
    // Calculate height: 2 rows + spacing
    // Container width minus horizontal padding (24px on each side)
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth - (AppSpacing.xxl * 2);
    const columns = 4;
    const rows = 2;

    // Calculate image width: (container width - spacing between columns) / number of columns
    final imageWidth = (containerWidth - (_gridSpacing * (columns - 1))) / columns;

    // Calculate total height: (image height × rows) + spacing between rows
    final totalHeight = (imageWidth * rows) + (_gridSpacing * (rows - 1));

    return SizedBox(
      height: totalHeight,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final images = category['images'] as List<String>;
          return _buildGalleryGrid(images, category['key'] as String);
        },
      ),
    );
  }

  /// Build underline-style tab bar (matching GalleryTabWidget)
  Widget _buildFixedTabBar(List<Map<String, dynamic>> categories) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          margin: const EdgeInsets.only(bottom: _tabBarBottomMargin),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.border,
                width: _tabBarBorderWidth,
              ),
            ),
          ),
          child: Row(
            children: categories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              final label = td(ref, category['labelKey'] as String);
              return SizedBox(
                width: constraints.maxWidth * _tabWidth,
                child: _buildTabItem(label, index),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// Build a single tab item with label and underline indicator
  Widget _buildTabItem(String label, int index) {
    final isSelected = _currentTabIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.only(top: _tabPaddingTop),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: _selectedTabFontSize,
                fontWeight: isSelected
                    ? _selectedTabFontWeight
                    : _unselectedTabFontWeight,
                color: isSelected ? AppColors.accent : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: _tabIndicatorSpacing),
            if (isSelected)
              Container(
                height: _tabIndicatorHeight,
                width: label.length * _tabIndicatorWidthPerChar,
                color: AppColors.accent,
              ),
          ],
        ),
      ),
    );
  }

  /// Build 4-column × 2-row grid for a category (8 images)
  Widget _buildGalleryGrid(List<String> images, String categoryKey) {
    // Show first 8 images in 4×2 grid
    final displayedImages = images.take(8).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: _gridSpacing,
        mainAxisSpacing: _gridSpacing,
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

  /// Build individual gallery image with uniform border radius
  Widget _buildGalleryImage(
    String imageUrl,
    int index,
    List<String> allImages,
    String categoryKey,
  ) {
    return GestureDetector(
      onTap: () => _handleImageTap(index, allImages, categoryKey),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_imageBorderRadius),
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

  /// Handle tab tap - jump to page
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

  /// Build "Se alle billeder →" text link to full gallery page
  /// JSX reference: business_profile.jsx line 291
  Widget _buildViewAllButton(int? businessId) {
    if (businessId == null) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => _handleViewAllTap(businessId),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              td(ref, 'gallery_view_all'),
              style: AppTypography.viewToggle.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: AppSpacing.xs),
            const Icon(
              Icons.arrow_forward,
              color: AppColors.textSecondary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate to full gallery page and track analytics
  void _handleViewAllTap(int businessId) {
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
        'businessId': businessId,
      },
    )
        .catchError((e) {
      debugPrint('Analytics error: $e');
      return ApiCallResponse.failure('Analytics failed');
    });

    context.push('/business/$businessId/gallery');
  }

  /// Track analytics for tab change
  void _trackTabChange(int tabIndex) {
    if (tabIndex >= _activeCategories.length) return;
    final tabKey = _activeCategories[tabIndex]['key'] as String;

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
