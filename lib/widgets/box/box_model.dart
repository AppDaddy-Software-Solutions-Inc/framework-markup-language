// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/constraint.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/box/box_view.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

enum LayoutTypes {none, row, column, stack}

class BoxModel extends DecoratedWidgetModel implements IViewableWidget
{
  @override
  Constraints get localConstraints
  {
    var constraints = super.localConstraints;
    if (expand)
    {
      constraints.width     = constraints.width  ?? globalConstraints.maxWidth;
      constraints.height    = constraints.height ?? globalConstraints.maxHeight;
      constraints.minWidth  = null;
      constraints.minHeight = null;
    }
    else
    {
      if (constraints.width  == null && constraints.minWidth  != null) constraints.width  = constraints.minWidth;
      if (constraints.height == null && constraints.minHeight != null) constraints.height = constraints.minHeight;
      constraints.maxWidth  = null;
      constraints.maxHeight = null;
    }
    return constraints;
  }

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
  double? get borderwidth => _borderwidth?.get() ?? (border == 'none' ? 0 : 2);

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
  double get elevation => _elevation?.get() ?? 0;

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
  bool get center => _center?.get() ?? false;

  /// Layout determines the widgets childrens layout. Can be `row`, `column`, `col`, or `stack`. Defaulted to `column`. If set to `stack` it can take `POSITIONED` as a child.
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
  bool get expand => _expand?.get() ?? true;
  bool get expanded => expand;

  BoxModel(
    WidgetModel? parent,
    String? id, {
    Scope?  scope,
    dynamic width,
    dynamic height,
    dynamic minwidth,
    dynamic padding,
    dynamic minheight,
    dynamic maxwidth,
    dynamic maxheight,
    dynamic opacity,
    dynamic blur,
    dynamic color,
    dynamic start,
    dynamic end,
    dynamic elevation,
    dynamic shadowcolor,
    dynamic shadowy,
    dynamic shadowx,
    dynamic radius,
    dynamic bordercolor,
    dynamic borderwidth,
    dynamic border,
    dynamic layout,
    dynamic valign,
    dynamic halign,
    dynamic expand,
    dynamic center,
    dynamic wrap,
  }) : super(parent, id, scope: scope)
  {
    // constraints
    if (width     != null) this.width     = width;
    if (height    != null) this.height    = height;
    if (minwidth  != null) this.minWidth  = minwidth;
    if (minheight != null) this.minHeight = minheight;
    if (maxwidth  != null) this.maxWidth  = maxwidth;
    if (maxheight != null) this.maxHeight = maxheight;

    if (padding   != null) this.padding = padding;
    if (opacity != null) this.opacity = opacity;
    if (color != null) this.color = color;
    if (start != null) this.start = start;
    if (end != null) this.end = end;
    if (shadowcolor != null) this.shadowcolor = shadowcolor;
    if (shadowy != null) this.shadowy = shadowy;
    if (shadowx != null) this.shadowx = shadowx;
    if (elevation != null) this.elevation = elevation;
    if (radius != null) this.radius = radius;
    if (bordercolor != null) this.bordercolor = bordercolor;
    if (borderwidth != null) this.borderwidth = borderwidth;
    if (border != null) this.border = border;
    if (halign != null) this.halign = halign;
    if (valign != null) this.valign = valign;
    if (center != null) this.center = center;
    if (layout != null) this.layout = layout;
    if (expand != null) this.expand = expand;
    if (blur != null) this.blur = blur;
    if (wrap != null) this.wrap = wrap;
  }

  static BoxModel? fromXml(WidgetModel parent, XmlElement xml, {String? type}) {
    BoxModel? model;
    try {
      model = BoxModel(parent, Xml.get(node: xml, tag: 'id'));
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

    /// Layout Attributes
    layout = Xml.get(node: xml, tag: 'layout');
    center = Xml.get(node: xml, tag: 'center');

    // expand="false" is same as adding attribute shrink
    var expand = Xml.get(node: xml, tag: 'expand');
    if (expand == null && Xml.hasAttribute(node: xml, tag: 'shrink')) expand = 'false';
    this.expand = expand;

    wrap = Xml.get(node: xml, tag: 'wrap');

    // if stack, sort children by depth
    if (getLayoutType() == LayoutTypes.stack)
    if (children != null)
    {
      children?.sort((a, b)
      {
        if(a.depth != null && b.depth != null) return a.depth?.compareTo(b.depth!) ?? 0;
        return 0;
      });
    }
  }

  LayoutTypes getLayoutType()
  {
    if (layout == 'col')    return LayoutTypes.column;
    if (layout == 'column') return LayoutTypes.column;
    if (layout == 'row')    return LayoutTypes.row;
    if (layout == 'stack')  return LayoutTypes.stack;
    return LayoutTypes.column;
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  /// determines if the widget has a size in its primary axis
  bool isConstrained()
  {
    // get constraints
    var systemConstraints = this.systemConstraints;
    var localConstraints  = this.localConstraints;
    var globalConstraints = this.globalConstraints;

    var layout = getLayoutType();
    if (layout == LayoutTypes.row)
    {
      if (expand  && localConstraints.hasHorizontalExpansionConstraints) return true;
      if (expand  && (globalConstraints.maxWidth ?? double.infinity) != double.infinity) return true;
      if (expand  && (systemConstraints.maxWidth ?? double.infinity) == double.infinity) return false;
      if (!expand && localConstraints.hasHorizontalContractionConstraints) return true;
    }

    else if (layout == LayoutTypes.column)
    {
      if (expand  && localConstraints.hasVerticalExpansionConstraints) return true;
      if (expand  && (globalConstraints.maxHeight ?? double.infinity) != double.infinity) return true;
      if (expand  && (systemConstraints.maxHeight ?? double.infinity) == double.infinity) return false;
      if (!expand && localConstraints.hasVerticalContractionConstraints) return true;
    }

    return false;
  }

  Widget getView({Key? key}) => getReactiveView(BoxView(this));
}
