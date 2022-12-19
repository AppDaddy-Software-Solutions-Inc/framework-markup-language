// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart'    ;
import 'package:fml/widgets/grid/item/grid_item_model.dart' as ITEM;

class GridItemView extends StatefulWidget
{
  final ITEM.GridItemModel? model;
  GridItemView({this.model}) : super(key: ObjectKey(model));

  @override
  _GridItemViewState createState() => _GridItemViewState();
}

class _GridItemViewState extends State<GridItemView> implements IModelListener
{
  @override
  void initState()
  {
    super.initState();

    
    if (widget.model != null) widget.model!.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    if (widget.model != null) widget.model!.initialize();
  }

  @override
  didChangeDependencies()
  {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(GridItemView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    
    if ((oldWidget.model != widget.model))
    {
      oldWidget.model!.removeListener(this);
      widget.model!.registerListener(this);
    }

  }

  @override
  void dispose()
  {
    if (widget.model != null) widget.model!.removeListener(this);

    super.dispose();
  }

  /// Callback to fire the [_GridItemViewState.build] when the [GridItemModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value})
  {
    if (this.mounted) setState((){});
  }

  @override
  Widget build(BuildContext context)
  {
    return LayoutBuilder(builder: builder);
  }

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Check if widget is visible before wasting resources on building it
    if ((widget.model == null) || (widget.model!.visible == false)) return Offstage();

    //////////////////
    /* Add Children */
    //////////////////
    List<Widget> children = [];
    if (widget.model!.children != null)
    widget.model!.children!.forEach((model)
    {
      if (model is IViewableWidget) {
        children.add((model as IViewableWidget).getView());
      }
    });

    if (children.isEmpty) children.add(Container());
    return Container(child: Center(child: children.length == 1 ? children[0] : Column(children: children, mainAxisSize: MainAxisSize.min)));
  }
}