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

  // holds the system layout constraints
  Constraint _flutterConstraints = Constraint();

  Constraints(this.id, this.scope, this.parent, this.listener);

  bool isVerticallyConstrained()   => (height != null && height! >= 0) || minHeight != null || maxHeight != null;
  bool isHorizontallyConstrained() => (width  != null && width!  >= 0) || minWidth  != null || maxWidth  != null;

  // width
  double? _widthPercentage;
  double? get pctWidth => _widthPercentage;
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
  double? get pctHeight => _heightPercentage;
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

  // calculates the min width
  double? getMinWidth()
  {
    double? v;
    if (_flutterConstraints.minWidth != null && _flutterConstraints.minWidth != double.infinity) v = _flutterConstraints.minWidth;
    if (v == null && parent is ViewableWidgetModel) v = (parent as ViewableWidgetModel).getMinWidth();
    return v;
  }

  // calculates the max width
  double? getMaxWidth()
  {
    double? v;
    if (_flutterConstraints.maxWidth != null && _flutterConstraints.maxWidth != double.infinity) v = _flutterConstraints.maxWidth;
    if (v == null && this.parent is ViewableWidgetModel)
    {
      ViewableWidgetModel parent = (this.parent as ViewableWidgetModel);
      if (_widthPercentage == null)
      {
        var hpad = _getHPadding(parent.paddings, parent.padding, parent.padding2, parent.padding3, parent.padding4);
        if (parent.width == null)
        {
           var w = parent.getMaxWidth();
           if (w != null) v = w - hpad;
        }
        else v = parent.width! - hpad;
      }
      else v = parent.width ?? parent.getMaxWidth();
    }
    return v;
  }

  // calculates the min height
  double? getMinHeight()
  {
    double? v;
    if (_flutterConstraints.minHeight != null && _flutterConstraints.minHeight != double.infinity) v = _flutterConstraints.minHeight;
    if (v == null && parent is ViewableWidgetModel) v = (parent as ViewableWidgetModel).getMinHeight();
    return v;
  }

  // calculates the max height
  double? getMaxHeight()
  {
    double? v;
    if (_flutterConstraints.maxHeight != null && _flutterConstraints.maxHeight != double.infinity) v = _flutterConstraints.maxHeight;
    if (v == null && parent is ViewableWidgetModel)
    {
      ViewableWidgetModel? parent = (this.parent as ViewableWidgetModel);
      if (_heightPercentage == null)
      {
        var vpad = _getVPadding(parent.paddings, parent.padding, parent.padding2, parent.padding3, parent.padding4);
        if (parent.height == null)
        {
          var h = parent.getMaxHeight();
          if (h != null) v = h - vpad;
        }
        else v = parent.height! - vpad;
      }
      else v = parent.height ?? parent.getMaxHeight();
    }
    return v;
  }

  Constraint getConstraints()
  {
    Constraint constraint = Constraint();
    constraint.minHeight = height ?? minHeight ?? getMinHeight() ??  0.0;
    constraint.minWidth  = width  ?? minWidth  ?? getMinWidth()  ?? 0.0;
    constraint.maxHeight = height ?? maxHeight ?? getMaxHeight() ?? double.infinity;
    constraint.maxWidth  = width  ?? maxWidth  ?? getMaxWidth()  ?? double.infinity;

    // ensure not negative
    if (constraint.minHeight! < 0) constraint.minHeight = 0;
    if (constraint.maxHeight! < 0) constraint.maxHeight = double.infinity;

    // ensure max > min
    if (constraint.minHeight! > constraint.maxHeight!)
    {
      if (maxHeight != null)
           constraint.minHeight = constraint.maxHeight;
      else constraint.maxHeight = constraint.minHeight;
    }

    // ensure not negative
    if (constraint.minWidth! < 0) constraint.minWidth = 0;
    if (constraint.maxWidth! < 0) constraint.maxWidth = double.infinity;

    // ensure max > min
    if (constraint.minWidth! > constraint.maxWidth!)
    {
      if (maxWidth != null)
           constraint.minWidth = constraint.maxWidth;
      else constraint.maxWidth = constraint.minWidth;
    }
    return constraint;
  }

  // sets the layout constraints and adjust the height & width accordingly
  void setConstraints(BoxConstraints? constraints)
  {
    _flutterConstraints.minWidth  = constraints?.minWidth;
    _flutterConstraints.maxWidth  = constraints?.maxWidth;
    _flutterConstraints.minHeight = constraints?.minHeight;
    _flutterConstraints.maxHeight = constraints?.maxHeight;

    // adjust the width
    if (width != null && width! >= 100000) _widthPercentage = (width!/1000000);
    if (_widthPercentage != null)
    {
      // calculate the width
      double? width;
      double? maxwidth = getMaxWidth();
      if (maxwidth != null)
      {
        width = maxwidth * (_widthPercentage! / 100.0);
        if (minWidth != null && minWidth! > width)  width = minWidth;
        if (maxWidth != null && maxWidth! < width!) width = maxWidth;
      }

      // set the width
      _width?.set(width, notify: false);
    }

    // adjust the height
    if (height != null && height! >= 100000) _heightPercentage = (height!/1000000);
    if (_heightPercentage != null)
    {
      double? height;
      double? maxheight = getMaxWidth();
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