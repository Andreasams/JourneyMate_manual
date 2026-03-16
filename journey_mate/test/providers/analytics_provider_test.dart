import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:journey_mate/providers/app_providers.dart';
import 'package:journey_mate/providers/provider_state_classes.dart';

/// Helper: initialize a menu session on the analytics notifier.
/// Replaces the deleted startMenuSession() for test setup.
void _initMenuSession(ProviderContainer container) {
  final sessionId = const Uuid().v4();
  final notifier = container.read(analyticsProvider.notifier);
  final current = container.read(analyticsProvider);
  // Use copyWith to set menuSessionData directly
  notifier.state = current.copyWith(
    menuSessionData: MenuSessionData.initial(sessionId),
  );
}

/// Helper: clear menu session on the analytics notifier.
/// Replaces the deleted endMenuSession() for test setup.
void _clearMenuSession(ProviderContainer container) {
  final notifier = container.read(analyticsProvider.notifier);
  notifier.state = container.read(analyticsProvider).copyWithNullable(
    clearMenuSession: true,
  );
}

void main() {
  group('AnalyticsProvider - Basic Analytics', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has empty deviceId', () {
      final state = container.read(analyticsProvider);

      expect(state.deviceId, '');
      expect(state.sessionId, null);
      expect(state.sessionStartTime, null);
      expect(state.menuSessionData, null);
    });

    test('initialize() creates and persists deviceId', () async {
      await container.read(analyticsProvider.notifier).initialize();

      final state = container.read(analyticsProvider);
      expect(state.deviceId.isNotEmpty, true);
      expect(state.deviceId.length, 36); // UUID v4 length

      // Verify persisted
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('device_id'), state.deviceId);
    });

    test('initialize() loads existing deviceId', () async {
      SharedPreferences.setMockInitialValues({
        'device_id': 'existing-device-id-123',
      });

      container = ProviderContainer();
      await container.read(analyticsProvider.notifier).initialize();

      final state = container.read(analyticsProvider);
      expect(state.deviceId, 'existing-device-id-123');
    });

    test('startSession() sets sessionId and timestamp', () {
      const testSessionId = 'test-uuid-1234-5678-abcd-efgh';
      container.read(analyticsProvider.notifier).startSession(sessionId: testSessionId);

      final state = container.read(analyticsProvider);
      expect(state.sessionId, testSessionId);
      expect(state.sessionStartTime, isNotNull);
      expect(
        state.sessionStartTime!.difference(DateTime.now()).inSeconds,
        lessThanOrEqualTo(1),
      );
    });

    test('endSession() clears session data and menuSessionData', () async {
      await container.read(analyticsProvider.notifier).initialize();
      container.read(analyticsProvider.notifier).startSession(sessionId: 'test-uuid-abcd-1234-efgh-5678');
      _initMenuSession(container);

      // Verify session and menu session are active
      var state = container.read(analyticsProvider);
      expect(state.sessionId, isNotNull);
      expect(state.menuSessionData, isNotNull);

      // End session
      container.read(analyticsProvider.notifier).endSession();

      state = container.read(analyticsProvider);
      expect(state.sessionId, null);
      expect(state.sessionStartTime, null);
      expect(state.menuSessionData, null); // Menu session also cleared
    });
  });

  group('AnalyticsProvider - MenuSessionData Lifecycle', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('menu session initialization creates MenuSessionData with initial values', () {
      _initMenuSession(container);

      final state = container.read(analyticsProvider);
      final menuData = state.menuSessionData!;

      expect(menuData.menuSessionId.length, 36); // UUID
      expect(menuData.itemClicks, 0);
      expect(menuData.packageClicks, 0);
      expect(menuData.categoriesViewed, isEmpty);
      expect(menuData.deepestScrollPercent, 0);
      expect(menuData.filterInteractions, 0);
      expect(menuData.filterResets, 0);
      expect(menuData.everHadFiltersActive, false);
      expect(menuData.zeroResultCount, 0);
      expect(menuData.lowResultCount, 0);
      expect(menuData.filterResultHistory, isEmpty);
    });

    test('clearing menu session nullifies menuSessionData', () {
      _initMenuSession(container);
      expect(container.read(analyticsProvider).menuSessionData, isNotNull);

      _clearMenuSession(container);
      expect(container.read(analyticsProvider).menuSessionData, null);
    });

    test('incrementItemClick() increases count', () {
      _initMenuSession(container);

      container.read(analyticsProvider.notifier).incrementItemClick();
      container.read(analyticsProvider.notifier).incrementItemClick();
      container.read(analyticsProvider.notifier).incrementItemClick();

      final menuData = container.read(analyticsProvider).menuSessionData!;
      expect(menuData.itemClicks, 3);
    });

    test('incrementPackageClick() increases count', () {
      _initMenuSession(container);

      container.read(analyticsProvider.notifier).incrementPackageClick();
      container.read(analyticsProvider.notifier).incrementPackageClick();

      final menuData = container.read(analyticsProvider).menuSessionData!;
      expect(menuData.packageClicks, 2);
    });

    test('recordCategoryViewed() adds unique categories only', () {
      _initMenuSession(container);

      container.read(analyticsProvider.notifier).recordCategoryViewed(1);
      container.read(analyticsProvider.notifier).recordCategoryViewed(2);
      container.read(analyticsProvider.notifier).recordCategoryViewed(1); // Duplicate
      container.read(analyticsProvider.notifier).recordCategoryViewed(3);

      final menuData = container.read(analyticsProvider).menuSessionData!;
      expect(menuData.categoriesViewed, [1, 2, 3]);
    });

    test('updateDeepestScroll() only updates if higher', () {
      _initMenuSession(container);

      container.read(analyticsProvider.notifier).updateDeepestScroll(25);
      expect(
        container.read(analyticsProvider).menuSessionData!.deepestScrollPercent,
        25,
      );

      container.read(analyticsProvider.notifier).updateDeepestScroll(15); // Lower
      expect(
        container.read(analyticsProvider).menuSessionData!.deepestScrollPercent,
        25, // Unchanged
      );

      container.read(analyticsProvider.notifier).updateDeepestScroll(75); // Higher
      expect(
        container.read(analyticsProvider).menuSessionData!.deepestScrollPercent,
        75,
      );
    });

    test('incrementFilterReset() increases count', () {
      _initMenuSession(container);

      container.read(analyticsProvider.notifier).incrementFilterReset();
      container.read(analyticsProvider.notifier).incrementFilterReset();

      final menuData = container.read(analyticsProvider).menuSessionData!;
      expect(menuData.filterResets, 2);
    });

    test('updateMenuSessionFilterMetrics() tracks interactions', () {
      _initMenuSession(container);

      container.read(analyticsProvider.notifier).updateMenuSessionFilterMetrics(5, true);

      final menuData = container.read(analyticsProvider).menuSessionData!;
      expect(menuData.filterInteractions, 1);
      expect(menuData.filterResultHistory, [5]);
    });

    test('updateMenuSessionFilterMetrics() tracks zero results', () {
      _initMenuSession(container);

      container.read(analyticsProvider.notifier).updateMenuSessionFilterMetrics(0, true);
      container.read(analyticsProvider.notifier).updateMenuSessionFilterMetrics(10, true);
      container.read(analyticsProvider.notifier).updateMenuSessionFilterMetrics(0, true);

      final menuData = container.read(analyticsProvider).menuSessionData!;
      expect(menuData.zeroResultCount, 2);
      expect(menuData.filterInteractions, 3);
    });

    test('updateMenuSessionFilterMetrics() tracks low results (1-2)', () {
      _initMenuSession(container);

      container.read(analyticsProvider.notifier).updateMenuSessionFilterMetrics(1, true);
      container.read(analyticsProvider.notifier).updateMenuSessionFilterMetrics(2, true);
      container.read(analyticsProvider.notifier).updateMenuSessionFilterMetrics(3, true); // Not low
      container.read(analyticsProvider.notifier).updateMenuSessionFilterMetrics(1, true);

      final menuData = container.read(analyticsProvider).menuSessionData!;
      expect(menuData.lowResultCount, 3);
      expect(menuData.filterResultHistory, [1, 2, 3, 1]);
    });

    test('updateMenuSessionFilterMetrics() sets everHadFiltersActive', () {
      _initMenuSession(container);

      expect(
        container.read(analyticsProvider).menuSessionData!.everHadFiltersActive,
        false,
      );

      // Call with no filters active - should remain false
      container.read(analyticsProvider.notifier).updateMenuSessionFilterMetrics(100, false);
      expect(
        container.read(analyticsProvider).menuSessionData!.everHadFiltersActive,
        false,
      );

      // Call with filters active - should become true
      container.read(analyticsProvider.notifier).updateMenuSessionFilterMetrics(5, true);
      expect(
        container.read(analyticsProvider).menuSessionData!.everHadFiltersActive,
        true,
      );

      // Once set to true, should remain true even if filters cleared
      container.read(analyticsProvider.notifier).updateMenuSessionFilterMetrics(100, false);
      expect(
        container.read(analyticsProvider).menuSessionData!.everHadFiltersActive,
        true, // Still true - it's "ever had" not "currently has"
      );
    });

    test('all 11 fields are tracked correctly in a full session', () {
      _initMenuSession(container);

      // Track various events
      container.read(analyticsProvider.notifier).incrementItemClick();
      container.read(analyticsProvider.notifier).incrementItemClick();
      container.read(analyticsProvider.notifier).incrementPackageClick();
      container.read(analyticsProvider.notifier).recordCategoryViewed(10);
      container.read(analyticsProvider.notifier).recordCategoryViewed(20);
      container.read(analyticsProvider.notifier).recordCategoryViewed(10); // Duplicate
      container.read(analyticsProvider.notifier).updateDeepestScroll(45);
      container.read(analyticsProvider.notifier).updateDeepestScroll(80);
      container.read(analyticsProvider.notifier).updateMenuSessionFilterMetrics(0, true);
      container.read(analyticsProvider.notifier).updateMenuSessionFilterMetrics(1, true);
      container.read(analyticsProvider.notifier).updateMenuSessionFilterMetrics(10, true);
      container.read(analyticsProvider.notifier).incrementFilterReset();

      final menuData = container.read(analyticsProvider).menuSessionData!;

      expect(menuData.menuSessionId.isNotEmpty, true);
      expect(menuData.itemClicks, 2);
      expect(menuData.packageClicks, 1);
      expect(menuData.categoriesViewed, [10, 20]);
      expect(menuData.deepestScrollPercent, 80);
      expect(menuData.filterInteractions, 3);
      expect(menuData.filterResets, 1);
      expect(menuData.everHadFiltersActive, true);
      expect(menuData.zeroResultCount, 1);
      expect(menuData.lowResultCount, 1);
      expect(menuData.filterResultHistory, [0, 1, 10]);
    });

    test('methods do nothing when menuSessionData is null', () {
      // Don't start a menu session
      expect(container.read(analyticsProvider).menuSessionData, null);

      // These should not crash
      container.read(analyticsProvider.notifier).incrementItemClick();
      container.read(analyticsProvider.notifier).incrementPackageClick();
      container.read(analyticsProvider.notifier).recordCategoryViewed(5);
      container.read(analyticsProvider.notifier).updateDeepestScroll(50);
      container.read(analyticsProvider.notifier).incrementFilterReset();
      container.read(analyticsProvider.notifier).updateMenuSessionFilterMetrics(10, true);

      // State should still be null
      expect(container.read(analyticsProvider).menuSessionData, null);
    });
  });

  group('AnalyticsProvider - State Immutability', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('copyWith creates new instances', () {
      final state1 = container.read(analyticsProvider);
      final state2 = state1.copyWith(deviceId: 'new-id');

      expect(identical(state1, state2), false);
      expect(state1.deviceId, '');
      expect(state2.deviceId, 'new-id');
    });

    test('MenuSessionData is immutable', () {
      _initMenuSession(container);

      final menuData1 = container.read(analyticsProvider).menuSessionData!;
      container.read(analyticsProvider.notifier).incrementItemClick();
      final menuData2 = container.read(analyticsProvider).menuSessionData!;

      expect(identical(menuData1, menuData2), false);
      expect(menuData1.itemClicks, 0);
      expect(menuData2.itemClicks, 1);
    });
  });
}
