// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/widget/widget_state.dart';
import 'link_model.dart';

class LinkView extends StatefulWidget implements IWidgetView
{
  @override
  final LinkModel model;
  LinkView(this.model) : super(key: ObjectKey(model));

  @override
  State<LinkView> createState() => _LinkViewState();
}

class _LinkViewState extends WidgetState<LinkView>
{
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

  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // column view
    Widget view = BoxView(widget.model);

    // wrap in gesture detector
    if (widget.model.enabled) view = GestureDetector(onTap: onTap, onLongPress: onLongPress, onDoubleTap: onDoubleTap, child: MouseRegion(cursor: SystemMouseCursors.click, child: view));

    // build the child views
    return view;
  }
}
