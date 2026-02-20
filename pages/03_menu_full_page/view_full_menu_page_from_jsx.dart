// ============================================================
// VIEW FULL MENU PAGE - Converted from JSX v2 Design
// Clean Flutter UI shell with no backend functionality
//
// Full menu view with category navigation and dietary filters
// Shows: menu items by category, dietary filters, allergen options
// This is the UI shell only - backend integration comes later
// ============================================================

import 'package:flutter/material.dart';
import '../../shared/app_theme.dart';

// TODO: Import when backend integrated
// import '/flutter_flow/flutter_flow_util.dart';
// import '/custom_code/actions/index.dart' as actions;

/// Translation helper function
/// TODO: Wire up when backend is integrated
/// For now, returns the key as a placeholder
String getTranslations(String languageCode, String key, dynamic translationsCache) {
  // TODO: Implement translation lookup from translationsCache
  // This is a placeholder that will be replaced with actual translation logic
  return key;
}

class ViewFullMenuPage extends StatefulWidget {
  final String languageCode;
  final dynamic translationsCache;

  const ViewFullMenuPage({
    super.key,
    required this.languageCode,
    required this.translationsCache,
  });

  @override
  State<ViewFullMenuPage> createState() => _ViewFullMenuPageState();
}

class _ViewFullMenuPageState extends State<ViewFullMenuPage> {
  // Active category state
  String _activeCategory = 'Burger';

  // Filter panel expanded state
  bool _filterPanelExpanded = false;

  // Filter selections
  final Set<String> _selectedRestrictions = {};
  final Set<String> _selectedPreferences = {};
  final Set<String> _selectedAllergens = {'Blødyr', 'Fisk', 'Jordnødder'};

  // Mock data - TODO: Replace with actual restaurant data
  final String _restaurantName = 'Restaurant Name';
  final String _menuLastUpdated = '15. december 2025';

  final List<String> _categories = [
    'Mød',
    'Drikke',
    'Burger',
    'Poké bowls',
    'Classic bowls',
    'Sand',
  ];

  final List<String> _restrictions = ['Glutenfrit', 'Laktosefrit'];
  final List<String> _preferences = ['Pescetarianligt', 'Vegansk', 'Vegetarisk'];
  final List<String> _allergens = ['Blødyr', 'Fisk', 'Jordnødder', 'Korn med...'];

  // Mock menu items - TODO: Replace with actual menu data
  final List<Map<String, dynamic>> _menuItems = [
    {
      'category': 'Burger',
      'name': 'Classic Burger',
      'description': 'Beef patty, lettuce, tomato, pickles, special sauce',
      'price': '95 kr.',
    },
    {
      'category': 'Burger',
      'name': 'Cheese Burger',
      'description': 'Beef patty, cheddar cheese, lettuce, tomato, onions',
      'price': '105 kr.',
    },
    {
      'category': 'Burger',
      'name': 'Veggie Burger',
      'description': 'Plant-based patty, avocado, sprouts, vegan mayo',
      'price': '98 kr.',
    },
  ];

  List<Map<String, dynamic>> get _currentMenuItems =>
      _menuItems.where((item) => item['category'] == _activeCategory).toList();

  void _toggleFilter(Set<String> filterSet, String value) {
    setState(() {
      if (filterSet.contains(value)) {
        filterSet.remove(value);
      } else {
        filterSet.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and restaurant name
            Container(
              height: 60,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl), // 20px
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.divider), // #f2f2f2
                ),
              ),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    onPressed: () {
                      // TODO: Add markUserEngaged() call
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back_ios_new),
                    color: AppColors.textPrimary,
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                  // Centered restaurant name
                  Expanded(
                    child: Text(
                      _restaurantName, // TODO: Translation handling for name
                      // Note: Using categoryHeading (16px w700) with w600 override
                      // Design system gap: No token for 16px w600
                      style: AppTypography.categoryHeading.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Spacer to balance the back button
                  const SizedBox(width: 36),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl, // 20px horizontal
                  AppSpacing.lg, // 16px top
                  AppSpacing.xl,
                  AppSpacing.xxl, // 24px bottom
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Menu heading and last updated
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getTranslations(widget.languageCode, 'foeokmwh', widget.translationsCache),
                          style: AppTypography.sectionHeading, // 18px w700
                        ),
                        Text(
                          '${getTranslations(widget.languageCode, 'sgpknl00', widget.translationsCache)}$_menuLastUpdated',
                          // Note: 11px text - no exact typography token
                          // Design system gap: Smallest token is bodyTiny (12px w400)
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm), // 8px

                    // Filter toggle
                    InkWell(
                      onTap: () {
                        setState(() {
                          _filterPanelExpanded = !_filterPanelExpanded;
                        });
                      },
                      child: Text(
                        _filterPanelExpanded
                            ? getTranslations(widget.languageCode, '1smig27j', widget.translationsCache)
                            : getTranslations(widget.languageCode, 'bwvizajd', widget.translationsCache),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg), // 16px

                    // Filter panel (expandable)
                    if (_filterPanelExpanded) ...[
                      Container(
                        padding: EdgeInsets.all(AppSpacing.lg), // 16px
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.input), // 12px
                          color: AppColors.bgCard, // #fafafa
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Heading
                            Text(
                              getTranslations(widget.languageCode, 'menu_full_filters_heading', widget.translationsCache),
                              style: AppTypography.menuItemName, // 15px w600
                            ),
                            SizedBox(height: AppSpacing.md), // 12px

                            // Dietary Restrictions
                            _FilterSection(
                              languageCode: widget.languageCode,
                              translationsCache: widget.translationsCache,
                              label: getTranslations(widget.languageCode, 'filter_restrictions_label', widget.translationsCache),
                              description: getTranslations(widget.languageCode, 'filter_restrictions_explain', widget.translationsCache),
                              options: _restrictions,
                              selectedOptions: _selectedRestrictions,
                              onToggle: (value) => _toggleFilter(_selectedRestrictions, value),
                            ),
                            SizedBox(height: AppSpacing.lg), // 16px

                            // Dietary Preferences
                            _FilterSection(
                              languageCode: widget.languageCode,
                              translationsCache: widget.translationsCache,
                              label: getTranslations(widget.languageCode, 'filter_preferences_label', widget.translationsCache),
                              description: getTranslations(widget.languageCode, 'filter_preferences_explain', widget.translationsCache),
                              options: _preferences,
                              selectedOptions: _selectedPreferences,
                              onToggle: (value) => _toggleFilter(_selectedPreferences, value),
                            ),
                            SizedBox(height: AppSpacing.lg), // 16px

                            // Allergens
                            _FilterSection(
                              languageCode: widget.languageCode,
                              translationsCache: widget.translationsCache,
                              label: getTranslations(widget.languageCode, 'filter_allergens_label', widget.translationsCache),
                              description: getTranslations(widget.languageCode, 'filter_allergens_explain', widget.translationsCache),
                              options: _allergens,
                              selectedOptions: _selectedAllergens,
                              onToggle: (value) => _toggleFilter(_selectedAllergens, value),
                              isLastSection: true,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg), // 16px
                    ],

                    // Category chips (horizontal scrollable)
                    SizedBox(
                      height: 34, // Chip height with padding
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (context, index) => SizedBox(width: AppSpacing.sm), // 8px
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isActive = _activeCategory == category;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _activeCategory = category;
                              });
                            },
                            borderRadius: BorderRadius.circular(AppRadius.filter), // 10px
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14, // JSX: 14px horizontal
                                vertical: 7, // Design-specific: 7px (between xs=4 and sm=8)
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppRadius.filter), // 10px
                                color: isActive ? AppColors.accent : AppColors.bgSurface,
                                border: Border.all(
                                  color: isActive ? AppColors.accent : AppColors.border,
                                ),
                              ),
                              child: Text(
                                category, // TODO: Translation handling for category names
                                // Note: 13px w580 - using bodySmall (13px w500) with w600 override
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isActive ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl), // 20px

                    // Menu section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category heading
                        Text(
                          _activeCategory, // TODO: Translation handling
                          style: AppTypography.categoryHeading, // 16px w700
                        ),
                        SizedBox(height: AppSpacing.sm), // 8px

                        // Special note for Burger category
                        if (_activeCategory == 'Burger') ...[
                          Row(
                            children: [
                              Text(
                                getTranslations(widget.languageCode, 'menu_category_burger_note', widget.translationsCache),
                                style: AppTypography.bodyTiny, // 12px
                              ),
                              SizedBox(width: 4),
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.textTertiary),
                                ),
                                child: Center(
                                  child: Text(
                                    'i',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.lg), // 16px
                        ],

                        // Menu items
                        ..._currentMenuItems.map((item) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: AppSpacing.xl), // 20px
                            child: InkWell(
                              onTap: () {
                                // TODO: Open menu item detail overlay
                                // TODO: Add markUserEngaged() call
                                debugPrint('Menu item tapped: ${item['name']}');
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Item name
                                  Text(
                                    item['name'] as String, // TODO: Translation handling
                                    style: AppTypography.menuItemName, // 15px w600
                                  ),
                                  SizedBox(height: 4),
                                  // Item description
                                  Text(
                                    item['description'] as String, // TODO: Translation handling
                                    // Note: 13px w400 - using bodySmall with w400 override
                                    style: AppTypography.bodySmall.copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textSecondary,
                                      height: 1.38, // 18px / 13px
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  // Item price
                                  Text(
                                    item['price'] as String,
                                    // Note: 13.5px w540 - using bodySmall with custom overrides
                                    style: AppTypography.bodySmall.copyWith(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ],
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
// FILTER SECTION WIDGET
// ============================================================

/// Filter section with label, description, and chips
class _FilterSection extends StatelessWidget {
  final String languageCode;
  final dynamic translationsCache;
  final String label;
  final String description;
  final List<String> options;
  final Set<String> selectedOptions;
  final Function(String) onToggle;
  final bool isLastSection;

  const _FilterSection({
    required this.languageCode,
    required this.translationsCache,
    required this.label,
    required this.description,
    required this.options,
    required this.selectedOptions,
    required this.onToggle,
    this.isLastSection = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary, // #555
          ),
        ),
        SizedBox(height: 6), // Design-specific: 6px gap

        // Description
        Text(
          description,
          style: AppTypography.bodyTiny.copyWith(
            height: 1.33, // 16px / 12px
          ),
        ),
        SizedBox(height: AppSpacing.sm), // 8px

        // Chips
        Wrap(
          spacing: AppSpacing.sm, // 8px
          runSpacing: AppSpacing.sm,
          children: options.map((option) {
            final isSelected = selectedOptions.contains(option);
            return InkWell(
              onTap: () => onToggle(option),
              borderRadius: BorderRadius.circular(AppRadius.filter), // 10px
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, // 12px
                  vertical: 7, // Design-specific: 7px (between xs=4 and sm=8)
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.filter), // 10px
                  color: isSelected ? AppColors.accent : AppColors.bgSurface,
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.border,
                  ),
                ),
                child: Text(
                  option, // TODO: Translation handling for filter options
                  style: AppTypography.chip.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
