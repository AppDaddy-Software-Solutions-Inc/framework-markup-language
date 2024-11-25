// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/window/window_manager_view.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/widgets/window/window_view.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class WindowModel extends BoxModel {
  final Widget? child;

  @override
  bool get center => true;

  @override
  bool get expand => true;

  @override
  bool get needsVisibilityDetector => false;

  WindowModel(Model super.parent, super.id,
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
    var view = findListenerOfExactType(WindowViewState);
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

  // left
  // bool _leftIsPercent = false;
  DoubleObservable? _left;
  set left(dynamic v) {
    if (_left != null) {
      _left!.set(v);
    } else if (v != null) {
      if (isPercent(v)) {
        // _leftIsPercent = true;
        v = v.split("%")[0];
      }
      _left = DoubleObservable(Binding.toKey(id, 'left'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double? get left => _left?.get();

  // right
  // bool _rightIsPercent = false;
  DoubleObservable? _right;
  set right(dynamic v) {
    if (_right != null) {
      _right!.set(v);
    } else if (v != null) {
      if (isPercent(v)) {
        // _rightIsPercent = true;
        v = v.split("%")[0];
      }
      _right = DoubleObservable(Binding.toKey(id, 'right'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double? get right => _right?.get();

  // top
  // bool _topIsPercent = false;
  DoubleObservable? _top;
  set top(dynamic v) {
    if (_top != null) {
      _top!.set(v);
    } else if (v != null) {
      if (isPercent(v)) {
        // _topIsPercent = true;
        v = v.split("%")[0];
      }
      _top = DoubleObservable(Binding.toKey(id, 'top'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double? get top => _top?.get();

  // bottom
  // bool _bottomIsPercent = false;
  DoubleObservable? _bottom;
  set bottom(dynamic v) {
    if (_bottom != null) {
      _bottom!.set(v);
    } else if (v != null) {
      if (isPercent(v)) {
        // _bottomIsPercent = true;
        v = v.split("%")[0];
      }
      _bottom = DoubleObservable(Binding.toKey(id, 'bottom'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double? get bottom => _bottom?.get();

  static WindowModel? fromXml(Model parent, XmlElement xml) {
    WindowModel? model;
    try {
      model = WindowModel(parent, Xml.get(node: xml, tag: 'id'));
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

    closeable = Xml.get(node: xml, tag: 'closeable');
    modal = Xml.get(node: xml, tag: 'modal');

    left = Xml.get(node: xml, tag: 'left');
    right = Xml.get(node: xml, tag: 'right');
    top = Xml.get(node: xml, tag: 'top');
    bottom = Xml.get(node: xml, tag: 'bottom');
  }

  @override
  Future<dynamic> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();
    switch (function) {
      case "open":
        var view = findListenerOfExactType(WindowViewState);
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

  void open(WindowView view) {
    WindowManagerView? manager =
        context?.findAncestorWidgetOfExactType<WindowManagerView>();
    if (manager != null) {
      manager.model.windows.add(view);
      manager.model.refresh();
    }
  }

  void close() {
    var view = findListenerOfExactType(WindowViewState);
    if (view != null) {
      view!.onClose();
      WindowManagerView? manager =
          context?.findAncestorWidgetOfExactType<WindowManagerView>();
      if (manager != null) manager.model.refresh();
    }
    resetSize();
  }

  void dismiss() {
    var view = findListenerOfExactType(WindowViewState);
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
  WindowView getView({Key? key}) => WindowView(this);
}
