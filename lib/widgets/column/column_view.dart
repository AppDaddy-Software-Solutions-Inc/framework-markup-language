// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/column/column_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/helper/common_helpers.dart';

class ColumnView extends StatefulWidget {
  final ColumnModel model;

  ColumnView(this.model) : super(key: ObjectKey(model));

  @override
  _ColumnViewState createState() => _ColumnViewState();
}

class _ColumnViewState extends State<ColumnView> implements IModelListener {
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
  void didUpdateWidget(ColumnView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (
        (oldWidget.model != widget.model)) {
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }

  }

  @override
  void dispose() {
    widget.model.removeListener(this);

    super.dispose();
  }

  /// Callback to fire the [_ColumnViewState.build] when the [ColumnModel] changes
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
    widget.model.maxHeight = constraints.maxHeight;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible)
      return Offstage();

    ///////////
    /* Child */
    ///////////
    List<Widget> children = [];
    if (widget.model.children != null)
      widget.model.children!.forEach((model) {
        if (model is IViewableWidget) {
          children.add((model as IViewableWidget).getView());
        }
      });
    if (children.isEmpty) children.add(Container());

    //this must go after the children are determined
    Map<String, dynamic> align = AlignmentHelper.alignWidgetAxis(
        children.length,
        'column',
        widget.model.center,
        widget.model.halign,
        widget.model.valign);
    CrossAxisAlignment? crossAlignment = align['crossAlignment'];
    MainAxisAlignment? mainAlignment = align['mainAlignment'];
    WrapAlignment? mainWrapAlignment = align['mainWrapAlignment'];
    WrapCrossAlignment? crossWrapAlignment = align['crossWrapAlignment'];
    //Alignment aligned = align['aligned'];

    // set main axis size
    var mainAxisSize = widget.model.expand == false ? MainAxisSize.min : MainAxisSize.max;

    /// safeguard - don't allow infinite size
    if (mainAxisSize == MainAxisSize.max && constraints.maxHeight == double.infinity) mainAxisSize = MainAxisSize.min;

    Widget view;

    // paddings
    EdgeInsets insets = EdgeInsets.only();
    if (widget.model.paddings > 0)
    {
     // pad all
     if (widget.model.paddings == 1) insets = EdgeInsets.all(widget.model.padding);

     // pad directions v,h
     else if (widget.model.paddings == 2) insets = EdgeInsets.symmetric(vertical: widget.model.padding, horizontal: widget.model.padding2);

     // pad sides top, right, bottom
     else if (widget.model.paddings == 3) insets = EdgeInsets.only(top: widget.model.padding, left: widget.model.padding2, right: widget.model.padding2, bottom: widget.model.padding3);

     // pad sides top, right, bottom
     else if (widget.model.paddings == 4) insets = EdgeInsets.only(top: widget.model.padding, right: widget.model.padding2, bottom: widget.model.padding3, left: widget.model.padding4);
    }
    if (widget.model.wrap == true)
      view = Padding( padding: insets, child: Wrap(
          children: children,
          direction: Axis.vertical,
          alignment: mainWrapAlignment!,
          runAlignment: mainWrapAlignment,
          crossAxisAlignment: crossWrapAlignment!));
    else
      view = Padding( padding: insets, child:Column(
          children: children,
          mainAxisAlignment: mainAlignment!,
          crossAxisAlignment: crossAlignment!,
          mainAxisSize: mainAxisSize));

    // Constrained?
    if (widget.model.hasSizing)
    {
      var constraints = widget.model.getConstraints();
      double minWidth  = widget.model.haslHorizontalSizing ? constraints.minWidth  ?? 0.0 : 0.0;
      double maxWidth  = widget.model.haslHorizontalSizing ? constraints.maxWidth  ?? double.infinity : double.infinity;
      double minHeight = widget.model.hasVerticalSizing   ? constraints.minHeight ?? 0.0 : 0.0;
      double maxHeight = widget.model.hasVerticalSizing   ? constraints.maxHeight ?? double.infinity : double.infinity;
      view = ConstrainedBox(child: view, constraints: BoxConstraints(minHeight: minHeight, maxHeight: maxHeight, minWidth: minWidth, maxWidth: maxWidth));
    }

    return view;
  }
}
