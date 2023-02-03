// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/view/view_model.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';

import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/splitview/split_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class SplitModel extends DecoratedWidgetModel implements IViewableWidget
{
  /// The splitter bar divider color
  ColorObservable? _dividerColor;
  set dividerColor (dynamic v)
  {
    if (_dividerColor != null)
    {
      _dividerColor!.set(v);
    }
    else if (v != null)
    {
      _dividerColor = ColorObservable(Binding.toKey(id, 'dividercolor'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get dividerColor => _dividerColor?.get();

  /// The splitter bar divider width
  DoubleObservable? _dividerWidth;
  set dividerWidth (dynamic v)
  {
    if (_dividerWidth != null)
    {
      _dividerWidth!.set(v);
    }
    else if (v != null)
    {
      _dividerWidth = DoubleObservable(Binding.toKey(id, 'dividerwidth'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double? get dividerWidth => _dividerWidth?.get();

  /// The splitter bar divider handle color
  ColorObservable? _dividerHandleColor;
  set dividerHandleColor (dynamic v)
  {
    if (_dividerHandleColor != null)
    {
      _dividerHandleColor!.set(v);
    }
    else if (v != null)
    {
      _dividerHandleColor = ColorObservable(Binding.toKey(id, 'dividerhandlecolor'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get dividerHandleColor => _dividerHandleColor?.get();

  /// split ratio
  DoubleObservable? _ratio;
  set ratio (dynamic v)
  {
    if (_ratio != null)
    {
      _ratio!.set(v);
    }
    else if (v != null)
    {
      _ratio = DoubleObservable(null, v, scope: scope);
    }
  }
  double get ratio => _ratio?.get() ?? 0.5;

  SplitModel(WidgetModel parent, String? id,
  {
    dynamic width,
  }) : super(parent, id)
  {
    this.width = width;
  }

  @override
  dispose()
  {
    super.dispose();
  }

  static SplitModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    SplitModel? model;
    try
    {
      model = SplitModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'form.Model');
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
    ratio         = Xml.get(node: xml, tag: 'ratio');
    dividerColor  = Xml.get(node: xml, tag: 'dividercolor');
    dividerWidth  = Xml.get(node: xml, tag: 'dividerwidth');
    dividerHandleColor  = Xml.get(node: xml, tag: 'dividerhandlecolor');

    // remove non view children
    children?.removeWhere((element) => !(element is ViewModel));
  }

  Widget getView({Key? key}) => SplitView(this);
}


