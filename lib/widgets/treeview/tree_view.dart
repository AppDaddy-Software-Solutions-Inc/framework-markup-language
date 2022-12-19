// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/event/event.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/widgets/treeview/tree_model.dart';
import 'package:fml/widgets/treeview/node/tree_node_view.dart';
import 'package:fml/widgets/widget/widget_model.dart';

class TreeView extends StatefulWidget
{
  final TreeModel model;
  TreeView(this.model) : super(key: ObjectKey(model));

  @override
  _TreeViewState createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> implements IModelListener
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
    // register event listeners
    EventManager.of(widget.model)?.registerEventListener(EventTypes.focusnode, widget.model.onFocus);

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(TreeView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.model != widget.model))
    {
      // remove old event listeners
      EventManager.of(oldWidget.model)?.registerEventListener(EventTypes.focusnode, widget.model.onFocus);

      // register new event listeners
      EventManager.of(widget.model)?.registerEventListener(EventTypes.focusnode, widget.model.onFocus);

      // remove old model listener
      oldWidget.model.removeListener(this);

      // register new model listener
      widget.model.registerListener(this);
    }
  }

  @override
  void dispose()
  {
    // remove model listener
    widget.model.removeListener(this);

    // remove event listeners
    EventManager.of(widget.model)?.removeEventListener(EventTypes.focusnode, widget.model.onFocus);

    super.dispose();
  }

  /// Callback to fire the [_TreeViewState.build] when the [TreeModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value})
  {
    if (this.mounted) setState((){});
  }

  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // View
    return ClipRect(child:ListView.builder(padding: EdgeInsets.zero, itemCount: widget.model.nodes.length, itemBuilder: (context, index) => TreeNodeView(widget.model.nodes[index])));
  }
}