import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:fml/helper/string.dart';
import 'package:fml/helper/xml.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/double.dart';
import 'package:fml/observable/scope.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/scroller/scroller_model.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:xml/xml.dart';
import 'constraint.dart';

class ConstraintModel extends WidgetModel
{
  ConstraintModel(WidgetModel? parent, String? id, {Scope? scope}) : super(parent, id, scope: scope);

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);

    // set constraints
    width     = Xml.get(node: xml, tag: 'width');
    height    = Xml.get(node: xml, tag: 'height');
    minWidth  = Xml.get(node: xml, tag: 'minwidth');
    maxWidth  = Xml.get(node: xml, tag: 'maxwidth');
    minHeight = Xml.get(node: xml, tag: 'minheight');
    maxHeight = Xml.get(node: xml, tag: 'maxheight');
  }


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
  Constraints get calculated
  {
    Constraints constraints = Constraints();

    // calculated constraints
    Constraints calculated = Constraints();
    calculated.minWidth  = myMinWidth;
    calculated.maxWidth  = myMaxWidth;
    calculated.minHeight = myMinHeight;
    calculated.maxHeight = myMaxHeight;

    // constraints as specified on the model template
    Constraints model = getModelConstraints();

    // WIDTH
    constraints.width     = model.width;
    constraints.minWidth  = model.width  ?? model.minWidth  ?? calculated.minWidth;
    constraints.maxWidth  = model.width  ?? model.maxWidth  ?? calculated.maxWidth;

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
    constraints.minHeight = model.height ?? model.minHeight ?? calculated.minHeight;
    constraints.maxHeight = model.height ?? model.maxHeight ?? calculated.maxHeight;

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
    if (_width != null)
    {
      _width!.set(v);
    }
    else if (v != null)
    {
      _width = DoubleObservable(Binding.toKey(id, 'width'), v, scope: scope, listener: onPropertyChange, setter: _widthSetter);
    }
  }
  double? get width => _width?.get();

  // this routine set the width silently and resets the
  // fixedWidth property
  setWidth(double? v)
  {
    // create the _width observable if it
    // hasn't already been created
    if (_width == null)
    {
      _width = DoubleObservable(Binding.toKey(id, 'width'), null, scope: scope, setter: _widthSetter);
      _width!.registerListener(onPropertyChange);
    }

    // we must remember these settings since they are
    // changed by the _widthSetter() and need to be restored
    // after assigning _width a value
    var pct = _widthPercentage;

    // set the width
    _width?.set(v, notify: false);

    // restore original settings
    if (pct != null) _widthPercentage = pct;
  }

  // this routine enforces the min and max width
  // constraints from the template
  dynamic _widthSetter(dynamic value)
  {
    // is the value a percentage?
    _widthPercentage = null;
    if (S.isPercentage(value))
    {
      _widthPercentage = S.toDouble(value.split("%")[0]);
      value = null;
    }

    // is the value a number?
    if (S.isNumber(value))
    {
      double v = S.toDouble(value)!;

      // must be greater than minWidth
      if (minWidth != null && v < minWidth!) v = minWidth!;

      // must be greater than maxWidth
      if (maxWidth != null && v > maxWidth!) v = maxWidth!;

      // cannot be negative
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
    if (_height != null)
    {
      _height!.set(v);
    }
    else if (v != null)
    {
      _height = DoubleObservable(Binding.toKey(id, 'height'), v, scope: scope, listener: onPropertyChange, setter: _heightSetter);
    }
  }
  double? get height => _height?.get();

  setHeight(double? v)
  {
    // create the _height observable if it
    // hasn't already been created
    if (_height == null)
    {
      _height = DoubleObservable(Binding.toKey(id, 'height'), null, scope: scope, setter: _heightSetter);
      _height!.registerListener(onPropertyChange);
    }

    // we must remember these settings since they are
    // changed by the _heightSetter() and need to be restored
    // after assigning _height a value
    var pct = _heightPercentage;

    // set the height
    _height?.set(v, notify:false);

    // restore original settings
    if (pct != null) _heightPercentage = pct;
  }

  // this routine enforces the min and max height
  // constraints from the template
  dynamic _heightSetter(dynamic value)
  {
    // is the value a percentage?
    _heightPercentage = null;
    if (S.isPercentage(value))
    {
      _heightPercentage = S.toDouble(value.split("%")[0]);
      value = null;
    }

    // is the value a number?
    if (S.isNumber(value))
    {
      double v = S.toDouble(value)!;

      // must be greater than minHeight
      if (minHeight != null && v < minHeight!) v = minHeight!;

      // must be less than maxHeight
      if (maxHeight != null && v > maxHeight!) v = maxHeight!;

      // cannot be negative
      if (v.isNegative) v = 0;

      if (v != S.toDouble(value)) value = v;
    }

    return value;
  }

  // min width
  double? _minWidthPercentage;
  double? get minWidthPercentage => _minWidthPercentage;
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
      else {
        _minWidthPercentage = null;
      }
      if (_minWidth == null) {
        _minWidth = DoubleObservable(Binding.toKey(id, 'minWidth'), v, scope: scope, listener: onPropertyChange);
      } else if (v != null) {
        _minWidth!.set(v);
      }
    }
  }
  double? get minWidth => _minWidth?.get();

  // max width
  double? _maxWidthPercentage;
  double? get maxWidthPercentage => _maxWidthPercentage;
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
      else {
        _maxWidthPercentage = null;
      }
      if (_maxWidth == null) {
        _maxWidth = DoubleObservable(Binding.toKey(id, 'maxwidth'), v, scope: scope, listener: onPropertyChange);
      } else if (v != null) {
        _maxWidth!.set(v);
      }
    }
  }
  double? get maxWidth => _maxWidth?.get();

  // min height
  double? _minHeightPercentage;
  double? get minHeightPercentage => _minHeightPercentage;
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
      else {
        _minHeightPercentage = null;
      }
      if (_minHeight == null) {
        _minHeight = DoubleObservable(Binding.toKey(id, 'minheight'), v, scope: scope, listener: onPropertyChange);
      } else if (v != null) {
        _minHeight!.set(v);
      }
    }
  }
  double? get minHeight => _minHeight?.get();

  // max height
  double? _maxHeightPercentage;
  double? get maxHeightPercentage => _maxHeightPercentage;
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
      else {
        _maxHeightPercentage = null;
      }
      if (_maxHeight == null) {
        _maxHeight = DoubleObservable(Binding.toKey(id, 'maxheight'), v, scope: scope, listener: onPropertyChange);
      } else if (v != null) {
        _maxHeight!.set(v);
      }
    }
  }
  double? get maxHeight => _maxHeight?.get();

  /// walks up the model tree looking for
  /// the first system non-null minWidth value
  double get myMinWidth
  {
    double? v;
    if (system.minWidth != null) v = system.minWidth;
    if (v == null && parent is ViewableWidgetModel) v = (parent as ViewableWidgetModel).myMinWidth;
    return v ?? 0;
  }

  static double ancestorMaxWidth(WidgetModel? widget, {bool forPercent = false})
  {
    if (widget is ViewableWidgetModel)
    {
      if (widget is ScrollerModel && widget.layoutType == LayoutType.row && !forPercent) return double.infinity;
      if (widget.system.maxWidth  != null) return max(widget.system.maxWidth! - widget.horizontalPadding,0);
      if (widget.width            != null) return max(widget.width!           - widget.horizontalPadding,0);
      if (widget.maxWidth         != null) return max(widget.maxWidth!        - widget.horizontalPadding,0);
      return ancestorMaxWidth(widget.parent);
    }
    else {
      return double.infinity;
    }
  }

  /// walks up the model tree looking for
  /// the first system non-null maxWidth value
  double get myMaxWidth
  {
    if (system.maxWidth  != null) return system.maxWidth!;
    if (width       != null) return width!;
    if (maxWidth    != null) return maxWidth!;
    return ancestorMaxWidth(parent);
  }

  // if the widgets own constraints specify a maxWidth then that is used
  // otherwise it gets the maxWidth from its parent walking up the model tree
  double get calculatedMaxWidthForPercentage
  {
    double maxWidth = system.maxWidth ?? ancestorMaxWidth(parent, forPercent: true);
    if (maxWidth == double.infinity) maxWidth = System().screenwidth.toDouble();
    return maxWidth;
  }

  // returns the max width or screen width if unconstrained
  double get calculatedMaxWidthOrDefault
  {
    var v = myMaxWidth;
    if (v == double.infinity) v = System().screenwidth.toDouble();
    return v;
  }

  /// walks up the model tree looking for
  /// the first system non-null minHeight value
  double get myMinHeight
  {
    double? v;
    if (system.minHeight != null) v = system.minHeight;
    if (v == null && parent is ViewableWidgetModel) v = (parent as ViewableWidgetModel).myMinHeight;
    return v ?? 0;
  }

  static double ancestorMaxHeight(WidgetModel? widget, double padding, {bool forPercent = false})
  {
    if (widget is ViewableWidgetModel)
    {
      padding = padding + widget.verticalPadding;

      if (widget is ScrollerModel && widget.layoutType == LayoutType.column && !forPercent) return double.infinity;
      if (widget.system.maxHeight != null) return max(widget.system.maxHeight! - padding,0);
      if (widget.height           != null) return max(widget.height!           - padding,0);
      if (widget.maxHeight        != null) return max(widget.maxHeight!        - padding,0);

      return ancestorMaxHeight(widget.parent, padding);
    }
    else {
      return double.infinity;
    }
  }

  /// walks up the model tree looking for
  /// the first system non-null maxHeight value
  double get myMaxHeight
  {
    if (system.maxHeight != null) return system.maxHeight!;
    if (height      != null) return height!;
    if (maxHeight   != null) return maxHeight!;
    return ancestorMaxHeight(parent, 0);
  }

  // if the widgets own constraints specify a maxHeight then that is used
  // otherwise it gets the maxHeight from its parent walking up the model tree
  double get calculatedMaxHeightForPercentage
  {
    double maxHeight = system.maxHeight ?? ancestorMaxHeight(parent, 0, forPercent: true);
    if (maxHeight == double.infinity) maxHeight = System().screenheight.toDouble();
    return maxHeight;
  }

  // returns the max height or screen height if unconstrained
  double get calculatedMaxHeightOrDefault
  {
    var v = myMaxHeight;
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

    LayoutType parentLayout = LayoutType.none;
    if (parent is BoxModel) parentLayout = (parent as BoxModel).layoutType;

    // adjust the width if defined as a percentage
    if (widthPercentage != null && parentLayout != LayoutType.row)
    {
      // calculate the width
      int? width = (calculatedMaxWidthForPercentage * (widthPercentage!/100.0)).floor();

      // adjust min and max widths
      if (minWidth != null && minWidth! > width)  width = minWidth?.toInt();
      if (maxWidth != null && maxWidth! < width!) width = maxWidth?.toInt();

      // set the width
      setWidth(width?.toDouble());
    }

    // adjust the height if defined as a percentage
    if (_heightPercentage != null && parentLayout != LayoutType.column)
    {
      // calculate the height
      int? height = (calculatedMaxHeightForPercentage * (_heightPercentage!/100.0)).floor();

      // adjust min and max heights
      if (minHeight != null && minHeight! > height)  height = minHeight?.toInt();
      if (maxHeight != null && maxHeight! < height!) height = maxHeight?.toInt();

      // set the height
      setHeight(height?.toDouble());
    }
  }
}