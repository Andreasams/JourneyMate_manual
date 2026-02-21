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

import 'dart:async';

/// Self-contained filter titles row with automatic count calculation
///
/// Displays three filter category titles (Location, Type, Needs) as
/// button-styled containers with: - Top and bottom borders across entire row
/// - Vertical dividers between buttons (right edge on Location and Type) - No
/// outer left/right borders - Dynamic counts calculated from
/// FFAppState.filtersUsedForSearch - Visual feedback for selected title
/// (orange text and border) - Toggle behavior (click same title to close
/// overlay) - Localized text via translation system
///
/// Layout Structure: - 3 Expanded containers - Location: top, bottom, right
/// borders (center-aligned text) - Type: top, bottom, right borders
/// (center-aligned text) - Needs: top, bottom only (center-aligned text)
///
/// State Management: - Uses FFAppState.activeSelectedTitleId for selected
/// title (0 = none/closed) - Uses FFAppState.filterOverlayOpen for overlay
/// visibility - Calls onTitleClick callback for parent page side effects only
class FilterTitlesRow extends StatefulWidget {
  const FilterTitlesRow({
    super.key,
    this.width,
    this.height,
    required this.filterData,
    required this.languageCode,
    required this.translationsCache,
    required this.onTitleClick,
  });

  final double? width;
  final double? height;
  final dynamic filterData;
  final String languageCode;
  final dynamic translationsCache;
  final Future Function(int titleId) onTitleClick;

  @override
  State<FilterTitlesRow> createState() => _FilterTitlesRowState();
}

class _FilterTitlesRowState extends State<FilterTitlesRow> {
  // ============================================================================
  // CONSTANTS
  // ============================================================================

  static const int _locationTitleId = 1;
  static const int _typeTitleId = 2;
  static const int _preferencesTitleId = 3;

  static const Color _primaryOrange = Color(0xFFe9874b);
  static const Color _primaryText = Color(0xFF14181b);
  static const Color _borderColor = Colors.black;

  /// Unified font size for all titles
  static const double _fontSize = 17.0;
  static const double _borderThickness = 1.0;

  /// Base padding values (adjusted per-button for optical alignment)
  static const double _buttonPaddingVertical = 8.0;

  static const String _locationKey = 'filter_location';
  static const String _typeKey = 'filter_type';
  static const String _preferencesKey = 'filter_preferences';

  // ============================================================================
  // STATE VARIABLES
  // ============================================================================

  Map<int, dynamic> _filterMap = {};
  Timer? _rebuildTimer;

  // ============================================================================
  // LIFECYCLE METHODS
  // ============================================================================

  @override
  void initState() {
    super.initState();
    _buildFilterMap();
    _schedulePeriodicRebuild();
  }

  @override
  void didUpdateWidget(FilterTitlesRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.filterData != oldWidget.filterData) {
      _buildFilterMap();
    }

    if (widget.translationsCache != oldWidget.translationsCache ||
        widget.languageCode != oldWidget.languageCode) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _rebuildTimer?.cancel();
    super.dispose();
  }

  // ============================================================================
  // FILTER MAP BUILDING
  // ============================================================================

  /// Builds a flat map of all filters by ID from the hierarchical filterData
  void _buildFilterMap() {
    _filterMap.clear();
    _populateFilterMap(widget.filterData);
  }

  /// Recursively populates the filter map from nested data structure
  void _populateFilterMap(dynamic data) {
    if (data == null) return;

    if (data is Map) {
      if (data.containsKey('filters')) {
        final filters = data['filters'];
        if (filters is List) {
          _populateFilterMap(filters);
          return;
        }
      }
      if (data['id'] is int) {
        _filterMap[data['id'] as int] = data;
        final children = data['children'];
        if (children != null && children is List && children.isNotEmpty) {
          _populateFilterMap(children);
        }
      }
      return;
    }

    if (data is List) {
      for (final item in data) {
        _populateFilterMap(item);
      }
    }
  }

  // ============================================================================
  // PERIODIC REBUILD SCHEDULING
  // ============================================================================

  /// Schedules periodic rebuilds to keep counts synchronized with FFAppState
  void _schedulePeriodicRebuild() {
    _rebuildTimer?.cancel();
    _rebuildTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  // ============================================================================
  // COUNT CALCULATION
  // ============================================================================

  /// Calculates how many selected filters belong to the given title
  int _calculateCount(int titleId) {
    final selectedFilters = FFAppState().filtersUsedForSearch;
    int count = 0;

    for (final filterId in selectedFilters) {
      final filter = _filterMap[filterId];
      if (filter != null) {
        final filterTitleId = _findTitleIdForFilter(filter);
        if (filterTitleId == titleId) {
          count++;
        }
      }
    }

    return count;
  }

  /// Traverses up the filter hierarchy to find the parent title ID
  int? _findTitleIdForFilter(dynamic filter) {
    var currentFilter = filter;
    while (currentFilter != null) {
      if (currentFilter['type'] == 'title') {
        return currentFilter['id'] as int?;
      }
      final parentId = currentFilter['parent_id'] as int?;
      currentFilter = parentId != null ? _filterMap[parentId] : null;
    }
    return null;
  }

  // ============================================================================
  // UI STATE HELPERS
  // ============================================================================

  /// Returns whether the given title is currently selected
  bool _isSelected(int titleId) {
    return FFAppState().filterOverlayOpen &&
        FFAppState().activeSelectedTitleId == titleId;
  }

  /// Returns the text color based on selection state
  Color _getTitleColor(int titleId) {
    return _isSelected(titleId) ? _primaryOrange : _primaryText;
  }

  // ============================================================================
  // INTERACTION HANDLERS
  // ============================================================================

  /// Handles title button clicks - toggles overlay and updates FFAppState
  Future<void> _handleTitleClick(int titleId) async {
    try {
      await markUserEngaged();
    } catch (e) {
      debugPrint('⚠️ Failed to mark engagement: $e');
    }

    FFAppState().update(() {
      if (titleId == FFAppState().activeSelectedTitleId) {
        FFAppState().filterOverlayOpen = !FFAppState().filterOverlayOpen;
      } else {
        FFAppState().activeSelectedTitleId = titleId;
        FFAppState().filterOverlayOpen = true;
      }
    });

    await widget.onTitleClick(titleId);
  }

  // ============================================================================
  // TRANSLATION HELPERS
  // ============================================================================

  /// Gets translated UI text for the given key
  String _getUIText(String key) {
    return getTranslations(widget.languageCode, key, widget.translationsCache);
  }

  /// Returns the display text for a title including count if > 0
  String _getTitleText(int titleId) {
    final key = switch (titleId) {
      _locationTitleId => _locationKey,
      _typeTitleId => _typeKey,
      _ => _preferencesKey,
    };

    final baseText = _getUIText(key);
    final count = _calculateCount(titleId);

    return count > 0 ? '$baseText ($count)' : baseText;
  }

  // ============================================================================
  // UI BUILDERS - MAIN BUILD METHOD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Row(
        children: [
          _buildButtonContainer(_locationTitleId),
          _buildButtonContainer(_typeTitleId),
          _buildButtonContainer(_preferencesTitleId),
        ],
      ),
    );
  }

  // ============================================================================
  // UI BUILDERS - BUTTON CONTAINER
  // ============================================================================

  /// Builds a button container with appropriate borders and text
  ///
  /// Border structure:
  /// - Location: top, bottom, right (vertical divider on right)
  /// - Type: top, bottom, right (vertical divider on right)
  /// - Needs: top, bottom only (no right border)
  Widget _buildButtonContainer(int titleId) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _handleTitleClick(titleId),
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            border: _getBorderForTitle(titleId),
          ),
          padding: _getButtonPadding(titleId),
          alignment: Alignment.center,
          child: Text(
            _getTitleText(titleId),
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: _fontSize,
              fontWeight:
                  _isSelected(titleId) ? FontWeight.w500 : FontWeight.w400,
              color: _getTitleColor(titleId),
            ),
            maxLines: 1,
            overflow: TextOverflow.clip,
            softWrap: false,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // UI BUILDERS - STYLING HELPERS
  // ============================================================================

  /// Returns the appropriate border for each button position
  ///
  /// - Location & Type: top, bottom, right (right acts as divider)
  /// - Needs: top, bottom only
  Border _getBorderForTitle(int titleId) {
    final borderSide = BorderSide(color: _borderColor, width: _borderThickness);

    if (titleId == _preferencesTitleId) {
      // Last button: top and bottom only, no right border
      return Border(
        top: borderSide,
        bottom: borderSide,
      );
    }

    // Location and Type: top, bottom, and right (right acts as divider)
    return Border(
      top: borderSide,
      bottom: borderSide,
      right: borderSide,
    );
  }

  /// Returns optically-adjusted padding for each button
  ///
  /// Compensates for visual weight of letter shapes:
  /// - Location: Less left padding (L has visual weight on left)
  /// - Type: Balanced padding
  /// - Needs: Less right padding (s curves away on right)
  EdgeInsets _getButtonPadding(int titleId) {
    switch (titleId) {
      case _locationTitleId:
        return EdgeInsets.fromLTRB(
            6.0, _buttonPaddingVertical, 10.0, _buttonPaddingVertical);
      case _typeTitleId:
        return EdgeInsets.symmetric(
            horizontal: 8.0, vertical: _buttonPaddingVertical);
      case _preferencesTitleId:
        return EdgeInsets.fromLTRB(
            10.0, _buttonPaddingVertical, 6.0, _buttonPaddingVertical);
      default:
        return EdgeInsets.symmetric(
            horizontal: 8.0, vertical: _buttonPaddingVertical);
    }
  }
}
