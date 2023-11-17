// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:fml/widgets/droppable/droppable_model.dart';
import 'package:fml/widgets/variable/variable_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/event/handler.dart' ;
import 'package:fml/widgets/draggable/draggable_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class DraggableModel extends DecoratedWidgetModel 
{
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

  // ondrag
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
    DraggableModel? model = DraggableModel(parent, Xml.get(node: xml, tag: 'id'));
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
    ondrag = Xml.get(node: xml, tag: 'ondrag');
    ondrop = Xml.get(node: xml, tag: 'ondrop');
  }

  // on drag event
  Future<bool> onDrag(BuildContext context) async => await EventHandler(this).execute(_ondrag);

  // on drop event
  Future<bool> onDrop(BuildContext context, DroppableModel droppable) async
  {
    // set my drag variables from droppable
    var dragVariables = variables;
    var dropVariables = droppable.variables;
    var dragValues    = <VariableModel, dynamic>{};
    for (var dropVariable in dropVariables)
    {
      var dragVariable = dragVariables.firstWhereOrNull((dragVariable) => dragVariable.id == dropVariable.id);
      if (dragVariable != null)
      {
        // save old values
        dragValues[dragVariable] = dragVariable.value;

        // set new value
        dragVariable.value = dropVariable.value;
      }
    }

    // fire ondrop event
    bool ok = await EventHandler(this).execute(_ondrop);

    // restore old value
    if (!ok)
    {
      dragValues.forEach((dragVariable, oldValue) => dragVariable.value = oldValue);
    }

    return ok;
  }

  @override
  Widget getView({Key? key}) => getReactiveView(DraggableView(this));
}