import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/search_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_constants.dart';
import '../../theme/app_typography.dart';

/// Displays selected filters as removable buttons with a "Clear All" action.
///
/// Features:
/// - Shows filters organized by category (Location, Type, Preferences)
/// - Sticky "Clear All" button that remains visible during horizontal scrolling
/// - Self-contained search execution on filter removal/clear
/// - Reads filter state from searchStateProvider as single source of truth
/// - Localized button text via translation system
/// - Automatic button width caching for performance
/// - Accessibility support with text scaling
/// - Automatic rebuild when translations change
class SelectedFiltersBtns extends ConsumerStatefulWidget {
  const SelectedFiltersBtns({
    super.key,
    this.width,
    this.height,
    required this.filters,
    required this.languageCode,
    required this.translationsCache,
    this.onClearAll,
    this.onFilterRemoved,
  });

  final double? width;
  final double? height;
  final dynamic filters;
  final String languageCode;
  final Map<String, String> translationsCache;
  final VoidCallback? onClearAll;
  final void Function(int filterId)? onFilterRemoved;

  /// Static cache for "Clear All" button widths by language
  static Map<String, double> cachedButtonWidths = {};

  @override
  ConsumerState<SelectedFiltersBtns> createState() =>
      _SelectedFiltersBtnsState();
}

class _SelectedFiltersBtnsState extends ConsumerState<SelectedFiltersBtns>
    with WidgetsBindingObserver {
  // --- State ---
  List<Map<String, dynamic>>? _flattenedFilters;
  bool _initialized = false;
  final GlobalKey _clearButtonKey = GlobalKey();
  double? _lastTextScaleFactor;

  // --- Style Constants ---
  static const double _buttonSpacing = 6.0;
  static const double _clearButtonSpacing = 8.0;
  static const double _iconSize = 10.0;

  // --- Category Title IDs ---
  static const int _locationTitleId = 1;
  static const int _typeTitleId = 2;
  static const int _preferencesTitleId = 3;

  // --- Special Parent IDs (that show parent name with child name) ---
  static const List<int> _specialParentIds = [100, 101];

  /// Sub-item IDs that need parent context in filter buttons
  /// These are ambiguous without knowing the parent category
  static const Set<int> _needsParentContextIds = {
    158, // With in-house bakery
    159, // In bookstore
    588, // Other
  };

  /// Parent-child filter relationships for display logic.
  /// When a child is selected, the parent chip is hidden and a combined chip is shown.
  ///
  /// Format rules:
  /// - Bakery (56): "Parent lowercase_child" (no colon)
  /// - Others: "Parent: Child" (with colon)
  ///
  /// NOTE: This map is duplicated in filter_count_helper.dart for count deduplication.
  /// If adding new relationships, update both files.
  static const Map<int, List<int>> _parentChildRelationships = {
    56: [585, 586],        // Bakery → [With seating, With café]
    58: [158, 159],        // Café → [With in-house bakery, In bookstore]
    55: [588],             // Food truck → [Other]
    100: [196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207], // Sharing menu → 12 courses
    101: [184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195], // Multi-course menu → 12 courses
    // Neighborhood hierarchies
    44: [41, 42, 34],      // Indre By → Kongens Nytorv, Nyhavn, Christianshavn
    48: [35, 43],          // Amager → Islands Brygge, Ørestad
    37: [30],              // Nordvest → Bispebjerg
    31: [40],              // Vanløse → Grøndal
  };

  /// Children IDs from Bakery parent (use lowercase formatting)
  static const Set<int> _bakeryChildrenIds = {585, 586};

  /// Flattened list of all children under parent-child relationships
  static final Set<int> _allChildrenIds =
      _parentChildRelationships.values.expand((list) => list).toSet();

  // --- Lifecycle Methods ---

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (_shouldInitialize()) {
      _initializeFlattenedFilters();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _handleTextScaleChange();
  }

  @override
  void didUpdateWidget(SelectedFiltersBtns oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Rebuild if translation cache or language changes
    if (widget.translationsCache != oldWidget.translationsCache ||
        widget.languageCode != oldWidget.languageCode) {
      SelectedFiltersBtns.cachedButtonWidths.remove(widget.languageCode);
      setState(() {});
      _scheduleMeasurementIfNeeded();
    }

    if (_shouldInitialize()) {
      _initializeFlattenedFilters();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeTextScaleFactor() {
    _handleTextScaleChange();
  }

  // --- Helper Methods ---

  bool _shouldInitialize() {
    return widget.filters != null && !_initialized;
  }

  void _initializeFlattenedFilters() {
    _flattenedFilters = _flattenFilters(widget.filters);
    _initialized = true;
    _scheduleMeasurementIfNeeded();
  }

  void _handleTextScaleChange() {
    final currentScale = MediaQuery.textScalerOf(context).scale(1.0);
    if (_lastTextScaleFactor != currentScale) {
      _lastTextScaleFactor = currentScale;
      // Invalidate cached button width on text scale change
      SelectedFiltersBtns.cachedButtonWidths.remove(widget.languageCode);
      _scheduleMeasurementIfNeeded();
    }
  }

  void _scheduleMeasurementIfNeeded() {
    if (!SelectedFiltersBtns.cachedButtonWidths.containsKey(widget.languageCode)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureButtonWidth());
    }
  }

  void _measureButtonWidth() {
    final renderBox =
        _clearButtonKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null) {
      final totalWidth = renderBox.size.width + _clearButtonSpacing;
      SelectedFiltersBtns.cachedButtonWidths[widget.languageCode] = totalWidth;
      if (mounted) setState(() {});
    }
  }

  // --- Data Transformation ---

  List<Map<String, dynamic>> _flattenFilters(dynamic filtersData) {
    final flatList = <Map<String, dynamic>>[];

    // Extract the filters array from the response
    List<dynamic> filters;
    if (filtersData is Map) {
      filters = filtersData['filters'] as List<dynamic>? ?? [];
    } else if (filtersData is List) {
      filters = filtersData;
    } else {
      return [];
    }

    void traverse(
      dynamic node, {
      int? parentId,
      String? parentName,
      int? titleId,
    }) {
      if (node is! Map) return;

      final nodeType = node['type'] as String?;
      final nodeId = node['id'] as int?;
      final nodeName = node['name'] as String?;

      if (nodeType == 'title') {
        titleId = nodeId;
      } else if (nodeType != 'category' && nodeId != null && nodeName != null) {
        flatList.add({
          'id': nodeId,
          'name': nodeName,
          'parent_id': parentId,
          'parent_name': parentName,
          'type': nodeType,
          'title_id': titleId,
        });
      }

      final children = node['children'] as List<dynamic>?;
      if (children != null) {
        for (final child in children) {
          traverse(
            child,
            // For dietary food items (593-597), preserve parent context
            parentId: (nodeType == 'category' || nodeType == 'item')
                ? nodeId
                : parentId,
            parentName: (nodeType == 'category' || nodeType == 'item')
                ? nodeName
                : parentName,
            titleId: titleId,
          );
        }
      }
    }

    for (final filter in filters) {
      traverse(filter);
    }

    return flatList;
  }

  List<Map<String, dynamic>> _organizeFiltersByCategory() {
    if (_flattenedFilters == null) {
      return [];
    }

    final searchState = ref.watch(searchStateProvider);
    final selectedFilterIds = searchState.filtersUsedForSearch;

    // Include routed IDs (neighbourhood, shopping area) in chip display
    final allDisplayIds = <int>[
      ...selectedFilterIds,
      ...?searchState.selectedNeighbourhoodId,
      if (searchState.selectedShoppingAreaId != null) searchState.selectedShoppingAreaId!,
    ];

    // Filter out parents when children are selected
    // Use allDisplayIds (not just selectedFilterIds) to include routed neighbourhoods
    final parentsToHide = _findParentsToHide(allDisplayIds);
    final visibleDisplayIds = allDisplayIds.where((id) => !parentsToHide.contains(id)).toList();

    final selectedFilters = _flattenedFilters!
        .where((f) => visibleDisplayIds.contains(f['id'] as int))
        .toList();

    final categoryOrder = <int, int>{
      _locationTitleId: 1,
      _typeTitleId: 2,
      _preferencesTitleId: 3,
    };

    selectedFilters.sort((a, b) {
      final aTitleId = a['title_id'] as int?;
      final bTitleId = b['title_id'] as int?;

      final aOrder = categoryOrder[aTitleId] ?? 999;
      final bOrder = categoryOrder[bTitleId] ?? 999;

      if (aOrder != bOrder) return aOrder.compareTo(bOrder);

      final aName = (a['name'] as String? ?? '').toLowerCase();
      final bName = (b['name'] as String? ?? '').toLowerCase();
      return aName.compareTo(bName);
    });

    return selectedFilters;
  }

  String _getDisplayName(Map<String, dynamic> filter) {
    final filterId = filter['id'] as int;
    final parentId = filter['parent_id'] as int?;
    final parentName = filter['parent_name'] as String?;
    final name = filter['name'] as String;

    // Neighborhood children - use original capitalization with dash separator
    // Example: "Indre By - Kongens Nytorv"
    if (AppConstants.kNeighborhoodChildren.contains(filterId)) {
      // Look up parent from relationships map to get correct parent name
      final actualParentId = _findParentForChild(filterId);
      if (actualParentId != null) {
        final parentFilter = _flattenedFilters?.firstWhere(
          (f) => f['id'] == actualParentId,
          orElse: () => <String, dynamic>{},
        );
        final actualParentName = parentFilter?['name'] as String?;
        if (actualParentName != null) {
          return '$actualParentName - $name';
        }
      }
      // Fallback to parentName from filter if available
      if (parentName != null) {
        return '$parentName - $name';
      }
    }

    // Check if this is a dietary composite (6-digit ID starting with 593-597)
    // BUT exclude 592 ("All") which should display normally
    final filterIdStr = filterId.toString();
    final isDietaryComposite = filterIdStr.length == 6 &&
        filterId != 592 && // Exclude "All" from dietary composite formatting
        (filterIdStr.startsWith('593') ||
            filterIdStr.startsWith('594') ||
            filterIdStr.startsWith('595') ||
            filterIdStr.startsWith('596') ||
            filterIdStr.startsWith('597'));

    // Show parent context for dietary composites (e.g., "Lactose-free baguette")
    if (isDietaryComposite && parentName != null) {
      final lowercasedName = _lowercaseFirstLetter(name);
      return '$parentName $lowercasedName';
    }

    // Bakery children (585, 586) - use lowercase format like dietary composites
    // Format: "Bakery lowercase_child" (matches dietary composite pattern)
    if (_bakeryChildrenIds.contains(filterId) && parentName != null) {
      final lowercasedName = _lowercaseFirstLetter(name);
      return '$parentName $lowercasedName';
    }

    // Show parent context for specific ambiguous sub-items
    if (_needsParentContextIds.contains(filterId) && parentName != null) {
      return '$parentName: $name';
    }

    // Existing special parent logic (for IDs 100, 101)
    if (parentId != null &&
        _specialParentIds.contains(parentId) &&
        parentName != null) {
      return '$parentName: $name';
    }

    // Menu children (196-207, 184-195) and other parent-child relationships
    // Format: "Parent: Child" (with colon)
    // Check if this filter is a child in parent-child relationships
    if (_allChildrenIds.contains(filterId) &&
        !_bakeryChildrenIds.contains(filterId) &&
        parentName != null) {
      return '$parentName: $name';
    }

    return name;
  }

  /// Lowercases the first letter of a string, preserving the rest
  String _lowercaseFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toLowerCase() + text.substring(1);
  }

  /// Finds parent filter IDs that should be hidden because their children are selected.
  ///
  /// Logic: If any child from a parent-child relationship is in selectedFilterIds,
  /// hide the parent (we'll show the combined "Parent: Child" chip instead).
  ///
  /// Example: selectedFilterIds contains 585 → hide parent 56 (Bakery)
  ///          selectedFilterIds contains 196 → hide parent 100 (Sharing menu)
  Set<int> _findParentsToHide(List<int> selectedFilterIds) {
    final selectedSet = selectedFilterIds.toSet();
    final parentsToHide = <int>{};

    for (final entry in _parentChildRelationships.entries) {
      final parentId = entry.key;
      final childrenIds = entry.value;

      // If ANY child is selected, hide the parent
      final hasSelectedChild = childrenIds.any((childId) => selectedSet.contains(childId));
      if (hasSelectedChild) {
        parentsToHide.add(parentId);
      }
    }

    return parentsToHide;
  }

  // --- Action Handlers ---

  /// Handles individual filter removal - delegates search to parent.
  ///
  /// Updates filter state (toggles filter or clears routed ID) and invokes
  /// the [onFilterRemoved] callback to trigger a new search with remaining filters.
  ///
  /// For parent-child relationships:
  /// - First tap on merged chip removes child (reverts to parent)
  /// - Second tap removes parent
  void _handleFilterRemoval(int filterId) {
    final searchState = ref.read(searchStateProvider);
    final notifier = ref.read(searchStateProvider.notifier);

    // Check if this is a child in a parent-child relationship
    final parentId = _findParentForChild(filterId);

    if (parentId != null) {
      // This is a child - check if parent is also selected (merged chip scenario)
      final allSelectedIds = [
        ...searchState.filtersUsedForSearch,
        ...?searchState.selectedNeighbourhoodId,
      ];

      if (allSelectedIds.contains(parentId)) {
        // FIRST TAP: Remove child, keep parent
        // The filter overlay widget handles this - just remove the child
        notifier.toggleFilter(filterId);
        widget.onFilterRemoved?.call(filterId);
        return;
      }
    }

    // Check if this is a parent with children selected
    final childIds = _parentChildRelationships[filterId];
    if (childIds != null) {
      final allSelectedIds = [
        ...searchState.filtersUsedForSearch,
        ...?searchState.selectedNeighbourhoodId,
      ];

      final hasSelectedChild = childIds.any((id) => allSelectedIds.contains(id));
      if (hasSelectedChild) {
        // This shouldn't happen (chip shows child, not parent)
        // But handle gracefully: remove all children and parent
        for (final childId in childIds) {
          notifier.toggleFilter(childId);
        }
      }
    }

    // Default removal logic (existing)
    final isRoutedNeighbourhood = searchState.selectedNeighbourhoodId?.contains(filterId) ?? false;
    final isRoutedShoppingArea = searchState.selectedShoppingAreaId == filterId;

    if (isRoutedNeighbourhood) {
      // Clear the routed neighbourhood ID
      notifier.clearRoutedNeighbourhoodId();
    } else if (isRoutedShoppingArea) {
      // Clear the routed shopping area ID
      notifier.clearRoutedShoppingAreaId();
    } else {
      // Regular filter — toggle it off
      notifier.toggleFilter(filterId);
    }

    // Delegate search execution to the parent (stays mounted)
    widget.onFilterRemoved?.call(filterId);
  }

  /// Helper method to find parent for a child ID
  int? _findParentForChild(int childId) {
    for (final entry in _parentChildRelationships.entries) {
      if (entry.value.contains(childId)) {
        return entry.key;
      }
    }
    return null;
  }

  /// Handles "Clear All" — clears state and delegates search to parent.
  ///
  /// Clearing filters causes this widget to unmount (the parent conditionally
  /// renders it only when filters are active). An async API call here would
  /// race against the unmount and fail the `context.mounted` check, so we
  /// delegate the search execution to the parent via [onClearAll].
  void _handleClearAll() {
    // Clear all filters in state
    ref.read(searchStateProvider.notifier).clearFilters();
    // Delegate search execution to the parent (stays mounted)
    widget.onClearAll?.call();
  }

  /// Get translated text for UI keys
  String _getUIText(String key) {
    return widget.translationsCache[key] ?? key;
  }

  // --- UI Building ---

  @override
  Widget build(BuildContext context) {
    if (!_initialized || !_hasFilters()) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.only(
        top: AppSpacing.xsm,     // 6px - pairs with filter tabs bottom padding for 12px total
        bottom: AppSpacing.md,   // 12px - matches spacing between other elements
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 1.0,
          ),
        ),
      ),
      child: Stack(
        children: [
          _buildScrollableFilterButtons(),
          _buildStickyGradientClearButton(context),
        ],
      ),
    );
  }

  bool _hasFilters() {
    final searchState = ref.watch(searchStateProvider);
    return searchState.filtersUsedForSearch.isNotEmpty ||
        searchState.selectedNeighbourhoodId != null ||
        searchState.selectedShoppingAreaId != null;
  }

  Widget _buildScrollableFilterButtons() {
    final organizedFilters = _organizeFiltersByCategory();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(
            left:
                SelectedFiltersBtns.cachedButtonWidths[widget.languageCode] ?? 75,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: organizedFilters
                .map((filter) => Padding(
                      padding: const EdgeInsets.only(right: _buttonSpacing),
                      child: _buildFilterButton(filter),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(Map<String, dynamic> filter) {
    final filterId = filter['id'] as int;
    final displayName = _getDisplayName(filter);

    return ElevatedButton(
      onPressed: () => _handleFilterRemoval(filterId),
      style: _buildFilterButtonStyle(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            displayName,
            style: AppTypography.bodySm.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.green,
              height: 1.2,
            ),
          ),
          const SizedBox(width: 2),
          const Icon(
            Icons.close,
            size: _iconSize,
            color: AppColors.textPlaceholder,
          ),
        ],
      ),
    );
  }

  ButtonStyle _buildFilterButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.greenBg,
      foregroundColor: AppColors.green,
      elevation: 0,
      padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.chip),
        side: const BorderSide(color: AppColors.greenBorder, width: 1.5),
      ),
    );
  }

  Widget _buildStickyGradientClearButton(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.white,
              AppColors.white.withValues(alpha: 0.0),
            ],
            stops: const [0.7, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: _clearButtonSpacing + 2), // Add 2px gap
          child: _buildClearAllButton(),
        ),
      ),
    );
  }

  Widget _buildClearAllButton() {
    return ElevatedButton(
      key: _clearButtonKey,
      onPressed: _handleClearAll,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.accent,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
          side: const BorderSide(color: AppColors.border, width: 1.5),
        ),
      ),
      child: Text(
        _getUIText('search_clear_all'),
        style: AppTypography.bodySm.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
          height: 1.2,
        ),
      ),
    );
  }
}
