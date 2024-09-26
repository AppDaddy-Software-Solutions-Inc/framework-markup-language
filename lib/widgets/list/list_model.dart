// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'package:collection/collection.dart';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/dragdrop/drag_drop_interface.dart';
import 'package:fml/widgets/dragdrop/dragdrop.dart';
import 'package:fml/widgets/form/form_interface.dart';
import 'package:fml/widgets/form/form_mixin.dart';
import 'package:fml/widgets/reactive/reactive_view.dart';
import 'package:fml/widgets/scroller/scroller_interface.dart';
import 'package:xml/xml.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/widgets/list/list_view.dart';
import 'package:fml/widgets/list/item/list_item_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class ListModel extends BoxModel with FormMixin implements IForm, IScrollable {

  // indicates if the widget expands infinitely in
  // it's horizontal axis if not constrained
  @override
  bool get canExpandInfinitelyWide => !hasBoundedWidth;

  // indicates if the widget expands infinitely in
  // it's vertical axis if not constrained
  @override
  bool get canExpandInfinitelyHigh => !hasBoundedHeight;

  // indicates if the widget will grow in
  // its horizontal axis
  @override
  bool get expandHorizontally => !hasBoundedWidth;

  // indicates if the widget will grow in
  // its vertical axis
  @override
  bool get expandVertically => !hasBoundedHeight;

  // maintains list of items
  final HashMap<int, ListItemModel> items = HashMap<int, ListItemModel>();

  // data map from the list item that is currently selected
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

  double? _extentWidth;
  double? _extentHeight;
  bool _measured = false;

  // used by the view to determine if it should measure
  // the items extent on layout
  bool shouldMeasureExtent() {

    // already measured?
    if (_measured) return false;

    // no prototype
    if (prototype == null) return false;

    switch (directionOf()) {
      case Axis.horizontal:

        // autosize?
        var auto = Xml.get(node: prototype, tag: 'width')?.trim().toLowerCase() == 'auto';
        if (auto) return false;

      case Axis.vertical:
      default:

        // autosize?
        var auto = Xml.get(node: prototype, tag: 'height')?.trim().toLowerCase() == 'auto';
        if (auto) return false;
    }

    // extend defined?
    return extent == null;
  }

  // used by the view to indictate that a layout measurement was performed
  void didMeasureExtent({double? width, double? height}) {
    _measured = true;
    _extentWidth = width;
    _extentHeight = height;
  }

  // returns the item extent based on the layout direction
  double? get extent {
    double? extent;
    switch (directionOf()) {
      case Axis.horizontal:
        extent = getWidth() ?? _extentWidth;
      case Axis.vertical:
      default:
        extent = getHeight() ?? _extentHeight;
    }

    // return extent
    return extent;
  }

  // max extent - items * item extent
  double get maxExtent {
    int i = isNullOrEmpty(datasource) ? items.length : data?.length ?? 0;
    return (extent ?? 0) * i;
  }

  // the list item prototype
  XmlElement? prototype;

  // IDataSource
  IDataSource? myDataSource;

  @override
  bool? get post => true;

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

  @override
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

  @override
  bool clear() => true;

  // Clean
  @override
  bool clean() {
    dirty = false;
    items.forEach((index, item) => item.dirty = false);
    return true;
  }

  // oncomplete
  StringObservable? _oncomplete;
  set oncomplete(dynamic v) {
    if (_oncomplete != null) {
      _oncomplete!.set(v);
    } else if (v != null) {
      _oncomplete = StringObservable(Binding.toKey(id, 'oncomplete'), v,
          scope: scope, lazyEvaluation: true);
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
  String get direction => _direction?.get()?.toLowerCase().trim() ?? 'vertical';

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
          scope: scope, listener: onPropertyChange, lazyEvaluation: true);
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
      dynamic onpulldown}) {
    // instantiate busy observable
    busy = false;

    this.direction = direction;
    this.reverse = reverse;
    this.allowDrag = allowDrag;
    this.onpulldown = onpulldown;
    moreUp = false;
    moreDown = false;
    moreLeft = false;
    moreRight = false;
  }

  static ListModel? fromXml(Model? parent, XmlElement xml) {
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
    collapsed = Xml.get(node: xml, tag: 'collapsed');
    onpulldown = Xml.get(node: xml, tag: 'onpulldown');
    reverse = Xml.get(node: xml, tag: 'reverse');

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
    if (!isNullOrEmpty(datasource) && items.isNotEmpty) {
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
    if (isNullOrEmpty(datasource)) {
      return (index < items.length) ? items[index] : null;
    }

    // item model exists?
    if (data == null) return null;

    if (data.length < index + 1) return null;
    if (items.containsKey(index)) return items[index];
    if (index.isNegative || data.length < index) return null;

    //var mod = index % 10000;
    //if (items.containsKey(mod)) {
      //if (items[mod]?.index == index) return items[mod];
      //items[mod]?.dispose();
    //}

    // build item model
    var model = ListItemModel.fromXml(this, prototype, data: data[index]);
    if (model != null) {
      // set the index
      model.index = index;

      // set the selected data
      if (model.selected == true) {
        // this must be done after the build
        WidgetsBinding.instance.addPostFrameCallback((_) => selected = model.data);
      }

      // register listener to dirty field
      if (model.dirtyObservable != null) {
        model.dirtyObservable!.registerListener(onDirtyListener);
      }

      // save model
      items[index] = model;
      //items[mod] = model;
    }

    return model;
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async {
    busy = true;

    // save pointer to data source
    myDataSource = source;

    // mark clean
    clean();

    // clear items
    items.forEach((_, item) => item.dispose());
    items.clear();

    // set data
    data = list ?? Data();

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

    // post the dirty items
    var list = items.values.where((item) => item.dirty == true).toList();
    for (var item in list) {
      ok = await item.complete();
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
        bool isSelected = item.selected ? false : true;

        // set values
        item.selected = isSelected;
        selected = isSelected ? item.data : Data();
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
        disableNotifications();
        myDataSource?.move(dragIndex, dropIndex, notifyListeners: false);
        data = myDataSource?.data ?? data;
        enableNotifications();

        // notify listeners
        notifyListeners('list', items);
      }
    }
  }

  /// scroll +/- pixels or to an item
  @override
  void scroll(double? pixels, {bool animate = false}) {

    // get the view
    ListLayoutViewState? view = findListenerOfExactType(ListLayoutViewState);

    // scroll specified number of pixels
    // from current position
    view?.scroll(pixels, animate: animate);
  }

  /// scroll +/- pixels or to an item
  @override
  void scrollTo(String? id, String? value, {bool animate = false}) {

    if (id == null) return;

    // get the view
    ListLayoutViewState? view = findListenerOfExactType(ListLayoutViewState);

    // scroll to top
    if ((id.trim().toLowerCase() == 'top' || id.trim().toLowerCase() == 'start') && isNullOrEmpty(value)) {
      view?.scrollTo(0, animate: false);
      return;
    }

    // scroll to bottom
    if ((id.trim().toLowerCase() == 'bottom' || id.trim().toLowerCase() == 'end') && isNullOrEmpty(value)) {
      view?.scrollTo(double.maxFinite, animate: false);
      return;
    }

    // scroll to specific pixel position
    if (isNumeric(id) && isNullOrEmpty(value)) {
      view?.scrollTo(toDouble(id), animate: false);
    }

    // build out the items
    // this may lag the system if the list is large
    if (data != null && items.length != data.length) {
      for (int i = 0; i < data.length; i++) {
        if (!items.containsKey(i)) {
          var item = getItemModel(i);
          if (item != null) {
            items[i] = item;
          }
        }
      }
    }

    // find the first item containing a child with the specified
    // id and matching value
    for (var item in items.values) {
      var child = item.descendants?.toList().firstWhereOrNull((child) => child.id == id && child.value == (value ?? child.value));
      if (child != null) {

        // get the item's position in the list
        int i = items.values.toList().indexOf(item);

        // scroll to that item
        view?.scrollTo(i * (extent ?? 0), animate: animate);
      }
    }
  }

  @override
  Offset? positionOf() {
    ListLayoutViewState? view = findListenerOfExactType(ListLayoutViewState);
    return view?.positionOf();
  }

  @override
  Axis directionOf() => direction == 'horizontal' ? Axis.horizontal : Axis.vertical;

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
      disableNotifications();
      myDataSource?.insert(jsonOrXml, index, notifyListeners: false);
      data = myDataSource?.data ?? data;
      enableNotifications();

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
          disableNotifications();
          myDataSource?.delete(index, notifyListeners: false);
          data = myDataSource?.data ?? data;
          enableNotifications();

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
      disableNotifications();
      myDataSource?.move(fromIndex, toIndex, notifyListeners: false);
      data = myDataSource?.data ?? data;
      enableNotifications();

      // notify
      data = myDataSource?.notify();
    } catch (e) {
      Log().exception(e);
    }
    return true;
  }

  // this routine iterates through each element in the data
  // and executes the eval string within the scope of that data
  Future<bool> forEach(String? eval) async {

    bool ok = true;

    // eval is null or empty
    if (isNullOrEmpty(eval)) return ok;

    // data is null or empty
    if (items.isEmpty) return ok;

    // iterate through each data point and execute the eval string
    for (var item in items.values) {

      // create observable
      var o = StringObservable(null, eval, scope: item.scope);

      // execute the eval string
      ok = await EventHandler(item).execute(o);

      // abort?
      if (ok == false) break;
    }

    return ok;
  }

  @override
  Future<dynamic> execute(
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
        if (index >= 0 && data != null && index < data.length) {
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

    // add an item
      case "foreach":
        forEach(
            toStr(elementAt(arguments, 0)));
        return true;

      // scroll +/- pixels
      case "scroll":
        scroll(toDouble(elementAt(arguments, 0)), animate: toBool(elementAt(arguments, 1)) ?? true);
        return true;

      // scroll to item by id
      case "scrollto":
        scrollTo(toStr(elementAt(arguments, 0)), toStr(elementAt(arguments, 1)), animate: toBool(elementAt(arguments, 2)) ?? true);
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  @override
  Widget getView({Key? key}) {
    var view = ListLayoutView(this);
    return isReactive ? ReactiveView(this, view) : view;
  }
}
