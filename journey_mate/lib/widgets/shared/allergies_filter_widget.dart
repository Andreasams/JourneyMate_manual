import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../../services/translation_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';

/// A horizontal scrollable widget for filtering menu items by allergens.
///
/// This widget displays allergen buttons that users can toggle to show/hide
/// menu items containing specific allergens. Uses translations from Supabase
/// ui_translations table for multi-language support.
///
/// Visual States:
/// - Orange button (selected): Allergen is NOT excluded - items WITH this allergen are shown
/// - Grey button (unselected): Allergen IS excluded - items WITH this allergen are hidden
class AllergiesFilterWidget extends ConsumerStatefulWidget {
  const AllergiesFilterWidget({
    super.key,
    this.width,
    this.height,
    required this.onAllergiesChanged,
    this.initiallyExcludedAllergyIds,
    required this.currentResultCount,
  });

  final double? width;
  final double? height;
  final Function(List<int> excludedAllergyIds) onAllergiesChanged;
  final List<int>? initiallyExcludedAllergyIds;

  /// Current number of menu items visible after filtering.
  /// Used for session-level filter impact analytics.
  final int currentResultCount;

  @override
  ConsumerState<AllergiesFilterWidget> createState() =>
      _AllergiesFilterWidgetState();
}

class _AllergiesFilterWidgetState
    extends ConsumerState<AllergiesFilterWidget> {
  /// =========================================================================
  /// STATE & CONSTANTS
  /// =========================================================================

  /// Set of allergen IDs that are currently excluded from display.
  /// When an allergen ID is in this set, items containing that allergen are hidden.
  Set<int> _excludedAllergyIds = {};

  late final ScrollController _scrollController;

  /// Visual styling constants
  static const Color _selectedColor = AppColors.accent;
  static const Color _unselectedColor = AppColors.bgInput;
  static const Color _selectedTextColor = Colors.white;
  static const Color _unselectedTextColor = AppColors.textPrimary;
  static const Color _borderColor = AppColors.border;

  static const Duration _animationDuration = Duration(milliseconds: 200);
  static const EdgeInsets _buttonPadding =
      EdgeInsets.symmetric(horizontal: AppSpacing.lg);
  static const Size _buttonMinSize = Size(0, 32);
  static const double _buttonBorderRadius = AppRadius.button;
  static const double _buttonSpacing = AppSpacing.sm;

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

    if (hasExclusionListChanged) {
      _syncStateFromParent(widget.initiallyExcludedAllergyIds);
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
  void _toggleAllergyExclusion(int allergyId) {
    final updatedExclusionSet = Set<int>.from(_excludedAllergyIds);

    final wasExcluded = updatedExclusionSet.contains(allergyId);
    final willBeExcluded = !wasExcluded;

    willBeExcluded
        ? updatedExclusionSet.add(allergyId)
        : updatedExclusionSet.remove(allergyId);

    widget.onAllergiesChanged(updatedExclusionSet.toList());
  }

  /// =========================================================================
  /// TRANSLATION & DATA RETRIEVAL
  /// =========================================================================

  /// Gets localized allergen name using translation helper.
  ///
  /// Returns null if translation is missing (indicated by empty string or ⚠️ prefix).
  ///
  /// Args:
  ///   allergenId: The allergen ID (1-14)
  ///
  /// Returns:
  ///   Localized allergen name, or null if translation not found
  String? _getAllergenName(int allergenId) {
    final translationKey = 'allergen_${allergenId}_cap';
    final allergenName = td(ref, translationKey);

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
            '⚠️ Missing translation for allergen_$allergyId in current language');
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
          padding: WidgetStateProperty.all(_buttonPadding),
          minimumSize: WidgetStateProperty.all(_buttonMinSize),
          shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_buttonBorderRadius),
              side: isVisuallySelected
                  ? BorderSide.none
                  : const BorderSide(color: _borderColor, width: 1),
            ),
          ),
          backgroundColor: WidgetStateProperty.all(
            isVisuallySelected ? _selectedColor : _unselectedColor,
          ),
          elevation: WidgetStateProperty.all(0),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
        child: Text(
          allergyName,
          style: AppTypography.bodyMedium.copyWith(
            color:
                isVisuallySelected ? _selectedTextColor : _unselectedTextColor,
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
        separatorBuilder: (_, _) => const SizedBox(width: _buttonSpacing),
        itemBuilder: (_, index) =>
            _buildAllergyListItem(localizedAllergies[index]),
      ),
    );
  }
}
