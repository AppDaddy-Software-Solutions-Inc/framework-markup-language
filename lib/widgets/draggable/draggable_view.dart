// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/draggable/draggable_model.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:flutter/services.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class DraggableView extends StatefulWidget implements IWidgetView
{
  final DraggableModel model;
  DraggableView(this.model) : super(key: ObjectKey(model));

  @override
  _DraggableViewState createState() => _DraggableViewState();
}


class _DraggableViewState extends WidgetState<DraggableView>
{
  bool dragging = false;
  SystemMouseCursor cursor = SystemMouseCursors.grab;

  @override
  void initState()
  {
    super.initState();
    dragging = false;
  }

  @override
  didChangeDependencies()
  {
    dragging = false;
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(DraggableView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    dragging = false;
  }
  
  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // build the child views
    List<Widget> children = widget.model.inflate();
    if (children.isEmpty) children.add(Container());

    return MouseRegion(cursor: cursor, child: Draggable(child: Stack(children: children), feedback: Transform.rotate(angle: -0.07, child: Card(elevation: 20, color: Colors.transparent, child: Stack(children: children))), childWhenDragging: Container(), data: widget.model, onDragCompleted: onDragCompleted, onDragStarted: () { setState(() => cursor = SystemMouseCursors.grabbing); widget.model.onDrag(context); }, onDragEnd: (_) => setState(() => cursor = SystemMouseCursors.grab),));
  }

  void onDragCompleted()
  {
    setState(()
    {
      dragging = false;
    });
  }
}
