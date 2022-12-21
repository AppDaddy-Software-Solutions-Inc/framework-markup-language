// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart'    ;
import 'package:fml/widgets/center/center_model.dart' as CENTER;

/// Center View
///
/// DEPRECATED
/// Builds a centered Center View from [Model] properties
class CenterView extends StatefulWidget
{
  final CENTER.CenterModel model;
  final List<Widget> children = [];

  CenterView(this.model) : super(key: ObjectKey(model));

  @override
  _CenterViewState createState() => _CenterViewState();
}

class _CenterViewState extends State<CenterView> implements IModelListener
{
  @override
  void initState()
  {
    super.initState();
    widget.model.registerListener(this);
  }

  @override
  void dispose()
  {
    widget.model.removeListener(this);

    super.dispose();
  }

  /// Callback to fire the [_CenterViewState.build] when the [CenterModel] changes
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
    // Set Build Constraints in the [WidgetModel]
      widget.model.minwidth  = constraints.minWidth;
      widget.model.maxwidth  = constraints.maxWidth;
      widget.model.minheight = constraints.minHeight;
      widget.model.maxheight = constraints.maxHeight;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    widget.children.clear();
    if (widget.model.children != null)
      widget.model.children!.forEach((model)
      {
        if (model is IViewableWidget) {
          widget.children.add((model as IViewableWidget).getView());
        }
      });
    if (widget.children.isEmpty) widget.children.add(Container());

    ////////////
    /* Center */
    ////////////
    dynamic view = Center(child: widget.children.length == 1
      ? widget.children[0]
      : Column(children: widget.children, crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.max));

    /////////////////
    /* Constrained */
    /////////////////
    if (widget.model.constrained)
    {
      var constraints = widget.model.getConstraints();
      view = ConstrainedBox(child: view, constraints: BoxConstraints(
      minHeight: constraints.minHeight!, maxHeight: constraints.maxHeight!,
          minWidth: constraints.minWidth!, maxWidth: constraints.maxWidth!));
    }

    return view;
  }
}
