// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/icon/icon_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class IconModel extends DecoratedWidgetModel  
{
  // icon
  IconObservable? _icon;
  set icon(dynamic v)
  {
    if (_icon != null)
    {
      _icon!.set(v);
    }
    else if (v != null)
    {
      _icon = IconObservable(Binding.toKey(id, 'icon'), v, scope: scope, listener: onPropertyChange);
    }
  }
  IconData? get icon => _icon?.get();

  // size
  DoubleObservable? _size;
  set size(dynamic v)
  {
    if (_size != null)
    {
      _size!.set(v);
    }
    else if (v != null)
    {
      _size = DoubleObservable(Binding.toKey(id, 'size'), null, scope: scope, listener: onPropertyChange, getter: _sizeGetter, setter: _sizeSetter);
      _size!.set(v);
    }
  }
  double? get size => _size?.get() ?? 24;

  dynamic _sizeGetter() => width;
  dynamic _sizeSetter(dynamic value, {Observable? setter})
  {
    width  = value;
    height = value;
    return width;
  }

  IconModel(WidgetModel? parent, String? id,
      {dynamic visible,
      dynamic icon,
      dynamic size,
      dynamic color,
      dynamic opacity})
      : super(parent, id) {
    this.visible = visible;
    this.icon = icon;
    this.color = color;
    this.opacity = opacity;
    this.size = size;
  }

  static IconModel? fromXml(WidgetModel parent, XmlElement xml) {
    IconModel? model;
    try {
      model = IconModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'icon.Model');
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
    icon     = Xml.get(node: xml, tag: 'icon');
    size     = Xml.get(node: xml, tag: 'size');
    opacity  = Xml.get(node: xml, tag: 'opacity');
  }

  @override
  dispose() {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  @override
  Widget getView({Key? key}) => getReactiveView(IconView(this));
}
