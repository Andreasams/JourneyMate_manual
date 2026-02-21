// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MenuItemsStruct extends BaseStruct {
  MenuItemsStruct({
    String? itemName,
    int? basePrice,
    List<String>? allergyIds,
    int? businessId,
    bool? isBeverage,
    int? menuItemId,
    int? displayOrder,
    String? languageCode,
    String? itemImageUrl,
    List<String>? dietaryTypeIds,
    String? itemDescription,
    List<String>? itemModifierGroups,
  })  : _itemName = itemName,
        _basePrice = basePrice,
        _allergyIds = allergyIds,
        _businessId = businessId,
        _isBeverage = isBeverage,
        _menuItemId = menuItemId,
        _displayOrder = displayOrder,
        _languageCode = languageCode,
        _itemImageUrl = itemImageUrl,
        _dietaryTypeIds = dietaryTypeIds,
        _itemDescription = itemDescription,
        _itemModifierGroups = itemModifierGroups;

  // "item_name" field.
  String? _itemName;
  String get itemName => _itemName ?? '';
  set itemName(String? val) => _itemName = val;

  bool hasItemName() => _itemName != null;

  // "base_price" field.
  int? _basePrice;
  int get basePrice => _basePrice ?? 0;
  set basePrice(int? val) => _basePrice = val;

  void incrementBasePrice(int amount) => basePrice = basePrice + amount;

  bool hasBasePrice() => _basePrice != null;

  // "allergy_ids" field.
  List<String>? _allergyIds;
  List<String> get allergyIds => _allergyIds ?? const [];
  set allergyIds(List<String>? val) => _allergyIds = val;

  void updateAllergyIds(Function(List<String>) updateFn) {
    updateFn(_allergyIds ??= []);
  }

  bool hasAllergyIds() => _allergyIds != null;

  // "business_id" field.
  int? _businessId;
  int get businessId => _businessId ?? 0;
  set businessId(int? val) => _businessId = val;

  void incrementBusinessId(int amount) => businessId = businessId + amount;

  bool hasBusinessId() => _businessId != null;

  // "is_beverage" field.
  bool? _isBeverage;
  bool get isBeverage => _isBeverage ?? false;
  set isBeverage(bool? val) => _isBeverage = val;

  bool hasIsBeverage() => _isBeverage != null;

  // "menu_item_id" field.
  int? _menuItemId;
  int get menuItemId => _menuItemId ?? 0;
  set menuItemId(int? val) => _menuItemId = val;

  void incrementMenuItemId(int amount) => menuItemId = menuItemId + amount;

  bool hasMenuItemId() => _menuItemId != null;

  // "display_order" field.
  int? _displayOrder;
  int get displayOrder => _displayOrder ?? 0;
  set displayOrder(int? val) => _displayOrder = val;

  void incrementDisplayOrder(int amount) =>
      displayOrder = displayOrder + amount;

  bool hasDisplayOrder() => _displayOrder != null;

  // "language_code" field.
  String? _languageCode;
  String get languageCode => _languageCode ?? '';
  set languageCode(String? val) => _languageCode = val;

  bool hasLanguageCode() => _languageCode != null;

  // "item_image_url" field.
  String? _itemImageUrl;
  String get itemImageUrl => _itemImageUrl ?? '';
  set itemImageUrl(String? val) => _itemImageUrl = val;

  bool hasItemImageUrl() => _itemImageUrl != null;

  // "dietary_type_ids" field.
  List<String>? _dietaryTypeIds;
  List<String> get dietaryTypeIds => _dietaryTypeIds ?? const [];
  set dietaryTypeIds(List<String>? val) => _dietaryTypeIds = val;

  void updateDietaryTypeIds(Function(List<String>) updateFn) {
    updateFn(_dietaryTypeIds ??= []);
  }

  bool hasDietaryTypeIds() => _dietaryTypeIds != null;

  // "item_description" field.
  String? _itemDescription;
  String get itemDescription => _itemDescription ?? '';
  set itemDescription(String? val) => _itemDescription = val;

  bool hasItemDescription() => _itemDescription != null;

  // "item_modifier_groups" field.
  List<String>? _itemModifierGroups;
  List<String> get itemModifierGroups => _itemModifierGroups ?? const [];
  set itemModifierGroups(List<String>? val) => _itemModifierGroups = val;

  void updateItemModifierGroups(Function(List<String>) updateFn) {
    updateFn(_itemModifierGroups ??= []);
  }

  bool hasItemModifierGroups() => _itemModifierGroups != null;

  static MenuItemsStruct fromMap(Map<String, dynamic> data) => MenuItemsStruct(
        itemName: data['item_name'] as String?,
        basePrice: castToType<int>(data['base_price']),
        allergyIds: getDataList(data['allergy_ids']),
        businessId: castToType<int>(data['business_id']),
        isBeverage: data['is_beverage'] as bool?,
        menuItemId: castToType<int>(data['menu_item_id']),
        displayOrder: castToType<int>(data['display_order']),
        languageCode: data['language_code'] as String?,
        itemImageUrl: data['item_image_url'] as String?,
        dietaryTypeIds: getDataList(data['dietary_type_ids']),
        itemDescription: data['item_description'] as String?,
        itemModifierGroups: getDataList(data['item_modifier_groups']),
      );

  static MenuItemsStruct? maybeFromMap(dynamic data) => data is Map
      ? MenuItemsStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'item_name': _itemName,
        'base_price': _basePrice,
        'allergy_ids': _allergyIds,
        'business_id': _businessId,
        'is_beverage': _isBeverage,
        'menu_item_id': _menuItemId,
        'display_order': _displayOrder,
        'language_code': _languageCode,
        'item_image_url': _itemImageUrl,
        'dietary_type_ids': _dietaryTypeIds,
        'item_description': _itemDescription,
        'item_modifier_groups': _itemModifierGroups,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'item_name': serializeParam(
          _itemName,
          ParamType.String,
        ),
        'base_price': serializeParam(
          _basePrice,
          ParamType.int,
        ),
        'allergy_ids': serializeParam(
          _allergyIds,
          ParamType.String,
          isList: true,
        ),
        'business_id': serializeParam(
          _businessId,
          ParamType.int,
        ),
        'is_beverage': serializeParam(
          _isBeverage,
          ParamType.bool,
        ),
        'menu_item_id': serializeParam(
          _menuItemId,
          ParamType.int,
        ),
        'display_order': serializeParam(
          _displayOrder,
          ParamType.int,
        ),
        'language_code': serializeParam(
          _languageCode,
          ParamType.String,
        ),
        'item_image_url': serializeParam(
          _itemImageUrl,
          ParamType.String,
        ),
        'dietary_type_ids': serializeParam(
          _dietaryTypeIds,
          ParamType.String,
          isList: true,
        ),
        'item_description': serializeParam(
          _itemDescription,
          ParamType.String,
        ),
        'item_modifier_groups': serializeParam(
          _itemModifierGroups,
          ParamType.String,
          isList: true,
        ),
      }.withoutNulls;

  static MenuItemsStruct fromSerializableMap(Map<String, dynamic> data) =>
      MenuItemsStruct(
        itemName: deserializeParam(
          data['item_name'],
          ParamType.String,
          false,
        ),
        basePrice: deserializeParam(
          data['base_price'],
          ParamType.int,
          false,
        ),
        allergyIds: deserializeParam<String>(
          data['allergy_ids'],
          ParamType.String,
          true,
        ),
        businessId: deserializeParam(
          data['business_id'],
          ParamType.int,
          false,
        ),
        isBeverage: deserializeParam(
          data['is_beverage'],
          ParamType.bool,
          false,
        ),
        menuItemId: deserializeParam(
          data['menu_item_id'],
          ParamType.int,
          false,
        ),
        displayOrder: deserializeParam(
          data['display_order'],
          ParamType.int,
          false,
        ),
        languageCode: deserializeParam(
          data['language_code'],
          ParamType.String,
          false,
        ),
        itemImageUrl: deserializeParam(
          data['item_image_url'],
          ParamType.String,
          false,
        ),
        dietaryTypeIds: deserializeParam<String>(
          data['dietary_type_ids'],
          ParamType.String,
          true,
        ),
        itemDescription: deserializeParam(
          data['item_description'],
          ParamType.String,
          false,
        ),
        itemModifierGroups: deserializeParam<String>(
          data['item_modifier_groups'],
          ParamType.String,
          true,
        ),
      );

  @override
  String toString() => 'MenuItemsStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is MenuItemsStruct &&
        itemName == other.itemName &&
        basePrice == other.basePrice &&
        listEquality.equals(allergyIds, other.allergyIds) &&
        businessId == other.businessId &&
        isBeverage == other.isBeverage &&
        menuItemId == other.menuItemId &&
        displayOrder == other.displayOrder &&
        languageCode == other.languageCode &&
        itemImageUrl == other.itemImageUrl &&
        listEquality.equals(dietaryTypeIds, other.dietaryTypeIds) &&
        itemDescription == other.itemDescription &&
        listEquality.equals(itemModifierGroups, other.itemModifierGroups);
  }

  @override
  int get hashCode => const ListEquality().hash([
        itemName,
        basePrice,
        allergyIds,
        businessId,
        isBeverage,
        menuItemId,
        displayOrder,
        languageCode,
        itemImageUrl,
        dietaryTypeIds,
        itemDescription,
        itemModifierGroups
      ]);
}

MenuItemsStruct createMenuItemsStruct({
  String? itemName,
  int? basePrice,
  int? businessId,
  bool? isBeverage,
  int? menuItemId,
  int? displayOrder,
  String? languageCode,
  String? itemImageUrl,
  String? itemDescription,
}) =>
    MenuItemsStruct(
      itemName: itemName,
      basePrice: basePrice,
      businessId: businessId,
      isBeverage: isBeverage,
      menuItemId: menuItemId,
      displayOrder: displayOrder,
      languageCode: languageCode,
      itemImageUrl: itemImageUrl,
      itemDescription: itemDescription,
    );
