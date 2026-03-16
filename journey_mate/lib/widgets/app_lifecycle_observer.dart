// ⚠️ CRITICAL: Import from widgets, NOT foundation
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/analytics_service.dart';
import '../providers/app_providers.dart';
import '../providers/settings_providers.dart';

/// App lifecycle observer
/// Hooks into Flutter's app lifecycle to track foreground/background/detached states
class AppLifecycleObserver extends WidgetsBindingObserver {
  final ProviderContainer container;

  AppLifecycleObserver({required this.container});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // onAppResumed() returns the current active session UUID
      // (may be new session or continuing existing session)
      final currentSessionId = await AnalyticsService.instance.engagementTracker.onAppResumed();

      // Sync current session UUID to Riverpod provider
      container.read(analyticsProvider.notifier).startSession(sessionId: currentSessionId);

      // Check location permission on resume (detect permission/service changes via Settings)
      final locationNotifier = container.read(locationProvider.notifier);
      final previousState = container.read(locationProvider);

      await locationNotifier.checkPermission();
      final currentState = container.read(locationProvider);

      // Reset dismissal if location newly usable (service + permission) via Settings
      if (!previousState.isLocationUsable && currentState.isLocationUsable) {
        await locationNotifier.resetBannerDismissal();
      }
    } else if (state == AppLifecycleState.paused) {
      await AnalyticsService.instance.engagementTracker.onAppPaused();
    } else if (state == AppLifecycleState.detached) {
      await AnalyticsService.instance.engagementTracker.onAppDetached();
    }
  }
}
