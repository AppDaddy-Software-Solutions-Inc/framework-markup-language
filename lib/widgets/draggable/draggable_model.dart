// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';

import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/event/handler.dart' ;
import 'package:fml/widgets/draggable/draggable_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/helper_barrel.dart';

class DraggableModel extends DecoratedWidgetModel implements IViewableWidget
{
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

  /////////////
  /* ondrag */
  /////////////
  StringObservable? _ondrag;
  set ondrag (dynamic v)
  {
    if (_ondrag != null)
    {
      _ondrag!.set(v);
    }
    else if (v != null)
    {
      _ondrag = StringObservable(Binding.toKey(id, 'ondrag'), v, scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }
  String? get ondrag => _ondrag?.get();

  DraggableModel(WidgetModel parent, String?  id, {dynamic ondrop}) : super(parent, id)
  {
    this.ondrop = ondrop;
  }

  static DraggableModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    DraggableModel? model;
    try
    {
      /////////////////
      /* Build Model */
      /////////////////
      model = DraggableModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().debug(e.toString());
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
    ondrag = Xml.get(node: xml, tag: 'ondrag');
    ondrop = Xml.get(node: xml, tag: 'ondrop');
  }

  @override
  dispose()
  {
    Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  Future<bool> onDrag(BuildContext context) async
  {
    bool ok = true;

    EventHandler e = EventHandler(this);

    //////////////////////
    /* Fire Drag Events */
    //////////////////////
    if ((ok) && (!S.isNullOrEmpty(ondrag))) ok = await e.execute(_ondrag);

    return ok;
  }

  Widget getView({Key? key}) => DraggableView(this);
}