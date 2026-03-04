import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../providers/app_providers.dart';
import '../../providers/business_providers.dart';
import '../../providers/filter_providers.dart';
import '../../providers/search_providers.dart';
import '../../services/api_service.dart';
import '../../services/analytics_service.dart';
import '../../services/translation_service.dart';
import '../../services/custom_actions/determine_status_and_color.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import '../../widgets/shared/expandable_text_widget.dart';
import '../../widgets/shared/business_feature_buttons.dart';
import '../../widgets/shared/payment_options_widget.dart';
import '../../widgets/shared/contact_details_widget.dart';
import '../../widgets/shared/erroneous_info_form_widget.dart';
import '../../widgets/shared/filter_description_sheet.dart';

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

  /// Page start time for analytics duration tracking
  DateTime? _pageStartTime;

  /// Status color for indicator dot (set by determineStatusAndColor callback)
  Color? _statusColor;

  /// Status text (e.g., "Åbner kl. 17:30", "Lukker kl. 22:00")
  String? _statusText;

  // ============================================================================
  // LIFECYCLE
  // ============================================================================

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // Calculate status
      final business = ref.read(businessProvider).currentBusiness;
      final openingHours = business?['opening_hours'];

      if (openingHours != null) {
        final statusText = await determineStatusAndColor(
          (color) async {
            if (mounted) {
              setState(() => _statusColor = color);
            }
          },
          openingHours,
          DateTime.now(),
          Localizations.localeOf(context).languageCode,
          ref.read(translationsCacheProvider),
        );

        if (mounted) {
          setState(() => _statusText = statusText);
        }
      }
    });
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
        style: AppTypography.bodyRegular.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  // ============================================================================
  // BODY (STACK LAYOUT)
  // ============================================================================

  Widget _buildBody(Map<String, dynamic>? business) {
    if (business == null) {
      return Center(
        child: Text(
          td(ref, 'no_business_data'),
          style: AppTypography.bodyRegular.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Layer 1: Scrollable Content (starts at 250px from top)
        _buildScrollableContent(business),

        // Layer 2: Google Map (positioned at top)
        _buildMapSection(business),

        // Layer 3: Status Overlay (positioned over map bottom)
        _buildStatusOverlay(business),
      ],
    );
  }

  // ============================================================================
  // MAP SECTION
  // ============================================================================

  Widget _buildMapSection(Map<String, dynamic> business) {
    final lat = business['latitude'] as double?;
    final lng = business['longitude'] as double?;

    if (lat == null || lng == null) {
      // Fallback: Grey placeholder
      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: 200,
        child: Container(
          color: AppColors.bgInput,
          child: Center(
            child: Text(
              td(ref, 'map_unavailable'),
              style: AppTypography.bodyRegular.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    final location = LatLng(lat, lng);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 200,
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
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        trafficEnabled: false,
      ),
    );
  }

  // ============================================================================
  // STATUS OVERLAY
  // ============================================================================

  Widget _buildStatusOverlay(Map<String, dynamic> business) {
    final businessName = business['business_name'] ?? 'Restaurant';

    return Positioned(
      top: 168, // 200px map height - 32px overlay height
      left: AppSpacing.md,
      right: AppSpacing.md,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Business Name
              Text(
                businessName,
                style: AppTypography.sectionHeading.copyWith(fontSize: 24),
              ),
              SizedBox(height: AppSpacing.xs),

              // Status Row (dot + text)
              if (_statusText != null)
                Row(
                  children: [
                    // Colored dot
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _statusColor ?? AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),

                    // Status text
                    Expanded(
                      child: Text(
                        _statusText!,
                        style: AppTypography.bodyRegular.copyWith(
                          fontWeight: FontWeight.w300,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // SCROLLABLE CONTENT
  // ============================================================================

  Widget _buildScrollableContent(Map<String, dynamic> business) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: 250, // Map 200px + overlay 32px + gap 18px
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Business Description (Conditional)
          _buildDescriptionSection(business),

          // Section 2: Features, Services & Amenities
          _buildFeaturesSection(business),

          // Section 3: Payment Options
          _buildPaymentOptionsSection(),

          // Section 4: Contact Details
          _buildContactDetailsSection(),

          // Section 5: Report Incorrect Info Button
          _buildReportButton(),
        ],
      ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          td(ref, 'about_description_label'), // "About"
          style: AppTypography.sectionHeading,
        ),
        SizedBox(height: AppSpacing.sm),
        ExpandableTextWidget(
          text: description,
          businessId: int.tryParse(widget.businessId),
        ),
        SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  // ============================================================================
  // FEATURES SECTION
  // ============================================================================

  Widget _buildFeaturesSection(Map<String, dynamic> business) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          td(ref, '7pk0thnp'), // "Features, services & amenities"
          style: AppTypography.sectionHeading,
        ),
        SizedBox(height: AppSpacing.sm),
        BusinessFeatureButtons(
          containerWidth:
              MediaQuery.of(context).size.width - (AppSpacing.lg * 2),
          onInitialCount: (int count) async {
            debugPrint('Feature buttons count: $count');
          },
          onFilterTap: _showFilterDescriptionSheet,
          onHeightCalculated: (double height) async {
            debugPrint('Feature buttons height: $height');
          },
        ),
        SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  /// Show filter description bottom sheet
  Future<void> _showFilterDescriptionSheet(
    int filterId,
    String filterName,
    String? filterDescription,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterDescriptionSheet(
        filterName: filterName,
        filterDescription: filterDescription ?? '',
      ),
    );
  }

  // ============================================================================
  // PAYMENT OPTIONS SECTION
  // ============================================================================

  Widget _buildPaymentOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          td(ref, 'about_payment_options_label'), // "Payment Options"
          style: AppTypography.sectionHeading,
        ),
        SizedBox(height: AppSpacing.sm),
        PaymentOptionsWidget(
          containerWidth:
              MediaQuery.of(context).size.width - (AppSpacing.lg * 2),
          filters: ref.watch(filterProvider).value?.filtersForLanguage ?? [],
          filtersUsedForSearch:
              ref.watch(searchStateProvider).filtersUsedForSearch,
          filtersOfThisBusiness: ref.watch(businessProvider).businessFilterIds,
          onInitialCount: (int count) async {
            debugPrint('Payment options count: $count');
          },
          onHeightCalculated: (double height) async {
            debugPrint('Payment widget height: $height');
          },
        ),
        SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  // ============================================================================
  // CONTACT DETAILS SECTION
  // ============================================================================

  Widget _buildContactDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          td(ref, 'c9r4q0c8'), // "Hours & contact"
          style: AppTypography.sectionHeading,
        ),
        SizedBox(height: AppSpacing.sm),
        const ContactDetailsWidget(),
        SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  // ============================================================================
  // REPORT BUTTON
  // ============================================================================

  Widget _buildReportButton() {
    return Center(
      child: TextButton.icon(
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const ErroneousInfoFormWidget(),
          );
        },
        icon: Icon(Icons.report_outlined, color: AppColors.textSecondary),
        label: Text(
          td(ref, 'about_report_incorrect_info'),
          style: AppTypography.label.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
