// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:ui';
import 'package:fml/helper/common_helpers.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/layout/layout_model.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:fml/widgets/alignment/alignment.dart';

/// [BOX] view
class BoxView extends StatefulWidget implements IWidgetView
{
  final BoxModel model;

  BoxView(this.model) : super(key: ObjectKey(model));

  @override
  _BoxViewState createState() => _BoxViewState();

  /// Function to find gradient alignment
  static Alignment? toGradientAlignment(String? alignment) {
    Alignment? align;
    switch (alignment) {
      case 'top':
      case 'topcenter':
      case 'centertop':
        align = Alignment.topCenter;
        break;
      case 'bottom':
      case 'bottomcenter':
      case 'centerbottom':
        align = Alignment.bottomCenter;
        break;
      case 'left':
      case 'leftcenter':
      case 'centerleft':
        align = Alignment.centerLeft;
        break;
      case 'right':
      case 'rightcenter':
      case 'centerright':
        align = Alignment.centerRight;
        break;
      case 'topleft':
      case 'lefttop':
        align = Alignment.topLeft;
        break;
      case 'topright':
      case 'righttop':
        align = Alignment.topRight;
        break;
      case 'bottomleft':
      case 'leftbottom':
        align = Alignment.bottomLeft;
        break;
      case 'bottomright':
      case 'rightbottom':
        align = Alignment.bottomRight;
        break;
      default:
        align = null;
        break;
    }
    return align;
  }
}

List<Color> getGradientColors(c1, c2, c3, c4) {
  List<Color> gradientColors = [];
  if (c1 != null) gradientColors.add(c1);
  if (c2 != null) gradientColors.add(c2);
  if (c3 != null) gradientColors.add(c3);
  if (c4 != null) gradientColors.add(c4);
  return gradientColors;
}

class _BoxViewState extends WidgetState<BoxView>
{
  Border? _getBorder()
  {
    Border? border;
    bool hasBorder = widget.model.border != 'none';
    if (hasBorder)
    {
      if (widget.model.border == 'all')
      {
        border = Border.all(
            color: widget.model.bordercolor ?? Theme.of(context).colorScheme.onInverseSurface,
            width: widget.model.borderwidth);
      } else {
        border = Border(
          top: (widget.model.border == 'top' ||
              widget.model.border == 'vertical')
              ? BorderSide(
              width: widget.model.borderwidth,
              color: widget.model.bordercolor ?? Theme.of(context).colorScheme.onInverseSurface)
              : BorderSide(width: 0, color: Colors.transparent),
          bottom: (widget.model.border == 'bottom' ||
              widget.model.border == 'vertical')
              ? BorderSide(
              width: widget.model.borderwidth,
              color: widget.model.bordercolor ?? Theme.of(context).colorScheme.onInverseSurface)
              : BorderSide(width: 0, color: Colors.transparent),
          left: (widget.model.border == 'left' ||
              widget.model.border == 'horizontal')
              ? BorderSide(
              width: widget.model.borderwidth,
              color: widget.model.bordercolor ?? Theme.of(context).colorScheme.onInverseSurface)
              : BorderSide(width: 0, color: Colors.transparent),
          right: (widget.model.border == 'right' ||
              widget.model.border == 'horizontal')
              ? BorderSide(
              width: widget.model.borderwidth,
              color: widget.model.bordercolor ?? Theme.of(context).colorScheme.onInverseSurface)
              : BorderSide(width: 0, color: Colors.transparent),
        );
      }
    }
    return border;
  }

  BorderRadius? _getRadius(Border? border)
  {
    String? radius = widget.model.radius;
    if (radius == null) return null;
    if (border != null && widget.model.border != 'all') return null;

    // border decoration
    List<String> cornersFromTopRightClockwise = [];
    List<double?> radii = [];
    try
    {
      cornersFromTopRightClockwise = radius.split(',');
      if (cornersFromTopRightClockwise.length == 1) // round all the same
           radii = List<double?>.filled(4, S.toDouble(cornersFromTopRightClockwise[0]));
      else radii = cornersFromTopRightClockwise.map((r) => S.toDouble(r)).toList();
    }
    catch(e)
    {
      // TODO LOG
      radii = List<double>.filled(4, 0);
    }

    BorderRadius? containerRadius =
        BorderRadius.only(
        topRight: Radius.circular(
            radii.asMap().containsKey(0) ? radii[0] ?? 0 : 0),
        bottomRight: Radius.circular(
            radii.asMap().containsKey(1) ? radii[1] ?? 0 : 0),
        bottomLeft: Radius.circular(
            radii.asMap().containsKey(2) ? radii[2] ?? 0 : 0),
        topLeft: Radius.circular(
            radii.asMap().containsKey(3) ? radii[3] ?? 0 : 0));

    return containerRadius;
  }

  BoxShadow? _getShadow()
  {
    var elevation = (widget.model.elevation ?? 0);
    if (elevation > 0) return BoxShadow(color: widget.model.shadowcolor, spreadRadius: elevation, blurRadius: elevation * 2,
        offset: Offset(widget.model.shadowx, widget.model.shadowy));
    return null;
  }

  _getBoxDecoration(BorderRadius? radius)
  {
    // shadow
    BoxShadow? boxShadow = _getShadow();

    // get colors
    Color?  color  = widget.model.color;
    Color?  color2 = widget.model.color2;
    Color?  color3 = widget.model.color3;
    Color?  color4 = widget.model.color4;

    // gradient
    LinearGradient? gradient;
    if ((color != null) && (color2 != null))
    {
      gradient = LinearGradient(
        begin: BoxView.toGradientAlignment(widget.model.start)!,
        end: BoxView.toGradientAlignment(widget.model.end)!,
        colors: getGradientColors(color, color2, color3, color4),
        tileMode: TileMode.clamp);

      color = null;
    }
    return BoxDecoration(borderRadius: radius, boxShadow: boxShadow != null ? [boxShadow] : null, color: color, gradient: gradient);
  }

  Widget _getFadedView(Widget view)
  {
    double? opacity = widget.model.opacity;
    if (opacity == null) return view;
    if (opacity > 1) opacity = 1;
    if (opacity.isNegative) opacity = 0;
    return Opacity(child: view, opacity: opacity);
  }

  Widget _getFrostedView(Widget child, BorderRadius? radius)
  {
     Widget view = BackdropFilter(filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), child: child);
     if (radius != null)
          view = ClipRRect(borderRadius: radius, child: view);
     else view = ClipRect(child: view);
     return view;
  }

  Widget _getBlurredView(Widget child, Decoration? decoration)
  {
     return Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: <Widget>[
          child,
          ClipRect(
            clipBehavior: Clip.antiAlias,
            // <-- clips to the [Container] below
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: decoration,
                color: Colors.transparent,
              ),
            ),
          ),
        ]);
  }

  // applies padding around the of the box
  Widget addPadding(Widget view)
  {
    if (widget.model.paddingTop != null)
    {
      var inset = EdgeInsets.only(top: widget.model.paddingTop ?? 0, right: widget.model.paddingRight ?? 0, bottom: widget.model.paddingBottom ?? 0, left: widget.model.paddingLeft ?? 0);
      view = Padding(child: view, padding: inset);
    }
    return view;
  }

  Widget _applyConstraints(Widget view)
  {
    // apply model constraints
    view = applyConstraints(view, widget.model.constraints.model);

    // allow the box to shrink on any axis that is not expanding
    // this is done by applying an UnconstrainedBox() to the view
    // in the direction of the constrained axis
    if (!widget.model.expand) view = UnconstrainedBox(child: view);

    return view;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Check if widget is visible before wasting resources on building it
    if (widget.model.visible == false) return Offstage();

    // set system sizing
    onLayout(constraints);

    // this must go after the children are determined
    var alignment = WidgetAlignment(widget.model.layoutType, widget.model.center, widget.model.halign, widget.model.valign);

    // layout the children
    Widget content = widget.model.getContentView();

    // build the border
    Border? border = _getBorder();

    // build the border radius
    BorderRadius? radius = _getRadius(border);

    // build the box decoration
    BoxDecoration? decoration = _getBoxDecoration(radius);

    // build the box border decoration
    BoxDecoration? borderDecoration = border != null ? BoxDecoration(border: border, borderRadius: radius) : null;

    // blur the view
    if (widget.model.blur) content = _getBlurredView(content, borderDecoration);

    // add padding
    content = addPadding(content);

    // inner box - contents
    Widget view = Container(clipBehavior: Clip.antiAlias, decoration: decoration, alignment: alignment.aligned, child: content);

    // build the outer box - border
    if (borderDecoration != null) view = Container(decoration: borderDecoration, child: view);

    // set the box opacity
    if (widget.model.opacity != null) view = _getFadedView(view);

    // blur the view - white10 = Blur (This creates mirrored/frosted effect overtop of something else)
    if (widget.model.color == Colors.white10) view = _getFrostedView(view, radius);

    // add margins
    view = addMargins(view);

    // apply constraints
    view = _applyConstraints(view);

    return view;
  }
}
