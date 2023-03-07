// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/helper/string.dart';
import 'package:fml/widgets/animation/animation_helper.dart';
import 'package:fml/widgets/animation/animation_child/slide/slide_transition_model.dart'
    as SlideTransitionModel;
import 'package:fml/widgets/widget/widget_model.dart';

/// Animation View
///
/// Builds the View from model properties
class SlideTransitionView extends StatefulWidget {
  final SlideTransitionModel.AnimationModel model;
  final List<Widget> children = [];
  final Widget? child;
  final AnimationController controller;

  SlideTransitionView(this.model, this.child, this.controller)
      : super(key: ObjectKey(model));

  @override
  FadeTransitionViewState createState() => FadeTransitionViewState();
}

class FadeTransitionViewState extends State<SlideTransitionView>
    with TickerProviderStateMixin
    implements IModelListener {
  late AnimationController _controller;
  List<double> _defaultFrom = [-1, 0];
  late Animation<Offset> _animation;
  String? _direction;
  TextDirection? _align;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller;
  }

  @override
  didChangeDependencies() {
    // register model listener
    widget.model.registerListener(this);

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(SlideTransitionView oldWidget) {
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
    _direction = widget.model.direction?.toLowerCase();

    if (_direction == "right") {
      _align = TextDirection.ltr;
      _defaultFrom = [-1, 0];
    } else if (_direction == "left") {
      _align = TextDirection.rtl;
      _defaultFrom = [-1, 0];
    } else if (_direction == "up") {
      _defaultFrom = [0, 1];
    } else if (_direction == "down") {
      _defaultFrom = [0, -1];
    }

    // Tween
    List<String>? from = widget.model.from?.split(",");
    Offset fromOffset = Offset(
        S.toDouble(from?.elementAt(0)) ?? _defaultFrom[0],
        S.toDouble(from?.elementAt(1)) ?? _defaultFrom[1]);
    List<String>? to = widget.model.to.split(",");
    Offset toOffset = Offset(
        S.toDouble(to.elementAt(0)) ?? 0, S.toDouble(to.elementAt(1)) ?? 0);
    double _begin = widget.model.begin;
    double _end = widget.model.end;
    Curve _curve = AnimationHelper.getCurve(widget.model.curve);
    Tween<Offset> _newTween = Tween<Offset>(
      begin: fromOffset,
      end: toOffset,
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

    view = SlideTransition(
      position: _animation,
      textDirection: _align,
      child: widget.child,
    );

    // Return View
    return view;
  }
}
