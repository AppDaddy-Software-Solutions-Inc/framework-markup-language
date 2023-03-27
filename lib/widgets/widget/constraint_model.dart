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

  /// walks up the model tree looking for
  /// the first system non-null minWidth value
  double? getSystemMinWidth()
  {
    double? v;
    if (_systemConstraints.minWidth != null && _systemConstraints.minWidth != double.infinity) v = _systemConstraints.minWidth;
    if (v == null && parent is ViewableWidgetModel) v = (parent as ViewableWidgetModel).getSystemMinWidth();
    return v;
  }

  /// walks up the model tree looking for
  /// the first system non-null maxWidth value
  double? getSystemMaxWidth()
  {
    double? v;
    if (_systemConstraints.maxWidth != null && _systemConstraints.maxWidth != double.infinity) v = _systemConstraints.maxWidth;
    if (v == null && this.parent is ViewableWidgetModel)
    {
      ViewableWidgetModel parent = (this.parent as ViewableWidgetModel);
      if (_widthPercentage == null)
      {
        var hpad = _getHorizontalPadding(parent.paddings, parent.padding, parent.padding2, parent.padding3, parent.padding4);
        if (parent.width == null)
        {
           var w = parent.getSystemMaxWidth();
           if (w != null) v = w - hpad;
        }
        else v = parent.width! - hpad;
      }
      else v = parent.width ?? parent.getSystemMaxWidth();
    }
    return v;
  }

  /// walks up the model tree looking for
  /// the first system non-null minHeight value
  double? getSystemMinHeight()
  {
    double? v;
    if (_systemConstraints.minHeight != null && _systemConstraints.minHeight != double.infinity) v = _systemConstraints.minHeight;
    if (v == null && parent is ViewableWidgetModel) v = (parent as ViewableWidgetModel).getSystemMinHeight();
    return v;
  }

  /// walks up the model tree looking for
  /// the first system non-null maxHeight value
  double? getSystemMaxHeight()
  {
    double? v;
    if (_systemConstraints.maxHeight != null && _systemConstraints.maxHeight != double.infinity) v = _systemConstraints.maxHeight;
    if (v == null && parent is ViewableWidgetModel)
    {
      ViewableWidgetModel? parent = (this.parent as ViewableWidgetModel);
      if (_heightPercentage == null)
      {
        var vpad = _getVerticalPadding(parent.paddings, parent.padding, parent.padding2, parent.padding3, parent.padding4);
        if (parent.height == null)
        {
          var h = parent.getSystemMaxHeight();
          if (h != null) v = h - vpad;
        }
        else v = parent.height! - vpad;
      }
      else v = parent.height ?? parent.getSystemMaxHeight();
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
    constraint.minWidth  = width  ?? minWidth  ?? getSystemMinWidth();
    constraint.maxWidth  = width  ?? maxWidth  ?? getSystemMaxWidth();

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

    // HEIGHT
    constraint.height    = height;
    constraint.minHeight = height ?? minHeight ?? getSystemMinHeight();
    constraint.maxHeight = height ?? maxHeight ?? getSystemMaxHeight();

    // ensure not negative
    if (constraint.minHeight != null && constraint.minHeight! < 0) constraint.minHeight = 0;
    if (constraint.maxHeight != null && constraint.maxHeight! < 0) constraint.maxHeight = double.infinity;

    // ensure max > min
    if (constraint.minHeight! > constraint.maxHeight!)
    {
      if (maxHeight != null)
        constraint.minHeight = constraint.maxHeight;
      else constraint.maxHeight = constraint.minHeight;
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

  // sets the layout constraints and adjust the height & width accordingly
  void setSystemConstraints(BoxConstraints? constraints)
  {
    _systemConstraints.minWidth  = constraints?.minWidth;
    _systemConstraints.maxWidth  = constraints?.maxWidth;
    _systemConstraints.minHeight = constraints?.minHeight;
    _systemConstraints.maxHeight = constraints?.maxHeight;

    // adjust the width
    if (width != null && width! >= 100000) _widthPercentage = (width!/1000000);
    if (_widthPercentage != null)
    {
      // calculate the width
      double? width;
      double? maxwidth = getSystemMaxWidth();
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
      double? maxheight = getSystemMaxWidth();
      if (maxheight != null)
      {
        if (this.parent != null)
        {
          double vpadding = 0;
          ViewableWidgetModel? parent = (this.parent is ViewableWidgetModel) ? (this.parent as ViewableWidgetModel) : null;
          if (parent != null) vpadding = _getVerticalPadding(parent.paddings, parent.padding, parent.padding2, parent.padding3, parent.padding4);

          height = ((maxheight - vpadding) * (_heightPercentage! / 100.0));
          if (minHeight != null && minHeight! > height) height = minHeight ?? 0;
          if (maxHeight != null && maxHeight! < height) height = maxHeight;
        }
      }
      _height?.set(height, notify: false);
    }

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