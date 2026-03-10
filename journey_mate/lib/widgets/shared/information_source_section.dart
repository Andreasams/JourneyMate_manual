import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// An expandable accordion section for displaying information source disclaimers.
///
/// Used by both ItemBottomSheet and PackageBottomSheet to show the
/// "Information source" section with business disclaimer and JourneyMate text.
class InformationSourceSection extends StatefulWidget {
  const InformationSourceSection({
    super.key,
    required this.headerText,
    required this.disclaimerText,
    required this.journeymateText,
  });

  final String headerText;
  final String disclaimerText;
  final String journeymateText;

  @override
  State<InformationSourceSection> createState() =>
      _InformationSourceSectionState();
}

class _InformationSourceSectionState extends State<InformationSourceSection> {
  /// =========================================================================
  /// STATE & CONSTANTS
  /// =========================================================================

  bool _isExpanded = false;

  /// Animation constants
  static const Duration _expandDuration = Duration(milliseconds: 100);
  static const Curve _expandCurve = Curves.linear;

  /// Spacing constants
  static const double _expandedContentTopSpacing = AppSpacing.sm;
  static const double _disclaimerToJourneymateSpacing = AppSpacing.sm;

  /// Icon size
  static const double _iconSize = 24.0;

  /// =========================================================================
  /// USER INTERACTION HANDLERS
  /// =========================================================================

  /// Toggles the expanded state
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  /// =========================================================================
  /// UI BUILDERS
  /// =========================================================================

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderRow(),
        _buildExpandableContent(),
      ],
    );
  }

  /// Builds the header row with tap handler
  Widget _buildHeaderRow() {
    return InkWell(
      onTap: _toggleExpanded,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHeaderText(),
          _buildExpandIcon(),
        ],
      ),
    );
  }

  /// Builds the header text
  Widget _buildHeaderText() {
    return Text(
      widget.headerText,
      style: AppTypography.h6.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }

  /// Builds the expand/collapse icon
  Widget _buildExpandIcon() {
    return Icon(
      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
      color: AppColors.textSecondary,
      size: _iconSize,
    );
  }

  /// Builds the expandable content with animation
  Widget _buildExpandableContent() {
    return ClipRect(
      child: AnimatedAlign(
        duration: _expandDuration,
        curve: _expandCurve,
        heightFactor: _isExpanded ? 1.0 : 0.0,
        alignment: Alignment.topCenter,
        child: _buildExpandedContent(),
      ),
    );
  }

  /// Builds the expanded content
  Widget _buildExpandedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: _expandedContentTopSpacing),
        _buildDisclaimerText(),
        const SizedBox(height: _disclaimerToJourneymateSpacing),
        _buildJourneymateText(),
      ],
    );
  }

  /// Builds the disclaimer text
  Widget _buildDisclaimerText() {
    return Text(
      widget.disclaimerText,
      style: AppTypography.body.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }

  /// Builds the Journeymate text
  Widget _buildJourneymateText() {
    return Text(
      widget.journeymateText,
      style: AppTypography.body.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }
}
