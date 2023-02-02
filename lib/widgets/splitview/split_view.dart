// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/navigation/navigation_manager.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/splitview/split_model.dart';
import 'package:fml/event/event.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/widgets/view/view_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';

class SplitView extends StatefulWidget
{
  final SplitModel model;
  final List<Widget> views = [];

  SplitView(this.model) : super(key: ObjectKey(model));

  @override
  _SplitViewState createState() => _SplitViewState();
}

class _SplitViewState extends State<SplitView> implements IModelListener
{
  final _dividerWidth = System().useragent == 'desktop' || S.isNullOrEmpty(System().useragent) ? 6.0 : 12.0; // looks best synced to barpadding in tabview

  double _ratio = 0.5;
  set ratio (double v)
  {
    if (v < 0) v = 1;
    if (v > 1) v = 1;
    _ratio = v;
  }

  double? _maxWidth;
  get _width1 => _ratio * _maxWidth!;
  get _width2 => (1 - _ratio) * _maxWidth!;

  @override
  void initState() {
    super.initState();
    widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    widget.model.initialize();
    ratio = widget.model.width != null ? widget.model.width! / (widget.model.maxwidth! - _dividerWidth) : widget.model.ratio;
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(SplitView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model != widget.model)
    {
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }
  }

  @override
  void dispose() {
    widget.model.removeListener(this);
    super.dispose();
  }

  /// Callback to fire the [_BoxViewState.build] when the [BoxModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value}) {
    ratio = widget.model.width != null ? widget.model.width! / (widget.model.maxwidth! - _dividerWidth) : widget.model.ratio;
    if (this.mounted) setState(() {});
  }

  void onBack(Event event)
  {
    event.handled = true;
    String? pages = S.mapVal(event.parameters, 'until');
    if (!S.isNullOrEmpty(pages)) NavigationManager().back(pages);
  }

  void onClose(Event event)
  {
    event.handled = true;
    NavigationManager().back(-1);
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

    if (_maxWidth == null)                  _maxWidth = widget.model.maxwidth! - _dividerWidth;
    if (_maxWidth != widget.model.maxwidth) _maxWidth = widget.model.maxwidth! - _dividerWidth;
    if (_maxWidth != null && _maxWidth! < 0) _maxWidth = 0;

    // views
    if (widget.views.isEmpty)
    {
      widget.model.children?.forEach((child)
      {
        if (child is ViewModel) widget.views.add(child.getView());
      });
    }

    // left pane
    var left = SizedBox(width: _width1, child: Container(color: Theme.of(context).colorScheme.surface, child: (widget.views.isNotEmpty ? widget.views[0] : Text ('Missing <View />'))));

    // handle
    var handle = GestureDetector(behavior: HitTestBehavior.opaque, onHorizontalDragUpdate: _onDrag,
        child: Container(color: Theme.of(context).colorScheme.onInverseSurface, child: SizedBox(width: _dividerWidth, height: constraints.maxHeight, child: MouseRegion(cursor: SystemMouseCursors.resizeLeftRight, child: RotationTransition(child: Icon(Icons.drag_handle, color: Theme.of(context).colorScheme.inverseSurface,), turns: AlwaysStoppedAnimation(0.25))))));

    // right pane
    var right = SizedBox(width: _width2, child: Container(color: Theme.of(context).colorScheme.surface, child: (widget.views.length > 1 ? widget.views[1] : Text ('Missing <View />'))));

    // view
    return SizedBox(width: constraints.maxWidth, child: Row(children: <Widget>[left, handle, right]));
  }

  void _onDrag(DragUpdateDetails details)
  {
    /// print('hor drag' + details.delta.dx.toString() + ' | ' + _ratio.toString() + ' w1: ' + _width1.toString() + ' w2: ' + _width2.toString());
    setState(() { _ratio += details.delta.dx / _maxWidth!; if (_ratio > 1) _ratio = 1; else if (_ratio < 0.0) _ratio = 0.0; });
  }
}
