// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/hive/database.dart';
import 'package:fml/helper/common_helpers.dart';

class ThemeData
{
  static String tableName = "THEME";

  Map<String, dynamic> _map = <String, dynamic>{};

  String  get key                  => _map["key"];
  String? get background           => _map["background"];
  String? get onBackground         => _map["background"];
  String? get shadow               => _map["background"];
  String? get outline              => _map["background"];
  String? get surface              => _map["background"];
  String? get onSurface            => _map["background"];
  String? get surfaceVariant       => _map["background"];
  String? get onSurfaceVariant     => _map["background"];
  String? get inverseSurface       => _map["background"];
  String? get onInverseSurface     => _map["background"];
  String? get primary              => _map["background"];
  String? get onPrimary            => _map["background"];
  String? get primaryContainer     => _map["background"];
  String? get onPrimaryContainer   => _map["background"];
  String? get inversePrimary       => _map["background"];
  String? get secondary            => _map["background"];
  String? get onSecondary          => _map["background"];
  String? get secondaryContainer   => _map["background"];
  String? get onSecondaryContainer => _map["background"];
  String? get tertiaryContainer    => _map["background"];
  String? get onTertiaryContainer  => _map["background"];
  String? get error                => _map["background"];
  String? get onError              => _map["background"];
  String? get errorContainer       => _map["background"];
  String? get onErrorContainer     => _map["background"];

  ThemeData({
    String? key,
    String? background,
    String? onBackground,
    String? shadow,
    String? outline,
    String? surface,
    String? onSurface,
    String? surfaceVariant,
    String? onSurfaceVariant,
    String? inverseSurface,
    String? onInverseSurface,
    String? primary,
    String? onPrimary,
    String? primaryContainer,
    String? onPrimaryContainer,
    String? inversePrimary,
    String? secondary,
    String? onSecondary,
    String? secondaryContainer,
    String? onSecondaryContainer,
    String? tertiaryContainer,
    String? onTertiaryContainer,
    String? error,
    String? onError,
    String? errorContainer,
    String? onErrorContainer
  })
  {
    _map["key"] = key ?? S.newId();
    _map["background"] = background;
    _map["onBackground"] = onBackground;
    _map["shadow"] = shadow;
    _map["outline"] = outline;
    _map["surface"] = surface;
    _map["onSurface"] = onSurface;
    _map["surfaceVariant"] = surfaceVariant;
    _map["onSurfaceVariant"] = onSurfaceVariant;
    _map["inverseSurface"] = inverseSurface;
    _map["onInverseSurface"] = onInverseSurface;
    _map["primary"] = primary;
    _map["onPrimary"] = onPrimary;
    _map["primaryContainer"] = primaryContainer;
    _map["onPrimaryContainer"] = onPrimaryContainer;
    _map["inversePrimary"] = inversePrimary;
    _map["secondary"] = secondary;
    _map["onSecondary"] = onSecondary;
    _map["secondaryContainer"] = secondaryContainer;
    _map["onSecondaryContainer"] = onSecondaryContainer;
    _map["tertiaryContainer"] = tertiaryContainer;
    _map["onTertiaryContainer"] = onTertiaryContainer;
    _map["error"] = error;
    _map["onError"] = onError;
    _map["errorContainer"] = errorContainer;
    _map["onErrorContainer"] = onErrorContainer;
  }

  Future<bool> insert() async => (await Database().insert(tableName, key, _map) == null);
  Future<bool> update() async => (await Database().update(tableName, key, _map) == null);
  Future<bool> delete() async => (await Database().delete(tableName, key) == null);
  static Future<bool> deleteAll() async => (await Database().deleteAll(tableName) == null);

  static ThemeData? _fromMap(dynamic map)
  {
    ThemeData? theme;
    if (map is Map<String, dynamic>) {
      theme = ThemeData(
          key: S.mapVal(map, 'key'),
          background: S.mapVal(map, 'background'),
          onBackground: S.mapVal(map, 'onBackground'),
          shadow: S.mapVal(map, 'shadow'),
          outline: S.mapVal(map, 'outline'),
          surface: S.mapVal(map, 'surface'),
          onSurface: S.mapVal(map, 'onSurface'),
          surfaceVariant: S.mapVal(map, 'surfaceVariant'),
          onSurfaceVariant: S.mapVal(map, 'onSurfaceVariant'),
          inverseSurface: S.mapVal(map, 'inverseSurface'),
          onInverseSurface: S.mapVal(map, 'onInverseSurface'),
          primary: S.mapVal(map, 'primary'),
          onPrimary: S.mapVal(map, 'onPrimary'),
          primaryContainer: S.mapVal(map, 'primaryContainer'),
          onPrimaryContainer: S.mapVal(map, 'onPrimaryContainer'),
          inversePrimary: S.mapVal(map, 'inversePrimary'),
          secondary: S.mapVal(map, 'secondary'),
          onSecondary: S.mapVal(map, 'onSecondary'),
          secondaryContainer: S.mapVal(map, 'secondaryContainer'),
          onSecondaryContainer: S.mapVal(map, 'onSecondaryContainer'),
          tertiaryContainer: S.mapVal(map, 'tertiaryContainer'),
          onTertiaryContainer: S.mapVal(map, 'onTertiaryContainer'),
          error: S.mapVal(map, 'error'),
          onError: S.mapVal(map, 'onError'),
          errorContainer: S.mapVal(map, 'errorContainer'),
          onErrorContainer: S.mapVal(map, 'onErrorContainer'));
    }

    return theme;
  }

  Future<ThemeData?> find(String key) async
  {
    Map<String, dynamic>? entry = await Database().find(tableName, key);
    ThemeData? theme = _fromMap(entry);
    return theme;
  }
}