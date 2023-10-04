// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/scope.dart';
import 'package:fml/widgets/scope/scope_view.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/helper/common_helpers.dart';

class ScopeModel extends ViewableWidgetModel
{
  ScopeModel(WidgetModel parent, String? id, {dynamic data}) : super(parent, id, scope: Scope(id: id, parent: parent.scope))
  {
    this.data = data;
  }

  static ScopeModel? fromXml(WidgetModel parent, XmlElement xml, {dynamic data})
  {
    ScopeModel? model;
    try
    {
      model = ScopeModel(parent, Xml.get(node: xml, tag: 'id'), data: data);
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'scope.Model');
      model = null;
    }
    return model;
  }

  @override
  dispose()
  {
    scope?.dispose();
    super.dispose();
  }

  @override
  Widget getView({Key? key}) => ScopeView(this);
}
