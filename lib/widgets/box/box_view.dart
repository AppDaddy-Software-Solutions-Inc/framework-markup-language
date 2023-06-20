// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_data.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/box/flex/flex_object.dart';
import 'package:fml/widgets/box/stack/stack_object.dart';
import 'package:fml/widgets/box/wrap/wrap_object.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:fml/widgets/alignment/alignment.dart';

/// [BOX] view
class BoxView extends StatefulWidget implements IWidgetView
{
  @override
  final BoxModel model;
  final List<LayoutBoxChildData>? children;

  BoxView(this.model, {this.children}) : super(key: ObjectKey(model));

  @override
  State<BoxView> createState() => _BoxViewState();

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
    bool hasBorder = widget.model.border != null && widget.model.border != 'none';
    if (hasBorder)
    {
      var width = widget.model.borderwidth ?? 1;
      if (widget.model.border == 'all')
      {
        border = Border.all(
            color: widget.model.bordercolor ?? Theme.of(context).colorScheme.onInverseSurface,
            width: width);
      } else {
        border = Border(
          top: (widget.model.border == 'top' ||
              widget.model.border == 'vertical')
              ? BorderSide(
              width: width,
              color: widget.model.bordercolor ?? Theme.of(context).colorScheme.onInverseSurface)
              : BorderSide(width: 0, color: Colors.transparent),
          bottom: (widget.model.border == 'bottom' ||
              widget.model.border == 'vertical')
              ? BorderSide(
              width: width,
              color: widget.model.bordercolor ?? Theme.of(context).colorScheme.onInverseSurface)
              : BorderSide(width: 0, color: Colors.transparent),
          left: (widget.model.border == 'left' ||
              widget.model.border == 'horizontal')
              ? BorderSide(
              width: width,
              color: widget.model.bordercolor ?? Theme.of(context).colorScheme.onInverseSurface)
              : BorderSide(width: 0, color: Colors.transparent),
          right: (widget.model.border == 'right' ||
              widget.model.border == 'horizontal')
              ? BorderSide(
              width: width,
              color: widget.model.bordercolor ?? Theme.of(context).colorScheme.onInverseSurface)
              : BorderSide(width: 0, color: Colors.transparent),
        );
      }
    }
    return border;
  }

  BoxShadow? _getShadow()
  {
    var elevation = (widget.model.elevation ?? 0);
    if (elevation > 0) {
      return BoxShadow(color: widget.model.shadowcolor, spreadRadius: elevation, blurRadius: elevation * 2,
          offset: Offset(widget.model.shadowx, widget.model.shadowy));
    }
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
    if (radius != null) {
      view = ClipRRect(borderRadius: radius, child: view);
    } else {
      view = ClipRect(child: view);
    }
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

  Widget _buildInnerBox(Widget child,  BoxConstraints constraints, BoxDecoration? decoration, Alignment? alignment, Clip clip)
  {
    Widget? view = child;

    // set expand
    var expand = widget.model.expand;
    if (widget.model.expandHorizontally && !constraints.hasBoundedWidth)  expand = false;
    if (widget.model.expandVertically   && !constraints.hasBoundedHeight) expand = false;
    if (alignment != null && expand)
    {
      // a width factor of 1 forces the container alignment to fit the child's width
      // rather than expand to fill its parent
      double? widthFactor;
      if (!widget.model.expandHorizontally) widthFactor = 1;

      // a height factor of 1 forces the container to shrink to its child's height
      // rather than expand to fill the parent
      double? heightFactor;
      if (!widget.model.expandVertically) heightFactor = 1;

      view = Align(alignment: alignment, child: view, widthFactor: widthFactor, heightFactor: heightFactor);
    }

    if (decoration != null)
    {
      if (clip != Clip.none)
      {
        view = ClipPath(clipper: _DecorationClipper(textDirection: Directionality.maybeOf(context), decoration: decoration), clipBehavior: clip, child: view);
      }
      view = DecoratedBox(decoration: decoration, child: view);
    }

    return view;
  }

  Widget _buildInnerContent(BoxConstraints constraints, WidgetAlignment alignment)
  {
    /// Build the Layout
    var children = widget.children ?? widget.model.inflate();

    // create view
    Widget view;
    switch (widget.model.layoutType)
    {
      // stack object
      case LayoutType.stack:
        view = StackObject(
          model: widget.model,
          alignment: alignment.aligned,
          fit: StackFit.passthrough,
          clipBehavior: Clip.antiAlias,
          children: children,);
        break;

      // box object
      case LayoutType.row:
      case LayoutType.column:
      default:

        // axis direction
        var direction = widget.model.layoutType == LayoutType.row ? Axis.horizontal : Axis.vertical;

        // wrap object
        if (widget.model.wrap)
        {
          view = WrapObject(
              model: widget.model,
              direction: direction,
              alignment: alignment.mainWrapAlignment,
              runAlignment: alignment.mainWrapAlignment,
              crossAxisAlignment: alignment.crossWrapAlignment,
              clipBehavior: Clip.antiAlias,
              children: children);
        }

        // flex object (row, column)
        else
        {
          view = FlexObject(
              model: widget.model,
              direction: direction,
              mainAxisAlignment: alignment.mainAlignment,
              crossAxisAlignment: alignment.crossAlignment,
              clipBehavior: Clip.antiAlias,
              children: children);
        }
        break;
    }

    return view;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // set system sizing
    onLayout(constraints);

    // calculate the alignment
    var alignment = WidgetAlignment(widget.model.layoutType, widget.model.center, widget.model.halign, widget.model.valign);

    // build the inner content
    Widget view = _buildInnerContent(constraints, alignment);

    // add padding around inner content
    view = addPadding(view);

    // get the border
    Border? border = _getBorder();

    // get the border radius
    BorderRadius? radius = BorderRadius.only(
        topRight: Radius.circular(widget.model.radiusTopRight),
        bottomRight: Radius.circular(widget.model.radiusBottomRight),
        bottomLeft: Radius.circular(widget.model.radiusBottomLeft),
        topLeft: Radius.circular(widget.model.radiusTopLeft));

    // build the box decoration
    BoxDecoration? decoration = _getBoxDecoration(radius);

    // build the border decoration
    BoxDecoration? borderDecoration = border != null ? BoxDecoration(border: border, borderRadius: radius) : null;

    // blur the view
    if (widget.model.blur) view = _getBlurredView(view, borderDecoration);

    // build the inner content box
    view = _buildInnerBox(view, constraints, decoration, alignment.aligned, Clip.antiAlias);

    // build the outer border box
    if (borderDecoration != null) view = Container(child: view, decoration: borderDecoration);

    // set the view opacity
    if (widget.model.opacity != null) view = _getFadedView(view);

    // blur the view - white10 = Blur (This creates mirrored/frosted effect overtop of something else)
    if (widget.model.color == Colors.white10) view = _getFrostedView(view, radius);

    // apply constraints
    view = applyConstraints(view, widget.model.constraints);

    // add margins around the entire widget
    view = addMargins(view);

    return view;
  }
}

/// A clipper that uses [Decoration.getClipPath] to clip.
class _DecorationClipper extends CustomClipper<Path>
{
  _DecorationClipper({TextDirection? textDirection, required this.decoration,
  }) : textDirection = textDirection ?? TextDirection.ltr;

  final TextDirection textDirection;
  final Decoration decoration;

  @override
  Path getClip(Size size)
  {
    return decoration.getClipPath(Offset.zero & size, textDirection);
  }

  @override
  bool shouldReclip(_DecorationClipper oldClipper)
  {
    return oldClipper.decoration != decoration || oldClipper.textDirection != textDirection;
  }
}