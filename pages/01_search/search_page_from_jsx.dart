// ============================================================
// SEARCH PAGE (Udforsk) - Converted from JSX v2 Design
// Clean Flutter UI shell with no backend functionality
//
// Main search/explore page with:
// - Three filter buttons (Lokation, Type, Behov) → FilterSheet
// - Active filter chip row with "Ryd alle" button
// - Match sections (full/partial/none) when filters active
// - Liste/Kort toggle (Kort shows "coming soon" placeholder)
// - Floating sort button → SortSheet with station picker submenu
// - Bottom tab bar navigation
//
// This is the UI shell only - backend integration comes later
// ============================================================

import 'dart:ui'; // For ImageFilter.blur
import 'package:flutter/material.dart';
import '../../shared/app_theme.dart';

// Import for translation support
// TODO: Update path when integrated with main app
// import '/flutter_flow/custom_functions.dart' as functions;

/// Search page props (to be wired when integrated with app)
/// - onSelect(restaurant) — navigate to business profile
/// - activeNeeds — Set<String> of persistent needs
/// - onToggleNeed(String) — add/remove a need
/// - onClearAllNeeds() — clear all needs
/// - onOpenNeedsPicker() — open needs picker (if separate from this page)
/// - languageCode — ISO language code for translations
/// - translationsCache — Translation cache from FFAppState
class SearchPage extends StatefulWidget {
  final String languageCode;
  final dynamic translationsCache;

  const SearchPage({
    super.key,
    required this.languageCode,
    required this.translationsCache,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  // Translation helper function
  String _getUIText(String key) {
    // TODO: Uncomment when integrated with main app
    // return functions.getTranslations(
    //   widget.languageCode,
    //   key,
    //   widget.translationsCache,
    // );
    // Temporary fallback until integration
    return key;
  }

  // Sheet state
  String? _activeSheet; // "Lokation", "Type", or "Behov"
  bool _sheetVisible = false;

  // Filter state
  final Set<String> _selectedFilters = {};

  // Search state
  bool _searchFocused = false;
  final TextEditingController _searchController = TextEditingController();

  // View mode
  String _viewMode = 'liste'; // 'liste' or 'kort'

  // Sort state
  String _activeSort = 'match';
  String? _selectedStation;
  bool _showOnlyOpen = false;

  // Sort sheet state
  bool _sortSheetOpen = false;
  bool _sortSheetVisible = false;

  // TODO: Replace with actual persistent needs from app state
  final Set<String> _activeNeeds = {};

  // TODO: Replace with actual restaurant data from BuildShip API
  final List<Map<String, dynamic>> _mockRestaurants = [
    {
      'id': '1',
      'name': 'Noma',
      'initial': 'N',
      'bg': AppColors.accent,
      'distance': '0.8 km',
      'statusOpen': true,
      'statusText': 'til 22:00',
      'closingTime': '22:00',
      'cuisine': 'Nordisk',
      'priceRange': '500-800 kr',
      'address': 'Refshalevej 96, 1432 København K',
      'hours': [],
      'has': ['Helt glutenfrit', 'Veganske muligheder', 'Romantisk'], // PLACEHOLDER: needs matching
    },
    {
      'id': '2',
      'name': 'Geranium',
      'initial': 'G',
      'bg': Color(0xFF2a9456),
      'distance': '1.2 km',
      'statusOpen': false,
      'statusText': 'åbner kl. 18:00',
      'closingTime': '23:00',
      'cuisine': 'Moderne europæisk',
      'priceRange': '600-1000 kr',
      'address': 'Per Henrik Lings Allé 4, 2100 København',
      'hours': [],
      'has': ['Vegetariske muligheder', 'Havudsigt', 'Romantisk'],
    },
    // Add more mock restaurants as needed
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSheet(String sheet) {
    setState(() {
      _activeSheet = sheet;
    });
    // Two-frame delay for animation
    Future.microtask(() {
      Future.microtask(() {
        if (mounted) {
          setState(() {
            _sheetVisible = true;
          });
        }
      });
    });
  }

  void _closeSheet() {
    setState(() {
      _sheetVisible = false;
    });
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _activeSheet = null;
        });
      }
    });
  }

  void _toggleFilter(String filter) {
    setState(() {
      if (_selectedFilters.contains(filter)) {
        _selectedFilters.remove(filter);
      } else {
        _selectedFilters.add(filter);
      }
    });
  }

  void _toggleNeed(String need) {
    setState(() {
      // TODO: Wire to persistent app state when integrated
      if (_activeNeeds.contains(need)) {
        _activeNeeds.remove(need);
      } else {
        _activeNeeds.add(need);
      }
    });
  }

  void _clearAllNeeds() {
    setState(() {
      _activeNeeds.clear();
    });
  }

  void _openSortSheet() {
    setState(() {
      _sortSheetOpen = true;
    });
    Future.microtask(() {
      Future.microtask(() {
        if (mounted) {
          setState(() {
            _sortSheetVisible = true;
          });
        }
      });
    });
  }

  void _closeSortSheet() {
    setState(() {
      _sortSheetVisible = false;
    });
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _sortSheetOpen = false;
        });
      }
    });
  }

  // Get filter count for a specific tab
  int _getFilterCount(String tab) {
    // TODO: Implement actual filter count logic when filterSets data is available
    // For now, return 0
    return 0;
  }

  // Calculate match data for restaurants
  List<Map<String, dynamic>> _getRestaurantsWithMatch() {
    final allNeeds = <String>{..._activeNeeds, ..._selectedFilters};

    return _mockRestaurants.map((r) {
      final has = List<String>.from(r['has'] as List);
      final matched = allNeeds.where((n) => has.contains(n)).toList();
      final missed = allNeeds.where((n) => !has.contains(n)).toList();

      return {
        ...r,
        'matchCount': matched.length,
        'matchedNeeds': matched,
        'missedNeeds': missed,
      };
    }).toList();
  }

  // Apply sorting
  List<Map<String, dynamic>> _applySorting(List<Map<String, dynamic>> restaurants) {
    final sorted = List<Map<String, dynamic>>.from(restaurants);

    switch (_activeSort) {
      case 'nearest':
        sorted.sort((a, b) {
          final aVal = double.tryParse((a['distance'] as String).replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
          final bVal = double.tryParse((b['distance'] as String).replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
          return aVal.compareTo(bVal);
        });
        break;
      case 'price_low':
        sorted.sort((a, b) {
          final aVal = int.tryParse((a['priceRange'] as String).replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
          final bVal = int.tryParse((b['priceRange'] as String).replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
          return aVal.compareTo(bVal);
        });
        break;
      case 'price_high':
        sorted.sort((a, b) {
          final aVal = int.tryParse((a['priceRange'] as String).replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
          final bVal = int.tryParse((b['priceRange'] as String).replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
          return bVal.compareTo(aVal);
        });
        break;
      case 'match':
        final hasNeeds = _activeNeeds.isNotEmpty || _selectedFilters.isNotEmpty;
        if (hasNeeds) {
          sorted.sort((a, b) {
            final matchCompare = (b['matchCount'] as int).compareTo(a['matchCount'] as int);
            if (matchCompare != 0) return matchCompare;

            // Tie-breaker: distance
            final aVal = double.tryParse((a['distance'] as String).replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
            final bVal = double.tryParse((b['distance'] as String).replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
            return aVal.compareTo(bVal);
          });
        }
        break;
      case 'station':
        // TODO: Implement station-based sorting when BuildShip integration available
        break;
      case 'newest':
        // TODO: Implement newest sorting when date data available
        break;
    }

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final withMatch = _getRestaurantsWithMatch();
    final sorted = _applySorting(withMatch);
    final filtered = _showOnlyOpen ? sorted.where((r) => r['statusOpen'] as bool).toList() : sorted;

    final hasFilters = _selectedFilters.isNotEmpty;
    final hasNeeds = _activeNeeds.isNotEmpty;
    final showMatchSections = hasNeeds || hasFilters;

    // Split into match sections
    final allNeeds = <String>{..._activeNeeds, ..._selectedFilters};
    final fullMatch = showMatchSections
        ? filtered.where((r) => (r['matchCount'] as int) == allNeeds.length).toList()
        : <Map<String, dynamic>>[];
    final partialMatch = showMatchSections
        ? filtered.where((r) {
            final count = r['matchCount'] as int;
            return count > 0 && count < allNeeds.length;
          }).toList()
        : <Map<String, dynamic>>[];
    final noMatch = showMatchSections
        ? filtered.where((r) => (r['matchCount'] as int) == 0).toList()
        : <Map<String, dynamic>>[];

    // Sort button label
    final activeSortLabel = _activeSort == 'station' && _selectedStation != null
        ? _selectedStation!
        : _getSortOptionLabel(_activeSort);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        bottom: false, // Allow tab bar to extend to bottom edge
        child: Stack(
          children: [
            // Main scrollable content
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header section
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.xl, // 20px
                            AppSpacing.xs, // 4px top
                            AppSpacing.xl,
                            0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // City indicator
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: AppColors.accent,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    _getUIText('city_copenhagen'),
                                    style: AppTypography.label.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 14),

                              // Search bar
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.bgInput,
                                  borderRadius: BorderRadius.circular(AppRadius.input),
                                  border: Border.all(
                                    color: _searchFocused ? AppColors.accent : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 11,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.search,
                                      size: 17,
                                      color: AppColors.textTertiary,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        onTap: () => setState(() => _searchFocused = true),
                                        onTapOutside: (_) => setState(() => _searchFocused = false),
                                        decoration: InputDecoration(
                                          hintText: 'Søg restauranter, retter...', // TODO: Translation key
                                          hintStyle: AppTypography.input.copyWith(
                                            color: AppColors.textPlaceholder,
                                          ),
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        style: AppTypography.input.copyWith(
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),

                              // Title
                              Text(
                                hasFilters || hasNeeds
                                    ? 'Søgeresultater (${filtered.length})' // TODO: Translation key
                                    : 'Steder nær dig', // TODO: Translation key
                                // Note: 24px w700 letterSpacing -0.6px (-0.025em × 24)
                                // Design gap: No 24px heading token; sectionHeading is 18px w700
                                style: AppTypography.sectionHeading.copyWith(
                                  fontSize: 24,
                                  letterSpacing: -0.025 * 24,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: 14),

                              // Filter buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: _FilterButton(
                                      label: 'Lokation', // TODO: Translation key
                                      isActive: _activeSheet == 'Lokation',
                                      count: _getFilterCount('Lokation'),
                                      onTap: () {
                                        if (_activeSheet == 'Lokation') {
                                          _closeSheet();
                                        } else {
                                          _openSheet('Lokation');
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: _FilterButton(
                                      label: 'Type', // TODO: Translation key
                                      isActive: _activeSheet == 'Type',
                                      count: _getFilterCount('Type'),
                                      onTap: () {
                                        if (_activeSheet == 'Type') {
                                          _closeSheet();
                                        } else {
                                          _openSheet('Type');
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: _FilterButton(
                                      label: 'Behov', // TODO: Translation key
                                      isActive: _activeSheet == 'Behov',
                                      count: _getFilterCount('Behov'),
                                      onTap: () {
                                        if (_activeSheet == 'Behov') {
                                          _closeSheet();
                                        } else {
                                          _openSheet('Behov');
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Active filter chip row
                        if (hasFilters || hasNeeds)
                          Container(
                            padding: EdgeInsets.only(
                              top: 14,
                              bottom: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppColors.divider),
                              ),
                            ),
                            child: Stack(
                              children: [
                                // "Ryd alle" button (fixed, left side)
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    color: AppColors.bgPage,
                                    padding: EdgeInsets.only(left: AppSpacing.xl), // 20px
                                    child: Row(
                                      children: [
                                        OutlinedButton(
                                          onPressed: () {
                                            setState(() {
                                              _selectedFilters.clear();
                                              _clearAllNeeds();
                                            });
                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: AppSpacing.md, // 12px
                                              vertical: 7,
                                            ),
                                            side: BorderSide(
                                              color: AppColors.border,
                                              width: 1.5,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(AppRadius.chip),
                                            ),
                                          ),
                                          child: Text(
                                            _getUIText('menu_filter_clear_all'),
                                            style: AppTypography.label.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.accent,
                                            ),
                                          ),
                                        ),
                                        // Gradient fade
                                        Container(
                                          width: 10,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColors.bgPage,
                                                AppColors.bgPage.withOpacity(0),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Scrollable chip list
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 140, // Space for "Ryd alle" button
                                    right: AppSpacing.xl, // 20px
                                  ),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        // Active needs chips
                                        ..._activeNeeds.map((need) => Padding(
                                          padding: EdgeInsets.only(right: 6),
                                          child: _FilterChip(
                                            label: need,
                                            onRemove: () => _toggleNeed(need),
                                          ),
                                        )),
                                        // Selected filter chips
                                        ..._selectedFilters.map((filter) => Padding(
                                          padding: EdgeInsets.only(right: 6),
                                          child: _FilterChip(
                                            label: filter,
                                            onRemove: () => _toggleFilter(filter),
                                          ),
                                        )),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Liste/Kort toggle
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.xl, // 20px
                            AppSpacing.md, // 12px
                            AppSpacing.xl,
                            0,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _ToggleButton(
                                  label: _getUIText('view_list'), // TODO: Add to MASTER_TRANSLATION_KEYS.md
                                  isActive: _viewMode == 'liste',
                                  isLeft: true,
                                  onTap: () => setState(() => _viewMode = 'liste'),
                                ),
                              ),
                              SizedBox(width: -1.5), // Overlap borders
                              Expanded(
                                child: _ToggleButton(
                                  label: _getUIText('view_map'), // TODO: Add to MASTER_TRANSLATION_KEYS.md
                                  isActive: _viewMode == 'kort',
                                  isLeft: false,
                                  onTap: () => setState(() => _viewMode = 'kort'),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Results area
                        if (_viewMode == 'liste')
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              AppSpacing.xl, // 20px
                              AppSpacing.lg, // 16px
                              AppSpacing.xl,
                              32 + 80, // 32px bottom + 80px tab bar height
                            ),
                            child: filtered.isEmpty
                                ? _SearchNoResults(
                                    searchQuery: _searchController.text,
                                    onClearSearch: () {
                                      setState(() {
                                        _searchController.clear();
                                        _selectedFilters.clear();
                                        _clearAllNeeds();
                                      });
                                    },
                                  )
                                : showMatchSections
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Full match section
                                          if (fullMatch.isNotEmpty) ...[
                                            _MatchSectionHeader(
                                              label: _getUIText('match_full_header'),
                                              type: 'full',
                                            ),
                                            SizedBox(height: 10),
                                            ...fullMatch.asMap().entries.map((entry) {
                                              return _RestaurantCard(
                                                restaurant: entry.value,
                                                index: entry.key,
                                                hasNeeds: true,
                                                variant: 'full',
                                                onTap: () {
                                                  // TODO: Navigate to business profile
                                                  debugPrint('Navigate to ${entry.value['name']}');
                                                },
                                              );
                                            }),
                                            SizedBox(height: 4),
                                          ],

                                          // Partial match section
                                          if (partialMatch.isNotEmpty) ...[
                                            if (fullMatch.isNotEmpty) SizedBox(height: 24),
                                            _MatchSectionHeader(
                                              label: _getUIText('match_partial_header'),
                                              type: 'partial',
                                            ),
                                            SizedBox(height: 10),
                                            ...partialMatch.asMap().entries.map((entry) {
                                              return _RestaurantCard(
                                                restaurant: entry.value,
                                                index: entry.key,
                                                hasNeeds: true,
                                                variant: 'partial',
                                                onTap: () {
                                                  // TODO: Navigate to business profile
                                                  debugPrint('Navigate to ${entry.value['name']}');
                                                },
                                              );
                                            }),
                                            SizedBox(height: 4),
                                          ],

                                          // No match section
                                          if (noMatch.isNotEmpty) ...[
                                            if (fullMatch.isNotEmpty || partialMatch.isNotEmpty)
                                              SizedBox(height: 24),
                                            _MatchSectionHeader(
                                              label: _getUIText('match_other_header'),
                                              type: 'none',
                                            ),
                                            SizedBox(height: 10),
                                            ...noMatch.asMap().entries.map((entry) {
                                              return _RestaurantCard(
                                                restaurant: entry.value,
                                                index: entry.key,
                                                hasNeeds: false,
                                                variant: 'none',
                                                onTap: () {
                                                  // TODO: Navigate to business profile
                                                  debugPrint('Navigate to ${entry.value['name']}');
                                                },
                                              );
                                            }),
                                          ],
                                        ],
                                      )
                                    : Column(
                                        children: filtered.asMap().entries.map((entry) {
                                          return _RestaurantCard(
                                            restaurant: entry.value,
                                            index: entry.key,
                                            hasNeeds: false,
                                            variant: 'none',
                                            onTap: () {
                                              // TODO: Navigate to business profile
                                              debugPrint('Navigate to ${entry.value['name']}');
                                            },
                                          );
                                        }).toList(),
                                      ),
                          )
                        else
                          // Kort view placeholder
                          Container(
                            padding: EdgeInsets.fromLTRB(
                              AppSpacing.xl,
                              60,
                              AppSpacing.xl,
                              32 + 80,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: AppColors.bgInput,
                                      borderRadius: BorderRadius.circular(AppRadius.card),
                                    ),
                                    child: Icon(
                                      Icons.location_on_outlined,
                                      size: 28,
                                      color: AppColors.divider,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    _getUIText('view_map_coming_soon'), // TODO: Add to MASTER_TRANSLATION_KEYS.md
                                    style: AppTypography.menuItemName.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Kommer snart', // TODO: Translation key
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textDisabled,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Floating sort button (liste view only)
            if (_viewMode == 'liste')
              Positioned(
                bottom: 92, // Above tab bar (80px) + 12px gap
                right: 16,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: _openSortSheet,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sort,
                            size: 12,
                            color: Colors.white,
                          ),
                          SizedBox(width: 5),
                          Text(
                            activeSortLabel,
                            // Note: 12.5px w600 — anchor to bodySmall (13px w400)
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Bottom tab bar
            _SearchTabBar(
              activeTab: 'udforsk',
              onTabChange: (tab) {
                // TODO: Navigate to other tabs when integrated
                debugPrint('Navigate to tab: $tab');
              },
            ),

            // Filter sheet
            if (_activeSheet != null)
              _FilterSheet(
                initialTab: _activeSheet!,
                selectedFilters: _selectedFilters,
                activeNeeds: _activeNeeds,
                onToggle: _toggleFilter,
                onClose: _closeSheet,
                visible: _sheetVisible,
                resultCount: filtered.length,
                onReset: () => setState(() => _selectedFilters.clear()),
              ),

            // Sort sheet
            if (_sortSheetOpen)
              _SortSheet(
                visible: _sortSheetVisible,
                activeSort: _activeSort,
                selectedStation: _selectedStation,
                showOnlyOpen: _showOnlyOpen,
                filteredCount: filtered.length,
                onClose: _closeSortSheet,
                onSortChange: (sort, station) {
                  setState(() {
                    _activeSort = sort;
                    if (station != null) {
                      _selectedStation = station;
                    }
                  });
                  _closeSortSheet();
                },
                onToggleOnlyOpen: () {
                  setState(() {
                    _showOnlyOpen = !_showOnlyOpen;
                  });
                },
                getSortLabel: _getSortOptionLabel,
              ),
          ],
        ),
      ),
    );
  }

  String _getSortOptionLabel(String key) {
    switch (key) {
      case 'match': return _getUIText('sort_match');
      case 'nearest': return _getUIText('sort_nearest');
      case 'station': return _getUIText('sort_station');
      case 'price_low': return _getUIText('sort_price_low');
      case 'price_high': return _getUIText('sort_price_high');
      case 'newest': return _getUIText('sort_newest');
      default: return _getUIText('sort_sheet_title');
    }
  }
}

// ============================================================
// FILTER BUTTON
// ============================================================

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final int count;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isActive,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.filter), // 10px
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent : AppColors.bgSurface,
          border: Border.all(
            color: isActive ? AppColors.accent : AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(AppRadius.filter),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                count > 0 && !isActive ? '$label ($count)' : label,
                // Note: 13.5px w600 — anchor to bodySmall (13px w400)
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
            // Indicator dot
            if (count > 0 && !isActive)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// FILTER CHIP
// ============================================================

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onRemove,
      borderRadius: BorderRadius.circular(AppRadius.chip),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md, // 12px left
          7,
          AppSpacing.sm, // 8px right (less for close icon)
          7,
        ),
        decoration: BoxDecoration(
          color: AppColors.greenBg,
          border: Border.all(
            color: AppColors.greenBorder,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.label.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.green,
              ),
            ),
            SizedBox(width: 5),
            Icon(
              Icons.close,
              size: 10,
              color: AppColors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TOGGLE BUTTON (Liste/Kort)
// ============================================================

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isLeft;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isActive,
    required this.isLeft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.bgInput : AppColors.bgSurface,
          border: Border.all(
            color: AppColors.border,
            width: 1.5,
          ),
          borderRadius: isLeft
              ? BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.chip),
                  bottomLeft: Radius.circular(AppRadius.chip),
                )
              : BorderRadius.only(
                  topRight: Radius.circular(AppRadius.chip),
                  bottomRight: Radius.circular(AppRadius.chip),
                ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          // Note: 13.5px w600/w500 — anchor to bodySmall (13px w400)
          style: AppTypography.bodySmall.copyWith(
            fontSize: 13.5,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MATCH SECTION HEADER
// ============================================================

class _MatchSectionHeader extends StatelessWidget {
  final String label;
  final String type; // 'full', 'partial', 'none'

  const _MatchSectionHeader({
    required this.label,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    Widget? icon;

    switch (type) {
      case 'full':
        color = AppColors.green;
        icon = Icon(
          Icons.check,
          size: 11,
          color: AppColors.green,
        );
        break;
      case 'partial':
        color = AppColors.accent;
        icon = null;
        break;
      case 'none':
        color = AppColors.textDisabled;
        icon = null;
        break;
      default:
        color = AppColors.textTertiary;
        icon = null;
    }

    return Row(
      children: [
        if (icon != null) ...[
          icon,
          SizedBox(width: 5),
        ],
        Text(
          label.toUpperCase(),
          // Note: 11px w600 letterSpacing 0.55px — anchor to bodyTiny (12px w400)
          style: AppTypography.bodyTiny.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
            letterSpacing: 0.05 * 11,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// RESTAURANT CARD
// ============================================================

class _RestaurantCard extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  final int index;
  final bool hasNeeds;
  final String variant; // 'full', 'partial', 'none'
  final VoidCallback onTap;

  const _RestaurantCard({
    required this.restaurant,
    required this.index,
    required this.hasNeeds,
    required this.variant,
    required this.onTap,
  });

  @override
  State<_RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<_RestaurantCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;
    final closed = !(r['statusOpen'] as bool);

    // PLACEHOLDER: Mock photo colors
    final photos = [
      Color(0xFFF0DCC8),
      Color(0xFFE8C8B8),
      Color(0xFFD4B8A0),
      Color(0xFFC0D8C8),
      Color(0xFFB0C8B8),
      Color(0xFFD8CCC0),
      Color(0xFFC8B8A8),
      Color(0xFFE0D0C0),
    ];

    Color borderColor;
    switch (widget.variant) {
      case 'full':
        borderColor = AppColors.greenBorder;
        break;
      case 'partial':
        borderColor = Color(0xFFF0DCC8); // Note: #f0dcc8 - partial match border color
        break;
      default:
        borderColor = AppColors.border;
    }

    // TODO: Add staggered card entrance animation
    // JSX: cardIn 0.25s ease with index-based delay (min(i,8) * 40ms)
    // Use AnimationController + FadeTransition/SlideTransition per card
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Opacity(
        opacity: closed ? 0.5 : 1.0,
        child: Container(
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Base row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant initial icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    // Note: JSX uses borderRadius 13px for restaurant icon
                    // No semantic token for this specific value
                    borderRadius: BorderRadius.circular(13),
                    color: r['bg'] as Color,
                  ),
                  child: Center(
                    child: Text(
                      r['initial'] as String,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),

                // Restaurant info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and distance
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              r['name'] as String,
                              // Note: JSX uses 15.5px w630 for restaurant name
                              // Design gap: 0.5px above menuItemName (15px); w630 → w600
                              style: AppTypography.menuItemName.copyWith(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            r['distance'] as String,
                            // Note: #aaa for distance text — JSX design value
                            // Design gap: sits between textSecondary (#555) and textPlaceholder (#999)
                            // textDisabled (#bbb) is too light — using hardcoded value
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFAAAAAA),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),

                      // Status
                      Row(
                        children: [
                          Text(
                            closed ? _getUIText('status_closed') : _getUIText('business_status_open'),
                            // Note: 12.5px w600 — anchor to bodySmall (13px w400)
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: closed ? AppColors.red : AppColors.green,
                            ),
                          ),
                          SizedBox(width: 6),
                          Container(
                            width: 2,
                            height: 2,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            r['statusText'] as String,
                            // Note: 12.5px — anchor to bodySmall (13px w400)
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 12.5,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),

                      // Cuisine and price
                      Row(
                        children: [
                          Text(
                            r['cuisine'] as String,
                            // Note: 12.5px — anchor to bodySmall (13px w400)
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 12.5,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          SizedBox(width: 6),
                          Container(
                            width: 2,
                            height: 2,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            r['priceRange'] as String,
                            // Note: 12.5px — anchor to bodySmall (13px w400)
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 12.5,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Partial match info box
            if (widget.hasNeeds && widget.variant == 'partial')
              Container(
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.fromLTRB(11, 9, 11, 9),
                decoration: BoxDecoration(
                  // Note: #fef8f2 accent tint background for partial match info
                  // TODO: Add AppColors.accentSurface to design system
                  color: Color(0xFFFEF8F2),
                  borderRadius: BorderRadius.circular(AppRadius.filter), // 10px
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: AppColors.accent,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          // Note: 12px — anchor to bodyTiny (12px w400)
                          style: AppTypography.bodyTiny.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: _getUIText('match_info_matches')
                                  .replaceAll('{count}', '${r['matchCount']}')
                                  .replaceAll('{total}', '${(r['matchCount'] as int) + (r['missedNeeds'] as List).length}'),
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            TextSpan(text: ' · ${_getUIText('match_info_missing').replaceAll('{filters}', (r['missedNeeds'] as List).join(', '))}'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Expanded preview
            if (_expanded) ...[
              Container(
                margin: EdgeInsets.only(top: 12),
                padding: EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.divider),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Address
                    Text(
                      r['address'] as String,
                      // Note: 12.5px — anchor to bodySmall (13px w400)
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 12.5,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    SizedBox(height: 10),

                    // Photo gallery preview
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: photos.asMap().entries.map((entry) {
                          return Container(
                            width: 80,
                            height: 60,
                            margin: EdgeInsets.only(
                              right: entry.key < photos.length - 1 ? 4 : 0,
                            ),
                            decoration: BoxDecoration(
                              color: entry.value,
                              borderRadius: BorderRadius.circular(AppRadius.chip),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 10),

                    // "Se mere" button
                    // Note: GestureDetector with opaque behavior prevents tap from bubbling to parent InkWell
                    // JSX equivalent: e.stopPropagation()
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onTap,
                      child: OutlinedButton(
                        onPressed: null, // Gesture handled by GestureDetector above
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 9),
                          minimumSize: Size(double.infinity, 0),
                          side: BorderSide(
                            color: AppColors.border,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.filter),
                          ),
                        ),
                        child: Text(
                          'Se mere →', // TODO: Translation key
                          // Note: 12.5px w600 — anchor to bodySmall (13px w400)
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Collapse chevron
            if (!_expanded)
              Container(
                margin: EdgeInsets.only(top: 6),
                child: Center(
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 14,
                    color: AppColors.divider,
                  ),
                ),
              ),
          ],
        ),
        ),
      ),
    );
  }
}

// ============================================================
// SEARCH TAB BAR
// ============================================================

class _SearchTabBar extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTabChange;

  const _SearchTabBar({
    required this.activeTab,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'key': 'udforsk', 'label': 'Udforsk', 'icon': Icons.search}, // TODO: Translation keys
      {'key': 'minebehov', 'label': 'Mine behov', 'icon': Icons.favorite_border},
      {'key': 'profil', 'label': 'Profil', 'icon': Icons.person_outline},
    ];

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.bgPage.withOpacity(0.95),
              border: Border(
                top: BorderSide(color: AppColors.divider),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: tabs.map((tab) {
                final isActive = activeTab == tab['key'];
                return InkWell(
                  onTap: () => onTabChange(tab['key'] as String),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 10, 16, 2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab['icon'] as IconData,
                          size: 21,
                          color: isActive ? AppColors.accent : AppColors.textDisabled,
                        ),
                        SizedBox(height: 3),
                        Text(
                          tab['label'] as String,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                            color: isActive ? AppColors.accent : AppColors.textDisabled,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SEARCH NO RESULTS WIDGET
// ============================================================

class _SearchNoResults extends StatelessWidget {
  final String searchQuery;
  final VoidCallback onClearSearch;

  const _SearchNoResults({
    required this.searchQuery,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Empty state icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Note: JSX uses #f5f5f5 for empty state icon background
                // AppColors.bgInput is #f5f5f5 — numerically correct but semantic is for input fields
                // Using bgInput as it matches the JSX value exactly
                color: AppColors.bgInput,
              ),
              child: Center(
                child: Text(
                  '🔍',
                  style: TextStyle(fontSize: 36),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xxl), // 24px

            // Heading
            Text(
              _getUIText('search_no_results_title'),
              style: AppTypography.sectionHeading.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.md), // 12px

            // Description
            Text(
              searchQuery.isNotEmpty
                  ? _getUIText('search_no_results_body').replaceAll('{query}', searchQuery)
                  : _getUIText('search_no_results_body_filters'), // TODO: Add to MASTER_TRANSLATION_KEYS.md
              style: AppTypography.bodyRegular.copyWith(
                color: AppColors.textTertiary,
                height: 1.43,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),

            // Clear search button
            if (searchQuery.isNotEmpty)
              OutlinedButton(
                onPressed: onClearSearch,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl, // 24px
                    vertical: AppSpacing.md, // 12px
                  ),
                  side: BorderSide(
                    color: AppColors.accent,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.filter),
                  ),
                ),
                child: Text(
                  _getUIText('search_clear_button'),
                  style: AppTypography.label.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// FILTER SHEET (Three-column bottom sheet)
// ============================================================
// TODO: Implement with actual filterSets data from shared data
// For now, shows placeholder structure

class _FilterSheet extends StatefulWidget {
  final String initialTab;
  final Set<String> selectedFilters;
  final Set<String> activeNeeds;
  final ValueChanged<String> onToggle;
  final VoidCallback onClose;
  final bool visible;
  final int resultCount;
  final VoidCallback onReset;

  const _FilterSheet({
    required this.initialTab,
    required this.selectedFilters,
    required this.activeNeeds,
    required this.onToggle,
    required this.onClose,
    required this.visible,
    required this.resultCount,
    required this.onReset,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _activeTab;
  String _activeParent = '';
  String _activeItem = '';

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
    // TODO: Initialize _activeParent and _activeItem from filterSets data
  }

  void _switchTab(String tab) {
    setState(() {
      _activeTab = tab;
      // TODO: Reset parent and item selection from filterSets
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ['Lokation', 'Type', 'Behov'];

    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
      bottom: widget.visible ? 0 : -MediaQuery.of(context).size.height * 0.78,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () {}, // Prevent dismissal when tapping sheet
        child: Container(
          height: MediaQuery.of(context).size.height * 0.78,
          decoration: BoxDecoration(
            color: AppColors.bgPage,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.card),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: EdgeInsets.only(top: AppSpacing.md), // 12px
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              // Tab bar — widths match columns: 36% / 33% / 31%
              Container(
                decoration: BoxDecoration(
                  // Note: JSX uses #f0f0f0 for filter sheet internal borders
                  // Design gap: lighter than AppColors.divider (#f2f2f2), no exact token
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFF0F0F0)),
                  ),
                ),
                child: Row(
                  children: tabs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final tab = entry.value;
                    final isActive = _activeTab == tab;
                    final width = index == 0 ? 0.36 : index == 1 ? 0.33 : 0.31;
                    final count = 0; // TODO: Calculate from filterSets

                    return SizedBox(
                      width: MediaQuery.of(context).size.width * width,
                      child: InkWell(
                        onTap: () => _switchTab(tab),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isActive ? AppColors.accent : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                tab,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                                  color: isActive ? AppColors.accent : AppColors.textTertiary,
                                ),
                              ),
                              if (count > 0) ...[
                                SizedBox(width: 5),
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isActive ? AppColors.accent : AppColors.textDisabled,
                                  ),
                                  child: Center(
                                    child: Text(
                                      count.toString(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Three-column content
              Expanded(
                child: Row(
                  children: [
                    // Column 1 — category groups (36%)
                    Container(
                      width: MediaQuery.of(context).size.width * 0.36,
                      decoration: BoxDecoration(
                        color: Color(0xFFFAFAFA),
                        // Note: JSX uses #f0f0f0 for filter sheet internal borders
                        // Design gap: lighter than AppColors.divider (#f2f2f2), no exact token
                        border: Border(
                          right: BorderSide(color: Color(0xFFF0F0F0)),
                        ),
                      ),
                      child: ListView(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        children: [
                          // TODO: Populate from filterSets data
                          _CategoryGroupItem(
                            label: 'Placeholder',
                            count: 0,
                            isActive: false,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    // Column 2 — items with checkboxes (33%)
                    Container(
                      width: MediaQuery.of(context).size.width * 0.33,
                      decoration: BoxDecoration(
                        // Note: JSX uses #f0f0f0 for filter sheet internal borders
                        // Design gap: lighter than AppColors.divider (#f2f2f2), no exact token
                        border: Border(
                          right: BorderSide(color: Color(0xFFF0F0F0)),
                        ),
                      ),
                      child: ListView(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        children: [
                          // TODO: Populate from filterSets data
                        ],
                      ),
                    ),

                    // Column 3 — sub-items (31%)
                    Container(
                      width: MediaQuery.of(context).size.width * 0.31,
                      child: ListView(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        children: [
                          // TODO: Populate from filterSets data
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Footer
              Container(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl, // 20px
                  14,
                  AppSpacing.xl,
                  32,
                ),
                decoration: BoxDecoration(
                  // Note: JSX uses #f0f0f0 for filter sheet internal borders
                  // Design gap: lighter than AppColors.divider (#f2f2f2), no exact token
                  border: Border(
                    top: BorderSide(color: Color(0xFFF0F0F0)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onReset,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 13),
                          side: BorderSide(
                            color: AppColors.border,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            // Note: JSX uses borderRadius 12px on footer buttons
                            // Using AppRadius.input (12px) numerically matches but semantic is for inputs
                            // TODO: Confirm button radius with design team — AppRadius.button may be more appropriate
                            borderRadius: BorderRadius.circular(AppRadius.input),
                          ),
                        ),
                        child: Text(
                          'Nulstil', // TODO: Translation key
                          // Note: 14px w600 — anchor to label (14px w500)
                          style: AppTypography.label.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: widget.onClose,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 13),
                          backgroundColor: AppColors.accent,
                          shape: RoundedRectangleBorder(
                            // Note: JSX uses borderRadius 12px on footer buttons
                            // Using AppRadius.input (12px) numerically matches but semantic is for inputs
                            // TODO: Confirm button radius with design team — AppRadius.button may be more appropriate
                            borderRadius: BorderRadius.circular(AppRadius.input),
                          ),
                        ),
                        child: Text(
                          'Se ${widget.resultCount} steder', // TODO: Translation key
                          // Note: 14px w600 — anchor to label (14px w500)
                          style: AppTypography.label.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CATEGORY GROUP ITEM (Column 1 in filter sheet)
// ============================================================

class _CategoryGroupItem extends StatelessWidget {
  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryGroupItem({
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(14, 11, 10, 11),
        decoration: BoxDecoration(
          color: isActive ? AppColors.bgSurface : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isActive ? AppColors.accent : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                // Note: 13px w600/w400 — anchor to bodySmall (13px w400)
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? AppColors.accent : AppColors.textTertiary,
                  height: 1.35,
                ),
              ),
            ),
            if (count > 0)
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent,
                ),
                child: Center(
                  child: Text(
                    count.toString(),
                    // Note: 10px w700 badge text — anchor to bodyTiny (12px w400)
                    style: AppTypography.bodyTiny.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SORT SHEET
// ============================================================

class _SortSheet extends StatefulWidget {
  final bool visible;
  final String activeSort;
  final String? selectedStation;
  final bool showOnlyOpen;
  final int filteredCount;
  final VoidCallback onClose;
  final Function(String sort, String? station) onSortChange;
  final VoidCallback onToggleOnlyOpen;
  final String Function(String key) getSortLabel;

  const _SortSheet({
    required this.visible,
    required this.activeSort,
    required this.selectedStation,
    required this.showOnlyOpen,
    required this.filteredCount,
    required this.onClose,
    required this.onSortChange,
    required this.onToggleOnlyOpen,
    required this.getSortLabel,
  });

  @override
  State<_SortSheet> createState() => _SortSheetState();
}

class _SortSheetState extends State<_SortSheet> {
  String _view = 'options'; // 'options' or 'stations'

  // TODO: Replace with actual station data
  final List<String> _stations = [
    'København H',
    'Nørreport',
    'Østerport',
    'Vesterport',
    'Christianshavn',
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
      bottom: widget.visible ? 0 : -MediaQuery.of(context).size.height * 0.62,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () {}, // Prevent dismissal when tapping sheet
        child: Container(
          height: MediaQuery.of(context).size.height * 0.62,
          decoration: BoxDecoration(
            color: AppColors.bgPage,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.card),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: EdgeInsets.only(top: AppSpacing.md), // 12px
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              // Header
              Container(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl, // 20px
                  AppSpacing.xs, // 4px
                  AppSpacing.xl,
                  10, // Note: 10px from JSX — between sm (8px) and md (12px), no token
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.divider),
                  ),
                ),
                child: Row(
                  children: [
                    if (_view == 'stations')
                      IconButton(
                        onPressed: () => setState(() => _view = 'options'),
                        icon: Icon(Icons.arrow_back_ios_new),
                        iconSize: 10,
                        padding: EdgeInsets.all(4),
                        constraints: BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                        color: AppColors.textSecondary,
                      ),
                    if (_view == 'stations') SizedBox(width: 12),
                    Text(
                      _view == 'stations'
                          ? _getUIText('sort_select_station')
                          : _getUIText('sort_sheet_title'),
                      style: AppTypography.sectionHeading.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // Content area
              Expanded(
                child: Stack(
                  children: [
                    // TODO: Add slide animation between options/stations views
                    // JSX: slideInLeft/slideOutLeft at cubic-bezier(0.32,0.72,0,1)
                    // Use AnimatedSwitcher or PageView with custom transition

                    // Options view
                    if (_view == 'options')
                      ListView(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        children: [
                          // "Open now" filter toggle
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppColors.divider),
                              ),
                            ),
                            child: Container(
                              padding: EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: widget.showOnlyOpen
                                    ? AppColors.greenBg
                                    : AppColors.bgSurface,
                                border: Border.all(
                                  color: widget.showOnlyOpen
                                      ? AppColors.greenBorder
                                      : AppColors.border,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(AppRadius.filter),
                              ),
                              child: InkWell(
                                onTap: widget.onToggleOnlyOpen,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            border: widget.showOnlyOpen
                                                ? null
                                                : Border.all(
                                                    color: AppColors.border,
                                                    width: 1.5,
                                                  ),
                                            color: widget.showOnlyOpen
                                                ? AppColors.green
                                                : AppColors.bgSurface,
                                          ),
                                          child: widget.showOnlyOpen
                                              ? Icon(
                                                  Icons.check,
                                                  size: 11,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          _getUIText('filter_only_open'),
                                          style: AppTypography.menuItemName.copyWith(
                                            fontWeight: widget.showOnlyOpen
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            color: widget.showOnlyOpen
                                                ? AppColors.green
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (widget.showOnlyOpen)
                                      Text(
                                        '${widget.filteredCount} steder',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.green,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Sort options
                          ..._getSortOptions().map((option) {
                            final isActive = widget.activeSort == option['key'];
                            final hasSubmenu = option['hasSubmenu'] == true;
                            final baseLabel = widget.getSortLabel(option['key'] as String);
                            final displayLabel = option['key'] == 'station' &&
                                    widget.selectedStation != null
                                ? '$baseLabel: ${widget.selectedStation}'
                                : baseLabel;

                            return InkWell(
                              onTap: () {
                                if (hasSubmenu) {
                                  setState(() => _view = 'stations');
                                } else {
                                  widget.onSortChange(option['key'] as String, null);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xl,
                                  vertical: 14,
                                ),
                                color: isActive
                                    ? Color(0xFFFAFAFA)
                                    : Colors.transparent,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      displayLabel,
                                      style: AppTypography.menuItemName.copyWith(
                                        fontWeight: isActive
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: isActive
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                    if (isActive && !hasSubmenu)
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.accent,
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          size: 11,
                                          color: Colors.white,
                                        ),
                                      )
                                    else if (hasSubmenu)
                                      Icon(
                                        Icons.chevron_right,
                                        size: 14,
                                        color: AppColors.textDisabled,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),

                    // Stations view
                    if (_view == 'stations')
                      ListView(
                        children: _stations.map((station) {
                          final isSelected = widget.selectedStation == station;

                          return InkWell(
                            onTap: () {
                              widget.onSortChange('station', station);
                              setState(() => _view = 'options');
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                                vertical: 16,
                              ),
                              color: isSelected
                                  ? Color(0xFFFAFAFA)
                                  : Colors.transparent,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    station,
                                    style: AppTypography.menuItemName.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.accent,
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        size: 11,
                                        color: Colors.white,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),

              // Footer note (only in stations view)
              if (_view == 'stations')
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Color(0xFFFAFAFA),
                    border: Border(
                      top: BorderSide(color: AppColors.divider),
                    ),
                  ),
                  child: Text(
                    '💡 I den færdige app vil dette sortere steder efter afstand til den valgte station via Typesense & BuildShip.',
                    // TODO: Translation key
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                      height: 1.4,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getSortOptions() {
    return [
      {'key': 'match', 'label': '', 'icon': '★'}, // Label set via callback
      {'key': 'nearest', 'label': '', 'icon': '↕'},
      {'key': 'station', 'label': '', 'icon': '🚉', 'hasSubmenu': true},
      {'key': 'price_low', 'label': '', 'icon': '↑'},
      {'key': 'price_high', 'label': '', 'icon': '↓'},
      {'key': 'newest', 'label': 'Nyeste', 'icon': '✦'},
    ];
  }
}
