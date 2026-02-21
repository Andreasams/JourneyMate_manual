// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CourseItemMetadataStruct extends BaseStruct {
  CourseItemMetadataStruct({
    bool? isExcluded,
    int? menuItemId,
    int? displayOrder,
    bool? isPremiumItem,
    int? premiumUpcharge,
  })  : _isExcluded = isExcluded,
        _menuItemId = menuItemId,
        _displayOrder = displayOrder,
        _isPremiumItem = isPremiumItem,
        _premiumUpcharge = premiumUpcharge;

  // "is_excluded" field.
  bool? _isExcluded;
  bool get isExcluded => _isExcluded ?? false;
  set isExcluded(bool? val) => _isExcluded = val;

  bool hasIsExcluded() => _isExcluded != null;

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

  // "is_premium_item" field.
  bool? _isPremiumItem;
  bool get isPremiumItem => _isPremiumItem ?? false;
  set isPremiumItem(bool? val) => _isPremiumItem = val;

  bool hasIsPremiumItem() => _isPremiumItem != null;

  // "premium_upcharge" field.
  int? _premiumUpcharge;
  int get premiumUpcharge => _premiumUpcharge ?? 0;
  set premiumUpcharge(int? val) => _premiumUpcharge = val;

  void incrementPremiumUpcharge(int amount) =>
      premiumUpcharge = premiumUpcharge + amount;

  bool hasPremiumUpcharge() => _premiumUpcharge != null;

  static CourseItemMetadataStruct fromMap(Map<String, dynamic> data) =>
      CourseItemMetadataStruct(
        isExcluded: data['is_excluded'] as bool?,
        menuItemId: castToType<int>(data['menu_item_id']),
        displayOrder: castToType<int>(data['display_order']),
        isPremiumItem: data['is_premium_item'] as bool?,
        premiumUpcharge: castToType<int>(data['premium_upcharge']),
      );

  static CourseItemMetadataStruct? maybeFromMap(dynamic data) => data is Map
      ? CourseItemMetadataStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'is_excluded': _isExcluded,
        'menu_item_id': _menuItemId,
        'display_order': _displayOrder,
        'is_premium_item': _isPremiumItem,
        'premium_upcharge': _premiumUpcharge,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'is_excluded': serializeParam(
          _isExcluded,
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
        'is_premium_item': serializeParam(
          _isPremiumItem,
          ParamType.bool,
        ),
        'premium_upcharge': serializeParam(
          _premiumUpcharge,
          ParamType.int,
        ),
      }.withoutNulls;

  static CourseItemMetadataStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      CourseItemMetadataStruct(
        isExcluded: deserializeParam(
          data['is_excluded'],
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
        isPremiumItem: deserializeParam(
          data['is_premium_item'],
          ParamType.bool,
          false,
        ),
        premiumUpcharge: deserializeParam(
          data['premium_upcharge'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'CourseItemMetadataStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is CourseItemMetadataStruct &&
        isExcluded == other.isExcluded &&
        menuItemId == other.menuItemId &&
        displayOrder == other.displayOrder &&
        isPremiumItem == other.isPremiumItem &&
        premiumUpcharge == other.premiumUpcharge;
  }

  @override
  int get hashCode => const ListEquality().hash(
      [isExcluded, menuItemId, displayOrder, isPremiumItem, premiumUpcharge]);
}

CourseItemMetadataStruct createCourseItemMetadataStruct({
  bool? isExcluded,
  int? menuItemId,
  int? displayOrder,
  bool? isPremiumItem,
  int? premiumUpcharge,
}) =>
    CourseItemMetadataStruct(
      isExcluded: isExcluded,
      menuItemId: menuItemId,
      displayOrder: displayOrder,
      isPremiumItem: isPremiumItem,
      premiumUpcharge: premiumUpcharge,
    );
