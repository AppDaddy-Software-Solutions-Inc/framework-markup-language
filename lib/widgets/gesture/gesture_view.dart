// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';

import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'gesture_model.dart' as LINK;

class GestureView extends StatefulWidget
{
  final LINK.GestureModel model;
  GestureView(this.model) : super(key: ObjectKey(model));

  @override
  _GestureViewState createState() => _GestureViewState();
}

class _GestureViewState extends State<GestureView> implements IModelListener
{
  @override
  void initState()
  {
    super.initState();

    
   widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    widget.model.initialize();
  }

  @override
  didChangeDependencies()
  {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(GestureView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    
    if ((oldWidget.model != widget.model))
    {
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }

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

    //////////////////
    /* Add Children */
    //////////////////
    List<Widget> children = [];
    if (widget.model.children != null)
      widget.model.children!.forEach((model)
      {
        if (model is IViewableWidget) {
          children.add((model as IViewableWidget).getView());
        }
      });

    Widget child = children.length == 1 ? children[0] : Column(children: children, mainAxisSize: MainAxisSize.min);

    Offset? dragStart;
    Offset? dragEnd;

    return (widget.model.enabled == false) ? child : GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        onDoubleTap: onDoubleTap,
        onHorizontalDragStart: (DragStartDetails d)   => dragStart  = d.globalPosition,
        onHorizontalDragUpdate: (DragUpdateDetails d) => dragEnd = d.globalPosition,
        onHorizontalDragEnd: (DragEndDetails d) => (dragStart?.dx ?? 0) - (dragEnd?.dx ?? 0) > 0 ? onSwipeLeft() : onSwipeRight(),
        onVerticalDragStart: (DragStartDetails d) => dragStart = d.globalPosition,
        onVerticalDragUpdate: (DragUpdateDetails d) => dragEnd = d.globalPosition,
        onVerticalDragEnd: (DragEndDetails d) => (dragStart?.dy ?? 0) - (dragEnd?.dy ?? 0) > 0 ? onSwipeUp() : onSwipeDown(),
        onSecondaryTap: onRightClick,
        child: MouseRegion(cursor: SystemMouseCursors.click, child: child));
  }

  onTap() async
  {
    WidgetModel.unfocus();
    await widget.model.onClick(context);
  }

  onDoubleTap() async
  {
    WidgetModel.unfocus();
    await widget.model.onDoubleTap(context);
  }

  onLongPress() async
  {
    WidgetModel.unfocus();
    await widget.model.onLongPress(context);
  }

  onSwipeLeft() async
  {
    WidgetModel.unfocus();
    await widget.model.onSwipeLeft(context);
  }

  onSwipeRight() async
  {
    WidgetModel.unfocus();
    await widget.model.onSwipeRight(context);
  }

  onSwipeUp() async
  {
    WidgetModel.unfocus();
    await widget.model.onSwipeUp(context);
  }

  onSwipeDown() async
  {
    WidgetModel.unfocus();
    await widget.model.onSwipeDown(context);
  }

  onRightClick() async
  {
    WidgetModel.unfocus();
    await widget.model.onRightClick(context);
  }
}
