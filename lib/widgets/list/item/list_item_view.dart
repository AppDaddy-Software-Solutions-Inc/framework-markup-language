// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/list/item/list_item_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class ListItemView extends StatefulWidget implements IWidgetView
{
  final ListItemModel model;
  final bool? selectable;

  ListItemView({required this.model, this.selectable}) : super(key: ObjectKey(model));

  @override
  _ListItemViewState createState() => _ListItemViewState();
}

class _ListItemViewState extends WidgetState<ListItemView>
{
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

    if (children.isEmpty) children.add(Container());

    return Container(color: widget.model.backgroundcolor ?? Theme.of(context).colorScheme.surface, child: children.length == 1 ? children[0] : Row(children: children));
  }
}