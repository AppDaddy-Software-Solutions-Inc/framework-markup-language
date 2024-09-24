// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'package:fml/widgets/icon/icon_model.dart';

class IconView extends StatefulWidget implements ViewableWidgetView {
  @override
  final IconModel model;

  IconView(this.model) : super(key: ObjectKey(model));

  @override
  State<IconView> createState() => _IconViewState();
}

class _IconViewState extends ViewableWidgetState<IconView> {

  @override
  Widget build(BuildContext context) {

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    IconData? value = widget.model.icon;

    // icon's size can be expressed as a %
    // Don't use layoutBuilder() as this causes issues in popover
    // myMaxWidth traverses up the parent tree to find the max width constraint
    double? size = widget.model.size ?? 32;
    if (widget.model.widthPercentage != null) {
      size = (widget.model.widthPercentage! / 100) * widget.model.myMaxWidth;
    }

    // icon color
    Color? color = Theme.of(context).colorScheme.inverseSurface;
    if (widget.model.color != null) color = widget.model.color;
    if (widget.model.opacity != null) {
      color = color!.withOpacity(widget.model.opacity!);
    }

    // view
    Widget view = Icon(value, size: size, color: color);

    // add margins
    view = addMargins(view);

    // apply visual transforms
    view = applyTransforms(view);

    return view;
  }
}
