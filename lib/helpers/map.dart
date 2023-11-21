import 'package:fml/helpers/string.dart';

/// Returns a key value pair from a map if it exists, otherwise optionally return a default value else null
dynamic fromMap(Map? map, dynamic key, {dynamic defaultValue}) {
  dynamic value = defaultValue;
  try {
    if ((map != null) && (map.containsKey(key))) {
      value = map[key];
    }
  } catch (e) {
    return defaultValue;
  }
  return value;
}

/// Returns the value from [fromMap] as an int if it is numeric
int? fromMapAsInt(Map? map, dynamic key, {int? defaultValue}) {
  dynamic value = fromMap(map, key, defaultValue: defaultValue);
  if (isNumeric(value)) {
    value = toInt(value);
  } else {
    value = defaultValue;
  }
  return value;
}

/// Returns the value from [fromMap] as a bool if it is a bool
bool? fromMapAsBool(Map? map, dynamic key, {bool? defaultValue}) {
  dynamic value = fromMap(map, key, defaultValue: defaultValue);
  if (isBool(value)) {
    value = toBool(value);
  } else {
    value = defaultValue;
  }
  return value;
}

/// Returns a value from [fromMap] as a double if it is numeric
double? fromMapAsDouble(Map map, dynamic key, {double? defaultValue}) {
  dynamic value = fromMap(map, key, defaultValue: defaultValue);
  if (isNumeric(value)) {
    value = toDouble(value);
  } else {
    value = defaultValue;
  }
  return value;
}