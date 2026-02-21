import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:journey_mate/providers/app_providers.dart';

void main() {
  group('AccessibilityProvider', () {
    late ProviderContainer container;

    setUp(() {
      // Reset SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has correct defaults', () {
      final state = container.read(accessibilityProvider);

      expect(state.isBoldTextEnabled, false);
      expect(state.fontScale, 1.0);
    });

    test('loadFromPreferences() loads persisted values', () async {
      // Set mock values
      SharedPreferences.setMockInitialValues({
        'is_bold_text_enabled': true,
        'font_scale': 1.5,
      });

      container = ProviderContainer();

      await container.read(accessibilityProvider.notifier).loadFromPreferences();

      final state = container.read(accessibilityProvider);
      expect(state.isBoldTextEnabled, true);
      expect(state.fontScale, 1.5);
    });

    test('loadFromPreferences() uses defaults when keys missing', () async {
      // Empty preferences
      SharedPreferences.setMockInitialValues({});

      container = ProviderContainer();

      await container.read(accessibilityProvider.notifier).loadFromPreferences();

      final state = container.read(accessibilityProvider);
      expect(state.isBoldTextEnabled, false);
      expect(state.fontScale, 1.0);
    });

    test('setBoldText() persists to SharedPreferences AND updates state', () async {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();

      await container.read(accessibilityProvider.notifier).setBoldText(true);

      // Verify state updated
      final state = container.read(accessibilityProvider);
      expect(state.isBoldTextEnabled, true);

      // Verify persisted
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('is_bold_text_enabled'), true);
    });

    test('setFontScale() persists to SharedPreferences AND updates state', () async {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();

      await container.read(accessibilityProvider.notifier).setFontScale(1.8);

      // Verify state updated
      final state = container.read(accessibilityProvider);
      expect(state.fontScale, 1.8);

      // Verify persisted
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('font_scale'), 1.8);
    });

    test('write-then-update pattern: persistence happens before state update', () async {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();

      // Set initial value
      await container.read(accessibilityProvider.notifier).setBoldText(true);

      // Create new container (simulates app restart)
      container.dispose();
      container = ProviderContainer();

      // Load from preferences
      await container.read(accessibilityProvider.notifier).loadFromPreferences();

      // Verify persisted value was loaded
      final state = container.read(accessibilityProvider);
      expect(state.isBoldTextEnabled, true);
    });

    test('multiple updates maintain persistence', () async {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();

      // Multiple updates
      await container.read(accessibilityProvider.notifier).setFontScale(1.2);
      await container.read(accessibilityProvider.notifier).setFontScale(1.5);
      await container.read(accessibilityProvider.notifier).setBoldText(true);
      await container.read(accessibilityProvider.notifier).setFontScale(1.8);

      // Verify final state
      final state = container.read(accessibilityProvider);
      expect(state.fontScale, 1.8);
      expect(state.isBoldTextEnabled, true);

      // Verify persisted
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('font_scale'), 1.8);
      expect(prefs.getBool('is_bold_text_enabled'), true);
    });

    test('state is immutable - copyWith creates new instance', () {
      final state1 = container.read(accessibilityProvider);
      final state2 = state1.copyWith(isBoldTextEnabled: true);

      expect(state1.isBoldTextEnabled, false);
      expect(state2.isBoldTextEnabled, true);
      expect(identical(state1, state2), false);
    });

    test('copyWith preserves unmodified fields', () {
      final state1 = container.read(accessibilityProvider);
      final state2 = state1.copyWith(isBoldTextEnabled: true);

      expect(state2.fontScale, state1.fontScale);
    });
  });
}
