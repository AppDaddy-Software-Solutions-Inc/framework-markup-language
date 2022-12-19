// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/modal/modal_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;

class ModalView extends StatefulWidget
{
  final ModalModel model;

  ModalView(this.model) : super(key: ObjectKey(model));

  @override
  _ModalViewState createState() => _ModalViewState();
}

class _ModalViewState extends State<ModalView> implements IModelListener
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
  void didUpdateWidget(ModalView oldWidget)
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
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    ///////////
    /* Child */
    ///////////
    List<Widget> children = [];
    if (widget.model.children != null)
      widget.model.children!.forEach((model)
      {
        if (model is IViewableWidget) {
          children.add((model as IViewableWidget).getView());
        }
      });
    if (children.isEmpty) children.add(Container());
    Widget child = children.length == 1 ? children[0] : Column(children: children, crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min);

    //////////
    /* View */
    //////////
    Widget view = SingleChildScrollView(child: child, scrollDirection: Axis.vertical);

    Map<String, double?> constr = widget.model.constraints;
    view = ConstrainedBox(
        child: view,
        constraints: BoxConstraints(
            minHeight: constr['minheight']!,
            maxHeight: constr['maxheight']!,
            minWidth: constr['minwidth']!,
            maxWidth: constr['maxwidth']!));

    return view;
  }
}
