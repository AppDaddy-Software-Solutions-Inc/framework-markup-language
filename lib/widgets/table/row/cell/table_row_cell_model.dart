// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/table/row/table_row_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class TableRowCellModel extends BoxModel
{
  @override
  LayoutType get layoutType => LayoutType.stack;

  /////////////////////
  /* Position in Row */
  /////////////////////
  int? get index {
    if ((parent != null) && (parent is TableRowModel)) {
      return (parent as TableRowModel).cells.indexOf(this);
    }
    return null;
  }

  //////////////
  /* selected */
  //////////////
  BooleanObservable? _selected;
  set selected(dynamic v) {
    if (_selected != null) {
      _selected!.set(v);
    } else if (v != null) {
      _selected = BooleanObservable(Binding.toKey(id, 'selected'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get selected => _selected?.get() ?? false;

  ///////////
  /* Color */
  ///////////
  ColorObservable? _color;
  @override
  Color? get color
  {
    if (selected == true) return selectedcolor;
    if ((parent != null) && (parent is TableRowModel) && ((parent as TableRowModel).selected == true)) return (parent as TableRowModel).selectedcolor;
    if (_color == null)
    {
      if ((parent != null) && (parent is TableRowModel)) return (parent as TableRowModel).color;
      return null;
    }
    return _color?.get();
  }

  ////////////////////
  /* alter color */
  ////////////////////
  ColorObservable? _altcolor;
  set altcolor(dynamic v) {
    if (_altcolor != null) {
      _altcolor!.set(v);
    } else if (v != null) {
      _altcolor = ColorObservable(
          Binding.toKey(id, 'altcolor'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  Color? get altcolor
  {
    if (selected == true) return selectedcolor;
    if ((parent != null) && (parent is TableRowModel) && ((parent as TableRowModel).selected == true)) return (parent as TableRowModel).selectedcolor;
    if (_altcolor == null)
    {
      if ((parent != null) && (parent is TableRowModel)) return (parent as TableRowModel).altcolor;
      return null;
    }
    return _altcolor?.get();
  }
  ////////////////////
  /* selected color */
  ////////////////////
  ColorObservable? _selectedcolor;
  set selectedcolor(dynamic v) {
    if (_selectedcolor != null) {
      _selectedcolor!.set(v);
    } else if (v != null) {
      _selectedcolor = ColorObservable(
          Binding.toKey(id, 'selectedcolor'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  Color? get selectedcolor
  {
    if (_selectedcolor == null)
    {
      if ((parent != null) && (parent is TableRowModel)) return (parent as TableRowModel).selectedcolor;
      return null;
    }
    return _selectedcolor?.get();
  }

  //////////////////
  /* border color */
  //////////////////
  ColorObservable? _bordercolor;
  @override
  set bordercolor(dynamic v) {
    if (_bordercolor != null) {
      _bordercolor!.set(v);
    } else if (v != null) {
      _bordercolor = ColorObservable(
          Binding.toKey(id, 'bordercolor'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  @override
  Color? get bordercolor
  {
    if (selected == true) return selectedbordercolor;
    if ((parent != null) && (parent is TableRowModel) && ((parent as TableRowModel).selected == true)) return (parent as TableRowModel).selectedbordercolor;
    if (_bordercolor == null)
    {
      if ((parent != null) && (parent is TableRowModel)) return (parent as TableRowModel).bordercolor;
      return null;
    }
    return _bordercolor?.get();
  }

  ///////////////////////////
  /* selected border color */
  ///////////////////////////
  ColorObservable? _selectedbordercolor;
  set selectedbordercolor(dynamic v) {
    if (_selectedbordercolor != null) {
      _selectedbordercolor!.set(v);
    } else if (v != null) {
      _selectedbordercolor = ColorObservable(
          Binding.toKey(id, 'selectedbordercolor'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  Color? get selectedbordercolor
  {
    if (_selectedbordercolor == null)
    {
      if ((parent != null) && (parent is TableRowModel)) return (parent as TableRowModel).selectedbordercolor;
      return null;
    }
    return _selectedbordercolor?.get();
  }

  ////////////////////////
  /* outer border color */
  ////////////////////////
  Color? get outerbordercolor
  {
    Color? color;
    if ((parent != null) && (parent is TableRowModel)) color = (parent as TableRowModel).bordercolor;
    return color;
  }

  /// alignment and layout attributes
  ///
  /// The horizontal alignment of the widgets children, overrides `center`. Can be `left`, `right`, `start`, or `end`.
  StringObservable? _halign;
  @override
  set halign(dynamic v) {
    if (_halign != null) {
      _halign!.set(v);
    } else if (v != null) {
      _halign = StringObservable(Binding.toKey(id, 'halign'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  @override
  String? get halign
  {
    if (_halign == null)
    {
      if ((parent != null) && (parent is TableRowModel)) return (parent as TableRowModel).halign;
      return null;
    }
    return _halign?.get();
  }

  /// The vertical alignment of the widgets children, overrides `center`. Can be `top`, `bottom`, `start`, or `end`.
  StringObservable? _valign;
  @override
  String? get valign {
    if (_valign == null) {
      if ((parent != null) && (parent is TableRowModel)) {
        return (parent as TableRowModel).valign;
      }
      return null;
    }
    return _valign?.get();
  }

  ////////////////////
  /* expanded width */
  ////////////////////
  DoubleObservable? _expandedwidth;
  set expandedwidth(dynamic v) {
    if (_expandedwidth != null) {
      _expandedwidth!.set(v);
    } else if (v != null) {
      _expandedwidth = DoubleObservable(
          Binding.toKey(id, 'expandedwidth'), v,
          scope: scope);
    }
  }
  double? get expandedwidth => _expandedwidth?.get();

  /////////////////////
  /* expanded height */
  /////////////////////
  DoubleObservable? _expandedheight;
  set expandedheight(dynamic v) {
    if (_expandedheight != null) {
      _expandedheight!.set(v);
    } else if (v != null) {
      _expandedheight = DoubleObservable(
          Binding.toKey(id, 'expandedheight'), v,
          scope: scope);
    }
  }
  double? get expandedheight => _expandedheight?.get();

  TableRowCellModel(WidgetModel parent, String? id, {dynamic width, dynamic height, dynamic altcolor}) : super(parent, id)
  {
    if (width  != null) this.width  = width;
    if (height != null) this.height = height;
    this.altcolor = altcolor;
  }

  static TableRowCellModel? fromXml(WidgetModel parent, XmlElement xml) {
    TableRowCellModel? model;
    try
    {
      model = TableRowCellModel(parent, null);
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'column.Model');
      model = null;
    }
    return model;
  }

  static TableRowCellModel? fromXmlString(WidgetModel parent, String xml) {
    XmlDocument? document = Xml.tryParse(xml);
    return (document != null) ? TableRowCellModel.fromXml(parent, document.rootElement) : null;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize 
    super.deserialize(xml);

    // properties
    center        = Xml.get(node: xml, tag: 'center');
    wrap          = Xml.get(node: xml, tag: 'wrap');
    altcolor          = Xml.get(node: xml, tag: 'altcolor');
    selectedcolor = Xml.get(node: xml, tag: 'selectedcolor');
    selectedbordercolor = Xml.get(node: xml, tag: 'selectedbordercolor');
    bordercolor    = Xml.get(node: xml, tag: 'bordercolor');
    borderwidth    = Xml.get(node: xml, tag: 'borderwidth');
    expandedwidth  = Xml.get(node: xml, tag: 'expandedwidth');
    expandedheight = Xml.get(node: xml, tag: 'expandedheight');
  }

  void onSelect() {
    if (selected == false) selected = !selected;
    if ((parent != null) && (parent is TableRowModel)) {
      (parent as TableRowModel).onSelect(this);
    }
  }

  @override
  dispose() {
// Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }
}
