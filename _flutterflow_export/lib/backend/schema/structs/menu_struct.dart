// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MenuStruct extends BaseStruct {
  MenuStruct({
    List<MenuItemsStruct>? menuItems,
    List<CategoriesStruct>? categories,
    List<int>? availablePreferences,
    List<int>? availableAllergies,
  })  : _menuItems = menuItems,
        _categories = categories,
        _availablePreferences = availablePreferences,
        _availableAllergies = availableAllergies;

  // "menu_items" field.
  List<MenuItemsStruct>? _menuItems;
  List<MenuItemsStruct> get menuItems => _menuItems ?? const [];
  set menuItems(List<MenuItemsStruct>? val) => _menuItems = val;

  void updateMenuItems(Function(List<MenuItemsStruct>) updateFn) {
    updateFn(_menuItems ??= []);
  }

  bool hasMenuItems() => _menuItems != null;

  // "categories" field.
  List<CategoriesStruct>? _categories;
  List<CategoriesStruct> get categories => _categories ?? const [];
  set categories(List<CategoriesStruct>? val) => _categories = val;

  void updateCategories(Function(List<CategoriesStruct>) updateFn) {
    updateFn(_categories ??= []);
  }

  bool hasCategories() => _categories != null;

  // "availablePreferences" field.
  List<int>? _availablePreferences;
  List<int> get availablePreferences => _availablePreferences ?? const [];
  set availablePreferences(List<int>? val) => _availablePreferences = val;

  void updateAvailablePreferences(Function(List<int>) updateFn) {
    updateFn(_availablePreferences ??= []);
  }

  bool hasAvailablePreferences() => _availablePreferences != null;

  // "availableAllergies" field.
  List<int>? _availableAllergies;
  List<int> get availableAllergies => _availableAllergies ?? const [];
  set availableAllergies(List<int>? val) => _availableAllergies = val;

  void updateAvailableAllergies(Function(List<int>) updateFn) {
    updateFn(_availableAllergies ??= []);
  }

  bool hasAvailableAllergies() => _availableAllergies != null;

  static MenuStruct fromMap(Map<String, dynamic> data) => MenuStruct(
        menuItems: getStructList(
          data['menu_items'],
          MenuItemsStruct.fromMap,
        ),
        categories: getStructList(
          data['categories'],
          CategoriesStruct.fromMap,
        ),
        availablePreferences: getDataList(data['availablePreferences']),
        availableAllergies: getDataList(data['availableAllergies']),
      );

  static MenuStruct? maybeFromMap(dynamic data) =>
      data is Map ? MenuStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'menu_items': _menuItems?.map((e) => e.toMap()).toList(),
        'categories': _categories?.map((e) => e.toMap()).toList(),
        'availablePreferences': _availablePreferences,
        'availableAllergies': _availableAllergies,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'menu_items': serializeParam(
          _menuItems,
          ParamType.DataStruct,
          isList: true,
        ),
        'categories': serializeParam(
          _categories,
          ParamType.DataStruct,
          isList: true,
        ),
        'availablePreferences': serializeParam(
          _availablePreferences,
          ParamType.int,
          isList: true,
        ),
        'availableAllergies': serializeParam(
          _availableAllergies,
          ParamType.int,
          isList: true,
        ),
      }.withoutNulls;

  static MenuStruct fromSerializableMap(Map<String, dynamic> data) =>
      MenuStruct(
        menuItems: deserializeStructParam<MenuItemsStruct>(
          data['menu_items'],
          ParamType.DataStruct,
          true,
          structBuilder: MenuItemsStruct.fromSerializableMap,
        ),
        categories: deserializeStructParam<CategoriesStruct>(
          data['categories'],
          ParamType.DataStruct,
          true,
          structBuilder: CategoriesStruct.fromSerializableMap,
        ),
        availablePreferences: deserializeParam<int>(
          data['availablePreferences'],
          ParamType.int,
          true,
        ),
        availableAllergies: deserializeParam<int>(
          data['availableAllergies'],
          ParamType.int,
          true,
        ),
      );

  @override
  String toString() => 'MenuStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is MenuStruct &&
        listEquality.equals(menuItems, other.menuItems) &&
        listEquality.equals(categories, other.categories) &&
        listEquality.equals(availablePreferences, other.availablePreferences) &&
        listEquality.equals(availableAllergies, other.availableAllergies);
  }

  @override
  int get hashCode => const ListEquality()
      .hash([menuItems, categories, availablePreferences, availableAllergies]);
}

MenuStruct createMenuStruct() => MenuStruct();
