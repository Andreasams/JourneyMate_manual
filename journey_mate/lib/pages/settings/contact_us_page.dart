import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../services/translation_service.dart';
import '../../services/api_service.dart';
import '../../services/analytics_service.dart';
import 'widgets/contact_us_form_widget.dart';

/// Contact Us Page (Phase 7.10)
///
/// Support contact form wrapper page.
/// All form logic is handled by ContactUsFormWidget.
///
/// Page responsibilities:
/// - App bar with back button
/// - Analytics tracking (page_viewed with duration)
/// - Passing props to ContactUsFormWidget
///
/// Analytics: Tracks page_viewed with duration on dispose
class ContactUsPage extends ConsumerStatefulWidget {
  const ContactUsPage({super.key});

  @override
  ConsumerState<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends ConsumerState<ContactUsPage> {
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
      final deviceId = analytics.deviceId;
      final sessionId = analytics.currentSessionId;
      final userId = analytics.userId;
      if (deviceId == null || sessionId == null || userId == null) {
        debugPrint('WARNING: page_viewed skipped — analytics IDs not initialized');
        super.dispose();
        return;
      }
      // Fire-and-forget analytics call
      ApiService.instance.postAnalytics(
        eventType: 'page_viewed',
        deviceId: deviceId,
        sessionId: sessionId,
        userId: userId,
        timestamp: DateTime.now().toIso8601String(),
        eventData: {
          'pageName': 'contactUs',
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
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          td(ref, 'contact_form_title_main'), // "Contact us"
          style: AppTypography.h5,
        ),
      ),
      body: const ContactUsFormWidget(),
    );
  }
}
