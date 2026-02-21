import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'image_gallery_overlay_swipable_model.dart';
export 'image_gallery_overlay_swipable_model.dart';

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
  late ImageGalleryOverlaySwipableModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImageGalleryOverlaySwipableModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: custom_widgets.ImageGalleryWidget(
        width: double.infinity,
        height: double.infinity,
        imageUrls: widget!.imageURLs!,
        currentIndex: widget!.imageIndex!,
        categoryName: widget!.tabCategory!,
        onClose: (closeAction) async {
          Navigator.pop(context);
        },
      ),
    );
  }
}
