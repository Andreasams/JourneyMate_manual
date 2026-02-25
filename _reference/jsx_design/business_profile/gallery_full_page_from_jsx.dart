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

class GalleryFullPage extends StatefulWidget {
  const GalleryFullPage({super.key});

  @override
  State<GalleryFullPage> createState() => _GalleryFullPageState();
}

class _GalleryFullPageState extends State<GalleryFullPage> {
  // Active tab state
  String _activeTab = 'Mad';

  // Tab categories
  final List<String> _tabs = ['Mad', 'Menu', 'Inde', 'Ude'];

  // Mock gallery data - TODO: Replace with actual restaurant images
  // PLACEHOLDER: color values below will be removed entirely when real network images load
  final Map<String, List<Map<String, dynamic>>> _galleryImages = {
    'Mad': List.generate(
      12,
      (i) => {'id': i, 'bg': const Color(0xFFD0D0D0)}, // PLACEHOLDER: grey background for food images
    ),
    'Menu': List.generate(
      8,
      (i) => {'id': i, 'bg': const Color(0xFFC0C0C0)}, // PLACEHOLDER: grey background for menu images
    ),
    'Inde': List.generate(
      6,
      (i) => {'id': i, 'bg': const Color(0xFFB0B0B0)}, // PLACEHOLDER: grey background for interior images
    ),
    'Ude': List.generate(
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
                      'Galleri', // TODO: Translation key 'gallery_title'
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
                children: _tabs.map((tab) {
                  final isActive = _activeTab == tab;
                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _activeTab = tab;
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
                          tab, // TODO: Translation keys for tab names
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
