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

/// A horizontal scrollable filter widget for selecting dietary preferences.
///
/// Features: - Validation against parent allergen exclusions - Syncs with
/// parent page's allergen exclusion state - Aware of current restriction to
/// properly calculate auto-selection - Localized preference names via
/// translation system - Alphabetically sorted display - Automatic rebuild
/// when translations change
///
/// Visual States: - Orange button (selected): Preference is active - Grey
/// button (unselected): Preference is inactive
///
/// Supported preferences: - Vegan (excludes: milk, eggs, fish, crustaceans,
/// molluscs) - Vegetarian (excludes: fish, crustaceans, molluscs) -
/// Pescetarian-friendly (no allergen exclusions)
class DietaryPreferencesFilterWidgets extends StatefulWidget {
  const DietaryPreferencesFilterWidgets({
    super.key,
    this.width,
    this.height,
    required this.onDietaryPreferenceChanged,
    required this.availableDietaryPreferences,
    required this.currentLanguage,
    required this.translationsCache,
    this.initialSelectedPreferenceId,
    required this.currentlyExcludedAllergyIdsFromParent,
    required this.currentResultCount,
    this.currentSelectedRestrictionId,
  });

  final double? width;
  final double? height;
  final Future Function(
          int? selectedPreferenceId, List<int> impliedHiddenAllergens)
      onDietaryPreferenceChanged;
  final List<int> availableDietaryPreferences;
  final String currentLanguage;
  final dynamic translationsCache;
  final int? initialSelectedPreferenceId;
  final List<int>? currentlyExcludedAllergyIdsFromParent;

  /// Current number of menu items visible after filtering.
  /// Used for session-level filter impact analytics.
  final int currentResultCount;

  /// Currently selected restriction ID from parent (if any)
  /// Used to calculate which allergens are implied by restriction vs preference
  final int? currentSelectedRestrictionId;

  @override
  State<DietaryPreferencesFilterWidgets> createState() =>
      _DietaryPreferencesFilterWidgetsState();
}

class _DietaryPreferencesFilterWidgetsState
    extends State<DietaryPreferencesFilterWidgets> {
  /// =========================================================================
  /// STATE & CONSTANTS
  /// =========================================================================

  /// Currently selected dietary preference ID
  int? _selectedDietaryPreferenceId;

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
  static const int _milkAllergenId = 7;
  static const int _eggsAllergenId = 4;
  static const int _fishAllergenId = 5;
  static const int _crustaceansAllergenId = 3;
  static const int _molluscsAllergenId = 8;

  /// Dietary preference IDs
  static const int _veganId = 6;
  static const int _vegetarianId = 7;
  static const int _pescetarianId = 2;

  /// Maps dietary preferences to the allergen IDs they imply should be hidden
  static const Map<int, List<int>> _preferenceToImpliedAllergensMap = {
    _veganId: [
      _milkAllergenId,
      _eggsAllergenId,
      _fishAllergenId,
      _crustaceansAllergenId,
      _molluscsAllergenId
    ],
    _vegetarianId: [
      _fishAllergenId,
      _crustaceansAllergenId,
      _molluscsAllergenId
    ],
    _pescetarianId: [],
  };

  /// Preferences eligible for automatic selection based on exact allergen match
  /// NOTE: Empty set - no auto-selection for preferences to avoid conflicts
  static const Set<int> _autoSelectablePreferenceIds = <int>{};

  /// =========================================================================
  /// LIFECYCLE METHODS
  /// =========================================================================

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _selectedDietaryPreferenceId = widget.initialSelectedPreferenceId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _validateCurrentPreferenceAgainstParentAllergens(isInitialSync: true);
      }
    });
  }

  @override
  void didUpdateWidget(covariant DietaryPreferencesFilterWidgets oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Rebuild if translation cache or language changes
    if (widget.translationsCache != oldWidget.translationsCache ||
        widget.currentLanguage != oldWidget.currentLanguage) {
      setState(() {
        // Trigger rebuild with new translations
      });
    }

    _handlePreferencePropChanges(oldWidget);
    _handleAllergenPropChanges(oldWidget);
    _handleRestrictionPropChanges(oldWidget);
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

  /// Gets dietary preference name by ID safely.
  ///
  /// Returns null if ID is null/0 or translation is missing,
  /// preventing attempts to translate invalid keys like "dietary_0".
  ///
  /// Args:
  ///   preferenceId: The preference ID (2,6,7)
  ///
  /// Returns:
  ///   Localized preference name, or null if invalid/missing
  String? _getPreferenceNameSafe(int? preferenceId) {
    // Guard: null or zero ID
    if (preferenceId == null || preferenceId == 0) {
      return null;
    }

    final translationKey = 'dietary_${preferenceId}_cap';
    final preferenceName = _getUIText(translationKey);

    // Return null if translation not found (indicated by empty or ⚠️ prefix)
    if (preferenceName.isEmpty || preferenceName.startsWith('⚠️')) {
      debugPrint(
          '⚠️ Missing translation for $translationKey in ${widget.currentLanguage}');
      return null;
    }

    return preferenceName;
  }

  /// Gets dietary preference name by ID (non-null variant for internal use).
  ///
  /// This is only called when we know the ID is valid (from availableDietaryPreferences).
  /// Returns a fallback string if translation fails.
  String _getPreferenceName(int preferenceId) {
    return _getPreferenceNameSafe(preferenceId) ??
        'Preference $preferenceId'; // Fallback
  }

  /// =========================================================================
  /// WIDGET UPDATE HANDLERS
  /// =========================================================================

  /// Handles changes to the selected preference prop from parent
  void _handlePreferencePropChanges(DietaryPreferencesFilterWidgets oldWidget) {
    final preferencePropChanged = widget.initialSelectedPreferenceId !=
        oldWidget.initialSelectedPreferenceId;

    if (preferencePropChanged &&
        _selectedDietaryPreferenceId != widget.initialSelectedPreferenceId) {
      setState(() {
        _selectedDietaryPreferenceId = widget.initialSelectedPreferenceId;
      });
      _validateCurrentPreferenceAgainstParentAllergens(
          triggerCallbackIfChanged: true);
    }
  }

  /// Handles changes to the excluded allergen list from parent
  void _handleAllergenPropChanges(DietaryPreferencesFilterWidgets oldWidget) {
    final parentAllergensPropChanged = !DeepCollectionEquality().equals(
      widget.currentlyExcludedAllergyIdsFromParent ?? [],
      oldWidget.currentlyExcludedAllergyIdsFromParent ?? [],
    );

    if (parentAllergensPropChanged &&
        widget.initialSelectedPreferenceId ==
            oldWidget.initialSelectedPreferenceId) {
      _validateCurrentPreferenceAgainstParentAllergens(
          triggerCallbackIfChanged: true);
    }
  }

  /// Handles changes to the selected restriction from parent
  void _handleRestrictionPropChanges(
      DietaryPreferencesFilterWidgets oldWidget) {
    final restrictionPropChanged = widget.currentSelectedRestrictionId !=
        oldWidget.currentSelectedRestrictionId;

    if (restrictionPropChanged) {
      _validateCurrentPreferenceAgainstParentAllergens(
          triggerCallbackIfChanged: true);
    }
  }

  /// =========================================================================
  /// VALIDATION & AUTO-SELECTION LOGIC
  /// =========================================================================

  /// Validates current preference against parent's allergen exclusions.
  void _validateCurrentPreferenceAgainstParentAllergens({
    bool triggerCallbackIfChanged = false,
    bool isInitialSync = false,
  }) {
    final validationResult = _performValidation();
    final preferenceChanged = _applyValidationResult(validationResult);
    _triggerCallbackIfNeeded(validationResult, preferenceChanged, isInitialSync,
        triggerCallbackIfChanged);
  }

  /// Performs the validation logic and returns the result
  _ValidationResult _performValidation() {
    final parentExcludedSet =
        Set<int>.from(widget.currentlyExcludedAllergyIdsFromParent ?? []);

    // First, check if we should auto-select a preference
    final autoSelectedPreference = _attemptAutoSelection(parentExcludedSet);
    if (autoSelectedPreference.preferenceId != null) {
      return autoSelectedPreference;
    }

    // If no auto-selection, validate existing selection (if any)
    if (_selectedDietaryPreferenceId != null) {
      return _validateExistingPreference(parentExcludedSet);
    }

    // No selection, no auto-selection possible
    return _ValidationResult(preferenceId: null, impliedAllergens: []);
  }

  /// Validates if the currently selected preference is still valid
  _ValidationResult _validateExistingPreference(Set<int> parentExcludedSet) {
    final requiredHiddenByPreference =
        _preferenceToImpliedAllergensMap[_selectedDietaryPreferenceId!];

    if (requiredHiddenByPreference == null ||
        requiredHiddenByPreference.isEmpty) {
      return _ValidationResult(
        preferenceId: _selectedDietaryPreferenceId,
        impliedAllergens: [],
      );
    }

    final stillValid =
        _areAllergensStillValid(requiredHiddenByPreference, parentExcludedSet);

    if (stillValid) {
      return _ValidationResult(
        preferenceId: _selectedDietaryPreferenceId,
        impliedAllergens: List<int>.from(requiredHiddenByPreference),
      );
    } else {
      return _ValidationResult(
        preferenceId: null,
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

  /// Attempts to auto-select a preference based on allergen exclusions
  _ValidationResult _attemptAutoSelection(Set<int> parentExcludedSet) {
    // Get allergens implied by current restriction (if any) from parent widget
    final restrictionAllergens = _getRestrictionImpliedAllergens();

    // Calculate allergens that are "extra" (not from restriction)
    final extraAllergens = Set<int>.from(parentExcludedSet);
    extraAllergens.removeAll(restrictionAllergens);

    // Only auto-select if extra allergens EXACTLY match a preference's requirements
    for (var entry in _preferenceToImpliedAllergensMap.entries) {
      final preferenceId = entry.key;
      final requiredAllergens = entry.value;

      // Skip preferences without allergen requirements
      if (requiredAllergens.isEmpty) continue;

      // Skip if not in available list
      if (!widget.availableDietaryPreferences.contains(preferenceId)) continue;

      // Skip if not auto-selectable (currently none, but kept for consistency)
      if (!_autoSelectablePreferenceIds.contains(preferenceId)) continue;

      // Check for exact match of extra allergens
      final requiredSet = Set<int>.from(requiredAllergens);
      if (SetEquality().equals(extraAllergens, requiredSet)) {
        return _ValidationResult(
          preferenceId: preferenceId,
          impliedAllergens: List<int>.from(requiredAllergens),
        );
      }
    }

    return _ValidationResult(preferenceId: null, impliedAllergens: []);
  }

  /// Gets allergens implied by the current restriction
  Set<int> _getRestrictionImpliedAllergens() {
    if (widget.currentSelectedRestrictionId == null) {
      return {};
    }

    // Restriction allergen mappings
    const restrictionAllergens = {
      1: [2], // Gluten-free → gluten
      4: [7], // Lactose-free → milk
      3: [], // Halal
      5: [], // Kosher
    };

    final allergens = restrictionAllergens[widget.currentSelectedRestrictionId];
    return allergens != null ? Set<int>.from(allergens) : {};
  }

  /// Applies the validation result to internal state
  bool _applyValidationResult(_ValidationResult result) {
    final preferenceChanged =
        _selectedDietaryPreferenceId != result.preferenceId;

    if (preferenceChanged) {
      setState(() {
        _selectedDietaryPreferenceId = result.preferenceId;
      });
    }

    return preferenceChanged;
  }

  /// Triggers callback to parent if conditions are met
  void _triggerCallbackIfNeeded(
    _ValidationResult result,
    bool preferenceChanged,
    bool isInitialSync,
    bool triggerCallbackIfChanged,
  ) {
    final shouldTrigger = _shouldTriggerCallback(
        preferenceChanged, isInitialSync, triggerCallbackIfChanged);

    if (shouldTrigger) {
      final impliedAllergens = _determineImpliedAllergensForCallback(
          result, preferenceChanged, isInitialSync);
      widget.onDietaryPreferenceChanged(
          _selectedDietaryPreferenceId, impliedAllergens);
    }
  }

  /// Determines if callback should be triggered
  bool _shouldTriggerCallback(bool preferenceChanged, bool isInitialSync,
      bool triggerCallbackIfChanged) {
    return (preferenceChanged && triggerCallbackIfChanged) || isInitialSync;
  }

  /// Determines the implied allergens list for the callback
  List<int> _determineImpliedAllergensForCallback(
    _ValidationResult result,
    bool preferenceChanged,
    bool isInitialSync,
  ) {
    if (isInitialSync &&
        !preferenceChanged &&
        _selectedDietaryPreferenceId != null) {
      return List<int>.from(
          _preferenceToImpliedAllergensMap[_selectedDietaryPreferenceId!] ??
              []);
    }
    return result.impliedAllergens;
  }

  /// =========================================================================
  /// USER INTERACTION HANDLERS
  /// =========================================================================

  /// Handles user selection/deselection of a dietary preference
  Future<void> _selectDietaryPreference(int preferenceId) async {
    final selectionResult = _determineSelectionResult(preferenceId);

    // Track user engagement
    markUserEngaged();

    // Track analytics event
    _trackPreferenceToggle(preferenceId, selectionResult);

    _applyUserSelection(selectionResult);
    _notifyParentOfUserSelection(selectionResult);

    // Update menu session-level filter metrics
    await updateMenuSessionFilterMetrics(widget.currentResultCount);
  }

  /// Determines the result of user's selection action
  _SelectionResult _determineSelectionResult(int preferenceId) {
    final isDeselecting = _selectedDietaryPreferenceId == preferenceId;

    if (isDeselecting) {
      return _SelectionResult(preferenceId: null, impliedAllergens: []);
    } else {
      return _SelectionResult(
        preferenceId: preferenceId,
        impliedAllergens: List<int>.from(
            _preferenceToImpliedAllergensMap[preferenceId] ?? []),
      );
    }
  }

  /// Applies user's selection to internal state
  void _applyUserSelection(_SelectionResult result) {
    if (_selectedDietaryPreferenceId != result.preferenceId) {
      setState(() {
        _selectedDietaryPreferenceId = result.preferenceId;
      });
    }
  }

  /// Notifies parent of user's selection change
  void _notifyParentOfUserSelection(_SelectionResult result) {
    widget.onDietaryPreferenceChanged(
        result.preferenceId, result.impliedAllergens);
  }

  /// =========================================================================
  /// ANALYTICS TRACKING
  /// =========================================================================

  /// Tracks dietary preference toggle event to analytics backend.
  ///
  /// Captures which preference was toggled, its new state, and implied allergens
  /// to understand filtering patterns and dietary preference combinations.
  void _trackPreferenceToggle(
      int preferenceId, _SelectionResult selectionResult) {
    final preferenceName = _getPreferenceName(preferenceId);
    final isNowSelected = selectionResult.preferenceId != null;

    trackAnalyticsEvent(
      'dietary_preference_toggled',
      {
        'preference_id': preferenceId,
        'preference_name': preferenceName,
        'action': isNowSelected ? 'selected' : 'deselected',
        'is_now_selected': isNowSelected,
        'implied_allergen_exclusions': selectionResult.impliedAllergens,
        'implied_allergen_count': selectionResult.impliedAllergens.length,
        'language': widget.currentLanguage,
      },
    ).catchError((error) {
      debugPrint('⚠️ Failed to track preference toggle: $error');
    });
  }

  /// =========================================================================
  /// DATA RETRIEVAL & TRANSFORMATION
  /// =========================================================================

  /// Gets localized and alphabetically sorted dietary preferences for display.
  ///
  /// Filters out any preferences without valid translations to prevent
  /// display of invalid items.
  List<MapEntry<int, String>> _getLocalizedAndSortedPreferences() {
    final availablePreferences = widget.availableDietaryPreferences
        .map((id) {
          final name = _getPreferenceNameSafe(id);
          return name != null ? MapEntry(id, name) : null;
        })
        .whereType<MapEntry<int, String>>() // Filter out nulls
        .toList();

    return _sortPreferencesAlphabetically(availablePreferences);
  }

  /// Sorts preferences alphabetically by name
  List<MapEntry<int, String>> _sortPreferencesAlphabetically(
      List<MapEntry<int, String>> entries) {
    return entries..sort((a, b) => a.value.compareTo(b.value));
  }

  /// =========================================================================
  /// UI BUILDERS
  /// =========================================================================

  @override
  Widget build(BuildContext context) {
    final sortedPreferences = _getLocalizedAndSortedPreferences();

    return SizedBox(
      height: widget.height ?? _buttonMinSize.height,
      width: widget.width,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: sortedPreferences.length,
        separatorBuilder: (_, __) => const SizedBox(width: _buttonSpacing),
        itemBuilder: (_, index) =>
            _buildPreferenceButton(sortedPreferences[index]),
      ),
    );
  }

  /// Builds a single dietary preference button
  Widget _buildPreferenceButton(MapEntry<int, String> entry) {
    final preferenceId = entry.key;
    final preferenceName = entry.value;
    final isSelected = _selectedDietaryPreferenceId == preferenceId;

    return _buildButton(
      text: preferenceName,
      isSelected: isSelected,
      onPressed: () => _selectDietaryPreference(preferenceId),
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
  final int? preferenceId;
  final List<int> impliedAllergens;

  _ValidationResult({
    required this.preferenceId,
    required this.impliedAllergens,
  });
}

/// Result of user selection action
class _SelectionResult {
  final int? preferenceId;
  final List<int> impliedAllergens;

  _SelectionResult({
    required this.preferenceId,
    required this.impliedAllergens,
  });
}
