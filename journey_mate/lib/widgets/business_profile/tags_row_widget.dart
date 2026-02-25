import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../providers/business_providers.dart';

/// Tags Row Widget - Horizontal scrollable display of business tags
///
/// Features:
/// - Conditional display: hides if no tags available
/// - Non-interactive display-only chips
/// - Horizontal scroll with right padding for fade effect
/// - Self-contained (reads from businessProvider internally)
///
/// Design:
/// - Horizontal SingleChildScrollView with Row
/// - White chips with light gray border (#e8e8e8)
/// - 8px gap between chips
/// - 24px horizontal padding
/// - Border radius: 8px (AppRadius.chip)
/// - Padding: 6px 12px per chip
/// - Font: 12.5px, w500, #555 (AppColors.textSecondary)
///
class TagsRowWidget extends ConsumerWidget {
  const TagsRowWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(businessProvider).currentBusiness;

    // Hide if no business data
    if (business == null) return const SizedBox.shrink();

    // Extract tags from business data (API returns List<String> or null)
    final tags = business['tags'] as List<dynamic>?;

    // Hide if no tags
    if (tags == null || tags.isEmpty) {
      return const SizedBox.shrink();
    }

    // Convert to List<String> safely (filter out any non-string values)
    final tagList = tags.whereType<String>().toList();

    // Hide if no valid string tags
    if (tagList.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),  // 24px
      child: Row(
        children: [
          for (int i = 0; i < tagList.length; i++) ...[
            _buildTagChip(tagList[i]),
            if (i < tagList.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  /// Build individual tag chip
  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFE8E8E8),  // Light gray border
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(AppRadius.chip),  // 8px
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,  // #555
          height: 1.2,
        ),
      ),
    );
  }
}
