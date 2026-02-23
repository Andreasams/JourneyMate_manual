import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../providers/business_providers.dart';
import '../providers/settings_providers.dart';
import '../services/api_service.dart';
import '../services/analytics_service.dart';
import '../services/translation_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/shared/unified_filters_widget.dart';
import '../widgets/shared/menu_categories_rows.dart';
import '../widgets/shared/menu_dishes_list_view.dart';
import '../widgets/shared/item_bottom_sheet.dart';
import '../widgets/shared/package_bottom_sheet.dart';
import '../widgets/shared/category_description_sheet.dart';

/// Menu Full Page - Dedicated full-screen menu browsing experience
///
/// Provides focused menu exploration with dietary filtering, category navigation,
/// and item detail views. Extracted from Business Profile Menu tab into standalone
/// page with dedicated AppBar.
///
/// Route: /business/:id/menu
class MenuFullPage extends ConsumerStatefulWidget {
  final String businessId;

  const MenuFullPage({super.key, required this.businessId});

  @override
  ConsumerState<MenuFullPage> createState() => _MenuFullPageState();
}

class _MenuFullPageState extends ConsumerState<MenuFullPage> {
  // ============================================================================
  // LOCAL STATE (NOT providers)
  // ============================================================================

  /// Currently selected category ID (for bidirectional scroll sync)
  String? _selectedCategoryId;

  /// Currently selected menu ID (for bidirectional scroll sync)
  String? _selectedMenuId;

  /// Count of visible items after dietary filtering
  // ignore: unused_field
  int _visibleItemCount = 0;

  /// Page start time for analytics duration tracking
  DateTime? _pageStartTime;

  // ============================================================================
  // LIFECYCLE
  // ============================================================================

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();

    // Check data availability after first frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final menuItems = ref.read(businessProvider).menuItems;
      if (menuItems == null) {
        debugPrint('MenuFullPage: No menu data available');
      }
    });
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

  // ============================================================================
  // BUILD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final business = ref.watch(businessProvider).currentBusiness;
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
          style: AppTypography.categoryHeading,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  // ============================================================================
  // BODY LAYOUT
  // ============================================================================

  /// Build body with 3-widget stack: Filters → Category chips → Menu list
  ///
  /// Pattern copied from Business Profile Menu tab (lines 511-669)
  Widget _buildBody() {
    final menuItems = ref.watch(businessProvider).menuItems;
    final business = ref.watch(businessProvider).currentBusiness;

    // Loading state
    if (menuItems == null) {
      return Center(
        child: Text(
          td(ref, 'menu_loading'),
          style: AppTypography.bodyRegular.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    // Data available - build 3-widget stack
    return Column(
      children: [
        // Widget 1: Unified Filters (Dietary filtering)
        UnifiedFiltersWidget(
          businessId: int.parse(widget.businessId),
          height: 350.0, // Standard height (not adaptive)
          onFiltersChanged: () async {
            // Filters updated - menu will auto-rebuild via provider watch
            debugPrint('Dietary filters changed');
          },
          onVisibleItemCountChanged: (int count) async {
            setState(() => _visibleItemCount = count);

            // Update menu session analytics with 2 positional parameters
            ref
                .read(analyticsProvider.notifier)
                .updateMenuSessionFilterMetrics(count, _hasActiveFilters());
          },
        ),

        SizedBox(height: AppSpacing.md),

        // Widget 2: Category chips (Horizontal category navigation)
        SizedBox(
          height: 40.0, // Fixed height (single row)
          child: MenuCategoriesRows(
            businessID: int.parse(widget.businessId),
            apiResult: menuItems,
            onCategoryChanged: (int categoryId, int menuId) async {
              // User tapped category chip → update state → MenuDishesListView scrolls
              setState(() {
                _selectedCategoryId = categoryId.toString();
                _selectedMenuId = menuId.toString();
              });
            },
            onNumberOfRows: (int numberOfRows) async {
              debugPrint('Menu categories rows: $numberOfRows');
            },
            visibleSelection: _selectedCategoryId != null &&
                    _selectedMenuId != null
                ? {
                    'categoryId': int.tryParse(_selectedCategoryId!) ?? 0,
                    'menuId': int.tryParse(_selectedMenuId!) ?? 0,
                  }
                : null,
          ),
        ),

        SizedBox(height: AppSpacing.md),

        // Widget 3: Menu list (takes remaining space)
        Expanded(
          child: _buildMenuDishesListView(menuItems, business),
        ),
      ],
    );
  }

  // ============================================================================
  // MENU DISHES LIST VIEW WITH CALLBACKS
  // ============================================================================

  /// Build MenuDishesListView with all 5 callbacks wired
  ///
  /// Callbacks:
  /// 1. onItemTap → ItemBottomSheet
  /// 2. onPackageTap → PackageBottomSheet
  /// 3. onVisibleCategoryChanged → Update highlighted category chip (with loop prevention!)
  /// 4. onCategoryDescriptionTap → CategoryDescriptionSheet
  /// 5. (No 5th callback - that's onFiltersChanged in UnifiedFiltersWidget above)
  Widget _buildMenuDishesListView(dynamic menuItems, dynamic business) {
    return MenuDishesListView(
      originalCurrencyCode: business?['price_range_currency_code'] ?? 'DKK',
      isDynamicHeight: false, // Full-page view uses fixed layout
      // Callback 1: Item tap → Item detail bottom sheet
      onItemTap: (itemData, isBeverage, dietaryIds, allergyIds,
          formattedPrice, hasVariations, variationPrice) async {
        if (!mounted) return;

        final localization = ref.read(localizationProvider);
        final translationsCache = ref.read(translationsCacheProvider);
        final currentLanguage = Localizations.localeOf(context).languageCode;

        await showModalBottomSheet(
          context: context,
          isScrollControlled: true, // Required for DraggableScrollableSheet
          backgroundColor: Colors.transparent, // Let sheet define background
          builder: (context) => ItemBottomSheet(
            itemData: itemData,
            chosenCurrency: localization.currencyCode,
            originalCurrencyCode:
                business?['price_range_currency_code'] ?? 'DKK',
            exchangeRate: localization.exchangeRate,
            currentLanguage: currentLanguage,
            businessName: business?['business_name'] ?? '',
            translationsCache: translationsCache,
            hasVariations: hasVariations,
          ),
        );

        // Track item click
        ref.read(analyticsProvider.notifier).incrementItemClick();
      },
      // Callback 2: Package tap → Package detail bottom sheet
      onPackageTap: (packageData) async {
        if (!mounted) return;

        final localization = ref.read(localizationProvider);

        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => PackageBottomSheet(
            normalizedMenuData: menuItems,
            packageId: packageData['package_id'] ?? 0,
            chosenCurrency: localization.currencyCode,
            originalCurrencyCode:
                business?['price_range_currency_code'] ?? 'DKK',
            exchangeRate: localization.exchangeRate,
            businessName: business?['business_name'] ?? '',
          ),
        );

        // Track package click
        ref.read(analyticsProvider.notifier).incrementPackageClick();
      },
      // Callback 3: Visible category changed (with loop prevention!)
      onVisibleCategoryChanged: (selectionData) async {
        // User scrolled → category became visible
        final categoryId = selectionData['categoryId']?.toString();
        final menuId = selectionData['menuId']?.toString();

        // ✅ CRITICAL: Only update if different (prevents infinite loop)
        // Pattern from Business Profile lines 637-643
        if (categoryId != _selectedCategoryId || menuId != _selectedMenuId) {
          setState(() {
            _selectedCategoryId = categoryId;
            _selectedMenuId = menuId;
          });
        }

        // Track category viewed
        if (categoryId != null) {
          ref
              .read(analyticsProvider.notifier)
              .recordCategoryViewed(int.tryParse(categoryId) ?? 0);
        }
      },
      // Callback 4: Category description tap → Category info bottom sheet
      onCategoryDescriptionTap: (categoryData) async {
        if (!mounted) return;

        await showModalBottomSheet(
          context: context,
          builder: (context) => CategoryDescriptionSheet(
            categoryName: categoryData['name'] ?? '',
            categoryDescription: categoryData['description'] ?? '',
            scrollController: ScrollController(),
          ),
        );
      },
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Check if any dietary filters are currently active
  ///
  /// Used for analytics tracking: updateMenuSessionFilterMetrics(count, hasActiveFilters)
  bool _hasActiveFilters() {
    final businessState = ref.read(businessProvider);
    return businessState.selectedDietaryPreferenceId != null ||
        businessState.selectedDietaryRestrictionIds.isNotEmpty ||
        businessState.excludedAllergyIds.isNotEmpty;
  }
}
