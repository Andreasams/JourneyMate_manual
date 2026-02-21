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

/// A widget that displays text which can be expanded from a collapsed state
/// with a maximum number of lines.
class ExpandableTextWidget extends StatefulWidget {
  const ExpandableTextWidget({
    super.key,
    this.width,
    this.height,
    required this.text,
    required this.languageCode,
    required this.translationsCache,
    this.businessId,
  });

  final double? width;
  final double? height;
  final String text;
  final String languageCode;
  final dynamic translationsCache;
  final int? businessId;

  @override
  State<ExpandableTextWidget> createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
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

  static const TextStyle _textStyle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: _baseFontSize,
    fontWeight: FontWeight.w300,
    color: Colors.black,
    height: _lineHeightMultiplier,
  );

  static const TextStyle _buttonTextStyle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  bool _isExpanded = false;
  bool _isOverflown = false;

  @override
  void initState() {
    super.initState();
    _determineIfTextOverflows();
  }

  @override
  void didUpdateWidget(ExpandableTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.translationsCache != oldWidget.translationsCache ||
        widget.languageCode != oldWidget.languageCode) {
      setState(() {});
    }
  }

  void _determineIfTextOverflows() {
    final estimatedMaxCharacters =
        _maxLinesWhenCollapsed * _charsPerLineEstimate;
    if (widget.text.length > estimatedMaxCharacters) {
      _isOverflown = true;
    }
  }

  String _getUIText(String key) {
    return getTranslations(widget.languageCode, key, widget.translationsCache);
  }

  String _getShowMoreText() => _getUIText('expandable_show_more');
  String _getShowLessText() => _getUIText('expandable_show_less');

  double _calculateSingleLineHeight() => _baseFontSize * _lineHeightMultiplier;
  double _calculateCollapsedTextHeight() =>
      _calculateSingleLineHeight() * _maxLinesWhenCollapsed;
  double _calculateGradientOverlayHeight() =>
      _calculateSingleLineHeight() * _gradientHeightMultiplier;

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
              backgroundColor.withOpacity(_gradientStartOpacity),
              backgroundColor.withOpacity(_gradientMidOpacity),
              backgroundColor.withOpacity(_gradientEndOpacity),
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
              const Icon(Icons.keyboard_arrow_up,
                  color: Colors.black, size: _arrowIconSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedView() {
    final backgroundColor = FlutterFlowTheme.of(context).primaryBackground;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _calculateCollapsedTextHeight(),
          child: Stack(
            children: [
              Text(widget.text,
                  maxLines: _maxLinesWhenCollapsed,
                  overflow: TextOverflow.clip,
                  style: _textStyle),
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

  void _expandText() {
    markUserEngaged();
    _trackTextInteraction('expand');
    setState(() => _isExpanded = true);
  }

  void _collapseText() {
    markUserEngaged();
    _trackTextInteraction('collapse');
    setState(() => _isExpanded = false);
  }

  void _trackTextInteraction(String action) {
    trackAnalyticsEvent(
      'expandable_text_toggled',
      {
        'action': action,
        'text_id': 'description', // Identifies which text section
        'business_id': widget.businessId, // Track which business
        'language': widget.languageCode,
      },
    ).catchError((error) {
      debugPrint('⚠️ Failed to track text interaction: $error');
    });
  }

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
