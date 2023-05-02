// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/event/handler.dart' ;
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/draggable/draggable_model.dart';
import 'package:fml/widgets/droppable/droppable_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class DroppableModel extends DecoratedWidgetModel 
{
  List<String>? accept;

  /////////////
  /* ondrop */
  /////////////
  StringObservable? _ondrop;
  set ondrop (dynamic v)
  {
    if (_ondrop != null)
    {
      _ondrop!.set(v);
    }
    else if (v != null)
    {
      _ondrop = StringObservable(Binding.toKey(id, 'ondrop'), v, scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }
  String? get ondrop => _ondrop?.get();

  DroppableModel(WidgetModel parent, String?  id, {dynamic ondrop, dynamic accept}) : super(parent, id)
  {
    this.ondrop = ondrop;
    this.accept = accept;
  }

  static DroppableModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    DroppableModel? model;
    try
    {
// build model
      model = DroppableModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'droppable.Model');
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
    accept = Xml.attribute(node: xml, tag: 'accept')?.split(',');
    ondrop = Xml.get(node: xml, tag: 'ondrop');
  }

  bool willAccept(String? id)
  {
    if ((accept != null) && (accept!.contains(id))) return true;
    return false;
  }

  Future<bool> onDrop(BuildContext context, DraggableModel draggable) async
  {
      bool ok = true;

      EventHandler e = EventHandler(this);

      //////////////////////
      /* Fire Drop Events */
      //////////////////////
      if ((ok) && (!S.isNullOrEmpty(ondrop))) ok = await e.execute(_ondrop);

      //////////////////////
      /* Fire Drag Events */
      //////////////////////
      // requires fix
      //if ((ok) && (draggable != null) && (!S.isNullOrEmpty(draggable.ondrop))) ok = await e.execute(draggable.ondrop);

      return ok;
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  Widget getView({Key? key}) => getReactiveView(DroppableView(this));
}