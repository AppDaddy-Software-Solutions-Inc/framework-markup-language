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
}