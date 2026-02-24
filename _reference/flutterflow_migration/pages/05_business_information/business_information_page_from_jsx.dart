// ============================================================
// BUSINESS INFORMATION PAGE - Converted from JSX v2 Design
// Clean Flutter UI shell with no backend functionality
//
// Detailed information page accessible from business profile
// Shows: hero image, status, about, hours, facilities, payments
// This is the UI shell only - backend integration comes later
// ============================================================

import 'package:flutter/material.dart';
import '../../shared/app_theme.dart';

// Import for translation support
// TODO: Update path when integrated with main app
// import '/flutter_flow/custom_functions.dart' as functions;

class BusinessInformationPage extends StatefulWidget {
  final String languageCode;
  final dynamic translationsCache;

  const BusinessInformationPage({
    super.key,
    required this.languageCode,
    required this.translationsCache,
  });

  @override
  State<BusinessInformationPage> createState() =>
      _BusinessInformationPageState();
}

class _BusinessInformationPageState extends State<BusinessInformationPage> {
  // Translation helper function
  String _getUIText(String key) {
    // TODO: Uncomment when integrated with main app
    // return functions.getTranslations(
    //   widget.languageCode,
    //   key,
    //   widget.translationsCache,
    // );
    // Temporary fallback until integration
    return key;
  }

  // Mock data - TODO: Replace with actual restaurant data from props/state
  final String _restaurantName = 'Restaurant Name';
  final bool _isOpen = true;
  final String _statusText = 'Åbent til 22:00';
  final String? _about =
      'Cozy restaurant serving traditional Danish cuisine with a modern twist. Perfect for family dinners and celebrations.';
  final List<String> _facilities = [
    'Handicapvenligt',
    'Udeservering',
    'WiFi',
    'Parkering',
    'Børnevenligt',
  ];
  final List<String> _payments = [
    'Kontant',
    'Dankort',
    'Visa',
    'Mastercard',
    'MobilePay',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and restaurant name
            Container(
              height: 60,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl), // 20px
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.divider), // #f2f2f2
                ),
              ),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    onPressed: () {
                      // TODO: Add markUserEngaged() call
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back_ios_new),
                    color: AppColors.textPrimary,
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                  // Centered restaurant name
                  Expanded(
                    child: Text(
                      _restaurantName, // TODO: Translation handling for name
                      // Note: Using categoryHeading (16px w700) with w600 override
                      // Design system gap: No token for 16px w600
                      style: AppTypography.categoryHeading.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Spacer to balance the back button
                  const SizedBox(width: 36),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: AppSpacing.huge), // 40px
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero image placeholder
                    // TODO: Replace with actual restaurant image from data
                    Container(
                      width: double.infinity,
                      height: 180,
                      color: const Color(0xFFD0D0D0), // Grey placeholder
                    ),

                    // Content section
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.xxl, // 24px horizontal
                        AppSpacing.xl, // 20px top
                        AppSpacing.xxl,
                        AppSpacing.xl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Restaurant name
                          Text(
                            _restaurantName, // TODO: Translation handling
                            style: AppTypography.restaurantName, // 24px w800
                          ),
                          // Note: 6px gap - design-specific value between xs (4px) and sm (8px)
                          // Recurring pattern for status indicator spacing
                          SizedBox(height: 6),

                          // Status indicator
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      _isOpen ? AppColors.green : AppColors.red,
                                ),
                              ),
                              // Note: 6px gap - design-specific value for status dot spacing
                              // Recurring pattern across LocalizationPage and BusinessInformationPage
                              SizedBox(width: 6),
                              Text(
                                _statusText, // TODO: Translation key
                                // Note: JSX uses fontWeight: 460 which maps to w400 per font weight table
                                // Using bodySmall (13px w500) with w400 override
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.lg), // 16px

                          // About description (if exists)
                          if (_about != null) ...[
                            Text(
                              _about!, // TODO: Translation handling
                              style: AppTypography.bodyRegular, // 14px w400, lineHeight 1.43
                            ),
                            SizedBox(height: AppSpacing.xxl), // 24px
                          ],

                          // Opening hours section
                          // TODO: Implement OpeningHoursSection component
                          // TODO: Pass title, hours, contact (phone, links), variant='info'
                          _OpeningHoursSectionPlaceholder(
                            title: _getUIText('information_page_heading_hours'),
                          ),

                          // Facilities section (if exists)
                          if (_facilities.isNotEmpty) ...[
                            SizedBox(height: AppSpacing.xxl), // 24px
                            Text(
                              _getUIText('information_page_heading_facilities'),
                              style: AppTypography.menuItemName, // 15px w600 - perfect match!
                            ),
                            SizedBox(height: AppSpacing.md), // 12px
                            Wrap(
                              spacing: AppSpacing.sm, // 8px
                              runSpacing: AppSpacing.sm,
                              children: _facilities.map((facility) {
                                return _ChipWidget(label: facility);
                              }).toList(),
                            ),
                          ],

                          // Payment methods section (if exists)
                          if (_payments.isNotEmpty) ...[
                            SizedBox(height: AppSpacing.xxl), // 24px
                            Text(
                              _getUIText('information_page_heading_payments'),
                              style: AppTypography.menuItemName, // 15px w600
                            ),
                            SizedBox(height: AppSpacing.md), // 12px
                            Wrap(
                              spacing: AppSpacing.sm, // 8px
                              runSpacing: AppSpacing.sm,
                              children: _payments.map((payment) {
                                return _ChipWidget(label: payment);
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
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
// PLACEHOLDER WIDGET FOR OPENING HOURS SECTION
// TODO: Replace with actual OpeningHoursSection component
// ============================================================

/// Placeholder for OpeningHoursSection component
/// Shows basic expandable section structure
class _OpeningHoursSectionPlaceholder extends StatefulWidget {
  final String title;

  const _OpeningHoursSectionPlaceholder({
    required this.title,
  });

  @override
  State<_OpeningHoursSectionPlaceholder> createState() =>
      _OpeningHoursSectionPlaceholderState();
}

class _OpeningHoursSectionPlaceholderState
    extends State<_OpeningHoursSectionPlaceholder> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg), // 16px
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card), // 16px
        border: Border.all(color: AppColors.border),
        color: AppColors.bgSurface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (tappable to expand/collapse)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: AppTypography.menuItemName, // 15px w600
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),

          // Expandable content
          if (_isExpanded) ...[
            SizedBox(height: AppSpacing.lg),
            Text(
              'TODO: Implement opening hours display',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'TODO: Implement contact info (phone, links)',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// CHIP WIDGET FOR FACILITIES AND PAYMENTS
// ============================================================

/// Chip widget for displaying facilities and payment methods
class _ChipWidget extends StatelessWidget {
  final String label;

  const _ChipWidget({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md, // 12px
        vertical: 7, // Design-specific: 7px (between xs=4 and sm=8)
      ),
      decoration: BoxDecoration(
        // Note: 10px radius is used for facility/payment chips
        borderRadius: BorderRadius.circular(AppRadius.filter), // 10px
        color: AppColors.bgCard,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label, // TODO: Translation handling for facility/payment names
        style: AppTypography.chip, // 12.5px w600
      ),
    );
  }
}
