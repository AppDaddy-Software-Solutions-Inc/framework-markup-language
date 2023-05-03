// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/column/column_model.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:fml/widgets/alignment/alignment.dart';
import 'package:fml/widgets/layout/layout_model.dart';

class ColumnView extends StatefulWidget implements IWidgetView
{
  @override
  final LayoutModel model;

  ColumnView(this.model) : super(key: ObjectKey(model));

  @override
  _ColumnViewState createState() => _ColumnViewState();
}

class _ColumnViewState extends WidgetState<ColumnView>
{
  @override
  void initState()
  {
    super.initState();

    // remove listener to the model if the model
    // is not a column model. The BoxModel will share the same model
    // and rebuild this view on model change
    if (widget.model is! ColumnModel) widget.model.removeListener(this);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // save system constraints
    onLayout(constraints);

    // build the child views
    List<Widget> children = widget.model.inflate();
    if (children.isEmpty) children.add(Container());

    // get main axis size
    MainAxisSize? mainAxisSize = widget.model.verticalAxisSize;

    // this must go after the children are determined
    var alignment = WidgetAlignment(widget.model.layoutType, widget.model.center, widget.model.halign, widget.model.valign);

    Widget view;

    // create view
    if (widget.model.wrap == true) {
      view = Wrap(children: children,
          direction: Axis.vertical,
          alignment: alignment.mainWrapAlignment,
          runAlignment: alignment.mainWrapAlignment,
          crossAxisAlignment: alignment.crossWrapAlignment);
    } else {
      view = Column(
          children: children,
          mainAxisAlignment: alignment.mainAlignment,
          crossAxisAlignment: alignment.crossAlignment,
          mainAxisSize: mainAxisSize);
    }

    // add margins
    if (model is ColumnModel) view = addMargins(view);

    // apply user defined constraints
    if (model is ColumnModel) view = applyConstraints(view, widget.model.constraints.model);

    return view;
  }
}
