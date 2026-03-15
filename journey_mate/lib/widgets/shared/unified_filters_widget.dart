import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../../providers/business_providers.dart';
import '../../providers/provider_state_classes.dart';
import '../../services/analytics_service.dart';
import '../../services/api_service.dart';
import '../../services/translation_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';

/// A unified filter widget combining dietary restrictions, preferences, and
/// allergens with MULTI-RESTRICTION SUPPORT.
///
/// KEY FEATURES:
/// - Restrictions are MULTI-SELECT (can select gluten-free + lactose-free)
/// - Preferences are SINGLE-SELECT (vegan OR vegetarian)
/// - Allergens are MULTI-EXCLUDE (exclude multiple allergens)
/// - Auto-selection validates ALL restrictions whose allergen requirements are met
/// - Cumulative allergen logic prevents conflicts when deselecting restrictions
/// - Calculates visible item count directly from menu data
class UnifiedFiltersWidget extends ConsumerStatefulWidget {
  const UnifiedFiltersWidget({
    super.key,
    this.width,
    this.height,
    required this.businessId,
    this.onFiltersChanged,
    this.onVisibleItemCountChanged,
  });

  final double? width;
  final double? height;
  final int businessId;
  final Future Function()? onFiltersChanged;
  final Future Function(int count, bool hasFilters, int itemsTotal, int itemsVisible, int categoriesEmpty)? onVisibleItemCountChanged;

  @override
  ConsumerState<UnifiedFiltersWidget> createState() =>
      _UnifiedFiltersWidgetState();
}

class _UnifiedFiltersWidgetState extends ConsumerState<UnifiedFiltersWidget> {
  /// =========================================================================
  /// CONSTANTS - ALLERGEN & DIETARY IDS
  /// =========================================================================

  static const int _glutenAllergenId = 2;
  static const int _crustaceansAllergenId = 3;
  static const int _eggsAllergenId = 4;
  static const int _fishAllergenId = 5;
  static const int _milkAllergenId = 7;
  static const int _molluscsAllergenId = 8;

  static const int _glutenFreeId = 1;
  static const int _halalId = 3;
  static const int _lactoseFreeId = 4;
  static const int _kosherId = 5;

  static const int _pescetarianId = 2;
  static const int _veganId = 6;
  static const int _vegetarianId = 7;

  static const int _totalAllergenCount = 14;

  /// =========================================================================
  /// CONSTANTS - DIETARY MAPPINGS
  /// =========================================================================

  static const Map<int, List<int>> _dietaryToAllergensMap = {
    _glutenFreeId: [_glutenAllergenId],
    _lactoseFreeId: [_milkAllergenId],
    _halalId: [],
    _kosherId: [],
    _veganId: [
      _milkAllergenId,
      _eggsAllergenId,
      _fishAllergenId,
      _crustaceansAllergenId,
      _molluscsAllergenId,
    ],
    _vegetarianId: [
      _fishAllergenId,
      _crustaceansAllergenId,
      _molluscsAllergenId,
    ],
    _pescetarianId: [],
  };

  static const Map<int, List<int>> _dietaryImpliesOtherDietaryMap = {
    _veganId: [_lactoseFreeId],
  };

  static const Set<int> _autoSelectableRestrictions = {
    _glutenFreeId,
    _lactoseFreeId,
  };

  static const Set<int> _autoSelectablePreferences = {
    _veganId,
    _vegetarianId,
  };

  static const List<int> _restrictionDisplayOrder = [
    _glutenFreeId,
    _lactoseFreeId,
    _halalId,
    _kosherId,
  ];

  /// =========================================================================
  /// CONSTANTS - VISUAL STYLING
  /// =========================================================================

  static const Color _selectedColor = AppColors.accent;
  static const Color _unselectedColor = AppColors.bgSurface;
  static const Color _selectedTextColor = AppColors.white;
  static const Color _unselectedTextColor = AppColors.textPrimary;
  static final Color _borderColor = AppColors.border;

  static const Duration _animationDuration = Duration(milliseconds: 200);
  static const EdgeInsets _buttonPadding = EdgeInsets.symmetric(horizontal: 16);
  static const Size _buttonMinSize = Size(0, 32);
  static const double _buttonBorderRadius = AppRadius.chip;
  static const double _buttonSpacing = AppSpacing.sm;

  static const double _containerBorderRadius = AppRadius.button;
  static const EdgeInsets _containerPadding = EdgeInsets.fromLTRB(16, 18, 16, 18);

  static const double _sectionSpacing = AppSpacing.lg;
  static const double _widgetTopPadding = 4.0;
  static const double _widgetHeight = 32.0;

  /// =========================================================================
  /// STATE - SCROLL CONTROLLERS
  /// =========================================================================

  late final ScrollController _restrictionScrollController;
  late final ScrollController _preferenceScrollController;

  bool _isInitializing = true;

  /// =========================================================================
  /// STATE - MENU DATA CACHE
  /// =========================================================================

  /// Cached menu item map for quick lookup by ID
  Map<int, Map<String, dynamic>> _menuItemMap = {};

  /// Cached list of regular categories (non-package)
  List<Map<String, dynamic>> _regularCategories = [];

  /// Cached list of menu packages
  List<Map<String, dynamic>> _menuPackages = [];

  /// Last calculated visible item count
  int _lastCalculatedCount = 0;

  /// =========================================================================
  /// LIFECYCLE METHODS
  /// =========================================================================

  @override
  void initState() {
    super.initState();

    _restrictionScrollController = ScrollController();
    _preferenceScrollController = ScrollController();

    // Extract and cache menu data
    _extractMenuData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _isInitializing = false;
        _validateAllFiltersAgainstAllergens();
        // Calculate initial count after validation
        _calculateAndNotifyVisibleCount();
      }
    });
  }

  @override
  void didUpdateWidget(covariant UnifiedFiltersWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Re-extract menu data if business changed
    if (oldWidget.businessId != widget.businessId) {
      _extractMenuData();
      _calculateAndNotifyVisibleCount();
    }
  }

  @override
  void dispose() {
    _restrictionScrollController.dispose();
    _preferenceScrollController.dispose();
    super.dispose();
  }

  /// =========================================================================
  /// MENU DATA EXTRACTION
  /// =========================================================================

  /// Extracts and caches menu data from businessProvider for count calculation
  void _extractMenuData() {
    try {
      final businessState = ref.read(businessProvider);
      final normalizedData = businessState.menuItems;

      if (normalizedData is! Map<String, dynamic>) {
        _clearMenuDataCache();
        return;
      }

      _buildMenuItemMap(normalizedData);
      _extractCategories(normalizedData);
    } catch (e) {
      _clearMenuDataCache();
    }
  }

  /// Clears all cached menu data
  void _clearMenuDataCache() {
    _menuItemMap = {};
    _regularCategories = [];
    _menuPackages = [];
  }

  /// Builds a map of menu items keyed by menu_item_id for quick lookup
  void _buildMenuItemMap(Map<String, dynamic> normalizedMap) {
    final menuItems = normalizedMap['menu_items'] as List<dynamic>? ?? [];
    _menuItemMap = Map.fromEntries(
      menuItems.whereType<Map<String, dynamic>>().map(
            (item) => MapEntry(item['menu_item_id'] as int, item),
          ),
    );
  }

  /// Extracts and separates regular categories from packages
  void _extractCategories(Map<String, dynamic> normalizedMap) {
    final categories = normalizedMap['categories'] as List<dynamic>? ?? [];
    final allCategories =
        categories.whereType<Map<String, dynamic>>().toList();

    _regularCategories = allCategories
        .where((cat) => cat['category_type'] != 'menu_package')
        .toList();

    _menuPackages = allCategories
        .where((cat) => cat['category_type'] == 'menu_package')
        .toList();
  }

  /// =========================================================================
  /// VISIBLE COUNT CALCULATION
  /// =========================================================================

  /// Calculates and notifies parent of visible item count with rich filter metrics
  void _calculateAndNotifyVisibleCount() {
    // Re-extract in case data changed
    _extractMenuData();

    final visibleCount = _calculateVisibleItemCount();
    final totalCount = _calculateTotalItemCount();
    final categoriesEmpty = _calculateCategoriesCompletelyEmpty();

    // Get current filter state
    final businessState = ref.read(businessProvider);
    final hasFilters = businessState.selectedDietaryRestrictionIds.isNotEmpty ||
        businessState.selectedDietaryPreferenceId != null ||
        businessState.excludedAllergyIds.isNotEmpty;

    if (visibleCount != _lastCalculatedCount) {
      _lastCalculatedCount = visibleCount;
      widget.onVisibleItemCountChanged?.call(
        visibleCount,
        hasFilters,
        totalCount,
        visibleCount,
        categoriesEmpty,
      );
    }
  }

  /// Calculates total count of all items (unfiltered)
  int _calculateTotalItemCount() {
    int count = 0;
    // Count all regular category items
    for (final category in _regularCategories) {
      if (category['category_type'] != 'a la carte') continue;
      final itemIds = category['menu_item_ids'] as List<dynamic>? ?? [];
      count += itemIds.whereType<int>().length;
    }
    // Add all packages
    count += _menuPackages.length;
    return count;
  }

  /// Counts how many categories have zero visible items after filtering
  int _calculateCategoriesCompletelyEmpty() {
    int emptyCount = 0;
    for (final category in _regularCategories) {
      if (category['category_type'] != 'a la carte') continue;
      final itemIds = category['menu_item_ids'] as List<dynamic>? ?? [];
      bool hasVisibleItem = false;
      for (final itemId in itemIds) {
        if (itemId is! int) continue;
        final item = _menuItemMap[itemId];
        if (item != null && _isItemVisible(item)) {
          hasVisibleItem = true;
          break;
        }
      }
      if (!hasVisibleItem) {
        emptyCount++;
      }
    }
    return emptyCount;
  }

  /// Calculates total count of visible items based on current filters
  int _calculateVisibleItemCount() {
    int count = 0;

    // Count regular category items
    for (final category in _regularCategories) {
      if (category['category_type'] != 'a la carte') continue;

      final itemIds = category['menu_item_ids'] as List<dynamic>? ?? [];
      for (final itemId in itemIds) {
        if (itemId is! int) continue;
        final item = _menuItemMap[itemId];
        if (item != null && _isItemVisible(item)) {
          count++;
        }
      }
    }

    // Add package count (packages are always visible)
    count += _menuPackages.length;

    return count;
  }

  /// =========================================================================
  /// ITEM VISIBILITY LOGIC (ported from MenuDishesListView)
  /// =========================================================================

  /// Determines if an item should be visible based on current filters
  bool _isItemVisible(Map<String, dynamic> item) {
    // Item must pass dietary filter (via either IS or CAN BE MADE)
    if (!_passesDietaryFilter(item)) {
      return false;
    }

    // Check if item qualifies for allergen override
    if (_qualifiesForAllergenOverride(item)) {
      return true; // Show item despite allergens
    }

    // Apply normal allergen filtering
    return _passesAllergyFilter(item);
  }

  /// Checks if a dietary ID is valid (not null and not 0)
  bool _isValidDietaryIdForFilter(int? dietaryId) {
    return dietaryId != null && dietaryId != 0;
  }

  /// Checks if item passes dietary filters (both restrictions and preference)
  bool _passesDietaryFilter(Map<String, dynamic> item) {
    final itemDietaryTypes = _extractIntList(item, 'dietary_type_ids');
    final itemCanBeMadeTypes =
        _extractIntList(item, 'dietary_type_can_be_made_ids');

    // Check ALL active restrictions
    for (final restrictionId in _selectedRestrictionIds) {
      if (_isValidDietaryIdForFilter(restrictionId)) {
        final hasInherently = itemDietaryTypes.contains(restrictionId);
        final canBeMade = itemCanBeMadeTypes.contains(restrictionId);

        if (!hasInherently && !canBeMade) {
          return false;
        }
      }
    }

    // Check preference filter
    if (_isValidDietaryIdForFilter(_selectedPreferenceId)) {
      final hasInherently = itemDietaryTypes.contains(_selectedPreferenceId);
      final canBeMade = itemCanBeMadeTypes.contains(_selectedPreferenceId);

      if (!hasInherently && !canBeMade) {
        return false;
      }
    }

    return true;
  }

  /// Checks if item qualifies for allergen override via can-be-made
  bool _qualifiesForAllergenOverride(Map<String, dynamic> item) {
    final itemCanBeMadeTypes =
        _extractIntList(item, 'dietary_type_can_be_made_ids');

    // Check if ANY active restriction is in can-be-made array
    for (final restrictionId in _selectedRestrictionIds) {
      if (_isValidDietaryIdForFilter(restrictionId)) {
        if (itemCanBeMadeTypes.contains(restrictionId)) {
          return true;
        }
      }
    }

    // Check if preference is in can-be-made array
    if (_isValidDietaryIdForFilter(_selectedPreferenceId)) {
      if (itemCanBeMadeTypes.contains(_selectedPreferenceId)) {
        return true;
      }
    }

    return false;
  }

  /// Checks if item passes allergy exclusion filter
  bool _passesAllergyFilter(Map<String, dynamic> item) {
    final excludedAllergies = _excludedAllergyIds;
    if (excludedAllergies.isEmpty) {
      return true;
    }

    final itemAllergies = _extractIntList(item, 'allergy_ids');
    final excludedSet = Set<int>.from(excludedAllergies);

    return !itemAllergies.any((allergyId) => excludedSet.contains(allergyId));
  }

  /// Safely extracts a list of integers from a map
  List<int> _extractIntList(Map<String, dynamic> map, String key) {
    final value = map[key];
    return value is List ? value.whereType<int>().toList() : [];
  }

  /// =========================================================================
  /// PROVIDER ACCESSORS
  /// =========================================================================

  String get _currentLanguage => Localizations.localeOf(context).languageCode;

  List<int> get _availableRestrictions {
    final businessState = ref.watch(businessProvider);
    return businessState.availableDietaryRestrictions;
  }

  List<int> get _availablePreferences {
    final businessState = ref.watch(businessProvider);
    return businessState.availableDietaryPreferences;
  }

  List<int> get _selectedRestrictionIds {
    final businessState = ref.watch(businessProvider);
    return businessState.selectedDietaryRestrictionIds;
  }

  int? get _selectedPreferenceId {
    final businessState = ref.watch(businessProvider);
    return businessState.selectedDietaryPreferenceId;
  }

  List<int> get _excludedAllergyIds {
    final businessState = ref.watch(businessProvider);
    return businessState.excludedAllergyIds;
  }

  /// =========================================================================
  /// PROVIDER MUTATORS
  /// =========================================================================

  void _setRestrictionIds(List<int> ids) {
    ref.read(businessProvider.notifier).setDietaryRestrictions(ids);
  }

  void _setPreferenceId(int? id) {
    ref.read(businessProvider.notifier).setDietaryPreference(id);
  }

  void _setExcludedAllergyIds(List<int> ids) {
    ref.read(businessProvider.notifier).setExcludedAllergies(ids);
  }

  /// =========================================================================
  /// PARENT NOTIFICATION
  /// =========================================================================

  /// Notifies parent that filters changed and provides updated count
  void _notifyFiltersChanged() {
    // Calculate count FIRST (synchronously)
    _calculateAndNotifyVisibleCount();

    // THEN notify parent to rebuild
    widget.onFiltersChanged?.call();
  }

  /// =========================================================================
  /// TRANSLATION HELPERS
  /// =========================================================================

  String _getUIText(String key) {
    return td(ref, key);
  }

  String _getDietaryName(int id) {
    final key = _dietaryIdToKey[id];
    if (key == null) return '⚠️ Unknown dietary $id';
    return _getUIText('${key}_cap');
  }

  String? _getAllergenName(int id) {
    final key = _allergenIdToKey[id];
    if (key == null) return null;
    final name = _getUIText('${key}_cap');
    return name.isEmpty || name.startsWith('⚠️') ? null : name;
  }

  /// Maps dietary type IDs to named translation key prefixes.
  static const Map<int, String> _dietaryIdToKey = {
    1: 'dietary_glutenfree',
    2: 'dietary_pescetarian',
    3: 'dietary_halal',
    4: 'dietary_lactosefree',
    5: 'dietary_kosher',
    6: 'dietary_vegan',
    7: 'dietary_vegetarian',
  };

  /// Maps allergen IDs to named translation key prefixes.
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

  /// =========================================================================
  /// DATA RETRIEVAL & SORTING
  /// =========================================================================

  List<MapEntry<int, String>> _getSortedRestrictions() {
    final entries = _availableRestrictions
        .map((id) => MapEntry(id, _getDietaryName(id)))
        .toList();

    entries.sort((a, b) {
      final indexA = _restrictionDisplayOrder.indexOf(a.key);
      final indexB = _restrictionDisplayOrder.indexOf(b.key);

      if (indexA != -1 && indexB != -1) return indexA.compareTo(indexB);
      if (indexA != -1) return -1;
      if (indexB != -1) return 1;
      return a.key.compareTo(b.key);
    });

    return entries;
  }

  List<MapEntry<int, String>> _getSortedPreferences() {
    final entries = _availablePreferences
        .map((id) => MapEntry(id, _getDietaryName(id)))
        .toList();

    entries.sort((a, b) => a.value.compareTo(b.value));
    return entries;
  }

  List<MapEntry<int, String>> _getSortedAllergens() {
    final entries = <MapEntry<int, String>>[];

    for (int id = 1; id <= _totalAllergenCount; id++) {
      final name = _getAllergenName(id);
      if (name != null) {
        entries.add(MapEntry(id, name));
      }
    }

    entries.sort((a, b) => a.value.compareTo(b.value));
    return entries;
  }

  /// =========================================================================
  /// VALIDATION & COORDINATION LOGIC
  /// =========================================================================

  void _validateAllFiltersAgainstAllergens() {
    if (_isInitializing) return;

    final currentExcludedSet = Set<int>.from(_excludedAllergyIds);
    bool madeChanges = false;

    final validRestrictions =
        _findValidRestrictionsForAllergens(currentExcludedSet);

    if (!ListEquality().equals(validRestrictions, _selectedRestrictionIds)) {
      _setRestrictionIds(validRestrictions);
      madeChanges = true;
    }

    final validPreference =
        _findValidPreferenceForAllergens(currentExcludedSet);

    if (validPreference != _selectedPreferenceId) {
      _setPreferenceId(validPreference);
      madeChanges = true;
    }

    if (madeChanges) {
      setState(() {});
      _notifyFiltersChanged();
    }
  }

  List<int> _findValidRestrictionsForAllergens(Set<int> currentExcludedSet) {
    final validRestrictions = <int>[];

    for (final restrictionId in _autoSelectableRestrictions) {
      if (!_availableRestrictions.contains(restrictionId)) continue;

      final requiredAllergens = _dietaryToAllergensMap[restrictionId] ?? [];
      if (requiredAllergens.isEmpty) continue;

      if (requiredAllergens.every(currentExcludedSet.contains)) {
        validRestrictions.add(restrictionId);
      }
    }

    return validRestrictions;
  }

  int? _findValidPreferenceForAllergens(Set<int> currentExcludedSet) {
    int? validPreference;
    int maxAllergenCount = 0;

    for (final preferenceId in _autoSelectablePreferences) {
      if (!_availablePreferences.contains(preferenceId)) continue;

      final requiredAllergens = _dietaryToAllergensMap[preferenceId] ?? [];
      if (requiredAllergens.isEmpty) continue;

      if (requiredAllergens.every(currentExcludedSet.contains)) {
        if (requiredAllergens.length > maxAllergenCount) {
          validPreference = preferenceId;
          maxAllergenCount = requiredAllergens.length;
        }
      }
    }

    // If we found an auto-selectable preference, use it
    if (validPreference != null) {
      return validPreference;
    }

    // Otherwise, preserve current preference if it's not auto-manageable
    // (e.g., pescatarian, halal, kosher have no allergen requirements)
    if (_selectedPreferenceId != null &&
        !_autoSelectablePreferences.contains(_selectedPreferenceId)) {
      return _selectedPreferenceId;
    }

    return null;
  }

  /// =========================================================================
  /// USER INTERACTION HANDLERS
  /// =========================================================================

  Future<void> _handleRestrictionTap(int restrictionId) async {
    final isCurrentlySelected = _selectedRestrictionIds.contains(restrictionId);

    _trackRestrictionToggle(restrictionId, isCurrentlySelected);

    if (isCurrentlySelected) {
      _deselectRestriction(restrictionId);
    } else {
      _selectRestriction(restrictionId);
    }

    _notifyFiltersChanged();
  }

  void _deselectRestriction(int restrictionId) {
    final newRestrictions = List<int>.from(_selectedRestrictionIds)
      ..remove(restrictionId);
    _setRestrictionIds(newRestrictions);

    final allergensToInclude = _dietaryToAllergensMap[restrictionId] ?? [];
    final allergensStillNeeded =
        _getAllergensNeededByRestrictions(newRestrictions);

    if (_selectedPreferenceId != null) {
      final preferenceAllergens =
          _dietaryToAllergensMap[_selectedPreferenceId] ?? [];
      allergensStillNeeded.addAll(preferenceAllergens);
    }

    final newExcludedSet = Set<int>.from(_excludedAllergyIds);
    for (final allergenId in allergensToInclude) {
      if (!allergensStillNeeded.contains(allergenId)) {
        newExcludedSet.remove(allergenId);
      }
    }

    _setExcludedAllergyIds(newExcludedSet.toList());
    _validateAllFiltersAgainstAllergens();
    setState(() {});
  }

  void _selectRestriction(int restrictionId) {
    final newRestrictions = List<int>.from(_selectedRestrictionIds)
      ..add(restrictionId);
    _setRestrictionIds(newRestrictions);

    final impliedAllergens = _dietaryToAllergensMap[restrictionId] ?? [];
    final newExcludedSet = Set<int>.from(_excludedAllergyIds)
      ..addAll(impliedAllergens);

    _setExcludedAllergyIds(newExcludedSet.toList());
    setState(() {});
  }

  Set<int> _getAllergensNeededByRestrictions(List<int> restrictionIds) {
    final needed = <int>{};
    for (final id in restrictionIds) {
      final allergens = _dietaryToAllergensMap[id] ?? [];
      needed.addAll(allergens);
    }
    return needed;
  }

  Future<void> _handlePreferenceTap(int preferenceId) async {
    final isDeselecting = _selectedPreferenceId == preferenceId;

    _trackPreferenceToggle(preferenceId, isDeselecting);

    if (isDeselecting) {
      _setPreferenceId(null);

      final allergensToInclude = _dietaryToAllergensMap[preferenceId] ?? [];
      final allergensNeededByRestrictions =
          _getAllergensNeededByRestrictions(_selectedRestrictionIds);

      final newExcludedSet = Set<int>.from(_excludedAllergyIds);
      for (final allergenId in allergensToInclude) {
        if (!allergensNeededByRestrictions.contains(allergenId)) {
          newExcludedSet.remove(allergenId);
        }
      }

      _setExcludedAllergyIds(newExcludedSet.toList());

      final impliedRestrictions =
          _dietaryImpliesOtherDietaryMap[preferenceId] ?? [];
      final newRestrictions = List<int>.from(_selectedRestrictionIds)
        ..removeWhere(impliedRestrictions.contains);
      _setRestrictionIds(newRestrictions);

      setState(() {});
    } else {
      _setPreferenceId(preferenceId);

      final impliedAllergens = _dietaryToAllergensMap[preferenceId] ?? [];
      final newExcludedSet = Set<int>.from(_excludedAllergyIds)
        ..addAll(impliedAllergens);

      _setExcludedAllergyIds(newExcludedSet.toList());

      final impliedRestrictions =
          _dietaryImpliesOtherDietaryMap[preferenceId] ?? [];
      final newRestrictions = List<int>.from(_selectedRestrictionIds);
      for (final restrictionId in impliedRestrictions) {
        if (_availableRestrictions.contains(restrictionId) &&
            !newRestrictions.contains(restrictionId)) {
          newRestrictions.add(restrictionId);
        }
      }
      _setRestrictionIds(newRestrictions);

      setState(() {});
    }

    _notifyFiltersChanged();
  }

  Future<void> _handleAllergenTap(int allergenId) async {
    final isCurrentlyExcluded = _excludedAllergyIds.contains(allergenId);

    _trackAllergenToggle(allergenId, isCurrentlyExcluded);

    final newExcludedSet = Set<int>.from(_excludedAllergyIds);
    if (isCurrentlyExcluded) {
      newExcludedSet.remove(allergenId);
    } else {
      newExcludedSet.add(allergenId);
    }

    _setExcludedAllergyIds(newExcludedSet.toList());
    _validateAllFiltersAgainstAllergens();

    _notifyFiltersChanged();
  }

  Future<void> _handleResetTap() async {
    _trackAnalyticsEvent(
      'unified_filters_reset',
      {'business_id': widget.businessId},
    );

    _setRestrictionIds([]);
    _setPreferenceId(null);
    _setExcludedAllergyIds([]);

    setState(() {});
    _notifyFiltersChanged();
  }

  /// =========================================================================
  /// ANALYTICS TRACKING
  /// =========================================================================

  void _trackRestrictionToggle(int restrictionId, bool isDeselecting) {
    final restrictionName = _getDietaryName(restrictionId);

    _trackAnalyticsEvent(
      'unified_filter_restriction_toggled',
      {
        'business_id': widget.businessId,
        'restriction_id': restrictionId,
        'restriction_name': restrictionName,
        'action': isDeselecting ? 'deselected' : 'selected',
        'is_now_selected': !isDeselecting,
        'total_restrictions_active': isDeselecting
            ? _selectedRestrictionIds.length - 1
            : _selectedRestrictionIds.length + 1,
        'language': _currentLanguage,
      },
    );
  }

  void _trackPreferenceToggle(int preferenceId, bool isDeselecting) {
    final preferenceName = _getDietaryName(preferenceId);

    _trackAnalyticsEvent(
      'unified_filter_preference_toggled',
      {
        'business_id': widget.businessId,
        'preference_id': preferenceId,
        'preference_name': preferenceName,
        'action': isDeselecting ? 'deselected' : 'selected',
        'is_now_selected': !isDeselecting,
        'language': _currentLanguage,
      },
    );
  }

  void _trackAllergenToggle(int allergenId, bool isCurrentlyExcluded) {
    final allergenName = _getAllergenName(allergenId);

    _trackAnalyticsEvent(
      'unified_filter_allergen_toggled',
      {
        'business_id': widget.businessId,
        'allergen_id': allergenId,
        'allergen_name': allergenName ?? 'unknown',
        'action': isCurrentlyExcluded ? 'included' : 'excluded',
        'is_now_excluded': !isCurrentlyExcluded,
        'language': _currentLanguage,
      },
    );
  }

  void _trackAnalyticsEvent(String eventName, Map<String, dynamic> params) {
    // Fire-and-forget (no await)
    final deviceId = AnalyticsService.instance.deviceId ?? 'unknown';
    final sessionId = AnalyticsService.instance.currentSessionId ?? 'unknown';
    final userId = AnalyticsService.instance.userId ?? 'unknown';

    ApiService.instance.postAnalytics(
      eventType: eventName,
      deviceId: deviceId,
      sessionId: sessionId,
      userId: userId,
      eventData: params,
      timestamp: DateTime.now().toIso8601String(),
    ).catchError(
      (error) {
        return ApiCallResponse.failure('Analytics tracking failed: $error');
      },
    );
  }

  /// =========================================================================
  /// UI STATE HELPERS
  /// =========================================================================

  bool _hasActiveFilters() {
    return _selectedRestrictionIds.isNotEmpty ||
        _selectedPreferenceId != null ||
        _excludedAllergyIds.isNotEmpty;
  }

  bool _isAllergenVisible(int allergenId) {
    return !_excludedAllergyIds.contains(allergenId);
  }

  bool _isRestrictionSelected(int restrictionId) {
    return _selectedRestrictionIds.contains(restrictionId);
  }

  /// =========================================================================
  /// UI BUILDERS - BUTTONS
  /// =========================================================================

  Widget _buildDietaryButton({
    required String text,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return AnimatedContainer(
      duration: _animationDuration,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          padding: WidgetStateProperty.all(_buttonPadding),
          minimumSize: WidgetStateProperty.all(_buttonMinSize),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_buttonBorderRadius),
              side: isSelected
                  ? BorderSide.none
                  : BorderSide(color: _borderColor, width: 1),
            ),
          ),
          backgroundColor: WidgetStateProperty.all(
            isSelected ? _selectedColor : _unselectedColor,
          ),
          elevation: WidgetStateProperty.all(0),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
        child: Text(
          text,
          style: AppTypography.bodySm.copyWith(
            color: isSelected ? _selectedTextColor : _unselectedTextColor,
          ),
        ),
      ),
    );
  }

  Widget _buildAllergenButton({
    required String text,
    required bool isVisible,
    required VoidCallback onPressed,
  }) {
    return AnimatedContainer(
      duration: _animationDuration,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          padding: WidgetStateProperty.all(_buttonPadding),
          minimumSize: WidgetStateProperty.all(_buttonMinSize),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_buttonBorderRadius),
              side: isVisible
                  ? BorderSide.none
                  : BorderSide(color: _borderColor, width: 1),
            ),
          ),
          backgroundColor: WidgetStateProperty.all(
            isVisible ? _selectedColor : _unselectedColor,
          ),
          elevation: WidgetStateProperty.all(0),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
        child: Text(
          text,
          style: AppTypography.bodySm.copyWith(
            color: isVisible ? _selectedTextColor : _unselectedTextColor,
          ),
        ),
      ),
    );
  }

  /// =========================================================================
  /// UI BUILDERS - SECTIONS
  /// =========================================================================

  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _getUIText('menu_dishes_filter_title'),
          style: AppTypography.h5,
        ),
        if (_hasActiveFilters())
          GestureDetector(
            onTap: _handleResetTap,
            child: Text(
              _getUIText('search_reset'),
              style: AppTypography.bodyLg,
            ),
          ),
      ],
    );
  }

  Widget _buildFilterSection({
    required String header,
    required String description,
    required List<MapEntry<int, String>> items,
    required bool Function(int) isSelected,
    required Future<void> Function(int) onTap,
    required ScrollController scrollController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: AppTypography.h6,
        ),
        Text(
          description,
          style: AppTypography.body,
        ),
        Padding(
          padding: const EdgeInsets.only(top: _widgetTopPadding),
          child: SizedBox(
            height: _widgetHeight,
            child: ListView.separated(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: _buttonSpacing),
              itemBuilder: (_, index) {
                final item = items[index];
                return _buildDietaryButton(
                  text: item.value,
                  isSelected: isSelected(item.key),
                  onPressed: () => onTap(item.key),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllergenSection() {
    final allergens = _getSortedAllergens();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getUIText('info_header_allergens'),
          style: AppTypography.h6,
        ),
        Text(
          _getUIText('menu_dishes_filter_allergens_subtitle'),
          style: AppTypography.body,
        ),
        Padding(
          padding: const EdgeInsets.only(top: _widgetTopPadding),
          child: Wrap(
            spacing: _buttonSpacing,
            runSpacing: AppSpacing.sm,
            children: allergens
                .map((allergen) => _buildAllergenButton(
                      text: allergen.value,
                      isVisible: _isAllergenVisible(allergen.key),
                      onPressed: () => _handleAllergenTap(allergen.key),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  /// =========================================================================
  /// BUILD METHOD
  /// =========================================================================

  @override
  Widget build(BuildContext context) {
    // Recalculate visible count when filter state changes externally (e.g. from
    // the full menu page's UnifiedFiltersWidget instance while this instance is
    // in Offstage on the business profile page).
    ref.listen<BusinessState>(businessProvider, (previous, next) {
      final restrictionsChanged = !const ListEquality<int>()
          .equals(previous?.selectedDietaryRestrictionIds,
              next.selectedDietaryRestrictionIds);
      final preferenceChanged =
          previous?.selectedDietaryPreferenceId != next.selectedDietaryPreferenceId;
      final allergiesChanged = !const ListEquality<int>()
          .equals(previous?.excludedAllergyIds, next.excludedAllergyIds);
      if (restrictionsChanged || preferenceChanged || allergiesChanged) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _calculateAndNotifyVisibleCount();
        });
      }
    });

    final restrictions = _getSortedRestrictions();
    final preferences = _getSortedPreferences();

    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(_containerBorderRadius),
      ),
      padding: _containerPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(),
          const SizedBox(height: AppSpacing.xs),
          _buildFilterSection(
            header: _getUIText('menu_dishes_filter_restrictions_title'),
            description: _getUIText('menu_dishes_filter_restrictions_subtitle'),
            items: restrictions,
            isSelected: _isRestrictionSelected,
            onTap: _handleRestrictionTap,
            scrollController: _restrictionScrollController,
          ),
          const SizedBox(height: _sectionSpacing),
          _buildFilterSection(
            header: _getUIText('menu_dishes_filter_preferences_title'),
            description: _getUIText('menu_dishes_filter_preferences_subtitle'),
            items: preferences,
            isSelected: (id) => _selectedPreferenceId == id,
            onTap: _handlePreferenceTap,
            scrollController: _preferenceScrollController,
          ),
          const SizedBox(height: _sectionSpacing),
          _buildAllergenSection(),
        ],
      ),
    );
  }
}
