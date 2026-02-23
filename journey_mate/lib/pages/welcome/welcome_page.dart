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
  bool _isLoadingSearch = false;

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

      // Check if user has language set (determines returning vs new user)
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('user_language_code');
      final isReturningUser = languageCode != null && languageCode.isNotEmpty;

      // Load translations if returning user
      if (isReturningUser) {
        await ref.read(translationsCacheProvider.notifier).loadTranslations(languageCode);
      }

      // Check location permission (fire-and-forget, don't block UI)
      ref.read(locationProvider.notifier).checkPermission();

      // Update UI state
      if (mounted) {
        setState(() {
          _isReturningUser = isReturningUser;
          _buttonsVisible = true;
        });
      }
    } catch (e) {
      debugPrint('⚠️ Welcome page initialization error: $e');
      // Still show buttons even if initialization fails
      if (mounted) {
        setState(() {
          _buttonsVisible = true;
        });
      }
    }
  }

  // ============================================================
  // BUTTON HANDLERS
  // ============================================================

  /// Handle "Continue" button for new users → English setup flow
  Future<void> _handleEnglishSetup() async {
    if (!mounted) return;

    // Track analytics before navigating away
    await _trackPageView();

    // Navigate to English setup wizard
    if (!mounted) return;
    context.push('/set-language-currency');
  }

  /// Handle "Fortsæt på dansk" button → Danish quick path
  Future<void> _handleDanishDirect() async {
    if (!mounted) return;

    setState(() {
      _isLoadingSearch = true;
    });

    try {
      // 1. Save language preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_language_code', 'da');

      // 2. Load Danish translations
      await ref.read(translationsCacheProvider.notifier).loadTranslations('da');

      // 3. Set currency to DKK
      await ref.read(localizationProvider.notifier).setCurrency('DKK', 1.0);

      // 4. Get user location (if available)
      String? userLocation;
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          ),
        );
        userLocation = 'LatLng(lat: ${position.latitude}, lng: ${position.longitude})';
      } catch (e) {
        debugPrint('⚠️ Could not get location: $e');
        // Continue without location
      }

      // 5. Call SearchAPI with Danish language
      final response = await ApiService.instance.search(
        filters: [],
        filtersUsedForSearch: [],
        cityId: AppConstants.kDefaultCityId.toString(),
        searchInput: '',
        userLocation: userLocation,
        languageCode: 'da',
        sortBy: 'match',
        sortOrder: 'desc',
        page: 1,
        pageSize: 20,
      );

      if (!mounted) return;

      // 6. Handle API response
      if (!response.succeeded) {
        setState(() {
          _isLoadingSearch = false;
        });
        _showErrorDialog();
        return;
      }

      // 7. Store search results
      final resultCount = response.jsonBody['resultCount'] ?? 0;
      ref.read(searchStateProvider.notifier).updateSearchResults(
        response.jsonBody,
        resultCount,
      );

      // 8. Track analytics
      await _trackPageView();

      // 9. Navigate to search page
      if (!mounted) return;
      context.go('/search');

    } catch (e) {
      debugPrint('❌ Danish direct flow error: $e');
      if (mounted) {
        setState(() {
          _isLoadingSearch = false;
        });
        _showErrorDialog();
      }
    }
  }

  /// Handle "Continue" button for returning users → Load search
  Future<void> _handleReturningUserContinue() async {
    if (!mounted) return;

    setState(() {
      _isLoadingSearch = true;
    });

    try {
      // 1. Get stored language code
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('user_language_code') ?? 'en';

      // 2. Get user location (if available)
      String? userLocation;
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          ),
        );
        userLocation = 'LatLng(lat: ${position.latitude}, lng: ${position.longitude})';
      } catch (e) {
        debugPrint('⚠️ Could not get location: $e');
        // Continue without location
      }

      // 3. Call SearchAPI with user's language
      final response = await ApiService.instance.search(
        filters: [],
        filtersUsedForSearch: [],
        cityId: AppConstants.kDefaultCityId.toString(),
        searchInput: '',
        userLocation: userLocation,
        languageCode: languageCode,
        sortBy: 'match',
        sortOrder: 'desc',
        page: 1,
        pageSize: 20,
      );

      if (!mounted) return;

      // 4. Handle API response
      if (!response.succeeded) {
        setState(() {
          _isLoadingSearch = false;
        });
        _showErrorDialog();
        return;
      }

      // 5. Store search results
      final resultCount = response.jsonBody['resultCount'] ?? 0;
      ref.read(searchStateProvider.notifier).updateSearchResults(
        response.jsonBody,
        resultCount,
      );

      // 6. Track analytics
      await _trackPageView();

      // 7. Navigate to search page
      if (!mounted) return;
      context.go('/search');

    } catch (e) {
      debugPrint('❌ Returning user continue error: $e');
      if (mounted) {
        setState(() {
          _isLoadingSearch = false;
        });
        _showErrorDialog();
      }
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
          style: AppTypography.sectionHeading,
        ),
        content: Text(
          'Could not load restaurants. Please check your internet connection and try again.',
          style: AppTypography.bodyRegular,
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
    if (_pageStartTime == null) return;

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

      debugPrint('✅ Tracked welcomePage view: ${duration.inSeconds}s');
    } catch (e) {
      debugPrint('⚠️ Failed to track page view: $e');
      // Fail silently - analytics should never block user flow
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.huge,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Heading
              Text(
                td(ref, '6dww9uct'), // "Welcome to JourneyMate"
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: AppSpacing.huge),

              // Mascot Image
              Center(
                child: Image.asset(
                  'assets/images/journeymate_mascot.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // If image fails to load, show placeholder
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

              // Tagline
              Text(
                td(ref, 'z6e1v2g7'), // "Go out, your way."
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Description
              Text(
                td(ref, '0eehrkgn'), // "Discover restaurants, cafés, and..."
                textAlign: TextAlign.center,
                style: AppTypography.bodyRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppSpacing.huge),

              // Buttons (conditional based on user type)
              if (_buttonsVisible) ...[
                // Primary "Continue" button (always shown)
                ElevatedButton(
                  onPressed: _isLoadingSearch
                      ? null
                      : (_isReturningUser
                          ? _handleReturningUserContinue
                          : _handleEnglishSetup),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    disabledBackgroundColor: AppColors.border,
                    minimumSize: const Size(270, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoadingSearch
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          td(ref, 'd2mrwxr4'), // "Continue" / "Fortsæt"
                          style: AppTypography.button.copyWith(
                            color: Colors.white,
                          ),
                        ),
                ),

                // Secondary "Fortsæt på dansk" button (only for new users)
                if (!_isReturningUser) ...[
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton(
                    onPressed: _isLoadingSearch ? null : _handleDanishDirect,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.bgPage,
                      side: const BorderSide(
                        color: AppColors.accent,
                        width: 2,
                      ),
                      minimumSize: const Size(270, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      td(ref, 'cuy6esxb'), // "Fortsæt på dansk"
                      style: AppTypography.button.copyWith(
                        color: AppColors.accent,
                      ),
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
