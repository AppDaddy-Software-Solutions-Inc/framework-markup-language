// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/hive/settings.dart';
import 'package:fml/system.dart';

import 'package:fml/observable/observables/color.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _themeData;

  ThemeNotifier(this._themeData);

  getTheme() => _themeData;

  void mapSystemThemeBindables() {

    // System().brightness           = _themeData.brightness == Brightness.dark ? 'dark' : 'light';
    // System().colorscheme          = 'lightblue';

    System().background           = _themeData.colorScheme.background;
    System().onbackground         = _themeData.colorScheme.onBackground;
    System().shadow               = _themeData.colorScheme.shadow;
    System().outline              = _themeData.colorScheme.outline;

    System().surface              = _themeData.colorScheme.surface;
    System().onsurface            = _themeData.colorScheme.onSurface;
    System().surfacevariant       = _themeData.colorScheme.surfaceVariant;
    System().onsurfacevariant     = _themeData.colorScheme.onSurfaceVariant;
    System().inversesurface       = _themeData.colorScheme.inverseSurface;
    System().oninversesurface     = _themeData.colorScheme.onInverseSurface;

    System().primary              = _themeData.colorScheme.primary;
    System().onprimary            = _themeData.colorScheme.onPrimary;
    System().primarycontainer     = _themeData.colorScheme.primaryContainer;
    System().onprimarycontainer   = _themeData.colorScheme.onPrimaryContainer;
    System().inverseprimary       = _themeData.colorScheme.inversePrimary;

    System().secondary            = _themeData.colorScheme.secondary;
    System().onsecondary          = _themeData.colorScheme.onSecondary;
    System().secondarycontainer   = _themeData.colorScheme.secondaryContainer;
    System().onsecondarycontainer = _themeData.colorScheme.onSecondaryContainer;

    System().tertiarycontainer    = _themeData.colorScheme.tertiaryContainer;
    System().ontertiarycontainer  = _themeData.colorScheme.onTertiaryContainer;

    System().error                = _themeData.colorScheme.error;
    System().onerror              = _themeData.colorScheme.onError;
    System().errorcontainer       = _themeData.colorScheme.errorContainer;
    System().onerrorcontainer     = _themeData.colorScheme.onErrorContainer;

  }

  setTheme(String sBrightness, [String? sColor, Map<String, String>? schemeColors]) async {
    Brightness brightness = await Settings().get('brightness') == 'dark' ? Brightness.dark : Brightness.light;
    if (sBrightness.toLowerCase() == 'light'){
      brightness = Brightness.light;
      System().brightness = sBrightness.toLowerCase();
    }
    else if (sBrightness.toLowerCase() == 'dark') {
      brightness = Brightness.dark;
      System().brightness = sBrightness.toLowerCase();
    }
    Settings().set('brightness', sBrightness);
    if (sColor != null) {
      Color? colorScheme = ColorObservable.toColor(sColor);
      System().colorscheme = sColor;
      ThemeData themeData = ThemeData(colorSchemeSeed: colorScheme, brightness: brightness, useMaterial3: true);
      _themeData = themeData;
    }
    else {
      ThemeData themeData = ThemeData(brightness: brightness, useMaterial3: true);
      _themeData = themeData;
    }
    notifyListeners();
  }
}