import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/viewable_widget_model.dart';
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

  Widget applyUserContraints(Widget view, {bool? expand})
  {
    if (this.model is ViewableWidgetModel)
    {
      ViewableWidgetModel model = this.model as ViewableWidgetModel;

      var width  = model.width;
      var height = model.height;
      var constraints = model.getConstraints();
      var hasVerticalSizing = model.constraints.hasVerticalSizing;
      var hasHorizontalSizing = model.constraints.hasHorizontalSizing;

      // expanded?
      if (expand == true)
      {
        // this is a safe guard to ensure widgets
        // do not expand out infinitely
        if (constraints.maxWidth == double.infinity || constraints.maxHeight == double.infinity) expand = false;

        // expand in all directions
        if (expand == true)
        {
          width  = constraints.maxWidth;
          height = constraints.maxHeight;
        }
      }

      // width specified
      if (width != null && height == null)
      {
        view = UnconstrainedBox(child: SizedBox(child: view, width: width), constrainedAxis: Axis.vertical);
        if (hasVerticalSizing)
        {
          double minHeight = constraints.minHeight ?? 0.0;
          double maxHeight = constraints.maxHeight ?? double.infinity;
          view = ConstrainedBox(child: view, constraints: BoxConstraints(minHeight: minHeight, maxHeight: maxHeight));
        }
      }

      // height specified
      else if (width == null && height != null)
      {
        view = UnconstrainedBox(child: SizedBox(child: view, height: height), constrainedAxis: Axis.horizontal);
        if (hasHorizontalSizing)
        {
          double minWidth = constraints.minWidth ?? 0.0;
          double maxWidth = constraints.maxWidth ?? double.infinity;
          view = ConstrainedBox(child: view, constraints: BoxConstraints(minWidth: minWidth, maxWidth: maxWidth));
        }
        return view;
      }

      // width & height specified
      else if (width != null && height != null) view = UnconstrainedBox(child: SizedBox(child: view, width: width, height: height));

      // neither width or height specified
      // but min, max width or height defined
      else if (hasVerticalSizing || hasHorizontalSizing)
      {
        double minWidth  = hasHorizontalSizing ? constraints.minWidth  ?? 0.0 : 0.0;
        double maxWidth  = hasHorizontalSizing ? constraints.maxWidth  ?? double.infinity : double.infinity;
        double minHeight = hasVerticalSizing   ? constraints.minHeight ?? 0.0 : 0.0;
        double maxHeight = hasVerticalSizing   ? constraints.maxHeight ?? double.infinity : double.infinity;
        view = ConstrainedBox(child: view, constraints: BoxConstraints(minHeight: minHeight, maxHeight: maxHeight, minWidth: minWidth, maxWidth: maxWidth));
      }

      // containers will expand to the size of their parent
      // unless we wrap in an Unconstrained
      // may not be required - legacy
      if (expand == false && view is! UnconstrainedBox) view = UnconstrainedBox(child: view);
    }
    return view;
  }
}