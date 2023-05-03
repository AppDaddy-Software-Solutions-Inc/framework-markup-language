// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'dart:convert';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/form/form_model.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/datasources/transforms/sort.dart' as sort_transform;
import 'package:fml/event/handler.dart' ;
import 'package:fml/widgets/table/table_view.dart';
import 'package:fml/widgets/table/header/table_header_model.dart';
import 'package:fml/widgets/table/header/cell/table_header_cell_model.dart';
import 'package:fml/widgets/table/footer/table_footer_model.dart';
import 'package:fml/widgets/table/row/table_row_model.dart';
import 'package:fml/widgets/table/row/cell/table_row_cell_model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';


enum PaddingType { none, first, last, evenly, proportionately }

class TableModel extends DecoratedWidgetModel implements IForm, IScrolling
{

  @override
  bool get isVerticallyExpanding => !isFixedHeight;

  @override
  bool get isHorizontallyExpanding => !isFixedWidth;

  // prototype
  String? prototype;
  TableRowModel? prototypeModel;

  TableHeaderModel? tableheader;
  TableFooterModel? tablefooter;
  final HashMap<int, TableRowModel> rows = HashMap<int, TableRowModel>();

  Size? proxyrow;
  Size? proxyheader;
  Map<String, double?> heights = {'header': 48, 'row': 38, 'footer': 48};
  Map<int, double> widths = HashMap<int, double>();
  Map<int, double> cellpadding = HashMap<int, double>();

  TableRowModel? selectedRow;
  TableRowCellModel? selectedCell;

  PaddingType _paddingType = PaddingType.proportionately;
  PaddingType get paddingType {
    return _paddingType;
  }

  set paddingType(dynamic t) {
    PaddingType? type;
    if (t is String) type = S.toEnum(t, PaddingType.values);
    if (t is PaddingType) type = t;
    if (type != null) _paddingType = type;
  }

  ////////////////////
  /* slt color */
  ////////////////////
  ColorObservable? _altcolor;
  set altcolor(dynamic v) {
    if (_altcolor != null) {
      _altcolor!.set(v);
    } else if (v != null) {
      _altcolor = ColorObservable(Binding.toKey(id, 'altcolor'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  Color? get altcolor => _altcolor?.get();


  ////////////////////
  /* selected color */
  ////////////////////
  ColorObservable? _selectedcolor;
  set selectedcolor(dynamic v) {
    if (_selectedcolor != null) {
      _selectedcolor!.set(v);
    } else if (v != null) {
      _selectedcolor = ColorObservable(Binding.toKey(id, 'selectedcolor'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  Color? get selectedcolor => _selectedcolor?.get();

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
  Color? get selectedbordercolor => _selectedbordercolor?.get();

  //////////////////
  /* border color */
  //////////////////
  ColorObservable? _bordercolor;
  set bordercolor(dynamic v) {
    if (_bordercolor != null) {
      _bordercolor!.set(v);
    } else if (v != null) {
      _bordercolor = ColorObservable(Binding.toKey(id, 'bordercolor'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  Color? get bordercolor => _bordercolor?.get();

  //////////////////
  /* border width */
  //////////////////
  DoubleObservable? _borderwidth;
  set borderwidth(dynamic v) {
    if (_borderwidth != null) {
      _borderwidth!.set(v);
    } else if (v != null) {
      _borderwidth = DoubleObservable(Binding.toKey(id, 'borderwidth'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double? get borderwidth => _borderwidth?.get();

  // override
  @override
  String get valign => super.valign ?? 'center';

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
  bool get center => _center?.get() ?? false;

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
  bool get wrap => _wrap?.get() ?? false;

  BooleanObservable? _scrollButtons;
  set scrollButtons(dynamic v) {
    if (_scrollButtons != null) {
      _scrollButtons!.set(v);
    } else if (v != null) {
      _scrollButtons = BooleanObservable(Binding.toKey(id, 'scrollbuttons'), v,
          scope: scope);
    }
  }
  bool get scrollButtons => _scrollButtons?.get() ?? false;

  BooleanObservable? _scrollShadows;
  set scrollShadows(dynamic v) {
    if (_scrollShadows != null) {
      _scrollShadows!.set(v);
    } else if (v != null) {
      _scrollShadows = BooleanObservable(Binding.toKey(id, 'scrollshadows'), v,
          scope: scope);
    }
  }
  bool get scrollShadows => _scrollShadows?.get() ?? false;

  ///////////
  /* moreup */
  ///////////
  BooleanObservable? _moreUp;
  @override
  set moreUp(dynamic v)
  {
    if (_moreUp != null)
    {
      _moreUp!.set(v);
    }
    else if (v != null)
    {
      _moreUp = BooleanObservable(Binding.toKey(id, 'moreup'), v, scope: scope);
    }
  }
  @override
  bool? get moreUp=> _moreUp?.get();

  ///////////
  /* moreDown */
  ///////////
  BooleanObservable? _moreDown;
  @override
  set moreDown(dynamic v)
  {
    if (_moreDown != null)
    {
      _moreDown!.set(v);
    }
    else if (v != null)
    {
      _moreDown = BooleanObservable(Binding.toKey(id, 'moredown'), v, scope: scope);
    }
  }
  @override
  bool? get moreDown => _moreDown?.get();

  ///////////
  /* moreLeft */
  ///////////
  BooleanObservable? _moreLeft;
  @override
  set moreLeft(dynamic v)
  {
    if (_moreLeft != null) {
      _moreLeft!.set(v);
    } else if (v != null) {
      _moreLeft = BooleanObservable(Binding.toKey(id, 'moreleft'), v, scope: scope);
    }
  }
  @override
  bool? get moreLeft => _moreLeft?.get();

  ///////////////
  /* moreRight */
  ///////////////
  BooleanObservable? _moreRight;
  @override
  set moreRight(dynamic v)
  {
    if (_moreRight != null)
    {
      _moreRight!.set(v);
    }
    else if (v != null)
    {
      _moreRight = BooleanObservable(Binding.toKey(id, 'moreright'), v, scope: scope);
    }
  }
  @override
  bool? get moreRight => _moreRight?.get();

  //////////////////
  /* Multi-Select */
  //////////////////
  bool _multiselect = false;
  set multiselect(dynamic v) {
    bool? b = S.toBool(v);
    if (b != null) _multiselect = b;
  }

  get multiselect => _multiselect;

  /////////////////
  /* onccomplete */
  /////////////////
  StringObservable? _oncomplete;
  set oncomplete(dynamic v) {
    if (_oncomplete != null) {
      _oncomplete!.set(v);
    } else if (v != null) {
      _oncomplete = StringObservable(Binding.toKey(id, 'oncomplete'), v,
          scope: scope, lazyEval: true);
    }
  }
  String? get oncomplete => _oncomplete?.get();

  ///////////
  /* dirty */
  ///////////
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
      if ((entry.value.dirty == true)) {
        isDirty = true;
        break;
      }
    }
    dirty = isDirty;
  }

  ///////////
  /* Clean */
  ///////////
  @override
  set clean(bool b) {
    dirty = false;
    rows.forEach((index, row) => row.dirty = false);
  }

  ///////////
  /* paged */
  ///////////
  BooleanObservable? _paged;
  set paged(dynamic v) {
    if (_paged != null) {
      _paged!.set(v);
    } else if (v != null) {
      _paged = BooleanObservable(null, v, scope: scope);
    }
  }
  bool get paged => _paged?.get() ?? true;

  //////////////
  /* pagesize */
  //////////////
  IntegerObservable? _pagesize;
  set pagesize(dynamic v) {
    if (_pagesize != null) {
      _pagesize!.set(v);
    } else if (v != null) {
      _pagesize = IntegerObservable(Binding.toKey(id, 'pagesize'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  int? get pagesize
  {
    if (_pagesize == null)
    {
      if ((data != null) && (data.isNotEmpty)) return data.length;
      return null;
    }
    return _pagesize?.get();
  }

  //////////
  /* page */
  //////////
  IntegerObservable? _page;
  set page(dynamic v) {
    if (_page != null) {
      _page!.set(v);
    } else if (v != null) {
      _page = IntegerObservable(Binding.toKey(id, 'page'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  int? get page
  {
    if (_page == null)
    {
      if ((data != null) && (data.isNotEmpty)) return 1;
      return null;
    }
    return _page?.get();
  }

  ////////////
  /* margin */
  ////////////
  DoubleObservable? _margin;
  set margin(dynamic v) {
    if (_margin != null) {
      _margin!.set(v);
    } else if (v != null) {
      _margin = DoubleObservable(null, v, scope: scope);
    }
  }
  double get margin => _margin?.get() ?? 24;

  ////////////
  /* spacing */
  ////////////
  DoubleObservable? _spacing;
  set spacing(dynamic v) {
    if (_spacing != null) {
      _spacing!.set(v);
    } else if (v != null) {
      _spacing = DoubleObservable(null, v, scope: scope);
    }
  }
  double get spacing => _spacing?.get() ?? 56;

  /////////////////
  /* sortButtons */
  /////////////////
  BooleanObservable? _sortButtons;
  set sortButtons(dynamic v) {
    if (_sortButtons != null) {
      _sortButtons!.set(v);
    } else if (v != null) {
      _sortButtons = BooleanObservable(null, v, scope: scope);
    }
  }
  bool get sortButtons => _sortButtons?.get() ?? true;

  StringObservable? _onpulldown;
  set onpulldown (dynamic v)
  {
    if (_onpulldown != null)
    {
      _onpulldown!.set(v);
    }
    else if (v != null)
    {
      _onpulldown = StringObservable(Binding.toKey(id, 'onpulldown'), v, scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }
  dynamic get onpulldown => _onpulldown?.get();

  BooleanObservable? _draggable;
  set draggable(dynamic v) {
    if (_draggable != null) {
      _draggable!.set(v);
    } else if (v != null) {
      _draggable = BooleanObservable(Binding.toKey(id, 'draggable'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get draggable => _draggable?.get() ?? false;

  /// Contains the data map from the row that is selected
  ListObservable? _selected;
  set selected(dynamic v) {
    if (_selected != null) {
      _selected!.set(v);
    } else if (v != null) {
      _selected = ListObservable(Binding.toKey(id, 'selected'), null,
          scope: scope, listener: onPropertyChange);
      _selected!.set(v);
    }
  }
  dynamic get selected => _selected?.get();

  TableModel(WidgetModel parent, String? id,
      {dynamic selected,
      dynamic draggable,
      dynamic width,
      dynamic height,
      dynamic oncomplete,
      dynamic center,
      dynamic wrap,
      dynamic onpulldown,
      dynamic margin,
      dynamic altcolor,
      dynamic spacing,
      dynamic sortButtons,
      dynamic scrollButtons,
      dynamic scrollShadows})
      : super(parent, id) {
    // instantiate busy observable
    busy = false;

    if (width  != null) this.width  = width;
    if (height != null) this.height = height;

    this.selected = selected;
    this.draggable = draggable;
    this.onpulldown = onpulldown;
    this.oncomplete = oncomplete;
    dirty = false;
    this.margin = margin;
    this.spacing = spacing;
    this.altcolor = altcolor;
    this.center = center;
    this.wrap = wrap;
    this.sortButtons = sortButtons;
    this.scrollButtons = scrollButtons;
    this.scrollShadows = scrollShadows;
    moreUp = false;
    moreDown = false;
    moreLeft = false;
    moreRight = false;
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
  void deserialize(XmlElement xml) {
    busy = false;

    // deserialize
    super.deserialize(xml);

    // properties
    selected = Xml.get(node: xml, tag: 'selected');
    draggable = Xml.get(node:xml, tag: 'draggable');
    onpulldown = Xml.get(node: xml, tag: 'onpulldown');
    pagesize = Xml.get(node: xml, tag: 'pagesize');
    paged = Xml.get(node: xml, tag: 'paged');

    if (width != null)  width  = Xml.get(node: xml, tag: 'width');
    if (height != null) height = Xml.get(node: xml, tag: 'height');

    center = Xml.get(node: xml, tag: 'center');
    altcolor = Xml.get(node: xml, tag: 'altcolor');
    wrap = Xml.get(node: xml, tag: 'wrap');
    selectedcolor = Xml.get(node: xml, tag: 'selectedcolor');
    bordercolor = Xml.get(node: xml, tag: 'bordercolor');
    selectedbordercolor = Xml.get(node: xml, tag: 'selectedbordercolor');
    borderwidth = Xml.get(node: xml, tag: 'borderwidth');
    oncomplete = Xml.get(node: xml, tag: 'oncomplete');
    margin = Xml.get(node: xml, tag: 'margin');
    spacing = Xml.get(node: xml, tag: 'spacing');
    paddingType = Xml.get(node: xml, tag: 'pad');
    sortButtons = Xml.get(node: xml, tag: 'sortButtons');
    scrollButtons = Xml.get(node: xml, tag: 'scrollbuttons');
    scrollShadows = Xml.get(node: xml, tag: 'scrollshadows');

    //////////////////////
    /* Get Table Header */
    //////////////////////
    List<TableHeaderModel> headers = findChildrenOfExactType(TableHeaderModel).cast<TableHeaderModel>();
    if (headers.isNotEmpty) tableheader = headers.first;

    //////////////////////
    /* Get Table Footer */
    //////////////////////
    List<TableFooterModel> footers = findChildrenOfExactType(TableFooterModel).cast<TableFooterModel>();
    if (footers.isNotEmpty) tablefooter = footers.first;

    // get prototype
    List<TableRowModel> rows = findChildrenOfExactType(TableRowModel).cast<TableRowModel>();
    if ((rows.isNotEmpty)) {
      prototypeModel = rows.first;
      prototype = S.toPrototype(prototypeModel!.element.toString());
    }
  }

  TableRowModel? getEmptyRowModel() {
    // build prototype
    XmlElement? prototype = S.fromPrototype(this.prototype, "$id-${0}");

    // build model
    TableRowModel? model =
        TableRowModel.fromXml(this, prototype, data: null);
    if(model?.cells != null){for (var cell in model!.cells) {
      cell.visible = false;
    }}
    return model;
  }

  TableRowModel? getRowModel(int index) {
    // model exists?
    if (data == null) return null;
    if (data.length < (index + 1)) return null;
    if (rows.containsKey(index)) return rows[index];
    if ((index.isNegative) || (data.length < index)) return null;

    // build prototype
    XmlElement? prototype =
        S.fromPrototype(this.prototype, "$id-$index");

    // build row model
    TableRowModel? model =
        TableRowModel.fromXml(this, prototype, data: data[index]);

    // defined height
    if (prototypeModel!.height != null) heights['row'] = prototypeModel!.height;

    // Register Listener to Dirty Field
    if (model?.dirtyObservable != null) model?.dirtyObservable!.registerListener(onDirtyListener);

    if (model != null) rows[index] = model;

    return model;
  }

  TableHeaderCellModel? getHeaderCell(int col) {
    if ((tableheader != null) && (col < tableheader!.cells.length)) {
      return tableheader!.cells[col];
    }
    return null;
  }

  Future<bool> _build(IDataSource source, Data? map) async {
    if ((S.isNullOrEmpty(datasource)) || (datasource == source.id)) {
      if (tableheader!.prototype != null) await _buildDynamic(map);

      clean = true;

      // clear rows
      rows.forEach((_,row) => row.dispose());
      rows.clear();

      page = 1;
      data = map;
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

  Future<void> sort(final int index, context) async {
    busy = true;

    int i = 0;
    TableHeaderCellModel? model;
    while ((model = getHeaderCell(i)) != null) {
      if (i == index) {
        model = getHeaderCell(index);
        if (model != null) {
          model.sorted = true;
          model.sortAscending = !model.sortAscending;
          model.isSorting = true;
        }


        sort_transform.Sort sort = sort_transform.Sort(null,
            field: model?.sort,
            type: model?.sortType,
            ascending: model?.sortAscending,
            casesensitive: false);

        await sort.apply(data);
      } else {
        model?.sorted = false;
      }
      i = i + 1;
    }

    // clear rows
    rows.forEach((_,row) => row.dispose());
    rows.clear();

    // Notify Listeners of Change
    notifyListeners('list', null);

    busy = false;
  }

  void updatedSortedBy(ascending, index) {
    var currCol;
    int i = 0;
    while ((currCol = getHeaderCell(i++)) != null) {
      if (i == index) {
        currCol.sortAscending = ascending;
        currCol.sortedColumn = true;
      } else {
        currCol.sortedColumn = false;
      }
    }
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
    tableheader?.dispose();
    prototypeModel?.dispose();

    // clear rows
    rows.forEach((_,row) => row.dispose());
    rows.clear();

    super.dispose();
  }

  @override
  Future<bool> complete() async {
    busy = true;

    bool ok = true;

    ///////////////////
    /* Post the Form */
    ///////////////////
    if (dirty){
      for (var entry in rows.entries) {
        ok = await entry.value.complete();
      }
  }
    busy = false;
    return ok;
  }

  @override
  Future<bool> onComplete(BuildContext context) async {
    return await EventHandler(this).execute(_oncomplete);
  }

  void setCellWidth(int cellindex, double width) {
    if ((width >= 0) && (cellindex < widths.length)) widths[cellindex] = width;
  }

  void setCellPadding(int cellindex, double padding) {
    if ((padding >= 0) && (cellindex < cellpadding.length)) {
      cellpadding[cellindex] = padding;
    }
  }

  double getCellPosition(int cellindex) {
    double offset = 0;
    for (int i = 0; i < cellindex; i++) {
      offset += (widths[i] ?? 0) + (cellpadding[i] ?? 0);
    }
    return offset;
  }

  double? getCellWidth(int cellindex) {
    double? width = 0;
    if (widths.containsKey(cellindex)) width = widths[cellindex];
    return width;
  }

  double getContentWidth() {
    double width = 0;
    widths.forEach((key, cellwidth) => width += cellwidth);
    return width;
  }

  double? getCellPadding(int cellindex) {
    double? pad = 0;
    if (cellpadding.containsKey(cellindex)) pad = cellpadding[cellindex];
    return pad;
  }

  Future<bool> onSort(int index) async {
    busy = true;
    await sort(index, null);
    busy = false;
    return true;
  }

  void onSelect(TableRowModel row, TableRowCellModel cell) {
    if (selectedRow == row && selectedCell == cell) {
      // Deselect
      selectedRow?.selected = false;
      selectedCell?.selected = false;
      selectedRow = null;
      selectedCell = null;
      selected = [];
    } else {
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

  Future<bool> _buildDynamic(Data? data) async {
    /////////////////////////
    /* Remove Header Cells */
    /////////////////////////
    tableheader!.cells.clear();

    //////////////////////
    /* Remove Row Cells */
    //////////////////////
    prototypeModel!.cells.clear();

    Iterable<XmlElement>? nodes = Xml.getChildElements(node: prototypeModel!.element!, tag: 'cell');

    prototypeModel!.element!.children.removeWhere((node) => nodes!.contains(node));

    if ((data != null) && (data.isNotEmpty)) {
      data[0].forEach((key, value)
      {
        if ((key != 'xml') && (key != 'rownum')) {
          String xml;

          /////////////////
          /* Header Cell */
          /////////////////
          xml = tableheader!
              .prototype!
              .toXmlString()
              .replaceAll("{field}", key);
          TableHeaderCellModel? c1 =
              TableHeaderCellModel.fromXmlString(this, xml);
          if ((c1 != null) && (c1.visible == false)) c1 = null;

          ///////////////
          /* Row Cells */
          ///////////////
          xml = prototypeModel!.cellprototype
              .toXmlString()
              .replaceAll("{field}", "{$key}");
          XmlDocument? c2 = Xml.tryParse(xml);

          //////////////////////////////
          /* Add Header and Row Cells */
          //////////////////////////////
          if ((c1 != null) && (c2 != null)) {
            tableheader!.cells.add(c1);
            prototypeModel!.element!.children.add(c2.rootElement.copy());
          }
        }
      });
    }

    //////////////////////////
    /* Force View to Resize */
    //////////////////////////
    proxyheader = null;
    proxyrow = null;

    return true;
  }

  void calculatePadding(double pad) {
    ///////////////////
    /* Clear Padding */
    ///////////////////
    cellpadding.clear();

    ////////////////
    /* Do Nothing */
    ////////////////
    if (pad == 0) return;

    ////////////
    /* Shrink */
    ////////////
    if (pad.isNegative) return shrinkBy(pad);

    if (paddingType == PaddingType.none) return;

    switch (paddingType) {
      case PaddingType.none:
        break;

      //////////////////////
      /* Pad First Column */
      //////////////////////
      case PaddingType.first:
        {
          cellpadding[0] = pad;
          break;
        }

      /////////////////////
      /* Pad Last Column */
      /////////////////////
      case PaddingType.last:
        {
          cellpadding[widths.length - 1] = pad;
          break;
        }

      ////////////////////////////
      /* Pad Each Column Evenly */
      ////////////////////////////
      case PaddingType.evenly:
        {
          double p = pad / widths.length;
          widths.forEach((key, value) => cellpadding[key] = p);
          break;
        }

      ////////////////////////////////////////
      /* Pad Each Proportionate to its Size */
      ////////////////////////////////////////
      case PaddingType.proportionately:
        {
          double totalWidth = 0;
          widths.forEach((key, width) => totalWidth += width);
          widths.forEach((key, width) {
            double percentageWidth = (width) / totalWidth;
            double p = pad * percentageWidth;
            cellpadding[key] = p;
          });
        }
    }
  }

  void shrinkBy(double pixels) {
    double currentWidth = getContentWidth();
    double targetWidth = currentWidth - pixels.abs();
    double percentReduction = targetWidth / currentWidth;
    for (int i = 0; i < widths.length; i++) {
      widths[i] = (widths[i]! * percentReduction).roundToDouble();
    }
  }

  @override
  Future<bool> save() async {
    // not implemented
    return true;
  }

  Future<void> onPull(BuildContext context) async
  {
    await EventHandler(this).execute(_onpulldown);
  }


  @override
  Widget getView({Key? key}) => getReactiveView(TableView(this));
}
