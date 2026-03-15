import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../providers/app_providers.dart';
import '../../providers/business_providers.dart';
import '../../providers/filter_providers.dart';
import '../../providers/search_providers.dart';
import '../../services/api_service.dart';
import '../../services/analytics_service.dart';
import '../../services/custom_functions/business_status.dart';
import '../../services/custom_functions/days_day_opening_hour.dart';
import '../../services/translation_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/shared/expandable_text_widget.dart';
import '../../widgets/shared/business_feature_buttons.dart';
import '../../widgets/shared/payment_options_widget.dart';
import '../../widgets/shared/erroneous_info_form_widget.dart';
import '../../widgets/shared/section_card.dart';
import '../../widgets/business_profile/opening_hours_contact_widget.dart';
import '../../widgets/shared/description_sheet.dart';

/// Business Information Page - Dedicated full-screen business detail view
///
/// Displays comprehensive restaurant information including interactive map,
/// real-time status, opening hours, features, payment options, and contact details.
///
/// Route: /business/:id/information
class BusinessInformationPage extends ConsumerStatefulWidget {
  final String businessId;

  const BusinessInformationPage({super.key, required this.businessId});

  @override
  ConsumerState<BusinessInformationPage> createState() =>
      _BusinessInformationPageState();
}

class _BusinessInformationPageState
    extends ConsumerState<BusinessInformationPage> {
  // ============================================================================
  // LOCAL STATE (NOT providers)
  // ============================================================================

  static const double _mapHeight = 200.0;

  /// Page start time for analytics duration tracking
  DateTime? _pageStartTime;

  // ============================================================================
  // LIFECYCLE
  // ============================================================================

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();
  }

  @override
  void dispose() {
    // Track page view with duration
    if (_pageStartTime != null) {
      final duration = DateTime.now().difference(_pageStartTime!);
      final analytics = AnalyticsService.instance;

      ApiService.instance
          .postAnalytics(
        eventType: 'page_viewed',
        deviceId: analytics.deviceId ?? '',
        sessionId: analytics.currentSessionId ?? '',
        userId: analytics.userId ?? '',
        timestamp: DateTime.now().toIso8601String(),
        eventData: {
          'pageName': 'businessInformation', // ← EXACT name per BUNDLE.md
          'durationSeconds': duration.inSeconds,
          'businessId': int.parse(widget.businessId),
        },
      )
          .catchError((_) {
        // Fire-and-forget, ignore errors
        return ApiCallResponse.failure('Analytics failed');
      });
    }
    super.dispose();
  }

  // ============================================================================
  // BUILD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final business = ref.watch(businessProvider).currentBusiness;
    final businessName = business?['business_name'] ?? 'Information';

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: _buildAppBar(businessName),
      body: _buildBody(business),
    );
  }

  // ============================================================================
  // APP BAR
  // ============================================================================

  AppBar _buildAppBar(String businessName) {
    return AppBar(
      backgroundColor: AppColors.bgPage,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        businessName,
        style: AppTypography.h5,
      ),
      centerTitle: true,
    );
  }

  // ============================================================================
  // BODY
  // ============================================================================

  Widget _buildBody(Map<String, dynamic>? business) {
    if (business == null) {
      return Center(
        child: Text(
          td(ref, 'no_business_data'),
          style: AppTypography.bodyLg.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full-width map
          _buildMapSection(business),

          // Padded content below map
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSpacing.md),

                // Card 1: Business name + open/closed status
                SectionCard(child: _buildTitleAndStatus(business)),
                SizedBox(height: AppSpacing.md),

                // Card 2: Description (conditional)
                _buildDescriptionSection(business),

                // Card 3: Opening hours & contact
                SectionCard(
                  child: const OpeningHoursContactWidget(
                    showTodayPreview: false,
                  ),
                ),
                SizedBox(height: AppSpacing.md),

                // Card 4: Features, services & amenities
                SectionCard(child: _buildFeaturesSection(business)),
                SizedBox(height: AppSpacing.md),

                // Card 5: Payment options
                SectionCard(child: _buildPaymentOptionsSection()),
                SizedBox(height: AppSpacing.md),

                // Report incorrect info (not carded)
                _buildReportButton(),
                SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // MAP SECTION
  // ============================================================================

  Widget _buildMapSection(Map<String, dynamic> business) {
    final lat = (business['latitude'] as num?)?.toDouble();
    final lng = (business['longitude'] as num?)?.toDouble();

    if (lat == null || lng == null) {
      // Fallback: Grey placeholder
      return SizedBox(
        height: _mapHeight,
        child: Container(
          color: AppColors.bgInput,
          child: Center(
            child: Text(
              td(ref, 'map_unavailable'),
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    final location = LatLng(lat, lng);

    return SizedBox(
      height: _mapHeight,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: location,
          zoom: 12,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('business_location'),
            position: location,
          ),
        },
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        trafficEnabled: false,
      ),
    );
  }

  // ============================================================================
  // TITLE + STATUS SECTION
  // ============================================================================

  Widget _buildTitleAndStatus(Map<String, dynamic> business) {
    final businessName = business['business_name'] ?? '';
    final openingHours = ref.watch(businessProvider).openingHours;
    final languageCode = Localizations.localeOf(context).languageCode;
    final translationsCache = ref.watch(mergedTranslationsCacheProvider);
    final now = DateTime.now(); // Single timestamp for color/text consistency

    final statusResult = determineStatusAndColor(
      openingHours,
      now,
      languageCode,
      translationsCache,
    );
    final statusColor = statusResult['color'] as Color;

    final openingHoursText = daysDayOpeningHour(
      now,
      openingHours,
      languageCode,
      translationsCache,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          businessName,
          style: AppTypography.h4,
        ),
        SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Icon(Icons.circle_rounded, size: 12, color: statusColor),
            SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                openingHoursText,
                style: AppTypography.body,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================================
  // DESCRIPTION SECTION
  // ============================================================================

  Widget _buildDescriptionSection(Map<String, dynamic> business) {
    final description = business['description'];

    // Only render if description exists and is non-empty
    if (description == null || description.toString().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              td(ref, 'about_description_label'), // "About"
              style: AppTypography.h4,
            ),
            SizedBox(height: AppSpacing.sm),
            ExpandableTextWidget(
              text: description,
              businessId: int.tryParse(widget.businessId),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // FEATURES SECTION
  // ============================================================================

  Widget _buildFeaturesSection(Map<String, dynamic> business) {
    // Container width = screen - outer padding (12*2) - card border (1.5*2) - card inner padding (12*2)
    final cardContentWidth =
        MediaQuery.of(context).size.width - (AppSpacing.md * 4) - 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          td(ref, 'facilities_heading'),
          style: AppTypography.h4,
        ),
        SizedBox(height: AppSpacing.sm),
        BusinessFeatureButtons(
          containerWidth: cardContentWidth,
          onInitialCount: (int count) async {},
          onFilterTap: _showFacilitiesInfoSheet,
          onHeightCalculated: (double height) async {},
        ),
      ],
    );
  }

  /// Show facilities info bottom sheet (matches profile page)
  Future<void> _showFacilitiesInfoSheet(
    int filterId,
    String filterName,
    String? filterDescription,
  ) async {
    if (context.mounted) {
      _trackFacilityInfoOpened(filterName, filterDescription);
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DescriptionSheet(
          title: filterName,
          description: filterDescription,
          fallbackDescription: td(ref, 'no_description_available'),
        ),
      );
    }
  }

  /// Track facility info sheet opened (fire-and-forget).
  void _trackFacilityInfoOpened(
      String filterName, String? filterDescription) {
    final analytics = AnalyticsService.instance;
    ApiService.instance
        .postAnalytics(
      eventType: 'facility_info_opened',
      deviceId: analytics.deviceId ?? '',
      sessionId: analytics.currentSessionId ?? '',
      userId: analytics.userId ?? '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'pageName': 'businessInformation',
        'facilityName': filterName,
        'hasDescription':
            filterDescription != null && filterDescription.isNotEmpty,
      },
    )
        .catchError((e) {
      return ApiCallResponse.failure('Analytics failed');
    });
  }

  // ============================================================================
  // PAYMENT OPTIONS SECTION
  // ============================================================================

  Widget _buildPaymentOptionsSection() {
    // Container width = screen - outer padding (12*2) - card border (1.5*2) - card inner padding (12*2)
    final cardContentWidth =
        MediaQuery.of(context).size.width - (AppSpacing.md * 4) - 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          td(ref, 'about_payment_options_label'), // "Payment Options"
          style: AppTypography.h4,
        ),
        SizedBox(height: AppSpacing.sm),
        PaymentOptionsWidget(
          containerWidth: cardContentWidth,
          filters: ref.watch(filterProvider).value?.filtersForLanguage ?? [],
          filtersUsedForSearch:
              ref.watch(searchStateProvider).filtersUsedForSearch,
          filtersOfThisBusiness: ref.watch(businessProvider).businessFilterIds,
          onInitialCount: (int count) async {},
          onHeightCalculated: (double height) async {},
        ),
      ],
    );
  }

  // ============================================================================
  // REPORT BUTTON
  // ============================================================================

  Widget _buildReportButton() {
    return Center(
      child: TextButton(
        onPressed: () async {
          final analytics = AnalyticsService.instance;
          ApiService.instance
              .postAnalytics(
            eventType: 'report_link_tapped',
            deviceId: analytics.deviceId ?? '',
            sessionId: analytics.currentSessionId ?? '',
            userId: analytics.userId ?? '',
            timestamp: DateTime.now().toIso8601String(),
            eventData: {'pageName': 'businessInformation'},
          )
              .catchError((e) {
            return ApiCallResponse.failure('Analytics failed');
          });
          if (mounted) {
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const ErroneousInfoFormWidget(),
            );
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.report_outlined, color: AppColors.textSecondary),
            SizedBox(width: AppSpacing.xs),
            Text(
              td(ref, 'about_report_incorrect_info'),
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.textSecondary,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
