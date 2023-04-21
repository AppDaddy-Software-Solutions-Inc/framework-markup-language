// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/column/column_view.dart';
import 'package:fml/widgets/modal/modal_model.dart';
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

    // single column layout
    Widget view = BoxView(widget.model);

    // view
    view = SingleChildScrollView(child: view, scrollDirection: Axis.vertical);

    // apply user defined constraints
    view = applyConstraints(view, widget.model.constraints.model);

    return view;
  }
}
