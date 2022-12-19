// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/draggable/draggable_model.dart';

import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/services.dart';

class DraggableView extends StatefulWidget
{
  final DraggableModel model;
  DraggableView(this.model) : super(key: ObjectKey(model));

  @override
  _DraggableViewState createState() => _DraggableViewState();
}


class _DraggableViewState extends State<DraggableView> implements IModelListener
{
  bool dragging = false;
  SystemMouseCursor cursor = SystemMouseCursors.grab;
  @override
  void initState()
  {
    super.initState();

    
    widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    widget.model.initialize();

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
    
    if ((oldWidget.model != widget.model))
    {
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }

    dragging = false;

  }
  
  @override
  void dispose()
  {
    widget.model.removeListener(this);

    super.dispose();
  }
  /// Callback function for when the model changes, used to force a rebuild with setState()
  onModelChange(WidgetModel model,{String? property, dynamic value})
  {
    if (this.mounted) setState((){});
  }

  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    ////////////////////
    /* Build Children */
    ////////////////////
    List<Widget> children = [];
    if (widget.model.children != null)
    widget.model.children!.forEach((model)
    {
      if (model is IViewableWidget) {
        children.add((model as IViewableWidget).getView());
      }
    });
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
