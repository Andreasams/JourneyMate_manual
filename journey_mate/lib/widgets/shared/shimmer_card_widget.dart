import 'package:flutter/material.dart';
import 'package:journey_mate/theme/app_colors.dart';
import 'package:journey_mate/theme/app_radius.dart';
import 'package:journey_mate/theme/app_spacing.dart';

class ShimmerCardWidget extends StatelessWidget {
  final int index;

  const ShimmerCardWidget({
    required this.index,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Vary line widths based on index for visual balance
    final widths = [0.7, 0.5, 0.4]; // 70%, 50%, 40%

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.mlg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.border,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      padding: EdgeInsets.all(AppSpacing.mlg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo placeholder
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.border.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppRadius.logoSmall),
            ),
          ),
          SizedBox(width: AppSpacing.mlg),
          // Text content area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line 1: Name (70% width)
                Container(
                  height: 14,
                  width: MediaQuery.of(context).size.width * widths[0] * 0.6,
                  decoration: BoxDecoration(
                    color: AppColors.border.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                // Line 2: Status (50% width)
                Container(
                  height: 12,
                  width: MediaQuery.of(context).size.width * widths[1] * 0.6,
                  decoration: BoxDecoration(
                    color: AppColors.border.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                // Line 3: Details (40% width)
                Container(
                  height: 12,
                  width: MediaQuery.of(context).size.width * widths[2] * 0.6,
                  decoration: BoxDecoration(
                    color: AppColors.border.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
