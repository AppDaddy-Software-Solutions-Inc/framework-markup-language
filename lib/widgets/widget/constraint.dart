import 'package:flutter/cupertino.dart';
import 'package:fml/helper/string.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observable.dart';
import 'package:fml/observable/observables/double.dart';
import 'package:fml/observable/scope.dart';
import 'package:fml/widgets/widget/viewable_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';

class Constraints
{
  String? id;
  Scope? scope;
  OnChangeCallback? listener;
  WidgetModel? parent;

  Constraints(this.id, this.scope, this.parent, this.listener);

  // width
  double? _widthPercentage;
  double? get widthPercentage => _widthPercentage;
  DoubleObservable? _width;
  set width(dynamic v)
  {
    if (v != null)
    {
      if (S.isPercentage(v))
      {
        _widthPercentage = S.toDouble(v.split("%")[0]);
        v = null;
      }
      else _widthPercentage = null;
      if (v != null && v.runtimeType == String && v.contains('%'))
      {
        String s = v;
        v = s.replaceAll('%', '000000');
      }

      if (_width == null) _width = DoubleObservable(Binding.toKey(id, 'width'), v, scope: scope, listener: listener);
      else if (v != null) _width!.set(v);
    }
  }
  double? get width => _width?.get();

  // height
  double? _heightPercentage;
  double? get heightPercentage => _heightPercentage;
  DoubleObservable? _height;
  set height(dynamic v)
  {
    if (v != null)
    {
      if (S.isPercentage(v))
      {
        _heightPercentage = S.toDouble(v.split("%")[0]);
        v = null;
      }
      else
        _heightPercentage = null;
      if (v != null && v.runtimeType == String && v.contains('%'))
      {
        String s = v;
        v = s.replaceAll('%', '000000');
      }
      if (_height == null) _height = DoubleObservable(Binding.toKey(id, 'height'), v, scope: scope, listener: listener);
      else if (v != null) _height!.set(v);
    }
  }
  double? get height => _height?.get();

  // min width
  DoubleObservable? _minWidth;
  set minWidth(dynamic v)
  {
    if (_minWidth != null)
    {
      _minWidth!.set(v);
    }
    else if (v != null)
    {
      _minWidth = DoubleObservable(Binding.toKey(id, 'minwidth'), v, scope: scope, listener: listener);
    }
  }
  double? get minWidth => _minWidth?.get();

  // max width
  DoubleObservable? _maxWidth;
  set maxWidth(dynamic v)
  {
    if (_maxWidth != null)
    {
      _maxWidth!.set(v);
    }
    else if (v != null)
    {
      _maxWidth = DoubleObservable(Binding.toKey(id, 'maxwidth'), v, scope: scope, listener: listener);
    }
  }
  double? get maxWidth => _maxWidth?.get();

  // min height
  DoubleObservable? _minHeight;
  set minHeight(dynamic v)
  {
    if (_minHeight != null)
    {
      _minHeight!.set(v);
    }
    else if (v != null)
    {
      _minHeight = DoubleObservable(Binding.toKey(id, 'minheight'), v, scope: scope, listener: listener);
    }
  }
  double? get minHeight => _minHeight?.get();

  // max height
  DoubleObservable? _maxHeight;
  set maxHeight(dynamic v)
  {
    if (_maxHeight != null)
    {
      _maxHeight!.set(v);
    }
    else if (v != null)
    {
      _maxHeight = DoubleObservable(Binding.toKey(id, 'maxheight'), v, scope: scope, listener: listener);
    }
  }
  double? get maxHeight => _maxHeight?.get();

  bool get hasVerticalSizing   => ((height != null) && (height! >= 0)) || (minHeight != null) || (maxHeight != null);
  bool get hasHorizontalSizing => ((width  != null) && (width!  >= 0)) || (minWidth != null)  || (maxWidth != null);
  bool get hasSizing => hasVerticalSizing || hasHorizontalSizing;


  // this holds the constraints passed in the layout builder
  Constraint _system = Constraint();
  set system(BoxConstraints? constraints)
  {
    if (constraints != null)
    {
      _system.minWidth  = constraints.minWidth;
      _system.maxWidth  = constraints.maxWidth;
      _system.minHeight = constraints.minHeight;
      _system.maxHeight = constraints.maxHeight;
    }
  }

  // min width
  double? getMinWidth()
  {
    double? v;
    if ((v == null) && (_system.minWidth != null) && (_system.minWidth != double.infinity)) v = _system.minWidth;
    if ((v == null) && (parent is ViewableWidgetModel)) v = (parent as ViewableWidgetModel).constraints.getMinWidth();
    return v;
  }

  // min height
  double? getMinHeight()
  {
    double? v;
    if ((v == null) && (_system.minHeight != null) && (_system.minHeight != double.infinity)) v = _system.minHeight;
    if ((v == null) && (parent is ViewableWidgetModel)) v = (parent as ViewableWidgetModel).constraints.getMinHeight();
    return v;
  }

  double? getMaxWidth()
  {
    double? v;
    if (v == null && _system.maxWidth != null && _system.maxWidth != double.infinity) v = _system.maxWidth;
    if ((v == null) && (parent != null))
    {
      ViewableWidgetModel? parent = (this.parent is ViewableWidgetModel) ? (this.parent as ViewableWidgetModel) : null;
      if (parent?.padding != null)
      {
        var hpad = _getHPadding(parent!.paddings, parent.padding, parent.padding2, parent.padding3, parent.padding4);
        if (parent.width == null)
        {
           var w = parent.constraints.getMaxWidth();
           if (w != null) v = w - hpad;
        }
        else v = parent.width! - hpad;
      }
      else if (parent != null) v = (parent.width ?? parent.constraints.getMaxWidth());
    }
    return v;
  }

  double? getMaxHeight()
  {
    double? v;
    if ( v == null && _system.maxHeight != null && _system.maxHeight != double.infinity) v = _system.maxHeight;
    if ((v == null) && (parent != null))
    {
      ViewableWidgetModel? parent = (this.parent is ViewableWidgetModel) ? (this.parent as ViewableWidgetModel) : null;
      if (parent?.padding != null && _heightPercentage == null)
      {
        var vpad = _getVPadding(parent!.paddings, parent.padding, parent.padding2, parent.padding3, parent.padding4);
        if (parent.height == null)
        {
          var h = parent.constraints.getMaxHeight();
          if (h != null) v = h - vpad;
        }
        else v = parent.height! - vpad;
      }
      else if (parent != null) v = (parent.height ?? parent.constraints.getMaxHeight());
    }
    return v;
  }

  // sets the max width
  setMaxWidth(double? v)
  {
    _system.maxWidth = v;
    if (_width?.value != null && _width!.value >= 100000) _widthPercentage = (_width!.value / 1000000)!;
    if (_widthPercentage != null)
    {
      double? width;
      var maxwidth = this.maxWidth;
      if (maxwidth != null)
      {
        width = maxwidth * (_widthPercentage! / 100.0);
        if (minWidth != null && minWidth! > width)  width = minWidth;
        if (maxWidth != null && maxWidth! < width!) width = maxWidth;
      }
      _width?.set(width, notify: false);
    }
  }

  // sets the max height
  setMaxHeight(double? v)
  {
    _system.maxHeight = v;

    if (_height?.value != null && _height!.value >= 100000) _heightPercentage = (_height!.value / 1000000)!;
    if (_heightPercentage != null)
    {
      double? height;
      var maxheight = this.maxHeight;
      if (maxheight != null)
      {
        if (this.parent != null)
        {
          double vpadding = 0;
          ViewableWidgetModel? parent = (this.parent is ViewableWidgetModel) ? (this.parent as ViewableWidgetModel) : null;
          if (parent != null) vpadding = _getVPadding(parent.paddings, parent.padding, parent.padding2, parent.padding3, parent.padding4);

          height = ((maxheight - vpadding) * (_heightPercentage! / 100.0));
          if (minHeight != null && minHeight! > height) height = minHeight ?? 0;
          if (maxHeight != null && maxHeight! < height) height = maxHeight;
        }
      }
      _height?.set(height, notify: false);
    }
  }

  static double _getVPadding(int paddings, double? padding, double padding2, double padding3, double padding4)
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

  static double _getHPadding(int paddings, double? padding, double padding2, double padding3, double padding4)
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

class Constraint
{
  double? minWidth;
  double? maxWidth;
  double? minHeight;
  double? maxHeight;
}