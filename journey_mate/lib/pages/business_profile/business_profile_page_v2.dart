import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/app_providers.dart';
import '../../providers/business_providers.dart';
import '../../providers/filter_providers.dart';
import '../../providers/locale_provider.dart';
import '../../providers/search_providers.dart';
import '../../services/analytics_service.dart';
import '../../services/api_service.dart';
import '../../services/translation_service.dart';
import '../../services/business_cache.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import '../../widgets/shared/business_feature_buttons.dart';
import '../../widgets/shared/erroneous_info_form_widget.dart';
import '../../widgets/shared/payment_options_widget.dart';
import '../../widgets/shared/restaurant_shimmer_widget.dart';
import '../../widgets/shared/description_sheet.dart';
import '../../widgets/business_profile/hero_section_widget.dart';
import '../../widgets/business_profile/inline_gallery_widget.dart';
import '../../widgets/business_profile/inline_menu_widget.dart';
import '../../widgets/business_profile/match_card_widget.dart';
import '../../widgets/business_profile/opening_hours_contact_widget.dart';
import '../../widgets/business_profile/quick_actions_pills_widget.dart';

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
  bool _aboutExpanded = false; // JSX: collapsed by default (aboutOpen = false)
  bool _menuLoadFailed = false;
  bool _menuSessionStarted = false;

  // Cached for safe use in dispose() — ref is invalid after unmount
  String _cachedDeviceId = '';
  String _cachedSessionId = '';

  // ============================================================================
  // LIFECYCLE METHODS
  // ============================================================================

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();

    // Schedule both cache preview and API data load after frame renders
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Cache analytics state for safe use in dispose() (ref is invalid after unmount)
      final analyticsState = ref.read(analyticsProvider);
      _cachedDeviceId = analyticsState.deviceId;
      _cachedSessionId = analyticsState.sessionId ?? '';

      _trackMenuSessionStart();
      _loadCachedPreview();
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
      _menuLoadFailed = false;
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
        final raw = businessResponse.jsonBody as Map<String, dynamic>;
        final menuData = menuResponse.succeeded ? menuResponse.jsonBody as Map<String, dynamic>? : null;

        // API top-level keys: businessInfo, filters, businessHours, openWindows, gallery, menuCategories
        final businessInfo = raw['businessInfo'] as Map<String, dynamic>?;
        if (businessInfo == null) {
          debugPrint('❌ Business not found: id=$businessIdInt');
          setState(() {
            _errorMessage = 'Business not found';
            _isLoading = false;
          });
          return;
        }

        // Filters, gallery, and menuCategories are top-level (not nested inside businessInfo)
        final topLevelFilters = raw['filters'] as List? ?? [];
        final topLevelGallery = raw['gallery'] as Map<String, dynamic>? ?? {};
        final topLevelMenuCategories = raw['menuCategories'] as List? ?? [];
        final businessHours = raw['businessHours'] as Map<String, dynamic>? ?? {};

        final filterIds = topLevelFilters
            .whereType<Map<String, dynamic>>()
            .map((f) => f['filter_id'] as int?)
            .whereType<int>()
            .toList();

        // Build business map: spread businessInfo + merge top-level arrays
        final business = <String, dynamic>{
          ...businessInfo,
          'filters': topLevelFilters,
          'gallery': topLevelGallery,
          'menuCategories': topLevelMenuCategories,
        };

        ref.read(businessProvider.notifier).setCurrentBusiness(
              business: business,
              filterIds: filterIds,
              hours: businessHours,
            );

        // Store menu data
        if (menuData != null) {
          // Pass full menuData Map (includes menu_items AND categories)
          // MenuDishesListView expects Map structure, not just items array
          ref.read(businessProvider.notifier).setMenuItems(menuData);

          // Debug: Verify structure is correct
          debugPrint('✅ Menu data stored: ${menuData.keys}');
          debugPrint('✅ Categories count: ${(menuData['categories'] as List?)?.length}');
          debugPrint('✅ Items count: ${(menuData['menu_items'] as List?)?.length}');

          final preferences = List<int>.from(menuData['availablePreferences'] ?? []);
          final restrictions = List<int>.from(menuData['availableRestrictions'] ?? []);
          ref.read(businessProvider.notifier).setDietaryOptions(
                preferences: preferences,
                restrictions: restrictions,
              );
        } else {
          setState(() => _menuLoadFailed = true);
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
      ApiService.instance.postAnalytics(
        eventType: 'business_profile_viewed',
        deviceId: analyticsState.deviceId,
        sessionId: analyticsState.sessionId ?? '',
        userId: '',
        timestamp: DateTime.now().toIso8601String(),
        eventData: {
          'business_id': businessId,
          'business_name': businessName ?? '',
        },
      );
    }
  }

  /// Track menu session start (fire-and-forget).
  /// Called immediately on page open so session duration is accurate.
  void _trackMenuSessionStart() {
    final businessIdInt = int.tryParse(widget.businessId);
    if (businessIdInt == null) return;
    _menuSessionStarted = true;
    final analyticsState = ref.read(analyticsProvider);
    ApiService.instance.postAnalytics(
      eventType: 'menu_session_started',
      deviceId: analyticsState.deviceId,
      sessionId: analyticsState.sessionId ?? '',
      userId: '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {'business_id': businessIdInt},
    );
  }

  @override
  void dispose() {
    if (_pageStartTime != null && _menuSessionStarted) {
      final duration = DateTime.now().difference(_pageStartTime!);
      final businessIdInt = int.tryParse(widget.businessId);

      // Use cached values — ref is unsafe during dispose()
      ApiService.instance.postAnalytics(
        eventType: 'menu_session_ended',
        deviceId: _cachedDeviceId,
        sessionId: _cachedSessionId,
        userId: '',
        timestamp: DateTime.now().toIso8601String(),
        eventData: {
          'session_duration_seconds': duration.inSeconds,
          'business_id': businessIdInt,
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
          icon: const Icon(Icons.ios_share, color: AppColors.textPrimary),
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
        // Sections 1–5: rely on parent horizontal padding (no own h-padding)
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
              const SizedBox(height: AppSpacing.xxl),

              // 2. Quick Actions Pills (Call, Website, Booking, Map)
              const QuickActionsPillsWidget(),
              const SizedBox(height: AppSpacing.xxl),

              // 3. Match Card (if search filters are active)
              const MatchCardWidget(),
              const SizedBox(height: AppSpacing.xxl),

              // 4. Opening Hours & Contact
              const OpeningHoursContactWidget(),
            ]),
          ),
        ),

        _sectionDivider,

        // 6. Gallery — self-contained widget with own 24 px horizontal padding.
        // Must be a separate SliverToBoxAdapter (not inside the SliverPadding
        // above) to avoid 48 px double-padding. Matches v1 pattern (page.dart:536).
        const SliverToBoxAdapter(child: InlineGalleryWidget()),

        _sectionDivider,

        // 7. Menu (category chips + inline filter panel + items list)
        SliverToBoxAdapter(
          child: _menuLoadFailed
              ? _buildMenuErrorWidget()
              : InlineMenuWidget(
                  businessId: int.parse(widget.businessId),
                ),
        ),

        _sectionDivider,

        // 8. Facilities & Services
        SliverToBoxAdapter(child: _buildFacilitiesSection()),

        _sectionDivider,

        // 9. Payment Options
        SliverToBoxAdapter(child: _buildPaymentsSection()),

        // 10. About (collapsible) — dividers conditional on description existing
        if (_hasAboutContent) ...[
          _sectionDivider,
          SliverToBoxAdapter(child: _buildAboutSection()),
          _sectionDivider,
        ] else
          _sectionDivider,

        // 11. Report link
        SliverToBoxAdapter(child: _buildReportLink()),

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.huge)),
      ],
    );
  }

  /// Pure white spacing between major content sections (24px).
  SliverToBoxAdapter get _sectionDivider => const SliverToBoxAdapter(
        child: SizedBox(height: AppSpacing.xxl),
      );

  /// Whether the About section has content to display.
  bool get _hasAboutContent {
    final business = ref.watch(businessProvider).currentBusiness;
    final description = business?['description'] as String?;
    return description != null && description.isNotEmpty;
  }

  /// Inline error widget shown in place of the menu section when the menu
  /// API call fails. Keeps the rest of the business profile visible.
  Widget _buildMenuErrorWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            td(ref, 'tab_menu'),
            style: AppTypography.sectionHeading,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            td(ref, 'menu_load_error'),
            style: AppTypography.bodyRegular,
          ),
          SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: _loadBusinessData,
            child: Text(
              td(ref, 'retry'),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Error state display
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
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

  /// Build facilities & services section
  /// JSX reference: business_profile.jsx lines 501-537
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
            onInitialCount: (int count) async {},
            onFilterTap: (int filterId, String filterName,
                String? filterDescription) async {
              if (context.mounted) {
                _trackFacilityInfoOpened(filterName, filterDescription);
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => DraggableScrollableSheet(
                    initialChildSize: 0.4,
                    maxChildSize: 0.9,
                    minChildSize: 0.25,
                    builder: (context, scrollController) => DescriptionSheet(
                      title: filterName,
                      description: filterDescription,
                      scrollController: scrollController,
                      fallbackDescription:
                          td(ref, 'no_description_available'),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  /// Build payment options section
  /// JSX reference: business_profile.jsx lines 542-550
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
            filters:
                ref.watch(filterProvider).value?.filtersForLanguage ?? [],
            filtersUsedForSearch:
                ref.watch(searchStateProvider).filtersUsedForSearch,
            filtersOfThisBusiness:
                ref.watch(businessProvider).businessFilterIds,
            onInitialCount: (int count) async {},
          ),
        ],
      ),
    );
  }

  /// Build about section (collapsible description)
  /// JSX reference: business_profile.jsx lines 554-563 (aboutOpen = false by default)
  Widget _buildAboutSection() {
    final business = ref.watch(businessProvider).currentBusiness;
    final description = business?['description'] as String?;

    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: GestureDetector(
        onTap: _toggleAboutExpanded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    td(ref, 'about_description_label'),
                    style: AppTypography.sectionHeading,
                  ),
                ),
                AnimatedRotation(
                  turns: _aboutExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
              ],
            ),
            if (_aboutExpanded) ...[
              SizedBox(height: AppSpacing.sm),
              Text(
                description,
                style: AppTypography.bodyRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Toggle About expanded/collapsed and track analytics
  void _toggleAboutExpanded() {
    setState(() {
      _aboutExpanded = !_aboutExpanded;
    });
    final analytics = AnalyticsService.instance;
    final businessIdInt = int.tryParse(widget.businessId);
    ApiService.instance
        .postAnalytics(
      eventType: 'expandable_text_toggled',
      deviceId: analytics.deviceId ?? '',
      sessionId: analytics.currentSessionId ?? '',
      userId: analytics.userId ?? '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'action': _aboutExpanded ? 'expanded' : 'collapsed',
        'text_id': 'about',
        'business_id': businessIdInt,
      },
    )
        .catchError((e) {
      debugPrint('Analytics error: $e');
      return ApiCallResponse.failure('Analytics failed');
    });
  }

  /// Build report link button at bottom of page
  /// JSX reference: business_profile.jsx lines 567-572
  Widget _buildReportLink() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Center(
        child: TextButton.icon(
          onPressed: () async {
            final analytics = AnalyticsService.instance;
            ApiService.instance
                .postAnalytics(
              eventType: 'report_link_tapped',
              deviceId: analytics.deviceId ?? '',
              sessionId: analytics.currentSessionId ?? '',
              userId: analytics.userId ?? '',
              timestamp: DateTime.now().toIso8601String(),
              eventData: {'pageName': 'businessProfile'},
            )
                .catchError((e) {
              debugPrint('Analytics error: $e');
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

  // ============================================================================
  // EVENT HANDLERS
  // ============================================================================

  /// Track facility info sheet opened (fire-and-forget).
  /// Extracted from FacilitiesInfoSheet.initState for call-site control.
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
        'pageName': 'businessProfile',
        'facilityName': filterName,
        'hasDescription':
            filterDescription != null && filterDescription.isNotEmpty,
      },
    )
        .catchError((e) {
      debugPrint('Analytics error: $e');
      return ApiCallResponse.failure('Analytics failed');
    });
  }

  void _handleShareTap() {
    final business = ref.read(businessProvider).currentBusiness;
    if (business == null) return;

    final businessName = business['business_name'] as String? ?? '';
    final businessId = business['business_id'] as int?;
    final analyticsState = ref.read(analyticsProvider);

    // Share business profile
    final shareText = td(ref, 'share_business_text')
        .replaceAll('{name}', businessName);
    SharePlus.instance.share(ShareParams(text: shareText));

    // Track share event
    ApiService.instance.postAnalytics(
      eventType: 'share_button_clicked',
      deviceId: analyticsState.deviceId,
      sessionId: analyticsState.sessionId ?? '',
      userId: '',
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
