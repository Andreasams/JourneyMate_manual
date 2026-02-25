import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import '../../providers/app_providers.dart';
import '../../providers/business_providers.dart';
import '../../providers/settings_providers.dart';
import '../../services/translation_service.dart';
import '../../services/analytics_service.dart';
import '../../services/api_service.dart';
import '../shared/unified_filters_widget.dart';
import '../shared/item_bottom_sheet.dart';

/// Inline Menu Widget - Shows menu items with filter panel
///
/// Features:
/// - Filter panel container (background: AppColors.bgSurface, borderRadius: 14px)
/// - Shows active filter count + "Edit" button
/// - Edit button opens UnifiedFiltersWidget in modal
/// - Shows first 5 items by default
/// - Expand/collapse toggle for full list
/// - Tap opens ItemBottomSheet for item details
/// - Self-contained (reads from businessProvider internally)
/// - Shrink-wrapped and non-scrollable (part of main CustomScrollView)
///
/// Design:
/// - Filter panel: bgSurface background, 14px borderRadius
/// - Item spacing: 12px between items
/// - Section heading: AppTypography.sectionHeading
/// - 24px horizontal padding (AppSpacing.xxl)
/// - 16px vertical spacing (AppSpacing.lg)
class InlineMenuWidget extends ConsumerStatefulWidget {
  final int businessId;

  const InlineMenuWidget({
    super.key,
    required this.businessId,
  });

  @override
  ConsumerState<InlineMenuWidget> createState() => _InlineMenuWidgetState();
}

class _InlineMenuWidgetState extends ConsumerState<InlineMenuWidget> {
  bool _isExpanded = false;
  String? _selectedCategoryId; // null = "All" categories

  @override
  Widget build(BuildContext context) {
    final businessState = ref.watch(businessProvider);
    final menuItems = businessState.menuItems;
    final business = businessState.currentBusiness;

    // Hide if no menu items
    if (menuItems == null || menuItems.isEmpty) {
      return const SizedBox.shrink();
    }

    // Extract categories from menuCategories (from API)
    final menuCategoriesRaw = business?['menuCategories'] as List?;
    final categories = <Map<String, dynamic>>[];
    if (menuCategoriesRaw != null) {
      for (final cat in menuCategoriesRaw) {
        if (cat is Map<String, dynamic>) {
          categories.add({
            'category_id': cat['menu_category_id']?.toString() ?? '',
            'category_name': cat['category_name'] ?? '',
            'display_order': cat['category_display_order'] ?? 999,
          });
        }
      }
      // Sort by display_order
      categories.sort((a, b) =>
          (a['display_order'] as int).compareTo(b['display_order'] as int));
    }

    // Build flat list of all menu items with category_id
    final allItems = <Map<String, dynamic>>[];
    for (final menu in menuItems) {
      final categoriesData = menu['categories'] as List? ?? [];
      for (final category in categoriesData) {
        final categoryId = category['menu_category_id']?.toString();
        final items = category['items'] as List? ?? [];
        for (final item in items) {
          if (item is Map<String, dynamic>) {
            // Add category_id to item for filtering
            final itemWithCategory = Map<String, dynamic>.from(item);
            itemWithCategory['_category_id'] = categoryId;
            allItems.add(itemWithCategory);
          }
        }
      }
    }

    if (allItems.isEmpty) {
      return const SizedBox.shrink();
    }

    // Filter items by selected category
    final filteredItems = _selectedCategoryId == null
        ? allItems // "All" - show everything
        : allItems
            .where((item) => item['_category_id'] == _selectedCategoryId)
            .toList();

    // Show first 5 items, or all if expanded
    final displayedItems =
        _isExpanded ? filteredItems : filteredItems.take(5).toList();
    final hasMore = filteredItems.length > 5;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section heading
          Text(
            td(ref, 'menu_heading'),
            style: AppTypography.sectionHeading,
          ),
          SizedBox(height: AppSpacing.sm),

          // Category chips (if multiple categories exist)
          if (categories.length > 1) ...[
            _buildCategoryChips(categories),
            SizedBox(height: AppSpacing.md),
          ],

          // Filter panel (dietary filters)
          _buildFilterPanel(),
          SizedBox(height: AppSpacing.md),

          // Menu items list
          ...displayedItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                _buildMenuItem(item, business),
                if (index < displayedItems.length - 1)
                  SizedBox(height: AppSpacing.md),
              ],
            );
          }),

          // Expand/Collapse toggle (if more than 5 items)
          if (hasMore) ...[
            SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _handleToggleExpand,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.bgSurface,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                ),
                child: Text(
                  _isExpanded
                      ? td(ref, 'menu_show_less')
                      : td(ref, 'menu_show_all')
                          .replaceAll('{count}', filteredItems.length.toString()),
                  style: AppTypography.bodyRegular.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],

          // "View full menu" button
          SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _handleViewFullMenuTap,
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    td(ref, 'menu_view_full_page'),
                    style: AppTypography.bodyRegular.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.arrow_forward,
                    color: AppColors.accent,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build horizontal category chips
  Widget _buildCategoryChips(List<Map<String, dynamic>> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // "All" chip
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => _onCategoryTapped(null), // null = "All"
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _selectedCategoryId == null
                      ? AppColors.accent
                      : Colors.white,
                  border: Border.all(
                    color: _selectedCategoryId == null
                        ? AppColors.accent
                        : AppColors.border,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                child: Text(
                  td(ref, 'menu_category_all'),
                  style: AppTypography.bodySmall.copyWith(
                    color: _selectedCategoryId == null
                        ? Colors.white
                        : AppColors.textSecondary,
                    fontWeight: _selectedCategoryId == null
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),

          // Individual category chips
          ...categories.map((category) {
            final categoryId = category['category_id'] as String;
            final categoryName = category['category_name'] as String;
            final isSelected = _selectedCategoryId == categoryId;

            return Padding(
              padding: EdgeInsets.only(right: AppSpacing.sm),
              child: GestureDetector(
                onTap: () => _onCategoryTapped(categoryId),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent : Colors.white,
                    border: Border.all(
                      color:
                          isSelected ? AppColors.accent : AppColors.border,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                  child: Text(
                    categoryName,
                    style: AppTypography.bodySmall.copyWith(
                      color:
                          isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Build filter panel with active count and Edit button
  Widget _buildFilterPanel() {
    final businessState = ref.watch(businessProvider);
    final hasActiveFilters =
        businessState.selectedDietaryRestrictionIds.isNotEmpty ||
            businessState.selectedDietaryPreferenceId != null ||
            businessState.excludedAllergyIds.isNotEmpty;

    final activeCount = businessState.selectedDietaryRestrictionIds.length +
        (businessState.selectedDietaryPreferenceId != null ? 1 : 0) +
        businessState.excludedAllergyIds.length;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Row(
        children: [
          // Filter icon
          Icon(
            Icons.filter_list,
            color: hasActiveFilters ? AppColors.accent : AppColors.textTertiary,
            size: 20,
          ),
          SizedBox(width: AppSpacing.sm),

          // Filter status text
          Expanded(
            child: Text(
              hasActiveFilters
                  ? td(ref, 'menu_filters_active')
                      .replaceAll('{count}', activeCount.toString())
                  : td(ref, 'menu_filters_none'),
              style: AppTypography.bodyRegular.copyWith(
                color: hasActiveFilters
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),

          // Edit button
          TextButton(
            onPressed: _handleEditFiltersTap,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.accent,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.chip),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              td(ref, 'menu_filters_edit'),
              style: AppTypography.label.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual menu item card
  Widget _buildMenuItem(Map<String, dynamic> item, dynamic business) {
    final localization = ref.watch(localizationProvider);

    // Extract item data
    final name = item['name'] ?? '';
    final description = item['description'] ?? '';
    final price = item['price'] as num?;
    final hasVariations = (item['variations'] as List?)?.isNotEmpty ?? false;

    // Format price
    String? formattedPrice;
    if (price != null && price > 0) {
      final convertedPrice = price * localization.exchangeRate;
      formattedPrice =
          '${localization.currencyCode} ${convertedPrice.toStringAsFixed(0)}';
    }

    return GestureDetector(
      onTap: () => _handleItemTap(item, hasVariations),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          border: Border.all(color: AppColors.border, width: 1),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item name + price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: AppTypography.bodyRegular.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (formattedPrice != null) ...[
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    formattedPrice,
                    style: AppTypography.bodyRegular.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),

            // Item description (if available)
            if (description.isNotEmpty) ...[
              SizedBox(height: AppSpacing.xs),
              Text(
                description,
                style: AppTypography.bodyRegular.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Handle edit filters button tap - open UnifiedFiltersWidget modal
  Future<void> _handleEditFiltersTap() async {
    // Track analytics
    final analytics = AnalyticsService.instance;
    ApiService.instance
        .postAnalytics(
      eventType: 'menu_edit_filters_tapped',
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

    // Open UnifiedFiltersWidget modal
    if (mounted) {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => UnifiedFiltersWidget(
          businessId: widget.businessId,
          height: 350.0,
          onFiltersChanged: () async {
            // Filters updated - UI will rebuild via provider watch
            debugPrint('Dietary filters changed from inline menu');
          },
          onVisibleItemCountChanged: (int count) async {
            debugPrint('Visible items after filter: $count');
          },
        ),
      );
    }
  }

  /// Handle menu item tap - open ItemBottomSheet modal
  Future<void> _handleItemTap(
    Map<String, dynamic> item,
    bool hasVariations,
  ) async {
    final localization = ref.read(localizationProvider);
    final translationsCache = ref.read(translationsCacheProvider);
    final business = ref.read(businessProvider).currentBusiness;
    final currentLanguage = Localizations.localeOf(context).languageCode;
    final originalCurrency = business?['price_range_currency_code'] ?? 'DKK';

    // Track analytics
    final analytics = AnalyticsService.instance;
    ref.read(analyticsProvider.notifier).incrementItemClick();

    ApiService.instance
        .postAnalytics(
      eventType: 'menu_item_tapped',
      deviceId: analytics.deviceId ?? '',
      sessionId: analytics.currentSessionId ?? '',
      userId: analytics.userId ?? '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'pageName': 'businessProfile',
        'itemName': item['name'] ?? '',
      },
    )
        .catchError((e) {
      debugPrint('Analytics error: $e');
      return ApiCallResponse.failure('Analytics failed');
    });

    // Open ItemBottomSheet modal
    if (mounted) {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ItemBottomSheet(
          itemData: item,
          chosenCurrency: localization.currencyCode,
          originalCurrencyCode: originalCurrency,
          exchangeRate: localization.exchangeRate,
          currentLanguage: currentLanguage,
          businessName: business?['business_name'] ?? '',
          translationsCache: translationsCache,
          hasVariations: hasVariations,
        ),
      );
    }
  }

  /// Handle category chip tap
  void _onCategoryTapped(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _isExpanded = false; // Reset expansion when category changes
    });

    // Track analytics
    final analytics = AnalyticsService.instance;
    ApiService.instance
        .postAnalytics(
      eventType: 'menu_category_selected',
      deviceId: analytics.deviceId ?? '',
      sessionId: analytics.currentSessionId ?? '',
      userId: analytics.userId ?? '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'pageName': 'businessProfile',
        'categoryId': categoryId ?? 'all',
      },
    )
        .catchError((e) {
      debugPrint('Analytics error: $e');
      return ApiCallResponse.failure('Analytics failed');
    });
  }

  /// Handle expand/collapse toggle
  void _handleToggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    // Track analytics
    final analytics = AnalyticsService.instance;
    ApiService.instance
        .postAnalytics(
      eventType: 'menu_toggle_expand',
      deviceId: analytics.deviceId ?? '',
      sessionId: analytics.currentSessionId ?? '',
      userId: analytics.userId ?? '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'pageName': 'businessProfile',
        'isExpanded': _isExpanded,
      },
    )
        .catchError((e) {
      debugPrint('Analytics error: $e');
      return ApiCallResponse.failure('Analytics failed');
    });
  }

  /// Handle "View full menu" button tap - navigate to full menu page
  Future<void> _handleViewFullMenuTap() async {
    // Track analytics
    final analytics = AnalyticsService.instance;
    ApiService.instance
        .postAnalytics(
      eventType: 'menu_full_page_opened',
      deviceId: analytics.deviceId ?? '',
      sessionId: analytics.currentSessionId ?? '',
      userId: analytics.userId ?? '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'pageName': 'businessProfile',
        'businessId': widget.businessId,
      },
    )
        .catchError((e) {
      debugPrint('Analytics error: $e');
      return ApiCallResponse.failure('Analytics failed');
    });

    // Navigate to full menu page (existing route at /business/:id/menu)
    if (mounted) {
      await Navigator.pushNamed(
        context,
        '/business/${widget.businessId}/menu',
      );
    }
  }
}
