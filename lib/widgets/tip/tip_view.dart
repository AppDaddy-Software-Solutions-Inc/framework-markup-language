// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/helper/measured.dart';
import 'package:fml/system.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/tip/tip_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/tooltip/tooltip_model.dart';
import 'package:fml/helper/common_helpers.dart';

class TipView extends StatefulWidget
{
  final List<Widget> children = [];
  final TipModel model;
  TipView(this.model) : super(key: ObjectKey(model));

  @override
  _TipViewState createState() => _TipViewState();
}

class _TipViewState extends State<TipView> implements IModelListener
{
  double padding = 15;
  double? width;
  double? height;

  onMeasured(Size size, {dynamic data})
  {
    if (height == null) height = size.height;
    if (width == null)  width  = size.width;
    setState(() {});
  }

  @override
  void initState()
  {
    super.initState();
    widget.model.registerListener(this);
    widget.model.initialize();
  }

  @override
  didChangeDependencies()
  {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(TipView oldWidget)
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

  /// Callback to fire the [_TooltipViewState.build] when the [TooltipModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value})
  {
    if (this.mounted) setState((){});
  }

  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    //////////////////
    /* Add Children */
    //////////////////
    List<Widget> children = [];
    if (widget.model.children != null)
      widget.model.children!.forEach((model)
      {
        if (model is IViewableWidget) {
          children.add((model as IViewableWidget).getView());
        }
      });


    Widget child = children.length == 1 ? children[0] : Column(children: children, mainAxisSize: MainAxisSize.min);

    // we have to measure size of the tooltip since LayoutBuilder and
    // Overlays dont seem to work well together
    // fsailing to do this causes a crash
    if ((width == null) || (height == null)) return Offstage(child: Material(child: MeasuredView(UnconstrainedBox(child: child), onMeasured)));

    // Exceeds Width of Viewport
    var maxWidth  = MediaQuery.of(context).size.width;
    if (width! > (maxWidth - (padding * 4))) width = (maxWidth - (padding * 4));
    if (width! <= 0) width = 50;

    // Exceeds Height of Viewport
    var maxHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    if (height! > (maxHeight - (padding * 4))) height = (maxHeight - (padding * 4));
    if (height! <= 0) height = 50;

    Widget content = UnconstrainedBox(child: SizedBox(height: height, width: width, child: child));

    // tooltip = WidgetTooltip(widgetOverlay: Icon(Icons.import_contacts_sharp, color: Colors.pinkAccent), message: widget.model.label ?? '', textStyle: Theme.of(context).accentTextTheme.overline, child: activator);
    return content;
  }
}