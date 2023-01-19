// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';

import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/splitview/split_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class SplitModel extends DecoratedWidgetModel implements IViewableWidget
{
  List<List<IViewableWidget>> views = [];

  ////////////
  /* ratio */
  ////////////
  DoubleObservable? _ratio;
  set ratio (dynamic v)
  {
    if (_ratio != null)
    {
      _ratio!.set(v);
    }
    else if (v != null)
    {
      _ratio = DoubleObservable(null, v, scope: scope);
    }
  }
  double get ratio => _ratio?.get() ?? 0.5;

  SplitModel(WidgetModel parent, String? id,
  {
    dynamic width,
  }) : super(parent, id)
  {
    this.width = width;
  }

  @override
  dispose()
  {
    super.dispose();
  }

  static SplitModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    SplitModel? model;
    try
    {
      model = SplitModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'form.Model');
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
    ratio = Xml.get(node: xml, tag: 'ratio');

    ///////////
    /* Views */
    ///////////
    views.clear();
    Iterable<XmlElement> oView = xml.findElements("VIEW", namespace: "*");
      oView.forEach((oView)
    {
      List<IViewableWidget> children = [];
      oView.children.forEach((node)
      {
        if (node.nodeType == XmlNodeType.ELEMENT)
        {
          dynamic child = WidgetModel.fromXml(this, node as XmlElement);
          if (child != null) children.add(child);
        }
      });
      views.add(children);
    });
  }

  Widget getView({Key? key}) => SplitView(this);
}


