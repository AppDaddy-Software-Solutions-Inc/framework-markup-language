// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/theme/theme_model.dart';
import 'package:fml/helper/common_helpers.dart';

MyTheme theme = MyTheme();

class MyTheme {
  static final MyTheme _singleton = MyTheme._init();
  static const String font = 'Roboto';
  static Brightness? brightnessPreference;

  factory MyTheme() => _singleton;

  MyTheme._init();

  /// Derive theme from a color value and a https://fonts.google.com/ font
  ThemeData deriveTheme(String? fromValue, {String googleFont = font}) {
    Color? col = ColorHelper.fromString(fromValue);
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
      colorScheme: ColorScheme(
        brightness: m.brightness == 'dark' ? Brightness.dark : Brightness.light,
        background: ColorHelper.fromString(m.background) ?? base.background,
        onBackground: ColorHelper.fromString(m.onbackground) ?? base.onBackground,
        shadow: ColorHelper.fromString(m.shadow) ?? base.shadow,
        outline: ColorHelper.fromString(m.outline) ?? base.outline,
        surface: ColorHelper.fromString(m.surface) ?? base.surface,
        onSurface: ColorHelper.fromString(m.onsurface) ?? base.onSurface,
        surfaceVariant: ColorHelper.fromString(m.surfacevariant) ?? base.surfaceVariant,
        onSurfaceVariant:
            ColorHelper.fromString(m.onsurfacevariant) ?? base.onSurfaceVariant,
        inverseSurface: ColorHelper.fromString(m.inversesurface) ?? base.inverseSurface,
        onInverseSurface:
            ColorHelper.fromString(m.oninversesurface) ?? base.onInverseSurface,
        primary: ColorHelper.fromString(m.primary) ?? base.primary,
        onPrimary: ColorHelper.fromString(m.onprimary) ?? base.onPrimary,
        primaryContainer:
            ColorHelper.fromString(m.primarycontainer) ?? base.primaryContainer,
        onPrimaryContainer:
            ColorHelper.fromString(m.onprimarycontainer) ?? base.onPrimaryContainer,
        inversePrimary: ColorHelper.fromString(m.inverseprimary) ?? base.inversePrimary,
        secondary: ColorHelper.fromString(m.secondary) ?? base.secondary,
        onSecondary: ColorHelper.fromString(m.onsecondary) ?? base.onSecondary,
        secondaryContainer:
            ColorHelper.fromString(m.secondarycontainer) ?? base.secondaryContainer,
        onSecondaryContainer:
            ColorHelper.fromString(m.onsecondarycontainer) ?? base.onSecondaryContainer,
        tertiaryContainer:
            ColorHelper.fromString(m.tertiarycontainer) ?? base.tertiaryContainer,
        onTertiaryContainer:
            ColorHelper.fromString(m.ontertiarycontainer) ?? base.onTertiaryContainer,
        error: ColorHelper.fromString(m.error) ?? base.error,
        onError: ColorHelper.fromString(m.onerror) ?? base.onError,
        errorContainer: ColorHelper.fromString(m.errorcontainer) ?? base.errorContainer,
        onErrorContainer:
            ColorHelper.fromString(m.onerrorcontainer) ?? base.onErrorContainer,
      ),
      useMaterial3: true,
    );
  } catch (e) {
    Log().exception(e);
  }
  return customizedTheme ??
      ThemeData.from(colorScheme: base, useMaterial3: true);
}
