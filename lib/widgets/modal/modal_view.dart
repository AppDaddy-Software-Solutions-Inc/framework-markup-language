// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/modal/modal_model.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class ModalView extends StatefulWidget implements IWidgetView
{
  @override
  final ModalModel model;

  ModalView(this.model) : super(key: ObjectKey(model));

  @override
  State<ModalView> createState() => _ModalViewState();
}

class _ModalViewState extends WidgetState<ModalView>
{
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // single column layout
    Widget view = BoxView(widget.model);

    // view
    //view = SingleChildScrollView(child: view, scrollDirection: Axis.vertical);

    // apply user defined constraints
    //view = applyConstraints(view, widget.model.constraints);

    return Material(child: view);
  }
}
