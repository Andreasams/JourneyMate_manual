import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../providers/app_providers.dart';
import '../../providers/business_providers.dart';
import '../../providers/settings_providers.dart';
import '../../services/translation_service.dart';
import 'unified_filters_widget.dart';
import 'menu_categories_rows.dart';
import 'menu_dishes_list_view.dart';
import 'item_bottom_sheet.dart';
import 'package_bottom_sheet.dart';
import 'description_sheet.dart';

/// Shared menu section used by both InlineMenuWidget (business profile) and
/// MenuFullPage (dedicated menu page).
///
/// Layout:
/// (1) Row: "Menu" title  |  "Last updated on [date]"
/// (2) Column: filter summary + show/hide toggle + UnifiedFiltersWidget
/// (3) MenuCategoriesRows (dynamic height: 42/72px based on row count)
/// (4) MenuDishesListView
///     isFullPage=false -> Container(maxHeight: 337)
///     isFullPage=true  -> Expanded
///
/// Bottom sheets (ItemBottomSheet, PackageBottomSheet, DescriptionSheet) are
/// handled internally — identical display logic regardless of context.
///
/// Self-contained: reads business data, language, translations, and
/// localization from providers/context internally. Only [businessId] and
/// [isFullPage] are required props.
///
/// No outer padding — parent widgets add their own horizontal padding.
class MenuSectionWidget extends ConsumerStatefulWidget {
  final int businessId;

  /// false = 337px max height (business profile inline),
  /// true  = Expanded to fill remaining space (full page).
  final bool isFullPage;

  /// Optional analytics callbacks for page-level tracking.
  /// NOTE: MenuDishesListView already tracks item/package/category analytics
  /// internally via analyticsProvider. Only wire these if the page needs
  /// *additional* work beyond what MenuDishesListView does.
  final VoidCallback? onItemTapped;
  final VoidCallback? onPackageTapped;
  final void Function(int categoryId)? onCategoryViewed;
  final void Function(int count, bool hasActiveFilters)? onFilterCountChanged;

  const MenuSectionWidget({
    super.key,
    required this.businessId,
    this.isFullPage = false,
    this.onItemTapped,
    this.onPackageTapped,
    this.onCategoryViewed,
    this.onFilterCountChanged,
  });

  @override
  ConsumerState<MenuSectionWidget> createState() => _MenuSectionWidgetState();
}

class _MenuSectionWidgetState extends ConsumerState<MenuSectionWidget> {
  late final MenuScrollController _menuScrollController;
  bool _showFilters = false;
  int _visibleItemCount = 0;
  int _numberOfCategoryRows = 1;
  dynamic _visibleSelection; // JSON for MenuCategoriesRows bidirectional sync

  // ─── Height constants (match FlutterFlow) ─────────────────────────────────
  static const double _categoryRowsHeightSingle = 42.0;
  static const double _categoryRowsHeightDouble = 72.0;
  static const double _menuListMaxHeight = 337.0;

  @override
  void initState() {
    super.initState();
    _menuScrollController = MenuScrollController();
  }

  @override
  void dispose() {
    _menuScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final businessState = ref.watch(businessProvider);
    final business = businessState.currentBusiness;
    final menuItems = businessState.menuItems;

    if (menuItems == null || business == null) return const SizedBox.shrink();

    final lastReviewedAt = business['last_reviewed_at']?.toString() ?? '';
    final menuCategories = business['menuCategories'];
    final businessName = business['business_name']?.toString() ?? '';
    final originalCurrencyCode =
        business['price_range_currency_code']?.toString() ?? 'DKK';
    final language = Localizations.localeOf(context).languageCode;

    final hasActiveFilters =
        businessState.selectedDietaryRestrictionIds.isNotEmpty ||
            businessState.selectedDietaryPreferenceId != null ||
            businessState.excludedAllergyIds.isNotEmpty;

    return Column(
      mainAxisSize: widget.isFullPage ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── (1) Title row ──────────────────────────────────────────────────
        _buildTitleRow(lastReviewedAt, language),
        SizedBox(height: AppSpacing.sm),

        // ── (2) Filter section ─────────────────────────────────────────────
        _buildFilterSection(hasActiveFilters),

        // ── (3) MenuCategoriesRows ─────────────────────────────────────────
        _buildCategoryRows(business, menuCategories),

        // ── (4) MenuDishesListView ─────────────────────────────────────────
        if (widget.isFullPage)
          Expanded(
            child: _buildMenuDishesListView(
              originalCurrencyCode,
              businessName,
            ),
          )
        else
          Container(
            constraints: const BoxConstraints(maxHeight: _menuListMaxHeight),
            decoration: BoxDecoration(color: AppColors.bgCard),
            child: _buildMenuDishesListView(
              originalCurrencyCode,
              businessName,
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION BUILDERS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTitleRow(String lastReviewedAt, String language) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          td(ref, 'tab_menu'),
          style: AppTypography.h2,
        ),
        Row(
          children: [
            Text(
              td(ref, 'menu_last_updated_prefix'),
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              _formatLocalizedDate(lastReviewedAt, language),
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterSection(bool hasActiveFilters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter summary — shown only when filters are active
        if (hasActiveFilters)
          Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              _buildFilterSummary(),
              style: AppTypography.bodyLg,
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
              style: AppTypography.bodyLgMedium.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),

        // UnifiedFiltersWidget — always mounted so _visibleItemCount stays
        // current even when the panel is collapsed. Offstage hides visually
        // but keeps the widget in the tree to receive filter callbacks.
        Offstage(
          offstage: !_showFilters,
          child: Padding(
            padding: EdgeInsets.only(top: 6, bottom: 12),
            child: UnifiedFiltersWidget(
              businessId: widget.businessId,
              width: double.infinity,
              // Intentional empty setState — triggers rebuild so filter
              // summary text and menu list reflect the new filter state.
              onFiltersChanged: () async {
                setState(() {});
              },
              onVisibleItemCountChanged: (count) async {
                setState(() => _visibleItemCount = count);
                if (widget.onFilterCountChanged != null) {
                  final state = ref.read(businessProvider);
                  final hasFilters =
                      state.selectedDietaryRestrictionIds.isNotEmpty ||
                          state.selectedDietaryPreferenceId != null ||
                          state.excludedAllergyIds.isNotEmpty;
                  widget.onFilterCountChanged!(count, hasFilters);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryRows(dynamic business, dynamic menuCategories) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.md,
      ),
      child: SizedBox(
        width: double.infinity,
        height: _numberOfCategoryRows <= 1
            ? _categoryRowsHeightSingle
            : _categoryRowsHeightDouble,
        child: MenuCategoriesRows(
          width: double.infinity,
          height: _numberOfCategoryRows <= 1
              ? _categoryRowsHeightSingle
              : _categoryRowsHeightDouble,
          businessID: business['business_id'] ?? widget.businessId,
          apiResult: menuCategories,
          visibleSelection: _visibleSelection,
          // Scroll the dishes list to the tapped category
          onCategoryChanged: (categoryId, menuId) async {
            _menuScrollController.scrollToCategory(categoryId);
          },
          onNumberOfRows: (rows) async =>
              setState(() => _numberOfCategoryRows = rows),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MENU DISHES LIST VIEW + CALLBACKS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMenuDishesListView(
    String originalCurrencyCode,
    String businessName,
  ) {
    return MenuDishesListView(
      width: double.infinity,
      height: widget.isFullPage ? null : _menuListMaxHeight,
      originalCurrencyCode: originalCurrencyCode,
      isDynamicHeight: false,
      scrollController: _menuScrollController,
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
                originalCurrencyCode: originalCurrencyCode,
                exchangeRate: localization.exchangeRate,
                currentLanguage: lang,
                businessName: businessName,
                translationsCache: translationsCache,
                hasVariations: hasVariations,
              ),
            ),
          ),
        );

        widget.onItemTapped?.call();
      },
      onPackageTap: (packageData) async {
        final localization = ref.read(localizationProvider);
        final normalizedMenuData = ref.read(businessProvider).menuItems;
        final packageId =
            (packageData as Map<String, dynamic>)['package_id'] as int? ?? 0;

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
                originalCurrencyCode: originalCurrencyCode,
                exchangeRate: localization.exchangeRate,
                businessName: businessName,
              ),
            ),
          ),
        );

        widget.onPackageTapped?.call();
      },
      onVisibleCategoryChanged: (selectionData) async {
        setState(() => _visibleSelection = selectionData);

        if (selectionData is Map) {
          final categoryId = selectionData['categoryId'];
          if (categoryId is int) {
            widget.onCategoryViewed?.call(categoryId);
          }
        }
      },
      // Fix: use camelCase keys matching what MenuDishesListView actually
      // sends in _handleCategoryDescriptionTap (categoryName/categoryDescription).
      // Previously InlineMenuWidget used snake_case (category_name) and
      // MenuFullPage used short names (name/description) — both wrong.
      onCategoryDescriptionTap: (categoryData) async {
        final data = categoryData as Map<String, dynamic>;
        final catName = data['categoryName']?.toString() ?? '';
        final catDescription =
            data['categoryDescription']?.toString() ?? '';

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
              builder: (sheetContext, scrollController) => DescriptionSheet(
                title: catName,
                description: catDescription,
                scrollController: scrollController,
                width: double.infinity,
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Formats an ISO date string to a short localized date.
  ///
  /// Supports all 15 languages with automatic locale-specific formatting:
  /// - English (en): "Feb 22, 2026"
  /// - Danish (da): "22. feb. 2026"
  /// - Japanese (ja): "2026/2/22"
  /// - Korean (ko): "2026. 2. 22."
  /// - Chinese (zh): "2026/2/22"
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
