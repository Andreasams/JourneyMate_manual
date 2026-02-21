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

/// A full-screen image gallery widget with swipe navigation and zoom
/// capabilities.
///
/// Supports both single image display and multi-image carousel with infinite
/// scroll. Features include gesture-based navigation, custom arrow buttons,
/// and a semi-transparent backdrop with close functionality.
class ImageGalleryWidget extends StatefulWidget {
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
  final Future Function(bool? closeAction)? onClose;

  @override
  State<ImageGalleryWidget> createState() => _ImageGalleryWidgetState();
}

class _ImageGalleryWidgetState extends State<ImageGalleryWidget> {
  /// =========================================================================
  /// STATE & CONSTANTS
  /// =========================================================================

  late PageController _pageController;
  late int _currentPage;

  /// Multiplier for creating infinite scroll effect in multi-image view
  static const int _virtualMultiplier = 1000;

  /// Current horizontal drag offset for single image bounce effect
  double _dragOffset = 0.0;

  /// Tracks whether user is currently dragging to prevent accidental closes
  bool _isDragging = false;

  /// Visual constants
  static const double _backdropOpacity = 0.3;
  static const double _closeButtonOpacity = 0.5;
  static const double _closeButtonSize = 24.0;
  static const double _closeButtonPadding = 8.0;
  static const double _closeButtonMargin = 16.0;
  static const double _maxDragOffset = 100.0;
  static const Duration _dragAnimationDuration = Duration(milliseconds: 300);
  static const Duration _dragResetDelay = Duration(milliseconds: 300);
  static const Curve _dragAnimationCurve = Curves.easeOutBack;

  /// =========================================================================
  /// LIFECYCLE METHODS
  /// =========================================================================

  @override
  void initState() {
    super.initState();
    _initializePageController();

    // Track gallery opened
    _trackGalleryOpened();
  }

  @override
  void dispose() {
    _disposePageController();
    super.dispose();
  }

  /// =========================================================================
  /// INITIALIZATION & CLEANUP
  /// =========================================================================

  /// Initializes the page controller for multi-image galleries.
  ///
  /// Sets up infinite scroll by calculating a virtual page index that allows
  /// seamless looping through images in both directions.
  void _initializePageController() {
    if (_hasMultipleImages) {
      _currentPage = _calculateVirtualPageIndex(widget.currentIndex);
      _pageController = PageController(initialPage: _currentPage);
    }
  }

  /// Calculates the virtual page index for infinite scroll.
  ///
  /// Maps the actual image index to a position in the virtual page space
  /// that allows scrolling in both directions without visible jumps.
  int _calculateVirtualPageIndex(int actualIndex) {
    final totalImages = widget.imageUrls.length;
    final virtualCenter = totalImages * (_virtualMultiplier ~/ 2);
    return (actualIndex + virtualCenter) % (totalImages * _virtualMultiplier);
  }

  /// Safely disposes the page controller if it was initialized.
  void _disposePageController() {
    if (_hasMultipleImages) {
      _pageController.dispose();
    }
  }

  /// =========================================================================
  /// STATE QUERIES
  /// =========================================================================

  /// Returns true if the gallery contains more than one image.
  bool get _hasMultipleImages => widget.imageUrls.length > 1;

  /// Returns true if the gallery contains exactly one image.
  bool get _hasSingleImage => widget.imageUrls.length == 1;

  /// =========================================================================
  /// ANALYTICS TRACKING
  /// =========================================================================

  /// Tracks when the gallery is opened.
  void _trackGalleryOpened() {
    trackAnalyticsEvent(
      'image_gallery_opened',
      {
        'category': widget.categoryName,
        'total_images': widget.imageUrls.length,
        'initial_image_index': widget.currentIndex,
        'gallery_type': _hasMultipleImages ? 'carousel' : 'single',
      },
    ).catchError((error) {
      debugPrint('⚠️ Failed to track gallery opened: $error');
    });
  }

  /// Tracks navigation between images.
  void _trackImageNavigation(String method, int newIndex) {
    trackAnalyticsEvent(
      'image_gallery_navigation',
      {
        'category': widget.categoryName,
        'navigation_method': method, // 'arrow_left', 'arrow_right', 'swipe'
        'from_index': _currentPage % widget.imageUrls.length,
        'to_index': newIndex % widget.imageUrls.length,
        'total_images': widget.imageUrls.length,
      },
    ).catchError((error) {
      debugPrint('⚠️ Failed to track image navigation: $error');
    });
  }

  /// Tracks when the gallery is closed.
  void _trackGalleryClosed(String closeMethod) {
    trackAnalyticsEvent(
      'image_gallery_closed',
      {
        'category': widget.categoryName,
        'close_method': closeMethod, // 'close_button', 'backdrop_tap'
        'final_image_index':
            _hasMultipleImages ? _currentPage % widget.imageUrls.length : 0,
        'total_images': widget.imageUrls.length,
      },
    ).catchError((error) {
      debugPrint('⚠️ Failed to track gallery closed: $error');
    });
  }

  /// =========================================================================
  /// USER INTERACTION HANDLERS
  /// =========================================================================

  /// Handles the close action, ensuring it doesn't trigger during drags.
  Future<void> _handleClose({bool isBackdropTap = false}) async {
    if (!_isDragging && widget.onClose != null) {
      markUserEngaged();
      _trackGalleryClosed(isBackdropTap ? 'backdrop_tap' : 'close_button');
      await widget.onClose?.call(true);
    }
  }

  /// Handles horizontal drag start for single image view.
  void _handleSingleImageDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  /// Handles horizontal drag updates for single image bounce effect.
  void _handleSingleImageDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dx;
      _dragOffset = _dragOffset.clamp(-_maxDragOffset, _maxDragOffset);
    });
  }

  /// Handles horizontal drag end, resetting the image position.
  void _handleSingleImageDragEnd(DragEndDetails details) {
    setState(() {
      _dragOffset = 0.0;
    });
    _resetDraggingStateAfterDelay();
  }

  /// Handles page change events in the multi-image carousel.
  void _handlePageChanged(int page) {
    final oldPage = _currentPage;
    setState(() {
      _currentPage = page;
    });

    // Track swipe navigation
    if ((page - oldPage).abs() == 1) {
      _trackImageNavigation('swipe', page);
    }
  }

  /// Navigates to the previous image in the carousel.
  void _navigateToPreviousImage() {
    markUserEngaged();
    _isDragging = true;

    final targetPage = _currentPage - 1;
    _trackImageNavigation('arrow_left', targetPage);

    _pageController.previousPage(
      duration: _dragAnimationDuration,
      curve: Curves.easeInOut,
    );
    _resetDraggingStateAfterDelay();
  }

  /// Navigates to the next image in the carousel.
  void _navigateToNextImage() {
    markUserEngaged();
    _isDragging = true;

    final targetPage = _currentPage + 1;
    _trackImageNavigation('arrow_right', targetPage);

    _pageController.nextPage(
      duration: _dragAnimationDuration,
      curve: Curves.easeInOut,
    );
    _resetDraggingStateAfterDelay();
  }

  /// Resets the dragging state after a brief delay.
  ///
  /// This prevents accidental closes immediately after navigation gestures.
  void _resetDraggingStateAfterDelay() {
    Future.delayed(_dragResetDelay, () {
      if (mounted) {
        setState(() {
          _isDragging = false;
        });
      }
    });
  }

  /// =========================================================================
  /// UI BUILDERS - MAIN LAYOUT
  /// =========================================================================

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleClose(isBackdropTap: true),
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          _buildBackdrop(),
          _buildMainContent(),
          _buildCloseButton(context),
        ],
      ),
    );
  }

  /// Builds the semi-transparent backdrop that covers the full screen.
  Widget _buildBackdrop() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(_backdropOpacity),
      ),
    );
  }

  /// Builds the main content area containing the image viewer.
  Widget _buildMainContent() {
    return Positioned.fill(
      child: Container(
        width: widget.width,
        height: widget.height,
        color: Colors.transparent,
        child:
            _hasSingleImage ? _buildSingleImageView() : _buildMultiImageView(),
      ),
    );
  }

  /// Builds the close button in the top-left corner.
  Widget _buildCloseButton(BuildContext context) {
    return Positioned(
      left: _closeButtonMargin,
      top: MediaQuery.of(context).padding.top + _closeButtonMargin,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(_closeButtonOpacity),
            shape: BoxShape.circle,
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => _handleClose(isBackdropTap: false),
            child: Container(
              padding: const EdgeInsets.all(_closeButtonPadding),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: _closeButtonSize,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// =========================================================================
  /// UI BUILDERS - IMAGE VIEWS
  /// =========================================================================

  /// Builds the single image view with horizontal drag bounce effect.
  Widget _buildSingleImageView() {
    return GestureDetector(
      onHorizontalDragStart: _handleSingleImageDragStart,
      onHorizontalDragUpdate: _handleSingleImageDragUpdate,
      onHorizontalDragEnd: _handleSingleImageDragEnd,
      child: AnimatedContainer(
        duration: _dragAnimationDuration,
        curve: _dragAnimationCurve,
        transform: Matrix4.translationValues(_dragOffset, 0.0, 0.0),
        child: _buildCenteredImage(widget.imageUrls[0]),
      ),
    );
  }

  /// Builds the multi-image carousel view with navigation controls.
  Widget _buildMultiImageView() {
    return Stack(
      children: [
        _buildPageView(),
        _buildLeftNavigationButton(),
        _buildRightNavigationButton(),
      ],
    );
  }

  /// Builds the PageView for scrolling through multiple images.
  Widget _buildPageView() {
    return GestureDetector(
      onHorizontalDragStart: (_) => setState(() => _isDragging = true),
      onHorizontalDragEnd: (_) => _resetDraggingStateAfterDelay(),
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: _handlePageChanged,
        itemBuilder: (context, index) {
          final imageIndex = index % widget.imageUrls.length;
          return _buildCenteredImage(widget.imageUrls[imageIndex]);
        },
      ),
    );
  }

  /// Builds a centered image widget with network loading.
  Widget _buildCenteredImage(String imageUrl) {
    return Center(
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
      ),
    );
  }

  /// Builds the left navigation arrow button.
  Widget _buildLeftNavigationButton() {
    return Positioned(
      left: 10,
      top: 0,
      bottom: 0,
      child: Center(
        child: CircularArrowButton(
          isLeft: true,
          onPressed: _navigateToPreviousImage,
        ),
      ),
    );
  }

  /// Builds the right navigation arrow button.
  Widget _buildRightNavigationButton() {
    return Positioned(
      right: 10,
      top: 0,
      bottom: 0,
      child: Center(
        child: CircularArrowButton(
          isLeft: false,
          onPressed: _navigateToNextImage,
        ),
      ),
    );
  }
}

/// ============================================================================
/// CIRCULAR ARROW BUTTON COMPONENT
/// ============================================================================

/// A circular button with a custom-painted arrow for image navigation.
///
/// Features a semi-transparent background with ripple effect on tap.
class CircularArrowButton extends StatelessWidget {
  const CircularArrowButton({
    super.key,
    required this.isLeft,
    required this.onPressed,
  });

  final bool isLeft;
  final VoidCallback onPressed;

  static const double _buttonSize = 48.0;
  static const double _backgroundOpacity = 0.5;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        width: _buttonSize,
        height: _buttonSize,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(_backgroundOpacity),
          shape: BoxShape.circle,
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: CustomPaint(
            painter: ArrowPainter(
              isLeft: isLeft,
              arrowColor: Colors.white,
              strokeWidth: 2.5,
              arrowLength: 12.0,
              arrowSpread: 20.0,
              horizontalOffset: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
/// ARROW PAINTER
/// ============================================================================

/// Custom painter for drawing directional arrows in navigation buttons.
///
/// Creates a chevron-style arrow pointing left or right, centered within
/// the button with optional horizontal offset for visual balance.
class ArrowPainter extends CustomPainter {
  const ArrowPainter({
    required this.isLeft,
    this.arrowColor = Colors.white,
    this.strokeWidth = 2.5,
    this.arrowLength = 12.0,
    this.arrowSpread = 20.0,
    this.horizontalOffset = 2.0,
  });

  final bool isLeft;
  final Color arrowColor;
  final double strokeWidth;
  final double arrowLength;
  final double arrowSpread;
  final double horizontalOffset;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = arrowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = _createArrowPath(size);
    canvas.drawPath(path, paint);
  }

  /// Creates the path for the arrow based on direction.
  Path _createArrowPath(Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final adjustedCenterX =
        isLeft ? centerX - horizontalOffset : centerX + horizontalOffset;

    final path = Path();

    if (isLeft) {
      _drawLeftArrow(path, adjustedCenterX, centerY);
    } else {
      _drawRightArrow(path, adjustedCenterX, centerY);
    }

    return path;
  }

  /// Draws a left-pointing arrow (chevron).
  void _drawLeftArrow(Path path, double centerX, double centerY) {
    path.moveTo(centerX + arrowLength / 2, centerY - arrowSpread / 2);
    path.lineTo(centerX - arrowLength / 2, centerY);
    path.lineTo(centerX + arrowLength / 2, centerY + arrowSpread / 2);
  }

  /// Draws a right-pointing arrow (chevron).
  void _drawRightArrow(Path path, double centerX, double centerY) {
    path.moveTo(centerX - arrowLength / 2, centerY - arrowSpread / 2);
    path.lineTo(centerX + arrowLength / 2, centerY);
    path.lineTo(centerX - arrowLength / 2, centerY + arrowSpread / 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
