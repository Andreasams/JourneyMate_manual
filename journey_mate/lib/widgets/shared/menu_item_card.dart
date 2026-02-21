import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';
import '../../services/translation_service.dart';

/// Pure display component for individual menu items within MenuDishesListView.
///
/// Shows menu item name, description, price, dietary preference badges,
/// and allergen warning indicators with zero state management dependencies.
///
/// Design Source: Menu Full Page JSX + MenuDishesListView patterns
class MenuItemCard extends StatelessWidget {
  const MenuItemCard({
    super.key,
    required this.name,
    this.description,
    this.price,
    this.currencyCode,
    this.dietaryPreferenceIds = const [],
    this.allergenIds = const [],
    this.hasAllergenOverride = false,
    this.onTap,
  });

  /// Menu item name (e.g., "Eggs Benedict")
  final String name;

  /// Item description (optional)
  final String? description;

  /// Price in original currency (nullable for items without pricing)
  final double? price;

  /// Currency code for price display (e.g., "DKK")
  final String? currencyCode;

  /// Dietary preference IDs this item satisfies (e.g., [100, 101] for Vegan, Vegetarian)
  final List<int> dietaryPreferenceIds;

  /// Allergen IDs present in this item
  final List<int> allergenIds;

  /// Whether allergens can be removed on request (overrides allergen display logic)
  final bool hasAllergenOverride;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final showAllergenWarning =
        allergenIds.isNotEmpty && !hasAllergenOverride;
    final hasBadgesOrWarning =
        dietaryPreferenceIds.isNotEmpty || showAllergenWarning;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name + Price row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name (flexible to take available space)
                Expanded(
                  child: Text(
                    name,
                    style: AppTypography.bodyRegular.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Price (fixed width, right-aligned)
                if (price != null && currencyCode != null)
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: Text(
                      _formatPrice(price!, currencyCode!),
                      style: AppTypography.label.copyWith(
                        color: AppColors.accent,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
              ],
            ),

            // Description (if exists)
            if (description != null && description!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                description!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Dietary badges + Allergen warning (if any exist)
            if (hasBadgesOrWarning) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  // Dietary preference badges
                  if (dietaryPreferenceIds.isNotEmpty)
                    Expanded(
                      child: Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: dietaryPreferenceIds
                            .map((id) => _buildDietaryBadge(id))
                            .toList(),
                      ),
                    ),

                  // Allergen warning
                  if (showAllergenWarning)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (dietaryPreferenceIds.isNotEmpty)
                          const SizedBox(width: AppSpacing.sm),
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: AppColors.red,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          ts(
                            context,
                            'menu_contains_allergens',
                          ).replaceAll('{count}', '${allergenIds.length}'),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds a dietary preference badge icon
  Widget _buildDietaryBadge(int preferenceId) {
    // Map preference IDs to icons
    // 100 = Vegan, 101 = Vegetarian, 102 = Pescetarian
    IconData icon;
    Color color;

    switch (preferenceId) {
      case 100:
        // Vegan
        icon = Icons.eco;
        color = AppColors.success;
        break;
      case 101:
        // Vegetarian
        icon = Icons.spa;
        color = AppColors.success;
        break;
      case 102:
        // Pescetarian
        icon = Icons.set_meal;
        color = AppColors.accent;
        break;
      default:
        icon = Icons.circle;
        color = AppColors.textSecondary;
    }

    return Icon(
      icon,
      size: 18,
      color: color,
    );
  }

  /// Formats price with currency symbol
  String _formatPrice(double priceValue, String currency) {
    // Simple formatting - integrate with convertAndFormatPrice if needed
    final code = currency.toUpperCase();

    // Currency-specific formatting
    switch (code) {
      case 'DKK':
      case 'SEK':
      case 'NOK':
        return '${priceValue.round()} kr.';
      case 'EUR':
        return '€${priceValue.toStringAsFixed(2)}';
      case 'USD':
        return '\$${priceValue.toStringAsFixed(2)}';
      case 'GBP':
        return '£${priceValue.toStringAsFixed(1)}';
      default:
        return '${priceValue.round()} $currency';
    }
  }
}
