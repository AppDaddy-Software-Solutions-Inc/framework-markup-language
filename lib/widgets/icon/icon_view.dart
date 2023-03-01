// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/animation/animation_view.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/icon/icon_model.dart';
import 'dart:math' as math;

import 'package:visibility_detector/visibility_detector.dart';

class IconView extends StatefulWidget
{
  final IconModel model;

  IconView(this.model) : super(key: ObjectKey(model));

  @override
  _IconViewState createState() => _IconViewState();
}

class _IconViewState extends State<IconView> implements IModelListener
{
  @override
  void initState()
  {
    super.initState();

    
   widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    widget.model.initialize();
  }

  @override
  didChangeDependencies()
  {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(IconView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    
    if ((oldWidget.model != widget.model))
    {
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }

  }

  @override
  void dispose()
  {
    widget.model.removeListener(this);

    super.dispose();
  }
  /// Callback function for when the model changes, used to force a rebuild with setState()
  onModelChange(WidgetModel model,{String? property, dynamic value})
  {
    if (this.mounted) setState((){});
  }

  @override
  Widget build(BuildContext context)
  {
    return LayoutBuilder(builder: builder);
  }

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Set Build Constraints in the [WidgetModel]
    widget.model.minWidth  = constraints.minWidth;
    widget.model.maxWidth  = constraints.maxWidth;
    widget.model.minHeight = constraints.minHeight;
    widget.model.maxHeight = constraints.maxHeight;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    IconData? value  = widget.model.icon;

    double? size = 32;
    if (widget.model.size != null) size = widget.model.size;

    ///////////
    /* Color */
    ///////////
    Color? color = Theme.of(context).colorScheme.inverseSurface;
    if (widget.model.color != null) color = widget.model.color;
    if (widget.model.opacity != null) color = color!.withOpacity(widget.model.opacity!);

    // view
    Widget view = Icon(value, size: size, color: color);

    // rotation
    if (widget.model.rotation != 0) view = Transform.rotate(angle: widget.model.rotation * math.pi / 180, child: view);

    // wrap in animation?
    if (widget.model.animations.isNotEmpty)
    {
      var animations = widget.model.animations.reversed;
      animations.forEach((element)
      {
        var model = widget.model.getAnimationModel(element);
        if (model != null) view = AnimationView(model, view);
      });
    };

    // wrap in visibility detector
    if (widget.model.needsVisibilityDetector) view = VisibilityDetector(key: ObjectKey(widget.model), onVisibilityChanged: widget.model.onVisibilityChanged, child: view);

    return view;
  }
}
