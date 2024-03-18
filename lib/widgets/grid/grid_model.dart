// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/dragdrop/drag_drop_interface.dart';
import 'package:fml/widgets/dragdrop/dragdrop.dart';
import 'package:fml/widgets/grid/grid_view.dart';
import 'package:fml/widgets/scroller/scroller_interface.dart';
import 'package:fml/widgets/widget/widget_model.dart'     ;
import 'package:fml/widgets/grid/grid_view.dart' as grid_view;
import 'package:fml/widgets/grid/item/grid_item_model.dart';
import 'package:fml/datasources/transforms/sort.dart' as sort_transform;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

// platform
import 'package:fml/platform/platform.web.dart'
if (dart.library.io)   'package:fml/platform/platform.vm.dart'
if (dart.library.html) 'package:fml/platform/platform.web.dart';

class GridModel extends BoxModel implements IScrollable
{
  // full list of data
  // pointing to data broker data
  Data? _dataset;

  // data sourced prototype
  XmlElement? prototype;

  // IDataSource
  IDataSource? myDataSource;

  // returns the number of records in the dataset
  int? get records => _dataset?.length;

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

  // dirty
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
  bool get moreUp =>  _moreUp?.get() ?? false;

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
  bool get moreDown => _moreDown?.get() ?? false;

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
  bool get moreLeft => _moreLeft?.get() ?? false;

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
  bool get moreRight =>_moreRight?.get() ?? false;

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

  // allow drag
  BooleanObservable? _allowDrag;
  set allowDrag(dynamic v) {
    if (_allowDrag != null) {
      _allowDrag!.set(v);
    } else if (v != null) {
      _allowDrag = BooleanObservable(Binding.toKey(id, 'allowdrag'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get allowDrag => _allowDrag?.get() ?? false;

  Size? size;

  GridModel(WidgetModel super.parent, super.id, {dynamic width, dynamic height, dynamic direction, dynamic scrollShadows, dynamic scrollButtons, dynamic onpulldown, dynamic allowDrag})
  {
    // instantiate busy observable
    busy = false;

    if (width  != null) this.width  = width;
    if (height != null) this.height = height;

    this.allowDrag = allowDrag;
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
    onpulldown     = Xml.get(node: xml, tag: 'onpulldown');
    allowDrag      = Xml.get(node: xml, tag: 'allowDrag');

    // clear items
    items.forEach((_,item) => item.dispose());
    items.clear();

    // build grid items
    _buildItems();
  }

  void _buildItems()
  {
    List<GridItemModel> items = findChildrenOfExactType(GridItemModel).cast<GridItemModel>();

    // set prototype
    if (!isNullOrEmpty(datasource) && items.isNotEmpty)
    {
      prototype = prototypeOf(items.first.element);
      items.removeAt(0);
    }

    // build items
    int i=0;
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
    int index = 0;

    // save pointer to data source
    myDataSource = source;

    if (list != null)
    {
      clean = true;

      // clear items
      items.forEach((_,item) => item.dispose());
      items.clear();

      // Populate grid items from datasource
      for (var row in list)
      {
        var model = GridItemModel.fromXml(parent!, prototype, data: row);

        if (model != null)
        {
          // set the index
          model.index = index;

          // set the selected data
          if (model.selected == true)
          {
            // this must be done after the build
            WidgetsBinding.instance.addPostFrameCallback((_) => data = model.data);
          }

          // add to items list
          items[index++] = model;
        }
      }

      _dataset = list;
      notifyListeners('list', items);
    }

    busy = false;
    return true;
  }

  Future<bool> onTap(GridItemModel? model) async
  {
    items.forEach((key, item)
    {
      if (item == model)
      {
        // toggle selected
        bool isSelected = (item.selected ?? false) ? false : true;

        // set values
        item.selected = isSelected;
        data = isSelected ? item.data : Data();
      }
      else
      {
        item.selected = false;
      }
    });
    return true;
  }

  void sort(String? field, String? type, bool? ascending) async
  {
    if (_dataset == null ||  _dataset!.isEmpty || field == null) return;

    busy = true;

    sort_transform.Sort sort = sort_transform.Sort(null, field: field, type: type, ascending: ascending);
    await sort.apply(_dataset);

    busy = false;
  }

  // export to excel
  Future<bool> export() async
  {
    var data = Data.from(_dataset);

    // convert to data
    String csv = await Data.toCsv(data);

    // encode
    var csvBytes = utf8.encode(csv);

    // save to file
    Platform.fileSaveAs(csvBytes, "${newId()}.csv");

    return true;
  }

  @override
  dispose()
  {
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

      // selects the item by index
      case "select" :
        int index = toInt(elementAt(arguments, 0)) ?? -1;
        if (index >= 0 && index < items.length)
        {
          var model = items[index];
          if (model != null && model.selected == false) onTap(model);
        }
        return true;

      // de-selects the item by index
      case "deselect" :
        int index = toInt(elementAt(arguments, 0)) ?? -1;
        if (index >= 0 && _dataset != null && index < _dataset!.length)
        {
          var model = items[index];
          if (model != null && model.selected == true) onTap(model);
        }
        return true;

      // de-selects the item by index
      case "clear" :
        onTap(null);
        return true;
    }

    return super.execute(caller, propertyOrFunction, arguments);
  }

  @override
  void scrollUp(int pixels)
  {
    GridViewState? view = findListenerOfExactType(GridViewState);
    if (view == null) return;

    // already at top
    if (view.controller.offset == 0) return;

    var to = view.controller.offset - pixels;
    to = (to < 0) ? 0 : to;

    view.controller.jumpTo(to);
  }

  @override
  void scrollDown(int pixels)
  {
    GridViewState? view = findListenerOfExactType(GridViewState);
    if (view == null) return;

    if (view.controller.position.pixels >= view.controller.position.maxScrollExtent) return;

    var to = view.controller.offset + pixels;
    to = (to > view.controller.position.maxScrollExtent) ? view.controller.position.maxScrollExtent : to;

    view.controller.jumpTo(to);
  }

  @override
  Offset? positionOf()
  {
    GridViewState? view = findListenerOfExactType(GridViewState);
    return view?.positionOf();
  }

  @override
  Size? sizeOf()
  {
    GridViewState? view = findListenerOfExactType(GridViewState);
    return view?.sizeOf();
  }

  void onDragDrop(IDragDrop droppable, IDragDrop draggable, {Offset? dropSpot}) async
  {
    if (droppable is GridItemModel && draggable is GridItemModel)
    {
      // fire onDrop event
      await DragDrop.onDrop(droppable, draggable, dropSpot: dropSpot);

      // get drag and drop index
      var dragIndex = items.entries.firstWhereOrNull((element) => element.value == draggable)?.key;
      var dropIndex = items.entries.firstWhereOrNull((element) => element.value == droppable)?.key;

      // move the cell in the items list
      if (dragIndex != null && dropIndex != null && dragIndex != dropIndex)
      {
        // reorder hashmap
        moveInHashmap(items, dragIndex, dropIndex);

        // reorder data
        notificationsEnabled = false;
        myDataSource?.move(dragIndex, dropIndex, notifyListeners: false);
        data = myDataSource?.data ?? data;
        notificationsEnabled = true;


        // notify listeners
        notifyListeners('list', items);
      }
    }
  }

  @override
  Widget getView({Key? key}) => getReactiveView(grid_view.GridView(this));
}
