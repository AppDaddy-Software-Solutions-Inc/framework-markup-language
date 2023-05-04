// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:math';

import 'package:flutter/material.dart';
import '../scope.dart';
import '../observable.dart' ;

class ColorObservable extends Observable
{
  static Map<String,Color> colors =
  {
    'red'                 : Colors.red,
    'redaccent'           : Colors.redAccent,
    'pink'                : Colors.pink,
    'pinkaccent'          : Colors.pinkAccent,
    'purple'              : Colors.purple,
    'purpleaccent'        : Colors.purpleAccent,
    'deeppurple'          : Colors.deepPurple,
    'deeppurpleaccent'    : Colors.deepPurpleAccent,
    'indigo'              : Colors.indigo,
    'indigoaccent'        : Colors.indigoAccent,
    'blue'                : Colors.blue,
    'blueaccent'          : Colors.blueAccent,
    'lightblue'           : Colors.lightBlue,
    'lightblueaccent'     : Colors.lightBlueAccent,
    'cyan'                : Colors.cyan,
    'cyanaccent'          : Colors.cyanAccent,
    'teal'                : Colors.teal,
    'tealaccent'          : Colors.tealAccent,
    'green'               : Colors.green,
    'greenaccent'         : Colors.greenAccent,
    'lightgreen'          : Colors.lightGreen,
    'lightgreenaccent'    : Colors.lightGreenAccent,
    'lime'                : Colors.lime,
    'limeaccent'          : Colors.limeAccent,
    'yellow'              : Colors.yellow,
    'yellowaccent'        : Colors.yellowAccent,
    'amber'               : Colors.amber,
    'amberaccent'         : Colors.amberAccent,
    'orange'              : Colors.orange,
    'orangeaccent'        : Colors.orangeAccent,
    'deeporange'          : Colors.deepOrange,
    'deeporangeaccent'    : Colors.deepOrangeAccent,
    'brown'               : Colors.brown,
    'black'               : Colors.black,
    'bluegrey'            : Colors.blueGrey,
    'grey'                : Colors.grey,
    'white'               : Colors.white,
    'blur'                : Colors.white10,
    'transparent'         : Colors.transparent,
    
    'red50'               : Colors.red.shade50,
    'red100'              : Colors.red.shade100,
    'red200'              : Colors.red.shade200,
    'red300'              : Colors.red.shade300,
    'red400'              : Colors.red.shade400,
    'red500'              : Colors.red.shade500,
    'red600'              : Colors.red.shade600,
    'red700'              : Colors.red.shade700,
    'red800'              : Colors.red.shade800,
    'red900'              : Colors.red.shade900,

    'redaccent100'        : Colors.redAccent.shade100,
    'redaccent200'        : Colors.redAccent.shade200,
    'redaccent400'        : Colors.redAccent.shade400,
    'redaccent700'        : Colors.redAccent.shade700,

    'pink50'              : Colors.pink.shade50,
    'pink100'             : Colors.pink.shade100,
    'pink200'             : Colors.pink.shade200,
    'pink300'             : Colors.pink.shade300,
    'pink400'             : Colors.pink.shade400,
    'pink500'             : Colors.pink.shade500,
    'pink600'             : Colors.pink.shade600,
    'pink700'             : Colors.pink.shade700,
    'pink800'             : Colors.pink.shade800,
    'pink900'             : Colors.pink.shade900,

    'pinkaccent100'       : Colors.pinkAccent.shade100,
    'pinkaccent200'       : Colors.pinkAccent.shade200,
    'pinkaccent400'       : Colors.pinkAccent.shade400,
    'pinkaccent700'       : Colors.pinkAccent.shade700,

    'purple50'            : Colors.purple.shade50,
    'purple100'           : Colors.purple.shade100,
    'purple200'           : Colors.purple.shade200,
    'purple300'           : Colors.purple.shade300,
    'purple400'           : Colors.purple.shade400,
    'purple500'           : Colors.purple.shade500,
    'purple600'           : Colors.purple.shade600,
    'purple700'           : Colors.purple.shade700,
    'purple800'           : Colors.purple.shade800,
    'purple900'           : Colors.purple.shade900,

    'purpleaccent100'     : Colors.purpleAccent.shade100,
    'purpleaccent200'     : Colors.purpleAccent.shade200,
    'purpleaccent400'     : Colors.purpleAccent.shade400,
    'purpleaccent700'     : Colors.purpleAccent.shade700,

    'deeppurple50'        : Colors.deepPurple.shade50,
    'deeppurple100'       : Colors.deepPurple.shade100,
    'deeppurple200'       : Colors.deepPurple.shade200,
    'deeppurple300'       : Colors.deepPurple.shade300,
    'deeppurple400'       : Colors.deepPurple.shade400,
    'deeppurple500'       : Colors.deepPurple.shade500,
    'deeppurple600'       : Colors.deepPurple.shade600,
    'deeppurple700'       : Colors.deepPurple.shade700,
    'deeppurple800'       : Colors.deepPurple.shade800,
    'deeppurple900'       : Colors.deepPurple.shade900,

    'deeppurpleaccent100' : Colors.deepPurpleAccent.shade100,
    'deeppurpleaccent200' : Colors.deepPurpleAccent.shade200,
    'deeppurpleaccent400' : Colors.deepPurpleAccent.shade400,
    'deeppurpleaccent700' : Colors.deepPurpleAccent.shade700,

    'indigo50'            : Colors.indigo.shade50,
    'indigo100'           : Colors.indigo.shade100,
    'indigo200'           : Colors.indigo.shade200,
    'indigo300'           : Colors.indigo.shade300,
    'indigo400'           : Colors.indigo.shade400,
    'indigo500'           : Colors.indigo.shade500,
    'indigo600'           : Colors.indigo.shade600,
    'indigo700'           : Colors.indigo.shade700,
    'indigo800'           : Colors.indigo.shade800,
    'indigo900'           : Colors.indigo.shade900,

    'indigoaccent100'     : Colors.indigoAccent.shade100,
    'indigoaccent200'     : Colors.indigoAccent.shade200,
    'indigoaccent400'     : Colors.indigoAccent.shade400,
    'indigoaccent700'     : Colors.indigoAccent.shade700,

    'blue50'              : Colors.blue.shade50,
    'blue100'             : Colors.blue.shade100,
    'blue200'             : Colors.blue.shade200,
    'blue300'             : Colors.blue.shade300,
    'blue400'             : Colors.blue.shade400,
    'blue500'             : Colors.blue.shade500,
    'blue600'             : Colors.blue.shade600,
    'blue700'             : Colors.blue.shade700,
    'blue800'             : Colors.blue.shade800,
    'blue900'             : Colors.blue.shade900,

    'blueaccent100'       : Colors.blueAccent.shade100,
    'blueaccent200'       : Colors.blueAccent.shade200,
    'blueaccent400'       : Colors.blueAccent.shade400,
    'blueaccent700'       : Colors.blueAccent.shade700,

    'lightblue50'         : Colors.lightBlue.shade50,
    'lightblue100'        : Colors.lightBlue.shade100,
    'lightblue200'        : Colors.lightBlue.shade200,
    'lightblue300'        : Colors.lightBlue.shade300,
    'lightblue400'        : Colors.lightBlue.shade400,
    'lightblue500'        : Colors.lightBlue.shade500,
    'lightblue600'        : Colors.lightBlue.shade600,
    'lightblue700'        : Colors.lightBlue.shade700,
    'lightblue800'        : Colors.lightBlue.shade800,
    'lightblue900'        : Colors.lightBlue.shade900,

    'lightblueaccent100'  : Colors.lightBlueAccent.shade100,
    'lightblueaccent200'  : Colors.lightBlueAccent.shade200,
    'lightblueaccent400'  : Colors.lightBlueAccent.shade400,
    'lightblueaccent700'  : Colors.lightBlueAccent.shade700,

    'cyan50'              : Colors.cyan.shade50,
    'cyan100'             : Colors.cyan.shade100,
    'cyan200'             : Colors.cyan.shade200,
    'cyan300'             : Colors.cyan.shade300,
    'cyan400'             : Colors.cyan.shade400,
    'cyan500'             : Colors.cyan.shade500,
    'cyan600'             : Colors.cyan.shade600,
    'cyan700'             : Colors.cyan.shade700,
    'cyan800'             : Colors.cyan.shade800,
    'cyan900'             : Colors.cyan.shade900,

    'cyanaccent100'       : Colors.cyanAccent.shade100,
    'cyanaccent200'       : Colors.cyanAccent.shade200,
    'cyanaccent400'       : Colors.cyanAccent.shade400,
    'cyanaccent700'       : Colors.cyanAccent.shade700,

    'teal50'              : Colors.teal.shade50,
    'teal100'             : Colors.teal.shade100,
    'teal200'             : Colors.teal.shade200,
    'teal300'             : Colors.teal.shade300,
    'teal400'             : Colors.teal.shade400,
    'teal500'             : Colors.teal.shade500,
    'teal600'             : Colors.teal.shade600,
    'teal700'             : Colors.teal.shade700,
    'teal800'             : Colors.teal.shade800,
    'teal900'             : Colors.teal.shade900,

    'tealaccent100'       : Colors.tealAccent.shade100,
    'tealaccent200'       : Colors.tealAccent.shade200,
    'tealaccent400'       : Colors.tealAccent.shade400,
    'tealaccent700'       : Colors.tealAccent.shade700,

    'green50'             : Colors.green.shade50,
    'green100'            : Colors.green.shade100,
    'green200'            : Colors.green.shade200,
    'green300'            : Colors.green.shade300,
    'green400'            : Colors.green.shade400,
    'green500'            : Colors.green.shade500,
    'green600'            : Colors.green.shade600,
    'green700'            : Colors.green.shade700,
    'green800'            : Colors.green.shade800,
    'green900'            : Colors.green.shade900,

    'greenaccent100'      : Colors.greenAccent.shade100,
    'greenaccent200'      : Colors.greenAccent.shade200,
    'greenaccent400'      : Colors.greenAccent.shade400,
    'greenaccent700'      : Colors.greenAccent.shade700,

    'lightgreen50'        : Colors.lightGreen.shade50,
    'lightgreen100'       : Colors.lightGreen.shade100,
    'lightgreen200'       : Colors.lightGreen.shade200,
    'lightgreen300'       : Colors.lightGreen.shade300,
    'lightgreen400'       : Colors.lightGreen.shade400,
    'lightgreen500'       : Colors.lightGreen.shade500,
    'lightgreen600'       : Colors.lightGreen.shade600,
    'lightgreen700'       : Colors.lightGreen.shade700,
    'lightgreen800'       : Colors.lightGreen.shade800,
    'lightgreen900'       : Colors.lightGreen.shade900,

    'lightgreenaccent100' : Colors.lightGreenAccent.shade100,
    'lightgreenaccent200' : Colors.lightGreenAccent.shade200,
    'lightgreenaccent400' : Colors.lightGreenAccent.shade400,
    'lightgreenaccent700' : Colors.lightGreenAccent.shade700,

    'lime50'              : Colors.lime.shade50,
    'lime100'             : Colors.lime.shade100,
    'lime200'             : Colors.lime.shade200,
    'lime300'             : Colors.lime.shade300,
    'lime400'             : Colors.lime.shade400,
    'lime500'             : Colors.lime.shade500,
    'lime600'             : Colors.lime.shade600,
    'lime700'             : Colors.lime.shade700,
    'lime800'             : Colors.lime.shade800,
    'lime900'             : Colors.lime.shade900,

    'limeaccent100'       : Colors.limeAccent.shade100,
    'limeaccent200'       : Colors.limeAccent.shade200,
    'limeaccent400'       : Colors.limeAccent.shade400,
    'limeaccent700'       : Colors.limeAccent.shade700,

    'yellow50'            : Colors.yellow.shade50,
    'yellow100'           : Colors.yellow.shade100,
    'yellow200'           : Colors.yellow.shade200,
    'yellow300'           : Colors.yellow.shade300,
    'yellow400'           : Colors.yellow.shade400,
    'yellow500'           : Colors.yellow.shade500,
    'yellow600'           : Colors.yellow.shade600,
    'yellow700'           : Colors.yellow.shade700,
    'yellow800'           : Colors.yellow.shade800,
    'yellow900'           : Colors.yellow.shade900,

    'yellowaccent100'     : Colors.yellowAccent.shade100,
    'yellowaccent200'     : Colors.yellowAccent.shade200,
    'yellowaccent400'     : Colors.yellowAccent.shade400,
    'yellowaccent700'     : Colors.yellowAccent.shade700,

    'amber50'             : Colors.amber.shade50,
    'amber100'            : Colors.amber.shade100,
    'amber200'            : Colors.amber.shade200,
    'amber300'            : Colors.amber.shade300,
    'amber400'            : Colors.amber.shade400,
    'amber500'            : Colors.amber.shade500,
    'amber600'            : Colors.amber.shade600,
    'amber700'            : Colors.amber.shade700,
    'amber800'            : Colors.amber.shade800,
    'amber900'            : Colors.amber.shade900,

    'amberaccent100'      : Colors.amberAccent.shade100,
    'amberaccent200'      : Colors.amberAccent.shade200,
    'amberaccent400'      : Colors.amberAccent.shade400,
    'amberaccent700'      : Colors.amberAccent.shade700,

    'orange50'            : Colors.orange.shade50,
    'orange100'           : Colors.orange.shade100,
    'orange200'           : Colors.orange.shade200,
    'orange300'           : Colors.orange.shade300,
    'orange400'           : Colors.orange.shade400,
    'orange500'           : Colors.orange.shade500,
    'orange600'           : Colors.orange.shade600,
    'orange700'           : Colors.orange.shade700,
    'orange800'           : Colors.orange.shade800,
    'orange900'           : Colors.orange.shade900,

    'orangeaccent100'     : Colors.orangeAccent.shade100,
    'orangeaccent200'     : Colors.orangeAccent.shade200,
    'orangeaccent400'     : Colors.orangeAccent.shade400,
    'orangeaccent700'     : Colors.orangeAccent.shade700,

    'deeporange50'        : Colors.deepOrange.shade50,
    'deeporange100'       : Colors.deepOrange.shade100,
    'deeporange200'       : Colors.deepOrange.shade200,
    'deeporange300'       : Colors.deepOrange.shade300,
    'deeporange400'       : Colors.deepOrange.shade400,
    'deeporange500'       : Colors.deepOrange.shade500,
    'deeporange600'       : Colors.deepOrange.shade600,
    'deeporange700'       : Colors.deepOrange.shade700,
    'deeporange800'       : Colors.deepOrange.shade800,
    'deeporange900'       : Colors.deepOrange.shade900,

    'deeporangeaccent100' : Colors.deepOrangeAccent.shade100,
    'deeporangeaccent200' : Colors.deepOrangeAccent.shade200,
    'deeporangeaccent400' : Colors.deepOrangeAccent.shade400,
    'deeporangeaccent700' : Colors.deepOrangeAccent.shade700,

    'brown50'             : Colors.brown.shade50,
    'brown100'            : Colors.brown.shade100,
    'brown200'            : Colors.brown.shade200,
    'brown300'            : Colors.brown.shade300,
    'brown400'            : Colors.brown.shade400,
    'brown500'            : Colors.brown.shade500,
    'brown600'            : Colors.brown.shade600,
    'brown700'            : Colors.brown.shade700,
    'brown800'            : Colors.brown.shade800,
    'brown900'            : Colors.brown.shade900,

    'grey50'             : Colors.grey.shade50,
    'grey100'            : Colors.grey.shade100,
    'grey200'            : Colors.grey.shade200,
    'grey300'            : Colors.grey.shade300,
    'grey400'            : Colors.grey.shade400,
    'grey500'            : Colors.grey.shade500,
    'grey600'            : Colors.grey.shade600,
    'grey700'            : Colors.grey.shade700,
    'grey800'            : Colors.grey.shade800,
    'grey900'            : Colors.grey.shade900,
    
  };

  // 20 brightness neutral colors in an aesthetically appealing order
  static List<Color?> niceColors = [
    colors['blue600'],
    colors['lightblue'],
    colors['cyan'],
    colors['teal'],
    colors['green'],
    colors['lightgreen'],
    colors['lime700'],
    colors['amber'],
    colors['orange'],
    colors['deeporangeaccent'],
    colors['red'],
    colors['pink'],
    colors['pinkaccent'],
    colors['purpleaccent'],
    colors['purple'],
    colors['deeppurpleaccent'],
    colors['indigo'],
    colors['indigoaccent'],
    colors['bluegrey'],
    colors['brown'],
  ];

  ColorObservable(String? name, dynamic value, {Scope? scope, OnChangeCallback? listener, Getter? getter, Setter? setter}) : super(name, value, scope: scope, listener: listener, getter: getter, setter: setter);

  @override
  Color? get()
  {
    dynamic value = super.get();
    return (value is Color) ? value : null;
  }

  @override
  dynamic to(dynamic value)
  {
    try
    {
      if (value == null)   return null;
      if (value is Color)  return value;
      if (value is String) return toColor(value);
      return Exception();
    }
    catch(e)
    {
      return e;
    }
  }

  static Color? toColor(String? color)
  {
    Color? c;
    try
    {
      if (color != null && color != '')
      {
        // color code
        if (colors.containsKey(color.toLowerCase())) {
          c = colors[color.toLowerCase()];
        } else if (color.toLowerCase() == 'random') {
          c = colors[colors.keys.elementAt(Random().nextInt(colors.length))];
        } else if (color.length == 7 && color.startsWith('#')) {
          c = Color(int.parse(color.substring(1, 7), radix: 16) + 0xFF000000);
        } else if (color.length == 9 && color.startsWith('#')) {
          c = Color(int.parse(color.substring(1, 9), radix: 16) + 0x00000000);
        } else if (color.length == 8 && color.startsWith('0x')) {
          c = Color(int.parse(color.substring(2, 8), radix: 16) + 0xFF000000);
        } else if (color.length == 10 && color.startsWith('0x')) {
          c = Color(int.parse(color.substring(2, 10), radix: 16) + 0x00000000);
        } else if (color.length == 17 && color.startsWith('Color(0x')) {
          c = Color(int.parse(color.substring(8, 16), radix: 16) + 0x00000000);
        }
      }
    }
    catch(e)
    {
      c = null;
    }
    return c;
  }
}