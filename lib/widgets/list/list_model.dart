// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'package:collection/collection.dart';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/dragdrop/drag_drop_interface.dart';
import 'package:fml/widgets/dragdrop/dragdrop.dart';
import 'package:fml/widgets/form/form_interface.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:fml/widgets/scroller/scroller_interface.dart';
import 'package:xml/xml.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/widgets/list/list_view.dart';
import 'package:fml/widgets/list/item/list_item_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class ListModel extends DecoratedWidgetModel implements IForm, IScrollable {
  final HashMap<int, ListItemModel> items = HashMap<int, ListItemModel>();

  // full list of data
  // pointing to data broker data
  Data? _dataset;

  // data sourced prototype
  XmlElement? prototype;

  // returns the number of records in the dataset
  int? get records => _dataset?.length;

  // IDataSource
  IDataSource? myDataSource;

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

  // moreup
  BooleanObservable? _moreUp;
  @override
  set moreUp(dynamic v) {
    if (_moreUp != null) {
      _moreUp!.set(v);
    } else if (v != null) {
      _moreUp = BooleanObservable(Binding.toKey(id, 'moreup'), v, scope: scope);
    }
  }

  @override
  bool get moreUp => _moreUp?.get() ?? false;

  // moreDown
  BooleanObservable? _moreDown;
  @override
  set moreDown(dynamic v) {
    if (_moreDown != null) {
      _moreDown!.set(v);
    } else if (v != null) {
      _moreDown =
          BooleanObservable(Binding.toKey(id, 'moredown'), v, scope: scope);
    }
  }

  @override
  bool get moreDown => _moreDown?.get() ?? false;

  // moreLeft
  BooleanObservable? _moreLeft;
  @override
  set moreLeft(dynamic v) {
    if (_moreLeft != null) {
      _moreLeft!.set(v);
    } else if (v != null) {
      _moreLeft =
          BooleanObservable(Binding.toKey(id, 'moreleft'), v, scope: scope);
    }
  }

  @override
  bool get moreLeft => _moreLeft?.get() ?? false;

  // moreRight
  BooleanObservable? _moreRight;
  @override
  set moreRight(dynamic v) {
    if (_moreRight != null) {
      _moreRight!.set(v);
    } else if (v != null) {
      _moreRight =
          BooleanObservable(Binding.toKey(id, 'moreright'), v, scope: scope);
    }
  }

  @override
  bool get moreRight => _moreRight?.get() ?? false;

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
    for (var entry in items.entries) {
      if ((entry.value.dirty == true)) {
        isDirty = true;
        break;
      }
    }
    dirty = isDirty;
  }

  // Clean
  @override
  set clean(bool b) {
    dirty = false;
    items.forEach((index, item) => item.dirty = false);
  }

  // oncomplete
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

  // Direction
  StringObservable? _direction;
  set direction(dynamic v) {
    if (_direction != null) {
      _direction!.set(v);
    } else if (v != null) {
      _direction = StringObservable(Binding.toKey(id, 'direction'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  dynamic get direction => _direction?.get();

  BooleanObservable? _collapsed;
  set collapsed(dynamic v) {
    if (_collapsed != null) {
      _collapsed!.set(v);
    } else if (v != null) {
      _collapsed =
          BooleanObservable(Binding.toKey(id, 'collapsed'), v, scope: scope);
    }
  }

  bool get collapsed => _collapsed?.get() ?? false;

  /// Calls an [Event] String when the scroll overscrolls
  StringObservable? _onpulldown;
  set onpulldown(dynamic v) {
    if (_onpulldown != null) {
      _onpulldown!.set(v);
    } else if (v != null) {
      _onpulldown = StringObservable(Binding.toKey(id, 'onpulldown'), v,
          scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }

  dynamic get onpulldown => _onpulldown?.get();

  // allowDrag
  BooleanObservable? _allowDrag;
  set allowDrag(dynamic v) {
    if (_allowDrag != null) {
      _allowDrag!.set(v);
    } else if (v != null) {
      _allowDrag = BooleanObservable(Binding.toKey(id, 'allowdrag'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get allowDrag => _allowDrag?.get() ?? false;

  BooleanObservable? _reverse;
  set reverse(dynamic v) {
    if (_reverse != null) {
      _reverse!.set(v);
    } else if (v != null) {
      _reverse = BooleanObservable(Binding.toKey(id, 'reverse'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get reverse => _reverse?.get() ?? false;

  ListModel(super.parent, super.id,
      {dynamic direction,
      dynamic reverse,
      dynamic allowDrag,
      dynamic scrollShadows,
      dynamic onpulldown}) {
    // instantiate busy observable
    busy = false;

    this.direction = direction;
    this.reverse = reverse;
    this.allowDrag = allowDrag;
    this.onpulldown = onpulldown;
    this.scrollShadows = scrollShadows;
    scrollButtons = scrollButtons;
    collapsed = collapsed;
    moreUp = false;
    moreDown = false;
    moreLeft = false;
    moreRight = false;
  }

  static ListModel? fromXml(WidgetModel? parent, XmlElement xml) {
    ListModel? model;
    try {
      model = ListModel(parent, Xml.get(node: xml, tag: 'id'));

      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'list.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {
    // deserialize
    super.deserialize(xml);

    // properties
    direction = Xml.get(node: xml, tag: 'direction');
    allowDrag = Xml.get(node: xml, tag: 'allowDrag');
    scrollShadows = Xml.get(node: xml, tag: 'scrollshadows');
    scrollButtons = Xml.get(node: xml, tag: 'scrollbuttons');
    collapsed = Xml.get(node: xml, tag: 'collapsed');
    onpulldown = Xml.get(node: xml, tag: 'onpulldown');
    reverse = Xml.get(node: xml, tag: 'reverse');
    post = Xml.get(node: xml, tag: 'post');

    // clear items
    items.forEach((_, item) => item.dispose());
    items.clear();

    // build list items
    _buildItems();
  }

  void _buildItems() {
    List<ListItemModel> items =
        findChildrenOfExactType(ListItemModel).cast<ListItemModel>();

    // set prototype
    if ((!isNullOrEmpty(datasource)) && (items.isNotEmpty)) {
      prototype = prototypeOf(items.first.element);
      items.removeAt(0);
    }

    // build items
    int i = 0;
    for (var item in items) {
      this.items[i++] = item;
    }
  }

  ListItemModel? getItemModel(int index) {
    // fixed list?
    if (isNullOrEmpty(datasource))
      return (index < items.length) ? items[index] : null;

    // item model exists?
    if (_dataset == null) return null;

    var list = _dataset!;
    if (list.length < (index + 1)) return null;
    if (items.containsKey(index)) return items[index];
    if (index.isNegative || list.length < index) return null;

    // build item model
    var model = ListItemModel.fromXml(this, prototype, data: list[index]);
    if (model != null) {
      // set the index
      model.index = index;

      // set the selected data
      if (model.selected == true) {
        // this must be done after the build
        WidgetsBinding.instance.addPostFrameCallback((_) => data = model.data);
      }

      // register listener to dirty field
      if (model.dirtyObservable != null)
        model.dirtyObservable!.registerListener(onDirtyListener);

      // save model
      items[index] = model;
    }

    return model;
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async {
    busy = true;

    // save pointer to data source
    myDataSource = source;

    clean = true;

    // clear items
    items.forEach((_, item) => item.dispose());
    items.clear();

    if (list != null) {
      _dataset = list;
    } else {
      _dataset = Data();
    }

    // notify listeners
    notifyListeners('list', items);

    busy = false;
    return true;
  }

  @override
  dispose() {
    // clear items
    items.forEach((_, item) => item.dispose());
    items.clear();

    super.dispose();
  }

  @override
  Future<bool> complete() async {
    busy = true;

    bool ok = true;

    // Post the Form
    if (dirty) {
      for (var entry in items.entries) {
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

  Future<void> onPull(BuildContext context) async {
    await EventHandler(this).execute(_onpulldown);
  }

  Future<bool> onTap(ListItemModel? model) async {
    items.forEach((key, item) {
      if (item == model) {
        // toggle selected
        bool isSelected = (item.selected ?? false) ? false : true;

        // set values
        item.selected = isSelected;
        data = isSelected ? item.data : Data();
      } else {
        item.selected = false;
      }
    });
    return true;
  }

  void onDragDrop(IDragDrop droppable, IDragDrop draggable,
      {Offset? dropSpot}) async {
    if (droppable is ListItemModel && draggable is ListItemModel) {
      // fire onDrop event
      await DragDrop.onDrop(droppable, draggable, dropSpot: dropSpot);

      // get drag and drop index
      var dragIndex = items.entries
          .firstWhereOrNull((element) => element.value == draggable)
          ?.key;
      var dropIndex = items.entries
          .firstWhereOrNull((element) => element.value == droppable)
          ?.key;

      // move the cell in the items list
      if (dragIndex != null && dropIndex != null && dragIndex != dropIndex) {
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
  Future<bool?> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    /// setter
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    switch (function) {
      // selects the item by index
      case "select":
        int index = toInt(elementAt(arguments, 0)) ?? -1;
        if (index >= 0 && index < items.length) {
          var model = items[index];
          if (model != null && model.selected == false) onTap(model);
        }
        return true;

      // de-selects the item by index
      case "deselect":
        int index = toInt(elementAt(arguments, 0)) ?? -1;
        if (index >= 0 && _dataset != null && index < _dataset!.length) {
          var model = items[index];
          if (model != null && model.selected == true) onTap(model);
        }
        return true;

      // move an item
      case "move":
        moveItem(toInt(elementAt(arguments, 0)) ?? 0,
            toInt(elementAt(arguments, 1)) ?? 0);
        return true;

      // delete an item
      case "delete":
        deleteItem(toInt(elementAt(arguments, 0)));
        return true;

      // add an item
      case "insert":
        insertItem(
            toStr(elementAt(arguments, 0)), toInt(elementAt(arguments, 1)));
        return true;

      // de-selects the item by index
      case "clear":
        onTap(null);
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  @override
  void scrollUp(int pixels) {
    ListLayoutViewState? view = findListenerOfExactType(ListLayoutViewState);
    if (view == null) return;

    // already at top
    if (view.controller.offset == 0) return;

    var to = view.controller.offset - pixels;
    to = (to < 0) ? 0 : to;

    view.controller.jumpTo(to);
  }

  @override
  void scrollDown(int pixels) {
    ListLayoutViewState? view = findListenerOfExactType(ListLayoutViewState);
    if (view == null) return;

    if (view.controller.position.pixels >=
        view.controller.position.maxScrollExtent) return;

    var to = view.controller.offset + pixels;
    to = (to > view.controller.position.maxScrollExtent)
        ? view.controller.position.maxScrollExtent
        : to;

    view.controller.jumpTo(to);
  }

  @override
  Offset? positionOf() {
    ListLayoutViewState? view = findListenerOfExactType(ListLayoutViewState);
    return view?.positionOf();
  }

  @override
  Size? sizeOf() {
    ListLayoutViewState? view = findListenerOfExactType(ListLayoutViewState);
    return view?.sizeOf();
  }

  // insert an item
  Future<bool> insertItem(String? jsonOrXml, int? index) async {
    try {
      // get index
      index ??= myDataSource?.data?.indexOf(data) ?? 0;
      if (index < 0) index = 0;
      if (index > items.length) index = items.length;

      // add empty element to the data set
      // important to do this first as
      // get row model below depends on an entry
      // in the dataset at specified index
      notificationsEnabled = false;
      myDataSource?.insert(jsonOrXml, index, notifyListeners: false);
      data = myDataSource?.data ?? data;
      notificationsEnabled = true;

      // open up a space for the new model
      insertInHashmap(items, index);

      // create new row
      var item = getItemModel(index);

      // add row to rows
      if (item != null) {
        items[index] = item;

        // fire the rows onInsert event
        await item.onInsertHandler();
      }

      // notify
      data = myDataSource?.notify();
    } catch (e) {
      Log().exception(e);
    }
    return true;
  }

  // delete a row
  Future<bool> deleteItem(int? index) async {
    try {
      // get index
      index ??= myDataSource?.data?.indexOf(data) ?? 0;
      if (index < 0) index = 0;
      if (index > items.length) index = items.length;

      // lookup the item
      var item = items.containsKey(index) ? items[index] : null;
      if (item != null) {
        // fire the rows onDelete event
        bool ok = await item.onDeleteHandler();

        // continue?
        if (ok) {
          // reorder hashmap
          deleteInHashmap(items, index);

          // remove the data associated with the row
          notificationsEnabled = false;
          myDataSource?.delete(index, notifyListeners: false);
          data = myDataSource?.data ?? data;
          notificationsEnabled = true;

          // notify
          data = myDataSource?.notify();
        }
      }
    } catch (e) {
      Log().exception(e);
    }
    return true;
  }

  // delete a item
  Future<bool> moveItem(int? fromIndex, int? toIndex) async {
    try {
      fromIndex ??= myDataSource?.data?.indexOf(data) ?? 0;
      toIndex ??= myDataSource?.data?.indexOf(data) ?? 0;
      if (fromIndex > toIndex) {
        var index = fromIndex;
        fromIndex = toIndex;
        toIndex = index;
      }
      if (fromIndex < 0) fromIndex = 0;
      if (fromIndex > items.length) fromIndex = items.length;
      if (toIndex < 0) toIndex = 0;
      if (toIndex > items.length) toIndex = items.length;
      if (fromIndex == toIndex) return true;

      // reorder hashmap
      moveInHashmap(items, fromIndex, toIndex);

      // reorder data
      notificationsEnabled = false;
      myDataSource?.move(fromIndex, toIndex, notifyListeners: false);
      data = myDataSource?.data ?? data;
      notificationsEnabled = true;

      // notify
      data = myDataSource?.notify();
    } catch (e) {
      Log().exception(e);
    }
    return true;
  }

  @override
  Widget getView({Key? key}) => getReactiveView(ListLayoutView(this));
}
