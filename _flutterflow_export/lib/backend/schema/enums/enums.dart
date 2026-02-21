import 'package:collection/collection.dart';

enum Weekdays {
  Monday,
  Tuesday,
  Wednesday,
  Thursday,
  Friday,
  Saturday,
  Sunday,
}

enum LanguageCodes {
  en,
  da,
  zh,
  es,
  fr,
  de,
}

extension FFEnumExtensions<T extends Enum> on T {
  String serialize() => name;
}

extension FFEnumListExtensions<T extends Enum> on Iterable<T> {
  T? deserialize(String? value) =>
      firstWhereOrNull((e) => e.serialize() == value);
}

T? deserializeEnum<T>(String? value) {
  switch (T) {
    case (Weekdays):
      return Weekdays.values.deserialize(value) as T?;
    case (LanguageCodes):
      return LanguageCodes.values.deserialize(value) as T?;
    default:
      return null;
  }
}
