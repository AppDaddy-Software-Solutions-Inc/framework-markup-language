// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/navigation/navigation_manager.dart';
import 'package:fml/widgets/box/box_data.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/splitview/split_model.dart';
import 'package:fml/event/event.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class SplitView extends StatefulWidget implements IWidgetView
{
  @override
  final SplitModel model;

  final List<BoxView> boxes = [];

  SplitView(this.model) : super(key: ObjectKey(model));

  @override
  State<SplitView> createState() => SplitViewState();
}

class SplitViewState extends WidgetState<SplitView>
{
  ThemeData? theme;

  BoxConstraints constraints = BoxConstraints();

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

  void _onDrag(DragUpdateDetails details, BoxConstraints constraints)
  {
    var ratio = widget.model.ratio;

    var maxHeight = constraints.hasBoundedHeight ? constraints.maxHeight : 0.0;
    var maxWidth  = constraints.hasBoundedWidth  ? constraints.maxWidth  : 0.0;
    if (widget.model.vertical)
    {
      if (maxHeight > 0)
      {
        var height = (ratio * maxHeight) + details.delta.dy;
        ratio = height/maxHeight;
      }
    }
    else
    {
      if (maxWidth > 0)
      {
        var width = (ratio * maxWidth) + details.delta.dx;
        ratio = width/maxWidth;
      }
    }

    // reset the ratio
    if (ratio < 0) ratio = 0;
    if (ratio > 1) ratio = 1;
    if (ratio != widget.model.ratio) widget.model.ratio = ratio;
  }

  Widget _buildHandle()
  {
    var myDividerColor = widget.model.dividerColor ?? theme?.colorScheme.onInverseSurface;
    var myDividerWidth = widget.model.dividerWidth;

    Widget view = widget.model.vertical ?
    GestureDetector(behavior: HitTestBehavior.opaque, onVerticalDragUpdate:  (DragUpdateDetails details) => _onDrag(details, constraints), child: Container(color: myDividerColor, child: SizedBox(width: constraints.maxWidth, height: myDividerWidth, child: MouseRegion(cursor: SystemMouseCursors.resizeUpDown,     child: Stack(children: [Positioned(top: -10, child: Icon(Icons.drag_handle, color: widget.model.dividerHandleColor))]))))) :
    GestureDetector(behavior: HitTestBehavior.opaque, onHorizontalDragUpdate: (DragUpdateDetails details) => _onDrag(details, constraints), child: Container(color: myDividerColor, child: SizedBox(width: myDividerWidth, height: constraints.maxHeight, child: MouseRegion(cursor: SystemMouseCursors.resizeLeftRight, child: RotationTransition(child: Icon(Icons.drag_handle, color: widget.model.dividerHandleColor), turns: AlwaysStoppedAnimation(.25))))));

    return LayoutBoxChildData(child: view, model: BoxModel(null,null,expandDefault: false));
  }

  Widget _constrainBox(BoxView box, int flex)
  {
    var direction = widget.model.vertical ? Axis.vertical : Axis.horizontal;
    switch (direction)
    {
      case Axis.horizontal:
        box.model.setFlex(flex);
        break;

      case Axis.vertical:
        box.model.setFlex(flex);
        break;
    }
    return LayoutBoxChildData(child: box, model: box.model);
  }

  BoxView get _missingView => BoxView(BoxModel(widget.model,null));

  // called by models inflate
  List<Widget> inflate()
  {
    // create box views
    if (widget.boxes.isEmpty)
    {
      var views = widget.model.viewableChildren;

      Widget? view1;
      if (views.isNotEmpty) view1 = views.elementAt(0).getView();
      widget.boxes.add(view1 is BoxView ? view1 : _missingView);

      Widget? view2;
      if (views.length > 1) view2 = views.elementAt(1).getView();
      widget.boxes.add(view2 is BoxView ? view2 : _missingView);
    }

    // ratio box1:box2. if 1, box 1 is 100% size
    var ratio = widget.model.ratio;
    if (ratio < 0) ratio = 0;
    if (ratio > 1) ratio = 1;
    var flex = (ratio * 1000).ceil();

    List<Widget> list = [];

    // left/top pane
    var box1 = _constrainBox(widget.boxes[0], flex);
    list.add(box1);

    // handle
    Widget handle = _buildHandle();
    list.add(handle);

    // right/bottom pane
    var box2 = _constrainBox(widget.boxes[1], 1000 - flex);
    list.add(box2);

    return list;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    theme = Theme.of(context);

    this.constraints = constraints;
    return BoxView(widget.model);
  }
}
