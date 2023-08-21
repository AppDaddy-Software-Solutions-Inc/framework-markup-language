// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:fml/emoji.dart';
import 'package:fml/log/manager.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart' deferred as mime;
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

class S {
  static bool _mimeLibraryLoaded = false;

  /// Parses Strings containing emoiji(s) in a text syntax like `:taco:` to `🌮`
  static String parseEmojis(String val) {
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
        if (!S.isNullOrEmpty(m2) &&
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

  /// List Item
  static dynamic item(Object list, int index) {
    if (list is List) {
      if ((list.isEmpty) || (index.isNegative) || (index >= list.length)) {
        return null;
      }
      return list[index];
    }
    return null;
  }

  /// Returns a String name given an Enum Type
  static String? fromEnum(Object? e) {
    try {
      return e.toString().split('.').last;
    } catch (e) {
      return null;
    }
  }

  /// Returns an Enum given a Key \[Value\] pair
  static T? toEnum<T>(String? key, List<T> values) {
    try {
      return values.firstWhereOrNull((v) => key == fromEnum(v));
    } catch (e) {
      return null;
    }
  }

  /// Dynamic check for a boolean from a String/bool
  static bool isBool(dynamic b) {
    try {
      if (b == null) return false;
      if (b is bool) return true;
      b = b.toString();
      b = b.trim().toLowerCase();
      return ((b == 'false') ||
          (b == '0') ||
          (b == 'no') ||
          (b == 'true') ||
          (b == '1') ||
          (b == 'yes'));
    } catch (e) {
      return false;
    }
  }

  /// returns true if v is all upper case characters
  static bool isUpperCase(dynamic v) {
    if (v is String && v == v.toUpperCase()) {
      return true;
    } else {
      return false;
    }
  }

  /// returns true if v is all lower case characters
  static bool isLowerCase(dynamic v) {
    if (v is String && v == v.toLowerCase()) {
      return true;
    } else {
      return false;
    }
  }

  static UriData? toDataUri(dynamic uri) {
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

  /// Check if a String is numeric value
  static bool isNumeric(String s) {
    try {
      double.parse(s);
      return true;
    } catch (e) {
      Log().debug('$e');
    }
    return false;
  }

  /// Check if a String is a percentage value
  static bool isPercentage(dynamic s) {
    if (s == null) return false;
    if (s is! String) return false;

    try {
      if (s.endsWith("%")) {
        s = s.split("%")[0];
        return isNumber(s);
      }
    } catch (e) {
      Log().debug('$e');
    }
    return false;
  }

  /// Check if a String contains uppercase character(s)
  static bool hasUpper(String value) {
    String pattern = "(.*[A-Z].*)";
    bool valid = RegExp(pattern).hasMatch(value);
    return valid;
  }

  /// Check if a String contains lowercase character(s)
  static bool hasLower(String value) {
    String pattern = "(.*[a-z].*)";
    bool valid = RegExp(pattern).hasMatch(value);
    return valid;
  }

  /// Check if a String contains numeric character(s)
  static bool hasNumber(String value) {
    String pattern = "(.*[0-9].*)";
    bool valid = RegExp(pattern).hasMatch(value);
    return valid;
  }

  /// Check if a String contains special character(s)
  static bool hasSpecialCharacter(String value) {
    String pattern = "[^a-zA-Z0-9]";
    bool valid = RegExp(pattern).hasMatch(value);
    return valid;
  }

  /// Converts a String to a formattable DateTime object
  ///
  /// More info on supported formats can be found in [DateFormat] and [DateTime]
  static DateTime? toDate(String? datetime, {String? format}) {
    if (S.isNullOrEmpty(datetime) || datetime == 'null') return null;
    DateTime? result;
    try {
      DateFormat formattedDate = DateFormat(format);
      if (format is String) result = formattedDate.parse(datetime!);
    } on FormatException catch (e) {
      Log().debug(e.toString(),
          caller:
              'static DateTime? toDate(String? datetime, {String? format})');
    } catch (e) {
      result = null;
      Log().debug(e.toString(),
          caller:
              'helper/string.dart => DateTime toDate(String date, String format) => DateFormat(format).parse(date)');
    }

    try {
      result ??= DateTime.parse(datetime!);
    } on FormatException catch (e) {
      Log().debug(e.toString(), caller: 'Invalid Format $e');
    } catch (e) {
      result = null;
      Log().debug(e.toString(),
          caller:
              'helper/string.dart => DateTime toDate(String date, String format) => DateTime.tryParse(date)');
    }
    return result;
  }

  /// Helper function for an [eval._toDate()]
  static String? toChar(DateTime? datetime, {String? format}) {
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
      Log().debug(e.toString(),
          caller:
              'helper/string.dart => String toChar(String date, String format)');
    }
    return result;
  }

  /// Returns a key value pair from a map if it exists, otherwise optionally return a default value else null
  static dynamic mapVal(Map? map, dynamic key, {dynamic defaultValue}) {
    dynamic value = defaultValue;
    try {
      if ((map != null) && (map.containsKey(key))) {
        value = map[key];
      }
    } catch (e) {
      Log().debug(e.toString(),
          caller:
              'helper/string.dart => mapVal(Map map, dynamic key, {dynamic defaultValue})');
      return defaultValue;
    }
    return value;
  }

  /// Returns the value from [mapVal] as an int if it is numeric
  static int? mapInt(Map? map, dynamic key, {int? defaultValue}) {
    dynamic value = mapVal(map, key, defaultValue: defaultValue);
    if (isNumber(value)) {
      value = S.toInt(value);
    } else {
      value = defaultValue;
    }
    return value;
  }

  /// Returns the value from [mapVal] as a bool if it is a bool
  static bool? mapBoo(Map? map, dynamic key, {bool? defaultValue}) {
    dynamic value = mapVal(map, key, defaultValue: defaultValue);
    if (isBool(value)) {
      value = S.toBool(value);
    } else {
      value = defaultValue;
    }
    return value;
  }

  /// Returns a value from [mapVal] as a double if it is numeric
  static double? mapDbl(Map map, dynamic key, {double? defaultValue}) {
    dynamic value = mapVal(map, key, defaultValue: defaultValue);
    if (isNumber(value)) {
      value = S.toDouble(value);
    } else {
      value = defaultValue;
    }
    return value;
  }

  /// Returns true if a String/Value is numeric
  static bool isNumber(dynamic s) {
    try {
      if (s is double) return true;
      double.parse(s.toString());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Returns a bool from a String if it is a bool value including '0' / '1' / 'no' / 'yes'
  static bool? toBool(dynamic s) {
    try {
      if (s == null) return null;
      if (s is bool) return s;

      String b = s.toString();
      b = b.trim().toLowerCase();
      if ((b == 'false') || (b == '0')) return false;
      if ((b == 'true') || (b == '1'))  return true;
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Returns an int from a String if it is a numeric value
  static int? toInt(dynamic s) {
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

  /// Remove the non ASCII characters from a String
  static String removeNonASCII(String str) {
    return str.replaceAll(RegExp(r'[^\x20-\x7E]'), '');
  }

  /// Takes a value typically a String and if its numeric parsed will output a num
  static num? toNum(dynamic s) {
    try {
      if (s == null || s == '' || s == 'null') return null;
      if (s is num) return s;
      if (s is String) return num.parse(s);
      return toNum(s.toString());
    } catch (e) {
      return null;
    }
  }

  /// toString() but safe to use on null
  static String? toStr(dynamic s) {
    try {
      if (s == null) return null;
      return s.toString();
    } catch (e) {
      return null;
    }
  }

  /// toBase64() but safe to use on null
  static String? toBase64(dynamic s) {
    try {
      if (s is String) {
        var bytes = utf8.encode(s);
        return Base64Codec().encode(bytes);
      }
      if (s is List<int>) {
        return Base64Codec().encode(s);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// fromBase64() but safe to use on null
  static String? fromBase64(dynamic s) {
    try {
      if (s is String) {
        // length must be divible by 4
        while (s.length % 4 != 0) {
          s = s + "=";
        }
        var bytes = Base64Codec().decode(s);
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

  /// If a value (typically a String) is numeric return as a double
  static double? toDouble(dynamic s) {
    try {
      if (isNullOrEmpty(s)) return null;
      if (s is double) return s;
      if (s is String) return double.parse(s);
      return toDouble(s.toString());
    } catch (e) {
      return null;
    }
  }

  // TODO
  static int _setBit({required int bit, int? value, required bool on}) {
    int myValue = pow(2, bit - 1) as int;
    return on ? (value! | myValue) : (value! - (value & myValue));
  }

  // TODO
  static bool isBitSet({int? bit, int? value}) {
    if (bit == null) return false;
    if (value == null) return false;

    int myValue = pow(2, bit - 1) as int;
    return ((value & myValue) == myValue);
  }

  // TODO
  static int setBit({required int bit, int? value}) {
    return _setBit(bit: bit, value: value, on: true);
  }

  // TODO
  static int clearBit({required int bit, int? value}) {
    return _setBit(bit: bit, value: value, on: false);
  }

  /// Takes in a String/List and returns true if it is null, blank or empty
  static bool isNullOrEmpty(dynamic s) {
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

  /// [compareTo] function with ascending/descending and ignore case
  static int? compare(dynamic a, dynamic b,
      {bool ascending = true, bool ignoreCase = true}) {
    if ((a == null) && (b == null)) return 0;
    if ((a == null) && (b != null)) return (ascending == true) ? -1 : 1;
    if ((a != null) && (b == null)) return (ascending == true) ? 1 : -1;

    if ((a is String) && (ignoreCase == true)) a = a.toLowerCase();
    if ((b is String) && (ignoreCase == true)) b = b.toLowerCase();
    if (ascending == true) {
      return a.compareTo(b);
    } else {
      return b.compareTo(a);
    }
  }

  /// Trim a String from the end of another String
  static String rtrim(String s, String char) {
    while (s.endsWith(char)) {
      s = s.replaceFirst(char, "", s.lastIndexOf(char));
    }
    return s;
  }

  /// Trim a String from the start of another String
  static String ltrim(String s, String char) {
    while (s.startsWith(char)) {
      s = s.replaceFirst(char, "");
    }
    return s;
  }

  /// Returns a String Datetime of the current time as this format `13:37:09:480`
  static String timestamp() {
    return "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')}.${DateTime.now().millisecond.toString().padLeft(3, '0')}";
  }

  static Future<String> mimetype(String path, {String defaultType = ""}) async {
    String type;
    try {
      if (!_mimeLibraryLoaded) {
        await mime.loadLibrary();
        _mimeLibraryLoaded = true;
      }
      type = mime.lookupMimeType(path) ?? defaultType;
    } catch (e) {
      type = defaultType;
    }
    return type;
  }

  /// Returns a given String with all the first chars of each word capitalised and other chars lowercase
  static String toTitleCase(String text) {
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
  static int byteToInt8(int b) =>
      Uint8List.fromList([b]).buffer.asByteData().getInt8(0);

  /// Convert two byte length int values to an int value, for example a byte of \[00000001, 00000010\] -> 258
  static int twoByteToInt16(int v1, int v2) =>
      Uint8List.fromList([v1, v2]).buffer.asByteData().getUint16(0);

  // TODO
  static String byteListToHexString(List<int> bytes) => bytes
      .map((i) => i.toRadixString(16).padLeft(2, '0'))
      .reduce((a, b) => (a + b));

  // converts versions of 0.0.0 to a number
  static int? toVersionNumber(String? version) {
    if (version == null) return null;
    try {
      version = version.replaceAll("+", "");
      List versionCells = version.split('.');
      versionCells = versionCells.map((i) => int.parse(i)).toList();
      return versionCells[0] * 100000 +
          versionCells[1] * 1000 +
          versionCells[2];
    } catch (e) {
      return null;
    }
  }

  /// makes a filename safe
  static String toSafeFileName(String filename,
      {String separator = '-',
      bool withSpaces = false,
      bool lowercase = false,
      bool onlyAlphanumeric = false}) {
    final List<String> reservedCharacters = [
      '?',
      ':',
      '"',
      '*',
      '|',
      '/',
      '\\',
      '<',
      '>',
      '+',
      '[',
      ']'
    ];
    final RegExp onlyAlphanumericRegex = RegExp(r'''[^a-zA-Z0-9\s.]''');
    String returnString = filename;
    if (onlyAlphanumeric) {
      returnString = returnString.replaceAll(onlyAlphanumericRegex, '');
    } else {
      for (var c in reservedCharacters) {
        returnString = returnString.replaceAll(c, separator);
      }
    }
    if (!withSpaces) returnString = returnString.replaceAll(' ', separator);
    return lowercase ? returnString.toLowerCase() : returnString;
  }

  static String newId({String prefix = "auto"}) =>
      "$prefix${Uuid().v4().replaceAll("-", "").toLowerCase()}";
}
