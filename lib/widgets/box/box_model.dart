// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:fml/widgets/drawer/drawer_model.dart';
import 'package:fml/widgets/modal/modal_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

enum LayoutType { none, row, column, stack }

enum VerticalAlignmentType { top, bottom, center, around, between, evenly }

enum HorizontalAlignmentType { left, right, center, around, between, evenly }

class BoxModel extends ViewableWidgetModel {
  LayoutType get layoutType =>
      getLayoutType(layout, defaultLayout: LayoutType.column);

  // Denotes whether box widgets (row, column) naturally expand or contract
  final bool expandDefault;

  DrawerModel? drawer;

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
  set expand(dynamic v) {
    if (_expand != null) {
      _expand!.set(v);
    } else if (v != null) {
      _expand = BooleanObservable(Binding.toKey(id, 'expand'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get expand => _expand?.get() ?? expandDefault;

  /// layout
  StringObservable? _layout;
  set layout(dynamic v) {
    if (_layout != null) {
      _layout!.set(v);
    } else if (v != null) {
      _layout = StringObservable(Binding.toKey(id, 'layout'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get layout => _layout?.get()?.toLowerCase().trim();

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
  set blur(dynamic v) {
    if (_blur != null) {
      _blur!.set(v);
    } else if (v != null) {
      _blur = BooleanObservable(Binding.toKey(id, 'blur'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get blur => _blur?.get() ?? false;

  /// The start of the gradient in location, this will be the first `color` position if two colors are given
  StringObservable? _gradientStart;
  set gradientStart(dynamic v) {
    if (_gradientStart != null) {
      _gradientStart!.set(v);
    } else if (v != null) {
      _gradientStart = StringObservable(Binding.toKey(id, 'start'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String get gradientStart => _gradientStart?.get()?.toLowerCase() ?? 'top';

  /// The end of the gradient in location, this will be the second `color` position if two colors are given
  StringObservable? _gradientEnd;
  set gradientEnd(dynamic v) {
    if (_gradientEnd != null) {
      _gradientEnd!.set(v);
    } else if (v != null) {
      _gradientEnd = StringObservable(Binding.toKey(id, 'end'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String get gradientEnd => _gradientEnd?.get()?.toLowerCase() ?? 'bottom';

  // box radius
  StringObservable? _borderRadius;
  set borderRadius(dynamic v) {
    if (_borderRadius != null) {
      _borderRadius!.set(v);
    } else if (v != null) {
      _borderRadius = StringObservable(Binding.toKey(id, 'borderradius'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get borderRadius => _borderRadius?.get()?.toLowerCase();

  double get radiusTopRight {
    if (borderRadius == null) return 0;
    var radii = borderRadius!.split(',');
    if (radii.isEmpty) return 0;
    return toDouble(radii[0]) ?? 0;
  }

  double get radiusBottomRight {
    if (borderRadius == null) return 0;
    var radii = borderRadius!.split(',');
    if (radii.isEmpty) return 0;
    if (radii.length == 1) {
      return toDouble(radii[0]) ?? 0;
    }
    if (radii.length > 1) {
      return toDouble(radii[1]) ?? 0;
    }
    return 0;
  }

  double get radiusBottomLeft {
    if (borderRadius == null) return 0;
    var radii = borderRadius!.split(',');
    if (radii.isEmpty) return 0;
    if (radii.length == 1) {
      return toDouble(radii[0]) ?? 0;
    }
    if (radii.length > 2) {
      return toDouble(radii[2]) ?? 0;
    }
    return 0;
  }

  double get radiusTopLeft {
    if (borderRadius == null) return 0;
    var radii = borderRadius!.split(',');
    if (radii.isEmpty) return 0;
    if (radii.length == 1) {
      return toDouble(radii[0]) ?? 0;
    }
    if (radii.length > 3) {
      return toDouble(radii[3]) ?? 0;
    }
    return 0;
  }

  /// The color of the border for box, defaults to black54
  ColorObservable? _borderColor;
  set borderColor(dynamic v) {
    if (_borderColor != null) {
      _borderColor!.set(v);
    } else if (v != null) {
      _borderColor = ColorObservable(Binding.toKey(id, 'bordercolor'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  Color? get borderColor => _borderColor?.get();

  /// The width of the containers border, defaults to 0
  DoubleObservable? _borderWidth;
  set borderWidth(dynamic v) {
    if (_borderWidth != null) {
      _borderWidth!.set(v);
    } else if (v != null) {
      _borderWidth = DoubleObservable(Binding.toKey(id, 'borderwidth'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double get borderWidth => _borderWidth?.get() ?? 1;

  /// The border label
  StringObservable? _borderLabel;
  set borderLabel(dynamic v) {
    if (_borderLabel != null) {
      _borderLabel!.set(v);
    } else if (v != null) {
      _borderLabel = StringObservable(Binding.toKey(id, 'borderlabel'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get borderLabel => _borderLabel?.get();

  /// The border choice, can be `all`, `none`, `top`, `left`, `right`, `bottom`, `vertical`, or `horizontal`
  StringObservable? _border;
  set border(dynamic v) {
    if (_border != null) {
      _border!.set(v);
    } else if (v != null) {
      _border = StringObservable(Binding.toKey(id, 'border'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String get border => _border?.get()?.toLowerCase() ?? 'none';

  /// shadow attributes
  ///
  /// the color of the elevation shadow, defaults to black26
  ColorObservable? _shadowColor;
  set shadowColor(dynamic v) {
    if (_shadowColor != null) {
      _shadowColor!.set(v);
    } else if (v != null) {
      _shadowColor = ColorObservable(Binding.toKey(id, 'shadowcolor'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  Color get shadowColor => _shadowColor?.get() ?? Colors.black26;

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
  DoubleObservable? _shadowX;
  set shadowX(dynamic v) {
    if (_shadowX != null) {
      _shadowX!.set(v);
    } else if (v != null) {
      _shadowX = DoubleObservable(Binding.toKey(id, 'shadowx'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double get shadowX => _shadowX?.get() ?? 4;

  /// The x offset of the box FROM the shadow. 0,0 is center. This is combined with `elevation` when determining the size.
  DoubleObservable? _shadowY;
  set shadowY(dynamic v) {
    if (_shadowY != null) {
      _shadowY!.set(v);
    } else if (v != null) {
      _shadowY = DoubleObservable(Binding.toKey(id, 'shadowy'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double get shadowY => _shadowY?.get() ?? 4;

  // set padding
  set padding(dynamic v) {
    if (v is String) {
      var s = v.split(',');

      // all
      if (s.length == 1) {
        paddingTop = s[0];
        paddingRight = s[0];
        paddingBottom = s[0];
        paddingLeft = s[0];
      }

      // top/bottom
      else if (s.length == 2) {
        paddingTop = s[0];
        paddingRight = s[1];
        paddingBottom = s[0];
        paddingLeft = s[1];
      }

      // top/bottom
      else if (s.length == 3) {
        paddingTop = s[0];
        paddingRight = s[1];
        paddingBottom = s[2];
        paddingLeft = s[1];
      }

      // top/bottom
      else if (s.length > 3) {
        paddingTop = s[0];
        paddingRight = s[1];
        paddingBottom = s[2];
        paddingLeft = s[3];
      }
    }
  }

  // paddings top
  DoubleObservable? _paddingTop;
  set paddingTop(dynamic v) {
    if (_paddingTop != null) {
      _paddingTop!.set(v);
    } else if (v != null) {
      _paddingTop = DoubleObservable(Binding.toKey(id, 'paddingtop'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double? get paddingTop => _paddingTop?.get();

  // paddings right
  DoubleObservable? _paddingRight;
  set paddingRight(dynamic v) {
    if (_paddingRight != null) {
      _paddingRight!.set(v);
    } else if (v != null) {
      _paddingRight = DoubleObservable(Binding.toKey(id, 'paddingright'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double? get paddingRight => _paddingRight?.get();

  // paddings bottom
  DoubleObservable? _paddingBottom;
  set paddingBottom(dynamic v) {
    if (_paddingBottom != null) {
      _paddingBottom!.set(v);
    } else if (v != null) {
      _paddingBottom = DoubleObservable(Binding.toKey(id, 'paddingbottom'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double? get paddingBottom => _paddingBottom?.get();

  // paddings left
  DoubleObservable? _paddingLeft;
  set paddingLeft(dynamic v) {
    if (_paddingLeft != null) {
      _paddingLeft!.set(v);
    } else if (v != null) {
      _paddingLeft = DoubleObservable(Binding.toKey(id, 'paddingleft'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double? get paddingLeft => _paddingLeft?.get();

  BoxModel(super.parent, super.id,
      {super.scope, this.expandDefault = true, super.data});

  static BoxModel? fromXml(WidgetModel parent, XmlElement xml,
      {bool expandDefault = true, Scope? scope, dynamic data}) {
    BoxModel? model;
    try {

      model = BoxModel(parent, Xml.get(node: xml, tag: 'id'),
          expandDefault: expandDefault, scope: scope, data: data);

      model.deserialize(xml);

    } catch (e) {
      Log().exception(e, caller: 'box.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {

    // deserialize
    super.deserialize(xml);

    /// border attributes
    border       = Xml.get(node: xml, tag: 'border');
    borderRadius = Xml.get(node: xml, tag: 'borderradius') ?? Xml.get(node: xml, tag: 'radius');
    borderColor  = Xml.get(node: xml, tag: 'bordercolor');
    borderWidth  = Xml.get(node: xml, tag: 'borderwidth');
    borderLabel  = Xml.get(node: xml, tag: 'borderlabel');
    // set default border on any border property specified
    if (_border == null &&
        (_borderRadius != null ||
         _borderColor != null ||
         _borderWidth != null ||
         _borderLabel != null)) {
      border = "all";
    }

    // shadow attributes
    elevation = Xml.get(node: xml, tag: 'elevation');
    shadowColor = Xml.get(node: xml, tag: 'shadowcolor');
    shadowX = Xml.get(node: xml, tag: 'shadowx');
    shadowY = Xml.get(node: xml, tag: 'shadowy');

    /// layout
    layout = Xml.get(node: xml, tag: 'layout');
    center = Xml.get(node: xml, tag: 'center');
    wrap = Xml.get(node: xml, tag: 'wrap');
    expand = Xml.get(node: xml, tag: 'expand');

    // set padding. Can be comma separated top,left,bottom,right
    // space around the widget's children
    var padding = Xml.attribute(node: xml, tag: 'pad') ??
        Xml.attribute(node: xml, tag: 'padding');
    this.padding = padding;

    /// other style attributes
    gradientStart = Xml.get(node: xml, tag: 'gradientstart') ??
        Xml.get(node: xml, tag: 'start');
    gradientEnd = Xml.get(node: xml, tag: 'gradientend') ??
        Xml.get(node: xml, tag: 'end');
    blur = Xml.get(node: xml, tag: 'blur');

    // build drawers
    List<XmlElement>? nodes;
    nodes = Xml.getChildElements(node: xml, tag: "DRAWER");
    if (nodes != null && nodes.isNotEmpty) {
      drawer = DrawerModel.fromXmlList(this, nodes);
    }
  }

  @override
  List<Widget> inflate() {
    // process children
    List<Widget> views = [];
    for (var model in viewableChildren) {
      if (model is! ModalModel) {

        // build the view
        var view = model.getView();

        // add the view to the
        // view list
        if (view != null) {
          views.add(view);
        }
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
  void layoutComplete(Size size, Offset offset) {
    // we need to adjust the size and position to account for padding, margin, and border
    var w = size.width  + (paddingLeft ?? 0) + (paddingRight  ?? 0)  + (marginLeft ?? 0) + (marginRight ?? 0);// + (borderWidth * 2);
    var h = size.height + (paddingTop ?? 0)  + (paddingBottom ?? 0) + (marginTop ?? 0)  + (marginBottom ?? 0);// + (borderWidth * 2);
    super.layoutComplete(Size(w,h), offset);
  }

  @override
  Widget getView({Key? key}) => getReactiveView(BoxView(this));
}
