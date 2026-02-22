import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../providers/business_providers.dart';
import '../providers/settings_providers.dart';
import '../services/api_service.dart';
import '../services/analytics_service.dart';
import '../services/translation_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../models/lat_lng.dart';
import '../widgets/shared/profile_top_business_block_widget.dart';
import '../widgets/shared/restaurant_shimmer_widget.dart';
import 'package:share_plus/share_plus.dart';

/// Business Profile Page - Detailed restaurant view with 3 tabs
/// Phase 7.3 implementation
///
/// Features:
/// - 3 parallel API calls on load (business profile, menu items, filter descriptions)
/// - 3-tab interface (Menu, Gallery, About)
/// - Menu session analytics tracking
/// - Comprehensive page view analytics
///
/// TODO: Integrate remaining shared widgets once their exact interfaces are confirmed
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

class _BusinessProfilePageState extends ConsumerState<BusinessProfilePage>
    with SingleTickerProviderStateMixin {
  // ============================================================================
  // LOCAL STATE
  // ============================================================================

  DateTime? _pageStartTime;
  bool _isLoading = false;
  String? _errorMessage;
  late TabController _tabController;

  // Filter descriptions for "Why this match?" sheet
  List<dynamic>? _filterDescriptions;

  // ============================================================================
  // LIFECYCLE METHODS
  // ============================================================================

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadBusinessData();
    });
  }

  @override
  void dispose() {
    _trackPageView();
    _endMenuSession();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  // ============================================================================
  // DATA LOADING (3 PARALLEL API CALLS)
  // ============================================================================

  Future<void> _loadBusinessData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final languageCode = Localizations.localeOf(context).languageCode;
    final businessIdInt = int.parse(widget.businessId);

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
        final businessData = profileResponse.jsonBody['business_profile'];
        final filters = (businessData['filters'] as List?)
                ?.map((f) => f['filter_id'] as int)
                .toList() ??
            [];
        final hours = profileResponse.jsonBody['business_hours'];

        ref.read(businessProvider.notifier).setCurrentBusiness(
              business: businessData,
              filterIds: filters,
              hours: hours,
            );
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

      // Store filter descriptions locally (for "Why this match?" sheet)
      if (filterDescResponse.succeeded) {
        setState(() {
          _filterDescriptions =
              filterDescResponse.jsonBody['filterDescriptions'];
        });
      }

      // Start menu session (fire-and-forget analytics)
      _startMenuSession(businessIdInt);

      setState(() {
        _isLoading = false;
      });
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

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;

    final tabNames = ['menu', 'gallery', 'about'];
    final tabName = tabNames[_tabController.index];

    final analytics = AnalyticsService.instance;
    ApiService.instance
        .postAnalytics(
      eventType: 'tab_switched',
      deviceId: analytics.deviceId ?? '',
      sessionId: analytics.currentSessionId ?? '',
      userId: analytics.userId ?? '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'pageName': 'businessProfile',
        'tabName': tabName,
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
    final locationState = ref.watch(locationProvider);

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
                  ts(context, 'error_retry_button'),
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
                ts(context, 'business_not_found'),
                style: AppTypography.bodyRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Success state - Main content
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
          if (_filterDescriptions != null && _filterDescriptions!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.info_outline),
              color: AppColors.textPrimary,
              onPressed: () {
                // TODO: Show filter description sheet
                debugPrint('Show filter descriptions');
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Hero section - always visible above tabs
          _buildHeroSection(business, locationState),

          // Tab bar
          _buildTabBar(),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMenuTab(),
                _buildGalleryTab(),
                _buildAboutTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // HERO SECTION
  // ============================================================================

  Widget _buildHeroSection(Map<String, dynamic> business, dynamic locationState) {
    // Get user location if permission granted
    LatLng? userLocation;
    if (locationState.hasPermission == true) {
      // Will be fetched inside ProfileTopBusinessBlockWidget if needed
      userLocation = null; // TODO: Get from geolocator when needed
    }

    return ProfileTopBusinessBlockWidget(
      openingHours: ref.read(businessProvider).openingHours ?? {},
      userLocation: userLocation,
      priceRangeMin: business['price_range_min'] ?? 0,
      priceRangeMax: business['price_range_max'] ?? 0,
      profilePicture: business['profile_picture']?['url'],
      businessName: business['business_name'],
      latitude: business['address']?['latitude'],
      longitude: business['address']?['longitude'],
      street: business['address']?['street'],
      neighbourhoodName: business['address']?['neighbourhood_name'],
      businessID: int.tryParse(widget.businessId),
      businessType: business['business_type'],
    );
  }

  // ============================================================================
  // TAB BAR
  // ============================================================================

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.accent,
        labelColor: AppColors.accent,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTypography.bodyMedium,
        tabs: [
          Tab(text: ts(context, 'tab_menu')),
          Tab(text: ts(context, 'tab_gallery')),
          Tab(text: ts(context, 'tab_about')),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB 0: MENU
  // ============================================================================

  Widget _buildMenuTab() {
    final menuItems = ref.watch(businessProvider).menuItems;

    if (menuItems == null) {
      return Center(
        child: Text(
          ts(context, 'menu_loading'),
          style: AppTypography.bodyRegular.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    // TODO: Integrate UnifiedFiltersWidget, MenuCategoriesRows, MenuDishesListView
    // These widgets have complex interfaces that need careful parameter matching
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Menu tab - Widget integration pending',
              style: AppTypography.bodyRegular.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              '${(menuItems as List? ?? []).length} menu items loaded',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // TAB 1: GALLERY
  // ============================================================================

  Widget _buildGalleryTab() {
    final business = ref.watch(businessProvider).currentBusiness;
    final gallery = business?['gallery'] ?? [];

    // TODO: Integrate GalleryTabWidget
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library,
              size: 64,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Gallery tab - Widget integration pending',
              style: AppTypography.bodyRegular.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              '${(gallery as List? ?? []).length} photos available',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // TAB 2: ABOUT
  // ============================================================================

  Widget _buildAboutTab() {
    final business = ref.watch(businessProvider).currentBusiness;

    if (business == null) {
      return Center(
        child: Text(
          ts(context, 'business_not_found'),
          style: AppTypography.bodyRegular.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    // TODO: Integrate ExpandableTextWidget, PaymentOptionsWidget, ContactDetailsWidget
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description section
          if (business['description'] != null &&
              business['description'].toString().isNotEmpty) ...[
            Text(
              ts(context, 'about_description_label'),
              style: AppTypography.sectionHeading.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              business['description'],
              style: AppTypography.bodyRegular.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.xxxl),
          ],

          // Payment options section (placeholder)
          Text(
            ts(context, 'about_payment_options_label'),
            style: AppTypography.sectionHeading.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Payment options widget integration pending',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          SizedBox(height: AppSpacing.xxxl),

          // Contact details section (placeholder)
          Text(
            'Contact Details',
            style: AppTypography.sectionHeading.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Contact details widget integration pending',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          SizedBox(height: AppSpacing.xxxl),

          // Report incorrect info button
          Center(
            child: TextButton.icon(
              onPressed: () {
                // TODO: Show erroneous info form
                debugPrint('Show erroneous info form');
              },
              icon: Icon(
                Icons.flag_outlined,
                color: AppColors.textSecondary,
                size: 16,
              ),
              label: Text(
                ts(context, 'about_report_incorrect_info'),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
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
}
