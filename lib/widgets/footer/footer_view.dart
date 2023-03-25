// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';

import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/footer/footer_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class FooterView extends StatefulWidget implements IWidgetView
{
  final List<Widget> children = [];
  final FooterModel model;

  FooterView(this.model) : super(key: ObjectKey(model));

  @override
  _FooterViewState createState() => _FooterViewState();
}

class _FooterViewState extends WidgetState<FooterView>
{
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // save system constraints
    widget.model.setConstraints(constraints);

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
