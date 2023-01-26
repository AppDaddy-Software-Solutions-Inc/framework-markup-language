// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/table/table_model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class TableFooterModel extends DecoratedWidgetModel
{
  //////////////////
  /* border color */
  //////////////////
  ColorObservable? _bordercolor;
  set bordercolor (dynamic v)
  {
    if (_bordercolor != null)
    {
      _bordercolor!.set(v);
    }
    else if (v != null)
    {
      _bordercolor = ColorObservable(Binding.toKey(id, 'bordercolor'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get bordercolor
  {
    if (_bordercolor == null)
    {
      if ((this.parent != null) && (this.parent is TableModel)) return (this.parent as TableModel).bordercolor;
      return null;
    }
    return _bordercolor?.get();
  }

  //////////////////
  /* border width */
  //////////////////
  DoubleObservable? _borderwidth;
  set borderwidth (dynamic v)
  {
    if (_borderwidth != null)
    {
      _borderwidth!.set(v);
    }
    else if (v != null)
    {
      _borderwidth = DoubleObservable(Binding.toKey(id, 'borderwidth'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double? get borderwidth
  {
    if (_borderwidth == null)
    {
      if ((this.parent != null) && (this.parent is TableModel)) return (this.parent as TableModel).borderwidth;
      return null;
    }
    return _borderwidth?.get();
  }

  TableFooterModel(WidgetModel parent, String? id, {dynamic width, dynamic height, dynamic color}) : super(parent, id, scope: Scope(parent: parent.scope))
  {
    this.width  = width;
    this.height = height;
    this.color  = color;
  }

  static TableFooterModel? fromXml(WidgetModel parent, XmlElement xml, {Map<dynamic,dynamic>? data})
  {
    TableFooterModel? model;
    try
    {
      model = TableFooterModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'tableFooter.Model');
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
    bordercolor = Xml.get(node: xml, tag: 'bordercolor');
    borderwidth = Xml.get(node: xml, tag: 'borderwidth');
  }

  @override
  dispose()
  {
    Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
    scope?.dispose();
  }
}