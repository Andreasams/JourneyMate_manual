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

/// A tabbed gallery widget for displaying categorized restaurant images.
///
/// Features: - Four image categories: Food, Menu, Interior, Outdoor -
/// Tab-based navigation with PageView - Grid layout with 4 columns and 2 rows
/// - Image precaching for smooth loading - Localized category names via
/// translation system (15 languages) - Optional limit to first 8 images per
/// category - Tap handler for full-screen image viewing - Automatic rebuild
/// when translations change
class GalleryTabWidget extends StatefulWidget {
  const GalleryTabWidget({
    super.key,
    this.width,
    this.height,
    required this.galleryData,
    required this.languageCode,
    required this.translationsCache,
    this.onImageTap,
    this.limitToEightImages = false,
  });

  final double? width;
  final double? height;
  final dynamic galleryData;
  final String languageCode;
  final dynamic translationsCache;
  final Future Function(List<String> imageUrls, int index, String categoryKey)?
      onImageTap;
  final bool limitToEightImages;

  @override
  State<GalleryTabWidget> createState() => _GalleryTabWidgetState();
}

class _GalleryTabWidgetState extends State<GalleryTabWidget>
    with SingleTickerProviderStateMixin {
  /// =========================================================================
  /// STATE & CONSTANTS
  /// =========================================================================

  late TabController _tabController;
  late PageController _pageController;
  late List<GalleryCategory> _categories;

  /// Flag to track if gallery opened event has been fired
  bool _hasTrackedOpened = false;

  /// Layout constants
  static const double _tabBarBottomMargin = 12.0;
  static const double _tabBarBorderWidth = 2.0;
  static const double _tabPaddingTop = 12.0;
  static const double _tabIndicatorHeight = 2.0;
  static const double _tabIndicatorSpacing = 6.0;
  static const double _tabIndicatorWidthPerChar = 10.0;
  static const double _tabWidth = 0.25; // 25% of parent width

  /// Grid layout constants
  static const int _gridColumnCount = 4;
  static const int _gridRowCount = 2;
  static const double _gridSpacing = 4.0;
  static const double _gridHorizontalPadding = 2.0;
  static const double _imageBorderRadius = 4.0;
  static const int _maxImagesToPreload = 8;

  /// Animation constants
  static const Duration _pageTransitionDuration = Duration(milliseconds: 300);
  static const Curve _pageTransitionCurve = Curves.easeInOut;

  /// Visual styling constants
  static const Color _backgroundColor = Colors.white;
  static const Color _tabBarBorderColor = Color(0xFFE0E0E0);
  static const Color _selectedTabColor = Color(0xFFE9874B);
  static const Color _unselectedTabColor = Color(0xFF14181B);
  static const double _selectedTabFontSize = 18.0;
  static const FontWeight _selectedTabFontWeight = FontWeight.w400;
  static const FontWeight _unselectedTabFontWeight = FontWeight.w300;

  /// Error state styling
  static final Color _imageErrorBackgroundColor = Colors.grey[300]!;
  static const Color _imageErrorIconColor = Colors.grey;
  static final Color _imageLoadingBackgroundColor = Colors.grey[200]!;
  static const double _loadingIndicatorStrokeWidth = 1.0;

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
    _scheduleImagePreloading();

    // NOTE: Gallery opened tracking removed from initState
    // It now fires on first user interaction (see _ensureOpenedTracking)
  }

  @override
  void didUpdateWidget(covariant GalleryTabWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Rebuild if translation cache or language changes
    if (widget.translationsCache != oldWidget.translationsCache ||
        widget.languageCode != oldWidget.languageCode) {
      // Reparse gallery data with new translations
      _parseGalleryData();
      setState(() {
        // Trigger rebuild with new translations
      });
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  /// =========================================================================
  /// TRANSLATION HELPERS
  /// =========================================================================

  /// Gets localized UI text using central translation function
  String _getUIText(String key) {
    return getTranslations(widget.languageCode, key, widget.translationsCache);
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
    return _getUIText(translationKey);
  }

  /// =========================================================================
  /// INITIALIZATION
  /// =========================================================================

  /// Initializes tab and page controllers
  void _initializeControllers() {
    _tabController = TabController(length: _categories.length, vsync: this);
    _pageController = PageController();
  }

  /// Disposes controllers
  void _disposeControllers() {
    _tabController.dispose();
    _pageController.dispose();
  }

  /// Schedules image preloading after first frame
  void _scheduleImagePreloading() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadImages();
    });
  }

  /// =========================================================================
  /// IMAGE PRELOADING
  /// =========================================================================

  /// Preloads first 8 images of each category for smooth display
  void _preloadImages() {
    for (var category in _categories) {
      final imagesToPreload = category.images.take(_maxImagesToPreload);
      for (var imageUrl in imagesToPreload) {
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

    for (String categoryKey in categoryOrder) {
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
    _categories.add(GalleryCategory(
      key: categoryKey,
      label: _getCategoryLabel(categoryKey),
      images: images,
    ));
  }

  /// Ensures at least one category exists (empty placeholder)
  void _ensureAtLeastOneCategory() {
    if (_categories.isEmpty) {
      _categories.add(GalleryCategory(
        key: _emptyKey,
        label: 'Gallery',
        images: [],
      ));
    }
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

  /// Handles page change from swipe gesture
  void _handlePageChanged(int index) {
    final previousIndex = _tabController.index;

    // Track gallery opened on first swipe
    _ensureOpenedTracking();

    setState(() {
      _tabController.animateTo(index);
    });

    // Track tab navigation via swipe
    _trackTabChange(previousIndex, index, 'swipe');
  }

  /// Handles tab tap to navigate to corresponding page
  void _handleTabTap(int index) {
    final previousIndex = _tabController.index;

    // Track gallery opened on first tap
    _ensureOpenedTracking();

    markUserEngaged();

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

    markUserEngaged();

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
    final availableTabNames = _categories.map((c) => c.label).toList();
    final initialTab = _categories.isNotEmpty ? _categories[0].key : null;

    trackAnalyticsEvent(
      'gallery_tab_opened',
      {
        'available_tabs': availableTabs,
        'available_tab_names': availableTabNames,
        'tab_count': _categories.length,
        'initial_tab': initialTab,
        'initial_tab_name':
            _categories.isNotEmpty ? _categories[0].label : null,
        'language': widget.languageCode,
      },
    ).catchError((error) {
      debugPrint('⚠️ Failed to track gallery opened: $error');
    });
  }

  /// Tracks tab change events with context of available tabs.
  ///
  /// Records which tabs are available so we can calculate usage
  /// statistics properly (knowing what was NOT selected).
  void _trackTabChange(int fromIndex, int toIndex, String method) {
    // Don't track if it's the same tab
    if (fromIndex == toIndex) return;

    final availableTabs = _categories.map((c) => c.key).toList();
    final fromTab = _categories[fromIndex].key;
    final toTab = _categories[toIndex].key;
    final fromTabName = _categories[fromIndex].label;
    final toTabName = _categories[toIndex].label;

    trackAnalyticsEvent(
      'gallery_tab_changed',
      {
        'from_tab': fromTab,
        'to_tab': toTab,
        'from_tab_name': fromTabName,
        'to_tab_name': toTabName,
        'from_index': fromIndex,
        'to_index': toIndex,
        'navigation_method': method, // 'tap' or 'swipe'
        'available_tabs': availableTabs,
        'tab_count': _categories.length,
        'language': widget.languageCode,
      },
    ).catchError((error) {
      debugPrint('⚠️ Failed to track tab change: $error');
    });
  }

  /// =========================================================================
  /// UI BUILDERS - MAIN LAYOUT
  /// =========================================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: _backgroundColor,
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
      color: _backgroundColor,
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
        itemBuilder: (_, index) => _buildGalleryGrid(_categories[index]),
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
          color: _tabBarBorderColor,
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
            SizedBox(height: _tabIndicatorSpacing),
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
        fontFamily: 'Roboto',
        fontSize: _selectedTabFontSize,
        fontWeight:
            isSelected ? _selectedTabFontWeight : _unselectedTabFontWeight,
        color: isSelected ? _selectedTabColor : _unselectedTabColor,
      ),
    );
  }

  /// Builds the tab selection indicator
  Widget _buildTabIndicator(String label) {
    return Container(
      height: _tabIndicatorHeight,
      width: label.length * _tabIndicatorWidthPerChar,
      color: _selectedTabColor,
    );
  }

  /// =========================================================================
  /// UI BUILDERS - GALLERY GRID
  /// =========================================================================

  /// Builds the gallery grid for a category
  Widget _buildGalleryGrid(GalleryCategory category) {
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
  Widget _buildImageGrid(GalleryCategory category) {
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
      itemBuilder: (_, index) => _buildImageTile(category.images, index),
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
        errorBuilder: (_, __, ___) => _buildImageErrorState(),
        loadingBuilder: (_, child, loadingProgress) =>
            _buildImageLoadingState(child, loadingProgress),
      ),
    );
  }

  /// Builds the image error state
  Widget _buildImageErrorState() {
    return Container(
      color: _imageErrorBackgroundColor,
      child: const Icon(
        Icons.broken_image,
        color: _imageErrorIconColor,
      ),
    );
  }

  /// Builds the image loading state with progress indicator
  Widget _buildImageLoadingState(
      Widget child, ImageChunkEvent? loadingProgress) {
    if (loadingProgress == null) return child;

    return Container(
      color: _imageLoadingBackgroundColor,
      child: Center(
        child: CircularProgressIndicator(
          value: _calculateLoadingProgress(loadingProgress),
          strokeWidth: _loadingIndicatorStrokeWidth,
          color: _selectedTabColor,
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
        _getUIText(_noImagesTranslationKey),
        style: const TextStyle(
          color: _unselectedTabColor,
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
class GalleryCategory {
  const GalleryCategory({
    required this.key,
    required this.label,
    required this.images,
  });

  final String key;
  final String label;
  final List<String> images;
}
