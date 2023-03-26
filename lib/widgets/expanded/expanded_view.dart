// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';

import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/expanded/expanded_model.dart';
import 'package:fml/widgets/row/row_model.dart';
import 'package:fml/widgets/column/column_model.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class ExpandedView extends StatefulWidget implements IWidgetView
{
  final ExpandedModel model;

  ExpandedView(this.model) : super(key: ObjectKey(model));

  @override
  _ExpandedViewState createState() => _ExpandedViewState();
}

class _ExpandedViewState extends WidgetState<ExpandedView>
{
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // save system constraints
    widget.model.setConstraints(constraints);

    var c = widget.model.getConstraints();

    // build children
    List<Widget> children = [];
    if (widget.model.children != null)
      widget.model.children!.forEach((model)
      {
        if (model is IViewableWidget) {
          children.add((model as IViewableWidget).getView());
        }
      });
    if (children.isEmpty) children.add(Container());

    var view = children.length == 1 ? children[0] : Column(children: children);

    // parent must be a Row or Column
    if (widget.model.parent is! RowModel &&
        widget.model.parent is! ColumnModel &&
        (widget.model.parent is BoxModel && (widget.model.parent as BoxModel).layout != 'stack')) return view;

    // Using Flexible() will allow max constraints to be satisfied.
    //  When using FlexFit.loose (Flexible() rather than Expanded(), the flex: factor needs to be dynamically calculated to represent the available space on the screen, minus the siblings max constraints once those constraints are exceeded
    // ie: if the screen width is 1200 and the max constraint of the 1 sibling is 600, the flex factor remains 1 on the unconstrained flexible and 1 on the constrained, as both can take up 50%.
    // if the screen width is 1800 the flex factor on the unconstrained must be 2, as 2/(2+1) is 66% of the available space, which the unconstrained must be given to allow it to take up the space that the constrained child will not use.
    //
    // This can potentially be calculated IF(there is /an unconstrained child in the main axis direction) with c: number of children, s: sum of siblings max constraints in the main axis direction, p: the size of the parent widget in the main axist direction, u: unconstrained children.
    //
    // ceil(((p-s)/p*100/(100-(p-s)/p*100))/u) : the ceiling will give us leeway so we do not have to adjust the unconstrained childrens flex factor outside of 1, since the flex factor cannot be a double.
    // This can also be calculated more simply by ceil(((p - s)/(s))/u)
    //
    // this becomes slightly more complex when flex factors are involved. We could convert this to a fraction as well to get more accurate flex factors rather than 1 for constrained children.
    // to use this with wrapping, ROW needs to only wrap when its width is less than the sum of its childrens min constraints

    // Set the Fit
    // tight: The child is forced to fill the available space. This is the default for the Expanded() widget.
    // loose: The child can be at most as large as the available space (but is allowed to be smaller). This is the default for the Flexible() widget.
    var fit = FlexFit.tight;

    /// safeguard - don't allow infinite size
    if (constraints.maxHeight == double.infinity || constraints.maxWidth == double.infinity) fit = FlexFit.tight;

    // crate the view
    view = Flexible(flex: widget.model.flex, child: view, fit: fit);

    return view;
  }
}
