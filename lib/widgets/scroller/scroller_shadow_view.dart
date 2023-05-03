// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/system.dart';

/// [ScrollShadow] builds the [ScrollerView] "scroll for more" shadows on the top and bottom
class ScrollShadow extends StatefulWidget {
  final ScrollController scrollController;
  final String pos;
  final Axis axis;
  final Color? shadowColor;
  ScrollShadow(this.scrollController, this.pos, this.axis, [this.shadowColor]);

  @override
  _ScrollShadowState createState() => _ScrollShadowState();
}

class _ScrollShadowState extends State<ScrollShadow> {
  bool _needShadowOnTop = false;
  bool _needShadowOnBottom = false;

  @override
  void initState() {
    widget.scrollController.addListener(_updateShadowsVisibility);
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _updateShadowsVisibility());
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_updateShadowsVisibility);
    super.dispose();
  }

  void _updateShadowsVisibility() {
    bool top;
    bool bottom;
    if (!widget.scrollController.hasClients) {
      if (widget.scrollController.initialScrollOffset > 0) {
        top = true;
        bottom = true;
      } else {
        top = false;
        bottom = true;
      }
    } else if (widget.scrollController.position.atEdge) {
      if (widget.scrollController.position.pixels ==
          widget.scrollController.position.minScrollExtent) {
        top = false;
      } else {
        top = true;
      }
      if (widget.scrollController.position.pixels ==
          widget.scrollController.position.maxScrollExtent) {
        bottom = false;
      } else {
        bottom = true;
      }
    } else {
      top = bottom = true;
    }
    if (_needShadowOnTop != top || _needShadowOnBottom != bottom) {
      // Calling setState only rebuilds this widget, not child unless it was changed
      setState(() {
        _needShadowOnTop = top;
        _needShadowOnBottom = bottom;
      });
    }
  }

  @override
  Widget build(BuildContext context)
  {
    // Remove shadows on mobile web.
    if (System().userplatform == 'web' && (System().useragent == 'android' || System().useragent == 'ios')) {
      return Offstage();
    }
    Positioned shadow;
    var col =
    widget.shadowColor as bool? ?? Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).colorScheme.shadow.withOpacity(0.40)
        : Theme.of(context).colorScheme.shadow;
    if (widget.axis == Axis.vertical) {
      shadow = widget.pos == 'top'
          ? Positioned(
        top: 0,
        child: Container(
          height: 0,
          width: MediaQuery.of(context).size.width,
          decoration: _needShadowOnTop
              ? BoxDecoration(boxShadow: [
            BoxShadow(color: col, spreadRadius: 3, blurRadius: 8)
          ])
              : BoxDecoration(),
        ),
      )
      // Shadow on bottom
          : Positioned(
        bottom: 0,
        child: Container(
          height: 0,
          width: MediaQuery.of(context).size.width,
          decoration: _needShadowOnBottom
              ? BoxDecoration(boxShadow: [
            BoxShadow(color: col, spreadRadius: 6, blurRadius: 10)
          ])
              : BoxDecoration(),
        ),
      );
    } else {
      shadow = widget.pos == 'top'
          ? Positioned(
        left: 0,
        child: Container(
          width: 0,
          height: MediaQuery.of(context).size.height,
          decoration: _needShadowOnTop
              ? BoxDecoration(boxShadow: [
            BoxShadow(color: col, spreadRadius: 3, blurRadius: 8)
          ])
              : BoxDecoration(),
        ),
      )
          : Positioned(
        right: 0,
        child: Container(
          width: 0,
          height: MediaQuery.of(context).size.height,
          decoration: _needShadowOnBottom
              ? BoxDecoration(boxShadow: [
            BoxShadow(color: col, spreadRadius: 3, blurRadius: 8)
          ])
              : BoxDecoration(),
        ),
      );
    }
    return shadow;
  }
}
