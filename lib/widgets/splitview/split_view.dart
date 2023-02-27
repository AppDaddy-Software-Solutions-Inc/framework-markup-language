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
  onModelChange(WidgetModel model, {String? property, dynamic value})
  {
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
    widget.model.minWidth  = constraints.minWidth;
    widget.model.maxWidth  = constraints.maxWidth;
    widget.model.minHeight = constraints.minHeight;
    widget.model.maxHeight = constraints.maxHeight;

    var _dividerWidth = widget.model.dividerWidth ?? (System().useragent == 'desktop' || S.isNullOrEmpty(System().useragent) ? 6.0 : 12.0);
    if (_dividerWidth % 2 != 0) _dividerWidth = _dividerWidth + 1;

    var _dividerColor = widget.model.dividerColor ?? Theme.of(context).colorScheme.onInverseSurface;
    
    // views
    if (widget.views.isEmpty)
    widget.model.children?.forEach((child)
    {
      if (child is ViewModel) widget.views.add(child.getView());
    });


    // calculate sizes
    var size1 = (widget.model.vertical ? widget.model.height ?? 0 : widget.model.width  ?? 0);
    var size2 = (widget.model.vertical ? widget.model.maxHeight! : widget.model.maxWidth!) - size1;
    size1 = size1 - (_dividerWidth/2);
    size2 = size2 - (_dividerWidth/2);
    if (size1 < 0)
    {
      size2 = size2 + size1;
      size1 = 0;
    }
    if (size2 < 0)
    {
      size1 = size1 + size2;
      size2 = 0;
    }

    // left/top pane
    var pane1 = widget.model.vertical ?
    SizedBox(height: size1, child: Container(color: Theme.of(context).colorScheme.surface, child: (widget.views.isNotEmpty ? widget.views[0] : Text ('Missing <View />')))) :
    SizedBox(width:  size1, child: Container(color: Theme.of(context).colorScheme.surface, child: (widget.views.isNotEmpty ? widget.views[0] : Text ('Missing <View />'))));

    // handle
    Widget handle = widget.model.vertical ?
    GestureDetector(behavior: HitTestBehavior.opaque, onVerticalDragUpdate:   _onDrag, child: Container(color: _dividerColor, child: SizedBox(width: constraints.maxWidth, height: _dividerWidth, child: MouseRegion(cursor: SystemMouseCursors.resizeUpDown,     child: Stack(children: [Positioned(top: -10, child: Icon(Icons.drag_handle, color: widget.model.dividerHandleColor))]))))) :
    GestureDetector(behavior: HitTestBehavior.opaque, onHorizontalDragUpdate: _onDrag, child: Container(color: _dividerColor, child: SizedBox(width: _dividerWidth, height: constraints.maxHeight, child: MouseRegion(cursor: SystemMouseCursors.resizeLeftRight, child: RotationTransition(child: Icon(Icons.drag_handle, color: widget.model.dividerHandleColor), turns: AlwaysStoppedAnimation(.25))))));

    // right/bottom pane
    var pane2 = widget.model.vertical ?
    SizedBox(height: size2, child: Container(color: Theme.of(context).colorScheme.surface, child: (widget.views.length > 1 ? widget.views[1] : Text ('Missing <View />')))) :
    SizedBox(width: size2, child: Container(color: Theme.of(context).colorScheme.surface, child: (widget.views.length > 1 ? widget.views[1] : Text ('Missing <View />'))));

    // view
    return widget.model.vertical ?
    SizedBox(height: constraints.maxHeight, child: Column(children: <Widget>[pane1, handle, pane2])) :
    SizedBox(width: constraints.maxWidth,   child: Row(children: <Widget>[pane1, handle, pane2]));
  }

  void _onDrag(DragUpdateDetails details)
  {
    if (widget.model.vertical)
    {
      var height = (widget.model.height ?? 0) + details.delta.dy;
      if (height < 0) height = 0;
      if (height > widget.model.maxHeight!) height = widget.model.maxHeight!;
      widget.model.height = height;
    }
    else
    {
      var width = (widget.model.width ?? 0) + details.delta.dx;
      if (width < 0) width = 0;
      if (width > widget.model.maxWidth!) width = widget.model.maxWidth!;
      widget.model.width = width;
    }
  }
}
