// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/iDataSource.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart'     ;
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/widgets/grid/grid_view.dart' as grid_view;
import 'package:fml/widgets/grid/item/grid_item_model.dart';
import 'package:fml/datasources/transforms/sort.dart' as sort_transform;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class GridModel extends DecoratedWidgetModel implements IScrolling
{
  // prototype
  String? prototype;

  @override
  bool get isVerticallyExpanding => !isFixedHeight;

  @override
  bool get isHorizontallyExpanding => !isFixedWidth;

  // items
  HashMap<int,GridItemModel> items = HashMap<int,GridItemModel>();

  BooleanObservable? _scrollShadows;
  set scrollShadows (dynamic v)
  {
    if (_scrollShadows != null)
    {
      _scrollShadows!.set(v);
    }
    else if (v != null)
    {
      _scrollShadows = BooleanObservable(Binding.toKey(id, 'scrollshadows'), v, scope: scope);
    }
  }
  bool get scrollShadows => _scrollShadows?.get() ?? false;

  ///////////
  /* dirty */
  ///////////
  BooleanObservable? get dirtyObservable => _dirty;
  BooleanObservable? _dirty;
  set dirty (dynamic v)
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
  bool? get dirty => _dirty?.get();

  void onDirtyListener(Observable property)
  {
    bool isDirty = false;
      for (var entry in items.entries)
      {
        if ((entry.value.dirty == true))
        {
          isDirty = true;
          break;
        }
      }
    dirty = isDirty;
  }

  ///////////
  /* Clean */
  ///////////
  set clean (bool b)
  {
    dirty = false;
    items.forEach((index, item) => item.dirty = false);
  }


  ////////////
  /* moreup */
  ////////////
  BooleanObservable? get moreUpObservable => _moreUp;
  BooleanObservable? _moreUp;
  @override
  set moreUp (dynamic v)
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
  bool? get moreUp =>  _moreUp?.get();

  //////////////
  /* moreDown */
  //////////////
  BooleanObservable? get moreDownObservable => _moreDown;
  BooleanObservable? _moreDown;
  @override
  set moreDown (dynamic v)
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
  BooleanObservable? get moreLeftObservable => _moreLeft;
  BooleanObservable? _moreLeft;
  @override
  set moreLeft (dynamic v)
  {
    if (_moreLeft != null)
    {
      _moreLeft!.set(v);
    }
    else if (v != null)
    {
      _moreLeft = BooleanObservable(Binding.toKey(id, 'moreleft'), v, scope: scope);
    }
  }
  @override
  bool? get moreLeft => _moreLeft?.get();

  ///////////
  /* moreRight */
  ///////////
  BooleanObservable? get moreRightObservable => _moreRight;
  BooleanObservable? _moreRight;
  @override
  set moreRight (dynamic v)
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
  bool? get moreRight =>_moreRight?.get();

  ///////////////
  /* Direction */
  ///////////////
  StringObservable? _direction;
  set direction (dynamic v)
  {
    if (_direction != null)
    {
      _direction!.set(v);
    }
    else if (v != null)
    {
      _direction = StringObservable(Binding.toKey(id, 'direction'), v, scope: scope, listener: onPropertyChange);
    }
  }
  dynamic get direction => _direction?.get();

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

  Size? itemSize;

  GridModel(WidgetModel parent, String? id, {dynamic width, dynamic height, dynamic direction, dynamic scrollShadows, dynamic scrollButtons, dynamic onpulldown, dynamic draggable}) : super(parent, id)
  {
    // instantiate busy observable
    busy = false;

    if (width  != null) this.width  = width;
    if (height != null) this.height = height;

    this.draggable = draggable;
    this.onpulldown    = onpulldown;
    this.direction = direction;
    this.scrollShadows = scrollShadows;
    moreUp = false;
    moreDown = false;
    moreLeft = false;
    moreRight = false;
  }

  static GridModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    GridModel? model;
    try
    {
      model = GridModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'grid.Model');
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
    direction      = Xml.get(node: xml, tag: 'direction');
    scrollShadows  = Xml.get(node: xml, tag: 'scrollshadows');
    onpulldown  = Xml.get(node: xml, tag: 'onpulldown');
    draggable = Xml.get(node: xml, tag: 'draggable');

    // clear items
    this.items.forEach((_,item) => item.dispose());
    this.items.clear();

    // Build items
    int i = 0;
    List<GridItemModel> items = findChildrenOfExactType(GridItemModel).cast<GridItemModel>();

    // set prototype
    if (!S.isNullOrEmpty(datasource) && items.isNotEmpty) {
      prototype = S.toPrototype(items[0].element.toString());
      items.removeAt(0);
    }
    // build items
    for (var item in items) {
      this.items[i++] = item;
    }
  }

  GridItemModel? getItemModel(int item) {
    if ((item.isNegative) || (items.length <= item)) return null;
    return items[item];
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async {
    busy = true;
    int i = 0;

    if (list != null)
    {
      clean = true;

      // clear items
      items.forEach((_,item) => item.dispose());
      items.clear();

      // Populate grid items from datasource
      list.forEach((row) {
        XmlElement? prototype = S.fromPrototype(this.prototype, "$id-$i");
        var model = GridItemModel.fromXml(parent!, prototype, data: row);
        if (model != null) items[i++] = model;
      });

      notifyListeners('list', items);
    }

    busy = false;
    return true;
  }

  void sort(String? field, String? type, bool? ascending) async {
    if ((data == null) ||  (data.isEmpty) || (field == null)) return;

    busy = true;

    sort_transform.Sort sort = sort_transform.Sort(null, field: field, type: type, ascending: ascending);
    await sort.apply(data);

    busy = false;
  }

  Future<bool> export({bool? raw}) async
  {
//  //////////
//    EXCEL
//  //////////
//    List<int> excelBytes = await EXCEL.Excel.create(this.data);
//    if (excelBytes != null) System().fileSaveAs(excelBytes, S.newId() + '.csv');

//  ////////
//    CSV
//  ////////
    List<int> csvBytes = []; // Our csvString is stored in Uint8List for output to file
//    /////////////
//      ALL DATA
//    /////////////
//    Note csvStringFromData() does not handle large amounts of data in chunks and can overflow
    if (raw == true) {
      String str = await csvStringFromData(data);
      csvBytes = utf8.encode(str);
      Platform.fileSaveAs(csvBytes, '${S.newId()}.csv');
      return true;
    }

//    /////////////
//      GRID DATA
//    /////////////
//    HEADERS
    GridItemModel? currItem;
    int i = 0;
    // String csvItems = '';
    while ((currItem = getItemModel(i++)) != null) {
      String csvCellText = '';
      List<dynamic>? descendants = currItem!.findDescendantsOfExactType(TextModel);
      if (descendants != null && descendants.isNotEmpty) {
        descendants.forEach((val) {
          var textLine = '';
          // add return newline to csv for multiple text values within cell
//          if (csvCellText != '') csvCellText += '\n';
          textLine = val?.value ?? '';
          // escape "'s in string
          textLine.replaceAll('"', '""');
          // surround in quotes for newline+returns / comma handling
          textLine = (textLine.contains(',') || textLine.contains('\n')) ? '"$textLine"' : textLine;
          // goto next column
          csvCellText = '$textLine, ';
        });
      }
      else {
        csvCellText = '';
      }

      // go to next row
      csvCellText += '\n';
      // append the csv cell row to the csv string bytes
      csvBytes = [...csvBytes, ...utf8.encode(csvCellText)];
      // reset current csv row
      csvCellText = '';
    }
    // eof replacing last \n with \r\n
    if (csvBytes.length >= 2) {
      csvBytes.removeLast(); // \ = 5c
      csvBytes.removeLast(); // n = 6e
    }
    csvBytes = [...csvBytes, ...utf8.encode('\r\n')]; // \r\n = 5c, 72, 5c, 6e
    // Uint8List.fromList(bytes) - typed_data conversion needed for converting back to Uint8List after manipulating the list
    if ( csvBytes.isNotEmpty) Platform.fileSaveAs(Uint8List.fromList(csvBytes), '${S.newId()}.csv');
    return true;
  }

  Future<String> csvStringFromData(List<dynamic>? data) async {
    String str = '';
    int i = 0;
    try {
//      Build Header
      List<String> header = [];
      List<String> columns = [];
      if ((data != null) && (data.isNotEmpty)) {
        data[0].forEach((key, value) {
          columns.add(key);
          String h = key.toString();
          h.replaceAll('"', '""');
          h = h.contains(',') ? '"$h"' : h;
          header.add(h);
        });
      }

//      Output Header
      str += '${header.join(", ")}\n';
//      Output Data
      i = 0;
      if (columns.isNotEmpty) {
        data!.forEach((map)
        {
          i++;
          List<String> row = [];
          columns.forEach((column)
          {
            String value = map.containsKey(column) ? map[column].toString() : '';
            value.replaceAll('"', '""');
            value = value.contains(',') ? '"$value"' : value;
            row.add(value);
          });
          str += '${row.join(", ")}\n';
        });
      }
      // eof
      str.replaceFirst('\n', '\r\n', str.lastIndexOf('\n')); // replaces last
    }
    catch(e)
    {
      Log().exception(e, caller: 'grid.Model');
      Log().debug('Error - Creating CSV - column[$i]');
      Log().info('Error - Creating CSV');
    }
    return str;
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');

    // clear items
    items.forEach((_,item) => item.dispose());
    items.clear();

    super.dispose();
  }

  Future<void> onPull(BuildContext context) async
  {
    await EventHandler(this).execute(_onpulldown);
  }

  @override
  Widget getView({Key? key}) => getReactiveView(grid_view.GridView(this));
}
