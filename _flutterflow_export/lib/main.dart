import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'auth/supabase_auth/supabase_user_provider.dart';
import 'auth/supabase_auth/auth_util.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
import 'flutter_flow/nav/nav.dart';
import 'index.dart';

// main.dart

import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'auth/supabase_auth/supabase_user_provider.dart';
import 'auth/supabase_auth/auth_util.dart';
import 'custom_code/actions/track_analytics_event.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
import 'flutter_flow/nav/nav.dart';
import 'index.dart';
import 'package:flutter/foundation.dart';
import '/custom_code/actions/index.dart';
import '/custom_code/actions/check_location_permission.dart';

// ---------------------------------------------------------------------------
// MAIN ENTRY POINT
// ---------------------------------------------------------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  await SupaFlow.initialize();
  await FFLocalizations.initialize();

  // Initialize analytics BEFORE building app
  await AnalyticsService.instance.initialize();

  final appState = FFAppState();
  await appState.initializePersistedState();

  final appObserver = AppLifecycleObserver(appState);
  WidgetsBinding.instance.addObserver(appObserver);

  runApp(ChangeNotifierProvider(
    create: (context) => appState,
    child: ActivityScope(
      child: MyApp(),
    ),
  ));
}

// ---------------------------------------------------------------------------
// ENGAGEMENT TRACKER
// ---------------------------------------------------------------------------
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
    debugPrint('🌙 EngagementTracker: App detached');
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
  /// This allows custom actions/widgets to trigger engagement
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
  /// Called by heartbeat to detect activity marked by custom actions
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

    // Store in FFAppState for access in custom actions
    FFAppState().update(() {
      FFAppState().sessionStartTime = sessionStartTime;
    });

    // Track session start
    await trackAnalyticsEvent('session_start', {
      'sessionId': sessionId,
      'timestamp': now.toIso8601String(),
    });

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

    // Track session end with comprehensive metrics
    await trackAnalyticsEvent('session_end', {
      'sessionId': sessionId,
      'sessionDuration': sessionDuration,
      'foregroundSeconds': foregroundSeconds,
      'engagedSeconds': engagedSeconds,
      'engagementRate': engagementRate,
      'endReason': reason,
      'timestamp': now.toIso8601String(),
    });

    debugPrint('🏁 Engagement session ended:');
    debugPrint('   Session: ${sessionId?.substring(0, 8)}');
    debugPrint('   Duration: ${sessionDuration}s');
    debugPrint('   Foreground: ${foregroundSeconds}s');
    debugPrint('   Engaged: ${engagedSeconds}s');
    debugPrint('   Rate: ${(engagementRate * 100).toStringAsFixed(1)}%');
    debugPrint('   Reason: $reason');

    // Clear session data from FFAppState
    FFAppState().update(() {
      FFAppState().sessionStartTime = null;
    });

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

    // Track partial session update
    await trackAnalyticsEvent('session_heartbeat', {
      'sessionId': sessionId,
      'foregroundSeconds': foregroundSeconds,
      'engagedSeconds': engagedSeconds,
      'engagementRate': engagementRate,
      'timestamp': now.toIso8601String(),
    });

    _lastFlushTime = now;
    debugPrint(
        '💾 Flushed partial session: ${foregroundSeconds}s fg, ${engagedSeconds}s engaged');
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

// Global singleton instance
final engagementTracker = EngagementTracker();

// ---------------------------------------------------------------------------
// ANALYTICS SERVICE
// ---------------------------------------------------------------------------
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  static AnalyticsService get instance => _instance;
  AnalyticsService._internal();

  String? _deviceId;
  String? _userId;
  String? _currentFilterSessionId;
  bool _isFirstSession = false;

  String? get deviceId => _deviceId;
  String? get userId => _userId;

  /// Gets current session ID from engagement tracker
  /// This always returns the current, active session ID
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
    final existing = await getUserPreference('analytics_device_id');
    if (existing.isNotEmpty) {
      debugPrint('📱 Existing device_id: ${existing.substring(0, 8)}...');
      return existing;
    }
    final newId = const Uuid().v4();
    await saveUserPreference('analytics_device_id', newId);
    debugPrint('📱 Created new device_id: ${newId.substring(0, 8)}...');
    return newId;
  }

  Future<bool> _detectFirstSession() async {
    final launchedFlag = await getUserPreference('has_launched_before');
    if (launchedFlag == 'true') return false;
    await saveUserPreference('has_launched_before', 'true');
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

  // Filter session management (unchanged)
  void setFilterSessionId(String filterSessionId) {
    _currentFilterSessionId = filterSessionId;
    debugPrint('🔍 Filter session set: ${filterSessionId.substring(0, 8)}...');
  }

  void clearFilterSessionId() {
    if (_currentFilterSessionId != null) {
      debugPrint(
          '🔍 Cleared filter session: ${_currentFilterSessionId?.substring(0, 8)}...');
    }
    _currentFilterSessionId = null;
  }
}

// ---------------------------------------------------------------------------
// APP LIFECYCLE OBSERVER
// ---------------------------------------------------------------------------
class AppLifecycleObserver extends WidgetsBindingObserver {
  final FFAppState appState;

  AppLifecycleObserver(this.appState);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      debugPrint('🌅 App resumed');

      // Use the WORKING geolocator-based check
      await checkLocationPermission('app_resume');

      await engagementTracker.onAppResumed();
    } else if (state == AppLifecycleState.paused) {
      debugPrint('⏸️ App paused');
      await engagementTracker.onAppPaused();
    } else if (state == AppLifecycleState.detached) {
      debugPrint('🌙 App closed');
      await engagementTracker.onAppDetached();
    }
  }
}

// ---------------------------------------------------------------------------
// ACTIVITY DETECTION WIDGET
// ---------------------------------------------------------------------------
/// Wraps your app to detect user interactions and accessibility settings.
///
/// Responsibilities:
/// - Captures all user activity (tap/scroll/keyboard/navigation)
/// - Detects system bold text setting on startup
/// - Listens for accessibility setting changes while app is running
///
/// Stores in FFAppState:
/// - isBoldTextEnabled: Whether system bold text is enabled
class ActivityScope extends StatefulWidget {
  final Widget child;

  const ActivityScope({
    super.key,
    required this.child,
  });

  @override
  State<ActivityScope> createState() => _ActivityScopeState();
}

class _ActivityScopeState extends State<ActivityScope>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _detectAccessibilitySettings();
  }

  @override
  void didChangeAccessibilityFeatures() {
    // Called when user changes accessibility settings while app is running
    _detectAccessibilitySettings();
    debugPrint('♿ Accessibility settings changed - re-detected');
  }

  /// Detects system accessibility settings and stores in FFAppState
  void _detectAccessibilitySettings() {
    final mediaQuery = MediaQuery.of(context);

    final isBoldTextEnabled = mediaQuery.boldText;
    final fontScale = mediaQuery.textScaler.scale(1.0);
    final hasFontScaleEnabled = fontScale > 1.1;

    FFAppState().update(() {
      FFAppState().isBoldTextEnabled = isBoldTextEnabled;
      FFAppState().fontScale = hasFontScaleEnabled;
    });

    debugPrint('♿ Accessibility detected:');
    debugPrint('   Bold text: $isBoldTextEnabled');
    debugPrint(
        '   Font scale: ${fontScale.toStringAsFixed(2)} (enabled: $hasFontScaleEnabled)');
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      // Captures all pointer events (tap, drag, scroll)
      onPointerDown: (_) => engagementTracker.markUserActive(),
      onPointerMove: (_) => engagementTracker.markUserActive(),
      onPointerUp: (_) => engagementTracker.markUserActive(),
      child: NotificationListener<ScrollNotification>(
        // Captures scroll events
        onNotification: (notification) {
          engagementTracker.markUserActive();
          return false;
        },
        child: Focus(
          // Captures keyboard events
          onKeyEvent: (node, event) {
            engagementTracker.markUserActive();
            return KeyEventResult.ignored;
          },
          child: widget.child,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// NAVIGATION OBSERVER
// ---------------------------------------------------------------------------
/// Navigation observer that marks user active on route changes
///
/// Add to your MaterialApp's navigatorObservers:
/// ```dart
/// MaterialApp(
///   navigatorObservers: [ActivityNavigatorObserver()],
///   ...
/// )
/// ```
class ActivityNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    engagementTracker.markUserActive();
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    engagementTracker.markUserActive();
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    engagementTracker.markUserActive();
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class MyAppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class _MyAppState extends State<MyApp> {
  Locale? _locale = FFLocalizations.getStoredLocale();

  ThemeMode _themeMode = ThemeMode.system;
  double _textScaleFactor = 1.0;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();
  late Stream<BaseAuthUser> userStream;

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    userStream = journeyMateSupabaseUserStream()
      ..listen((user) {
        _appStateNotifier.update(user);
      });
    jwtTokenStream.listen((_) {});
    Future.delayed(
      Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  void setLocale(String language) {
    safeSetState(() => _locale = createLocale(language));
    FFLocalizations.storeLocale(language);
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
      });

  void setTextScaleFactor(double updatedFactor) {
    if (updatedFactor < FlutterFlowTheme.minTextScaleFactor ||
        updatedFactor > FlutterFlowTheme.maxTextScaleFactor) {
      return;
    }
    safeSetState(() {
      _textScaleFactor = updatedFactor;
    });
  }

  void incrementTextScaleFactor(double incrementValue) {
    final updatedFactor = _textScaleFactor + incrementValue;
    if (updatedFactor < FlutterFlowTheme.minTextScaleFactor ||
        updatedFactor > FlutterFlowTheme.maxTextScaleFactor) {
      return;
    }
    safeSetState(() {
      _textScaleFactor = updatedFactor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'JourneyMate',
      scrollBehavior: MyAppScrollBehavior(),
      localizationsDelegates: [
        FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackMaterialLocalizationDelegate(),
        FallbackCupertinoLocalizationDelegate(),
      ],
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('da'),
        Locale('de'),
        Locale('it'),
        Locale('sv'),
        Locale('no'),
        Locale('fr'),
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        scrollbarTheme: ScrollbarThemeData(),
      ),
      themeMode: _themeMode,
      routerConfig: _router,
      builder: (_, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler:
              _textScaleFactor == FlutterFlowTheme.defaultTextScaleFactor
                  ? MediaQuery.of(context).textScaler.clamp(
                        minScaleFactor: FlutterFlowTheme.minTextScaleFactor,
                        maxScaleFactor: FlutterFlowTheme.maxTextScaleFactor,
                      )
                  : TextScaler.linear(_textScaleFactor).clamp(
                      minScaleFactor: FlutterFlowTheme.minTextScaleFactor,
                      maxScaleFactor: FlutterFlowTheme.maxTextScaleFactor,
                    ),
        ),
        child: child!,
      ),
    );
  }
}
