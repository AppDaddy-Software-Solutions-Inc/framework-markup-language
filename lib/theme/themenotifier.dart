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
        setTheme(brightness: System.theme.brightness ?? 'light', color: toStr(System.theme.colorscheme ?? 'lightblue'));
      });
    }
  }
  getTheme() => _themeData;

  void mapSystemThemeBindables()
  {
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
      System.theme.colorscheme = toColor(color) ?? System.theme.colorscheme;
      _themeData = ThemeData(colorSchemeSeed: System.theme.colorscheme, brightness: bn, fontFamily: System.theme.font, textTheme: fontTheme, useMaterial3: true);
    }
    notifyListeners();
  }
}