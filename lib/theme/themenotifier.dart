// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fml/helpers/string.dart';
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
    if (!libraryLoader!.isCompleted)
    {
      libraryLoader!.future.whenComplete(() {
        setTheme(brightness: System.theme.brightness ?? 'light', color: toStr(System.theme.colorScheme ?? 'lightblue'));
      });
    }
  }
  getTheme() => _themeData;

  void mapSystemThemeBindables()
  {
    System.theme.background           = _themeData.colorScheme.background;
    System.theme.onBackground         = _themeData.colorScheme.onBackground;
    System.theme.shadow               = _themeData.colorScheme.shadow;
    System.theme.outline              = _themeData.colorScheme.outline;

    System.theme.surface              = _themeData.colorScheme.surface;
    System.theme.onSurface            = _themeData.colorScheme.onSurface;
    System.theme.surfaceVariant       = _themeData.colorScheme.surfaceVariant;
    System.theme.onSurfaceVariant     = _themeData.colorScheme.onSurfaceVariant;
    System.theme.inverseSurface       = _themeData.colorScheme.inverseSurface;
    System.theme.onInverseSurface     = _themeData.colorScheme.onInverseSurface;

    System.theme.primary              = _themeData.colorScheme.primary;
    System.theme.onPrimary            = _themeData.colorScheme.onPrimary;
    System.theme.primaryContainer     = _themeData.colorScheme.primaryContainer;
    System.theme.onPrimaryContainer   = _themeData.colorScheme.onPrimaryContainer;
    System.theme.inversePrimary       = _themeData.colorScheme.inversePrimary;

    System.theme.secondary            = _themeData.colorScheme.secondary;
    System.theme.onSecondary          = _themeData.colorScheme.onSecondary;
    System.theme.secondaryContainer   = _themeData.colorScheme.secondaryContainer;
    System.theme.onSecondaryContainer = _themeData.colorScheme.onSecondaryContainer;

    System.theme.tertiaryContainer    = _themeData.colorScheme.tertiaryContainer;
    System.theme.onTertiaryContainer  = _themeData.colorScheme.onTertiaryContainer;

    System.theme.error                = _themeData.colorScheme.error;
    System.theme.onError              = _themeData.colorScheme.onError;
    System.theme.errorContainer       = _themeData.colorScheme.errorContainer;
    System.theme.onErrorContainer     = _themeData.colorScheme.onErrorContainer;
  }

  setTheme({String? brightness, String? color}) async
  {
    // load google fonts
    var fontTheme = (libraryLoader?.isCompleted ?? false) ? fonts.GoogleFonts.getTextTheme(System.theme.font) : null;

    // set system brightness
    var bn = await Settings().get('brightness') == 'dark' ? Brightness.dark : Brightness.light;
    brightness = brightness?.toLowerCase().trim();
    if (brightness == 'light')
    {
      bn = Brightness.light;
      System.theme.brightness = brightness;
    }
    else if (brightness == 'dark')
    {
      bn = Brightness.dark;
      System.theme.brightness = brightness;
    }
    Settings().set('brightness', brightness);

    // set system color scheme
    if (color != null)
    {
      // set system color scheme
      System.theme.colorScheme = toColor(color) ?? System.theme.colorScheme;
      _themeData = ThemeData(colorSchemeSeed: System.theme.colorScheme, brightness: bn, fontFamily: System.theme.font, textTheme: fontTheme, useMaterial3: true);
    }
    notifyListeners();
  }
}