// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CoursesStruct extends BaseStruct {
  CoursesStruct({
    int? courseId,
    String? courseName,
    int? courseOrder,
    List<int>? menuItemIds,
    int? maxSelections,
    int? minSelections,
    String? courseDescription,
    List<CourseItemMetadataStruct>? courseItemMetadata,
  })  : _courseId = courseId,
        _courseName = courseName,
        _courseOrder = courseOrder,
        _menuItemIds = menuItemIds,
        _maxSelections = maxSelections,
        _minSelections = minSelections,
        _courseDescription = courseDescription,
        _courseItemMetadata = courseItemMetadata;

  // "course_id" field.
  int? _courseId;
  int get courseId => _courseId ?? 0;
  set courseId(int? val) => _courseId = val;

  void incrementCourseId(int amount) => courseId = courseId + amount;

  bool hasCourseId() => _courseId != null;

  // "course_name" field.
  String? _courseName;
  String get courseName => _courseName ?? '';
  set courseName(String? val) => _courseName = val;

  bool hasCourseName() => _courseName != null;

  // "course_order" field.
  int? _courseOrder;
  int get courseOrder => _courseOrder ?? 0;
  set courseOrder(int? val) => _courseOrder = val;

  void incrementCourseOrder(int amount) => courseOrder = courseOrder + amount;

  bool hasCourseOrder() => _courseOrder != null;

  // "menu_item_ids" field.
  List<int>? _menuItemIds;
  List<int> get menuItemIds => _menuItemIds ?? const [];
  set menuItemIds(List<int>? val) => _menuItemIds = val;

  void updateMenuItemIds(Function(List<int>) updateFn) {
    updateFn(_menuItemIds ??= []);
  }

  bool hasMenuItemIds() => _menuItemIds != null;

  // "max_selections" field.
  int? _maxSelections;
  int get maxSelections => _maxSelections ?? 0;
  set maxSelections(int? val) => _maxSelections = val;

  void incrementMaxSelections(int amount) =>
      maxSelections = maxSelections + amount;

  bool hasMaxSelections() => _maxSelections != null;

  // "min_selections" field.
  int? _minSelections;
  int get minSelections => _minSelections ?? 0;
  set minSelections(int? val) => _minSelections = val;

  void incrementMinSelections(int amount) =>
      minSelections = minSelections + amount;

  bool hasMinSelections() => _minSelections != null;

  // "course_description" field.
  String? _courseDescription;
  String get courseDescription => _courseDescription ?? '';
  set courseDescription(String? val) => _courseDescription = val;

  bool hasCourseDescription() => _courseDescription != null;

  // "course_item_metadata" field.
  List<CourseItemMetadataStruct>? _courseItemMetadata;
  List<CourseItemMetadataStruct> get courseItemMetadata =>
      _courseItemMetadata ?? const [];
  set courseItemMetadata(List<CourseItemMetadataStruct>? val) =>
      _courseItemMetadata = val;

  void updateCourseItemMetadata(
      Function(List<CourseItemMetadataStruct>) updateFn) {
    updateFn(_courseItemMetadata ??= []);
  }

  bool hasCourseItemMetadata() => _courseItemMetadata != null;

  static CoursesStruct fromMap(Map<String, dynamic> data) => CoursesStruct(
        courseId: castToType<int>(data['course_id']),
        courseName: data['course_name'] as String?,
        courseOrder: castToType<int>(data['course_order']),
        menuItemIds: getDataList(data['menu_item_ids']),
        maxSelections: castToType<int>(data['max_selections']),
        minSelections: castToType<int>(data['min_selections']),
        courseDescription: data['course_description'] as String?,
        courseItemMetadata: getStructList(
          data['course_item_metadata'],
          CourseItemMetadataStruct.fromMap,
        ),
      );

  static CoursesStruct? maybeFromMap(dynamic data) =>
      data is Map ? CoursesStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'course_id': _courseId,
        'course_name': _courseName,
        'course_order': _courseOrder,
        'menu_item_ids': _menuItemIds,
        'max_selections': _maxSelections,
        'min_selections': _minSelections,
        'course_description': _courseDescription,
        'course_item_metadata':
            _courseItemMetadata?.map((e) => e.toMap()).toList(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'course_id': serializeParam(
          _courseId,
          ParamType.int,
        ),
        'course_name': serializeParam(
          _courseName,
          ParamType.String,
        ),
        'course_order': serializeParam(
          _courseOrder,
          ParamType.int,
        ),
        'menu_item_ids': serializeParam(
          _menuItemIds,
          ParamType.int,
          isList: true,
        ),
        'max_selections': serializeParam(
          _maxSelections,
          ParamType.int,
        ),
        'min_selections': serializeParam(
          _minSelections,
          ParamType.int,
        ),
        'course_description': serializeParam(
          _courseDescription,
          ParamType.String,
        ),
        'course_item_metadata': serializeParam(
          _courseItemMetadata,
          ParamType.DataStruct,
          isList: true,
        ),
      }.withoutNulls;

  static CoursesStruct fromSerializableMap(Map<String, dynamic> data) =>
      CoursesStruct(
        courseId: deserializeParam(
          data['course_id'],
          ParamType.int,
          false,
        ),
        courseName: deserializeParam(
          data['course_name'],
          ParamType.String,
          false,
        ),
        courseOrder: deserializeParam(
          data['course_order'],
          ParamType.int,
          false,
        ),
        menuItemIds: deserializeParam<int>(
          data['menu_item_ids'],
          ParamType.int,
          true,
        ),
        maxSelections: deserializeParam(
          data['max_selections'],
          ParamType.int,
          false,
        ),
        minSelections: deserializeParam(
          data['min_selections'],
          ParamType.int,
          false,
        ),
        courseDescription: deserializeParam(
          data['course_description'],
          ParamType.String,
          false,
        ),
        courseItemMetadata: deserializeStructParam<CourseItemMetadataStruct>(
          data['course_item_metadata'],
          ParamType.DataStruct,
          true,
          structBuilder: CourseItemMetadataStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'CoursesStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is CoursesStruct &&
        courseId == other.courseId &&
        courseName == other.courseName &&
        courseOrder == other.courseOrder &&
        listEquality.equals(menuItemIds, other.menuItemIds) &&
        maxSelections == other.maxSelections &&
        minSelections == other.minSelections &&
        courseDescription == other.courseDescription &&
        listEquality.equals(courseItemMetadata, other.courseItemMetadata);
  }

  @override
  int get hashCode => const ListEquality().hash([
        courseId,
        courseName,
        courseOrder,
        menuItemIds,
        maxSelections,
        minSelections,
        courseDescription,
        courseItemMetadata
      ]);
}

CoursesStruct createCoursesStruct({
  int? courseId,
  String? courseName,
  int? courseOrder,
  int? maxSelections,
  int? minSelections,
  String? courseDescription,
}) =>
    CoursesStruct(
      courseId: courseId,
      courseName: courseName,
      courseOrder: courseOrder,
      maxSelections: maxSelections,
      minSelections: minSelections,
      courseDescription: courseDescription,
    );
