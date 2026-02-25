// ============================================================
// CONTACT COPY SUCCESS POPUP - Converted from JSX v2 Design
// Clean Flutter UI shell with no backend functionality
//
// Small success toast shown after copying contact info
// Displays at bottom of screen with fade-in animation
// This is the UI shell only - backend integration comes later
// ============================================================

import 'package:flutter/material.dart';
import '../../shared/app_theme.dart';

/// Success toast widget shown after copying contact information
///
/// Usage: Show using an OverlayEntry or as part of a Stack
/// ```dart
/// // Example: Show as overlay
/// final overlayEntry = OverlayEntry(
///   builder: (context) => ContactCopyPopup(
///     message: 'Kopieret til udklipsholder',
///   ),
/// );
/// Overlay.of(context).insert(overlayEntry);
///
/// // Auto-dismiss after 2 seconds
/// Future.delayed(Duration(seconds: 2), () => overlayEntry.remove());
/// ```
class ContactCopyPopup extends StatefulWidget {
  final String message;

  const ContactCopyPopup({
    super.key,
    this.message = 'Kopieret til udklipsholder', // TODO: Translation key
  });

  @override
  State<ContactCopyPopup> createState() => _ContactCopyPopupState();
}

class _ContactCopyPopupState extends State<ContactCopyPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Animation: fadeInUp 0.3s ease
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5), // Slide up from 10px below
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100, // JSX: bottom: 100
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xl, // 20px
                vertical: AppSpacing.md, // 12px
              ),
              decoration: BoxDecoration(
                color: AppColors.green, // Success color
                borderRadius: BorderRadius.circular(AppRadius.filter), // 10px
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                widget.message,
                style: AppTypography.label.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper function to show the contact copy popup
///
/// Usage:
/// ```dart
/// showContactCopyPopup(
///   context,
///   message: 'Kopieret til udklipsholder',
/// );
/// ```
void showContactCopyPopup(
  BuildContext context, {
  String? message,
  Duration duration = const Duration(seconds: 2),
}) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => ContactCopyPopup(
      message: message ?? 'Kopieret til udklipsholder',
    ),
  );

  overlay.insert(overlayEntry);

  // Auto-dismiss after duration
  Future.delayed(duration, () {
    overlayEntry.remove();
  });
}
