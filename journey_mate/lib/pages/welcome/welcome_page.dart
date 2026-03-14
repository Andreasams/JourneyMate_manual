import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/app_providers.dart';
import '../../providers/search_providers.dart';
import '../../providers/settings_providers.dart';
import '../../services/api_service.dart';
import '../../services/translation_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_constants.dart';
import '../../providers/filter_providers.dart';
import '../../providers/locale_provider.dart';

/// Welcome/Onboarding Page
///
/// Entry point for all users. Detects new vs returning users and adapts UI:
/// - New users: Choose English setup or Danish quick path
/// - Returning users: Quick continue to search
///
/// Phase 7.1 implementation
class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({super.key});

  @override
  ConsumerState<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<WelcomePage> {
  // ============================================================
  // LOCAL STATE
  // ============================================================

  bool _isReturningUser = false;
  DateTime? _pageStartTime;
  bool _buttonsVisible = false;
  bool _hasTrackedPageView = false; // Prevent duplicate tracking

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
      // Check if user has language set (determines returning vs new user)
      // SP is already cached from main.dart — this is instant
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('user_language_code');
      final isReturningUser = languageCode != null && languageCode.isNotEmpty;

      // Update UI state immediately (buttons visible while permission dialog shows)
      if (mounted) {
        setState(() {
          _isReturningUser = isReturningUser;
          _buttonsVisible = true;
        });
      }

      // Request location permission if never asked (shows iOS dialog on first launch)
      // Awaited so location state is resolved before pre-fetch — ensures "near me"
      // sort works on the first search results the user sees.
      await ref.read(locationProvider.notifier).requestPermissionIfNeeded();

      // Pre-fetch search results (fire-and-forget)
      if (isReturningUser) {
        // Returning users: fetch with their saved language
        _preFetchSearchResults(languageCode);
      } else {
        // New users: fetch with Danish by default (optimized for primary audience)
        // Will be overwritten if user chooses English path or other language
        _preFetchSearchResults('da');
      }
    } catch (e) {
      // Still show buttons even if initialization fails
      if (mounted) {
        setState(() {
          _buttonsVisible = true;
        });
      }
    }
  }

  // ============================================================
  // PRE-FETCH SEARCH RESULTS
  // ============================================================

  /// Pre-fetch search results for returning users (fire-and-forget)
  Future<void> _preFetchSearchResults(String languageCode) async {
    try {
      // Check if cache is already fresh
      final searchNotifier = ref.read(searchStateProvider.notifier);
      if (searchNotifier.isCacheFresh()) {
        return;
      }

      // Get user location if usable (with timeout)
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
        // Continue without location
      }

      // Call search API with user's language
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
          fetchedWithLocation: userLocation != null,
        );
        searchNotifier.updateActiveFilterIds(activeIds);
      } else {
        // Fail silently - user will see loading shimmer on Search page
      }
    } catch (e) {
      // Fail silently - don't block Welcome page
    }
  }

  // ============================================================
  // BUTTON HANDLERS
  // ============================================================

  /// Handle "Continue" button for new users → English setup flow
  Future<void> _handleEnglishSetup() async {
    if (!context.mounted) return;

    // Navigate to English setup wizard (analytics tracked in dispose)
    context.push('/set-language-currency');
  }

  /// Handle "Fortsæt på dansk" button → Danish quick path
  /// Loads Danish translations + filters from disk cache (pre-cached at boot),
  /// navigates immediately, and cleans up English cache in background.
  Future<void> _handleDanishDirect() async {
    try {
      // Capture router before async operations
      final router = GoRouter.of(context);

      // 1. Save language preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_language_code', 'da');

      // 2. Load Danish translations from disk cache (pre-cached at boot → instant)
      //    Falls back to API if cache miss (e.g. background fetch hadn't finished)
      final cachedTranslations = await TranslationsCacheNotifier.loadFromCache('da');
      if (cachedTranslations.isNotEmpty) {
        ref.read(translationsCacheProvider.notifier).initializeFromPrefs(cachedTranslations, 'da');
      } else {
        await ref.read(translationsCacheProvider.notifier).loadTranslations('da');
      }

      // 3. Load Danish filters from disk cache (pre-cached at boot → instant)
      //    Falls back to API if cache miss
      final cachedFilters = await FilterNotifier.loadFromCache('da');
      if (cachedFilters.filtersForLanguage != null) {
        ref.read(filterProvider.notifier).initializeFromPrefs(cachedFilters);
      } else {
        unawaited(ref.read(filterProvider.notifier).loadFiltersForLanguage('da'));
      }

      // 4. Set currency to DKK
      await ref.read(localizationProvider.notifier).setCurrency('DKK', 1.0);

      // 5. Update locale for app-wide change
      ref.read(localeProvider.notifier).setLocale('da');

      // Navigate immediately — search results already cached from page load
      router.go('/search');

      // 6. Background cleanup: discard English cache (user chose Danish)
      unawaited(FilterNotifier.clearCacheForLanguage('en'));

    } catch (e) {
      if (context.mounted) {
        _showErrorDialog();
      }
    }
  }


  /// Handle "Continue" button for returning users → Navigate immediately
  /// NEW: Uses pre-fetched results if available, or shows shimmer while loading
  Future<void> _handleReturningUserContinue() async {
    if (!context.mounted) return;

    // Check if cached results are fresh
    final searchNotifier = ref.read(searchStateProvider.notifier);
    final hasFreshCache = searchNotifier.isCacheFresh();

    // Navigate immediately (analytics tracked in dispose, don't block navigation)
    context.go('/search');

    // If cache is stale, fetch in background (SearchPage will show shimmer)
    if (!hasFreshCache) {
      _fetchSearchResultsBackground();
    }
  }

  /// Background search fetch for returning users (non-blocking)
  Future<void> _fetchSearchResultsBackground() async {
    try {
      // Save notifier before async operations (safe even if widget unmounted)
      final searchNotifier = ref.read(searchStateProvider.notifier);

      // Get stored language code
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('user_language_code') ?? 'en';

      // Get user location (if available)
      String? userLocation;
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 5),
          ),
        );
        userLocation = 'LatLng(lat: ${position.latitude}, lng: ${position.longitude})';
      } catch (e) {
        // Continue without location
      }

      // Call SearchAPI
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
          fetchedWithLocation: userLocation != null,
        );
        searchNotifier.updateActiveFilterIds(activeIds);
      }
    } catch (e) {
      // Fail silently - SearchPage will handle error state
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  /// Show error dialog when API call fails
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Connection Error',
          style: AppTypography.h4,
        ),
        content: Text(
          td(ref, 'error_load_restaurants'),
          style: AppTypography.bodyLg,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: AppTypography.button.copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  /// Track page_viewed analytics event on dispose
  Future<void> _trackPageView() async {
    if (_pageStartTime == null || _hasTrackedPageView) return;
    _hasTrackedPageView = true; // Prevent duplicate calls

    try {
      final duration = DateTime.now().difference(_pageStartTime!);

      // Get deviceId and sessionId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString('analytics_device_id') ?? 'unknown';
      final sessionId = prefs.getString('current_session_id') ?? 'unknown';

      // Track event using ApiService directly
      await ApiService.instance.postAnalytics(
        eventType: 'page_viewed',
        deviceId: deviceId,
        sessionId: sessionId,
        userId: deviceId,
        eventData: {
          'pageName': 'welcomePage',
          'durationSeconds': duration.inSeconds.toString(),
        },
        timestamp: DateTime.now().toIso8601String(),
      );

    } catch (e) {
      // Fail silently - analytics should never block user flow
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // Hide translated text until translations are loaded (prevents key ID flash)
    final translationsCache = ref.watch(translationsCacheProvider);
    final hasTranslations = translationsCache.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.huge,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Heading - Split into two lines
              // "JourneyMate" always visible; translated prefix fades in
              AnimatedOpacity(
                opacity: hasTranslations ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  td(ref, 'onboarding_title_welcome_prefix'), // "Welcome to"
                  textAlign: TextAlign.center,
                  style: AppTypography.hero,
                ),
              ),
              Text(
                'JourneyMate', // Hardcoded - never translated
                textAlign: TextAlign.center,
                style: AppTypography.hero,
              ),

              const SizedBox(height: AppSpacing.huge),

              // Mascot Image (always visible immediately)
              Center(
                child: Image.asset(
                  'assets/images/JourneyMate Mascot - bg FDF4EC.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      width: 180,
                      height: 180,
                      child: Icon(
                        Icons.restaurant,
                        size: 100,
                        color: AppColors.accent,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.huge),

              // Tagline + description fade in with translations
              AnimatedOpacity(
                opacity: hasTranslations ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Column(
                  children: [
                    Text(
                      td(ref, 'welcome_tagline'), // "Go out, your way."
                      textAlign: TextAlign.center,
                      style: AppTypography.h4.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      td(ref, 'welcome_subtitle'), // "Discover restaurants, cafés, and..."
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLg.copyWith(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.huge),

              // Buttons fade in with translations
              if (_buttonsVisible && hasTranslations) ...[
                // Primary "Continue" button (always shown)
                SizedBox(
                  width: double.infinity,
                  height: AppConstants.buttonHeight,
                  child: TextButton(
                    onPressed: _isReturningUser
                        ? _handleReturningUserContinue
                        : _handleEnglishSetup,
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(AppColors.accent),
                      foregroundColor:
                          WidgetStateProperty.all(AppColors.white),
                      overlayColor:
                          WidgetStateProperty.all(Colors.transparent),
                      elevation: WidgetStateProperty.all(0),
                      minimumSize: WidgetStateProperty.all(Size.zero),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.filter),
                          side: const BorderSide(
                              color: AppColors.accent, width: 1.5),
                        ),
                      ),
                      textStyle:
                          WidgetStateProperty.all(AppTypography.button),
                    ),
                    child: Text(td(ref, 'welcome_continue')), // "Continue" / "Fortsæt"
                  ),
                ),

                // Secondary "Fortsæt på dansk" button (only for new users)
                if (!_isReturningUser) ...[
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    height: AppConstants.buttonHeight,
                    child: TextButton(
                      onPressed: _handleDanishDirect,
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(AppColors.white),
                        foregroundColor:
                            WidgetStateProperty.all(AppColors.accent),
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        elevation: WidgetStateProperty.all(0),
                        minimumSize: WidgetStateProperty.all(Size.zero),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.filter),
                            side: const BorderSide(
                                color: AppColors.accent, width: 1.5),
                          ),
                        ),
                        textStyle:
                            WidgetStateProperty.all(AppTypography.button),
                      ),
                      child: Text(
                          td(ref, 'welcome_continue_danish')), // "Fortsæt på dansk"
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
