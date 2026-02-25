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
import '../services/business_cache.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../models/lat_lng.dart';
import '../widgets/shared/profile_top_business_block_widget.dart';
import '../widgets/shared/restaurant_shimmer_widget.dart';
import '../widgets/shared/expandable_text_widget.dart';
import '../widgets/shared/payment_options_widget.dart';
import '../widgets/shared/contact_details_widget.dart';
import '../widgets/shared/erroneous_info_form_widget.dart';
import '../widgets/shared/gallery_tab_widget.dart';
import '../widgets/shared/image_gallery_widget.dart';
import '../widgets/shared/unified_filters_widget.dart';
import '../widgets/shared/menu_categories_rows.dart';
import '../widgets/shared/menu_dishes_list_view.dart';
import '../widgets/shared/item_bottom_sheet.dart';
import '../widgets/shared/package_bottom_sheet.dart';
import '../widgets/shared/category_description_sheet.dart';
import '../providers/filter_providers.dart';
import '../providers/search_providers.dart';
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

  // Menu tab scroll sync state
  String? _selectedMenuId;
  String? _selectedCategoryId;
  // ignore: unused_field
  int _visibleItemCount = 0;

  // ============================================================================
  // LIFECYCLE METHODS
  // ============================================================================

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);

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
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
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

      // Store filter descriptions locally (for "Why this match?" sheet)
      if (filterDescResponse.succeeded) {
        setState(() {
          _filterDescriptions =
              filterDescResponse.jsonBody['filterDescriptions'];
        });
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
                // Show info dialog explaining how to view filter descriptions
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      td(ref, 'filterinfotitle'),
                      style: AppTypography.sectionHeading,
                    ),
                    content: Text(
                      td(ref, 'filterinfomessage'),
                      style: AppTypography.bodyRegular,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          td(ref, 'ok'),
                          style: AppTypography.bodyRegular.copyWith(
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
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
          Tab(text: td(ref, 'tab_menu')),
          Tab(text: td(ref, 'tab_gallery')),
          Tab(text: td(ref, 'tab_about')),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB 0: MENU
  // ============================================================================

  Widget _buildMenuTab() {
    final menuItems = ref.watch(businessProvider).menuItems;
    final business = ref.watch(businessProvider).currentBusiness;

    if (menuItems == null) {
      return Center(
        child: Text(
          td(ref, 'menu_loading'),
          style: AppTypography.bodyRegular.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Column(
      children: [
        // 1. Unified Filters Widget (Dietary filters)
        UnifiedFiltersWidget(
          businessId: int.parse(widget.businessId),
          height: 350.0, // Standard height
          onFiltersChanged: () async {
            // Filters updated - menu will auto-rebuild via provider watch
            debugPrint('Dietary filters changed');
          },
          onVisibleItemCountChanged: (int count) async {
            setState(() => _visibleItemCount = count);

            // Update menu session analytics
            ref
                .read(analyticsProvider.notifier)
                .updateMenuSessionFilterMetrics(count, _hasActiveFilters());
          },
        ),

        SizedBox(height: AppSpacing.md),

        // 2. Menu Categories Row (Horizontal category chips)
        SizedBox(
          height: 40.0,
          child: MenuCategoriesRows(
            businessID: int.parse(widget.businessId),
            apiResult: menuItems,
            onCategoryChanged: (int categoryId, int menuId) async {
              // User tapped category chip → update state → MenuDishesListView scrolls
              setState(() {
                _selectedCategoryId = categoryId.toString();
                _selectedMenuId = menuId.toString();
              });
            },
            onNumberOfRows: (int numberOfRows) async {
              debugPrint('Menu categories rows: $numberOfRows');
            },
            visibleSelection: _selectedCategoryId != null &&
                    _selectedMenuId != null
                ? {
                    'categoryId': int.tryParse(_selectedCategoryId!) ?? 0,
                    'menuId': int.tryParse(_selectedMenuId!) ?? 0,
                  }
                : null,
          ),
        ),

        SizedBox(height: AppSpacing.md),

        // 3. Menu Dishes List View (Scrollable menu items)
        Expanded(
          child: MenuDishesListView(
            originalCurrencyCode: business?['price_range_currency_code'] ?? 'DKK',
            isDynamicHeight: false,
            onItemTap: (itemData, isBeverage, dietaryIds, allergyIds,
                formattedPrice, hasVariations, variationPrice) async {
              if (!mounted) return;

              final localization = ref.read(localizationProvider);
              final translationsCache = ref.read(translationsCacheProvider);
              final currentLanguage = Localizations.localeOf(context).languageCode;

              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => ItemBottomSheet(
                  itemData: itemData,
                  chosenCurrency: localization.currencyCode,
                  originalCurrencyCode:
                      business?['price_range_currency_code'] ?? 'DKK',
                  exchangeRate: localization.exchangeRate,
                  currentLanguage: currentLanguage,
                  businessName: business?['business_name'] ?? '',
                  translationsCache: translationsCache,
                  hasVariations: hasVariations,
                ),
              );

              // Track item click
              ref.read(analyticsProvider.notifier).incrementItemClick();
            },
            onPackageTap: (packageData) async {
              if (!mounted) return;

              final localization = ref.read(localizationProvider);

              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => PackageBottomSheet(
                  normalizedMenuData: menuItems,
                  packageId: packageData['package_id'] ?? 0,
                  chosenCurrency: localization.currencyCode,
                  originalCurrencyCode:
                      business?['price_range_currency_code'] ?? 'DKK',
                  exchangeRate: localization.exchangeRate,
                  businessName: business?['business_name'] ?? '',
                ),
              );

              // Track package click
              ref.read(analyticsProvider.notifier).incrementPackageClick();
            },
            onVisibleCategoryChanged: (selectionData) async {
              // User scrolled → category became visible
              final categoryId = selectionData['categoryId']?.toString();
              final menuId = selectionData['menuId']?.toString();

              // ✅ CRITICAL: Only update if different (prevents infinite loop)
              if (categoryId != _selectedCategoryId ||
                  menuId != _selectedMenuId) {
                setState(() {
                  _selectedCategoryId = categoryId;
                  _selectedMenuId = menuId;
                });
              }

              // Track scroll depth
              if (categoryId != null) {
                ref
                    .read(analyticsProvider.notifier)
                    .recordCategoryViewed(int.tryParse(categoryId) ?? 0);
              }
            },
            onCategoryDescriptionTap: (categoryData) async {
              if (!mounted) return;

              await showModalBottomSheet(
                context: context,
                builder: (context) => CategoryDescriptionSheet(
                  categoryName: categoryData['name'] ?? '',
                  categoryDescription: categoryData['description'] ?? '',
                  scrollController: ScrollController(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // TAB 1: GALLERY
  // ============================================================================

  Widget _buildGalleryTab() {
    final business = ref.watch(businessProvider).currentBusiness;

    return GalleryTabWidget(
      galleryData: _buildGalleryData(business?['gallery']),
      onImageTap: (imageUrls, index, categoryKey) async {
        if (!mounted) return;
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => ImageGalleryWidget(
            currentIndex: index,
            imageUrls: imageUrls,
            categoryName: td(ref, categoryKey), // Translation for category
          ),
        );
      },
      limitToEightImages: false, // Show all images
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
          td(ref, 'business_not_found'),
          style: AppTypography.bodyRegular.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Business Description (ExpandableTextWidget)
          if (business['description'] != null &&
              business['description'].toString().isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  td(ref, 'about_description_label'), // "About"
                  style: AppTypography.sectionHeading,
                ),
                SizedBox(height: AppSpacing.sm),
                ExpandableTextWidget(
                  text: business['description'],
                  businessId: int.tryParse(widget.businessId),
                ),
                SizedBox(height: AppSpacing.xl),
              ],
            ),

          // 2. Payment Options (PaymentOptionsWidget)
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

          // 3. Contact Details (ContactDetailsWidget)
          ContactDetailsWidget(),
          SizedBox(height: AppSpacing.xl),

          // 4. Report Incorrect Info Button
          Center(
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
                td(ref,
                    'about_report_incorrect_info'), // "Report incorrect information"
                style: AppTypography.label.copyWith(
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

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Build gallery data by grouping images by category
  Map<String, dynamic> _buildGalleryData(dynamic gallery) {
    if (gallery == null) {
      return {'food': [], 'menu': [], 'interior': [], 'outdoor': []};
    }

    // Group images by category
    final Map<String, List<String>> grouped = {
      'food': [],
      'menu': [],
      'interior': [],
      'outdoor': [],
    };

    for (final image in gallery as List) {
      final categoryId = image['category_id'] as int?;
      final imageUrl = image['image_url'] as String?;

      if (imageUrl != null) {
        switch (categoryId) {
          case 3:
            grouped['food']!.add(imageUrl);
            break;
          case 4:
            grouped['menu']!.add(imageUrl);
            break;
          case 1:
            grouped['interior']!.add(imageUrl);
            break;
          case 2:
            grouped['outdoor']!.add(imageUrl);
            break;
        }
      }
    }

    return grouped;
  }

  /// Check if any dietary filters are active
  bool _hasActiveFilters() {
    final state = ref.read(businessProvider);
    return state.selectedDietaryRestrictionIds.isNotEmpty ||
        state.selectedDietaryPreferenceId != null ||
        state.excludedAllergyIds.isNotEmpty;
  }
}
