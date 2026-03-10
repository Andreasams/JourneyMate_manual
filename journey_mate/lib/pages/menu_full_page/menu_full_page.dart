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

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();
  }

  @override
  void dispose() {
    // Track page view with duration
    if (_pageStartTime != null) {
      final duration = DateTime.now().difference(_pageStartTime!);
      final analytics = AnalyticsService.instance;

      ApiService.instance
          .postAnalytics(
        eventType: 'page_viewed',
        deviceId: analytics.deviceId ?? '',
        sessionId: analytics.currentSessionId ?? '',
        userId: analytics.userId ?? '',
        timestamp: DateTime.now().toIso8601String(),
        eventData: {
          'pageName': 'menuFullPage',
          'durationSeconds': duration.inSeconds,
        },
      )
          .catchError((_) {
        // Fire-and-forget, ignore errors
        return ApiCallResponse.failure('Analytics failed');
      });
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
        AppSpacing.xxl,
        AppSpacing.md,
        AppSpacing.xxl,
        0,
      ),
      child: MenuSectionWidget(
        businessId: int.parse(widget.businessId),
        isFullPage: true,
        // NOTE: onItemTapped/onPackageTapped/onCategoryViewed are intentionally
        // NOT wired here — MenuDishesListView already tracks those analytics
        // internally via analyticsProvider. Wiring them would double-count.
        onFilterCountChanged: (count, hasFilters) => ref
            .read(analyticsProvider.notifier)
            .updateMenuSessionFilterMetrics(count, hasFilters),
      ),
    );
  }
}
