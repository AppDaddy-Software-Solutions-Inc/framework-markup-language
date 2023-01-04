// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/graphics.dart' deferred as gf;
import 'package:flutter/material.dart';
import 'package:fml/observable/observable.dart';
import 'package:fml/observable/scope.dart';

class IconObservable extends Observable
{
  bool _libraryLoaded = false;
  String? _iconname;

  IconObservable(String? name, dynamic value, {Scope? scope, OnChangeCallback? listener, Getter? getter, Setter? setter}) : super(name, value, scope: scope, listener: listener, getter: getter, setter: setter)
  {
    gf.loadLibrary().then((_)
    {
      _libraryLoaded = true;
      if (_iconname != null) set(toIcon(_iconname!));
    });
  }

  @override
  IconData? get({String? dotnotation})
  {
    dynamic value = super.get();
    return (value is IconData) ? value : null;
  }

  @override
  dynamic to(dynamic s)
  {
    try
    {
      if (s == null)      return null;
      if (s is IconData)  return s;
      if (s is String)    return toIcon(s);
      return Exception();
    }
    catch(e)
    {
      return e;
    }
  }

  IconData? toIcon(String name)
  {
    IconData? icon;
    if (_libraryLoaded)
    {
      name = name.toLowerCase();
      if (gf.Graphics.icons.containsKey(name)) icon = gf.Graphics.icons[name];
    }
    else
    {
      _iconname = name;
      icon = Icons.hourglass_empty_rounded;
    }
    return icon;
  }
}