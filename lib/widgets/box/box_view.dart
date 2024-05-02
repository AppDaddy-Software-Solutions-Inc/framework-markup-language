// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fml/widgets/alignment/alignment.dart';
import 'package:fml/widgets/box/box_layout.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/box/decoration/decoration_clipper.dart';
import 'package:fml/widgets/box/decoration/labelled_box.dart';
import 'package:fml/widgets/box/flex/flex_object.dart';
import 'package:fml/widgets/box/stack/stack_object.dart';
import 'package:fml/widgets/box/wrap/wrap_object.dart';
import 'package:fml/widgets/drawer/drawer_model.dart';
import 'package:fml/widgets/drawer/drawer_view.dart';
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'package:fml/widgets/widget/model.dart';

typedef Builder = List<Widget> Function(BuildContext context, BoxConstraints constraints);

/// [BOX] view
class BoxView extends StatefulWidget implements ViewableWidgetView {

  @override
  final BoxModel model;
  final Builder builder;

  BoxView(this.model, this.builder, {Key? key}) : super(key: key ?? ObjectKey(model));

  @override
  State<BoxView> createState() => BoxViewState();
}

class BoxViewState extends ViewableWidgetState<BoxView> {

  List<Widget>? children;

  /// Function to find gradient alignment
  static Alignment? _toGradientAlignment(String? alignment) {
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

  static List<Color> getGradientColors(c1, c2, c3, c4) {
    List<Color> gradientColors = [];
    if (c1 != null) gradientColors.add(c1);
    if (c2 != null) gradientColors.add(c2);
    if (c3 != null) gradientColors.add(c3);
    if (c4 != null) gradientColors.add(c4);
    return gradientColors;
  }

  static Border? _getBorder(BoxModel model, BuildContext context) {

    // set theme
    var theme = Theme.of(context);

    // no border
    if (model.border == 'none') return null;

    var width = model.borderWidth;
    var color = model.borderColor ?? theme.colorScheme.onInverseSurface;

    // simple border on all sides
    if (model.border == 'all') {
      return Border.all(color: color, width: width);
    }

    var defaultBorder = const BorderSide(width: 1, color: Colors.transparent);

    // top border
    var top = (model.border == 'top' ||
        model.border == 'vertical')
        ? BorderSide(
        width: width,
        color: color)
        : defaultBorder;

    // bottom border
    var bottom = (model.border == 'bottom' ||
        model.border == 'vertical')
        ? BorderSide(width: width, color: color)
        : defaultBorder;

    // left border
    var left =  (model.border == 'left' ||
        model.border == 'horizontal')
        ? BorderSide(width: width, color: color)
        : defaultBorder;

    // right border
    var right = (model.border == 'right' ||
        model.border == 'horizontal')
        ? BorderSide(width: width, color: color)
        : defaultBorder;

    // return border
    return Border(top: top, bottom: bottom, left: left, right: right);
  }

  static BoxShadow? _getShadow(BoxModel model) {
    var elevation = (model.elevation ?? 0);
    if (elevation > 0) {
      return BoxShadow(
          color: model.shadowColor,
          spreadRadius: elevation,
          blurRadius: elevation * 2,
          offset: Offset(model.shadowX, model.shadowY));
    }
    return null;
  }

  static _getBoxDecoration(BoxModel model, BorderRadius? radius) {
    // shadow
    BoxShadow? boxShadow = _getShadow(model);

    // get colors
    Color? color = model.color;
    Color? color2 = model.color2;
    Color? color3 = model.color3;
    Color? color4 = model.color4;

    // gradient
    LinearGradient? gradient;
    if ((color != null) && (color2 != null)) {
      gradient = LinearGradient(
          begin: _toGradientAlignment(model.gradientStart)!,
          end: _toGradientAlignment(model.gradientEnd)!,
          colors: getGradientColors(color, color2, color3, color4),
          tileMode: TileMode.clamp);

      color = null;
    }
    return BoxDecoration(
        borderRadius: radius,
        boxShadow: boxShadow != null ? [boxShadow] : null,
        color: color,
        gradient: gradient);
  }

  static Widget _getFadedView(BoxModel model, Widget view) {
    double? opacity = model.opacity;
    if (opacity == null) return view;
    if (opacity > 1) opacity = 1;
    if (opacity.isNegative) opacity = 0;
    return Opacity(opacity: opacity, child: view);
  }

  static Widget _getFrostedView(BoxModel model, Widget child, BorderRadius? radius) {
    Widget view = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), child: child);
    if (radius != null) {
      view = ClipRRect(borderRadius: radius, child: view);
    } else {
      view = ClipRect(child: view);
    }
    return view;
  }

  static Widget _getBlurredView(BoxModel model, Widget child, Decoration? decoration) {
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
  static Widget addPadding(BoxModel model, Widget view) {
    if (model.paddingTop != null) {
      var inset = EdgeInsets.only(
          top: model.paddingTop ?? 0,
          right: model.paddingRight ?? 0,
          bottom: model.paddingBottom ?? 0,
          left: model.paddingLeft ?? 0);
      view = Padding(padding: inset, child: view);
    }
    return view;
  }

  static Widget _buildInnerBox(BoxModel model, BuildContext context, Widget child, BoxConstraints constraints,
      BoxDecoration? decoration, Alignment? alignment, Clip clip) {
    Widget? view = child;

    // set expand
    var expand = model.expand;
    if (model.expandHorizontally && !constraints.hasBoundedWidth) {
      expand = false;
    }
    if (model.expandVertically && !constraints.hasBoundedHeight) {
      expand = false;
    }
    if (alignment != null && expand) {
      // a width factor of 1 forces the container alignment to fit the child's width
      // rather than expand to fill its parent
      double? widthFactor;
      if (!model.expandHorizontally) widthFactor = 1;

      // a height factor of 1 forces the container to shrink to its child's height
      // rather than expand to fill the parent
      double? heightFactor;
      if (!model.expandVertically) heightFactor = 1;

      view = Align(
          alignment: alignment,
          widthFactor: widthFactor,
          heightFactor: heightFactor,
          child: view);
    }

    if (decoration != null) {
      if (clip != Clip.none) {
        view = ClipPath(
            clipper: DecorationClipper(
                textDirection: Directionality.maybeOf(context),
                decoration: decoration),
            clipBehavior: clip,
            child: view);
      }
      view = DecoratedBox(decoration: decoration, child: view);
    }

    // wrapped drawer view?
    if (model.drawer != null) {
      view = _buildDrawers(model, view);
    }

    return view;
  }

  static Widget _buildOuterBox(BoxModel model, BuildContext context,
      Widget view, BorderRadius radius) {
    Border? border = _getBorder(model, context);
    if (border == null) return view;

    var hasLabel = model.borderLabel != null;
    if (hasLabel) {
      var lbl = TextModel(null, null,
          value: model.borderLabel, overflow: "ellipsis")
          .getView();
      var box = Container(child: view);
      return LabelledBorderContainer(box, lbl,
          decoration: BoxDecoration(border: border, borderRadius: radius));
    }

    return Container(
        decoration: BoxDecoration(border: border, borderRadius: radius),
        child: view);
  }

  static Widget _buildInnerContent(BoxModel model, WidgetAlignment alignment, List<Widget> children) {

    // create view
    Widget view;
    switch (model.layoutType) {
    // stack object
      case LayoutType.stack:
        view = StackObject(
          model: model,
          alignment: alignment.aligned,
          fit: StackFit.passthrough,
          clipBehavior: Clip.antiAlias,
          children: children,
        );
        break;

    // box object
      case LayoutType.row:
      case LayoutType.column:
      default:

      // axis direction
        var direction = model.layoutType == LayoutType.row
            ? Axis.horizontal
            : Axis.vertical;

        // wrap object
        if (model.wrap) {
          view = WrapObject(
              model: model,
              direction: direction,
              alignment: alignment.mainWrapAlignment,
              runAlignment: alignment.mainWrapAlignment,
              crossAxisAlignment: alignment.crossWrapAlignment,
              clipBehavior: Clip.antiAlias,
              children: children);
        }

        // flex object (row, column)
        else {
          view = FlexObject(
              model: model,
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

  static Widget _buildDrawers(BoxModel model, Widget view) {
    // drawer defined
    if (model.drawer == null) return view;

    // wrap view in stacked view
    var drawer = DrawerView(model.drawer!, view);

    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => Model.unfocus(),
        onVerticalDragStart: (dragStartDetails) =>
            drawer.onDragStart(dragStartDetails, DragDirection.vertical),
        onHorizontalDragStart: (dragStartDetails) =>
            drawer.onDragStart(dragStartDetails, DragDirection.horizontal),
        onVerticalDragUpdate: (dragUpdateDetails) =>
            drawer.onDragging(dragUpdateDetails, DragDirection.vertical, true),
        onHorizontalDragUpdate: (dragUpdateDetails) =>
            drawer.onDragging(dragUpdateDetails, DragDirection.horizontal, true),
        onVerticalDragEnd: (dragEndDetails) =>
            drawer.onDragEnd(dragEndDetails, DragDirection.vertical, false),
        onHorizontalDragEnd: (dragEndDetails) =>
            drawer.onDragEnd(dragEndDetails, DragDirection.horizontal, false),
        child: drawer);
  }

  // applies padding around the of the box
  static Widget _addPadding(BoxModel model, Widget view) {
    if (model.paddingTop != null) {
      var inset = EdgeInsets.only(
          top: model.paddingTop ?? 0,
          right: model.paddingRight ?? 0,
          bottom: model.paddingBottom ?? 0,
          left: model.paddingLeft ?? 0);
      view = Padding(padding: inset, child: view);
    }
    return view;
  }

  // build a decorated box around the specified child
  static Widget _buildView(BuildContext context, BoxConstraints constraints, BoxModel model, List<Widget> children) {

    // wrap inner children in layout box
    List<Widget> list = [];
    for (var child in children) {
      var model = (child is ViewableWidgetView) ? (child as ViewableWidgetView).model : null;
      list.add(model != null ? BoxLayout(model: model, child: child) : child);
    }
    children = list;

    // calculate the alignment
    var alignment = WidgetAlignment(model.layoutType,
        model.center, model.halign, model.valign);

    // build the inner content
    Widget view = _buildInnerContent(model, alignment, children);

    // add padding around inner content
    view = _addPadding(model, view);

    // get the border radius
    BorderRadius? radius = BorderRadius.only(
        topRight: Radius.circular(model.radiusTopRight),
        bottomRight: Radius.circular(model.radiusBottomRight),
        bottomLeft: Radius.circular(model.radiusBottomLeft),
        topLeft: Radius.circular(model.radiusTopLeft));

    // build the box decoration
    BoxDecoration? decoration = _getBoxDecoration(model, radius);

    // blur the view
    if (model.blur) view = _getBlurredView(model, view, decoration);

    // build the inner content box
    view = _buildInnerBox(model, context,
        view, constraints, decoration, alignment.aligned, Clip.antiAlias);

    // build the outer border box
    view = _buildOuterBox(model, context, view, radius);

    // set the view opacity
    if (model.opacity != null) view = _getFadedView(model, view);

    // blur the view - white10 = Blur (This creates mirrored/frosted effect overtop of something else)
    if (model.color == Colors.white10) {
      view = _getFrostedView(model, view, radius);
    }

    return view;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints) {

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    // set system sizing
    // this may no necessary in the future
    onLayout(constraints);

    // rebuild content?
    children = widget.builder(context, constraints);

    // build the box
    var view = _buildView(context, constraints, widget.model, children!);

    // add margins
    view = addMargins(view);

    // apply visual transforms
    view = applyTransforms(view);

    // apply constraints
    view = applyConstraints(view, widget.model.constraints);

    return view;
  }
}
