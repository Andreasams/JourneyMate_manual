import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/search_providers.dart';
import '../../providers/settings_providers.dart';
import '../../providers/locale_provider.dart';
import '../../services/api_service.dart';
import '../../services/translation_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_constants.dart';
import '../../widgets/shared/language_selector_button.dart';
import '../../widgets/shared/currency_selector_button.dart';

/// App Settings Initiate Flow Page
///
/// Second step in new user onboarding (English path). Required setup page
/// where users select language and currency before entering the main app.
///
/// User Flow:
/// Welcome Page (new user, no language set)
///   ↓ User taps "Continue" (English button)
/// App Settings Initiate Flow (THIS PAGE)
///   ↓ User selects language & currency → taps "Complete setup"
/// Search Results Page (main app)
///
/// Phase 7.2 implementation
class AppSettingsInitiateFlowPage extends ConsumerStatefulWidget {
  const AppSettingsInitiateFlowPage({super.key});

  @override
  ConsumerState<AppSettingsInitiateFlowPage> createState() =>
      _AppSettingsInitiateFlowPageState();
}

class _AppSettingsInitiateFlowPageState
    extends ConsumerState<AppSettingsInitiateFlowPage> {
  // ============================================================
  // LOCAL STATE
  // ============================================================

  DateTime? _pageStartTime;
  String _currentLanguageCode = 'en'; // Default to English
  String? _latestLanguageCode; // Track latest language for API override handling

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void initState() {
    super.initState();

    // Initialize after frame is rendered
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  @override
  void dispose() {
    _trackPageView();
    super.dispose();
  }

  // ============================================================
  // INITIALIZATION
  // ============================================================

  Future<void> _initialize() async {
    // Record page start time for analytics
    _pageStartTime = DateTime.now();

    try {
      // Load current language code from SharedPreferences (cached, instant)
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('user_language_code') ?? 'en';

      // Update local state
      if (mounted) {
        setState(() {
          _currentLanguageCode = languageCode;
        });
      }

      // Pre-fetch search results with English by default (fire-and-forget)
      // For English users: results ready when they tap "Complete setup" (instant navigation)
      // For non-English users: results overwritten when they select language (one "wasted" call)
      _fetchSearchResultsForLanguage('en');
    } catch (e) {
      debugPrint('⚠️ App Settings page initialization error: $e');
      // Continue with defaults even if initialization fails
    }
  }

  // ============================================================
  // LANGUAGE SELECTION
  // ============================================================

  Future<void> _handleLanguageSelected(String newLanguageCode) async {
    try {
      // Persist language to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_language_code', newLanguageCode);

      // Update local state
      if (mounted) {
        setState(() {
          _currentLanguageCode = newLanguageCode;
        });
      }

      debugPrint('✅ Language updated to: $newLanguageCode');

      // Start search API call immediately (fire-and-forget)
      // Handles rapid language changes by tracking latest selection
      _fetchSearchResultsForLanguage(newLanguageCode);
    } catch (e) {
      debugPrint('⚠️ Failed to persist language: $e');
    }
  }

  /// Fetch search results for selected language (handles rapid changes)
  Future<void> _fetchSearchResultsForLanguage(String languageCode) async {
    try {
      // Track this as the latest language being fetched
      _latestLanguageCode = languageCode;

      debugPrint('🔧 Setup: Fetching search results for $languageCode...');

      // Save notifier before async operations (safe even if widget unmounted)
      final searchNotifier = ref.read(searchStateProvider.notifier);

      // Get user location (optional, with timeout)
      String? userLocation;
      try {
        final locationState = ref.read(locationProvider);
        if (locationState.isLocationUsable) {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 5),
            ),
          );
          userLocation = 'LatLng(lat: ${position.latitude}, lng: ${position.longitude})';
        }
      } catch (e) {
        debugPrint('🔧 Setup: Location fetch failed: $e');
        // Continue without location
      }

      // Call Search API
      final response = await ApiService.instance.search(
        cityId: AppConstants.kDefaultCityId.toString(),
        userLocation: userLocation,
        searchInput: '',
        languageCode: languageCode,
        filters: [],
        sortOrder: 'desc',
        page: 1,
        pageSize: 20,
      );

      // Only store results if this is still the latest language
      // (handles rapid language changes - ignore stale responses)
      if (_latestLanguageCode != languageCode) {
        debugPrint('🔧 Setup: Ignoring stale results for $languageCode (latest: $_latestLanguageCode)');
        return;
      }

      if (response.succeeded) {
        final resultCount = response.jsonBody['resultCount'] as int? ?? 0;
        final fullMatchCount = (response.jsonBody['fullMatchCount'] as num?)?.toInt() ?? 0;
        final activeIds = (response.jsonBody['activeids'] as List?)
            ?.map((e) => (e as num).toInt())
            .toList() ?? [];
        final scoringFilterIds = (response.jsonBody['scoringFilterIds'] as List?)
            ?.map((e) => (e as num).toInt())
            .toList() ?? [];
        // Use saved notifier (safe even if widget unmounted)
        searchNotifier.updateSearchResults(
          response.jsonBody,
          resultCount,
          fullMatchCount,
          scoringFilterIds,
        );
        searchNotifier.updateActiveFilterIds(activeIds);
        debugPrint('🔧 Setup: Fetch succeeded for $languageCode ($resultCount results, $fullMatchCount full matches)');
      } else {
        debugPrint('🔧 Setup: Fetch failed for $languageCode: ${response.error}');
        // Fail silently - user will see shimmer on Search page if needed
      }
    } catch (e) {
      debugPrint('🔧 Setup: Fetch exception for $languageCode: $e');
      // Fail silently - don't block setup flow
    }
  }

  // ============================================================
  // COMPLETE SETUP
  // ============================================================

  Future<void> _handleCompleteSetup() async {
    // Persist language selection to SharedPreferences
    // This guarantees persistence even if user didn't interact with selector
    try {
      final prefs = await SharedPreferences.getInstance();

      // Persist language code
      await prefs.setString('user_language_code', _currentLanguageCode);

      // Update localeProvider for immediate app-wide locale change
      ref.read(localeProvider.notifier).setLocale(_currentLanguageCode);

      debugPrint('✅ Setup complete: language=$_currentLanguageCode persisted');
    } catch (e) {
      debugPrint('⚠️ Failed to persist language during setup: $e');
      // Continue navigation - don't block user flow on persistence error
    }

    // Navigate immediately - search results are already cached
    // (Either from page load 'en' pre-fetch, or from language selection)
    // No need to check cache staleness - it's always fresh for new users
    // Check mounted after async operations, immediately before using context
    if (!mounted) return;
    context.go('/search');
  }

  // ============================================================
  // ANALYTICS
  // ============================================================

  Future<void> _trackPageView() async {
    if (_pageStartTime == null) return;

    try {
      final duration = DateTime.now().difference(_pageStartTime!);
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString('analytics_device_id') ?? 'unknown';
      final sessionId = prefs.getString('current_session_id') ?? 'unknown';

      await ApiService.instance.postAnalytics(
        eventType: 'page_viewed',
        deviceId: deviceId,
        sessionId: sessionId,
        userId: deviceId,
        eventData: {
          'pageName': 'appSettingsInitiateFlowPage',
          'durationSeconds': duration.inSeconds.toString(),
        },
        timestamp: DateTime.now().toIso8601String(),
      );

      debugPrint(
          '✅ Tracked appSettingsInitiateFlowPage view: ${duration.inSeconds}s');
    } catch (e) {
      debugPrint('⚠️ Failed to track page view: $e');
      // Fail silently — analytics should never block user flow
    }
  }

  // ============================================================
  // BUILD UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        elevation: 0,
        automaticallyImplyLeading: false, // NO back button
        centerTitle: true,
        title: Text(
          td(ref, 'feedback_page_settings'), // "App setup"
          style: AppTypography.h3,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main page title
              Text(
                td(ref, 'settings_localization_title'), // "Localization"
                style: AppTypography.h2.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: AppSpacing.sm),

              // Main subtitle
              Text(
                td(ref, 'onboarding_language_currency_desc'), // "Select your preferred language..."
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w300,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 28), // Tighter first gap

              // Language Section Title
              Text(
                td(ref, 'settings_language_label'), // "Language"
                style: AppTypography.bodyLgMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              LanguageSelectorButton(
                currentLanguageCode: _currentLanguageCode,
                onLanguageSelected: _handleLanguageSelected,
                width: double.infinity,
              ),
              SizedBox(height: AppSpacing.xxl), // Increased section spacing

              // Currency Section Title
              Text(
                td(ref, 'onboarding_currency_label'), // "Currency"
                style: AppTypography.bodyLgMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              const CurrencySelectorButton(
                width: double.infinity,
                height: 50.0,
              ),
              SizedBox(height: AppSpacing.md),

              // Exchange Rate Note
              Text(
                td(ref,
                    'currency_exchange_rate_disclaimer'), // "Exchange rates are updated once per 24 hours"
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              SizedBox(height: 40), // Space before button

              // Complete Setup Button
              SizedBox(
                width: double.infinity,
                height: AppConstants.buttonHeight,
                child: ElevatedButton(
                  onPressed: _handleCompleteSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                  ),
                  child: Text(
                    td(ref, 'onboarding_complete_setup'), // "Complete setup"
                    style: AppTypography.button.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
