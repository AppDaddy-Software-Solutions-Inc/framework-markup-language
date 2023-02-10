// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/busy/busy_view.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';

import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

/// Busy Model
///
/// Defines the properties of a [BUSY.BusyView]
class BusyModel extends DecoratedWidgetModel implements IViewableWidget
{
  // visible
  BooleanObservable? _visible;

  @override
  set visible(dynamic v)
  {
    if (_visible != null)
    {
      _visible!.set(v);
    }
    else if (v != null)
    {
      _visible = BooleanObservable(Binding.toKey(id, 'visible'), v, scope: scope, listener: onPropertyChange);
    }
  }
  @override
  bool get visible => _visible?.get() ?? false;


  /// Size of the widget sets the width and height
  bool _sizeIsPercent = false;
  DoubleObservable? _size;
  set size (dynamic v)
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

  double? get size
  {
    var s = _size?.get();
    if (s == null) return null;

    if (_sizeIsPercent == true)
    {
      var s1;
      var s2;

      var mh = maxheight;
      if (mh != null)
        s1 = mh * (s/100.0);
      else s1 = null;

      var mw = maxWidth;
      if (mw != null)
        s2 = mw * (s/100.0);
      else s2 = null;

      if ((s1 != null) && (s2 != null)) s = (s1 > s2) ? s1 : s2;
      if ((s1 == null) && (s2 != null)) s = s2;
      if ((s1 != null) && (s2 == null)) s = s1;
    }

    return s;
  }

  /// if true creates a modal barrier to prevent actions until the busy disappears
  BooleanObservable? _modal;
  set modal (dynamic v)
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

  BooleanObservable? _expand;
  set expand(dynamic v) {
    if (_expand != null) {
      _expand!.set(v);
    } else if (v != null) {
      _expand = BooleanObservable(Binding.toKey(id, 'expand'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get expand => _expand?.get() ?? true;



  BusyModel(WidgetModel? parent, {String? id, dynamic visible, dynamic expand, dynamic size, dynamic color, dynamic modal, Observable? observable}) : super(parent, id)
  {
    //this.visible = (visible == true) ? true : false; // TODO this causes issues with binding as we are not setting it to widget.model's observable
    this.visible = visible;
    this.size    = size;
    this.color   = color;
    this.modal   = modal;
    this.expand = expand;
    if (observable != null) observable.registerListener(onObservableChange);
  }

  void onObservableChange(Observable observable)
  {

      var v = observable.get();
      this.visible = v;

  }


  static BusyModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    BusyModel? model;
    try
    {
      model = BusyModel(parent, id: Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'busy.Model');
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
    size  = Xml.get(node: xml, tag: 'size');
    modal = Xml.get(node: xml, tag: 'modal');

    // expand="false" is same as adding attribute shrink
    var expand = Xml.get(node: xml, tag: 'expand');
    if (expand == null && Xml.hasAttribute(node: xml, tag: 'shrink')) expand = 'false';
    this.expand = expand;
  }

  Widget getView({Key? key}) => BusyView(this);
}
