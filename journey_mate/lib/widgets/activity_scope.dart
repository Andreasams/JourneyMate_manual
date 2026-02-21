import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import '../services/analytics_service.dart';

/// Activity detection widget
/// Wraps the app to detect all user interactions (tap/scroll/keyboard/navigation)
class ActivityScope extends StatelessWidget {
  final Widget child;

  const ActivityScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      // Captures all pointer events (tap, drag, scroll)
      onPointerDown: (_) {
        AnalyticsService.instance.engagementTracker.markUserActive();
      },
      onPointerMove: (_) {
        AnalyticsService.instance.engagementTracker.markUserActive();
      },
      onPointerSignal: (signal) {
        // Captures scroll wheel events
        if (signal is PointerScrollEvent) {
          AnalyticsService.instance.engagementTracker.markUserActive();
        }
      },
      child: child,
    );
  }
}
