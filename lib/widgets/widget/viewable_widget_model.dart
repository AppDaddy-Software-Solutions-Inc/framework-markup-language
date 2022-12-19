// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/helper_barrel.dart';
import 'package:fml/widgets/widget/widget_model.dart';

class ViewableWidgetModel extends WidgetModel
{
  // Width
  double? _widthPercentage;
  DoubleObservable? _width;
  set width(dynamic v)
  {
    if (_width == null)
    {
      if (v != null)
      {
        if (S.isPercentage(v))
        {
          _widthPercentage = S.toDouble(v.split("%")[0]);
          v = null;
        }
        if (v != null && v.runtimeType == String && v.contains('%')) {
          String s = v;
          v = s.replaceAll('%', '000000');
        }
        _width = DoubleObservable(Binding.toKey(id, 'width'), v, scope: scope, listener: onPropertyChange);
      }
    }
    else _width!.set(v);
  }
  double? get width => _width?.get();

  // Height
  double? _heightPercentage;
  DoubleObservable? _height;
  set height(dynamic v)
  {
    if (_height == null)
    {
      if (v != null)
      {
        if (S.isPercentage(v))
        {
          _heightPercentage = S.toDouble(v.split("%")[0]);
          v = null;
        }
        if (v != null && v.runtimeType == String && v.contains('%')) {
          String s = v;
          v = s.replaceAll('%', '000000');
        }
        _height = DoubleObservable(Binding.toKey(id, 'height'), v, scope: scope, listener: onPropertyChange);
      }
    }
    else _height!.set(v);
  }
  double? get height => _height?.get();

  // Constraints
  final Map<String, double?> _constraints = {'minwidth': null, 'maxwidth': null, 'minheight': null, 'maxheight': null};

  Map<String, double?> get constraints
  {
    Map<String, double?> con = Map<String, double?>();
    con['minheight'] = height ?? _constraints['minheight'] ?? minheight ?? 0.0;
    con['maxheight'] = height ?? _constraints['maxheight'] ?? maxheight ?? double.infinity;
    con['minwidth']  = width  ?? _constraints['minwidth'] ?? minwidth ?? 0.0;
    con['maxwidth']  = width  ?? _constraints['maxwidth'] ?? maxwidth ?? double.infinity;

    // ensure not negative
    if(con['minheight']! < 0) con['minheight'] = 0;
    if(con['maxheight']! < 0) con['maxheight'] = double.infinity;

    // ensure max > min
    if (con['minheight']! > con['maxheight']!)
    {
      if (_constraints['maxheight'] != null)
           con['minheight'] = con['maxheight'];
      else con['maxheight'] = con['minheight'];
    }

    // ensure not negative
    if(con['minwidth']! < 0) con['minwidth'] = 0;
    if(con['maxwidth']! < 0) con['maxwidth'] = double.infinity;

    // ensure max > min
    if (con['minwidth']! > con['maxwidth']!)
    {
      if (_constraints['maxwidth'] != null)
           con['minwidth'] = con['maxwidth'];
      else con['maxwidth'] = con['minwidth'];
    }
    return con;
  }

  // is constrained?
  bool get constrained => ((width != null) && (width! >= 0)) ||
          ((height != null) && (height! >= 0)) ||
          (_constraints['minwidth'] != null) ||
          (_constraints['maxwidth'] != null) ||
          (_constraints['minheight'] != null) ||
          (_constraints['maxheight'] != null);

  // Min Width
  double? _minwidth;
  set minwidth(double? v) => _minwidth = v;
  double? get minwidth
  {
    double? v;
    if ((v == null) && (_minwidth != null) && (_minwidth != double.infinity)) v = _minwidth;
    if ((v == null) && (parent is ViewableWidgetModel)) v = (parent as ViewableWidgetModel).minwidth;
    return v;
  }

  // Min Height
  double? _minheight;
  set minheight(double? v) => _minheight = v;
  double? get minheight
  {
    double? v;
    if ((v == null) && (_minheight != null) && (_minheight != double.infinity)) v = _minheight;
    if ((v == null) && (parent is ViewableWidgetModel)) v = (parent as ViewableWidgetModel).minheight;
    return v;
  }

  // Max Width
  double? _maxwidth;
  set maxwidth(double? v)
  {
    _maxwidth = v;
    if (_width?.value != null && _width!.value >= 100000)
      _widthPercentage = (_width!.value / 1000000)!;
    if (_widthPercentage != null)
    {
      double? width;
      var maxwidth = this.maxwidth;
      if (maxwidth != null)
      {
        width = maxwidth * (_widthPercentage! / 100.0);
        if ((_constraints['minwidth'] != null) && (_constraints['minwidth']! > width))  width = _constraints['minwidth'];
        if ((_constraints['maxwidth'] != null) && (_constraints['maxwidth']! < width!)) width = _constraints['maxwidth'];
      }
      _width?.set(width, notify: false);
    }
  }
  double? get maxwidth
  {
    double? v;
    if ((v == null) && (_maxwidth != null) && (_maxwidth != double.infinity)) v = _maxwidth;
    if ((v == null) && (parent != null))
    {
      ViewableWidgetModel? parent = (this.parent is ViewableWidgetModel) ? (this.parent as ViewableWidgetModel) : null;
      if (parent?.padding != null)
      {
        var vpad = getParentHPadding(parent!.paddings, parent.padding, parent.padding2, parent.padding3, parent.padding4);
        v = (parent.width != null) ? (parent.width! - vpad) : (parent.maxwidth! - vpad);
      }
      else if (parent != null) v = (parent.width ?? parent.maxwidth);
    }
    return v;
  }

  // Max Height
  double? _maxheight;
  set maxheight(double? v)
  {
    _maxheight = v;

    if (_height?.value != null && _height!.value >= 100000)
      _heightPercentage = (_height!.value / 1000000)!;
    if (_heightPercentage != null)
    {
      double? height;
      var maxheight = this.maxheight;
      if (maxheight != null)
      {
        if (this.parent != null)
        {
          double vpadding = 0;
          ViewableWidgetModel? parent = (this.parent is ViewableWidgetModel) ? (this.parent as ViewableWidgetModel) : null;
          if (parent != null) vpadding = getParentVPadding(parent.paddings, parent.padding, parent.padding2, parent.padding3, parent.padding4);

          height = ((maxheight - vpadding) * (_heightPercentage! / 100.0));
          if ((_constraints['minheight'] != null) && (_constraints['minheight']! > height)) height = _constraints['minheight'] ?? 0;
          if ((_constraints['maxheight'] != null) && (_constraints['maxheight']! < height)) height = _constraints['maxheight'];
        }
      }
      _height?.set(height, notify: false);
    }
  }
  double? get maxheight
  {
    double? v;
    if ((v == null) && (_maxheight != null) && (_maxheight != double.infinity)) v = _maxheight;
    if ((v == null) && (parent != null))
    {
      ViewableWidgetModel? parent = (this.parent is ViewableWidgetModel) ? (this.parent as ViewableWidgetModel) : null;
      if (parent?.padding != null && _heightPercentage == null)
      {
        var vpad = getParentVPadding(parent!.paddings, parent.padding, parent.padding2, parent.padding3, parent.padding4);
        v = (parent.height != null) ? (parent.height! - vpad) : (parent.maxheight! - vpad);
      }
      else if (parent != null) v = (parent.height ?? parent.maxheight);
    }
    return v;
  }

  /// alignment and layout attributes
  ///
  /// The horizontal alignment of the widgets children, overrides `center`. Can be `left`, `right`, `start`, or `end`.
  StringObservable? _halign;
  set halign(dynamic v)
  {
    if (_halign != null)
    {
      _halign!.set(v);
    }
    else if (v != null)
    {
      _halign = StringObservable(Binding.toKey(id, 'halign'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get halign => _halign?.get();

  /// The vertical alignment of the widgets children, overrides `center`. Can be `top`, `bottom`, `start`, or `end`.
  StringObservable? _valign;
  set valign(dynamic v)
  {
    if (_valign != null)
    {
      _valign!.set(v);
    }
    else if (v != null)
    {
      _valign = StringObservable(Binding.toKey(id, 'valign'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get valign => _valign?.get();

  int paddings = 0; 
  set _paddings(dynamic v)
  {
    // build PADDINGS array
    if (v is String)
    {
      var s = v.split(',');
      paddings = s.length;
      if (s.length > 0) padding  = s[0];
      if (s.length > 1) padding2 = s[1];
      if (s.length > 2) padding3 = s[2];
      if (s.length > 3) padding4 = s[3];
    }
  }

  // padding
  DoubleObservable? _padding;
  set padding(dynamic v)
  {
    if (_padding != null) _padding!.set(v);
    else if (v != null) _padding = DoubleObservable(Binding.toKey(id, 'pad'), v, scope: scope, listener: onPropertyChange);
  }
  double get padding => _padding?.get() ?? 0;

  // padding 2
  DoubleObservable? _padding2;
  set padding2(dynamic v)
  {
    if (_padding2 != null) _padding2!.set(v);
    else if (v != null) _padding2 = DoubleObservable(Binding.toKey(id, 'pad2'), v, scope: scope, listener: onPropertyChange);
  }
  double get padding2 => _padding2?.get() ?? 0;

  // padding 3
  DoubleObservable? _padding3;
  set padding3(dynamic v)
  {
    if (_padding3 != null) _padding3!.set(v);
    else if (v != null) _padding3 = DoubleObservable(Binding.toKey(id, 'pad3'), v, scope: scope, listener: onPropertyChange);
  }
  double get padding3 => _padding3?.get() ?? 0;

  // padding 4
  DoubleObservable? _padding4;
  set padding4(dynamic v)
  {
    if (_padding4 != null) _padding4!.set(v);
    else if (v != null) _padding4 = DoubleObservable(Binding.toKey(id, 'pad4'), v, scope: scope, listener: onPropertyChange);
  }
  double get padding4 => _padding4?.get() ?? 0;
  
  
  // visible
  BooleanObservable? _visible;
  set visible(dynamic v)
  {
    if (_visible != null)
    {
      _visible!.set(v);
    }
    else if (v != null)
    {
      _visible = BooleanObservable(Binding.toKey(id, 'visible'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get visible => _visible?.get() ?? true;

  // is visible
  static bool isVisible(DecoratedWidgetModel? widget)
  {
    if (widget == null) return false;
    if (widget.visible == false) return false;
    if (widget.parent is DecoratedWidgetModel) return isVisible(widget.parent as DecoratedWidgetModel);
    return true;
  }

  // enabled
  BooleanObservable? _enabled;
  set enabled(dynamic v)
  {
    if (_enabled != null)
    {
      _enabled!.set(v);
    }
    else if (v != null)
    {
      _enabled = BooleanObservable(Binding.toKey(id, 'enabled'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get enabled => _enabled?.get() ?? true;

  ViewableWidgetModel(WidgetModel? parent, String? id, {Scope?  scope}) : super(parent, id, scope: scope);

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);

    // set constraints
    _constraints['minwidth']  = S.toDouble(Xml.get(node: xml, tag: 'minwidth'));
    _constraints['maxwidth']  = S.toDouble(Xml.get(node: xml, tag: 'maxwidth'));
    _constraints['minheight'] = S.toDouble(Xml.get(node: xml, tag: 'minheight'));
    _constraints['maxheight'] = S.toDouble(Xml.get(node: xml, tag: 'maxheight'));

    // properties
    visible = Xml.get(node: xml, tag: 'visible');
    enabled = Xml.get(node: xml, tag: 'enabled');
    width   = Xml.get(node: xml, tag: 'width');
    height  = Xml.get(node: xml, tag: 'height');
    halign  = Xml.get(node: xml, tag: 'halign');
    valign  = Xml.get(node: xml, tag: 'valign');

    // pad and padd are always defined as attibutes. PAD as an element nam,e is the PADDING widget
    _paddings = Xml.attribute(node: xml, tag: 'pad') ?? Xml.attribute(node: xml, tag: 'padd');
  }

  static double getParentVPadding(int paddings, double? padding, double padding2, double padding3, double padding4)
  {
    double insets = 0.0;
    if (paddings > 0)
    {
      // pad all
      if (paddings == 1) insets = (padding ?? 0) * 2;

      // pad directions v,h
      else if (paddings == 2) insets = (padding ?? 0) * 2;

      // pad sides top, right, bottom, left
      else if (paddings > 2) insets = (padding ?? 0) + padding3;
    }
    //should add up all of the padded siblings to do this so you can have multiple padded siblings unconstrained.
    return insets;
  }

  static double getParentHPadding(int paddings, double? padding, double padding2, double padding3, double padding4)
  {
    double insets = 0.0;
    if (paddings > 0)
    {
      // pad all
      if (paddings == 1) insets = (padding ?? 0) * 2;

      // pad directions v,h
      else if (paddings == 2) insets = padding2 * 2;

      // pad sides top, right, bottom, left
      else if (paddings > 2) insets = padding2 + padding4;
    }

    //should add up all of the padded siblings to do this.
    return insets;
  }
}
