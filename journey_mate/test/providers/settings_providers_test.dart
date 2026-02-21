import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:journey_mate/providers/settings_providers.dart';

void main() {
  group('LocalizationProvider', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has DKK and rate 1.0', () {
      final state = container.read(localizationProvider);
      expect(state.currencyCode, 'DKK');
      expect(state.exchangeRate, 1.0);
    });

    test('loadFromPreferences() loads persisted currency', () async {
      SharedPreferences.setMockInitialValues({'user_currency_code': 'USD'});
      container = ProviderContainer();

      await container.read(localizationProvider.notifier).loadFromPreferences();

      final state = container.read(localizationProvider);
      expect(state.currencyCode, 'USD');
    });

    test('setCurrency() persists code and updates both fields', () async {
      await container.read(localizationProvider.notifier).setCurrency('EUR', 7.5);

      final state = container.read(localizationProvider);
      expect(state.currencyCode, 'EUR');
      expect(state.exchangeRate, 7.5);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_currency_code'), 'EUR');
    });

    test('setExchangeRate() updates rate only (not persisted)', () async {
      await container.read(localizationProvider.notifier).setCurrency('EUR', 7.5);
      container.read(localizationProvider.notifier).setExchangeRate(8.0);

      final state = container.read(localizationProvider);
      expect(state.exchangeRate, 8.0);
      expect(state.currencyCode, 'EUR');

      // Verify rate not persisted
      container.dispose();
      container = ProviderContainer();
      await container.read(localizationProvider.notifier).loadFromPreferences();
      final newState = container.read(localizationProvider);
      expect(newState.exchangeRate, 1.0); // Default, not 8.0
    });

    test('resetToDefault() sets DKK with rate 1.0', () async {
      await container.read(localizationProvider.notifier).setCurrency('USD', 6.8);
      await container.read(localizationProvider.notifier).resetToDefault();

      final state = container.read(localizationProvider);
      expect(state.currencyCode, 'DKK');
      expect(state.exchangeRate, 1.0);
    });
  });

  group('LocationProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has no permission', () {
      final state = container.read(locationProvider);
      expect(state.hasPermission, false);
    });

    test('setPermission() updates state', () {
      container.read(locationProvider.notifier).setPermission(true);

      final state = container.read(locationProvider);
      expect(state.hasPermission, true);
    });

    // Note: checkPermission() and requestPermission() require mocking geolocator
    // and permission_handler which is beyond the scope of unit tests.
    // These should be tested in integration tests with actual permission handling.
  });
}
