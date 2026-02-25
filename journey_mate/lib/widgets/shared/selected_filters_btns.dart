import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/search_providers.dart';
import '../../providers/settings_providers.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_constants.dart';

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
  });

  final double? width;
  final double? height;
  final dynamic filters;
  final String languageCode;
  final Map<String, String> translationsCache;

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
  static const double _fontSize = 12.5;

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

  // --- Train Station Category ID ---
  static const int _trainStationCategoryId = 7;

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

    final selectedFilterIds = ref.watch(
      searchStateProvider.select((state) => state.filtersUsedForSearch),
    );

    final selectedFilters = _flattenedFilters!
        .where((f) => selectedFilterIds.contains(f['id'] as int))
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

  /// Finds a filter in the flattened list by its ID
  /// Returns null if filter not found
  Map<String, dynamic>? _getFilterById(int filterId) {
    if (_flattenedFilters == null) return null;

    try {
      return _flattenedFilters!.firstWhere(
        (filter) => filter['id'] == filterId,
        orElse: () => <String, dynamic>{},
      );
    } catch (e) {
      return null;
    }
  }

  String _getDisplayName(Map<String, dynamic> filter) {
    final filterId = filter['id'] as int;
    final parentId = filter['parent_id'] as int?;
    final parentName = filter['parent_name'] as String?;
    final name = filter['name'] as String;

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

    return name;
  }

  /// Lowercases the first letter of a string, preserving the rest
  String _lowercaseFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toLowerCase() + text.substring(1);
  }

  // --- Action Handlers ---

  /// Handles individual filter removal with integrated search execution
  Future<void> _handleFilterRemoval(int filterId) async {
    try {
      // Remove filter from state
      ref.read(searchStateProvider.notifier).toggleFilter(filterId);

      // Get user location (only if location is usable)
      Position? position;
      final locationState = ref.read(locationProvider);
      if (locationState.isLocationUsable) {
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 5),
            ),
          );
        } catch (_) {
          position = null;
        }
      }

      final userLocation = position != null
          ? '${position.latitude},${position.longitude}'
          : '0.0,0.0';

      // Read updated filters from state
      final currentFilters = ref.read(searchStateProvider).filtersUsedForSearch;

      // Check if train station filter exists
      final hasTrainStation =
          currentFilters.contains(_trainStationCategoryId) ||
              currentFilters.any((id) {
                final filter = _getFilterById(id);
                return filter?['parent_id'] == _trainStationCategoryId;
              });

      // Get train station ID if applicable
      int? trainStationId;
      if (hasTrainStation) {
        trainStationId = currentFilters.firstWhere(
          (id) {
            final filter = _getFilterById(id);
            return filter?['parent_id'] == _trainStationCategoryId;
          },
          orElse: () => -1,
        );
        if (trainStationId == -1) trainStationId = null;
      }

      // Execute search with updated filters
      final response = await ApiService.instance.search(
        filters: currentFilters,
        filtersUsedForSearch: currentFilters,
        cityId: AppConstants.kDefaultCityId.toString(),
        searchInput: ref.read(searchStateProvider).currentSearchText,
        userLocation: userLocation,
        languageCode: widget.languageCode,
        selectedStation: trainStationId,
      );

      if (response.succeeded && context.mounted) {
        // Extract result count
        final resultCount = response.jsonBody['resultCount'] as int? ??
            (response.jsonBody['documents'] as List?)?.length ??
            0;

        // Update search state
        ref.read(searchStateProvider.notifier).updateSearchResults(
              response.jsonBody,
              resultCount,
            );

        // Update filter list in state
        ref.read(searchStateProvider.notifier).setFilters(currentFilters);
      }
    } catch (e) {
      // Silent failure - errors handled by API service
    }
  }

  /// Handles "Clear All" with integrated search execution
  Future<void> _handleClearAll() async {
    try {
      // Clear all filters in state
      ref.read(searchStateProvider.notifier).clearFilters();

      // Get user location (only if location is usable)
      Position? position;
      final locationState = ref.read(locationProvider);
      if (locationState.isLocationUsable) {
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 5),
            ),
          );
        } catch (_) {
          position = null;
        }
      }

      final userLocation = position != null
          ? '${position.latitude},${position.longitude}'
          : '0.0,0.0';

      // Execute search with empty filters
      final response = await ApiService.instance.search(
        filters: [],
        filtersUsedForSearch: [],
        cityId: AppConstants.kDefaultCityId.toString(),
        searchInput: ref.read(searchStateProvider).currentSearchText,
        userLocation: userLocation,
        languageCode: widget.languageCode,
      );

      if (response.succeeded && context.mounted) {
        // Extract result count
        final resultCount = response.jsonBody['resultCount'] as int? ??
            (response.jsonBody['documents'] as List?)?.length ??
            0;

        // Update search state
        ref.read(searchStateProvider.notifier).updateSearchResults(
              response.jsonBody,
              resultCount,
            );
      }
    } catch (e) {
      // Silent failure - errors handled by API service
    }
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
        top: AppSpacing.mlg,      // 14px
        bottom: AppSpacing.sm,     // 8px
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
    final selectedFilterIds = ref.watch(
      searchStateProvider.select((state) => state.filtersUsedForSearch),
    );
    return selectedFilterIds.isNotEmpty;
  }

  Widget _buildScrollableFilterButtons() {
    final organizedFilters = _organizeFiltersByCategory();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
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
            style: const TextStyle(
              fontSize: _fontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.green,
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
      padding: const EdgeInsets.fromLTRB(12, 7, 10, 7),
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
              AppColors.bgPage,
              AppColors.bgPage.withValues(alpha: 0.0),
            ],
            stops: const [0.7, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: _clearButtonSpacing),
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
        backgroundColor: AppColors.bgPage,
        foregroundColor: AppColors.accent,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
          side: const BorderSide(color: AppColors.border, width: 1.5),
        ),
      ),
      child: Text(
        _getUIText('search_clear_all'),
        style: const TextStyle(
          fontSize: _fontSize,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
        ),
      ),
    );
  }
}
