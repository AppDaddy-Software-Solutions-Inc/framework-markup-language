// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:fml/event/handler.dart' ;
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:fml/widgets/variable/variable_model.dart';
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

  // variables
  List<VariableModel> get variables => findChildrenOfExactType(VariableModel).cast<VariableModel>();

  // ondrop
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

  DroppableModel(WidgetModel parent, String?  id, {dynamic ondrop, this.accept}) : super(parent, id)
  {
    this.ondrop = ondrop;
  }

  static DroppableModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    DroppableModel? model = DroppableModel(parent, Xml.get(node: xml, tag: 'id'));
    model.deserialize(xml);
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

      // set drop variables
      var dropVariables = variables;
      var dragVariables = draggable.variables;
      var dropValues    = <VariableModel, dynamic>{};
      for (var dragVariable in dragVariables)
      {
          var dropVariable = dropVariables.firstWhereOrNull((dropVariable) => dropVariable.id == dragVariable.id);
          if (dropVariable != null)
          {
            // save old values
            dropValues[dropVariable] = dropVariable.value;

            // set new value
            dropVariable.value = dragVariable.value;
          }
      }

      // fire drop event
      if (ok) ok = await EventHandler(this).execute(_ondrop);

      // fire draggables drop event
      if (ok) ok = await draggable.onDrop(context, this);

      // restore old values
      if (!ok)
      {
        dropValues.forEach((dropVariable, oldValue) => dropVariable.value = oldValue);
      }

      return ok;
  }

  @override
  Widget getView({Key? key}) => getReactiveView(DroppableView(this));
}