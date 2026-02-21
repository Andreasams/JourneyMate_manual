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

import 'package:collection/collection.dart';

/// A horizontal scrollable widget for filtering menu items by allergens.
///
/// This widget displays allergen buttons that users can toggle to show/hide
/// menu items containing specific allergens. Uses translations from Supabase
/// flutterflowtranslations table for 15 language support.
///
/// Visual States: - Orange button (selected): Allergen is NOT excluded -
/// items WITH this allergen are shown - Grey button (unselected): Allergen IS
/// excluded - items WITH this allergen are hidden
class AllergiesFilterWidget extends StatefulWidget {
  const AllergiesFilterWidget({
    super.key,
    this.width,
    this.height,
    required this.onAllergiesChanged,
    required this.currentLanguage,
    this.initiallyExcludedAllergyIds,
    required this.translationsCache,
    required this.currentResultCount,
  });

  final double? width;
  final double? height;
  final Future Function(List<int> excludedAllergyIds) onAllergiesChanged;
  final String currentLanguage;
  final List<int>? initiallyExcludedAllergyIds;

  /// Translation cache from FFAppState containing all localized strings.
  /// Expected to contain keys like 'allergen_1', 'allergen_2', etc.
  final dynamic translationsCache;

  /// Current number of menu items visible after filtering.
  /// Used for session-level filter impact analytics.
  final int currentResultCount;

  @override
  State<AllergiesFilterWidget> createState() => _AllergiesFilterWidgetState();
}

class _AllergiesFilterWidgetState extends State<AllergiesFilterWidget> {
  /// =========================================================================
  /// STATE & CONSTANTS
  /// =========================================================================

  /// Set of allergen IDs that are currently excluded from display.
  /// When an allergen ID is in this set, items containing that allergen are hidden.
  Set<int> _excludedAllergyIds = {};

  late final ScrollController _scrollController;

  /// Visual styling constants
  static const Color _selectedColor = Color(0xFFEE8B60);
  static const Color _unselectedColor = Color(0xFFf2f3f5);
  static const Color _selectedTextColor = Colors.white;
  static const Color _unselectedTextColor = Color(0xFF242629);
  static final Color _borderColor = Colors.grey[500]!;

  static const Duration _animationDuration = Duration(milliseconds: 200);
  static const EdgeInsets _buttonPadding = EdgeInsets.symmetric(horizontal: 16);
  static const Size _buttonMinSize = Size(0, 32);
  static const double _buttonBorderRadius = 15.0;
  static const double _buttonFontSize = 14.0;
  static const double _buttonSpacing = 8.0;

  /// Total number of allergens supported by the system (IDs 1-14)
  static const int _totalAllergenCount = 14;

  /// =========================================================================
  /// LIFECYCLE METHODS
  /// =========================================================================

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _syncStateFromParent(widget.initiallyExcludedAllergyIds);
  }

  @override
  void didUpdateWidget(covariant AllergiesFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final hasExclusionListChanged = !DeepCollectionEquality().equals(
      widget.initiallyExcludedAllergyIds,
      oldWidget.initiallyExcludedAllergyIds,
    );

    final hasLanguageChanged =
        widget.currentLanguage != oldWidget.currentLanguage;

    final hasTranslationCacheChanged =
        widget.translationsCache != oldWidget.translationsCache;

    if (hasExclusionListChanged) {
      _syncStateFromParent(widget.initiallyExcludedAllergyIds);
    } else if (hasLanguageChanged || hasTranslationCacheChanged) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// =========================================================================
  /// STATE MANAGEMENT
  /// =========================================================================

  /// Synchronizes internal exclusion state with parent-provided list.
  ///
  /// Only triggers setState if the exclusion set has actually changed,
  /// preventing unnecessary rebuilds.
  void _syncStateFromParent(List<int>? exclusionListFromParent) {
    final newExclusionSet = exclusionListFromParent?.toSet() ?? <int>{};

    final hasStateChanged = !SetEquality().equals(
      _excludedAllergyIds,
      newExclusionSet,
    );

    if (hasStateChanged) {
      setState(() {
        _excludedAllergyIds = newExclusionSet;
      });
    }
  }

  /// Toggles an allergen's exclusion state and notifies parent.
  ///
  /// When an allergen is excluded, menu items containing that allergen
  /// will be filtered out from display.
  ///
  /// Also tracks analytics and user engagement for this interaction.
  Future<void> _toggleAllergyExclusion(int allergyId) async {
    final updatedExclusionSet = Set<int>.from(_excludedAllergyIds);

    final wasExcluded = updatedExclusionSet.contains(allergyId);
    final willBeExcluded = !wasExcluded;

    willBeExcluded
        ? updatedExclusionSet.add(allergyId)
        : updatedExclusionSet.remove(allergyId);

    // Track user engagement (extends engagement window by 15s)
    markUserEngaged();

    // Track analytics event with allergen interaction details
    _trackAllergenToggle(
      allergyId: allergyId,
      isNowExcluded: willBeExcluded,
      updatedExclusionList: updatedExclusionSet.toList(),
    );

    widget.onAllergiesChanged(updatedExclusionSet.toList());

    // Update menu session-level filter metrics
    await updateMenuSessionFilterMetrics(widget.currentResultCount);
  }

  /// =========================================================================
  /// ANALYTICS TRACKING
  /// =========================================================================

  /// Tracks allergen filter toggle event to analytics backend.
  ///
  /// Captures which allergen was toggled, its new state, and the complete
  /// exclusion list to understand filtering patterns and combinations.
  ///
  /// Fire-and-forget pattern - tracking failures won't impact UX.
  void _trackAllergenToggle({
    required int allergyId,
    required bool isNowExcluded,
    required List<int> updatedExclusionList,
  }) {
    final allergyName = _getAllergenName(allergyId);

    trackAnalyticsEvent(
      'allergen_filter_toggled',
      {
        'allergen_id': allergyId,
        'allergen_name': allergyName ?? 'unknown',
        'action': isNowExcluded ? 'excluded' : 'included',
        'is_now_excluded': isNowExcluded,
        'current_excluded_allergens': updatedExclusionList,
        'excluded_count': updatedExclusionList.length,
        'language': widget.currentLanguage,
      },
    ).catchError((error) {
      debugPrint('⚠️ Failed to track allergen toggle: $error');
    });
  }

  /// =========================================================================
  /// TRANSLATION & DATA RETRIEVAL
  /// =========================================================================

  /// Gets localized allergen name using central translation function.
  ///
  /// Follows the same pattern as _getAllergenName() in generateFilterSummary.
  /// Returns null if translation is missing (indicated by empty string or ⚠️ prefix).
  ///
  /// Args:
  ///   allergenId: The allergen ID (1-14)
  ///
  /// Returns:
  ///   Localized allergen name, or null if translation not found
  String? _getAllergenName(int allergenId) {
    final translationKey = 'allergen_${allergenId}_cap';
    final allergenName = getTranslations(
      widget.currentLanguage,
      translationKey,
      widget.translationsCache,
    );

    // Return null if translation not found (indicated by ⚠️ prefix or empty)
    if (allergenName.isEmpty || allergenName.startsWith('⚠️')) {
      return null;
    }

    return allergenName;
  }

  /// Retrieves all allergen entries for display, sorted alphabetically.
  ///
  /// Generates allergen ID-name pairs (1-14) with localized names,
  /// then sorts them alphabetically by the translated name for better UX.
  /// Filters out any allergens without valid translations.
  ///
  /// Returns:
  ///   List of allergen ID-name pairs with valid translations, sorted by name
  List<MapEntry<int, String>> _getLocalizedAllergies() {
    final allergyEntries = <MapEntry<int, String>>[];

    for (int allergyId = 1; allergyId <= _totalAllergenCount; allergyId++) {
      final allergyName = _getAllergenName(allergyId);

      // Skip allergens without valid translations
      if (allergyName == null) {
        debugPrint(
            '⚠️ Missing translation for allergen_$allergyId in ${widget.currentLanguage}');
        continue;
      }

      allergyEntries.add(MapEntry(allergyId, allergyName));
    }

    // Sort alphabetically by translated allergen name
    return allergyEntries..sort((a, b) => a.value.compareTo(b.value));
  }

  /// Determines if an allergen button should be visually selected.
  ///
  /// A button is "selected" (orange) when its allergen is NOT excluded,
  /// meaning items with this allergen are currently visible.
  bool _isAllergyVisible(int allergyId) {
    return !_excludedAllergyIds.contains(allergyId);
  }

  /// =========================================================================
  /// UI BUILDERS
  /// =========================================================================

  /// Builds an animated allergen filter button.
  ///
  /// Visual state indicates whether the allergen is currently excluded:
  /// - Orange button: Allergen NOT excluded (items with this allergen shown)
  /// - Grey button: Allergen IS excluded (items with this allergen hidden)
  Widget _buildAllergyButton({
    required String allergyName,
    required bool isVisuallySelected,
    required VoidCallback onPressed,
  }) {
    return AnimatedContainer(
      duration: _animationDuration,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          padding: MaterialStateProperty.all(_buttonPadding),
          minimumSize: MaterialStateProperty.all(_buttonMinSize),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_buttonBorderRadius),
              side: isVisuallySelected
                  ? BorderSide.none
                  : BorderSide(color: _borderColor, width: 1),
            ),
          ),
          backgroundColor: MaterialStateProperty.all(
            isVisuallySelected ? _selectedColor : _unselectedColor,
          ),
          elevation: MaterialStateProperty.all(0),
          overlayColor: MaterialStateProperty.all(Colors.transparent),
        ),
        child: Text(
          allergyName,
          style: TextStyle(
            fontFamily: 'Roboto',
            color:
                isVisuallySelected ? _selectedTextColor : _unselectedTextColor,
            fontSize: _buttonFontSize,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  /// Builds an individual allergen button list item.
  Widget _buildAllergyListItem(MapEntry<int, String> allergyEntry) {
    final allergyId = allergyEntry.key;
    final allergyName = allergyEntry.value;
    final isVisible = _isAllergyVisible(allergyId);

    return _buildAllergyButton(
      allergyName: allergyName,
      isVisuallySelected: isVisible,
      onPressed: () => _toggleAllergyExclusion(allergyId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizedAllergies = _getLocalizedAllergies();

    return SizedBox(
      height: widget.height ?? _buttonMinSize.height,
      width: widget.width,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: localizedAllergies.length,
        separatorBuilder: (_, __) => const SizedBox(width: _buttonSpacing),
        itemBuilder: (_, index) =>
            _buildAllergyListItem(localizedAllergies[index]),
      ),
    );
  }
}
