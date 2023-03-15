// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:ui';
import 'package:fml/helper/common_helpers.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/scroller/scroller_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/box/box_model.dart' as BOX;
import 'package:fml/widgets/widget/widget_state.dart';

/// [BOX] view
class BoxView extends StatefulWidget implements IWidgetView
{
  final BOX.BoxModel model;
  final Widget? child;

  BoxView(this.model, {this.child});

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
  bool isGradient = false;

  @override
  Widget build(BuildContext context)
  {
    return LayoutBuilder(builder: builder);
  }

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    //String? _id = widget.model.id;

    // Check if widget is visible before wasting resources on building it
    if (widget.model.visible == false) return Offstage();

    // Set Build Constraints in the [WidgetModel]
    widget.model.minWidth  = constraints.minWidth;
    widget.model.maxWidth  = constraints.maxWidth  - ((S.toDouble(widget.model.borderwidth) ?? 0) * 2);
    widget.model.minHeight = constraints.minHeight - ((S.toDouble(widget.model.borderwidth) ?? 0) * 2);
    widget.model.maxHeight = constraints.maxHeight;

    // get colors
    Color?  color  = widget.model.color;
    Color?  color2 = widget.model.color2;
    Color?  color3 = widget.model.color3;
    Color?  color4 = widget.model.color4;

    //var mainAxisSize = widget.model.expand == true ? MainAxisSize.min : MainAxisSize.max;

    // gradient
    if ((color != null) && (color2 != null)) isGradient = true;

    // Child
    List<Widget> children = [];
    if (widget.model.children != null)
      widget.model.children!.forEach((model) 
      {
        if (model is IViewableWidget) {
          children.add((model as IViewableWidget).getView());
        }
      });

    if (children.isEmpty) children.add(Container(width: 0, height: 0));

    //this must go after the children are determined
    Map<String, dynamic> align = AlignmentHelper.alignWidgetAxis(
        children.length,
        widget.model.layout,
        widget.model.center,
        widget.model.halign,
        widget.model.valign);

    CrossAxisAlignment? crossAlignment = align['crossAlignment'];
    MainAxisAlignment? mainAlignment = align['mainAlignment'];
    WrapAlignment? mainWrapAlignment = align['mainWrapAlignment'];
    WrapCrossAlignment? crossWrapAlignment = align['crossWrapAlignment'];
    Alignment? aligned = align['aligned'];

    // Setting aligned on widgets with BoxFit (images) causes layout issues
    // so ignore the default (Alignment.topLeft) 
    if (aligned == Alignment.topLeft) aligned = null;

    // set alignment if only a single child or a stack
    // TODO: consider adding scroll attribute scroll=true/false to match with the layout==row/col && expand==false;
    // return no row/col if only a single child and NOT stack
    // Flex: I removed the single child feature and just used a default column, result: not expanding to parent anymore
    dynamic child;

    // Constrained?
    bool expand = widget.model.expand;
    double? height = widget.model.height;
    double? width = widget.model.width;

    var constr = widget.model.getConstraints();

    ScrollerModel? scrollerModel = widget.model.findParentOfExactType(ScrollerModel);

    if (scrollerModel != null && expand == true)
    {
      expand = false;
      if(scrollerModel.layout == "col" || scrollerModel.layout == "column") width ??= constr.maxWidth;
      if(scrollerModel.layout == "row") height ??= constr.maxHeight;
    }

    if (expand == false && height != null && width != null) expand = true;

    if (children.length == 1 && widget.model.layout != 'stack')
    {
      child = children[0];
    }

    else if (widget.model.layout == 'column' || widget.model.layout == 'col')
    {
      //here we check if wrap is true and return the corresponding direction.
      if (widget.model.wrap == true)
        child = Wrap(
            children: children,
            direction: Axis.vertical,
            alignment: mainWrapAlignment!,
            runAlignment: mainWrapAlignment,
            crossAxisAlignment: crossWrapAlignment!);
      else
        child = Column(
          children: children,
          crossAxisAlignment: crossAlignment!,
          mainAxisAlignment: mainAlignment!,
        );
    }

    else if (widget.model.layout == 'row')
    {
      if (widget.model.wrap == true)
        child = Wrap(
            children: children,
            direction: Axis.horizontal,
            alignment: mainWrapAlignment!,
            runAlignment: mainWrapAlignment,
            crossAxisAlignment: crossWrapAlignment!);
      else child = Row(children: children, crossAxisAlignment: crossAlignment!, mainAxisAlignment: mainAlignment!);
    }

    // stack takes positioned but ignores layout attributes.
    else if (widget.model.layout == 'stack')
    {
      // We add a sizedbox.expand if expand is false to allow for stacks children to correctly align based on the alignment attribute.
      // SizedBox.expand crashes the layout if it is given to a contracting box.
      // expand must be grabbed in its form b
      if(expand == true) children.add(SizedBox.expand());
      child = aligned != null ? Stack(children: children, alignment: aligned, fit: StackFit.loose) : Stack(children: children, fit: StackFit.loose);
    }

    else child = Column(children: children, mainAxisAlignment: mainAlignment!, crossAxisAlignment: crossAlignment!);

    if (widget.child != null) child = widget.child;

    // Border?
    Border? border;
    bool hasBorder = widget.model.border != 'none';
    String? radius = widget.model.radius;
    if (hasBorder) {
      if (widget.model.border == 'all') {
        border = Border.all(
            color: widget.model.bordercolor ?? Theme.of(context).colorScheme.onInverseSurface,
            width: widget.model.borderwidth!);
      } else {
        border = Border(
          top: (widget.model.border == 'top' ||
                  widget.model.border == 'vertical')
              ? BorderSide(
                  width: widget.model.borderwidth!,
                  color: widget.model.bordercolor ?? Theme.of(context).colorScheme.onInverseSurface)
              : BorderSide(width: 0, color: Colors.transparent),
          bottom: (widget.model.border == 'bottom' ||
                  widget.model.border == 'vertical')
              ? BorderSide(
                  width: widget.model.borderwidth!,
                  color: widget.model.bordercolor ?? Theme.of(context).colorScheme.onInverseSurface)
              : BorderSide(width: 0, color: Colors.transparent),
          left: (widget.model.border == 'left' ||
                  widget.model.border == 'horizontal')
              ? BorderSide(
                  width: widget.model.borderwidth!,
                  color: widget.model.bordercolor ?? Theme.of(context).colorScheme.onInverseSurface)
              : BorderSide(width: 0, color: Colors.transparent),
          right: (widget.model.border == 'right' ||
                  widget.model.border == 'horizontal')
              ? BorderSide(
                  width: widget.model.borderwidth!,
                  color: widget.model.bordercolor ?? Theme.of(context).colorScheme.onInverseSurface)
              : BorderSide(width: 0, color: Colors.transparent),
        );
        radius = null;
      }
    }

    // border decoration
    List<String> cornersFromTopRightClockwise = [];
    List<double?> radii = [];
    try {
      if (radius != null) cornersFromTopRightClockwise = radius.split(',');
      if (cornersFromTopRightClockwise.length == 1) // round all the same
        radii =
            List<double?>.filled(4, S.toDouble(cornersFromTopRightClockwise[0]));
      else // round corners [NE, SE, SW, NW] based on csv
        radii = cornersFromTopRightClockwise.map((r) => S.toDouble(r)).toList();
    } catch(e) {
      // TODO LOG
      radii = List<double>.filled(4, 0);
    }

    BorderRadius? containerRadius = (radius != null)
        ? BorderRadius.only(
            topRight: Radius.circular(
                radii.asMap().containsKey(0) ? radii[0] ?? 0 : 0),
            bottomRight: Radius.circular(
                radii.asMap().containsKey(1) ? radii[1] ?? 0 : 0),
            bottomLeft: Radius.circular(
                radii.asMap().containsKey(2) ? radii[2] ?? 0 : 0),
            topLeft: Radius.circular(
                radii.asMap().containsKey(3) ? radii[3] ?? 0 : 0))
        : null;

    List<BoxShadow>? boxShadow = widget.model.elevation != 0
        ? [
            BoxShadow(
                color: widget.model.shadowcolor,
                spreadRadius: widget.model.elevation,
                blurRadius: widget.model.elevation * 2,
                offset: Offset(
                    widget.model.shadowx,
                    widget.model
                        .shadowy)), // potentially add shadowoffset to control this
          ]
        : null;

    BoxDecoration? decoration = BoxDecoration(
        borderRadius: containerRadius,
        boxShadow: boxShadow,
        color: isGradient ? null : color,
        gradient: isGradient
            ? LinearGradient(
                begin: BoxView.toGradientAlignment(widget.model.start)!,
                end: BoxView.toGradientAlignment(widget.model.end)!,
                colors: getGradientColors(color, color2, color3, color4),
                tileMode: TileMode.clamp) // Flutter doesn't display other TileModes correctly in skia web
            : null);

    BoxDecoration borderDeco = BoxDecoration(
        border: border,
        borderRadius: containerRadius);

    // View
    Widget view;

    // Padding values
    EdgeInsets insets = EdgeInsets.only();
    if (widget.model.paddings > 0)
    {
      // pad all
      if (widget.model.paddings == 1) insets = EdgeInsets.all(widget.model.padding);

      // pad directions v,h
      else if (widget.model.paddings == 2) insets = EdgeInsets.symmetric(vertical: widget.model.padding, horizontal: widget.model.padding2);

      // pad sides top, right, bottom
      else if (widget.model.paddings == 3) insets = EdgeInsets.only(top: widget.model.padding, left: widget.model.padding2, right: widget.model.padding2, bottom: widget.model.padding3);

      // pad sides top, right, bottom
      else if (widget.model.paddings == 4) insets = EdgeInsets.only(top: widget.model.padding, right: widget.model.padding2, bottom: widget.model.padding3, left: widget.model.padding4);
    }

    // if blur is true, blur the containers children.
    if (widget.model.blur) {
      view = Container(decoration: borderDeco, child: Container(
        padding: insets,
        clipBehavior: Clip.antiAlias,
        decoration: decoration,
        alignment: aligned,
        child: Stack(
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
                    decoration: borderDeco,
                    color: Colors.transparent,
                  ),
                ),
              ),
            ]),
      ));
    }
    else {
      view = Container(decoration: borderDeco, child: Container(
          padding: insets,
          clipBehavior: Clip.antiAlias, // .antiAlias - Flex: removed because of canvaskit assertion errors while scrolling ???
          decoration: decoration,
          //set alignment based on valign and halign.
          alignment: aligned,
          child: child));
    }

    // Opacity
    if (widget.model.opacity != null) {
      if (widget.model.opacity! > 1)
        widget.model.opacity = 1;
      else if (widget.model.opacity! < 0) widget.model.opacity = 0;
      view = Opacity(child: view, opacity: widget.model.opacity!);
    }

    // white10 = Blur (This creates mirrored/frosted effect overtop of something else)
    if (color == Colors.white10) {
      view = BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), child: view);
      if (containerRadius != null && radius != null)
        view = ClipRRect(borderRadius: containerRadius, child: view);
      else
        view = ClipRect(child: view);
    }





    if (expand == false)
    {
        //unsure how to make this work with maxwidth/maxheight, as it should yet constraints always come in. What should it do? same with minwidth/minheight...
        if (width != null) {
          view = UnconstrainedBox(
            child: LimitedBox(
              maxWidth: constr.maxWidth!,
              child: ConstrainedBox(
                  child: view,
                  constraints: BoxConstraints(
                    minHeight: constr.minHeight!,
                    minWidth: constr.minWidth!,)),
            ),
          );
        } else if (height != null) {
          view = UnconstrainedBox(
            child: LimitedBox(
              maxHeight: constr.maxHeight!,
              child: ConstrainedBox(
                  child: view,
                  constraints: BoxConstraints(
                    minHeight: constr.minHeight!,
                    minWidth: constr.minWidth!,)),
            ),
          );
        }
        else {
          view = UnconstrainedBox(
              child:
              ConstrainedBox(
                  child: view,
                  constraints: BoxConstraints(
                    minHeight: constr.minHeight!,
                    minWidth: constr.minWidth!,))
          );
        }

      } else {
        view = ConstrainedBox(
            child: view,
            constraints: BoxConstraints(
                minHeight: constr.minHeight!,
                maxHeight: constr.maxHeight!,
                minWidth: constr.minWidth!,
                maxWidth: constr.maxWidth!));
      }

      return view;
    }
}
