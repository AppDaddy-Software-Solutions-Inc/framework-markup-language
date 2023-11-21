// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class DroppableView extends StatefulWidget implements IWidgetView
{
  @override
  final ViewableWidgetModel model;
  final Widget view;

  DroppableView(this.model, this.view) : super(key: ObjectKey(model));

  @override
  State<DroppableView> createState() => _DroppableViewState();
}


class _DroppableViewState extends WidgetState<DroppableView>
{
  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    return DragTarget(onWillAccept: onWillAccept, onAccept: onAccept, builder: onBuild);
  }

  bool onWillAccept(ViewableWidgetModel? draggable)
  {
    if (draggable == null) return false;
    return ViewableWidgetModel.willAccept(widget.model, draggable.id);
  }

  Future<bool> onAccept(ViewableWidgetModel draggable) async
  {
    draggable.busy = true;

    bool ok = await ViewableWidgetModel.onDrop(context, widget.model, draggable);
    setState(() {});

    return ok;
  }

  Widget onBuild(context, List<dynamic> cd, List<dynamic> rd) => widget.view;
}
