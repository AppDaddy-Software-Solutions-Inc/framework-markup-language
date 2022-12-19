// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';

import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/footer/footer_model.dart';

class FooterView extends StatefulWidget
{
  double? get height
  {
    if (model.height! > 0) return model.height;
    return null;
  }

  final List<Widget> children = [];
  final FooterModel model;

  FooterView(this.model) : super(key: ObjectKey(model));

  @override
  _FooterViewState createState() => _FooterViewState();
}

class _FooterViewState extends State<FooterView> implements IModelListener
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
  void didUpdateWidget(FooterView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    // re-register model listener
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
    widget.model.minwidth  = constraints.minWidth;
    widget.model.maxwidth  = constraints.maxWidth;
    widget.model.minheight = constraints.minHeight;
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
