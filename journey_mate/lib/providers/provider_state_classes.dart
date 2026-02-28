/// State classes for all Riverpod providers
/// Centralized to prevent circular import issues
library;

// ============================================================
// ACCESSIBILITY STATE
// ============================================================

/// Accessibility preferences for text size and bold text
class AccessibilityState {
  final bool isBoldTextEnabled;
  final double fontScale;

  const AccessibilityState({
    required this.isBoldTextEnabled,
    required this.fontScale,
  });

  factory AccessibilityState.initial() {
    return const AccessibilityState(
      isBoldTextEnabled: false,
      fontScale: 1.0,
    );
  }

  AccessibilityState copyWith({
    bool? isBoldTextEnabled,
    double? fontScale,
  }) {
    return AccessibilityState(
      isBoldTextEnabled: isBoldTextEnabled ?? this.isBoldTextEnabled,
      fontScale: fontScale ?? this.fontScale,
    );
  }
}

// ============================================================
// ANALYTICS STATE (with MenuSessionData)
// ============================================================

/// Menu session tracking data (11 fields)
class MenuSessionData {
  final String menuSessionId; // UUID v4
  final int itemClicks; // Menu item detail opens
  final int packageClicks; // Package detail opens
  final List<int> categoriesViewed; // Category IDs viewed (de-duped)
  final int deepestScrollPercent; // Max scroll depth (0-100)
  final int filterInteractions; // Total filter toggle count
  final int filterResets; // "Clear All" button presses
  final bool everHadFiltersActive; // Any filter activated flag
  final int zeroResultCount; // Times filters resulted in 0 items
  final int lowResultCount; // Times filters resulted in 1-2 items
  final List<int> filterResultHistory; // Result count after each filter change

  const MenuSessionData({
    required this.menuSessionId,
    required this.itemClicks,
    required this.packageClicks,
    required this.categoriesViewed,
    required this.deepestScrollPercent,
    required this.filterInteractions,
    required this.filterResets,
    required this.everHadFiltersActive,
    required this.zeroResultCount,
    required this.lowResultCount,
    required this.filterResultHistory,
  });

  factory MenuSessionData.initial(String sessionId) {
    return MenuSessionData(
      menuSessionId: sessionId,
      itemClicks: 0,
      packageClicks: 0,
      categoriesViewed: [],
      deepestScrollPercent: 0,
      filterInteractions: 0,
      filterResets: 0,
      everHadFiltersActive: false,
      zeroResultCount: 0,
      lowResultCount: 0,
      filterResultHistory: [],
    );
  }

  MenuSessionData copyWith({
    String? menuSessionId,
    int? itemClicks,
    int? packageClicks,
    List<int>? categoriesViewed,
    int? deepestScrollPercent,
    int? filterInteractions,
    int? filterResets,
    bool? everHadFiltersActive,
    int? zeroResultCount,
    int? lowResultCount,
    List<int>? filterResultHistory,
  }) {
    return MenuSessionData(
      menuSessionId: menuSessionId ?? this.menuSessionId,
      itemClicks: itemClicks ?? this.itemClicks,
      packageClicks: packageClicks ?? this.packageClicks,
      categoriesViewed: categoriesViewed ?? this.categoriesViewed,
      deepestScrollPercent: deepestScrollPercent ?? this.deepestScrollPercent,
      filterInteractions: filterInteractions ?? this.filterInteractions,
      filterResets: filterResets ?? this.filterResets,
      everHadFiltersActive: everHadFiltersActive ?? this.everHadFiltersActive,
      zeroResultCount: zeroResultCount ?? this.zeroResultCount,
      lowResultCount: lowResultCount ?? this.lowResultCount,
      filterResultHistory: filterResultHistory ?? this.filterResultHistory,
    );
  }
}

/// Analytics state tracking device, session, and menu session
class AnalyticsState {
  final String deviceId;
  final String? sessionId;
  final DateTime? sessionStartTime;
  final MenuSessionData? menuSessionData;

  const AnalyticsState({
    required this.deviceId,
    this.sessionId,
    this.sessionStartTime,
    this.menuSessionData,
  });

  factory AnalyticsState.initial() {
    return const AnalyticsState(deviceId: '');
  }

  AnalyticsState copyWith({
    String? deviceId,
    String? sessionId,
    DateTime? sessionStartTime,
    MenuSessionData? menuSessionData,
  }) {
    return AnalyticsState(
      deviceId: deviceId ?? this.deviceId,
      sessionId: sessionId ?? this.sessionId,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
      menuSessionData: menuSessionData ?? this.menuSessionData,
    );
  }

  /// Special copyWith for nullable field resets
  AnalyticsState copyWithNullable({
    String? deviceId,
    String? sessionId,
    DateTime? sessionStartTime,
    MenuSessionData? menuSessionData,
    bool clearSession = false,
    bool clearMenuSession = false,
  }) {
    return AnalyticsState(
      deviceId: deviceId ?? this.deviceId,
      sessionId: clearSession ? null : (sessionId ?? this.sessionId),
      sessionStartTime: clearSession ? null : (sessionStartTime ?? this.sessionStartTime),
      menuSessionData: clearMenuSession ? null : (menuSessionData ?? this.menuSessionData),
    );
  }
}

// ============================================================
// SEARCH STATE
// ============================================================

/// Search state tracking current search, filters, and refinement history
class SearchState {
  final dynamic searchResults; // JSON from API
  final int searchResultsCount;
  final int fullMatchCount; // Count of documents where matchCount === scoringFilterIds.length (all needs met)
  final bool hasActiveSearch;
  final String currentSearchText;
  final List<int> filtersUsedForSearch; // User's checked filters
  final List<int> activeFilterIds; // API's compatible filters (from activeids response)
  final List<int> scoringFilterIds; // All filter IDs the node used for match scoring (from API response, for section grouping)
  final String currentFilterSessionId;
  final List<int> previousActiveFilters; // Snapshot before last change
  final String previousSearchText; // Snapshot before last change
  final String previousFilterSessionId; // Snapshot before last change
  final int currentRefinementSequence; // Count of refinements in this search
  final int? selectedNeighbourhoodId; // Neighbourhood filter ID routed from overlay (API param, not in filters array)
  final int? selectedShoppingAreaId; // Shopping area filter ID routed from overlay (API param, not in filters array)
  final DateTime? lastRefinementTime;
  final DateTime? lastFetchTime; // Timestamp of most recent search API call

  const SearchState({
    required this.searchResults,
    required this.searchResultsCount,
    required this.fullMatchCount,
    required this.hasActiveSearch,
    required this.currentSearchText,
    required this.filtersUsedForSearch,
    required this.activeFilterIds,
    required this.scoringFilterIds,
    required this.currentFilterSessionId,
    required this.previousActiveFilters,
    required this.previousSearchText,
    required this.previousFilterSessionId,
    required this.currentRefinementSequence,
    this.selectedNeighbourhoodId,
    this.selectedShoppingAreaId,
    this.lastRefinementTime,
    this.lastFetchTime,
  });

  factory SearchState.initial() {
    return const SearchState(
      searchResults: null,
      searchResultsCount: 0,
      fullMatchCount: 0,
      hasActiveSearch: false,
      currentSearchText: '',
      filtersUsedForSearch: [],
      activeFilterIds: [], // Empty until first search
      scoringFilterIds: [], // Empty until first search with need filters
      currentFilterSessionId: '',
      previousActiveFilters: [],
      previousSearchText: '',
      previousFilterSessionId: '',
      currentRefinementSequence: 0,
      lastRefinementTime: null,
      lastFetchTime: null,
    );
  }

  SearchState copyWith({
    dynamic searchResults,
    int? searchResultsCount,
    int? fullMatchCount,
    bool? hasActiveSearch,
    String? currentSearchText,
    List<int>? filtersUsedForSearch,
    List<int>? activeFilterIds,
    List<int>? scoringFilterIds,
    String? currentFilterSessionId,
    List<int>? previousActiveFilters,
    String? previousSearchText,
    String? previousFilterSessionId,
    int? currentRefinementSequence,
    int? selectedNeighbourhoodId,
    int? selectedShoppingAreaId,
    DateTime? lastRefinementTime,
    DateTime? lastFetchTime,
  }) {
    return SearchState(
      searchResults: searchResults ?? this.searchResults,
      searchResultsCount: searchResultsCount ?? this.searchResultsCount,
      fullMatchCount: fullMatchCount ?? this.fullMatchCount,
      hasActiveSearch: hasActiveSearch ?? this.hasActiveSearch,
      currentSearchText: currentSearchText ?? this.currentSearchText,
      filtersUsedForSearch: filtersUsedForSearch ?? this.filtersUsedForSearch,
      activeFilterIds: activeFilterIds ?? this.activeFilterIds,
      scoringFilterIds: scoringFilterIds ?? this.scoringFilterIds,
      currentFilterSessionId: currentFilterSessionId ?? this.currentFilterSessionId,
      previousActiveFilters: previousActiveFilters ?? this.previousActiveFilters,
      previousSearchText: previousSearchText ?? this.previousSearchText,
      previousFilterSessionId: previousFilterSessionId ?? this.previousFilterSessionId,
      currentRefinementSequence: currentRefinementSequence ?? this.currentRefinementSequence,
      selectedNeighbourhoodId: selectedNeighbourhoodId ?? this.selectedNeighbourhoodId,
      selectedShoppingAreaId: selectedShoppingAreaId ?? this.selectedShoppingAreaId,
      lastRefinementTime: lastRefinementTime ?? this.lastRefinementTime,
      lastFetchTime: lastFetchTime ?? this.lastFetchTime,
    );
  }

  /// Special copyWith for nullable field resets
  SearchState copyWithNullable({
    dynamic searchResults,
    int? searchResultsCount,
    int? fullMatchCount,
    bool? hasActiveSearch,
    String? currentSearchText,
    List<int>? filtersUsedForSearch,
    List<int>? activeFilterIds,
    List<int>? scoringFilterIds,
    String? currentFilterSessionId,
    List<int>? previousActiveFilters,
    String? previousSearchText,
    String? previousFilterSessionId,
    int? currentRefinementSequence,
    int? selectedNeighbourhoodId,
    int? selectedShoppingAreaId,
    DateTime? lastRefinementTime,
    DateTime? lastFetchTime,
    bool clearResults = false,
    bool clearActiveFilterIds = false,
    bool clearScoringFilterIds = false,
    bool clearNeighbourhoodId = false,
    bool clearShoppingAreaId = false,
    bool clearRefinementTime = false,
    bool clearFetchTime = false,
  }) {
    return SearchState(
      searchResults: clearResults ? null : (searchResults ?? this.searchResults),
      searchResultsCount: searchResultsCount ?? this.searchResultsCount,
      fullMatchCount: fullMatchCount ?? this.fullMatchCount,
      hasActiveSearch: hasActiveSearch ?? this.hasActiveSearch,
      currentSearchText: currentSearchText ?? this.currentSearchText,
      filtersUsedForSearch: filtersUsedForSearch ?? this.filtersUsedForSearch,
      activeFilterIds: clearActiveFilterIds ? [] : (activeFilterIds ?? this.activeFilterIds),
      scoringFilterIds: clearScoringFilterIds ? [] : (scoringFilterIds ?? this.scoringFilterIds),
      currentFilterSessionId: currentFilterSessionId ?? this.currentFilterSessionId,
      previousActiveFilters: previousActiveFilters ?? this.previousActiveFilters,
      previousSearchText: previousSearchText ?? this.previousSearchText,
      previousFilterSessionId: previousFilterSessionId ?? this.previousFilterSessionId,
      currentRefinementSequence: currentRefinementSequence ?? this.currentRefinementSequence,
      selectedNeighbourhoodId: clearNeighbourhoodId ? null : (selectedNeighbourhoodId ?? this.selectedNeighbourhoodId),
      selectedShoppingAreaId: clearShoppingAreaId ? null : (selectedShoppingAreaId ?? this.selectedShoppingAreaId),
      lastRefinementTime: clearRefinementTime ? null : (lastRefinementTime ?? this.lastRefinementTime),
      lastFetchTime: clearFetchTime ? null : (lastFetchTime ?? this.lastFetchTime),
    );
  }
}

// ============================================================
// BUSINESS STATE
// ============================================================

/// Business profile and menu data
class BusinessState {
  final dynamic currentBusiness; // JSON from API
  final dynamic menuItems; // JSON from API
  final List<int> businessFilterIds; // Filter IDs associated with business
  final dynamic openingHours; // JSON opening hours data
  final List<int> availableDietaryPreferences; // Filter IDs
  final List<int> availableDietaryRestrictions; // Filter IDs

  // Dietary filter selections (for UnifiedFiltersWidget)
  final List<int> selectedDietaryRestrictionIds; // Multi-select restrictions
  final int? selectedDietaryPreferenceId; // Single-select preference
  final List<int> excludedAllergyIds; // Multi-exclude allergens

  // Filter match data (for MatchCardWidget)
  final List<dynamic> filterDescriptions; // Filter descriptions with matched booleans
  final int matchedCount; // Number of filters matched (client-side computed)
  final int totalCount; // Total number of search filters

  const BusinessState({
    required this.currentBusiness,
    required this.menuItems,
    required this.businessFilterIds,
    required this.openingHours,
    required this.availableDietaryPreferences,
    required this.availableDietaryRestrictions,
    required this.selectedDietaryRestrictionIds,
    this.selectedDietaryPreferenceId,
    required this.excludedAllergyIds,
    required this.filterDescriptions,
    required this.matchedCount,
    required this.totalCount,
  });

  factory BusinessState.initial() {
    return const BusinessState(
      currentBusiness: null,
      menuItems: null,
      businessFilterIds: [],
      openingHours: null,
      availableDietaryPreferences: [],
      availableDietaryRestrictions: [],
      selectedDietaryRestrictionIds: [],
      selectedDietaryPreferenceId: null,
      excludedAllergyIds: [],
      filterDescriptions: [],
      matchedCount: 0,
      totalCount: 0,
    );
  }

  BusinessState copyWith({
    dynamic currentBusiness,
    dynamic menuItems,
    List<int>? businessFilterIds,
    dynamic openingHours,
    List<int>? availableDietaryPreferences,
    List<int>? availableDietaryRestrictions,
    List<int>? selectedDietaryRestrictionIds,
    int? selectedDietaryPreferenceId,
    List<int>? excludedAllergyIds,
    List<dynamic>? filterDescriptions,
    int? matchedCount,
    int? totalCount,
  }) {
    return BusinessState(
      currentBusiness: currentBusiness ?? this.currentBusiness,
      menuItems: menuItems ?? this.menuItems,
      businessFilterIds: businessFilterIds ?? this.businessFilterIds,
      openingHours: openingHours ?? this.openingHours,
      availableDietaryPreferences: availableDietaryPreferences ?? this.availableDietaryPreferences,
      availableDietaryRestrictions: availableDietaryRestrictions ?? this.availableDietaryRestrictions,
      selectedDietaryRestrictionIds: selectedDietaryRestrictionIds ?? this.selectedDietaryRestrictionIds,
      selectedDietaryPreferenceId: selectedDietaryPreferenceId ?? this.selectedDietaryPreferenceId,
      excludedAllergyIds: excludedAllergyIds ?? this.excludedAllergyIds,
      filterDescriptions: filterDescriptions ?? this.filterDescriptions,
      matchedCount: matchedCount ?? this.matchedCount,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  /// Special copyWith for nullable preference ID
  BusinessState copyWithNullable({
    dynamic currentBusiness,
    dynamic menuItems,
    List<int>? businessFilterIds,
    dynamic openingHours,
    List<int>? availableDietaryPreferences,
    List<int>? availableDietaryRestrictions,
    List<int>? selectedDietaryRestrictionIds,
    int? selectedDietaryPreferenceId,
    List<int>? excludedAllergyIds,
    List<dynamic>? filterDescriptions,
    int? matchedCount,
    int? totalCount,
    bool clearPreference = false,
  }) {
    return BusinessState(
      currentBusiness: currentBusiness ?? this.currentBusiness,
      menuItems: menuItems ?? this.menuItems,
      businessFilterIds: businessFilterIds ?? this.businessFilterIds,
      openingHours: openingHours ?? this.openingHours,
      availableDietaryPreferences: availableDietaryPreferences ?? this.availableDietaryPreferences,
      availableDietaryRestrictions: availableDietaryRestrictions ?? this.availableDietaryRestrictions,
      selectedDietaryRestrictionIds: selectedDietaryRestrictionIds ?? this.selectedDietaryRestrictionIds,
      selectedDietaryPreferenceId: clearPreference ? null : (selectedDietaryPreferenceId ?? this.selectedDietaryPreferenceId),
      excludedAllergyIds: excludedAllergyIds ?? this.excludedAllergyIds,
      filterDescriptions: filterDescriptions ?? this.filterDescriptions,
      matchedCount: matchedCount ?? this.matchedCount,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

// ============================================================
// FILTER STATE
// ============================================================

/// Filter hierarchy and lookup data
class FilterState {
  final dynamic filtersForLanguage; // JSON hierarchy from API
  final Map<int, dynamic> filterLookupMap; // Flattened map for quick lookups
  final List<dynamic> foodDrinkTypes; // Food/drink type list from API

  const FilterState({
    required this.filtersForLanguage,
    required this.filterLookupMap,
    required this.foodDrinkTypes,
  });

  factory FilterState.initial() {
    return const FilterState(
      filtersForLanguage: null,
      filterLookupMap: {},
      foodDrinkTypes: [],
    );
  }

  FilterState copyWith({
    dynamic filtersForLanguage,
    Map<int, dynamic>? filterLookupMap,
    List<dynamic>? foodDrinkTypes,
  }) {
    return FilterState(
      filtersForLanguage: filtersForLanguage ?? this.filtersForLanguage,
      filterLookupMap: filterLookupMap ?? this.filterLookupMap,
      foodDrinkTypes: foodDrinkTypes ?? this.foodDrinkTypes,
    );
  }
}

// ============================================================
// LOCALIZATION STATE
// ============================================================

/// Localization preferences (currency with exchange rate)
class LocalizationState {
  final String currencyCode; // Persisted
  final double exchangeRate; // Not persisted (ephemeral)

  const LocalizationState({
    required this.currencyCode,
    required this.exchangeRate,
  });

  factory LocalizationState.initial() {
    return const LocalizationState(
      currencyCode: 'DKK',
      exchangeRate: 1.0,
    );
  }

  LocalizationState copyWith({
    String? currencyCode,
    double? exchangeRate,
  }) {
    return LocalizationState(
      currencyCode: currencyCode ?? this.currencyCode,
      exchangeRate: exchangeRate ?? this.exchangeRate,
    );
  }
}

// ============================================================
// LOCATION STATE
// ============================================================

/// Location permission and service state
class LocationState {
  final bool hasPermission;
  final bool isServiceEnabled;
  final bool isBannerDismissed;

  const LocationState({
    required this.hasPermission,
    required this.isServiceEnabled,
    required this.isBannerDismissed,
  });

  /// Whether location is actually usable (service on + permission granted)
  bool get isLocationUsable => isServiceEnabled && hasPermission;

  factory LocationState.initial() {
    return const LocationState(
      hasPermission: false,
      isServiceEnabled: false,
      isBannerDismissed: false,
    );
  }

  LocationState copyWith({
    bool? hasPermission,
    bool? isServiceEnabled,
    bool? isBannerDismissed,
  }) {
    return LocationState(
      hasPermission: hasPermission ?? this.hasPermission,
      isServiceEnabled: isServiceEnabled ?? this.isServiceEnabled,
      isBannerDismissed: isBannerDismissed ?? this.isBannerDismissed,
    );
  }
}
