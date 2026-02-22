import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../services/translation_service.dart';
import '../../services/api_service.dart';
import '../../services/analytics_service.dart';
import '../../widgets/shared/language_selector_button.dart';
import '../../widgets/shared/currency_selector_button.dart';

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

class _LocalizationPageState extends ConsumerState<LocalizationPage> {
  DateTime? _pageStartTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageStartTime = DateTime.now();
    });
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
          'pageName': 'languageAndCurrency',
          'durationSeconds': durationSeconds,
        },
      ).catchError((_) => ApiCallResponse.failure('Analytics failed'));
    }
    super.dispose();
  }

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
          ts(context, 'rct7k6pr'), // "Settings"
          style: AppTypography.bodyRegular.copyWith(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),

            // Language Section
            Text(
              ts(context, 'phfch9og'), // "Language"
              style: AppTypography.bodyMedium.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              ts(context, 'gl71ej9n'), // "Select your preferred language..."
              style: AppTypography.bodyRegular.copyWith(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            LanguageSelectorButton(
              width: double.infinity,
              currentLanguageCode: currentLanguage,
              onLanguageSelected: (String newLanguage) {
                // Widget handles all state updates internally
                // Just trigger a rebuild to show the new language
                setState(() {});
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // Currency Section
            Text(
              ts(context, 'y0gzdnsp'), // "Currency"
              style: AppTypography.bodyMedium.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              ts(context, 'n4pzujqg'), // "We can display prices..."
              style: AppTypography.bodyRegular.copyWith(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const CurrencySelectorButton(
              width: double.infinity,
              height: 90.0,
            ),

            const SizedBox(height: AppSpacing.md),

            // Exchange rate note
            Text(
              ts(context, '82y059ik'), // "Exchange rates are updated once per 24 hours..."
              style: AppTypography.bodyRegular.copyWith(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}
