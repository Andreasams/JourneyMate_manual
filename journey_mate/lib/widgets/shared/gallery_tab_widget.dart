import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../services/translation_service.dart';
import '../../services/analytics_service.dart';
import '../../services/api_service.dart';
import '../../providers/app_providers.dart';

/// A tabbed gallery widget for displaying categorized restaurant images.
///
/// Features:
/// - Four image categories: Food, Menu, Interior, Outdoor
/// - Tab-based navigation with PageView
/// - Grid layout with 4 columns and 2 rows
/// - Image precaching for smooth loading
/// - Localized category names via translation system (15 languages)
/// - Optional limit to first 8 images per category
/// - Tap handler for full-screen image viewing
/// - Automatic rebuild when translations change
class GalleryTabWidget extends ConsumerStatefulWidget {
  const GalleryTabWidget({
    super.key,
    this.width,
    this.height,
    required this.galleryData,
    this.onImageTap,
    this.limitToEightImages = false,
  });

  final double? width;
  final double? height;
  final dynamic galleryData;
  final Future<void> Function(List<String> imageUrls, int index, String categoryKey)?
      onImageTap;
  final bool limitToEightImages;

  @override
  ConsumerState<GalleryTabWidget> createState() => _GalleryTabWidgetState();
}

class _GalleryTabWidgetState extends ConsumerState<GalleryTabWidget>
    with SingleTickerProviderStateMixin {
  /// =========================================================================
  /// STATE & CONSTANTS
  /// =========================================================================

  late TabController _tabController;
  late PageController _pageController;
  late List<_GalleryCategory> _categories;

  /// Flag to track if gallery opened event has been fired
  bool _hasTrackedOpened = false;

  /// Layout constants
  static const double _tabBarBottomMargin = AppSpacing.md;
  static const double _tabBarBorderWidth = 2.0;
  static const double _tabPaddingTop = AppSpacing.md;
  static const double _tabIndicatorHeight = 2.0;
  static const double _tabIndicatorSpacing = 6.0;
  static const double _tabIndicatorWidthPerChar = 10.0;
  static const double _tabWidth = 0.25; // 25% of parent width

  /// Grid layout constants
  static const int _gridColumnCount = 4;
  static const int _gridRowCount = 2;
  static const double _gridSpacing = AppSpacing.xs;
  static const double _gridHorizontalPadding = 2.0;
  static const double _imageBorderRadius = 4.0;
  static const int _maxImagesToPreload = 8;

  /// Animation constants
  static const Duration _pageTransitionDuration = Duration(milliseconds: 300);
  static const Curve _pageTransitionCurve = Curves.easeInOut;

  /// Visual styling constants
  static const double _selectedTabFontSize = 18.0;
  static const FontWeight _selectedTabFontWeight = FontWeight.w400;
  static const FontWeight _unselectedTabFontWeight = FontWeight.w300;

  /// Category keys for gallery data structure
  static const String _foodKey = 'food';
  static const String _menuKey = 'menu';
  static const String _interiorKey = 'interior';
  static const String _outdoorKey = 'outdoor';
  static const String _emptyKey = 'empty';

  /// Translation keys
  static const String _foodTranslationKey = 'gallery_food';
  static const String _menuTranslationKey = 'gallery_menu';
  static const String _interiorTranslationKey = 'gallery_interior';
  static const String _outdoorTranslationKey = 'gallery_outdoor';
  static const String _noImagesTranslationKey = 'gallery_no_images';

  /// =========================================================================
  /// LIFECYCLE METHODS
  /// =========================================================================

  @override
  void initState() {
    super.initState();
    _parseGalleryData();
    _initializeControllers();
    _setupTabListener();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleImagePreloading();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  /// =========================================================================
  /// INITIALIZATION
  /// =========================================================================

  /// Initializes tab and page controllers
  void _initializeControllers() {
    _tabController = TabController(length: _categories.length, vsync: this);
    _pageController = PageController();
  }

  /// Sets up tab controller listener for bidirectional sync
  void _setupTabListener() {
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _pageController.animateToPage(
          _tabController.index,
          duration: _pageTransitionDuration,
          curve: _pageTransitionCurve,
        );
        _onTabChanged();
      }
    });
  }

  /// Disposes controllers
  void _disposeControllers() {
    _tabController.dispose();
    _pageController.dispose();
  }

  /// Schedules image preloading after first frame
  void _scheduleImagePreloading() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _preloadImages();
      }
    });
  }

  /// =========================================================================
  /// IMAGE PRELOADING
  /// =========================================================================

  /// Preloads first 8 images of each category for smooth display
  void _preloadImages() {
    for (final category in _categories) {
      final imagesToPreload = category.images.take(_maxImagesToPreload);
      for (final imageUrl in imagesToPreload) {
        precacheImage(NetworkImage(imageUrl), context);
      }
    }
  }

  /// =========================================================================
  /// GALLERY DATA PARSING
  /// =========================================================================

  /// Parses gallery data into categorized image lists
  void _parseGalleryData() {
    _categories = [];
    final categoryOrder = [_foodKey, _menuKey, _interiorKey, _outdoorKey];

    for (final categoryKey in categoryOrder) {
      _processCategoryIfAvailable(categoryKey);
    }

    _ensureAtLeastOneCategory();
  }

  /// Processes a single category if it has images
  void _processCategoryIfAvailable(String categoryKey) {
    if (!_hasCategoryData(categoryKey)) return;

    final images = _extractImagesFromCategory(categoryKey);
    if (images.isEmpty) return;

    final limitedImages = _limitImagesIfNeeded(images);
    _addCategory(categoryKey, limitedImages);
  }

  /// Checks if category data exists
  bool _hasCategoryData(String categoryKey) {
    return widget.galleryData != null &&
        widget.galleryData[categoryKey] != null;
  }

  /// Extracts image URLs from category data
  List<String> _extractImagesFromCategory(String categoryKey) {
    final images = widget.galleryData[categoryKey] as List<dynamic>?;
    if (images == null || images.isEmpty) return [];
    return images.map((e) => e.toString()).toList();
  }

  /// Limits images to first 8 if limitToEightImages is enabled
  List<String> _limitImagesIfNeeded(List<String> images) {
    if (widget.limitToEightImages && images.length > _maxImagesToPreload) {
      return images.take(_maxImagesToPreload).toList();
    }
    return images;
  }

  /// Adds a category to the list
  void _addCategory(String categoryKey, List<String> images) {
    _categories.add(_GalleryCategory(
      key: categoryKey,
      label: _getCategoryLabel(categoryKey),
      images: images,
    ));
  }

  /// Ensures at least one category exists (empty placeholder)
  void _ensureAtLeastOneCategory() {
    if (_categories.isEmpty) {
      _categories.add(_GalleryCategory(
        key: _emptyKey,
        label: 'Gallery',
        images: [],
      ));
    }
  }

  /// Maps category keys to their translation keys
  String _getTranslationKey(String categoryKey) {
    const keyMap = {
      _foodKey: _foodTranslationKey,
      _menuKey: _menuTranslationKey,
      _interiorKey: _interiorTranslationKey,
      _outdoorKey: _outdoorTranslationKey,
    };
    return keyMap[categoryKey] ?? categoryKey;
  }

  /// Gets translated category label
  String _getCategoryLabel(String categoryKey) {
    final translationKey = _getTranslationKey(categoryKey);
    return td(ref, translationKey);
  }

  /// =========================================================================
  /// USER INTERACTION HANDLERS
  /// =========================================================================

  /// Ensures gallery opened event is tracked on first user interaction
  ///
  /// This method is called from all user interaction handlers to ensure
  /// we track the gallery as "opened" only when the user actually engages
  /// with it (tap, swipe, etc.) rather than on page load.
  void _ensureOpenedTracking() {
    if (!_hasTrackedOpened) {
      _hasTrackedOpened = true;
      _trackGalleryOpened();
    }
  }

  /// Called when tab changes (from tab tap or page swipe)
  void _onTabChanged() {
    _ensureOpenedTracking();
  }

  /// Handles page change from swipe gesture
  void _handlePageChanged(int index) {
    final previousIndex = _tabController.index;

    // Track gallery opened on first swipe
    _ensureOpenedTracking();

    setState(() {
      _tabController.index = index;
    });

    // Track tab navigation via swipe
    _trackTabChange(previousIndex, index, 'swipe');
  }

  /// Handles tab tap to navigate to corresponding page
  void _handleTabTap(int index) {
    final previousIndex = _tabController.index;

    // Track gallery opened on first tap
    _ensureOpenedTracking();

    _pageController.animateToPage(
      index,
      duration: _pageTransitionDuration,
      curve: _pageTransitionCurve,
    );

    // Track tab navigation via tap
    _trackTabChange(previousIndex, index, 'tap');
  }

  /// Handles image tap to open full-screen viewer
  Future<void> _handleImageTap(List<String> images, int index) async {
    // Track gallery opened on first image tap
    _ensureOpenedTracking();

    final currentCategory = _categories[_tabController.index];
    if (widget.onImageTap != null) {
      await widget.onImageTap!(images, index, currentCategory.key);
    }
  }

  /// =========================================================================
  /// ANALYTICS TRACKING
  /// =========================================================================

  /// Tracks gallery tab opened on initialization.
  ///
  /// Records all available tabs so we can calculate usage rates
  /// even for tabs that aren't clicked.
  void _trackGalleryOpened() {
    final availableTabs = _categories.map((c) => c.key).toList();

    // Get analytics data
    final analyticsState = ref.read(analyticsProvider);
    final deviceId = AnalyticsService.instance.deviceId ?? 'unknown';
    final sessionId = analyticsState.sessionId ?? 'unknown';
    final userId = AnalyticsService.instance.userId ?? 'unknown';

    // Track event (fire and forget)
    ApiService.instance.postAnalytics(
      eventType: 'gallery_opened',
      deviceId: deviceId,
      sessionId: sessionId,
      userId: userId,
      eventData: {
        'available_tabs': availableTabs,
        'total_tabs': availableTabs.length,
        'initial_tab': availableTabs.isNotEmpty ? availableTabs[0] : 'empty',
      },
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  /// Tracks tab change events with context of available tabs.
  ///
  /// Records which tabs are available so we can calculate usage
  /// statistics properly (knowing what was NOT selected).
  void _trackTabChange(int fromIndex, int toIndex, String method) {
    // Don't track if it's the same tab
    if (fromIndex == toIndex) return;

    final fromTab = _categories[fromIndex].key;
    final toTab = _categories[toIndex].key;
    final availableTabs = _categories.map((c) => c.key).toList();

    // Get analytics data
    final analyticsState = ref.read(analyticsProvider);
    final deviceId = AnalyticsService.instance.deviceId ?? 'unknown';
    final sessionId = analyticsState.sessionId ?? 'unknown';
    final userId = AnalyticsService.instance.userId ?? 'unknown';

    // Track event (fire and forget)
    ApiService.instance.postAnalytics(
      eventType: 'gallery_tab_changed',
      deviceId: deviceId,
      sessionId: sessionId,
      userId: userId,
      eventData: {
        'from_tab': fromTab,
        'to_tab': toTab,
        'from_index': fromIndex,
        'to_index': toIndex,
        'method': method, // 'tap' or 'swipe'
        'available_tabs': availableTabs,
      },
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  /// =========================================================================
  /// UI BUILDERS - MAIN LAYOUT
  /// =========================================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: AppColors.bgPage,
      child: Column(
        children: [
          _buildTabBarContainer(),
          _buildGalleryPageView(),
        ],
      ),
    );
  }

  /// Builds the tab bar container
  Widget _buildTabBarContainer() {
    return Container(
      margin: const EdgeInsets.only(bottom: _tabBarBottomMargin),
      color: AppColors.bgPage,
      child: _buildFixedTabBar(),
    );
  }

  /// Builds the gallery page view
  Widget _buildGalleryPageView() {
    return Expanded(
      child: PageView.builder(
        controller: _pageController,
        itemCount: _categories.length,
        onPageChanged: _handlePageChanged,
        itemBuilder: (context, index) => _buildGalleryGrid(_categories[index]),
      ),
    );
  }

  /// =========================================================================
  /// UI BUILDERS - TAB BAR
  /// =========================================================================

  /// Builds the fixed tab bar with equal-width tabs
  Widget _buildFixedTabBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: _getTabBarDecoration(),
          child: Row(
            children: _buildTabItems(constraints.maxWidth),
          ),
        );
      },
    );
  }

  /// Gets the tab bar decoration with bottom border
  BoxDecoration _getTabBarDecoration() {
    return const BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: AppColors.border,
          width: _tabBarBorderWidth,
        ),
      ),
    );
  }

  /// Builds all tab items
  List<Widget> _buildTabItems(double maxWidth) {
    return _categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      return _buildSizedTabItem(category.label, index, maxWidth);
    }).toList();
  }

  /// Builds a single tab item with fixed width
  Widget _buildSizedTabItem(String label, int index, double maxWidth) {
    return SizedBox(
      width: maxWidth * _tabWidth,
      child: _buildTabItem(label, index),
    );
  }

  /// Builds the tab item content
  Widget _buildTabItem(String label, int index) {
    final isSelected = _tabController.index == index;

    return GestureDetector(
      onTap: () => _handleTabTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.only(top: _tabPaddingTop),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTabLabel(label, isSelected),
            const SizedBox(height: _tabIndicatorSpacing),
            if (isSelected) _buildTabIndicator(label),
          ],
        ),
      ),
    );
  }

  /// Builds the tab label text
  Widget _buildTabLabel(String label, bool isSelected) {
    return Text(
      label,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: _selectedTabFontSize,
        fontWeight:
            isSelected ? _selectedTabFontWeight : _unselectedTabFontWeight,
        color: isSelected ? AppColors.accent : AppColors.textPrimary,
      ),
    );
  }

  /// Builds the tab selection indicator
  Widget _buildTabIndicator(String label) {
    return Container(
      height: _tabIndicatorHeight,
      width: label.length * _tabIndicatorWidthPerChar,
      color: AppColors.accent,
    );
  }

  /// =========================================================================
  /// UI BUILDERS - GALLERY GRID
  /// =========================================================================

  /// Builds the gallery grid for a category
  Widget _buildGalleryGrid(_GalleryCategory category) {
    if (category.images.isEmpty) {
      return _buildEmptyState();
    }

    final gridHeight = _calculateGridHeight();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _gridHorizontalPadding),
      child: SizedBox(
        height: gridHeight,
        child: _buildImageGrid(category),
      ),
    );
  }

  /// Calculates the required height for the grid (2 rows)
  double _calculateGridHeight() {
    final containerWidth = widget.width ?? MediaQuery.of(context).size.width;
    final imageWidth =
        (containerWidth - (_gridColumnCount - 1) * _gridSpacing) /
            _gridColumnCount;
    return (imageWidth * _gridRowCount) + _gridSpacing;
  }

  /// Builds the image grid view
  Widget _buildImageGrid(_GalleryCategory category) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _gridColumnCount,
        crossAxisSpacing: _gridSpacing,
        mainAxisSpacing: _gridSpacing,
        childAspectRatio: 1,
      ),
      itemCount: category.images.length,
      itemBuilder: (context, index) => _buildImageTile(category.images, index),
    );
  }

  /// Builds a single image tile
  Widget _buildImageTile(List<String> images, int index) {
    return GestureDetector(
      onTap: () => _handleImageTap(images, index),
      child: _buildRoundedImage(images[index]),
    );
  }

  /// Builds a rounded image with error and loading states
  Widget _buildRoundedImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_imageBorderRadius),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImageErrorState(),
        loadingBuilder: (context, child, loadingProgress) =>
            _buildImageLoadingState(child, loadingProgress),
      ),
    );
  }

  /// Builds the image error state
  Widget _buildImageErrorState() {
    return Container(
      color: AppColors.bgInput,
      child: const Icon(
        Icons.broken_image,
        color: AppColors.textTertiary,
      ),
    );
  }

  /// Builds the image loading state with progress indicator
  Widget _buildImageLoadingState(
      Widget child, ImageChunkEvent? loadingProgress) {
    if (loadingProgress == null) return child;

    return Container(
      color: AppColors.bgSurface,
      child: Center(
        child: CircularProgressIndicator(
          value: _calculateLoadingProgress(loadingProgress),
          strokeWidth: 1.0,
          color: AppColors.accent,
        ),
      ),
    );
  }

  /// Calculates loading progress value
  double? _calculateLoadingProgress(ImageChunkEvent loadingProgress) {
    final expectedTotal = loadingProgress.expectedTotalBytes;
    if (expectedTotal == null) return null;
    return loadingProgress.cumulativeBytesLoaded / expectedTotal;
  }

  /// Builds the empty state when no images are available
  Widget _buildEmptyState() {
    return Center(
      child: Text(
        td(ref, _noImagesTranslationKey),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
      ),
    );
  }
}

/// ============================================================================
/// GALLERY CATEGORY MODEL
/// ============================================================================

/// Represents a single gallery category with its images
class _GalleryCategory {
  const _GalleryCategory({
    required this.key,
    required this.label,
    required this.images,
  });

  final String key;
  final String label;
  final List<String> images;
}
