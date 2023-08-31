// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/form/form_interface.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/table/table_view.dart';
import 'package:fml/widgets/table/table_header_model.dart';
import 'package:fml/widgets/table/table_header_cell_model.dart';
import 'package:fml/widgets/table/table_footer_model.dart';
import 'package:fml/widgets/table/table_row_model.dart';
import 'package:fml/widgets/table/table_row_cell_model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

enum PaddingType { none, first, last, evenly, proportionately }

class TableModel extends BoxModel implements IForm
{
  final double defaultPadding = 4;

  @override
  double? get paddingTop => super.paddingTop ?? defaultPadding;

  @override
  double? get paddingRight => super.paddingRight ?? defaultPadding;

  @override
  double? get paddingBottom => super.paddingBottom ?? defaultPadding;

  @override
  double? get paddingLeft => super.paddingLeft ?? defaultPadding;

  @override
  String get radius => super.radius ?? "10";

  @override
  String get halign => super.halign ?? "center";

  @override
  String get valign => super.valign ?? "center";

  // allow sorting
  BooleanObservable? _sortable;
  set sortable(dynamic v)
  {
    if (_sortable != null)
    {
      _sortable!.set(v);
    }
    else if (v != null)
    {
      _sortable = BooleanObservable(Binding.toKey(id, 'sortable'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get sortable => _sortable?.get() ?? true;

  // allow reordering
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

  // allow resizing
  BooleanObservable? _resizeable;
  set resizeable(dynamic v)
  {
    if (_resizeable != null)
    {
      _resizeable!.set(v);
    }
    else if (v != null)
    {
      _resizeable = BooleanObservable(Binding.toKey(id, 'resizeable'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get resizeable => _resizeable?.get() ?? true;

  // prototype
  XmlElement? prototypeHeaderCell;
  XmlElement? prototypeRowCell;
  XmlElement? prototypeRow;

  TableHeaderModel? header;
  TableFooterModel? footer;

  final HashMap<int, TableRowModel> rows = HashMap<int, TableRowModel>();

  // onccomplete
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
  @override
  BooleanObservable? get dirtyObservable => _dirty;
  BooleanObservable? _dirty;
  @override
  set dirty(dynamic v)
  {
    if (_dirty != null)
    {
      _dirty!.set(v);
    }
    else if (v != null)
    {
      _dirty = BooleanObservable(Binding.toKey(id, 'dirty'), v, scope: scope);
    }
  }
  @override
  bool get dirty => _dirty?.get() ?? false;

  void onDirtyListener(Observable property)
  {
    bool isDirty = false;
    for (var entry in rows.entries)
    {
      if ((entry.value.dirty == true))
      {
        isDirty = true;
        break;
      }
    }
    dirty = isDirty;
  }

  // Clean
  @override
  set clean(bool b)
  {
    dirty = false;
    rows.forEach((index, row) => row.dirty = false);
  }

  // page size - used for paging
  IntegerObservable? _pageSize;
  set pageSize(dynamic v)
  {
    if (_pageSize != null)
    {
      _pageSize!.set(v);
    }
    else if (v != null)
    {
      _pageSize = IntegerObservable(Binding.toKey(id, 'pagesize'), v, scope: scope, listener: onPropertyChange);
    }
  }
  int get pageSize => _pageSize?.get() ?? 0;

  TableModel(WidgetModel parent, String? id) : super(parent, id)
  {
    // instantiate busy observable
    busy = false;
  }

  static TableModel? fromXml(WidgetModel parent, XmlElement xml) {
    TableModel? model;
    try
    {
      model = TableModel(parent, Xml.get(node: xml, tag: 'id'));
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
    busy = false;

    // deserialize
    super.deserialize(xml);

    // properties
    sortable   = Xml.get(node: xml, tag: 'sortable');
    draggable  = Xml.get(node: xml, tag: 'draggable');
    resizeable = Xml.get(node: xml, tag: 'resizeable');
    pageSize   = Xml.get(node: xml, tag: 'pagesize');
    oncomplete = Xml.get(node: xml, tag: 'oncomplete');

    // Get Table Header
    List<TableHeaderModel> headers = findChildrenOfExactType(TableHeaderModel).cast<TableHeaderModel>();
    if (headers.isNotEmpty)
    {
      header = headers.first;
      if (header!.cells.length == 1)
      {
        prototypeHeaderCell = header!.cells.first.element;
      }
    }

    // Get Table Footer
    List<TableFooterModel> footers = findChildrenOfExactType(TableFooterModel).cast<TableFooterModel>();
    if (footers.isNotEmpty)
    {
      footer = footers.first;
    }

    // dynamic?
    List<TableRowModel> rows = findChildrenOfExactType(TableRowModel).cast<TableRowModel>();
    if (rows.isNotEmpty)
    {
      prototypeRow = WidgetModel.prototypeOf(rows.first.element);
      if (rows.first.cells.length == 1)
      {
        prototypeRowCell = rows.first.cells.first.element;
      }
    }
  }

  TableRowModel? getEmptyRowModel()
  {
    // build model
    TableRowModel? model = TableRowModel.fromXml(this, prototypeRow, data: null);
    if (model?.cells != null)
    {for (var cell in model!.cells)
    {
      cell.visible = false;
    }}
    return model;
  }

  TableRowModel? getRowModel(int index)
  {
    // model exists?
    if (data == null) return null;
    if (data.length < (index + 1)) return null;
    if (rows.containsKey(index)) return rows[index];
    if (index.isNegative || data.length < index) return null;

    // build row model
    TableRowModel? model = TableRowModel.fromXml(this, prototypeRow, data: data[index]);

    // Register Listener to Dirty Field
    if (model?.dirtyObservable != null) model?.dirtyObservable!.registerListener(onDirtyListener);

    if (model != null) rows[index] = model;

    return model;
  }

  TableRowCellModel? getRowCellModel(int rowIdx, int cellIdx)
  {
    TableRowModel? model = getRowModel(rowIdx);
    if (model == null || cellIdx > model.cells.length) return null;
    return model.cells[max(cellIdx,0)];
  }

  Future<bool> _build(IDataSource source, Data? data) async
  {
    if (S.isNullOrEmpty(datasource) || datasource == source.id)
    {
      await _buildDynamic(data);

      clean = true;

      // clear rows
      rows.forEach((_,row) => row.dispose());
      rows.clear();

      this.data = data;
    }
    notifyListeners('list', null);
    return true;
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async {
    await _build(source, list);
    busy = false;
    return true;
  }

  // export to excel
  Future<bool> export() async
  {
    var data = Data.from(this.data);

    // convert to data
    String csv = await Data.toCsv(data);

    // encode
    var csvBytes = utf8.encode(csv);

    // save to file
    Platform.fileSaveAs(csvBytes, "${S.newId()}.csv");

    return true;
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');

    // cleanup
    header?.dispose();

    // clear rows
    rows.forEach((_,row) => row.dispose());
    rows.clear();

    super.dispose();
  }

  @override
  Future<bool> complete() async
  {
    busy = true;

    bool ok = true;

    // post the form
    if (dirty)
    {
      for (var entry in rows.entries)
      {
        ok = await entry.value.complete();
      }
  }
    busy = false;
    return ok;
  }

  @override
  Future<bool> validate() async => true;

  @override
  Future<bool> save() async => true;

  Future<void> _buildDynamic(Data? data) async
  {
    // both header and row prototypes must be defined
    if (prototypeHeaderCell == null || prototypeRowCell == null) return;

    // clear old header cells
    for (var cell in header!.cells)
    {
      cell.dispose();
    }
    header!.cells.clear();

    // clear prototype row cells
    prototypeRow ??= XmlElement(XmlName("ROW"));
    prototypeRow!.children.clear();

    if (data != null && data.isNotEmpty)
    {
      var headerCell = prototypeHeaderCell.toString();
      var rowCell = prototypeRowCell.toString();
      data[0].forEach((key, value)
      {
        if (key != 'xml' && key != 'rownum')
        {
          // header cell
          var xml = headerCell.replaceAll("{field}", key);
          var m1 = TableHeaderCellModel.fromXmlString(this, xml);

          // row cells
          xml = rowCell.replaceAll("{field}", "{data.$key}");
          var m2 = Xml.tryParse(xml);

          if (m1 != null && m2 != null)
          {
            header?.cells.add(m1);
            prototypeRow!.children.add(m2.rootElement.copy());
          }
        }
      });
    }

    // make prototype conversions
    prototypeRow = WidgetModel.prototypeOf(prototypeRow);
  }

  void onSelect(TableRowModel row, TableRowCellModel cell)
  {
    if (selectedRow == row && selectedCell == cell)
    {
      // Deselect
      selectedRow?.selected = false;
      selectedCell?.selected = false;
      selectedRow = null;
      selectedCell = null;
      selected = [];
    }
    else
    {
      // new selection
      // Unselect the previous selected row/cell models
      selectedRow?.selected = false;
      selectedCell?.selected = false;
      // Set selected on the new row/cell selection
      row.selected = true;
      cell.selected = true;
      // Update our table selected row/cell models so we have easy access to them
      selectedRow = row;
      selectedCell = cell;
      // Update the bindables to the selected row data
      selected = selectedRow!.data;
    }
  }

  @override
  Future<bool?> execute(String caller, String propertyOrFunction, List<dynamic> arguments) async
  {
    /// setter
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    switch (function)
    {
      // export the data
      case "export" :
        await export();
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  @override
  Widget getView({Key? key}) => getReactiveView(TableView(this));
}
