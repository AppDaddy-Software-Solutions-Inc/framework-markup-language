// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/table/table_model.dart';
import 'package:fml/widgets/table/header/cell/table_header_cell_model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class TableHeaderModel extends DecoratedWidgetModel
{
  ///////////
  /* Cells */
  ///////////
  final List<TableHeaderCellModel> cells = [];

  // prototype
  XmlElement? prototype;

  //////////////////
  /* border color */
  //////////////////
  ColorObservable? _bordercolor;
  set bordercolor(dynamic v) {
    if (_bordercolor != null) {
      _bordercolor!.set(v);
    } else if (v != null) {
      _bordercolor = ColorObservable(
          Binding.toKey(id, 'bordercolor'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  Color? get bordercolor {
    if (_bordercolor == null) {
      if ((this.parent != null) && (this.parent is TableModel))
        return (this.parent as TableModel).bordercolor;
      return null;
    }
    return _bordercolor?.get();
  }

  Color? get headerbordercolor {
    if ((this.parent != null) && (this.parent is TableModel))
      return (this.parent as TableModel).bordercolor;
    return null;
  }

  //////////////////
  /* border width */
  //////////////////
  DoubleObservable? _borderwidth;
  set borderwidth(dynamic v) {
    if (_borderwidth != null) {
      _borderwidth!.set(v);
    } else if (v != null) {
      _borderwidth = DoubleObservable(
          Binding.toKey(id, 'borderwidth'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get borderwidth {
    if (_borderwidth == null) {
      if ((this.parent != null) && (this.parent is TableModel))
        return (this.parent as TableModel).borderwidth;
      return null;
    }
    return _borderwidth?.get();
  }

  /// Allows header to be resized by dragging
  /// Defaults to true
  BooleanObservable? _draggable;
  set draggable(dynamic v) {
    if (_draggable != null) {
      _draggable!.set(v);
    } else if (v != null) {
      _draggable = BooleanObservable(Binding.toKey(id, 'draggable'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get draggable => _draggable?.get() ?? true;

  /// alignment and layout attributes
  ///
  /// The horizontal alignment of the widgets children, overrides `center`. Can be `left`, `right`, `start`, or `end`.
  StringObservable? _halign;
  String? get halign
  {
    if (_halign == null) {
      if ((this.parent != null) && (this.parent is TableModel))
        return (this.parent as TableModel).halign;
      return null;
    }
    return _halign?.get();
  }

  /// The vertical alignment of the widgets children, overrides `center`. Can be `top`, `bottom`, `start`, or `end`.
  StringObservable? _valign;
  String? get valign {
    if (_valign == null) {
      if ((this.parent != null) && (this.parent is TableModel))
        return (this.parent as TableModel).valign;
      return null;
    }
    return _valign?.get();
  }

  /// Center attribute allows a simple boolean override for halign and valign both being center. halign and valign will override center if given.
  BooleanObservable? _center;
  set center(dynamic v) {
    if (_center != null) {
      _center!.set(v);
    } else if (v != null) {
      _center = BooleanObservable(Binding.toKey(id, 'center'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool? get center {
    if (_center == null) {
      if ((this.parent != null) && (this.parent is TableModel))
        return (this.parent as TableModel).center;
      return null;
    }
    return _center?.get();
  }

  /// wrap is a boolean that dictates if the widget will wrap or not.
  BooleanObservable? _wrap;
  set wrap(dynamic v) {
    if (_wrap != null) {
      _wrap!.set(v);
    } else if (v != null) {
      _wrap = BooleanObservable(Binding.toKey(id, 'wrap'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool? get wrap {
    if (_wrap == null) {
      if ((this.parent != null) && (this.parent is TableModel))
        return (this.parent as TableModel).wrap;
      return null;
    }
    return _wrap?.get();
  }

  TableHeaderModel(WidgetModel parent, String? id, {dynamic width, dynamic height, dynamic color}) : super(parent, id, scope: Scope(parent: parent.scope))
  {
    this.width = width;
    this.height = height;
    this.color = color;
  }

  static TableHeaderModel? fromXml(WidgetModel parent, XmlElement xml, {Map<dynamic, dynamic>? data})
  {
    TableHeaderModel? model;
    try
    {
      model = TableHeaderModel(parent, Xml.get(node: xml, tag: 'id'));
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

    ///////////////
    /* Get Cells */
    ///////////////
    List<TableHeaderCellModel> cells = findChildrenOfExactType(TableHeaderCellModel).cast<TableHeaderCellModel>();
    for (TableHeaderCellModel model in cells) this.cells.add(model);

    ////////////////
    /* Prototype? */
    ////////////////
    if ((cells.length == 1) && (cells[0].element!.toXmlString().contains("{" + 'field' + "}"))) prototype = cells[0].element!.copy();
  }

  bool onSort(TableHeaderCellModel model)
  {
    int index = cells.indexOf(model);
    if ((this.parent != null) && (this.parent is TableModel))
      (this.parent as TableModel).onSort(index);
    return true;
  }

  @override
  dispose()
  {
    Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
    scope?.dispose();
  }
}
