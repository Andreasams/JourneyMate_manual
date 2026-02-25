import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import '../../providers/business_providers.dart';
import '../../services/translation_service.dart';
import '../../services/analytics_service.dart';
import '../../services/api_service.dart';

/// Match Card Widget - Shows filter match percentage with conditional styling
///
/// Features:
/// - Green background/border for 100% match
/// - Orange background/border for partial match
/// - Shows matched filters with green check icon
/// - Shows missed filters with red X icon
/// - Tap opens FilterDescriptionSheet modal with detailed descriptions
/// - Self-contained (reads from businessProvider internally)
///
/// Design:
/// - borderRadius: 16px (AppRadius.card)
/// - padding: 16px (AppSpacing.lg)
/// - Full match: greenBg background, greenBorder border, green text
/// - Partial match: orangeBg background, orangeBorder border, accent text
class MatchCardWidget extends ConsumerWidget {
  const MatchCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessState = ref.watch(businessProvider);
    final filterDescriptions = businessState.filterDescriptions;

    // Hide if no filter descriptions available
    if (filterDescriptions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Split filters into matched and missed
    final matchedFilters = <Map<String, dynamic>>[];
    final missedFilters = <Map<String, dynamic>>[];

    for (final filter in filterDescriptions) {
      if (filter is Map<String, dynamic>) {
        final isMatched = filter['matched'] == true;
        if (isMatched) {
          matchedFilters.add(filter);
        } else {
          missedFilters.add(filter);
        }
      }
    }

    // Calculate counts
    final matchedCount = matchedFilters.length;
    final totalCount = filterDescriptions.length;

    // Determine if full match (all filters matched)
    final isFullMatch = matchedCount == totalCount && totalCount > 0;

    // Conditional styling
    final backgroundColor = isFullMatch ? AppColors.greenBg : AppColors.orangeBg;
    final borderColor = isFullMatch ? AppColors.greenBorder : AppColors.orangeBorder;
    final primaryColor = isFullMatch ? AppColors.green : AppColors.accent;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: GestureDetector(
        onTap: () => _handleTap(context, ref),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Match count
              Text(
                td(ref, 'match_card_matches')
                    .replaceAll('{count}', matchedCount.toString())
                    .replaceAll('{total}', totalCount.toString()),
                style: AppTypography.sectionHeading.copyWith(
                  color: primaryColor,
                ),
              ),
              SizedBox(height: AppSpacing.sm),

              // Matched filters (green check)
              if (matchedFilters.isNotEmpty) ...[
                ...matchedFilters.map(
                  (filter) => Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.green,
                          size: 16,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            filter['filter_name'] ?? '',
                            style: AppTypography.bodyRegular.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Missed filters (red X)
              if (missedFilters.isNotEmpty) ...[
                if (matchedFilters.isNotEmpty) SizedBox(height: AppSpacing.xs),
                ...missedFilters.map(
                  (filter) => Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.cancel,
                          color: AppColors.red,
                          size: 16,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            filter['filter_name'] ?? '',
                            style: AppTypography.bodyRegular.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

                    ],
          ),
        ),
      ),
    );
  }

  /// Handle tap - track analytics (modal functionality to be added later)
  Future<void> _handleTap(BuildContext context, WidgetRef ref) async {
    // Track analytics
    final analytics = AnalyticsService.instance;
    ApiService.instance
        .postAnalytics(
      eventType: 'match_card_tapped',
      deviceId: analytics.deviceId ?? '',
      sessionId: analytics.currentSessionId ?? '',
      userId: analytics.userId ?? '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'pageName': 'businessProfile',
      },
    )
        .catchError((e) {
      debugPrint('Analytics error: $e');
      return ApiCallResponse.failure('Analytics failed');
    });

    // TODO: Open detailed filter descriptions modal
    // For now, the card shows all filters inline, so tap does nothing
  }
}
