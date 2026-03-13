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

    // Full-page mode: use LayoutBuilder so we can give the menu list a
    // fixed viewport-sized height when filters are visible, allowing the
    // entire page to scroll (title + filters + categories scroll off-screen).
    if (widget.isFullPage) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final menuList = _buildMenuDishesListView(
            originalCurrencyCode,
            businessName,
          );

          final column = Column(
            mainAxisSize: _showFilters ? MainAxisSize.min : MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleRow(lastReviewedAt, language),
              SizedBox(height: AppSpacing.sm),
              _buildFilterSection(hasActiveFilters),
              _buildCategoryRows(business, menuCategories),
              if (_showFilters)
                SizedBox(height: constraints.maxHeight, child: menuList)
              else
                Expanded(child: menuList),
            ],
          );

          // When filters are visible, wrap in SingleChildScrollView so the
          // header (title + filters + categories) can scroll off-screen,
          // leaving the full viewport for the menu list underneath.
          if (_showFilters) {
            return SingleChildScrollView(child: column);
          }
          return column;
        },
      );
    }

    // Inline mode (business profile): fixed max-height container.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleRow(lastReviewedAt, language),
        SizedBox(height: AppSpacing.sm),
        _buildFilterSection(hasActiveFilters),
        _buildCategoryRows(business, menuCategories),
        Container(
          constraints: const BoxConstraints(maxHeight: _menuListMaxHeight),
          // White when inside SectionCard on profile page; bgPage on full menu page.
          decoration: BoxDecoration(
            color: widget.isFullPage ? AppColors.bgPage : AppColors.bgCard,
          ),
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
          style: AppTypography.h4,
        ),
        Row(
          children: [
            Text(
              td(ref, 'menu_last_updated_prefix'),
              style: AppTypography.bodyLight,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              _formatLocalizedDate(lastReviewedAt, language),
              style: AppTypography.bodyLight,
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
        final translationsCache = ref.read(translationsCacheProvider);
        final normalizedMenuData = ref.read(businessProvider).menuItems;
        final lang = Localizations.localeOf(context).languageCode;
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
                currentLanguage: lang,
                translationsCache: translationsCache,
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
            child: DescriptionSheet(
              title: catName,
              description: catDescription,
              width: double.infinity,
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

  // ═══════════════════════════════════════════════════════════════════════════
  // FILTER SUMMARY — ported from FlutterFlow generateFilterSummary
  // ═══════════════════════════════════════════════════════════════════════════

  /// Maps dietary type IDs → named translation keys (lowercase versions).
  static const Map<int, String> _dietaryIdToKey = {
    1: 'dietary_glutenfree',
    2: 'dietary_pescetarian',
    3: 'dietary_halal',
    4: 'dietary_lactosefree',
    5: 'dietary_kosher',
    6: 'dietary_vegan',
    7: 'dietary_vegetarian',
  };

  /// Maps allergen IDs → named translation keys (lowercase versions).
  static const Map<int, String> _allergenIdToKey = {
    1: 'allergen_celery',
    2: 'allergen_gluten',
    3: 'allergen_crustaceans',
    4: 'allergen_eggs',
    5: 'allergen_fish',
    6: 'allergen_lupin',
    7: 'allergen_milk',
    8: 'allergen_molluscs',
    9: 'allergen_mustard',
    10: 'allergen_nuts',
    11: 'allergen_peanuts',
    12: 'allergen_sesame',
    13: 'allergen_soybeans',
    14: 'allergen_sulfites',
  };

  /// Dietary filters that imply certain allergen exclusions.
  /// Used to avoid redundant allergen names in the summary text.
  static const Map<int, List<int>> _impliedAllergenExclusions = {
    1: [2], // Gluten-free → cereals containing gluten
    4: [7], // Lactose-free → milk
    6: [7, 4, 5, 3, 8], // Vegan → milk, eggs, fish, crustaceans, molluscs
    7: [5, 3, 8], // Vegetarian → fish, crustaceans, molluscs
  };

  /// Languages where dietary/allergen names should be lowercased in context.
  static const Set<String> _lowercaseLanguages = {
    'da', 'en', 'es', 'de', 'fr', 'nl', 'no', 'sv', 'it', 'pl', 'fi', 'uk',
  };

  /// Languages where no space is needed before the count number.
  static const Set<String> _noSpaceBeforeCount = {'zh', 'ja', 'ko'};

  /// Builds the filter summary string shown above the toggle when filters
  /// are active. Ported from FlutterFlow's generateFilterSummary.
  ///
  /// Examples:
  /// - "Showing the 34 items that are or can be made lactose-free."
  /// - "Showing the 12 items that are free from peanuts."
  /// - "Showing the 8 items that are or can be made gluten-free and
  ///   lactose-free and are free from peanuts and fish."
  String _buildFilterSummary() {
    final lang = Localizations.localeOf(context).languageCode;
    final state = ref.read(businessProvider);

    final isPlural = _visibleItemCount != 1;
    final itemCountKey =
        isPlural ? 'filter_item_plural' : 'filter_item_singular';
    final itemCountText =
        td(ref, itemCountKey).replaceAll('{}', _visibleItemCount.toString());

    // ── Step 1: Collect dietary filter names ──────────────────────────────

    final dietaryFilters = <String>[];

    for (final restrictionId in state.selectedDietaryRestrictionIds) {
      final name = _getDietaryNameLowercase(restrictionId, lang);
      if (name != null) dietaryFilters.add(name);
    }

    final prefId = state.selectedDietaryPreferenceId;
    if (prefId != null && prefId != 0) {
      final name = _getDietaryNameLowercase(prefId, lang);
      if (name != null) dietaryFilters.add(name);
    }

    final hasDietary = dietaryFilters.isNotEmpty;

    // ── Step 2: Collect allergen filter names (excluding implied) ─────────

    final impliedAllergens = <int>{};
    for (final rid in state.selectedDietaryRestrictionIds) {
      if (_impliedAllergenExclusions.containsKey(rid)) {
        impliedAllergens.addAll(_impliedAllergenExclusions[rid]!);
      }
    }
    if (prefId != null && _impliedAllergenExclusions.containsKey(prefId)) {
      impliedAllergens.addAll(_impliedAllergenExclusions[prefId]!);
    }

    final allergensToShow = <String>[];
    for (final allergenId in state.excludedAllergyIds) {
      if (impliedAllergens.contains(allergenId)) continue;
      final key = _allergenIdToKey[allergenId];
      if (key == null) continue;
      final name = td(ref, key);
      if (name.isEmpty || name.startsWith('⚠️')) continue;
      allergensToShow.add(_applyCase(name, lang));
    }
    allergensToShow.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final hasAllergens = allergensToShow.isNotEmpty;

    // ── Step 3: Build sentence ────────────────────────────────────────────

    if (!hasDietary && !hasAllergens) {
      return '$itemCountText.';
    }

    final and = td(ref, 'filter_and');

    if (hasDietary && !hasAllergens) {
      final prefix = td(ref, isPlural
          ? 'filter_dietary_prefix_plural'
          : 'filter_dietary_prefix_singular');
      final dietaryList = _joinDietaryList(dietaryFilters, and, lang);
      return '$itemCountText$prefix$dietaryList.';
    }

    if (!hasDietary && hasAllergens) {
      final connector = td(ref, isPlural
          ? 'filter_connector_plural'
          : 'filter_connector_singular');
      final allergenList = _formatAllergenList(allergensToShow, and, lang);
      return '$itemCountText$connector$allergenList.';
    }

    // Both dietary AND allergens
    final prefix = td(ref, isPlural
        ? 'filter_dietary_prefix_plural'
        : 'filter_dietary_prefix_singular');
    final dietaryList = _joinDietaryList(dietaryFilters, and, lang);
    final andAreFreeFrom = td(ref, 'filter_and_are_free_from');
    final allergenList = _formatAllergenList(allergensToShow, and, lang);

    return '$itemCountText$prefix$dietaryList$andAreFreeFrom$allergenList.';
  }

  /// Gets a lowercase dietary name for the summary sentence.
  String? _getDietaryNameLowercase(int id, String lang) {
    final key = _dietaryIdToKey[id];
    if (key == null) return null;
    final name = td(ref, key);
    if (name.isEmpty || name.startsWith('⚠️')) return null;
    return _applyCase(name, lang);
  }

  /// Applies lowercase for languages that require it in sentence context.
  String _applyCase(String text, String lang) {
    return _lowercaseLanguages.contains(lang) ? text.toLowerCase() : text;
  }

  /// Joins dietary names and appends the German copula once at the end.
  /// For non-German languages, delegates to [_joinList] unchanged.
  String _joinDietaryList(List<String> items, String conjunction, String lang) {
    final joined = _joinList(items, conjunction);
    if (lang == 'de') {
      return '$joined ${_visibleItemCount != 1 ? 'sind' : 'ist'}';
    }
    return joined;
  }

  /// Joins a list with a conjunction before the last item.
  String _joinList(List<String> items, String conjunction) {
    if (items.isEmpty) return '';
    if (items.length == 1) return items.first;
    if (items.length == 2) return items.join(conjunction);
    final allButLast = items.sublist(0, items.length - 1).join(', ');
    return '$allButLast$conjunction${items.last}';
  }

  /// Formats allergen list: up to 2 named, then "X other allergens".
  String _formatAllergenList(
      List<String> allergens, String and, String lang) {
    if (allergens.isEmpty) return '';
    if (allergens.length == 1) return allergens.first;
    if (allergens.length == 2) return allergens.join(and);

    final firstTwo = allergens.sublist(0, 2).join(', ');
    final othersCount = allergens.length - 2;
    final othersNoun = td(ref, othersCount == 1
        ? 'filter_other_singular'
        : 'filter_other_plural');

    if (_noSpaceBeforeCount.contains(lang)) {
      return '$firstTwo$and$othersCount$othersNoun';
    }
    return '$firstTwo$and$othersCount $othersNoun';
  }
}
