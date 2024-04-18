// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/box/box_view_state.dart';
import 'package:fml/widgets/widget/viewable_widget_view.dart';

/// [BOX] view
class BoxView extends StatefulWidget implements ViewableWidgetView {
  @override
  final BoxModel model;
  final List<Widget>? children;

  BoxView(this.model, {this.children}) : super(key: ObjectKey(model));

  @override
  State<BoxView> createState() => BoxViewState();
}

class BoxViewState extends BoxViewWidgetState<BoxView> {

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (_,constraints) =>
      buildBox(constraints, widget.model, children: widget.children));
}
