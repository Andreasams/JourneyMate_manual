import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../providers/business_providers.dart';
import '../../services/api_service.dart';
import '../../services/translation_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/shared/tabbed_gallery_widget.dart';
import '../../widgets/shared/image_gallery_widget.dart';

/// Gallery Full Page - Dedicated full-screen photo gallery browsing
///
/// Provides focused photo exploration organized by four categories: Food, Menu,
/// Interior, Outdoor. Users can view all photos in a tabbed grid layout and tap
/// any image to open full-screen swipeable viewer.
///
/// Route: /business/:id/gallery
class GalleryFullPage extends ConsumerStatefulWidget {
  final String businessId;

  const GalleryFullPage({super.key, required this.businessId});

  @override
  ConsumerState<GalleryFullPage> createState() => _GalleryFullPageState();
}

class _GalleryFullPageState extends ConsumerState<GalleryFullPage> {
  // ============================================================================
  // LOCAL STATE (NOT providers)
  // ============================================================================

  /// Page start time for analytics duration tracking
  DateTime? _pageStartTime;

  // Cached for safe use in dispose() — ref is invalid after unmount
  String _cachedDeviceId = '';
  String _cachedSessionId = '';

  // ============================================================================
  // LIFECYCLE
  // ============================================================================

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();

    // Check data availability and cache analytics state after first frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Cache analytics state for safe use in dispose() (ref is invalid after unmount)
      final analyticsState = ref.read(analyticsProvider);
      _cachedDeviceId = analyticsState.deviceId;
      _cachedSessionId = analyticsState.sessionId ?? '';
    });
  }

  @override
  void dispose() {
    // Track page view with duration
    if (_pageStartTime != null) {
      final duration = DateTime.now().difference(_pageStartTime!);

      // Use cached values — ref is unsafe during dispose()
      ApiService.instance.postAnalytics(
        eventType: 'page_viewed',
        deviceId: _cachedDeviceId,
        sessionId: _cachedSessionId,
        userId: '',
        timestamp: DateTime.now().toIso8601String(),
        eventData: {
          'pageName': 'galleryFullPage',
          'durationSeconds': duration.inSeconds,
        },
      );
    }
    super.dispose();
  }

  // ============================================================================
  // BUILD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final business = ref.watch(businessProvider).currentBusiness;
    final businessName = business?['business_name'] ?? 'Gallery';

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          businessName,
          style: AppTypography.h5,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  // ============================================================================
  // BODY LAYOUT
  // ============================================================================

  /// Build body with "Gallery" label + TabbedGalleryWidget
  ///
  /// Much simpler than Menu Full Page - no filters, no categories, just the gallery widget
  Widget _buildBody() {
    final business = ref.watch(businessProvider).currentBusiness;
    final gallery = business?['gallery'];

    // Loading state
    if (gallery == null) {
      return Center(
        child: Text(
          td(ref, 'gallery_loading'),
          style: AppTypography.bodyLg.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Gallery" label
          Text(
            td(ref, 'tab_gallery'), // "Gallery"
            style: AppTypography.h4.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          // TabbedGalleryWidget takes remaining space
          Expanded(
            child: _buildGalleryTabWidget(gallery),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // GALLERY TAB WIDGET WITH CALLBACK
  // ============================================================================

  /// Build TabbedGalleryWidget with image tap callback wired
  ///
  /// Key decisions:
  /// - limitToEightImages = false (show all images in full page view)
  /// - onImageTap callback opens full-screen gallery via ImageGalleryWidget.show()
  Widget _buildGalleryTabWidget(dynamic gallery) {
    return TabbedGalleryWidget(
      galleryData: gallery as Map<String, dynamic>,
      limitToEightImages: false,
      pageName: 'galleryFullPage',
      onImageTap: (imageUrls, index, categoryKey) {
        _showImageGalleryOverlay(imageUrls, index, categoryKey);
      },
    );
  }

  /// Show full-screen image gallery via canonical bottom sheet presentation.
  Future<void> _showImageGalleryOverlay(
    List<String> imageUrls,
    int index,
    String categoryKey,
  ) async {
    if (!mounted) return;

    await ImageGalleryWidget.show(
      context,
      imageUrls: imageUrls,
      currentIndex: index,
      categoryName: _getCategoryDisplayName(categoryKey),
    );
  }

  /// Get localized category name for display
  ///
  /// Maps category keys (food/menu/interior/outdoor) to translated names
  /// using translation service.
  String _getCategoryDisplayName(String categoryKey) {
    switch (categoryKey) {
      case 'food':
        return td(ref, 'gallery_food');
      case 'menu':
        return td(ref, 'tab_menu');
      case 'interior':
        return td(ref, 'gallery_interior');
      case 'outdoor':
        return td(ref, 'gallery_outdoor');
      default:
        return categoryKey;
    }
  }
}
