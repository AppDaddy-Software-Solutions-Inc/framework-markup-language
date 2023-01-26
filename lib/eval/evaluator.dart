// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
library expressions.evaluator;

import '../log/manager.dart';
import 'expressions.dart';
import 'dart:math';
import 'package:decimal/decimal.dart';

class ExpressionEvaluator {
  const ExpressionEvaluator();

  dynamic eval(Expression? expression, Map<String?, dynamic> context)
  {
    if (expression == null) throw ArgumentError.notNull('expression');
    if (expression is Literal) return evalLiteral(expression, context);
    if (expression is Variable) return evalVariable(expression, context);
    if (expression is ThisExpression) return evalThis(expression, context);
    if (expression is MemberExpression) {
      return evalMemberExpression(expression, context);
    }
    if (expression is IndexExpression) {
      return evalIndexExpression(expression, context);
    }
    if (expression is CallExpression) {
      return evalCallExpression(expression, context);
    }
    if (expression is UnaryExpression) {
      return evalUnaryExpression(expression, context);
    }
    if (expression is BinaryExpression) {
      dynamic result = evalBinaryExpression(expression, context);
      if (result is Decimal)

        return result.toDouble();

      else return result;
    }
    if (expression is ConditionalExpression) {
      return evalConditionalExpression(expression, context);
    }
    throw ArgumentError("Unknown expression type '${expression.runtimeType}'");
  }

  dynamic evalLiteral(Literal literal, Map<String?, dynamic> context) {
    var value = literal.value;
    if (value is List) return value.map((e) => eval(e, context)).toList();
    if (value is Map) {
      return value.map(
              (key, value) => MapEntry(eval(key, context), eval(value, context)));
    }
    return value;
  }

  dynamic evalVariable(Variable variable, Map<String?, dynamic> context) {
    return context[variable.identifier.name];
  }

  dynamic evalThis(ThisExpression expression, Map<String?, dynamic> context) {
    return context['this'];
  }

  dynamic evalMemberExpression(
      MemberExpression expression, Map<String?, dynamic> context) {
    throw UnsupportedError('Member expressions not supported');
  }

  dynamic evalIndexExpression(
      IndexExpression expression, Map<String?, dynamic> context) {
    return eval(expression.object, context)[eval(expression.index, context)];
  }

  bool isAVariable(dynamic object)
  {
    if (object == null) return false;

    // this captures instances like a.set()
    if (object is Variable) return true;

    // this captures instances like GLOBAL.a.set()
    String exp = object.toString();
    if (object is MemberExpression && exp.contains(".") && !exp.contains("(") && !exp.contains("[")) return true;

    return false;
  }

  dynamic evalCallExpression(CallExpression expression, Map<String?, dynamic> context)
  {
    // olajos - March 14, 2022 - Added Functionality to Convert a.b() to _call call with parameters id, function, list<arguments>
    // olajos - Modified January 26, 2023 - Added IsAVariable to capture dot notated executes like GLOBAL.x.set('value') or <id>.<subproperty>.set('red');
    MemberExpression? exp = (expression.callee is MemberExpression) ? (expression.callee as MemberExpression) : null;
    if  (exp != null && isAVariable(exp.object) && expression.arguments is List)
    {
      // evaluate id. id may be a bindable
      String id = (expression.callee as MemberExpression).object.toString();
      if (id.startsWith("___V") && context.containsKey(id) && (context[id] is String)) id = context[id];

      // evaluate function. function may be a bindable
      String fn = (expression.callee as MemberExpression).property.toString();
      if (fn.startsWith("___V") && context.containsKey(fn) && (context[fn] is String)) fn = context[fn];

      expression = CallExpression(Variable(Identifier("execute")), expression.arguments);
      var callee = eval(expression.callee, context);
      var arguments = expression.arguments!.map((e) => eval(e, context)).toList();

      final List<dynamic> args = [id, fn, arguments];
      return Function.apply(callee, args);
    }
    else
    {
      var callee = eval(expression.callee, context);
      var arguments = expression.arguments!.map((e) => eval(e, context)).toList();
      return Function.apply(callee, arguments);
    }
  }

  dynamic evalUnaryExpression(
      UnaryExpression expression, Map<String?, dynamic> context) {
    var argument = eval(expression.argument, context);
    switch (expression.operator) {
      case '-':
        return -argument;
      case '+':
        return argument;
      case '!':
       // if(argument == null) argument = false; removed by Isaac as we have null aware operator now.
        return !argument;

      case '~':
        return ~argument;
    }
    throw ArgumentError('Unknown unary operator ${expression.operator}');
  }

  dynamic evalBinaryExpression(
      BinaryExpression expression, Map<String?, dynamic> context) {
    var left = eval(expression.left, context);
    var right = () => eval(expression.right, context);
    switch (expression.operator) {
      case '||':
        return left || right();
      case '??':
        return left ?? right(); //Added by isaac for alternate to nvl. Can be expressions on each side.
      case '&&':
        return left && right();
      case '|':
        return left | right();
      case '^':
        return pow(left, right());
      case '&':
        return left & right();
      case '==':
        return left == right();
      case '!=':
        return left != right();
      case '<=':
        return left <= right();
      case '>=':
        return left >= right();
      case '<':
        return left < right();
      case '>':
        return left > right();
      case '<<':
        return left << right();
      case '>>':
        return left >> right();
      case '+':
        return Decimal.parse(left.toString()) + Decimal.parse(right().toString());
      case '-':
        return Decimal.parse(left.toString()) - Decimal.parse(right().toString());
      case '*':
        return Decimal.parse(left.toString()) * Decimal.parse(right().toString());
      case '/':
        return Decimal.parse(left.toString()) / Decimal.parse(right().toString());
      case '%':
        return Decimal.parse(left.toString()) % Decimal.parse(right().toString());
    }
    throw ArgumentError(
        'Unknown operator ${expression.operator} in expression');
  }

  dynamic evalConditionalExpression(
      ConditionalExpression expression, Map<String?, dynamic> context)
  {
    // modified by olajos = 2022-03-10
    bool? test;

    try {
      test = eval(expression.test, context);
    } catch(e){
      Log().debug("Expression is invalid ${expression.test}", caller: "eval");
    }
    return (test ?? false) ? eval(expression.consequent, context) : eval(expression.alternate, context);
  }
}