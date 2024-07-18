// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/dragdrop/dragdrop.dart';
import 'package:fml/widgets/form/form_interface.dart';
import 'package:fml/widgets/reactive/reactive_view.dart';
import 'package:fml/widgets/table/table_footer_model.dart';
import 'package:fml/widgets/table/nodata_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/widgets/table/table_view.dart';
import 'package:fml/widgets/table/table_header_model.dart';
import 'package:fml/widgets/table/table_header_cell_model.dart';
import 'package:fml/widgets/table/table_row_model.dart';
import 'package:fml/widgets/table/table_row_cell_model.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/helpers/mime.dart';

// platform
import 'package:fml/platform/platform.vm.dart'
    if (dart.library.io) 'package:fml/platform/platform.vm.dart'
    if (dart.library.html) 'package:fml/platform/platform.web.dart';

class TableModel extends BoxModel implements IForm {
  static String dynamicTableValue1 = "{field}";
  static String dynamicTableValue2 = "[*]";

  PlutoGridStateManager? stateManager;

  @override
  bool get canExpandInfinitelyWide => !hasBoundedWidth;

  @override
  bool get canExpandInfinitelyHigh => !hasBoundedHeight;

  // data sourced prototype
  XmlElement? prototype;

  // holds header
  TableHeaderModel? header;

  // holds no data model
  NoDataModel? noData;

  // holds footer
  TableFooterModel? footer;

  // draggable rows?
  bool draggableRows = false;

  // holds list of rows
  final HashMap<int, TableRowModel> rows = HashMap<int, TableRowModel>();

  final double defaultPadding = 4;

  // dynamically generated headers
  bool get hasDynamicHeaders => header?.isDynamic ?? false;

  // table has a data source
  bool get hasDataSource => !isNullOrEmpty(datasource);

  // IDataSource
  IDataSource? myDataSource;

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
  set post(dynamic v) {
    if (_post != null) {
      _post!.set(v);
    } else if (v != null) {
      _post = BooleanObservable(Binding.toKey(id, 'post'), v, scope: scope);
    }
  }

  @override
  bool? get post => _post?.get();

  // text color
  ColorObservable? _textColor;
  set textColor(dynamic v) {
    if (_textColor != null) {
      _textColor!.set(v);
    } else if (v != null) {
      _textColor = ColorObservable(Binding.toKey(id, 'textcolor'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  Color? get textColor => _textColor?.get();

  // text Size
  DoubleObservable? _textSize;
  set textSize(dynamic v) {
    if (_textSize != null) {
      _textSize!.set(v);
    } else if (v != null) {
      _textSize = DoubleObservable(Binding.toKey(id, 'textsize'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double get textSize => _textSize?.get() ?? 14;

  // show busy spinner by default
  BooleanObservable? _showBusy;
  set showBusy(dynamic v) {
    if (_showBusy != null) {
      _showBusy!.set(v);
    } else if (v != null) {
      _showBusy = BooleanObservable(Binding.toKey(id, 'showbusy'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get showBusy => _showBusy?.get() ?? true;

  // show column menu by default
  BooleanObservable? _menu;
  set menu(dynamic v) {
    if (_menu != null) {
      _menu!.set(v);
    } else if (v != null) {
      _menu = BooleanObservable(Binding.toKey(id, 'menu'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get menu => _menu?.get() ?? true;

  // allow sorting
  BooleanObservable? _sortable;
  set sortable(dynamic v) {
    if (_sortable != null) {
      _sortable!.set(v);
    } else if (v != null) {
      _sortable = BooleanObservable(Binding.toKey(id, 'sortable'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get sortable => _sortable?.get() ?? true;

  // allow resizing
  BooleanObservable? _resizeable;
  set resizeable(dynamic v) {
    if (_resizeable != null) {
      _resizeable!.set(v);
    } else if (v != null) {
      _resizeable = BooleanObservable(Binding.toKey(id, 'resizeable'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get resizeable => _resizeable?.get() ?? true;

  // column uses editable
  bool get maybeEditable => _editable != null;

  // editable - used on non row prototype only
  BooleanObservable? _editable;
  set editable(dynamic v) {
    if (_editable != null) {
      _editable!.set(v);
    } else if (v != null) {
      _editable = BooleanObservable(Binding.toKey(id, 'editable'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool? get editable => _editable?.get();

  // allow filtering
  BooleanObservable? _filter;
  set filter(dynamic v) {
    if (_filter != null) {
      _filter!.set(v);
    } else if (v != null) {
      _filter = BooleanObservable(Binding.toKey(id, 'filter'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get filter => _filter?.get() ?? false;

  // display shadow
  BooleanObservable? _shadow;
  set shadow(dynamic v) {
    if (_shadow != null) {
      _shadow!.set(v);
    } else if (v != null) {
      _shadow = BooleanObservable(Binding.toKey(id, 'shadow'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get shadow => _shadow?.get() ?? false;

  // current row selected
  TableRowModel? selectedRow;

  // current column selected
  TableRowCellModel? selectedCell;

  // data map from the row that is currently selected
  ListObservable? _selected;
  set selected(dynamic v) {
    if (_selected != null) {
      _selected!.set(v);
    } else if (v != null) {
      // we don't want this to update the table view so don't add listener: onPropertyChange
      _selected =
          ListObservable(Binding.toKey(id, 'selected'), null, scope: scope);
      _selected!.set(v);
    }
  }
  dynamic get selected => _selected?.get();

  // onChange - only used for simple data grid
  StringObservable? _onChange;
  set onChange(dynamic v) {
    if (_onChange != null) {
      _onChange!.set(v);
    } else if (v != null) {
      _onChange =
          StringObservable(Binding.toKey(id, 'onchange'), v, scope: scope);
    }
  }

  String? get onChange => _onChange?.get();

  // onInsert
  StringObservable? _onInsert;
  set onInsert(dynamic v) {
    if (_onInsert != null) {
      _onInsert!.set(v);
    } else if (v != null) {
      _onInsert = StringObservable(Binding.toKey(id, 'oninsert'), v,
          scope: scope, lazyEval: true);
    }
  }

  String? get onInsert => _onInsert?.get();

  // onDelete
  StringObservable? _onDelete;
  set onDelete(dynamic v) {
    if (_onDelete != null) {
      _onDelete!.set(v);
    } else if (v != null) {
      _onDelete = StringObservable(Binding.toKey(id, 'ondelete'), v,
          scope: scope, lazyEval: true);
    }
  }

  String? get onDelete => _onDelete?.get();

  // dirty
  @override
  BooleanObservable? get dirtyObservable => _dirty;
  BooleanObservable? _dirty;
  @override
  set dirty(dynamic v) {
    if (_dirty != null) {
      _dirty!.set(v);
    } else if (v != null) {
      _dirty = BooleanObservable(Binding.toKey(id, 'dirty'), v, scope: scope);
    }
  }

  @override
  bool get dirty => _dirty?.get() ?? false;

  void onDirtyListener(Observable property) {
    bool isDirty = false;
    for (var entry in rows.entries) {
      if (entry.value.dirty) {
        isDirty = true;
        break;
      }
    }
    dirty = isDirty;
  }

  @override
  bool clear() => true;

  // Clean
  @override
  bool clean() {
    dirty = false;
    rows.forEach((index, row) => row.dirty = false);
    return true;
  }

  // page size - used for paging
  IntegerObservable? _pageSize;
  set pageSize(dynamic v) {
    if (_pageSize != null) {
      _pageSize!.set(v);
    } else if (v != null) {
      _pageSize = IntegerObservable(Binding.toKey(id, 'pagesize'), v,
          scope: scope, listener: onPageSizeChange);
    }
  }

  int get pageSize => _pageSize?.get() ?? 0;

  TableModel(Model super.parent, super.id) {
    // instantiate busy observable
    busy = false;
  }

  static TableModel? fromXml(Model parent, XmlElement xml) {
    TableModel? model;
    try {
      model = TableModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'form.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {
    busy = false;

    // deserialize
    super.deserialize(xml);

    // properties
    menu = Xml.get(node: xml, tag: 'menu');
    sortable = Xml.get(node: xml, tag: 'sortable');
    resizeable = Xml.get(node: xml, tag: 'resizeable');
    editable = Xml.get(node: xml, tag: 'editable');
    shadow = Xml.get(node: xml, tag: 'shadow');
    showBusy = Xml.get(node: xml, tag: 'showbusy');
    post = Xml.get(node: xml, tag: 'post');
    textSize = Xml.get(node: xml, tag: 'textsize') ??
        Xml.get(node: xml, tag: 'fontsize');
    textColor = Xml.get(node: xml, tag: 'textcolor') ??
        Xml.get(node: xml, tag: 'fontcolor');
    filter = Xml.get(node: xml, tag: 'filter');

    // legacy support
    String? size = "0";
    var paged = toBool(Xml.get(node: xml, tag: 'paged'));
    if (paged != false) {
      size = Xml.get(node: xml, tag: 'pagesize');
      if (size == null && paged == true) size = "20";
    }
    pageSize = size ?? "0";

    // events
    onInsert = Xml.get(node: xml, tag: 'oninsert');
    onDelete = Xml.get(node: xml, tag: 'ondelete');
    onChange = Xml.get(node: xml, tag: 'onchange');

    // set header
    header = findChildOfExactType(TableHeaderModel);
    if (header == null) _buildDefaultHeader();

    // set no rows widget
    noData = findChildOfExactType(NoDataModel);

    // set footer
    footer = findChildOfExactType(TableFooterModel);

    // build initial rows
    _setInitialRows();
  }

  void _buildDefaultHeader() {
    var th = XmlElement(XmlName("TH"));
    header = TableHeaderModel.fromXml(this, th);
  }

  void _setInitialRows() {

    // get all child rows
    List<TableRowModel> rows =
        findChildrenOfExactType(TableRowModel).cast<TableRowModel>();

    // iterate through all rows
    for (var row in rows) {

      // first row?
      var isFirstRow = rows.first == row;

      // set header as simple
      if (isFirstRow) {

        // set column usesRenderer
        for (var cell in row.cells) {
          var cellIdx = row.cells.indexOf(cell);
          var column = header != null && cellIdx < header!.cells.length
              ? header!.cells[cellIdx]
              : null;
          column?.usesRenderer = TableRowCellModel.usesRenderer(cell);
          column?.hasEnterableFields =
              TableRowCellModel.hasEnterableFields(cell);
        }
      }

      // draggable rows?
      if (isFirstRow && row.draggable) {
        draggableRows = true;
      }

      // create the row prototype
      if (isFirstRow && hasDataSource) {
        // create the row prototype
        prototype = prototypeOf(row.element);

        // dispose of the row
        row.dispose();

        // remove it from the child list
        children?.remove(row);
      }

      // add the row to the list
      else {
        this.rows[this.rows.length] = row;
      }
    }
  }

  TableRowModel? getRowModel(int index) {
    // model exists?
    if (rows.containsKey(index)) return rows[index];

    // prototype exists?
    if (prototype == null) return null;

    // get data
    var data =
        (index >= 0 && this.data is Data && index < (this.data as Data).length)
            ? this.data[index]
            : null;
    if (data == null) return null;

    // build the row model
    TableRowModel? model = TableRowModel.fromXml(this, prototype, data: data);

    // register a listener to dirty field
    if (model?.dirtyObservable != null) {
      model?.dirtyObservable!.registerListener(onDirtyListener);
    }

    // add it to the list of rows
    if (model != null) {
      rows[index] = model;
    }

    return model;
  }

  TableRowCellModel? getRowCellModel(int rowIdx, int cellIdx) {
    TableRowModel? model = getRowModel(rowIdx);
    if (model == null || cellIdx >= model.cells.length) return null;
    return model.cells[max(cellIdx, 0)];
  }

  Future<bool> _build(IDataSource source, Data? data) async {
    if (isNullOrEmpty(datasource) || datasource == source.id) {
      // save pointer to data source
      myDataSource = source;

      await _buildDynamic(data);

      // mark all fields clean
      clean();

      // clear rows
      rows.forEach((_, row) => row.dispose());
      rows.clear();

      this.data = data;
    }

    // this forces a table refresh
    var view = findListenerOfExactType(TableViewState);
    if (view is TableViewState) {
      hasDynamicHeaders ? view.rebuild() : view.reload();
    }

    return true;
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async {
    await _build(source, list);
    onDeSelect();
    busy = false;
    return true;
  }

  // export to excel
  Future<bool> export(String? format, String? filename) async {
    try {
      var view = findListenerOfExactType(TableViewState);
      if (view is TableViewState) {
        if (isNullOrEmpty(filename)) filename = newId();
        var name = Mime.toSafeFileName(filename!.split(".")[0]);
        switch (format?.toLowerCase().trim()) {
          case "raw":
            var file = await Data.toCsv(Data.from(data));
            var bytes = utf8.encode(file);
            Platform.fileSaveAs(bytes, "$name.csv");
            break;

          case "xls":
          case "csv":
            var file = await view.exportToCSV();
            var bytes = utf8.encode(file ?? "");
            Platform.fileSaveAs(bytes, "$name.csv");
            break;

          case "pdf":
          default:
            var bytes = await view.exportToPDF();
            if (bytes != null) Platform.fileSaveAs(bytes, "$name.pdf");
            break;
        }
      }
    } catch (e) {
      Log().exception(e);
    }
    return true;
  }

  // autosize
  bool autosize(String? mode) {
    try {
      var view = findListenerOfExactType(TableViewState);
      if (view is TableViewState) {
        view.autosize(mode);
      }
    } catch (e) {
      Log().exception(e);
    }
    return true;
  }

  @override
  dispose() {
    // cleanup
    header?.dispose();

    // clear rows
    rows.forEach((_, row) => row.dispose());
    rows.clear();
    stateManager?.dispose();
    super.dispose();
  }

  @override
  Future<bool> complete() async {

    busy = true;

    bool ok = true;

    // post the dirty rows
    var list = rows.values.where((row) => row.dirty == true).toList();
    for (var model in list) {
      ok = await model.complete();
    }

    busy = false;
    return ok;
  }

  @override
  Future<bool> validate() async => true;

  @override
  Future<bool> save() async => true;

  void _buildDynamicHeaders(Data? data) {
    // header has no dynamic fields?
    if (header == null || !header!.isDynamic) return;

    // cleanup
    for (var cell in header!.cells) {
      // remove cell from parent child list
      cell.parent?.children?.remove(cell);

      // dispose of the cell
      cell.dispose();
    }

    // clear header cells
    header!.cells.clear();

    // build new header cells
    header!.prototypes.forEach((prototype, parentModel) {
      // create a new header cells
      Model parent = parentModel ?? header!;
      parent.children ??= [];

      // build dynamic cell(s)
      if (Xml.hasAttribute(node: prototype, tag: "dynamic")) {
        var hasData = (data?.isNotEmpty ?? false) && (data?.first is Map);
        if (hasData) {
          // replace wildcards
          var keys = (data!.first as Map)
              .keys
              .where((key) => key != 'xml' && key != 'rownum');
          for (var key in keys) {
            // replace [*] and {field} with key
            var xml = prototype
                .toString()
                .replaceAll(dynamicTableValue1, key)
                .replaceAll(dynamicTableValue2, key);

            // parse the element
            XmlDocument? document = Xml.tryParse(xml);
            if (document != null) {
              // get id of proposed model
              var id = Xml.attribute(node: document.rootElement, tag: "id");

              // get id of proposed model
              var visible = toBool(Xml.attribute(
                      node: document.rootElement, tag: "visible")) ??
                  true;

              // dynamic cells with the same id as static fields do not get rendered
              var exists = header!.staticFields?.contains(id) ?? false;

              if (!exists && visible) {
                var cell = TableHeaderCellModel.fromXml(
                        parent, document.rootElement) ??
                    TableHeaderCellModel(parent, null);
                parent.children!.add(cell);
                header!.cells.add(cell);
              }
            }

            // dummy model form invalid xml
            else {
              var cell = TableHeaderCellModel(parent, null);
              parent.children!.add(cell);
              header!.cells.add(cell);
            }
          }
        }
      }

      // build static cell
      else {
        // get id of proposed model
        var visible =
            toBool(Xml.attribute(node: prototype, tag: "visible")) ?? true;

        if (visible) {
          var cell = TableHeaderCellModel.fromXml(parent, prototype) ??
              TableHeaderCellModel(parent, null);
          parent.children!.add(cell);
          header!.cells.add(cell);
        }
      }
    });
  }

  void _buildRowPrototype(Data? data) {

    if (prototype == null) return;

    // build row prototype cells
    if (data?.isNotEmpty ?? false) {
      // build row model
      TableRowModel? model =
          TableRowModel.fromXml(this, prototype, data: data!.first);
      if (model == null) return;

      // create new row prototype
      var tr = prototype!.copy();

      // clear cell children
      var cells = {'CELL', 'TD', 'TABLEDATA'};
      tr.children.removeWhere((child) => child is XmlElement && cells.contains(child.localName));

      // process each cell
      int cellIdx = 0;
      for (var cell in model.cells) {
        var td =
            cell.element?.toString() ?? XmlElement(XmlName("TD")).toString();

        // dynamic cell
        bool isDynamic =
            td.contains(dynamicTableValue1) || td.contains(dynamicTableValue2);
        if (isDynamic) {
          var map = data.first is Map ? data.first as Map : null;

          // replace wildcards
          var keys =
              map?.keys.where((key) => key != 'xml' && key != 'rownum') ?? [];
          for (var key in keys) {
            var xml = td
                .replaceAll(dynamicTableValue1, "{data.$key}")
                .replaceAll(dynamicTableValue2, "{data.$key}");
            var doc = Xml.tryParse(xml);
            var node = doc?.rootElement.copy() ?? XmlElement(XmlName("TD"));
            tr.children.add(node);

            var column = header != null && cellIdx < header!.cells.length
                ? header!.cells[cellIdx]
                : null;
            column?.usesRenderer = TableRowCellModel.usesRenderer(cell);
            column?.hasEnterableFields =
                TableRowCellModel.hasEnterableFields(cell);
            cellIdx++;
          }
        }

        // static cell
        else {
          var node = cell.element?.copy();
          if (node != null) tr.children.add(node);

          var column = header != null && cellIdx < header!.cells.length
              ? header!.cells[cellIdx]
              : null;
          column?.usesRenderer = TableRowCellModel.usesRenderer(cell);
          column?.hasEnterableFields =
              TableRowCellModel.hasEnterableFields(cell);
          cellIdx++;
        }
      }

      // cleanup
      model.dispose();

      // apply prototype conversions
      // and set the main row prototype
      prototype = prototypeOf(tr);
    }
  }

  Future<void> _buildDynamic(Data? data) async {
    // build dynamic headers
    _buildDynamicHeaders(data);

    // build row model prototype
    _buildRowPrototype(data);
  }

  Future<bool> onChangeHandler(
      int rowIdx,
      int colIdx,
      dynamic value,
      dynamic oldValue) async {

    var row = (rowIdx >= 0 && rowIdx < rows.length) ? rows[rowIdx] : null;
    var rowCell = row?.cell(colIdx);
    var colCell = header?.cell(colIdx);
    var data = getData(rowIdx);
    var fld = colCell?.field;

    bool ok = true;
    if (data != null && colCell != null && fld != null) {

      // mark dirty
      row?.dirty = true;
      rowCell?.dirty = true;
      //rowCell?.touched = true;

      // write new value
      // the data needs to be written ahead of alarm validation
      // in order for binding to work correctly
      Data.write(data, fld, value);

      // set current data
      row?.data = data;

      // set selected to current data
      selected = data;

      // validation alarm?
      ok = !(rowCell?.alarming ?? false);
      if (!ok) rowCell?.onAlarm();

      // fire the row's cell change handler
      if (ok) ok = await rowCell?.onChangeHandler() ?? true;

      // fire the row's change handler
      if (ok) ok = await row?.onChangeHandler() ?? true;

      // fire the column's cell change handler
      if (ok) ok = await colCell.onChangeHandler();

      // fire the column's change handler
      if (ok) ok = await header?.onChangeHandler() ?? true;

      // fire the table's change handler
      if (ok) {
        ok = _onChange != null
            ? await EventHandler(this).execute(_onChange)
            : true;
      }

      // on fail, restore old value
      if (!ok) {

        // write back old value
        Data.write(data, fld, oldValue);

        // reset current row data
        row?.data = data;

        // reset selected
        selected = data;
      }
    }
    return ok;
  }

  void onSelect(int rowIdx, int cellIdx) {
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

  void onDeSelect() {
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
  dynamic getData(int rowIdx) =>
      (rowIdx >= 0 && data is Data && rowIdx < data.length)
          ? data[rowIdx]
          : null;

  // returns the length of the dataset
  int getDataRowCount() => data is Data ? (data as Data).length : 0;

  @override
  Future<bool?> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    /// setter
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    switch (function) {
      // export the data
      case "export":
        var format = toStr(elementAt(arguments, 0));
        var filename = toStr(elementAt(arguments, 1));
        await export(format, filename);
        return true;

      // move a row
      case "move":
        moveRow(toInt(elementAt(arguments, 0)) ?? 0,
            toInt(elementAt(arguments, 1)) ?? 0);
        return true;

      // delete a row
      case "delete":
        deleteRow(toInt(elementAt(arguments, 0)));
        return true;

      // add a row
      case "insert":
        insertRow(
            toStr(elementAt(arguments, 0)), toInt(elementAt(arguments, 1)));
        return true;

      // autosize the fields
      case "autosize":
        var mode = toStr(elementAt(arguments, 0));
        autosize(mode);
        return true;

      case 'post':
      case 'submit':
      case 'complete':
        return await complete();

      case 'save':
        return await save();

      case 'validate':
        return await validate();
    }

    return super.execute(caller, propertyOrFunction, arguments);
  }

  void onPageSizeChange(Observable observable) {
    try {
      var view = findListenerOfExactType(TableViewState);
      if (view is TableViewState) {
        view.setPageSize(pageSize);
      }
    } catch (e) {
      Log().exception(e);
    }
  }

  void onFilterBarChange(Observable observable) {
    try {
      var view = findListenerOfExactType(TableViewState);
      if (view is TableViewState) {
        view.setFilterBar(filter);
      }
    } catch (e) {
      Log().exception(e);
    }
  }

  // insert a row
  Future<bool> insertRow(String? jsonOrXml, int? rowIndex) async {
    try {
      var view = findListenerOfExactType(TableViewState);
      if (view is TableViewState) {
        // get current row index if not specified
        rowIndex ??= view.currentRowIndex ?? 0;

        // add empty element to the data set
        // important to do this first as
        // get row model below depends on an entry
        // in the dataset at specified index
        notificationsEnabled = false;
        myDataSource?.insert(jsonOrXml, rowIndex, notifyListeners: false);
        data = myDataSource?.data ?? data;
        notificationsEnabled = true;

        // open up a space for the new model
        insertInHashmap(rows, rowIndex);

        // create new row
        var row = getRowModel(rowIndex);

        // add row to rows
        if (row != null) {
          rows[rowIndex] = row;

          // fire the rows onInsert event
          await row.onInsertHandler();
        }

        //data = myDataSource?.notify();

        // add row to table view
        rowIndex = view.insertRow(rowIndex);
      }
    } catch (e) {
      Log().exception(e);
    }
    return true;
  }

  // delete a row
  Future<bool> deleteRow(int? rowIndex) async {
    try {
      var view = findListenerOfExactType(TableViewState);
      if (view is TableViewState) {
        // delete row from table view
        rowIndex = view.deleteRow(rowIndex);

        // row was deleted?
        if (rowIndex != null) {
          // lookup the row
          var row = rows.containsKey(rowIndex) ? rows[rowIndex] : null;
          if (row != null) {
            // fire the rows onDelete event
            bool ok = await row.onDeleteHandler();

            // continue?
            if (ok) {
              // reorder hashmap
              deleteInHashmap(rows, rowIndex);

              // remove the data associated with the row
              notificationsEnabled = false;
              myDataSource?.delete(rowIndex, notifyListeners: false);
              data = myDataSource?.data ?? data;
              notificationsEnabled = true;
            }
          }
        }
      }
    } catch (e) {
      Log().exception(e);
    }
    return true;
  }

  // delete a row
  Future<bool> moveRow(int fromIndex, int toIndex) async {
    try {
      // reorder hashmap
      moveInHashmap(rows, fromIndex, toIndex);

      // reorder data
      notificationsEnabled = false;
      myDataSource?.move(fromIndex, toIndex, notifyListeners: false);
      data = myDataSource?.data ?? data;
      notificationsEnabled = true;
    } catch (e) {
      Log().exception(e);
    }
    return true;
  }

  Future<bool> onDragDrop(int dragIndex, int dropIndex) async {
    var draggable = getRowModel(dragIndex);
    var droppable = getRowModel(dropIndex);
    if (draggable != null && droppable != null) {
      // fire onDrop event
      await DragDrop.onDrop(droppable, draggable);

      // move the row
      moveRow(dragIndex, dropIndex);
    }
    return true;
  }

  @override
  Widget getView({Key? key}) {
    var view = TableView(this);
    return isReactive ? ReactiveView(this, view) : view;
  }
}
