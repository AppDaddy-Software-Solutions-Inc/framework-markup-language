// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/column/column_model.dart';
import 'package:fml/widgets/reactive/reactive_view.dart';
import 'package:fml/widgets/row/row_model.dart';
import 'package:fml/widgets/scroller/scroller_interface.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/scroller/scroller_view.dart';
import 'package:fml/event/event.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

/// Button [ScrollerModel]
///
/// Defines the properties used to build a [SCROLLER.ScrollerView]
class ScrollerModel extends BoxModel implements IScrollable {
  // holds the inner child content
  BoxModel? _body;

  // to be implemented
  @override
  bool moreUp = false;

  @override
  bool moreDown = false;

  @override
  bool moreLeft = false;

  @override
  bool moreRight = false;

  @override
  set layout(dynamic v) {
    if (v is String) {
      switch (v.toLowerCase().trim()) {
        case 'row':
        case 'horizontal':
          super.layout = 'row';
          break;
        default:
          super.layout = 'column';
          break;
      }
    }
  }

  /// If true will display a scrollbar, just used as a backup if flutter's built in scrollbar doesn't work
  BooleanObservable? _scrollbar;
  set scrollbar(dynamic v) {
    if (_scrollbar != null) {
      _scrollbar!.set(v);
    } else if (v != null) {
      _scrollbar = BooleanObservable(Binding.toKey(id, 'scrollbar'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get scrollbar => _scrollbar?.get() ?? true;

  /// Calls an [Event] String when the scroll reaches max extent
  StringObservable? _onscrolledtoend;
  set onscrolledtoend(dynamic v) {
    if (_onscrolledtoend != null) {
      _onscrolledtoend!.set(v);
    } else if (v != null) {
      _onscrolledtoend = StringObservable(
          Binding.toKey(id, 'onscrolledtoend'), v,
          scope: scope, listener: onPropertyChange, lazyEvaluation: true);
    }
  }

  dynamic get onscrolledtoend => _onscrolledtoend?.get();

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

  ScrollerModel(Model super.parent, super.id);

  static ScrollerModel? fromXml(Model parent, XmlElement xml) {
    ScrollerModel? model;
    try {
      // build model
      model = ScrollerModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'scroller.Model');
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
    layout = Xml.get(node: xml, tag: 'layout') ??
        Xml.get(node: xml, tag: 'direction');
    scrollbar = Xml.get(node: xml, tag: 'scrollbar');
    onscrolledtoend = Xml.get(node: xml, tag: 'onscrolledtoend');
    shadowColor = Xml.get(node: xml, tag: 'shadowcolor');
    onpulldown = Xml.get(node: xml, tag: 'onpulldown');
    allowDrag = Xml.get(node: xml, tag: 'allowDrag');
  }

  Future<bool> scrolledToEnd(BuildContext context) async {
    if (isNullOrEmpty(onscrolledtoend)) return false;
    return await EventHandler(this).execute(_onscrolledtoend);
  }

  Future<void> onPull(BuildContext context) async {
    await EventHandler(this).execute(_onpulldown);
  }

  // returns the inner content model
  BoxModel getContentModel() {
    // build the _body model
    _body ??= (layoutType == LayoutType.row)
        ? RowModel(this, null)
        : ColumnModel(this, null);

    // add my children to content
    _body!.children = [];
    _body!.children!.addAll(children ?? []);

    return _body!;
  }

  @override
  Offset? positionOf() {
    ScrollerViewState? view = findListenerOfExactType(ScrollerViewState);
    return view?.positionOf();
  }

  @override
  Size? sizeOf() {
    ScrollerViewState? view = findListenerOfExactType(ScrollerViewState);
    return view?.sizeOf();
  }

  @override
  Axis directionOf() =>layoutType == LayoutType.row ? Axis.horizontal : Axis.vertical;

  /// scroll +/- pixels or to an item
  @override
  void scroll(double? pixels, {bool animate = false}) {

    // get the view
    ScrollerViewState? view = findListenerOfExactType(ScrollerViewState);

    // scroll specified number of pixels
    // from current position
    view?.scroll(pixels, animate: animate);
  }

  /// scroll to specified item by id and value
  @override
  void scrollTo(String? id, String? value, {bool animate = false}) {

    if (id == null) return;

    // get the view
    ScrollerViewState? view = findListenerOfExactType(ScrollerViewState);

    // scroll to top
    if (id.trim().toLowerCase() == 'top' && isNullOrEmpty(value)) {
      view?.scrollTo(0, animate: false);
      return;
    }

    // scroll to bottom
    if (id.trim().toLowerCase() == 'bottom' && isNullOrEmpty(value)) {
      view?.scrollTo(double.maxFinite, animate: false);
      return;
    }

    // scroll to specific pixel position
    if (isNumeric(id) && isNullOrEmpty(value)) {
      view?.scrollTo(toDouble(id), animate: false);
    }

    // find the first child with the specified
    // id and matching value
    var child = descendants?.toList().firstWhereOrNull((child) => child.id == id && child.value == (value ?? child.value));
    if (child != null) {
      view?.scrollToContext(child.context, animate: animate);
    }
  }

  @override
  Future<dynamic> execute(String caller,
      String propertyOrFunction,
      List<dynamic> arguments) async {

    /// setter
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    switch (function) {

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
    var view = ScrollerView(this);
    return isReactive ? ReactiveView(this, view) : view;
  }
}
