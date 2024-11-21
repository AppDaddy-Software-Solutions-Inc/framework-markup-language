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

  @override
  bool get needsVisibilityDetector => false;

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

  @override
  Color get borderColor {
      if (super.borderColor != null) return super.borderColor!;
      if (color != null && !titleBar) return color!;
      if (context != null) return Theme.of(context!).colorScheme.outline;
      return Colors.transparent;
  }

  // returns thge modal border radius for the header
  double get headerRadius {
    if (borderRadius == null) return 5;
    return super.radiusTopRight;
  }

  @override
  double get radiusTopRight => titleBar ? 0 : super.radiusTopRight;

  @override
  double get radiusTopLeft => titleBar ? 0 : super.radiusTopLeft;

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

  // show title bar
  BooleanObservable? _titleBar;
  set titleBar(dynamic v) {
    if (_titleBar != null) {
      _titleBar!.set(v);
    } else if (v != null) {
      _titleBar = BooleanObservable(Binding.toKey(id, 'titlebar'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get titleBar => _titleBar?.get() ?? true;

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

  // holds the resized width and height
  Size? _size;

  @override
  double? get width {
    var w = _size?.width;
    if (w == null || w == double.negativeInfinity) return super.width;
    return w;
  }

  @override
  double? get height {
    var h = _size?.height;
    if (h == null || h == double.negativeInfinity) return super.height;
    return h;
  }

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
    titleBar = Xml.get(node: xml, tag: 'titlebar');
    title = Xml.get(node: xml, tag: 'title');
    dismissable = Xml.get(node: xml, tag: 'dismissable');
    resizeable = Xml.get(node: xml, tag: 'resizeable');
    closeable = Xml.get(node: xml, tag: 'closeable');
    modal = Xml.get(node: xml, tag: 'modal');
  }

  @override
  Future<dynamic> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();
    switch (function) {
      case "open":
        var view = findListenerOfExactType(ModalViewState);
        if (view == null) {

          // modal?
          if (arguments.isNotEmpty) modal = toBool(arguments[0]) ?? false;

          open(getView());
        }
        return true;

      case "close":
        close();
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  // called to resize the modal
  // we do not want to change width and height directly since
  // they may be bindables
  void setSize(double? width, double? height) {
    _size = Size(width ?? double.negativeInfinity, height ?? double.negativeInfinity);
    notifyListeners(null, null);
  }

  // called when modal is closed
  // this allows original width and height to take precedence
  void resetSize() {
    _size = null;
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
    resetSize();
  }

  void dismiss() {
    var view = findListenerOfExactType(ModalViewState);
    if (view != null) view!.onDismiss();
  }

  @override
  void dispose() async {

    // close window if open
    close();

    // cleanup children
    super.dispose();
  }

  @override
  ModalView getView({Key? key}) => ModalView(this);
}
