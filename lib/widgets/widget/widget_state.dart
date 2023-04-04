import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/constraint.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/viewable_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';

abstract class WidgetState<T extends StatefulWidget> extends State<T> implements IModelListener
{
  ViewableWidgetModel? get model => (widget is IWidgetView) ? (widget as IWidgetView).model : null;

  @override
  void initState()
  {
    super.initState();
    model?.registerListener(this);
    model?.initialize();
  }

  @override
  didChangeDependencies()
  {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(dynamic oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    if (oldWidget is IWidgetView && oldWidget.model != model)
    {
      oldWidget.model?.removeListener(this);
      model?.registerListener(this);
    }
  }

  @override
  void dispose()
  {
    model?.removeListener(this);
    super.dispose();
  }

  /// Callback to fire the [_TooltipViewState.build] when the [TooltipModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value})
  {
    if (this.mounted) setState((){});
  }

  Widget applyPadding(Widget view)
  {
    if (model?.padding1 == null) return view;

    double padding = 0.0;
    var paddings = (model?.padding1 != null ? 1 : 0) + (model?.padding2 != null ? 1 : 0) + (model?.padding3 != null ? 1 : 0) + (model?.padding4 != null ? 1 : 0);

    EdgeInsets insets = EdgeInsets.all(model?.padding1 ?? 0);

    // pad all
    if (paddings == 1) insets = EdgeInsets.all(model?.padding1 ?? 0);

    // pad directions v,h
    else if (padding == 2) insets = EdgeInsets.symmetric(vertical: model?.padding1 ?? 0, horizontal: model?.padding2 ?? 0);

    // pad sides top, right, bottom
    else if (padding == 3) insets = EdgeInsets.only(top: model?.padding1 ?? 0, left: model?.padding2 ?? 0, right: model?.padding2 ?? 0, bottom: model?.padding3 ?? 0);

    // pad sides top, right, bottom
    else if (padding == 4) insets = EdgeInsets.only(top: model?.padding1 ?? 0, right: model?.padding2 ?? 0, bottom: model?.padding3 ?? 0, left: model?.padding4 ?? 0);

    // pad all
    else insets = EdgeInsets.all(model?.padding1 ?? 0);

    // create view
    return Padding(padding: insets, child: view);
  }

  /// This routine applies the given constraints to the supplied
  /// view and then returns a widget with the view wrapped in those
  /// constraints
  Widget applyConstraints(Widget view, Constraints constraints)
  {
    // If no constraints are specified
    // return the view
    if (constraints.isEmpty) return view;

    // Apply min and max constraints to the view only if
    // they are supplied and have not already been applied using
    // width and/or height
    if (constraints.minWidth  != null) view = ConstrainedBox(child: view, constraints: BoxConstraints(minWidth:  constraints.minWidth!));
    if (constraints.maxWidth  != null) view = ConstrainedBox(child: view, constraints: BoxConstraints(maxWidth:  constraints.maxWidth!));
    if (constraints.minHeight != null) view = ConstrainedBox(child: view, constraints: BoxConstraints(minHeight: constraints.minHeight!));
    if (constraints.maxHeight != null) view = ConstrainedBox(child: view, constraints: BoxConstraints(maxHeight: constraints.maxHeight!));

    // If a hard width is specified
    // wrap the view in an unconstrained box of the specified
    // width and honor any applicable vertical constraints
    if (constraints.width != null && constraints.height == null)
      view = UnconstrainedBox(child: SizedBox(child: view, width: constraints.width), constrainedAxis: Axis.vertical);

    // if a hard height is specified
    // wrap the view in an unconstrained box of the specified
    // height and honor any applicable horizontal constraints
    else if (constraints.width == null && constraints.height != null)
      view = UnconstrainedBox(child: SizedBox(child: view, height: constraints.height), constrainedAxis: Axis.horizontal);

    // If a both a hard width and height are specified
    // wrap the view in an unconstrained box of the specified
    // width and height and defeat any vertical and/or horizontal constraints
    else if (constraints.width != null && constraints.height != null)
      view = UnconstrainedBox(child: SizedBox(child: view, width: constraints.width, height: constraints.height));

    return view;
  }

  /// This routine constrains the specified Axis. If Axis is nuull, it will constrain
  /// both Axis.vertical and Axis.horizontal if unconstrained
  Widget constrainAxis(Widget view, Constraints constraints, Constraints maxConstraints, {Axis? axis})
  {
    // If no constraints are specified
    // return the view
    if (constraints.isEmpty) return view;

    double? maxWidth;
    double? maxHeight;

    // restrain the vertical if if unconstrained (double.infinity)
    if (axis == Axis.vertical || axis == null)
    {
      // the vertical axis is constrained if a height or max height
      // is specified since it would have already been applied above
      var constrained = constraints.height != null || constraints.maxHeight != null;

      // max height is either the calculated max height
      // or the height of the display (default). The default could very well be
      // any other arbitrary size.
      if (!constrained) maxHeight = maxConstraints.maxHeight ?? MediaQuery.of(context).size.height;
    }

    // restrain the horizontal if unconstrained (double.infinity)
    if (axis == Axis.vertical || axis == null)
    {
      // the horizontal axis is constrained if a width or max width
      // is specified since it would have already been applied above
      var constrained = constraints.width != null || constraints.maxWidth  != null;

      // max width is either the calculated max width
      // or the width of the display (default). The default could very well be
      // any other arbitrary size.
      if (!constrained) maxHeight = maxConstraints.maxWidth ?? MediaQuery.of(context).size.width;
    }

    // set constraints in order to contain the box
    BoxConstraints? boxConstraints;
    if (maxWidth != null && maxHeight != null) boxConstraints = BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight);
    if (maxWidth != null && maxHeight == null) boxConstraints = BoxConstraints(maxWidth: maxWidth);
    if (maxWidth == null && maxHeight != null) boxConstraints = BoxConstraints(maxHeight: maxHeight);

    // set the constraints on the view
    if (boxConstraints != null) view = ConstrainedBox(child: view, constraints: boxConstraints);

    return view;
  }

  void onLayout(BoxConstraints constraints)
  {
    model?.onLayout(constraints);
    WidgetsBinding.instance.addPostFrameCallback((_)
    {
      var box = context.findRenderObject() as RenderBox?;
      var position = (box != null) ? box.localToGlobal(Offset.zero) : null;
      model?.onLayoutComplete(box, position);
    });
  }
}