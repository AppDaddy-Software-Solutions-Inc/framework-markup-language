// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fml/widgets/animation/animation_helper.dart';
import 'package:fml/widgets/animation/animation_child/flip/flip_card_model.dart'
    as MODEL;
import 'package:fml/widgets/widget/widget_model.dart';

/// Animation View
///
/// Builds the View from model properties
class FlipCardView extends StatefulWidget {
  final MODEL.FlipCardModel model;
  final List<Widget> children = [];
  final Widget? child;
  final AnimationController controller;

  FlipCardView(this.model, this.child, this.controller)
      : super(key: ObjectKey(model));

  @override
  FlipCardViewState createState() => FlipCardViewState();
}

class FlipCardViewState extends State<FlipCardView>
    with TickerProviderStateMixin
    implements IModelListener {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.addListener(() {setState(() {

    });});
  }

  @override
  didChangeDependencies() {
    // register model listener
    widget.model.registerListener(this);

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(FlipCardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.model != widget.model)) {
      // re-register model listeners
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }
  }

  @override
  void dispose() {
    // remove model listener
    widget.model.removeListener(this);

    super.dispose();
  }

  /// Callback to fire the [_AnimationViewState.build] when the [AnimationModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value}) {
    if (this.mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: builder);
  }

  Widget builder(BuildContext context, BoxConstraints constraints) {
    double _begin = widget.model.begin;
    double _end = widget.model.end;
    Curve _curve = AnimationHelper.getCurve(widget.model.curve);
    // Build View
    Widget? view;
    Alignment anchor =
        AnimationHelper.getAlignment(widget.model.anchor.toLowerCase());
    Widget? frontWidget;
    Widget? backWidget;
    double _from;
    double _to;
    Tween<double> _newTween;

    if (_begin != 0.0 || _end != 1.0) {
      _curve = Interval(
        _begin,
        _end,
        // the style curve to pass.
        curve: _curve,
      );
    }

    _from = widget.model.from;
    _to = widget.model.to;
    _newTween = Tween<double>(
      begin: _from,
      end: _to,
    );

    if (_begin != 0.0 || _end != 1.0) {
      _curve = Interval(
        _begin,
        _end,
        // the style curve to pass.
        curve: _curve,
      );
    }

    _animation = _newTween.animate(CurvedAnimation(
      curve: _curve,
      parent: _controller,
    ));

    //get front and back widgets.

    // frontWidget = widget.firstLevelChildren?.elementAt(0);
    // backWidget =  widget.firstLevelChildren?.elementAt(1);

    view = Stack(
      alignment: anchor,
      fit: StackFit.passthrough,
      children:[ _buildContent(
          frontWidget: frontWidget ?? Container(),
          backWidget: backWidget ?? Container(),
      )]);

    return view;
  }

  Widget _buildContent({required Widget frontWidget, required Widget backWidget}) {
    /// pointer events that would reach the backside of the card should be
        return Transform(
          alignment: FractionalOffset.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(pi * _animation.value),
          child: Card(
            child: _animation.value <= 0.5
                ? frontWidget
                : backWidget,
          ),
        );
  }
}
