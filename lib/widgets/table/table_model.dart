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
import 'package:fml/widgets/table/table_footer_model.dart';
import 'package:fml/widgets/table/table_norows_model.dart';
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
  @override
  bool get canExpandInfinitelyWide => !hasBoundedWidth;

  @override
  bool get canExpandInfinitelyHigh => !hasBoundedHeight;

  // data sourced prototype
  XmlElement? prototype;

  // holds header
  TableHeaderModel? header;

  // holds header
  TableNoRowsModel? norows;

  // holds footer
  TableFooterModel? footer;

  // holds list of rows
  final HashMap<int, TableRowModel> rows = HashMap<int, TableRowModel>();

  final double defaultPadding = 4;

  // dynamically generated headers
  bool get hasDynamicHeaders => header?.isDynamic ?? false;

  // table has a data source
  bool get hasDataSource => !S.isNullOrEmpty(datasource);

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

  /// Post tells the form whether or not to include the field in the posting body. If post is null, visible determines post.
  BooleanObservable? _post;
  set post(dynamic v)
  {
    if (_post != null)
    {
      _post!.set(v);
    }
    else if (v != null)
    {
      _post = BooleanObservable(Binding.toKey(id, 'post'), v, scope: scope);
    }
  }
  @override
  bool? get post => _post?.get();

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

  // show busy spinner by default
  BooleanObservable? _showBusy;
  set showBusy(dynamic v)
  {
    if (_showBusy != null)
    {
      _showBusy!.set(v);
    }
    else if (v != null)
    {
      _showBusy = BooleanObservable(Binding.toKey(id, 'showbusy'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get showBusy => _showBusy?.get() ?? true;
  
  // show column menu by default
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
      _filterBar = BooleanObservable(Binding.toKey(id, 'filterbar'), v, scope: scope, listener: onFilterBarChange);
    }
  }
  bool get filterBar => _filterBar?.get() ?? false;

  // display shadow
  BooleanObservable? _shadow;
  set shadow(dynamic v)
  {
    if (_shadow != null)
    {
      _shadow!.set(v);
    }
    else if (v != null)
    {
      _shadow = BooleanObservable(Binding.toKey(id, 'shadow'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get shadow => _shadow?.get() ?? false;
  
  // current row selected
  TableRowModel? selectedRow;

  // current column selected
  TableRowCellModel? selectedCell;

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
      _pageSize = IntegerObservable(Binding.toKey(id, 'pagesize'), v, scope: scope, listener: onPageSizeChange);
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
    shadow     = Xml.get(node: xml, tag: 'shadow');
    showBusy   = Xml.get(node: xml, tag: 'showBusy');
    post       = Xml.get(node: xml, tag: 'post');

    // used in simple grids
    textSize   = Xml.get(node: xml, tag: 'textSize') ?? Xml.get(node: xml, tag: 'fontSize');
    textColor  = Xml.get(node: xml, tag: 'textColor') ?? Xml.get(node: xml, tag: 'fontColor');

    // legacy support
    String? size  = "0";
    var paged = S.toBool(Xml.get(node: xml, tag: 'paged'));
    if (paged != false)
    {
      size = Xml.get(node: xml, tag: 'pagesize');
      if (size == null && paged == true) size = "20";
    }
    pageSize = size ?? "0";

    // events
    onChange = Xml.get(node: xml, tag: 'onchange');

    // filter
    filter = Xml.get(node: xml, tag: 'filter');
    filterBar = Xml.get(node: xml, tag: 'filterbar');
    if (_filterBar != null && _filter == null) filter=true;

    // set header
    header = findChildOfExactType(TableHeaderModel);

    // set no rows widget
    norows = findChildOfExactType(TableNoRowsModel);

    // set footer
    footer = findChildOfExactType(TableFooterModel);

    // build initial rows
    _setInitialRows();
  }

  void _setInitialRows()
  {
    // get all child rows
    List<TableRowModel> rows = findChildrenOfExactType(TableRowModel).cast<TableRowModel>();

    // iterate through all rows
    for (var row in rows)
    {
      var isFirstRow = rows.first == row;

      // first row?
      // set header as simple
      if (isFirstRow)
      {
        // set usesRenderer
        for (var cell in row.cells)
        {
          var cellIdx = row.cells.indexOf(cell);
          var column  = header != null && cellIdx < header!.cells.length ? header!.cells[cellIdx] : null;
          column?.usesRenderer = TableRowCellModel.usesRenderer(cell);
          column?.hasEnterableFields = TableRowCellModel.hasEnterableFields(cell);
        }
      }

      // create the row prototype
      if (isFirstRow && hasDataSource)
      {
        // create the row prototype
        prototype = WidgetModel.prototypeOf(row.element);

        // dispose of the row
        row.dispose();

        // remove it from the child list
        children?.remove(row);
      }

      // add the row to the list
      else
      {
        this.rows[this.rows.length] = row;
      }
    }
  }

  TableRowModel? getRowModel(int index)
  {
    // model exists?
    if (rows.containsKey(index)) return rows[index];

    // prototype exists?
    if (prototype == null) return null;

    // get data
    var data = (index >= 0 && this.data is Data && index < (this.data as Data).length) ? this.data[index] : null;
    if (data == null) return null;

    // build the row model
    TableRowModel? model = TableRowModel.fromXml(this, prototype, data: data);

    // register a listener to dirty field
    if (model?.dirtyObservable != null)
    {
      model?.dirtyObservable!.registerListener(onDirtyListener);
    }

    // add it to the list of rows
    if (model != null)
    {
      rows[index] = model;
    }

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
      hasDynamicHeaders ? view.rebuild() : view.reload();
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

  // export to excel
  bool autosize(String? mode)
  {
    try
    {
      var view = findListenerOfExactType(TableViewState);
      if (view is TableViewState)
      {
        view.autosize(mode);
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

  void _buildDynamicHeaders(Data? data)
  {
    // header has no dynamic fields?
    if (header == null || !header!.isDynamic) return;

    // cleanup
    for (var cell in header!.cells)
    {
      cell.dispose();
    }
    header!.cells.clear();

    // build new header cells
    for (var prototype in header!.prototypes)
    {
      // build xml
      bool isDynamic = Xml.hasAttribute(node: prototype, tag: "dynamic");
      if (isDynamic)
      {
        bool hasData = (data?.isNotEmpty ?? false) && (data?.first is Map);
        if (hasData)
        {
          // replace wildcards
          var keys = (data!.first as Map).keys.where((key) => key != 'xml' && key != 'rownum');
          for (var key in keys)
          {
            var xml = prototype.toString().replaceAll("{field}", key).replaceAll("{*}", key);

            // build the cell
            var model = TableHeaderCellModel.fromXmlString(header!, xml) ?? TableHeaderCellModel(header!, null);
            header!.cells.add(model);
          }
        }
      }

      // static header
      else
      {
        var model = TableHeaderCellModel.fromXml(header!, prototype) ?? TableHeaderCellModel(header!, null);
        header!.cells.add(model);
      }
    }
  }

  void _buildRowPrototype(Data? data)
  {
    if (prototype == null) return;

    // create new row with no cell elements
    var tr = prototype!.copy();
    tr.children.clear();

    // build row prototype cells
    bool hasData = (data?.isNotEmpty ?? false);
    if (hasData)
    {
      // build row model
      TableRowModel? model = TableRowModel.fromXml(this, prototype, data: data!.first);
      if (model == null) return;

      // process each cell
      int cellIdx = 0;
      for (var cell in model.cells)
      {
        var td = cell.element?.toString() ?? XmlElement(XmlName("TD")).toString();

        // dynamic cell
        bool isDynamic = td.contains("{field}") || td.contains("{*}");
        if (isDynamic)
        {
          var map = data.first is Map ? data.first as Map : null;

          // replace wildcards
          var keys = map?.keys.where((key) => key != 'xml' && key != 'rownum') ?? [];
          for (var key in keys)
          {
              var xml  = td.replaceAll("{field}", "{data.$key}").replaceAll("{*}", "{data.$key}");
              var doc  = Xml.tryParse(xml);
              var node = doc?.rootElement.copy() ?? XmlElement(XmlName("TD"));
              tr.children.add(node);

              var column  = header != null && cellIdx < header!.cells.length ? header!.cells[cellIdx] : null;
              column?.usesRenderer = TableRowCellModel.usesRenderer(cell);
              column?.hasEnterableFields = TableRowCellModel.hasEnterableFields(cell);
              cellIdx++;
          }
        }

        // static cell
        else
        {
          var node = cell.element?.copy();
          if (node != null) tr.children.add(node);

          var column  = header != null && cellIdx < header!.cells.length ? header!.cells[cellIdx] : null;
          column?.usesRenderer = TableRowCellModel.usesRenderer(cell);
          column?.hasEnterableFields = TableRowCellModel.hasEnterableFields(cell);
          cellIdx++;
        }
      }

      // cleanup
      model.dispose();
    }

    // apply prototype conversions
    // and set the main row prototype
    prototype = WidgetModel.prototypeOf(tr);
  }

  Future<void> _buildDynamic(Data? data) async
  {
    // build dynamic headers
    _buildDynamicHeaders(data);

    // build row model prototype
    _buildRowPrototype(data);
  }

  Future<bool> onChangeHandler(int rowIdx, int colIdx, dynamic value, dynamic oldValue) async
  {
    var row  = (rowIdx >= 0 && rowIdx < rows.length) ? rows[rowIdx] : null;
    var data = getData(rowIdx);
    var col  = header?.cell(colIdx);
    var fld  = col?.field;

    bool ok = true;
    if (data != null && col != null && fld != null)
    {
      // write new value
      Data.writeValue(data, fld, value);

      // set current data
      row?.data = data;

      // set selected to current data
      selected = data;

      // fire column change handler
      bool ok = await col.onChangeHandler();

      // fire table change handler
      if (ok && _onChange != null)
      {
        ok = await EventHandler(this).execute(_onChange);
      }

      // on fail, restore old value
      if (!ok)
      {
        Data.writeValue(data, fld, oldValue);

        // reset current row data
        row?.data = data;

        // reset selected
        selected = data;
      }
    }
    return ok;
  }

  void onSelect(int rowIdx, int cellIdx)
  {
    // set row selection
    var row = getRowModel(rowIdx);
    if (row != selectedRow) selectedRow?.selected = false;
    row?.selected = true;
    selectedRow = row;

    // set cell selection
    var cell = getRowCellModel(rowIdx, cellIdx);
    if (cell != selectedCell) selectedCell?.selected = false;
    cell?.selected = true;
    selectedCell = cell;

    // set selected
    selected = getData(rowIdx) ?? [];
    _selected?.notifyListeners();
  }

  void onDeSelect()
  {
    // set row selection
    selectedRow?.selected = false;
    selectedRow = null;

    // set cell selection
    selectedCell?.selected = false;
    selectedCell = null;

    // set selected
    selected = [];
  }

  // returns the specified row in data
  dynamic getData(int rowIdx) => (rowIdx >= 0 && data is Data && rowIdx < data.length) ? data[rowIdx] : null;

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

      // export the data
      case "autofit" :
      case "autosize" :
        var mode = S.toStr(S.item(arguments, 0));
        autosize(mode);
        return true;
    }
    
    return super.execute(caller, propertyOrFunction, arguments);
  }

  void onPageSizeChange(Observable observable)
  {
    try
    {
      var view = findListenerOfExactType(TableViewState);
      if (view is TableViewState)
      {
        view.setPageSize(pageSize);
      }
    }
    catch(e)
    {
      print (e);
    }
  }

  void onFilterBarChange(Observable observable)
  {
    try
    {
      var view = findListenerOfExactType(TableViewState);
      if (view is TableViewState)
      {
        view.setFilterBar(filterBar);
      }
    }
    catch(e)
    {
      print (e);
    }
  }

  @override
  Widget getView({Key? key}) => getReactiveView(TableView(this));
}
