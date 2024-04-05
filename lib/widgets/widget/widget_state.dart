import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/viewable/viewable_widget_mixin.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/widgets/widget/widget_model_interface.dart';
import 'package:fml/widgets/widget/widget_model.dart';

abstract class WidgetState<T extends StatefulWidget> extends State<T>
    implements IModelListener {
  ViewableWidgetMixin? get model =>
      (widget is IWidgetView) ? (widget as IWidgetView).model : null;

  @override
  void initState() {
    super.initState();
    model?.registerListener(this);
    model?.initialize();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(dynamic oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget is IWidgetView && oldWidget.model != model) {
      oldWidget.model?.removeListener(this);
      model?.registerListener(this);
    }
  }

  @override
  void dispose() {
    model?.removeListener(this);
    super.dispose();
  }

  @override
  onModelChange(WidgetModel model, {String? property, dynamic value}) {
    try {
      if (mounted) setState(() {});
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
    }
  }

  /// applies trabnsforms like rotate, flip, etc.
  Widget applyTransforms(Widget view) {

    // opacity
    if (model?.opacity != null) {
      view = Opacity(opacity: model!.opacity!, child: view);
    }

    // rotation
    if (model?.rotation != null) {
      view = Transform.rotate(
          angle: model!.rotation! * pi / 180,
          child: view);
    }

    // flip
    if (model?.flip != null) {
      switch (model?.flip?.toLowerCase()){
        case 'vertical':
          view = Transform.scale(scaleY: -1, child: view);
          break;
        case 'horizontal':
          view = Transform.scale(scaleX: -1, child: view);
          break;
      }
    }

    return view;
  }

    /// applies margins to the view based on the widget model
  Widget addMargins(Widget view) {
    if (model?.marginTop != null ||
        model?.marginBottom != null ||
        model?.marginRight != null ||
        model?.marginLeft != null) {
      var inset = EdgeInsets.only(
          top: model?.marginTop ?? 0,
          right: model?.marginRight ?? 0,
          bottom: model?.marginBottom ?? 0,
          left: model?.marginLeft ?? 0);
      view = Padding(padding: inset, child: view);
    }
    return view;
  }

  /// This routine applies the given constraints to the supplied
  /// view and then returns a widget with the view wrapped in those
  /// constraints
  Widget applyConstraints(Widget view, Constraints constraints) {
    // If no constraints are specified
    // return the view
    if (constraints.isEmpty) return view;

    // if parent is a Box Model these constraints
    // have already been applied
    if (this.model?.parent is BoxModel) return view;

    // Apply min and max constraints to the view only if
    // they are supplied and have not already been applied using
    // width and/or height
    if ((constraints.minWidth ?? 0) > 0 ||
        (constraints.maxWidth ?? double.infinity) < double.infinity ||
        (constraints.minHeight ?? 0) > 0 ||
        (constraints.maxHeight ?? double.infinity) < double.infinity) {
      var box = BoxConstraints(
          minWidth: constraints.minWidth ?? 0,
          maxWidth: constraints.maxWidth ?? double.infinity,
          minHeight: constraints.minHeight ?? 0,
          maxHeight: constraints.maxHeight ?? double.infinity);
      view = ConstrainedBox(constraints: box, child: view);
    }

    // If a width is specified
    // wrap the view in an unconstrained box of the specified
    // width and allow existing vertical constraints
    if (constraints.width != null && constraints.height == null) {
      view = UnconstrainedBox(
          constrainedAxis: Axis.vertical,
          child: SizedBox(width: constraints.width, child: view));
    }

    // If a height is specified
    // wrap the view in an unconstrained box of the specified
    // height and allow existing horizontal constraints
    else if (constraints.width == null && constraints.height != null) {
      view = UnconstrainedBox(
          constrainedAxis: Axis.horizontal,
          child: SizedBox(height: constraints.height, child: view));
    }

    // If both width and height are specified
    // wrap the view in an unconstrained box of the specified
    // width and height
    else if (constraints.width != null && constraints.height != null) {
      view = UnconstrainedBox(
          child: SizedBox(
              width: constraints.width,
              height: constraints.height,
              child: view));
    }

    return view;
  }

  void onLayout(BoxConstraints constraints) {
    model?.setLayoutConstraints(constraints);
    //WidgetsBinding.instance.addPostFrameCallback((_) => model?.onLayoutComplete(model));
  }
}
