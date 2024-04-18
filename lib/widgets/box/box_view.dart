// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/box/box_view_state.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';

/// [BOX] view
class BoxView extends StatefulWidget implements IWidgetView {
  @override
  final BoxModel model;
  final List<Widget>? children;

  BoxView(this.model, {this.children}) : super(key: ObjectKey(model));

  @override
  State<BoxView> createState() => BoxViewState();
}

class BoxViewState extends BoxViewWidgetState<BoxView> {
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints) {

    // build the box
    var view = buildBox(constraints, widget.model, children: widget.children);

    return view;
  }
}
