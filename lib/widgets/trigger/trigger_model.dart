// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/event/handler.dart' ;
import 'package:fml/widgets/trigger/condition/trigger_condition_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/helper/common_helpers.dart';

class TriggerModel extends WidgetModel {

  String? type = 'multi';
  final List<TriggerConditionModel> cases = [];

  TriggerModel(WidgetModel parent, {String? id, dynamic type}) : super(parent, id){
    this.type = type;
  }

  static TriggerModel? fromXml(WidgetModel parent, XmlElement e)
  {
    String? id = Xml.get(node: e, tag: 'id');
    if (S.isNullOrEmpty(id))
    {
      Log().warning('<TRIGGER> missing required id');
      id = S.newId();
    }

    TriggerModel trigger = TriggerModel
      (
      parent,
      id : id,
      type : Xml.get(node: e, tag: 'type'),
    );

    trigger.deserialize(e);

    return trigger;
  }

  void deserialize(XmlElement e)
  {
    /////////////////
    /* Deserialize */
    /////////////////
    super.deserialize(e);

    ///////////
    /* Cases */
    ///////////
    this.cases.clear();
    List<TriggerConditionModel> conditions = findChildrenOfExactType(TriggerConditionModel).cast<TriggerConditionModel>();
    conditions.forEach((condition) => this.cases.add(condition));
  }

  Future<bool> trigger() async
  {
    for (int i = 0; i < cases.length; i++)
    {
      if (cases[i].when != null && cases[i].call != null)
      {
        if (S.toBool(cases[i].when) == true)
        {
          await EventHandler(this).execute(cases[i].callObservable);
          if (type == 'single')
          {
            i = cases.length;
            return true;
          }
        }
      }
    }
    return true;
  }

  Future<bool?> execute(String caller, String propertyOrFunction, List<dynamic> arguments) async
  {
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();
    switch (function)
    {
      case 'trigger':
        return await trigger();
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }
}