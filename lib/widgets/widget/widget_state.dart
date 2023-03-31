import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/constraint.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/widget_model.dart';

abstract class WidgetState<T extends StatefulWidget> extends State<T> implements IModelListener
{
  WidgetModel? get model => (widget is IWidgetView) ? (widget as IWidgetView).model : null;

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

  /// This routine applies the given constraints to the supplied
  /// view and then returns a widget with the view wrapped in those
  /// constraints
  Widget applyConstraints(Widget view, Constraints constraints, {bool restrainVerticalAxis = false, restrainHorizontalAxis = false, Constraints? maxConstraints})
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

    // checks that either of the axis are unrestrained by the system
    // if if so, applies basis size restrictions in order to avoid
    // an infinitely expanding widget error
    if (restrainVerticalAxis || restrainHorizontalAxis)
    {
      // the horizontal axis is constrained if a width or max width
      // is specified since it would have already been applied above
      var horizontalAxisConstrained = constraints.width  != null || constraints.maxWidth  != null;
      var horizontalAxisUnconstrained = !horizontalAxisConstrained;

      // the vertical axis is constrained if a height or max height
      // is specified since it would have already been applied above
      var verticalAxisConstrained = constraints.height != null || constraints.maxHeight != null;
      var verticalAxisUnconstrained = !verticalAxisConstrained;

      // If the box unconstrained in either axis,
      // we need to constrain it, otherwise it
      // will throw a flutter exception
      if (horizontalAxisUnconstrained || verticalAxisUnconstrained)
      {
        // max width is either the calculated max width
        // or the width of the display (default). The default could very well be
        // any other arbitrary size.
        var maxWidth  = maxConstraints?.maxWidth  ?? MediaQuery.of(context).size.width;

        // max height is either the calculated max height
        // or the height of the display (default). The default could very well be
        // any other arbitrary size.
        var maxHeight = maxConstraints?.maxHeight ?? MediaQuery.of(context).size.height;

        // set constraints in order to contain the box
        BoxConstraints? constraints;
        if (horizontalAxisUnconstrained && verticalAxisUnconstrained) constraints = BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight);
        if (horizontalAxisUnconstrained && verticalAxisConstrained)   constraints = BoxConstraints(maxHeight: maxWidth);
        if (horizontalAxisConstrained   && verticalAxisUnconstrained) constraints = BoxConstraints(maxWidth: maxHeight);

        // set the constraints on the view
        if (constraints != null) view = ConstrainedBox(child: view, constraints: constraints);
      }
    }
    return view;
  }
}