// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/table/header/table_header_model.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class TableHeaderCellModel extends DecoratedWidgetModel
{
  /////////////////////
  /* Position in Row */
  /////////////////////
  int? get index {
    if ((parent != null) && (parent is TableHeaderModel))
      return (parent as TableHeaderModel).cells.indexOf(this);
    return null;
  }

  /////////////////////
  /* Used for Layout */
  /////////////////////
  Size? size;

  //////////
  /* sort */
  //////////
  String? sort;
  String? sortType;
  bool isSorting = false;

  ///////////
  /* field */
  ///////////
  String? field;

  ///////////
  /* Color */
  ///////////
  ColorObservable? _color;
  Color? get color {
    if (_color == null) {
      if ((this.parent != null) && (this.parent is TableHeaderModel))
        return (this.parent as TableHeaderModel).color;
      return null;
    }
    return _color?.get();
  }

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
      if ((this.parent != null) && (this.parent is TableHeaderModel))
        return (this.parent as TableHeaderModel).bordercolor;
      return null;
    }
    return _bordercolor?.get();
  }

  Color? get outerbordercolor {
    Color? color;
    if ((this.parent != null) && (this.parent is TableHeaderModel))
      color = (this.parent as TableHeaderModel).bordercolor;
    return color;
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
      if ((this.parent != null) && (this.parent is TableHeaderModel))
        return (this.parent as TableHeaderModel).borderwidth;
      return null;
    }
    return _borderwidth?.get();
  }

  /// alignment and layout attributes
  ///
  /// The horizontal alignment of the widgets children, overrides `center`. Can be `left`, `right`, `start`, or `end`.
  StringObservable? _halign;
  set halign(dynamic v) {
    if (_halign != null) {
      _halign!.set(v);
    } else if (v != null) {
      _halign = StringObservable(Binding.toKey(id, 'halign'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get halign {
    if (_halign == null) {
      if ((this.parent != null) && (this.parent is TableHeaderModel))
        return (this.parent as TableHeaderModel).halign;
      return null;
    }
    return _halign?.get();
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

  bool get center
  {
    if (_center == null)
    {
      if ((this.parent != null) && (this.parent is TableHeaderModel)) return (this.parent as TableHeaderModel).center;
      return false;
    }
    return _center?.get() ?? false;
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

  bool get wrap
  {
    if (_wrap == null)
    {
      if ((this.parent != null) && (this.parent is TableHeaderModel)) return (this.parent as TableHeaderModel).wrap;
      return false;
    }
    return _wrap?.get() ?? false;
  }

  /// wrap is a boolean that dictates if the widget will wrap or not.
  BooleanObservable? _sortbydefault;
  set sortbydefault(dynamic v) {
    if (_sortbydefault != null) {
      _sortbydefault!.set(v);
    } else if (v != null) {
      _sortbydefault = BooleanObservable(Binding.toKey(id, 'sortbydefault'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get sortbydefault {
    return _sortbydefault?.get() ?? false;
  }

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
    this.sortAscending = false;
  }

  static TableHeaderCellModel? fromXml(WidgetModel parent, XmlElement xml) {
    TableHeaderCellModel? model;
    try {
      model = TableHeaderCellModel(parent, null);
      model.deserialize(xml);
    } catch(e) {
      Log().exception(e,
           caller: 'column.Model');
      model = null;
    }
    return model;
  }

  static TableHeaderCellModel? fromXmlString(WidgetModel parent, String xml) {
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

  bool onSort() {
    if ((this.parent != null) && (this.parent is TableHeaderModel))
      (this.parent as TableHeaderModel).onSort(this);
    return true;
  }

  @override
  dispose() {
// Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }
}
