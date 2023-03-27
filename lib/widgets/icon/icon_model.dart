// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/icon/icon_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class IconModel extends DecoratedWidgetModel implements IViewableWidget {
  @override
  double get width {
    return 24;
  }

  //////////
  /* icon */
  //////////
  IconObservable? _icon;
  set icon(dynamic v) {
    if (_icon != null) {
      _icon!.set(v);
    } else if (v != null) {
      _icon = IconObservable(Binding.toKey(id, 'icon'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  IconData? get icon => _icon?.get();

  //////////
  /* size */
  //////////
  bool _sizeIsPercent = false;
  DoubleObservable? _size;
  set size(dynamic v)
  {
    if (_size != null)
    {
      _size!.set(v);
      width = v;
    }
    else if (v != null)
    {
      if (S.isPercentage(v))
      {
        _sizeIsPercent = true;
        v = v.split("%")[0];
      }
      _size = DoubleObservable(Binding.toKey(id, 'size'), v, scope: scope, listener: onPropertyChange);
    }
  }

  double? get size {
    var s = _size?.get();
    if (s == null) return null;

    if (_sizeIsPercent == true) {
      var s1;
      var s2;

      var mh = getSystemMaxHeight();
      if (mh != null)
        s1 = mh * (s / 100.0);
      else
        s1 = null;

      var mw = getSystemMaxWidth();
      if (mw != null)
        s2 = mw * (s / 100.0);
      else
        s2 = null;

      if ((s1 != null) && (s2 != null)) s = (s1 > s2) ? s1 : s2;
      if ((s1 == null) && (s2 != null)) s = s2;
      if ((s1 != null) && (s2 == null)) s = s1;
    }

    return s;
  }

  //////////////
  /* rotation */
  //////////////
  DoubleObservable? _rotation;
  set rotation(dynamic v) {
    if (_rotation != null) {
      _rotation!.set(v);
    } else if (v != null) {
      _rotation = DoubleObservable(Binding.toKey(id, 'rotation'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double get rotation => _rotation?.get() ?? 0.0;

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
  void deserialize(XmlElement xml) {
    // deserialize
    super.deserialize(xml);

    // properties
    icon = Xml.get(node: xml, tag: 'icon');
    size = Xml.get(node: xml, tag: 'size');
    opacity = Xml.get(node: xml, tag: 'opacity');
    rotation = Xml.get(node: xml, tag: 'rotation');
  }

  @override
  dispose() {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  Widget getView({Key? key}) => getReactiveView(IconView(this));
}
