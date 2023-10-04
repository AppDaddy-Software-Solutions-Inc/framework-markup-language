// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/scope/scope_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class ScopeView extends StatefulWidget implements IWidgetView
{
  final List<Widget> children = [];
  @override
  final ScopeModel model;
  ScopeView(this.model) : super(key: ObjectKey(model));

  @override
  State<ScopeView> createState() => _ScopeViewState();
}

class _ScopeViewState extends WidgetState<ScopeView>
{
  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // build the child views
    List<Widget> children = widget.model.inflate();
    if (children.isEmpty) children.add(Container());

    // view
    var view = children.length == 1 ? children[0] : Column(children: children, mainAxisSize: MainAxisSize.min);

    return view;
  }
}
