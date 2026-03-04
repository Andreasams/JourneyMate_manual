import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../providers/app_providers.dart';
import '../../providers/business_providers.dart';
import '../../providers/settings_providers.dart';
import '../../services/translation_service.dart';
import '../shared/unified_filters_widget.dart';
import '../shared/menu_categories_rows.dart';
import '../shared/menu_dishes_list_view.dart';
import '../shared/item_bottom_sheet.dart';
import '../shared/package_bottom_sheet.dart';
import '../shared/category_description_sheet.dart';

/// Inline menu section on the business profile page.
///
/// Layout (matching FlutterFlow reference):
/// (0) Column
/// (1) Row: "Menu" title  |  "Last updated on [date]"
/// (2) Column: generateFilterSummary + show/hide filters toggle +
///             UnifiedFiltersWidget (inline, shown when toggled)
/// (3) MenuCategoriesRows
/// (4) Container(maxHeight: 337) → MenuDishesListView
///     onItemTap → ItemBottomSheet
///     onPackageTap → PackageBottomSheet
///     onCategoryDescriptionTap → CategoryDescriptionSheet
/// (5) Row: "View on full page" + arrow
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
  bool _showFilters = false;
  int _visibleItemCount = 0;
  int _numberOfCategoryRows = 1;
  dynamic _visibleSelection; // JSON for MenuCategoriesRows bidirectional sync

  // ─── Height constants (match FlutterFlow) ─────────────────────────────────
  static const double _filterWidgetHeight = 350.0;
  static const double _categoryRowsHeightSingle = 42.0;
  static const double _categoryRowsHeightDouble = 72.0;
  static const double _menuListMaxHeight = 337.0;

  @override
  Widget build(BuildContext context) {
    final businessState = ref.watch(businessProvider);
    final business = businessState.currentBusiness;
    final menuItems = businessState.menuItems;

    if (menuItems == null || business == null) return const SizedBox.shrink();

    final lastReviewedAt =
        business['last_reviewed_at']?.toString() ?? '';
    final menuCategories = business['menuCategories'];
    final businessName =
        business['business_name']?.toString() ?? '';

    final language = Localizations.localeOf(context).languageCode;

    final hasActiveFilters =
        businessState.selectedDietaryRestrictionIds.isNotEmpty ||
            businessState.selectedDietaryPreferenceId != null ||
            businessState.excludedAllergyIds.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── (1) Title row ──────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                td(ref, 'menu_heading'),
                style: AppTypography.sectionHeading,
              ),
              Row(
                children: [
                  Text(
                    td(ref, 'menu_last_updated_prefix'),
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    _formatLocalizedDate(lastReviewedAt, language),
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),

          // ── (2) Filter summary + show/hide toggle + UnifiedFiltersWidget ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter summary — shown only when filters are active
              if (hasActiveFilters)
                Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text(
                    _buildFilterSummary(),
                    style: AppTypography.bodyRegular,
                  ),
                ),

              // Toggle: "Show filters" / "Hide filters"
              Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: GestureDetector(
                  onTap: () => setState(() => _showFilters = !_showFilters),
                  child: Text(
                    _showFilters
                        ? td(ref, 'menu_hide_filters')
                        : td(ref, 'menu_show_filters'),
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),

              // UnifiedFiltersWidget — inline, shown when toggled
              if (_showFilters)
                Padding(
                  padding: EdgeInsets.only(top: 6, bottom: 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: _filterWidgetHeight,
                    child: UnifiedFiltersWidget(
                      businessId: widget.businessId,
                      width: double.infinity,
                      height: _filterWidgetHeight,
                      onFiltersChanged: () async { setState(() {}); },
                      onVisibleItemCountChanged: (count) async { setState(() => _visibleItemCount = count); },
                    ),
                  ),
                ),
            ],
          ),

          // ── (3) MenuCategoriesRows ─────────────────────────────────────────
          Padding(
            padding: EdgeInsets.only(
              top: AppSpacing.md,
              bottom: AppSpacing.lg,
            ),
            child: SizedBox(
              width: double.infinity,
              height: _numberOfCategoryRows == 1
                  ? _categoryRowsHeightSingle
                  : _categoryRowsHeightDouble,
              child: MenuCategoriesRows(
                width: double.infinity,
                height: _numberOfCategoryRows == 1
                    ? _categoryRowsHeightSingle
                    : _categoryRowsHeightDouble,
                businessID:
                    business['business_id'] ?? widget.businessId,
                apiResult: menuCategories,
                visibleSelection: _visibleSelection,
                onCategoryChanged: (categoryId, menuId) async {
                  // No additional local state needed — MenuDishesListView
                  // listens to its own provider state for scroll-to-category.
                },
                onNumberOfRows: (rows) async =>
                    setState(() => _numberOfCategoryRows = rows),
              ),
            ),
          ),

          // ── (4) MenuDishesListView ─────────────────────────────────────────
          Container(
            constraints: const BoxConstraints(maxHeight: _menuListMaxHeight),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
            ),
            child: MenuDishesListView(
              width: double.infinity,
              height: _menuListMaxHeight,
              originalCurrencyCode: 'DKK',
              isDynamicHeight: false,
              onItemTap: (itemData, isBeverage, dietaryTypeIds, allergyIds,
                  formattedPrice, hasVariations, formattedVariationPrice) async {
                final localization = ref.read(localizationProvider);
                final translationsCache = ref.read(translationsCacheProvider);
                final lang = Localizations.localeOf(context).languageCode;

                if (!context.mounted) return;
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (sheetContext) => GestureDetector(
                    onTap: () {
                      FocusScope.of(sheetContext).unfocus();
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: Padding(
                      padding: MediaQuery.viewInsetsOf(sheetContext),
                      child: ItemBottomSheet(
                        itemData: itemData,
                        chosenCurrency: localization.currencyCode,
                        originalCurrencyCode: 'DKK',
                        exchangeRate: localization.exchangeRate,
                        currentLanguage: lang,
                        businessName: businessName,
                        translationsCache: translationsCache,
                        hasVariations: hasVariations,
                      ),
                    ),
                  ),
                );
              },
              onPackageTap: (packageData) async {
                final localization = ref.read(localizationProvider);
                final normalizedMenuData =
                    ref.read(businessProvider).menuItems;
                final packageId =
                    (packageData as Map<String, dynamic>)['package_id'] as int? ??
                        0;

                if (!context.mounted) return;
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  useSafeArea: true,
                  builder: (sheetContext) => GestureDetector(
                    onTap: () {
                      FocusScope.of(sheetContext).unfocus();
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: Padding(
                      padding: MediaQuery.viewInsetsOf(sheetContext),
                      child: PackageBottomSheet(
                        normalizedMenuData: normalizedMenuData,
                        packageId: packageId,
                        chosenCurrency: localization.currencyCode,
                        originalCurrencyCode: 'DKK',
                        exchangeRate: localization.exchangeRate,
                        businessName: businessName,
                      ),
                    ),
                  ),
                );
              },
              onVisibleCategoryChanged: (selectionData) async =>
                  setState(() => _visibleSelection = selectionData),
              onCategoryDescriptionTap: (categoryData) async {
                final data = categoryData as Map<String, dynamic>;
                final catName = data['category_name']?.toString() ?? '';
                final catDescription =
                    data['category_description']?.toString() ?? '';

                if (!context.mounted) return;
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (sheetContext) => GestureDetector(
                    onTap: () {
                      FocusScope.of(sheetContext).unfocus();
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: DraggableScrollableSheet(
                      initialChildSize: 0.4,
                      maxChildSize: 0.9,
                      minChildSize: 0.25,
                      builder: (sheetContext, scrollController) =>
                          CategoryDescriptionSheet(
                        categoryName: catName,
                        categoryDescription: catDescription,
                        scrollController: scrollController,
                        width: double.infinity,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── (5) "View on full page" row ────────────────────────────────────
          Padding(
            padding: EdgeInsets.only(top: 12),
            child: GestureDetector(
              onTap: () =>
                  context.push('/business/${widget.businessId}/menu'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text(
                      td(ref, 'menu_view_full_page'),
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(
                      Icons.keyboard_arrow_right_sharp,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Formats an ISO date string to a short localized date.
  ///
  /// Supports all 15 languages with automatic locale-specific formatting:
  /// - English (en): "Feb 22, 2026"
  /// - Danish (da): "22. feb. 2026"
  /// - Japanese (ja): "2026年2月22日"
  /// - Korean (ko): "2026. 2. 22."
  /// - Chinese (zh): "2026年2月22日"
  /// - And 10 more European languages
  String _formatLocalizedDate(String isoDate, String languageCode) {
    if (isoDate.isEmpty) return '';
    try {
      final date = DateTime.parse(isoDate);
      try {
        // Use language code directly - intl package supports all 15 languages
        return DateFormat.yMMMd(languageCode).format(date);
      } catch (e) {
        // Fallback to English if locale not supported
        return DateFormat.yMMMd('en').format(date);
      }
    } catch (e) {
      // Could not parse date at all
      return isoDate;
    }
  }

  /// Builds the filter summary string shown above the toggle when filters
  /// are active. Mirrors FlutterFlow's generateFilterSummary custom function.
  String _buildFilterSummary() {
    final template = td(ref, 'menu_filter_summary');
    if (template != 'menu_filter_summary') {
      return template.replaceAll('{count}', _visibleItemCount.toString());
    }
    return 'Showing $_visibleItemCount items';
  }
}
