// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/animation/animation_helper.dart';
import 'package:fml/widgets/animation/animation_child/size/size_transition_model.dart'
    as MODEL;
import 'package:fml/widgets/widget/widget_model.dart';

/// Animation View
///
/// Builds the View from model properties
class SizeTransitionView extends StatefulWidget {
  final MODEL.SizeTransitionModel model;
  final List<Widget> children = [];
  final Widget? child;
  final AnimationController controller;

  SizeTransitionView(this.model, this.child, this.controller)
      : super(key: ObjectKey(model));

  @override
  SizeTransitionViewState createState() => SizeTransitionViewState();
}

class SizeTransitionViewState extends State<SizeTransitionView>
    with TickerProviderStateMixin
    implements IModelListener {
  late AnimationController _controller;
  late Animation<double> _animation;

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
  void didUpdateWidget(SizeTransitionView oldWidget) {
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
    double _from = widget.model.from;
    double _to = widget.model.to;
    double _begin = widget.model.begin;
    double _end = widget.model.end;
    Curve _curve = AnimationHelper.getCurve(widget.model.curve);
    //
    Axis _direction = widget.model.size?.toLowerCase() == "height"
        ? Axis.vertical
        : Axis.horizontal;
    //start, end, center
    double _align = widget.model.align?.toLowerCase() == "start"
        ? -1
        : widget.model.align?.toLowerCase() == "end"
            ? 1
            : 0;
    Tween<double> _newTween = Tween<double>(
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
    // Build View
    Widget? view;

    view = SizeTransition(
      sizeFactor: _animation,
      axis: _direction,
      axisAlignment: _align,
      child: widget.child,
    );

    // Return View
    return view;
  }
}
