// ============================================================
// GALLERY FULL PAGE - Converted from JSX v2 Design
// Clean Flutter UI shell with no backend functionality
//
// Full-screen photo gallery with tabbed categories
// Shows: Mad (Food), Menu, Inde (Inside), Ude (Outside)
// This is the UI shell only - backend integration comes later
// ============================================================

import 'package:flutter/material.dart';
import '../../shared/app_theme.dart';

// TODO: Import when backend integrated
// import '/flutter_flow/flutter_flow_util.dart';
// import '/custom_code/actions/index.dart' as actions;

/// Translation helper function
/// TODO: Wire up when backend is integrated
/// For now, returns the key as a placeholder
String getTranslations(String languageCode, String key, dynamic translationsCache) {
  // TODO: Implement translation lookup from translationsCache
  // This is a placeholder that will be replaced with actual translation logic
  return key;
}

class GalleryFullPage extends StatefulWidget {
  final String languageCode;
  final dynamic translationsCache;

  const GalleryFullPage({
    super.key,
    required this.languageCode,
    required this.translationsCache,
  });

  @override
  State<GalleryFullPage> createState() => _GalleryFullPageState();
}

class _GalleryFullPageState extends State<GalleryFullPage> {
  // Active tab state
  String _activeTab = 'gallery_food';

  // Tab categories with translation keys
  final Map<String, String> _tabs = {
    'gallery_food': 'gallery_food',
    'gallery_menu': 'gallery_menu',
    'gallery_interior': 'gallery_interior',
    'gallery_outdoor': 'gallery_outdoor',
  };

  // Mock gallery data - TODO: Replace with actual restaurant images
  // PLACEHOLDER: color values below will be removed entirely when real network images load
  final Map<String, List<Map<String, dynamic>>> _galleryImages = {
    'gallery_food': List.generate(
      12,
      (i) => {'id': i, 'bg': const Color(0xFFD0D0D0)}, // PLACEHOLDER: grey background for food images
    ),
    'gallery_menu': List.generate(
      8,
      (i) => {'id': i, 'bg': const Color(0xFFC0C0C0)}, // PLACEHOLDER: grey background for menu images
    ),
    'gallery_interior': List.generate(
      6,
      (i) => {'id': i, 'bg': const Color(0xFFB0B0B0)}, // PLACEHOLDER: grey background for interior images
    ),
    'gallery_outdoor': List.generate(
      10,
      (i) => {'id': i, 'bg': const Color(0xFFA0A0A0)}, // PLACEHOLDER: grey background for exterior images
    ),
  };

  List<Map<String, dynamic>> get _currentImages =>
      _galleryImages[_activeTab] ?? [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
            Container(
              height: 60,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl), // 20px
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.divider), // #f2f2f2
                ),
              ),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    onPressed: () {
                      // TODO: Add markUserEngaged() call
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back_ios_new),
                    color: AppColors.textPrimary,
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                  // Centered title
                  Expanded(
                    child: Text(
                      getTranslations(widget.languageCode, '9wk6mbas', widget.translationsCache),
                      // Note: Using categoryHeading (16px w700) with w600 override
                      style: AppTypography.categoryHeading.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Spacer to balance the back button
                  const SizedBox(width: 36),
                ],
              ),
            ),

            // Tabs
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl), // 20px
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.divider), // #f2f2f2
                ),
              ),
              child: Row(
                children: _tabs.entries.map((entry) {
                  final tabKey = entry.key;
                  final translationKey = entry.value;
                  final isActive = _activeTab == tabKey;
                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _activeTab = tabKey;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSpacing.md, // 12px
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isActive
                                  ? AppColors.accent
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          getTranslations(widget.languageCode, translationKey, widget.translationsCache),
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w500,
                            color: isActive
                                ? AppColors.accent
                                : AppColors.textTertiary, // #888
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Gallery grid
            Expanded(
              child: SingleChildScrollView(
                // Note: JSX specifies "16px 20px" (16 top/bottom, 20 left/right)
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl, // 20px
                  vertical: AppSpacing.lg, // 16px
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: AppSpacing.sm, // 8px
                    mainAxisSpacing: AppSpacing.sm, // 8px
                    childAspectRatio: 1.0, // Square tiles
                  ),
                  itemCount: _currentImages.length,
                  itemBuilder: (context, index) {
                    final image = _currentImages[index];
                    return _GalleryTile(
                      backgroundColor: image['bg'] as Color,
                      onTap: () {
                        // TODO: Open full-screen image viewer
                        // TODO: Add markUserEngaged() call
                        debugPrint('Image $index tapped in $_activeTab');
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// GALLERY TILE WIDGET
// ============================================================

/// Individual gallery tile with placeholder background
class _GalleryTile extends StatelessWidget {
  final Color backgroundColor;
  final VoidCallback onTap;

  const _GalleryTile({
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.chip), // 8px
      child: Container(
        decoration: BoxDecoration(
          // PLACEHOLDER: background color will be replaced by actual network images
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.chip), // 8px
        ),
        // TODO: Replace with actual Image widget showing restaurant photos
        // child: Image.network(imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}
