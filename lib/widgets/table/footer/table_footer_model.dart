// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/row/row_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/table/table_model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class TableFooterModel extends RowModel
{
  // shrink in both axis
  @override
  bool get expandHorizontally => false;

  @override
  bool get expandVertically => false;

  @override
  Color? get color => super.color ?? (parent is TableModel ? (parent as TableModel).color : null);

  @override
  Color? get bordercolor => super.bordercolor ?? (parent is TableModel ? (parent as TableModel).bordercolor : null);

  @override
  String? get halign => super.halign ?? (parent is TableModel ? (parent as TableModel).halign : null);

  @override
  String? get valign => super.valign ?? (parent is TableModel ? (parent as TableModel).valign : null);

  @override
  bool? get center => super.center ?? (parent is TableModel ? (parent as TableModel).center : null);

  TableFooterModel(WidgetModel parent, String? id, {dynamic width, dynamic height, dynamic color}) : super(parent, id, scope: Scope(parent: parent.scope))
  {
    if (width  != null) this.width  = width;
    if (height != null) this.height = height;
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
    super.dispose();
    scope?.dispose();
  }
}