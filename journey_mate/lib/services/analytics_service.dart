import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'api_service.dart';

// ============================================================
// ENGAGEMENT TRACKER
// ============================================================

/// Professional engagement tracking system
///
/// Tracks two key metrics:
/// - Foreground time: App is visible
/// - Engaged time: User is actively interacting
///
/// Features:
/// - Activity detection (tap/scroll/keyboard/navigation)
/// - Automatic session timeout (30 minutes inactivity)
/// - Periodic flushing (every 60 seconds)
/// - Battery-efficient heartbeat (1-second intervals, stopped during background)
class EngagementTracker {
  // -------------------------------------------------------------------------
  // CONFIGURATION
  // -------------------------------------------------------------------------
  static const Duration sessionTimeout = Duration(minutes: 30);
  static const Duration engagedWindow = Duration(seconds: 15);
  static const Duration heartbeatInterval = Duration(seconds: 1);
  static const Duration flushInterval = Duration(seconds: 60);

  // -------------------------------------------------------------------------
  // SESSION STATE
  // -------------------------------------------------------------------------
  String? sessionId;
  DateTime? sessionStartTime;
  DateTime lastActiveAt = DateTime.now();
  DateTime? engagedUntil;

  // -------------------------------------------------------------------------
  // COUNTERS (reset each session)
  // -------------------------------------------------------------------------
  int foregroundSeconds = 0;
  int engagedSeconds = 0;

  // -------------------------------------------------------------------------
  // RUNTIME STATE
  // -------------------------------------------------------------------------
  bool _inForeground = false;
  Timer? _heartbeatTimer;
  Timer? _flushTimer;
  DateTime? _lastFlushTime;
  SharedPreferences? _cachedPrefs;

  // -------------------------------------------------------------------------
  // LIFECYCLE METHODS
  // -------------------------------------------------------------------------

  /// Called when app comes to foreground
  Future<void> onAppResumed() async {
    debugPrint('💚 EngagementTracker: App resumed');
    _inForeground = true;
    await _maybeEndStaleSessionAndStartNew();
    _ensureHeartbeat();
    _ensurePeriodicFlush();
  }

  /// Called when app goes to background
  Future<void> onAppPaused() async {
    debugPrint('💤 EngagementTracker: App paused');

    final now = DateTime.now();
    _inForeground = false;

    // Credit remaining engagement time before clearing window
    if (engagedUntil != null && now.isBefore(engagedUntil!)) {
      final remainingSeconds = engagedUntil!.difference(now).inSeconds;
      engagedSeconds += remainingSeconds;
      debugPrint(
          '   💤 Credited $remainingSeconds seconds of remaining engagement');
    }
    engagedUntil = null; // Clear engagement window

    await _flushPartialSession();

    // Stop timers to save battery
    _stopHeartbeat();
    _flushTimer?.cancel();
    _flushTimer = null;
  }

  /// Called when app is closing (best effort)
  Future<void> onAppDetached() async {
    debugPrint('🛑 EngagementTracker: App detached');
    await endSession(reason: 'app_closed');
    _stopHeartbeat();
    _flushTimer?.cancel();
    _flushTimer = null;
  }

  // -------------------------------------------------------------------------
  // ACTIVITY TRACKING
  // -------------------------------------------------------------------------

  /// Call this on ANY user interaction (tap/scroll/type/navigate)
  void markUserActive() {
    final now = DateTime.now();
    lastActiveAt = now;
    engagedUntil = now.add(engagedWindow);

    // Also save to SharedPreferences for custom code access
    _saveActivityTimestamp(now);
  }

  /// Saves activity timestamp to SharedPreferences
  Future<void> _saveActivityTimestamp(DateTime timestamp) async {
    try {
      _cachedPrefs ??= await SharedPreferences.getInstance();
      await _cachedPrefs!
          .setInt('last_user_activity', timestamp.millisecondsSinceEpoch);
    } catch (e) {
      // Fail silently
    }
  }

  /// Checks SharedPreferences for activity from custom code
  Future<void> _checkForExternalActivity() async {
    try {
      _cachedPrefs ??= await SharedPreferences.getInstance();
      final lastActivityMs = _cachedPrefs!.getInt('last_user_activity');

      if (lastActivityMs != null) {
        final activityTime =
            DateTime.fromMillisecondsSinceEpoch(lastActivityMs);

        // If activity is recent (within last 2 seconds), update engagement
        if (DateTime.now().difference(activityTime).inSeconds < 2) {
          lastActiveAt = activityTime;
          engagedUntil = activityTime.add(engagedWindow);
        }
      }
    } catch (e) {
      // Fail silently
    }
  }

  // -------------------------------------------------------------------------
  // SESSION MANAGEMENT
  // -------------------------------------------------------------------------

  /// Checks if current session is stale and starts new one if needed
  Future<void> _maybeEndStaleSessionAndStartNew() async {
    final now = DateTime.now();
    final hasActiveSession = sessionId != null;

    // Check if session is stale (inactive for sessionTimeout)
    final isStale =
        hasActiveSession && now.difference(lastActiveAt) > sessionTimeout;

    if (isStale) {
      debugPrint(
          '⏰ Session stale (${now.difference(lastActiveAt).inMinutes}m inactive)');
      await endSession(reason: 'timeout');
    }

    // Start new session if none exists
    if (sessionId == null) {
      await startNewSession();
    }
  }

  /// Starts a new engagement session
  Future<void> startNewSession() async {
    final now = DateTime.now();

    sessionId = const Uuid().v4();
    sessionStartTime = now;
    lastActiveAt = now;
    engagedUntil = now.add(engagedWindow);
    foregroundSeconds = 0;
    engagedSeconds = 0;
    _lastFlushTime = now;

    // Store in SharedPreferences for access by custom code
    try {
      _cachedPrefs ??= await SharedPreferences.getInstance();
      await _cachedPrefs!.setString('current_session_id', sessionId!);
    } catch (e) {
      debugPrint('⚠️ Failed to save session ID to SharedPreferences: $e');
    }

    // Track session start (fire and forget)
    unawaited(_trackAnalyticsEvent('session_start', {
      'sessionId': sessionId,
      'timestamp': now.toIso8601String(),
    }));

    debugPrint('🚀 Engagement session started: ${sessionId?.substring(0, 8)}');
  }

  /// Ends the current session
  Future<void> endSession({required String reason}) async {
    if (sessionId == null) return;

    final now = DateTime.now();
    final sessionDuration = sessionStartTime != null
        ? now.difference(sessionStartTime!).inSeconds
        : 0;

    // Calculate engagement rate
    final engagementRate = foregroundSeconds > 0
        ? (engagedSeconds / foregroundSeconds).clamp(0.0, 1.0)
        : 0.0;

    // Track session end with comprehensive metrics (fire and forget)
    unawaited(_trackAnalyticsEvent('session_end', {
      'sessionId': sessionId,
      'sessionDuration': sessionDuration,
      'foregroundSeconds': foregroundSeconds,
      'engagedSeconds': engagedSeconds,
      'engagementRate': engagementRate,
      'endReason': reason,
      'timestamp': now.toIso8601String(),
    }));

    debugPrint('🏁 Engagement session ended:');
    debugPrint('   Session: ${sessionId?.substring(0, 8)}');
    debugPrint('   Duration: ${sessionDuration}s');
    debugPrint('   Foreground: ${foregroundSeconds}s');
    debugPrint('   Engaged: ${engagedSeconds}s');
    debugPrint('   Rate: ${(engagementRate * 100).toStringAsFixed(1)}%');
    debugPrint('   Reason: $reason');

    // Clear session ID from SharedPreferences
    try {
      _cachedPrefs ??= await SharedPreferences.getInstance();
      await _cachedPrefs!.remove('current_session_id');
    } catch (e) {
      debugPrint('⚠️ Failed to clear session ID from SharedPreferences: $e');
    }

    sessionId = null;
    sessionStartTime = null;
    engagedUntil = null;
    foregroundSeconds = 0;
    engagedSeconds = 0;
  }

  // -------------------------------------------------------------------------
  // HEARTBEAT & COUNTING
  // -------------------------------------------------------------------------

  /// Ensures heartbeat timer is running
  void _ensureHeartbeat() {
    if (_heartbeatTimer != null && _heartbeatTimer!.isActive) return;

    _heartbeatTimer = Timer.periodic(heartbeatInterval, (_) => _tick());
    debugPrint('💓 Heartbeat started');
  }

  /// Stops heartbeat timer
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    debugPrint('💔 Heartbeat stopped');
  }

  /// Heartbeat tick - increments counters
  void _tick() {
    if (sessionId == null) return;

    final now = DateTime.now();

    // Check for activity from custom code (async, doesn't block tick)
    _checkForExternalActivity();

    // Increment foreground seconds when app is visible
    if (_inForeground) {
      foregroundSeconds++;
    }

    // Increment engaged seconds when within activity window
    if (engagedUntil != null && now.isBefore(engagedUntil!)) {
      engagedSeconds++;
    }
  }

  // -------------------------------------------------------------------------
  // PERIODIC FLUSHING
  // -------------------------------------------------------------------------

  /// Ensures periodic flush timer is running
  void _ensurePeriodicFlush() {
    if (_flushTimer != null && _flushTimer!.isActive) return;

    _flushTimer = Timer.periodic(flushInterval, (_) => _flushPartialSession());
    debugPrint('🔄 Periodic flush started');
  }

  /// Flushes partial session data (every 60 seconds while active)
  Future<void> _flushPartialSession() async {
    if (sessionId == null) return;

    final now = DateTime.now();
    final timeSinceLastFlush =
        _lastFlushTime != null ? now.difference(_lastFlushTime!).inSeconds : 0;

    // Only flush if meaningful time has passed
    if (timeSinceLastFlush < 30) return;

    final engagementRate = foregroundSeconds > 0
        ? (engagedSeconds / foregroundSeconds).clamp(0.0, 1.0)
        : 0.0;

    // Track partial session update (fire and forget)
    unawaited(_trackAnalyticsEvent('session_heartbeat', {
      'sessionId': sessionId,
      'foregroundSeconds': foregroundSeconds,
      'engagedSeconds': engagedSeconds,
      'engagementRate': engagementRate,
      'timestamp': now.toIso8601String(),
    }));

    _lastFlushTime = now;
    debugPrint(
        '💾 Flushed partial session: ${foregroundSeconds}s fg, ${engagedSeconds}s engaged');
  }

  // -------------------------------------------------------------------------
  // ANALYTICS HELPER
  // -------------------------------------------------------------------------

  /// Tracks an analytics event (fire and forget)
  Future<void> _trackAnalyticsEvent(
      String eventType, Map<String, dynamic> eventData) async {
    try {
      await ApiService.instance.postAnalytics(
        eventType: eventType,
        deviceId: AnalyticsService.instance.deviceId ?? 'unknown',
        sessionId: sessionId ?? 'unknown',
        userId: AnalyticsService.instance.userId ?? 'unknown',
        eventData: eventData,
        timestamp: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      debugPrint('⚠️ Failed to track analytics event: $e');
    }
  }

  // -------------------------------------------------------------------------
  // GETTERS
  // -------------------------------------------------------------------------

  /// Gets current engagement rate (0.0 to 1.0)
  double get currentEngagementRate {
    if (foregroundSeconds == 0) return 0.0;
    return (engagedSeconds / foregroundSeconds).clamp(0.0, 1.0);
  }

  /// Gets current session duration in seconds
  int get currentSessionDuration {
    if (sessionStartTime == null) return 0;
    return DateTime.now().difference(sessionStartTime!).inSeconds;
  }
}

// ============================================================
// ANALYTICS SERVICE
// ============================================================

/// Analytics service singleton
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  static AnalyticsService get instance => _instance;
  AnalyticsService._internal();

  String? _deviceId;
  String? _userId;
  String? _currentFilterSessionId;
  bool _isFirstSession = false;

  final engagementTracker = EngagementTracker();

  String? get deviceId => _deviceId;
  String? get userId => _userId;
  String? get currentSessionId => engagementTracker.sessionId;
  String? get currentFilterSessionId => _currentFilterSessionId;
  bool get isFirstSession => _isFirstSession;

  /// Initialize analytics and start engagement tracking
  Future<void> initialize() async {
    try {
      _deviceId = await _getOrCreateDeviceId();
      _userId = _deviceId;
      _isFirstSession = await _detectFirstSession();

      // Start engagement tracking
      await engagementTracker.startNewSession();

      debugPrint('✅ Analytics initialized');
      debugPrint('   Device: ${_deviceId?.substring(0, 8)}...');
      debugPrint('   Session: ${currentSessionId?.substring(0, 8)}...');
      debugPrint('   First session: $_isFirstSession');
    } catch (e, s) {
      debugPrint('❌ Analytics init failed: $e');
      debugPrint('$s');
    }
  }

  Future<String> _getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('analytics_device_id');

    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString('analytics_device_id', deviceId);
      debugPrint('📱 Created new device_id: ${deviceId.substring(0, 8)}...');
    } else {
      debugPrint('📱 Existing device_id: ${deviceId.substring(0, 8)}...');
    }

    return deviceId;
  }

  Future<bool> _detectFirstSession() async {
    final prefs = await SharedPreferences.getInstance();
    final launchedFlag = prefs.getString('has_launched_before');

    if (launchedFlag == 'true') return false;

    await prefs.setString('has_launched_before', 'true');
    return true;
  }

  /// Gets current session duration (uses engagement tracker)
  int getSessionDurationSeconds() {
    return engagementTracker.currentSessionDuration;
  }

  /// Gets current foreground seconds (uses engagement tracker)
  int getForegroundSeconds() {
    return engagementTracker.foregroundSeconds;
  }

  /// Gets current engaged seconds (uses engagement tracker)
  int getEngagedSeconds() {
    return engagementTracker.engagedSeconds;
  }

  /// Gets current engagement rate (uses engagement tracker)
  double getEngagementRate() {
    return engagementTracker.currentEngagementRate;
  }

  /// Set filter session ID
  void setFilterSessionId(String filterSessionId) {
    _currentFilterSessionId = filterSessionId;
    debugPrint('🔍 Filter session set: ${filterSessionId.substring(0, 8)}...');
  }

  /// Clear filter session ID
  void clearFilterSessionId() {
    if (_currentFilterSessionId != null) {
      debugPrint(
          '🔍 Cleared filter session: ${_currentFilterSessionId?.substring(0, 8)}...');
    }
    _currentFilterSessionId = null;
  }
}
