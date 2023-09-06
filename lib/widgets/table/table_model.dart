// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/form/form_interface.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/table/table_view.dart';
import 'package:fml/widgets/table/table_header_model.dart';
import 'package:fml/widgets/table/table_header_cell_model.dart';
import 'package:fml/widgets/table/table_row_model.dart';
import 'package:fml/widgets/table/table_row_cell_model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class TableModel extends BoxModel implements IForm
{
  final double defaultPadding = 4;

  // data grids are grids that do not define a complex row/cell schema
  bool get isSimpleGrid => prototypeRowCell  == null;

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

  // text color
  ColorObservable? _textColor;
  set textColor(dynamic v)
  {
    if (_textColor != null) {
      _textColor!.set(v);
    } else if (v != null) {
      _textColor = ColorObservable(Binding.toKey(id, 'textcolor'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color get textColor => _textColor?.get() ?? Colors.black;

  // text Size
  DoubleObservable? _textSize;
  set textSize(dynamic v)
  {
    if (_textSize != null) {
      _textSize!.set(v);
    } else if (v != null) {
      _textSize = DoubleObservable(Binding.toKey(id, 'textsize'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double get textSize => _textSize?.get() ?? 14;

  // allow sorting
  BooleanObservable? _menu;
  set menu(dynamic v)
  {
    if (_menu != null)
    {
      _menu!.set(v);
    }
    else if (v != null)
    {
      _menu = BooleanObservable(Binding.toKey(id, 'menu'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get menu => _menu?.get() ?? true;

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

  // editable - used on non row prototype only
  BooleanObservable? _editable;
  set editable(dynamic v)
  {
    if (_editable != null)
    {
      _editable!.set(v);
    }
    else if (v != null)
    {
      _editable = BooleanObservable(Binding.toKey(id, 'editable'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool? get editable => _editable?.get();

  // allow filtering
  BooleanObservable? _filter;
  set filter(dynamic v)
  {
    if (_filter != null)
    {
      _filter!.set(v);
    }
    else if (v != null)
    {
      _filter = BooleanObservable(Binding.toKey(id, 'filter'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get filter => _filter?.get() ?? false;

  // show filter bar
  BooleanObservable? _filterBar;
  set filterBar(dynamic v)
  {
    if (_filterBar != null)
    {
      _filterBar!.set(v);
    }
    else if (v != null)
    {
      _filterBar = BooleanObservable(Binding.toKey(id, 'filterbar'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get filterBar => _filterBar?.get() ?? false;
  
  // current row selected
  TableRowModel? _rowSelected;

  // current column selected
  TableRowCellModel? _cellSelected;

  // data map from the row that is currently selected
  ListObservable? _selected;
  set selected(dynamic v)
  {
    if (_selected != null)
    {
      _selected!.set(v);
    }
    else if (v != null)
    {
      // we don't want this to update the table view so don't add listener: onPropertyChange
      _selected = ListObservable(Binding.toKey(id, 'selected'), null, scope: scope);
      _selected!.set(v);
    }
  }
  dynamic get selected => _selected?.get();

  // prototype
  XmlElement? prototypeHeaderCell;
  XmlElement? prototypeRowCell;
  XmlElement? prototypeRow;

  TableHeaderModel? header;

  final HashMap<int, TableRowModel> rows = HashMap<int, TableRowModel>();

  // onChange - only used for simple data grid
  StringObservable? _onChange;
  set onChange(dynamic v)
  {
    if (_onChange != null)
    {
      _onChange!.set(v);
    }
    else if (v != null)
    {
      _onChange = StringObservable(Binding.toKey(id, 'onchange'), v, scope: scope);
    }
  }
  String? get onChange => _onChange?.get();
  
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
    menu       = Xml.get(node: xml, tag: 'menu');
    sortable   = Xml.get(node: xml, tag: 'sortable');
    draggable  = Xml.get(node: xml, tag: 'draggable');
    resizeable = Xml.get(node: xml, tag: 'resizeable');
    editable   = Xml.get(node: xml, tag: 'editable');

    // used in simple grids
    textSize   = Xml.get(node: xml, tag: 'textSize') ?? Xml.get(node: xml, tag: 'fontSize');
    textColor  = Xml.get(node: xml, tag: 'textColor') ?? Xml.get(node: xml, tag: 'fontColor');

    // legacy support
    var paged = S.toBool(Xml.get(node: xml, tag: 'pagesize'));
    if (paged != false)
    {
      var size = Xml.get(node: xml, tag: 'pagesize');
      if (size == null && paged == true) size = "20";
      pageSize = size;
    }

    // events
    onChange = Xml.get(node: xml, tag: 'onchange');

    // filter
    filter = Xml.get(node: xml, tag: 'filter');
    filterBar = Xml.get(node: xml, tag: 'filterbar');

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

    // this forces a table refresh
    var view = findListenerOfExactType(TableViewState);
    if (view is TableViewState)
    {
      view.refresh();
    }

    return true;
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async {
    await _build(source, list);
    busy = false;
    return true;
  }

  // export to excel
  Future<bool> export(String? format) async
  {
    try
    {
      var view = findListenerOfExactType(TableViewState);
      if (view is TableViewState)
      {
        switch (format?.toLowerCase().trim())
        {
          case "raw" :
            var file  = await Data.toCsv(Data.from(data));
            var bytes = utf8.encode(file);
            Platform.fileSaveAs(bytes, "${S.newId()}.csv");
            break;

          case "csv" :
            var bytes = await view.exportToCSVBytes();
            if (bytes != null) Platform.fileSaveAs(bytes, "${S.newId()}.csv");
            break;

          case "pdf":
          default:
            var bytes = await view.exportToPDF();
            if (bytes != null) Platform.fileSaveAs(bytes, "${S.newId()}.pdf");
            break;
        }
      }
    }
    catch(e)
    {
      print (e);
    }
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
      for (var model in rows.values)
      {
        ok = await model.complete();
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
    if (prototypeHeaderCell == null || this.header == null) return;

    var header = this.header!;

    // clear old header cells
    for (var cell in header.cells)
    {
      cell.dispose();
    }
    header.cells.clear();

    // build header prototype cells
    if (data != null && data.isNotEmpty)
    {
      var prototype = prototypeHeaderCell.toString();
      data[0].forEach((key, value)
      {
        if (key != 'xml' && key != 'rownum')
        {
          // header cell
          var xml   = prototype.replaceAll("{field}", key);
          var model = TableHeaderCellModel.fromXmlString(header, xml) ?? TableHeaderCellModel(header, null);
          header.cells.add(model);
        }
      });
    }

    // no prototype row
    if (isSimpleGrid) return;

    // clear prototype row cells
    prototypeRow ??= XmlElement(XmlName("TR"));
    prototypeRow!.children.clear();

    // build row prototype cells
    if (data != null && data.isNotEmpty)
    {
      var prototype = prototypeRowCell.toString();
      data[0].forEach((key, value)
      {
        if (key != 'xml' && key != 'rownum')
        {
          var xml  = prototype.replaceAll("{field}", "{data.$key}");
          var doc  = Xml.tryParse(xml);
          var node = doc?.rootElement.copy() ?? XmlElement(XmlName("TD"));
          prototypeRow!.children.add(node);
        }
      });
    }

    // apply prototype conversions
    prototypeRow = WidgetModel.prototypeOf(prototypeRow);
  }

  Future<bool> onChangeHandler(int rowIdx, int colIdx, dynamic value, dynamic oldValue) async
  {
    bool ok = true;
    var data = getDataRow(rowIdx);
    var col  = header?.cell(colIdx);
    var fld  = col?.field;

    if (data != null && col != null && fld != null)
    {
      Data.writeValue(data, fld, value);

      // fire the onchange event
      if (_onChange != null)
      {
        bool ok = await col.onChangeHandler();
        if (ok) await EventHandler(this).execute(_onChange);
      }
    }
    return ok;
  }
  
  void onSelect(TableRowModel row, TableRowCellModel cell)
  {
    // deselect - same row/cell clicked
    if (_rowSelected == row && _cellSelected == cell)
    {
      // deselect row and cell
      row.selected  = false;
      cell.selected = false;

      // clear current selected row and cell
      _rowSelected  = null;
      _cellSelected = null;

      // clear data
      selected = [];
    }

    // select - different row and/or cell
    else
    {
      // deselect current row and cell
      if (_rowSelected  != row )  _rowSelected?.selected  = false;
      if (_cellSelected != cell ) _cellSelected?.selected = false;

      // select row and cell
      row.selected  = true;
      cell.selected = true;

      // set current selected row and cell
      _rowSelected  = row;
      _cellSelected = cell;

      // set data
      selected = row.data;
    }
  }

  // returns the specified row in data
  dynamic getDataRow(int rowIdx) => (rowIdx >= 0 && data is Data && rowIdx < data.length) ? data[rowIdx] : null;

  // returns the length of the dataset
  int getDataRowCount() => data is Data ? (data as Data).length : 0;

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
        var format = S.toStr(S.item(arguments, 0));
        await export(format);
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  @override
  Widget getView({Key? key}) => getReactiveView(TableView(this));
}
