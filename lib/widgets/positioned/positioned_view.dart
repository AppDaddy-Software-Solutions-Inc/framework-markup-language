// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_layout.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/stack/stack_model.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'positioned_model.dart';

class PositionedView extends StatefulWidget implements ViewableWidgetView {
  final List<Widget> children = [];

  @override
  final PositionedModel model;
  PositionedView(this.model) : super(key: ObjectKey(model));

  @override
  State<PositionedView> createState() => _PositionedViewState();
}

class _PositionedViewState extends ViewableWidgetState<PositionedView> {

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints) {

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    // build the child views
    List<Widget> children = widget.model.inflate();
    if (children.isEmpty) children.add(Container());

    var view = children.length == 1 ? children[0] : Column(children: children);
    view = BoxLayout(model: widget.model, child: view);

    return view;
  }
}
