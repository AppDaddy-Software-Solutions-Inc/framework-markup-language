// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'scroll_shadow_model.dart';

class ScrollShadowView extends StatefulWidget implements IWidgetView {
  @override
  final ScrollShadowModel model;

  ScrollShadowView(this.model) : super(key: ObjectKey(model));

  @override
  State<ScrollShadowView> createState() => _ScrollShadowViewState();
}

class _ScrollShadowViewState extends WidgetState<ScrollShadowView> {
  @override
  Widget build(BuildContext context) {
    var col = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).colorScheme.shadow.withOpacity(0.35)
        : Theme.of(context).colorScheme.shadow;

    List<Widget> moreShadows = [];
    // TODO - Create a better gui, ie: a rounded shadow with indicator icon
    Widget left = widget.model.left
        ? Positioned(
            left: 0,
            child: Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(blurRadius: 20, spreadRadius: 8, color: col)
                ]),
                width: 1,
                height: MediaQuery.of(context).size.height))
        : Container();
    Widget right = widget.model.right
        ? Positioned(
            right: 0,
            child: Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(blurRadius: 20, spreadRadius: 8, color: col)
                ]),
                width: 1,
                height: MediaQuery.of(context).size.height))
        : Container();
    Widget top = widget.model.up
        ? Positioned(
            top: 0,
            child: Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(blurRadius: 20, spreadRadius: 8, color: col)
                ]),
                height: 1,
                width: MediaQuery.of(context).size.width))
        : Container();
    Widget bottom = widget.model.down
        ? Positioned(
            bottom: 0,
            child: Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(blurRadius: 20, spreadRadius: 8, color: col)
                ]),
                height: 1,
                width: MediaQuery.of(context).size.width))
        : Container();

    moreShadows.addAll([top, bottom, left, right]);

    return Stack(children: moreShadows);
  }
}
