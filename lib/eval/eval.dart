// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:math';
import 'package:fml/crypto/crypto.dart';
import 'package:fml/system.dart';
import 'package:intl/intl.dart';
import 'package:fml/eval/evaluator.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/eval/expressions.dart';
import 'package:fml/helper/common_helpers.dart';

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
  static final Map<String, dynamic> functions = {'acos': acos, 'asin': asin, 'atan': atan, 'bit': _bit, 'bytes': _bytes, 'case' : _case, 'ceil': _ceil, 'contains': _contains, 'cos': cos, 'decrypt': _decrypt, 'encrypt': _encrypt, 'endsWith': _endsWith, 'endswith': _endsWith, 'floor': _floor, 'hash' : _hash, 'if': _if, 'isBool' : _isBool, 'isbool' : _isBool, 'isBoolean' : _isBool, 'isboolean' : _isBool, 'isNull': _isNull, 'isnull': _isNull, 'isNullOrEmpty': _isNullOrEmpty, 'isnullorempty': _isNullOrEmpty, 'isNum' : _isNumeric, 'isnum' : _isNumeric, 'isNumeric' : _isNumeric, 'isnumeric' : _isNumeric, 'join': _join, 'length': _length, 'mod': _mod, 'noe': _isNullOrEmpty, 'number': _number, 'nvl': _nvl, 'pi': pi / 5, 'regex': _regex, 'replace': _replace, 'round': _round, 'sin': sin, 'startsWith': _startsWith, 'startswith': _startsWith, 'substring': _substring, 'tan': tan, 'toBool': _toBool, 'tobool': _toBool, 'toBoolean': _toBool, 'toboolean': _toBool, 'toDate': _toDate, 'todate': _toDate, 'toLower' : _toLower, 'tolower': _toLower, 'toNum': _toNum, 'tonum': _toNum, 'toNumber': _toNum, 'tonumber': _toNum, 'toStr': _toString, 'tostr': _toString, 'toString': _toString, 'tostring': _toString, 'toUpper' : _toUpper, 'toupper': _toUpper, 'truncate': _truncate,};

  static dynamic evaluate(String? expression, {Map<String?, dynamic>? variables, Map<String?, dynamic>? altFunctions})
  {
    if (expression == null) return null;

    dynamic result;
    var myExpression = expression;
    Expression? myParsed;
    var i = 0;
    var myVariables = <String, dynamic>{};
    var myFunctions = <String?, dynamic>{};

    try
    {
      // setup variable substitutions
      if (variables != null) {
        variables.forEach((key,value)
      {
        i++;
        var mKey = "___V$i";
        myVariables[mKey] = S.toNum(value) ?? S.toBool(value) ?? value;
        myExpression = myExpression.replaceAll(key!, mKey);
      });
      }

      // add variables
      myFunctions.addAll(myVariables);

      // add functions
      myFunctions.addAll(functions);

      // add alternate functions that dont clash
      altFunctions?.forEach((key, value) => myFunctions.containsKey(key) ? null : myFunctions[key] = value);

      // parse the expression
      myParsed  = Expression.tryParse(myExpression);

      // failed parse?
      if (myParsed == null) throw(Exception('Failed to parse $myExpression'));

      // required to replace quoted string observables
      myParsed = replaceInLiterals(myParsed, myVariables);

      // evaluate the expression
      result = evaluator.eval(myParsed, myFunctions);
    }
    catch(e)
    {
      String? msg;
      if (variables != null) variables.forEach((key, value) => msg = "${msg ?? ""}${msg == null ? "" : ",  "}$key=${value.toString()}");
      Log().debug("eval($expression) [$msg] failed. Error is $e");
      result = null;
    }
    return result;
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
          variables.forEach((key, value) => v = v.replaceAll(key, _toString(value) ?? key));
          expression = Literal(v,v);
        }
        break;

      default:
        break;
    }
    return expression;
  }

  // TODO: describe what this does
  static dynamic _toDate([dynamic datetime, dynamic format, dynamic outputFormat])
  {
    if (datetime == null) return null;
    DateTime? result;

    if (format is String) format = format.replaceAll('Y', 'y');
    if (outputFormat is String) outputFormat = outputFormat.replaceAll('Y', 'y');

    if (S.isNumber(datetime))
    {
      result = DateTime.fromMillisecondsSinceEpoch(S.toNum(datetime) as int);
    }
    else if (datetime is String)
    {
      result = S.toDate(datetime, format: format);
    }
    return S.toChar(result, format: outputFormat);
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
    return S.toStr(value);
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
    if (left == null || !S.isNumber(left)) return null;
    if (operator != '~' && (right == null || !S.isNumber(right))) return null;
    var l = S.toInt(left)!;
    var r = S.toInt(right) ?? 0;
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

  /// Returns a bool from a dynamic value using [S.toBool]
  static dynamic _toBool(dynamic value)
  {
    return S.toBool(value);
  }

  /// Returns a Nul from a dynamic value using [S.toNum]
  static dynamic _toNum(dynamic value)
  {
    return S.toNum(value);
  }

  /// Returns the nearest integer value rounding up
  static dynamic _ceil(dynamic value)
  {
    var n = S.toNum(value);
    if (n != null) {
      return n.ceil();
    } else {
      return null;
    }
  }

  /// Returns the nearest integer value rounding down
  static dynamic _floor(dynamic value)
  {
    var n = S.toNum(value);
    if (n != null) {
      return n.floor();
    } else {
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
    return S.isNullOrEmpty(value) ? true : false;
  }

  /// Returns a defaultValue if the value is null or '' otherwise returns the null-safe value
  static dynamic _nvl(dynamic value, dynamic defaultValue)
  {
    value = value?.toString();
    return S.isNullOrEmpty(value) ? defaultValue : value;
  }

  /// Returns true if the value is numeric
  static bool _isNumeric(dynamic value)
  {
    return S.isNumber(value);
  }

  /// Returns a bool from a dynamic value using [S.isBool]
  static bool _isBool(dynamic value)
  {
    return S.isBool(value);
  }

  /// Returns a or b depending on the if condition value
  static dynamic _if(dynamic value, dynamic a, dynamic b)
  {
    return S.toBool(value) ?? false ? a : b;
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
      dynamic v = S.toDouble(value);
      int? p = S.toInt(precision);
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
      dynamic v = S.toDouble(value);
      int? p = S.toInt(precision);
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
    if (S.isNullOrEmpty(val)) return '';
    int start = S.toInt(startIndex) ?? 0;
    int end   = S.toInt(endIndex) ?? val.length;
    if(end > val.length) {
      end = val.length;
    }
    if (start < 0 && (start * -1) <= val.length) {
      return val.substring(0, val.length + start);
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
    return S.toStr(value)?.toLowerCase() ?? value;
  }

  /// Returns an all uppercase String
  static dynamic _toUpper(dynamic value)
  {
    return S.toStr(value)?.toUpperCase() ?? value;
  }


  /// Returns the modular of a number and a divisor
  static dynamic _mod(dynamic num, dynamic div)
  {
    int? number  = S.toInt(num);
    int? divisor = S.toInt(div);
    if ((number != null) && (divisor != null) && (divisor != 0)) {
      return number%divisor;
    }
    return null;
  }

  // TODO: define this with a better name perhaps
  static String? normalize(dynamic expression)
  {
    expression = S.toStr(expression);
    if (expression == null) return null;

    //////////////////////////////////////////////
    /* Remove Extraneous Unquoted Blank Strings */
    //////////////////////////////////////////////
    return expression.replaceAll(RegExp(r"\s+(?=(?:[^\']*[\'][^\']*[\'])*[^\']*$)"), '');
  }

  /// Replace all [Pattern] occurrences in a String with a String
  static String _replace(dynamic s, dynamic pattern, dynamic replace) {
    pattern = S.toStr(pattern);
    replace = S.toStr(replace);
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
    key = S.toStr(key);
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
    key = S.toStr(key);
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
    key = S.toStr(key);
    try
    {
      s = Cryptography.decrypt(text: s, secretkey: key, vector: key);
    }
    catch(e) {
      return null;
    }
    return s;
  }

  static dynamic _case(dynamic value, [dynamic v0, dynamic r0, dynamic v1, dynamic r1, dynamic v2, dynamic r2, dynamic v3, dynamic r3, dynamic v4, dynamic r4, dynamic v5, dynamic r5, dynamic v6, dynamic r6, dynamic v7, dynamic r7, dynamic v8, dynamic r8, dynamic v9, dynamic r9])
  {
    if (value == v0) return r0;
    if (value == v1) return r1;
    if (value == v2) return r2;
    if (value == v3) return r3;
    if (value == v4) return r4;
    if (value == v5) return r5;
    if (value == v6) return r6;
    if (value == v7) return r7;
    if (value == v8) return r8;
    if (value == v9) return r9;
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

  /// null-safe String length
  static int _length(dynamic s)
  {
    if (s == null) return 0;
    if (s is List) return s.length;
    s = S.toStr(s);
    return s?.length ?? 0;
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
        if (value is String) value = S.toDouble(value);
        return f.format(value);
      }
      catch(e) {
        return value;
      }
    }
    return value;
  }
}