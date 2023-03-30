// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'padding_model.dart';

class PaddingView extends StatefulWidget implements IWidgetView
{
  final PaddingModel model;

  PaddingView(this.model) : super(key: ObjectKey(model));

  @override
  _PaddingViewState createState() => _PaddingViewState();
}

class _PaddingViewState extends WidgetState<PaddingView>
{
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

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

    // save system constraints
    var minWidth  = constraints.minWidth + pLeft + pRight;
    var maxWidth  = constraints.maxWidth - pLeft - pRight;
    var minHeight = constraints.minHeight + pTop + pBottom;
    var maxHeight = constraints.maxHeight - pTop - pBottom;
    widget.model.constraints.system = BoxConstraints(minWidth:  minWidth, maxWidth:  maxWidth, minHeight: minHeight, maxHeight: maxHeight);

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // build the child views
    List<Widget> children = widget.model.inflate();
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
