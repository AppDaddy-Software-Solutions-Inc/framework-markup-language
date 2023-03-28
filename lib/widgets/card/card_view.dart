// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/card/card_model.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/widget_state.dart';

/// Card View
///
/// DEPRECATED
/// Builds the Card View from [CardModel] properties
class CardView extends StatefulWidget implements IWidgetView
{
  final CardModel model;

  CardView(this.model) : super(key: ObjectKey(model));

  @override
  _CardViewState createState() => _CardViewState();
}

class _CardViewState extends WidgetState<CardView>
{
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // save system constraints
    widget.model.setSystemConstraints(constraints);

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    String halign = widget.model.halign;
    CrossAxisAlignment crossAlignmentRow = CrossAxisAlignment.start;
    switch (halign.toLowerCase()) {
      case 'center':
        crossAlignmentRow = CrossAxisAlignment.center;
        break;
      case 'start':
      case 'left':
        crossAlignmentRow = CrossAxisAlignment.start;
        break;
      case 'end':
      case 'right':
        crossAlignmentRow = CrossAxisAlignment.end;
        break;
      default:
        crossAlignmentRow = CrossAxisAlignment.start;
        break;
    }

    String valign = widget.model.valign;
    MainAxisAlignment mainAlignmentRow = MainAxisAlignment.start;
    switch (valign.toLowerCase()) {
      case 'center':
        mainAlignmentRow = MainAxisAlignment.center;
        break;
      case 'start':
      case 'top':
        mainAlignmentRow = MainAxisAlignment.start;
        break;
      case 'end':
      case 'bottom':
        mainAlignmentRow = MainAxisAlignment.end;
        break;
      default:
        mainAlignmentRow = MainAxisAlignment.start;
        break;
    }

    // build the child views
    List<Widget> children = widget.model.inflate();
    if (children.isEmpty) children.add(Container());

    var child = children.length == 1
        ? children[0]
        : Column(
            children: children,
            crossAxisAlignment: crossAlignmentRow,
            mainAxisAlignment: mainAlignmentRow,
            mainAxisSize: MainAxisSize.min);

    //////////
    /* View */
    //////////
    Widget view = Card(
        margin: EdgeInsets.all(widget.model.margin),
        clipBehavior: Clip.antiAlias,
        color: widget.model.color ?? Theme.of(context).colorScheme.surface,
        elevation: widget.model.elevation,
        borderOnForeground: true,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(widget.model.radius)),
            side: BorderSide(
              color: widget.model.bordercolor ??
                  widget.model.color ??
                  Theme.of(context).colorScheme.onBackground,
              width: widget.model.borderwidth,
            )),
        child: child);

    // apply user defined constraints
    return applyConstraints(view, widget.model.localConstraints);
  }
}
