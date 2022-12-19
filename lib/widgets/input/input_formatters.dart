// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/services.dart';
import 'package:fml/eval/eval.dart';
import 'package:fml/helper/helper_barrel.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue)
  {
    return TextEditingValue(text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}

class TextInputValidators {


  bool isEmailValid(
      String email) {
    bool emailValid = RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?").hasMatch(email);
    return emailValid;
  }

  bool isExpiryValid(
      String expiry) {
    bool expiryValid = RegExp(r"^(0[1-9]|1[0-2])\/?([0-9]{4}|[0-9]{2})$").hasMatch(expiry);
    return expiryValid;
  }


  bool isPasswordValid(
      String password) {
    bool passwordValid = RegExp(r"^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z]).{8,}$").hasMatch(password);
    return passwordValid;
  }


}

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
        text: newValue.text.toLowerCase(), selection: newValue.selection);
  }
}

class TextToNumericFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (S.isNullOrEmpty(newValue.text))
      return TextEditingValue(
          text: newValue.text, selection: newValue.selection);
    if (newValue.text == '-' || newValue.text == '+')
      return TextEditingValue(
          text: newValue.text, selection: newValue.selection);
    if (S.isNumber(newValue.text))
      return TextEditingValue(
          text: newValue.text, selection: newValue.selection);
    else
      return TextEditingValue(
          text: oldValue.text, selection: oldValue.selection);
  }
}

class TextToIntegerFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (S.isNullOrEmpty(newValue.text))
      return TextEditingValue(
          text: newValue.text, selection: newValue.selection);
    if (newValue.text == '-' || newValue.text == '+')
      return TextEditingValue(
          text: newValue.text, selection: newValue.selection);
    if (S.isNumber(newValue.text))
      return TextEditingValue(
          text: S.toStr(S.toInt(newValue.text))!, selection: newValue.selection);
    else
      return TextEditingValue(
          text: oldValue.text, selection: oldValue.selection);
  }
}

class TextToBooleanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (S.isNullOrEmpty(newValue.text))
      return TextEditingValue(
          text: newValue.text, selection: newValue.selection);
    if (S.isBool(newValue.text))
      return TextEditingValue(
          text: S.toStr(S.toInt(newValue.text))!, selection: newValue.selection);
    else
      return TextEditingValue(
          text: oldValue.text, selection: oldValue.selection);
  }
}

class TextLengthFormatter extends TextInputFormatter {
  int length;
  TextLengthFormatter(this.length);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (
        (length >= 0) &&
        (newValue.text.length > length))
      return TextEditingValue(
          text: oldValue.text, selection: oldValue.selection);
    else
      return TextEditingValue(
          text: newValue.text, selection: newValue.selection);
  }
}

class CustomFormatter extends TextInputFormatter {
  final String format;

  CustomFormatter(this.format);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue,
      TextEditingValue newValue) {
    dynamic v = newValue.text;
    dynamic s = newValue.selection;

    if (S.isNullOrEmpty(v)) return TextEditingValue(text: v, selection: s);

    var formatters = format.split(';');
    for (String fmt in formatters) {
      if (!S.isNullOrEmpty(fmt)) {
        fmt = fmt.replaceAll('()', '(' + '\'' + v + '\'' + ')');
        fmt = fmt.trim();
        v = Eval.evaluate(fmt);
        if (v == null) {
          v = oldValue.text;
          s = oldValue.selection;
          break;
        } else
          v = S.toStr(v);
      }
    }
    return TextEditingValue(text: v, selection: s);
  }
}