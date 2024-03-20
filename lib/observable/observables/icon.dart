// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/graphics.dart' deferred as icons;
import 'package:flutter/material.dart';
import 'package:fml/observable/observable.dart';

class IconObservable extends Observable {
  static Completer? libraryLoader;
  String? _pendingIcon;

  IconObservable(super.name, super.value,
      {super.scope, super.listener, super.getter, super.setter}) {
    // load the library
    if (libraryLoader == null) {
      libraryLoader = Completer();
      icons.loadLibrary().then((value) => libraryLoader!.complete(true));
    }

    // wait for the library to load
    if (!libraryLoader!.isCompleted) {
      libraryLoader!.future.whenComplete(() {
        if (_pendingIcon != null) set(toIcon(_pendingIcon!));
      });
    }
  }

  @override
  IconData? get({String? dotnotation}) {
    dynamic value = super.get();
    return (value is IconData) ? value : null;
  }

  @override
  dynamic to(dynamic value) {
    try {
      if (value == null) return null;
      if (value is IconData) return value;
      if (value is String) return toIcon(value);
      return Exception();
    } catch (e) {
      return e;
    }
  }

  IconData? toIcon(String name) {
    IconData? icon;
    if (libraryLoader?.isCompleted ?? false) {
      name = name.toLowerCase();
      if (icons.Graphics.icons.containsKey(name)) {
        icon = icons.Graphics.icons[name];
      }
    } else {
      _pendingIcon = name;
      icon = Icons.horizontal_rule;
    }
    return icon;
  }
}
