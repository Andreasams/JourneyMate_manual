import 'package:flutter/material.dart';
import 'image_gallery_widget.dart';

/// Wrapper widget for displaying full-screen image gallery overlay.
///
/// This widget delegates all functionality to ImageGalleryWidget and only
/// handles the onClose callback to dismiss the overlay via Navigator.pop().
///
/// Features:
/// - Full-screen image gallery display
/// - Swipeable carousel for multiple images
/// - Close button integration
/// - Category-based analytics tracking
/// - Proper integration with ImageGalleryWidget from Session #4
class ImageGalleryOverlaySwipableWidget extends StatefulWidget {
  const ImageGalleryOverlaySwipableWidget({
    super.key,
    required this.imageURLs,
    required this.imageIndex,
    required this.tabCategory,
  });

  final List<String>? imageURLs;
  final int? imageIndex;
  final String? tabCategory;

  @override
  State<ImageGalleryOverlaySwipableWidget> createState() =>
      _ImageGalleryOverlaySwipableWidgetState();
}

class _ImageGalleryOverlaySwipableWidgetState
    extends State<ImageGalleryOverlaySwipableWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: ImageGalleryWidget(
        width: double.infinity,
        height: double.infinity,
        imageUrls: widget.imageURLs ?? [],
        currentIndex: widget.imageIndex ?? 0,
        categoryName: widget.tabCategory ?? '',
        onClose: (closeAction) async {
          // Dismiss the overlay when close button is tapped
          if (context.mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
