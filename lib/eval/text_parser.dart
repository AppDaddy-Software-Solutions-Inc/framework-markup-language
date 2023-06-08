// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:math';
import 'package:fml/helper/common_helpers.dart';

class TextValue {
  List<String> styles = [];
  String text = "";

  TextValue(this.styles, this.text);
}

List<TextValue> textValues = [];
List<String> styles = [];

void matchElements (String value) {
  /// WARNING: DO NOT USE LOOKBEHIND it is unsupported in safari and other browsers.
  RegExp bdO =  RegExp(r"(([ \*\_\^\#\`])|\\)(\*\*)(?![ \*])"); // \ will escape the mandatory space before or after a character.
  RegExp bdC =  RegExp(r"\*\*((?=[ \*\_\^\#\`\\])|\\)");
  RegExp itO =  RegExp(r"(([ \*\_\^\#\`\\])|\\)(\*)(?![ \*])");
  RegExp itC =  RegExp(r"\*((?=[ \*\_\^\#\`\\])|\\)");
  RegExp sbO =  RegExp(r"(([ \*\_\^\#\`\\])|\\)(\^\^)(?![ \^])");
  RegExp sbC =  RegExp(r"\^\^((?=[ \*\_\^\#\`\\])|\\)");
  RegExp spO =  RegExp(r"(([ \*\_\^\#\`\\])|\\)(\^)(?![ \^])");
  RegExp spC =  RegExp(r"\^((?=[ \*\_\^\#\`\\])|\\)");
  RegExp unO =  RegExp(r"(([ \*\_\^\#\`\\])|\\)(\_)(?![ \_])");
  RegExp unC =  RegExp(r"(\_)((?=[ \*\_\^\#\`\\])|\\)");
  RegExp ovO =  RegExp(r"(([ \*\_\^\#\`\\])|\\)(\_\_\_)(?![ \_])");
  RegExp ovC =  RegExp(r"\_\_\_((?=[ \*\_\^\#\`\\])|\\)");
  RegExp stO =  RegExp(r"(([ \*\_\^\#\`\\])|\\)(\_\_)(?![ \_])");
  RegExp stC =  RegExp(r"\_\_((?=[ \*\_\^\#\`\\])|\\)");
  RegExp codeO = RegExp(r"(([ *_^#`\\])|\\)(```)(?![ `])");
  RegExp codeC = RegExp(r"(\S)(```(?=\W|\\))");

  // pad the value rather than adding extra cases for start and end of line
  if (value.length > 2) {
    value = " $value ";
  } else {
    return extractStyles(value, []); // There is nothing to apply markdown to
  }

  while (bdO.firstMatch(value) != null && bdC.firstMatch(value) != null) // add or for start and end or add space to start and end
   {
    //value = value.replaceFirst(bdO, '###bol###');
    value = value.replaceFirstMapped(bdO, (match) => "${match.group(1)!}###bol###");
    value = value.replaceFirst(bdC, '###bol###');
  }

  while (itO.firstMatch(value) != null && itC.firstMatch(value) != null)
  {
    //value = value.replaceFirst(itO, '###ita###', 1);
    value = value.replaceFirstMapped(itO, (match) => "${match.group(1)!}###ita###");
    value = value.replaceFirst(itC, '###ita###');
  }





  while (sbO.firstMatch(value) != null && sbC.firstMatch(value) != null)
  {
    value = value.replaceFirstMapped(sbO, (match) => "${match.group(1)!}###sub###");
    value = value.replaceFirst(sbC, '###sub###');
  }

  while (spO.firstMatch(value) != null && spC.firstMatch(value) != null)
  {
    value = value.replaceFirstMapped(spO, (match) => "${match.group(1)!}###sup###");
    value = value.replaceFirst(spC, '###sup###');
  }

  while (ovO.firstMatch(value) != null && ovC.firstMatch(value) != null)
  {
    value = value.replaceFirstMapped(ovO, (match) => "${match.group(1)!}###ove###");
    value = value.replaceFirst(ovC, '###ove###');
  }

  while (stO.firstMatch(value) != null && stC.firstMatch(value) != null)
  {
    value = value.replaceFirstMapped(stO, (match) => "${match.group(1)!}###str###");
    value = value.replaceFirst(stC, '###str###');
  }

  while (unO.firstMatch(value) != null && unC.firstMatch(value) != null)
  {
    value = value.replaceFirstMapped(unO, (match) => "${match.group(1)!}###und###");
    value = value.replaceFirst(unC, '###und###');
  }


  while (codeO.firstMatch(value) != null && codeC.firstMatch(value) != null) {
    value = value.replaceFirstMapped(codeO, (match) => "${match.group(1)!}###code###");
    value = value.replaceFirstMapped(codeC, (match) => "${match[1]!}###code###");
    // value = value.replaceFirst(codeC, '###code###');
  }

  return extractStyles(value, []);

}


void extractStyles(String value, List<String> styleList) {

 String under = "###und###";
 String over = "###ove###";
 String strike = "###str###";
 String sub = "###sub###";
 String sup = "###sup###";
 String bold = "###bol###";
 String italic = "###ita###";
 String code = "###code###";
 List<String> styles = [];
 int? i;

 value = value.trim();

  while (true) {

    List<int> leastIndex = [
      value.indexOf(under),
      value.indexOf(over),
      value.indexOf(strike),
      value.indexOf(sub),
      value.indexOf(sup),
      value.indexOf(bold),
      value.indexOf(italic),
      value.indexOf(code),
    ];

    if(leastIndex.isNotEmpty) leastIndex.removeWhere((element) => element == -1);
    if(leastIndex.isNotEmpty) i = leastIndex.reduce(min);

    if(leastIndex.isEmpty) { //check for no matches
      if (S.isNullOrEmpty(value)) return;
      textValues.add(TextValue(List.from(styles), value.substring(0)));
      return;
    }

    if (i! > 0) { //if index > 0 return value with styles attached
      textValues.add(TextValue(List.from(styles), value.substring(0, i))); //return everything before the match with styles attached
      value = value.substring(i);
    }


    if (value.substring(0, 9) == under) {
      if(styles.contains("underline")) {
        styles.remove("underline");
      } else {
        styles.add("underline");
      }

      value = value.substring(9);
    }

    else if (value.substring(0, 9) == over) {
      if(styles.contains("overline")) {
        styles.remove("overline");
      } else {
        styles.add("overline");
      }

      value = value.substring(9);
    }

    else if (value.substring(0, 9) == strike) {
      if(styles.contains("strikethrough")) {
        styles.remove("strikethrough");
      } else {
        styles.add("strikethrough");
      }

      value = value.substring(9);
    }

    else if (value.substring(0, 9) == sub) {
      if(styles.contains("subscript")) {
        styles.remove("subscript");
      } else {
        styles.add("subscript");
      }

      value = value.substring(9);
    }

    else if (value.substring(0, 9) == sup) {
      if(styles.contains("superscript")) {
        styles.remove("superscript");
      } else {
        styles.add("superscript");
      }

      value = value.substring(9);
    }

    else if (value.substring(0, 9) == bold) {
      if(styles.contains("bold")) {
        styles.remove("bold");
      } else {
        styles.add("bold");
      }

      value = value.substring(9);
    }

    else if (value.substring(0, 9) == italic) {
      if(styles.contains("italic")) {
        styles.remove("italic");
      } else {
        styles.add("italic");
      }

      value = value.substring(9);
    }

    else if (value.substring(0, 10) == code) {
      if(styles.contains("code")) {
        styles.remove("code");
      } else {
        styles.add("code");
      }

      value = value.substring(10);
    }

    else {
      return;
    }

  }
}

