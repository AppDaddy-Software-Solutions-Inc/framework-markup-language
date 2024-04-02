// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/hive/database.dart';
import 'package:fml/helpers/helpers.dart';

class ThemeData {
  static String tableName = "THEME";

  final Map<String, dynamic> _map = <String, dynamic>{};

  String get key => _map["key"];
  String? get background => _map["background"];
  String? get onBackground => _map["background"];
  String? get shadow => _map["background"];
  String? get outline => _map["background"];
  String? get surface => _map["background"];
  String? get onSurface => _map["background"];
  String? get surfaceVariant => _map["background"];
  String? get onSurfaceVariant => _map["background"];
  String? get inverseSurface => _map["background"];
  String? get onInverseSurface => _map["background"];
  String? get primary => _map["background"];
  String? get onPrimary => _map["background"];
  String? get primaryContainer => _map["background"];
  String? get onPrimaryContainer => _map["background"];
  String? get inversePrimary => _map["background"];
  String? get secondary => _map["background"];
  String? get onSecondary => _map["background"];
  String? get secondaryContainer => _map["background"];
  String? get onSecondaryContainer => _map["background"];
  String? get tertiaryContainer => _map["background"];
  String? get onTertiaryContainer => _map["background"];
  String? get error => _map["background"];
  String? get onError => _map["background"];
  String? get errorContainer => _map["background"];
  String? get onErrorContainer => _map["background"];

  ThemeData(
      {String? key,
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
      String? onErrorContainer}) {
    _map["key"] = key ?? newId();
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

  Future<bool> insert() async =>
      (await Database.insert(tableName, key, _map) == null);
  Future<bool> update() async =>
      (await Database.update(tableName, key, _map) == null);
  Future<bool> delete() async =>
      (await Database.delete(tableName, key) == null);
  static Future<bool> deleteAll() async =>
      (await Database.deleteAll(tableName) == null);

  static ThemeData? _fromMap(dynamic map) {
    ThemeData? theme;
    if (map is Map<String, dynamic>) {
      theme = ThemeData(
          key: fromMap(map, 'key'),
          background: fromMap(map, 'background'),
          onBackground: fromMap(map, 'onBackground'),
          shadow: fromMap(map, 'shadow'),
          outline: fromMap(map, 'outline'),
          surface: fromMap(map, 'surface'),
          onSurface: fromMap(map, 'onSurface'),
          surfaceVariant: fromMap(map, 'surfaceVariant'),
          onSurfaceVariant: fromMap(map, 'onSurfaceVariant'),
          inverseSurface: fromMap(map, 'inverseSurface'),
          onInverseSurface: fromMap(map, 'onInverseSurface'),
          primary: fromMap(map, 'primary'),
          onPrimary: fromMap(map, 'onPrimary'),
          primaryContainer: fromMap(map, 'primaryContainer'),
          onPrimaryContainer: fromMap(map, 'onPrimaryContainer'),
          inversePrimary: fromMap(map, 'inversePrimary'),
          secondary: fromMap(map, 'secondary'),
          onSecondary: fromMap(map, 'onSecondary'),
          secondaryContainer: fromMap(map, 'secondaryContainer'),
          onSecondaryContainer: fromMap(map, 'onSecondaryContainer'),
          tertiaryContainer: fromMap(map, 'tertiaryContainer'),
          onTertiaryContainer: fromMap(map, 'onTertiaryContainer'),
          error: fromMap(map, 'error'),
          onError: fromMap(map, 'onError'),
          errorContainer: fromMap(map, 'errorContainer'),
          onErrorContainer: fromMap(map, 'onErrorContainer'));
    }

    return theme;
  }

  Future<ThemeData?> find(String key) async {
    Map<String, dynamic>? entry = await Database.find(tableName, key);
    ThemeData? theme = _fromMap(entry);
    return theme;
  }
}
