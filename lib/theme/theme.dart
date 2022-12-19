// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/navigation/transition.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/theme/theme_model.dart' as THEME;
import 'package:google_fonts/google_fonts.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/helper_barrel.dart';

MyTheme theme = MyTheme();

class MyTheme
{
  static final MyTheme _singleton = MyTheme._init();
  static const String font = 'Roboto';
  static Brightness? brightnessPreference;

  factory MyTheme()
  {
    return _singleton;
  }

  MyTheme._init()
  {
    init();
  }

  Future<bool> init() async
  {
    // await getBrightness();
    return true;
  }

  /// Derive theme from a color value and a https://fonts.google.com/ font
  ThemeData deriveTheme(String? fromValue, {String googleFont = font}) {
    Color? col = ColorObservable.toColor(fromValue);
    Brightness? b = getBrightness();
    return ThemeData(
        colorSchemeSeed: col ?? Colors.blueGrey,
        brightness: b,
        fontFamily: font,
        textTheme: GoogleFonts.getTextTheme(googleFont),
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.android: CustomTransitionBuilder('android'),
          TargetPlatform.iOS: CustomTransitionBuilder('ios'),
          TargetPlatform.macOS: CustomTransitionBuilder('macos'),
          TargetPlatform.windows: CustomTransitionBuilder('windows'),
          TargetPlatform.linux: CustomTransitionBuilder('linux'),
        }),
        useMaterial3: true);
  }

  getBrightness() {
    String? brightness = /*await Settings().get('brightness') ??*/ System().brightness;

    if (brightness != null) {
      if (brightness == 'system' || brightness == 'platform')
        brightnessPreference = MediaQueryData.fromWindow(WidgetsBinding.instance.window).platformBrightness;
      else if (brightness == 'dark')
        brightnessPreference = Brightness.dark;
      else if (brightness == 'light')
        brightnessPreference = Brightness.light;
    }
    else
      brightnessPreference = Brightness.light;
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

ThemeData applyCustomizations(ColorScheme base, THEME.ThemeModel m) {
  var customizedTheme;
  try {
    customizedTheme = ThemeData.from(
      colorScheme: ColorScheme(
        brightness: m.brightness == 'dark' ? Brightness.dark : Brightness.light,
        background: S.toColor(m.background) ?? base.background,
        onBackground: S.toColor(m.onbackground) ?? base.onBackground,
        shadow: S.toColor(m.shadow) ?? base.shadow,
        outline: S.toColor(m.outline) ?? base.outline,
        surface: S.toColor(m.surface) ?? base.surface,
        onSurface: S.toColor(m.onsurface) ?? base.onSurface,
        surfaceVariant: S.toColor(m.surfacevariant) ?? base.surfaceVariant,
        onSurfaceVariant: S.toColor(m.onsurfacevariant) ?? base.onSurfaceVariant,
        inverseSurface: S.toColor(m.inversesurface) ?? base.inverseSurface,
        onInverseSurface: S.toColor(m.oninversesurface) ?? base.onInverseSurface,
        primary: S.toColor(m.primary) ?? base.primary,
        onPrimary: S.toColor(m.onprimary) ?? base.onPrimary,
        primaryContainer: S.toColor(m.primarycontainer) ?? base.primaryContainer,
        onPrimaryContainer: S.toColor(m.onprimarycontainer) ?? base.onPrimaryContainer,
        inversePrimary: S.toColor(m.inverseprimary) ?? base.inversePrimary,
        secondary: S.toColor(m.secondary) ?? base.secondary,
        onSecondary: S.toColor(m.onsecondary) ?? base.onSecondary,
        secondaryContainer: S.toColor(m.secondarycontainer) ?? base.secondaryContainer,
        onSecondaryContainer: S.toColor(m.onsecondarycontainer) ?? base.onSecondaryContainer,
        tertiaryContainer: S.toColor(m.tertiarycontainer) ?? base.tertiaryContainer,
        onTertiaryContainer: S.toColor(m.ontertiarycontainer) ?? base.onTertiaryContainer,
        error: S.toColor(m.error) ?? base.error,
        onError: S.toColor(m.onerror) ?? base.onError,
        errorContainer: S.toColor(m.errorcontainer) ?? base.errorContainer,
        onErrorContainer: S.toColor(m.onerrorcontainer) ?? base.onErrorContainer,
      ),
      useMaterial3: true,
    );
  } catch(e) {
    Log().exception(e);
  }
  return customizedTheme ?? ThemeData.from(colorScheme: base, useMaterial3: true);
}

