// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:fml/crypto/crypto.dart';
import 'package:fml/data/data.dart';
import 'package:fml/helpers/time.dart';
import 'package:fml/system.dart';
import 'package:intl/intl.dart';
import 'package:fml/eval/evaluator.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/eval/expressions.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/widgets/input/input_formatters.dart';
import 'package:flutter_multi_formatter/formatters/credit_card_number_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';

/// Eval parses evaluation strings from FML templates
///
/// Evals are denoted in templates by =... or eval(...) where ... is what to evaluate
/// Evals can contain [functions] expressions which are inline function calls
/// Evals can contain common operators: !, ||, &&, ==, !=, >=, <=, >, <, +, -, *, /, %, ^
/// Evals can contain conditional operations; expression ? consequent : alternate
class Eval
{
  static final ExpressionEvaluator evaluator = const ExpressionEvaluator();

  /// The String value mapping of all the functions
  static final Map<String, dynamic> functions = {'abs': _abs, 'acos': acos, 'addTime': _addTime, 'addtime': _addTime, 'asin': asin, 'atan': atan, 'bit': _bit, 'bytes': _bytes, 'case' : _case, 'ceil': _ceil, 'contains': _contains, 'cos': cos, 'decrypt': _decrypt, 'distance': _distance, 'elementAt': _elementAt, 'encrypt': _encrypt, 'endsWith': _endsWith, 'endswith': _endsWith, 'floor': _floor, 'hash' : _hash, 'indexOf': _indexOf, 'if': _if, 'isAfter': _isAfter, 'isafter': _isAfter, 'isBefore': _isBefore, 'isbefore': _isBefore, 'isBool' : _isBool, 'isbool' : _isBool, 'isBoolean' : _isBool, 'isboolean' : _isBool, 'isPhone' : _isValidPhone, 'isCard' : _isValidCreditCard, 'isPassword' : _isValidPassword, 'isEmail' : _isValidEmail, 'isExpiryDate' : _isValidExpiryDate, 'isNull': _isNull, 'isnull': _isNull, 'isNullOrEmpty': _isNullOrEmpty, 'isnullorempty': _isNullOrEmpty, 'isNum' : _isNumeric, 'isnum' : _isNumeric, 'isNumeric' : _isNumeric, 'isnumeric' : _isNumeric, 'join': _join, 'length': _length, 'mod': _mod, 'noe': _isNullOrEmpty, 'number': _number, 'nvl': _nvl, 'pi': pi / 5, 'regex': _regex, 'replace': _replace, 'round': _round, 'sin': sin, 'split': _split, 'startsWith': _startsWith, 'startswith': _startsWith, 'substring': _substring, 'subtractTime': _subtractTime, 'subtracttime': _subtractTime, 'tan': tan, 'timeBetween': _timeBetween, 'timebetween': _timeBetween, 'toBool': _toBool, 'tobool': _toBool, 'toBoolean': _toBool, 'toboolean': _toBool, 'toDate': _toDate, 'todate': _toDate, 'toEpoch': _toEpoch, 'toepoch': _toEpoch, 'toJson': _toJson, 'toLower' : _toLower, 'tolower': _toLower, 'toNum': _toNum, 'tonum': _toNum, 'toNumber': _toNum, 'tonumber': _toNum, 'toStr': _toString, 'tostr': _toString, 'toString': _toString, 'tostring': _toString, 'toUpper' : _toUpper, 'toupper': _toUpper, 'toXml': _toXml, 'truncate': _truncate,};

  static dynamic evaluate(String? expression, {Map<String?, dynamic>? variables, Map<String?, dynamic>? altFunctions})
  {
    // expressions with leading or trailing spaces fail parse
    expression = expression?.trim();

    // no expression specified?
    if (expression == null || expression.isEmpty) return null;

    var i = 0;
    var myExpression = expression;
    var myVariables  = <String, dynamic>{};
    var myFunctions  = <String?, dynamic>{};

    try
    {
      // setup variable substitutions
      variables?.forEach((key,value)
      {
        i++;
        var myKey = "___V$i";
        myVariables[myKey] = toNum(value, allowMalformed: false) ?? toBool(value, allowFalse: ['false'], allowTrue: ['true']) ?? value;
        myExpression = myExpression.replaceAll(key!, myKey);
      });

      // add variables
      myFunctions.addAll(myVariables);

      // add functions
      myFunctions.addAll(functions);

      // add alternate functions that dont clash
      altFunctions?.forEach((key, value) => myFunctions.containsKey(key) ? null : myFunctions[key] = value);

      // parse the expression
      var myParsedResult = Expression.tryParse(myExpression);
      var myParsedExpression = myParsedResult.isSuccess ? myParsedResult.value : null;

      // failed parse?
      if (myParsedExpression == null) throw(Exception('Failed to parse $myExpression. Error is ${myParsedResult.message}'));

      // required to replace quoted string observables
      myParsedExpression = replaceInLiterals(myParsedExpression, myVariables);

      // evaluate the expression
      return evaluator.eval(myParsedExpression, myFunctions);
    }
    catch(e)
    {
      String? msg;
      variables?.forEach((key, value) => msg = "${msg ?? ""}${msg == null ? "" : ",  "}$key=${value.toString()}");
      Log().debug("eval($expression) [$msg] failed. Error is $e");
      return null;
    }
  }

  static Expression? replaceInLiterals(dynamic expression, Map<String, dynamic> variables)
  {
    Type? expressionType;

    if (expression is ConditionalExpression) {
      expressionType = ConditionalExpression;
    } else if (expression is BinaryExpression) {
      expressionType = BinaryExpression;
    } else if (expression is CallExpression) {
      expressionType = CallExpression;
    } else if (expression is Literal) {
      expressionType = Literal;
    } else if (expression is Variable) {
      expressionType = Variable;
    }

    switch(expressionType)
    {
      case ConditionalExpression:

        expression = ConditionalExpression(expression.test, replaceInLiterals(expression.consequent, variables), replaceInLiterals(expression.alternate, variables));
        break;

      case BinaryExpression:
        expression = BinaryExpression(expression.operator, replaceInLiterals(expression.left, variables), replaceInLiterals(expression.right, variables));
        break;

      case CallExpression:
        List? args = expression.arguments;
        for (int i = 0; i < expression.arguments.length; i++) {
          args![i] = replaceInLiterals(expression.arguments[i], variables);
        }
        expression = CallExpression(expression.callee, args as List<Expression?>?);
        break;

      case Variable:
        String? name = expression.identifier?.name;
        bool exists = variables.containsKey(name);
        if (!exists)
        {
          String? value = _toString(name);
          expression = Literal(value,value);
        }
        break;

      case Literal:
        if (expression.value is String)
        {
          String v = expression.value ?? "";

          // loop backwards in the string so v1 does not replace the start of v10
          for (String key in variables.keys.toList().reversed) {
            // replace the keys in the string with the value of the variables map
            // replace missing variables with a blank string (formerly the key name)
            v = v.replaceAll(key, _toString(variables[key]) ?? "");
          }
          expression = Literal(v,v);
        }
        break;

      default:
        break;
    }
    return expression;
  }

  // TODO: describe what this does
  static dynamic _toDate([dynamic datetime, dynamic inputFormat, dynamic outputFormat])
  {
    if (datetime == null) return null;
    DateTime? result;

    if (inputFormat is String) inputFormat = inputFormat.replaceAll('Y', 'y');
    if (outputFormat is String) outputFormat = outputFormat.replaceAll('Y', 'y');

    if (isNumeric(datetime))
    {
      result = DateTime.fromMillisecondsSinceEpoch(toNum(datetime) as int);
    }
    else if (datetime is String)
    {
      result = toDate(datetime, format: inputFormat);
    }
    return toChar(result, format: outputFormat);
  }

  // TODO: WIP
  static dynamic _regex(dynamic value, dynamic pattern, dynamic match)
  {
    String? v;
    var expression = pattern;
    RegExp exp = RegExp('r"$expression"');

    String input = value.toString();

    // returns a bool
    if (match == "has" || match == null) {
      v = exp.hasMatch(input).toString();
    }
    // returns the match
    if (match == "first") {
      v = exp.firstMatch(input).toString();
    }
    // returns substring match
    if (match == "string") {
      v = exp.stringMatch(input).toString();
    }
    // returns a joined string of matches
    if (match == "all") {
      v = exp.allMatches(input).join(', ').toString();
    }
    return v;
  }

  /// Returns a null safe String representation of a value
  static dynamic _toString(dynamic value)
  {
    return toStr(value);
  }

  /// XOR binary function
  ///
  /// Given left = 60 and right = 13
  /// left  = 0011 1100
  /// right = 0000 1101
  /// XOR   = 0011 0001
  /// returns 49
  static dynamic _bit(dynamic operator, dynamic left, dynamic right)
  {
    if (operator == null) return null;
    if (left == null || !isNumeric(left)) return null;
    if (operator != '~' && (right == null || !isNumeric(right))) return null;
    var l = toInt(left)!;
    var r = toInt(right) ?? 0;
    switch (operator) {
      case '&':
        return (l&r);
      case '|':
        return (l|r);
      case '^':
        return (l^r);
      // case '~': // NOT Operator doesn't work, try it yourself:
      //   return (~l); // print(~3); // Should print -4 (~0011 = 1100)
      case '<<':
        return (l<<r);
      case '>>':
        return (l>>r);
    }
    return null;
  }

  /// Returns a bool from a dynamic value using [toBool]
  static dynamic _toBool(dynamic value)
  {
    return toBool(value);
  }

  /// Returns a Nul from a dynamic value using [toNum]
  static dynamic _toNum(dynamic value)
  {
    return toNum(value);
  }

  /// Returns the nearest integer value rounding up
  static dynamic _ceil(dynamic value)
  {
    var n = toNum(value);
    if (n != null) {
      return n.ceil();
    } else {
      return null;
    }
  }

  /// Returns the nearest integer value rounding down
  static dynamic _floor(dynamic value)
  {
    var n = toNum(value);
    if (n != null) {
      return n.floor();
    } else {
      return null;
    }
  }

  /// Returns the absolute value of a number
  static dynamic _abs(dynamic value)
  {
    if (!isNumeric(value)) return null;
    try
    {
      var v = toNum(value);
      return v?.abs();
    }
    catch(e)
    {
      return null;
    }
  }


  /// Returns true if a String value contains [Pattern]
  static dynamic _contains(dynamic value, dynamic pat)
  {
    if (pat == null || pat == '') {
      return false;
    }
    if (value is List)   return value.contains(_toString(pat));
    if (value is String) return value.contains(_toString(pat));
    return false;
  }

  /// Returns true if a String value starts with [Pattern]
  static dynamic _startsWith(dynamic value, dynamic pat)
  {
    if (pat == null || pat == '') {
      return false;
    }
    value = _toString(value);
    pat = _toString(pat);
    if (value is String && pat is String)
    {
      return value.startsWith(pat);
    }
    return false;
  }

  /// Returns true if a String value ends with a [Pattern]
  static dynamic _endsWith(dynamic value, dynamic pat)
  {
    if (pat == null || pat == '') {
      return false;
    }
    value = _toString(value);
    pat = _toString(pat);
    if (value is String && pat is String)
    {
      return value.endsWith(pat);
    }
    return false;
  }

  /// Returns true if the value is null
  static bool _isNull(dynamic value)
  {
    return value == null;
  }

  /// Returns true if the value is null or '' otherwise returns false
  static bool _isNullOrEmpty(dynamic value)
  {
    return isNullOrEmpty(value) ? true : false;
  }

  /// Returns a defaultValue if the value is null or '' otherwise returns the null-safe value
  static dynamic _nvl(dynamic value, dynamic defaultValue)
  {
    value = value?.toString();
    return isNullOrEmpty(value) ? defaultValue : value;
  }

  /// Returns true if the value is numeric
  static bool _isNumeric(dynamic value)
  {
    return isNumeric(value);
  }

  /// Returns a bool from a dynamic value using [isBool]
  static bool _isBool(dynamic value)
  {
    return isBool(value);
  }

  /// Returns a or b depending on the if condition value
  static dynamic _if(dynamic value, dynamic a, dynamic b)
  {
    return toBool(value) ?? false ? a : b;
  }


  /// Rounds a value to the nearest value based on precision
  ///
  /// Precision of 0 will round to nearest full integer
  /// Precision of -1 will round to the nearest multiple of ten
  /// Precision of 1 will round to the nearest tenth
  /// Pad will ensure the number has a determined amount of digits after the decimal
  static dynamic _round(dynamic value, dynamic precision, [dynamic pad]) {
    try {
      if ((value == null) || (value == 'null')) return null;
      dynamic v = toDouble(value);
      int? p = toInt(precision);
      bool? z = pad != null && pad >= 0;
      if (v != null && p != null) {
        double power = pow(10.0, p) as double;
        // v = ((v * power).round().toDouble() / power);
        v = v * power;
        v = v?.round();
        v = v?.toDouble();
        if (v != null && power != 0) v = v / power;
      }
      if (v != null && z == true) {
        return v.toStringAsFixed(pad);
      }
      return v;
    }
    catch(e) {
      return null;
    }
  }

  /// Truncates a value removing all value right of the precision
  ///
  /// Precision of 0 will round down to nearest integer, removing the decimal value
  /// Precision of -1 will round down to the nearest multiple of 10
  /// Precision of 1 will round down to the nearest tenth
  /// Pad will ensure the number has a determined amount of digits after the decimal
  static dynamic _truncate(dynamic value, dynamic precision, [dynamic pad]) {
    try {
      if ((value == null) || (value == 'null')) return null;
      dynamic v = toDouble(value);
      int? p = toInt(precision);
      bool? z = pad != null && pad >= 0;
      if (v != null && p != null) {
        double power = pow(10.0, p) as double;
        // v = ((v * power).truncate().toDouble() / power);
        v = v * power;
        v = v?.truncate();
        v = v?.toDouble();
        if (v != null && power != 0) v = v / power;
      }
      if (v != null && z == true) {
        return v.toStringAsFixed(pad);
      }
      return v;
    }
    catch(e) {
      return null;
    }
  }

  /// Inclusive start to exclusive end
  static dynamic _substring(dynamic value, [dynamic startIndex, dynamic endIndex])
  {
    String val = value.toString();
    if (isNullOrEmpty(val)) return '';
    int start = toInt(startIndex) ?? 0;
    int end   = toInt(endIndex) ?? val.length;
    if (start < 0 && (start * -1) <= val.length) {
      start = val.length + start;
    }
    if (end < 0 && (end * -1) <= val.length) {
      end = val.length + end;
    }
    if (end > val.length) {
      end = val.length;
    }
    if (start >= end) {
      return ''; // out of range
    } else {
      return val.substring(start, end);
    }

  }

  /// Returns an all lowercase String
  static dynamic _toLower(dynamic value)
  {
    return toStr(value)?.toLowerCase() ?? value;
  }

  /// Returns distance in meters between two coordinates in degrees
  static dynamic _distance(dynamic latitude1, dynamic longitude1, dynamic latitude2, dynamic longitude2, )
  {

    //haversine formula
    double? lat1 = toDouble(latitude1);
    double? lon1 = toDouble(longitude1);

    double? lat2 = toDouble(latitude2);
    double? lon2 = toDouble(longitude2);

    if(lat1 == null || lon1 == null || lat2 == null || lon2 == null ) return null;

    var earthRadius = 6378137.0;

    //latlng must be in radians
    double toRad = pi / 180.0;
    double distance = 2 *
        earthRadius *
        asin(sqrt(pow(sin(lat2 * toRad - lat1 * toRad) / 2, 2) +
            cos(lat1 * toRad ) * cos(lat2 * toRad) * pow(sin(lon2 * toRad - lon1 * toRad) / 2, 2)));

    //distance returned in M
    return distance;
  }

  /// Returns an all uppercase String
  static dynamic _toUpper(dynamic value)
  {
    return toStr(value)?.toUpperCase() ?? value;
  }

  /// Returns value as a valid json string
  static dynamic _toJson(dynamic value)
  {
    // convert from xml
    if (value is String)
    {
      return Json.decode(value);
    }

    if (value is Data)
    {
      return Data.toJson(value);
    }

    return null;
  }

  /// Returns value as a valid xml string
  static dynamic _toXml(dynamic value, [dynamic rootName, dynamic nodeName])
  {
    // parse and validate
    if (value is String)
    {
      var doc = Xml.tryParse(value);
      return doc?.toString();
    }

    // convert from Data to xml
    if (value is Data)
    {
      return Data.toXml(value, defaultRootName: toStr(rootName), defaultNodeName: toStr(nodeName));
    }

    return null;
  }

  /// Returns the modular of a number and a divisor
  static dynamic _mod(dynamic num, dynamic div)
  {
    int? number  = toInt(num);
    int? divisor = toInt(div);
    if ((number != null) && (divisor != null) && (divisor != 0)) {
      return number%divisor;
    }
    return null;
  }

  // TODO: define this with a better name perhaps
  static String? normalize(dynamic expression)
  {
    expression = toStr(expression);
    if (expression == null) return null;

    //////////////////////////////////////////////
    /* Remove Extraneous Unquoted Blank Strings */
    //////////////////////////////////////////////
    return expression.replaceAll(RegExp(r"\s+(?=(?:[^\']*[\'][^\']*[\'])*[^\']*$)"), '');
  }

  /// Replace all [Pattern] occurrences in a String with a String
  static String _replace(dynamic s, dynamic pattern, dynamic replace) {
    pattern = toStr(pattern);
    replace = toStr(replace);
    try {
      s = s.replaceAll(pattern, replace);
    }
    catch(e)
    {
      Log().exception(e);
    }
    return s;
  }

  /// Hash a String
  static String? _hash(dynamic s, [dynamic key])
  {
    key ??= System.app?.settings("HASHKEY");
    if (key == null) return null;
    key = toStr(key);
    try
    {
      s = Cryptography.hash(text: s, key: key);
    }
    catch(e) {
      return null;
    }
    return s;
  }

  /// Encrypt a String
  static String? _encrypt(dynamic s, dynamic key)
  {
    if (key == null) return null;
    key = toStr(key);
    try
    {
      s = Cryptography.encrypt(text: s, secretkey: key, vector: key);
    }
    catch(e) {
      return null;
    }
    return s;
  }

  /// Decrypt a String
  static String? _decrypt(dynamic s, dynamic key)
  {
    if (key == null) return null;
    key = toStr(key);
    try
    {
      s = Cryptography.decrypt(text: s, secretkey: key, vector: key);
    }
    catch(e) {
      return null;
    }
    return s;
  }

  static final RegExp nonQuotedColons = RegExp(r"\):(?=([^'\\]*(\\.|'([^'\\]*\\.)*[^'\\]*'))*[^']*$)");
  static final String nonQuotedPlaceholder = "!~!";

  static dynamic _case(dynamic value, [dynamic v0, dynamic r0, dynamic v1, dynamic r1, dynamic v2, dynamic r2, dynamic v3, dynamic r3, dynamic v4, dynamic r4, dynamic v5, dynamic r5, dynamic v6, dynamic r6, dynamic v7, dynamic r7, dynamic v8, dynamic r8, dynamic v9, dynamic r9])
  {
    // legacy k1, v2, k2, v2 ... up to 10 values
    if (v0 is! List) return _case(value, [v0,v1,v2,v3,v4,v5,v6,v7,v8,v9], [r0,r1,r2,r3,r4,r5,r6,r7,r8,r9]);

    if (r0 is! List)
    {
      var list = v0;

      // build keys list
      var keys = [];
      int i = 0;
      while (i < list.length)
      {
        keys.add(list[i]);
        i = i + 2;
      }

      // build values list
      var values = [];
      var j = 1;
      while (j < list.length)
      {
        values.add(list[j]);
        j = j + 2;
      }

      return _case(value,keys,values);
    }

    // 2 lists
    var keys   = v0;
    var values = r0;

    // evaluate
    var key = keys.firstWhereOrNull((key) => key == value);
    if (key != null)
    {
      var i = values.indexOf(key);
      if (!i.isNegative && i < values.length) return values[i];
    }
    return null;
  }

  static dynamic _join(dynamic s, [dynamic s1, dynamic s2, dynamic s3, dynamic s4, dynamic s5, dynamic s6, dynamic s7, dynamic s8, dynamic s9, dynamic s10])
  {
    String myString = "";
    if (_toString(s)   != null) myString += _toString(s);
    if (_toString(s1)  != null) myString += _toString(s1);
    if (_toString(s2)  != null) myString += _toString(s2);
    if (_toString(s3)  != null) myString += _toString(s3);
    if (_toString(s4)  != null) myString += _toString(s4);
    if (_toString(s5)  != null) myString += _toString(s5);
    if (_toString(s6)  != null) myString += _toString(s6);
    if (_toString(s7)  != null) myString += _toString(s7);
    if (_toString(s8)  != null) myString += _toString(s8);
    if (_toString(s9)  != null) myString += _toString(s9);
    if (_toString(s10) != null) myString += _toString(s10);
    return myString;
  }

  /// null-safe object length
  /// string or list
  static int _length(dynamic s)
  {
    if (s == null) return 0;
    if (s is List) return s.length;
    s = toStr(s);
    return s?.length ?? 0;
  }

  /// index of object in list
  static int _indexOf(dynamic object, dynamic list)
  {
    if (list is List)
    {
       if (list.contains(object)) return list.indexOf(object);
       if (object is List && object.isNotEmpty && list.contains(object.first)) return list.indexOf(object.first);
    }
    if (list != null && list == object) return 0;
    return -1;
  }

  /// object in list at specified index
  static dynamic _elementAt(dynamic list, dynamic index)
  {
    if (list is List && isNumeric(index))
    {
      int i = toInt(index)!;
      if (i.isNegative) return null;
      if (i >= list.length) return null;
      return list.elementAt(i);
    }
    return null;
  }

  /// splits the string by the character and retirns the list or
  /// if the index is supplied, just the list element at that index
  static dynamic _split(dynamic object, dynamic character, [dynamic index])
  {
    if (object is String && character is String)
    {
      var list = object.split(character);
      return isNumeric(index) ? _elementAt(list, index) : list;
    }
    return null;
  }

  /// null-safe String length
  static int _bytes(dynamic s)
  {
    if (s == null) return 0;
    return s?.length ?? 0;
  }

  /// Returns a formatted number
  ///
  /// Given a number or String this function provides a variety of useful reformats
  /// If currency is true it will add a dollar sign and keep 2 digits after the decimal
  /// If compact is true it will suffux a number with a letter
  /// for example: k for thousand or M for million, creating a shortened number representation
  /// If semicompact is true it will write the full word as the suffix, example: 1000 = 1 thousand
  static dynamic _number(dynamic value, dynamic currency, dynamic compact, [dynamic semicompact]) {
    String locale = 'en_US'; // TODO more formats https://pub.dev/documentation/intl/latest/intl/NumberFormat-class.html
    if (value != null) {
      try {
        late NumberFormat f;
        if (semicompact == true) {
          f = NumberFormat.compactLong(locale: locale);
        } else if (compact == true && currency != true) {
          f = NumberFormat.compact(locale: locale);
        } else if (compact != true && currency != true) { // not compact and not currency
          // We need to create a format string that maintains decimal places
          var decimals = 0;
          var split = value.toString().split('.');
          if (split.length == 2) decimals = split[1].length;
          String format = "#,###,###,###,###,###,###";
          if (decimals > 0) {
            format = '$format.${List.filled(decimals, '#').join()}';
            format.padRight(decimals, '#');
          }
          f = NumberFormat(format, locale);
        } else if (compact == true && currency == true) {
          f = NumberFormat.compactSimpleCurrency(locale: locale);
        } else if (compact != true && currency == true) {
          f = NumberFormat.simpleCurrency(locale: locale);
        }
        if (value is String) value = toDouble(value);
        return f.format(value);
      }
      catch(e) {
        return value;
      }
    }
    return value;
  }

  /// Returns the epoch of a DateTime String
  static int? _toEpoch(dynamic dts) {
    if (dts == null || dts is! String) return null;
    DateTime? dt = toDate(dts);
    if (dt == null) return null;
    return dt.millisecondsSinceEpoch;
  }

  /// Takes in 2 DateTime Strings and returns true if the first is after the second
  /// otherwise it returns false except, when an input is an invalid format it will return null.
  static bool? _isAfter(dynamic dts1, dynamic dts2) {
    if (dts1 == null || dts1 is! String || dts2 == null || dts2 is! String) return null;
    DateTime? dt1 = toDate(dts1);
    DateTime? dt2 = toDate(dts2);
    if (dt1 == null || dt2 == null) return null;
    return DT.isAfter(dt1, dt2);
  }

  /// Takes in 2 DateTime Strings and returns true if the first is before the second
  /// otherwise it returns false, except when an input is an invalid format it will return null.
  static bool? _isBefore(dynamic dts1, dynamic dts2) {
    if (dts1 == null || dts1 is! String || dts2 == null || dts2 is! String) return null;
    DateTime? dt1 = toDate(dts1);
    DateTime? dt2 = toDate(dts2);
    if (dt1 == null || dt2 == null) return null;
    return DT.isBefore(dt1, dt2);
  }

  /// Takes in 2 DateTime Strings and returns a human readable string describing the time between.
  /// When either input is an invalid format it will return null.
  static String? _timeBetween(dynamic dts1, dynamic dts2) {
    if (dts1 == null || dts1 is! String || dts2 == null || dts2 is! String) return null;
    DateTime? dt1 = toDate(dts1);
    DateTime? dt2 = toDate(dts2);
    if (dt1 == null || dt2 == null) return null;
    return DT.timeBetween(dt1, dt2);
  }

  /// Takes in a plain language time value String and adds it to a DateTime String.
  /// Plain language time values ie: `500ms`, `1 year`, `3 weeks`, for more see [TimeUnitDuration]
  static String? _addTime(dynamic add, dynamic dts) {
    if (add == null || add is! String || dts == null || dts is! String) return null;
    TimeUnitDuration addTUD = TimeUnitDuration.fromString(add);
    if (addTUD.amount == 0) return null;
    DateTime? dt = toDate(dts);
    if (dt == null) return null;
    return DT.add(dt, addTUD).toString();
  }

  /// Takes in a plain language time value String and subtracts it from a DateTime String.
  /// Plain language time values ie: `500ms`, `1 year`, `3 weeks`, for more see [TimeUnitDuration]
  static String? _subtractTime(dynamic subtract, dynamic dts) {
    if (subtract == null || subtract is! String || dts == null || dts is! String) return null;
    TimeUnitDuration addTUD = TimeUnitDuration.fromString(subtract);
    if (addTUD.amount == 0) return null;
    DateTime? dt = toDate(dts);
    if (dt == null) return null;
    return DT.subtract(dt, addTUD).toString();
  }

  /// validates phone number
  static bool? _isValidPhone(dynamic num) =>  _isNullOrEmpty(num) ? null : isPhoneValid(num.toString());

  /// validates credit card number
  static bool? _isValidCreditCard(dynamic num) =>  _isNullOrEmpty(num) ? null : isCardNumberValid(cardNumber: toStr(num) ?? "");

  /// validates email
  static bool? _isValidEmail(dynamic num) =>  _isNullOrEmpty(num) ? null : TextInputValidators().isEmailValid(toStr(num) ?? "");

  /// validates password
  static bool? _isValidPassword(dynamic num) =>  _isNullOrEmpty(num) ? null : TextInputValidators().isPasswordValid(toStr(num) ?? "");

  /// validates expiry date
  static bool? _isValidExpiryDate(dynamic num) =>  _isNullOrEmpty(num) ? null : TextInputValidators().isExpiryValid(toStr(num) ?? "");
}