import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Analytics state
class AnalyticsState {
  final String deviceId;
  final String? sessionId;
  final DateTime? sessionStartTime;

  AnalyticsState({
    required this.deviceId,
    this.sessionId,
    this.sessionStartTime,
  });

  AnalyticsState copyWith({
    String? deviceId,
    String? sessionId,
    DateTime? sessionStartTime,
  }) {
    return AnalyticsState(
      deviceId: deviceId ?? this.deviceId,
      sessionId: sessionId ?? this.sessionId,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
    );
  }
}

/// Analytics provider (Riverpod 3.x)
final analyticsProvider =
    NotifierProvider<AnalyticsNotifier, AnalyticsState>(() {
  return AnalyticsNotifier();
});

class AnalyticsNotifier extends Notifier<AnalyticsState> {
  @override
  AnalyticsState build() {
    return AnalyticsState(deviceId: '');
  }

  /// Initialize analytics (load or create device ID)
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');

    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString('device_id', deviceId);
    }

    state = state.copyWith(deviceId: deviceId);
  }

  /// Start a new session
  void startSession() {
    final sessionId = const Uuid().v4();
    final sessionStartTime = DateTime.now();

    state = state.copyWith(
      sessionId: sessionId,
      sessionStartTime: sessionStartTime,
    );
  }

  /// End the current session
  void endSession() {
    state = state.copyWith(
      sessionId: null,
      sessionStartTime: null,
    );
  }
}
