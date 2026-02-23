import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../services/translation_service.dart';
import '../../services/api_service.dart';
import '../../services/analytics_service.dart';
import '../../widgets/shared/missing_location_form_widget.dart';

/// Missing Place Page (Phase 7.12)
///
/// Report missing restaurant form wrapper page.
/// All form logic is handled by MissingLocationFormWidget.
///
/// Page responsibilities:
/// - App bar with back button
/// - Analytics tracking (page_viewed with duration)
/// - Passing props to MissingLocationFormWidget
///
/// Note: No SingleChildScrollView wrapper - widget handles its own scrolling
///
/// Analytics: Tracks page_viewed with duration on dispose
class MissingPlacePage extends ConsumerStatefulWidget {
  const MissingPlacePage({super.key});

  @override
  ConsumerState<MissingPlacePage> createState() => _MissingPlacePageState();
}

class _MissingPlacePageState extends ConsumerState<MissingPlacePage> {
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
          'pageName': 'missingPlace',
          'durationSeconds': durationSeconds,
        },
      ).catchError((_) => ApiCallResponse.failure('Analytics failed'));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          td(ref, 'f5zshdrf'), // "Are we missing a place?"
          style: AppTypography.bodyRegular.copyWith(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: const MissingLocationFormWidget(),
    );
  }
}
