import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MenuSectionWidget(
            businessId: businessId,
            isFullPage: false,
          ),

          // ── "View on full page" row ──────────────────────────────────────
          Padding(
            padding: EdgeInsets.only(top: AppSpacing.lg),
            child: GestureDetector(
              onTap: () => context.push('/business/$businessId/menu'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text(
                      td(ref, 'menu_view_full_page'),
                      style: AppTypography.bodyLgMedium,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(
                      Icons.keyboard_arrow_right_sharp,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
