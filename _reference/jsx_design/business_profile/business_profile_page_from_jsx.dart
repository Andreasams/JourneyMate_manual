// ============================================================
// BUSINESS PROFILE PAGE - Converted from JSX v2 Design
// Clean Flutter UI shell with no backend functionality
//
// Full restaurant profile with hero, quick actions, match card,
// gallery, menu, facilities, payments, and about sections
// This is the UI shell only - backend integration comes later
// ============================================================

import 'package:flutter/material.dart';
import '../../shared/app_theme.dart';

class BusinessProfilePage extends StatefulWidget {
  const BusinessProfilePage({super.key});

  @override
  State<BusinessProfilePage> createState() => _BusinessProfilePageState();
}

class _BusinessProfilePageState extends State<BusinessProfilePage> {
  // Expandable sections state
  bool _matchCardExpanded = false;
  bool _aboutExpanded = false;
  bool _contactExpanded = false;
  bool _menuFilterExpanded = false;

  // Active selections
  String _activeGalleryTab = 'Mad';
  String _activeMenuCategory = 'Burger';
  final Set<String> _selectedDietaryRestrictions = {};
  final Set<String> _selectedDietaryPreferences = {};
  final Set<String> _selectedAllergens = {};

  // Mock restaurant data - TODO: Replace with actual data
  final Map<String, dynamic> _restaurant = {
    'name': 'Restaurant Name',
    'initial': 'R',
    'bg': const Color(0xFFE8751A), // Placeholder
    'cuisine': 'Italiensk',
    'statusOpen': true,
    'closingTime': '22:00',
    'priceRange': '150-300 kr.',
    'address': 'Vesterbrogade 1, København',
    'phone': '+45 12 34 56 78',
    'website': 'www.restaurant.dk',
    'instagram': '@restaurant',
    'booking': 'book.restaurant.dk',
    'about': 'Cozy restaurant serving traditional Danish cuisine with a modern twist.',
    'hours': [
      ['Mandag', '17:00-22:00'],
      ['Tirsdag', '17:00-22:00'],
      ['Onsdag', '17:00-22:00'],
      ['Torsdag', '17:00-22:00'],
      ['Fredag', '17:00-23:00'],
      ['Lørdag', '12:00-23:00'],
      ['Søndag', 'Lukket'],
    ],
  };

  // Mock active needs - TODO: Replace with actual state
  final Set<String> _activeNeeds = {'Glutenfrit', 'Børnevenligt', 'WiFi'};
  final List<String> _matched = ['Glutenfrit', 'WiFi'];
  final List<String> _missed = ['Børnevenligt'];

  final List<String> _galleryTabs = ['Mad', 'Menu', 'Inde', 'Ude'];
  final List<String> _menuCategories = ['Burger', 'Pizza', 'Pasta', 'Salat'];
  final List<String> _facilities = ['Handicapvenligt', 'Udeservering', 'WiFi', 'Parkering'];
  final List<String> _payments = ['Kontant', 'Dankort', 'Visa', 'MobilePay'];

  // Mock menu items
  final List<Map<String, String>> _menuItems = [
    {'name': 'Classic Burger', 'desc': 'Beef patty, lettuce, tomato', 'price': '95 kr.'},
    {'name': 'Cheese Burger', 'desc': 'With cheddar cheese', 'price': '105 kr.'},
    {'name': 'Veggie Burger', 'desc': 'Plant-based patty', 'price': '98 kr.'},
  ];

  @override
  Widget build(BuildContext context) {
    final bool hasNeeds = _activeNeeds.isNotEmpty;
    final bool isFullMatch = hasNeeds && _missed.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(
          children: [
            // Nav bar
            Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl, // 20px horizontal
                4, // JSX: 4px top padding
                AppSpacing.xl,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  IconButton(
                    onPressed: () {
                      // TODO: Add markUserEngaged() call
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back),
                    iconSize: 22,
                    color: AppColors.textPrimary,
                    padding: EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                  ),

                  // Action buttons
                  Row(
                    children: [
                      // Share button
                      IconButton(
                        onPressed: () {
                          // TODO: Share functionality
                        },
                        icon: const Icon(Icons.share_outlined),
                        iconSize: 20,
                        color: AppColors.textPrimary,
                        padding: EdgeInsets.all(4),
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      ),
                      SizedBox(width: 14),
                      // Info button
                      IconButton(
                        onPressed: () {
                          // TODO: Navigate to information page
                        },
                        icon: const Icon(Icons.info_outline),
                        iconSize: 20,
                        color: AppColors.textPrimary,
                        padding: EdgeInsets.all(4),
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable body
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Hero section
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.xxl, // 24px
                        AppSpacing.lg, // 16px top
                        AppSpacing.xxl,
                        0,
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Logo
                              Container(
                                width: 64,
                                height: 64,
                                // Note: JSX uses 18px radius, slightly larger than AppRadius.card (16px)
                                decoration: BoxDecoration(
                                  color: _restaurant['bg'] as Color,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Center(
                                  child: Text(
                                    _restaurant['initial'] as String,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: AppSpacing.lg), // 16px

                              // Restaurant info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Name
                                    Text(
                                      _restaurant['name'] as String,
                                      // Note: JSX uses 24px w750 - using restaurantName (24px w800) with w700 override
                                      style: AppTypography.restaurantName.copyWith(
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.72, // -0.03em of 24px
                                      ),
                                    ),
                                    SizedBox(height: 4),

                                    // Cuisine
                                    Text(
                                      _restaurant['cuisine'] as String,
                                      // Note: 13.5px - using bodySmall (13px) with size override
                                      style: AppTypography.bodySmall.copyWith(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                    SizedBox(height: 2),

                                    // Status line
                                    Row(
                                      children: [
                                        Text(
                                          _restaurant['statusOpen'] as bool ? 'Åben' : 'Lukket',
                                          // Note: 13px w580 - using bodySmall (13px w500) with w600 override
                                          style: AppTypography.bodySmall.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: _restaurant['statusOpen'] as bool
                                                ? AppColors.green
                                                : AppColors.red,
                                          ),
                                        ),
                                        SizedBox(width: 7),
                                        Container(
                                          width: 3,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.textPlaceholder,
                                          ),
                                        ),
                                        SizedBox(width: 7),
                                        Text(
                                          'til ${_restaurant['closingTime']}',
                                          style: AppTypography.bodySmall.copyWith(
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.textPlaceholder,
                                          ),
                                        ),
                                        SizedBox(width: 7),
                                        Container(
                                          width: 3,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.textPlaceholder,
                                          ),
                                        ),
                                        SizedBox(width: 7),
                                        Expanded(
                                          child: Text(
                                            _restaurant['priceRange'] as String,
                                            style: AppTypography.bodySmall.copyWith(
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.textPlaceholder,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 3),

                                    // Address
                                    Text(
                                      _restaurant['address'] as String,
                                      style: AppTypography.bodySmall.copyWith(
                                        fontWeight: FontWeight.w400,
                                        // Note: #aaa slightly lighter than textPlaceholder (#999)
                                        // Design gap: No token for this specific neutral shade
                                        color: Color(0xFFAAAAAA),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 14),

                          // 2. Quick action pills
                          _QuickActionButtons(phone: _restaurant['phone'] as String?),

                          // 3. Match card (if has needs)
                          if (hasNeeds) ...[
                            SizedBox(height: AppSpacing.lg),
                            _MatchCard(
                              isExpanded: _matchCardExpanded,
                              isFullMatch: isFullMatch,
                              matchedNeeds: _matched,
                              missedNeeds: _missed,
                              totalNeeds: _activeNeeds.length,
                              onToggle: () {
                                setState(() {
                                  _matchCardExpanded = !_matchCardExpanded;
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    ),

                    // 4. Opening hours & contact section
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: _OpeningHoursContactSection(
                        restaurant: _restaurant,
                        isExpanded: _contactExpanded,
                        onToggle: () {
                          setState(() {
                            _contactExpanded = !_contactExpanded;
                          });
                        },
                      ),
                    ),

                    // 5. Gallery section
                    _GallerySection(
                      activeTab: _activeGalleryTab,
                      tabs: _galleryTabs,
                      onTabChange: (tab) {
                        setState(() {
                          _activeGalleryTab = tab;
                        });
                      },
                      onViewAll: () {
                        // TODO: Navigate to gallery full page
                      },
                    ),

                    Container(height: 1, color: AppColors.divider),

                    // 6. Menu section
                    _MenuSection(
                      activeCategory: _activeMenuCategory,
                      categories: _menuCategories,
                      menuItems: _menuItems,
                      filterExpanded: _menuFilterExpanded,
                      selectedDietaryRestrictions: _selectedDietaryRestrictions,
                      selectedDietaryPreferences: _selectedDietaryPreferences,
                      selectedAllergens: _selectedAllergens,
                      onCategoryChange: (cat) {
                        setState(() {
                          _activeMenuCategory = cat;
                        });
                      },
                      onToggleFilter: () {
                        setState(() {
                          _menuFilterExpanded = !_menuFilterExpanded;
                        });
                      },
                      onDietaryRestrictionToggle: (restriction) {
                        setState(() {
                          if (_selectedDietaryRestrictions.contains(restriction)) {
                            _selectedDietaryRestrictions.remove(restriction);
                          } else {
                            _selectedDietaryRestrictions.add(restriction);
                          }
                        });
                      },
                      onDietaryPreferenceToggle: (preference) {
                        setState(() {
                          if (_selectedDietaryPreferences.contains(preference)) {
                            _selectedDietaryPreferences.remove(preference);
                          } else {
                            _selectedDietaryPreferences.add(preference);
                          }
                        });
                      },
                      onAllergenToggle: (allergen) {
                        setState(() {
                          if (_selectedAllergens.contains(allergen)) {
                            _selectedAllergens.remove(allergen);
                          } else {
                            _selectedAllergens.add(allergen);
                          }
                        });
                      },
                      onViewFullMenu: () {
                        // TODO: Navigate to menu full page
                      },
                      onItemTap: (item) {
                        // TODO: Show menu item detail overlay
                      },
                    ),

                    Container(height: 1, color: AppColors.divider),

                    // 7. Facilities section
                    _FacilitiesSection(
                      facilities: _facilities,
                      matchedNeeds: hasNeeds ? _activeNeeds : {},
                      onFacilityTap: (facility) {
                        // TODO: Show facilities info sheet
                      },
                    ),

                    Container(height: 1, color: AppColors.divider),

                    // 8. Payment options section
                    _PaymentSection(payments: _payments),

                    Container(height: 1, color: AppColors.divider),

                    // 9. About section (collapsible)
                    _AboutSection(
                      about: _restaurant['about'] as String,
                      isExpanded: _aboutExpanded,
                      onToggle: () {
                        setState(() {
                          _aboutExpanded = !_aboutExpanded;
                        });
                      },
                    ),

                    Container(height: 1, color: AppColors.divider),

                    // 10. Report button
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.xxl,
                        AppSpacing.xxl,
                        AppSpacing.xxl,
                        44, // JSX: 44px bottom
                      ),
                      child: Center(
                        child: TextButton(
                          onPressed: () {
                            // TODO: Show report missing info modal
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                          ),
                          child: Text(
                            'Rapportér manglende eller forkerte oplysninger',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textDisabled,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.textDisabled,
                            ),
                          ),
                        ),
                      ),
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
// QUICK ACTION BUTTONS
// ============================================================

class _QuickActionButtons extends StatelessWidget {
  final String? phone;

  const _QuickActionButtons({this.phone});

  @override
  Widget build(BuildContext context) {
    final actions = [
      if (phone != null) {'label': 'Ring op', 'icon': Icons.phone_outlined},
      {'label': 'Hjemmeside', 'icon': Icons.language_outlined},
      {'label': 'Bestil bord', 'icon': Icons.calendar_today_outlined},
      {'label': 'Se på kort', 'icon': Icons.location_on_outlined},
    ];

    return SizedBox(
      height: 36,
      // TODO: Implement right-edge scroll bleed pattern (lesson 59)
      // JSX uses marginRight: -24, paddingRight: 24 to let trailing items scroll to screen edge
      // Current: pills stop at hero section's 24px right padding
      // Fix: Move quick actions outside hero padding OR use Transform/Stack for negative margin effect
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (context, index) => SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final action = actions[index];
          return OutlinedButton.icon(
            onPressed: () {
              // TODO: Handle quick action
            },
            icon: Icon(
              action['icon'] as IconData,
              size: 14,
              // Note: #666 for icon - neutral shade between textSecondary (#555) and textTertiary (#888)
              // Design gap: No exact token
              color: Color(0xFF666666),
            ),
            label: Text(
              action['label'] as String,
              // Note: 13px w520 - using bodySmall (13px w500) with w600 override
              // Note: #444 for text - darker than textSecondary (#555)
              // Design gap: No exact token
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: Color(0xFF444444),
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: AppSpacing.sm, // 8px
              ),
              side: BorderSide(
                color: AppColors.border,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.filter), // 10px
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// MATCH CARD
// ============================================================

class _MatchCard extends StatelessWidget {
  final bool isExpanded;
  final bool isFullMatch;
  final List<String> matchedNeeds;
  final List<String> missedNeeds;
  final int totalNeeds;
  final VoidCallback onToggle;

  const _MatchCard({
    required this.isExpanded,
    required this.isFullMatch,
    required this.matchedNeeds,
    required this.missedNeeds,
    required this.totalNeeds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Note: Partial match uses accent-tinted surface (#fef8f2) and border (#f0dcc8)
        // Design gap: These specific accent tints have no AppColors tokens
        // TODO: Consider adding AppColors.accentSurface and AppColors.accentBorder
        color: isFullMatch ? AppColors.greenBg : const Color(0xFFFEF8F2),
        border: Border.all(
          color: isFullMatch ? AppColors.greenBorder : const Color(0xFFF0DCC8),
          width: 1.5,
        ),
        // Note: JSX uses borderRadius 12px — coincides with AppRadius.input numerically
        // but match card is a container, not an input field (semantic mismatch)
        // Using AppRadius.card (16px) for correct semantic meaning per lesson 65
        // TODO: Confirm 12px vs 16px with design team
        borderRadius: BorderRadius.circular(AppRadius.card), // 16px — semantic correctness
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: AppSpacing.md, // 12px
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isFullMatch ? Icons.check_circle_outline : Icons.info_outline,
                        size: 15,
                        color: isFullMatch ? AppColors.green : AppColors.accent,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        isFullMatch
                            ? 'Matcher alle ${matchedNeeds.length} behov'
                            : 'Matcher ${matchedNeeds.length} af $totalNeeds behov',
                        // Note: 13.5px w600 - using bodySmall (13px) with overrides
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: AppColors.textPlaceholder,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (isExpanded)
            Padding(
              // Note: 14px horizontal padding — between md (12px) and lg (16px), matching JSX pill padding
              padding: EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Wrap(
                // Note: 5px gap — design-specific value for dense chip layout (below sm=8px)
                spacing: 5,
                runSpacing: 5,
                children: [
                  ...matchedNeeds.map((need) => _NeedChip(
                        label: need,
                        matched: true,
                      )),
                  ...missedNeeds.map((need) => _NeedChip(
                        label: need,
                        matched: false,
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// NEED CHIP (for match card)
// ============================================================

class _NeedChip extends StatelessWidget {
  final String label;
  final bool matched;

  const _NeedChip({
    required this.label,
    required this.matched,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm, // 8px
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        border: Border.all(
          // Note: Missed need uses red-tinted border (#f5d5d2)
          // Design gap: No token for red border tint (complementary to greenBorder)
          // TODO: Consider adding AppColors.redBorder
          color: matched ? AppColors.greenBorder : Color(0xFFF5D5D2),
        ),
        // Note: 6px radius — below AppRadius.chip (8px) floor
        // Design-specific: tighter pill for inline match chips within card context
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            matched ? Icons.check : Icons.close,
            size: 8,
            color: matched ? AppColors.green : AppColors.red,
          ),
          SizedBox(width: 3),
          Text(
            label,
            // Note: 11px w560/w520 - using bodyTiny (12px) with overrides
            // JSX: matched=w560 (→w600), missed=w520 (→w500)
            style: AppTypography.bodyTiny.copyWith(
              fontSize: 11,
              fontWeight: matched ? FontWeight.w600 : FontWeight.w500,
              color: matched ? AppColors.green : AppColors.red,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// OPENING HOURS & CONTACT SECTION
// ============================================================

class _OpeningHoursContactSection extends StatelessWidget {
  final Map<String, dynamic> restaurant;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _OpeningHoursContactSection({
    required this.restaurant,
    required this.isExpanded,
    required this.onToggle,
  });

  String _getTodayPreview() {
    final days = ['Søndag', 'Mandag', 'Tirsdag', 'Onsdag', 'Torsdag', 'Fredag', 'Lørdag'];
    final today = days[DateTime.now().weekday % 7];
    final hours = restaurant['hours'] as List?;

    if (hours == null) return '';

    final todayEntry = hours.firstWhere(
      (entry) => entry[0] == today,
      orElse: () => null,
    );

    if (todayEntry == null) return '';
    return todayEntry[1] as String;
  }

  @override
  Widget build(BuildContext context) {
    final todayPreview = _getTodayPreview();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: onToggle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Åbningstider og kontakt',
                      // Note: JSX uses 18px w680 - using sectionHeading (18px w700)
                      style: AppTypography.sectionHeading,
                    ),
                    if (!isExpanded && todayPreview.isNotEmpty) ...[
                      SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Text(
                            'I dag: ',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          Text(
                            todayPreview,
                            style: AppTypography.bodySmall.copyWith(
                              color: todayPreview == 'Lukket'
                                ? AppColors.red
                                : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 14,
                  color: AppColors.textPlaceholder,
                ),
              ],
            ),
          ),

          // Expanded content
          if (isExpanded) ...[
            SizedBox(height: 14),
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(AppRadius.button), // 14px
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hours table
                  Text(
                    'ÅBNINGSTIDER',
                    // Note: 11.5px w620 uppercase - using bodyTiny (12px) with overrides
                    style: AppTypography.bodyTiny.copyWith(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.04,
                    ),
                  ),
                  SizedBox(height: 10),

                  // Hours rows
                  ...List.generate((restaurant['hours'] as List?)?.length ?? 0, (index) {
                    final hours = restaurant['hours'] as List;
                    final entry = hours[index];
                    final day = entry[0] as String;
                    final time = entry[1] as String;
                    final isLast = index == hours.length - 1;

                    return Container(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        border: !isLast
                            // Note: #ececec for inner-panel row separators
                            // Design gap: lighter than AppColors.border (#e8e8e8), darker than divider (#f2f2f2)
                            // Used for subtle separation within card content per lesson 63
                            ? Border(bottom: BorderSide(color: Color(0xFFECECEC)))
                            : null,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(
                              day,
                              // Note: 13.5px w500 - using bodySmall with size override
                              // Note: #333 for day name - slightly lighter than textPrimary (#0f0f0f)
                              // Design gap: No token for this neutral shade (lesson 63)
                              style: AppTypography.bodySmall.copyWith(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              time,
                              // Note: 13.5px w460/w520 - using bodySmall with overrides
                              // Note: #444 for time text - darker than textSecondary (#555)
                              // Design gap: No exact token (lesson 63 - consistent comment at every usage site)
                              style: AppTypography.bodySmall.copyWith(
                                fontSize: 13.5,
                                fontWeight: time == 'Lukket'
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                                color: time == 'Lukket'
                                  ? AppColors.red
                                  : Color(0xFF444444),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  SizedBox(height: AppSpacing.lg),
                  Container(height: 1, color: AppColors.border),
                  SizedBox(height: AppSpacing.lg),

                  // Contact
                  Text(
                    'KONTAKT',
                    // Note: 11.5px w620 uppercase - using bodyTiny with overrides
                    style: AppTypography.bodyTiny.copyWith(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.04,
                    ),
                  ),
                  SizedBox(height: 10),

                  // Phone
                  if (restaurant['phone'] != null)
                    _ContactRow(
                      label: 'Telefon',
                      value: restaurant['phone'] as String,
                      isAccent: false,
                      isLast: restaurant['website'] == null &&
                              restaurant['instagram'] == null &&
                              restaurant['booking'] == null,
                    ),

                  // Website
                  if (restaurant['website'] != null)
                    _ContactRow(
                      label: 'Hjemmeside',
                      value: restaurant['website'] as String,
                      isAccent: true,
                      isLast: restaurant['instagram'] == null &&
                              restaurant['booking'] == null,
                    ),

                  // Instagram
                  if (restaurant['instagram'] != null)
                    _ContactRow(
                      label: 'Instagram',
                      value: restaurant['instagram'] as String,
                      isAccent: true,
                      isLast: restaurant['booking'] == null,
                    ),

                  // Booking
                  if (restaurant['booking'] != null)
                    _ContactRow(
                      label: 'Booking',
                      value: restaurant['booking'] as String,
                      isAccent: true,
                      isLast: true,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// CONTACT ROW (for opening hours section)
// ============================================================

class _ContactRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isAccent;
  final bool isLast;

  const _ContactRow({
    required this.label,
    required this.value,
    required this.isAccent,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        border: !isLast
            ? Border(bottom: BorderSide(color: Color(0xFFECECEC)))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyRegular.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyRegular.copyWith(
              fontWeight: FontWeight.w500,
              color: isAccent ? AppColors.accent : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MENU FILTER PANEL
// ============================================================

class _MenuFilterPanel extends StatelessWidget {
  final Set<String> selectedRestrictions;
  final Set<String> selectedPreferences;
  final Set<String> selectedAllergens;
  final Function(String) onRestrictionToggle;
  final Function(String) onPreferenceToggle;
  final Function(String) onAllergenToggle;

  const _MenuFilterPanel({
    required this.selectedRestrictions,
    required this.selectedPreferences,
    required this.selectedAllergens,
    required this.onRestrictionToggle,
    required this.onPreferenceToggle,
    required this.onAllergenToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        // Note: #f0f0f0 border - lighter than standard border (#e8e8e8)
        // Design gap: No token for this lighter border shade
        border: Border.all(color: Color(0xFFF0F0F0)),
        borderRadius: BorderRadius.circular(AppRadius.button), // 14px
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kostrestriktioner (Dietary Restrictions)
          _FilterSection(
            title: 'Kostrestriktioner',
            subtitle: 'Vis kun retter, der overholder den valgte kostrestriktion.',
            items: ['Glutenfrit', 'Laktosefrit'],
            selectedItems: selectedRestrictions,
            onToggle: onRestrictionToggle,
          ),

          // Kostpræferencer (Dietary Preferences)
          _FilterSection(
            title: 'Kostpræferencer',
            subtitle: 'Vis kun retter, der overholder den valgte diæt.',
            items: ['Pescetarvenligt', 'Vegansk', 'Vegetarisk'],
            selectedItems: selectedPreferences,
            onToggle: onPreferenceToggle,
          ),

          // Allergener (Allergens)
          _FilterSection(
            title: 'Allergener',
            subtitle: 'Skjul retter, der indeholder det valgte allergen.',
            items: ['Bløddyr', 'Fisk', 'Jordnødder', 'Korn', 'Mælk', 'Æg', 'Soja', 'Selleri', 'Sennep', 'Sesamfrø'],
            selectedItems: selectedAllergens,
            onToggle: onAllergenToggle,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FILTER SECTION (for menu filter panel)
// ============================================================

class _FilterSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> items;
  final Set<String> selectedItems;
  final Function(String) onToggle;
  final bool isLast;

  const _FilterSection({
    required this.title,
    required this.subtitle,
    required this.items,
    required this.selectedItems,
    required this.onToggle,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          // Note: 14px w640 - using bodyRegular (14px) with w600 override
          style: AppTypography.bodyRegular.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2),
        Text(
          subtitle,
          style: AppTypography.bodyTiny.copyWith(
            color: AppColors.textPlaceholder,
            height: 1.4,
          ),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: items.map((item) {
            final isSelected = selectedItems.contains(item);
            return InkWell(
              onTap: () => onToggle(item),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : AppColors.bgPage,
                  border: Border.all(
                    color: isSelected ? AppColors.accent : Color(0xFFE4E4E4),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Text(
                  item,
                  // Note: 12.5px w600/w460 - using bodyTiny (12px) with overrides
                  style: AppTypography.bodyTiny.copyWith(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Colors.white : AppColors.textTertiary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        // Add gap after section unless it's the last one (lesson 62 - wire dead parameters)
        if (!isLast) SizedBox(height: 14),
      ],
    );
  }
}

// ============================================================
// GALLERY SECTION
// ============================================================

class _GallerySection extends StatelessWidget {
  final String activeTab;
  final List<String> tabs;
  final Function(String) onTabChange;
  final VoidCallback onViewAll;

  const _GallerySection({
    required this.activeTab,
    required this.tabs,
    required this.onTabChange,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    // Placeholder colors per tab
    final colors = {
      'Mad': [Color(0xFFF0DCC8), Color(0xFFE8C8B8), Color(0xFFD4B8A0), Color(0xFFC8A888), Color(0xFFDDC8B0), Color(0xFFF0E0D0)],
      'Menu': [Color(0xFFE0E0E0), Color(0xFFD8D8D8), Color(0xFFD0D0D0), Color(0xFFC8C8C8), Color(0xFFE0E0E0), Color(0xFFD8D8D8)],
      'Inde': [Color(0xFFD8CCC0), Color(0xFFC8B8A8), Color(0xFFE0D0C0), Color(0xFFD0C0B0), Color(0xFFC8B8A8), Color(0xFFD8CCC0)],
      'Ude': [Color(0xFFC0D8C8), Color(0xFFB0C8B8), Color(0xFFA8C0A8), Color(0xFFB8D0B8), Color(0xFFC0D8C8), Color(0xFFB0C8B8)],
    };

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Galleri',
                  // Note: JSX uses 18px w680 - using sectionHeading (18px w700)
                  style: AppTypography.sectionHeading,
                ),
                SizedBox(height: AppSpacing.md),

                // Tabs
                Row(
                  children: tabs.map((tab) {
                    final isActive = tab == activeTab;
                    return Expanded(
                      child: InkWell(
                        onTap: () => onTabChange(tab),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isActive ? AppColors.accent : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            tab,
                            textAlign: TextAlign.center,
                            // Note: 13.5px, w620/w460 - using bodySmall with overrides
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 13.5,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                              color: isActive ? AppColors.accent : AppColors.textPlaceholder,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.md),

          // Gallery grid
          // TODO: Add GestureDetector with onHorizontalDragEnd for swipe-to-change-tab
          // JSX: onTouchStart/onTouchEnd with dx > 40 threshold triggers adjacent tab
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                // Note: JSX uses 3px gap - design-specific value
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
                childAspectRatio: 1.0,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                final color = colors[activeTab]![index];
                // Complex border radius pattern from JSX
                BorderRadius radius;
                if (index == 0) {
                  radius = BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  );
                } else if (index == 2) {
                  radius = BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  );
                } else if (index == 3) {
                  radius = BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(4),
                  );
                } else if (index == 5) {
                  radius = BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(10),
                  );
                } else {
                  radius = BorderRadius.circular(4);
                }

                return Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: radius,
                  ),
                );
              },
            ),
          ),

          SizedBox(height: AppSpacing.sm),

          // View all button
          Center(
            child: TextButton(
              onPressed: onViewAll,
              child: Text(
                'Se alle billeder →',
                // Note: 13px w540 - using bodySmall (13px w500) with w600 override
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MENU SECTION
// ============================================================

class _MenuSection extends StatelessWidget {
  final String activeCategory;
  final List<String> categories;
  final List<Map<String, String>> menuItems;
  final bool filterExpanded;
  final Set<String> selectedDietaryRestrictions;
  final Set<String> selectedDietaryPreferences;
  final Set<String> selectedAllergens;
  final Function(String) onCategoryChange;
  final VoidCallback onToggleFilter;
  final Function(String) onDietaryRestrictionToggle;
  final Function(String) onDietaryPreferenceToggle;
  final Function(String) onAllergenToggle;
  final VoidCallback onViewFullMenu;
  final Function(Map<String, String>) onItemTap;

  const _MenuSection({
    required this.activeCategory,
    required this.categories,
    required this.menuItems,
    required this.filterExpanded,
    required this.selectedDietaryRestrictions,
    required this.selectedDietaryPreferences,
    required this.selectedAllergens,
    required this.onCategoryChange,
    required this.onToggleFilter,
    required this.onDietaryRestrictionToggle,
    required this.onDietaryPreferenceToggle,
    required this.onAllergenToggle,
    required this.onViewFullMenu,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.xxl,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Menu',
                style: AppTypography.sectionHeading,
              ),
              Text(
                'Sidst ajourført 15. dec 2025',
                // Note: 11.5px w400 — below bodyTiny (12px); no exact token
                // Design gap: JSX uses fontSize 11.5px for "last reviewed" metadata text
                style: AppTypography.bodyTiny.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textDisabled,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),

          // Filter toggle
          TextButton(
            onPressed: onToggleFilter,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              filterExpanded ? 'Skjul filtre' : 'Filtrer',
              // Note: 13.5px w560 - using bodySmall with overrides
              style: AppTypography.bodySmall.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ),
          SizedBox(height: 14),

          // Filter panel (if expanded)
          if (filterExpanded) ...[
            _MenuFilterPanel(
              selectedRestrictions: selectedDietaryRestrictions,
              selectedPreferences: selectedDietaryPreferences,
              selectedAllergens: selectedAllergens,
              onRestrictionToggle: onDietaryRestrictionToggle,
              onPreferenceToggle: onDietaryPreferenceToggle,
              onAllergenToggle: onAllergenToggle,
            ),
            SizedBox(height: AppSpacing.lg),
          ],

          // Category chips
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (context, index) => SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isActive = category == activeCategory;
                return OutlinedButton(
                  onPressed: () => onCategoryChange(category),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7, // Design-specific: 7px (between xs=4 and sm=8)
                    ),
                    backgroundColor: isActive ? AppColors.accent : AppColors.bgPage,
                    foregroundColor: isActive ? Colors.white : AppColors.textSecondary,
                    side: BorderSide(
                      color: isActive ? AppColors.accent : AppColors.border,
                      width: 1.5,
                    ),
                    // Note: 9px radius - between chip (8px) and filter (10px)
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: Text(
                    category,
                    // Note: 13px w600/w480 - using bodySmall with overrides
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // Menu items
          Text(
            activeCategory,
            // Note: 16px w650 - using categoryHeading (16px w700) with w600 override
            style: AppTypography.categoryHeading.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2),

          // Empty state when no items
          if (menuItems.isEmpty)
            Container(
              margin: EdgeInsets.only(top: AppSpacing.md),
              padding: EdgeInsets.symmetric(
                vertical: 32,
                horizontal: AppSpacing.xl,
              ),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                border: Border.all(color: Color(0xFFF0F0F0)),
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: Color(0xFFD0D0D0),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Ingen retter matcher dine filtre',
                    // Note: 15px w680 - using menuItemName (15px w600) with w700 override
                    style: AppTypography.menuItemName.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Prøv at fjerne nogle filtre eller vælg "Ryd alle"\nfor at se hele menuen.',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.textTertiary,
                      height: 1.38,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          // Menu items list
          // Note: Using indexed iteration to skip bottom border on last item (JSX: i < length - 1)
          ...List.generate(menuItems.length, (index) {
            final item = menuItems[index];
            final isLast = index == menuItems.length - 1;
            return InkWell(
              onTap: () => onItemTap(item),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  border: isLast ? null : Border(
                    bottom: BorderSide(color: AppColors.divider),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          item['name']!,
                          style: AppTypography.menuItemName, // 15px w600
                        ),
                        if (item['price'] != null)
                          Text(
                            item['price']!,
                            // Note: 13.5px w540 - using bodySmall with overrides
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.accent,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 3),
                    Text(
                      item['desc']!,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPlaceholder,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }),

          // View full menu button (only if items exist)
          if (menuItems.isNotEmpty) ...[
            SizedBox(height: AppSpacing.md),
            Center(
              child: TextButton(
                onPressed: onViewFullMenu,
                child: Text(
                  'Vis på hel side →',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
          SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

// ============================================================
// FACILITIES SECTION
// ============================================================

class _FacilitiesSection extends StatelessWidget {
  final List<String> facilities;
  final Set<String> matchedNeeds;
  final Function(String) onFacilityTap;

  const _FacilitiesSection({
    required this.facilities,
    required this.matchedNeeds,
    required this.onFacilityTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // JSX: padding: "16px 24px" → vertical 16px, horizontal 24px
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl, // 24px
        vertical: AppSpacing.lg,    // 16px
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Faciliteter og services',
            style: AppTypography.sectionHeading,
          ),
          SizedBox(height: AppSpacing.md),

          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: facilities.map((facility) {
              // Check if facility matches a need
              final isMatch = matchedNeeds.any((need) =>
                  facility.toLowerCase().contains(need.toLowerCase()) ||
                  need.toLowerCase().contains(facility.toLowerCase()));

              return InkWell(
                onTap: () => onFacilityTap(facility),
                borderRadius: BorderRadius.circular(9),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 7, // Design-specific: 7px (between xs=4 and sm=8)
                  ),
                  decoration: BoxDecoration(
                    color: isMatch ? AppColors.greenBg : AppColors.bgPage,
                    border: Border.all(
                      color: isMatch ? AppColors.greenBorder : AppColors.border,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        facility,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: isMatch ? FontWeight.w600 : FontWeight.w500,
                          // Note: #444 for non-match facility text - darker than textSecondary (#555)
                          // Design gap: No exact token
                          color: isMatch ? AppColors.green : Color(0xFF444444),
                        ),
                      ),
                      // TODO: Info icon currently always shown — facilities data model simplified to List<String>
                      // JSX: only facilities with f.i=true show info icon and respond to tap
                      // When real data is wired, extend model to carry hasInfo flag and conditionally render:
                      // if (facilityHasInfo) ...[SizedBox(width: 5), Icon(...)]
                      SizedBox(width: 5),
                      Icon(
                        Icons.info_outline,
                        size: 12,
                        color: isMatch ? AppColors.green : AppColors.textDisabled,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PAYMENT SECTION
// ============================================================

class _PaymentSection extends StatelessWidget {
  final List<String> payments;

  const _PaymentSection({required this.payments});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // JSX: padding: "16px 24px" → vertical 16px, horizontal 24px
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl, // 24px
        vertical: AppSpacing.lg,    // 16px
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Betalingsmuligheder',
            style: AppTypography.sectionHeading,
          ),
          SizedBox(height: AppSpacing.md),

          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: payments.map((payment) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7, // Design-specific: 7px (between xs=4 and sm=8)
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.border,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  payment,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ABOUT SECTION
// ============================================================

class _AboutSection extends StatelessWidget {
  final String about;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _AboutSection({
    required this.about,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Om',
                  style: AppTypography.sectionHeading,
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: AppColors.textPlaceholder,
                ),
              ],
            ),
          ),

          if (isExpanded) ...[
            SizedBox(height: AppSpacing.md),
            Text(
              about,
              style: AppTypography.bodyRegular.copyWith(
                color: AppColors.textSecondary,
                height: 1.65,
              ),
            ),
          ],
        ],
      ),
    );
  }
}