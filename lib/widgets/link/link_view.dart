// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/widget/widget_state.dart';
import 'link_model.dart';

class LinkView extends StatefulWidget implements IWidgetView
{
  final LinkModel model;
  LinkView(this.model) : super(key: ObjectKey(model));

  @override
  _LinkViewState createState() => _LinkViewState();
}

class _LinkViewState extends WidgetState<LinkView>
{
  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

// build children
    List<Widget> children = [];
    if (widget.model.children != null)
    widget.model.children!.forEach((model)
    {
      if (model is IViewableWidget) {
        children.add((model as IViewableWidget).getView());
      }
    });

    Widget child = children.length == 1 ? children[0] : Column(children: children, mainAxisSize: MainAxisSize.min);
    return (widget.model.enabled == false) ? child : GestureDetector(onTap: onTap, onLongPress: onLongPress, onDoubleTap: onDoubleTap, child: MouseRegion(cursor: SystemMouseCursors.click, child: child));
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
}
