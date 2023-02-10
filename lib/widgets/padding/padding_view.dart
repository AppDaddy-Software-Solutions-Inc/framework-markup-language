// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';

import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'padding_model.dart';

class PaddingView extends StatefulWidget {
  final PaddingModel model;

  PaddingView(this.model) : super(key: ObjectKey(model));

  @override
  _PaddingViewState createState() => _PaddingViewState();
}

class _PaddingViewState extends State<PaddingView> implements IModelListener {
  @override
  void initState() {
    super.initState();

    
    widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    widget.model.initialize();
  }

  @override
  void didUpdateWidget(PaddingView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.model != widget.model)
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

  /// Callback to fire the [_PaddingViewState.build] when the [PaddingModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value}) {
    if (this.mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
return LayoutBuilder(builder: builder);
  }

  Widget builder(BuildContext context, BoxConstraints constraints) 
  {
    int defaultVal = 2;
    int pTop = defaultVal;
    int pBottom = defaultVal;
    int pLeft = defaultVal;
    int pRight = defaultVal;

    pTop = widget.model.top ?? widget.model.vertical ?? widget.model.all ?? defaultVal;
    pBottom = widget.model.bottom ?? widget.model.vertical ?? widget.model.all ?? defaultVal;
    pLeft = widget.model.left ?? widget.model.horizontal ?? widget.model.all ?? defaultVal;
    pRight = widget.model.right ?? widget.model.horizontal ?? widget.model.all ?? defaultVal;

    // Set Build Constraints in the [WidgetModel]
    widget.model.minWidth = constraints.minWidth + pLeft + pRight;
    widget.model.maxWidth = constraints.maxWidth - pLeft - pRight;
    widget.model.minHeight = constraints.minHeight + pTop + pBottom;
    widget.model.maxHeight = constraints.maxHeight - pTop - pBottom;

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

    if (children.isEmpty) return Container(width: pLeft.toDouble() + pRight.toDouble()-2, height: pTop.toDouble() + pBottom.toDouble()-2,);

    //////////
    /* View */
    //////////
    Widget view;
      view = children.length == 1
      ? children[0]
      : Column(   // should probably have a layout and alignment for padding like box? Also consider padding each child individually?
          children: children,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start);
        view = Padding( padding: EdgeInsets.only(
                  top: pTop.toDouble(),
                  bottom: pBottom.toDouble(),
                  left: pLeft.toDouble(),
                  right: pRight.toDouble()), child: view);
    return view;
  }
}
