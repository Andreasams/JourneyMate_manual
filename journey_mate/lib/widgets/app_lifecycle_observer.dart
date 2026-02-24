// ⚠️ CRITICAL: Import from widgets, NOT foundation
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/analytics_service.dart';
import '../providers/settings_providers.dart';

/// App lifecycle observer
/// Hooks into Flutter's app lifecycle to track foreground/background/detached states
class AppLifecycleObserver extends WidgetsBindingObserver {
  final ProviderContainer container;

  AppLifecycleObserver({required this.container});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      debugPrint('💚 AppLifecycleObserver: App resumed');
      await AnalyticsService.instance.engagementTracker.onAppResumed();

      // Check location permission on resume (detect permission changes via Settings)
      final locationNotifier = container.read(locationProvider.notifier);
      final previousPermission = container.read(locationProvider).hasPermission;

      await locationNotifier.checkPermission();
      final currentPermission = container.read(locationProvider).hasPermission;

      // Reset dismissal if permission newly granted via Settings
      if (!previousPermission && currentPermission) {
        await locationNotifier.resetBannerDismissal();
        debugPrint('✅ Location granted via Settings, dismissal reset');
      }
    } else if (state == AppLifecycleState.paused) {
      debugPrint('⏸️ AppLifecycleObserver: App paused');
      await AnalyticsService.instance.engagementTracker.onAppPaused();
    } else if (state == AppLifecycleState.detached) {
      debugPrint('🛑 AppLifecycleObserver: App detached');
      await AnalyticsService.instance.engagementTracker.onAppDetached();
    }
  }
}
