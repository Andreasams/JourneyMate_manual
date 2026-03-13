import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../services/translation_service.dart';
import '../shared/menu_section_widget.dart';

/// Inline menu section on the business profile page.
///
/// Thin wrapper around [MenuSectionWidget] that adds horizontal padding
/// and a "View on full page" navigation link.
///
/// Layout:
/// Padding(horizontal: xxl)
///   Column
///     MenuSectionWidget(isFullPage: false)  — constrained to 337px
///     "View on full page" + arrow
class InlineMenuWidget extends ConsumerWidget {
  final int businessId;

  const InlineMenuWidget({
    super.key,
    required this.businessId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MenuSectionWidget(
            businessId: businessId,
            isFullPage: false,
          ),

          // ── "View on full page" button ─────────────────────────────────────
          Padding(
            padding: EdgeInsets.only(top: AppSpacing.lg),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.push('/business/$businessId/menu'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  backgroundColor: AppColors.bgCard,
                  side: BorderSide(
                    color: AppColors.border,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.filter),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      td(ref, 'menu_view_full_page'),
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
  }
}
