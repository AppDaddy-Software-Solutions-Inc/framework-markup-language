// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fml/widgets/animation/animation_helper.dart';
import 'package:fml/widgets/animation/animation_child/transform/transform_model.dart'
    as MODEL;
import 'package:fml/widgets/widget/widget_model.dart';

/// Animation View
///
/// Builds the View from model properties
class TransformView extends StatefulWidget {
  final MODEL.TransformModel model;
  final List<Widget> children = [];
  final Widget? child;
  final AnimationController controller;

  TransformView(this.model, this.child, this.controller)
      : super(key: ObjectKey(model));

  @override
  TransformViewState createState() => TransformViewState();
}

class TransformViewState extends State<TransformView>
    with TickerProviderStateMixin
    implements IModelListener {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller;
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  didChangeDependencies() {
    // register model listener
    widget.model.registerListener(this);

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(TransformView oldWidget) {
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
    // Tween

    double _begin = widget.model.begin;
    double _end = widget.model.end;
    Curve _curve = AnimationHelper.getCurve(widget.model.curve);
    Tween<double> _newTween = Tween<double>(
      begin: 0.25,
      end: 0.75,
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

    // Build View
    Widget? view;

    view = Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0001)
        ..rotateY(pi / 2 * (1 - _animation.value * 4))
        ..rotateX(pi / 2 * (1 - _animation.value * 4))
        ..translate(0.0, 0.0, 0.0),
      alignment: Alignment.centerLeft,
      //origin: Offset(0, 0),
      child: widget.child,
    );

    // Return View
    return view;
  }
}
