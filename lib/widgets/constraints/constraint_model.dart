import 'package:flutter/cupertino.dart';
import 'package:fml/helper/string.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observable.dart';
import 'package:fml/observable/observables/double.dart';
import 'package:fml/observable/scope.dart';
import 'package:fml/widgets/box/box_model.dart';
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
  setWidth(double? v, {bool notify = false})
  {
    if (_width == null) _width = DoubleObservable(Binding.toKey(id, 'width'), null, scope: scope, listener: listener);
    _width?.set(v, notify: notify);
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
  setHeight(double? v, {bool notify = false})
  {
    if (_height == null) _height = DoubleObservable(Binding.toKey(id, 'height'), null, scope: scope, listener: listener);
    _height?.set(v, notify:notify);
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
    double? width;
    if (system.maxWidth != null) width = system.maxWidth;
    if (width == null && this.parent is ViewableWidgetModel)
    {
      ViewableWidgetModel parent = (this.parent as ViewableWidgetModel);
      if (_widthPercentage == null)
      {
        var margins = (parent.marginRight ?? 0) + (parent.marginLeft ?? 0);
        var borders = 0.0;
        var padding = 0.0;
        if (parent is BoxModel)
        {
          borders = borders + (parent.borderwidth * 2);
          padding = padding + (parent.paddingLeft ?? 0) + (parent.paddingRight ?? 0);
        }

        if (parent.width == null)
        {
           var max = parent.calculateMaxHeight();
           if (max != null) width = max - margins - borders - padding;
        }
        else width = parent.width! - margins - borders - padding;
      }
      else width = parent.width ?? parent.calculateMaxWidth();
    }
    return width;
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
    double? height;
    if (system.maxHeight != null) height = system.maxHeight;
    if (height == null && parent is ViewableWidgetModel)
    {
      ViewableWidgetModel? parent = (this.parent as ViewableWidgetModel);
      if (_heightPercentage == null)
      {
        var margins = (parent.marginTop ?? 0) + (parent.marginBottom ?? 0);
        var borders = 0.0;
        var padding = 0.0;
        if (parent is BoxModel)
        {
          borders = borders + (parent.borderwidth * 2);
          padding = padding + (parent.paddingTop ?? 0) + (parent.paddingBottom ?? 0);
        }

        if (parent.height == null)
        {
          var max = parent.calculateMaxHeight();
          if (max != null) height = max - margins - borders - padding;
        }
        else height = parent.height! - margins - borders - padding;
      }
      else height = parent.height ?? parent.calculateMaxHeight();
    }
    return height;
  }

  int? _widthAsPercentage(double percent)
  {
    var max = _calculateMaxWidth();
    if (max != null)
         return (max * (percent/100.0)).floor();
    else return null;
  }

  int? _heightAsPercentage(double percent)
  {
    var max = _calculateMaxHeight();
    if (max != null)
         return (max * (percent/100.0)).floor();
    else return null;
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
      int? width = _widthAsPercentage(_widthPercentage!);

      // adjust min and max widths
      if (width != null)
      {
        if (minWidth != null && minWidth! > width)  width = minWidth?.toInt();
        if (maxWidth != null && maxWidth! < width!) width = maxWidth?.toInt();
      }

      // set the width
      if (layout != LayoutType.row) setWidth(width?.toDouble());
    }

    // adjust the height if defined as a percentage
    if (height != null && height! >= 100000) _heightPercentage = (height!/1000000);
    if (_heightPercentage != null)
    {
      // calculate the height
      int? height = _heightAsPercentage(_heightPercentage!);

      // adjust min and max heights
      if (height != null)
      {
        if (minHeight != null && minHeight! > height)  height = minHeight?.toInt();
        if (maxHeight != null && maxHeight! < height!) height = maxHeight?.toInt();
      }

      // set the height
      if (layout != LayoutType.column) setHeight(height?.toDouble());
    }
  }
}