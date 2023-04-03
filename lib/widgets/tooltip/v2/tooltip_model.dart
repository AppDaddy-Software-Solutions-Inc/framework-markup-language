// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/boolean.dart';
import 'package:fml/observable/observables/color.dart';
import 'package:fml/observable/observables/double.dart';
import 'package:fml/observable/observables/integer.dart';
import 'package:fml/observable/observables/string.dart';
import 'package:fml/widgets/tooltip/v2/tooltip_view.dart';
import 'package:fml/widgets/widget/viewable_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/helper/common_helpers.dart';

enum OpenMethods {tap, longpress, hover, manual}

class TooltipModel extends ViewableWidgetModel
{
  OpenMethods? openMethod;

  // color
  ColorObservable? _color;
  set color(dynamic v)
  {
    if (_color != null) _color!.set(v);
    else if (v != null) _color = ColorObservable(Binding.toKey(id, 'color'), v, scope: scope, listener: onPropertyChange);
  }
  Color? get color => _color?.get();

  // padding
  DoubleObservable? _padding;
  set padding(dynamic v)
  {
    if (_padding != null) _padding!.set(v);
    else if (v != null) _padding = DoubleObservable(Binding.toKey(id, 'padding'), v, scope: scope, listener: onPropertyChange);
  }
  double get padding => _padding?.get() ?? 14.0;

  StringObservable? _position;
  set position(dynamic v)
  {
    if (_position != null)
    {
      _position!.set(v);
    }
    else if (v != null)
    {
      _position = StringObservable(Binding.toKey(id, 'position'), v, scope: scope);
    }
  }
  String? get position => _position?.get();

  /// [distance] Space between the tooltip and the trigger.
  DoubleObservable? _distance;
  set distance(dynamic v)
  {
    if (_distance != null)
    {
      _distance!.set(v);
    }
    else if (v != null)
    {
      _distance = DoubleObservable(Binding.toKey(id, 'distance'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double get distance => _distance?.get() ?? 10.0;

  /// [radius] Border radius around the tooltip.
  DoubleObservable? _radius;
  set radius(dynamic v) 
  {
    if (_radius != null) 
    {
      _radius!.set(v);
    } 
    else if (v != null) 
    {
      _radius = DoubleObservable(Binding.toKey(id, 'radius'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double get radius => _radius?.get() ?? 8.0;

  /// [modal] Shows a dark layer behind the tooltip.
  BooleanObservable? _modal;
  set modal(dynamic v)
  {
    if (_modal != null)
    {
      _modal!.set(v);
    }
    else if (v != null)
    {
      _modal = BooleanObservable(Binding.toKey(id, 'modal'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get modal => _modal?.get() ?? false;

  /// [arrow] Show the tip arrow?
  BooleanObservable? _arrow;
  set arrow(dynamic v)
  {
    if (_arrow != null)
    {
      _arrow!.set(v);
    }
    else if (v != null)
    {
      _arrow = BooleanObservable(Binding.toKey(id, 'arrow'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get arrow => _arrow?.get() ?? true;
  
  /// [timeout] Number of seconds until the tooltip disappears automatically
  /// The default value is 0 (zero) which means it never disappears.
  // timeout
  IntegerObservable? _timeout;
  set timeout(dynamic v)
  {
    if (_timeout != null)
    {
      _timeout!.set(v);
    }
    else if (v != null)
    {
      _timeout = IntegerObservable(Binding.toKey(id, 'timeout'), v, scope: scope, listener: onPropertyChange);
    }
  }
  int get timeout => _timeout?.get() ?? 0;

  TooltipModel(WidgetModel parent, String? id) : super(parent, id);

  static TooltipModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    TooltipModel? model;
    try
    {
      model = TooltipModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'tooltip.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize 
    super.deserialize(xml);

    // properties
    color    = Xml.attribute(node: xml, tag: 'color');
    padding  = Xml.attribute(node: xml, tag: 'pad');
    if (_padding == null) padding  = Xml.attribute(node: xml, tag: 'padding');
    radius   = Xml.attribute(node: xml, tag: 'radius');
    position = Xml.attribute(node: xml, tag: 'position');
    modal    = Xml.attribute(node: xml, tag: 'modal');
    timeout  = Xml.get(node: xml, tag: 'timeout');
    distance = Xml.get(node: xml, tag: 'distance');
    arrow    = Xml.get(node: xml, tag: 'arrow');
    openMethod = S.toEnum(Xml.get(node: xml, tag: 'openMethod'), OpenMethods.values);
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  @override
  Future<bool?> execute(String caller, String propertyOrFunction, List<dynamic> arguments) async
  {
    /// setter
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    switch (function)
    {
      case "open":
        var view = findListenerOfExactType(TooltipViewState);
        if (view is TooltipViewState && context != null && view.overlayEntry == null) view.showOverlay(context!);
        return true;

      case "close":
        var view = findListenerOfExactType(TooltipViewState);
        if (view is TooltipViewState && view.overlayEntry != null) view.hideOverlay();
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }
}
