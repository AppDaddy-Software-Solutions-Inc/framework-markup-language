// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:math';

import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_data.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/table/table_model.dart';
import 'package:fml/widgets/table/header/cell/table_header_cell_model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class TableBodyModel extends BoxModel
{
  bool needsLayout = false;

  double? cellHeight;

  // shrink in both axis
  @override
  bool get expandHorizontally => true;

  @override
  bool get expandVertically => false;

  // list of cells
  List<TableHeaderCellModel> cells = [];

  @override
  String? get border => super.border ?? "all";

  @override
  double? get paddingTop => super.paddingTop ?? (parent is TableModel ? (parent as TableModel).paddingTop : null);

  @override
  double? get paddingBottom => super.paddingBottom ?? (parent is TableModel ? (parent as TableModel).paddingBottom : null);

  @override
  double? get paddingLeft => super.paddingLeft ?? (parent is TableModel ? (parent as TableModel).paddingLeft : null);

  @override
  double? get paddingRight => super.paddingRight ?? (parent is TableModel ? (parent as TableModel).paddingRight : null);

  @override
  Color? get color => super.color ?? (parent is TableModel ? (parent as TableModel).color : null);

  @override
  Color? get bordercolor => super.bordercolor ?? (parent is TableModel ? (parent as TableModel).bordercolor : null);

  @override
  double? get borderwidth => super.borderwidth ?? 1;

  @override
  String? get halign => super.halign ?? (parent is TableModel ? (parent as TableModel).halign : null);

  @override
  String? get valign => super.valign ?? (parent is TableModel ? (parent as TableModel).valign : null);

  @override
  bool? get center => super.center ?? (parent is TableModel ? (parent as TableModel).center : null);

  Color? get headerbordercolor
  {
    if ((parent != null) && (parent is TableModel))
    {
      return (parent as TableModel).bordercolor;
    }
    return null;
  }

  @override
  void layoutComplete(Size size, Offset offset)
  {
    var height = cellHeight;

    super.layoutComplete(size, offset);
    for (var cell in cells)
    {
      cellHeight = max(cellHeight ?? 0, cell.viewHeight ?? 0);
    }

    var refresh = cellHeight != height;
    if (refresh && parent is TableModel)
    {
      var parent = (this.parent as TableModel);
      WidgetsBinding.instance.addPostFrameCallback((_) => parent.notifyListeners("cellheight", cellHeight));
    }
  }

  /// Allows header to be resized by dragging
  /// Defaults to true
  BooleanObservable? _draggable;
  set draggable(dynamic v)
  {
    if (_draggable != null)
    {
      _draggable!.set(v);
    }
    else if (v != null)
    {
      _draggable = BooleanObservable(Binding.toKey(id, 'draggable'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get draggable => _draggable?.get() ?? true;

  TableBodyModel(WidgetModel parent, String? id, {dynamic width, dynamic height, dynamic color}) : super(parent, id, scope: Scope(parent: parent.scope))
  {
    if (width  != null) this.width  = width;
    if (height != null) this.height = height;
    this.color = color;
  }

  static TableBodyModel? fromXml(WidgetModel parent, XmlElement xml, {Map<dynamic, dynamic>? data})
  {
    TableBodyModel? model;
    try
    {
      model = TableBodyModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'tableHeader.Model');
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

    // Get Cells
    List<TableHeaderCellModel> models = findChildrenOfExactType(TableHeaderCellModel).cast<TableHeaderCellModel>();
    for (TableHeaderCellModel model in models)
    {
      cells.add(model);
    }
  }

  bool onSort(TableHeaderCellModel model)
  {
    int? index = children?.indexOf(model);
    if (index != null && parent is TableModel)
    {
      (parent as TableModel).onSort(index);
    }
    return true;
  }

  @override
  List<Widget> inflate()
  {
    // process children
    List<Widget> views = [];
    for (var model in cells)
    {
      var view = model.getView();
      view = LayoutBoxChildData(child: view!, model: model);
      views.add(view);
    }
    return views;
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
    scope?.dispose();
  }
}
