// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:ui';
import 'package:fml/fml.dart';
import 'package:flutter/material.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/system.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/theme/theme_model.dart';
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
      // set the theme
      libraryLoader!.future.whenComplete(()
      {
        var brightness = System.app?.brightness ?? FmlEngine.defaultBrightness;
        var color = System.app?.color ?? FmlEngine.defaultColor;
        var font = System.app?.font ?? FmlEngine.defaultFont;
        setTheme(brightness: brightness, color: color, font: font);
      });
    }
  }
  getTheme() => _themeData;

  void setTheme({required Brightness brightness, required Color color, required String font, bool notify = true}) async
  {
    // set brightness
    var sameBrightness = brightness == (System.theme.brightness == 'dark' ? Brightness.dark : Brightness.light);

    // set color
    var sameColor = toStr(color) == toStr(System.theme.colorScheme);

    // set font && text theme
    var sameFont = toStr(font) == System.theme.font;

    // set text theme
    var text = (libraryLoader?.isCompleted ?? false) ? fonts.GoogleFonts.getTextTheme(font) : null;

    // set the theme
    if (!sameBrightness || !sameColor || !sameFont)
    {
      // set the theme
      _themeData = ThemeData(useMaterial3: true, brightness: brightness, colorSchemeSeed: color, fontFamily: font, textTheme: text);

      // set system theme bindables
      _setSystemBindables(brightness: brightness, color: color, font: font);

      // notify
      if (notify) notifyListeners();
    }
  }

  /// Derive theme from a color value and a https://fonts.google.com/ font
  static ThemeData from(dynamic colorScheme, {String? googleFont})
  {
    Color color = toColor(colorScheme) ?? toColor(FmlEngine.defaultColor) ?? Colors.blueGrey;
    return ThemeData(colorSchemeSeed: color, brightness: _brightness, fontFamily: googleFont ?? FmlEngine.defaultFont, useMaterial3: true);
  }

  static Brightness get _brightness
  {
    var brightness = System.theme.brightness ?? FmlEngine.defaultBrightness;
    switch(brightness)
    {
      case 'system':
      case 'platform':
        return PlatformDispatcher.instance.platformBrightness;

      case 'dark':
        return Brightness.dark;

      case 'light':
      default:
        return Brightness.light;
    }
  }

  static ThemeData fromTheme(ColorScheme base, ThemeModel theme)
  {
    try
    {
      var scheme = ColorScheme(
        brightness: theme.brightness == 'dark' ? Brightness.dark : Brightness.light,
        background: theme.background ?? base.background,
        onBackground: theme.onBackground ?? base.onBackground,
        shadow: theme.shadow ?? base.shadow,
        outline: theme.outline ?? base.outline,
        surface: theme.surface ?? base.surface,
        onSurface: theme.onSurface ?? base.onSurface,
        surfaceVariant: theme.surfaceVariant ?? base.surfaceVariant,
        onSurfaceVariant: theme.onSurfaceVariant ?? base.onSurfaceVariant,
        inverseSurface: theme.inverseSurface ?? base.inverseSurface,
        onInverseSurface: theme.onInverseSurface ?? base.onInverseSurface,
        primary: theme.primary ?? base.primary,
        onPrimary: theme.onPrimary ?? base.onPrimary,
        primaryContainer: theme.primaryContainer ?? base.primaryContainer,
        onPrimaryContainer: theme.onPrimaryContainer ?? base.onPrimaryContainer,
        inversePrimary: theme.inversePrimary ?? base.inversePrimary,
        secondary: theme.secondary ?? base.secondary,
        onSecondary: theme.onSecondary ?? base.onSecondary,
        secondaryContainer: theme.secondaryContainer ?? base.secondaryContainer,
        onSecondaryContainer: theme.onSecondaryContainer ?? base.onSecondaryContainer,
        tertiaryContainer: theme.tertiaryContainer ?? base.tertiaryContainer,
        onTertiaryContainer: theme.onTertiaryContainer ?? base.onTertiaryContainer,
        error: theme.error ?? base.error,
        onError: theme.onError ?? base.onError,
        errorContainer: theme.errorContainer ?? base.errorContainer,
        onErrorContainer: theme.onErrorContainer ?? base.onErrorContainer,
      );

      return ThemeData.from(useMaterial3: true, colorScheme: scheme);
    }
    catch (e)
    {
      Log().exception(e);
      return ThemeData.from(colorScheme: base, useMaterial3: true);
    }
  }

  void _setSystemBindables({required Brightness brightness, required Color color, required String font})
  {
    System.theme.brightness           = brightness == Brightness.dark ? 'dark' : 'light';
    System.theme.colorScheme          = color;
    System.theme.font                 = font;

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
}