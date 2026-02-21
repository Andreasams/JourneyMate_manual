import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'provider_state_classes.dart';

// ============================================================
// BUSINESS STATE PROVIDER
// ============================================================

/// Business state provider (Riverpod 3.x)
final businessProvider = NotifierProvider<BusinessNotifier, BusinessState>(() {
  return BusinessNotifier();
});

class BusinessNotifier extends Notifier<BusinessState> {
  @override
  BusinessState build() {
    return BusinessState.initial();
  }

  /// Set current business with associated data
  void setCurrentBusiness({
    required dynamic business,
    required List<int> filterIds,
    required dynamic hours,
  }) {
    state = state.copyWith(
      currentBusiness: business,
      businessFilterIds: filterIds,
      openingHours: hours,
    );
  }

  /// Set menu items for current business
  void setMenuItems(dynamic items) {
    state = state.copyWith(menuItems: items);
  }

  /// Set dietary options available for current business
  void setDietaryOptions({
    required List<int> preferences,
    required List<int> restrictions,
  }) {
    state = state.copyWith(
      availableDietaryPreferences: preferences,
      availableDietaryRestrictions: restrictions,
    );
  }

  /// Update only opening hours
  void updateOpeningHours(dynamic hours) {
    state = state.copyWith(openingHours: hours);
  }

  /// Update only filter IDs
  void updateFilterIds(List<int> filterIds) {
    state = state.copyWith(businessFilterIds: filterIds);
  }

  /// Clear all business data (reset to initial)
  void clearBusiness() {
    state = BusinessState.initial();
  }

  /// Check if business is currently loaded
  bool hasCurrentBusiness() {
    return state.currentBusiness != null;
  }

  /// Check if menu items are loaded
  bool hasMenuItems() {
    return state.menuItems != null;
  }

  /// Get business ID from current business (if available)
  int? getCurrentBusinessId() {
    if (state.currentBusiness == null) return null;
    if (state.currentBusiness is Map) {
      return state.currentBusiness['business_id'] as int?;
    }
    return null;
  }
}
