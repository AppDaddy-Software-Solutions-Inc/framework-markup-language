// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/animation/animation_helper.dart';
import 'package:fml/widgets/animation/animation_transition/rotate/rotate_transition_model.dart' as MODEL;
import 'package:fml/widgets/widget/widget_model.dart';

/// Animation View
///
/// Builds the View from model properties
class RotateTransitionView extends StatefulWidget
{
  final MODEL.RotateTransitionModel model;
  final List<Widget> children = [];
  final Widget? child;
  final AnimationController controller;

  RotateTransitionView(this.model, this.child, this.controller) : super(key: ObjectKey(model));

  @override
  RotateTransitionViewState createState() => RotateTransitionViewState();
}

class RotateTransitionViewState extends State<RotateTransitionView> with TickerProviderStateMixin implements IModelListener
{
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState()
  {
    super.initState();

    _controller = widget.controller;

  }

  @override
  didChangeDependencies()
  {
    // register model listener
    widget.model.registerListener(this);

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(RotateTransitionView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.model != widget.model))
    {
      // re-register model listeners
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }
  }

  @override
  void dispose()
  {

    // remove model listener
    widget.model.removeListener(this);

    super.dispose();
  }

  /// Callback to fire the [_AnimationViewState.build] when the [AnimationModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value}) {
    if (this.mounted) setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: builder);
  }

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Tween
    double from = widget.model.from;
    double to   = widget.model.to;
    double begin = widget.model.begin;
    double end   = widget.model.end;
    Curve curve = AnimationHelper.getCurve(widget.model.curve);

    //start, end, center
    Alignment _align = toAlignment(widget.model.align?.toLowerCase());

    // we must check from != to and begin !< end

    if(begin != 0.0 || end != 1.0) {
      _animation = Tween<double>(begin: from, end: to,
      ).animate(CurvedAnimation(
        curve: new Interval(
          begin,
          end,
          // the style curve to pass.
          curve: curve,
        ),
        parent: _controller,
      ));
    } else {
      _animation = Tween<double>(begin: from, end: to,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: curve,
      ));
    }


    // Build View
    Widget? view;

    view = RotationTransition(
      alignment: _align,
      turns: _animation,
      child: widget.child,
    );

    // Return View
    return view;
  }

  Alignment toAlignment(String? alignment) {
    switch (alignment) {
      case 'top':
      case 'topcenter':
      case 'centertop':
        return Alignment.topCenter;
      case 'bottom':
      case 'bottomcenter':
      case 'centerbottom':
        return Alignment.bottomCenter;
      case 'left':
      case 'leftcenter':
      case 'centerleft':
        return Alignment.centerLeft;
      case 'right':
      case 'rightcenter':
      case 'centerright':
        return Alignment.centerRight;
      case 'topleft':
      case 'lefttop':
        return Alignment.topLeft;
      case 'topright':
      case 'righttop':
        return Alignment.topRight;
      case 'bottomleft':
      case 'leftbottom':
        return Alignment.bottomLeft;
      case 'bottomright':
      case 'rightbottom':
        return Alignment.bottomRight;
      default:
        return Alignment.center;
    }
  }



}
