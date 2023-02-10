// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'positioned_model.dart';

class PositionedView extends StatefulWidget {
  final List<Widget> children = [];
  final PositionedModel model;
  PositionedView(this.model) : super(key: ObjectKey(model));

  @override
  _PositionedViewState createState() => _PositionedViewState();
}

class _PositionedViewState extends State<PositionedView>
    implements IModelListener {
  @override
  void initState() {
    super.initState();

    
    widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    widget.model.initialize();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(PositionedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.model != widget.model) {
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }
  }

  @override
  void dispose() {
    widget.model.removeListener(this);

    super.dispose();
  }

  /// Callback to fire the [_PositionedViewState.build] when the [PositionedModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value}) {
    if (this.mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }

  Widget builder(BuildContext context, BoxConstraints? constraints) {
    // Set Build Constraints in the [WidgetModel]
    widget.model.minWidth = constraints?.minWidth;
    widget.model.maxWidth = constraints?.maxWidth;
    widget.model.minHeight = constraints?.minHeight;
    widget.model.maxHeight = constraints?.maxHeight;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    //////////////////
    /* Add Children */
    //////////////////
    List<Widget> children = [];
    if (widget.model.children != null)
      widget.model.children!.forEach((model) {
        if (model is IViewableWidget) {
          children.add((model as IViewableWidget).getView());
        }
      });
    if (children.isEmpty) children.add(Container());
    var child = children.length == 1 ? children[0] : Column(children: children);

    ////////////////////////////
    /* Parent Must be a Stack */
    ////////////////////////////
    if (widget.model.xoffset != null && widget.model.yoffset != null) {
      double fromTop = (widget.model.maxHeight! / 2) + widget.model.yoffset!;
      double fromLeft = (widget.model.maxWidth! / 2) + widget.model.xoffset!;
      return Positioned(top: fromTop, left: fromLeft, child: child);
    } else
      return Positioned(
          top: widget.model.top,
          bottom: widget.model.bottom,
          left: widget.model.left,
          right: widget.model.right,
          child: child);
  }
}
