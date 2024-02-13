// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/theme/theme_model.dart';
import 'package:fml/helpers/helpers.dart';

MyTheme theme = MyTheme();

class MyTheme {
  static final MyTheme _singleton = MyTheme._init();
  static const String font = 'Roboto';
  static Brightness? brightnessPreference;

  factory MyTheme() => _singleton;

  MyTheme._init();

  /// Derive theme from a color value and a https://fonts.google.com/ font
  ThemeData deriveTheme(dynamic fromValue, {String googleFont = font})
  {
    Color? col = toColor(fromValue);
    Brightness? b = getBrightness();

    return ThemeData(
        colorSchemeSeed: col ?? Colors.blueGrey,
        brightness: b,
        fontFamily: font,
        // pageTransitionsTheme: PageTransitionsTheme(builders: {
        //   TargetPlatform.android: CustomTransitionBuilder('android'),
        //   TargetPlatform.iOS: CustomTransitionBuilder('ios'),
        //   TargetPlatform.macOS: CustomTransitionBuilder('macos'),
        //   TargetPlatform.windows: CustomTransitionBuilder('windows'),
        //   TargetPlatform.linux: CustomTransitionBuilder('linux'),
        // }),
        useMaterial3: true);
  }

  getBrightness() {
    String? brightness = /*await Settings().get('brightness') ??*/
        System.theme.brightness;
    if (brightness != null) {
      if (brightness == 'system' || brightness == 'platform') {
        brightnessPreference = PlatformDispatcher.instance.platformBrightness;
      } else if (brightness == 'dark') {
        brightnessPreference = Brightness.dark;
      } else if (brightness == 'light') {
        brightnessPreference = Brightness.light;
      }
    } else {
      brightnessPreference = Brightness.light;
    }
    return brightnessPreference;
  }

  // Map<String, ThemeData> themeList = {
  //   'default':    ThemeData(colorSchemeSeed: Colors.blueGrey,   brightness: brightnessPreference, fontFamily: font, useMaterial3: true),
  //   'red':        ThemeData(colorSchemeSeed: Colors.red,        brightness: brightnessPreference, fontFamily: font, useMaterial3: true),
  //   'pink':       ThemeData(colorSchemeSeed: Colors.pink,       brightness: brightnessPreference, fontFamily: font, useMaterial3: true),
  //   'purple':     ThemeData(colorSchemeSeed: Colors.purple,     brightness: brightnessPreference, fontFamily: font, useMaterial3: true),
  //   'deeppurple': ThemeData(colorSchemeSeed: Colors.deepPurple, brightness: brightnessPreference, fontFamily: font, useMaterial3: true),
  //   'indigo':     ThemeData(colorSchemeSeed: Colors.indigo,     brightness: brightnessPreference, fontFamily: font, useMaterial3: true),
  //   'blue':       ThemeData(colorSchemeSeed: Colors.blue,       brightness: brightnessPreference, fontFamily: font, useMaterial3: true),
  //   'lightblue':  ThemeData(colorSchemeSeed: Colors.lightBlue,  brightness: brightnessPreference, fontFamily: font, useMaterial3: true),
  //   'cyan':       ThemeData(colorSchemeSeed: Colors.cyan,       brightness: brightnessPreference, fontFamily: font, useMaterial3: true),
  //   'teal':       ThemeData(colorSchemeSeed: Colors.teal,       brightness: brightnessPreference, fontFamily: font, useMaterial3: true),
  //   'green':      ThemeData(colorSchemeSeed: Colors.green,      brightness: brightnessPreference, fontFamily: font, useMaterial3: true),
  //   'lightgreen': ThemeData(colorSchemeSeed: Colors.lightGreen, brightness: brightnessPreference, fontFamily: font, useMaterial3: true),
  //   'lime':       ThemeData(colorSchemeSeed: Colors.lime,       brightness: brightnessPreference, fontFamily: font, useMaterial3: true),
  //   'yellow':     ThemeData(colorSchemeSeed: Colors.yellow,     brightness: brightnessPreference, fontFamily: font, useMaterial3: true),
  //   'amber':      ThemeData(colorSchemeSeed: Colors.amber,      brightness: brightnessPreference, fontFamily: font, useMaterial3: true),
  //   'orange':     ThemeData(colorSchemeSeed: Colors.orange,     brightness: brightnessPreference, fontFamily: font, useMaterial3: true),
  //   'deeporange': ThemeData(colorSchemeSeed: Colors.deepOrange, brightness: brightnessPreference, fontFamily: font, useMaterial3: true),
  //   'brown':      ThemeData(colorSchemeSeed: Colors.brown,      brightness: brightnessPreference, fontFamily: font, useMaterial3: true),
  //   'bluegrey':   ThemeData(colorSchemeSeed: Colors.blueGrey,   brightness: brightnessPreference, fontFamily: font, useMateriThemeModeltrue),
  // };
}

ThemeData applyCustomizations(ColorScheme base, ThemeModel m) {
  ThemeData? customizedTheme;
  try {
    customizedTheme = ThemeData.from(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: m.brightness == 'dark' ? Brightness.dark : Brightness.light,
        background: m.background ?? base.background,
        onBackground: m.onBackground ?? base.onBackground,
        shadow: m.shadow ?? base.shadow,
        outline: m.outline ?? base.outline,
        surface: m.surface ?? base.surface,
        onSurface: m.onSurface ?? base.onSurface,
        surfaceVariant: m.surfaceVariant ?? base.surfaceVariant,
        onSurfaceVariant: m.onSurfaceVariant ?? base.onSurfaceVariant,
        inverseSurface: m.inverseSurface ?? base.inverseSurface,
        onInverseSurface: m.onInverseSurface ?? base.onInverseSurface,
        primary: m.primary ?? base.primary,
        onPrimary: m.onPrimary ?? base.onPrimary,
        primaryContainer: m.primaryContainer ?? base.primaryContainer,
        onPrimaryContainer: m.onPrimaryContainer ?? base.onPrimaryContainer,
        inversePrimary: m.inversePrimary ?? base.inversePrimary,
        secondary: m.secondary ?? base.secondary,
        onSecondary: m.onSecondary ?? base.onSecondary,
        secondaryContainer: m.secondaryContainer ?? base.secondaryContainer,
        onSecondaryContainer: m.onSecondaryContainer ?? base.onSecondaryContainer,
        tertiaryContainer: m.tertiaryContainer ?? base.tertiaryContainer,
        onTertiaryContainer: m.onTertiaryContainer ?? base.onTertiaryContainer,
        error: m.error ?? base.error,
        onError: m.onError ?? base.onError,
        errorContainer: m.errorContainer ?? base.errorContainer,
        onErrorContainer: m.onErrorContainer ?? base.onErrorContainer,
      ));
  }
  catch (e) {
    Log().exception(e);
  }
  return customizedTheme ??
      ThemeData.from(colorScheme: base, useMaterial3: true);
}
