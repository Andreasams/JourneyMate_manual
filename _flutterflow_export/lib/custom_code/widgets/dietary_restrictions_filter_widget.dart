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

import 'package:collection/collection.dart';

/// A horizontal scrollable filter widget for selecting dietary restrictions.
///
/// Features: - Automatic selection when allergen exclusions match
/// requirements - Automatic deselection when allergen exclusions no longer
/// satisfy requirements - Syncs with parent page's allergen exclusion state -
/// Localized restriction names via translation system - Smart ordering:
/// dietary needs first, then religious restrictions - Automatic rebuild when
/// translations change
///
/// Visual States: - Orange button (selected): Restriction is active - Grey
/// button (unselected): Restriction is inactive
///
/// Supported restrictions: - Gluten-free (excludes: gluten) - Lactose-free
/// (excludes: milk) - Halal (no allergen exclusions) - Kosher (no allergen
/// exclusions)
class DietaryRestrictionsFilterWidget extends StatefulWidget {
  const DietaryRestrictionsFilterWidget({
    super.key,
    this.width,
    this.height,
    required this.onDietaryRestrictionChanged,
    required this.availableDietaryRestrictions,
    required this.currentLanguage,
    required this.translationsCache,
    this.initialSelectedRestrictionId,
    required this.currentlyExcludedAllergyIdsFromParent,
    required this.currentResultCount,
  });

  final double? width;
  final double? height;
  final Future Function(
          int? selectedRestrictionId, List<int> impliedHiddenAllergens)
      onDietaryRestrictionChanged;
  final List<int> availableDietaryRestrictions;
  final String currentLanguage;
  final dynamic translationsCache;
  final int? initialSelectedRestrictionId;
  final List<int>? currentlyExcludedAllergyIdsFromParent;

  /// Current number of menu items visible after filtering.
  /// Used for session-level filter impact analytics.
  final int currentResultCount;

  @override
  State<DietaryRestrictionsFilterWidget> createState() =>
      _DietaryRestrictionsFilterWidgetState();
}

class _DietaryRestrictionsFilterWidgetState
    extends State<DietaryRestrictionsFilterWidget> {
  /// =========================================================================
  /// STATE & CONSTANTS
  /// =========================================================================

  /// Currently selected dietary restriction ID
  int? _selectedDietaryRestrictionId;

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

  /// Allergen IDs for reference
  static const int _glutenAllergenId = 2;
  static const int _milkAllergenId = 7;

  /// Dietary restriction IDs
  static const int _glutenFreeId = 1;
  static const int _lactoseFreeId = 4;
  static const int _halalId = 3;
  static const int _kosherId = 5;

  /// Maps dietary restrictions to the allergen IDs they imply should be hidden
  static const Map<int, List<int>> _restrictionToImpliedAllergensMap = {
    _glutenFreeId: [_glutenAllergenId],
    _lactoseFreeId: [_milkAllergenId],
    _halalId: [],
    _kosherId: [],
  };

  /// Restrictions eligible for automatic selection based on exact allergen match
  static const Set<int> _autoSelectableRestrictionIds = {
    _glutenFreeId,
    _lactoseFreeId,
  };

  /// Custom display order: dietary needs first, then religious restrictions
  static const List<int> _preferredOrder = [
    _glutenFreeId,
    _lactoseFreeId,
    _halalId,
    _kosherId,
  ];

  /// =========================================================================
  /// LIFECYCLE METHODS
  /// =========================================================================

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _selectedDietaryRestrictionId = widget.initialSelectedRestrictionId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _validateCurrentRestrictionAgainstParentAllergens(isInitialSync: true);
      }
    });
  }

  @override
  void didUpdateWidget(covariant DietaryRestrictionsFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Rebuild if translation cache or language changes
    if (widget.translationsCache != oldWidget.translationsCache ||
        widget.currentLanguage != oldWidget.currentLanguage) {
      setState(() {
        // Trigger rebuild with new translations
      });
    }

    _handleRestrictionPropChanges(oldWidget);
    _handleAllergenPropChanges(oldWidget);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// =========================================================================
  /// TRANSLATION HELPERS
  /// =========================================================================

  /// Gets localized UI text using central translation function
  String _getUIText(String key) {
    return getTranslations(
        widget.currentLanguage, key, widget.translationsCache);
  }

  /// Gets dietary restriction name by ID safely.
  ///
  /// Returns null if ID is null/0 or translation is missing,
  /// preventing attempts to translate invalid keys like "dietary_0".
  ///
  /// Args:
  ///   restrictionId: The restriction ID (1,3,4,5)
  ///
  /// Returns:
  ///   Localized restriction name, or null if invalid/missing
  String? _getRestrictionNameSafe(int? restrictionId) {
    // Guard: null or zero ID
    if (restrictionId == null || restrictionId == 0) {
      return null;
    }

    final translationKey = 'dietary_${restrictionId}_cap';
    final restrictionName = _getUIText(translationKey);

    // Return null if translation not found (indicated by empty or ⚠️ prefix)
    if (restrictionName.isEmpty || restrictionName.startsWith('⚠️')) {
      debugPrint(
          '⚠️ Missing translation for $translationKey in ${widget.currentLanguage}');
      return null;
    }

    return restrictionName;
  }

  /// Gets dietary restriction name by ID (non-null variant for internal use).
  ///
  /// This is only called when we know the ID is valid (from availableDietaryRestrictions).
  /// Returns a fallback string if translation fails.
  String _getRestrictionName(int restrictionId) {
    return _getRestrictionNameSafe(restrictionId) ??
        'Restriction $restrictionId'; // Fallback
  }

  /// =========================================================================
  /// WIDGET UPDATE HANDLERS
  /// =========================================================================

  /// Handles changes to the selected restriction prop from parent
  void _handleRestrictionPropChanges(
      DietaryRestrictionsFilterWidget oldWidget) {
    final restrictionPropChanged = widget.initialSelectedRestrictionId !=
        oldWidget.initialSelectedRestrictionId;

    if (restrictionPropChanged &&
        _selectedDietaryRestrictionId != widget.initialSelectedRestrictionId) {
      setState(() {
        _selectedDietaryRestrictionId = widget.initialSelectedRestrictionId;
      });
      _validateCurrentRestrictionAgainstParentAllergens(
          triggerCallbackIfChanged: true);
    }
  }

  /// Handles changes to the excluded allergen list from parent
  void _handleAllergenPropChanges(DietaryRestrictionsFilterWidget oldWidget) {
    final parentAllergensPropChanged = !DeepCollectionEquality().equals(
      widget.currentlyExcludedAllergyIdsFromParent ?? [],
      oldWidget.currentlyExcludedAllergyIdsFromParent ?? [],
    );

    if (parentAllergensPropChanged &&
        widget.initialSelectedRestrictionId ==
            oldWidget.initialSelectedRestrictionId) {
      _validateCurrentRestrictionAgainstParentAllergens(
          triggerCallbackIfChanged: true);
    }
  }

  /// =========================================================================
  /// VALIDATION & AUTO-SELECTION LOGIC
  /// =========================================================================

  /// Validates current restriction against parent's allergen exclusions.
  void _validateCurrentRestrictionAgainstParentAllergens({
    bool triggerCallbackIfChanged = false,
    bool isInitialSync = false,
  }) {
    final validationResult = _performValidation();
    final restrictionChanged = _applyValidationResult(validationResult);
    _triggerCallbackIfNeeded(validationResult, restrictionChanged,
        isInitialSync, triggerCallbackIfChanged);
  }

  /// Performs the validation logic and returns the result
  _ValidationResult _performValidation() {
    final parentExcludedSet =
        Set<int>.from(widget.currentlyExcludedAllergyIdsFromParent ?? []);

    // First, check if we should auto-select a restriction
    final autoSelectedRestriction = _attemptAutoSelection(parentExcludedSet);
    if (autoSelectedRestriction.restrictionId != null) {
      return autoSelectedRestriction;
    }

    // If no auto-selection, validate existing selection (if any)
    if (_selectedDietaryRestrictionId != null) {
      return _validateExistingRestriction(parentExcludedSet);
    }

    // No selection, no auto-selection possible
    return _ValidationResult(restrictionId: null, impliedAllergens: []);
  }

  /// Validates if the currently selected restriction is still valid
  _ValidationResult _validateExistingRestriction(Set<int> parentExcludedSet) {
    final requiredHiddenByRestriction =
        _restrictionToImpliedAllergensMap[_selectedDietaryRestrictionId!];

    if (requiredHiddenByRestriction == null ||
        requiredHiddenByRestriction.isEmpty) {
      return _ValidationResult(
        restrictionId: _selectedDietaryRestrictionId,
        impliedAllergens: [],
      );
    }

    final stillValid =
        _areAllergensStillValid(requiredHiddenByRestriction, parentExcludedSet);

    if (stillValid) {
      return _ValidationResult(
        restrictionId: _selectedDietaryRestrictionId,
        impliedAllergens: List<int>.from(requiredHiddenByRestriction),
      );
    } else {
      return _ValidationResult(
        restrictionId: null,
        impliedAllergens: [],
      );
    }
  }

  /// Checks if all required allergens are still excluded
  bool _areAllergensStillValid(
      List<int> requiredAllergens, Set<int> parentExcludedSet) {
    return requiredAllergens
        .every((allergenId) => parentExcludedSet.contains(allergenId));
  }

  /// Attempts to auto-select a restriction based on allergen exclusions
  _ValidationResult _attemptAutoSelection(Set<int> parentExcludedSet) {
    // Only auto-select if allergens EXACTLY match a restriction's requirements
    for (var entry in _restrictionToImpliedAllergensMap.entries) {
      final restrictionId = entry.key;
      final requiredAllergens = entry.value;

      // Skip restrictions without allergen requirements
      if (requiredAllergens.isEmpty) continue;

      // Skip if not in available list
      if (!widget.availableDietaryRestrictions.contains(restrictionId))
        continue;

      // Skip if not auto-selectable
      if (!_autoSelectableRestrictionIds.contains(restrictionId)) continue;

      // Check for exact match
      final requiredSet = Set<int>.from(requiredAllergens);
      if (SetEquality().equals(parentExcludedSet, requiredSet)) {
        return _ValidationResult(
          restrictionId: restrictionId,
          impliedAllergens: List<int>.from(requiredAllergens),
        );
      }
    }

    return _ValidationResult(restrictionId: null, impliedAllergens: []);
  }

  /// Applies the validation result to internal state
  bool _applyValidationResult(_ValidationResult result) {
    final restrictionChanged =
        _selectedDietaryRestrictionId != result.restrictionId;

    if (restrictionChanged) {
      setState(() {
        _selectedDietaryRestrictionId = result.restrictionId;
      });
    }

    return restrictionChanged;
  }

  /// Triggers callback to parent if conditions are met
  void _triggerCallbackIfNeeded(
    _ValidationResult result,
    bool restrictionChanged,
    bool isInitialSync,
    bool triggerCallbackIfChanged,
  ) {
    final shouldTrigger = _shouldTriggerCallback(
        restrictionChanged, isInitialSync, triggerCallbackIfChanged);

    if (shouldTrigger) {
      final impliedAllergens = _determineImpliedAllergensForCallback(
          result, restrictionChanged, isInitialSync);
      widget.onDietaryRestrictionChanged(
          _selectedDietaryRestrictionId, impliedAllergens);
    }
  }

  /// Determines if callback should be triggered
  bool _shouldTriggerCallback(bool restrictionChanged, bool isInitialSync,
      bool triggerCallbackIfChanged) {
    return (restrictionChanged && triggerCallbackIfChanged) || isInitialSync;
  }

  /// Determines the implied allergens list for the callback
  List<int> _determineImpliedAllergensForCallback(
    _ValidationResult result,
    bool restrictionChanged,
    bool isInitialSync,
  ) {
    if (isInitialSync &&
        !restrictionChanged &&
        _selectedDietaryRestrictionId != null) {
      return List<int>.from(
          _restrictionToImpliedAllergensMap[_selectedDietaryRestrictionId!] ??
              []);
    }
    return result.impliedAllergens;
  }

  /// =========================================================================
  /// USER INTERACTION HANDLERS
  /// =========================================================================

  /// Handles user selection/deselection of a dietary restriction
  Future<void> _selectDietaryRestriction(int restrictionId) async {
    final selectionResult = _determineSelectionResult(restrictionId);

    // Track user engagement
    markUserEngaged();

    // Track analytics event
    _trackRestrictionToggle(restrictionId, selectionResult);

    _applyUserSelection(selectionResult);
    _notifyParentOfUserSelection(selectionResult);

    // Update menu session-level filter metrics
    await updateMenuSessionFilterMetrics(widget.currentResultCount);
  }

  /// Determines the result of user's selection action
  _SelectionResult _determineSelectionResult(int restrictionId) {
    final isDeselecting = _selectedDietaryRestrictionId == restrictionId;

    if (isDeselecting) {
      return _SelectionResult(restrictionId: null, impliedAllergens: []);
    } else {
      return _SelectionResult(
        restrictionId: restrictionId,
        impliedAllergens: List<int>.from(
            _restrictionToImpliedAllergensMap[restrictionId] ?? []),
      );
    }
  }

  /// Applies user's selection to internal state
  void _applyUserSelection(_SelectionResult result) {
    if (_selectedDietaryRestrictionId != result.restrictionId) {
      setState(() {
        _selectedDietaryRestrictionId = result.restrictionId;
      });
    }
  }

  /// Notifies parent of user's selection change
  void _notifyParentOfUserSelection(_SelectionResult result) {
    widget.onDietaryRestrictionChanged(
        result.restrictionId, result.impliedAllergens);
  }

  /// =========================================================================
  /// ANALYTICS TRACKING
  /// =========================================================================

  /// Tracks dietary restriction toggle event to analytics backend.
  ///
  /// Captures which restriction was toggled, its new state, and implied allergens
  /// to understand filtering patterns and dietary preference combinations.
  void _trackRestrictionToggle(
      int restrictionId, _SelectionResult selectionResult) {
    final restrictionName = _getRestrictionName(restrictionId);
    final isNowSelected = selectionResult.restrictionId != null;

    trackAnalyticsEvent(
      'dietary_restriction_toggled',
      {
        'restriction_id': restrictionId,
        'restriction_name': restrictionName,
        'action': isNowSelected ? 'selected' : 'deselected',
        'is_now_selected': isNowSelected,
        'implied_allergen_exclusions': selectionResult.impliedAllergens,
        'implied_allergen_count': selectionResult.impliedAllergens.length,
        'language': widget.currentLanguage,
      },
    ).catchError((error) {
      debugPrint('⚠️ Failed to track restriction toggle: $error');
    });
  }

  /// =========================================================================
  /// DATA RETRIEVAL & TRANSFORMATION
  /// =========================================================================

  /// Gets localized and sorted dietary restrictions for display.
  ///
  /// Filters out any restrictions without valid translations to prevent
  /// display of invalid items.
  List<MapEntry<int, String>> _getLocalizedAndSortedRestrictions() {
    final availableRestrictions = widget.availableDietaryRestrictions
        .map((id) {
          final name = _getRestrictionNameSafe(id);
          return name != null ? MapEntry(id, name) : null;
        })
        .whereType<MapEntry<int, String>>() // Filter out nulls
        .toList();

    return _sortRestrictionsByPreferredOrder(availableRestrictions);
  }

  /// Sorts restrictions by preferred order
  List<MapEntry<int, String>> _sortRestrictionsByPreferredOrder(
      List<MapEntry<int, String>> entries) {
    entries.sort((a, b) {
      final indexA = _preferredOrder.indexOf(a.key);
      final indexB = _preferredOrder.indexOf(b.key);

      if (indexA != -1 && indexB != -1) return indexA.compareTo(indexB);
      if (indexA != -1) return -1;
      if (indexB != -1) return 1;
      return a.key.compareTo(b.key);
    });

    return entries;
  }

  /// =========================================================================
  /// UI BUILDERS
  /// =========================================================================

  @override
  Widget build(BuildContext context) {
    final sortedRestrictions = _getLocalizedAndSortedRestrictions();

    return SizedBox(
      height: widget.height ?? _buttonMinSize.height,
      width: widget.width,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: sortedRestrictions.length,
        separatorBuilder: (_, __) => const SizedBox(width: _buttonSpacing),
        itemBuilder: (_, index) =>
            _buildRestrictionButton(sortedRestrictions[index]),
      ),
    );
  }

  /// Builds a single dietary restriction button
  Widget _buildRestrictionButton(MapEntry<int, String> entry) {
    final restrictionId = entry.key;
    final restrictionName = entry.value;
    final isSelected = _selectedDietaryRestrictionId == restrictionId;

    return _buildButton(
      text: restrictionName,
      isSelected: isSelected,
      onPressed: () => _selectDietaryRestriction(restrictionId),
    );
  }

  /// Builds an animated button with consistent styling
  Widget _buildButton({
    required String text,
    required bool isSelected,
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
              side: isSelected
                  ? BorderSide.none
                  : BorderSide(color: _borderColor, width: 1),
            ),
          ),
          backgroundColor: MaterialStateProperty.all(
              isSelected ? _selectedColor : _unselectedColor),
          elevation: MaterialStateProperty.all(0),
          overlayColor: MaterialStateProperty.all(Colors.transparent),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Roboto',
            color: isSelected ? _selectedTextColor : _unselectedTextColor,
            fontSize: _buttonFontSize,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
/// HELPER CLASSES
/// ============================================================================

/// Result of validation logic
class _ValidationResult {
  final int? restrictionId;
  final List<int> impliedAllergens;

  _ValidationResult({
    required this.restrictionId,
    required this.impliedAllergens,
  });
}

/// Result of user selection action
class _SelectionResult {
  final int? restrictionId;
  final List<int> impliedAllergens;

  _SelectionResult({
    required this.restrictionId,
    required this.impliedAllergens,
  });
}
