import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../providers/business_providers.dart';
import '../../services/analytics_service.dart';
import '../../services/api_service.dart';
import '../../services/translation_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/shared/menu_section_widget.dart';
import '../../widgets/shared/section_card.dart';

/// Menu Full Page - Dedicated full-screen menu browsing experience
///
/// Thin wrapper around [MenuSectionWidget] that adds Scaffold, AppBar,
/// analytics lifecycle (page view duration), and loading/error states.
///
/// Route: /business/:id/menu
class MenuFullPage extends ConsumerStatefulWidget {
  final String businessId;

  const MenuFullPage({super.key, required this.businessId});

  @override
  ConsumerState<MenuFullPage> createState() => _MenuFullPageState();
}

class _MenuFullPageState extends ConsumerState<MenuFullPage> {
  /// Page start time for analytics duration tracking
  DateTime? _pageStartTime;
  bool _menuSessionStarted = false;

  // Cached for safe use in dispose() — ref is invalid after unmount
  String _cachedDeviceId = '';
  String _cachedSessionId = '';

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();

    // Cache analytics state for safe use in dispose()
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final analyticsState = ref.read(analyticsProvider);

      // Guard: skip if session not initialized
      final sessionId = analyticsState.sessionId;
      if (sessionId == null || sessionId.isEmpty) {
        debugPrint('WARNING: MenuFullPage — sessionId not initialized');
        return;
      }

      _cachedDeviceId = analyticsState.deviceId;
      _cachedSessionId = sessionId;

      // Initialize menu session with fresh counters
      ref.read(analyticsProvider.notifier).startMenuSession();

      _trackMenuSessionStart();
    });
  }

  void _trackMenuSessionStart() {
    final businessIdInt = int.tryParse(widget.businessId);
    if (businessIdInt == null) return;
    _menuSessionStarted = true;
    final analyticsState = ref.read(analyticsProvider);

    // Guard: skip if session not initialized
    final sessionId = analyticsState.sessionId;
    if (sessionId == null || sessionId.isEmpty) {
      debugPrint('WARNING: menu_session_started skipped — sessionId not initialized');
      return;
    }
    final deviceId = analyticsState.deviceId;
    if (deviceId.isEmpty) {
      debugPrint('WARNING: menu_session_started skipped — deviceId not initialized');
      return;
    }

    ApiService.instance.postAnalytics(
      eventType: 'menu_session_started',
      deviceId: deviceId,
      sessionId: sessionId,
      userId: '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'business_id': businessIdInt,
        'menu_context': 'full_page',
        'menu_session_id': analyticsState.menuSessionData?.menuSessionId ?? '',
      },
    );
  }

  void _trackMenuFilterImpact(int count, bool hasFilters, int itemsTotal, int itemsVisible, int categoriesEmpty) {
    final businessIdInt = int.tryParse(widget.businessId);
    if (businessIdInt == null) return;

    final analyticsState = ref.read(analyticsProvider);
    final menuData = analyticsState.menuSessionData;
    if (menuData == null) return;

    // Compute filter effectiveness
    final filterEffectivenessPercent = itemsTotal > 0
        ? (((itemsTotal - itemsVisible) / itemsTotal) * 100).round()
        : 0;

    ApiService.instance.postAnalytics(
      eventType: 'menu_filter_impact',
      deviceId: _cachedDeviceId,
      sessionId: _cachedSessionId,
      userId: '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'menu_session_id': menuData.menuSessionId,
        'menu_context': 'full_page',
        'business_id': businessIdInt,
        'items_total': itemsTotal,
        'items_visible': itemsVisible,
        'categories_completely_empty': categoriesEmpty,
        'filter_effectiveness_percent': filterEffectivenessPercent,
        'filters_active': hasFilters,
      },
    );
  }

  @override
  void dispose() {
    if (_pageStartTime != null) {
      final duration = DateTime.now().difference(_pageStartTime!);
      final businessIdInt = int.tryParse(widget.businessId);

      // Track page view with duration
      final analytics = AnalyticsService.instance;
      ApiService.instance.postAnalytics(
        eventType: 'page_viewed',
        deviceId: analytics.deviceId ?? '',
        sessionId: analytics.currentSessionId ?? '',
        userId: analytics.userId ?? '',
        timestamp: DateTime.now().toIso8601String(),
        eventData: {
          'pageName': 'menuFullPage',
          'durationSeconds': duration.inSeconds,
          'businessId': businessIdInt,
        },
      )
          .catchError((_) {
        // Fire-and-forget, ignore errors
        return ApiCallResponse.failure('Analytics failed');
      });

      // Track menu session end with full engagement data
      if (_menuSessionStarted && businessIdInt != null) {
        final menuData = ref.read(analyticsProvider).menuSessionData;
        if (menuData != null) {
          // Compute derived metrics
          final totalInteractions = menuData.itemClicks +
                                   menuData.packageClicks +
                                   menuData.filterInteractions;
          final avgResultCount = menuData.filterResultHistory.isEmpty
              ? 0
              : (menuData.filterResultHistory.reduce((a, b) => a + b) /
                 menuData.filterResultHistory.length).round();
          // Check if any dietary filters are active
          final businessState = ref.read(businessProvider);
          final filtersActiveAtEnd =
              businessState.selectedDietaryRestrictionIds.isNotEmpty ||
              businessState.selectedDietaryPreferenceId != null ||
              businessState.excludedAllergyIds.isNotEmpty;

          // Filter engagement score (ground truth formula from FlutterFlow end_menu_session.dart)
          // +10 per interaction, -15 per reset, -5 per zero-result, clamped 0-100
          final filterEngagementScore = menuData.filterInteractions == 0
              ? 0
              : ((menuData.filterInteractions * 10) -
                 (menuData.filterResets * 15) -
                 (menuData.zeroResultCount * 5))
                .clamp(0, 100);

          ApiService.instance.postAnalytics(
            eventType: 'menu_session_ended',
            deviceId: _cachedDeviceId,
            sessionId: _cachedSessionId,
            userId: '',
            timestamp: DateTime.now().toIso8601String(),
            eventData: {
              'menu_session_id': menuData.menuSessionId,
              'menu_context': 'full_page',
              'business_id': businessIdInt,
              'session_duration_seconds': duration.inSeconds,
              'items_clicked': menuData.itemClicks,
              'packages_clicked': menuData.packageClicks,
              'categories_viewed': menuData.categoriesViewed.length,
              'deepest_scroll_percent': menuData.deepestScrollPercent,
              'filter_interactions': menuData.filterInteractions,
              'filter_resets': menuData.filterResets,
              'ever_had_filters_active': menuData.everHadFiltersActive,
              'filters_active_at_end': filtersActiveAtEnd,
              'zero_result_count': menuData.zeroResultCount,
              'low_result_count': menuData.lowResultCount,
              'avg_result_count': avgResultCount,
              'total_interactions': totalInteractions,
              'filter_engagement_score': filterEngagementScore,
            },
          );

          // Clear menu session state to prevent bleed into next visit
          ref.read(analyticsProvider.notifier).clearMenuSession();
        }
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final businessState = ref.watch(businessProvider);
    final business = businessState.currentBusiness;
    final businessName = business?['business_name'] ?? 'Menu';

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          businessName,
          style: AppTypography.h5,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildBody(businessState.menuItems, business),
      ),
    );
  }

  Widget _buildBody(dynamic menuItems, dynamic business) {
    // Loading / error state
    if (menuItems == null) {
      // Business loaded but menu missing — fetch failed, don't spin forever
      if (business != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                td(ref, 'menu_load_error'),
                style: AppTypography.bodyLg,
              ),
              SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Text(
                  td(ref, 'back'),
                  style: AppTypography.bodyLgMedium.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      // Business also not loaded yet — genuinely still loading
      return Center(
        child: Text(
          td(ref, 'menu_loading'),
          style: AppTypography.bodyLg.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    // Data available — render shared menu section
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        0,
      ),
      child: Column(
        children: [
          Expanded(
            child: SectionCard(
              child: MenuSectionWidget(
                businessId: int.parse(widget.businessId),
                isFullPage: true,
                // NOTE: onItemTapped/onPackageTapped/onCategoryViewed are intentionally
                // NOT wired here — MenuDishesListView already tracks those analytics
                // internally via analyticsProvider. Wiring them would double-count.
                onFilterCountChanged: (count, hasFilters, itemsTotal, itemsVisible, categoriesEmpty) {
                  ref.read(analyticsProvider.notifier)
                      .updateMenuSessionFilterMetrics(count, hasFilters);
                  _trackMenuFilterImpact(count, hasFilters, itemsTotal, itemsVisible, categoriesEmpty);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
