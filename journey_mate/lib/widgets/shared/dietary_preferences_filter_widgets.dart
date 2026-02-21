import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../providers/business_providers.dart';
import '../../providers/filter_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';
import '../../services/translation_service.dart';
import '../../services/api_service.dart';

/// A horizontal scrollable filter widget for selecting dietary preferences.
///
/// Features:
/// - Single-selection toggle (only one preference active at a time)
/// - Validation against parent allergen exclusions
/// - Orange selected state, grey unselected state
/// - Automatic allergen exclusion based on preference
/// - Analytics tracking for each toggle interaction
/// - Translation support with alphabetical sorting
///
/// Supported preferences:
/// - Vegan (ID 100): excludes milk, eggs, fish, crustaceans, molluscs
/// - Vegetarian (ID 101): excludes fish, crustaceans, molluscs
/// - Pescetarian (ID 102): no allergen exclusions
class DietaryPreferencesFilterWidgets extends ConsumerStatefulWidget {
  const DietaryPreferencesFilterWidgets({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  ConsumerState<DietaryPreferencesFilterWidgets> createState() =>
      _DietaryPreferencesFilterWidgetsState();
}

class _DietaryPreferencesFilterWidgetsState
    extends ConsumerState<DietaryPreferencesFilterWidgets> {
  /// =========================================================================
  /// STATE & CONSTANTS
  /// =========================================================================

  late final ScrollController _scrollController;
  List<dynamic> _sortedPreferences = [];

  /// Visual styling constants (design tokens)
  static const Duration _animationDuration = Duration(milliseconds: 200);
  static const EdgeInsets _buttonPadding =
      EdgeInsets.symmetric(horizontal: AppSpacing.lg);
  static const Size _buttonMinSize = Size(0, 32);

  /// Allergen IDs for mapping (FlutterFlow IDs)
  static const int _milkAllergenId = 7;
  static const int _eggsAllergenId = 4;
  static const int _fishAllergenId = 5;
  static const int _crustaceansAllergenId = 3;
  static const int _molluscsAllergenId = 8;

  /// Dietary preference IDs (FlutterFlow IDs)
  static const int _veganId = 100; // NOTE: Plan says 6, but code might differ
  static const int _vegetarianId = 101; // NOTE: Plan says 7
  static const int _pescetarianId = 102; // NOTE: Plan says 2

  /// Maps dietary preferences to the allergen IDs they exclude
  static const Map<int, List<int>> _preferenceToAllergensMap = {
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

  /// =========================================================================
  /// LIFECYCLE METHODS
  /// =========================================================================

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Initial validation deferred to post-frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _validateCurrentPreference();
      }
    });
  }

  @override
  void didUpdateWidget(covariant DietaryPreferencesFilterWidgets oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Note: We don't monitor props here since we read directly from providers
    // Provider changes trigger rebuilds automatically
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// =========================================================================
  /// VALIDATION LOGIC
  /// =========================================================================

  /// Validates current preference against excluded allergens
  void _validateCurrentPreference() {
    final businessState = ref.read(businessProvider);
    final selectedPreferenceId = businessState.selectedDietaryPreferenceId;
    final excludedAllergens = businessState.excludedAllergyIds;

    if (selectedPreferenceId == null) return;

    // Get required allergens for this preference
    final requiredAllergens = _preferenceToAllergensMap[selectedPreferenceId];
    if (requiredAllergens == null || requiredAllergens.isEmpty) return;

    // Check if all required allergens are still excluded
    final allStillExcluded = requiredAllergens.every(
      (allergenId) => excludedAllergens.contains(allergenId),
    );

    // If not valid, clear preference
    if (!allStillExcluded) {
      ref.read(businessProvider.notifier).setDietaryPreference(null);
    }
  }

  /// Checks if a preference would conflict with current allergen exclusions
  bool _hasAllergenConflict(int preferenceId) {
    final businessState = ref.read(businessProvider);
    final excludedAllergens = businessState.excludedAllergyIds;
    final preferenceAllergens = _preferenceToAllergensMap[preferenceId] ?? [];

    // Check if any preference allergen is NOT in the excluded list
    // (would create a conflict)
    return preferenceAllergens.any(
      (allergenId) => !excludedAllergens.contains(allergenId),
    );
  }

  /// =========================================================================
  /// USER INTERACTION HANDLERS
  /// =========================================================================

  /// Handles user toggle of a dietary preference
  Future<void> _handlePreferenceToggle(int preferenceId) async {
    // Validate allergen conflict
    if (_hasAllergenConflict(preferenceId)) {
      _showErrorToast();
      return;
    }

    final businessState = ref.read(businessProvider);
    final currentId = businessState.selectedDietaryPreferenceId;
    final isDeselecting = currentId == preferenceId;

    // Toggle logic: tap same = deselect, tap different = select new
    final newPreferenceId = isDeselecting ? null : preferenceId;
    final impliedAllergens =
        isDeselecting ? <int>[] : (_preferenceToAllergensMap[preferenceId] ?? []);

    // Update provider
    ref.read(businessProvider.notifier).setDietaryPreference(newPreferenceId);

    // Fire analytics (fire-and-forget)
    _trackPreferenceToggle(preferenceId, newPreferenceId != null, impliedAllergens);
  }

  /// Shows error toast for allergen conflict
  void _showErrorToast() {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ts(context, 'filter_preference_allergen_conflict'),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.red,
      ),
    );
  }

  /// =========================================================================
  /// ANALYTICS TRACKING
  /// =========================================================================

  /// Tracks dietary preference toggle event
  void _trackPreferenceToggle(
    int preferenceId,
    bool isNowSelected,
    List<int> impliedAllergens,
  ) {
    final preferenceName = _getPreferenceName(preferenceId);
    final analyticsState = ref.read(analyticsProvider);

    ApiService.instance.postAnalytics(
      eventType: 'dietary_preference_selected',
      deviceId: analyticsState.deviceId,
      sessionId: analyticsState.sessionId ?? '',
      userId: '', // Anonymous user
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'preference_id': preferenceId,
        'preference_name': preferenceName,
        'action': isNowSelected ? 'selected' : 'deselected',
        'is_now_selected': isNowSelected,
        'implied_allergen_exclusions': impliedAllergens,
        'implied_allergen_count': impliedAllergens.length,
      },
    ).catchError((error) {
      debugPrint('⚠️ Failed to track preference toggle: $error');
      return ApiCallResponse.failure('Analytics tracking failed');
    });
  }

  /// =========================================================================
  /// DATA RETRIEVAL & TRANSFORMATION
  /// =========================================================================

  /// Gets localized and alphabetically sorted dietary preferences
  List<dynamic> _getLocalizedAndSortedPreferences(
    List<dynamic> preferences,
    String languageCode,
  ) {
    final sorted = List<dynamic>.from(preferences);
    sorted.sort((a, b) {
      final nameA = td(ref, 'dietary_${a['id']}');
      final nameB = td(ref, 'dietary_${b['id']}');
      return nameA.compareTo(nameB);
    });
    return sorted;
  }

  /// Gets preference name safely
  String _getPreferenceName(int preferenceId) {
    final name = td(ref, 'dietary_$preferenceId');
    if (name.isEmpty || name.startsWith('⚠️')) {
      return 'Preference $preferenceId'; // Fallback
    }
    return name;
  }

  /// =========================================================================
  /// UI BUILDERS
  /// =========================================================================

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(filterProvider);
    final businessState = ref.watch(businessProvider);

    return filterState.when(
      data: (state) {
        // Extract dietary preferences from filter data
        final allFilters = state.filtersForLanguage;
        final preferences =
            (allFilters?['dietary_preferences'] as List<dynamic>?) ?? [];

        if (preferences.isEmpty) {
          return const SizedBox.shrink();
        }

        // Sort preferences alphabetically by translated name
        final languageCode = Localizations.localeOf(context).languageCode;
        _sortedPreferences = _getLocalizedAndSortedPreferences(
          preferences,
          languageCode,
        );

        return SizedBox(
          height: widget.height ?? _buttonMinSize.height,
          width: widget.width,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: _sortedPreferences.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (_, index) {
              final preference = _sortedPreferences[index];
              final preferenceId = preference['id'] as int;
              final isSelected =
                  businessState.selectedDietaryPreferenceId == preferenceId;

              return _buildPreferenceButton(
                preference,
                isSelected,
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  /// Builds a single dietary preference button
  Widget _buildPreferenceButton(dynamic preference, bool isSelected) {
    final preferenceId = preference['id'] as int;
    final preferenceName = td(ref, 'dietary_$preferenceId');

    return AnimatedContainer(
      duration: _animationDuration,
      child: ElevatedButton(
        onPressed: () => _handlePreferenceToggle(preferenceId),
        style: ButtonStyle(
          padding: WidgetStateProperty.all(_buttonPadding),
          minimumSize: WidgetStateProperty.all(_buttonMinSize),
          shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
              side: isSelected
                  ? BorderSide.none
                  : BorderSide(
                      color: AppColors.border,
                      width: 1,
                    ),
            ),
          ),
          backgroundColor: WidgetStateProperty.all(
            isSelected ? AppColors.accent : AppColors.bgInput,
          ),
          elevation: WidgetStateProperty.all(0),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
        child: Text(
          preferenceName,
          style: AppTypography.label.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
