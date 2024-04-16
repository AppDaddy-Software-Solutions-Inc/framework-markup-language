// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/boolean.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:fml/widgets/dragdrop/drag_drop_interface.dart';
import 'package:fml/widgets/dragdrop/dragdrop.dart';
import 'package:fml/widgets/scroller/scroller_interface.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/menu/menu_view.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/menu/item/menu_item_model.dart';
import 'package:fml/helpers/helpers.dart';

class MenuModel extends ViewableWidgetModel implements IScrollable {
  static const String typeList = "list";
  static const String typeButton = "button";

  // to be implemented
  @override
  bool moreUp = false;

  @override
  bool moreDown = false;

  @override
  bool moreLeft = false;

  @override
  bool moreRight = false;

  // items
  List<MenuItemModel> items = [];

  // data sourced prototype
  XmlElement? prototype;

  // IDataSource
  IDataSource? myDataSource;

  @override
  bool get canExpandInfinitelyWide => !hasBoundedWidth;

  @override
  bool get canExpandInfinitelyHigh => !hasBoundedHeight;

  // allow drag
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

  MenuModel(super.parent, super.id) {
    // instantiate busy observable
    busy = false;
  }

  static MenuModel? fromXml(WidgetModel parent, XmlElement xml) {
    MenuModel? model;
    try {
      model = MenuModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'menu.Model');
      model = null;
    }
    return model;
  }

  static MenuModel? fromMap(WidgetModel parent, Map<String, String> map) {
    MenuModel? model;
    try {
      model = MenuModel(parent, newId());
      model.unmap(map);
    } catch (e) {
      Log().exception(e, caller: 'menu.Model');
      model = null;
    }
    return model;
  }

  void unmap(Map<String, String> map) {
    map.forEach((key, value) {
      MenuItemModel item = MenuItemModel(
        this,
        newId(),
        // url: ,
        title: key,
        // subtitle: ,
        icon: Icons.navigation_outlined,
      );
      items.add(item);
    });
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {
    // deserialize
    super.deserialize(xml);

    // allow mouse drag
    allowDrag = Xml.get(node: xml, tag: 'allowDrag');

    // clear items
    for (var item in items) {
      item.dispose();
    }
    items.clear();

    // build menu items
    _buildItems();
  }

  void _buildItems() {
    // build items
    List<MenuItemModel> items =
        findChildrenOfExactType(MenuItemModel).cast<MenuItemModel>();

    // set prototype
    if ((!isNullOrEmpty(datasource)) && (items.isNotEmpty)) {
      prototype = prototypeOf(items.first.element);
      items.removeAt(0);
    }

    // build items
    this.items.addAll(items);
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async {
    busy = true;

    // save pointer to data source
    myDataSource = source;

    // build options
    if ((list != null)) {
      // clear items
      for (var item in items) {
        item.dispose();
      }
      items.clear();

      for (var row in list) {
        var model = MenuItemModel.fromXml(this, prototype, data: row);
        if (model != null) items.add(model);
      }

      notifyListeners('list', items);
    }

    busy = false;

    return true;
  }

  @override
  dispose() {
    // clear items
    for (var item in items) {
      item.dispose();
    }
    items.clear();

    super.dispose();
  }

  /// scroll +/- pixels or to an item
  @override
  void scroll(double? pixels, {bool animate = false}) {

    // get the view
    MenuViewState? view = findListenerOfExactType(MenuViewState);

    // scroll specified number of pixels
    // from current position
    view?.scroll(pixels, animate: animate);
  }

  /// scroll to specified item by id and value
  @override
  void scrollTo(String? id, String? value, {bool animate = false}) {
    if (isNullOrEmpty(id)) return;

    // find the first item containing a child with the specified
    // id and matching value
    BuildContext? context;
    for (var item in items) {
      var child = item.descendants?.toList().firstWhereOrNull((child) => child.id == id && child.value == (value ?? child.value));
      if (child != null) {
        context = item.context;
        break;
      }
    }

    // context defined?
    if (context != null) {
      MenuViewState? view = findListenerOfExactType(MenuViewState);
      view?.scrollTo(context, animate: animate);
    }
  }

  @override
  Offset? positionOf() {
    MenuViewState? view = findListenerOfExactType(MenuViewState);
    return view?.positionOf();
  }

  @override
  Size? sizeOf() {
    MenuViewState? view = findListenerOfExactType(MenuViewState);
    return view?.sizeOf();
  }

  void onDragDrop(IDragDrop droppable, IDragDrop draggable,
      {Offset? dropSpot}) async {
    if (droppable is MenuItemModel && draggable is MenuItemModel) {
      // fire onDrop event
      await DragDrop.onDrop(droppable, draggable, dropSpot: dropSpot);

      // get drag and drop index
      var dragIndex = items.indexOf(draggable);
      var dropIndex = items.indexOf(droppable);

      //var center = DragDrop.getPercentOffset(dropBox, dropSpot);

      // move the cell in the items list
      if (dragIndex >= 0 && dropIndex >= 0 && dragIndex != dropIndex) {
        // move the cell in the dataset
        notificationsEnabled = false;
        myDataSource?.move(dragIndex, dropIndex, notifyListeners: false);
        data = myDataSource?.data ?? data;
        notificationsEnabled = true;

        // remove drag item from the list
        items.remove(draggable);

        // add drag item back into the list at drop index
        var moveUp = (dragIndex < dropIndex);
        var index = moveUp ? dropIndex - 1 : dropIndex;
        items.insert(index, draggable);

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
    // scroll +/- pixels
      case "scroll":
        scroll(toDouble(elementAt(arguments, 0)), animate: toBool(elementAt(arguments, 1)) ?? false);
        return true;

    // scroll to item by id
      case "scrollto":
        scrollTo(toStr(elementAt(arguments, 0)), toStr(elementAt(arguments, 1)), animate: toBool(elementAt(arguments, 1)) ?? false);
        return true;
    }

    return super.execute(caller, propertyOrFunction, arguments);
  }


  @override
  Widget getView({Key? key}) => getReactiveView(MenuView(this));
}
