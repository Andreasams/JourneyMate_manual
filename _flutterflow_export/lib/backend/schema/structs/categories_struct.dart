// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CategoriesStruct extends BaseStruct {
  CategoriesStruct({
    List<CoursesStruct>? courses,
    bool? isCombo,
    int? packageId,
    int? categoryId,
    String? packageName,
    String? categoryType,
    int? displayOrder,
    String? languageCode,
    bool? isSharingMenu,
    bool? isTastingMenu,
    bool? isFixedPriceMenu,
    String? packageDescription,
  })  : _courses = courses,
        _isCombo = isCombo,
        _packageId = packageId,
        _categoryId = categoryId,
        _packageName = packageName,
        _categoryType = categoryType,
        _displayOrder = displayOrder,
        _languageCode = languageCode,
        _isSharingMenu = isSharingMenu,
        _isTastingMenu = isTastingMenu,
        _isFixedPriceMenu = isFixedPriceMenu,
        _packageDescription = packageDescription;

  // "courses" field.
  List<CoursesStruct>? _courses;
  List<CoursesStruct> get courses => _courses ?? const [];
  set courses(List<CoursesStruct>? val) => _courses = val;

  void updateCourses(Function(List<CoursesStruct>) updateFn) {
    updateFn(_courses ??= []);
  }

  bool hasCourses() => _courses != null;

  // "is_combo" field.
  bool? _isCombo;
  bool get isCombo => _isCombo ?? false;
  set isCombo(bool? val) => _isCombo = val;

  bool hasIsCombo() => _isCombo != null;

  // "package_id" field.
  int? _packageId;
  int get packageId => _packageId ?? 0;
  set packageId(int? val) => _packageId = val;

  void incrementPackageId(int amount) => packageId = packageId + amount;

  bool hasPackageId() => _packageId != null;

  // "category_id" field.
  int? _categoryId;
  int get categoryId => _categoryId ?? 0;
  set categoryId(int? val) => _categoryId = val;

  void incrementCategoryId(int amount) => categoryId = categoryId + amount;

  bool hasCategoryId() => _categoryId != null;

  // "package_name" field.
  String? _packageName;
  String get packageName => _packageName ?? '';
  set packageName(String? val) => _packageName = val;

  bool hasPackageName() => _packageName != null;

  // "category_type" field.
  String? _categoryType;
  String get categoryType => _categoryType ?? '';
  set categoryType(String? val) => _categoryType = val;

  bool hasCategoryType() => _categoryType != null;

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

  // "is_sharing_menu" field.
  bool? _isSharingMenu;
  bool get isSharingMenu => _isSharingMenu ?? false;
  set isSharingMenu(bool? val) => _isSharingMenu = val;

  bool hasIsSharingMenu() => _isSharingMenu != null;

  // "is_tasting_menu" field.
  bool? _isTastingMenu;
  bool get isTastingMenu => _isTastingMenu ?? false;
  set isTastingMenu(bool? val) => _isTastingMenu = val;

  bool hasIsTastingMenu() => _isTastingMenu != null;

  // "is_fixed_price_menu" field.
  bool? _isFixedPriceMenu;
  bool get isFixedPriceMenu => _isFixedPriceMenu ?? false;
  set isFixedPriceMenu(bool? val) => _isFixedPriceMenu = val;

  bool hasIsFixedPriceMenu() => _isFixedPriceMenu != null;

  // "package_description" field.
  String? _packageDescription;
  String get packageDescription => _packageDescription ?? '';
  set packageDescription(String? val) => _packageDescription = val;

  bool hasPackageDescription() => _packageDescription != null;

  static CategoriesStruct fromMap(Map<String, dynamic> data) =>
      CategoriesStruct(
        courses: getStructList(
          data['courses'],
          CoursesStruct.fromMap,
        ),
        isCombo: data['is_combo'] as bool?,
        packageId: castToType<int>(data['package_id']),
        categoryId: castToType<int>(data['category_id']),
        packageName: data['package_name'] as String?,
        categoryType: data['category_type'] as String?,
        displayOrder: castToType<int>(data['display_order']),
        languageCode: data['language_code'] as String?,
        isSharingMenu: data['is_sharing_menu'] as bool?,
        isTastingMenu: data['is_tasting_menu'] as bool?,
        isFixedPriceMenu: data['is_fixed_price_menu'] as bool?,
        packageDescription: data['package_description'] as String?,
      );

  static CategoriesStruct? maybeFromMap(dynamic data) => data is Map
      ? CategoriesStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'courses': _courses?.map((e) => e.toMap()).toList(),
        'is_combo': _isCombo,
        'package_id': _packageId,
        'category_id': _categoryId,
        'package_name': _packageName,
        'category_type': _categoryType,
        'display_order': _displayOrder,
        'language_code': _languageCode,
        'is_sharing_menu': _isSharingMenu,
        'is_tasting_menu': _isTastingMenu,
        'is_fixed_price_menu': _isFixedPriceMenu,
        'package_description': _packageDescription,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'courses': serializeParam(
          _courses,
          ParamType.DataStruct,
          isList: true,
        ),
        'is_combo': serializeParam(
          _isCombo,
          ParamType.bool,
        ),
        'package_id': serializeParam(
          _packageId,
          ParamType.int,
        ),
        'category_id': serializeParam(
          _categoryId,
          ParamType.int,
        ),
        'package_name': serializeParam(
          _packageName,
          ParamType.String,
        ),
        'category_type': serializeParam(
          _categoryType,
          ParamType.String,
        ),
        'display_order': serializeParam(
          _displayOrder,
          ParamType.int,
        ),
        'language_code': serializeParam(
          _languageCode,
          ParamType.String,
        ),
        'is_sharing_menu': serializeParam(
          _isSharingMenu,
          ParamType.bool,
        ),
        'is_tasting_menu': serializeParam(
          _isTastingMenu,
          ParamType.bool,
        ),
        'is_fixed_price_menu': serializeParam(
          _isFixedPriceMenu,
          ParamType.bool,
        ),
        'package_description': serializeParam(
          _packageDescription,
          ParamType.String,
        ),
      }.withoutNulls;

  static CategoriesStruct fromSerializableMap(Map<String, dynamic> data) =>
      CategoriesStruct(
        courses: deserializeStructParam<CoursesStruct>(
          data['courses'],
          ParamType.DataStruct,
          true,
          structBuilder: CoursesStruct.fromSerializableMap,
        ),
        isCombo: deserializeParam(
          data['is_combo'],
          ParamType.bool,
          false,
        ),
        packageId: deserializeParam(
          data['package_id'],
          ParamType.int,
          false,
        ),
        categoryId: deserializeParam(
          data['category_id'],
          ParamType.int,
          false,
        ),
        packageName: deserializeParam(
          data['package_name'],
          ParamType.String,
          false,
        ),
        categoryType: deserializeParam(
          data['category_type'],
          ParamType.String,
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
        isSharingMenu: deserializeParam(
          data['is_sharing_menu'],
          ParamType.bool,
          false,
        ),
        isTastingMenu: deserializeParam(
          data['is_tasting_menu'],
          ParamType.bool,
          false,
        ),
        isFixedPriceMenu: deserializeParam(
          data['is_fixed_price_menu'],
          ParamType.bool,
          false,
        ),
        packageDescription: deserializeParam(
          data['package_description'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'CategoriesStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is CategoriesStruct &&
        listEquality.equals(courses, other.courses) &&
        isCombo == other.isCombo &&
        packageId == other.packageId &&
        categoryId == other.categoryId &&
        packageName == other.packageName &&
        categoryType == other.categoryType &&
        displayOrder == other.displayOrder &&
        languageCode == other.languageCode &&
        isSharingMenu == other.isSharingMenu &&
        isTastingMenu == other.isTastingMenu &&
        isFixedPriceMenu == other.isFixedPriceMenu &&
        packageDescription == other.packageDescription;
  }

  @override
  int get hashCode => const ListEquality().hash([
        courses,
        isCombo,
        packageId,
        categoryId,
        packageName,
        categoryType,
        displayOrder,
        languageCode,
        isSharingMenu,
        isTastingMenu,
        isFixedPriceMenu,
        packageDescription
      ]);
}

CategoriesStruct createCategoriesStruct({
  bool? isCombo,
  int? packageId,
  int? categoryId,
  String? packageName,
  String? categoryType,
  int? displayOrder,
  String? languageCode,
  bool? isSharingMenu,
  bool? isTastingMenu,
  bool? isFixedPriceMenu,
  String? packageDescription,
}) =>
    CategoriesStruct(
      isCombo: isCombo,
      packageId: packageId,
      categoryId: categoryId,
      packageName: packageName,
      categoryType: categoryType,
      displayOrder: displayOrder,
      languageCode: languageCode,
      isSharingMenu: isSharingMenu,
      isTastingMenu: isTastingMenu,
      isFixedPriceMenu: isFixedPriceMenu,
      packageDescription: packageDescription,
    );
