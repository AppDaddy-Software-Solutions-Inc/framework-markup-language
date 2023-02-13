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

    double pTop = widget.model.top ?? widget.model.vertical ?? widget.model.all ?? 0.0;
    double pBottom = widget.model.bottom ?? widget.model.vertical ?? widget.model.all ?? 0.0;
    double pLeft = widget.model.left ?? widget.model.horizontal ?? widget.model.all ?? 0.0;
    double pRight = widget.model.right ?? widget.model.horizontal ?? widget.model.all ?? 0.0;

    if(pTop.isNegative) pTop = 0;
    if(pBottom.isNegative) pBottom = 0;
    if(pLeft.isNegative) pLeft = 0;
    if(pRight.isNegative) pRight = 0;

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

    if (children.isEmpty) return SizedBox(width: pLeft + pRight, height: pTop + pBottom,);

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
                  top: pTop,
                  bottom: pBottom,
                  left: pLeft,
                  right: pRight), child: view);
    return view;
  }
}
