import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
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
/// Design Updates (Phase 2):
/// - borderRadius: 12px (not AppRadius.card which is 16px)
/// - border width: 1.5px (not 1px)
/// - Header padding: 14px horizontal, 12px vertical
/// - Icon before text: 16px (check_circle for full match, info_outline for partial)
/// - Chevron: 24px
/// - Expanded content: Wrap with chips (not Column with rows)
/// - Chip gap: 5px horizontal and vertical
/// - Chip padding: 3px vertical, 8px horizontal
/// - Chip font: 11px, w600
/// - Chip icons: 16px
/// - Matched chip: green text/icons, #d0ecd8 border
/// - Missed chip: red text/icons, #f5d5d2 border
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
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Icon + Match count + Chevron
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          size: 16,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            td(ref, 'match_card_matches')
                                .replaceAll('{count}', matchedCount.toString())
                                .replaceAll('{total}', totalCount.toString()),
                            style: AppTypography.sectionHeading.copyWith(
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Animated chevron icon
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0, // 0.5 turns = 180 degrees
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Expanded content: filter chips in Wrap
            if (_isExpanded) ...[
              Padding(
                padding: const EdgeInsets.only(left: 14, right: 14, bottom: 14),
                child: Wrap(
                  spacing: 5,  // 5px horizontal gap between chips
                  runSpacing: 5,  // 5px vertical gap between rows
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.greenBorder,  // #d0ecd8
          width: 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.green,
          ),
          const SizedBox(width: 4),
          Text(
            filter['name'] ?? '',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFF5D5D2),  // Light red border
          width: 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.close,  // X icon
            size: 16,
            color: AppColors.red,
          ),
          const SizedBox(width: 4),
          Text(
            filter['name'] ?? '',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
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
