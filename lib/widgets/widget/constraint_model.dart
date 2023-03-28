import 'package:flutter/cupertino.dart';
import 'package:fml/helper/string.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observable.dart';
import 'package:fml/observable/observables/double.dart';
import 'package:fml/observable/scope.dart';
import 'package:fml/widgets/widget/viewable_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';

import 'constraint.dart';

class ConstraintModel
{
  String? id;
  Scope? scope;
  OnChangeCallback? listener;
  WidgetModel? parent;

  // holds the system layout constraints
  Constraints _systemConstraints = Constraints();

  ConstraintModel(this.id, this.scope, this.parent, this.listener);

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
  double? _minWidthPercentage;
  DoubleObservable? _minWidth;
  set minWidth(dynamic v)
  {
    if (v != null)
    {
      if (S.isPercentage(v))
      {
        _minWidthPercentage = S.toDouble(v.split("%")[0]);
        v = null;
      }
      else _minWidthPercentage = null;
      if (_minWidth == null) _minWidth = DoubleObservable(Binding.toKey(id, 'minWidth'), v, scope: scope, listener: listener);
      else if (v != null) _minWidth!.set(v);
    }
  }
  double? get minWidth => _minWidth?.get();

  // max width
  double? _maxWidthPercentage;
  DoubleObservable? _maxWidth;
  set maxWidth(dynamic v)
  {
    if (v != null)
    {
      if (S.isPercentage(v))
      {
        _maxWidthPercentage = S.toDouble(v.split("%")[0]);
        v = null;
      }
      else _maxWidthPercentage = null;
      if (_maxWidth == null) _maxWidth = DoubleObservable(Binding.toKey(id, 'maxwidth'), v, scope: scope, listener: listener);
      else if (v != null) _maxWidth!.set(v);
    }
  }
  double? get maxWidth => _maxWidth?.get();

  // min height
  double? _minHeightPercentage;
  DoubleObservable? _minHeight;
  set minHeight(dynamic v)
  {
    if (v != null)
    {
      if (S.isPercentage(v))
      {
        _minHeightPercentage = S.toDouble(v.split("%")[0]);
        v = null;
      }
      else _minHeightPercentage = null;
      if (_minHeight == null) _minHeight = DoubleObservable(Binding.toKey(id, 'minheight'), v, scope: scope, listener: listener);
      else if (v != null) _minHeight!.set(v);
    }
  }
  double? get minHeight => _minHeight?.get();

  // max height
  double? _maxHeightPercentage;
  DoubleObservable? _maxHeight;
  set maxHeight(dynamic v)
  {
    if (v != null)
    {
      if (S.isPercentage(v))
      {
        _maxHeightPercentage = S.toDouble(v.split("%")[0]);
        v = null;
      }
      else _maxHeightPercentage = null;
      if (_maxHeight == null) _maxHeight = DoubleObservable(Binding.toKey(id, 'maxheight'), v, scope: scope, listener: listener);
      else if (v != null) _maxHeight!.set(v);
    }
  }
  double? get maxHeight => _maxHeight?.get();
  
  /// walks up the model tree looking for
  /// the first system non-null minWidth value
  double? getGlobalMinWidth()
  {
    double? v;
    if (_systemConstraints.minWidth != null) v = _systemConstraints.minWidth;
    if (v == null && parent is ViewableWidgetModel) v = (parent as ViewableWidgetModel).globalMinWidth;
    return v;
  }

  /// walks up the model tree looking for
  /// the first system non-null maxWidth value
  double? getGlobalMaxWidth()
  {
    double? v;
    if (_systemConstraints.maxWidth != null) v = _systemConstraints.maxWidth;
    if (v == null && this.parent is ViewableWidgetModel)
    {
      ViewableWidgetModel parent = (this.parent as ViewableWidgetModel);
      if (_widthPercentage == null)
      {
        var hpad = _getHorizontalPadding(parent.paddings, parent.padding, parent.padding2, parent.padding3, parent.padding4);
        if (parent.width == null)
        {
           var w = parent.globalMaxWidth;
           if (w != null) v = w - hpad;
        }
        else v = parent.width! - hpad;
      }
      else v = parent.width ?? parent.globalMaxWidth;
    }
    return v;
  }

  /// walks up the model tree looking for
  /// the first system non-null minHeight value
  double? getGlobalMinHeight()
  {
    double? v;
    if (_systemConstraints.minHeight != null) v = _systemConstraints.minHeight;
    if (v == null && parent is ViewableWidgetModel) v = (parent as ViewableWidgetModel).globalMinHeight;
    return v;
  }

  /// walks up the model tree looking for
  /// the first system non-null maxHeight value
  double? getGlobalMaxHeight()
  {
    double? v;
    if (_systemConstraints.maxHeight != null) v = _systemConstraints.maxHeight;
    if (v == null && parent is ViewableWidgetModel)
    {
      ViewableWidgetModel? parent = (this.parent as ViewableWidgetModel);
      if (_heightPercentage == null)
      {
        var vpad = _getVerticalPadding(parent.paddings, parent.padding, parent.padding2, parent.padding3, parent.padding4);
        if (parent.height == null)
        {
          var h = parent.globalMaxHeight;
          if (h != null) v = h - vpad;
        }
        else v = parent.height! - vpad;
      }
      else v = parent.height ?? parent.globalMaxHeight;
    }
    return v;
  }

  // walks up the tree
  // blending the system and user defined
  // constraints
  Constraints getGlobalConstraints()
  {
    Constraints constraint = Constraints();

    // WIDTH
    constraint.width     = width;
    constraint.minWidth  = width  ?? minWidth  ?? getGlobalMinWidth();
    constraint.maxWidth  = width  ?? maxWidth  ?? getGlobalMaxWidth();

    // ensure not negative
    if (constraint.minWidth == null || constraint.minWidth! < 0) constraint.minWidth = null;
    if (constraint.maxWidth == null || constraint.maxWidth! < 0) constraint.maxWidth = null;

    // ensure max > min
    if (constraint.minWidth != null && constraint.maxWidth != null && constraint.minWidth! > constraint.maxWidth!)
    {
      var v = constraint.minWidth;
      constraint.minWidth = constraint.maxWidth;
      constraint.maxWidth = v;
    }

    // HEIGHT
    constraint.height    = height;
    constraint.minHeight = height ?? minHeight ?? getGlobalMinHeight();
    constraint.maxHeight = height ?? maxHeight ?? getGlobalMaxHeight();

    // ensure not negative
    if (constraint.minHeight != null && constraint.minHeight! < 0) constraint.minHeight = null;
    if (constraint.maxHeight != null && constraint.maxHeight! < 0) constraint.maxHeight = null;

    // ensure max > min
    if (constraint.minHeight != null && constraint.maxHeight != null && constraint.minHeight! > constraint.maxHeight!)
    {
      var v = constraint.minHeight;
      constraint.minHeight = constraint.maxHeight;
      constraint.maxHeight = v;
    }

    return constraint;
  }

  // returns the constraints as specified
  // in the template
  Constraints getLocalConstraints()
  {
    Constraints constraint = Constraints();
    constraint.width     = width;
    constraint.minWidth  = minWidth;
    constraint.maxWidth  = maxWidth;

    constraint.height    = height;
    constraint.minHeight = minHeight;
    constraint.maxHeight = maxHeight;
    return constraint;
  }

  // returns the constraints as specified
  // by the system in LayoutBuilder()
  Constraints getSystemConstraints()
  {
    Constraints constraint = Constraints();
    constraint.minWidth  = _systemConstraints.minWidth;
    constraint.maxWidth  = _systemConstraints.maxWidth;
    constraint.minHeight = _systemConstraints.minHeight;
    constraint.maxHeight = _systemConstraints.maxHeight;
    return constraint;
  }

  // sets the layout constraints and adjust the height & width accordingly
  void setSystemConstraints(BoxConstraints? constraints)
  {
    // set the system constraints
    _systemConstraints.minWidth  = constraints?.minWidth;
    _systemConstraints.maxWidth  = constraints?.maxWidth;
    _systemConstraints.minHeight = constraints?.minHeight;
    _systemConstraints.maxHeight = constraints?.maxHeight;

    // adjust the width if defined as a percentage
    if (width != null && width! >= 100000) _widthPercentage = (width!/1000000);
    if (_widthPercentage != null)
    {
      // calculate the width
      double? width = _pctWidth(_widthPercentage!);

      // adjust min and max widths
      if (width != null)
      {
        if (minWidth != null && minWidth! > width)  width = minWidth;
        if (maxWidth != null && maxWidth! < width!) width = maxWidth;
      }

      // set the width
      _width?.set(width, notify: false);
    }

    // adjust the min/max widths if defined as percentages
    if (_minWidthPercentage != null) _minWidth?.set(_pctWidth(_minWidthPercentage!), notify: false);
    if (_maxWidthPercentage != null) _maxWidth?.set(_pctWidth(_maxWidthPercentage!), notify: false);

    // adjust the height if defined as a percentage
    if (height != null && height! >= 100000) _heightPercentage = (height!/1000000);
    if (_heightPercentage != null)
    {
      // calculate the height
      double? height = _pctHeight(_heightPercentage!);

      // adjust min and max heights
      if (height != null)
      {
        if (minHeight != null && minHeight! > height)  height = minHeight;
        if (maxHeight != null && maxHeight! < height!) height = maxHeight;
      }

      // set the height
      _height?.set(height, notify: false);
    }

    // adjust the min/max heights
    if (_minHeightPercentage != null) _minHeight?.set(_pctHeight(_minHeightPercentage!), notify: false);
    if (_maxHeightPercentage != null) _maxHeight?.set(_pctHeight(_maxHeightPercentage!), notify: false);
  }

  double? _pctWidth(double percent)
  {
    double? pct;
    double? max = getGlobalMaxWidth();
    if (max != null) pct = max * (percent/100.0);
    return pct;
  }

  double? _pctHeight(double percent)
  {
    double? pct;
    double? max = getGlobalMaxHeight();
    if (max != null) pct = max * (percent/100.0);
    return pct;
  }
  
  static double _getVerticalPadding(int paddings, double? padding, double padding2, double padding3, double padding4)
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

  static double _getHorizontalPadding(int paddings, double? padding, double padding2, double padding3, double padding4)
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