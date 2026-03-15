import 'package:flutter/material.dart';
import 'package:journey_mate/theme/app_colors.dart';
import 'package:journey_mate/theme/app_radius.dart';
import 'package:journey_mate/theme/app_spacing.dart';

class ShimmerCardWidget extends StatelessWidget {
  const ShimmerCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 50), // Match logo size minimum
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.border,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      padding: const EdgeInsets.all(AppSpacing.mlg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo placeholder
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.border.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppRadius.logoSmall),
            ),
          ),
          SizedBox(width: AppSpacing.md), // 12px — matches real card spacing
          // Text content area
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Line 1: Name (70% width) — matches AppTypography.bodyHeavy (15 * 1.45 = 22px)
                    Container(
                      height: 22,
                      width: availableWidth * 0.7,
                      decoration: BoxDecoration(
                        color: AppColors.border.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    // Line 2: Status (50% width) — matches AppTypography.bodySm (14 * 1.45 = 20px)
                    Container(
                      height: 20,
                      width: availableWidth * 0.5,
                      decoration: BoxDecoration(
                        color: AppColors.border.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    // Line 3: Details (40% width) — matches AppTypography.bodySm (14 * 1.45 = 20px)
                    Container(
                      height: 20,
                      width: availableWidth * 0.4,
                      decoration: BoxDecoration(
                        color: AppColors.border.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
