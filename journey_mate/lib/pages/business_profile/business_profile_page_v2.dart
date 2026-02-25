import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/app_providers.dart';
import '../../providers/business_providers.dart';
import '../../providers/locale_provider.dart';
import '../../services/api_service.dart';
import '../../services/translation_service.dart';
import '../../services/business_cache.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import '../../widgets/shared/restaurant_shimmer_widget.dart';
import '../../widgets/business_profile/hero_section_widget.dart';
import '../../widgets/business_profile/quick_actions_pills_widget.dart';
import '../../widgets/business_profile/match_card_widget.dart';
import '../../widgets/business_profile/tags_row_widget.dart';
import '../../widgets/business_profile/opening_hours_contact_widget.dart';

/// Business Profile Page V2 - Complete rewrite from JSX blueprint
///
/// This is a fresh implementation following the JSX design exactly:
/// - Hero section with business logo, name, details
/// - Quick actions pills (white bg, dark text/icons)
/// - Match card (green for 100%, orange for partial)
/// - Gallery with flat tabs (bottom border indicator)
/// - Menu with inline filter panel (3 sections)
/// - Facilities with green highlighting for matches
/// - Payment options, About section, Report link
///
/// Reference: _reference/jsx_design/business_profile/business_profile.jsx
class BusinessProfilePageV2 extends ConsumerStatefulWidget {
  final String businessId;

  const BusinessProfilePageV2({
    super.key,
    required this.businessId,
  });

  @override
  ConsumerState<BusinessProfilePageV2> createState() =>
      _BusinessProfilePageV2State();
}

class _BusinessProfilePageV2State extends ConsumerState<BusinessProfilePageV2> {
  // ============================================================================
  // LOCAL STATE
  // ============================================================================

  DateTime? _pageStartTime;
  bool _isLoading = false;
  String? _errorMessage;
  // TODO: Phase 7 - About section expansion state
  // bool _aboutExpanded = false; // JSX: collapsed by default
  // TODO: Phase 2 - Match card expansion state
  // bool _matchCardExpanded = false; // JSX: collapsed by default

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

  /// Load business data from API (3 parallel calls)
  Future<void> _loadBusinessData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final businessIdInt = int.tryParse(widget.businessId);
    if (businessIdInt == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid business ID';
      });
      return;
    }

    try {
      final locale = ref.read(localeProvider);
      final languageCode = locale.languageCode;

      // Parallel API calls (business profile, menu items)
      final results = await Future.wait([
        ApiService.instance.getBusinessProfile(
          businessId: businessIdInt,
          languageCode: languageCode,
        ),
        ApiService.instance.getRestaurantMenu(
          businessId: businessIdInt,
          languageCode: languageCode,
        ),
      ]);

      final businessResponse = results[0];
      final menuResponse = results[1];

      if (businessResponse.succeeded && businessResponse.jsonBody != null && mounted) {
        final businessData = businessResponse.jsonBody as Map<String, dynamic>;
        final menuData = menuResponse.succeeded ? menuResponse.jsonBody as Map<String, dynamic>? : null;

        // Store business data in provider
        ref.read(businessProvider.notifier).setCurrentBusiness(
              business: businessData['business_data'],
              filterIds: List<int>.from(businessData['filter_ids'] ?? []),
              hours: businessData['business_data']?['business_hours'] ?? {},
            );

        // Store menu data
        if (menuData != null) {
          ref.read(businessProvider.notifier).setMenuItems(menuData);

          // Extract available dietary options
          final preferences =
              List<int>.from(menuData['available_dietary_preferences'] ?? []);
          final restrictions =
              List<int>.from(menuData['available_dietary_restrictions'] ?? []);
          ref.read(businessProvider.notifier).setDietaryOptions(
                preferences: preferences,
                restrictions: restrictions,
              );
        }

        // Track page view
        _trackPageView();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading business data: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load business profile';
      });
    }
  }

  /// Track page view analytics
  void _trackPageView() {
    final business = ref.read(businessProvider).currentBusiness;
    if (business == null) return;

    final businessId = business['business_id'] as int?;
    final businessName = business['business_name'] as String?;
    final analyticsState = ref.read(analyticsProvider);

    if (businessId != null) {
      // Fire-and-forget analytics
      ApiService.instance.postAnalytics(
        eventType: 'page_viewed',
        deviceId: analyticsState.deviceId,
        sessionId: analyticsState.sessionId ?? '',
        userId: '', // Anonymous user
        timestamp: DateTime.now().toIso8601String(),
        eventData: {
          'page_name': 'businessProfile',
          'business_id': businessId,
          'business_name': businessName ?? '',
        },
      );
    }
  }

  @override
  void dispose() {
    // Track session duration
    if (_pageStartTime != null) {
      final duration = DateTime.now().difference(_pageStartTime!);
      final analyticsState = ref.read(analyticsProvider);

      ApiService.instance.postAnalytics(
        eventType: 'business_profile_session_end',
        deviceId: analyticsState.deviceId,
        sessionId: analyticsState.sessionId ?? '',
        userId: '', // Anonymous user
        timestamp: DateTime.now().toIso8601String(),
        eventData: {
          'session_duration_seconds': duration.inSeconds,
        },
      );
    }
    super.dispose();
  }

  // ============================================================================
  // UI BUILDERS
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: _buildAppBar(context),
      body: _isLoading && ref.watch(businessProvider).currentBusiness == null
          ? const RestaurantShimmerWidget()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  /// AppBar with back button, share icon, and info icon
  /// JSX reference: lines 137-155
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bgPage,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        iconSize: 22,
        padding: const EdgeInsets.all(4),
        onPressed: () => context.pop(),
      ),
      actions: [
        // Share button
        IconButton(
          icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
          iconSize: 20,
          padding: const EdgeInsets.all(4),
          onPressed: _handleShareTap,
        ),
        SizedBox(width: AppSpacing.mlg),
        // Info button
        IconButton(
          icon:
              const Icon(Icons.info_outline, color: AppColors.textPrimary),
          iconSize: 20,
          padding: const EdgeInsets.all(4),
          onPressed: _handleInfoTap,
        ),
        SizedBox(width: AppSpacing.mlg),
      ],
    );
  }

  /// Main content - single scroll with all sections
  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(
            top: AppSpacing.lg,
            left: AppSpacing.xxl,
            right: AppSpacing.xxl,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // 1. Hero Section (logo, name, cuisine, status, address)
              const HeroSectionWidget(),
              SizedBox(height: AppSpacing.mlg),

              // 2. Quick Actions Pills (Call, Website, Booking, Map)
              const QuickActionsPillsWidget(),
              SizedBox(height: AppSpacing.lg),

              // 3. Match Card (if search filters are active)
              const MatchCardWidget(),
              SizedBox(height: AppSpacing.lg),

              // 4. Tags Row (conditional on tags available)
              const TagsRowWidget(),
              SizedBox(height: AppSpacing.lg),

              // 5. Opening Hours & Contact (Phase 3)
              const OpeningHoursContactWidget(),
              SizedBox(height: AppSpacing.lg),

              // TODO: Remaining sections (Phase 4-7)
              // - Gallery
              // - Menu with inline filter panel
              // - Facilities & payments
              // - About section
              // - Report link

              SizedBox(height: AppSpacing.huge),
            ]),
          ),
        ),
      ],
    );
  }

  /// Error state display
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.textMuted,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              _errorMessage ?? td(ref, 'error_loading_business'),
              style: AppTypography.bodyRegular,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _loadBusinessData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
              ),
              child: Text(td(ref, 'retry')),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // EVENT HANDLERS
  // ============================================================================

  void _handleShareTap() {
    final business = ref.read(businessProvider).currentBusiness;
    if (business == null) return;

    final businessName = business['business_name'] as String? ?? '';
    final businessId = business['business_id'] as int?;
    final analyticsState = ref.read(analyticsProvider);

    // Share business profile
    SharePlus.instance.share(ShareParams(
      text: 'Check out $businessName on JourneyMate!',
    ));

    // Track share event
    ApiService.instance.postAnalytics(
      eventType: 'business_profile_shared',
      deviceId: analyticsState.deviceId,
      sessionId: analyticsState.sessionId ?? '',
      userId: '', // Anonymous user
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'business_id': businessId ?? 0,
        'business_name': businessName,
      },
    );
  }

  void _handleInfoTap() {
    final businessId = widget.businessId;
    final analyticsState = ref.read(analyticsProvider);

    // Navigate to information page
    context.push('/business/$businessId/information');

    // Track info button tap
    ApiService.instance.postAnalytics(
      eventType: 'business_info_button_tapped',
      deviceId: analyticsState.deviceId,
      sessionId: analyticsState.sessionId ?? '',
      userId: '', // Anonymous user
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'business_id': businessId,
      },
    );
  }
}
