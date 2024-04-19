// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/event/event.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/treeview/tree_model.dart';
import 'package:fml/widgets/treeview/node/tree_node_view.dart';
import 'package:fml/widgets/viewable/viewable_widget_view.dart';
import 'package:fml/widgets/viewable/viewable_widget_state.dart';

class TreeView extends StatefulWidget implements ViewableWidgetView {
  @override
  final TreeModel model;
  TreeView(this.model) : super(key: ObjectKey(model));

  @override
  State<TreeView> createState() => _TreeViewState();
}

class _TreeViewState extends ViewableWidgetState<TreeView> {
  @override
  didChangeDependencies() {
    // register event listeners
    EventManager.of(widget.model)
        ?.registerEventListener(EventTypes.focusnode, widget.model.onFocus);

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(TreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.model != widget.model)) {
      // remove old event listeners
      EventManager.of(oldWidget.model)
          ?.registerEventListener(EventTypes.focusnode, widget.model.onFocus);

      // register new event listeners
      EventManager.of(widget.model)
          ?.registerEventListener(EventTypes.focusnode, widget.model.onFocus);
    }
  }

  @override
  void dispose() {
    // remove event listeners
    EventManager.of(widget.model)
        ?.removeEventListener(EventTypes.focusnode, widget.model.onFocus);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    // View
    Widget view = ClipRect(
        child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: widget.model.nodes.length,
            itemBuilder: (context, index) =>
                TreeNodeView(widget.model.nodes[index])));

    // create as Box
    view = BoxView(widget.model, children: [view]);

    return view;
  }
}
