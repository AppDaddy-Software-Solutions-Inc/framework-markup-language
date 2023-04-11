// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/column/column_view.dart';
import 'package:fml/widgets/row/row_view.dart';
import 'package:fml/widgets/stack/stack_view.dart';
import 'package:fml/widgets/widget/layout_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/box/box_view.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class BoxModel extends LayoutModel
{
  LayoutType get layoutType => LayoutModel.getLayoutType(layout);

  MainAxisSize get verticalAxisSize
  {
    switch (layoutType)
    {
      case LayoutType.row:
        return MainAxisSize.max;

      case LayoutType.stack:
      case LayoutType.column:
      default:
        return (expand && verticallyConstrained) ? MainAxisSize.max : MainAxisSize.min;
    }
  }

  MainAxisSize get horizontalAxisSize
  {
    switch (layoutType)
    {
      case LayoutType.row:
        return MainAxisSize.max;

      case LayoutType.stack:
      case LayoutType.row:
      default:
        return (expand && horizontallyConstrained) ? MainAxisSize.max : MainAxisSize.min;
    }
  }

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
  double get borderwidth => _borderwidth?.get() ?? (border == 'none' ? 0 : 2);

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

  set padding(dynamic v)
  {
    // build PADDINGS array
    if (v is String)
    {
      var s = v.split(',');

      // all
      if (s.length == 1)
      {
        paddingTop=s[0];
        paddingRight=s[0];
        paddingBottom=s[0];
        paddingLeft=s[0];
      }

      // top/bottom
      else if (s.length == 2)
      {
        paddingTop=s[0];
        paddingRight=s[1];
        paddingBottom=s[0];
        paddingLeft=s[1];
      }

      // top/bottom
      else if (s.length == 3)
      {
        paddingTop=s[0];
        paddingRight=s[1];
        paddingBottom=s[2];
        paddingLeft=null;
      }

      // top/bottom
      else if (s.length > 3)
      {
        paddingTop=s[1];
        paddingRight=s[2];
        paddingBottom=s[3];
        paddingLeft=s[4];
      }
    }
  }

  // paddings top
  DoubleObservable? _paddingTop;
  set paddingTop(dynamic v)
  {
    if (_paddingTop != null) _paddingTop!.set(v);
    else if (v != null) _paddingTop = DoubleObservable(Binding.toKey(id, 'paddingtop'), v, scope: scope, listener: onPropertyChange);
  }
  double? get paddingTop => _paddingTop?.get();

  // paddings right
  DoubleObservable? _paddingRight;
  set paddingRight(dynamic v)
  {
    if (_paddingRight != null) _paddingRight!.set(v);
    else if (v != null) _paddingRight = DoubleObservable(Binding.toKey(id, 'paddingright'), v, scope: scope, listener: onPropertyChange);
  }
  double? get paddingRight => _paddingRight?.get();

  // paddings bottom
  DoubleObservable? _paddingBottom;
  set paddingBottom(dynamic v)
  {
    if (_paddingBottom != null) _paddingBottom!.set(v);
    else if (v != null)
      _paddingBottom = DoubleObservable(Binding.toKey(id, 'paddingbottom'), v, scope: scope, listener: onPropertyChange);
  }
  double? get paddingBottom => _paddingBottom?.get();

  // paddings left
  DoubleObservable? _paddingLeft;
  set paddingLeft(dynamic v)
  {
    if (_paddingLeft != null) _paddingLeft!.set(v);
    else if (v != null) _paddingLeft = DoubleObservable(Binding.toKey(id, 'paddingleft'), v, scope: scope, listener: onPropertyChange);
  }
  double? get paddingLeft => _paddingLeft?.get();

  BoxModel(WidgetModel? parent, String? id, {Scope?  scope}) : super(parent, id, scope: scope);

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

    // legacy support for padding vs margin
    if ((Xml.get(node: xml, tag: 'margin') ?? Xml.get(node: xml, tag: 'margins')) == null)
    {
      var attribute = xml.getAttributeNode("pad");
      if (attribute == null) attribute = xml.getAttributeNode("padding");
      if (attribute == null) attribute = xml.getAttributeNode("padd");
      if (attribute != null) Xml.changeAttributeName(xml, attribute.localName, "margin");
    }

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
    layout = Xml.get(node: xml, tag: 'layout');
  }

  Widget getView({Key? key}) => getReactiveView(BoxView(this));
  Widget getContentView({Key? key})
  {
    switch (layoutType)
    {
      case LayoutType.row:
        return RowView(this);

      case LayoutType.column:
        return ColumnView(this);

      case LayoutType.stack:
      default:
        return StackView(this);
    }
  }

}
