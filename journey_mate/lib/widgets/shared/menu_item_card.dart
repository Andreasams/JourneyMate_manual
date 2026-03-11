import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';
import '../../services/custom_functions/price_formatter.dart';

/// Pure display component for individual menu items within MenuDishesListView.
///
/// Shows menu item name, description, price, and dietary preference badges.
/// Allergen information is handled by the bottom sheet (tap to open).
///
/// Design Source: Menu Full Page JSX + MenuDishesListView patterns
class MenuItemCard extends ConsumerWidget {
  const MenuItemCard({
    super.key,
    required this.name,
    this.description,
    this.price,
    this.currencyCode,
    this.dietaryPreferenceIds = const [],
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

  /// Callback when card is tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    style: AppTypography.h6,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Price (fixed width, right-aligned)
                if (price != null && currencyCode != null)
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: Text(
                      // Using centralized price formatter for consistency
                      convertAndFormatPrice(
                            price!,
                            currencyCode!,
                            1.0, // No conversion needed (display in original currency)
                            currencyCode!,
                          ) ??
                          '${price!.round()} ${currencyCode!}',
                      style: AppTypography.bodyLgMedium.copyWith(
                        fontWeight: FontWeight.w600,
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
                style: AppTypography.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Dietary preference badges (if any)
            if (dietaryPreferenceIds.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: dietaryPreferenceIds
                    .map((id) => _buildDietaryBadge(id))
                    .toList(),
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

}
