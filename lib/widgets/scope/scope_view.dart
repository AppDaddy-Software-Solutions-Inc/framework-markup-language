// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/scope/scope_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class ScopeView extends StatefulWidget implements IWidgetView
{
  final List<Widget> children = [];
  final ScopeModel model;
  ScopeView(this.model) : super(key: ObjectKey(model));

  @override
  _ScopeViewState createState() => _ScopeViewState();
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

    //////////
    /* View */
    ///////////
    return children.length == 1 ? children[0] : Column(children: children, mainAxisSize: MainAxisSize.min);
  }
}
