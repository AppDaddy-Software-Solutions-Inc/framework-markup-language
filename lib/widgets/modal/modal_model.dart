// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_data.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/modal/modal_manager_view.dart';
import 'package:fml/widgets/positioned/positioned_view.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';
import 'modal_view.dart';

class ModalModel extends BoxModel
{
  final Widget? child;
  
  @override
  bool get center => true;

  @override
  bool get expand => true;

  ModalModel(WidgetModel parent, String?  id,
  {
    this.child,
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
    dynamic dismissable}) : super(parent, id)
  {
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
    if (dismissable != null) this.dismissable = dismissable;
  }

  @override
  String get border => "all";

  Color? defaultBorderColor;

  @override
  Color get bordercolor => super.bordercolor ?? defaultBorderColor ?? Colors.white;

  // returns thge modal border radius for the header
  double get headerRadius => super.radiusTopRight;

  @override
  double get radiusTopRight => 0;

  @override
  double get radiusTopLeft => 0;

  // title 
  StringObservable? _title;
  set title (dynamic v)
  {
    if (_title != null)
    {
      _title!.set(v);
    }
    else if (v != null)
    {
      _title = StringObservable(Binding.toKey(id, 'title'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get title => _title?.get();

  // modal
  BooleanObservable? _modal;
  set modal (dynamic v)
  {
    if (_modal != null)
    {
      _modal!.set(v);
    }
    else if (v != null)
    {
      _modal = BooleanObservable(Binding.toKey(id, 'modal'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get modal => _modal?.get() ?? true;

  // dismissable 
  BooleanObservable? _dismissable;
  set dismissable (dynamic v)
  {
    if (_dismissable != null)
    {
      _dismissable!.set(v);
    }
    else if (v != null)
    {
      _dismissable = BooleanObservable(Binding.toKey(id, 'dismissable'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get dismissable => _dismissable?.get() ?? true;
  
  // resizeable 
  BooleanObservable? _resizeable;
  set resizeable (dynamic v)
  {
    if (_resizeable != null)
    {
      _resizeable!.set(v);
    }
    else if (v != null)
    {
      _resizeable = BooleanObservable(Binding.toKey(id, 'resizeable'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get resizeable => _resizeable?.get() ?? true;

  // closeable 
  BooleanObservable? _closeable;
  set closeable (dynamic v)
  {
    if (_closeable != null)
    {
      _closeable!.set(v);
    }
    else if (v != null)
    {
      _closeable = BooleanObservable(Binding.toKey(id, 'closeable'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get closeable => _closeable?.get() ?? true;

  // draggable 
  BooleanObservable? _draggable;
  set draggable (dynamic v)
  {
    if (_draggable != null)
    {
      _draggable!.set(v);
    }
    else if (v != null)
    {
      _draggable = BooleanObservable(Binding.toKey(id, 'draggable'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get draggable => _draggable?.get() ?? true;

  bool get minimized
  {
    var view = findListenerOfExactType(ModalViewState);
    if (view != null) return view!.minimized;
    return false;
  }

  DoubleObservable? _x;
  set x(dynamic v)
  {
    if (_x != null)
    {
      _x!.set(v);
    }
    else if (v != null)
    {
      _x = DoubleObservable(Binding.toKey(id, 'x'), v, scope: scope, listener: onPropertyChange);
      _x!.set(v, notify: false);
    }
  }
  double? get x => _x?.get();

  DoubleObservable? _y;
  set y(dynamic v)
  {
    if (_y != null)
    {
      _y!.set(v);
    }
    else if (v != null)
    {
      _y = DoubleObservable(Binding.toKey(id, 'y'), v, scope: scope, listener: onPropertyChange);
      _y!.set(v, notify: false);
    }
  }
  double? get y => _y?.get();

  static ModalModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    ModalModel? model;
    try
    {
      model = ModalModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'modal.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement? xml)
  {
    // deserialize 
    super.deserialize(xml);

    // properties
    title        = Xml.get(node: xml, tag: 'title');
    dismissable  = Xml.get(node: xml, tag: 'resizeable');
    resizeable   = Xml.get(node: xml, tag: 'resizeable');
    closeable    = Xml.get(node: xml, tag: 'closable');
    draggable    = Xml.get(node: xml, tag: 'draggable');
    modal        = Xml.get(node: xml, tag: 'modal');
  }

  @override
  List<Widget> inflate()
  {
    // process children
    List<Widget> views = [];
    for (var model in viewableChildren)
    {
      if (model is! ModalModel)
      {
        var view = model.getView();

        // wrap child in child data widget
        // this is done for us in "positioned" if the child happens
        // to be a positioned widget and the layout is "stack" (see positioned_view.dart)
        if (view is! PositionedView)
        {
          view = LayoutBoxChildData(child: view!, model: model);
        }

        if (view != null) views.add(view);
      }
    }

    // add the static child
    if (child != null)
    {
      var view = child;
      if (view is! PositionedView)
      {
         view = LayoutBoxChildData(child: child!, model: this);
      }
      views.add(view!);
    }

    return views;
  }
  
  @override
  Future<bool?> execute(String caller, String propertyOrFunction, List<dynamic> arguments) async
  {
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();
    switch (function)
    {
      case "open" :

        var view = findListenerOfExactType(ModalViewState);
        if (view == null)
        {
          // modal width
          if (arguments.isNotEmpty) width = S.toStr(arguments[0]);

          // modal height
          if (arguments.length > 1) height = S.toStr(arguments[1]);

          // resizeable
          if (arguments.length > 2) resizeable = S.toBool(arguments[2]) ?? true;

          // closeable
          if (arguments.length > 3) closeable = S.toBool(arguments[3]) ?? true;

          // draggable
          if (arguments.length > 4) draggable = S.toBool(arguments[4]) ?? true;

          // modal
          if (arguments.length > 5) modal = S.toBool(arguments[5]) ?? true;

          view = ModalView(this);
        }
        open(view);
        return true;

      case "close" :
        close();
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  void open(ModalView view)
  {
    ModalManagerView? manager = context?.findAncestorWidgetOfExactType<ModalManagerView>();
    if (manager != null)
    {
      manager.model.modals.add(view);
      manager.model.refresh();
    }
  }

  void close()
  {
    var view = findListenerOfExactType(ModalViewState);
    if (view != null)
    {
      view!.onClose();
      ModalManagerView? manager = context?.findAncestorWidgetOfExactType<ModalManagerView>();
      if (manager != null) manager.model.refresh();
    }
  }

  void dismiss()
  {
    var view = findListenerOfExactType(ModalViewState);
    if (view != null) view!.onDismiss();
  }

  /// Returns the [MODAL] View
  @override
  Widget getView({Key? key}) => getReactiveView(ModalView(this));
}