import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:fml/helper/string.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observable.dart';
import 'package:fml/observable/observables/double.dart';
import 'package:fml/observable/scope.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/layout/layout_model.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
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

  // returns the constraints as calculated
  // by walking up the model tree and
  // examining system and local model constraints
  Constraints calculate()
  {
    Constraints constraints = Constraints();

    // calculates global constraints
    Constraints global = Constraints();
    global.minWidth  = calculatedMinWidth;
    global.maxWidth  = calculatedMaxWidth;
    global.minHeight = calculatedMinHeight;
    global.maxHeight = calculatedMaxHeight;

    // constraints as specified on the model template
    Constraints model = getModelConstraints();

    // WIDTH
    constraints.width     = model.width;
    constraints.minWidth  = model.width  ?? model.minWidth  ?? global.minWidth;
    constraints.maxWidth  = model.width  ?? model.maxWidth  ?? global.maxWidth;

    // ensure not negative
    if (constraints.minWidth == null || constraints.minWidth!.isNegative) constraints.minWidth = null;
    if (constraints.maxWidth == null || constraints.maxWidth!.isNegative) constraints.maxWidth = null;

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
    if (constraints.minHeight != null && constraints.minHeight!.isNegative) constraints.minHeight = null;
    if (constraints.maxHeight != null && constraints.maxHeight!.isNegative) constraints.maxHeight = null;

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

      if (_width == null) _width = DoubleObservable(Binding.toKey(id, 'width'), v, scope: scope, listener: listener, setter: _widthSetter);
      else if (v != null) _width!.set(v);
    }
  }
  double? get width => _width?.get();
  setWidth(double? v, {bool notify = false})
  {
    if (_width == null) _width = DoubleObservable(Binding.toKey(id, 'width'), null, scope: scope, listener: listener, setter: _widthSetter);
    _width?.set(v, notify: notify);
  }

  // this routine enforces the min and max width
  // constraints from the template
  dynamic _widthSetter(dynamic value)
  {
    if (S.isNumber(value))
    {
      double v = S.toDouble(value)!;
      if (minWidth != null && v < minWidth!) v = minWidth!;
      if (maxWidth != null && v > maxWidth!) v = maxWidth!;
      if (v.isNegative) v = 0;
      if (v != S.toDouble(value)) value = v;
    }
    return value;
  }

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
      else _heightPercentage = null;

      if (v != null && v.runtimeType == String && v.contains('%'))
      {
        String s = v;
        v = s.replaceAll('%', '000000');
      }

      if (_height == null) _height = DoubleObservable(Binding.toKey(id, 'height'), v, scope: scope, listener: listener, setter: _heightSetter);
      else if (v != null) _height!.set(v);
    }
  }
  double? get height => _height?.get();
  setHeight(double? v, {bool notify = false})
  {
    if (_height == null) _height = DoubleObservable(Binding.toKey(id, 'height'), null, scope: scope, listener: listener, setter: _heightSetter);
    _height?.set(v, notify:notify);
  }

  // this routine enforces the min and max height
  // constraints from the template
  dynamic _heightSetter(dynamic value)
  {
    if (S.isNumber(value))
    {
      double v = S.toDouble(value)!;
      if (minHeight != null && v < minHeight!) v = minHeight!;
      if (maxHeight != null && v > maxHeight!) v = maxHeight!;
      if (v.isNegative) v = 0;
      if (v != S.toDouble(value)) value = v;
    }
    return value;
  }

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
  double get calculatedMinWidth
  {
    double? v;
    if (system.minWidth != null) v = system.minWidth;
    if (v == null && parent is ViewableWidgetModel) v = (parent as ViewableWidgetModel).calculatedMinWidth;
    return v ?? 0;
  }

  /// walks up the model tree looking for
  /// the first system non-null maxWidth value
  double get calculatedMaxWidth
  {
    if (system.maxWidth != null) return system.maxWidth!;
    if (this.width      != null) return this.width!;
    if (this.maxWidth   != null) return this.maxWidth!;
    if (this.parent is ViewableWidgetModel)
    {
      var parent = (this.parent as ViewableWidgetModel);
      if (parent.width != null) return max(parent.width! - parent.horizontalPadding,0);
      return parent.calculatedMaxWidth;
    }
    return double.infinity;
  }

  // returns the max width or screen width if unconstrained
  double get calculatedMaxWidthOrDefault
  {
    var v = calculatedMaxWidth;
    if (v == double.infinity) v = System().screenwidth.toDouble();
    return v;
  }

  /// walks up the model tree looking for
  /// the first system non-null minHeight value
  double get calculatedMinHeight
  {
    double? v;
    if (system.minHeight != null) v = system.minHeight;
    if (v == null && parent is ViewableWidgetModel) v = (parent as ViewableWidgetModel).calculatedMinHeight;
    return v ?? 0;
  }

  /// walks up the model tree looking for
  /// the first system non-null maxHeight value
  double get calculatedMaxHeight
  {
    if (system.maxHeight != null) return system.maxHeight!;
    if (this.height      != null) return this.height!;
    if (this.maxHeight   != null) return this.maxHeight!;
    if (this.parent is ViewableWidgetModel)
    {
      var parent = (this.parent as ViewableWidgetModel);
      if (parent.height != null) return max(parent.height! - parent.verticalPadding,0);
      return parent.calculatedMaxHeight;
    }
    return double.infinity;
  }

  // returns the max height or screen height if unconstrained
  double get calculatedMaxHeightOrDefault
  {
    var v = calculatedMaxHeight;
    if (v == double.infinity) v = System().screenheight.toDouble();
    return v;
  }

  setLayoutConstraints(BoxConstraints constraints)
  {
    // set the system constraints
    system.minWidth  = constraints.minWidth;
    system.maxWidth  = constraints.maxWidth;
    system.minHeight = constraints.minHeight;
    system.maxHeight = constraints.maxHeight;

    LayoutModel? layoutModel = parent is LayoutModel ? (parent as LayoutModel) : null;

    LayoutType layout = LayoutType.none;
    if (layoutModel != null) layout = layoutModel.layoutType;

    // adjust the width if defined as a percentage
    if (width != null && width! >= 100000) _widthPercentage = (width!/1000000);
    if (_widthPercentage != null)
    {
      // calculate the width
      int? width = (calculatedMaxWidthOrDefault * (_widthPercentage!/100.0)).floor();

      // adjust min and max widths
      if (minWidth != null && minWidth! > width)  width = minWidth?.toInt();
      if (maxWidth != null && maxWidth! < width!) width = maxWidth?.toInt();

      // set the width
      if (layout != LayoutType.row) setWidth(width?.toDouble());
    }

    // adjust the height if defined as a percentage
    if (height != null && height! >= 100000) _heightPercentage = (height!/1000000);
    if (_heightPercentage != null)
    {
      // calculate the height
      int? height = (calculatedMaxHeightOrDefault * (_heightPercentage!/100.0)).floor();

      // adjust min and max heights
      if (minHeight != null && minHeight! > height)  height = minHeight?.toInt();
      if (maxHeight != null && maxHeight! < height!) height = maxHeight?.toInt();

      // set the height
      if (layout != LayoutType.column) setHeight(height?.toDouble());
    }
  }
}