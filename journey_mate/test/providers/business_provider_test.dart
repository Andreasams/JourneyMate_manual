import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journey_mate/providers/business_providers.dart';

void main() {
  group('BusinessProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is correct', () {
      final state = container.read(businessProvider);

      expect(state.currentBusiness, null);
      expect(state.menuItems, null);
      expect(state.businessFilterIds, isEmpty);
      expect(state.openingHours, null);
      expect(state.availableDietaryPreferences, isEmpty);
      expect(state.availableDietaryRestrictions, isEmpty);
    });

    test('setCurrentBusiness() sets all business data', () {
      final mockBusiness = {'business_id': 123, 'name': 'Test Restaurant'};
      final mockHours = {'monday': '09:00-17:00'};

      container.read(businessProvider.notifier).setCurrentBusiness(
            business: mockBusiness,
            filterIds: [10, 20, 30],
            hours: mockHours,
          );

      final state = container.read(businessProvider);
      expect(state.currentBusiness, mockBusiness);
      expect(state.businessFilterIds, [10, 20, 30]);
      expect(state.openingHours, mockHours);
    });

    test('setMenuItems() updates menu items', () {
      final mockMenu = [
        {'item_id': 1, 'name': 'Pizza'},
        {'item_id': 2, 'name': 'Pasta'},
      ];

      container.read(businessProvider.notifier).setMenuItems(mockMenu);

      final state = container.read(businessProvider);
      expect(state.menuItems, mockMenu);
    });

    test('setDietaryOptions() updates preferences and restrictions', () {
      container.read(businessProvider.notifier).setDietaryOptions(
            preferences: [100, 101, 102],
            restrictions: [200, 201],
          );

      final state = container.read(businessProvider);
      expect(state.availableDietaryPreferences, [100, 101, 102]);
      expect(state.availableDietaryRestrictions, [200, 201]);
    });

    test('updateOpeningHours() updates only opening hours', () {
      final mockBusiness = {'business_id': 123};
      final mockHours1 = {'monday': '09:00-17:00'};
      final mockHours2 = {'monday': '10:00-18:00'};

      container.read(businessProvider.notifier).setCurrentBusiness(
            business: mockBusiness,
            filterIds: [10],
            hours: mockHours1,
          );

      container.read(businessProvider.notifier).updateOpeningHours(mockHours2);

      final state = container.read(businessProvider);
      expect(state.openingHours, mockHours2);
      expect(state.currentBusiness, mockBusiness); // Unchanged
      expect(state.businessFilterIds, [10]); // Unchanged
    });

    test('updateFilterIds() updates only filter IDs', () {
      final mockBusiness = {'business_id': 123};

      container.read(businessProvider.notifier).setCurrentBusiness(
            business: mockBusiness,
            filterIds: [10, 20],
            hours: {},
          );

      container.read(businessProvider.notifier).updateFilterIds([30, 40, 50]);

      final state = container.read(businessProvider);
      expect(state.businessFilterIds, [30, 40, 50]);
      expect(state.currentBusiness, mockBusiness); // Unchanged
    });

    test('clearBusiness() resets all state', () {
      container.read(businessProvider.notifier).setCurrentBusiness(
            business: {'business_id': 123},
            filterIds: [10, 20],
            hours: {'monday': '09:00-17:00'},
          );
      container.read(businessProvider.notifier).setMenuItems([]);
      container.read(businessProvider.notifier).setDietaryOptions(
            preferences: [100],
            restrictions: [200],
          );

      container.read(businessProvider.notifier).clearBusiness();

      final state = container.read(businessProvider);
      expect(state.currentBusiness, null);
      expect(state.menuItems, null);
      expect(state.businessFilterIds, isEmpty);
      expect(state.openingHours, null);
      expect(state.availableDietaryPreferences, isEmpty);
      expect(state.availableDietaryRestrictions, isEmpty);
    });

    test('hasCurrentBusiness() returns correct boolean', () {
      final notifier = container.read(businessProvider.notifier);

      expect(notifier.hasCurrentBusiness(), false);

      notifier.setCurrentBusiness(
        business: {'business_id': 123},
        filterIds: [],
        hours: {},
      );

      expect(notifier.hasCurrentBusiness(), true);

      notifier.clearBusiness();
      expect(notifier.hasCurrentBusiness(), false);
    });

    test('hasMenuItems() returns correct boolean', () {
      final notifier = container.read(businessProvider.notifier);

      expect(notifier.hasMenuItems(), false);

      notifier.setMenuItems([{'item_id': 1}]);
      expect(notifier.hasMenuItems(), true);

      notifier.clearBusiness();
      expect(notifier.hasMenuItems(), false);
    });

    test('getCurrentBusinessId() returns correct ID', () {
      final notifier = container.read(businessProvider.notifier);

      expect(notifier.getCurrentBusinessId(), null);

      notifier.setCurrentBusiness(
        business: {'business_id': 456},
        filterIds: [],
        hours: {},
      );

      expect(notifier.getCurrentBusinessId(), 456);
    });

    test('getCurrentBusinessId() returns null for non-map business', () {
      final notifier = container.read(businessProvider.notifier);

      notifier.setCurrentBusiness(
        business: 'invalid',
        filterIds: [],
        hours: {},
      );

      expect(notifier.getCurrentBusinessId(), null);
    });

    test('full business profile flow', () {
      final notifier = container.read(businessProvider.notifier);

      // Set business
      notifier.setCurrentBusiness(
        business: {'business_id': 789, 'name': 'Pizza Place'},
        filterIds: [10, 20, 30],
        hours: {'monday': '11:00-22:00'},
      );

      // Set menu
      notifier.setMenuItems([
        {'item_id': 1, 'name': 'Margherita'},
        {'item_id': 2, 'name': 'Pepperoni'},
      ]);

      // Set dietary options
      notifier.setDietaryOptions(
        preferences: [100, 101],
        restrictions: [200, 201, 202],
      );

      final state = container.read(businessProvider);
      expect(state.currentBusiness?['business_id'], 789);
      expect(state.menuItems?.length, 2);
      expect(state.businessFilterIds, [10, 20, 30]);
      expect(state.openingHours?['monday'], '11:00-22:00');
      expect(state.availableDietaryPreferences.length, 2);
      expect(state.availableDietaryRestrictions.length, 3);
      expect(notifier.hasCurrentBusiness(), true);
      expect(notifier.hasMenuItems(), true);
      expect(notifier.getCurrentBusinessId(), 789);
    });

    test('partial updates preserve other fields', () {
      final notifier = container.read(businessProvider.notifier);

      notifier.setCurrentBusiness(
        business: {'business_id': 100},
        filterIds: [1, 2],
        hours: {'monday': '09:00-17:00'},
      );
      notifier.setMenuItems([{'item_id': 1}]);

      // Update only hours
      notifier.updateOpeningHours({'monday': '10:00-18:00'});

      var state = container.read(businessProvider);
      expect(state.currentBusiness?['business_id'], 100);
      expect(state.menuItems?.length, 1);
      expect(state.businessFilterIds, [1, 2]);
      expect(state.openingHours?['monday'], '10:00-18:00');

      // Update only filter IDs
      notifier.updateFilterIds([3, 4, 5]);

      state = container.read(businessProvider);
      expect(state.currentBusiness?['business_id'], 100);
      expect(state.menuItems?.length, 1);
      expect(state.businessFilterIds, [3, 4, 5]);
      expect(state.openingHours?['monday'], '10:00-18:00');
    });
  });
}
