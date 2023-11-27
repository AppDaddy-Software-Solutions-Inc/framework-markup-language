import 'package:flutter/rendering.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/dragdrop/drag_drop_interface.dart';
import 'package:fml/widgets/widget/widget_model.dart';

class DragDrop
{
  static bool willAccept(IDragDrop droppable, IDragDrop draggable)
  {
    // accept is not defined
    if (isNullOrEmpty(droppable.accept)) return true;

    // accept is defined and contains the drop id
    if (droppable.accept!.contains(draggable.id))  return true;

    // do not accept this drop
    return false;
  }

  static Future<bool> onDrop(IDragDrop droppable, IDragDrop draggable, {RenderBox? dragBox, RenderBox? dropBox, Offset? dropSpot}) async
  {
    bool ok = true;

    // same object dropped on itself
    if (draggable == droppable) return ok;

    // original data
    var original = droppable.drop;

    // set drop data
    droppable.drop = draggable.data;

    // fire onDrop event of the droppable
    if (ok)
    {
      // expression
      var expression = droppable.onDropObservable?.signature ?? droppable.onDropObservable?.value;

      // bindings
      var bindings = draggable.onDropObservable?.bindings;

      // variables
      var variables = EventHandler.getVariables(bindings, droppable as WidgetModel, draggable as WidgetModel, localAliasNames: ['this','drop'], remoteAliasNames: ['drag']);

      // execute event
      ok = await EventHandler(droppable as WidgetModel).executeExpression(expression, variables);
    }

    // fire onDropped event of the draggable
    if (ok)
    {
      // expression
      var expression = draggable.onDroppedObservable?.signature ?? draggable.onDroppedObservable?.value;

      // bindings
      var bindings = draggable.onDroppedObservable?.bindings;

      // variables
      var variables = EventHandler.getVariables(bindings, draggable as WidgetModel, droppable as WidgetModel, localAliasNames: ['this','drag'], remoteAliasNames: ['drop']);

      // execute event
      ok = await EventHandler(draggable as WidgetModel).executeExpression(expression, variables);
    }

    // undo data
    if (!ok) droppable.drop = original;

    return ok;
  }

  static Map<String, dynamic> getSourceTargetVariables(WidgetModel source, WidgetModel target, List<String> sourceAliasNames, List<String> targetAliasNames, List<Binding>? bindings)
  {
    var variables = <String, dynamic>{};

    // get variables
    bindings?.forEach((binding)
    {
      var key   = binding.key;
      var scope = source.scope;
      var name  = binding.source.toLowerCase();

      var i = sourceAliasNames.indexOf(name);
      if (i >= 0)
      {
        key = key?.replaceFirst(sourceAliasNames[i], source.id);
        scope = source.scope;
      }

      i = targetAliasNames.indexOf(name);
      if (i >= 0)
      {
        key = key?.replaceFirst(targetAliasNames[i], target.id);
        scope = target.scope;
      }

      // find the observable
      var observable = System.app?.scopeManager.findObservable(scope, key);

      // add to the list
      variables[binding.toString()] = observable?.get();
    });

    return variables;
  }

  // on drag event
  static Future<bool> onDrag(IDragDrop draggable) async 
  {
    return await EventHandler(draggable as WidgetModel).execute(draggable.onDragObservable);
  }

  // given 2 objects, returns the +/- offset from center expressed as a percentage
  static Offset? getPercentOffset(RenderBox? droppedOn, Offset? droppedAt)
  {
    if (droppedOn == null || droppedAt == null) return null;

    final offset = droppedOn.localToGlobal(Offset.zero);

    final center = Offset(droppedOn.size.width/2 + offset.dx, droppedOn.size.height/2 + offset.dy);

    // dx is +/- percent offset from center
    // dx = offset (droppedAt) - offset (center) / (width (droppedOn) / 2)
    final dx = ((droppedAt.dx - center.dx) / (droppedOn.size.width / 2)) * 100;

    // dy is +/- percent offset from center
    // dy = offset (droppedAt) - offset (center) / (width (droppedOn) / 2)
    final dy = ((droppedAt.dy - center.dy) / (droppedOn.size.height / 2)) * 100;

    return Offset(dx, dy);
  }
}