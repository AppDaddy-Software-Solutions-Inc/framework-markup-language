// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:flutter/material.dart';
import 'package:fml/emoji.dart';
import 'package:fml/helpers/color.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

/// String Helpers
///
/// Helper functions that can be used by importing *string.dart*
/// Example ```dart
/// String myString = ":burrito: or :taco:?"
/// print(S.parseEmojis(myString)); // outputs: 🌯 or 🌮
/// ```
///

extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

String newId({String prefix = "auto"}) =>
    "$prefix${const Uuid().v4().replaceAll("-", "").toLowerCase()}";

/// Takes in a String/List and returns true if it is null, blank or empty
bool isNull(value) => value == null;
bool isNullOrEmpty(dynamic s) {
  try {
    if (s == null || s == 'null') return true;
    if (s is String) {
      s = s.trim();
      if (s == '') return true;
    }
    if (s is List) return (s.isEmpty);
  } catch (e) {
    return true;
  }
  return false;
}

bool? toBool(dynamic s,
    {List<String> allowTrue = const ['true', '1', 'yes'],
    List<String> allowFalse = const ['false', '0', 'no']}) {
  try {
    if (s == null) return null;
    if (s is bool) return s;
    s = s.toString().trim().toLowerCase();
    if (allowTrue.contains(s)) return true;
    if (allowFalse.contains(s)) return false;
    return null;
  } catch (e) {
    return null;
  }
}

/// Dynamic check for a boolean from a String/bool
bool isBool(dynamic b,
    {List<String> allow = const ['true', 'false', '1', '0', 'yes', 'no']}) {
  try {
    if (b == null) return false;
    if (b is bool) return true;
    b = b.toString().trim().toLowerCase();
    return allow.contains(b);
  } catch (e) {
    return false;
  }
}

/// toString() but safe to use on null
String? toStr(dynamic s) {
  try {
    if (s == null) return null;
    if (s is Color) {
      var r = s.red.toRadixString(16).padLeft(2, '0');
      var g = s.green.toRadixString(16).padLeft(2, '0');
      var b = s.blue.toRadixString(16).padLeft(2, '0');
      var o = s.alpha.toRadixString(16).padLeft(2, '0');
      return "#$r$g$b$o";
    }
    if (s is $Value) {
      return toStr(s.$value);
    }
    return s.toString();
  } catch (e) {
    return null;
  }
}

/// Returns an int from a String if it is a numeric value
int? toInt(dynamic s) {
  try {
    if (s == null) return null;
    if (s is int) return s;
    num? n = toNum(s);
    if (n != null) n = n.round();
    return n as int?;
  } catch (e) {
    return null;
  }
}

/// Returns an int from a String if it is a numeric value
Color? toColor(dynamic s) {
  if (s == null) return null;
  if (s is String) return ColorHelper.toColor(s);
  if (s is Color) return s;
  if (s is MaterialColor) {
    return Color.fromRGBO(s.red, s.green, s.blue, s.opacity);
  }
  if (s is MaterialAccentColor) {
    return Color.fromRGBO(s.red, s.green, s.blue, s.opacity);
  }
  return null;
}

var hasAlpha = RegExp(r'[a-z]');

/// Takes a value typically a String and if its numeric parsed will output a num
num? toNum(dynamic s, {allowMalformed = true}) {
  try {
    if (s == null || s == '' || s == 'null') return null;
    if (s is num) return s;
    if (s is String) {
      var n = num.parse(s.trim());
      if (!allowMalformed) {
        s = s.toLowerCase().trim();
        if (s.startsWith('0') && s.length > 1) return null;
        if (s.startsWith('.') || s.endsWith('.')) return null;
        if (s.startsWith('+')) return null;
        if (s.contains(hasAlpha)) return null;
        return n;
      }
      return n;
    }
    return toNum(s.toString());
  } catch (e) {
    return null;
  }
}

/// If a value (typically a String) is numeric return as a double
double? toDouble(dynamic s, {int? precision}) {
  try {
    double? v;
    if (isNullOrEmpty(s)) return null;

    if (s is double) {
      v = s;
    }

    else if (s is String) {
      v = double.parse(s);
    }

    else {
      v = toDouble(s.toString());
    }

    // apply precision rounding
    if (v is double && precision != null && !precision.isNegative) {
      var mod = pow(10.0, precision);
      v = ((v * mod).round().toDouble() / mod);
    }

    return v;
  }
  catch (e) {
    return null;
  }
}

/// Converts a String to a formattable DateTime object
///
/// More info on supported formats can be found in [DateFormat] and [DateTime]
DateTime? toDate(dynamic value, {String? format}) {

  // missing or empty value
  if (isNullOrEmpty(value)) return null;

  // already a date
  if (value is DateTime) return value;

  // value is time of day
  if (value is TimeOfDay) {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day, value.hour, value.minute);
  }

  // not a string
  if (value is! String) return null;

  try {
    return format != null ? DateFormat(format).parse(value) : DateTime.parse(value);
  } catch (e) {
    return null;
  }
}

String? toDateString(dynamic value, {String? format, String? formatIn}) {

  var date = toDate(value, format: formatIn);
  if (date == null) return null;

  try {
    return DateFormat(format).format(date);
  } catch (e) {
    return null;
  }
}

TimeOfDay? toTime(dynamic value, {String? format}) {

  TimeOfDay? time;
  try
  {
    time = TimeOfDay.fromDateTime(toDate(value, format: format)!);
  }
  catch(e) {
    return null;
  }
  return time;
}

/// Helper function for an [eval._toDate()]
String? toChar(DateTime? datetime, {String? format}) {
  if (datetime == null) return null;
  String? result;
  try {
    if (format is String) {
      result = DateFormat(format).format(datetime);
    } else {
      result = datetime.toString();
    }
  } catch (e) {
    result = null;
  }
  return result;
}

/// Returns a given String with all the first chars of each word capitalised and other chars lowercase
String toTitleCase(String text) {
  if (text.length <= 1) return text.toUpperCase();
  final List<String> words = text.split(' ');
  final capitalizedWords = words.map((word) {
    if (word.trim().isNotEmpty) {
      final String firstLetter = word.trim().substring(0, 1).toUpperCase();
      final String remainingLetters = word.trim().substring(1).toLowerCase();
      return '$firstLetter$remainingLetters';
    }
    return '';
  });
  return capitalizedWords.join(' ');
}

/// Convert a byte length int value to an int value, for example a byte of 00000010 -> 2
int byteToInt8(int b) => Uint8List.fromList([b]).buffer.asByteData().getInt8(0);

/// Convert two byte length int values to an int value, for example a byte of \[00000001, 00000010\] -> 258
int twoByteToInt16(int v1, int v2) =>
    Uint8List.fromList([v1, v2]).buffer.asByteData().getUint16(0);

// TODO
String byteListToHexString(List<int> bytes) => bytes
    .map((i) => i.toRadixString(16).padLeft(2, '0'))
    .reduce((a, b) => (a + b));

/// Returns a String name given an Enum Type
String? fromEnum(Object? e) {
  try {
    return e.toString().split('.').last;
  } catch (e) {
    return null;
  }
}

/// Returns an Enum given a Key \[Value\] pair
T? toEnum<T>(String? key, List<T> values) {
  try {
    return values.firstWhereOrNull((v) => key == fromEnum(v));
  } catch (e) {
    return null;
  }
}

UriData? toDataUri(dynamic uri) {
  try {
    if (uri == null) return null;
    if (uri is UriData) return uri;
    if ((uri is String) && (uri.toLowerCase().trim().startsWith("data:"))) {
      return UriData.parse(uri);
    }
    return null;
  } catch (e) {
    return null;
  }
}

/// fromBase64() but safe to use on null
String? fromBase64(dynamic s) {
  try {
    if (s is String) {
// length must be divible by 4
      while (s.length % 4 != 0) {
        s = s + "=";
      }
      var bytes = const Base64Codec().decode(s);
      return utf8.decode(bytes);
    }
    if (s is List<int>) {
      return utf8.decode(s);
    }
    return null;
  } catch (e) {
    return null;
  }
}

/// Check if a String is numeric value
bool isNumeric(dynamic s) {
  try {
    if (s is double) return true;
    double.parse(s);
    return true;
  } catch (_) {}
  return false;
}

/// Check if a String is a percentage value
bool isPercent(dynamic s) {
  if (s == null) return false;
  if (s is! String) return false;

  try {
    if (s.endsWith("%")) {
      s = s.split("%")[0];
      return isNumeric(s);
    }
  }
  catch (e) {
    return false;
  }
  return false;
}

/// List Item
dynamic elementAt(Object list, int index) => (list is List &&
        list.isNotEmpty &&
        !index.isNegative &&
        index < list.length)
    ? list[index]
    : null;

/// Parses Strings containing emoiji(s) in a text syntax like `:taco:` to `🌮`
String parseEmojis(String val) {
  String value = val;
  try {
    value = value.replaceAllMapped(RegExp(r'(?=:)([^\s])(.*?)([^\s])(:)'),
        (Match m) {
      String? m2;
      if ((m[0]?.startsWith(':') ?? false) &&
          (m[0]?.endsWith(':') ?? false) &&
          !(m[0]?.contains(' ') ?? false)) {
        m2 = (m[0]!.substring(1, m[0]!.length - 1));
      }
      if (!isNullOrEmpty(m2) &&
          !(m2?.contains(':') ?? false) &&
          !(m2?.contains(' ') ?? false) &&
          Emoji.emoji[m2?.toLowerCase()] != null) {
        return Emoji.emoji[m2?.toLowerCase()]!;
      }
      return m[0] ?? m.toString();
    });
  } catch (e) {
    return val;
  }
  return value;
}
