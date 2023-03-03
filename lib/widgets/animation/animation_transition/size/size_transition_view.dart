// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/animation/animation_transition/size/size_transition_model.dart' as MODEL;
import 'package:fml/widgets/widget/widget_model.dart';

/// Animation View
///
/// Builds the View from model properties
class SizeTransitionView extends StatefulWidget
{
  final MODEL.SizeTransitionModel model;
  final List<Widget> children = [];
  final Widget? child;
  final AnimationController controller;

  SizeTransitionView(this.model, this.child, this.controller) : super(key: ObjectKey(model));

  @override
  SizeTransitionViewState createState() => SizeTransitionViewState();
}

class SizeTransitionViewState extends State<SizeTransitionView> with TickerProviderStateMixin implements IModelListener
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
  void didUpdateWidget(SizeTransitionView oldWidget)
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
    Curve curve = widget.model.getCurve();
    //
    Axis _direction = widget.model.size?.toLowerCase() == "height" ? Axis.vertical : Axis.horizontal;
    //start, end, center
    double _align = widget.model.align?.toLowerCase() == "start" ? -1 :  widget.model.align?.toLowerCase() == "end" ? 1 : 0;


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
