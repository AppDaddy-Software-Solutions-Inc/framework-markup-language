import 'package:flutter/material.dart';
import 'package:fml/widgets/scroller/scroller_model.dart';
import 'package:fml/widgets/widget/constraint.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
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

  Widget getConstrainedView(Widget view, ViewableWidgetModel model, bool expand)
  {
    if (model is ViewableWidgetModel)
    {
      double? width  = model.width;
      double? height = model.height;

      if (expand)
      {
        ScrollerModel? scrollerModel = model.findParentOfExactType(ScrollerModel);
        if (scrollerModel != null)
        {
          expand = false;
          if (scrollerModel.layout == "col" || scrollerModel.layout == "column") width ??= constraints.maxWidth;
          if (scrollerModel.layout == "row") height ??= constraints.maxHeight;
        }
      }
      if (expand == false && height != null && width != null) expand = true;

      if (!expand)
      {
        // unsure how to make this work with maxwidth/maxheight, as it should yet constraints always come in. What should it do? same with minwidth/minheight...
        if (width != null || height != null)
        {
          view = UnconstrainedBox(
            child: LimitedBox(
              maxWidth: constraints.maxWidth!,
              child: ConstrainedBox(
                  child: view,
                  constraints: BoxConstraints(
                    minHeight: constraints.minHeight!,
                    minWidth: constraints.minWidth!,)),
            ),
          );
        }
        else if (height != null)
        {
          view = UnconstrainedBox(
            child: LimitedBox(
              maxHeight: constraints.maxHeight!,
              child: ConstrainedBox(
                  child: view,
                  constraints: BoxConstraints(
                    minHeight: constraints.minHeight!,
                    minWidth: constraints.minWidth!,)),
            ),
          );
        }
        else
        {
          view = UnconstrainedBox(
              child:
              ConstrainedBox(
                  child: view,
                  constraints: BoxConstraints(
                    minHeight: constraints.minHeight!,
                    minWidth: constraints.minWidth!,))
          );
        }
      }

      else
      {
        view = ConstrainedBox(
            child: view,
            constraints: BoxConstraints(
                minHeight: constraints.minHeight!,
                maxHeight: constraints.maxHeight!,
                minWidth: constraints.minWidth!,
                maxWidth: constraints.maxWidth!));
      }
    }

    return view;
  }
}