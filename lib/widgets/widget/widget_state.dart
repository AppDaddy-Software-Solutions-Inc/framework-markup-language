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

  Widget applyConstraints(Widget view, Constraints constraints)
  {
    // If no constraints are specified
    // return the view
    if (constraints.hasNoConstraints) return view;

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

    // Apply min and max constraints to the view only if
    // they are supplied and have not already been applied above
    if ((constraints.isHorizontallyConstrained && constraints.width == null) || (constraints.isVerticallyConstrained && constraints.height == null))
      view = ConstrainedBox(child: view, constraints: BoxConstraints(minWidth: constraints.minWidth ?? 0, maxWidth: constraints.maxWidth ?? double.infinity, minHeight: constraints.minHeight ?? 0, maxHeight: constraints.maxHeight ?? double.infinity));

    return view;
  }
}