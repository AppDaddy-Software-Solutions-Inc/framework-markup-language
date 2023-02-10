// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/card/card_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;

/// Card View
///
/// DEPRECATED
/// Builds the Card View from [CardModel] properties
class CardView extends StatefulWidget {
  final CardModel model;

  CardView(this.model) : super(key: ObjectKey(model));

  @override
  _CardViewState createState() => _CardViewState();
}

class _CardViewState extends State<CardView> implements IModelListener {
  
  
  @override
  void initState() {
    super.initState();
    widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    widget.model.initialize();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
  }

  
  @override
  void didUpdateWidget(CardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model != widget.model) {
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }
  }

  @override
  void dispose() {
    widget.model.removeListener(this);
    super.dispose();
  }

  /// Callback to fire the [_CardViewState.build] when the [CardModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value}) {
    if (this.mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: builder);
  }

  Widget builder(BuildContext context, BoxConstraints constraints) {
    // Set Build Constraints in the [WidgetModel]
    widget.model.minWidth = constraints.minWidth;
    widget.model.maxWidth = constraints.maxWidth;
    widget.model.minHeight = constraints.minHeight;
    widget.model.maxheight = constraints.maxHeight;

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

    //////////////
    /* Children */
    //////////////
    List<Widget> children = [];
    if (widget.model.children != null)
      widget.model.children!.forEach((model)
      {
        if (model is IViewableWidget) {
          children.add((model as IViewableWidget).getView());
        }
      });

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

    //////////////////
    /* Constrained? */
    //////////////////
    if (widget.model.hasSizing) {
      var constraints = widget.model.getConstraints();
      view = UnconstrainedBox(
          child: ConstrainedBox(
              child: view,
              constraints: BoxConstraints(
                  minHeight: constraints.minHeight!,
                  maxHeight: constraints.maxHeight!,
                  minWidth: constraints.minWidth!,
                  maxWidth: constraints.maxWidth!)));
    }

    return view;
  }
}
