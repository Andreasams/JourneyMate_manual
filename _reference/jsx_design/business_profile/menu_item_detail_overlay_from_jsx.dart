// ============================================================
// MENU ITEM DETAIL OVERLAY - Converted from JSX v2 Design
// Clean Flutter UI shell with no backend functionality
//
// Expandable overlay showing full menu item details
// Features: language/currency switcher, dietary info, allergens
// This is the UI shell only - backend integration comes later
// ============================================================

import 'package:flutter/material.dart';
import '../../shared/app_theme.dart';

/// Shows menu item details in a modal overlay
///
/// Usage:
/// ```dart
/// showMenuItemDetailOverlay(
///   context,
///   item: menuItem,
/// );
/// ```
void showMenuItemDetailOverlay(
  BuildContext context, {
  required Map<String, dynamic> item,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (context) => MenuItemDetailOverlay(item: item),
  );
}

class MenuItemDetailOverlay extends StatefulWidget {
  final Map<String, dynamic> item;

  const MenuItemDetailOverlay({
    super.key,
    required this.item,
  });

  @override
  State<MenuItemDetailOverlay> createState() => _MenuItemDetailOverlayState();
}

class _MenuItemDetailOverlayState extends State<MenuItemDetailOverlay> {
  String _language = 'da';
  String _currency = 'DKK';
  bool _menuOpen = false;
  bool _reminderExpanded = false;

  // TODO: Replace with actual translation system
  Map<String, String> get _translations => {
        'additionalInfo': _language == 'da' ? 'Yderligere Information' : 'Additional Information',
        'dietary': _language == 'da' ? 'Kostpræferencer og restriktioner' : 'Dietary preferences and restrictions',
        'allergens': _language == 'da' ? 'Allergener' : 'Allergens',
        'reminder': _language == 'da' ? 'Påmindelse' : 'Reminder',
        'reminderText1': _language == 'da'
            ? 'Husk altid at bekræfte ingrediens- og kostoplysninger med personalet, inden du bestiller. Ingredienser, opskrifter og personale kan ændre sig, og krydskontaminering kan forekomme.'
            : 'Always verify ingredient and dietary information with staff before ordering. Ingredients, recipes, and staff can change, and cross-contamination may occur.',
        'reminderText2': _language == 'da'
            ? 'JourneyMate kan ikke garantere nøjagtigheden af disse oplysninger. Ved alvorlige allergier eller diætbehov, kontakt venligst restauranten direkte.'
            : 'JourneyMate cannot guarantee the accuracy of this information. For severe allergies or dietary requirements, please contact the restaurant directly.',
      };

  // Convert price based on currency
  String _convertPrice(String priceStr) {
    final basePrice = double.tryParse(priceStr.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
    if (_currency == 'USD') return '\$${(basePrice / 7.5).toStringAsFixed(0)}';
    if (_currency == 'GBP') return '£${(basePrice / 9).toStringAsFixed(0)}';
    return priceStr;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.84, // 84vh
        ),
        decoration: BoxDecoration(
          color: AppColors.bgPage, // JSX uses #fff for modal/sheet backgrounds
          borderRadius: BorderRadius.circular(AppRadius.card), // 16px
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: EdgeInsets.only(top: AppSpacing.md), // 12px
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                // Note: 4px radius - design-specific value for drag handle pattern
                // No semantic token for this visual element
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            // Header buttons
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg, // 16px
                AppSpacing.md, // 12px
                AppSpacing.lg,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close button
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    iconSize: 20,
                    color: AppColors.textPrimary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),

                  // Three-dot menu
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _menuOpen = !_menuOpen;
                          });
                        },
                        icon: const Icon(Icons.more_horiz),
                        iconSize: 20,
                        color: AppColors.textPrimary,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),

                      // Dropdown menu
                      if (_menuOpen)
                        Positioned(
                          top: 36,
                          right: 0,
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(AppRadius.filter), // 10px
                            child: Container(
                              width: 220,
                              decoration: BoxDecoration(
                                color: AppColors.bgSurface,
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(AppRadius.filter),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  _MenuOption(
                                    label: 'View dish in Danish',
                                    isSelected: _language == 'da',
                                    onTap: () {
                                      setState(() {
                                        _language = 'da';
                                        _menuOpen = false;
                                      });
                                    },
                                  ),
                                  _MenuOption(
                                    label: 'View dish in English',
                                    isSelected: _language == 'en',
                                    onTap: () {
                                      setState(() {
                                        _language = 'en';
                                        _menuOpen = false;
                                      });
                                    },
                                  ),
                                  _MenuOption(
                                    label: 'View price in US Dollar (\$)',
                                    isSelected: _currency == 'USD',
                                    onTap: () {
                                      setState(() {
                                        _currency = 'USD';
                                        _menuOpen = false;
                                      });
                                    },
                                  ),
                                  _MenuOption(
                                    label: 'View price in British Pound (£)',
                                    isSelected: _currency == 'GBP',
                                    isLast: true, // Last item - no bottom border
                                    onTap: () {
                                      setState(() {
                                        _currency = 'GBP';
                                        _menuOpen = false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xxl, // 24px horizontal
                  AppSpacing.sm, // 8px top
                  AppSpacing.xxl,
                  AppSpacing.xxl, // 24px bottom
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item name
                    Text(
                      _language == 'da' ? widget.item['name'] : widget.item['nameEn'] ?? widget.item['name'],
                      // Note: 18px w630 - using sectionHeading (18px w700) with w600 override
                      style: AppTypography.sectionHeading.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.33, // 24px / 18px
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm), // 8px

                    // Price
                    Text(
                      _convertPrice(widget.item['price']),
                      // Note: 15px w540 - using menuItemName (15px w600) with w500 override
                      style: AppTypography.menuItemName.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.accent,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md), // 12px

                    // Description
                    Text(
                      _language == 'da' ? widget.item['description'] : widget.item['descriptionEn'] ?? widget.item['description'],
                      style: AppTypography.bodyRegular.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.43, // 20px / 14px
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl), // 20px

                    // Divider
                    Container(
                      height: 1,
                      color: AppColors.divider,
                    ),
                    SizedBox(height: AppSpacing.xl), // 20px

                    // Additional Information heading
                    Text(
                      _translations['additionalInfo']!,
                      style: AppTypography.menuItemName, // 15px w600
                    ),
                    SizedBox(height: AppSpacing.md), // 12px

                    // Dietary preferences
                    if (widget.item['dietary'] != null) ...[
                      _InfoSection(
                        label: _translations['dietary']!,
                        content: _language == 'da' ? widget.item['dietary'] : widget.item['dietaryEn'] ?? widget.item['dietary'],
                      ),
                      SizedBox(height: AppSpacing.lg), // 16px
                    ],

                    // Allergens
                    if (widget.item['allergens'] != null) ...[
                      _InfoSection(
                        label: _translations['allergens']!,
                        content: _language == 'da' ? widget.item['allergens'] : widget.item['allergensEn'] ?? widget.item['allergens'],
                      ),
                      SizedBox(height: AppSpacing.lg), // 16px
                    ],

                    // Reminder expandable
                    InkWell(
                      onTap: () {
                        setState(() {
                          _reminderExpanded = !_reminderExpanded;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm), // 8px
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _translations['reminder']!,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Icon(
                              _reminderExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              size: 16,
                              color: AppColors.textTertiary,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Reminder content
                    if (_reminderExpanded) ...[
                      SizedBox(height: AppSpacing.sm), // 8px
                      Text(
                        _translations['reminderText1']!,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          height: 1.38, // 18px / 13px
                        ),
                      ),
                      SizedBox(height: AppSpacing.md), // 12px
                      Text(
                        _translations['reminderText2']!,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          height: 1.38, // 18px / 13px
                        ),
                      ),
                    ],
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
// MENU OPTION WIDGET
// ============================================================

class _MenuOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLast;

  const _MenuOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, // 16px
          vertical: AppSpacing.md, // 12px
        ),
        decoration: BoxDecoration(
          // Note: Accent tint surface — no token exists
          // Design gap: #fef8f2 used for selected state background
          // TODO: Add AppColors.accentSurface to design system
          color: isSelected ? const Color(0xFFFEF8F2) : AppColors.bgPage,
          border: !isLast
              ? Border(
                  bottom: BorderSide(color: AppColors.divider),
                )
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.label, // 14px w500
        ),
      ),
    );
  }
}

// ============================================================
// INFO SECTION WIDGET
// ============================================================

class _InfoSection extends StatelessWidget {
  final String label;
  final String content;

  const _InfoSection({
    required this.label,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.xs), // 4px
        Text(
          content,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
