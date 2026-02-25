// ============================================================
// FACILITIES INFO SHEET - Converted from JSX v2 Design
// Clean Flutter UI shell with no backend functionality
//
// Bottom sheet showing detailed facility information
// Shows title and description for selected facility
// This is the UI shell only - backend integration comes later
// ============================================================

import 'package:flutter/material.dart';
import '../../shared/app_theme.dart';

/// Shows facility details in a bottom sheet
///
/// Usage:
/// ```dart
/// showFacilitiesInfoSheet(
///   context,
///   facilityLabel: 'Udendørs siddepladser',
/// );
/// ```
void showFacilitiesInfoSheet(
  BuildContext context, {
  required String facilityLabel,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => FacilitiesInfoSheet(facilityLabel: facilityLabel),
  );
}

class FacilitiesInfoSheet extends StatelessWidget {
  final String facilityLabel;

  const FacilitiesInfoSheet({
    super.key,
    required this.facilityLabel,
  });

  // Mock facility data - TODO: Replace with actual facility data from backend
  static const Map<String, Map<String, String>> _facilityInfo = {
    'Udendørs siddepladser': {
      'title': 'Udendørs siddepladser',
      'description':
          'Vi har udendørs siddepladser med udsigt. Perfekt til solrige dage og lune sommeraftener.',
    },
    'Morgenmad': {
      'title': 'Morgenmad',
      'description':
          'Vi serverer morgenmad dagligt fra kl. 7:00 til 11:00. Vores morgenmadsmenu inkluderer friskbagte croissanter, brød, æg, pålæg og friskpresset juice.',
    },
    'Børnestol': {
      'title': 'Børnestol',
      'description':
          'Vi har børnestole tilgængelige. Giv os besked når du bestiller bord, så vi sørger for at have en klar til jer.',
    },
    'Hunde tilladt ude': {
      'title': 'Hunde tilladt ude',
      'description':
          'Hunde er velkomne i vores udeområde. Vi har vandskåle tilgængelige.',
    },
    'Økologisk': {
      'title': 'Økologiske ingredienser',
      'description':
          'Vi prioriterer økologiske og bæredygtige ingredienser i vores køkken.',
    },
  };

  @override
  Widget build(BuildContext context) {
    // Get facility info or use default
    final info = _facilityInfo[facilityLabel] ?? {
          'title': facilityLabel,
          'description':
              'For mere information om denne facilitet, kontakt venligst restauranten direkte.',
        };

    return Container(
      height: MediaQuery.of(context).size.height * 0.5, // 50% height
      decoration: BoxDecoration(
        color: AppColors.bgPage, // JSX uses #fff for modal/sheet backgrounds
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.card), // 16px
          topRight: Radius.circular(AppRadius.card),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: EdgeInsets.only(top: AppSpacing.md), // 12px
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl, // 20px horizontal
                AppSpacing.xxl, // 24px top
                AppSpacing.xl,
                AppSpacing.xxxl, // 32px bottom
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Padding(
                    padding: EdgeInsets.only(right: AppSpacing.huge), // 40px right padding
                    child: Text(
                      info['title']!, // TODO: Translation handling
                      // Design gap: 20px w700 — no exact token
                      // restaurantName is 24px w800; overriding both size and weight
                      style: AppTypography.restaurantName.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg), // 16px

                  // Description
                  Text(
                    info['description']!, // TODO: Translation handling
                    style: AppTypography.bodyRegular.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.43, // 20px / 14px
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
