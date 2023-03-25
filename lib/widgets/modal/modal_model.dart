// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/navigation/navigation_manager.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/widgets/overlay/overlay_view.dart';
import 'modal_view.dart';

class ModalModel extends DecoratedWidgetModel
{
  OverlayView? overlay;
  Size? proxysize;

  ModalModel(WidgetModel parent, String?  id,
  {
    dynamic title,
  }) : super(parent, id)
  {
    this.title = title;
  }

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
  void deserialize(XmlElement xml)
  {

    // deserialize 
    super.deserialize(xml);

    // properties
    title       = Xml.get(node: xml, tag: 'title');
    resizeable  = Xml.get(node: xml, tag: 'resizeable');
    closeable   = Xml.get(node: xml, tag: 'closable');
    draggable   = Xml.get(node: xml, tag: 'draggable');
    modal       = Xml.get(node: xml, tag: 'modal');
  }
  
  @override
  Future<bool?> execute(String caller, String propertyOrFunction, List<dynamic> arguments) async
  {
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();
    switch (function)
    {
      case "open" :
        
        // modal width
        String? width = arguments.length > 0 ? S.toStr(arguments[0]) : null;
        if (width == null) width = (pctWidth != null) ? "$pctWidth%" : "${this.width}";

        // modal height
        String? height = arguments.length > 1 ? S.toStr(arguments[1]) : null;
        if (height == null) height = (pctHeight != null) ? "$pctHeight%" : "${this.height}";

        // resizeable
        bool resizeable = this.resizeable;
        if (arguments.length > 2) resizeable = S.toBool(arguments[2]) ?? true;

        // closeable
        bool closeable = this.closeable;
        if (arguments.length > 3) closeable = S.toBool(arguments[3]) ?? true;

        // draggable
        bool draggable = this.draggable;
        if (arguments.length > 4) draggable = S.toBool(arguments[4]) ?? true;

        // modal
        bool modal = this.modal;
        if (arguments.length > 5) modal = S.toBool(arguments[5]) ?? true;

        overlay = NavigationManager().openModal(ModalView(this), context, modal: modal, resizeable: resizeable, closeable: closeable, draggable: draggable, width: width, height: height);
        return true;

      case "close" :
        NavigationManager().closeModal(overlay, context);
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  /// Returns the [MODAL] View
  Widget getView({Key? key}) => getReactiveView(ModalView(this));
}