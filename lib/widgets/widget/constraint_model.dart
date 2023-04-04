import 'package:flutter/cupertino.dart';
import 'package:fml/helper/string.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observable.dart';
import 'package:fml/observable/observables/double.dart';
import 'package:fml/observable/scope.dart';
import 'package:fml/widgets/column/column_model.dart';
import 'package:fml/widgets/row/row_model.dart';
import 'package:fml/widgets/widget/viewable_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'constraint.dart';

class ConstraintModel
{
  String? id;
  Scope? scope;
  OnChangeCallback? listener;
  WidgetModel? parent;

  // returns the constraints as specified
  // in the model template
  Constraints getModelConstraints()
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

  // constraints as specified
  // by the layoutBuilder()
  final Constraints system = Constraints();

  double? calculateMinWidth()  => _calculateMinWidth();
  double? calculateMaxWidth()  => _calculateMaxWidth();
  double? calculateMinHeight() => _calculateMinHeight();
  double? calculateMaxHeight() => _calculateMaxHeight();

  // returns the constraints as calculated
  // by walking up the model tree and
  // examining system and local model constraints
  Constraints calculate()
  {
    Constraints constraints = Constraints();

    // calculates global constraints
    Constraints global = Constraints();
    global.minWidth  = _calculateMinWidth();
    global.maxWidth  = _calculateMaxWidth();
    global.minHeight = _calculateMinHeight();
    global.maxHeight = _calculateMaxHeight();

    // constraints as specified on the model template
    Constraints model = getModelConstraints();

    // WIDTH
    constraints.width     = model.width;
    constraints.minWidth  = model.width  ?? model.minWidth  ?? global.minWidth;
    constraints.maxWidth  = model.width  ?? model.maxWidth  ?? global.maxWidth;

    // ensure not negative
    if (constraints.minWidth == null || constraints.minWidth! < 0) constraints.minWidth = null;
    if (constraints.maxWidth == null || constraints.maxWidth! < 0) constraints.maxWidth = null;

    // ensure max > min
    if (constraints.minWidth != null && constraints.maxWidth != null && constraints.minWidth! > constraints.maxWidth!)
    {
      var v = constraints.minWidth;
      constraints.minWidth = constraints.maxWidth;
      constraints.maxWidth = v;
    }

    // HEIGHT
    constraints.height    = model.height;
    constraints.minHeight = model.height ?? model.minHeight ?? global.minHeight;
    constraints.maxHeight = model.height ?? model.maxHeight ?? global.maxHeight;

    // ensure not negative
    if (constraints.minHeight != null && constraints.minHeight! < 0) constraints.minHeight = null;
    if (constraints.maxHeight != null && constraints.maxHeight! < 0) constraints.maxHeight = null;

    // ensure max > min
    if (constraints.minHeight != null && constraints.maxHeight != null && constraints.minHeight! > constraints.maxHeight!)
    {
      var v = constraints.minHeight;
      constraints.minHeight = constraints.maxHeight;
      constraints.maxHeight = v;
    }

    return constraints;
  }

  /// Local Constraints 
  /// 
  // width
  double? _widthPercentage;
  double? get pctWidth => _widthPercentage;
  setWidth(double? v) => _width?.set(v, notify: false);
  setMinWidth(double? v) => _minWidth?.set(v, notify: false);
  setMaxWidth(double? v) => _maxWidth?.set(v, notify: false);

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

  setHeight(double? v) => _height?.set(v, notify: false);
  setMinHeight(double? v) => _minHeight?.set(v, notify: false);
  setMaxHeight(double? v) => _maxHeight?.set(v, notify: false);

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

  ConstraintModel(this.id, this.scope, this.parent, this.listener);

  /// walks up the model tree looking for
  /// the first system non-null minWidth value
  double? _calculateMinWidth()
  {
    double? v;
    if (system.minWidth != null) v = system.minWidth;
    if (v == null && parent is ViewableWidgetModel) v = (parent as ViewableWidgetModel).calculateMinWidth();
    return v;
  }

  /// walks up the model tree looking for
  /// the first system non-null maxWidth value
  double? _calculateMaxWidth()
  {
    double? v;
    if (system.maxWidth != null) v = system.maxWidth;
    if (v == null && this.parent is ViewableWidgetModel)
    {      ViewableWidgetModel parent = (this.parent as ViewableWidgetModel);
      if (_widthPercentage == null)
      {
        var hpad = _getHorizontalPadding(parent.padding1, parent.padding2, parent.padding3, parent.padding4);
        if (parent.width == null)
        {
           var w = parent.calculateMaxHeight();
           if (w != null) v = w - hpad;
        }
        else v = parent.width! - hpad;
      }
      else v = parent.width ?? parent.calculateMaxWidth();
    }
    return v;
  }

  /// walks up the model tree looking for
  /// the first system non-null minHeight value
  double? _calculateMinHeight()
  {
    double? v;
    if (system.minHeight != null) v = system.minHeight;
    if (v == null && parent is ViewableWidgetModel) v = (parent as ViewableWidgetModel).calculateMinHeight();
    return v;
  }

  /// walks up the model tree looking for
  /// the first system non-null maxHeight value
  double? _calculateMaxHeight()
  {
    double? v;
    if (system.maxHeight != null) v = system.maxHeight;
    if (v == null && parent is ViewableWidgetModel)
    {
      ViewableWidgetModel? parent = (this.parent as ViewableWidgetModel);
      if (_heightPercentage == null)
      {
        var vpad = _getVerticalPadding(parent.padding1, parent.padding2, parent.padding3, parent.padding4);
        if (parent.height == null)
        {
          var h = parent.calculateMaxHeight();
          if (h != null) v = h - vpad;
        }
        else v = parent.height! - vpad;
      }
      else v = parent.height ?? parent.calculateMaxHeight();
    }
    return v;
  }

  double? _pctWidth(double percent)
  {
    double? pct;
    double? max = _calculateMaxWidth();
    if (max != null) pct = max * (percent/100.0);
    return pct;
  }

  double? _pctHeight(double percent)
  {
    double? pct;
    double? max = _calculateMaxHeight();
    if (max != null) pct = max * (percent/100.0);
    return pct;
  }
  
  static double _getVerticalPadding(double? padding1, double? padding2, double? padding3, double? padding4)
  {
    double padding = 0.0;
    double paddings = (padding1 ?? 0) + (padding2 ?? 0) + (padding3 ?? 0) + (padding4 ?? 0);

    if (paddings > 0)
    {
      // pad all
      if (paddings == 1) padding = (padding1 ?? 0) * 2;

      // pad directions v,h
      else if (paddings == 2) padding = (padding1 ?? 0) * 2;

      // pad sides top, right, bottom, left
      else if (paddings > 2) padding = (padding1 ?? 0)  + (padding3 ?? 0);
    }

    //should add up all of the padded siblings to do this.
    return padding;
  }

  static double _getHorizontalPadding(double? padding1, double? padding2, double? padding3, double? padding4)
  {
    double padding = 0.0;
    double paddings = (padding1 ?? 0) + (padding2 ?? 0) + (padding3 ?? 0) + (padding4 ?? 0);
    if (paddings > 0)
    {
      // pad all
      if (paddings == 1) padding = (padding1 ?? 0) * 2;

      // pad directions v,h
      else if (paddings == 2) padding = (padding2 ?? 0) * 2;

      // pad sides top, right, bottom, left
      else if (paddings > 2) padding = (padding2 ?? 0) + (padding4 ?? 0);
    }

    //should add up all of the padded siblings to do this.
    return padding;
  }

  setLayoutConstraints(BoxConstraints constraints)
  {
    // set the system constraints
    system.minWidth  = constraints.minWidth;
    system.maxWidth  = constraints.maxWidth;
    system.minHeight = constraints.minHeight;
    system.maxHeight = constraints.maxHeight;

    bool allowPercentWidthSizing = true;
    if (parent is RowModel)
    {
      var model = parent as RowModel;
      allowPercentWidthSizing = !model.performLayoutSizing;
    }

    bool allowPercentHeightSizing = true;
    if (parent is ColumnModel)
    {
      var model = parent as ColumnModel;
      allowPercentHeightSizing = !model.performLayoutSizing;
    }

    // adjust the width if defined as a percentage
    if (width != null && width! >= 100000) _widthPercentage = (width!/1000000);
    if (_widthPercentage != null && allowPercentWidthSizing)
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
      setWidth(width);
    }

    // adjust the min/max widths if defined as percentages
    if (_minWidthPercentage != null && allowPercentWidthSizing)
    {
      setMinWidth(_pctWidth(_minWidthPercentage!));
    }

    if (_maxWidthPercentage != null && allowPercentWidthSizing)
    {
      setMaxWidth(_pctWidth(_maxWidthPercentage!));
    }

    // adjust the height if defined as a percentage
    if (height != null && height! >= 100000) _heightPercentage = (height!/1000000);
    if (_heightPercentage != null && allowPercentHeightSizing)
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
      setHeight(height);
    }

    // adjust the min/max heights
    if (_minHeightPercentage != null && allowPercentHeightSizing)
    {
      setMinHeight(_pctHeight(_minHeightPercentage!));
    }

    if (_maxHeightPercentage != null && allowPercentHeightSizing)
    {
      setMaxHeight(_pctHeight(_maxHeightPercentage!));
    }
  }
}