// ⚠️ CRITICAL: Import from widgets, NOT foundation
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/analytics_service.dart';

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
    } else if (state == AppLifecycleState.paused) {
      debugPrint('⏸️ AppLifecycleObserver: App paused');
      await AnalyticsService.instance.engagementTracker.onAppPaused();
    } else if (state == AppLifecycleState.detached) {
      debugPrint('🛑 AppLifecycleObserver: App detached');
      await AnalyticsService.instance.engagementTracker.onAppDetached();
    }
  }
}
