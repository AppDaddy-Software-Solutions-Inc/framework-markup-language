// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/navigation/navigation_manager.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/helper_barrel.dart';
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

  ////////////////
  /* font title */
  ////////////////
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

  static ModalModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    ModalModel? model;
    try
    {
      /////////////////
      /* Build Model */
      /////////////////
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

  @override
  Future<bool?> execute(String propertyOrFunction, List<dynamic> arguments) async
  {
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();
    switch (function)
    {
      case "open" :
        double? width = arguments.length > 0 ? S.toDouble(arguments[0]) : null;
        if (width == null) width = this.width;

        double? height = arguments.length > 1 ? S.toDouble(arguments[1]) : null;
        if (height == null) height = this.height;

        overlay = NavigationManager().openModal(ModalView(this), context, width: S.toStr(width), height: S.toStr(height));
        return true;

      case "close" :
        NavigationManager().closeModal(overlay, context);
        return true;
    }
    return super.execute(propertyOrFunction, arguments);
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {

    // deserialize 
    super.deserialize(xml);

    // properties
    title  = Xml.get(node: xml, tag: 'title');
  }

  /// Returns the [MODAL] View
  Widget getView({Key? key}) => ModalView(this);
}