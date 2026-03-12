library;

/// Full-screen image gallery widget with swipe navigation and bounce effects.
///
/// Features:
/// - Multi-image mode: PageView with infinite scroll (virtual page indexing)
/// - Single-image mode: GestureDetector with horizontal bounce (±100px max drag)
/// - Analytics tracking: gallery_opened, gallery_image_viewed, gallery_closed
/// - Close button (top-left, positioned 60px from top to avoid iPhone gesture area)
/// - CachedNetworkImage with loading/error states
///
/// Used by:
/// - ImageGalleryOverlaySwipableWidget (Profile page)
/// - MenuDishesListView (Menu page)
/// - SearchResultsListView (Search page)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_constants.dart';

class ImageGalleryWidget extends ConsumerStatefulWidget {
  const ImageGalleryWidget({
    super.key,
    this.width,
    this.height,
    required this.imageUrls,
    required this.currentIndex,
    required this.categoryName,
    this.onClose,
  });

  final double? width;
  final double? height;
  final List<String> imageUrls;
  final int currentIndex;
  final String categoryName;
  final Future Function(bool?)? onClose;

  @override
  ConsumerState<ImageGalleryWidget> createState() => _ImageGalleryWidgetState();
}

class _ImageGalleryWidgetState extends ConsumerState<ImageGalleryWidget> {
  /// =========================================================================
  /// STATE & CONSTANTS
  /// =========================================================================

  late PageController _pageController;
  int _currentImageIndex = 0;

  /// Current horizontal drag offset for single image bounce effect
  Offset _currentOffset = Offset.zero;

  /// Prevents duplicate gallery_opened events on rebuilds
  bool _hasLoggedOpen = false;

  /// Multiplier for creating infinite scroll effect in multi-image view.
  /// Used as: initialPage = _virtualMultiplier * imageCount + tappedIndex.
  /// This guarantees (N * count + index) % count == index for ANY gallery size.
  static const int _virtualMultiplier = 10000;

  /// =========================================================================
  /// LIFECYCLE METHODS
  /// =========================================================================

  @override
  void initState() {
    super.initState();

    // Clamp currentIndex to valid range (handle out-of-bounds)
    _currentImageIndex = widget.currentIndex.clamp(0, widget.imageUrls.length - 1);

    // Initialize PageController ONLY for multi-image mode
    if (widget.imageUrls.length > 1) {
      // Virtual indexing: base must be a multiple of imageUrls.length
      // so that (base + index) % length == index for any gallery size
      _pageController = PageController(
        initialPage: _virtualMultiplier * widget.imageUrls.length + _currentImageIndex,
      );
    }

    // Fire gallery_opened analytics (once only)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fireGalleryOpenedEvent();
    });
  }

  @override
  void dispose() {
    // Dispose PageController ONLY if it was created
    if (widget.imageUrls.length > 1) {
      _pageController.dispose();
    }
    super.dispose();
  }

  /// =========================================================================
  /// ANALYTICS TRACKING
  /// =========================================================================

  void _fireGalleryOpenedEvent() {
    if (_hasLoggedOpen) return; // CRITICAL: Prevent duplicates

    // Fire-and-forget analytics (don't await)
    ApiService.instance.postAnalytics(
      eventType: 'gallery_opened',
      deviceId: '', // Handled by ApiService
      sessionId: '', // Handled by ApiService
      userId: '', // Handled by ApiService
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'cityId': AppConstants.kDefaultCityId,
        'categoryName': widget.categoryName,
        'imageCount': widget.imageUrls.length,
        'startIndex': _currentImageIndex,
      },
    ).catchError((error) {
      // Silent failure - don't block UI on analytics errors
      return ApiCallResponse.failure('Analytics error: $error');
    });

    _hasLoggedOpen = true;
  }

  void _fireImageViewedEvent() {
    // Fire-and-forget analytics (don't await)
    ApiService.instance.postAnalytics(
      eventType: 'gallery_image_viewed',
      deviceId: '', // Handled by ApiService
      sessionId: '', // Handled by ApiService
      userId: '', // Handled by ApiService
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'cityId': AppConstants.kDefaultCityId,
        'categoryName': widget.categoryName,
        'imageIndex': _currentImageIndex,
        'imageUrl': widget.imageUrls[_currentImageIndex],
      },
    ).catchError((error) {
      // Silent failure - don't block UI on analytics errors
      return ApiCallResponse.failure('Analytics error: $error');
    });
  }

  void _fireGalleryClosedEvent() {
    // Fire-and-forget analytics (don't await)
    ApiService.instance.postAnalytics(
      eventType: 'gallery_closed',
      deviceId: '', // Handled by ApiService
      sessionId: '', // Handled by ApiService
      userId: '', // Handled by ApiService
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'cityId': AppConstants.kDefaultCityId,
        'categoryName': widget.categoryName,
        'finalIndex': _currentImageIndex,
        'totalImages': widget.imageUrls.length,
      },
    ).catchError((error) {
      // Silent failure - don't block UI on analytics errors
      return ApiCallResponse.failure('Analytics error: $error');
    });
  }

  /// =========================================================================
  /// USER INTERACTION HANDLERS
  /// =========================================================================

  void _onPageChanged(int virtualIndex) {
    final actualIndex = virtualIndex % widget.imageUrls.length;

    // CRITICAL: Only fire analytics if ACTUAL index changed
    // (prevents duplicate events for same image)
    if (_currentImageIndex != actualIndex) {
      setState(() {
        _currentImageIndex = actualIndex;
      });
      _fireImageViewedEvent();
    }
  }

  /// =========================================================================
  /// UI BUILDERS - MAIN LAYOUT
  /// =========================================================================

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.black, // Fullscreen gallery backdrop
      child: Stack(
        children: [
          // Main content (PageView or single image)
          widget.imageUrls.length == 1
              ? _buildSingleImageView()
              : _buildMultiImageView(),

          // Drag handle (top-center, light for dark background)
          Positioned(
            top: AppSpacing.sm,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppRadius.handle),
                ),
              ),
            ),
          ),

          // Close button (top-left)
          _buildCloseButton(),
        ],
      ),
    );
  }

  /// Builds empty state when no images available
  Widget _buildEmptyState() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.black,
      child: Center(
        child: Text(
          'No images available',
          style: AppTypography.bodyLg.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// =========================================================================
  /// UI BUILDERS - IMAGE VIEWS
  /// =========================================================================

  /// Builds the single image view with horizontal drag bounce effect
  Widget _buildSingleImageView() {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          // CRITICAL: Accumulate delta (don't replace), clamp to ±100px
          _currentOffset = Offset(
            (_currentOffset.dx + details.delta.dx).clamp(-100.0, 100.0),
            0.0,
          );
        });
      },
      onPanEnd: (details) {
        setState(() {
          // Reset to center (AnimatedContainer will animate)
          _currentOffset = Offset.zero;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(_currentOffset.dx, 0.0, 0.0),
        child: _buildImageContainer(widget.imageUrls[_currentImageIndex]),
      ),
    );
  }

  /// Builds the multi-image carousel view with PageView
  Widget _buildMultiImageView() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      itemBuilder: (context, virtualIndex) {
        // CRITICAL: Modulo maps virtual page → actual image index
        final actualIndex = virtualIndex % widget.imageUrls.length;
        return _buildImageContainer(widget.imageUrls[actualIndex]);
      },
    );
  }

  /// Builds an image container with CachedNetworkImage
  Widget _buildImageContainer(String imageUrl) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md), // 12px padding
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain, // Don't crop, maintain aspect ratio
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent), // Orange
          ),
        ),
        errorWidget: (context, url, error) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.textSecondary,
                size: 48,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Image failed to load',
                style: AppTypography.bodyLg.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// =========================================================================
  /// UI BUILDERS - CONTROLS
  /// =========================================================================

  /// Builds the close button in the top-left corner
  Widget _buildCloseButton() {
    return Positioned(
      top: 60, // 60px from top to avoid iPhone gesture area
      left: AppSpacing.xl, // 20px from left
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _fireGalleryClosedEvent();
              if (widget.onClose != null) {
                widget.onClose!(true);
              } else {
                Navigator.of(context).pop();
              }
            },
            borderRadius: BorderRadius.circular(AppRadius.button), // 12px
            child: Container(
              padding: EdgeInsets.all(AppSpacing.sm), // 8px padding
              decoration: BoxDecoration(
                color: AppColors.bgCard.withValues(alpha: 0.8), // Semi-transparent white
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
              child: Icon(
                Icons.close,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

}
