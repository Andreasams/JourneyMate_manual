import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../services/translation_service.dart';
import '../../services/api_service.dart';
import '../../providers/app_providers.dart';

/// Unified tabbed gallery widget for displaying categorized restaurant images.
///
/// Used in two contexts:
/// - **Full-page gallery** (`limitToEightImages: false`, no `onViewAllTap`)
/// - **Inline business profile** (`limitToEightImages: true`, with `onViewAllTap`)
///
/// Features:
/// - Four image categories: Food, Menu, Interior, Outdoor
/// - PageView navigation with smooth sliding indicator (no TabController)
/// - Grid layout: 4 columns, 2 rows (inline) or scrollable (full-page)
/// - Image precaching for smooth loading
/// - Localized category names via translation system
/// - Analytics tracking for opens, tab changes, image taps, view-all taps
///
/// The tab-jumping bug (tapping tab 3 from tab 1 only reaching tab 2) is fixed
/// by using a `_targetPage` guard that ignores intermediate `onPageChanged`
/// events during programmatic `animateToPage` calls.
class TabbedGalleryWidget extends ConsumerStatefulWidget {
  const TabbedGalleryWidget({
    super.key,
    required this.galleryData,
    required this.onImageTap,
    this.limitToEightImages = false,
    this.onViewAllTap,
    this.pageName = 'galleryFullPage',
  });

  /// Gallery data map with category keys ('food', 'menu', 'interior', 'outdoor')
  /// each containing a list of image URL strings.
  final Map<String, dynamic> galleryData;

  /// Called when user taps an image. Receives the full image list for that
  /// category, the tapped index, and the category key. Sync void — caller
  /// can launch async dialogs/sheets inside the callback.
  final void Function(List<String> imageUrls, int index, String categoryKey)
      onImageTap;

  /// When true, limits each category to 8 images and uses a fixed-height
  /// non-scrollable grid. When false, shows all images in a scrollable grid.
  final bool limitToEightImages;

  /// Called when user taps "View All" link (inline mode only). Caller closes
  /// over businessId so this widget stays routing-free.
  final VoidCallback? onViewAllTap;

  /// Analytics context: 'businessProfile' or 'galleryFullPage'.
  final String pageName;

  @override
  ConsumerState<TabbedGalleryWidget> createState() =>
      _TabbedGalleryWidgetState();
}

class _TabbedGalleryWidgetState extends ConsumerState<TabbedGalleryWidget> {
  // ===========================================================================
  // STATE
  // ===========================================================================

  late PageController _pageController;
  late List<_GalleryCategory> _categories;
  int _currentTabIndex = 0;

  /// Guard against intermediate onPageChanged events during animateToPage.
  /// Set on tab tap, cleared when destination page is reached.
  int? _targetPage;

  /// One-shot flag: gallery_opened fires on first user interaction only.
  bool _hasTrackedOpened = false;

  // ===========================================================================
  // CONSTANTS
  // ===========================================================================

  // Tab bar layout
  static const double _tabBarBottomMargin = AppSpacing.md;
  static const double _tabBarBorderWidth = 2.0;
  static const double _tabPaddingTop = AppSpacing.md;
  static const double _tabIndicatorHeight = 2.0;
  static const double _tabIndicatorSpacing = 6.0;
  static const double _tabIndicatorWidthPerChar = 10.0;
  static const double _tabWidth = 0.25; // 25% of parent width

  // Grid layout
  static const int _gridColumnCount = 4;
  static const int _gridRowCount = 2;
  static const double _gridSpacing = AppSpacing.xs;
  static const double _gridHorizontalPadding = 2.0;
  static const double _imageBorderRadius = 4.0;
  static const int _maxImagesToPreload = 8;

  // Animation
  static const Duration _pageTransitionDuration = Duration(milliseconds: 450);
  static const Curve _pageTransitionCurve = Curves.easeInOut;

  // Category keys
  static const String _foodKey = 'food';
  static const String _menuKey = 'menu';
  static const String _interiorKey = 'interior';
  static const String _outdoorKey = 'outdoor';
  static const String _emptyKey = 'empty';

  // Translation keys
  static const String _noImagesTranslationKey = 'gallery_no_images';

  // Category config — labels re-resolved in build() so language switches propagate
  static const _categoryConfig = [
    {'key': _foodKey, 'labelKey': 'gallery_food'},
    {'key': _menuKey, 'labelKey': 'tab_menu'},
    {'key': _interiorKey, 'labelKey': 'gallery_interior'},
    {'key': _outdoorKey, 'labelKey': 'gallery_outdoor'},
  ];

  // ===========================================================================
  // LIFECYCLE
  // ===========================================================================

  @override
  void initState() {
    super.initState();
    _parseGalleryData();
    _pageController = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleImagePreloading();
  }

  @override
  void didUpdateWidget(covariant TabbedGalleryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.galleryData != oldWidget.galleryData) {
      _parseGalleryData();
      if (_currentTabIndex >= _categories.length) {
        _currentTabIndex = 0;
        _pageController.jumpToPage(0);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // IMAGE PRELOADING
  // ===========================================================================

  void _scheduleImagePreloading() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _categories.isNotEmpty) {
        _preloadCategoryImages(_categories[0]);
      }
    });
  }

  void _preloadCategoryImages(_GalleryCategory category) {
    if (!mounted || category.images.isEmpty) return;
    for (final imageUrl in category.images.take(_maxImagesToPreload)) {
      precacheImage(CachedNetworkImageProvider(imageUrl), context);
    }
  }

  // ===========================================================================
  // GALLERY DATA PARSING
  // ===========================================================================

  void _parseGalleryData() {
    _categories = [];

    for (final config in _categoryConfig) {
      final key = config['key']!;
      final labelKey = config['labelKey']!;
      final rawImages = widget.galleryData[key] as List<dynamic>?;
      if (rawImages == null || rawImages.isEmpty) continue;

      final images = rawImages.map((e) => e.toString()).toList();
      final limited = widget.limitToEightImages && images.length > _maxImagesToPreload
          ? images.take(_maxImagesToPreload).toList()
          : images;

      _categories.add(_GalleryCategory(
        key: key,
        labelKey: labelKey,
        images: limited,
      ));
    }

    if (_categories.isEmpty) {
      _categories.add(const _GalleryCategory(
        key: _emptyKey,
        labelKey: 'tab_gallery',
        images: [],
      ));
    }
  }

  // ===========================================================================
  // USER INTERACTION HANDLERS
  // ===========================================================================

  void _ensureOpenedTracking() {
    if (!_hasTrackedOpened) {
      _hasTrackedOpened = true;
      _trackGalleryOpened();
    }
  }

  void _onTabTapped(int index) {
    if (index == _currentTabIndex) return;

    _ensureOpenedTracking();

    final previousIndex = _currentTabIndex;
    _targetPage = index;
    _pageController.animateToPage(
      index,
      duration: _pageTransitionDuration,
      curve: _pageTransitionCurve,
    );

    _preloadCategoryImages(_categories[index]);
    _trackTabChange(previousIndex, index, 'tap');
  }

  void _onPageChanged(int index) {
    // Skip intermediate pages during programmatic animateToPage
    if (_targetPage != null && index != _targetPage) return;
    _targetPage = null;

    _ensureOpenedTracking();

    final previousIndex = _currentTabIndex;
    setState(() {
      _currentTabIndex = index;
    });

    _preloadCategoryImages(_categories[index]);

    // Only track swipe-initiated changes (tap changes tracked in _onTabTapped)
    if (previousIndex != index) {
      _trackTabChange(previousIndex, index, 'swipe');
    }
  }

  void _handleImageTap(List<String> images, int index) {
    _ensureOpenedTracking();

    final currentCategory = _categories[_currentTabIndex];
    _trackGalleryImageTapped(currentCategory.key, index);
    widget.onImageTap(images, index, currentCategory.key);
  }

  void _handleViewAllTap() {
    if (widget.onViewAllTap == null) return;
    _trackGalleryViewAllTapped();
    widget.onViewAllTap!();
  }

  // ===========================================================================
  // ANALYTICS
  // ===========================================================================

  void _trackGalleryOpened() {
    final availableTabs = _categories.map((c) => c.key).toList();
    final analyticsState = ref.read(analyticsProvider);

    ApiService.instance.postAnalytics(
      eventType: 'gallery_opened',
      deviceId: analyticsState.deviceId,
      sessionId: analyticsState.sessionId ?? '',
      userId: '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'pageName': widget.pageName,
        'available_tabs': availableTabs,
        'total_tabs': availableTabs.length,
        'initial_tab': availableTabs.isNotEmpty ? availableTabs[0] : 'empty',
      },
    );
  }

  void _trackTabChange(int fromIndex, int toIndex, String method) {
    if (fromIndex == toIndex) return;

    final fromTab = _categories[fromIndex].key;
    final toTab = _categories[toIndex].key;
    final availableTabs = _categories.map((c) => c.key).toList();
    final analyticsState = ref.read(analyticsProvider);

    ApiService.instance.postAnalytics(
      eventType: 'gallery_tab_changed',
      deviceId: analyticsState.deviceId,
      sessionId: analyticsState.sessionId ?? '',
      userId: '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'pageName': widget.pageName,
        'from_tab': fromTab,
        'to_tab': toTab,
        'from_index': fromIndex,
        'to_index': toIndex,
        'method': method,
        'available_tabs': availableTabs,
      },
    );
  }

  void _trackGalleryImageTapped(String categoryKey, int imageIndex) {
    final analyticsState = ref.read(analyticsProvider);

    ApiService.instance.postAnalytics(
      eventType: 'gallery_image_tapped',
      deviceId: analyticsState.deviceId,
      sessionId: analyticsState.sessionId ?? '',
      userId: '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'pageName': widget.pageName,
        'category': categoryKey,
        'imageIndex': imageIndex,
      },
    );
  }

  void _trackGalleryViewAllTapped() {
    final analyticsState = ref.read(analyticsProvider);

    ApiService.instance.postAnalytics(
      eventType: 'gallery_view_all_tapped',
      deviceId: analyticsState.deviceId,
      sessionId: analyticsState.sessionId ?? '',
      userId: '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'pageName': widget.pageName,
      },
    );
  }

  // ===========================================================================
  // UI — MAIN LAYOUT
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    if (widget.limitToEightImages) {
      // Inline mode: fixed-height column (no Expanded)
      return Column(
        children: [
          _buildTabBarContainer(),
          _buildInlineGalleryPageView(),
          if (widget.onViewAllTap != null) _buildViewAllLink(),
        ],
      );
    }

    // Full-page mode: tab bar + expanded PageView
    return Container(
      color: AppColors.bgPage,
      child: Column(
        children: [
          _buildTabBarContainer(),
          _buildExpandedGalleryPageView(),
        ],
      ),
    );
  }

  // ===========================================================================
  // UI — TAB BAR
  // ===========================================================================

  Widget _buildTabBarContainer() {
    return Container(
      margin: const EdgeInsets.only(bottom: _tabBarBottomMargin),
      color: AppColors.bgPage,
      child: _buildFixedTabBar(),
    );
  }

  Widget _buildFixedTabBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border,
                    width: _tabBarBorderWidth,
                  ),
                ),
              ),
              child: Row(
                children: _categories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  final label = td(ref, category.labelKey);
                  return SizedBox(
                    width: maxWidth * _tabWidth,
                    child: _buildTabItem(label, index),
                  );
                }).toList(),
              ),
            ),
            // Orange indicator overlaps the grey border and slides with page
            Positioned(
              bottom: 0,
              left: 0,
              child: _buildSlidingIndicator(maxWidth),
            ),
          ],
        );
      },
    );
  }

  double _getCurrentPage() {
    if (!_pageController.hasClients) {
      return _currentTabIndex.toDouble();
    }
    return _pageController.page ?? _currentTabIndex.toDouble();
  }

  /// Sliding orange indicator that tracks page position smoothly.
  /// Listens to [_pageController] for real-time interpolation during
  /// both swipe gestures and programmatic animateToPage calls.
  Widget _buildSlidingIndicator(double maxWidth) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, _) {
        final page = _getCurrentPage();
        final tabWidth = maxWidth * _tabWidth;

        final fromIdx = page.floor().clamp(0, _categories.length - 1);
        final toIdx = page.ceil().clamp(0, _categories.length - 1);
        final t = fromIdx == toIdx ? 0.0 : page - fromIdx;

        // Resolve labels for width calculation
        final fromLabel = td(ref, _categories[fromIdx].labelKey);
        final toLabel = td(ref, _categories[toIdx].labelKey);

        // Interpolate indicator width between the two tab labels
        final fromW = fromLabel.length * _tabIndicatorWidthPerChar;
        final toW = toLabel.length * _tabIndicatorWidthPerChar;
        final width = fromW + (toW - fromW) * t;

        // Interpolate center position across tab slots
        final fromCenter = (fromIdx + 0.5) * tabWidth;
        final toCenter = (toIdx + 0.5) * tabWidth;
        final left = (fromCenter + (toCenter - fromCenter) * t) - width / 2;

        return Padding(
          padding: EdgeInsets.only(left: left.clamp(0.0, maxWidth - width)),
          child: Container(
            height: _tabIndicatorHeight,
            width: width,
            color: AppColors.accent,
          ),
        );
      },
    );
  }

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
              style: AppTypography.h3.copyWith(
                fontWeight: isSelected
                    ? FontWeight.w400
                    : FontWeight.w300,
                color: isSelected ? AppColors.accent : AppColors.textPrimary,
              ),
            ),
            // Spacer matches layout: gap + indicator height
            const SizedBox(height: _tabIndicatorSpacing + _tabIndicatorHeight),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // UI — GALLERY PAGE VIEW
  // ===========================================================================

  /// Full-page mode: PageView fills remaining space via Expanded
  Widget _buildExpandedGalleryPageView() {
    return Expanded(
      child: PageView.builder(
        controller: _pageController,
        itemCount: _categories.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) =>
            _buildGalleryGrid(_categories[index], scrollable: true),
      ),
    );
  }

  /// Inline mode: fixed-height PageView using LayoutBuilder for width
  Widget _buildInlineGalleryPageView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth;
        final imageWidth =
            (containerWidth - (_gridColumnCount - 1) * _gridSpacing) /
                _gridColumnCount;
        final totalHeight =
            (imageWidth * _gridRowCount) + (_gridSpacing * (_gridRowCount - 1));

        return SizedBox(
          height: totalHeight,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _categories.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) =>
                _buildGalleryGrid(_categories[index], scrollable: false),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // UI — GALLERY GRID
  // ===========================================================================

  Widget _buildGalleryGrid(_GalleryCategory category,
      {required bool scrollable}) {
    if (category.images.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _gridHorizontalPadding),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: scrollable
            ? const ClampingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _gridColumnCount,
          crossAxisSpacing: _gridSpacing,
          mainAxisSpacing: _gridSpacing,
          childAspectRatio: 1,
        ),
        itemCount: category.images.length,
        itemBuilder: (context, index) =>
            _buildImageTile(category.images, index),
      ),
    );
  }

  Widget _buildImageTile(List<String> images, int index) {
    return GestureDetector(
      onTap: () => _handleImageTap(images, index),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_imageBorderRadius),
        child: CachedNetworkImage(
          imageUrl: images[index],
          fit: BoxFit.cover,
          memCacheWidth: 400,
          placeholder: (context, url) => Container(
            color: AppColors.bgSurface,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: AppColors.accent,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: AppColors.bgSurface,
            child: const Icon(
              Icons.broken_image,
              color: AppColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        td(ref, _noImagesTranslationKey),
        style: AppTypography.bodyLg.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // ===========================================================================
  // UI — VIEW ALL LINK (inline mode only)
  // ===========================================================================

  Widget _buildViewAllLink() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: GestureDetector(
        onTap: _handleViewAllTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                td(ref, 'gallery_view_all'),
                style: AppTypography.bodyLgMedium,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.xs),
              child: Icon(
                Icons.keyboard_arrow_right_sharp,
                color: AppColors.textPrimary,
                size: AppSpacing.xl,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// GALLERY CATEGORY MODEL
// =============================================================================

class _GalleryCategory {
  const _GalleryCategory({
    required this.key,
    required this.labelKey,
    required this.images,
  });

  final String key;
  final String labelKey;
  final List<String> images;
}
