// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/widgets/index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

/// Displays selected filters as removable buttons with a "Clear All" action.
///
/// Features: - Shows filters organized by category (Location, Type,
/// Preferences) - Sticky "Clear All" button that remains visible during
/// horizontal scrolling - Self-contained search execution on filter
/// removal/clear - Reads filter state from FFAppState as single source of
/// truth - Localized button text via translation system - Automatic button
/// width caching for performance - Accessibility support with text scaling -
/// Automatic rebuild when translations change
class SelectedFiltersBtns extends StatefulWidget {
  const SelectedFiltersBtns({
    super.key,
    this.width,
    this.height,
    required this.filters,
    this.selectedFilterIds,
    this.removeFilter,
    required this.onLocationFiltersCount,
    required this.onTypeFiltersCount,
    required this.onPreferencesFiltersCount,
    this.onClearAll,
    required this.languageCode,
    required this.translationsCache,
    required this.buttonRowMayLoad,
    this.onSearchCompleted,
  });

  final double? width;
  final double? height;
  final dynamic filters;
  final List<int>? selectedFilterIds;
  final Future Function(int idOfFilterToRemove)? removeFilter;
  final Future Function(int count) onLocationFiltersCount;
  final Future Function(int count) onTypeFiltersCount;
  final Future Function(int count) onPreferencesFiltersCount;
  final Future Function()? onClearAll;
  final String languageCode;
  final dynamic translationsCache;
  final bool buttonRowMayLoad;

  /// Callback fired after search completes to update parent page state
  /// Parameters: activeFilterIds (List<int>), resultCount (int)
  final Future Function(List<int> activeFilterIds, int resultCount)?
      onSearchCompleted;

  /// Static cache for "Clear All" button widths by language
  static Map<String, double> cachedButtonWidths = {};

  @override
  State<SelectedFiltersBtns> createState() => _SelectedFiltersBtnsState();
}

class _SelectedFiltersBtnsState extends State<SelectedFiltersBtns>
    with WidgetsBindingObserver {
  // --- State ---
  List<Map<String, dynamic>>? _flattenedFilters;
  bool _initialized = false;
  final GlobalKey _clearButtonKey = GlobalKey();
  double? _lastTextScaleFactor;

  // --- Style Constants ---
  static const Color _selectedColor = Color(0xFFdcdee0);
  static const Color _unselectedColor = Color(0xFFf2f3f5);
  static const Color _selectedTextColor = Color(0xFF242629);
  static const Color _unselectedTextColor = Color(0xFF242629);
  static final Color _borderColor = Colors.grey[500]!;

  static const double _buttonHeight = 32.0;
  static const double _buttonSpacing = 6.0;
  static const double _clearButtonSpacing = 8.0;
  static const double _iconSize = 12.0;
  static const double _fontSize = 12.0;

  // --- Category Title IDs ---
  static const int _locationTitleId = 1;
  static const int _typeTitleId = 2;
  static const int _preferencesTitleId = 3;

  // --- Special Parent IDs (that show parent name with child name) ---
  static const List<int> _specialParentIds = [100, 101];

  /// Sub-item IDs that need parent context in filter buttons
  /// These are ambiguous without knowing the parent category
  static const Set<int> _needsParentContextIds = {
    // Café sub-items that are ambiguous without "Café:" prefix
    158, // With in-house bakery
    159, // In bookstore
    // Food truck
    588, // Other
  };

  // --- Train Station Category ID ---
  static const int _trainStationCategoryId = 7;

  // --- Translation Keys ---
  static const String _clearAllKey = 'search_clear_all';

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

    if (!widget.buttonRowMayLoad) return;

    final needsReinit = _needsReinitialization(oldWidget);
    if (needsReinit) {
      _initializeFlattenedFilters();
      _scheduleMeasurementIfNeeded();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // --- Translation Helpers ---

  String _getUIText(String key) {
    return getTranslations(widget.languageCode, key, widget.translationsCache);
  }

  // --- Initialization Logic ---

  bool _shouldInitialize() {
    return widget.buttonRowMayLoad &&
        widget.selectedFilterIds != null &&
        widget.selectedFilterIds!.isNotEmpty;
  }

  bool _needsReinitialization(SelectedFiltersBtns oldWidget) {
    return widget.selectedFilterIds != null &&
        widget.selectedFilterIds!.isNotEmpty &&
        (!_initialized ||
            oldWidget.selectedFilterIds != widget.selectedFilterIds ||
            oldWidget.filters != widget.filters);
  }

  void _initializeFlattenedFilters() {
    if (!mounted) return;

    try {
      _flattenedFilters = _flattenFilters(widget.filters);
      _initialized = true;
      if (mounted) setState(() {});
    } catch (e) {
      // Silent failure - widget will show nothing if initialization fails
      _initialized = true;
    }
  }

  void _scheduleMeasurementIfNeeded() {
    if (!SelectedFiltersBtns.cachedButtonWidths
        .containsKey(widget.languageCode)) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _measureButtonWidth());
    }
  }

  void _handleTextScaleChange() {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    if (_lastTextScaleFactor != textScaleFactor) {
      _lastTextScaleFactor = textScaleFactor;
      SelectedFiltersBtns.cachedButtonWidths.clear();

      if (_initialized) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _measureButtonWidth());
      }
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
    if (_flattenedFilters == null || widget.selectedFilterIds == null) {
      return [];
    }

    final selectedFilters = _flattenedFilters!
        .where((f) => widget.selectedFilterIds!.contains(f['id'] as int))
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
  /// Reads updated filter list from FFAppState after removeFilter callback
  Future<void> _handleFilterRemoval(int filterId) async {
    try {
      // Mark user as engaged when removing filters
      try {
        await markUserEngaged();
      } catch (e) {
        // Silent failure for engagement tracking
      }

      // Update category count
      _updateCategoryCountForRemoval(filterId);

      // Call parent's removeFilter callback to update FFAppState
      await widget.removeFilter?.call(filterId);

      // Read updated filters from FFAppState (single source of truth)
      final currentFilters = FFAppState().filtersUsedForSearch ?? <int>[];

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

      // Execute search with current FFAppState filters
      final result = await performSearchAndUpdateState(
        FFAppState().currentSearchText ?? '',
        currentFilters,
        hasTrainStation,
        trainStationId,
        true, // shouldTrackAnalytics
        false, // filterOverlayWasOpen
        widget.languageCode,
      );

      // Notify parent to update page state
      // Extract only primitive types to avoid serialization errors
      if (widget.onSearchCompleted != null && result != null) {
        try {
          // Safely extract primitive data from result
          final activeFilterIds = <int>[];
          final rawActiveFilters = result['activeFilterIds'];

          if (rawActiveFilters is List) {
            for (final item in rawActiveFilters) {
              if (item is int) {
                activeFilterIds.add(item);
              }
            }
          }

          final resultCount =
              result['resultCount'] is int ? result['resultCount'] as int : 0;

          await widget.onSearchCompleted?.call(
            activeFilterIds,
            resultCount,
          );
        } catch (e) {
          // Silent failure if callback has serialization issues
        }
      }
    } catch (e) {
      // Silent failure - search errors should be handled by performSearchAndUpdateState
    }
  }

  void _updateCategoryCountForRemoval(int filterId) {
    final filter = _getFilterById(filterId);
    if (filter == null) return;

    final titleId = filter['title_id'] as int?;
    if (titleId == null) return;

    switch (titleId) {
      case _locationTitleId:
        widget.onLocationFiltersCount(-1);
        break;
      case _typeTitleId:
        widget.onTypeFiltersCount(-1);
        break;
      case _preferencesTitleId:
        widget.onPreferencesFiltersCount(-1);
        break;
    }
  }

  /// Handles "Clear All" with integrated search execution
  /// Reads updated filter list from FFAppState after onClearAll callback
  Future<void> _handleClearAll() async {
    try {
      // Mark user as engaged when clearing filters
      try {
        await markUserEngaged();
      } catch (e) {
        // Silent failure for engagement tracking
      }

      // Call parent's onClearAll callback to update FFAppState
      await widget.onClearAll?.call();

      // Read updated filters from FFAppState (should be empty after clear)
      final currentFilters = FFAppState().filtersUsedForSearch ?? <int>[];

      // Execute search with current FFAppState filters
      final result = await performSearchAndUpdateState(
        FFAppState().currentSearchText ?? '',
        currentFilters,
        false, // hasTrainStation
        null, // trainStationId
        true, // shouldTrackAnalytics
        false, // filterOverlayWasOpen
        widget.languageCode,
      );

      // Notify parent to update page state
      // Extract only primitive types to avoid serialization errors
      if (widget.onSearchCompleted != null && result != null) {
        try {
          // Safely extract primitive data from result
          final activeFilterIds = <int>[];
          final rawActiveFilters = result['activeFilterIds'];

          if (rawActiveFilters is List) {
            for (final item in rawActiveFilters) {
              if (item is int) {
                activeFilterIds.add(item);
              }
            }
          }

          final resultCount =
              result['resultCount'] is int ? result['resultCount'] as int : 0;

          await widget.onSearchCompleted?.call(
            activeFilterIds,
            resultCount,
          );
        } catch (e) {
          // Silent failure if callback has serialization issues
        }
      }
    } catch (e) {
      // Silent failure - search errors should be handled by performSearchAndUpdateState
    }
  }

  // --- UI Building ---

  @override
  Widget build(BuildContext context) {
    if (!widget.buttonRowMayLoad || !_initialized || !_hasFilters()) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        _buildScrollableFilterButtons(),
        _buildStickyGradientClearButton(context),
      ],
    );
  }

  bool _hasFilters() {
    return widget.selectedFilterIds != null &&
        widget.selectedFilterIds!.isNotEmpty;
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
          crossAxisAlignment: CrossAxisAlignment.center,
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

    return SizedBox(
      height: _buttonHeight,
      child: ElevatedButton(
        onPressed: () => _handleFilterRemoval(filterId),
        style: _buildFilterButtonStyle(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              displayName,
              style: const TextStyle(
                fontSize: _fontSize,
                fontWeight: FontWeight.w400,
                color: _unselectedTextColor,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.close,
              size: _iconSize,
              color: _unselectedTextColor,
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _buildFilterButtonStyle() {
    return ButtonStyle(
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 12),
      ),
      minimumSize: MaterialStateProperty.all(const Size(0, _buttonHeight)),
      shape: MaterialStateProperty.resolveWith<OutlinedBorder>(
        (states) => RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: _borderColor, width: 1),
        ),
      ),
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (states) => states.contains(MaterialState.pressed)
            ? _selectedColor
            : _unselectedColor,
      ),
      elevation: MaterialStateProperty.all(0),
      overlayColor: MaterialStateProperty.all(Colors.transparent),
    );
  }

  Widget _buildStickyGradientClearButton(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: Center(
        child: Container(
          key: _clearButtonKey,
          height: _buttonHeight,
          decoration: _buildGradientDecoration(context),
          padding: const EdgeInsets.only(right: 0),
          child: _buildClearAllButton(),
        ),
      ),
    );
  }

  BoxDecoration _buildGradientDecoration(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return BoxDecoration(
      color: bgColor,
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          bgColor,
          bgColor,
          bgColor.withOpacity(0.9),
          bgColor.withOpacity(0),
        ],
        stops: const [0.0, 0.7, 0.85, 1.0],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withOpacity(0.04),
          blurRadius: 2,
          offset: const Offset(2, 0),
          spreadRadius: 1,
        ),
      ],
    );
  }

  Widget _buildClearAllButton() {
    return ElevatedButton(
      onPressed: _handleClearAll,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        minimumSize: const Size(0, _buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.red, width: 1),
        ),
        backgroundColor: const Color(0xFFFEEBED),
        foregroundColor: const Color(0xFFFF5963),
        elevation: 0,
      ),
      child: Text(
        _getUIText(_clearAllKey),
        style: const TextStyle(
          fontSize: _fontSize,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
