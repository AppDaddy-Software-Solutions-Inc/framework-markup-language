// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/view/view_model.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/splitview/split_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class SplitModel extends DecoratedWidgetModel 
{
  /// vertical or horizontal splitter?
  bool? _vertical;
  bool get vertical => _vertical ?? false;

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

  SplitModel(WidgetModel parent, String? id, {dynamic width, dynamic height, bool? vertical}) : super(parent, id)
  {
    if (width  != null) this.width  = width;
    if (height != null) this.height = height;

    if (vertical != null) _vertical = vertical;
  }


  static SplitModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    SplitModel? model;
    try
    {
      model = SplitModel(parent, Xml.get(node: xml, tag: 'id'), vertical: Xml.get(node: xml, tag: 'direction') == "vertical");
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
    double ratio = S.toDouble(Xml.get(node: xml, tag: 'ratio')) ?? -1;
    if (ratio >= 0 && ratio <= 1)
    {
      if (vertical)
           this.height = "${ratio * 100}%";
      else this.width  = "${ratio * 100}%";
    }

    dividerColor  = Xml.get(node: xml, tag: 'dividercolor');
    dividerWidth  = Xml.get(node: xml, tag: 'dividerwidth');
    dividerHandleColor  = Xml.get(node: xml, tag: 'dividerhandlecolor');

    // remove non view children
    children?.removeWhere((element) => element is! ViewModel);
  }

  Widget getView({Key? key}) => getReactiveView(SplitView(this));
}


