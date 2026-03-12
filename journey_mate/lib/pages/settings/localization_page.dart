import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../services/translation_service.dart';
import '../../services/api_service.dart';
import '../../services/analytics_service.dart';
import '../../providers/settings_providers.dart';
import '../../widgets/shared/language_selector_button.dart';
import '../../widgets/shared/currency_selector_button.dart';
import '../../widgets/shared/distance_unit_selector_button.dart';
import 'widgets/location_status_card.dart';

/// Localization Page (Phase 7.8)
///
/// Settings page for language and currency selection.
/// Uses LanguageSelectorButton and CurrencySelectorButton widgets.
///
/// Language change triggers:
/// - Update localizationProvider
/// - Auto-suggest currency based on language
/// - Reload translations from BuildShip API
///
/// Currency change triggers:
/// - Update localizationProvider
/// - Fetch latest exchange rate from BuildShip API
///
/// Analytics: Tracks page_viewed with duration on dispose
class LocalizationPage extends ConsumerStatefulWidget {
  const LocalizationPage({super.key});

  @override
  ConsumerState<LocalizationPage> createState() => _LocalizationPageState();
}

class _LocalizationPageState extends ConsumerState<LocalizationPage> with WidgetsBindingObserver {
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
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageStartTime = DateTime.now();
      _checkLocationPermission();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
          'pageName': 'localization',
          'durationSeconds': durationSeconds,
        },
      ).catchError((_) => ApiCallResponse.failure('Analytics failed'));
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check location permission when app resumes (user returns from system settings)
    if (state == AppLifecycleState.resumed) {
      _checkLocationPermission();
    }
  }

  // ============================================================
  // LOCATION PERMISSION
  // ============================================================

  /// Check current location permission status
  Future<void> _checkLocationPermission() async {
    await ref.read(locationProvider.notifier).checkPermission();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final currentLanguage = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          td(ref, 'settings_language_currency_title'), // "Settings"
          style: AppTypography.h5,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),

            // Page title
            Text(
              td(ref, 'settings_page_title_localization'), // "Localization settings"
              style: AppTypography.h4,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              td(ref, 'settings_page_subtitle_localization'), // "Configure your language, currency, and location preferences"
              style: AppTypography.body,
            ),
            const SizedBox(height: 28), // xxxl (32) minus 4px for tighter first gap

            // Language Section
            Text(
              td(ref, 'settings_language_description'), // "Language"
              style: AppTypography.h6,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              td(ref, 'settings_current_language_info'), // "Select your preferred language..."
              style: AppTypography.body,
            ),
            const SizedBox(height: AppSpacing.sm),
            LanguageSelectorButton(
              width: double.infinity,
              currentLanguageCode: currentLanguage,
              onLanguageSelected: (String newLanguage) {
                // Widget handles all state updates internally
                // Just trigger a rebuild to show the new language
                setState(() {});
              },
            ),

            const SizedBox(height: AppSpacing.xxl), // Reduced from xxxl (32) to xxl (24)

            // Currency Section
            Text(
              td(ref, 'settings_currency_description'), // "Currency"
              style: AppTypography.h6,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              td(ref, 'currency_display_prefix'), // "We can display prices..."
              style: AppTypography.body,
            ),
            const SizedBox(height: AppSpacing.sm),
            const CurrencySelectorButton(
              width: double.infinity,
              height: 50.0,
            ),

            const SizedBox(height: AppSpacing.md),

            // Exchange rate note
            Text(
              td(ref, 'currency_exchange_rate_disclaimer'), // "Exchange rates are updated once per 24 hours..."
              style: AppTypography.bodySm,
            ),

            const SizedBox(height: AppSpacing.xxl), // 24px gap

            // Distance Unit Section (ONLY visible when language is English)
            if (currentLanguage == 'en') ...[
              Text(
                td(ref, 'distance_unit_title'), // "Distance Units"
                style: AppTypography.h6,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                td(ref, 'distance_unit_description'),
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.sm),
              const DistanceUnitSelectorButton(
                width: double.infinity,
                height: 50.0,
              ),
              const SizedBox(height: AppSpacing.xxl), // 24px gap before Location
            ],

            // Location Section
            Text(
              td(ref, 'filter_location'), // "Location"
              style: AppTypography.h6,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              td(ref, 'location_description_permission'), // "Allow JourneyMate to show nearby restaurants..."
              style: AppTypography.body,
            ),
            // Intentionally larger spacing (lg instead of xs) for visual breathing room
            // above the location sharing button — do not reduce to match other sections
            const SizedBox(height: AppSpacing.lg),

            // Status card (tappable — handles permission request / settings)
            const LocationStatusCard(),

            // Privacy note (only when disabled)
            if (!ref.watch(locationProvider).hasPermission) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                td(ref, 'settings_location_privacy_info'), // "Your location is exclusively u..."
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

}
