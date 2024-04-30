// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'package:fml/widgets/widget/model.dart';
import 'link_model.dart';

class LinkView extends StatefulWidget implements ViewableWidgetView {
  @override
  final LinkModel model;
  LinkView(this.model) : super(key: ObjectKey(model));

  @override
  State<LinkView> createState() => _LinkViewState();
}

class _LinkViewState extends ViewableWidgetState<LinkView> {
  onTap() async {
    Model.unfocus();
    await widget.model.onClick(context);
  }

  onDoubleTap() async {
    Model.unfocus();
    await widget.model.onDoubleTap(context);
  }

  onLongPress() async {
    Model.unfocus();
    await widget.model.onLongPress(context);
  }

  @override
  Widget build(BuildContext context) {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    // column view
    Widget view = BoxView(widget.model, (_,__) => widget.model.inflate());

    // wrap in gesture detector
    if (widget.model.enabled) {
      view = GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          onDoubleTap: onDoubleTap,
          child: MouseRegion(cursor: SystemMouseCursors.click, child: view));
    }

    // build the child views
    return view;
  }
}
