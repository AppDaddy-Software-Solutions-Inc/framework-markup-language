// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/observable/scope.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/widgets/scope/scope_view.dart';
import 'package:fml/helper/common_helpers.dart';

class ScopeModel extends DecoratedWidgetModel 
{
  ScopeModel(WidgetModel parent, String? id) : super(parent, id, scope: Scope(id: id, parent: parent.scope));

  static ScopeModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    ScopeModel? model;
    try
    {
      model = ScopeModel(parent, Xml.get(node: xml, tag: 'id'));
    }
    catch(e)
    {
      Log().exception(e,  caller: 'scope.Model');
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
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  Widget getView({Key? key}) => ScopeView(this);
}
