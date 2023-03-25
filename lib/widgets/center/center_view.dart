// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/center/center_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';

/// Center View
///
/// DEPRECATED
/// Builds a centered Center View from [Model] properties
class CenterView extends StatefulWidget implements IWidgetView
{
  final CenterModel model;
  final List<Widget> children = [];

  CenterView(this.model) : super(key: ObjectKey(model));

  @override
  _CenterViewState createState() => _CenterViewState();
}

class _CenterViewState extends WidgetState<CenterView>
{
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // save system constraints
    widget.model.setSystemConstraints(constraints);

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    widget.children.clear();
    if (widget.model.children != null)
      widget.model.children!.forEach((model)
      {
        if (model is IViewableWidget) {
          widget.children.add((model as IViewableWidget).getView());
        }
      });
    if (widget.children.isEmpty) widget.children.add(Container());

    ////////////
    /* Center */
    ////////////
    dynamic view = Center(child: widget.children.length == 1
      ? widget.children[0]
      : Column(children: widget.children, crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.max));

    // wrap constraints
    return getConstrainedView(view);
  }
}
