// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/form/form_field_interface.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/event/handler.dart' ;
import 'package:fml/widgets/table/table_model.dart';
import 'package:fml/widgets/table/table_row_cell_model.dart';
import 'package:fml/widgets/form/form_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class TableRowModel extends BoxModel
{
  @override
  String? get layout => super.layout ?? "row";

  // cells
  final List<TableRowCellModel> cells = [];

  // table
  TableModel? get table => parent is TableModel ? parent as TableModel : null;

  @override
  double? get paddingTop => super.paddingTop ?? table?.paddingTop;

  @override
  double? get paddingRight => super.paddingRight ?? table?.paddingRight;

  @override
  double? get paddingBottom => super.paddingBottom ?? table?.paddingBottom;

  @override
  double? get paddingLeft => super.paddingLeft ?? table?.paddingLeft;

  @override
  String? get halign => super.halign ?? table?.halign;

  @override
  String? get valign => super.valign ?? table?.valign;

  // cell by index
  TableRowCellModel? cell(int index) => index >= 0 && index < cells.length ? cells[index] : null;

  late XmlElement cellprototype;

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
  int? get index => _index?.get() ?? 0;

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

  // onCcomplete
  StringObservable? _oncomplete;
  set oncomplete(dynamic v)
  {
    if (_oncomplete != null)
    {
      _oncomplete!.set(v);
    }
    else if (v != null)
    {
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

  TableRowModel(WidgetModel parent, String? id, {dynamic data}) : super(parent, id, scope: Scope(parent: parent.scope))
  {
    this.data = data;
    dirty = false;
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
    oncomplete  = Xml.get(node: xml, tag: 'oncomplete');
    onclick     = Xml.get(node: xml, tag: 'onclick');
    postbrokers = Xml.attribute(node: xml, tag: 'postbroker');

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
      for (var field in fields)
      {
        if (this.fields == null) this.fields = [];
        this.fields!.add(field);

        // Register Listener
        if (field.dirtyObservable != null) field.dirtyObservable!.registerListener(onDirtyListener);
      }
    }

    // Prototype?
    if ((cells.length == 1) && (cells[0].element!.toXmlString().contains("{field}")))
    {
      cellprototype = cells[0].element!.copy();
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
          if (!source.custombody)
          {
            source.body = await FormModel.buildPostingBody(fields, rootname: source.root ?? "FORM");
          }
          ok = await source.start();
        }
        if (!ok) break;
      }}
    else {
      ok = false;
    }
    return ok;
  }

  void onSelect(TableRowCellModel cell)
  {
    if ((parent != null) && (parent is TableModel))
    {
      //(parent as TableModel).onSelect(this, cell);
    }
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
    scope?.dispose();
  }
}
