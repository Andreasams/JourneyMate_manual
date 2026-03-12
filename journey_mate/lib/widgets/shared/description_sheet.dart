import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/custom_functions/contact_utils.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'bottom_sheet_header.dart';

/// DescriptionSheet — Shared bottom sheet for displaying title + body text.
///
/// Canonical JourneyMate bottom sheet pattern: swipe bar, 40px close button
/// top-right, self-sizing height based on content.
///
/// Replaces FacilitiesInfoSheet, CategoryDescriptionSheet, and
/// FilterDescriptionSheet with a single, design-system-aligned widget.
///
/// The sheet sizes itself to fit content, with a minimum height of 40% and
/// maximum of 80% of screen height. Scrolls automatically when content
/// exceeds the maximum.
///
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   backgroundColor: Colors.transparent,
///   builder: (context) => DescriptionSheet(
///     title: 'Appetizers',
///     description: 'Start your meal with...',
///   ),
/// );
/// ```
///
/// Design:
/// - Background: AppColors.bgCard
/// - Top corners: AppRadius.bottomSheet (20px)
/// - Swipe bar: 80×4px, centered, 8px top padding, AppColors.textPrimary
/// - Close button: 40×40px circle, top-right, 12px from edges
/// - Header height: 64px
/// - Content: 24px horizontal padding, sectionHeading title, bodyRegular body
/// - Fallback: italic text in textTertiary when description is null/empty
class DescriptionSheet extends StatefulWidget {
  const DescriptionSheet({
    super.key,
    required this.title,
    this.description,
    this.scrollController,
    this.fallbackDescription = 'No description available.',
    this.width,
  });

  /// Heading text displayed at the top of the sheet.
  final String title;

  /// Body text. When null or empty, [fallbackDescription] is shown instead.
  final String? description;

  /// Optional scroll controller (for external scroll coordination).
  final ScrollController? scrollController;

  /// Text shown when [description] is null or empty.
  final String? fallbackDescription;

  /// Optional width override for the sheet container.
  final double? width;

  @override
  State<DescriptionSheet> createState() => _DescriptionSheetState();
}

class _DescriptionSheetState extends State<DescriptionSheet> {
  static const double _contentHorizontalPadding = 24.0;
  static const double _minHeightFraction = 0.4;
  static const double _maxHeightFraction = 0.8;

  /// Combined regex matching URLs, emails, and international phone numbers.
  /// Phone pattern requires '+' prefix to avoid false positives on plain numbers.
  static final _linkPattern = RegExp(
    r'https?://\S+'
    r'|[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
    r'|\+\d[\d\s-]{6,}\d',
  );

  final List<TapGestureRecognizer> _recognizers = [];

  bool get _hasDescription =>
      widget.description != null && widget.description!.isNotEmpty;

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  /// Builds a Text.rich widget that auto-links URLs, emails, and phone numbers.
  Widget _buildLinkifiedText(String text) {
    // Dispose recognizers from any previous build.
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();

    final baseStyle = AppTypography.bodyLg.copyWith(
      color: AppColors.textSecondary,
    );
    final linkStyle = AppTypography.bodyLg.copyWith(
      color: AppColors.accent,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.accent,
    );

    final spans = <InlineSpan>[];
    var lastEnd = 0;

    for (final match in _linkPattern.allMatches(text)) {
      // Plain text before this match.
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }

      final matched = match.group(0)!;
      final recognizer = TapGestureRecognizer()
        ..onTap = () => _launchLink(matched);
      _recognizers.add(recognizer);

      spans.add(TextSpan(
        text: matched,
        style: linkStyle,
        recognizer: recognizer,
      ));

      lastEnd = match.end;
    }

    // Trailing plain text after the last match.
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: baseStyle,
      ));
    }

    return Text.rich(TextSpan(children: spans));
  }

  /// Launches the appropriate handler for a detected link.
  Future<void> _launchLink(String link) async {
    final Uri uri;
    if (link.contains('@') && !link.startsWith('http')) {
      uri = Uri(scheme: 'mailto', path: link);
    } else if (link.startsWith('+')) {
      uri = Uri(scheme: 'tel', path: formatPhoneForDial(link));
    } else {
      uri = Uri.parse(ensureHttpsUrl(link));
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: screenHeight * _minHeightFraction,
        maxHeight: screenHeight * _maxHeightFraction,
      ),
      child: Container(
        width: widget.width,
        decoration: BottomSheetHeader.sheetDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BottomSheetHeader(
              rightAction: BottomSheetAction(
                icon: Icons.close,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                controller: widget.scrollController,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: _contentHorizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppSpacing.md),
                    Text(
                      widget.title,
                      style: AppTypography.h4,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    if (_hasDescription)
                      _buildLinkifiedText(widget.description!)
                    else
                      Text(
                        widget.fallbackDescription ??
                            'No description available.',
                        style: AppTypography.bodyLg.copyWith(
                          color: AppColors.textTertiary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
