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

  setConstraints(BoxConstraints constraints)
  {
    if (model is ViewableWidgetModel)
    {
      // Set Build Constraints in the [WidgetModel]
      (model as ViewableWidgetModel).minWidth  = constraints.minWidth;
      (model as ViewableWidgetModel).maxWidth  = constraints.maxWidth;
      (model as ViewableWidgetModel).minHeight = constraints.minHeight;
      (model as ViewableWidgetModel).maxHeight = constraints.maxHeight;
    }
  }

  Widget getConstrainedView(IWidgetView widget, Widget view)
  {
    var model = widget.model;
    if (model is ViewableWidgetModel)
    {
      // width specified
      if (model.width != null && model.height == null)
      {
        view = UnconstrainedBox(child: SizedBox(child: view, width: model.width), constrainedAxis: Axis.vertical);
        if (model.hasVerticalSizing)
        {
          var constraints  = model.getConstraints();
          double minHeight = constraints.minHeight ?? 0.0;
          double maxHeight = constraints.maxHeight ?? double.infinity;
          view = ConstrainedBox(child: view, constraints: BoxConstraints(minHeight: minHeight, maxHeight: maxHeight));
        }
      }

      // height specified
      else if (model.width == null && model.height != null)
      {
        view = UnconstrainedBox(child: SizedBox(child: view, height: model.height), constrainedAxis: Axis.horizontal);
        if (model.hasHorizontalSizing)
        {
          var constraints = model.getConstraints();
          double minWidth = constraints.minWidth ?? 0.0;
          double maxWidth = constraints.maxWidth ?? double.infinity;
          view = ConstrainedBox(child: view, constraints: BoxConstraints(minHeight: minWidth, maxHeight: maxWidth));
        }
        return view;
      }

      // width & height specified
      else if (model.width != null && model.height != null)
      {
        view = UnconstrainedBox(child: SizedBox(child: view, width: model.width, height: model.height));
      }

      // neither width or height specified
      // but min, max width or height defined
      else if (model.hasSizing)
      {
        var constraints  = model.getConstraints();
        double minWidth  = model.hasHorizontalSizing ? constraints.minWidth  ?? 0.0 : 0.0;
        double maxWidth  = model.hasHorizontalSizing ? constraints.maxWidth  ?? double.infinity : double.infinity;
        double minHeight = model.hasVerticalSizing   ? constraints.minHeight ?? 0.0 : 0.0;
        double maxHeight = model.hasVerticalSizing   ? constraints.maxHeight ?? double.infinity : double.infinity;
        view = ConstrainedBox(child: view, constraints: BoxConstraints(minHeight: minHeight, maxHeight: maxHeight, minWidth: minWidth, maxWidth: maxWidth));
      }
    }
    return view;
  }
}