import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../services/analytics_service.dart';
import '../../services/api_service.dart';
import '../../services/translation_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// A widget that displays text which can be expanded from a collapsed state
/// with a maximum number of lines.
///
/// Features:
/// - Displays text collapsed to 4 lines with gradient overlay
/// - "Show more" button expands to full text
/// - "Show less" button collapses back
/// - Smooth animation between states
/// - Tracks analytics events on expand/collapse
class ExpandableTextWidget extends ConsumerStatefulWidget {
  const ExpandableTextWidget({
    super.key,
    required this.text,
    this.businessId,
    this.textId = 'description',
  });

  final String text;
  final int? businessId;
  final String textId;

  @override
  ConsumerState<ExpandableTextWidget> createState() =>
      _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends ConsumerState<ExpandableTextWidget> {
  // ========================================
  // CONSTANTS
  // ========================================

  static const int _maxLinesWhenCollapsed = 4;
  static const int _charsPerLineEstimate = 50;
  static const double _baseFontSize = 15.0;
  static const double _lineHeightMultiplier = 1.5;
  static const double _gradientHeightMultiplier = 1.2;
  static const double _buttonVerticalPadding = 12.0;
  static const double _buttonIconSpacing = 6.0;
  static const double _expandedButtonTopSpacing = 16.0;
  static const double _arrowIconSize = 20.0;
  static const double _gradientStartOpacity = 0.0;
  static const double _gradientMidOpacity = 0.8;
  static const double _gradientEndOpacity = 1.0;
  static const List<double> _gradientStops = [0.0, 0.5, 1.0];
  static const Duration _animationDuration = Duration(milliseconds: 300);

  static const TextStyle _textStyle = AppTypography.body;

  static final TextStyle _buttonTextStyle = AppTypography.bodyLgMedium.copyWith(
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  // ========================================
  // STATE VARIABLES
  // ========================================

  bool _isExpanded = false;
  bool _isOverflown = false;

  // ========================================
  // LIFECYCLE METHODS
  // ========================================

  @override
  void initState() {
    super.initState();
    _determineIfTextOverflows();
  }

  // ========================================
  // OVERFLOW DETECTION
  // ========================================

  void _determineIfTextOverflows() {
    final estimatedMaxCharacters =
        _maxLinesWhenCollapsed * _charsPerLineEstimate;
    if (widget.text.length > estimatedMaxCharacters) {
      _isOverflown = true;
    }
  }

  // ========================================
  // TRANSLATION HELPERS
  // ========================================

  String _getShowMoreText() => td(ref, 'expandable_show_more');
  String _getShowLessText() => td(ref, 'expandable_show_less');

  // ========================================
  // HEIGHT CALCULATIONS
  // ========================================

  double _calculateSingleLineHeight() => _baseFontSize * _lineHeightMultiplier;

  double _calculateCollapsedTextHeight() =>
      _calculateSingleLineHeight() * _maxLinesWhenCollapsed;

  double _calculateGradientOverlayHeight() =>
      _calculateSingleLineHeight() * _gradientHeightMultiplier;

  // ========================================
  // UI BUILDERS
  // ========================================

  Widget _buildGradientOverlay(Color backgroundColor) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: _calculateGradientOverlayHeight(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: _gradientStops,
            colors: [
              backgroundColor.withValues(alpha: _gradientStartOpacity),
              backgroundColor.withValues(alpha: _gradientMidOpacity),
              backgroundColor.withValues(alpha: _gradientEndOpacity),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShowMoreButton(Color backgroundColor) {
    return GestureDetector(
      onTap: _expandText,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: _buttonVerticalPadding),
        child: Center(child: Text(_getShowMoreText(), style: _buttonTextStyle)),
      ),
    );
  }

  Widget _buildShowLessButton() {
    return GestureDetector(
      onTap: _collapseText,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: _buttonVerticalPadding),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_getShowLessText(), style: _buttonTextStyle),
              const SizedBox(width: _buttonIconSpacing),
              Icon(
                Icons.keyboard_arrow_up,
                color: AppColors.textPrimary,
                size: _arrowIconSize,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedView() {
    final backgroundColor = AppColors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _calculateCollapsedTextHeight(),
          child: Stack(
            children: [
              Text(
                widget.text,
                maxLines: _maxLinesWhenCollapsed,
                overflow: TextOverflow.clip,
                style: _textStyle,
              ),
              _buildGradientOverlay(backgroundColor),
            ],
          ),
        ),
        _buildShowMoreButton(backgroundColor),
      ],
    );
  }

  Widget _buildExpandedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.text, style: _textStyle),
        if (_isOverflown) ...[
          const SizedBox(height: _expandedButtonTopSpacing),
          _buildShowLessButton(),
        ],
      ],
    );
  }

  // ========================================
  // EVENT HANDLERS
  // ========================================

  void _expandText() {
    _trackTextInteraction('expand');
    setState(() => _isExpanded = true);
  }

  void _collapseText() {
    _trackTextInteraction('collapse');
    setState(() => _isExpanded = false);
  }

  void _trackTextInteraction(String action) {
    // Get language code from context
    final locale = Localizations.localeOf(context);
    final languageCode = locale.languageCode;

    // Get analytics data
    final analyticsState = ref.read(analyticsProvider);
    final deviceId = AnalyticsService.instance.deviceId ?? 'unknown';
    final sessionId = analyticsState.sessionId ?? 'unknown';
    final userId = AnalyticsService.instance.userId ?? 'unknown';

    // Track event (fire and forget)
    ApiService.instance.postAnalytics(
      eventType: 'expandable_text_toggled',
      deviceId: deviceId,
      sessionId: sessionId,
      userId: userId,
      eventData: {
        'action': action,
        'text_id': widget.textId,
        'business_id': widget.businessId, // Track which business
        'language': languageCode,
      },
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  // ========================================
  // BUILD METHOD
  // ========================================

  @override
  Widget build(BuildContext context) {
    if (!_isOverflown) return Text(widget.text, style: _textStyle);

    return AnimatedSize(
      duration: _animationDuration,
      curve: Curves.easeInOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [_isExpanded ? _buildExpandedView() : _buildCollapsedView()],
      ),
    );
  }
}
