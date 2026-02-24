import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/search_providers.dart';
import '../../providers/settings_providers.dart';
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
      // Load localization preferences (currency)
      await ref.read(localizationProvider.notifier).loadFromPreferences();

      // Load current language code from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('user_language_code') ?? 'en';

      // Check location permission (fire-and-forget, don't block UI)
      ref.read(locationProvider.notifier).checkPermission();

      // Update local state
      if (mounted) {
        setState(() {
          _currentLanguageCode = languageCode;
        });
      }
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

      // Get user location (optional, with timeout)
      String? userLocation;
      try {
        final locationState = ref.read(locationProvider);
        if (locationState.hasPermission) {
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
        filtersUsedForSearch: [],
        sortBy: 'match',
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
        ref.read(searchStateProvider.notifier).updateSearchResults(
          response.jsonBody,
          resultCount,
        );
        debugPrint('🔧 Setup: Fetch succeeded for $languageCode ($resultCount results)');
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
    if (!context.mounted) return;

    // Check if cached results are fresh
    final searchNotifier = ref.read(searchStateProvider.notifier);
    final hasFreshCache = searchNotifier.isCacheFresh();

    debugPrint('🔧 Setup: Complete tapped (cache fresh: $hasFreshCache)');

    // Navigate immediately (analytics tracked in dispose, don't block navigation)
    context.go('/search');

    // If cache is stale or missing, fetch in background
    // (This is rare since language selection already triggers fetch)
    if (!hasFreshCache) {
      debugPrint('🔧 Setup: Cache stale, fetching in background...');
      _fetchSearchResultsForLanguage(_currentLanguageCode);
    }
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
          td(ref, 'opycnrvy'), // "App setup"
          style: AppTypography.categoryHeading,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Heading
              Text(
                td(ref, '0aq8qo7g'), // "Localization"
                style: AppTypography.label,
              ),
              SizedBox(height: AppSpacing.sm),

              // Section Description
              Text(
                td(ref, 'lup5v7ii'), // "Select your preferred language..."
                style: AppTypography.bodyRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.xxxl),

              // Language Section
              Text(
                td(ref, 's3movlvc'), // "Language"
                style: AppTypography.label,
              ),
              SizedBox(height: AppSpacing.sm),
              LanguageSelectorButton(
                currentLanguageCode: _currentLanguageCode,
                onLanguageSelected: _handleLanguageSelected,
                width: double.infinity,
              ),
              SizedBox(height: AppSpacing.xxxl),

              // Currency Section
              Text(
                td(ref, 'elv468gp'), // "Currency"
                style: AppTypography.label,
              ),
              SizedBox(height: AppSpacing.sm),
              const CurrencySelectorButton(
                width: double.infinity,
                height: 50.0,
              ),
              SizedBox(height: AppSpacing.sm),

              // Exchange Rate Note
              Text(
                td(ref,
                    '6kxja9sp'), // "Exchange rates are updated once per 24 hours"
                style: AppTypography.helper.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              SizedBox(height: AppSpacing.xxxl),

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
                    td(ref, '9nldb2d7'), // "Complete setup"
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
