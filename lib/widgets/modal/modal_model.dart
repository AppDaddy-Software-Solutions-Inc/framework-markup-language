// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/modal/modal_manager_view.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';
import 'modal_view.dart';

class ModalModel extends BoxModel {
  final Widget? child;

  @override
  bool get center => true;

  @override
  bool get expand => true;

  ModalModel(Model super.parent, super.id,
      {this.child,
      dynamic title,
      dynamic width,
      dynamic height,
      dynamic x,
      dynamic y,
      dynamic color,
      dynamic resizeable,
      dynamic draggable,
      dynamic modal,
      dynamic closeable,
      dynamic dismissible}) {
    if (title != null) this.title = title;
    if (width != null) this.width = width;
    if (height != null) this.height = height;
    if (x != null) this.x = x;
    if (y != null) this.y = y;
    if (color != null) this.color = color;
    if (resizeable != null) this.resizeable = resizeable;
    if (draggable != null) this.draggable = draggable;
    if (modal != null) this.modal = modal;
    if (closeable != null) this.closeable = closeable;
    if (dismissible != null) dismissable = dismissible;
  }

  @override
  String get border => "all";

  Color? defaultBorderColor;

  @override
  Color get borderColor =>
      super.borderColor ?? defaultBorderColor ?? Colors.white;

  // returns thge modal border radius for the header
  double get headerRadius => super.radiusTopRight;

  @override
  double get radiusTopRight => 0;

  @override
  double get radiusTopLeft => 0;

  // title
  StringObservable? _title;
  set title(dynamic v) {
    if (_title != null) {
      _title!.set(v);
    } else if (v != null) {
      _title = StringObservable(Binding.toKey(id, 'title'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get title => _title?.get();

  // modal
  BooleanObservable? _modal;
  set modal(dynamic v) {
    if (_modal != null) {
      _modal!.set(v);
    } else if (v != null) {
      _modal = BooleanObservable(Binding.toKey(id, 'modal'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get modal => _modal?.get() ?? true;

  // dismissable
  BooleanObservable? _dismissable;
  set dismissable(dynamic v) {
    if (_dismissable != null) {
      _dismissable!.set(v);
    } else if (v != null) {
      _dismissable = BooleanObservable(Binding.toKey(id, 'dismissable'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get dismissable => _dismissable?.get() ?? true;

  // resizeable
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

  // closeable
  BooleanObservable? _closeable;
  set closeable(dynamic v) {
    if (_closeable != null) {
      _closeable!.set(v);
    } else if (v != null) {
      _closeable = BooleanObservable(Binding.toKey(id, 'closeable'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get closeable => _closeable?.get() ?? true;

  bool get minimized {
    var view = findListenerOfExactType(ModalViewState);
    if (view != null) return view!.minimized;
    return false;
  }

  DoubleObservable? _x;
  set x(dynamic v) {
    if (_x != null) {
      _x!.set(v);
    } else if (v != null) {
      _x = DoubleObservable(Binding.toKey(id, 'x'), v,
          scope: scope, listener: onPropertyChange);
      _x!.set(v, notify: false);
    }
  }

  double? get x => _x?.get();

  DoubleObservable? _y;
  set y(dynamic v) {
    if (_y != null) {
      _y!.set(v);
    } else if (v != null) {
      _y = DoubleObservable(Binding.toKey(id, 'y'), v,
          scope: scope, listener: onPropertyChange);
      _y!.set(v, notify: false);
    }
  }

  double? get y => _y?.get();

  static ModalModel? fromXml(Model parent, XmlElement xml) {
    ModalModel? model;
    try {
      model = ModalModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'modal.Model');
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
    title = Xml.get(node: xml, tag: 'title');
    dismissable = Xml.get(node: xml, tag: 'dismissable');
    resizeable = Xml.get(node: xml, tag: 'resizeable');
    closeable = Xml.get(node: xml, tag: 'closeable');
    modal = Xml.get(node: xml, tag: 'modal');
  }

  @override
  List<Widget> inflate() {
    // process children
    List<Widget> views = [];
    for (var model in viewableChildren) {
      if (model is! ModalModel) {

        var view = model.getView();

        // wrap child in child data widget
        // this is done for us in "positioned" if the child happens
        // to be a positioned widget and the layout is "stack" (see positioned_view.dart)
        if (view != null) {
          views.add(view);
        }
      }
    }

    // add the static child
    if (child != null) {
      views.add(child!);
    }

    return views;
  }

  @override
  Future<bool?> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();
    switch (function) {
      case "open":
        var view = findListenerOfExactType(ModalViewState);
        if (view == null) {
          // modal width
          if (arguments.isNotEmpty) width = toStr(arguments[0]);

          // modal height
          if (arguments.length > 1) height = toStr(arguments[1]);

          // resizeable
          if (arguments.length > 2) resizeable = toBool(arguments[2]) ?? true;

          // closeable
          if (arguments.length > 3) closeable = toBool(arguments[3]) ?? true;

          // draggable
          if (arguments.length > 4) draggable = toBool(arguments[4]) ?? true;

          // modal
          if (arguments.length > 5) modal = toBool(arguments[5]) ?? true;

          open(ModalView(this));
        }
        return true;

      case "close":
        close();
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  void open(ModalView view) {
    ModalManagerView? manager =
        context?.findAncestorWidgetOfExactType<ModalManagerView>();
    if (manager != null) {
      manager.model.modals.add(view);
      manager.model.refresh();
    }
  }

  void close() {
    var view = findListenerOfExactType(ModalViewState);
    if (view != null) {
      view!.onClose();
      ModalManagerView? manager =
          context?.findAncestorWidgetOfExactType<ModalManagerView>();
      if (manager != null) manager.model.refresh();
    }
  }

  void dismiss() {
    var view = findListenerOfExactType(ModalViewState);
    if (view != null) view!.onDismiss();
  }

  /// Returns the [MODAL] View
  @override
  Widget getView({Key? key}) => getReactiveView(ModalView(this));

  @override
  Widget getReactiveView(Widget view) {
    // wrap animations.
    if (animations != null) {
      var animations = this.animations!.reversed;
      for (var model in animations) {
        view = model.getAnimatedView(view);
      }
    }
    return view;
  }
}
