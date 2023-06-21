// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fml/helper/color.dart';
import 'package:fml/hive/settings.dart';
import 'package:fml/system.dart';
import 'package:google_fonts/google_fonts.dart' deferred as fonts;

class ThemeNotifier with ChangeNotifier
{
  // google fonts
  static Completer? libraryLoader;
  ThemeData _themeData;

  ThemeNotifier(this._themeData)
  {
    // load the library
    if (libraryLoader == null)
    {
      libraryLoader = Completer();
      fonts.loadLibrary().then((value) => libraryLoader!.complete(true));
    }

    // wait for the library to load
    if (!libraryLoader!.isCompleted) {
      libraryLoader!.future.whenComplete(()
    {
      setTheme(System.theme.brightness ?? 'light', System.theme.colorscheme ?? 'lightblue');
    });
    }
  }
  getTheme() => _themeData;

  void mapSystemThemeBindables()
  {
    // System().brightness           = _themeData.brightness == Brightness.dark ? 'dark' : 'light';
    // System().colorscheme          = 'lightblue';

    System.theme.background           = _themeData.colorScheme.background;
    System.theme.onbackground         = _themeData.colorScheme.onBackground;
    System.theme.shadow               = _themeData.colorScheme.shadow;
    System.theme.outline              = _themeData.colorScheme.outline;

    System.theme.surface              = _themeData.colorScheme.surface;
    System.theme.onsurface            = _themeData.colorScheme.onSurface;
    System.theme.surfacevariant       = _themeData.colorScheme.surfaceVariant;
    System.theme.onsurfacevariant     = _themeData.colorScheme.onSurfaceVariant;
    System.theme.inversesurface       = _themeData.colorScheme.inverseSurface;
    System.theme.oninversesurface     = _themeData.colorScheme.onInverseSurface;

    System.theme.primary              = _themeData.colorScheme.primary;
    System.theme.onprimary            = _themeData.colorScheme.onPrimary;
    System.theme.primarycontainer     = _themeData.colorScheme.primaryContainer;
    System.theme.onprimarycontainer   = _themeData.colorScheme.onPrimaryContainer;
    System.theme.inverseprimary       = _themeData.colorScheme.inversePrimary;

    System.theme.secondary            = _themeData.colorScheme.secondary;
    System.theme.onsecondary          = _themeData.colorScheme.onSecondary;
    System.theme.secondarycontainer   = _themeData.colorScheme.secondaryContainer;
    System.theme.onsecondarycontainer = _themeData.colorScheme.onSecondaryContainer;

    System.theme.tertiarycontainer    = _themeData.colorScheme.tertiaryContainer;
    System.theme.ontertiarycontainer  = _themeData.colorScheme.onTertiaryContainer;

    System.theme.error                = _themeData.colorScheme.error;
    System.theme.onerror              = _themeData.colorScheme.onError;
    System.theme.errorcontainer       = _themeData.colorScheme.errorContainer;
    System.theme.onerrorcontainer     = _themeData.colorScheme.onErrorContainer;
  }

  setTheme(String sBrightness, [String? sColor, Map<String, String>? schemeColors]) async
  {
    Brightness brightness = await Settings().get('brightness') == 'dark' ? Brightness.dark : Brightness.light;

    TextTheme? fontTheme = (libraryLoader?.isCompleted ?? false) ? fonts.GoogleFonts.getTextTheme(System.theme.font) : null;
    if (sBrightness.toLowerCase() == 'light')
    {
      brightness = Brightness.light;
      System.theme.brightness = sBrightness.toLowerCase();
    }
    else if (sBrightness.toLowerCase() == 'dark')
    {
      brightness = Brightness.dark;
      System.theme.brightness = sBrightness.toLowerCase();
    }
    Settings().set('brightness', sBrightness);
    if (sColor != null)
    {
      Color? colorScheme = ColorHelper.fromString(sColor);
      System.theme.colorscheme = sColor;
      ThemeData themeData = ThemeData(colorSchemeSeed: colorScheme, brightness: brightness, fontFamily: System.theme.font, textTheme: fontTheme, useMaterial3: true);
      _themeData = themeData;
    }
    else
    {
      ThemeData themeData = ThemeData(brightness: brightness, colorSchemeSeed: ColorHelper.fromString(System.theme.colorscheme), fontFamily: System.theme.font, textTheme: fontTheme, useMaterial3: true);
      _themeData = themeData;
    }
    notifyListeners();
  }
}