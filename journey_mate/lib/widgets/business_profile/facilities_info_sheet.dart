import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import '../../services/translation_service.dart';
import '../../services/analytics_service.dart';
import '../../services/api_service.dart';

/// Facilities Info Sheet - Bottom sheet displaying facility description
///
/// Features:
/// - DraggableScrollableSheet for smooth slide-up animation
/// - Shows facility name + detailed description
/// - Close button at top right
/// - Self-contained (no props beyond facility data)
///
/// Design:
/// - borderRadius: 22px top corners (AppRadius.bottomSheet)
/// - padding: 24px (AppSpacing.xxl)
/// - Close button: 32px circle, gray background
/// - Typography: sectionHeading for title, bodyRegular for description
/// - Matches JSX lines 576-582 in business_profile.jsx
class FacilitiesInfoSheet extends ConsumerStatefulWidget {
  const FacilitiesInfoSheet({
    super.key,
    required this.filterName,
    this.filterDescription,
  });

  final String filterName;
  final String? filterDescription;

  @override
  ConsumerState<FacilitiesInfoSheet> createState() =>
      _FacilitiesInfoSheetState();
}

class _FacilitiesInfoSheetState extends ConsumerState<FacilitiesInfoSheet> {
  @override
  void initState() {
    super.initState();
    _trackSheetOpened();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.bottomSheet),
            ),
          ),
          child: Column(
            children: [
              // Header with close button
              Padding(
                padding: EdgeInsets.all(AppSpacing.xxl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Facility name
                    Expanded(
                      child: Text(
                        widget.filterName,
                        style: AppTypography.sectionHeading,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    // Close button
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable description content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.filterDescription != null &&
                          widget.filterDescription!.isNotEmpty)
                        Text(
                          widget.filterDescription!,
                          style: AppTypography.bodyRegular.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        )
                      else
                        Text(
                          td(ref, 'no_description_available'),
                          style: AppTypography.bodyRegular.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Track analytics for sheet opened
  void _trackSheetOpened() {
    final analytics = AnalyticsService.instance;
    ApiService.instance
        .postAnalytics(
      eventType: 'facility_info_opened',
      deviceId: analytics.deviceId ?? '',
      sessionId: analytics.currentSessionId ?? '',
      userId: analytics.userId ?? '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'pageName': 'businessProfile',
        'facilityName': widget.filterName,
        'hasDescription': widget.filterDescription != null &&
            widget.filterDescription!.isNotEmpty,
      },
    )
        .catchError((e) {
      debugPrint('Analytics error: $e');
      return ApiCallResponse.failure('Analytics failed');
    });
  }
}
