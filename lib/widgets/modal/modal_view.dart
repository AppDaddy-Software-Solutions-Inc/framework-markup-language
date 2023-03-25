// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/modal/modal_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class ModalView extends StatefulWidget implements IWidgetView
{
  final ModalModel model;

  ModalView(this.model) : super(key: ObjectKey(model));

  @override
  _ModalViewState createState() => _ModalViewState();
}

class _ModalViewState extends WidgetState<ModalView>
{
  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    ///////////
    /* Child */
    ///////////
    List<Widget> children = [];
    if (widget.model.children != null)
      widget.model.children!.forEach((model)
      {
        if (model is IViewableWidget) {
          children.add((model as IViewableWidget).getView());
        }
      });
    if (children.isEmpty) children.add(Container());
    Widget child = children.length == 1 ? children[0] : Column(children: children, crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min);

    //////////
    /* View */
    //////////
    Widget view = SingleChildScrollView(child: child, scrollDirection: Axis.vertical);

    // wrap constraints
    return applyUserContraints(view);
  }
}
