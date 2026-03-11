import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';
import '../../services/custom_functions/price_formatter.dart';

/// Pure display component for individual menu items within MenuDishesListView.
///
/// Shows menu item name, description, price, and an optional right-aligned image.
/// Allergen and dietary information are handled by the bottom sheet (tap to open).
///
/// Design Source: Menu Full Page JSX + MenuDishesListView patterns
class MenuItemCard extends ConsumerWidget {
  const MenuItemCard({
    super.key,
    required this.name,
    this.description,
    this.price,
    this.currencyCode,
    this.imageUrl,
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

  /// Image URL for the item (optional, displayed right-aligned at 133×75)
  final String? imageUrl;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text content (takes remaining space)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: hasImage ? AppSpacing.sm : 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Price row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: AppTypography.h6,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (price != null && currencyCode != null)
                          Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.sm),
                            child: Text(
                              convertAndFormatPrice(
                                    price!,
                                    currencyCode!,
                                    1.0,
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
                  ],
                ),
              ),
            ),

            // Image (right-aligned, conditional)
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.chip),
                child: Image.network(
                  imageUrl!,
                  width: 133,
                  height: 75,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    width: 133,
                    height: 75,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
