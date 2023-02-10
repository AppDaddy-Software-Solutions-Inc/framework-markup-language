// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/header/header_model.dart';

class HeaderView extends StatefulWidget
{
  final List<Widget> children = [];
  final HeaderModel model;

  HeaderView(this.model) : super(key: ObjectKey(model));

  @override
  _HeaderViewState createState() => _HeaderViewState();
}

class _HeaderViewState extends State<HeaderView> implements IModelListener
{
  @override
  void initState()
  {
    super.initState();

    widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    widget.model.initialize();
  }

  @override
  didChangeDependencies()
  {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(HeaderView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    
    if ((oldWidget.model != widget.model))
    {
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }

  }

  @override
  void dispose()
  {
    widget.model.removeListener(this);
    super.dispose();
  }
  /// Callback function for when the model changes, used to force a rebuild with setState()
  onModelChange(WidgetModel model,{String? property, dynamic value})
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
    // Set Build Constraints in the [WidgetModel]
    widget.model.minWidth  = constraints.minWidth;
    widget.model.maxWidth  = constraints.maxWidth;
    widget.model.minHeight = constraints.minHeight;
    widget.model.maxheight = constraints.maxHeight;

    // Check if widget is visible before wasting resources on building it
    if (widget.model.visible == false) return Offstage();

    ///////////
    /* Child */
    ///////////
    List<Widget> children = [];
    children.add(Container(constraints: BoxConstraints.expand(), color: widget.model.color ?? Theme.of(context).colorScheme.primary));
    if (widget.model.children != null)
    widget.model.children!.forEach((model)
    {
      if (model is IViewableWidget) {
        children.add((model as IViewableWidget).getView());
      }
    });

    if (children.isEmpty) children.add(Container());

    //////////
    /* View */
    //////////
    Widget view = Stack(fit: StackFit.loose, children: children);

    return view;
  }
}
