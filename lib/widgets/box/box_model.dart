// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_data.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:fml/widgets/modal/modal_model.dart';
import 'package:fml/widgets/positioned/positioned_view.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

enum LayoutType { none, row, column, stack }

enum VerticalAlignmentType { top, bottom, center, around, between, evenly }

enum HorizontalAlignmentType { left, right, center, around, between, evenly }

class BoxModel extends DecoratedWidgetModel
{
  LayoutType get layoutType => getLayoutType(layout, defaultLayout: LayoutType.column);

  // Denotes whether box widgets (row, column) naturally expand or contract
  final bool expandDefault;

  // indicates if the widget will grow in
  // its horizontal axis
  @override
  bool get expandHorizontally => expand && !hasBoundedWidth;

  // indicates if the widget will grow in
  // its vertical axis
  @override
  bool get expandVertically => expand && !hasBoundedHeight;

  /// Expand, which is true by default, tells the widget if it should shrink to its children, or grow to its parents constraints. Width/Height attributes will override expand.
  BooleanObservable? _expand;
  set expand(dynamic v)
  {
    if (_expand != null)
    {
      _expand!.set(v);
    }
    else if (v != null)
    {
      _expand = BooleanObservable(Binding.toKey(id, 'expand'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get expand => _expand?.get() ?? expandDefault;

  /// layout
  StringObservable? _layout;
  set layout(dynamic v)
  {
    if (_layout != null)
    {
      _layout!.set(v);
    }
    else if (v != null)
    {
      _layout = StringObservable(Binding.toKey(id, 'layout'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get layout => _layout?.get()?.toLowerCase().trim();

  @override
  double get verticalPadding  => (marginTop ?? 0)  + (marginBottom ?? 0) + (borderwidth * 2) + (paddingTop ?? 0) + (paddingBottom ?? 0);

  @override
  double get horizontalPadding => (marginLeft ?? 0) + (marginRight  ?? 0) + (borderwidth * 2) + (paddingLeft ?? 0) + (paddingRight ?? 0);

  /// Center attribute allows a simple boolean override for halign and valign both being center. halign and valign will override center if given.
  BooleanObservable? _center;
  set center(dynamic v) {
    if (_center != null) {
      _center!.set(v);
    } else if (v != null) {
      _center = BooleanObservable(Binding.toKey(id, 'center'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool? get center => _center?.get();

  /// wrap determines the widget, if layout is row or col, how it will wrap.
  BooleanObservable? _wrap;
  set wrap(dynamic v) {
    if (_wrap != null) {
      _wrap!.set(v);
    } else if (v != null) {
      _wrap = BooleanObservable(Binding.toKey(id, 'wrap'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get wrap => _wrap?.get() ?? false;

  // box blur
  BooleanObservable? _blur;
  set blur(dynamic v)
  {
    if (_blur != null)
    {
      _blur!.set(v);
    }
    else if (v != null)
    {
      _blur = BooleanObservable(Binding.toKey(id, 'blur'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get blur => _blur?.get() ?? false;

  /// The start of the gradient in location, this will be the first `color` position if two colors are given
  StringObservable? _start;
  set start(dynamic v)
  {
    if (_start != null)
    {
      _start!.set(v);
    }
    else if (v != null)
    {
      _start = StringObservable(Binding.toKey(id, 'start'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String get start => _start?.get()?.toLowerCase() ?? 'top';

  /// The end of the gradient in location, this will be the second `color` position if two colors are given
  StringObservable? _end;
  set end(dynamic v)
  {
    if (_end != null)
    {
      _end!.set(v);
    }
    else if (v != null)
    {
      _end = StringObservable(Binding.toKey(id, 'end'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String get end => _end?.get()?.toLowerCase() ?? 'bottom';

  // box radius
  StringObservable? _radius;
  set radius(dynamic v)
  {
    if (_radius != null)
    {
      _radius!.set(v);
    }
    else if (v != null)
    {
      _radius = StringObservable(Binding.toKey(id, 'radius'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get radius => _radius?.get()?.toLowerCase();

  double get radiusTopRight
  {
    if (radius == null) return 0;
    var radii = radius!.split(',');
    if (radii.isEmpty) return 0;
    return S.toDouble(radii[0]) ?? 0;
  }

  double get radiusBottomRight
  {
    if (radius == null) return 0;
    var radii = radius!.split(',');
    if (radii.isEmpty) return 0;
    if (radii.length == 1)
    {
      return S.toDouble(radii[0]) ?? 0;
    }
    if (radii.length > 1)
    {
      return S.toDouble(radii[1]) ?? 0;
    }
    return 0;
  }

  double get radiusBottomLeft
  {
    if (radius == null) return 0;
    var radii = radius!.split(',');
    if (radii.isEmpty) return 0;
    if (radii.length == 1)
    {
      return S.toDouble(radii[0]) ?? 0;
    }
    if (radii.length > 2)
    {
      return S.toDouble(radii[2]) ?? 0;
    }
    return 0;
  }

  double get radiusTopLeft
  {
    if (radius == null) return 0;
    var radii = radius!.split(',');
    if (radii.isEmpty) return 0;
    if (radii.length == 1)
    {
      return S.toDouble(radii[0]) ?? 0;
    }
    if (radii.length > 3)
    {
      return S.toDouble(radii[3]) ?? 0;
    }
    return 0;
  }

  /// The color of the border for box, defaults to black54
  ColorObservable? _bordercolor;
  set bordercolor(dynamic v)
  {
    if (_bordercolor != null)
    {
      _bordercolor!.set(v);
    }
    else if (v != null)
    {
      _bordercolor = ColorObservable(Binding.toKey(id, 'bordercolor'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get bordercolor => _bordercolor?.get();

  /// The width of the containers border, defaults to 0
  DoubleObservable? _borderwidth;
  set borderwidth(dynamic v)
  {
    if (_borderwidth != null)
    {
      _borderwidth!.set(v);
    }
    else if (v != null)
    {
      _borderwidth = DoubleObservable(Binding.toKey(id, 'borderwidth'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double get borderwidth => _borderwidth?.get() ?? (border == 'none' ? 0 : 1);

  /// The border choice, can be `all`, `none`, `top`, `left`, `right`, `bottom`, `vertical`, or `horizontal`
  StringObservable? _border;
  set border(dynamic v)
  {
    if (_border != null)
    {
      _border!.set(v);
    }
    else if (v != null)
    {
      _border = StringObservable(Binding.toKey(id, 'border'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String get border => _border?.get()?.toLowerCase() ?? 'none';

  /// shadow attributes
  ///
  /// the color of the elevation shadow, defaults to black26
  ColorObservable? _shadowcolor;
  set shadowcolor(dynamic v)
  {
    if (_shadowcolor != null)
    {
      _shadowcolor!.set(v);
    }
    else if (v != null)
    {
      _shadowcolor = ColorObservable(Binding.toKey(id, 'shadowcolor'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color get shadowcolor => _shadowcolor?.get() ?? Colors.black26;

  /// the elevation of the box. The blur radius is 2* the elevation. This is combined with the offsets when constraining the size.
  DoubleObservable? _elevation;
  set elevation(dynamic v) {
    if (_elevation != null) {
      _elevation!.set(v);
    } else if (v != null) {
      _elevation = DoubleObservable(Binding.toKey(id, 'elevation'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double? get elevation => _elevation?.get();

  /// The x offset of the box FROM the shadow. 0,0 is center. This is combined with `elevation` when determining the size.
  DoubleObservable? _shadowx;
  set shadowx(dynamic v) {
    if (_shadowx != null) {
      _shadowx!.set(v);
    } else if (v != null) {
      _shadowx = DoubleObservable(Binding.toKey(id, 'shadowx'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double get shadowx => _shadowx?.get() ?? 4;

  /// The x offset of the box FROM the shadow. 0,0 is center. This is combined with `elevation` when determining the size.
  DoubleObservable? _shadowy;
  set shadowy(dynamic v) {
    if (_shadowy != null) {
      _shadowy!.set(v);
    } else if (v != null) {
      _shadowy = DoubleObservable(Binding.toKey(id, 'shadowy'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double get shadowy => _shadowy?.get() ?? 4;

  BoxModel(WidgetModel? parent, String? id,{Scope?  scope, this.expandDefault = true}) : super(parent, id, scope: scope);

  static BoxModel? fromXml(WidgetModel parent, XmlElement xml, {bool expandDefault = true})
  {
    BoxModel? model;
    try {
      model = BoxModel(parent, Xml.get(node: xml, tag: 'id'), expandDefault: expandDefault);
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'box.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement? xml)
  {
    if (xml == null) return;

    // deserialize
    super.deserialize(xml);

    /// Style Attributes
    start = Xml.get(node: xml, tag: 'start');
    end = Xml.get(node: xml, tag: 'end');
    blur = Xml.get(node: xml, tag: 'blur');

    /// Border and Shadow Attributes
    radius = Xml.get(node: xml, tag: 'radius');
    bordercolor = Xml.get(node: xml, tag: 'bordercolor');
    borderwidth = Xml.get(node: xml, tag: 'borderwidth');
    border = Xml.get(node: xml, tag: 'border');
    elevation = Xml.get(node: xml, tag: 'elevation');
    shadowcolor = Xml.get(node: xml, tag: 'shadowcolor');
    shadowy = Xml.get(node: xml, tag: 'shadowy');
    shadowx = Xml.get(node: xml, tag: 'shadowx');

    /// Build the layout
    layout  = Xml.get(node: xml, tag: 'layout');
    center = Xml.get(node: xml, tag: 'center');
    wrap = Xml.get(node: xml, tag: 'wrap');
    expand = Xml.get(node: xml, tag: 'expand');
  }

  @override
  List<Widget> inflate()
  {
    // process children
    List<Widget> views = [];
    for (var model in viewableChildren)
    {
      if (model is! ModalModel)
      {
        var view = model.getView();

        // wrap child in child data widget
        // this is done for us in "positioned" if the child happens
        // to be a positioned widget and the layout is "stack" (see positioned_view.dart)
        if (view is! PositionedView)
        {
          view = LayoutBoxChildData(child: view!, model: model);
        }

        if (view != null) views.add(view);
      }
    }
    return views;
  }

  static LayoutType getLayoutType(String? layout,
      {LayoutType defaultLayout = LayoutType.none}) {
    switch (layout?.toLowerCase().trim()) {
      case 'col':
      case 'column':
        return LayoutType.column;

      case 'row':
        return LayoutType.row;

      case 'stack':
        return LayoutType.stack;

      default:
        return defaultLayout;
    }
  }

  @override
  Widget getView({Key? key}) => getReactiveView(BoxView(this));
  //Widget getView({Key? key}) => BoxView(this);
}