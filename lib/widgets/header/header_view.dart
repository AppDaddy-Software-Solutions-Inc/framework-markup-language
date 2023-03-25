// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/header/header_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class HeaderView extends StatefulWidget implements IWidgetView
{
  final List<Widget> children = [];
  final HeaderModel model;

  HeaderView(this.model) : super(key: ObjectKey(model));

  @override
  _HeaderViewState createState() => _HeaderViewState();
}

class _HeaderViewState extends WidgetState<HeaderView>
{
  @override
  Widget build(BuildContext context) =>  LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // save system constraints
    widget.model.setSystemConstraints(constraints);

    // Check if widget is visible before wasting resources on building it
    if (widget.model.visible == false) return Offstage();

    ///////////
    /* Child */
    ///////////
    List<Widget> children = [];
    children.add(Container(constraints: BoxConstraints.expand(), color: widget.model.color ?? Theme.of(context).colorScheme.primary));
    if (widget.model.children != null)
    widget.model.children!.forEach((model)
    {
      if (model is IViewableWidget) {
        children.add((model as IViewableWidget).getView());
      }
    });

    if (children.isEmpty) children.add(Container());

    //////////
    /* View */
    //////////
    Widget view = Stack(fit: StackFit.loose, children: children);

    return view;
  }
}
