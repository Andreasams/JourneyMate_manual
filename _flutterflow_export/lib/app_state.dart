import 'package:flutter/material.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/api_requests/api_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:csv/csv.dart';
import 'package:synchronized/synchronized.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'dart:convert';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    secureStorage = FlutterSecureStorage();
    await _safeInitAsync(() async {
      _CityID = await secureStorage.getInt('ff_CityID') ?? _CityID;
    });
    await _safeInitAsync(() async {
      if (await secureStorage.read(key: 'ff_translationsCache') != null) {
        try {
          _translationsCache = jsonDecode(
              await secureStorage.getString('ff_translationsCache') ?? '');
        } catch (e) {
          print("Can't decode persisted json. Error: $e.");
        }
      }
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late FlutterSecureStorage secureStorage;

  int _CityID = 17;
  int get CityID => _CityID;
  set CityID(int value) {
    _CityID = value;
    secureStorage.setInt('ff_CityID', value);
  }

  void deleteCityID() {
    secureStorage.delete(key: 'ff_CityID');
  }

  bool _CityPickerIsOpen = false;
  bool get CityPickerIsOpen => _CityPickerIsOpen;
  set CityPickerIsOpen(bool value) {
    _CityPickerIsOpen = value;
  }

  bool _BusinessIsOpen = true;
  bool get BusinessIsOpen => _BusinessIsOpen;
  set BusinessIsOpen(bool value) {
    _BusinessIsOpen = value;
  }

  bool _restaurantIsFavorited = false;
  bool get restaurantIsFavorited => _restaurantIsFavorited;
  set restaurantIsFavorited(bool value) {
    _restaurantIsFavorited = value;
  }

  bool _isClosed = false;
  bool get isClosed => _isClosed;
  set isClosed(bool value) {
    _isClosed = value;
  }

  int _BusinessFeatureButtonsCount = 0;
  int get BusinessFeatureButtonsCount => _BusinessFeatureButtonsCount;
  set BusinessFeatureButtonsCount(int value) {
    _BusinessFeatureButtonsCount = value;
  }

  List<int> _filtersUsedForSearch = [];
  List<int> get filtersUsedForSearch => _filtersUsedForSearch;
  set filtersUsedForSearch(List<int> value) {
    _filtersUsedForSearch = value;
  }

  void addToFiltersUsedForSearch(int value) {
    filtersUsedForSearch.add(value);
  }

  void removeFromFiltersUsedForSearch(int value) {
    filtersUsedForSearch.remove(value);
  }

  void removeAtIndexFromFiltersUsedForSearch(int index) {
    filtersUsedForSearch.removeAt(index);
  }

  void updateFiltersUsedForSearchAtIndex(
    int index,
    int Function(int) updateFn,
  ) {
    filtersUsedForSearch[index] = updateFn(_filtersUsedForSearch[index]);
  }

  void insertAtIndexInFiltersUsedForSearch(int index, int value) {
    filtersUsedForSearch.insert(index, value);
  }

  List<int> _filtersOfSelectedBusiness = [];
  List<int> get filtersOfSelectedBusiness => _filtersOfSelectedBusiness;
  set filtersOfSelectedBusiness(List<int> value) {
    _filtersOfSelectedBusiness = value;
  }

  void addToFiltersOfSelectedBusiness(int value) {
    filtersOfSelectedBusiness.add(value);
  }

  void removeFromFiltersOfSelectedBusiness(int value) {
    filtersOfSelectedBusiness.remove(value);
  }

  void removeAtIndexFromFiltersOfSelectedBusiness(int index) {
    filtersOfSelectedBusiness.removeAt(index);
  }

  void updateFiltersOfSelectedBusinessAtIndex(
    int index,
    int Function(int) updateFn,
  ) {
    filtersOfSelectedBusiness[index] =
        updateFn(_filtersOfSelectedBusiness[index]);
  }

  void insertAtIndexInFiltersOfSelectedBusiness(int index, int value) {
    filtersOfSelectedBusiness.insert(index, value);
  }

  dynamic _openingHours;
  dynamic get openingHours => _openingHours;
  set openingHours(dynamic value) {
    _openingHours = value;
  }

  /// Used to display search results using $.documents
  dynamic _searchResults;
  dynamic get searchResults => _searchResults;
  set searchResults(dynamic value) {
    _searchResults = value;
  }

  dynamic _mostRecentlyViewedBusiness;
  dynamic get mostRecentlyViewedBusiness => _mostRecentlyViewedBusiness;
  set mostRecentlyViewedBusiness(dynamic value) {
    _mostRecentlyViewedBusiness = value;
  }

  dynamic _mostRecentlyViewedBusinesMenuItems;
  dynamic get mostRecentlyViewedBusinesMenuItems =>
      _mostRecentlyViewedBusinesMenuItems;
  set mostRecentlyViewedBusinesMenuItems(dynamic value) {
    _mostRecentlyViewedBusinesMenuItems = value;
  }

  int _mostRecentlyViewedBusinessSelectedCategoryID = 0;
  int get mostRecentlyViewedBusinessSelectedCategoryID =>
      _mostRecentlyViewedBusinessSelectedCategoryID;
  set mostRecentlyViewedBusinessSelectedCategoryID(int value) {
    _mostRecentlyViewedBusinessSelectedCategoryID = value;
  }

  int _mostRecentlyViewedBusinessSelectedMenuID = 0;
  int get mostRecentlyViewedBusinessSelectedMenuID =>
      _mostRecentlyViewedBusinessSelectedMenuID;
  set mostRecentlyViewedBusinessSelectedMenuID(int value) {
    _mostRecentlyViewedBusinessSelectedMenuID = value;
  }

  List<int> _mostRecentlyViewedBusinessAvailableDietaryPreferences = [];
  List<int> get mostRecentlyViewedBusinessAvailableDietaryPreferences =>
      _mostRecentlyViewedBusinessAvailableDietaryPreferences;
  set mostRecentlyViewedBusinessAvailableDietaryPreferences(List<int> value) {
    _mostRecentlyViewedBusinessAvailableDietaryPreferences = value;
  }

  void addToMostRecentlyViewedBusinessAvailableDietaryPreferences(int value) {
    mostRecentlyViewedBusinessAvailableDietaryPreferences.add(value);
  }

  void removeFromMostRecentlyViewedBusinessAvailableDietaryPreferences(
      int value) {
    mostRecentlyViewedBusinessAvailableDietaryPreferences.remove(value);
  }

  void removeAtIndexFromMostRecentlyViewedBusinessAvailableDietaryPreferences(
      int index) {
    mostRecentlyViewedBusinessAvailableDietaryPreferences.removeAt(index);
  }

  void updateMostRecentlyViewedBusinessAvailableDietaryPreferencesAtIndex(
    int index,
    int Function(int) updateFn,
  ) {
    mostRecentlyViewedBusinessAvailableDietaryPreferences[index] =
        updateFn(_mostRecentlyViewedBusinessAvailableDietaryPreferences[index]);
  }

  void insertAtIndexInMostRecentlyViewedBusinessAvailableDietaryPreferences(
      int index, int value) {
    mostRecentlyViewedBusinessAvailableDietaryPreferences.insert(index, value);
  }

  String _userCurrencyCode = '';
  String get userCurrencyCode => _userCurrencyCode;
  set userCurrencyCode(String value) {
    _userCurrencyCode = value;
  }

  double _exchangeRate = 0.0;
  double get exchangeRate => _exchangeRate;
  set exchangeRate(double value) {
    _exchangeRate = value;
  }

  bool _locationStatus = false;
  bool get locationStatus => _locationStatus;
  set locationStatus(bool value) {
    _locationStatus = value;
  }

  dynamic _translationsCache;
  dynamic get translationsCache => _translationsCache;
  set translationsCache(dynamic value) {
    _translationsCache = value;
    secureStorage.setString('ff_translationsCache', jsonEncode(value));
  }

  void deleteTranslationsCache() {
    secureStorage.delete(key: 'ff_translationsCache');
  }

  dynamic _filtersForUserLanguage;
  dynamic get filtersForUserLanguage => _filtersForUserLanguage;
  set filtersForUserLanguage(dynamic value) {
    _filtersForUserLanguage = value;
  }

  String _currentFilterSessionId = '';
  String get currentFilterSessionId => _currentFilterSessionId;
  set currentFilterSessionId(String value) {
    _currentFilterSessionId = value;
  }

  int _searchResultsCount = 0;
  int get searchResultsCount => _searchResultsCount;
  set searchResultsCount(int value) {
    _searchResultsCount = value;
  }

  bool _hasActiveSearch = false;
  bool get hasActiveSearch => _hasActiveSearch;
  set hasActiveSearch(bool value) {
    _hasActiveSearch = value;
  }

  List<int> _previousActiveFilters = [];
  List<int> get previousActiveFilters => _previousActiveFilters;
  set previousActiveFilters(List<int> value) {
    _previousActiveFilters = value;
  }

  void addToPreviousActiveFilters(int value) {
    previousActiveFilters.add(value);
  }

  void removeFromPreviousActiveFilters(int value) {
    previousActiveFilters.remove(value);
  }

  void removeAtIndexFromPreviousActiveFilters(int index) {
    previousActiveFilters.removeAt(index);
  }

  void updatePreviousActiveFiltersAtIndex(
    int index,
    int Function(int) updateFn,
  ) {
    previousActiveFilters[index] = updateFn(_previousActiveFilters[index]);
  }

  void insertAtIndexInPreviousActiveFilters(int index, int value) {
    previousActiveFilters.insert(index, value);
  }

  String _previousSearchText = '';
  String get previousSearchText => _previousSearchText;
  set previousSearchText(String value) {
    _previousSearchText = value;
  }

  int _currentRefinementSequence = 0;
  int get currentRefinementSequence => _currentRefinementSequence;
  set currentRefinementSequence(int value) {
    _currentRefinementSequence = value;
  }

  DateTime? _lastRefinementTime;
  DateTime? get lastRefinementTime => _lastRefinementTime;
  set lastRefinementTime(DateTime? value) {
    _lastRefinementTime = value;
  }

  String _currentSearchText = '';
  String get currentSearchText => _currentSearchText;
  set currentSearchText(String value) {
    _currentSearchText = value;
  }

  String _previousFilterSessionId = '';
  String get previousFilterSessionId => _previousFilterSessionId;
  set previousFilterSessionId(String value) {
    _previousFilterSessionId = value;
  }

  dynamic _filterLookupMap;
  dynamic get filterLookupMap => _filterLookupMap;
  set filterLookupMap(dynamic value) {
    _filterLookupMap = value;
  }

  DateTime? _sessionStartTime;
  DateTime? get sessionStartTime => _sessionStartTime;
  set sessionStartTime(DateTime? value) {
    _sessionStartTime = value;
  }

  dynamic _menuSessionData;
  dynamic get menuSessionData => _menuSessionData;
  set menuSessionData(dynamic value) {
    _menuSessionData = value;
  }

  List<int> _mostRecentlyViewedBusinessAvailableDietaryRestrictions = [];
  List<int> get mostRecentlyViewedBusinessAvailableDietaryRestrictions =>
      _mostRecentlyViewedBusinessAvailableDietaryRestrictions;
  set mostRecentlyViewedBusinessAvailableDietaryRestrictions(List<int> value) {
    _mostRecentlyViewedBusinessAvailableDietaryRestrictions = value;
  }

  void addToMostRecentlyViewedBusinessAvailableDietaryRestrictions(int value) {
    mostRecentlyViewedBusinessAvailableDietaryRestrictions.add(value);
  }

  void removeFromMostRecentlyViewedBusinessAvailableDietaryRestrictions(
      int value) {
    mostRecentlyViewedBusinessAvailableDietaryRestrictions.remove(value);
  }

  void removeAtIndexFromMostRecentlyViewedBusinessAvailableDietaryRestrictions(
      int index) {
    mostRecentlyViewedBusinessAvailableDietaryRestrictions.removeAt(index);
  }

  void updateMostRecentlyViewedBusinessAvailableDietaryRestrictionsAtIndex(
    int index,
    int Function(int) updateFn,
  ) {
    mostRecentlyViewedBusinessAvailableDietaryRestrictions[index] = updateFn(
        _mostRecentlyViewedBusinessAvailableDietaryRestrictions[index]);
  }

  void insertAtIndexInMostRecentlyViewedBusinessAvailableDietaryRestrictions(
      int index, int value) {
    mostRecentlyViewedBusinessAvailableDietaryRestrictions.insert(index, value);
  }

  int _selectedDietaryPreferenceId = 0;
  int get selectedDietaryPreferenceId => _selectedDietaryPreferenceId;
  set selectedDietaryPreferenceId(int value) {
    _selectedDietaryPreferenceId = value;
  }

  List<int> _excludedAllergyIds = [];
  List<int> get excludedAllergyIds => _excludedAllergyIds;
  set excludedAllergyIds(List<int> value) {
    _excludedAllergyIds = value;
  }

  void addToExcludedAllergyIds(int value) {
    excludedAllergyIds.add(value);
  }

  void removeFromExcludedAllergyIds(int value) {
    excludedAllergyIds.remove(value);
  }

  void removeAtIndexFromExcludedAllergyIds(int index) {
    excludedAllergyIds.removeAt(index);
  }

  void updateExcludedAllergyIdsAtIndex(
    int index,
    int Function(int) updateFn,
  ) {
    excludedAllergyIds[index] = updateFn(_excludedAllergyIds[index]);
  }

  void insertAtIndexInExcludedAllergyIds(int index, int value) {
    excludedAllergyIds.insert(index, value);
  }

  List<int> _selectedDietaryRestrictionId = [];
  List<int> get selectedDietaryRestrictionId => _selectedDietaryRestrictionId;
  set selectedDietaryRestrictionId(List<int> value) {
    _selectedDietaryRestrictionId = value;
  }

  void addToSelectedDietaryRestrictionId(int value) {
    selectedDietaryRestrictionId.add(value);
  }

  void removeFromSelectedDietaryRestrictionId(int value) {
    selectedDietaryRestrictionId.remove(value);
  }

  void removeAtIndexFromSelectedDietaryRestrictionId(int index) {
    selectedDietaryRestrictionId.removeAt(index);
  }

  void updateSelectedDietaryRestrictionIdAtIndex(
    int index,
    int Function(int) updateFn,
  ) {
    selectedDietaryRestrictionId[index] =
        updateFn(_selectedDietaryRestrictionId[index]);
  }

  void insertAtIndexInSelectedDietaryRestrictionId(int index, int value) {
    selectedDietaryRestrictionId.insert(index, value);
  }

  bool _filterOverlayOpen = false;
  bool get filterOverlayOpen => _filterOverlayOpen;
  set filterOverlayOpen(bool value) {
    _filterOverlayOpen = value;
  }

  LatLng? _emptyLocation = LatLng(0, 0);
  LatLng? get emptyLocation => _emptyLocation;
  set emptyLocation(LatLng? value) {
    _emptyLocation = value;
  }

  /// Greater than 1.1: true
  bool _fontScale = false;
  bool get fontScale => _fontScale;
  set fontScale(bool value) {
    _fontScale = value;
  }

  bool _isBoldTextEnabled = false;
  bool get isBoldTextEnabled => _isBoldTextEnabled;
  set isBoldTextEnabled(bool value) {
    _isBoldTextEnabled = value;
  }

  int _activeSelectedTitleId = 0;
  int get activeSelectedTitleId => _activeSelectedTitleId;
  set activeSelectedTitleId(int value) {
    _activeSelectedTitleId = value;
  }

  List<dynamic> _foodDrinkTypes = [];
  List<dynamic> get foodDrinkTypes => _foodDrinkTypes;
  set foodDrinkTypes(List<dynamic> value) {
    _foodDrinkTypes = value;
  }

  void addToFoodDrinkTypes(dynamic value) {
    foodDrinkTypes.add(value);
  }

  void removeFromFoodDrinkTypes(dynamic value) {
    foodDrinkTypes.remove(value);
  }

  void removeAtIndexFromFoodDrinkTypes(int index) {
    foodDrinkTypes.removeAt(index);
  }

  void updateFoodDrinkTypesAtIndex(
    int index,
    dynamic Function(dynamic) updateFn,
  ) {
    foodDrinkTypes[index] = updateFn(_foodDrinkTypes[index]);
  }

  void insertAtIndexInFoodDrinkTypes(int index, dynamic value) {
    foodDrinkTypes.insert(index, value);
  }

  int _visibleItemCount = 0;
  int get visibleItemCount => _visibleItemCount;
  set visibleItemCount(int value) {
    _visibleItemCount = value;
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}

extension FlutterSecureStorageExtensions on FlutterSecureStorage {
  static final _lock = Lock();

  Future<void> writeSync({required String key, String? value}) async =>
      await _lock.synchronized(() async {
        await write(key: key, value: value);
      });

  void remove(String key) => delete(key: key);

  Future<String?> getString(String key) async => await read(key: key);
  Future<void> setString(String key, String value) async =>
      await writeSync(key: key, value: value);

  Future<bool?> getBool(String key) async => (await read(key: key)) == 'true';
  Future<void> setBool(String key, bool value) async =>
      await writeSync(key: key, value: value.toString());

  Future<int?> getInt(String key) async =>
      int.tryParse(await read(key: key) ?? '');
  Future<void> setInt(String key, int value) async =>
      await writeSync(key: key, value: value.toString());

  Future<double?> getDouble(String key) async =>
      double.tryParse(await read(key: key) ?? '');
  Future<void> setDouble(String key, double value) async =>
      await writeSync(key: key, value: value.toString());

  Future<List<String>?> getStringList(String key) async =>
      await read(key: key).then((result) {
        if (result == null || result.isEmpty) {
          return null;
        }
        return CsvToListConverter()
            .convert(result)
            .first
            .map((e) => e.toString())
            .toList();
      });
  Future<void> setStringList(String key, List<String> value) async =>
      await writeSync(key: key, value: ListToCsvConverter().convert([value]));
}
