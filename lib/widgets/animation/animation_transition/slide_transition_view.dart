// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/animation/animation_transition/slide_transition_model.dart' as MODEL;
import 'package:fml/widgets/widget/widget_model.dart';

/// Animation View
///
/// Builds the View from model properties
class SlideTransitionView extends StatefulWidget
{
  final MODEL.SlideTransitionModel model;
  final List<Widget> children = [];
  final Widget? child;
  final AnimationController controller;

  SlideTransitionView(this.model, this.child, this.controller) : super(key: ObjectKey(model));

  @override
  FadeTransitionViewState createState() => FadeTransitionViewState();
}

class FadeTransitionViewState extends State<SlideTransitionView> with TickerProviderStateMixin implements IModelListener
{
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState()
  {
    super.initState();

    _controller = widget.controller;
    // Tween
    double from = widget.model.from;
    double to   = widget.model.to;
    double begin = widget.model.begin;
    double end   = widget.model.end;
    Curve curve = widget.model.getCurve();

    // we must check from != to and begin !< end

    if(begin != 0.0 || end != 1.0) {
      _animation = Tween<Offset>(begin: Offset(from, from), end: Offset(to, to),
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
      _animation = Tween<Offset>(begin: Offset(from, from), end: Offset(to, to),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: curve,
      ));
    }


  }

  @override
  didChangeDependencies()
  {
    // register model listener
    widget.model.registerListener(this);

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(SlideTransitionView oldWidget)
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
    // remove controller
    _controller.dispose();

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
    // Build View
    Widget? view;

    view = SlideTransition(
      position: _animation,
      child: widget.child,
    );

    // Return View
    return view;
  }


}
