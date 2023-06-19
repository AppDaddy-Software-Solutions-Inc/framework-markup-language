// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_data.dart';
import 'package:fml/widgets/form/form_field_interface.dart';
import 'package:fml/widgets/row/row_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/event/handler.dart' ;
import 'package:fml/widgets/table/table_model.dart';
import 'package:fml/widgets/table/row/cell/table_row_cell_model.dart';
import 'package:fml/widgets/form/form_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class TableRowModel extends RowModel
{
  // shrink in both axis
  @override
  bool get expandHorizontally => false;

  @override
  bool get expandVertically => false;

  @override
  String get layout => "row";

  // Cells
  final List<TableRowCellModel> cells = [];

  // Editable Fields
  List<IFormField>? fields;

  // posting source source
  List<String>? _postbrokers;
  set postbrokers(dynamic v)
  {
    if (v is String)
    {
      var values = v.split(",");
      _postbrokers = [];
      for (var e in values) {
        if (!S.isNullOrEmpty(e)) _postbrokers!.add(e.trim());
      }
    }
  }
  List<String>? get postbrokers => _postbrokers;

  // index
  IntegerObservable? _index;
  set index(dynamic v) {
    if (_index != null) {
      _index!.set(v);
    } else {
      _index = IntegerObservable(Binding.toKey(id, 'index'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  int? get index => _index?.get();

  // selected
  BooleanObservable? _selected;
  set selected(dynamic v) {
    if (_selected != null) {
      _selected!.set(v);
    } else {
      _selected = BooleanObservable(Binding.toKey(id, 'selected'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get selected => _selected?.get() ?? false;

  // onclick
  StringObservable? _onclick;
  set onclick(dynamic v) {
    if (_onclick != null) {
      _onclick!.set(v);
    } else if (v != null) {
      _onclick = StringObservable(Binding.toKey(id, 'onclick'), v, scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }

  String? get onclick {
    return _onclick?.get();
  }

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

  // alter color
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
    if (_altcolor == null)
    {
      if ((parent != null) && (parent is TableModel)) return (parent as TableModel).altcolor;
      return null;
    }
    return _altcolor?.get();
  }

  // selected color
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

  Color? get selectedcolor {
    if (_selectedcolor == null) {
      if ((parent != null) && (parent is TableModel)) {
        return (parent as TableModel).selectedcolor;
      }
      return null;
    }
    return _selectedcolor?.get();
  }

  // selected border color
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

  Color? get selectedbordercolor {
    if (_selectedbordercolor == null) {
      if ((parent != null) && (parent is TableModel)) {
        return (parent as TableModel).selectedbordercolor;
      }
      return null;
    }
    return _selectedbordercolor?.get();
  }

  // onccomplete
  StringObservable? _oncomplete;
  set oncomplete(dynamic v) {
    if (_oncomplete != null) {
      _oncomplete!.set(v);
    } else if (v != null) {
      _oncomplete = StringObservable(Binding.toKey(id, 'oncomplete'), v, scope: scope, lazyEval: true);
    }
  }
  String? get oncomplete => _oncomplete?.get();

  // dirty
  BooleanObservable? get dirtyObservable => _dirty;
  BooleanObservable? _dirty;
  set dirty(dynamic v) {
    if (_dirty != null) {
      _dirty!.set(v);
    } else if (v != null) {
      _dirty = BooleanObservable(Binding.toKey(id, 'dirty'), v,
          scope: scope);
    }
  }
  bool get dirty => _dirty?.get() ?? false;

  void onDirtyListener(Observable property)
  {
    bool isDirty = false;
    if (fields != null){
      for (IFormField field in fields!) {
        if (field.dirty ?? false)
        {
          isDirty = true;
          break;
        }
      }}
    dirty = isDirty;
  }

  TableRowModel(
    WidgetModel parent,
    String? id, {
    dynamic data,
    dynamic width,
    dynamic height,
    dynamic oncomplete,
    dynamic halign,
    dynamic valign,
    dynamic center,
    dynamic altcolor,
    dynamic wrap,
    dynamic color,
    dynamic onclick,
  }) : super(parent, id, scope: Scope(parent: parent.scope))
  {
    if (width  != null) this.width  = width;
    if (height != null) this.height = height;

    this.data = data;
    this.altcolor = altcolor;
    this.oncomplete = oncomplete;
    dirty = false;
    this.color = color;
    this.halign = halign;
    this.center = center;
    this.valign = valign;
    this.wrap = wrap;
    this.onclick = onclick;
  }

  static TableRowModel? fromXml(WidgetModel parent, XmlElement? xml, {dynamic data})
  {
    if (xml == null) return null;
    TableRowModel? model;
    try
    {
      model = TableRowModel(parent, Xml.get(node: xml, tag: 'id'), data: data);
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'tableRow.Model');
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
    oncomplete    = Xml.get(node: xml, tag: 'oncomplete');
    selectedcolor = Xml.get(node: xml, tag: 'selectedcolor');
    altcolor = Xml.get(node: xml, tag: 'altcolor');
    bordercolor   = Xml.get(node: xml, tag: 'bordercolor');
    selectedbordercolor = Xml.get(node: xml, tag: 'selectedbordercolor');
    borderwidth  = Xml.get(node: xml, tag: 'borderwidth');
    center       = Xml.get(node: xml, tag: 'center');
    wrap         = Xml.get(node: xml, tag: 'wrap');
    onclick      = Xml.get(node: xml, tag: 'onclick');
    postbrokers  = Xml.attribute(node: xml, tag: 'postbroker');

    // Get Cells
    List<TableRowCellModel> models = findChildrenOfExactType(TableRowCellModel).cast<TableRowCellModel>();
    for (TableRowCellModel model in models)
    {
      cells.add(model);
    }

    // Initialize Form Fields
    for (TableRowCellModel _ in cells)
    {
      List<IFormField> fields = findChildrenOfExactType(IFormField).cast<IFormField>();
      for (var field in fields) {
        if (this.fields == null) this.fields = [];
        this.fields!.add(field);

        // Register Listener
        if (field.dirtyObservable != null) field.dirtyObservable!.registerListener(onDirtyListener);
      }
    }
  }

  @override
  void onPropertyChange(Observable observable)
  {
    notifyListeners(observable.key, observable.get());
  }

  Future<bool> onClick(BuildContext context) async
  {
    if (onclick == null) return true;
    return await EventHandler(this).execute(_onclick);
  }

  Future<bool> complete() async
  {
    busy = true;

    bool ok = true;

    // Post the Row
    if (ok) ok = await _post();
    
    // Mark Clean
    if ((ok) && (fields != null))
    {
      for (var field in fields!) {
        field.dirty = false;
      }
    }

    busy = false;

    return ok;
  }

  Future<bool> onComplete() async
  {
    busy = true;

    bool ok = true;

    // Post the Form
    if (ok && dirty) ok = await complete();

    busy = false;
    return ok;
  }

  Future<bool> _post() async
  {
    if (dirty == false) return true;

    bool ok = true;
    if ((scope != null) && (postbrokers != null)){
      for (String id in postbrokers!)
      {
        IDataSource? source = scope!.getDataSource(id);
        if ((source != null) && (ok))
        {
          if (source.custombody != true) source.body = await FormModel.buildPostingBody(fields, rootname: source.root ?? "FORM");
          ok = await source.start();
        }
        if (!ok) break;
      }}
    else {
      ok = false;
    }
    return ok;
  }

  void onSelect(TableRowCellModel cell) {
    if ((parent != null) && (parent is TableModel)) {
      (parent as TableModel).onSelect(this, cell);
    }
  }

  @override
  List<Widget> inflate()
  {
    // process children
    List<Widget> views = [];
    for (var model in cells)
    {
      var view = model.getView();
      view = LayoutBoxChildData(child: view, model: model);
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
