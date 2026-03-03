import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_icon_sizes.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../providers/business_providers.dart';
import '../../providers/search_providers.dart';
import '../../providers/filter_providers.dart';
import '../../services/translation_service.dart';
import '../../services/analytics_service.dart';
import '../../services/api_service.dart';

/// Match Card Widget V2 - Shows filter match with collapsible UI
///
/// NEW ARCHITECTURE (Phase 2):
/// - Reads business.filters from businessProvider (what business HAS)
/// - Reads filtersUsedForSearch from searchStateProvider (what user SEARCHED)
/// - Computes matches/misses by comparing filter IDs
/// - Uses filterProvider lookup for missed filter names
/// - NO separate API call needed
///
/// Features:
/// - Collapsible: tap to expand/collapse filter list
/// - Default state: collapsed (header + chevron only)
/// - Green background/border for 100% match
/// - Orange background/border for partial match
/// - Shows matched filters with green check chip (when expanded)
/// - Shows missed filters with red X chip (when expanded)
/// - Chevron rotates 180° with smooth animation
/// - Self-contained (reads from providers internally)
///
/// Design (matches JSX lines 190-234):
/// - borderRadius: AppRadius.input (12px)
/// - border width: 1.5px
/// - Header padding: AppSpacing.mlg horizontal, AppSpacing.md vertical
/// - Header icon: AppIconSize.md (16px), check_circle / info_outline
/// - Header text: AppTypography.viewToggle w600, AppColors.textPrimary
/// - Chevron: AppIconSize.sm (12px), AppColors.textMuted
/// - Expanded: Wrap with AppSpacing.xs gap
/// - Chip padding: AppSpacing.xs vertical, AppSpacing.sm horizontal
/// - Chip borderRadius: AppRadius.chip (8px)
/// - Chip font: AppTypography.chip (12.5px, matched w600, missed w500)
/// - Chip icons: AppIconSize.xs (8px), gap AppSpacing.xs
/// - Matched chip: green text/icons, AppColors.greenBorder
/// - Missed chip: red text/icons, AppColors.redBorder
class MatchCardWidget extends ConsumerStatefulWidget {
  const MatchCardWidget({super.key});

  @override
  ConsumerState<MatchCardWidget> createState() => _MatchCardWidgetState();
}

class _MatchCardWidgetState extends ConsumerState<MatchCardWidget> {
  // Collapse state: false = collapsed (default), true = expanded
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final businessState = ref.watch(businessProvider);
    final searchState = ref.watch(searchStateProvider);
    final filterState = ref.watch(filterProvider);

    // Hide if no search filters active
    final filtersUsedForSearch = searchState.filtersUsedForSearch;
    if (filtersUsedForSearch.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get business data
    final business = businessState.currentBusiness;
    if (business == null) return const SizedBox.shrink();

    // Get business filters from API response
    final businessFilters = business['filters'] as List<dynamic>?;
    if (businessFilters == null || businessFilters.isEmpty) {
      // Business has no filters - all search filters are misses
      // Still show the card if user has search filters active
      return _buildCard(
        matchedCount: 0,
        totalCount: filtersUsedForSearch.length,
        matchedFilters: [],
        missedFilters: _buildMissedFiltersFromIds(
          filtersUsedForSearch,
          filterState,
        ),
      );
    }

    // Compute matched and missed filters
    final matched = <Map<String, dynamic>>[];
    final missed = <Map<String, dynamic>>[];

    for (final searchFilterId in filtersUsedForSearch) {
      // Check if business has this filter
      final businessFilter = businessFilters.firstWhere(
        (bf) => bf is Map && bf['filter_id'] == searchFilterId,
        orElse: () => null,
      );

      if (businessFilter != null && businessFilter is Map<String, dynamic>) {
        // Filter matched!
        matched.add({
          'filter_id': searchFilterId,
          'filter_name': businessFilter['filter_name_translated'] ??
              businessFilter['filter_name'] ??
              '',
        });
      } else {
        // Business doesn't have this filter - it's a miss
        // Look up name from global filters data
        final filterName = _getFilterNameById(searchFilterId, filterState);
        if (filterName != null) {
          missed.add({
            'filter_id': searchFilterId,
            'filter_name': filterName,
          });
        }
      }
    }

    final matchedCount = matched.length;
    final totalCount = filtersUsedForSearch.length;

    return _buildCard(
      matchedCount: matchedCount,
      totalCount: totalCount,
      matchedFilters: matched,
      missedFilters: missed,
    );
  }

  /// Build the card UI with computed data
  Widget _buildCard({
    required int matchedCount,
    required int totalCount,
    required List<Map<String, dynamic>> matchedFilters,
    required List<Map<String, dynamic>> missedFilters,
  }) {
    // Determine if full match (all filters matched)
    final isFullMatch = matchedCount == totalCount && totalCount > 0;

    // Conditional styling
    final backgroundColor = isFullMatch ? AppColors.greenBg : AppColors.orangeBg;
    final borderColor = isFullMatch ? AppColors.greenBorder : AppColors.orangeBorder;
    final primaryColor = isFullMatch ? AppColors.green : AppColors.accent;
    final icon = isFullMatch ? Icons.check_circle : Icons.info_outline;

    return GestureDetector(
      onTap: _toggleExpanded,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Icon + Match count + Chevron
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.mlg, vertical: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          size: AppIconSize.md,
                          color: primaryColor,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            td(ref, 'match_card_matches')
                                .replaceAll('{count}', matchedCount.toString())
                                .replaceAll('{total}', totalCount.toString()),
                            style: AppTypography.viewToggle.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Animated chevron icon
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textMuted,
                      size: AppIconSize.sm,
                    ),
                  ),
                ],
              ),
            ),

            // Expanded content: filter chips in Wrap
            if (_isExpanded) ...[
              Padding(
                padding: EdgeInsets.only(left: AppSpacing.mlg, right: AppSpacing.mlg, bottom: AppSpacing.mlg),
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    // Matched filter chips
                    ...matchedFilters.map((filter) => _buildMatchedChip(filter)),

                    // Missed filter chips
                    ...missedFilters.map((filter) => _buildMissedChip(filter)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build matched filter chip (green)
  Widget _buildMatchedChip(Map<String, dynamic> filter) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.greenBorder,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: AppIconSize.xs,
            color: AppColors.green,
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            filter['filter_name'] ?? '',
            style: AppTypography.chip.copyWith(
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }

  /// Build missed filter chip (red)
  Widget _buildMissedChip(Map<String, dynamic> filter) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.redBorder,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.close,
            size: AppIconSize.xs,
            color: AppColors.red,
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            filter['filter_name'] ?? '',
            style: AppTypography.chip.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.red,
            ),
          ),
        ],
      ),
    );
  }

  /// Toggle expanded/collapsed state and track analytics
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    // Calculate match counts for analytics
    final searchState = ref.read(searchStateProvider);
    final businessState = ref.read(businessProvider);

    final totalCount = searchState.filtersUsedForSearch.length;
    final businessFilters = businessState.currentBusiness?['filters'] as List<dynamic>?;

    int matchedCount = 0;
    if (businessFilters != null) {
      for (final searchFilterId in searchState.filtersUsedForSearch) {
        final hasMatch = businessFilters.any(
          (bf) => bf is Map && bf['filter_id'] == searchFilterId,
        );
        if (hasMatch) matchedCount++;
      }
    }

    final isFullMatch = matchedCount == totalCount && totalCount > 0;

    // Track analytics
    final analytics = AnalyticsService.instance;
    ApiService.instance
        .postAnalytics(
      eventType: _isExpanded ? 'match_card_expanded' : 'match_card_collapsed',
      deviceId: analytics.deviceId ?? '',
      sessionId: analytics.currentSessionId ?? '',
      userId: analytics.userId ?? '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'action': _isExpanded ? 'expanded' : 'collapsed',
        'matched_count': matchedCount,
        'total_count': totalCount,
        'is_full_match': isFullMatch,
      },
    )
        .catchError((e) {
      debugPrint('Analytics error: $e');
      return ApiCallResponse.failure('Analytics failed');
    });
  }

  /// Get filter name by ID from global filter metadata
  String? _getFilterNameById(int filterId, AsyncValue<dynamic> filterState) {
    return filterState.when(
      data: (data) {
        if (data == null) return null;
        final lookupMap = data.filterLookupMap as Map<int, dynamic>?;
        if (lookupMap == null) return null;

        final filterDef = lookupMap[filterId];
        if (filterDef == null) return null;

        // API returns 'name_translated' or fallback to 'name'
        return filterDef['name_translated'] ?? filterDef['name'];
      },
      loading: () => null,
      error: (e, _) => null,
    );
  }

  /// Build missed filter list when business has no filters at all
  List<Map<String, dynamic>> _buildMissedFiltersFromIds(
    List<int> filterIds,
    AsyncValue<dynamic> filterState,
  ) {
    final missed = <Map<String, dynamic>>[];

    for (final filterId in filterIds) {
      final filterName = _getFilterNameById(filterId, filterState);
      if (filterName != null) {
        missed.add({
          'filter_id': filterId,
          'filter_name': filterName,
        });
      }
    }

    return missed;
  }
}
