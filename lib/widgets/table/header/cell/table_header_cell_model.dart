// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/column/column_model.dart';
import 'package:fml/widgets/table/header/table_header_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class TableHeaderCellModel extends ColumnModel
{
  // shrink in both axis
  @override
  bool get expandHorizontally => false;

  @override
  bool get expandVertically => false;

  // position in row
  int? get index
  {
    if (parent is TableHeaderModel)
    {
      return (parent as TableHeaderModel).children?.indexOf(this);
    }
    return null;
  }

  @override
  double? get height
  {
    if (parent is TableHeaderModel)
    {
      return (parent as TableHeaderModel).cellHeight ?? super.height;
    }
    return null;
  }

  // sort
  String? sort;
  String? sortType;
  bool isSorting = false;

  // field
  String? field;

  @override
  String? get border
  {
    var b = super.border ?? "all";
    return b;
  }

  @override
  double? get paddingTop => super.paddingTop ?? (parent is TableHeaderModel ? (parent as TableHeaderModel).paddingTop : null) ?? 2;

  @override
  double? get paddingBottom => super.paddingBottom ?? (parent is TableHeaderModel ? (parent as TableHeaderModel).paddingBottom : null) ?? 2;

  @override
  double? get paddingLeft => super.paddingLeft ?? (parent is TableHeaderModel ? (parent as TableHeaderModel).paddingLeft : null) ?? 10;

  @override
  double? get paddingRight => super.paddingRight ?? (parent is TableHeaderModel ? (parent as TableHeaderModel).paddingRight : null) ?? 10;

  @override
  Color? get color => super.color ?? (parent is TableHeaderModel ? (parent as TableHeaderModel).color : null);

  @override
  Color? get bordercolor => super.bordercolor ?? (parent is TableHeaderModel ? (parent as TableHeaderModel).bordercolor : null);

  @override
  String? get halign => super.halign ?? (parent is TableHeaderModel ? (parent as TableHeaderModel).halign : null);

  @override
  String? get valign => super.valign ?? (parent is TableHeaderModel ? (parent as TableHeaderModel).valign : null);

  @override
  bool? get center => super.center ?? (parent is TableHeaderModel ? (parent as TableHeaderModel).center : null);

  //@override
  //bool? get wrap => super.wrap ?? (parent is TableHeaderModel ? (parent as TableHeaderModel).wrap : null);

  /// wrap is a boolean that dictates if the widget will wrap or not.
  BooleanObservable? _sortbydefault;
  set sortbydefault(dynamic v)
  {
    if (_sortbydefault != null)
    {
      _sortbydefault!.set(v);
    }
    else if (v != null)
    {
      _sortbydefault = BooleanObservable(Binding.toKey(id, 'sortbydefault'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get sortbydefault => _sortbydefault?.get() ?? false;

  BooleanObservable? _sortAscending;
  set sortAscending(dynamic v) {
    if (_sortAscending != null) {
      _sortAscending!.set(v);
    } else if (v != null) {
      _sortAscending = BooleanObservable(
          Binding.toKey(id, 'sortAscending'), v,
          scope: scope);
    }
  }
  bool get sortAscending => _sortAscending?.get() ?? false;

  bool sorted = false;

  TableHeaderCellModel(WidgetModel parent, String? id, {String? field, dynamic width, dynamic height, dynamic sortbydefault}) : super(parent, id)
  {
    if (width  != null) this.width  = width;
    if (height != null) this.height = height;
    this.sortbydefault = sortbydefault;
    sortAscending = false;
  }

  static TableHeaderCellModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    TableHeaderCellModel? model;
    try
    {
      model = TableHeaderCellModel(parent, null);
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'column.Model');
      model = null;
    }
    return model;
  }

  static TableHeaderCellModel? fromXmlString(WidgetModel parent, String xml)
  {
    XmlDocument? document = Xml.tryParse(xml);
    return (document != null) ? TableHeaderCellModel.fromXml(parent, document.rootElement) : null;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);

    // properties
    field       = Xml.get(node: xml, tag: 'field');
    sortbydefault       = Xml.get(node: xml, tag: 'sortbydefault');
    bordercolor = Xml.get(node: xml, tag: 'bordercolor');
    borderwidth = Xml.get(node: xml, tag: 'borderwidth');

    /////////////
    /* Sorting */
    /////////////
    var sortString = Xml.get(node: xml, tag: 'sort');
    if (!S.isNullOrEmpty(sortString)) {
      var s = sortString!.split(',');
      if ((s.isNotEmpty) && (!S.isNullOrEmpty(s[0]))) {
        sort = s[0];
        sortAscending = false;
      }
      if ((s.length > 1) && (!S.isNullOrEmpty(s[1]))) sortType = s[1];
    }
  }

  bool onSort()
  {
    if ((parent != null) && (parent is TableHeaderModel))
    {
      (parent as TableHeaderModel).onSort(this);
    }
    return true;
  }
}
