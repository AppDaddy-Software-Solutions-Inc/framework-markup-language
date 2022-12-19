// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';

import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/widgets/scope/scope_model.dart';

class ScopeView extends StatefulWidget
{
  final List<Widget> children = [];
  final ScopeModel model;
  ScopeView(this.model) : super(key: ObjectKey(model));

  @override
  _ScopeViewState createState() => _ScopeViewState();
}

class _ScopeViewState extends State<ScopeView> implements IModelListener
{
  @override
  void initState()
  {
    super.initState();

    

      widget.model.registerListener(this);
      widget.model.initialize();

  }

  @override
  didChangeDependencies()
  {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(ScopeView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    
    if ((oldWidget.model != widget.model))
    {
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }

  }

  @override
  void dispose()
  {
    widget.model.removeListener(this);

    super.dispose();
  }

  /// Callback to fire the [_ScopeViewState.build] when the [ScopeModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value})
  {
    if (this.mounted) setState((){});
  }

  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    //////////////////
    /* Add Children */
    //////////////////
    List<Widget> children = [];
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
    ///////////
    return children.length == 1 ? children[0] : Column(children: children, mainAxisSize: MainAxisSize.min);
  }
}
