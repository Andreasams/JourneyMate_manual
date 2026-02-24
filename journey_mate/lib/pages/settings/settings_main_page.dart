import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_constants.dart';
import '../../services/translation_service.dart';
import '../../services/api_service.dart';
import '../../services/analytics_service.dart';
import '../../providers/search_providers.dart';
import '../../providers/settings_providers.dart';
import '../../widgets/shared/nav_bar_widget.dart';

/// Settings Main Page (Phase 7.7)
///
/// Navigation hub for all settings pages with 3 sections:
/// 1. My JourneyMate: Localization
/// 2. Reach out: Missing place, Share feedback, Contact us
/// 3. Resources: Terms of use, Privacy policy (external URLs)
///
/// Analytics: Tracks page_viewed with duration on dispose
class SettingsMainPage extends ConsumerStatefulWidget {
  const SettingsMainPage({super.key});

  @override
  ConsumerState<SettingsMainPage> createState() => _SettingsMainPageState();
}

class _SettingsMainPageState extends ConsumerState<SettingsMainPage> {
  // ============================================================
  // LOCAL STATE
  // ============================================================

  DateTime? _pageStartTime;

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageStartTime = DateTime.now();

      // Pre-fetch search results in background (fire-and-forget)
      _preFetchSearchResults();
    });
  }

  // ============================================================
  // PRE-FETCH SEARCH RESULTS
  // ============================================================

  /// Pre-fetch search results for fast navigation to Search tab
  Future<void> _preFetchSearchResults() async {
    try {
      debugPrint('⚙️ Settings: Pre-fetching search results...');

      // Check if cache is already fresh
      final searchNotifier = ref.read(searchStateProvider.notifier);
      if (searchNotifier.isCacheFresh()) {
        debugPrint('⚙️ Settings: Cache is fresh, skipping pre-fetch');
        return;
      }

      // Get language code from preferences
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('user_language_code') ?? 'en';

      // Get user location if permission granted (with timeout)
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
        debugPrint('⚙️ Settings: Location fetch failed: $e');
        // Continue without location
      }

      // Call search API with empty query (default search)
      final response = await ApiService.instance.search(
        cityId: AppConstants.kDefaultCityId.toString(),
        userLocation: userLocation,
        searchInput: '',
        languageCode: languageCode,
        filters: [],
        filtersUsedForSearch: [],
        sortBy: 'match',
        sortOrder: 'desc',
        onlyOpen: false,
        category: 'all',
        page: 1,
        pageSize: 20,
      );

      if (response.succeeded) {
        final resultCount = response.jsonBody['resultCount'] as int? ?? 0;
        // Use saved notifier (safe even if widget unmounted)
        searchNotifier.updateSearchResults(
          response.jsonBody,
          resultCount,
        );
        debugPrint('⚙️ Settings: Pre-fetch succeeded ($resultCount results)');
      } else {
        debugPrint('⚙️ Settings: Pre-fetch failed: ${response.error}');
        // Fail silently - user will see loading shimmer on Search page
      }
    } catch (e) {
      debugPrint('⚙️ Settings: Pre-fetch exception: $e');
      // Fail silently - don't block Settings page
    }
  }

  @override
  void dispose() {
    // Track page view analytics with duration
    if (_pageStartTime != null) {
      final durationSeconds = DateTime.now().difference(_pageStartTime!).inSeconds;
      final analytics = AnalyticsService.instance;
      // Fire-and-forget analytics call
      ApiService.instance.postAnalytics(
        eventType: 'page_viewed',
        deviceId: analytics.deviceId ?? '',
        sessionId: analytics.currentSessionId ?? '',
        userId: analytics.userId ?? '',
        timestamp: DateTime.now().toIso8601String(),
        eventData: {
          'pageName': 'settingsAndAccount',
          'durationSeconds': durationSeconds,
        },
      ).catchError((_) => ApiCallResponse.failure('Analytics failed'));
    }
    super.dispose();
  }

  // ============================================================
  // HELPERS
  // ============================================================

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,    // 20px left
            AppSpacing.huge,  // 40px top
            AppSpacing.xl,    // 20px right
            0,                // No bottom padding - handled by navbar
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page title
                Text(
                  td(ref, 'cpiiq0im'), // "Settings & account"
                  style: AppTypography.pageTitle.copyWith(
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // Section 1: My JourneyMate
                _buildSection(
                  context,
                  td(ref, '3tlbn2an'), // "My JourneyMate"
                  [
                    _buildSettingRow(
                      context,
                      label: td(ref, '290fbi5g'), // "Localization"
                      icon: Icons.language_outlined,
                      onTap: () {
                        context.push('/settings/localization');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // Section 2: Reach out
                _buildSection(
                  context,
                  td(ref, 'pb7qrt34'), // "Reach out"
                  [
                    _buildSettingRow(
                      context,
                      label: td(ref, '297ogtn9'), // "Are we missing a place?"
                      icon: Icons.add_location_alt_outlined,
                      onTap: () {
                        context.push('/settings/missing-place');
                      },
                      showDividerAbove: false,
                    ),
                    _buildSettingRow(
                      context,
                      label: td(ref, 'uz83tnpj'), // "Share feedback"
                      icon: Icons.feedback_outlined,
                      onTap: () {
                        context.push('/settings/feedback');
                      },
                    ),
                    _buildSettingRow(
                      context,
                      label: td(ref, 'dme8eg1t'), // "Contact us"
                      icon: Icons.mail_outline,
                      onTap: () {
                        context.push('/settings/contact');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // Section 3: Resources
                _buildSection(
                  context,
                  td(ref, 'd952v5y4'), // "Resources"
                  [
                    _buildSettingRow(
                      context,
                      label: td(ref, '2v106a6z'), // "Terms of use"
                      icon: Icons.description_outlined,
                      onTap: () {
                        _launchURL(
                            'https://docs.google.com/document/d/1CAjvjWt73BgvBZSMUKiIyPbz2sZ5RiqCMGuD0R6KVpc/edit?usp=sharing');
                      },
                      showDividerAbove: false,
                    ),
                    _buildSettingRow(
                      context,
                      label: td(ref, 'gtmo283r'), // "Privacy policy"
                      icon: Icons.privacy_tip_outlined,
                      onTap: () {
                        _launchURL(
                            'https://docs.google.com/document/d/1nO_TaK-HB8-CV9FM8zs3uu0mYgCT4taO0nBSv2iHw3A/edit?usp=sharing');
                      },
                    ),
                  ],
                ),

                // Bottom spacing for navbar clearance
                const SizedBox(height: 80.0),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const NavBarWidget(
        pageIsSearchResults: false,
      ),
    );
  }

  /// Builds a section with header and setting rows
  Widget _buildSection(
    BuildContext context,
    String header,
    List<Widget> rows,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Text(
          header,
          style: AppTypography.label,
        ),
        const SizedBox(height: AppSpacing.sm),

        // Setting rows with dividers
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: Column(
            children: rows,
          ),
        ),
      ],
    );
  }

  /// Builds a setting row with icon, label and chevron (left-aligned)
  Widget _buildSettingRow(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    IconData? icon,
    bool showDividerAbove = true,
  }) {
    return Column(
      children: [
        if (showDividerAbove)
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.divider,
          ),
        InkWell(
          onTap: onTap,
          splashColor: Colors.transparent,
          highlightColor: AppColors.bgInput.withAlpha((0.5 * 255).round()),
          child: Container(
            height: 48.0,
            padding: EdgeInsets.zero,
            child: Row(
              children: [
                // Icon (if provided)
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: AppColors.textSecondary,
                    size: 20.0,
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                // Label (left-aligned)
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.bodyRegular,
                  ),
                ),
                // Chevron
                Icon(
                  Icons.keyboard_arrow_right_outlined,
                  color: AppColors.textSecondary,
                  size: 22.0,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
