// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/hive/theme.dart';
import 'package:fml/hive/database.dart';

class CustomTheme
{
  final String key;
  final String? background;
  final String? onBackground;
  final String? shadow;
  final String? outline;
  final String? surface;
  final String? onSurface;
  final String? surfaceVariant;
  final String? onSurfaceVariant;
  final String? inverseSurface;
  final String? onInverseSurface;
  final String? primary;
  final String? onPrimary;
  final String? primaryContainer;
  final String? onPrimaryContainer;
  final String? inversePrimary;
  final String? secondary;
  final String? onSecondary;
  final String? secondaryContainer;
  final String? onSecondaryContainer;
  final String? tertiaryContainer;
  final String? onTertiaryContainer;
  final String? error;
  final String? onError;
  final String? errorContainer;
  final String? onErrorContainer;

  CustomTheme(this.key, {this.background, this.onBackground, this.shadow, this.outline, this.surface, this.onSurface, this.surfaceVariant, this.onSurfaceVariant, this.inverseSurface, this.onInverseSurface, this.primary, this.onPrimary, this.primaryContainer, this.onPrimaryContainer, this.inversePrimary, this.secondary, this.onSecondary, this.secondaryContainer, this.onSecondaryContainer, this.tertiaryContainer, this.onTertiaryContainer, this.error, this.onError, this.errorContainer, this.onErrorContainer});
}

class Theme
{
  List<CustomTheme> themes = [];
  int size = 5000;
  bool debugging = false;

  static final Theme _singleton = Theme._init();
  factory Theme()
  {
    return _singleton;
  }

  Theme._init();

  Future<bool> saveTheme(String key, String background, String onBackground, String shadow, String outline, String surface, String onSurface, String surfaceVariant, String onSurfaceVariant, String inverseSurface, String onInverseSurface, String primary, String onPrimary, String primaryContainer, String onPrimaryContainer, String inversePrimary, String secondary, String onSecondary, String secondaryContainer, String onSecondaryContainer, String tertiaryContainer, String onTertiaryContainer, String error, String onError, String errorContainer, String onErrorContainer,) async {
    bool themed = false;
    themed = await ThemeData(
      key: key,
      background: background,
      onBackground: onBackground,
      shadow: shadow,
      outline: outline,
      surface: surface,
      onSurface: onSurface,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      inverseSurface: inverseSurface,
      onInverseSurface: onInverseSurface,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      inversePrimary: inversePrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
    ).insert();
    return themed;
  }

  Future<void> clear()
  async {
    await Database().deleteAll('THEME');
    themes.clear();
  }
}