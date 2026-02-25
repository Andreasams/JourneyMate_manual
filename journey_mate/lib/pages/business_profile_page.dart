import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../providers/business_providers.dart';
import '../services/api_service.dart';
import '../services/analytics_service.dart';
import '../services/translation_service.dart';
import '../services/business_cache.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../widgets/shared/profile_top_business_block_widget.dart';
import '../widgets/shared/restaurant_shimmer_widget.dart';
import '../widgets/shared/expandable_text_widget.dart';
import '../widgets/shared/payment_options_widget.dart';
import '../widgets/shared/erroneous_info_form_widget.dart';
import '../widgets/shared/opening_hours_and_weekdays.dart';
import '../widgets/shared/business_feature_buttons.dart';
import '../widgets/business_profile/match_card_widget.dart';
import '../widgets/business_profile/quick_actions_widget.dart';
import '../widgets/business_profile/inline_gallery_widget.dart';
import '../widgets/business_profile/inline_menu_widget.dart';
import '../providers/filter_providers.dart';
import '../providers/search_providers.dart';
import 'package:share_plus/share_plus.dart';

/// Business Profile Page - Detailed restaurant view with single scroll
/// JSX alignment - Phase 8 implementation
///
/// Features:
/// - 3 parallel API calls on load (business profile, menu items, filter descriptions)
/// - Single scrollable page with 10 sections (replaces 3-tab interface)
/// - Match card showing filter match percentage
/// - Quick actions (Call, Website, Booking, Map)
/// - Inline gallery and menu sections
/// - Menu session analytics tracking
/// - Comprehensive page view analytics
class BusinessProfilePage extends ConsumerStatefulWidget {
  final String businessId;

  const BusinessProfilePage({
    super.key,
    required this.businessId,
  });

  @override
  ConsumerState<BusinessProfilePage> createState() =>
      _BusinessProfilePageState();
}

class _BusinessProfilePageState extends ConsumerState<BusinessProfilePage> {
  // ============================================================================
  // LOCAL STATE
  // ============================================================================

  DateTime? _pageStartTime;
  bool _isLoading = false;
  String? _errorMessage;

  // ============================================================================
  // LIFECYCLE METHODS
  // ============================================================================

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();

    // Try to show cached preview data immediately (optimistic UI)
    _loadCachedPreview();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadBusinessData();
    });
  }

  /// Load cached preview data from search results for instant display
  void _loadCachedPreview() {
    final businessIdInt = int.tryParse(widget.businessId);
    if (businessIdInt == null) return;

    final preview = BusinessCache.instance.getBusinessPreview(businessIdInt);
    if (preview != null) {
      debugPrint('⚡ Showing cached preview: ${preview['business_name']}');

      // Show preview data immediately
      ref.read(businessProvider.notifier).setCurrentBusiness(
            business: preview,
            filterIds: [], // Filters will come from API
            hours: preview['business_hours'] ?? {},
          );

      // Not loading anymore (preview is shown)
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _trackPageView();
    _endMenuSession();
    super.dispose();
  }

  // ============================================================================
  // DATA LOADING (3 PARALLEL API CALLS)
  // ============================================================================

  Future<void> _loadBusinessData() async {
    final languageCode = Localizations.localeOf(context).languageCode;
    final businessIdInt = int.parse(widget.businessId);

    debugPrint('🏢 Loading full business data: id=$businessIdInt');

    // Only show loading state if we don't have cached preview
    final hasPreview = ref.read(businessProvider).currentBusiness != null;
    if (!hasPreview) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // Make 3 API calls in parallel
      final results = await Future.wait([
        ApiService.instance.getBusinessProfile(
          businessId: businessIdInt,
          languageCode: languageCode,
        ),
        ApiService.instance.getRestaurantMenu(
          businessId: businessIdInt,
          languageCode: languageCode,
        ),
        ApiService.instance.getFilterDescriptions(
          businessId: businessIdInt,
          languageCode: languageCode,
        ),
      ]);

      final profileResponse = results[0];
      final menuResponse = results[1];
      final filterDescResponse = results[2];

      // Check if page is still mounted after async calls
      if (!mounted) return;

      // Store business profile data in provider
      if (profileResponse.succeeded) {
        // API returns 'businessInfo' key (not 'business_profile' as documented)
        final businessData = profileResponse.jsonBody['businessInfo'];
        final businessHours = profileResponse.jsonBody['businessHours'] ?? {};

        if (businessData == null) {
          debugPrint('❌ Business not found: id=$businessIdInt');
          setState(() {
            _errorMessage = 'Business not found (ID: $businessIdInt)';
            _isLoading = false;
          });
          return;
        }

        // Extract filters from tags or filters array if available
        // For now, use empty list - filters will be handled separately
        final filters = <int>[];

        debugPrint('✅ API data loaded: ${businessData['business_name']}');

        ref.read(businessProvider.notifier).setCurrentBusiness(
              business: businessData,
              filterIds: filters,
              hours: businessHours,
            );
      } else {
        debugPrint('❌ API error: ${profileResponse.error}');
        setState(() {
          _errorMessage = profileResponse.error ?? 'Failed to load business profile';
          _isLoading = false;
        });
        return;
      }

      // Store menu items in provider
      if (menuResponse.succeeded) {
        ref.read(businessProvider.notifier).setMenuItems(
              menuResponse.jsonBody['menu_items'],
            );

        // Store dietary availability
        final availablePreferences =
            (menuResponse.jsonBody['availablePreferences'] as List?)
                    ?.cast<int>() ??
                [];
        final availableRestrictions =
            (menuResponse.jsonBody['availableRestrictions'] as List?)
                    ?.cast<int>() ??
                [];

        ref.read(businessProvider.notifier).setDietaryOptions(
              preferences: availablePreferences,
              restrictions: availableRestrictions,
            );
      }

      // Store filter descriptions in provider (for MatchCardWidget)
      if (filterDescResponse.succeeded) {
        final descriptions =
            filterDescResponse.jsonBody['filterDescriptions'] as List? ?? [];
        final matchPercentage =
            (filterDescResponse.jsonBody['matchPercentage'] as num?)?.toDouble() ?? 0.0;

        ref.read(businessProvider.notifier).setFilterDescriptions(
              descriptions,
              matchPercentage,
            );
      }

      // Start menu session (fire-and-forget analytics)
      _startMenuSession(businessIdInt);

      // Clear loading state (if it was set)
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load business data: $e';
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================================
  // ANALYTICS TRACKING
  // ============================================================================

  void _startMenuSession(int businessId) {
    // Fire-and-forget analytics
    ref.read(analyticsProvider.notifier).startMenuSession(businessId);
  }

  void _endMenuSession() {
    // Fire-and-forget analytics
    final businessIdInt = int.tryParse(widget.businessId);
    if (businessIdInt != null) {
      ref.read(analyticsProvider.notifier).endMenuSession(businessIdInt);
    }
  }

  void _trackPageView() {
    if (_pageStartTime == null) return;
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
        'pageName': 'businessProfile',
        'durationSeconds': duration.inSeconds,
        'businessId': widget.businessId,
      },
    )
        .catchError((e) {
      debugPrint('Analytics error: $e');
      return ApiCallResponse.failure('Analytics failed');
    });
  }

  void _trackShare() {
    final analytics = AnalyticsService.instance;
    final business = ref.read(businessProvider).currentBusiness;

    ApiService.instance
        .postAnalytics(
      eventType: 'business_shared',
      deviceId: analytics.deviceId ?? '',
      sessionId: analytics.currentSessionId ?? '',
      userId: analytics.userId ?? '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'businessId': widget.businessId,
        'businessName': business?['business_name'] ?? '',
      },
    )
        .catchError((e) {
      debugPrint('Analytics error: $e');
      return ApiCallResponse.failure('Analytics failed');
    });
  }

  // ============================================================================
  // BUILD METHOD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final business = ref.watch(businessProvider).currentBusiness;

    // Loading state
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.bgPage,
        body: const RestaurantShimmerWidget(),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.bgPage,
        appBar: AppBar(
          backgroundColor: AppColors.bgPage,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.textTertiary,
              ),
              SizedBox(height: AppSpacing.lg),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Text(
                  _errorMessage!,
                  style: AppTypography.bodyRegular.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: _loadBusinessData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                ),
                child: Text(
                  td(ref, 'error_retry_button'),
                  style: AppTypography.button.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (business == null) {
      return Scaffold(
        backgroundColor: AppColors.bgPage,
        appBar: AppBar(
          backgroundColor: AppColors.bgPage,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.business_outlined,
                size: 64,
                color: AppColors.textTertiary,
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                td(ref, 'business_not_found'),
                style: AppTypography.bodyRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Success state - Main content (single scrollable page)
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            color: AppColors.textPrimary,
            onPressed: _handleShare,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Section 1: Hero (ProfileTopBusinessBlockWidget)
          const SliverToBoxAdapter(
            child: ProfileTopBusinessBlockWidget(),
          ),

          // Spacing between sections
          SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.lg),
          ),

          // Section 2: Quick Actions (QuickActionsWidget)
          const SliverToBoxAdapter(
            child: QuickActionsWidget(),
          ),

          // Spacing between sections
          SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.lg),
          ),

          // Section 3: Match Card (MatchCardWidget)
          const SliverToBoxAdapter(
            child: MatchCardWidget(),
          ),

          // Spacing between sections
          SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.lg),
          ),

          // Section 4: Opening Hours
          SliverToBoxAdapter(
            child: _buildOpeningHoursSection(),
          ),

          // Spacing between sections
          SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.lg),
          ),

          // Section 5: Gallery (InlineGalleryWidget)
          const SliverToBoxAdapter(
            child: InlineGalleryWidget(),
          ),

          // Spacing between sections
          SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.lg),
          ),

          // Section 6: Menu (InlineMenuWidget)
          SliverToBoxAdapter(
            child: InlineMenuWidget(
              businessId: int.parse(widget.businessId),
            ),
          ),

          // Spacing between sections
          SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.lg),
          ),

          // Section 7: Facilities
          SliverToBoxAdapter(
            child: _buildFacilitiesSection(),
          ),

          // Spacing between sections
          SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.lg),
          ),

          // Section 8: Payments
          SliverToBoxAdapter(
            child: _buildPaymentsSection(),
          ),

          // Spacing between sections
          SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.lg),
          ),

          // Section 9: About
          SliverToBoxAdapter(
            child: _buildAboutSection(),
          ),

          // Spacing between sections
          SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.lg),
          ),

          // Section 10: Report Link
          SliverToBoxAdapter(
            child: _buildReportLink(),
          ),

          // Bottom padding
          SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxl),
          ),
        ],
      ),
    );
  }


  // ============================================================================
  // ACTIONS
  // ============================================================================

  /// Handle share button press
  void _handleShare() {
    final business = ref.read(businessProvider).currentBusiness;
    if (business == null) return;

    _trackShare();

    final businessName = business['business_name'] ?? '';
    final businessType = business['business_type'] ?? '';
    final street = business['address']?['street'] ?? '';

    SharePlus.instance.share(
      ShareParams(
        text: 'Check out $businessName on JourneyMate!\n\n'
            '$businessType\n'
            '$street\n\n'
            'Find restaurants that match your dietary needs with JourneyMate.',
        subject: businessName,
      ),
    );
  }

  // ============================================================================
  // SECTION BUILDERS
  // ============================================================================

  /// Build opening hours section
  Widget _buildOpeningHoursSection() {
    final openingHours = ref.read(businessProvider).openingHours;

    if (openingHours == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            td(ref, 'opening_hours_heading'),
            style: AppTypography.sectionHeading,
          ),
          SizedBox(height: AppSpacing.sm),
          OpeningHoursAndWeekdays(
            openingHours: openingHours,
          ),
        ],
      ),
    );
  }

  /// Build facilities section (business features)
  Widget _buildFacilitiesSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            td(ref, 'facilities_heading'),
            style: AppTypography.sectionHeading,
          ),
          SizedBox(height: AppSpacing.sm),
          BusinessFeatureButtons(
            containerWidth:
                MediaQuery.of(context).size.width - (AppSpacing.xxl * 2),
            onInitialCount: (int count) async {
              debugPrint('Facilities count: $count');
            },
            onHeightCalculated: (double height) async {
              debugPrint('Facilities widget height: $height');
            },
          ),
        ],
      ),
    );
  }

  /// Build payments section
  Widget _buildPaymentsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            td(ref, 'about_payment_options_label'),
            style: AppTypography.sectionHeading,
          ),
          SizedBox(height: AppSpacing.sm),
          PaymentOptionsWidget(
            containerWidth:
                MediaQuery.of(context).size.width - (AppSpacing.xxl * 2),
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
        ],
      ),
    );
  }

  /// Build about section (expandable description)
  Widget _buildAboutSection() {
    final business = ref.read(businessProvider).currentBusiness;
    final description = business?['description'] as String?;

    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            td(ref, 'about_description_label'),
            style: AppTypography.sectionHeading,
          ),
          SizedBox(height: AppSpacing.sm),
          ExpandableTextWidget(
            text: description,
            businessId: int.tryParse(widget.businessId),
          ),
        ],
      ),
    );
  }

  /// Build report link button
  Widget _buildReportLink() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Center(
        child: TextButton.icon(
          onPressed: () async {
            // Track analytics
            final analytics = AnalyticsService.instance;
            ApiService.instance
                .postAnalytics(
              eventType: 'report_link_tapped',
              deviceId: analytics.deviceId ?? '',
              sessionId: analytics.currentSessionId ?? '',
              userId: analytics.userId ?? '',
              timestamp: DateTime.now().toIso8601String(),
              eventData: {
                'pageName': 'businessProfile',
              },
            )
                .catchError((e) {
              debugPrint('Analytics error: $e');
              return ApiCallResponse.failure('Analytics failed');
            });

            // Open report form
            if (mounted) {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const ErroneousInfoFormWidget(),
              );
            }
          },
          icon: Icon(Icons.report_outlined, color: AppColors.textSecondary),
          label: Text(
            td(ref, 'about_report_incorrect_info'),
            style: AppTypography.label.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
