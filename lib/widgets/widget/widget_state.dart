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

  Widget getConstrainedView(Widget view)
  {
    // only required for viewable widgets with user specified constraints
    if (this.model is ViewableWidgetModel && (model as ViewableWidgetModel).isConstrained)
    {
      ViewableWidgetModel model = this.model as ViewableWidgetModel;

      double? width  = model.width;
      if (width == double.infinity) width = null;

      double? height = model.height;
      if (height == double.infinity) height = null;

      // width specified
      if (width != null && height == null)
      {
        var constraints = model.getConstraints();
        view = UnconstrainedBox(child: SizedBox(child: view, width: width), constrainedAxis: Axis.vertical);
        if (model.isConstrainedVertically)
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
        if (model.isConstrainedHorizontally)
        {
          var constraints = model.getConstraints();
          double minWidth = constraints.minWidth ?? 0.0;
          double maxWidth = constraints.maxWidth ?? double.infinity;
          view = ConstrainedBox(child: view, constraints: BoxConstraints(minWidth: minWidth, maxWidth: maxWidth));
        }
        return view;
      }

      // width & height specified
      else if (width != null && height != null)
      {
        view = UnconstrainedBox(child: SizedBox(child: view, width: width, height: height));
      }

      // default
      else
      {
        var constraints  = model.getConstraints();
        double minWidth  = model.isConstrainedHorizontally ? constraints.minWidth  ?? 0.0 : 0.0;
        double maxWidth  = model.isConstrainedHorizontally ? constraints.maxWidth  ?? double.infinity : double.infinity;
        double minHeight = model.isConstrainedVertically   ? constraints.minHeight ?? 0.0 : 0.0;
        double maxHeight = model.isConstrainedVertically   ? constraints.maxHeight ?? double.infinity : double.infinity;
        view = ConstrainedBox(child: view, constraints: BoxConstraints(minHeight: minHeight, maxHeight: maxHeight, minWidth: minWidth, maxWidth: maxWidth));
      }
    }
    return view;
  }
}